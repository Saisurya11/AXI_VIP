class axi_tx extends uvm_sequence_item;
  `NEW_OBJ
  rand bit [`data_width-1:0]      data[$];
  rand bit [`addr_width-1:0] 	   addr;
  rand bit [3:0]	    	            len;
  rand burst_type_t 	     burst_type;
  rand burst_size_t	     burst_size;
  rand bit [(`data_width/8)-1:0]     wstrb[$];
  rand resp_t		           resp;
  rand bit [1:0] 		           prot;
  rand lock_t		           lock;
  rand bit [3:0]                    cache;
  rand bit [3:0] 		       	     id;
  rand wr_rd_t 			  wr_rd;
  static int que[$];
  //   rand endian_t endian;


  `uvm_object_utils_begin(axi_tx)
  `uvm_field_queue_int(data,UVM_ALL_ON)
  `uvm_field_int(addr,UVM_ALL_ON)
  `uvm_field_int(len,UVM_ALL_ON)
  //   `uvm_field_enum(endian_t,endian,UVM_ALL_ON)
  `uvm_field_enum(burst_size_t,burst_size,UVM_ALL_ON)
  `uvm_field_enum(burst_type_t,burst_type,UVM_ALL_ON)
  `uvm_field_queue_int(wstrb,UVM_ALL_ON)
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
            burst_type dist {FIXED:=3, INCR:=3, WRAP:=3};
    burst_type!=RSVD_burst;
    !(id inside {que});
    //     soft resp==OKAY;
    //     soft lock==NORMAL;
    //     soft cache=='d0;
    burst_size <= $clog2((`data_width/8));
    wstrb.size() == len+1;
//     burst_size == BURST_SIZE_4_BYTE;
    foreach(wstrb[i]) {
      (burst_size==BURST_SIZE_1_BYTE) -> wstrb[i] =={{((`data_width/8)-1){1'b0}},1'b1};
      (burst_size==BURST_SIZE_2_BYTE) -> wstrb[i] == 3;
      (burst_size==BURST_SIZE_4_BYTE) -> wstrb[i] =='b1111;
      (burst_size==BURST_SIZE_8_BYTE) -> wstrb[i] =='b1111_1111;
      (burst_size==BURST_SIZE_16_BYTE) -> wstrb[i] =='b1111_1111_1111_1111;
      (burst_size==BURST_SIZE_32_BYTE) -> wstrb[i] =='b1111_1111_1111_1111_1111_1111_1111_1111;
      (burst_size==BURST_SIZE_64_BYTE) -> wstrb[i] =='b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;
      (burst_size==BURST_SIZE_128_BYTE) -> wstrb[i] =='b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;
    }
  }
      function void post_randomize();
    //     need to perfrom rolling wstrb
    que.push_back(id);
    for(int i=0;i<=len;i++) begin
      if(burst_size!=$clog2(`data_width/8)) begin
        if(i==0 || wstrb[i-1][(`data_width/8) -1]==1) begin
          //           $display("%b, %0d",wstrb[i],len);
          continue;
        end
        else if(i!=0 || wstrb[i][(`data_width/8) -1]!=1) begin
          wstrb[i]=wstrb[i-1] << 2**burst_size;
                    $display("%0d, %b",i,wstrb[i][(`data_width/8) -1]);
                    $display("%b, %0d, %0s",wstrb[i],len,burst_size);
        end
      end
    end
    if(que.size()==16)
      que.delete();
    if (addr % 2**burst_size != 0) begin
      int temp = addr % 2**burst_size;

      // Create a temporary bit vector
      logic [`data_width/8 -1:0] temp_wstrb;

      // Use a loop to set the bits
      for (int i = 0; i < `data_width/8; i++) begin
        if(i< 2**burst_size-temp)
          temp_wstrb[i]=1'b1;
        else
          temp_wstrb[i]=1'b0;
      end

      // Assign the result to wstrb[0]
      wstrb[0] = temp_wstrb;
    end

    endfunction

    endclass
