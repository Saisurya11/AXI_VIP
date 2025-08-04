class axi_agent extends uvm_agent;
  `uvm_component_utils(axi_agent)
  `NEW_COMP
  axi_mon mon;
  axi_cov cov;
  axi_drv drv;
  axi_sqr sqr;
  axi_slave slave;


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon=axi_mon::type_id::create("axi_mon",this);
    cov=axi_cov::type_id::create("axi_cov",this);
    drv=axi_drv::type_id::create("axi_drv",this);
    sqr=axi_sqr::type_id::create("axi_sqr",this);
    slave=axi_slave::type_id::create("slave",this);

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    mon.ap_port.connect(cov.analysis_export);
    drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass
