`default_nettype none

module ff_ram #(parameter aw = 10,
                parameter memsize = 1024)
              (input wire reset,
                input wire 	    clk,
		input wire 	    wen,
                input wire [aw-1:0] waddr,
                input wire [7:0]    din,

                input wire [aw-1:0] raddr,
                output reg [7:0]    dout);
    
    parameter DATA_WIDTH = 8 ;
    parameter ADDR_WIDTH = aw ;

    integer i;
    
    // Memory
    reg [DATA_WIDTH-1:0] mem[0:memsize-1];
    
   always @(posedge clk) begin
      if (wen)
        mem[waddr] = din;
      dout <= mem[raddr];

      if (reset) begin
	dout <= 0;
        for (i = 0; i < memsize; i = i + 1) begin
          mem[i] = 0;
        end
      end
    end
    
endmodule

`default_nettype wire
