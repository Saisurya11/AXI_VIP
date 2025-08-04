class axi_env extends uvm_env;
  `uvm_component_utils(axi_env)
  `NEW_COMP

  axi_agent age;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    age=axi_agent::type_id::create("age",this);
  endfunction
endclass
