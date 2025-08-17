`include "uvm_macros.svh"
import uvm_pkg::*;
`include "axi_common.sv"
`include "axi_tx.sv"
`include "axi_intf.sv"
`include "axi_slave.sv"
`include "axi_mon.sv"
`include "axi_cov.sv"
`include "axi_sqr.sv"
`include "axi_drv.sv"
`include "axi_agent.sv"
`include "axi_sbd.sv"
`include "axi_env.sv"
`include "axi_seq.sv"
`include "axi_assertion.sv"
`include "axi_test.sv"
module tb;
reg clk,rst;
initial begin
	clk=0;
	forever #5 clk=~clk;
end
  axi_intf pif(clk,rst);
  
  axi_assertion axi_assertion_dut(
    .aclk(pif.aclk),
    .arst(pif.arst),
    .awid(pif.awid),
    .awaddr(pif.awaddr),
    .awlen(pif.awlen),
    .awsize(pif.awsize),
    .awburst(pif.awburst),
    .awlock(pif.awlock),
    .awcache(pif.awcache),
    .awprot(pif.awprot),
    .awvalid(pif.awvalid),
    .awready(pif.awready),
    .wid(pif.wid),
    .wdata(pif.wdata),
    .wstrb(pif.wstrb),
    .wlast(pif.wlast),
    .wvalid(pif.wvalid),
    .wready(pif.wready),
    .bid(pif.bid),
    .bresp(pif.bresp),
    .bvalid(pif.bvalid),
    .bready(pif.bready),
    .arid(pif.arid),
    .araddr(pif.araddr),
    .arlen(pif.arlen),
    .arsize(pif.arsize),
    .arburst(pif.arburst),
    .arlock(pif.arlock),
    .arcache(pif.arcache),
    .arprot(pif.arprot),
    .arvalid(pif.arvalid),
    .arready(pif.arready),
    .rid(pif.rid),
    .rdata(pif.rdata),
    .rlast(pif.rlast),
    .rvalid(pif.rvalid),
    .rready(pif.rready),
    .rresp(pif.rresp)
  );
  
initial begin
  uvm_config_db#(virtual axi_intf)::set(uvm_root::get(),"*","vif",pif);
	rst=2;
	@(posedge clk);
	rst=0;
end

initial begin
  run_test("wr_rd_test");
end

initial begin
	$dumpfile("dump.vcd");
  $dumpvars(0,tb);
end
endmodule
