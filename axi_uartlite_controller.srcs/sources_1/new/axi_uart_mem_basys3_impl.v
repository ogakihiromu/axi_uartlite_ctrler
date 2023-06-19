`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/29 00:19:26
// Design Name: 
// Module Name: axi_uart_mem_basys3_impl
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


module axi_uart_mem_basys3_impl(
    input clk,
    input btnC,     // rst_button
    input RsRx,
    output RsTx,
    output [8:0]led //done
    );
    
    axi_uart_mem axi_uart_mem_basys3(
        .CLK(clk),
        .RST(btnC),
        .RX(RsRx),
        .TX(RsTx),
        .DONE(led[0]),
        .RDATA(led[8:1])     // for debug
    );
    
endmodule
