`timescale 1ns / 1ps

module tb_shift_register_PISO_Nbit_n();
    reg clk, reset_p;
    reg [7:0]d;
    reg shift_load;
    wire q;
    
    parameter data = 8'b10100011;
    
    shift_register_PISO_Nbit_n #(.N(8)) DUT(clk, reset_p,d,shift_load,q);
    
    initial begin
        clk =0;
        reset_p = 1;
        shift_load = 0;
        d = data;
    end
    
    always #5 clk = ~clk;
    
    initial begin
        #10;
        reset_p = 0; #10;
        shift_load = 1;#80;
        $finish;
    end
endmodule
