`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/18 23:21:48
// Design Name: 
// Module Name: axi_read_controller
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


module axi_read_controller #
   (
    parameter integer C_M_AXI_ADDR_WIDTH = 32,
    parameter integer C_M_AXI_DATA_WIDTH = 32
    )
   (
    // System Signals
    input wire M_AXI_ACLK,
    input wire M_AXI_ARESETN,

    // Master Interface Read Address
    output reg [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_ARADDR,
    output wire [3-1:0] M_AXI_ARPROT,
    output wire M_AXI_ARVALID,
    input wire M_AXI_ARREADY,

    // Master Interface Read Data 
    input wire [C_M_AXI_DATA_WIDTH-1:0] M_AXI_RDATA,
    input wire [2-1:0] M_AXI_RRESP,
    input wire M_AXI_RVALID,
    output wire M_AXI_RREADY,
    
    // mem interface
    (* dont_touch = "true" *)output reg[7:0] DATA_OUT,
    (* dont_touch = "true" *)output reg DATA_VALID,
    (* dont_touch = "true" *)input wire DATA_READY
    );

   // AXI4 signals
   reg 		    pop_read;
   reg          arvalid;
   reg          rready;

   
/////////////////
//I/O Connections
/////////////////
assign M_AXI_ARVALID = arvalid;
assign M_AXI_ARPROT = 3'b0;
assign M_AXI_RREADY = rready;

//////////////////////   
//Read Address Channel
//////////////////////
always @(posedge M_AXI_ACLK)
  begin
     if (M_AXI_ARESETN == 0 )
       arvalid <= 1'b0;
     else if (M_AXI_ARREADY && arvalid)begin
       arvalid <= 1'b0;
       end
     else if (pop_read)begin
       arvalid <= 1'b1;
       end
     else
       arvalid <= arvalid;
  end 

//////////////////////////////////   
//Read Data (and Response) Channel
//////////////////////////////////
always @(posedge M_AXI_ACLK)
  begin
     if (M_AXI_ARESETN == 0)
 	  rready <= 1'b0;
      else
 	  rready <= 1'b1;
   end


//////////////////////////////////   
//Address Controller
//////////////////////////////////
/*
This controller checks that the axiliteuart's 
FIFO has a valid value and switches the address
To read the status register, which always contains
the FIFO status data, the address 8 of that register is output.
Then, the status of the FIFO is determined when data is in the FIFO,
 and if it is, the address 0 of the register with the data is output.
*/
    always @(posedge M_AXI_ACLK)begin
        if(M_AXI_ARESETN == 0)begin
            M_AXI_ARADDR <= 4'h08;
            pop_read <= 1;
        end
        else if(M_AXI_RVALID)begin
            if (M_AXI_RDATA[0] == 1 && M_AXI_ARADDR == 4'h08)begin   // read_status->read_data_state
                M_AXI_ARADDR <= 4'h00;
                pop_read <= 1;
            end
            else if(M_AXI_ARADDR == 4'h00)begin                              // read_data->read_status_state
                M_AXI_ARADDR <= 4'h08;
                pop_read <= 1;
            end
            else if(DATA_VALID)
                pop_read <= 0;
            else begin
                M_AXI_ARADDR <= 4'h08;
                pop_read <= 1;
            end
        end
        else
            pop_read <= 0;
    end
    
//////////////////////////////////   
//data Controller
//////////////////////////////////
/*
*/
    always @(posedge M_AXI_ACLK)begin
        if(M_AXI_ARESETN == 0)begin
            DATA_OUT <= 8'h00;
            DATA_VALID <= 0;
        end
        else if(DATA_VALID == 1 && DATA_READY == 1)begin
            DATA_VALID <= 0;
        end
        else if(M_AXI_ARADDR == 4'h00 && M_AXI_RVALID == 1)begin                              // read_data->read_status_state
            DATA_OUT <= M_AXI_RDATA[7:0];
            DATA_VALID <= 1;
        end
        else begin
            DATA_OUT <= DATA_OUT;
            DATA_VALID <= DATA_VALID;
        end
            
    end
endmodule