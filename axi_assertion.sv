module axi_assertion(
  input logic aclk,arst,
  input [3:0]awid,
  input [`addr_width-1:0]awaddr,
  input [3:0]awlen,
  input [2:0]awsize,
  input [1:0]awburst,
  input [1:0]awlock,
  input [1:0]awcache,
  input [1:0]awprot,
  input awvalid,
  input awready,

  //data channel
  input [3:0]wid,
  input  [`data_width-1:0]wdata,
  input  [(`data_width/8)-1:0]wstrb,
  input  wlast,
  //input wuser,
  input  wvalid,
  input wready,


  //response channel
  input [3:0]bid,
  input [1:0]bresp,
  input bvalid,
  input bready,

  //read channel
  input [3:0]arid,
  input [`addr_width-1:0]araddr,
  input [3:0]arlen,
  input [2:0]arsize,
  input [1:0]arburst,
  input [1:0]arlock,
  input [1:0]arcache,
  input [1:0]arprot,
  input arvalid,
  input arready,

  //data channel
  input [3:0]rid,
  input [`data_width-1:0]rdata,
  input rlast,
  input rvalid,
  input rready,
  input [1:0]rresp
);
  /*
  -handshaking assertions
  -when address phase is happening, alll address channle signals hsould have known values same for dataphase,resp,read addr,read_data
  -based on burst_len, number of beats should happen
  */
    property handshake_prop(valid,ready);
      @(posedge aclk) valid|->##[0:3](ready==1);
    endproperty

    W_ADDRE: assert property(handshake_prop(awvalid,awready));
    W_DATA:  assert property(handshake_prop(wvalid,wready));
    W_RESP: assert property(handshake_prop(bvalid,bready));
    R_ADDR:  assert property(handshake_prop(arvalid,arready));
    R_DATA: assert property(handshake_prop(rvalid,rready));
      
      property value_check(valid,value);
        @(posedge aclk) valid|->not($isunknown(value));
      endproperty
            AW_ADDR_A:  assert property(value_check(awvalid,awaddr));
      AW_ID_A:    assert property(value_check(awvalid,awid));
      AW_LEN_A:   assert property(value_check(awvalid,awlen));
      AW_SIZE_A:  assert property(value_check(awvalid,awsize));
      AW_BURST_A: assert property(value_check(awvalid,awburst));
      AW_LOCK_A:  assert property(value_check(awvalid,awlock));
      AW_PROT_A:  assert property(value_check(awvalid,awprot));
      AW_CACHE_A: assert property(value_check(awvalid,awcache));
      
      AR_ADDR_A:  assert property(value_check(arvalid,araddr));
      AR_ID_A:    assert property(value_check(arvalid,arid));
      AR_LEN_A:   assert property(value_check(arvalid,arlen));
      AR_SIZE_A:  assert property(value_check(arvalid,arsize));
      AR_BURST_A: assert property(value_check(arvalid,arburst));
      AR_LOCK_A:  assert property(value_check(arvalid,arlock));
      AR_PROT_A:  assert property(value_check(arvalid,arprot));
      AR_CACHE_A: assert property(value_check(arvalid,arcache));

      W_ID_A:     assert property(value_check(wvalid,wid));
      W_DATA_A:   assert property(value_check(wvalid,wdata));
      W_STROBE_A: assert property(value_check(wvalid,wstrb));
      W_LAST_A:   assert property(value_check(wvalid,wlast));
      
      R_ID_A:     assert property(value_check(rvalid,rid));
      R_DATA_A:   assert property(value_check(rvalid,rdata));
      R_LAST_A:   assert property(value_check(rvalid,rlast));
        R_RESP_A:   assert property(value_check(rlast,rresp));


      B_ID_A:     assert property(value_check(bvalid,bid));
      B_RESP_A:   assert property(value_check(bvalid,bresp));
endmodule