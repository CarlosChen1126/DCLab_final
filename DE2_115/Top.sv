module Top (
    input i_clk, 
    input i_rst_n, 

    // VGA
    input i_clk_25, 
    output [7:0] VGA_R, 
    output [7:0] VGA_G, 
    output [7:0] VGA_B, 
    output VGA_CLK, 
    output VGA_BLANK_N, 
    output VGA_HS, 
    output VGA_VS, 
    output VGA_SYNC_N,

    // Game
    input i_next
);
    // display sync signals and coordinates
    localparam CORDW = 16; // screen coordinate width
    parameter COLR_BITS = 4;
    parameter H_RES = 640;
    logic signed [CORDW-1:0] sx, sy;
    logic de, line;
    assign VGA_R = r_r;
    assign VGA_G = g_r;
    assign VGA_B = b_r;
	assign VGA_CLK = i_clk_25;

    // display color
    parameter WIN_TRANS = 0;
    logic [7:0] r_r, r_w, g_r, g_w, b_r, b_w;

    always_comb begin
        r_w = (win_drawing_r && !(win_pix == WIN_TRANS) && de) ? {win_colr[11:8], 4'b0} : 8'b0;
        g_w = (win_drawing_r && !(win_pix == WIN_TRANS) && de) ? {win_colr[7:4], 4'b0} : 8'b0;
        b_w = (win_drawing_r && !(win_pix == WIN_TRANS) && de) ? {win_colr[3:0], 4'b0} : 8'b0;
    end
	always_ff @(posedge i_clk_25 or negedge i_rst_n) begin
		if (!i_rst_n) begin
            r_r <= 8'b0;
            g_r <= 8'b0;
            b_r <= 8'b0;
        end
		else begin
            r_r <= r_w;
            g_r <= g_w;
            b_r <= b_w;
        end
    end


    logic [3:0] win_pix;
    logic [11:0] win_colr;
    logic win_drawing_r;
    item #(
        .FILE("test.mem"), 
        .PALETTE_FILE("test_palette.mem"), 
        .WIDTH(267), 
        .HEIGHT(312)
    ) win (
        .i_clk_25(i_clk_25), 
        .i_rst_n(i_rst_n), 
        .sx(sx), 
        .sy(sy), 
        .x_init(-30), 
        .y_init(-10), 
        .line(line), 
        .pix(win_pix), 
        .colr(win_colr), 
        .drawing_r(win_drawing_r)
    );

    // monitor
    logic monitor_start_r, monitor_start_w;
    assign monitor_start_w = monitor_start_r;
	always_ff @(posedge i_clk_25 or negedge i_rst_n) begin
		if (!i_rst_n) begin
            monitor_start_r <= 1'b1;
        end
        else begin
            monitor_start_r <= monitor_start_w;       
        end
    end
    display_1 display0(
        .clk_25M(i_clk_25), 
        .rst_n(i_rst_n), 
        .VGA_BLANK_N(VGA_BLANK_N), 
        .VGA_HS(VGA_HS), 
        .VGA_VS(VGA_VS), 
        .VGA_SYNC_N(VGA_SYNC_N), 
        .de(de),  
        .line(line), 
        .sx(sx), 
        .sy(sy), 
        .i_start_display(monitor_start_r)
    );
    logic [3:0] o_random_out, timeout_r, timeout_w;
    logic [3:0] time_count_w, time_count_r;
    logic [24:0] sec_count_w, sec_count_r;
    lfsr lfsr0(
        .i_clk(i_clk_25),
        .i_rst_n(i_rst_n),
        .o_random_out(o_random_out)
    );
    always_comb begin
        case(state_r)
            S_GAME: begin
                
            end
        endcase
    end
    //TODO
    //Game FSM
    logic [2:0] state_r, state_w;
    localparam S_IDLE = 3'd0;
    localparam S_INST = 3'd1;
    localparam S_GAME = 3'd2;
    localparam S_MODET = 3'd3;
    localparam S_KILL = 3'd4;
    localparam S_DIE = 3'd5;
    localparam S_WIN = 3'd6;
    localparam S_END = 3'd7;

    always_comb begin
        case(state_r)
            S_IDLE: begin
                if(i_next) begin
                    state_w = S_INST;
                    timeout_w = timeout_r;
                end
                else begin
                    state_w = S_IDLE;
                    timeout_w = timeout_r;
                end
            end
            S_INST: begin
                if(i_next) begin
                    state_w = S_GAME;
                    timeout_w = o_random_out;
                end
                else begin
                    state_w = S_INST;
                    timeout_w = timeout_r;
                end
                
            end
            S_GAME: begin
                if(sec_count_r[25] == 1)begin
                    state_w = S_GAME;
                    time_count_w = time_count_r+1;
                end
                else begin
                    state_w = S_GAME;
                    time_count_w = time_count_r;
                end
                if(time_count_r == timeout_r) begin
                    state_w = S_MODET;
                    time_count_w = 0;
                    sec_count_w = 0;
                end
                else begin
                    if(i_finish_key) begin
                        state_w = S_WIN;
                        time_count_w = 0;
                        sec_count_w = 0;
                    end
                end
            end
            S_MODET: begin
                if(i_detected) begin
                    state_w = S_KILL;
                end
                else begin
                    if(sec_count_r[25] == 1)begin
                        state_w = S_MODET;
                        time_count_w = time_count_r+1;
                    end
                    else begin
                        state_w = S_MODET;
                        time_count_w = time_count_r;
                    end
                    if(time_count_r == timeout_r) begin
                        state_w = S_GAME;
                        time_count_w = 0;
                        sec_count_w = 0;
                    end 
                end
            end
            S_KILL: begin
                //handle servo
            end
            S_DIE: begin
                if(i_next) begin
                    state_w = S_END;
                end
                else begin
                    state_w = S_DIE;
                end
            end
            S_WIN: begin
                if(i_next) begin
                    state_w = S_END;
                end
                else begin
                    state_w = S_WIN;
                end
            end
            S_END: begin
                if(i_next) begin
                    state_w = S_IDLE;
                end
                else begin
                    state_w = S_END;
                end
            end
        endcase
        
    end
    always_ff @(posedge i_clk_25 or negedge i_rst_n) begin : blockName
        if(!i_rst_n) begin
            state_r <= S_IDLE;
            sec_count_r <= 0;
        end
        else begin
            state_r <= state_w;
            if(sec_count_r[25] == 1)begin
                sec_count_r <= 0;
            end
            else begin
               sec_count_r <= sec_count_w + 1; 
            end
        end
    end
endmodule