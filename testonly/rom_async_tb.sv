`timescale 1ns/100ps
module tb;
localparam CLK = 10;
localparam HCLK = CLK/4;
localparam PALETTE_FILE = "doodle_palette.mem";
localparam FILE = "doodle.mem";
logic clk;
initial clk=0;
always #HCLK clk = ~clk;

logic [3:0] pix;
logic [11:0] colr;

logic [3:0] rom_data;
logic [15:0] rom_addr;
rom_sync #(
    .WIDTH(4), 
    .DEPTH(512*128), 
    .INIT_F(FILE)
) title_rom (
    .clk(clk), 
    .addr(rom_addr), 
    .data(rom_data)
);

rom_async #(
		.WIDTH(12), 
		.DEPTH(16), 
		.INIT_F(PALETTE_FILE), 
        .ADDRW(4)
    ) title_clut(
        .addr(rom_data), 
        .data(colr)
    );
initial begin
		$fsdbDumpfile("rom_async.fsdb");
		$fsdbDumpvars;
        pix = 4'd1;
        rom_addr = 15'd100;
        $monitor("colr = %h, rom_addr = %b, rom_data = %h", colr, rom_addr, rom_data);
        #(20000000*CLK)
        $finish;
end
endmodule