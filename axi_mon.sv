class axi_mon extends uvm_monitor;
  `uvm_component_utils(axi_mon)
  `NEW_COMP
  axi_tx tx;
  int len_t=0;
  bit flag=0,w_flag=0;
  uvm_analysis_port#(axi_tx) ap_port;
  virtual axi_intf vif;
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual axi_intf)::get(this,"*","vif",vif))
      `uvm_info("DEBUG","VIF NOT RECIEVED",UVM_DEBUG)
      ap_port=new("ap_port",this);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.aclk);
      if(vif.awvalid && vif.awready) begin
        //         $display("%0d",vif.slave_cb.awid);
        tx=axi_tx::type_id::create("axi_tx_mon_wr");
        tx.addr=vif.awaddr;
        tx.len=vif.awlen;
        tx.burst_size=burst_size_t'(vif.awsize);
        tx.burst_type=burst_type_t'(vif.awburst);
        tx.prot=vif.awprot;
        tx.lock=lock_t'(vif.awlock);
        tx.cache=vif.awcache;
        tx.id=vif.awid;
        tx.wr_rd=WRITE;
      end
      if(vif.wvalid && vif.wready) begin
        if(w_flag==0) begin
          w_flag=1;
          @(posedge vif.aclk);
        end

        if(w_flag==1) begin
          tx.data.push_back(vif.wdata);
          tx.wstrb.push_back(vif.wstrb);
        end
      end
      if(vif.bvalid && vif.bready) begin
        `uvm_info("PRINT","CHECKING",UVM_DEBUG)
        tx.resp=resp_t'(vif.bresp);
        ap_port.write(tx);
        $display("%0p",tx.wstrb);
//         tx.print();
      end

      if(vif.arvalid && vif.arready) begin
        tx=axi_tx::type_id::create("axi_tx_mon_rd");
        tx.addr=vif.araddr;
        tx.len=vif.arlen;
        tx.burst_size=burst_size_t'(vif.arsize);
        tx.burst_type=burst_type_t'(vif.arburst);
        tx.prot=vif.arprot;
        tx.lock=lock_t'(vif.arlock);
        tx.cache=vif.arcache;
        tx.id=vif.arid;
        tx.wr_rd=READ;
      end
      if(vif.rvalid && vif.rready) begin
        if(flag==0) begin
          flag=1;
          @(posedge vif.aclk);
          tx.data.push_back(vif.rdata);          
        end
        else
          tx.data.push_back(vif.rdata);
        if(vif.rlast) begin
          tx.resp=resp_t'(vif.rresp);
          ap_port.write(tx);
//           tx.print();
        end
      end
    end
  endtask
endclass
