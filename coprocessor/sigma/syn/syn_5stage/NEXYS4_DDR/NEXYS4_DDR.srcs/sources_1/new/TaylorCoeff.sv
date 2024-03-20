`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2024 18:15:12
// Design Name: 
// Module Name: TaylorCoeff
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


module TaylorCoeff(
    input logic clk,
    input logic rst,
    input logic[31:0] x,
    output logic[31:0] y
    );
    
    localparam logic[31:0] k[0:7] = {
    32'h3f800000, //1
    32'h3f000000, // 0.5
    32'hbe000000, // -0.125
    32'h3d800000, // 0.0625
    32'hbd200000, // -0.0390625
    32'h3ce00000, // 0.0273438
    32'hbca7fff9, // -0.0205078
    32'h3c83ffff // 0.0161133
    };
    
    always@(posedge clk) 
        begin
            if (rst) begin
                y <= 0;
            end
            else begin
                y <= k[x];
            end
        end
        
endmodule
