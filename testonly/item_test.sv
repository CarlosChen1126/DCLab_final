module item_test (
    input i_clk_25, 
    input i_rst_n,
    input [9:0] sx, 
    input [9:0] sy,
    output [3:0] pix, 
    output [11:0] colr  
);
    

localparam PALETTE_FILE = "doodle_palette.mem";
localparam FILE = "doodle.mem";


logic [3:0] pix_w, pix_r;
logic [11:0] colr_w, colr_r;
assign colr = colr_r;
assign pix = pix_r;

logic [15:0] rom_addr_w, rom_addr_r;
always_comb begin
    rom_addr_w = sx + sy*64;
end
    
always_ff @(posedge i_clk_25 or negedge i_rst_n ) begin
    if(!i_rst_n) begin
        pix_r <= 4'd0;
        colr_r <= 12'd0;
        rom_addr_r <= 0;
    end
    else begin
        pix_r <= pix_w;
        colr_r <= colr_w;
        rom_addr_r <= rom_addr_w;
    end

end
    
rom_sync #(
    .WIDTH(4), 
    .DEPTH(64*64), 
    .INIT_F(FILE)
) title_rom (
    .clk(i_clk_25), 
    .addr(rom_addr_r), 
    .data(pix_w)
);

rom_async #(
		.WIDTH(12), 
		.DEPTH(16), 
		.INIT_F(PALETTE_FILE), 
        .ADDRW(4)
    ) title_clut(
        .addr(pix_r), 
        .data(colr_w)
    );
endmodule