`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/29 02:24:28
// Design Name: 
// Module Name: mem_debugger
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


module mem_debugger
  #(parameter WIDTH = 16,
    parameter MMSIZE = (2 ** 16))
    (input                          CLK,
    input                           RST_X,
    input                           IN_UP,
    input                           IN_DOWN,
    output reg [$clog2(MMSIZE)-1:0] MM_ADDR
    );
    
    wire up;
    wire down;
    
    chattering_convert up_switch_convert(
        .CLK(CLK),
        .SWITCH_IN(IN_UP),
        .SWITCH_OUT(up)
    );
    
    chattering_convert down_switch_convert(
        .CLK(CLK),
        .SWITCH_IN(IN_DOWN),
        .SWITCH_OUT(down)
    );
    
    always @(posedge CLK) begin
        if(!RST_X)begin
            MM_ADDR <= 0;
            end
        else if(up && MM_ADDR < 30)
            MM_ADDR <= MM_ADDR + 1;
        else if(down && MM_ADDR > -1)
            MM_ADDR <= MM_ADDR - 1;
        else
            MM_ADDR <= MM_ADDR;
    end
    
endmodule
