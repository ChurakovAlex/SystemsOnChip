`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2024 14:24:08
// Design Name: 
// Module Name: DecConvers
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


module DecConvers #(parameter max_exp = 9)
(
    input logic[31:0] x,
    output logic[31:0] y,
    output logic[4:0] exp
    );
    
    localparam  logic[31:0] dec_fract = 32'h3dcccccd; // 0.1
    logic [31:0] x_iter[max_exp:0];
    always@*
        begin
            x_iter[0] = x;
        end
    
    genvar j;
    generate
        for (j = 1 ; j <= max_exp; j++)
            FloatingMultiplication F_Div (.A(x_iter[j-1]), .B(dec_fract),.result(x_iter[j]));
    endgenerate
    
    logic[4:0] exp_tmp;
    always@*
        begin
            y = x_iter[0];
            exp_tmp = 0;
            exp = 0;
            if (y > 32'h3f800000) begin
                for (byte i = 0; i <= max_exp; i++) begin
                    if (x_iter[i] < 32'h3f800000) begin
                        y = x_iter[i];
                        exp = exp_tmp;
                        exp_tmp = 0;
                        break;
                    end else begin
                        exp_tmp += 1;
                    end
                end
            end     
        end
    
endmodule