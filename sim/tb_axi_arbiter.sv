module tb_axi_arbiter;

  timeunit 1ns;
  timeprecision 1ps;
  // Clock & reset
  logic ACLK = 0;
  logic ARESETn = 0;

  always #5 ACLK = ~ACLK;  // 100 MHz clock

  // Interfaces
  axi_if #(.ADDR_WIDTH(32), .DATA_WIDTH(32), .ID_WIDTH(4)) m_if[2](.*);
  axi_if #(.ADDR_WIDTH(32), .DATA_WIDTH(32), .ID_WIDTH(4)) s_if(.*);

  // DUT
  axi_arbiter #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .ID_WIDTH(4)
  ) dut (
    .clk(ACLK),
    .rst_n(ARESETn),
    .m_if(m_if),
    .s_if(s_if)
  );

  // Reset sequence
  initial begin
    $display("Starting AXI arbiter testbench...");
    ARESETn = 0;
    repeat (4) @(posedge ACLK);
    ARESETn = 1;
    $display("Reset deasserted.");
    #100;
    $display("Ending simulation.");
    $finish;
  end

endmodule
