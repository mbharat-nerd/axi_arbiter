module tb_axi_lite_arbiter;
  timeunit 1ns;
  timeprecision 1ps;

  logic clk = 0;
  logic rst_n = 0;

  always #5 clk = ~clk; // 100 MHz

  // Interfaces
  axi_lite_if #(.ADDR_WIDTH(32), .DATA_WIDTH(32)) m_if[2](clk, rst_n);
  axi_lite_if #(.ADDR_WIDTH(32), .DATA_WIDTH(32)) s_if(clk, rst_n);

  // DUT
  axi_lite_arbiter #(
    .REGISTER_OUTPUTS(0)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .m_if(m_if),
    .s_if(s_if)
  );

  // Simple slave model
  initial begin
    s_if.AWREADY = 0;
    s_if.WREADY  = 0;
    s_if.BVALID  = 0;
    s_if.BRESP   = 2'b00;

    s_if.ARREADY = 0;
    s_if.RVALID  = 0;
    s_if.RRESP   = 2'b00;
    s_if.RDATA   = 32'hCAFE_BABE;

    wait (rst_n);
    forever begin
      if (s_if.AWVALID) begin
        #10 s_if.AWREADY = 1;
        #10 s_if.AWREADY = 0;
        s_if.BVALID = 1;
      end

      if (s_if.WVALID) begin
        #10 s_if.WREADY = 1;
        #10 s_if.WREADY = 0;
      end

      if (s_if.BVALID && (m_if[0].BREADY || m_if[1].BREADY)) begin
        s_if.BVALID = 0;
      end

      if (s_if.ARVALID) begin
        #10 s_if.ARREADY = 1;
        #10 s_if.ARREADY = 0;
        s_if.RVALID = 1;
      end

      if (s_if.RVALID && (m_if[0].RREADY || m_if[1].RREADY)) begin
        s_if.RVALID = 0;
      end

      #1;
    end
  end

  // Stimulus for both masters
  initial begin
    $display("Starting 2-Master AXI-Lite Arbiter Testbench");
    rst_n = 0;
    #20 rst_n = 1;

    fork
      // Master 0 - higher priority
      begin
        @(posedge clk);
        m_if[0].AWADDR  <= 32'h0000_0000;
        m_if[0].AWVALID <= 1;
        wait (m_if[0].AWREADY);
        m_if[0].AWVALID <= 0;

        m_if[0].WDATA   <= 32'hAAAA5555;
        m_if[0].WSTRB   <= 4'b1111;
        m_if[0].WVALID  <= 1;
        wait (m_if[0].WREADY);
        m_if[0].WVALID  <= 0;

        m_if[0].BREADY <= 1;
        wait (m_if[0].BVALID);
        m_if[0].BREADY <= 0;

        m_if[0].ARADDR  <= 32'h0000_0004;
        m_if[0].ARVALID <= 1;
        wait (m_if[0].ARREADY);
        m_if[0].ARVALID <= 0;

        m_if[0].RREADY <= 1;
        wait (m_if[0].RVALID);
        $display("[%0t] M0 read: %h", $time, m_if[0].RDATA);
        m_if[0].RREADY <= 0;
      end

      // Master 1 - lower priority
      begin
        @(posedge clk);
        m_if[1].AWADDR  <= 32'h1000_0000;
        m_if[1].AWVALID <= 1;
        wait (m_if[1].AWREADY);
        m_if[1].AWVALID <= 0;

        m_if[1].WDATA   <= 32'hDEADBEEF;
        m_if[1].WSTRB   <= 4'b1111;
        m_if[1].WVALID  <= 1;
        wait (m_if[1].WREADY);
        m_if[1].WVALID  <= 0;

        m_if[1].BREADY <= 1;
        wait (m_if[1].BVALID);
        m_if[1].BREADY <= 0;

        m_if[1].ARADDR  <= 32'h1000_0004;
        m_if[1].ARVALID <= 1;
        wait (m_if[1].ARREADY);
        m_if[1].ARVALID <= 0;

        m_if[1].RREADY <= 1;
        wait (m_if[1].RVALID);
        $display("[%0t] M1 read: %h", $time, m_if[1].RDATA);
        m_if[1].RREADY <= 0;
      end
    join

    $display("Test complete.");
    #20 $finish;
  end

endmodule
