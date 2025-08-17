class axi_sbd extends uvm_scoreboard;
  `uvm_component_utils(axi_sbd)
  `NEW_COMP

  uvm_analysis_imp#(axi_tx,axi_sbd) imp_port;
  axi_tx temp[$],tx,temp_tx;
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp_port=new("imp_port",this);
  endfunction

  int lower_boundary,upper_boundary,low,up;

  bit [`addr_width-1:0]temp_addr;

  function void write(axi_tx tx1);
    $cast(temp_tx,tx1);
    temp.push_back(temp_tx);
    $display("write");
    //     temp_tx.print();
  endfunction

  int match_value=0, mis_match_value=0,match=0,mis_match=0;
  bit [7:0] memory[int];
  bit[`data_width-1:0]fixed_fifo[int][int];
  bit [7:0]data_q[$];
  bit [`data_width-1:0]data;
  bit [`data_width-1:0] temp_data;
  bit[`data_width-1:0] fixed_temp_data,fixed_combined_data,temp_que[$];
  task run_phase(uvm_phase phase);
    forever begin//{  
      wait(temp.size()>0);
      tx=temp.pop_front();
      temp_addr=0;
      //       tx.print();
      if(tx.burst_type == 2'b10)
        calc_boundary(tx.len, tx.burst_size,tx.addr,lower_boundary,upper_boundary);

      if(tx.wr_rd==WRITE) begin//{
        if(tx.burst_type==WRAP || tx.burst_type==INCR) begin //{
          for(int i=0;i<=tx.len;i++) begin//{
            for(int j=0;j<`data_width/8;j++) begin//{
              data_q.push_back(tx.data[i][7:0]);
              //             $write("%0h ",tx.data[i][7:0]);
              tx.data[i]=tx.data[i]>>8;
            end//}
            //           $display("tx.data[%0d]=%0h",i,tx.data[i]);
            if(axi_common::endian==`little) begin//{
              for(int j=0;j<`data_width/8;j++) begin//{
                if(tx.wstrb[i][j]==1) begin//{
                  //                 $write("%0h ",data_q[j]);
                  memory[tx.addr+temp_addr]=data_q[j];
                  `uvm_info("WRITE_SBD",$psprintf("addr=%0h,data=%0h",tx.addr+temp_addr,memory[tx.addr+temp_addr]),UVM_DEBUG)

                  temp_addr++;
                  if(tx.addr+temp_addr >= upper_boundary && tx.burst_type==WRAP) begin//{
                    temp_addr=0;
                    tx.addr=lower_boundary;
                  end//}
                end//}
              end//}
            end//}
            else if(axi_common::endian==`big) begin//{
              for(int j=`data_width/8 -1; j>=0 ;j--) begin//{
                if(tx.wstrb[i][j]==1) begin//{

                  memory[tx.addr+temp_addr]=data_q[j];
                  `uvm_info("WRITE_SBD",$psprintf("addr=%0h,data=%0h",tx.addr+temp_addr,memory[tx.addr+temp_addr]),UVM_DEBUG)

                  temp_addr++;
                  if(tx.addr+temp_addr >= upper_boundary && tx.burst_type==2'b10) begin//{
                    temp_addr=0;
                    tx.addr=lower_boundary;
                  end//}
                end//}
              end//}
            end//}
            data_q.delete();
          end//}
        end //}
        else if(tx.burst_type==FIXED) begin
          for(int len=0;len<=tx.len;len++) begin
            fixed_temp_data=tx.data[len];
            temp_que.delete();
            fixed_combined_data=0;
            for(int i=0;i<(`data_width/8);i++) begin //{ 
              temp_que.push_back(fixed_temp_data[7:0]);
              fixed_temp_data=fixed_temp_data >> 8;
            end //} 

            for(int i=(`data_width/8)-1;i>=0;i--) begin
              if(tx.wstrb[len][i]==1) begin
                fixed_combined_data[7:0]=temp_que[i];
                if(i!=0)
                  fixed_combined_data=fixed_combined_data << 8;
              end
            end
            fixed_fifo[tx.addr][len]=fixed_combined_data;
            `uvm_info("FIXED_SBD_WRITE",$psprintf("tx.addr=%0h, len=%0d, data=%0h",tx.addr,len,fixed_fifo[tx.addr][len]),UVM_DEBUG)
          end
        end
      end//}
      else if(tx.wr_rd==READ) begin//{
        //         $display("%0p",memory);
        if(tx.burst_type==2'b10 || tx.burst_type==2'b01) begin //{
          match_value = 0;
          mis_match_value = 0;
          temp_addr=0;
          for(int j=0;j<=tx.len;j++) begin//{
            data=0;
            data_q.delete();
            `uvm_info("READ_SBD",$psprintf("tx,data=%0h",tx.data[j]),UVM_DEBUG)

            for(int i=0;i<(2**tx.burst_size - (tx.addr%2**tx.burst_size));i++) begin//{
              `uvm_info("READ_SBD",$psprintf("addr=%0h,data=%0h",tx.addr+temp_addr,memory[tx.addr+temp_addr]),UVM_DEBUG)
              data_q.push_back(memory[tx.addr+temp_addr]);
              temp_addr++;
            end//}
            tx.addr=tx.addr-(tx.addr%2**tx.burst_size) + 2**tx.burst_size;
            temp_addr=0;
            if(tx.addr+temp_addr >= upper_boundary && tx.burst_type==WRAP) begin//{
              temp_addr=0;
              tx.addr=lower_boundary;
            end//}

            if(axi_common::endian==`little) begin//{
              for(int k=2**tx.burst_size-1;k>=0;k--) begin//{
                if(k<=2**tx.burst_size-2)
                  data=data<<8;
                data[7:0]=data_q[k];
              end//}
            end//}
            else if(axi_common::endian==`big) begin//{
              for(int k=0;k<data_q.size();k++) begin//{
                if(k>=1)
                  data=data<<8;
                data[7:0]=data_q[k];
              end//}
            end//}

            //                     `uvm_info("READ_SBD",$psprintf("addr=%0h,data=%0h",tx.addr,data),UVM_DEBUG)
            `uvm_info("report",$psprintf("tx.data[%0d]=%0h,data=%0h",j,tx.data[j],data),UVM_DEBUG)

            if(tx.data[j]==data) begin//{
              match_value++;
            end//}
            else
              mis_match_value++;

          end//}
        end//}
        else if(tx.burst_type==2'b00) begin
          for(int i=0;i<=tx.len;i++) begin
            `uvm_info("READ_SBD",$psprintf("FIXED: addr=%0h,I=%0d,,data=%0h",tx.addr,i,fixed_fifo[tx.addr][i]),UVM_DEBUG)
            if(tx.data[i]==fixed_fifo[tx.addr][i])
              match_value++;
            else
              mis_match_value++;
          end

        end
      end//}
      if (mis_match_value == 0 && tx.wr_rd==READ) begin
        $display("success");
        match++;
        match_value=0;
        mis_match_value=0;
      end
      else if(tx.wr_rd==READ && mis_match_value>0) begin
        $display("un success");
        mis_match++;  
        match_value=0;
        mis_match_value=0;
      end

    end//}
  endtask

  function void report_phase(uvm_phase phase);
    `uvm_info("REPORT",$psprintf("match=%0d,mis_match=%0d",match,mis_match),UVM_NONE)
  endfunction

  function void calc_boundary(input bit [3:0]awlen, input bit[2:0]awburst, input bit[`addr_width-1:0]addr, output int  lower, output int upper);
    int total_bytes=(awlen+1)*(2**awburst);
    lower=addr - (addr % total_bytes);
    upper=lower + (awlen+1)*(2**awburst);
    `uvm_info("calculation",$psprintf("lower=%0h upper=%0h",lower,upper),UVM_DEBUG)
  endfunction
endclass