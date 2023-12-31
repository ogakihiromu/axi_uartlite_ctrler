`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/27 01:24:32
// Design Name: 
// Module Name: memaccess
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
// memaccess.v:
// memory access machine
//

// ã¹ã?ã¼ãå
`define STATE_END    0
`define STATE_INIT   1
`define STATE_WRITE         2
`define STATE_WRITE_COUNT   3
`define STATE_READ          4
`define STATE_READ_COUNT    5
// å¿?è¦ã«å¿ãã¦ã¹ã?ã¼ãåã¨çªå·ãè¿½å?


module memaccess
  #(parameter                    WIDTH = 8,        // 16bitã¯ã¼ã?
    parameter                    MMSIZE = (2 ** 7)) // ã?ãã©ã«ã?128ã¯ã¼ã?
    (input                       CLK,               // ã¯ã­ã?ã¯å¥å?
     input                       RST_X, // ãªã»ã?ãå?¥åï¼ãªã»ã?ãããã¨ãã«0ãå?¥å?
     output reg                  DONE, // å¦ç?ãçµäº?ããã?1ãå?ºå?
     
     // uart_side
     input  [WIDTH-1:0]                DIN,
     input                       IN_VALID,
     output reg                  IN_READY,
     output [WIDTH-1:0]          DOUT,
     output reg                  OUT_VALID,
     input                       OUT_READY
     );

    // mem_side_connecter
    reg                          MM_en; // ã¡ã¢ãªã®ã¤ãã?¼ãã«ä¿¡å·
    reg                          MM_we; // ã¡ã¢ãªã®ã©ã¤ãã¤ãã?¼ãã«ä¿¡å·
    reg [$clog2(MMSIZE)-1:0]      abus;
    
    // innner_reg    
    reg [7:0]                    count; // 8-bitã«ã¦ã³ã¿
    reg [3:0]                    STATE;
    
    // memory (using 'memory.v')
    memory
      #(.WIDTH(WIDTH), .MMSIZE(MMSIZE))
    MM
      (.CLK(CLK),
       .RST_X(RST_X),
       .EN(MM_en),
       .WE(MM_we),
       .ADDR(abus),
       .DIN(DIN),
       .DOUT(DOUT)
       );

    // state control
    always @(posedge CLK) begin
        if (!RST_X) begin
            abus <= 0;
            DONE <= 0;
            
            MM_en <= 0;
            MM_we <= 0;
            count <= 0;
            
            IN_READY <= 0;
            OUT_VALID <= 0;


            STATE <= `STATE_WRITE;
        end
        else begin
            case (STATE)
              `STATE_WRITE: begin
              
                  if(IN_VALID == 1 && IN_READY == 0)begin   // 
                    abus <= count; // count_address
                    MM_en <= 1;
                    MM_we <= 1;
                    IN_READY <= 1;  // send_to_accept_data
                    count <= count + 1;
                    STATE <= `STATE_WRITE_COUNT;
                    end
                  else begin
                    MM_en <= 0;
                    MM_we <= 0;
                    IN_READY <= 0;
                    STATE <= `STATE_WRITE;
                    end
              end
              
              `STATE_WRITE_COUNT: begin
                  if (count == 30)begin // 30ñªJèÔµ½çAChóÔÖ
                    MM_en <= 0;
                    MM_we <= 0;
                    IN_READY <= 0;
                    STATE <= `STATE_INIT;
                    end
                  else
                    STATE <= `STATE_WRITE;
              end
              
              `STATE_INIT: begin
                  abus <= 0;
                  DONE <= 0;
                  MM_en <= 0;
                  MM_we <= 0;
                  count <= 0;
                  IN_READY <= 0;
                  STATE <= `STATE_READ;
              end

              `STATE_READ: begin
                  
                  if (OUT_VALID == 1 && OUT_READY == 1)begin
                    OUT_VALID <= 0;
                    count <= count + 1;
                    STATE <= `STATE_READ_COUNT;
                  end
                  else if (MM_en == 1)begin
                    OUT_VALID <= 1;
                  end
                  else begin
                    MM_en <= 1;
                    OUT_VALID <= OUT_VALID;
                    STATE <= `STATE_READ;
                  end
              end
              
              `STATE_READ_COUNT: begin
                  if (count == 30) begin // 30ñJèÔµ½çI¹
                      DONE <= 1;

                      STATE <= `STATE_END;
                  end
                  else begin
                      abus <= count;
                      STATE <= `STATE_READ;
                  end
              end
              
              `STATE_END:
                STATE <= `STATE_END;

              default: begin
                  MM_en <= 0;
                  MM_we <= 0;
                  STATE <= `STATE_WRITE;
              end

            endcase
        end
    end

/////////////
//for_debug
/////////////
vio_1 your_instance_name (
  .clk(CLK),              // input wire clk
  .probe_in0(STATE)  // input wire [3 : 0] probe_in0
);

endmodule // memaccess