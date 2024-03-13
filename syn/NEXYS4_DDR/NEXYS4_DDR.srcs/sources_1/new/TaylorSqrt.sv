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
    logic[31:0] dec_x; // x / 10^exp
    logic[4:0] exp = 0;
    parameter exp_max = 11;
    parameter logic[31:0] dec_fract = 32'h3dcccccd; // 0.1
    
    logic [31:0] x_iter[exp_max:0];
    always@*
        begin
            for (byte i = 0; i <= exp_max+1; i++) begin
                x_iter[i] = x;
            end
        end
    
    genvar itr;
    generate
        for (itr = 1 ; itr < exp_max + 1; itr = itr+1)
            FloatingMultiplication F_Div (.A(x_iter[itr-1]), .B(dec_fract),.result(x_iter[itr]));
    endgenerate
    
    logic[4:0] exp1;
    always@*
        begin
            dec_x = x_iter[0];
            if (dec_x > 32'h3f800000) begin
                for (byte i = 0; i < exp_max+1; i++) begin
                    exp += 1;
                    if (x_iter[i] < 32'h3f800000) begin
                        dec_x = x_iter[i];
                        break;
                    end
                end
            end
            exp1 = exp;
            exp = 0;
        end
    
    logic [31:0] dec_x_sub_res;   
    logic exception0;
    FloatingAddSub x_sub1(.a(dec_x), .b(32'h3f800000), .add_sub_signal(1'b1), .exception(exception0), .res(dec_x_sub_res));
    
//----------------------------Taylor series----------------------------------------//

    parameter logic[31:0] k1 = 32'h3f800000; // 1 
    parameter logic[31:0] k2 = 32'h3f000000; // 0.5
    parameter logic[31:0] k3 = 32'hbe000000; // -0.125
    parameter logic[31:0] k4 = 32'h3d36db79; // 0.0625
    parameter logic[31:0] k5 = 32'hbd200000; // -0.0390625
    parameter logic[31:0] k6 = 32'h3ce00000; // 0.02734375
    parameter logic[31:0] k7 = 32'hbca7fff9; // -0.0205078
    parameter logic[31:0] k8 = 32'h3c83ffff; // 0.01611328
        
    logic[31:0] result_term_1;
    logic[31:0] result_term_2;
    logic[31:0] result_term_3;
    logic[31:0] result_term_4;
    logic[31:0] result_term_5;
    logic[31:0] result_term_6;
    logic[31:0] result_term_7;
    logic[31:0] result_term_8;
    
    logic[31:0] y1 = 32'h3f800000;
    logic[31:0] y2;
    logic[31:0] y3;
    logic[31:0] y4;
    logic[31:0] y5;
    logic[31:0] y6;
    logic[31:0] y7;
    logic[31:0] y8;

//    always@*
//        begin
//            y1 = 32'h3f800000;
//        end
    
    TeylorTerm #(.TERM_INDEX(1)) term2(.x(dec_x_sub_res), .term_coeff(k2), .y(result_term_2));
    always@(dec_x_sub_res)
        begin
            y2 = result_term_2;
        end

    TeylorTerm #(.TERM_INDEX(2)) term3(.x(dec_x_sub_res), .term_coeff(k3), .y(result_term_3));
    always@(dec_x_sub_res)
        begin
            y3 = result_term_3;
        end
        
    TeylorTerm #(.TERM_INDEX(3)) term4(.x(dec_x_sub_res), .term_coeff(k4), .y(result_term_4));
    always@(dec_x_sub_res)
        begin
            y4 = result_term_4;
        end
        
    TeylorTerm #(.TERM_INDEX(4)) term5(.x(dec_x_sub_res), .term_coeff(k5), .y(result_term_5));
    always@(dec_x_sub_res)
        begin
            y5 = result_term_5;
        end
        
    TeylorTerm #(.TERM_INDEX(5)) term6(.x(dec_x_sub_res), .term_coeff(k6), .y(result_term_6));
    always@(dec_x_sub_res)
        begin
            y6 = result_term_6;
        end
        
    TeylorTerm #(.TERM_INDEX(6)) term7(.x(dec_x_sub_res), .term_coeff(k7), .y(result_term_7));
    always@(dec_x_sub_res)
        begin
            y7 = result_term_7;
        end

        
    TeylorTerm #(.TERM_INDEX(7)) term8(.x(dec_x_sub_res), .term_coeff(k8), .y(result_term_8));
    always@(dec_x_sub_res)
        begin
            y8 = result_term_8;
        end
                
    logic[31:0] sum_term23;
    logic[31:0] sum_term34;
    logic[31:0] sum_term56;
    logic[31:0] sum_term78;
    
    logic exception1;
    logic exception2;
    logic exception3;
    logic exception4;
    
    FloatingAddSub term_grp1_sum1(.a(y1), .b(y2), .add_sub_signal(1'b0), .exception(exception1), .res(sum_term23));
    FloatingAddSub term_grp1_sum2(.a(y3), .b(y4), .add_sub_signal(1'b0), .exception(exception2), .res(sum_term34));
    FloatingAddSub term_grp1_sum3(.a(y5), .b(y6), .add_sub_signal(1'b0), .exception(exception3), .res(sum_term56));
    FloatingAddSub term_grp1_sum4(.a(y7), .b(y8), .add_sub_signal(1'b0), .exception(exception4), .res(sum_term78));
    
    logic[31:0] grp1_sum1;
    logic[31:0] grp1_sum2;
    logic[31:0] grp1_sum3;
    logic[31:0] grp1_sum4;
    
    always@(sum_term23, sum_term34, sum_term56, sum_term78)
        begin
            grp1_sum1 = sum_term23;
            grp1_sum2 = sum_term34;
            grp1_sum3 = sum_term56;
            grp1_sum4 = sum_term78;
        end
    
    logic[31:0] sum_grp1_1;
    logic[31:0] sum_grp1_2;
    
    
    logic exception5;
    logic exception6;
    FloatingAddSub term_grp2_sum_1(.a(grp1_sum1), .b(grp1_sum2), .add_sub_signal(1'b0), .exception(exception5), .res(sum_grp1_1));
    FloatingAddSub term_grp2_sum_2(.a(grp1_sum3), .b(grp1_sum4), .add_sub_signal(1'b0), .exception(exception6), .res(sum_grp1_2));
    
    logic[31:0] result_sum_grp1_1;
    logic[31:0] result_sum_grp1_2;
    
    always@(sum_grp1_1, sum_grp1_2)
        begin
            result_sum_grp1_1 = sum_grp1_1;
            result_sum_grp1_2 = sum_grp1_2;
        end
    
    logic exception7;
    
    
    logic[31:0] result_sum;
    FloatingAddSub term_result_sum(.a(result_sum_grp1_1), .b(result_sum_grp1_2), .add_sub_signal(1'b0), .exception(exception7), .res(result_sum));
    
//---------------------Multiply on 10^(exp/2)------------------------------------------//

    parameter logic[31:0] root10 = 32'h404a62c2; // 3.16228

    logic[31:0] root_res;
    FloatingMultiplication result_mult_root10(.A(result_sum), .B(root10), .result(root_res));
    
    logic [31:0] x_mult[exp_max/2+1:0];
    always@(result_sum, root_res)
        begin
            if (exp[0] == 1) begin
                exp1 = exp1-1;
                x_mult[0] = root_res;
            end
            else begin
                x_mult[0] = result_sum;
            end
        end
    
    genvar it;
    generate
        for (it = 0 ; it < exp_max/2; it = it+1)
            FloatingMultiplication F_mul (.A(x_mult[it]), .B(32'h41200000),.result(x_mult[it+1]));
    endgenerate
    
    logic[4:0] exp2;
    always@(x_mult)
        begin
            exp2 = exp1 >>1;
            result = x_mult[exp2];
        end
//---------------------------Result----------------------//  
     
endmodule
