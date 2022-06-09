`timescale 1ns/100ps
module tb;
localparam CLK = 80;
localparam HCLK = CLK/2;
localparam QCLK = CLK/4;
logic clk, rst_n, clkk;
initial clk=0;
initial clkk=0;
initial rst_n=0;
always #HCLK clk = ~clk;
always #QCLK clkk = ~clkk;
    

logic [7:0] VGA_R; 
logic [7:0] VGA_G; 
logic [7:0] VGA_B; 
logic VGA_CLK; 
logic VGA_BLANK_N; 
logic VGA_HS; 
logic VGA_VS; 
logic VGA_SYNC_N;

logic next, finish;
logic [3:0] timeout, timecount; 
logic [2:0] state;
logic [17:0] sec;
Top top0(
    .i_clk(clk), 
    .i_rst_n(rst_n), 

    // VGA
    .i_clk_25(clkk), 
    .VGA_R(VGA_R), 
    .VGA_G(VGA_G), 
    .VGA_B(VGA_B), 
    .VGA_CLK(VGA_CLK), 
    .VGA_BLANK_N(VGA_BLANK_N), 
    .VGA_HS(VGA_HS), 
    .VGA_VS(VGA_VS), 
    .VGA_SYNC_N(VGA_SYNC_N),

    // Game
    .state(state),
    .i_next(next),
    .i_finish_key(finish),
    .timeout(timeout),
    .timecount(timecount),
    .sec(sec)

);
integer i;
initial begin
		$fsdbDumpfile("Lfsr.fsdb");
		$fsdbDumpvars;
        #(CLK)
        rst_n = 1;
        $monitor("state=%d, timeout=%d, timecount=%d, sec=%b",state, timeout, timecount, sec);
        #(HCLK)
        next = 1;
        #(HCLK)
        next = 0;
        #(HCLK)
        next = 1;
        #(HCLK)
        next = 0;
        #(HCLK)
        next = 1;
        #(HCLK)
        next = 0;
        #(2000000000*CLK)
        $finish;
end
endmodule