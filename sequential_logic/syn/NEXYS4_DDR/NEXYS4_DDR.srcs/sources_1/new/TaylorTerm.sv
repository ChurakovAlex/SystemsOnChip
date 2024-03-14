`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.03.2024 19:17:46
// Design Name: 
// Module Name: TaylorTerm
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


module TaylorTerm #(TERM_INDEX = 1) // index begin from 1, because 0 is x itself, so it dont need calculate
(
    input logic clk,
    input logic [31:0]  x,            // x value
    input logic [31:0]  term_coeff,   // coeff that multuply to x^n
    output logic [31:0] y             // result of coeff*x^n
);
    

    logic [31:0] x_value[TERM_INDEX:0];    
    
    logic status_value_a[TERM_INDEX:0];
    logic status_value_b[TERM_INDEX:0];
    logic status_value_res[TERM_INDEX:0];
    
    assign  x_value[0] = 32'h3f800000;
      
    integer i;
    initial begin
    for (i=0;i < TERM_INDEX; i=i+1)
        status_value_a[i] = 1'h1;
        status_value_b[i] = 1'h1;
        status_value_res[i] = 1'h1;
    end

    // --------------------------------------------------------------------------------------------------------------------------
    // Stage 1
    // --------------------------------------------------------------------------------------------------------------------------

    logic[31:0] x_power_result;
    logic [31:0]  step1_x;
    logic [31:0]  step1_term_coeff;
    
    always@(posedge clk)
        begin
            step1_x <= x;
            step1_term_coeff <= term_coeff;
        end
    
    genvar itr;
    generate
        for (itr = 1 ; itr <= TERM_INDEX; itr = itr+1)
            FloatingMultiplication F_Mult (.clk(clk), .A(x_value[itr-1]), .B(step1_x),.result(x_value[itr]));
    endgenerate
    
    
    always@*
        begin
            x_power_result = x_value[TERM_INDEX];
        end
        
    
    logic[31:0] term_result;
    FloatingMultiplication F_MultWithCoeff (.clk(clk), .A(step1_term_coeff), .B(x_power_result), .result(term_result));
    
    // --------------------------------------------------------------------------------------------------------------------------
    // Stage 2
    // --------------------------------------------------------------------------------------------------------------------------
     
    always@(posedge clk)
        begin
            y <= term_result;
        end

endmodule

