class axi_seq extends uvm_sequence#(axi_tx);
  `uvm_object_utils(axi_seq)
  `NEW_OBJ
  uvm_phase phase;
  task pre_body();
    phase=get_starting_phase();
    if(phase!=null) begin
      phase.raise_objection(this);
      phase.phase_done.set_drain_time(this,100);
    end
  endtask

  task post_body();
    if(phase!=null) begin
      phase.drop_objection(this);
    end
  endtask
endclass

class wr_rd_seq extends axi_seq;
  `uvm_object_utils(wr_rd_seq)
  `NEW_OBJ
  axi_tx q[$],temp;
  task body();
    repeat(axi_common::num_of_tx) begin
      axi_tx tx=axi_tx::type_id::create("axi_tx");	
      `uvm_do_with(req,{req.wr_rd==WRITE;})
      q.push_back(req);
    end

    repeat(axi_common::num_of_tx) begin
      axi_tx tx=axi_tx::type_id::create("axi_tx");	
      temp=q.pop_front();
      `uvm_do_with(req,{
        req.addr==temp.addr;
        req.wr_rd==READ;
      })
    end
  endtask
endclass
