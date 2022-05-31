`timescale 1ns/100ps
module tb;
localparam CLK = 10;
localparam HCLK = CLK/2;
localparam PALETTE_FILE = "doodle_palette.mem";
localparam FILE = "doodle.mem";
logic clk, rst_n;
initial clk=0;
initial rst_n=0;
always #HCLK clk = ~clk;

logic [3:0] pix;
logic [11:0] colr;
logic [9:0] sx, sy;
logic [7:0] o_vga_r,o_vga_g,o_vga_b;
logic o_VGA_BLANK_N,o_VGA_CLK,o_VGA_HS,o_VGA_SYNC_N,o_VGA_VS;
vga image_t(
    .i_rst_n(rst_n),
    .i_clk_25M(clk),
    .VGA_B(o_vga_b),
    .VGA_BLANK_N(o_VGA_BLANK_N),
    .VGA_CLK(o_VGA_CLK),
    .VGA_G(o_vga_g),
    .VGA_HS(o_VGA_HS),
    .VGA_R(o_vga_r),
    .VGA_SYNC_N(o_VGA_SYNC_N),
    .VGA_VS(o_VGA_VS),
    .sx(sx),
    .sy(sy)
);
integer i;
initial begin
		$fsdbDumpfile("rom_async.fsdb");
		$fsdbDumpvars;
        #(CLK)
        rst_n = 1;
        // $monitor("colr = %h, rom_addr = %b, rom_data = %h", colr, rom_addr, rom_data);
        //$monitor("R = %h, G = %h ,B = %h",o_vga_r, o_vga_g, o_vga_b);
        $monitor("x= %d, y=%d, R = %h, G = %h ,B = %h",sx, sy,o_vga_r, o_vga_g, o_vga_b);
        #(20*CLK)
        $finish;
end
endmodule