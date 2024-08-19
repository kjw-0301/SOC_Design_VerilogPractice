`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/24 16:34:33
// Design Name: 
// Module Name: 02_Sequencial_Logic
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


module D_FF_negativeEdge(
    input d,
    input clk,reset_p, enable,
    output reg q);
    
    always @ (negedge clk or posedge reset_p) begin
        if(reset_p) q= 0;
        else if(enable) q = d;
    end
endmodule


module D_FF_positiveEdge(
    input d,
    input clk,reset_p, enable,
    output reg q);
    
    always @ (posedge clk or posedge reset_p) begin
        if(reset_p) q= 0;
        else if(enable) q = d;
    end
endmodule


module T_FF_negative(
    input clk, reset_p,
    input t,
    output reg q);
    
    always @ (negedge clk or posedge reset_p)begin
        if(reset_p) q = 0;
        else begin
            if(t)q= ~q;
            else q=q;
        end
    end 
endmodule


module T_FF_positive(
    input clk, reset_p,
    input t,
    output reg q);
    
    always @ (posedge clk or posedge reset_p)begin
        if(reset_p) q = 0;
        else begin
            if(t)q= ~q;
            else q=q;
        end
    end 
endmodule



module UpCounter_4bit_async(
    input clk, reset_p,
    output [3:0] count);
    
    T_FF_negative T0(.clk(clk), .reset_p(reset_p), .t(1), .q(count[0]));
    T_FF_negative T1(.clk(count[0]), .reset_p(reset_p), .t(1), .q(count[1]));
    T_FF_negative T2(.clk(count[1]), .reset_p(reset_p), .t(1), .q(count[2]));
    T_FF_negative T3(.clk(count[2]), .reset_p(reset_p), .t(1), .q(count[3]));
endmodule

module DownCounter_4bit_async(
    input clk, reset_p,
    output [3:0] count);
    
    T_FF_positive T0(.clk(clk), .reset_p(reset_p), .t(1), .q(count[0]));
    T_FF_positive T1(.clk(count[0]), .reset_p(reset_p), .t(1), .q(count[1]));
    T_FF_positive T2(.clk(count[1]), .reset_p(reset_p), .t(1), .q(count[2]));
    T_FF_positive T3(.clk(count[2]), .reset_p(reset_p), .t(1), .q(count[3]));
endmodule



module UP_Counter_p(
    input clk, reset_p, enable,
    output reg[3:0] count);
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)count =0;
        else if(enable)count = count + 1;
    end
endmodule

module UP_Counter_n(
    input clk, reset_p, enable,
    output reg[3:0] count);
    
    always@(negedge clk or negedge reset_p)begin
        if(reset_p)count =0;
        else if(enable)count = count + 1;
    end
endmodule


module Down_Counter_p(
    input clk, reset_p, enable,
    output reg[3:0] count);
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)count =0;
        else if(enable)count = count - 1;
    end
endmodule

module Down_Counter_n(
    input clk, reset_p, enable,
    output reg[3:0] count);
    
    always@(negedge clk or negedge reset_p)begin
        if(reset_p)count =0;
        else if(enable)count = count - 1;
    end
endmodule

//no enable >> outomatic enable = 1
module bcd_upcounter(
    input clk, reset_p,
    output reg[3:0] count);
        
    always@(posedge clk or posedge reset_p)begin
    if(reset_p) count =0;
    else begin
        if(count >=9) count = 0;
        else count = count +1;
        end
    end
endmodule



module bcd_downcounter(
    input clk, reset_p,
    output reg[3:0] count);
    
    always@(negedge clk or negedge reset_p)begin
    if(reset_p) count = 0;
    else begin
        if(count >= 10 | count == 0) count = 9;
        else count = count - 1;
        //count = count - 1;
        //if(count>= 10) count = 9;
        end
    end
endmodule

module BCD_Up_Down_p(
    input clk, reset_p,
    input up_down,
    output reg[3:0] count);
    
    always@(posedge clk or posedge reset_p)begin
    if(reset_p) count = 0;
    else begin
        if(up_down)begin
            if(count >=9) count =0;
            else count = count +1;
        end
        else begin
            if(count >= 10 | count == 0) count = 9;
            else count = count -1;
            end  
        end
    end
endmodule


module up_down_counter_p(
    input clk, reset_p,
    input up_down,
    output reg [3:0] count);
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)count = 9;
        else begin
            if(up_down)begin
                count = count +1;
            end
            else begin
                count = count -1;
            end
        end
    end
endmodule



module ring_counter(
    input clk, reset_p,
    output reg [3:0] q);
    
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p) q = 4'b0001;
        else begin
            case(q)
                4'b0001 : q = 4'b0010;
                4'b0010 : q = 4'b0100;
                4'b0100 : q = 4'b1000;
                4'b1000 : q = 4'b0001;
                default: q = 4'b0001;
            endcase
        end
    end
endmodule

module ring_counter_3bit(
    input clk, reset_p,
    output reg [2:0] q);
    
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p) q = 4'b001;
        else begin
            case(q)
                4'b001 : q = 4'b010;
                4'b010 : q = 4'b100;
                4'b100 : q = 4'b001;
                default: q = 4'b001;
            endcase
        end
    end
endmodule

module ring_counter_shift(
    input clk, reset_p,
    output reg [3:0] q);
    
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)q = 4'b0001;
        else begin
            if(q == 4'b1000)q=4'b0001;
            else q[3:0] = {q[2:0],1'b0};
            //else q = q << 1;
        end
    end
endmodule


module edge_dectector_p(
    input clk, reset_p,
    input cp,
    output p_edge);
    
    reg ff_current, ff_old;
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            ff_current <= 0;
            ff_old <= 0;
        end
        else begin
            ff_current <= cp;
            ff_old <= ff_current;
         end
    end
    
    assign p_edge = ({ff_current, ff_old} == 2'b10) ? 1:0; //LUT
endmodule


module edge_dectector_n(
    input clk, reset_p,
    input cp,
    output p_edge,n_edge);
    
    reg ff_current, ff_old;
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            ff_current <= 0;
            ff_old <= 0;
        end
        else begin
            ff_current <= cp;
            ff_old <= ff_current;
         end
    end
    
    assign p_edge = ({ff_current, ff_old} == 2'b10) ? 1:0; //LUT
    assign n_edge = ({ff_current, ff_old} == 2'b01) ? 1:0; //LUT
endmodule

module edge_dectector_clk_neg(
    input clk, reset_p,
    input cp,
    output p_edge,n_edge);
    
    reg ff_current, ff_old;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)begin
            ff_current <= 0;
            ff_old <= 0;
        end
        else begin
            ff_current <= cp;
            ff_old <= ff_current;
         end
    end
    
    assign p_edge = ({ff_current, ff_old} == 2'b10) ? 1:0; //LUT
    assign n_edge = ({ff_current, ff_old} == 2'b01) ? 1:0; //LUT
endmodule

module shift_register_SISO_n(
    input clk, reset_p,
    input d,
    output q);
    
    reg[3:0] siso_reg;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p) siso_reg <= 0;
        else begin
        siso_reg <= {d, siso_reg[3:1]}; 
//            siso_reg[3] <= d;
//            siso_reg[2] <= siso_reg[3];
//            siso_reg[1] <= siso_reg[2];
//            siso_reg[0] <= siso_reg[1];
        end
    end
    assign q = siso_reg[0];
endmodule

module R_shift_register_SISO_Nbit_n #(parameter N = 8)(
    input clk, reset_p,
    input d,
    output q);
    
    reg[N-1:0] siso_reg;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p) siso_reg <= 0;
        else begin
        siso_reg <= {d, siso_reg[N-1:1]}; 
        end
    end
    assign q = siso_reg[0];
endmodule


module L_shift_register_SISO_Nbit_n #(parameter N = 8)(
    input clk, reset_p,
    input d,
    output q);
    
    reg[N-1:0] siso_reg;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p) siso_reg <= 0;
        else begin
        siso_reg <= {siso_reg[N-2:0],d}; 
        end
    end
    assign q = siso_reg[0];
endmodule


module shift_register_SIPO_n(
    input clk, reset_p,
    input d,
    input rd_en,
    output[3:0]q);
    
    reg[3:0] sipo_reg;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p) sipo_reg <= 0;
        else begin
            sipo_reg <= {d, sipo_reg[3:1]}; 
        end
    end

    assign q = rd_en ? 4'bz:sipo_reg;
    //bufif0(q[0],sipo_reg[0],ed_en);
endmodule

module shift_register_SIPO_Nbit_n #(parameter N = 8)(
    input clk, reset_p,
    input d,
    input rd_en,
    output[N-1:0]q);
    
    reg[N-1:0] sipo_reg;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p) sipo_reg <= 0;
        else begin
            sipo_reg <= {d, sipo_reg[N-1:1]}; 
        end
    end

    assign q = rd_en ? 'bz:sipo_reg;
    //bufif0(q[0],sipo_reg[0],ed_en);
endmodule

module shift_register_PISO_n(
    input clk, reset_p,
    input [3:0]d,
    input shift_load,
    output q);
    
    reg[3:0] piso_reg;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p) piso_reg <= 0;
        else begin
            if(shift_load) begin
                piso_reg <= {1'b0, piso_reg[3:1]}; 
            end
            else begin
                piso_reg = d;
            end
        end
    end
    assign q = piso_reg[0];
endmodule

module shift_register_PISO_Nbit_n #(parameter N = 8)(
    input clk, reset_p,
    input [N-1:0]d,
    input shift_load,
    output q);
    
    reg[N-1:0] piso_reg;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p) piso_reg <= 0;
        else begin
            if(shift_load) begin
                piso_reg <= {1'b0, piso_reg[N-1:1]}; 
            end
            else begin
                piso_reg = d;
            end
        end
    end
    assign q = piso_reg[0];
endmodule


module register_8bit_n(
    input [7:0] in_Data,
    input clk,reset_p, wr_en, rd_en,
    output [7:0]out_Data);
    
    reg [7:0] register;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p) register=0;
        else if(wr_en) register=in_Data;
    end
    assign out_Data = rd_en ? register : 'bz;
    
endmodule


module register_8bit_Nbit_n #(parameter N = 8)(
    input [N-1:0] in_Data,
    input clk,reset_p, wr_en, rd_en,
    output [N-1:0]out_Data);
    
    reg [N-1:0] register;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p) register=0;
        else if(wr_en) register=in_Data;
    end
    assign out_Data = rd_en ? register : 'bz;
    
endmodule


module SRAM_8bit_1024(
    input clk, 
    input wr_en,rd_en,
    input [9:0] address,
    inout [7:0] data);
    
    reg [7:0] memory[0:1023];
    
    always@(posedge clk)if(wr_en) memory[address] = data;
    assign data = rd_en ? memory[address] : 'bz;
    
endmodule


