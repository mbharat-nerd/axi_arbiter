module sv_pipeline 
    #(parameter WIDTH = 32)
    (input logic clk,
     input logic rst_n,
     input logic en, // optional enable for pipelining
     input logic [WIDTH-1:0] din,
     output logic [WIDTH-1:0] dout);
     
     timeunit 1ns;
     timeprecision 1ps;
     
     always_ff @(posedge clk) begin
        if (!rst_n)
            dout <= '0;
        else
            if (en)
                dout <= din;            
     end
endmodule : sv_pipeline     