`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/27 14:14:33
// Design Name: 
// Module Name: axi_uart_mem
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


module axi_uart_mem(
    input CLK,
    input RST,
    input RX,
    output TX,
    output DONE,
    output [7:0]RDATA     // for debug
    );
    
    wire um_valid;
    wire um_ready;
    wire [7:0]um_data;
    wire mu_valid;
    wire mu_ready;
    wire [7:0]mu_data;
    
    // for debug
    assign RDATA[7:0] = um_data[7:0];
    
    (* dont_touch = "true" *)axi_uartlite_controller uart_ctrl(
        .CLK(CLK),
        .RST(~RST),      // rst_active_low
        .RX(RX),       // from host pc to fpga
        .TX(TX),      // from fpga to host pc
        .READ_VALID(um_valid),
        .READ_READY(um_ready),
        .READ_DATA(um_data[7:0]),  // from uart to controller
        .WRITE_VALID(mu_valid),
        .WRITE_READY(mu_ready),
        .WRITE_DATA(mu_data[7:0])   // from controller to uart
    );
    
    (* dont_touch = "true" *)memaccess memaccess_state_machine(
        .CLK(CLK),               // „ÇØ„É≠„É?„ÇØÂÖ•Âä?
        .RST_X(~RST), // „É™„Çª„É?„ÉàÂ?•ÂäõÔºö„É™„Çª„É?„Éà„Åô„Çã„Å®„Åç„Å´0„ÇíÂ?•Âä?
        .DONE(DONE), // Âá¶Áê?„ÅåÁµÇ‰∫?„Åó„Åü„Ç?1„ÇíÂ?∫Âä?
        .DIN(um_data),
        .IN_VALID(um_valid),
        .IN_READY(um_ready),
        .DOUT(mu_data),
        .OUT_VALID(mu_valid),
        .OUT_READY(mu_ready)
     );
    
endmodule
