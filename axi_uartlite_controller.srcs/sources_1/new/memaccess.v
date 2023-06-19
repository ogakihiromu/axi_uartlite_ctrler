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

// 繧ｹ繝?繝ｼ繝亥錐
`define STATE_END    0
`define STATE_INIT   1
`define STATE_WRITE         2
`define STATE_WRITE_COUNT   3
`define STATE_READ          4
`define STATE_READ_COUNT    5
// 蠢?隕√↓蠢懊§縺ｦ繧ｹ繝?繝ｼ繝亥錐縺ｨ逡ｪ蜿ｷ繧定ｿｽ蜉?


module memaccess
  #(parameter                    WIDTH = 8,        // 16bit繝ｯ繝ｼ繝?
    parameter                    MMSIZE = (2 ** 7)) // 繝?繝輔か繝ｫ繝?128繝ｯ繝ｼ繝?
    (input                       CLK,               // 繧ｯ繝ｭ繝?繧ｯ蜈･蜉?
     input                       RST_X, // 繝ｪ繧ｻ繝?繝亥?･蜉幢ｼ壹Μ繧ｻ繝?繝医☆繧九→縺阪↓0繧貞?･蜉?
     output reg                  DONE, // 蜃ｦ逅?縺檎ｵゆｺ?縺励◆繧?1繧貞?ｺ蜉?
     
     // uart_side
     input  [WIDTH-1:0]                DIN,
     input                       IN_VALID,
     output reg                  IN_READY,
     output [WIDTH-1:0]          DOUT,
     output reg                  OUT_VALID,
     input                       OUT_READY
     );

    // mem_side_connecter
    reg                          MM_en; // 繝｡繝｢繝ｪ縺ｮ繧､繝阪?ｼ繝悶Ν菫｡蜿ｷ
    reg                          MM_we; // 繝｡繝｢繝ｪ縺ｮ繝ｩ繧､繝医う繝阪?ｼ繝悶Ν菫｡蜿ｷ
    reg [$clog2(MMSIZE)-1:0]      abus;
    
    // innner_reg    
    reg [7:0]                    count; // 8-bit繧ｫ繧ｦ繝ｳ繧ｿ
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
                  if (count == 30)begin // 30回分繰り返したらアイドル状態へ
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
                  if (count == 30) begin // 30回繰り返したら終了
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