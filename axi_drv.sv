class axi_drv extends uvm_driver#(axi_tx);
  `uvm_component_utils(axi_drv)
  `NEW_COMP
  virtual axi_intf.master_mp vif;
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual axi_intf)::get(this,"*","vif",vif))
      $display("vif not recieved");
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      req.print();
      seq_item_port.item_done;
    end
  endtask

  task drive(axi_tx tx);
    `uvm_info("driving","driving the transaction",UVM_DEBUG)
    if(tx.wr_rd==WRITE) begin
      write_address(tx);
      write_data(tx);
      write_response(tx);
    end
    else if(tx.wr_rd==READ) begin
      read_address(tx);
      read_data(tx);
    end
  endtask

  task write_address(axi_tx tx);
    @(vif.master_cb);
    vif.master_cb.awaddr<=tx.addr;
    vif.master_cb.awid<=tx.id;
    vif.master_cb.awlen<=tx.len;
    vif.master_cb.awsize<=tx.burst_size;
    vif.master_cb.awburst<=tx.burst_type;
    vif.master_cb.awlock<=tx.lock;
    vif.master_cb.awcache<=tx.cache;
    vif.master_cb.awprot<=tx.prot;
    vif.master_cb.awvalid<=1;

    wait(vif.master_cb.awready==1);

    //     @(posedge vif.master_cb);
    vif.master_cb.awaddr<=0;
    vif.master_cb.awid<=0;
    vif.master_cb.awlen<=0;
    vif.master_cb.awsize<=0;
    vif.master_cb.awburst<=0;
    vif.master_cb.awlock<=0;
    vif.master_cb.awcache<=0;
    vif.master_cb.awprot<=0;
    vif.master_cb.awvalid<=0;

  endtask

  task read_address(axi_tx tx);
    $display("read_address");
   @(vif.master_cb);
    vif.master_cb.araddr<=tx.addr;
    vif.master_cb.arid<=tx.id;
    vif.master_cb.arlen<=tx.len;
    vif.master_cb.arsize<=tx.burst_size;
    vif.master_cb.arburst<=tx.burst_type;
    vif.master_cb.arlock<=tx.lock;
    vif.master_cb.arcache<=tx.cache;
    vif.master_cb.arprot<=tx.prot;
    vif.master_cb.arvalid<=1;

//     wait(vif.master_cb.arready==1);

        @(posedge vif.master_cb);
    vif.master_cb.araddr<=0;
    vif.master_cb.arid<=0;
    vif.master_cb.arlen<=0;
    vif.master_cb.arsize<=0;
    vif.master_cb.arburst<=0;
    vif.master_cb.arlock<=0;
    vif.master_cb.arcache<=0;
    vif.master_cb.arprot<=0;
    vif.master_cb.arvalid<=0;

  endtask

  task write_data(axi_tx tx);
    foreach(tx.data[i])
      begin
        @(vif.master_cb)
        vif.master_cb.wdata<=tx.data[i];
        vif.master_cb.wvalid<=1;
        vif.master_cb.wstrb<=tx.wstrb;
        vif.master_cb.wid<=tx.id;
        if(i==tx.len)begin
          vif.master_cb.wlast<=1;
        end
        else
          vif.master_cb.wlast<=0;
        wait(vif.master_cb.wready);
      end
    @(vif.master_cb)
    vif.master_cb.wdata<=0;
    vif.master_cb.wvalid<=0;
    vif.master_cb.wstrb<=0;
    vif.master_cb.wid<=0;
    vif.master_cb.wlast<=0;
  endtask

  task write_response(axi_tx tx);
    wait(vif.master_cb.bvalid);
    vif.master_cb.bready<=1;
    @(vif.master_cb);
    vif.master_cb.bready<=0;
    
  endtask
  
  task read_data(axi_tx tx);
    @(vif.master_cb);
    if(vif.master_cb.rvalid)
      vif.master_cb.rready<=1;
  endtask
endclass


