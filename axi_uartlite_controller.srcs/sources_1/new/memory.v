`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/25/2023 02:33:31 PM
// Design Name: 
// Module Name: memory
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



//
// memory.v:
// memory (random access memory)
//

module memory
  #(parameter WIDTH = 16,
    parameter MMSIZE = (2 ** 16))
    (input                      CLK,
     input                      RST_X,
     input                      EN,
     input                      WE,
     input [$clog2(MMSIZE)-1:0] ADDR,
     input [WIDTH-1:0]          DIN,
     output reg [WIDTH-1:0]     DOUT
     );

    // data array
    reg [WIDTH-1:0]             data[0:MMSIZE-1];

    always @(posedge CLK) begin
        if (!RST_X)
          DOUT <= 0;
        else if (EN) begin
            if (WE)
              data[ADDR] <= DIN;

            DOUT <= data[ADDR];
        end
        else begin
            DOUT <= 0;
        end
    end
///////////////
//for_debug
///////////////    
    vio_0 vio_0 (
        .clk(CLK),                // input wire clk
        .probe_in0(data[0]),    // input wire [7 : 0] probe_in0
        .probe_in1(data[1]),    // input wire [7 : 0] probe_in1
        .probe_in2(data[2]),    // input wire [7 : 0] probe_in2
        .probe_in3(data[3]),    // input wire [7 : 0] probe_in3
        .probe_in4(data[4]),    // input wire [7 : 0] probe_in4
        .probe_in5(data[5]),    // input wire [7 : 0] probe_in5
        .probe_in6(data[6]),    // input wire [7 : 0] probe_in6
        .probe_in7(data[7]),    // input wire [7 : 0] probe_in7
        .probe_in8(data[8]),    // input wire [7 : 0] probe_in8
        .probe_in9(data[9]),    // input wire [7 : 0] probe_in9
        .probe_in10(data[10]),  // input wire [7 : 0] probe_in10
        .probe_in11(data[11]),  // input wire [7 : 0] probe_in11
        .probe_in12(data[12]),  // input wire [7 : 0] probe_in12
        .probe_in13(data[13]),  // input wire [7 : 0] probe_in13
        .probe_in14(data[14]),  // input wire [7 : 0] probe_in14
        .probe_in15(data[15]),  // input wire [7 : 0] probe_in15
        .probe_in16(data[16]),  // input wire [7 : 0] probe_in16
        .probe_in17(data[17]),  // input wire [7 : 0] probe_in17
        .probe_in18(data[18]),  // input wire [7 : 0] probe_in18
        .probe_in19(data[19]),  // input wire [7 : 0] probe_in19
        .probe_in20(data[20]),  // input wire [7 : 0] probe_in20
        .probe_in21(data[21]),  // input wire [7 : 0] probe_in21
        .probe_in22(data[22]),  // input wire [7 : 0] probe_in22
        .probe_in23(data[23]),  // input wire [7 : 0] probe_in23
        .probe_in24(data[24]),  // input wire [7 : 0] probe_in24
        .probe_in25(data[25]),  // input wire [7 : 0] probe_in25
        .probe_in26(data[26]),  // input wire [7 : 0] probe_in26
        .probe_in27(data[27]),  // input wire [7 : 0] probe_in27
        .probe_in28(data[28]),  // input wire [7 : 0] probe_in28
        .probe_in29(data[29])  // input wire [7 : 0] probe_in29
    );
    
endmodule // memory
