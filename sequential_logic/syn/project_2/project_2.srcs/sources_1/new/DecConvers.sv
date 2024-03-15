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
    input logic clk,
    input logic rst,
    input logic[31:0] x,
    output logic[31:0] y,
    output logic[4:0] exp
    );
    
    // --------------------------------------------------------------------------------------------------------------------------
    // Stage 1
    // --------------------------------------------------------------------------------------------------------------------------
    logic[31:0] step1_x;
    always@(posedge clk)
        begin
            if (rst) begin
                step1_x <= 0;
            end
            else begin
                step1_x <= x;
            end   
        end
    
    localparam  logic[31:0] dec_fract = 32'h3dcccccd; // 0.1
    logic [31:0] x_iter[max_exp:0];
    always@(posedge clk)
        begin
            if (rst) begin
                x_iter[0] <= 0;
            end
            else begin
                x_iter[0] = step1_x;
            end    
        end
    
    // --------------------------------------------------------------------------------------------------------------------------
    // Stage 2
    // --------------------------------------------------------------------------------------------------------------------------
    logic [31:0] step2_x_iter[max_exp:0];
    genvar j;
    generate
        for (j = 1 ; j < max_exp; j++) begin
            FloatingMultiplication F_Div (.clk(clk), .A(x_iter[j-1]), .B(dec_fract),.result(x_iter[j]));
            always@(posedge clk)
                begin
                    if (rst) begin
                        step2_x_iter[j-1] <= 0;
                    end
                    else begin
                        step2_x_iter[j-1] <= x_iter[j-1];
                    end  
                end     
        end
    endgenerate
    
    // --------------------------------------------------------------------------------------------------------------------------
    // Stage 3
    // --------------------------------------------------------------------------------------------------------------------------
    
    logic[4:0] exp_tmp;
    always@(posedge clk)
        begin
            if (rst) begin
                y <= 0;
                exp_tmp = 0;
                exp = 0;
            end
            else begin
                y = step2_x_iter[0];
                exp_tmp = 0;
                exp = 0;  
                if (y > 32'h3f800000) begin
                    for (byte i = 0; i <= max_exp; i++) begin
                        if (step2_x_iter[i] < 32'h3f800000) begin
                            y = step2_x_iter[i];
                            exp = exp_tmp;
                            exp_tmp = 0;
                            break;
                        end else begin
                            exp_tmp += 1;
                        end
                    end
                end 
            end           
        end
    
endmodule