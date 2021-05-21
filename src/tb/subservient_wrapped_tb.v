/*
 * subservient_wrapper_tb.v : Verilog testbench for Subservient with RAM
 *
 * SPDX-FileCopyrightText: 2021 Klas Nordmark <klas.nordmark.se@ieee.org>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

`include "/home/klasn/git/openlane-master/pdks/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v"
`include "/home/klasn/git/openlane-master/pdks/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"
`include "/home/klasn/git/openlane-master/pdks/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_ef_sc_hd__fakediode_2.v"

module subservient_wrapper_tb; 
    parameter memfile = ""; 
    parameter memsize = 512; 
    parameter with_csr = 0; 
    parameter aw = $clog2(memsize);
    
    reg clk = 1'b0;
    reg rst = 1'b1;
    
    wire PWR = 1'b1;
    wire GND = 1'b0;

    //Debug interface
    reg 		 la_data_in;
    reg [31:0] 	 wbs_adr_i;
    reg [31:0] 	 wbs_dat_i;
    reg [3:0] 	 wbs_sel_i;
    reg 		 wbs_we_i;
    reg 		 wbs_stb_i = 1'b0;
    wire [31:0]  wbs_dat_o;
    wire 	     wbs_ack_o;
    
    wire io_out;
    
    always  #5 clk  <= !clk;
    initial #62 rst <= 1'b0;
    
    vlog_tb_utils vtu();
    
    integer baudrate = 0;
    initial begin
        if ($value$plusargs("uart_baudrate=%d", baudrate))
            $display("UART decoder using baud rate %0d", baudrate);
        else
            forever
                @(io_out) $display("%0t output o_gpio is %s", $time, io_out ? "ON" : "OFF");
        
    end
    
    reg [1023:0] firmware_file;
    integer 	idx = 0;
    reg [7:0] 	 mem [0:memsize-1];
    
    task wb_dbg_write32(input [31:0] adr, input [31:0] dat);
        begin
            @ (posedge clk) begin
                wbs_adr_i <= adr;
                wbs_dat_i <= dat;
                wbs_sel_i <= 4'b1111;
                wbs_we_i  <= 1'b1;
                wbs_stb_i <= 1'b1;
            end
            while (!wbs_ack_o)
                @ (posedge clk);
            wbs_stb_i <= 1'b0;
        end
    endtask
    
    reg [31:0] tmp_dat;
    integer    adr;
    reg [1:0]  bsel;
    
    initial begin
        $display("Setting debug mode");
        la_data_in <= 1'b0;
        if ($value$plusargs("firmware=%s", firmware_file)) begin
            $display("Writing %0s to SRAM", firmware_file);
            $readmemh(firmware_file, mem);
        end else
            $display("No application to load. SRAM will be empty");
            
        repeat (10) @(posedge clk);
            
        //Write full 32-bit words
        while ((mem[idx] !== 8'bxxxxxxxx) && (idx < memsize)) begin
            adr                = (idx >> 2)*4;
            bsel               = idx[1:0];
            tmp_dat[bsel*8+:8] = mem[idx];
            if (bsel == 2'd3)
                wb_dbg_write32(adr, tmp_dat);
            idx = idx + 1;
        end
                
        //Zero-pad final word if required
        if (idx[1:0]) begin
            adr      = (idx >> 2)*4;
            bsel     = idx[1:0];
            if (bsel == 1) tmp_dat[31:8] = 24'd0;
            if (bsel == 2) tmp_dat[31:16] = 16'd0;
            if (bsel == 3) tmp_dat[31:24] = 8'd0;
            wb_dbg_write32(adr, tmp_dat);
        end
        repeat (10) @(posedge clk);
                
        $display("Done writing %0d bytes to SRAM. Turning off debug mode", idx);
        la_data_in <= 1'b1;
    end
            
    uart_decoder uart_decoder (baudrate, io_out);
            
    subservient_wrapped dut
    (
    `ifdef USE_POWER_PINS
    .vccd1(PWR),
    .vssd1(GND),
    `endif    
    // Clock & reset
    .wb_clk_i (clk),
    .wb_rst_i (rst),
            
    //Debug interface
    .la_data_in (la_data_in),
    .wbs_adr_i (wbs_adr_i),
    .wbs_dat_i (wbs_dat_i),
    .wbs_sel_i (wbs_sel_i),
    .wbs_we_i  (wbs_we_i),
    .wbs_stb_i (wbs_stb_i),
    .wbs_dat_o (wbs_dat_o),
    .wbs_ack_o (wbs_ack_o),
            
    // External I/O
    .io_out (io_out));
            
endmodule
