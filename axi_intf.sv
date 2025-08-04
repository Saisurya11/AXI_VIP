interface axi_intf(input logic aclk,arst);
  logic [3:0]awid=0;
  logic [`addr_width-1:0]awaddr=0;
  logic [3:0]awlen=0;
  logic [2:0]awsize=0;
  logic [1:0]awburst=0;
  logic [1:0]awlock=0;
  logic [1:0]awcache=0;
  logic [1:0]awprot=0;
  logic awvalid=0;
  logic awready=0;

  //data channel
  logic [3:0]wid=0;
  logic [`data_width-1:0]wdata;
  logic [(`data_width/8)-1:0]wstrb=0;
  logic wlast=0;
  logic wvalid=0;
  logic wready=0;


  //response channel
  logic [3:0]bid=0;
  logic [1:0]bresp=0;
  logic bvalid=0,bready=0;

  //read channel
  logic [3:0]arid=0;
  logic [`addr_width-1:0]araddr=0;
  logic [3:0]arlen=0;
  logic [2:0]arsize=0;
  logic [1:0]arburst=0;
  logic [1:0]arlock=0;
  logic [1:0]arcache=0;
  logic [1:0]arprot=0;
  logic arvalid=0;
  logic arready=0;

  //data channel
  logic [3:0]rid=0;
  logic [`data_width-1:0]rdata=0;
  logic rlast=0;
  logic rvalid=0;
  logic rready=0;
  logic [1:0]rresp=0;

  clocking master_cb@(posedge aclk);
    default input #0 output #1;
    output awid;
    output awaddr;
    output awlen;
    output awsize;
    output awburst;
    output awlock;
    output awcache;
    output awprot;
    output awvalid;
    input awready;
    
    //
    output wid;
    output wdata;
    output wvalid;
    input wready;
    output wstrb;
    output wlast;
    
    //
    input bid;
    input bresp;
    input bvalid;
    output #0 bready;
    
    //
    output arid;
    output araddr;
    output arlen;
    output arsize;
    output arburst;
    output arlock;
    output arcache;
    output arprot;
    output arvalid;
    input  arready;
    
    input  rid;
    input  rdata;
    input  rvalid;
    output  rready;
    input  rlast;
    input rresp;
  endclocking
  modport master_mp(clocking master_cb);
    
    
    clocking slave_cb@(posedge aclk);
    default input #0 output #0;
    input awid;
    input awaddr;
    input awlen;
    input awsize;
    input awburst;
    input awlock;
    input awcache;
    input awprot;
    input awvalid;
    output awready;
    
    //
    input wid;
    input wdata;
    input wvalid;
    output wready;
    input wstrb;
    input wlast;
    
    //
    output bid;
    output bresp;
    output bvalid;
    input bready;
    
    //
    input arid;
    input araddr;
    input arlen;
    input arsize;
    input arburst;
    input arlock;
    input arcache;
    input arprot;
    input arvalid;
    output  arready;
    
    output  rid;
    output  rdata;
    output  rvalid;
    input  rready;
    output  rlast;
    output rresp;
  endclocking
    modport slave_mp(clocking slave_cb);
endinterface
