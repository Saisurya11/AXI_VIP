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
`include "axi_env.sv"
`include "axi_seq.sv"
`include "axi_test.sv"
module tb;
reg clk,rst;
initial begin
	clk=0;
	forever #5 clk=~clk;
end
  axi_intf pif(clk,rst);
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
