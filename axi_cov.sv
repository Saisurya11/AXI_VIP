class axi_cov extends uvm_subscriber#(axi_tx);
  `uvm_component_utils(axi_cov)
  axi_tx txQ[$],tx,temp;
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  function void write(T t);
    $cast(temp,t);
    //     temp.print();
    txQ.push_back(temp);
  endfunction

  covergroup axi_cg;
    addr: coverpoint tx.addr{
      option.auto_bin_max=1;
    }
    wr_rd: coverpoint tx.wr_rd;
    len: coverpoint tx.len{
      option.auto_bin_max=4;
    }
    burst_size: coverpoint tx.burst_size
    {
      option.auto_bin_max=2;
      //       bins BURST_SIZE_1_BYTE={BURST_SIZE_1_BYTE};
      //       bins BURST_SIZE_2_BYTE={BURST_SIZE_2_BYTE};
      //       bins BURST_SIZE_4_BYTE={BURST_SIZE_4_BYTE};
      //       bins BURST_SIZE_8_BYTE={BURST_SIZE_8_BYTE};
      //       bins BURST_SIZE_16_BYTE={BURST_SIZE_16_BYTE};
      //       bins BURST_SIZE_32_BYTE={BURST_SIZE_32_BYTE};
      //       bins BURST_SIZE_64_BYTE={BURST_SIZE_64_BYTE};
      //       bins BURST_SIZE_128_BYT={BURST_SIZE_128_BYTE};
    }
    id: coverpoint tx.id{
      option.auto_bin_max=2;
    }
    lock: coverpoint tx.lock{
      bins legal={NORMAL,EXCLUSIVE,LOCKED};
      ignore_bins rsvd={RSVD_lock};
    }
    prot: coverpoint tx.prot{
      option.auto_bin_max=2;
    }
    cache: coverpoint tx.cache{
      option.auto_bin_max=2;
    }
    resp: coverpoint tx.resp{
      option.auto_bin_max=2;

    }
    burst_type: coverpoint tx.burst_type{
      bins legal={ FIXED,INCR,WRAP};
      ignore_bins rsvd={RSVD_burst};
    }
    //     ADDR_X_WR_RD: cross addr,wr_rd;
    //     LEN_X_WR_RD: cross len,wr_rd;
    //     BURST_SIZE_X_WR_RD:cross burst_size,wr_rd;
    //     BURST_TYPE_X_WR_RD:cross burst_type,wr_rd;
    //     ID_X_WR_RD:cross id,wr_rd;
    //     LOCK_X_WR_RD:cross lock,wr_rd;
    //     RESP_X_WR_RD:cross resp,wr_rd;
    //     CACHE_X_WR_RD:cross cache,wr_rd;
    //     PROT_X_WR_RD:cross prot,wr_rd;

  endgroup


  function new(string name="",uvm_component parent);
    super.new(name,parent);
    axi_cg=new();
  endfunction



  task run_phase(uvm_phase phase);
    forever begin
      wait(txQ.size()>0);
      tx=txQ.pop_front();
      axi_cg.sample();
    end
  endtask

  function void report_phase(uvm_phase phase);
    $display("coverage=%0.3f",axi_cg.get_coverage());
  endfunction
endclass
