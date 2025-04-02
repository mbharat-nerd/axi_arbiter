interface axi_if #(
  parameter int DATA_WIDTH = 32,
  parameter int ADDR_WIDTH = 32,
  parameter int ID_WIDTH   = 4
) (
  input logic ACLK,
  input logic ARESETn
);

  // -------------------------------------
  // Write Address Channel (AW)
  // -------------------------------------
  logic [ID_WIDTH-1:0]     AWID;
  logic [ADDR_WIDTH-1:0]   AWADDR;
  logic [7:0]              AWLEN;
  logic [2:0]              AWSIZE;
  logic [1:0]              AWBURST;
  logic                    AWLOCK;
  logic [3:0]              AWCACHE;
  logic [2:0]              AWPROT;
  logic                    AWVALID;
  logic                    AWREADY;

  // -------------------------------------
  // Write Data Channel (W)
  // -------------------------------------
  logic [DATA_WIDTH-1:0]   WDATA;
  logic [DATA_WIDTH/8-1:0] WSTRB;
  logic                    WLAST;
  logic                    WVALID;
  logic                    WREADY;

  // -------------------------------------
  // Write Response Channel (B)
  // -------------------------------------
  logic [ID_WIDTH-1:0]     BID;
  logic [1:0]              BRESP;
  logic                    BVALID;
  logic                    BREADY;

  // -------------------------------------
  // Read Address Channel (AR)
  // -------------------------------------
  logic [ID_WIDTH-1:0]     ARID;
  logic [ADDR_WIDTH-1:0]   ARADDR;
  logic [7:0]              ARLEN;
  logic [2:0]              ARSIZE;
  logic [1:0]              ARBURST;
  logic                    ARLOCK;
  logic [3:0]              ARCACHE;
  logic [2:0]              ARPROT;
  logic                    ARVALID;
  logic                    ARREADY;

  // -------------------------------------
  // Read Data Channel (R)
  // -------------------------------------
  logic [ID_WIDTH-1:0]     RID;
  logic [DATA_WIDTH-1:0]   RDATA;
  logic [1:0]              RRESP;
  logic                    RLAST;
  logic                    RVALID;
  logic                    RREADY;

  // -------------------------------------
  // Modports
  // -------------------------------------
  modport MASTER (
    input  ACLK, ARESETn,
    output AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWLOCK, AWCACHE, AWPROT,
           AWVALID,
    input  AWREADY,

    output WDATA, WSTRB, WLAST, WVALID,
    input  WREADY,

    input  BID, BRESP, BVALID,
    output BREADY,

    output ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARLOCK, ARCACHE, ARPROT,
           ARVALID,
    input  ARREADY,

    input  RID, RDATA, RRESP, RLAST, RVALID,
    output RREADY
  );

  modport SLAVE (
    input  ACLK, ARESETn,
    input  AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWLOCK, AWCACHE, AWPROT,
           AWVALID,
    output AWREADY,

    input  WDATA, WSTRB, WLAST, WVALID,
    output WREADY,

    output BID, BRESP, BVALID,
    input  BREADY,

    input  ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARLOCK, ARCACHE, ARPROT,
           ARVALID,
    output ARREADY,

    output RID, RDATA, RRESP, RLAST, RVALID,
    input  RREADY
  );

endinterface
