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
    input logic[31:0] x,
    input logic[4:0] exp,
    output logic[31:0] y
);
    localparam logic[31:0] root10 = 32'h404a62c2; // 3.16228
    logic[31:0] root_res;
    FloatingMultiplication result_mult_root10(.A(x), .B(root10), .result(root_res));
    
    logic[4:0] exp_tmp;
    logic [31:0] x_mult[max_exp / 2:0];
    always@*
        begin
            if (exp[0] == 1) begin
                exp_tmp = exp-1;
                x_mult[0] = root_res;
            end
            else begin
                x_mult[0] = x;
                exp_tmp = exp;
            end
        end
    
    genvar l;
    generate
        for (l = 0 ; l < max_exp/2; l = l+1)
            FloatingMultiplication F_mul (.A(x_mult[l]), .B(32'h41200000),.result(x_mult[l+1]));
    endgenerate    
    
    logic[4:0] exp_tmp2;  
    always@*
        begin
            exp_tmp2 = exp_tmp >> 1;
            y = x_mult[exp_tmp2];
        end
    
endmodule
