`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.03.2024 19:23:34
// Design Name: 
// Module Name: TaylorSqrt
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

module TaylorSqrt(
    input logic clk,
    input logic rst,
    input logic [31:0]  x,            // x value
    output logic [31:0] result   // result of coeff*x^n
    );
    
    // --------------------------------------------------------------------------------------------------------------------------
    // Stage 0
    // --------------------------------------------------------------------------------------------------------------------------
    
    logic[31:0] step0_x;    
    always@(posedge clk)
        begin
            step0_x <= x;
        end
    
    //-------- Conversion to decimal --------------------------------//  
    parameter max_exp = 11;
    logic[4:0] exp;
    logic [31:0] dec_x;  
    DecConvers #(.max_exp(max_exp )) conv(.clk(clk), .x(step0_x), .y(dec_x), .exp(exp));
    //-------- Conversion to decimal --------------------------------// 
    
    logic[4:0] step00_exp;
    logic[31:0] step0_dec_x;
    
    always@(posedge clk)
        begin
            if (rst) begin
                step00_exp <= 0;
                step0_dec_x <= 0;
            end
            else begin
                step00_exp <= exp;
                step0_dec_x <= dec_x;
            end
        end
    
    logic [31:0] dec_x_sub_res;   
    logic exception0;
    FloatingAddSub x_sub1(.a(step0_dec_x), .b(32'h3f800000), .add_sub_signal(1'b1), .exception(exception0), .res(dec_x_sub_res));  // dec_x - 1
    
//    always@(posedge clk)
//        begin
            
//        end
    
    logic[31:0] step0_dec_x_sub;
    logic[4:0] step0_exp;
    
    always@(posedge clk)
        begin
            if (rst) begin
                step0_dec_x_sub <= 0;
                step0_exp <= 0;
            end
            else begin
                step0_dec_x_sub <= dec_x_sub_res;
                step0_exp <= step00_exp;
            end
        end
    
//----------------------------Taylor series----------------------------------------//

    // --------------------------------------------------------------------------------------------------------------------------
    // Stage 1
    // --------------------------------------------------------------------------------------------------------------------------
    
    parameter logic[31:0] k[0:6] = {  // size must be even
     32'h3f000000, // 0.5
     32'hbe000000, // -0.125
     32'h3d800000, // 0.0625
     32'hbd200000, // -0.0390625
     32'h3ce00000, // 0.0273438
     32'hbca7fff9, // -0.0205078
     32'h3c83ffff // 0.0161133
     };   
    logic[31:0] result_term[7:0];   
    assign result_term[0] = 32'h3f800000;
    
    genvar it;
    generate
        for (it = 0; it < $size(k); it++) begin
            TaylorTerm #(.TERM_INDEX(it+1)) term(.clk(clk), .x(step0_dec_x_sub), .term_coeff(k[it]), .y(result_term[it+1]));
        end
    endgenerate
    
    logic[31:0] step1_result_term[7:0];
    logic[4:0] step1_exp;
    
    always@(posedge clk)
        begin
            if (rst) begin
                for (byte i = 0; i < $size(step1_result_term); i++) step1_result_term[i] <= 0;
                step1_exp <= 0;
            end
            else begin
                step1_result_term <= result_term;
                step1_exp <= step0_exp;
            end
        end           

    // --------------------------------------------------------------------------------------------------------------------------
    // Stage 2
    // --------------------------------------------------------------------------------------------------------------------------

    logic[31:0] term_sum_1[3:0];
    logic exceptions[6:0];
    
    genvar itr;
    generate
        for (itr = 0; itr < $size(term_sum_1); itr++) begin 
            FloatingAddSub term_grp1_sum(.a(step1_result_term[itr]), .b(step1_result_term[$size(step1_result_term) - 1 - itr]), .add_sub_signal(1'b0), .exception(exceptions[itr]), .res(term_sum_1[itr]));
        end
    endgenerate  
    
    logic[31:0] step2_term_sum[3:0];
    logic[4:0] step2_exp;
    
    always@(posedge clk)
        begin
            if (rst) begin
                for (byte i = 0; i < $size(step2_term_sum); i++) step2_term_sum[i] <= 0;
                step2_exp <= 0;
            end
            else begin
                step2_term_sum <= term_sum_1;
                step2_exp <= step1_exp;
            end
        end  
    
    // --------------------------------------------------------------------------------------------------------------------------
    // Stage 3
    // --------------------------------------------------------------------------------------------------------------------------
    
    logic[31:0] term_sum_2[1:0];  
    
    genvar iter;
    generate
        for (iter = 0; iter < $size(term_sum_2); iter++) begin 
            FloatingAddSub term_grp1_sum(.a(step2_term_sum[iter]), .b(step2_term_sum[$size(step2_term_sum) - 1 - iter]), .add_sub_signal(1'b0), .exception(exceptions[iter+4]), .res(term_sum_2[iter]));
        end
    endgenerate  

    logic[31:0] step3_term_sum[1:0];
    logic[4:0] step3_exp;
    
    always@(posedge clk)
        begin
            if (rst) begin
                for (byte i = 0; i < $size(step3_term_sum); i++) step3_term_sum[i] <= 0;
                step3_exp <= 0;
            end
            else begin
                step3_term_sum <= term_sum_2;
                step3_exp <= step2_exp;
            end
        end 

    // --------------------------------------------------------------------------------------------------------------------------
    // Stage 4
    // --------------------------------------------------------------------------------------------------------------------------

    logic[31:0] result_sum;
    FloatingAddSub term_result_sum(.a(step3_term_sum[0]), .b(step3_term_sum[1]), .add_sub_signal(1'b0), .exception(exceptions[6]), .res(result_sum));
    
    logic[31:0] step4_result_sum;
    logic[4:0] step4_exp;
    always@(posedge clk)
        begin
            if (rst) begin
                step4_result_sum <= 0;
                step4_exp <= 0;
            end
            else begin
                step4_result_sum <= result_sum;
                step4_exp<= step3_exp;
            end
        end 
    //---------------------Multiply on 10^(exp/2)------------------------------------------//
    logic[31:0] step4_result;
    MulBack #(.max_exp(max_exp )) mul_back(.clk(clk), .x(step4_result_sum ), .exp(step4_exp), .y(step4_result));
    
    always@(posedge clk)
        begin
            if (rst) begin
                result <= 0;
            end
            else begin
                result <= step4_result;
            end 
        end 
    
endmodule
