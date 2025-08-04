class axi_test extends uvm_test;
  `uvm_component_utils(axi_test)
  `NEW_COMP
  axi_env env;
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=axi_env::type_id::create("env",this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_factory factory = uvm_factory::get();
    uvm_top.print_topology();
    factory.print();
  endfunction
endclass

class wr_rd_test extends axi_test;
  `uvm_component_utils(wr_rd_test)
  `NEW_COMP
  wr_rd_seq seq;
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq=wr_rd_seq::type_id::create("seq");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    phase.phase_done.set_drain_time(this,100);
    seq.start(env.age.sqr);
    phase.drop_objection(this);
  endtask
  
endclass
