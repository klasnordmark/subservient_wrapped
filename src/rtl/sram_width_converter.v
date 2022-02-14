`default_nettype none
module sram_width_converter
  #(parameter aw = 10)
  (
   input wire 		i_clk,
   //8-bit Subservient interface
   input wire [aw-1:0] 	i_sram_waddr,
   input wire [7:0] 	i_sram_wdata,
   input wire 		i_sram_wen,
   input wire [aw-1:0] 	i_sram_raddr,
   output wire [7:0] 	o_sram_rdata,
   input wire 		i_sram_ren,
   //32-bit OpenRAM interface
   output wire 		o_csb0,
   output wire 		o_web0,
   output wire [3:0] 	o_wmask0,
   output wire [aw-3:0] o_addr0,
   output wire [32:0] 	o_din0,
   input wire [32:0] 	i_dout0);

   assign o_csb0 = !(i_sram_wen | i_sram_ren);
   assign o_web0 = !i_sram_wen;
   assign o_wmask0 = 4'd1 << i_sram_waddr[1:0]; //Decode address LSB to write mask
   assign o_addr0 = i_sram_wen ? i_sram_waddr[aw-1:2] : i_sram_raddr[aw-1:2]; //Memory is 32-bit word-addressed. Cut off 2 LSB
   assign o_din0  = {1'b0,{4{i_sram_wdata}}}; //Mirror write data to all byte lanes

   reg [1:0] 		sram_bsel;
   always @(posedge i_clk)
     sram_bsel <= i_sram_raddr[1:0];

   assign o_sram_rdata = i_dout0[sram_bsel*8+:8]; //Pick the right byte from the read data

endmodule
`default_nettype wire
