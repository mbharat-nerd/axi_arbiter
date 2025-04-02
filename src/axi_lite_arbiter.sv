// Hardcoded NUM_MASTERS = 2 version,
// for compatibility with Vivado
// Vivado does not support loop indices in always_comb etc.

module axi_lite_arbiter #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32,
  parameter bit REGISTER_OUTPUTS = 0
)(
  input logic clk,
  input logic rst_n,

  axi_lite_if.MASTER m_if [2],
  axi_lite_if.SLAVE  s_if
);

  timeunit 1ns;
  timeprecision 1ps;
  // ----------------------------
  // Fixed-priority arbitration
  // ----------------------------
  logic grant;

  always_comb begin
    if (m_if[0].AWVALID)
      grant = 1'b0;
    else if (m_if[1].AWVALID)
      grant = 1'b1;
    else
      grant = 1'b0;
  end

  // ----------------------------
  // AW Channel
  // ----------------------------
  logic [ADDR_WIDTH-1:0] selected_awaddr;
  logic selected_awvalid;

  always_comb begin
    selected_awaddr  = (grant == 1'b0) ? m_if[0].AWADDR  : m_if[1].AWADDR;
    selected_awvalid = (grant == 1'b0) ? m_if[0].AWVALID : m_if[1].AWVALID;
  end

  generate
    if (REGISTER_OUTPUTS) begin : pipe_aw
      sv_pipeline #(.WIDTH(ADDR_WIDTH)) pipe_awaddr (
        .clk(clk), .rst_n(rst_n), .en(1'b1),
        .din(selected_awaddr),
        .dout(s_if.AWADDR)
      );

      sv_pipeline #(.WIDTH(1)) pipe_awvalid (
        .clk(clk), .rst_n(rst_n), .en(1'b1),
        .din(selected_awvalid),
        .dout(s_if.AWVALID)
      );
    end else begin : comb_aw
      assign s_if.AWADDR  = selected_awaddr;
      assign s_if.AWVALID = selected_awvalid;
    end
  endgenerate

  assign m_if[0].AWREADY = (grant == 1'b0) ? s_if.AWREADY : 1'b0;
  assign m_if[1].AWREADY = (grant == 1'b1) ? s_if.AWREADY : 1'b0;

  // ----------------------------
  // W Channel
  // ----------------------------
  assign s_if.WDATA  = (grant == 1'b0) ? m_if[0].WDATA  : m_if[1].WDATA;
  assign s_if.WSTRB  = (grant == 1'b0) ? m_if[0].WSTRB  : m_if[1].WSTRB;
  assign s_if.WVALID = (grant == 1'b0) ? m_if[0].WVALID : m_if[1].WVALID;

  assign m_if[0].WREADY = (grant == 1'b0) ? s_if.WREADY : 1'b0;
  assign m_if[1].WREADY = (grant == 1'b1) ? s_if.WREADY : 1'b0;

  // ----------------------------
  // B Channel (Response)
  // ----------------------------
  assign s_if.BREADY = (grant == 1'b0) ? m_if[0].BREADY : m_if[1].BREADY;

  assign m_if[0].BRESP  = s_if.BRESP;
  assign m_if[1].BRESP  = s_if.BRESP;
  assign m_if[0].BVALID = (grant == 1'b0) ? s_if.BVALID : 1'b0;
  assign m_if[1].BVALID = (grant == 1'b1) ? s_if.BVALID : 1'b0;

  // ----------------------------
  // AR Channel
  // ----------------------------
  assign s_if.ARADDR  = (grant == 1'b0) ? m_if[0].ARADDR  : m_if[1].ARADDR;
  assign s_if.ARVALID = (grant == 1'b0) ? m_if[0].ARVALID : m_if[1].ARVALID;

  assign m_if[0].ARREADY = (grant == 1'b0) ? s_if.ARREADY : 1'b0;
  assign m_if[1].ARREADY = (grant == 1'b1) ? s_if.ARREADY : 1'b0;

  // ----------------------------
  // R Channel
  // ----------------------------
  assign s_if.RREADY = (grant == 1'b0) ? m_if[0].RREADY : m_if[1].RREADY;

  assign m_if[0].RDATA  = s_if.RDATA;
  assign m_if[1].RDATA  = s_if.RDATA;
  assign m_if[0].RRESP  = s_if.RRESP;
  assign m_if[1].RRESP  = s_if.RRESP;
  assign m_if[0].RVALID = (grant == 1'b0) ? s_if.RVALID : 1'b0;
  assign m_if[1].RVALID = (grant == 1'b1) ? s_if.RVALID : 1'b0;

endmodule : axi_lite_arbiter
