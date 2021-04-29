module subservient_wrapped (input wb_clk_i,
                            input wb_rst_i,
                            input wbs_stb_i,
                            input wbs_cyc_i,
                            input wbs_we_i,
                            input [3:0] wbs_sel_i,
                            input [31:0] wbs_dat_i,
                            input [31:0] wbs_adr_i,
                            output wbs_ack_o,
                            output [31:0] wbs_dat_o,
                            input [127:0] la_data_in,
                            output [127:0] la_data_out,
                            input [127:0] la_oen,
                            input [`MPRJ_IO_PADS-1:0] io_in,
                            output [`MPRJ_IO_PADS-1:0] io_out,
                            output [`MPRJ_IO_PADS-1:0] io_oeb,
                            );
    
    localparam memsize = 8192;
    localparam aw      = $clog2(memsize);
    
    wire [aw-1:0] sram_waddr;
    wire [7:0] 	 sram_wdata;
    wire 	 sram_wen;
    wire [aw-1:0] sram_raddr;
    wire [7:0] 	 sram_rdata;
    wire 	 sram_ren;
    
    
     sram_1rw1r_32_256_8_sky130 sram (
    .clk0   (wb_clk_i),
    .csb0   (!sram_wen),
    .web0   (1'b0),
    .wmask0 (wmask0),
    .addr0  (waddr0),
    .din0   (din0),
    .dout0  (),
    .clk1   (wb_clk_i),
    .csb1   (!sram_ren),
    .addr1  (addr1),
    .dout1  (dout1)
    );
    
    //Adapt the 8-bit SRAM interface from subservient to the 32-bit OpenRAM instance
    reg [1:0] sram_bsel;
    always @(posedge wb_clk_i) begin
        sram_bsel <= sram_raddr[1:0];
    end
    
    wire [3:0] wmask0;// = 4'd1 << sram_waddr[1:0];
    assign wmask0        = 4'd1 << sram_waddr[1:0];
    wire [7:0] waddr0;// = sram_waddr[9:2]; //256 32-bit words = 1kB
    assign waddr0        = sram_waddr[9:2];
    wire [31:0] din0;//  = {4{sram_wdata}}; //Mirror write data to all byte lanes
    assign din0          = {4{sram_wdata}};
    
    wire [7:0]  addr1;// = sram_raddr[9:2];
    assign addr1         = sram_raddr[9:2];
    wire [31:0] dout1;
    assign sram_rdata = dout1[sram_bsel*8+:8]; //Pick the right byte from the read data
    
    subservient subservient_inst
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
    .i_debug_mode (la_data_in[0]),
    .i_wb_dbg_adr (wbs_adr_i),
    .i_wb_dbg_dat (wbs_dat_i),
    .i_wb_dbg_sel (wbs_sel_i),
    .i_wb_dbg_we  (wbs_we_i),
    .i_wb_dbg_stb (wbs_stb_i),
    .o_wb_dbg_rdt (wbs_dat_o),
    .o_wb_dbg_ack (wbs_ack_o),
    
    // External I/O
    .o_gpio (io_out[1])
    );
    
endmodule
