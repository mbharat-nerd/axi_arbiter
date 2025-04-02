module axi_arbiter #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32,
  parameter int ID_WIDTH   = 4
)(
  input logic clk,
  input logic rst_n,

  axi_if.MASTER m_if [2],
  axi_if.SLAVE  s_if
);

  timeunit 1ns;
  timeprecision 1ps;
  // ----------------------------
  // Fixed-priority arbitration: AW
  // ----------------------------
  logic aw_grant;

  always_comb begin
    if (m_if[0].AWVALID)
      aw_grant = 1'b0;
    else if (m_if[1].AWVALID)
      aw_grant = 1'b1;
    else
      aw_grant = 1'b0;
  end

  assign s_if.AWID     = (aw_grant == 0) ? m_if[0].AWID     : m_if[1].AWID;
  assign s_if.AWADDR   = (aw_grant == 0) ? m_if[0].AWADDR   : m_if[1].AWADDR;
  assign s_if.AWLEN    = (aw_grant == 0) ? m_if[0].AWLEN    : m_if[1].AWLEN;
  assign s_if.AWSIZE   = (aw_grant == 0) ? m_if[0].AWSIZE   : m_if[1].AWSIZE;
  assign s_if.AWBURST  = (aw_grant == 0) ? m_if[0].AWBURST  : m_if[1].AWBURST;
  assign s_if.AWLOCK   = (aw_grant == 0) ? m_if[0].AWLOCK   : m_if[1].AWLOCK;
  assign s_if.AWCACHE  = (aw_grant == 0) ? m_if[0].AWCACHE  : m_if[1].AWCACHE;
  assign s_if.AWPROT   = (aw_grant == 0) ? m_if[0].AWPROT   : m_if[1].AWPROT;
  assign s_if.AWVALID  = (aw_grant == 0) ? m_if[0].AWVALID  : m_if[1].AWVALID;

  assign m_if[0].AWREADY = (aw_grant == 0) ? s_if.AWREADY : 1'b0;
  assign m_if[1].AWREADY = (aw_grant == 1) ? s_if.AWREADY : 1'b0;

  // ----------------------------
  // Fixed-priority arbitration: AR
  // ----------------------------
  logic ar_grant;

  always_comb begin
    if (m_if[0].ARVALID)
      ar_grant = 1'b0;
    else if (m_if[1].ARVALID)
      ar_grant = 1'b1;
    else
      ar_grant = 1'b0;
  end

  assign s_if.ARID     = (ar_grant == 0) ? m_if[0].ARID     : m_if[1].ARID;
  assign s_if.ARADDR   = (ar_grant == 0) ? m_if[0].ARADDR   : m_if[1].ARADDR;
  assign s_if.ARLEN    = (ar_grant == 0) ? m_if[0].ARLEN    : m_if[1].ARLEN;
  assign s_if.ARSIZE   = (ar_grant == 0) ? m_if[0].ARSIZE   : m_if[1].ARSIZE;
  assign s_if.ARBURST  = (ar_grant == 0) ? m_if[0].ARBURST  : m_if[1].ARBURST;
  assign s_if.ARLOCK   = (ar_grant == 0) ? m_if[0].ARLOCK   : m_if[1].ARLOCK;
  assign s_if.ARCACHE  = (ar_grant == 0) ? m_if[0].ARCACHE  : m_if[1].ARCACHE;
  assign s_if.ARPROT   = (ar_grant == 0) ? m_if[0].ARPROT   : m_if[1].ARPROT;
  assign s_if.ARVALID  = (ar_grant == 0) ? m_if[0].ARVALID  : m_if[1].ARVALID;

  assign m_if[0].ARREADY = (ar_grant == 0) ? s_if.ARREADY : 1'b0;
  assign m_if[1].ARREADY = (ar_grant == 1) ? s_if.ARREADY : 1'b0;

  // ----------------------------
  // B Channel (stubbed)
  // TODO: Track and return correct BID, handle out-of-order response
  // ----------------------------
  assign s_if.BREADY = (aw_grant == 0) ? m_if[0].BREADY : m_if[1].BREADY;

  assign m_if[0].BRESP  = s_if.BRESP;
  assign m_if[1].BRESP  = s_if.BRESP;
  assign m_if[0].BVALID = (aw_grant == 0) ? s_if.BVALID : 1'b0;
  assign m_if[1].BVALID = (aw_grant == 1) ? s_if.BVALID : 1'b0;
  assign m_if[0].BID    = s_if.BID;
  assign m_if[1].BID    = s_if.BID;

  // ----------------------------
  // R Channel (stubbed)
  // ----------------------------
  assign s_if.RREADY = (ar_grant == 0) ? m_if[0].RREADY : m_if[1].RREADY;

  assign m_if[0].RDATA  = s_if.RDATA;
  assign m_if[1].RDATA  = s_if.RDATA;
  assign m_if[0].RRESP  = s_if.RRESP;
  assign m_if[1].RRESP  = s_if.RRESP;
  assign m_if[0].RVALID = (ar_grant == 0) ? s_if.RVALID : 1'b0;
  assign m_if[1].RVALID = (ar_grant == 1) ? s_if.RVALID : 1'b0;
  assign m_if[0].RLAST  = s_if.RLAST;
  assign m_if[1].RLAST  = s_if.RLAST;
  assign m_if[0].RID    = s_if.RID;
  assign m_if[1].RID    = s_if.RID;

  // ----------------------------
  // W Channel (to be added)
  // Need to track AWID/WID & handle bursts
  // ----------------------------
  // TODO: Track outstanding write transaction and forward beats

endmodule : axi_arbiter
