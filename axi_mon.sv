class axi_mon extends uvm_monitor;
  `uvm_component_utils(axi_mon)
  `NEW_COMP
  uvm_analysis_port#(axi_tx) ap_port;
  virtual axi_intf vif;
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual axi_intf)::get(this,"*","vif",vif))
      `uvm_info("DEBUG","VIF NOT RECIEVED",UVM_DEBUG)
      ap_port=new("ap_port",this);
  endfunction

endclass
