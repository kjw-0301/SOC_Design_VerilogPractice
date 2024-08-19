`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/16 09:45:33
// Design Name: 
// Module Name: tb_register_8bit_Nbit_n
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
module tb_register_8bit_Nbit_n();

    parameter T_Data_0 = 46;
    parameter T_Data_1 = 8'b10001111;
    parameter T_Data_2 = 8'hf7;
    parameter T_Data_3 = 7;
    reg [7:0] in_Data;
    reg clk, reset_p, wr_en, rd_en;
    wire [7:0] out_Data;
    
     register_8bit_Nbit_n #(.N(8)) DUT( in_Data,clk,reset_p, wr_en, rd_en,out_Data);
     
     initial begin
     clk = 0;
     reset_p = 1;
     in_Data = T_Data_0;
     rd_en = 0;
     wr_en = 0;
     end
     
     always #5 clk = ~clk;
     
     initial begin
     #10;
     reset_p = 0; #10;
     in_Data = T_Data_0; #10;
     wr_en = 1;#10;
     wr_en = 0; rd_en = 1;#10;
     rd_en = 0; in_Data = T_Data_1;#10
     wr_en = 1;#10;
     wr_en = 0; rd_en = 1;#10;
     rd_en = 0; in_Data = T_Data_2;#10
     wr_en = 1;#10;
     wr_en = 0; rd_en = 1;#10;
     rd_en = 0; in_Data = T_Data_3;#10
     wr_en = 1;#10;
     wr_en = 0; rd_en = 1;#10;
     $finish;
     end
endmodule
