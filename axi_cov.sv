class axi_cov extends uvm_subscriber#(axi_tx);
  `uvm_component_utils(axi_cov)
  axi_tx tx;
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  function void write(T t);
    $cast(tx,t);
  endfunction

  covergroup axi_cg;
    coverpoint tx.addr;
    coverpoint tx.wr_rd;
  endgroup

  function new(string name="",uvm_component parent);
    super.new(name,parent);
    axi_cg=new();
  endfunction
  
  task run_phase(uvm_phase phase);
//     axi_cg.sample();
  endtask
endclass
