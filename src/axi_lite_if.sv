interface axi_lite_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32)
    (input logic ACLK,
     input logic ARESETn);
    
    // Write Address Channel (AW)
    logic [ADDR_WIDTH-1:0] AWADDR;
    logic AWVALID;
    logic AWREADY;
    
    // Write Data Channel (W)
    logic [DATA_WIDTH-1:0] WDATA;
    logic [(DATA_WIDTH/8)-1:0] WSTRB;
    logic WVALID;
    logic WREADY;
    
    // Write Response Channel (B)
    logic [1:0] BRESP;
    logic BVALID;
    logic BREADY;
    
    // Read Address Channel (AR)
    logic [ADDR_WIDTH-1:0] ARADDR;
    logic ARVALID;
    logic ARREADY;
    
    // Read Data Channel (R)
    logic [DATA_WIDTH-1:0] RDATA;
    logic [1:0] RRESP;
    logic RVALID;
    logic RREADY;
    
    // Modports
    modport MASTER (
        input ACLK,
        input ARESETn,
        
        input AWREADY,
        input WREADY,
        input BRESP, BVALID,
        input ARREADY,
        input RDATA, RRESP, RVALID,
        
        output AWADDR, AWVALID,
        output WDATA, WSTRB, WVALID,
        output BREADY,
        output ARADDR, ARVALID,
        output RREADY);
        
   modport SLAVE (
        input ACLK,
        input ARESETn,
        
        input AWADDR, AWVALID,
        input WDATA, WSTRB, WVALID,
        input BREADY,
        input ARADDR, ARVALID,
        input RREADY,
        
        output AWREADY,
        output WREADY,
        output BRESP, BVALID,
        output ARREADY,
        output RDATA, RRESP, RVALID);
   
   // for verification
   modport MONITOR (
    input ACLK, ARESETn,
    
    input AWADDR, AWVALID, AWREADY,
    input WDATA, WSTRB, WVALID, WREADY,
    input BRESP, BVALID, BREADY,
    
    input ARADDR, ARVALID, ARREADY,
    input RDATA, RRESP, RVALID, RREADY);        
    
endinterface: axi_lite_if
