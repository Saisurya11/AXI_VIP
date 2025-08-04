class axi_slave extends uvm_driver#(axi_tx);
  `uvm_component_utils(axi_slave)
  `NEW_COMP
  logic [3:0]awid_t;
  logic [`addr_width-1:0]awaddr_t;
  logic [3:0]awlen_t;
  logic [2:0]awsize_t;
  logic [1:0]awburst_t;
  logic [1:0]awlock_t;
  logic [1:0]awcache_t;
  logic [1:0]awprot_t;

  logic [3:0]arid_t;
  logic [`addr_width-1:0]araddr_t;
  logic [3:0]arlen_t;
  logic [2:0]arsize_t;
  logic [1:0]arburst_t;
  logic [1:0]arlock_t;
  logic [1:0]arcache_t;
  logic [1:0]arprot_t;

  virtual axi_intf.slave_mp vif;
  bit[`addr_width-1:0] lower_boundary,upper_boundary,low,up;
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual axi_intf)::get(this,"","vif",vif))
      $display("vif not recieved");
  endfunction

  bit [7:0] memory[int];
  int addr_track=-1;
  int temp_addr;
  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.slave_cb);
      if(vif.slave_cb.awvalid==1'b1) begin
        vif.slave_cb.awready <= 1'b1;
        awid_t=vif.slave_cb.awid;
        awaddr_t=vif.slave_cb.awaddr;
        awlen_t=vif.slave_cb.awlen;
        awsize_t=vif.slave_cb.awsize;
        awburst_t=vif.slave_cb.awburst;
        awlock_t=vif.slave_cb.awlock;
        awcache_t=vif.slave_cb.awcache;
        awprot_t=vif.slave_cb.awprot;
        if(awsize_t==WRAP)
          calc_boundary(awlen_t,awsize_t,awaddr_t,lower_boundary,upper_boundary);
        up=upper_boundary;
      end
      else
        vif.slave_cb.awready <= 1'b0;

      if(vif.slave_cb.wvalid) begin
        vif.slave_cb.wready<=1;
        foreach(vif.slave_cb.wstrb[i]) begin
          if(vif.slave_cb.wstrb[i]==1) begin
            addr_track++;
            memory[awaddr_t+addr_track]=vif.slave_cb.wdata >> i*8;
          end
        end
        addr_track=-1;
        awaddr_t=awaddr_t+2**awsize_t;
        if(awburst_t == 2'b10 && awaddr_t>=up)
          awaddr_t=lower_boundary;

        if(vif.slave_cb.wlast) begin
          write_resp(awid_t);
          //           $display(awburst_t);
          //           void'(memory.first(temp_addr));
          //           $display("addr=%0h, data=%0h", temp_addr, memory[temp_addr]);
          //           while (memory.next(temp_addr)) begin
          //             $display("addr=%0h, data=%0h", temp_addr, memory[temp_addr]);
          //           end
          $display("%0p",memory);
          addr_track=-1;
        end
        $display("%0h",awaddr_t);

      end
      else
        vif.slave_cb.wready<=1;
    end

    if(vif.slave_cb.arvalid==1'b1) begin
      vif.slave_cb.arready <= 1'b1;
      arid_t=vif.slave_cb.arid;
      araddr_t=vif.slave_cb.araddr;
      arlen_t=vif.slave_cb.arlen;
      arsize_t=vif.slave_cb.arsize;
      arburst_t=vif.slave_cb.arburst;
      arlock_t=vif.slave_cb.arlock;
      arcache_t=vif.slave_cb.arcache;
      arprot_t=vif.slave_cb.arprot;
      if(awsize_t==WRAP)
        calc_boundary(arlen_t,arsize_t,araddr_t,lower_boundary,upper_boundary);
      up=upper_boundary;
      read_data(arid_t);
    end
    else
      vif.slave_cb.arready<=0;
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

  task read_data(bit[3:0] id);
    bit[`data_width-1:0] data;
    for(int i=0;i<=arlen_t;i++) begin
      @(vif.slave_cb);
      vif.slave_cb.rid<=id;
      vif.slave_cb.rvalid<=1;
      wait(vif.slave_cb.rready==1);
      for(int j=0;j<2**arburst_t;j++) begin
        data[7:0]=memory[araddr_t+j];
        data=data<<8;
      end     
      vif.slave_cb.rdata<=data;
      if(i==arlen_t) begin
        vif.slave_cb.rlast<=1;
        vif.slave_cb.rresp<=OKAY;
      end
      araddr_t=araddr_t+2**arburst_t;
      if(arburst_t == 2'b10 && araddr_t>=up)
        araddr_t=lower_boundary;
    end
  endtask

  function void calc_boundary(input bit [3:0]awlen, input bit[2:0]awburst, input bit[`addr_width-1:0]addr, output int  lower, output int upper);
    int total_bytes=(awlen+1)*(2**awburst);
    lower=addr - (addr % total_bytes);
    upper=lower + (awlen+1)*(2**awburst);
    $display("%0h %0h",lower,upper);
  endfunction
endclass