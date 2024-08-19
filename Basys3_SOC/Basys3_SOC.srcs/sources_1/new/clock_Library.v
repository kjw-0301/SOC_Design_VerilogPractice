`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/16 11:19:14
// Design Name: 
// Module Name: clock_Library
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
module clock_div_100(
    input clk, reset_p,
    output clk_div_100,
    output clk_div_100_nedge);
    
    reg [6:0] cnt_sysclk = 2;
    
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)cnt_sysclk = 0;
        else begin
            if(cnt_sysclk >= 99) cnt_sysclk  = 0;
            else cnt_sysclk = cnt_sysclk + 1;
        end
    end
    assign clk_div_100 = (cnt_sysclk < 50) ? 0:1;
    
    edge_dectector_n ed(
    .clk(clk), 
    .reset_p(reset_p),
    .cp(clk_div_100),
    .n_edge(clk_div_100_nedge));
endmodule







module clock_div_1000(
    input clk, reset_p,
    input clk_source,
    output clk_div_1000,
    output clk_div_1000_negedge);
    
    reg [9:0] cnt_clksource;
    
    wire clk_source_negedge;
    edge_dectector_n ed_source(
    .clk(clk), 
    .reset_p(reset_p),
    .cp(clk_source),
    .n_edge(clk_source_negedge));
    
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)cnt_clksource = 0;
        else if(clk_source_negedge)begin
            if(cnt_clksource >= 999) cnt_clksource  = 0;
            else cnt_clksource = cnt_clksource + 1;
        end
    end
    assign clk_div_1000 = (cnt_clksource < 999) ? 0:1;
    
    edge_dectector_n ed(
    .clk(clk), 
    .reset_p(reset_p),
    .cp(clk_div_1000),
    .n_edge(clk_div_1000_negedge));
endmodule


module clock_div_10_cc(
    input clk, reset_p,
    input clk_source,
    output clk_div_10,
    output clk_div_10_negedge);
    
    reg [9:0] cnt_clksource;
    
    wire clk_source_negedge;
    edge_dectector_n ed_source(
    .clk(clk), 
    .reset_p(reset_p),
    .cp(clk_source),
    .n_edge(clk_source_negedge));
    
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)cnt_clksource = 0;
        else if(clk_source_negedge)begin
            if(cnt_clksource >= 9) cnt_clksource  = 0;
            else cnt_clksource = cnt_clksource + 1;
        end
    end
    assign clk_div_10 = (cnt_clksource < 5) ? 0:1;
    
    edge_dectector_n ed(
    .clk(clk), 
    .reset_p(reset_p),
    .cp(clk_div_10),
    .n_edge(clk_div_10_negedge));
endmodule




module clock_div_60(
    input clk, reset_p,
    input clk_source,
    output clk_div_60,
    output clk_div_60_negedge);
    
    reg [9:0] cnt_clksource;
    
    wire clk_source_negedge;
    edge_dectector_n ed_source(
    .clk(clk), 
    .reset_p(reset_p),
    .cp(clk_source),
    .n_edge(clk_source_negedge));
    
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)cnt_clksource = 0;
        else if(clk_source_negedge)begin
            if(cnt_clksource >= 59) cnt_clksource  = 0;
            else cnt_clksource = cnt_clksource + 1;
        end
    end
    assign clk_div_60 = (cnt_clksource < 59) ? 0:1;
    
    edge_dectector_n ed(
    .clk(clk), 
    .reset_p(reset_p),
    .cp(clk_div_60),
    .n_edge(clk_div_60_negedge));
endmodule

//BCD 60 Counter
module counter_BCD_60(
    input clk, reset_p,
    input clk_time,
    output reg[3:0] BCD_1, BCD_10);
    
    wire clk_time_negedge;
    edge_dectector_n ed(.clk(clk), .reset_p(reset_p),.cp(clk_time),.n_edge(clk_time_negedge));
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            BCD_1 = 0;
            BCD_10 = 0;
        end
        else if(clk_time_negedge)begin
            if(BCD_1 >= 9)begin
                BCD_1 = 0;
                if(BCD_10 >=5)BCD_10=0;
                else BCD_10 = BCD_10 + 1;
            end
            else BCD_1 = BCD_1 + 1;
        end 
    end
endmodule



module Loadable_counter_BCD_60(
    input clk, reset_p,
    input clk_time,
    input load_enable,
    input [3:0] load_BCD1, load_BCD10,
    output reg[3:0] BCD_1, BCD_10);
    
    wire clk_time_negedge;
    edge_dectector_n ed(.clk(clk), .reset_p(reset_p),.cp(clk_time),.n_edge(clk_time_negedge));
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            BCD_1 = 0;
            BCD_10 = 0;
        end
        else begin
            if(load_enable)begin
                BCD_1 = load_BCD1;
                BCD_10 = load_BCD10;
            end
            if(clk_time_negedge)begin
            if(BCD_1 >= 9)begin
                BCD_1 = 0;
                if(BCD_10 >=5)BCD_10=0;
                else BCD_10 = BCD_10 + 1;
            end
            else BCD_1 = BCD_1 + 1;
        end 
      end
    end
endmodule



module counter_BCD_60_Clear(
    input clk, reset_p,
    input clk_time,
    input clear,
    output reg[3:0] BCD_1, BCD_10);
    
    wire clk_time_negedge;
    edge_dectector_n ed(.clk(clk), .reset_p(reset_p),.cp(clk_time),.n_edge(clk_time_negedge));
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            BCD_1 = 0;
            BCD_10 = 0;
        end
        else begin
            if(clear)begin
                BCD_1 = 0;
                BCD_10 = 0;
            end 
            if(clk_time_negedge)begin
            if(BCD_1 >= 9)begin
                BCD_1 = 0;
                if(BCD_10 >=5)BCD_10=0;
                else BCD_10 = BCD_10 + 1;
            end
            else BCD_1 = BCD_1 + 1;
        end 
      end
    end
endmodule

//BCD 100 Counter
module counter_BCD_100_clear(
    input clk, reset_p,
    input clk_time,
    input clear,
    output reg[3:0] BCD_1, BCD_10);
    
    wire clk_time_negedge;
    edge_dectector_n ed(.clk(clk), .reset_p(reset_p),.cp(clk_time),.n_edge(clk_time_negedge));
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            BCD_1 = 0;
            BCD_10 = 0;
        end
         else begin
            if(clear)begin
                BCD_1 = 0;
                BCD_10 = 0;
            end 
            if(clk_time_negedge)begin
            if(BCD_1 >= 9)begin
                BCD_1 = 0;
                if(BCD_10 >=9)BCD_10=0;
                else BCD_10 = BCD_10 + 1;
            end
            else BCD_1 = BCD_1 + 1;
        end 
      end
    end
endmodule






module Loadable_Down_counter_BCD_60(
    input clk, reset_p,
    input clk_time,
    input load_enable,
    input [3:0] load_BCD1, load_BCD10,
    output reg[3:0] BCD_1, BCD_10,
    output reg dec_clk);
    
    wire clk_time_negedge;
    edge_dectector_n ed(.clk(clk), .reset_p(reset_p),.cp(clk_time),.n_edge(clk_time_negedge));
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            BCD_1 = 0;
            BCD_10 = 0;
            dec_clk = 0;
        end
        else begin
            if(load_enable)begin
                BCD_1 = load_BCD1;
                BCD_10 = load_BCD10;
            end
            if(clk_time_negedge)begin
                if(BCD_1 == 0)begin
                    BCD_1 = 9;
                    if(BCD_10 == 0)begin
                        BCD_10=5;
                        dec_clk=1;
                    end
                else BCD_10 = BCD_10 - 1;
            end
            else BCD_1 = BCD_1 - 1;
        end 
        else dec_clk = 0;
      end
    end
endmodule

//BCD 60 Counter
module Downcounter_BCD_60(
    input clk, reset_p,
    input clk_time,
    output reg[3:0] BCD_1, BCD_10);
    
    wire clk_time_negedge;
    edge_dectector_n ed(.clk(clk), .reset_p(reset_p),.cp(clk_time),.n_edge(clk_time_negedge));
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            BCD_1 = 0;
            BCD_10 = 0;
        end
        else if(clk_time_negedge)begin
            if(BCD_1 == 0)begin
                BCD_1 = 9;
                if(BCD_10 == 0)BCD_10 = 5;
                else BCD_10 = BCD_10 - 1;
            end
            else BCD_1 = BCD_1 - 1;
        end 
    end
endmodule



module SR04_div_58(
    input clk, reset_p,
    input clk_microsec,cnt_enable,
    output reg[11:0] cm);
    
    reg [5:0] cnt;
    
    wire clk_source_negedge;
    
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)begin
            cnt = 0;
            cm = 0;
        end
        else if(clk_microsec)begin
            if(cnt_enable)begin
                if(cnt >= 57)begin 
                    cnt  = 0;
                    cm = cm + 1;
                end
                else cnt = cnt + 1;
            end
        end
        else if(!cnt_enable)begin
            cnt = 0;
            cm = 0;
        end
    end
endmodule
