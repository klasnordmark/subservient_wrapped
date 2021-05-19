`default_nettype none

module subservient_wrapped (
                            `ifdef USE_POWER_PINS 
                            inout vccd1,
                            inout vssd1,
                            `endif 
                            input	 wb_clk_i,
                            input 	 wb_rst_i,
                            input wbs_stb_i,
                            input wbs_cyc_i,
                            input 		 wbs_we_i,
                            input [3:0] wbs_sel_i,
                            input [31:0] wbs_dat_i,
                            input [31:0] wbs_adr_i,
                            output 		 wbs_ack_o,
                            output [31:0] wbs_dat_o,
			                input la_data_in,
                            output io_out,
                            output io_oeb,
                            output [2:0] irq);
    
    localparam memsize = 512;
    localparam aw      = $clog2(memsize);
    
    wire [aw-1:0] sram_waddr;
    wire [7:0] 	  sram_wdata;
    wire 	        sram_wen;
    wire [aw-1:0] sram_raddr;
    wire [7:0] 	  sram_rdata;
    wire 	        sram_ren;
    
    assign io_oeb = wb_rst_i;
    assign irq    = 3'b000;
    
    ff_ram #(.memsize(memsize), .aw(aw)) sram (
    .reset(wb_rst_i),
    .clk0(wb_clk_i),
    .clk1(wb_clk_i),
    .csb0(!sram_wen),
    .addr0(sram_waddr),
    .din0(sram_wdata),
    .csb1(!sram_ren),
    .addr1(sram_raddr),
    .dout1(sram_rdata)
    );
    
    subservient #(.memsize(memsize), .aw(aw)) subservient_inst
    (
    // Clock & reset
    .i_clk (wb_clk_i),
    .i_rst (wb_rst_i),
    
    //SRAM interface
    .o_sram_waddr (sram_waddr),
    .o_sram_wdata (sram_wdata),
    .o_sram_wen   (sram_wen),
    .o_sram_raddr (sram_raddr),
    .i_sram_rdata (sram_rdata),
    .o_sram_ren   (sram_ren),
    
    
    //Debug interface
    .i_debug_mode (~la_data_in),
    .i_wb_dbg_adr (wbs_adr_i),
    .i_wb_dbg_dat (wbs_dat_i),
    .i_wb_dbg_sel (wbs_sel_i),
    .i_wb_dbg_we  (wbs_we_i),
    .i_wb_dbg_stb (wbs_stb_i),
    .o_wb_dbg_rdt (wbs_dat_o),
    .o_wb_dbg_ack (wbs_ack_o),
    
    // External I/O
    .o_gpio (io_out)
    );
    
endmodule

`default_nettype wire
