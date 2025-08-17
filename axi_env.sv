class axi_env extends uvm_env;
  `uvm_component_utils(axi_env)
  `NEW_COMP

  axi_agent age;
  axi_sbd sbd;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    age=axi_agent::type_id::create("age",this);
    sbd=axi_sbd::type_id::create("sbd",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    age.mon.ap_port.connect(sbd.imp_port);
  endfunction
endclass
