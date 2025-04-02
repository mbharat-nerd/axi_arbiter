module axi_arbiter #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32,
  parameter int NUM_MASTERS = 2,
  parameter bit REGISTER_OUTPUTS = 0
)(
  input logic clk,
  input logic rst_n,

  axi_lite_if.MASTER m_if [NUM_MASTERS],
  axi_lite_if.SLAVE  s_if
);

    timeunit 1ns;
    timeprecision 1ps;
  // ----------------------------
  // Arbitration (priority)
  // ----------------------------
  logic [$clog2(NUM_MASTERS)-1:0] grant;

  always_comb begin
    grant = '0;
    for (int i = 0; i < NUM_MASTERS; i++) begin
      if (m_if[i].AWVALID) begin
        grant = i;
        break;
      end
    end
  end

  // ----------------------------
  // WRITE ADDRESS (AW) Channel
  // ----------------------------
  generate
    if (REGISTER_OUTPUTS) begin : pipe_aw
      logic [ADDR_WIDTH-1:0] awaddr_p;
      logic                  awvalid_p;

      sv_pipeline #(.WIDTH(ADDR_WIDTH)) pipe_awaddr (
        .clk(clk), .rst_n(rst_n), .en(1'b1),
        .din(m_if[grant].AWADDR),
        .dout(awaddr_p)
      );

      sv_pipeline #(.WIDTH(1)) pipe_awvalid (
        .clk(clk), .rst_n(rst_n), .en(1'b1),
        .din(m_if[grant].AWVALID),
        .dout(awvalid_p)
      );

      assign s_if.AWADDR  = awaddr_p;
      assign s_if.AWVALID = awvalid_p;
    end else begin : comb_aw
      assign s_if.AWADDR  = m_if[grant].AWADDR;
      assign s_if.AWVALID = m_if[grant].AWVALID;
    end
  endgenerate

  for (genvar i = 0; i < NUM_MASTERS; i++) begin : gen_awready
    assign m_if[i].AWREADY = (i == grant) ? s_if.AWREADY : 1'b0;
  end

  // ----------------------------
  // WRITE DATA (W) Channel
  // ----------------------------
  generate
    if (REGISTER_OUTPUTS) begin : pipe_w
      logic [DATA_WIDTH-1:0] wdata_p;
      logic [(DATA_WIDTH/8)-1:0] wstrb_p;
      logic wvalid_p;

      sv_pipeline #(.WIDTH(DATA_WIDTH)) pipe_wdata (
        .clk(clk), .rst_n(rst_n), .en(1'b1),
        .din(m_if[grant].WDATA),
        .dout(wdata_p)
      );

      sv_pipeline #(.WIDTH(DATA_WIDTH/8)) pipe_wstrb (
        .clk(clk), .rst_n(rst_n), .en(1'b1),
        .din(m_if[grant].WSTRB),
        .dout(wstrb_p)
      );

      sv_pipeline #(.WIDTH(1)) pipe_wvalid (
        .clk(clk), .rst_n(rst_n), .en(1'b1),
        .din(m_if[grant].WVALID),
        .dout(wvalid_p)
      );

      assign s_if.WDATA  = wdata_p;
      assign s_if.WSTRB  = wstrb_p;
      assign s_if.WVALID = wvalid_p;
    end else begin : comb_w
      assign s_if.WDATA  = m_if[grant].WDATA;
      assign s_if.WSTRB  = m_if[grant].WSTRB;
      assign s_if.WVALID = m_if[grant].WVALID;
    end
  endgenerate

  for (genvar i = 0; i < NUM_MASTERS; i++) begin : gen_wready
    assign m_if[i].WREADY = (i == grant) ? s_if.WREADY : 1'b0;
  end

  // ----------------------------
  // WRITE RESPONSE (B)
  // ----------------------------
  assign s_if.BREADY = m_if[grant].BREADY;
  for (genvar i = 0; i < NUM_MASTERS; i++) begin
    assign m_if[i].BRESP  = s_if.BRESP;
    assign m_if[i].BVALID = (i == grant) ? s_if.BVALID : 1'b0;
  end

  // ----------------------------
  // READ ADDRESS (AR)
  // ----------------------------
  generate
    if (REGISTER_OUTPUTS) begin : pipe_ar
      logic [ADDR_WIDTH-1:0] araddr_p;
      logic                  arvalid_p;

      sv_pipeline #(.WIDTH(ADDR_WIDTH)) pipe_araddr (
        .clk(clk), .rst_n(rst_n), .en(1'b1),
        .din(m_if[grant].ARADDR),
        .dout(araddr_p)
      );

      sv_pipeline #(.WIDTH(1)) pipe_arvalid (
        .clk(clk), .rst_n(rst_n), .en(1'b1),
        .din(m_if[grant].ARVALID),
        .dout(arvalid_p)
      );

      assign s_if.ARADDR  = araddr_p;
      assign s_if.ARVALID = arvalid_p;
    end else begin : comb_ar
      assign s_if.ARADDR  = m_if[grant].ARADDR;
      assign s_if.ARVALID = m_if[grant].ARVALID;
    end
  endgenerate

  for (genvar i = 0; i < NUM_MASTERS; i++) begin : gen_arready
    assign m_if[i].ARREADY = (i == grant) ? s_if.ARREADY : 1'b0;
  end

  // ----------------------------
  // READ DATA (R)
  // ----------------------------
  assign s_if.RREADY = m_if[grant].RREADY;
  for (genvar i = 0; i < NUM_MASTERS; i++) begin
    assign m_if[i].RDATA  = s_if.RDATA;
    assign m_if[i].RRESP  = s_if.RRESP;
    assign m_if[i].RVALID = (i == grant) ? s_if.RVALID : 1'b0;
  end

endmodule : axi_arbiter
