`timescale 1ns/100ps
module tb;
localparam CLK = 10;
localparam HCLK = CLK/4;
localparam PALETTE_FILE = "doodle_palette.mem";
localparam FILE = "doodle.mem";
logic clk, rst_n;
initial clk=0;
initial rst_n=0;
always #HCLK clk = ~clk;

logic [3:0] pix;
logic [11:0] colr;

logic [3:0] rom_data;
logic [15:0] rom_addr;
logic [15:0] sx, sy;
item_test item_t(
    .i_clk_25(clk),
    .i_rst_n(rst_n),
    .sx(sx),
    .sy(sy),
    .pix(pix),
    .colr(colr)
);
integer i;
initial begin
		$fsdbDumpfile("rom_async.fsdb");
		$fsdbDumpvars;
        #(CLK)
        rst_n = 1;
        rom_addr = 15'd100;
        sx = 0;
        sy = 0;
        // $monitor("colr = %h, rom_addr = %b, rom_data = %h", colr, rom_addr, rom_data);
        $monitor("sx = %d, sy = %d pix = %h, colr = %h",sx, sy, pix, colr);
        #(20000000*CLK)
        $finish;
end
endmodule