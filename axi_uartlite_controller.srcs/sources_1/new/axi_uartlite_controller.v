`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/19 01:54:28
// Design Name: 
// Module Name: axi_uartlite_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_uartlite_controller(
    input CLK,
    input RST,      // rst
    input RX,       // from host pc to fpga
    output TX,      // from fpga to host pc
    output READ_VALID,
    input READ_READY,
    output [7:0]READ_DATA,  // from uart to controller
    input WRITE_VALID,
    output WRITE_READY,
    input [7:0]WRITE_DATA   // from controller to uart
    );
    
////////////////////
// axi_lite_wire
////////////////////
    wire interrupt;     // don't use
    wire [3:0]awaddr;
    wire awvalid;
    wire awready;
    wire [31:0]wdata;
    wire [3:0]wstrb;
    wire wvalid;
    wire wready;
    wire [1:0]bresp;
    wire bvalid;
    wire bready;
    wire [3:0]araddr;
    wire arvalid;
    wire arready;
    wire [31:0]rdata;
    wire [1:0]rresp;
    wire rvalid;
    wire rready;

////////////////////
// uart_module
////////////////////
    axi_uartlite_0 uart (
        .s_axi_aclk(CLK),        // input wire s_axi_aclk
        .s_axi_aresetn(RST),  // input wire s_axi_aresetn
        .interrupt(interrupt),          // output wire interrupt
        .s_axi_awaddr(awaddr),    // input wire [3 : 0] s_axi_awaddr
        .s_axi_awvalid(awvalid),  // input wire s_axi_awvalid
        .s_axi_awready(awready),  // output wire s_axi_awready
        .s_axi_wdata(wdata),      // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb(wstrb),      // input wire [3 : 0] s_axi_wstrb
        .s_axi_wvalid(wvalid),    // input wire s_axi_wvalid
        .s_axi_wready(wready),    // output wire s_axi_wready
        .s_axi_bresp(bresp),      // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid(bvalid),    // output wire s_axi_bvalid
        .s_axi_bready(bready),    // input wire s_axi_bready
        .s_axi_araddr(araddr),    // input wire [3 : 0] s_axi_araddr
        .s_axi_arvalid(arvalid),  // input wire s_axi_arvalid
        .s_axi_arready(arready),  // output wire s_axi_arready
        .s_axi_rdata(rdata),      // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp(rresp),      // output wire [1 : 0] s_axi_rresp
        .s_axi_rvalid(rvalid),    // output wire s_axi_rvalid
        .s_axi_rready(rready),    // input wire s_axi_rready
        .rx(RX),                        // input wire rx
        .tx(TX)                        // output wire tx
    );

////////////////////
// reader_module
////////////////////
    (* dont_touch = "true" *)axi_read_controller reader(
        // System Signals
        .M_AXI_ACLK(CLK),
        .M_AXI_ARESETN(RST),
        // Master Interface Read Address
        .M_AXI_ARADDR(araddr),
        .M_AXI_ARPROT(),
        .M_AXI_ARVALID(arvalid),
        .M_AXI_ARREADY(arready),
        // Master Interface Read Data 
        .M_AXI_RDATA(rdata),
        .M_AXI_RRESP(rresp),
        .M_AXI_RVALID(rvalid),
        .M_AXI_RREADY(rready),
        
        // other module side signal
        .DATA_OUT(READ_DATA[7:0]), // read_data
        .DATA_VALID(READ_VALID),
        .DATA_READY(READ_READY)
    );

////////////////////
// sender_module
////////////////////
    (* dont_touch = "true" *)axi_write_controller writer(
        // System Signals
        .M_AXI_ACLK(CLK),
        .M_AXI_ARESETN(RST),

        // axi_lite side signal
        // Master Interface Write Address
        .M_AXI_AWADDR(awaddr),
        .M_AXI_AWPROT(),
        .M_AXI_AWVALID(awvalid),
        .M_AXI_AWREADY(awready),
        // Master Interface Write Data
        .M_AXI_WDATA(wdata),
        .M_AXI_WSTRB(wstrb),
        .M_AXI_WVALID(wvalid),
        .M_AXI_WREADY(wready),
        // Master Interface Write Response
        .M_AXI_BRESP(bresp),
        .M_AXI_BVALID(bvalid),
        .M_AXI_BREADY(bready),

        // other module side signal
        .DATA_IN(WRITE_DATA[7:0]),  // write_data
        .DATA_VALID(WRITE_VALID),
        .DATA_READY(WRITE_READY)
    );
    
    
    
endmodule
