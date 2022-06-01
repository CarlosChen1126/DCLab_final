`timescale 1ns/100ps
module tb;
localparam CLK = 10;
localparam HCLK = CLK/2;
logic clk, rst_n;
initial clk=0;
initial rst_n=0;
always #HCLK clk = ~clk;

logic [3:0] mem_out;
logic [3:0] rand_out;
logic valid;
logic start;
Lfsr lf1(
    .i_clk(clk),
    .i_rst_n(rst_n),
    .o_random_out(rand_out)
);
integer i;
initial begin
		$fsdbDumpfile("Lfsr.fsdb");
		$fsdbDumpvars;
        #(CLK)
        rst_n = 1;
        $monitor("rand = %d", rand_out);

        #(20*CLK)
        $finish;
end
endmodule