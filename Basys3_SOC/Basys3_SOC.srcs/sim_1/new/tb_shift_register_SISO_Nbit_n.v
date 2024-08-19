`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/15 11:24:09
// Design Name: 
// Module Name: tb_shift_register_SISO_Nbit_n
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
module tb_shift_register_SISO_Nbit_n();
    reg clk, reset_p;
    reg d;
    wire q;
    parameter data = 4'b1010;
    
    L_shift_register_SISO_Nbit_n #(.N(4)) DUT(
        .clk(clk), .reset_p(reset_p),
        .d(d),
        .q(q));
    initial begin
        clk = 0;
        reset_p = 1;
        d = data[0];
    end
    always #5 clk = ~clk;
    integer i;
    initial begin
        #10;
        reset_p = 0;
        for(i = 0; i <4; i = i+1)begin
            d = data[i]; #10;
        end   
        #40;
        $finish;
    end

endmodule
