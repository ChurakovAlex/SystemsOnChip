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
    input logic [31:0]  x,            // x value
    output logic [31:0] result   // result of coeff*x^n
    );
    
    //-------- Conversion to decimal --------------------------------//  
    parameter max_exp = 11;
    logic[4:0] exp;
    logic [31:0] dec_x;  
    DecConvers #(.max_exp(max_exp )) conv(.x(x), .y(dec_x), .exp(exp));
    
    logic [31:0] dec_x_sub_res;   
    logic exception0;
    FloatingAddSub x_sub1(.a(dec_x), .b(32'h3f800000), .add_sub_signal(1'b1), .exception(exception0), .res(dec_x_sub_res));
    
//----------------------------Taylor series----------------------------------------//
    
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
            TaylorTerm #(.TERM_INDEX(it+1)) term(.x(dec_x_sub_res), .term_coeff(k[it]), .y(result_term[it+1]));
        end
    endgenerate         

    logic[31:0] term_sum_1[3:0];
    logic exceptions[6:0];
    
    genvar itr;
    generate
        for (itr = 0; itr < $size(term_sum_1); itr++) begin 
            FloatingAddSub term_grp1_sum(.a(result_term[itr]), .b(result_term[$size(result_term) - 1 - itr]), .add_sub_signal(1'b0), .exception(exceptions[itr]), .res(term_sum_1[itr]));
        end
    endgenerate  
    
    logic[31:0] term_sum_2[1:0];  
    
    genvar iter;
    generate
        for (iter = 0; iter < $size(term_sum_2); iter++) begin 
            FloatingAddSub term_grp1_sum(.a(term_sum_1[iter]), .b(term_sum_1[$size(term_sum_1) - 1 - iter]), .add_sub_signal(1'b0), .exception(exceptions[iter+4]), .res(term_sum_2[iter]));
        end
    endgenerate  

    logic[31:0] result_sum;
    FloatingAddSub term_result_sum(.a(term_sum_2[0]), .b(term_sum_2[1]), .add_sub_signal(1'b0), .exception(exceptions[6]), .res(result_sum));
    
    //---------------------Multiply on 10^(exp/2)------------------------------------------//
    
    MulBack #(.max_exp(max_exp )) mul_back(.x(result_sum), .exp(exp), .y(result));

endmodule
