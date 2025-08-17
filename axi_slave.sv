class axi_slave extends uvm_driver#(axi_tx);
  `uvm_component_utils(axi_slave)
  `NEW_COMP
  logic [3:0]awid_t[16];
  logic [`addr_width-1:0]awaddr_t[16];
  logic [3:0]awlen_t[16];
  logic [2:0]awsize_t[16];
  logic [1:0]awburst_t[16];
  logic [1:0]awlock_t[16];
  logic [1:0]awcache_t[16];
  logic [1:0]awprot_t[16];
  bit flag_w=0;
  bit [3:0]arid_t[16];
  bit [`addr_width-1:0]araddr_t[16];
  bit[3:0]arlen_t[16];
  bit[2:0]arsize_t[16];
  bit[1:0]arburst_t[16];
  bit[1:0]arlock_t[16];
  bit[1:0]arcache_t[16];
  bit[1:0]arprot_t[16];
  bit [3:0]w_incr,r_incr; //write incr, read_incr
  virtual axi_intf.slave_mp vif;
  bit[`addr_width-1:0] lower_boundary[16],upper_boundary[16],low[16],up[16];
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual axi_intf)::get(this,"","vif",vif))
      $display("vif not recieved");
  endfunction
  bit[`data_width-1:0] temp_data,temp_data_fixed1,temp_data_fixed;
  bit [7:0] memory[int];
  int addr_track=0;
  bit[7:0] temp_que[$];
  int temp_addr;
  int flag=0;
  int lower,upper;
  int fifo_counter;
  bit[`addr_width-1:0]temp_fixed_addr;
  bit[`data_width-1:0]fixed_fifo[*][*];
  task run_phase(uvm_phase phase);  
    forever begin //{ 
      @(vif.slave_cb);
      if(vif.slave_cb.awvalid==1'b1) begin //{ 
        vif.slave_cb.awready <= 1'b1;
        awid_t[vif.slave_cb.awid]=vif.slave_cb.awid;
        awaddr_t[vif.slave_cb.awid]=vif.slave_cb.awaddr;
        `uvm_info("ADDR_CHECK",$psprintf("awaddr_t=%0h",awaddr_t[vif.slave_cb.awid]),UVM_DEBUG);
        awlen_t[vif.slave_cb.awid]=vif.slave_cb.awlen;
        awsize_t[vif.slave_cb.awid]=vif.slave_cb.awsize;
        awburst_t[vif.slave_cb.awid]=vif.slave_cb.awburst;
        awlock_t[vif.slave_cb.awid]=vif.slave_cb.awlock;
        awcache_t[vif.slave_cb.awid]=vif.slave_cb.awcache;
        awprot_t[vif.slave_cb.awid]=vif.slave_cb.awprot;
        if(awburst_t[vif.slave_cb.awid]==2'b10)
          begin 
            //{
            calc_boundary(awlen_t[vif.slave_cb.awid],awsize_t[vif.slave_cb.awid],awaddr_t[vif.slave_cb.awid],lower_boundary[vif.slave_cb.awid],upper_boundary[vif.slave_cb.awid]);
            up[vif.slave_cb.awid]=upper_boundary[vif.slave_cb.awid];
            w_incr++;
          end //} 
      end //} 
      else
        vif.slave_cb.awready<=1'b0;

      if(vif.slave_cb.wvalid) begin //{ 
        temp_data=vif.slave_cb.wdata;
        vif.slave_cb.wready<=1;
        if(flag_w==0) begin //{ 
          repeat(2)@(vif.slave_cb);
          flag_w=1;
          addr_track=0;
        end //} 
        if(awburst_t[vif.slave_cb.wid]==2'b10 || awburst_t[vif.slave_cb.wid]==2'b01) begin //{ 
          for(int i=0;i<(`data_width/8);i++) begin //{ 
            temp_que.push_back(temp_data[7:0]);
            temp_data=temp_data >> 8;
          end //} 
          if(axi_common::endian ==`little) begin //{ 
            for(int i=0;i<=(`data_width/8);i++) begin //{ 
              if(vif.slave_cb.wstrb[i]==1) begin //{ 
                //                 $display("before-- addr=%0h",awaddr_t[vif.slave_cb.wid]);
                memory[awaddr_t[vif.slave_cb.wid]+addr_track]=temp_que[i];
                `uvm_info("WRITE_SLAVE",$psprintf("%0t, wid=%0d, i=%0d,temp_data=%0h, write_slave: slave_data=%0h, addr=%0h, data=%0h",$time, vif.slave_cb.wid,i,temp_data,vif.slave_cb.wdata, awaddr_t[vif.slave_cb.wid]+addr_track,memory[awaddr_t[vif.slave_cb.wid]+addr_track]),UVM_DEBUG);              addr_track++;

              end //} 
            end //} 
          end //} 
          else if(axi_common::endian == `big) begin //{ 
            for(int i=(`data_width/8)-1;i>=0;i--) begin //{ 
              if(vif.slave_cb.wstrb[i]==1) begin //{ 
                memory[awaddr_t[vif.slave_cb.wid]+addr_track]=temp_que[i];
                `uvm_info("WRITE_SLAVE",$psprintf("wid=%0d, i=%0d,temp_data=%0h, write_slave: slave_data=%0h, addr=%0h, data=%0h",vif.slave_cb.wid,i,temp_data,vif.slave_cb.wdata, awaddr_t[vif.slave_cb.wid]+addr_track,memory[awaddr_t[vif.slave_cb.wid]+addr_track]),UVM_DEBUG);   
                addr_track++;
              end //} 
            end //} 
          end //}

          if(flag_w==1 && vif.slave_cb.wvalid==1) begin //{ 
            //             $display("before addr=%0h",awaddr_t[vif.slave_cb.wid]);
            awaddr_t[vif.slave_cb.wid]=awaddr_t[vif.slave_cb.wid]-(awaddr_t[vif.slave_cb.wid]% (2**awsize_t[vif.slave_cb.wid]))+2**awsize_t[vif.slave_cb.wid];
            //             $display("after addr=%0h",awaddr_t[vif.slave_cb.wid]);
          end //}

          if(awaddr_t[vif.slave_cb.wid]>=up[vif.slave_cb.wid] && awburst_t[vif.slave_cb.wid]==2'b10)
            awaddr_t[vif.slave_cb.wid]=lower_boundary[vif.slave_cb.wid];
          addr_track=0;
        end //}
        else if(awburst_t[vif.slave_cb.wid]==2'b00) begin //{
          temp_data_fixed1=vif.slave_cb.wdata;
          for(int i=0;i<(`data_width/8);i++) begin //{ 
            temp_que.push_back(temp_data_fixed1[7:0]);
            temp_data_fixed1=temp_data_fixed1 >> 8;
          end //} 

          for(int i=(`data_width/8)-1;i>=0;i--) begin
            if(vif.slave_cb.wstrb[i]==1) begin
              temp_data_fixed[7:0]=temp_que[i];
              if(i!=0)
                temp_data_fixed=temp_data_fixed << 8;
            end
          end
//           temp_data_fixed=temp_data_fixed >> 8; //to remove extra added bits
          temp_fixed_addr=awaddr_t[vif.slave_cb.wid];
          fixed_fifo[temp_fixed_addr][fifo_counter]=temp_data_fixed;

          temp_data_fixed=0;
          `uvm_info("WRITE_FIXED_SLAVE",$psprintf("wstrb=%b, wid=%0d, write_slave: slave_data=%0h, addr=%0h,counter=%0d, data=%0h",vif.slave_cb.wstrb,vif.slave_cb.wid,vif.slave_cb.wdata,awaddr_t[vif.slave_cb.wid],fifo_counter, fixed_fifo[awaddr_t[vif.slave_cb.wid]][fifo_counter]),UVM_DEBUG)

          fifo_counter++;
        end //}

        temp_que.delete();
        if(vif.slave_cb.wlast) begin //{
          vif.slave_cb.bvalid<=1;
          awid_t[vif.slave_cb.wid]=0;
          awaddr_t[vif.slave_cb.wid]=0;
          awlen_t[vif.slave_cb.wid]=0;
          awsize_t[vif.slave_cb.wid]=0;
          awburst_t[vif.slave_cb.wid]=0;
          awprot_t[vif.slave_cb.wid]=0;
          awlock_t[vif.slave_cb.wid]=0;
          awcache_t[vif.slave_cb.wid]=0;
          wait(vif.slave_cb.bready==1);
          vif.slave_cb.bvalid<=0;
          fifo_counter=0;

        end //} 
      end //}

      if(vif.slave_cb.arvalid==1'b1) begin //{
        vif.slave_cb.arready <= 1'b1;
        r_incr++;
        @(vif.slave_cb);
        read_addr();
      end //}
      else
        vif.slave_cb.arready <= 1'b0;

    end //}
  endtask

  int read_count;
  task read_addr();
    arid_t[vif.slave_cb.arid]=vif.slave_cb.arid;
    araddr_t[vif.slave_cb.arid]=vif.slave_cb.araddr;
    arlen_t[vif.slave_cb.arid]=vif.slave_cb.arlen;
    arsize_t[vif.slave_cb.arid]=vif.slave_cb.arsize;
    arburst_t[vif.slave_cb.arid]=vif.slave_cb.arburst;
    arlock_t[vif.slave_cb.arid]=vif.slave_cb.arlock;
    arcache_t[vif.slave_cb.arid]=vif.slave_cb.arcache;
    arprot_t[vif.slave_cb.arid]=vif.slave_cb.arprot;
    if(arburst_t[vif.slave_cb.arid]==WRAP) begin //{
      calc_boundary(arlen_t[vif.slave_cb.arid],arsize_t[vif.slave_cb.arid],araddr_t[vif.slave_cb.arid],lower_boundary[vif.slave_cb.arid],upper_boundary[vif.slave_cb.arid]);
      up[vif.slave_cb.arid]=upper_boundary[vif.slave_cb.arid];
    end //}
    read_data(arid_t[vif.slave_cb.arid]);
    //     @(vif.slave_cb);
  endtask

  task write_resp(bit [3:0]id);
    @(vif.slave_cb);
    vif.slave_cb.bid<=id;
    vif.slave_cb.bvalid<=1;
    vif.slave_cb.bresp<=OKAY;
    wait(vif.slave_cb.bready);
    vif.slave_cb.bid<=0;
    vif.slave_cb.bvalid<=0;
    vif.slave_cb.bresp<=0;
  endtask


  int temp=0;
  int read_queue[16][$];
  bit [`data_width-1:0] data[16],read_out[16];
  task read_data(bit[3:0] id);
    for(int len=0;len<=arlen_t[id];len++) begin
      @(vif.slave_cb);
      vif.slave_cb.rvalid<=1;
      wait(vif.slave_cb.rready);
      vif.slave_cb.rid<=id;

      if(arburst_t[id]==2'b00) begin //fixed
        vif.slave_cb.rdata<=fixed_fifo[araddr_t[id]][len];
        `uvm_info("READ_FIXED_DATA",$psprintf("addr=%0h, read_data=%0h",araddr_t[id],fixed_fifo[araddr_t[id]][len]),UVM_DEBUG)

      end //fixed
      else if(arburst_t[id]==2'b01) begin //INCR
        for(int i=0;i<(2**arsize_t[id])-(araddr_t[id]%2**arsize_t[id]);i++) begin //{

          read_queue[id].push_back(memory[araddr_t[id]+i]);
        end //}
        if(axi_common::endian==`big) begin //{ 
          for(int i=0;i<read_queue[id].size();i++) begin //{
            data[id][7:0]=read_queue[id][i];
            if(i!=read_queue[id].size()-1)
              data[id]=data[id]<<8;
          end //}
        end //} 
        else if(axi_common::endian == `little) begin //{
          for(int i=0;i<read_queue[id].size();i++) begin //{
            data[id][7:0]=read_queue[id][read_queue[id].size() - 1 -i];
            if(i!=read_queue[id].size()-1)
              data[id]=data[id]<<8;
          end //} 
        end //} 
        vif.slave_cb.rdata<=data[id];
        `uvm_info("READ_INCR_DATA",$psprintf("addr=%0h, read_data=%0h",araddr_t[id],data[id]),UVM_DEBUG)

        data[id]=0;
        araddr_t[id]=araddr_t[id] - (araddr_t[id]%2**arsize_t[id]) + 2**arsize_t[id];
      end //INCR
      else if(arburst_t[id]==2'b10) begin //WRAP
        for(int i=0;i<(2**arsize_t[id])-(araddr_t[id]%2**arsize_t[id]);i++) begin //{

          read_queue[id].push_back(memory[araddr_t[id]+i]);
        end //}
        if(axi_common::endian==`big) begin //{ 
          for(int i=0;i<read_queue[id].size();i++) begin //{
            data[id][7:0]=read_queue[id][i];
            if(i!=read_queue[id].size()-1)
              data[id]=data[id]<<8;
          end //}
        end //}
        else if(axi_common::endian == `little) begin //{
          for(int i=0;i<read_queue[id].size();i++) begin //{
            data[id][7:0]=read_queue[id][read_queue[id].size() - 1 -i];
            if(i!=read_queue[id].size()-1)
              data[id]=data[id]<<8;
          end //} 
        end //} 
        `uvm_info("READ_WRAP_DATA",$psprintf("addr=%0h, read_data=%0h",araddr_t[id],data[id]),UVM_DEBUG)
        vif.slave_cb.rdata<=data[id];
        data[id]=0;
        araddr_t[id]=araddr_t[id] - (araddr_t[id]%2**arsize_t[id]) + 2**arsize_t[id];
        if(araddr_t[id]>=up[id] && arburst_t[id]==2'b10)
          araddr_t[id]=lower_boundary[id];
      end //WRAP

      read_queue[id].delete();
      if(len==arlen_t[id]) begin //{ 
        vif.slave_cb.rlast<=1;
        vif.slave_cb.rresp<=1;
        arid_t[id]=0;        
        araddr_t[id]=0;
        arlen_t[id]=0;
        arsize_t[id]=0;
        arburst_t[id]=0;
        arlock_t[id]=0;
        arcache_t[id]=0;
        arprot_t[id]=0;
        data[id]=0;
        @(vif.slave_cb);
        vif.slave_cb.rresp<=0;
        vif.slave_cb.rlast<=0;
        vif.slave_cb.rvalid<=0;
      end //} 
    end
  endtask

  function void calc_boundary(input bit [3:0]awlen, input bit[2:0]awburst, input bit[`addr_width-1:0]addr, output int  lower, output int upper);
    int total_bytes=(awlen+1)*(2**awburst);
    lower=addr - (addr % total_bytes);
    upper=lower + (awlen+1)*(2**awburst);
    `uvm_info("calculation",$psprintf("lower=%0h upper=%0h",lower,upper),UVM_DEBUG)
  endfunction
endclass
