`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/16 14:16:04
// Design Name: 
// Module Name: test_top
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


module board_test_top(
    input [15:0] switch,
    output [15:0] led);
    
    assign led = switch;
endmodule

// 1110 1101 1011 0111

 module ring_counter_fnd(
    input clk, reset_p,
    output reg [3:0] com);
    
    reg [20:0] clk_div = 0;
    always@(posedge clk)clk_div = clk_div+1;
    
    wire clk_div_nedge;
    edge_dectector_n ed(.clk(clk), .reset_p(reset_p),.cp(clk_div[16]),.n_edge(clk_div_nedge));
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p) com = 4'b1110;
        else if(clk_div_nedge)begin
           if(com == 4'b0111)com = 4'b1110;
           else com = {com[2:0], 1'b1};
        end
    end
endmodule



module ring_counter_LED(
    input clk, reset_p,
    output reg [15:0] led);
    
    reg [20:0] clk_div;
    always@(posedge clk)clk_div = clk_div+1;
    
    wire clk_div_nedge;
    edge_dectector_n ed(.clk(clk), .reset_p(reset_p),.cp(clk_div[20]),.n_edge(clk_div_nedge));
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p) led = 16'b0000_0000_0000_0001;
        else if(clk_div_nedge)begin
           if(led == 16'b1000_0000_0000_0000)led = 16'b1;
           else led = {led[14:0], 1'b0};
        end
    end
endmodule




module fnd_test_top(
    input clk, reset_p,
    input [15:0] switch,
    output [3:0] com,
    output[7:0] seg_7);

    fnd_controller(.clk(clk), .reset_p(reset_p), .value(switch), .com(com), .seg_7(seg_7)); 

endmodule


module watch_top(
    input clk, reset_p,
    input [2:0]btn, //0btn : mode Change
    output [3:0]com,
    output [7:0]seg_7);

    wire btn_mode;
    wire btn_sec;
    wire btn_min;
    wire set_watch;
    wire inc_sec, inc_min;
    wire clk_microsec, clk_msec, clk_sec, clk_min;
    wire [3:0] sec1,sec10,min1,min10;
    wire [15:0] value;
    
    
    button_Controller btn0(.clk(clk), .reset_p(reset_p),.btn(btn[0]), .btn_posedge(btn_mode));
    button_Controller btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]), .btn_posedge(btn_sec));
    button_Controller btn2(.clk(clk), .reset_p(reset_p),.btn(btn[2]), .btn_posedge(btn_min));
    
    //edge_dectector_n btn0(.clk(clk), .reset_p(reset_p),.cp(btn[0]),.p_edge(btn_mode));
    //edge_dectector_n btn1(.clk(clk), .reset_p(reset_p),.cp(btn[1]),.p_edge(btn_sec));
    //edge_dectector_n btn2(.clk(clk), .reset_p(reset_p),.cp(btn[2]),.p_edge(btn_min));
    
    T_FF_positive(.clk(clk), .reset_p(reset_p), .t(btn_mode), .q(set_watch));
    assign inc_sec = set_watch ? btn_sec : clk_sec;
    assign inc_min = set_watch ? btn_min : clk_min;
    
    clock_div_100 microsec_clk( .clk(clk), .reset_p(reset_p),.clk_div_100(clk_microsec));
    clock_div_1000 msec_clk(.clk(clk), .reset_p(reset_p), .clk_source(clk_microsec), .clk_div_1000(clk_msec));
    clock_div_1000 sec_clk(.clk(clk), .reset_p(reset_p), .clk_source(clk_msec), .clk_div_1000_negedge(clk_sec));
    clock_div_60 min_clk(.clk(clk), .reset_p(reset_p), .clk_source(inc_sec), .clk_div_60_negedge(clk_min));
   
    counter_BCD_60 counter_sec(.clk(clk), .reset_p(reset_p), .clk_time(inc_sec),.BCD_1(sec1), .BCD_10(sec10));
    counter_BCD_60 counter_min(.clk(clk), .reset_p(reset_p), .clk_time(inc_min),.BCD_1(min1), .BCD_10(min10));
    
    assign value = {min10,min1, sec10,sec1};
    fnd_controller(.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));
endmodule





module Loadable_watch_top(
    input clk, reset_p,
    input [2:0]btn, //0btn : mode Change
    output [3:0]com,
    output [7:0]seg_7);

    wire btn_mode;
    wire btn_sec;
    wire btn_min;
    wire set_watch;
    wire inc_sec, inc_min;
    wire clk_microsec, clk_msec, clk_sec, clk_min;
    wire [3:0] watch_sec1,watch_sec10,watch_min1,watch_min10;
    wire [3:0] set_sec1,set_sec10,set_min1,set_min10;
    wire [15:0] value,watch_value, set_value;
    
    
    button_Controller btn0(.clk(clk), .reset_p(reset_p),.btn(btn[0]), .btn_posedge(btn_mode));
    button_Controller btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]), .btn_posedge(btn_sec));
    button_Controller btn2(.clk(clk), .reset_p(reset_p),.btn(btn[2]), .btn_posedge(btn_min));
    
    
    //edge_dectector_n btn0(.clk(clk), .reset_p(reset_p),.cp(btn[0]),.p_edge(btn_mode));
    //edge_dectector_n btn1(.clk(clk), .reset_p(reset_p),.cp(btn[1]),.p_edge(btn_sec));
    //edge_dectector_n btn2(.clk(clk), .reset_p(reset_p),.cp(btn[2]),.p_edge(btn_min));
    
    T_FF_positive(.clk(clk), .reset_p(reset_p), .t(btn_mode), .q(set_watch));
   
    wire watch_load_enable,setMode_load_enable ;
    edge_dectector_n ed_source(.clk(clk), .reset_p(reset_p),.cp(set_watch), .n_edge(watch_load_enable), .p_edge(setMode_load_enable));
    
    
    assign inc_sec = set_watch ? btn_sec : clk_sec;
    assign inc_min = set_watch ? btn_min : clk_min;
    
    clock_div_100 microsec_clk( .clk(clk), .reset_p(reset_p),.clk_div_100(clk_microsec));
    clock_div_1000 msec_clk(.clk(clk), .reset_p(reset_p), .clk_source(clk_microsec), .clk_div_1000(clk_msec));
    clock_div_1000 sec_clk(.clk(clk), .reset_p(reset_p), .clk_source(clk_msec), .clk_div_1000_negedge(clk_sec));
    clock_div_60 min_clk(.clk(clk), .reset_p(reset_p), .clk_source(inc_sec), .clk_div_60_negedge(clk_min));
   
    Loadable_counter_BCD_60 sec_watch(.clk(clk), .reset_p(reset_p), .clk_time(clk_sec), .load_enable(watch_load_enable), 
                                      .load_BCD1(set_sec1), .load_BCD10(set_sec10), 
                                      .BCD_1(watch_sec1), .BCD_10(watch_sec10));
    Loadable_counter_BCD_60 min_watch(.clk(clk), .reset_p(reset_p), .clk_time(clk_min), .load_enable(watch_load_enable), 
                                      .load_BCD1(set_min1), .load_BCD10(set_min10), 
                                      .BCD_1(watch_min1), .BCD_10(watch_min10));
                                      
    Loadable_counter_BCD_60 sec_set(.clk(clk), .reset_p(reset_p), .clk_time(btn_sec), .load_enable(setMode_load_enable), 
                                      .load_BCD1(watch_sec1), .load_BCD10(watch_sec10), 
                                      .BCD_1(set_sec1), .BCD_10(set_sec10));
    Loadable_counter_BCD_60 min_set(.clk(clk), .reset_p(reset_p), .clk_time(btn_min), .load_enable(setMode_load_enable), 
                                      .load_BCD1(watch_min1), .load_BCD10(watch_min10), 
                                      .BCD_1(set_min1), .BCD_10(set_min10));
                                      
    assign watch_value = {watch_min10,watch_min1, watch_sec10,watch_sec1};
    assign set_value = {set_min10,set_min1, set_sec10,set_sec1};
    assign value = set_watch ? set_value : watch_value;
    fnd_controller(.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));
endmodule


module Loadable_watch_Project(
    //input, output, wire, reg
    input clk, reset_p,
    input [3:0]btn, //0btn : mode Change
    output [3:0]com,
    output [7:0]seg_7,
    output led_watch);

    wire btn_mode;
    wire btn_sec;
    wire btn_min;
    wire set_watch;
    wire inc_sec, inc_min;
    wire clk_microsec, clk_msec, clk_sec, clk_min;
    wire [3:0] watch_sec1,watch_sec10,watch_min1,watch_min10;
    wire [3:0] set_sec1,set_sec10,set_min1,set_min10;
    wire [15:0] value,watch_value, set_value;
    wire watch_load_enable,setMode_load_enable ;

    
    //btnController, 
    button_Controller btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]), .btn_posedge(btn_sec));
    button_Controller btn2(.clk(clk), .reset_p(reset_p),.btn(btn[2]), .btn_posedge(btn_min));
    button_Controller btn3(.clk(clk), .reset_p(reset_p),.btn(btn[3]), .btn_posedge(btn_mode));
    
    //btn3 > change set watch mode
    T_FF_positive T_inst(.clk(clk), .reset_p(reset_p), .t(btn_mode), .q(set_watch));
    assign set_watch = led_watch;
    
    //set,watch mode load
    edge_dectector_n ed_source(.clk(clk), .reset_p(reset_p),.cp(set_watch), .n_edge(watch_load_enable), .p_edge(setMode_load_enable));
    
    //mux : setmode increase sec, min btn
    assign inc_sec = set_watch ? btn_sec : clk_sec;
    assign inc_min = set_watch ? btn_min : clk_min;
    
    //clock divide
    clock_div_100 microsec_clk( .clk(clk), .reset_p(reset_p),.clk_div_100(clk_microsec));
    clock_div_1000 msec_clk(.clk(clk), .reset_p(reset_p), .clk_source(clk_microsec), .clk_div_1000(clk_msec));
    clock_div_1000 sec_clk(.clk(clk), .reset_p(reset_p), .clk_source(clk_msec), .clk_div_1000_negedge(clk_sec));
    clock_div_60 min_clk(.clk(clk), .reset_p(reset_p), .clk_source(inc_sec), .clk_div_60_negedge(clk_min));
   
   //Loadable BCD counter set,watchMode
    Loadable_counter_BCD_60 sec_watch(.clk(clk), .reset_p(reset_p), .clk_time(clk_sec), .load_enable(watch_load_enable), 
                                      .load_BCD1(set_sec1), .load_BCD10(set_sec10), 
                                      .BCD_1(watch_sec1), .BCD_10(watch_sec10));
    Loadable_counter_BCD_60 min_watch(.clk(clk), .reset_p(reset_p), .clk_time(clk_min), .load_enable(watch_load_enable), 
                                      .load_BCD1(set_min1), .load_BCD10(set_min10), 
                                      .BCD_1(watch_min1), .BCD_10(watch_min10));
                                      
    Loadable_counter_BCD_60 sec_set(.clk(clk), .reset_p(reset_p), .clk_time(btn_sec), .load_enable(setMode_load_enable), 
                                      .load_BCD1(watch_sec1), .load_BCD10(watch_sec10), 
                                      .BCD_1(set_sec1), .BCD_10(set_sec10));
    Loadable_counter_BCD_60 min_set(.clk(clk), .reset_p(reset_p), .clk_time(btn_min), .load_enable(setMode_load_enable), 
                                      .load_BCD1(watch_min1), .load_BCD10(watch_min10), 
                                      .BCD_1(set_min1), .BCD_10(set_min10));
    //value                                
    assign watch_value = {watch_min10,watch_min1, watch_sec10,watch_sec1};
    assign set_value = {set_min10,set_min1, set_sec10,set_sec1};
    assign value = set_watch ? set_value : watch_value;
    fnd_controller fnd_instance(.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));
endmodule






module stop_watch_top_clear(
    input clk, reset_p,
    input [2:0] btn,
    output [3:0] com,
    output led_start, led_lap,
    output [7:0] seg_7);
    
    wire [3:0] min10, min1, sec10, sec1;
    wire btn_start, btn_lap, btn_clear;
    reg lap;
    wire start_stop;
    wire clk_start;
    wire clk_microsec, clk_msec, clk_sec, clk_min;
    wire reset_start;

    assign clk_start = start_stop ? clk : 0;
    
    clock_div_100 microsec_clk( .clk(clk_start), .reset_p(reset_p),.clk_div_100(clk_microsec));
    clock_div_1000 msec_clk(.clk(clk_start), .reset_p(reset_p), .clk_source(clk_microsec), .clk_div_1000(clk_msec));
    clock_div_1000 sec_clk(.clk(clk_start), .reset_p(reset_p), .clk_source(clk_msec), .clk_div_1000_negedge(clk_sec));
    clock_div_60 min_clk(.clk(clk_start), .reset_p(reset_start), .clk_source(clk_sec), .clk_div_60_negedge(clk_min));
    
    button_Controller btn0(.clk(clk), .reset_p(reset_p),.btn(btn[0]), .btn_posedge(btn_start));
    button_Controller btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]), .btn_posedge(btn_lap));
    button_Controller btn2(.clk(clk), .reset_p(reset_p),.btn(btn[2]), .btn_posedge(btn_clear));
    
    
    assign reset_start = reset_p | btn_clear;
    
    T_FF_positive t_start(.clk(clk), .reset_p(reset_start), .t(btn_start), .q(start_stop));
    assign led_start = start_stop;
    
    always @ (posedge clk or posedge reset_p)begin
        if(reset_p) lap = 0;
        else begin
            if(btn_lap)lap = ~lap;
            else if(btn_clear) lap = 0;
            end
        end
    
    //T_FF_positive t_lap(.clk(clk), .reset_p(reset_p), .t(btn_lap), .q(lap)); //first 0 >> 1
    assign led_lap = lap; 
    
    reg [15:0] lap_time;
    wire [15:0] cur_time;
    assign cur_time  = {min10, min1, sec10, sec1};
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)lap_time = 0;
        else if(btn_lap) lap_time = cur_time; 
        else if(btn_clear) lap_time = 0;
    end
    
    counter_BCD_60_Clear counter_sec(.clk(clk), .reset_p(reset_p), .clk_time(clk_sec),.clear(btn_clear),.BCD_1(sec1), .BCD_10(sec10));
    counter_BCD_60_Clear counter_min(.clk(clk), .reset_p(reset_p), .clk_time(clk_min),.clear(btn_clear),.BCD_1(min1), .BCD_10(min10));
    
    wire[15:0] value;
   
    assign value =  lap ? lap_time : cur_time;
    fnd_controller(.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));

endmodule


module sec_stopwatch_Project(
    //input, output
    input clk, reset_p,
    input [3:0]btn,
    output [3:0] com,
    output led_start, led_lap,
    output [7:0] seg_7);
    
    wire clk_microsec, clk_msec, clk_Csec,clk_Csec10, clk_sec;
    wire btn_start, btn_lap,btn_clear;
    wire start_stop;
    wire [3:0] sec10, sec1, csec10, csec1;
    
    //push btn_start > stop or start Time
    assign clk_start = start_stop ? clk : 0;
    
    //clock divide , we need centi sec so, use 10 clock divide
    clock_div_100 microsec_clk( .clk(clk_start), .reset_p(reset_p),.clk_div_100(clk_microsec));
    clock_div_1000 msec_clk(.clk(clk_start), .reset_p(reset_p), .clk_source(clk_microsec), .clk_div_1000(clk_msec));
    clock_div_10_cc cc_clk10(.clk(clk), .reset_p(reset_p), .clk_source(clk_msec), .clk_div_10(clk_Csec));
    clock_div_1000 sec_clk(.clk(clk_start), .reset_p(reset_p), .clk_source(clk_msec), .clk_div_1000_negedge(clk_sec));
    
    button_Controller btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]), .btn_posedge(btn_start));
    button_Controller btn2(.clk(clk), .reset_p(reset_p),.btn(btn[2]), .btn_posedge(btn_lap));
    button_Controller btn3(.clk(clk), .reset_p(reset_p),.btn(btn[3]), .btn_posedge(btn_clear));
    
    //btn_start > start_stop value toggle
    T_FF_positive t_start(.clk(clk), .reset_p(reset_p), .t(btn_start), .q(start_stop));
    assign led_start = start_stop;
    //btn_lap > lap value toggle
    T_FF_positive t_lap(.clk(clk), .reset_p(reset_p), .t(btn_lap), .q(lap)); //first 0 >> 1
    assign led_lap = lap;
    
    //lap time function
    reg [15:0] lap_time;
    wire [15:0] cur_time;
    assign cur_time  = {sec10, sec1, csec10, csec1};
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)lap_time = 0;
        else if(btn_lap) lap_time = cur_time; 
        else if(btn_clear) lap_time = 0;
    end
    
    //10ms count 100time > 1sec
    counter_BCD_100_clear counter_csec(.clk(clk), .reset_p(reset_p), .clk_time(clk_Csec),.clear(btn_clear),.BCD_1(csec1), .BCD_10(csec10));
    //60sec count
    counter_BCD_60_Clear counter_sec(.clk(clk), .reset_p(reset_p), .clk_time(clk_sec),.clear(btn_clear),.BCD_1(sec1), .BCD_10(sec10));
    
    wire[15:0] value;
    assign value =  lap ? lap_time : cur_time;
    fnd_controller(.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));
    
endmodule



module sec_stopwatch(
    input clk, reset_p,
    input [2:0]btn,
    output [3:0] com,
    output led_start, led_lap,
    output [7:0] seg_7);
    
    wire clk_microsec, clk_msec, clk_Csec,clk_Csec10, clk_sec;
    wire btn_start, btn_lap;
    wire start_stop;
    wire [3:0] sec10, sec1, csec10, csec1;
    
    assign clk_start = start_stop ? clk : 0;
    
    clock_div_100 microsec_clk( .clk(clk_start), .reset_p(reset_p),.clk_div_100(clk_microsec));
    clock_div_1000 msec_clk(.clk(clk_start), .reset_p(reset_p), .clk_source(clk_microsec), .clk_div_1000(clk_msec));
    clock_div_10_cc cc_clk10(.clk(clk), .reset_p(reset_p), .clk_source(clk_msec), .clk_div_10(clk_Csec));
    clock_div_1000 sec_clk(.clk(clk_start), .reset_p(reset_p), .clk_source(clk_msec), .clk_div_1000_negedge(clk_sec));
    
    button_Controller btn0(.clk(clk), .reset_p(reset_p),.btn(btn[0]), .btn_posedge(btn_start));
    button_Controller btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]), .btn_posedge(btn_lap));
    
    T_FF_positive t_start(.clk(clk), .reset_p(reset_start), .t(btn_start), .q(start_stop));
    assign led_start = start_stop;
    
    T_FF_positive t_lap(.clk(clk), .reset_p(reset_p), .t(btn_lap), .q(lap)); //first 0 >> 1
    assign led_lap = lap;
    
    reg [15:0] lap_time;
    wire [15:0] cur_time;
    assign cur_time  = {sec10, sec1, csec10, csec1};
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)lap_time = 0;
        else if(btn_lap) lap_time = cur_time; 
    end
    
    counter_BCD_100_clear counter_csec(.clk(clk), .reset_p(reset_p), .clk_time(clk_Csec),.clear(btn_clear),.BCD_1(csec1), .BCD_10(csec10));
    counter_BCD_60_Clear counter_sec(.clk(clk), .reset_p(reset_p), .clk_time(clk_sec),.clear(btn_clear),.BCD_1(sec1), .BCD_10(sec10));
    
    wire[15:0] value;
   
    assign value =  lap ? lap_time : cur_time;
    fnd_controller(.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));
    
endmodule


module cook_timer_top(
    input clk, reset_p,
    input [3:0]btn,
    output [3:0]com,
    output [7:0]seg_7,
    output led_alarm, led_start,buzz);

    wire clk_microsec,clk_msec,clk_sec,clk_min;
    wire btn_start,btn_sec,btn_min,btn_alarm_off;
    wire [3:0] set_min10, set_min1, set_sec10, set_sec1; 
    wire [3:0] cur_min10, cur_min1, cur_sec10, cur_sec1; 
    reg start_set,alarm;
    wire [15:0] value, set_time, cur_time;
    wire dec_clk;
    
    clock_div_100 microsec_clk( .clk(clk), .reset_p(reset_p),.clk_div_100(clk_microsec));
    clock_div_1000 msec_clk(.clk(clk), .reset_p(reset_p), .clk_source(clk_microsec), .clk_div_1000(clk_msec));
    clock_div_1000 sec_clk(.clk(clk), .reset_p(reset_p), .clk_source(clk_msec), .clk_div_1000_negedge(clk_sec));
    //clock_div_60 min_clk(.clk(clk), .reset_p(reset_start), .clk_source(clk_sec), .clk_div_60_negedge(clk_min));
    
    button_Controller btn0(.clk(clk), .reset_p(reset_p),.btn(btn[0]), .btn_posedge(btn_start));
    button_Controller btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]), .btn_posedge(btn_sec));
    button_Controller btn2(.clk(clk), .reset_p(reset_p),.btn(btn[2]), .btn_posedge(btn_min));
    button_Controller btn3(.clk(clk), .reset_p(reset_p),.btn(btn[2]), .btn_posedge(btn_alarm_off));
    
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            start_set = 0;
            alarm = 0;
        end
        else begin
            if(btn_start) start_set = ~start_set;
            else if(cur_time == 0 && start_set)begin
                start_set = 0;
                alarm = 1;
            end
                else if(btn_alarm_off) alarm = 0;
        end  
    end
    
    assign led_alarm = alarm;
    assign led_start = start_set;
    assign buzz = alarm;
    
    counter_BCD_60 counter_sec(.clk(clk), .reset_p(reset_p), .clk_time(btn_sec),.BCD_1(set_sec1), .BCD_10(set_sec10));
    counter_BCD_60 counter_min(.clk(clk), .reset_p(reset_p), .clk_time(btn_min),.BCD_1(set_min1), .BCD_10(set_min10));
    
    Loadable_Down_counter_BCD_60 cur_sec(.clk(clk), .reset_p(reset_p), .clk_time(clk_sec), .load_enable(btn_start), .load_BCD1(set_sec1), .load_BCD10(set_sec10), .BCD_1(cur_sec1), .BCD_10(cur_sec10),.dec_clk(dec_clk));
    Loadable_Down_counter_BCD_60 cur_min(.clk(clk), .reset_p(reset_p), .clk_time(dec_clk), .load_enable(btn_start), .load_BCD1(set_min1), .load_BCD10(set_min10), .BCD_1(cur_min1), .BCD_10(cur_min10));
    
    assign set_time = {set_min10, set_min1, set_sec10, set_sec1};
    assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1};
    
    assign value = start_set ? cur_time : set_time;
    fnd_controller fnd(.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));


endmodule

module cook_timer_Project(
    //input, output
    input clk, reset_p,
    input [3:0]btn,
    input alarm_btn,
    input set_time_down_min_btn,
    output [3:0]com,
    output [7:0]seg_7,
    output led_alarm, led_start,buzz);

    wire clk_microsec,clk_msec,clk_sec,clk_min;
    wire btn_start,btn_sec,btn_min,btn_alarm_off;
    wire [3:0] set_min10, set_min1, set_sec10, set_sec1; 
    wire [3:0] cur_min10, cur_min1, cur_sec10, cur_sec1; 
    reg start_set,alarm;
    reg[15:0] set_time_r;
    wire [15:0] value, set_time, cur_time;
    wire dec_clk;
    
    //clock divide
    clock_div_100 microsec_clk( .clk(clk), .reset_p(reset_p),.clk_div_100(clk_microsec));
    clock_div_1000 msec_clk(.clk(clk), .reset_p(reset_p), .clk_source(clk_microsec), .clk_div_1000(clk_msec));
    clock_div_1000 sec_clk(.clk(clk), .reset_p(reset_p), .clk_source(clk_msec), .clk_div_1000_negedge(clk_sec));
    //btnController
    button_Controller btn3(.clk(clk), .reset_p(reset_p),.btn(btn[3]), .btn_posedge(btn_start));
    button_Controller btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]), .btn_posedge(btn_sec));
    button_Controller btn2(.clk(clk), .reset_p(reset_p),.btn(btn[2]), .btn_posedge(btn_min));
    //3rd_input_edgeDectector
    edge_dectector_n ed_alarm(.clk(clk), .reset_p(reset_p),.cp(alarm_btn), .p_edge(alarm_posedge));
    
    //timer alarm, clear function
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            start_set = 0;
            alarm = 0;
        end
        else begin
            if(btn_start) start_set = ~start_set;
            else if(cur_time == 0 && start_set)begin
                start_set = 0;
                alarm = 1;
            end
                else if(alarm_posedge) alarm = 0;
        end  
    end
    //LED 
    assign led_alarm = alarm;
    assign led_start = start_set;
    assign buzz = alarm;
    
    //setting timer
    counter_BCD_60 counter_sec(.clk(clk), .reset_p(reset_p), .clk_time(btn_sec),.BCD_1(set_sec1), .BCD_10(set_sec10));
    counter_BCD_60 counter_min(.clk(clk), .reset_p(reset_p), .clk_time(btn_min),.BCD_1(set_min1), .BCD_10(set_min10));
    //Down counter(BCD)
    Loadable_Down_counter_BCD_60 cur_sec(.clk(clk), .reset_p(reset_p), .clk_time(clk_sec), .load_enable(btn_start), .load_BCD1(set_sec1), .load_BCD10(set_sec10), .BCD_1(cur_sec1), .BCD_10(cur_sec10),.dec_clk(dec_clk));
    Loadable_Down_counter_BCD_60 cur_min(.clk(clk), .reset_p(reset_p), .clk_time(dec_clk), .load_enable(btn_start), .load_BCD1(set_min1), .load_BCD10(set_min10), .BCD_1(cur_min1), .BCD_10(cur_min10));
    //set_time value
    assign set_time = {set_min10, set_min1, set_sec10, set_sec1};
    //cur_time value
    assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1};
    //set value from start_set value
    assign value = start_set ? cur_time : set_time;
    fnd_controller fnd(.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));


endmodule

module keypad_test_top(
    input clk, reset_p,
    input [3:0] row, 
    output [3:0] col,
    output [3:0] com, 
    output [7:0] seg_7,
    output led_key_valid);

    wire [3:0] key_value;
    wire key_valid;
    
    wire key_valid_p;
    edge_dectector_n ed_clk(.clk(clk), .reset_p(reset_p),.cp(led), .p_edge(key_valid_p));
    
    reg [15:0]key_count;
    always@(posedge clk or posedge reset_p)begin
        if(reset_p) key_count = 0;
        else if(key_valid_p)begin
            if(key_value == 1)key_count = key_count + 1;
            else if(key_value == 2)key_count = key_count - 1;
            else if(key_value == 3)key_count = key_count + 2;
        end
    end
    
    assign key_valid = led_key_valid;

    keypad_Controller_FSM keypad(.clk(clk), .reset_p(reset_p), .row(row), .col(col),.key_value(key_value), .key_valid(key_valid));
    
    fnd_controller fnd(.clk(clk), .reset_p(reset_p), .value(key_count), .com(com), .seg_7(seg_7));
endmodule



module dht11_test_top(
    input clk, reset_p,
    inout dht11_data,
    output[3:0] com,
    output[7:0] seg_7,
    output[15:0]led_debug);
    
    wire[7:0] humidity, temperature;
    dht11_Controller dht(.clk(clk), .reset_p(reset_p), .dht11_data(dht11_data),. humidity(humidity), .temperature(temperature), .led_debug(led_debug));
    
    wire[15:0] humidity_bcd, temperature_bcd;
    bin_to_dec hum(.bin({4'b0, humidity}), .bcd(humidity_bcd));
    bin_to_dec tem(.bin({4'b0, temperature}), .bcd(temperature_bcd));
    
    wire[15:0]value;
    assign value = {humidity_bcd[7:0],temperature_bcd[7:0]};
    fnd_controller fnd(.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));
endmodule



module echo_test_top(
    input clk, reset_p,
    input echo,
    output trigger,
    output[3:0] com,
    output[7:0] seg_7,
    output[15:0]led_state);
    
    wire[21:0] distance;
    Echo_Controller_DownSlack echo_cntr(.clk(clk), .reset_p(reset_p),.echo(echo), .trigger(trigger),.distance(distance), .led_state(led_state));
    
    wire[11:0] distance_bcd;
    bin_to_dec bcd_to_dis(.bin(distance[11:0]), .bcd(distance_bcd));
    
    wire[15:0]value;
    assign value = distance_bcd;
    fnd_controller fnd(.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));
    
endmodule



module Watch_pj_top(
    //input, output, wire
    input clk, reset_p,
    input[3:0] btn,
    input alarm_button,
    output[3:0] com,
    output[7:0] seg_7,
    output led_timer_alarm,led_timer_start,led_sw_lap,led_sw_start, led_watch,
    output buzzuer);
    wire set_mode;
    wire[3:0] btn_mode_watch;
    wire[3:0] btn_mode_stopwatch;
    wire[3:0] btn_mode_timer;
    wire[2:0] mode;
    wire[3:0] watch_com,sw_com,tm_com;
    wire[7:0] watch_seg7,sw_seg7,tm_seg7;
    
    //mode change button, ringCounter
    button_Controller mode_btn(.clk(clk), .reset_p(reset_p),.btn(btn[0]), .btn_posedge(set_mode));
    ring_counter_3bit ring_inst(.clk(set_mode), .reset_p(reset_p),.q(mode));
  
    //3 watch instance module
    Loadable_watch_Project watch_inst(.clk(clk), .reset_p(reset_p), .btn(btn_mode_watch), 
                                      .com(watch_com),.seg_7(watch_seg7), .led_watch(led_watch));
                                                                        
    sec_stopwatch_Project sw_inst(.clk(clk), .reset_p(reset_p),.btn(btn_mode_stopwatch), 
                                  .com(sw_com),.seg_7(sw_seg7), .led_start(led_sw_start), .led_lap(led_sw_lap));
                                  
    cook_timer_Project tm_inst(.clk(clk), .reset_p(reset_p),.alarm_btn(alarm_button),.btn(btn_mode_timer),
                               .com(tm_com), .seg_7(tm_seg7),.led_alarm(led_timer_alarm), .led_start(led_timer_start),.buzz(buzzuer));
    
    //mux,demux 
    assign com = (mode==3'b001) ?  watch_com : ((mode==3'b010) ? sw_com : tm_com);
    assign seg_7 = (mode==3'b001) ?  watch_seg7 : ((mode==3'b010) ? sw_seg7 : tm_seg7);
    assign btn_mode_watch =     (mode==3'b001) ? btn : 0;
    assign btn_mode_stopwatch = (mode==3'b010) ? btn : 0;
    assign btn_mode_timer =     (mode==3'b100) ? btn : 0;

    
endmodule

module pwm_LED(
    input clk, reset_p,
    input[6:0] duty,
    output pwm,led_r,led_g,led_b);
    reg[31:0] clk_div;
    always@(posedge clk)clk_div = clk_div + 1;
    
    PWM_100s_128step pwm_inst(.clk(clk), .reset_p(reset_p), .duty(clk_div[25:19]), .pwm(pwm));
    
    PWM_Nstep_freq #(.duty_step(90)) pwm_r(.clk(clk), .reset_p(reset_p), .duty(clk_div[15:10]), .pwm(led_r));
    PWM_Nstep_freq #(.duty_step(90)) pwm_g(.clk(clk), .reset_p(reset_p), .duty(clk_div[25:20]), .pwm(led_g));
    PWM_Nstep_freq #(.duty_step(90)) pwm_b(.clk(clk), .reset_p(reset_p), .duty(clk_div[30:25]), .pwm(led_b));

endmodule


module DC_Motor_PWM_top(
    input clk, reset_p,
    output motor_pwm,
    output[3:0] com,
    output[7:0] seg_7);
    
    reg[31:0] clk_div;
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)clk_div = 0;
        else clk_div = clk_div + 1;
    end
    
    wire clk_div_26_negedge;
    edge_dectector_n ed_clk(.clk(clk), .reset_p(reset_p),.cp(clk_div[26]), .p_edge(clk_div_26_negedge));
    
    reg[5:0] duty;
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)duty = 20;
        else if(clk_div_26_negedge) begin
            if(duty >= 50) duty = 20;
            else duty = duty + 1;
        end
    end
    
    PWM_Nstep_freq #(
                .duty_step(100), 
                .pwm_freq(100)) 
    pwm_M(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm(motor_pwm));
    
    wire[15:0] duty_bcd;
    bin_to_dec bcd_to_dis_m(.bin({6'b0, duty}), .bcd(duty_bcd));
    
    fnd_controller fnd_m(.clk(clk), .reset_p(reset_p), .value(duty_bcd), .com(com), .seg_7(seg_7));

endmodule



module servo_PWM_top(
    input clk, reset_p,
    input [3:0] btn,
    output servo_pwm,
    output[3:0] com,
    output[7:0] seg_7);
    
    reg[31:0] clk_div;
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)clk_div = 0;
        else clk_div = clk_div + 1;
    end
    
    wire clk_div_negedge;
    edge_dectector_n ed_clk(.clk(clk), .reset_p(reset_p),.cp(clk_div[22]), .n_edge(clk_div_negedge));

    
    //button_Controller btn_1(.clk(clk), .reset_p(reset_p),.btn(btn[0]), .btn_posedge(clk_div_btn1));
    //button_Controller btn_2(.clk(clk), .reset_p(reset_p),.btn(btn[1]), .btn_posedge(clk_div_btn2));
    //button_Controller btn_3(.clk(clk), .reset_p(reset_p),.btn(btn[2]), .btn_posedge(clk_div_btn3));
    
    reg direction;
    reg[5:0] duty = 0;
//    always@(posedge clk or posedge reset_p)begin
//        if(reset_p)duty = 26;
//        else if(clk_div_btn1) duty = 9;
//       else if(clk_div_btn2) duty = 26;
//        else if(clk_div_btn3) duty = 46;    
//    end
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            duty = 9;
            direction = 0; // 0 is increrase duty direction, 1 is decrease duty direction
        end
        else if(clk_div_negedge)begin
            if(!direction)begin
                if(duty < 46) duty = duty + 1;
                else direction = 1;
            end
            else begin
                if(duty > 9)duty = duty - 1;
                else direction = 0;
            end
        end
    end
    
    PWM_Nstep_freq #(
                .duty_step(400), 
                .pwm_freq(50)) 
    pwm_Ser(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm(servo_pwm));
    
    wire[15:0] duty_bcd;
    bin_to_dec bcd_to_dis_S(.bin({6'b0, duty}), .bcd(duty_bcd));
    fnd_controller fnd_S(.clk(clk), .reset_p(reset_p), .value(duty_bcd), .com(com), .seg_7(seg_7));   
endmodule



module adc_ch6_top(
    input clk, reset_p,
    input vauxp6,vauxn6,
    output led_pwm,
    output[3:0] com,
    output[7:0] seg_7);
    
    wire[4:0] channel_out;
    wire[15:0] do_out;
    wire eoc_out;
    xadc_wiz_1 adc_6_15
          (
          .daddr_in({2'b0,channel_out}),             // Address bus for the dynamic reconfiguration port
          .dclk_in(clk),                             // Clock input for the dynamic reconfiguration port
          .den_in(eoc_out),                          // Enable Signal for the dynamic reconfiguration port         
          .reset_in(reset_p),                        // Reset signal for the System Monitor control logic
          .vauxp6(vauxp6),                                     // Auxiliary channel 6
          .vauxn6(vauxn6),
          .channel_out(channel_out),                                // Channel Selection Outputs
          .do_out(do_out),                                     // Output data bus for dynamic reconfiguration port
          .eoc_out(eoc_out)            // End of Conversion Signal
           );
          
           
    PWM_Nstep_freq #(
                .duty_step(256), 
                .pwm_freq(10000)) 
    pwm_backlight(.clk(clk), .reset_p(reset_p), .duty(do_out[15:8]), .pwm(led_pwm));
          
    wire[15:0] adc_value;
    bin_to_dec bcd_to_ADC(.bin({2'b0,do_out[15:6]}), .bcd(adc_value));
    fnd_controller fnd_ADC(.clk(clk), .reset_p(reset_p), .value(adc_value), .com(com), .seg_7(seg_7));   
endmodule


module adc_sequence2_top(
    input clk, reset_p,
    input vauxp6,vauxn6,vauxp15,vauxn15,
    output led_r, led_g,
    output[3:0] com,
    output[7:0] seg_7);
    
    wire[4:0] channel_out;
    wire[15:0] do_out;
    wire eoc_out;
    xadc_wiz_1 adc_6_15
          (
          .daddr_in({2'b0,channel_out}),             // Address bus for the dynamic reconfiguration port
          .dclk_in(clk),                             // Clock input for the dynamic reconfiguration port
          .den_in(eoc_out),                          // Enable Signal for the dynamic reconfiguration port         
          .reset_in(reset_p),                        // Reset signal for the System Monitor control logic
          .vauxp6(vauxp6),                                     // Auxiliary channel 6
          .vauxn6(vauxn6),
          .vauxp15(vauxp15),             // Auxiliary channel 15
          .vauxn15(vauxn15),
          .channel_out(channel_out),                                // Channel Selection Outputs
          .do_out(do_out),                                     // Output data bus for dynamic reconfiguration port
          .eoc_out(eoc_out)            // End of Conversion Signal
           );
    wire eoc_out_posedge;  
    edge_dectector_n ed_clk(.clk(clk), .reset_p(reset_p),.cp(eoc_out), .p_edge(eoc_out_posedge));
    
    reg[11:0] adc_value_x,adc_value_y;
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            adc_value_x = 0;
            adc_value_y = 0;
        end
        else if(eoc_out_posedge) begin
            case(channel_out[3:0])
                6:adc_value_x = do_out[15:4];
                15:adc_value_y = do_out[15:4];
            endcase
        end
    end 
    
    PWM_Nstep_freq #(
                .duty_step(256), 
                .pwm_freq(10000)) 
    pwm_red(.clk(clk), .reset_p(reset_p), .duty(adc_value_x[11:4]), .pwm(led_r));
    
    PWM_Nstep_freq #(
                .duty_step(256), 
                .pwm_freq(10000)) 
    pwm_green(.clk(clk), .reset_p(reset_p), .duty(adc_value_y[11:4]), .pwm(led_g));
    
    wire[15:0] bcd_x, bcd_y, value;
    bin_to_dec bcd_to_ADC_X(.bin({6'b0,adc_value_x[11:6]}), .bcd(bcd_x));
    bin_to_dec bcd_to_ADC_y(.bin({6'b0,adc_value_y[11:6]}), .bcd(bcd_y));
    
    assign value = {bcd_x[7:0], bcd_y[7:0]}; 
    fnd_controller fnd_ADC(.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));   
endmodule


module I2C_Master_top(
    input clk, reset_p,
    input[1:0] btn,
    output scl, sda,
    output[15:0] led);
    
    reg[7:0]data;
    reg comm_go; 
    
    wire[1:0]btn_pedge;
    button_Controller btn0(.clk(clk), .reset_p(reset_p),.btn(btn[0]), .btn_posedge(btn_pedge[0]));
    button_Controller btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]), .btn_posedge(btn_pedge[1]));
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            data = 0;
            comm_go = 0;
        end
        else begin
            if(btn_pedge[0])begin
                data = 8'b0000_0000;
                comm_go = 1;
            end
            else if(btn_pedge[1])begin
                data = 8'b0000_1000;
                comm_go = 1;
            end
            else comm_go = 0;
        end
    end
    
    
    I2C_Master(.clk(clk), .reset_p(reset_p), .addr(7'h27), .rd_wr(0), .data(data), .comm_go(comm_go), .scl(scl),.sda(sda), .led_debug(led));

endmodule




module I2C_txtLCD_top(
    input clk, reset_p,
    input[3:0] btn,
    output scl,sda,
    output[15:0]led);
    
    parameter IDLE = 6'b00_0001;
    parameter INIT = 6'b00_0010;
    parameter SEND_DATA = 6'b00_0100;
    parameter SEND_COMMAND_LINE_D = 6'b00_1000;
    parameter SEND_COMMAND_LINE_U = 6'b01_0000;
    parameter SEND_COMMAND_STRING = 6'b10_0000;
    
    wire clk_microsec;
    clock_div_100 microsec_clk(.clk(clk), .reset_p(reset_p),.clk_div_100_nedge(clk_microsec));
    
    reg[21:0] count_microsec;
    reg count_microsec_enable;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p) count_microsec = 0;
        else if(clk_microsec && count_microsec_enable) count_microsec = count_microsec + 1;
        else if(!count_microsec_enable)count_microsec = 0;
    end
    
    wire[3:0]btn_pedge;
    button_Controller btn0(.clk(clk), .reset_p(reset_p),.btn(btn[0]), .btn_posedge(btn_pedge[0]));
    button_Controller btn1(.clk(clk), .reset_p(reset_p),.btn(btn[1]), .btn_posedge(btn_pedge[1]));
    button_Controller btn2(.clk(clk), .reset_p(reset_p),.btn(btn[2]), .btn_posedge(btn_pedge[2]));
    button_Controller btn3(.clk(clk), .reset_p(reset_p),.btn(btn[3]), .btn_posedge(btn_pedge[3]));
    
    reg[7:0] send_buffer;
    reg rs,send;
    
    wire busy; 
    I2C_LCD_send_byte lcd(.clk(clk),.reset_p(reset_p), .addr(7'h27), .send_buffer(send_buffer),.rs(rs),.send(send),.scl(scl),.sda(sda), .busy(busy),.led(led));
    
    
    reg[5:0] state, next_state;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p) state = IDLE; 
        else state = next_state;
    end
    
    reg init_flag;
    reg[5:0] data_count;
    reg[8*14-1:0] init_word;
    reg[3:0] cnt_string;
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            next_state = IDLE;
            init_flag = 0;
            data_count = 0;
            count_microsec_enable = 0;
            init_word = "Enter Passward";
            cnt_string = 14;
        end
        else begin
            case(state)
                IDLE:begin
                    if(init_flag)begin
                        if(!busy)begin
                            if(btn_pedge[0]) next_state = SEND_DATA;
                            if(btn_pedge[1]) next_state = SEND_COMMAND_LINE_D;
                            if(btn_pedge[2]) next_state = SEND_COMMAND_LINE_U;
                            if(btn_pedge[3]) next_state = SEND_COMMAND_STRING;
                        end
                    end
                    else begin
                        if(count_microsec <= 22'd80_000)begin
                            count_microsec_enable = 1;
                        end
                        else begin
                            next_state = INIT;    
                            count_microsec_enable = 0;
                        end
                    end
                end
                INIT:begin
                     if(busy)begin
                        send = 0;
                        if(data_count > 21)begin
                            next_state = IDLE;
                            init_flag = 1;        
                            data_count = 0;    
                            rs = 0;     
                        end
                    end
                    else if(!send) begin //s
                        case(data_count)
                            0: send_buffer = 8'h33;
                            1: send_buffer = 8'h32;
                            2: send_buffer = 8'h28;
                            3: send_buffer = 8'h0F;
                            4: send_buffer = 8'h01;
                            5: send_buffer = 8'h06;
                            6: send_buffer =  init_word[111:104];
                            7: send_buffer =  init_word[103:96]; 
                            8: send_buffer =  init_word[95:88];  
                            9: send_buffer =  init_word[87:80];  
                            10: send_buffer = init_word[79:72];  
                            11: send_buffer = init_word[71:64];  
                            12: send_buffer = init_word[63:56];  
                            13: send_buffer = init_word[55:48];  
                            14: send_buffer = init_word[47:40];  
                            15: send_buffer = init_word[39:32];  
                            16: send_buffer = init_word[31:24];  
                            17: send_buffer = init_word[23:16];  
                            18: send_buffer = init_word[15:8];   
                            19: send_buffer = init_word[7:0];                             
                            20: send_buffer = 8'h06;                             
                            21: send_buffer = 8'hC0;                             
                        endcase
                        if(data_count <= 5) rs=0;
                        else if(data_count > 5 && data_count < 20)rs = 1;
                        else if(data_count > 19)rs = 0;
                        send = 1;
                        data_count = data_count + 1;
                    end
                end
                    SEND_DATA:begin
                    if(busy)begin
                        next_state = IDLE;
                        send = 0;
                        if(data_count >= 9) data_count = 0;
                        else data_count = data_count + 1;
                    end
                    else begin
                        send_buffer = "0" +data_count;
                        rs = 1;
                        send = 1;
                    end
                end
                SEND_COMMAND_LINE_D:begin
                    if(busy)begin
                        next_state = IDLE;
                        send = 0;
                        if(data_count >= 9) data_count = 0;
                        else data_count = data_count + 1;
                    end
                    else begin
                        send_buffer = 8'hC0;
                        rs = 0;
                        send = 1;
                    end 
                end
                SEND_COMMAND_LINE_U:begin
                    if(busy)begin
                        next_state = IDLE;
                        send = 0;
                        if(data_count >= 9) data_count = 0;
                        else data_count = data_count + 1;
                    end
                    else begin
                        send_buffer = 8'h80;
                        rs = 0;
                        send = 1;
                    end 
                end
                SEND_COMMAND_STRING:begin
                    if(busy)begin
                        send = 0;
                        if(cnt_string < 1)begin
                            next_state = IDLE;
                            cnt_string = 14;    
                        end
                    end
                    else if(!send) begin //s
                        case(cnt_string)
                            14: send_buffer = init_word[111:104];
                            13: send_buffer = init_word[103:96]; 
                            12: send_buffer = init_word[95:88];  
                            11: send_buffer = init_word[87:80];  
                            10: send_buffer = init_word[79:72];  
                            9: send_buffer =  init_word[71:64];  
                            8: send_buffer =  init_word[63:56];  
                            7: send_buffer =  init_word[55:48];  
                            6: send_buffer =  init_word[47:40];  
                            5: send_buffer =  init_word[39:32];  
                            4: send_buffer =  init_word[31:24];  
                            3: send_buffer =  init_word[23:16];  
                            2: send_buffer =  init_word[15:8];   
                            1: send_buffer =  init_word[7:0];    
                        endcase
                        rs = 1;
                        send = 1;
                        cnt_string = cnt_string - 1;
                    end
                end
            endcase
        end
    
    end
    
    
    
endmodule
