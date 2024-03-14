`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2024 15:24:21
// Design Name: 
// Module Name: MulBack
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


module MulBack #(parameter max_exp = 9)
(
    input logic clk,
    input logic[31:0] x,
    input logic[4:0] exp,
    output logic[31:0] y
);
    // --------------------------------------------------------------------------------------------------------------------------
    // Stage 1
    // --------------------------------------------------------------------------------------------------------------------------
    logic[31:0] step1_x;
    logic[4:0] step1_exp;
    
    always@(posedge clk)
        begin
            step1_x <= x;
            step1_exp <= exp;
        end
    
    // --------------------------------------------------------------------------------------------------------------------------
    // Stage 2
    // --------------------------------------------------------------------------------------------------------------------------
      
    localparam logic[31:0] root10 = 32'h404a62c2; // 3.16228
    logic[31:0] root_res;
    FloatingMultiplication result_mult_root10(.clk(clk), .A(step1_x), .B(root10), .result(root_res));
    
    logic[31:0] step2_root_res;
    logic[31:0] step2_x;
    logic[4:0] step2_exp;
    always@(posedge clk)
        begin
            step2_root_res <= root_res;
            step2_exp <= step1_exp;
            step2_x <= step1_x;
        end
    
    // --------------------------------------------------------------------------------------------------------------------------
    // Stage 3
    // --------------------------------------------------------------------------------------------------------------------------
    
    logic[4:0] exp_tmp;
    logic [31:0] x_mult[max_exp / 2:0];
    always@(posedge clk)
        begin
            if (step2_exp[0] == 1) begin
                exp_tmp <= step2_exp-1;
                x_mult[0] <= step2_root_res;
            end
            else begin
                x_mult[0] <= step2_x;
                exp_tmp <= step2_exp;
            end
        end
    
    // --------------------------------------------------------------------------------------------------------------------------
    // Stage 4
    // --------------------------------------------------------------------------------------------------------------------------
    logic [31:0] step4_x_mult[max_exp / 2:0];
    genvar l;
    generate
        for (l = 0 ; l < max_exp/2; l = l+1)
            FloatingMultiplication F_mul (.clk(clk), .A(x_mult[l]), .B(32'h41200000),.result(x_mult[l+1]));
            always@(posedge clk)
                begin
                    step4_x_mult[l+1] <= x_mult[l+1];
                end
    endgenerate    
    
    logic[4:0] step4_exp_tmp;
    always@(posedge clk)
        begin
            step4_exp_tmp <= exp_tmp;
        end
    
    logic[4:0] exp_tmp2;  
    always@(posedge clk)
        begin
            exp_tmp2 = step4_exp_tmp >> 1;
            y <= step4_x_mult[exp_tmp2];
        end
    
endmodule
