`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/04 01:08:45
// Design Name: 
// Module Name: axi_write_controller
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


module axi_write_controller #
   (
    parameter integer C_M_AXI_ADDR_WIDTH = 32,
    parameter integer C_M_AXI_DATA_WIDTH = 32,
    parameter integer C_DATA_WIDTH = 32,
    parameter integer C_NUM_COMMANDS = 4
    )
   (
    // System Signals
    input wire M_AXI_ACLK,
    input wire M_AXI_ARESETN,

    // axi_lite side signal
    // Master Interface Write Address
    output wire [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_AWADDR,
    output wire [3-1:0] M_AXI_AWPROT,
    output wire M_AXI_AWVALID,
    input wire M_AXI_AWREADY,
    // Master Interface Write Data
    output wire [C_M_AXI_DATA_WIDTH-1:0] M_AXI_WDATA,
    output wire [C_M_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB,
    output wire M_AXI_WVALID,
    input wire M_AXI_WREADY,
    // Master Interface Write Response
    input wire [2-1:0] M_AXI_BRESP,
    input wire M_AXI_BVALID,
    output wire M_AXI_BREADY,

    // other module side signal
    input wire [7:0]DATA_IN,  // write_data
    input wire DATA_VALID,
    output wire DATA_READY
    );

   // AXI4 signals
   reg      push_write;
   reg 		awvalid;
   reg 		wvalid;
   reg          bready;
   reg [3:0] 	awaddr = 4'h4;
   
   reg data_ready;
   

////////////////////
//axi_connection
////////////////////
assign M_AXI_AWADDR = awaddr;
assign M_AXI_WDATA[31:8] = 0;
assign M_AXI_AWPROT = 3'h0;
assign M_AXI_AWVALID = awvalid;
assign M_AXI_WVALID = wvalid;
assign M_AXI_WSTRB = 4'b1;  //Set all byte strobes
assign M_AXI_BREADY = bready;
assign M_AXI_WDATA[7:0] = DATA_IN;
assign DATA_READY = data_ready;

///////////////////////
//Write Address Channel
///////////////////////
always @(posedge M_AXI_ACLK)
    begin
        if (M_AXI_ARESETN == 0 )
            awvalid <= 1'b0;
        else if (M_AXI_AWREADY && awvalid)
            awvalid <= 1'b0;
        else if (push_write)
            awvalid <= 1'b1;
        else
            awvalid <= awvalid;
    end 

////////////////////
//Write Data Channel
////////////////////
always @(posedge M_AXI_ACLK)
    begin
        if (M_AXI_ARESETN == 0 )
            wvalid <= 1'b0;
        else if (M_AXI_WREADY && wvalid)
            wvalid <= 1'b0;
        else if (push_write)
            wvalid <= 1'b1;
        else
            wvalid <= awvalid;
    end 

////////////////////////////
//Write Response (B) Channel
////////////////////////////
always @(posedge M_AXI_ACLK)
    begin
        if (M_AXI_ARESETN == 0)
            bready <= 1'b0;
        else
            bready <= 1'b1;
    end
    
/////////////////////////////
//Resending_Controller
/////////////////////////////

always @(posedge M_AXI_ACLK)
    begin
        if (M_AXI_ARESETN == 0)
            bready <= 1'b0;
        else if(M_AXI_BRESP[1] == 0 && M_AXI_BVALID == 1)
        begin
            data_ready <= 1;
        end
        else if (DATA_VALID == 1)
        begin
            push_write <= 1;
        end
        else
        begin
            data_ready <= 0;
            push_write <= 0;
        end
    end
            
endmodule
