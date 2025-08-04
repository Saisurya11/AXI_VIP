class axi_tx extends uvm_sequence_item;
  `NEW_OBJ
  rand bit [`data_width-1:0]      data[$];
  rand bit [`addr_width-1:0] 	   addr;
  rand bit [3:0]	    	            len;
  rand burst_type_t 	     burst_type;
  rand burst_size_t	     burst_size;
  rand bit [(`data_width/8):0]     wstrb;
  rand resp_t		           resp;
  rand bit [1:0] 		           prot;
  rand lock_t		           lock;
  rand bit [3:0]                    cache;
  rand bit [3:0] 		       	     id;
  rand wr_rd_t 			  wr_rd;



  `uvm_object_utils_begin(axi_tx)
  `uvm_field_queue_int(data,UVM_ALL_ON)
  `uvm_field_int(addr,UVM_ALL_ON)
  `uvm_field_int(len,UVM_ALL_ON)
  `uvm_field_enum(burst_size_t,burst_size,UVM_ALL_ON)
  `uvm_field_enum(burst_type_t,burst_type,UVM_ALL_ON)
  `uvm_field_int(wstrb,UVM_ALL_ON)
  `uvm_field_enum(resp_t,resp,UVM_ALL_ON)
  `uvm_field_int(prot,UVM_ALL_ON)
  `uvm_field_enum(lock_t,lock,UVM_ALL_ON)
  `uvm_field_int(cache,UVM_ALL_ON)
  `uvm_field_int(id,UVM_ALL_ON)
  `uvm_field_enum(wr_rd_t,wr_rd,UVM_ALL_ON)
  `uvm_object_utils_end
  constraint axi_main{
    data.size()==len+1;
    lock!=RSVD_lock;
    burst_type!=RSVD_burst;
    soft resp==OKAY;
    soft lock==NORMAL;
    soft cache=='d0;
    burst_size <= $clog2((`data_width/8));
//     burst_size == BURST_SIZE_4_BYTE;
    (burst_size==BURST_SIZE_1_BYTE) -> wstrb=='b01;
    (burst_size==BURST_SIZE_2_BYTE) -> wstrb=='b11;
    (burst_size==BURST_SIZE_4_BYTE) -> wstrb=='b01111;
    (burst_size==BURST_SIZE_8_BYTE) -> wstrb=='b01111_1111;
    (burst_size==BURST_SIZE_16_BYTE) -> wstrb=='b0_1111_1111_1111_1111;
    (burst_size==BURST_SIZE_32_BYTE) -> wstrb=='b0_1111_1111_1111_1111_1111_1111_1111_1111;
    (burst_size==BURST_SIZE_64_BYTE) -> wstrb=='b0_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;
    (burst_size==BURST_SIZE_128_BYTE) -> wstrb=='b0_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;
  }
endclass
