`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/17 10:12:05
// Design Name: 
// Module Name: Controller
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

module fnd_controller(
    input clk, reset_p,
    input [15:0] value,
    output [3:0] com,
    output [7:0] seg_7);

     ring_counter_fnd rc(clk, reset_p, com);
    
    reg [3:0]hex_value;
    always@(posedge clk)begin
        case(com)
            4'b1110: hex_value = value[3:0];
            4'b1101: hex_value = value[7:4];
            4'b1011: hex_value = value[11:8];
            4'b0111: hex_value = value[15:12];
        endcase
    end
    
    decoder_7seg dec_7(.hex_value(hex_value), .seg_7(seg_7));
    //assign com = switch[3:0];
endmodule





module button_Controller(
    input clk, reset_p,
    input btn,
    output btn_posedge, btn_negedge);
    
     reg [20:0] clk_div = 0;
       always@(posedge clk)clk_div = clk_div+1;
    
     wire clk_div_nedge;
     edge_dectector_n ed_clk(.clk(clk), .reset_p(reset_p),.cp(clk_div[16]),.n_edge(clk_div_nedge));
     
     reg debounced_btn;
     always@(posedge clk or posedge reset_p)begin
        if(reset_p)debounced_btn = 0;
        else if(clk_div_nedge)debounced_btn = btn;
     end
     
     edge_dectector_n ed_btn(.clk(clk), .reset_p(reset_p),.cp(debounced_btn),.n_edge(btn_negedge),.p_edge(btn_posedge));
    
endmodule


module key_pad_controller(
    input clk, reset_p,
    input[3:0] row,
    output reg [3:0] col,
    output reg[3:0] key_value,    
    output reg key_valid);
    
    reg [19:0] clk_div;
    always@(posedge clk)clk_div = clk_div + 1;
    wire clk_8msec_p,clk_8msec_n; 
    edge_dectector_n ed_clk(.clk(clk), .reset_p(reset_p),.cp(clk_div[19]),.n_edge(clk_8msec_n), .p_edge(clk_8msec_p));
    
     always@(posedge clk or posedge reset_p)begin
        if(reset_p) col = 4'b0001;
        else if(clk_8msec_p && !key_valid) begin
            case(col)
                4'b0001 : col = 4'b0010;
                4'b0010 : col = 4'b0100;
                4'b0100 : col = 4'b1000;
                4'b1000 : col = 4'b0001;
                default: col = 4'b0001;
            endcase
        end
     end
     
     always@(posedge clk or posedge reset_p)begin
        if(reset_p) begin
            key_value = 0;
            key_valid = 0;
        end
        else begin
            if(clk_8msec_n)begin
                if(row)begin
                    key_valid = 1;
                    case({col,row})
                        8'b0001_0001: key_value = 4'h0;
                        8'b0001_0010: key_value = 4'h1;
                        8'b0001_0100: key_value = 4'h2;
                        8'b0001_1000: key_value = 4'h3;
                        8'b0010_0001: key_value = 4'h4;
                        8'b0010_0010: key_value = 4'h5;
                        8'b0010_0100: key_value = 4'h6;
                        8'b0010_1000: key_value = 4'h7;
                        8'b0100_0001: key_value = 4'h8;
                        8'b0100_0010: key_value = 4'h9;
                        8'b0100_0100: key_value = 4'ha;
                        8'b0100_1000: key_value = 4'hb;
                        8'b1000_0001: key_value = 4'hc;
                        8'b1000_0010: key_value = 4'hd;
                        8'b1000_0100: key_value = 4'he;
                        8'b1000_1000: key_value = 4'hf;
                        //default : 
                    
                    endcase
                end
                else begin
                    key_valid = 0;
                    key_value = 0;
                end    
            end
        end
     end
    
endmodule




module keypad_Controller_FSM(
    input clk, reset_p,
    input[3:0] row,
    output reg [3:0] col,
    output reg[3:0] key_value,    
    output reg key_valid);
    
    parameter SCAN0 =       5'b00001;
    parameter SCAN1 =       5'b00010;
    parameter SCAN2 =       5'b00100;
    parameter SCAN3 =       5'b01000;
    parameter KEY_PROCESS = 5'b10000;
    
    reg [19:0] clk_div;
    always@(posedge clk)clk_div = clk_div + 1;
    wire clk_8msec_p,clk_8msec_n; 
    edge_dectector_n ed_clk(.clk(clk), .reset_p(reset_p),.cp(clk_div[19]), .p_edge(clk_8msec_p), .n_edge(clk_8msec_n));
    
    reg [4:0] state, next_state;
    
    //SL
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)state = SCAN0;
        else if(clk_8msec_p)state = next_state;
    end
    
    //CL / FSM SCAN0~3, KEY_PROCESS
    always @* begin
        case(state)
            SCAN0: begin
                if(row == 0) next_state = SCAN1;
                else next_state =KEY_PROCESS;
            end
            SCAN1: begin
                if(row == 0) next_state = SCAN2;
                else next_state = KEY_PROCESS;
            end
            SCAN2: begin
                if(row == 0) next_state = SCAN3;
                else next_state = KEY_PROCESS;
            end
            SCAN3: begin
                if(row == 0) next_state = SCAN0;
                else next_state = KEY_PROCESS;
            end
            KEY_PROCESS: begin
                if(row == 0) next_state = SCAN0;
                else next_state = KEY_PROCESS;
            end
            default : next_state = SCAN0;
        endcase
    end
    
    
    always@(posedge clk or posedge reset_p) begin
        if(reset_p)begin
            key_value = 0;
            key_valid = 0;
            col = 0;
        end
        else if(clk_8msec_n)begin
            case(state)
                SCAN0:begin col = 4'b0001; key_valid = 0; key_value = 0;end
                SCAN1:begin col = 4'b0010; key_valid = 0; key_value = 0;end
                SCAN2:begin col = 4'b0100; key_valid = 0; key_value = 0;end
                SCAN3:begin col = 4'b1000; key_valid = 0; key_value = 0;end
                KEY_PROCESS:begin
                    key_valid = 1;
                    case({col,row})
                        8'b0001_0001: key_value = 4'h7;
                        8'b0001_0010: key_value = 4'h4;
                        8'b0001_0100: key_value = 4'h1;
                        8'b0001_1000: key_value = 4'hc;
                        8'b0010_0001: key_value = 4'h8;
                        8'b0010_0010: key_value = 4'h5;
                        8'b0010_0100: key_value = 4'h2;
                        8'b0010_1000: key_value = 4'h0;
                        8'b0100_0001: key_value = 4'h9;
                        8'b0100_0010: key_value = 4'h6;
                        8'b0100_0100: key_value = 4'h3;
                        8'b0100_1000: key_value = 4'hb;//+
                        8'b1000_0001: key_value = 4'ha;//-
                        8'b1000_0010: key_value = 4'hd;//*
                        8'b1000_0100: key_value = 4'he;// %
                        8'b1000_1000: key_value = 4'hf;// =
                        //default : 
                    endcase
                end
            endcase
        end
        
        
        
/*      else if(clk_8msec) begin
//            if(row)begin
//             key_valid = 1;
//                case({col,row})
//                    8'b0001_0001: key_value = 4'h0;
//                    8'b0001_0010: key_value = 4'h1;
//                    8'b0001_0100: key_value = 4'h2;
//                    8'b0001_1000: key_value = 4'h3;
//                    8'b0010_0001: key_value = 4'h4;
//                    8'b0010_0010: key_value = 4'h5;
//                    8'b0010_0100: key_value = 4'h6;
//                    8'b0010_1000: key_value = 4'h7;
//                    8'b0100_0001: key_value = 4'h8;
//                    8'b0100_0010: key_value = 4'h9;
//                    8'b0100_0100: key_value = 4'ha;
//                    8'b0100_1000: key_value = 4'hb;
//                    8'b1000_0001: key_value = 4'hc;
//                    8'b1000_0010: key_value = 4'hd;
//                    8'b1000_0100: key_value = 4'he;
//                    8'b1000_1000: key_value = 4'hf;
//                    //default :             
//                    endcase
//                end
//                else key_valid = 0;
//        end
//        else begin
//            case(state)
//                4'b0001 : col = 4'b0001;
//                4'b0010 : col = 4'b0010;
//                4'b0100 : col = 4'b0100;
//                4'b1000 : col = 4'b1000;
//            endcase
        end*/
        
    end
    
endmodule



module dht11_Controller(
    input clk, reset_p,
    inout dht11_data,
    output reg[7:0] humidity, temperature,
    output[15:0] led_debug);
    
    parameter S_IDLE = 6'b00_0001;
    parameter S_LOW_18MS = 6'b00_0010;
    parameter S_HIGH_20US = 6'b00_0100;
    parameter S_LOW_80US = 6'b00_1000;
    parameter S_HIGH_80US = 6'b01_0000;
    parameter S_READ_DATA = 6'b10_0000;
    
    parameter S_WAIT_POSEDGE = 2'b01;
    parameter S_WAIT_NEGEDGE = 2'b10;
    
    reg[5:0] state, next_state;
    reg[1:0] read_state;
    reg dht11_buffer;
    reg[39:0] temp_data;
    reg[5:0] data_count;
    
    assign led_debug[5:0] = state;

     wire clk_microsec;
    clock_div_100 microsec_clk(.clk(clk), .reset_p(reset_p),.clk_div_100_nedge(clk_microsec));
  
    reg[21:0] count_microsec;
    reg count_microsec_enable;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p) count_microsec = 0;
        else if(clk_microsec && count_microsec_enable) count_microsec = count_microsec + 1;
        else if(!count_microsec_enable)count_microsec = 0;
    end
    
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)state = S_IDLE;
        else state = next_state; 
    end
    assign dht11_data = dht11_buffer;

    wire dht_posedge, dht_negedge;
    edge_dectector_n ed_dht(.clk(clk), .reset_p(reset_p),.cp(dht11_data), .p_edge(dht_posedge), .n_edge(dht_negedge));
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            next_state = S_IDLE;
            read_state = S_WAIT_POSEDGE;
            temp_data = 0;
            data_count = 0;
        end
        else begin
            case(state)
                S_IDLE:begin
                    if(count_microsec < 22'd3_000_000)begin //22'd3_000_000
                        count_microsec_enable = 1;
                        dht11_buffer = 'bz;
                    end
                    else begin
                        count_microsec_enable = 0;
                        next_state = S_LOW_18MS;
                    end
                end
                S_LOW_18MS:begin
                    if(count_microsec < 22'd20_000)begin
                        dht11_buffer = 0;
                        count_microsec_enable = 1;
                    end
                    else begin 
                        count_microsec_enable = 0;
                        next_state = S_HIGH_20US;
                        dht11_buffer = 'bz;
                    end
                end
                S_HIGH_20US:begin
                    count_microsec_enable = 1;
                    if(count_microsec > 22'd100_000)begin
                        next_state = S_IDLE;
                        count_microsec_enable = 0;
                    end
                    else if(dht_negedge)begin
                        count_microsec_enable = 0;
                        next_state = S_LOW_80US;
                    end
                end
                S_LOW_80US:begin
                    count_microsec_enable = 1;
                    if(count_microsec > 22'd100_000)begin
                        next_state = S_IDLE;
                        count_microsec_enable = 0;
                    end
                    else if(dht_posedge)begin
                        next_state = S_HIGH_80US;
                        count_microsec_enable = 0;
                    end
                end
                S_HIGH_80US:begin
                    count_microsec_enable = 1;
                    if(count_microsec > 22'd100_000)begin
                        next_state = S_IDLE;
                        count_microsec_enable = 0;
                    end
                    else if(dht_negedge)begin
                        next_state = S_READ_DATA;
                        count_microsec_enable = 0;
                    end
                end
                S_READ_DATA:begin
                    count_microsec_enable = 1;
                    if(count_microsec > 22'd100_000)begin
                        next_state = S_IDLE;
                        count_microsec_enable = 0;
                        data_count = 0;
                        read_state = S_WAIT_POSEDGE;
                    end
                    else begin
                        case(read_state)
                            S_WAIT_POSEDGE:begin
                                if(dht_posedge)
                                    read_state = S_WAIT_NEGEDGE;
                                end
                            S_WAIT_NEGEDGE:begin
                                if(dht_negedge)begin
                                    if(count_microsec < 95)begin
                                        temp_data = {temp_data[38:0], 1'b0};
                                    end
                                    else begin
                                        temp_data = {temp_data[38:0], 1'b1};
                                    end
                                    data_count = data_count + 1;
                                    read_state = S_WAIT_POSEDGE;
                                    count_microsec_enable = 0;
                                end
                                else begin
                                    count_microsec_enable = 1;                           
                                end
                                end
                         endcase
                        if(data_count >= 40)begin
                            //data_count_temp = data_count;
                            data_count = 0;
                            next_state = S_IDLE;
                            read_state = S_WAIT_POSEDGE;
                            count_microsec_enable = 0;
                            if(temp_data[39:32] + temp_data[31:24] + temp_data[23:16] + temp_data[15:8] == temp_data[7:0])begin
                                humidity = temp_data[39:32];
                                temperature = temp_data[23:16];
                            end
                        end
                        end
                    end    
                endcase 
        end
    end
endmodule


module Echo_Controller(
    input clk, reset_p,
    input echo,
    output reg trigger,
    output reg[15:0] distance,
    output reg[15:0] led_state);
    
    parameter S_IDLE = 4'b0001;
    parameter S_TRIGGER = 4'b0010;
    parameter S_ECHO = 4'b0100;
    parameter S_CAL_DISTANCE = 4'b1000;
    
    reg[3:0] state, next_state;
    //assign led_state[3:0] = state;
    
    wire clk_microsec;
    clock_div_100 microsec_clk(.clk(clk), .reset_p(reset_p),.clk_div_100_nedge(clk_microsec));
    
    reg[21:0] count_microsec;
    reg count_microsec_enable;
    reg count_1us, count_dis;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p) count_microsec = 0;
        else if(clk_microsec && count_microsec_enable) count_microsec = count_microsec + 1;
        else if(!count_microsec_enable)count_microsec = 0;
    end
    
    wire echo_posedge, echo_negedge;
    edge_dectector_n ed_echo(.clk(clk), .reset_p(reset_p),.cp(echo), .p_edge(echo_posedge), .n_edge(echo_negedge));
    
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)state = S_IDLE;
        else state = next_state; 
    end
    //assign dht11_data = dht11_buffer;
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            next_state = S_IDLE;
            led_state = 0;
            trigger = 0;
            count_microsec_enable = 0;
        end
        else begin
            case(state)
                S_IDLE:begin
                    if(count_microsec < 22'd3_000_000)begin
                        count_microsec_enable = 1;
                        led_state[0] = 1;
                        count_1us = 0;
                        count_dis = 0;
                    end  
                    else begin
                        count_microsec_enable = 0;
                        led_state[1] = 1;
                        next_state = S_TRIGGER;
                    end
                end
                S_TRIGGER:begin
                    if(count_microsec < 22'd10)begin
                        trigger = 1;
                        count_microsec_enable = 1;
                        led_state[2] = 1;
                    end
                    else begin
                        next_state = S_ECHO;
                        count_microsec_enable = 0;
                        trigger = 0;
                        led_state[3] = 1;
                    end
                end
                S_ECHO:begin
                    led_state[4] = 1;
                    if(echo_posedge)begin
                        led_state[5] = 1;
                        next_state = S_CAL_DISTANCE;
                        count_microsec_enable = 1;
                    end
                end
                S_CAL_DISTANCE:begin
                    led_state[6] = 1;
                    if(echo_negedge)begin
                        distance = count_microsec / 22'd58;
                        count_microsec_enable = 0;
                        led_state[8] = 1;
                        next_state = S_IDLE;
                    end
                    else begin
                        count_microsec_enable = 1;
                        led_state[7] = 1;
                    end      
                end
                default:next_state =S_IDLE; 
            endcase
        end
    end 
endmodule


module Echo_Controller_DownSlack(
    input clk, reset_p,
    input echo,
    output reg trigger,
    output reg[15:0] distance,
    output reg[15:0] led_state);
    
    parameter S_IDLE = 4'b0001;
    parameter S_TRIGGER = 4'b0010;
    parameter S_ECHO = 4'b0100;
    parameter S_CAL_DISTANCE = 4'b1000;
    
    reg[3:0] state, next_state;
    //assign led_state[3:0] = state;
    
    wire clk_microsec;
    clock_div_100 microsec_clk(.clk(clk), .reset_p(reset_p),.clk_div_100_nedge(clk_microsec));
    
    reg cnt_enable;
    wire[11:0]cm;
    SR04_div_58 div58(.clk(clk), .reset_p(reset_p),.clk_microsec(clk_microsec),.cnt_enable(cnt_enable), .cm(cm));
    
    reg[21:0] count_microsec;
    reg count_microsec_enable;
    reg count_1us, count_dis;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p) count_microsec = 0;
        else if(clk_microsec && count_microsec_enable) count_microsec = count_microsec + 1;
        else if(!count_microsec_enable)count_microsec = 0;
    end
    
    wire echo_posedge, echo_negedge;
    edge_dectector_n ed_echo(.clk(clk), .reset_p(reset_p),.cp(echo), .p_edge(echo_posedge), .n_edge(echo_negedge));
    
    
    //reg[21:0] echo_time;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)state = S_IDLE;
        else state = next_state; 
    end
    //assign dht11_data = dht11_buffer;
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            next_state = S_IDLE;
            led_state = 0;
            trigger = 0;
            count_microsec_enable = 0;
            cnt_enable = 0;
        end
        else begin
            case(state)
                S_IDLE:begin
                    if(count_microsec < 22'd3_000_000)begin
                        count_microsec_enable = 1;
                        led_state[0] = 1;
                        count_1us = 0;
                        count_dis = 0;
                    end  
                    else begin
                        count_microsec_enable = 0;
                        led_state[1] = 1;
                        next_state = S_TRIGGER;
                    end
                end
                S_TRIGGER:begin
                    if(count_microsec < 22'd10)begin
                        trigger = 1;
                        count_microsec_enable = 1;
                        led_state[2] = 1;
                    end
                    else begin
                        next_state = S_ECHO;
                        count_microsec_enable = 0;
                        trigger = 0;
                        led_state[3] = 1;
                    end
                end
                S_ECHO:begin
                    led_state[4] = 1;
                    if(echo_posedge)begin
                        led_state[5] = 1;
                        next_state = S_CAL_DISTANCE;
                        //count_microsec_enable = 1;
                        cnt_enable = 1;
                    end
                end
                S_CAL_DISTANCE:begin
                    led_state[6] = 1;
                    if(echo_negedge)begin
                        distance = cm;
                        //echo_time = count_microsec;
                        cnt_enable = 0;
                        //count_microsec_enable = 0;
                        led_state[8] = 1;
                        next_state = S_IDLE;
                    end
                    else begin
                        cnt_enable = 1;
                        //count_microsec_enable = 1;
                        led_state[7] = 1;
                    end      
                end
                default:next_state =S_IDLE; 
            endcase
        end
    end 
    
    
//    always@(posedge clk or posedge reset_p)begin
//        if(reset_p) distance = 0;
//        else begin
//        if(echo_time < 174)distance = 2;
//        else if(echo_time < 232)distance = 3;
//        else if(echo_time < 290)distance = 4;
//        else if(echo_time < 348)distance = 5;
//        else if(echo_time < 406)distance = 6;
//        else if(echo_time < 464)distance = 7;
//        else if(echo_time < 522)distance = 8;
//        else if(echo_time < 580)distance = 9;
//        else if(echo_time < 638)distance = 10;
//        else if(echo_time < 696)distance = 11;
//        else if(echo_time < 754)distance = 12;
//        else if(echo_time < 812)distance = 13;
//        else if(echo_time < 870)distance = 14;
//        else if(echo_time < 928)distance = 15;
//        else if(echo_time < 986)distance = 16;
//        else if(echo_time < 1044)distance = 16;
//        else if(echo_time < 1102)distance = 17;
//        else if(echo_time < 1160)distance = 18;
//        else if(echo_time < 1218)distance = 19;
//        else if(echo_time < 1276)distance = 20;
//        else if(echo_time < 1334)distance = 21;
//        else if(echo_time < 1392)distance = 22;
//        else if(echo_time < 1450)distance = 23;
//        else if(echo_time < 1508)distance = 24;
//        else if(echo_time < 1566)distance = 25;
//        else if(echo_time < 1624)distance = 26;
//        else if(echo_time < 1682)distance = 27;
//        else if(echo_time < 1740)distance = 28;
//        else if(echo_time < 1798)distance = 29;
//        else if(echo_time < 1856)distance = 30;
//        else if(echo_time < 1914)distance = 31;
//        else if(echo_time < 1972)distance = 32;
//        else if(echo_time < 2030)distance = 33;
//        else if(echo_time < 2088)distance = 34;
//        else if(echo_time < 2146)distance = 35;
//        else if(echo_time < 2204)distance = 36;
//        else distance = 36;
//        end
//    end
    
endmodule



module PWM_100s_step(
    input clk, reset_p,
    input [6:0] duty,
    output pwm);
    
    //10ns * 100 = 1us
    reg [6:0] count_sysclk;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)count_sysclk = 0;
        else begin
            if(count_sysclk >= 99) count_sysclk  = 0;
            else count_sysclk = count_sysclk + 1;
        end
    end
    assign clk_div_100 = (count_sysclk < 50) ? 1 : 0;
    edge_dectector_n ed_sysclk(.clk(clk), .reset_p(reset_p),.cp(clk_div_100), .n_edge(clk_div_100_negedge));
    
    //1us 
    reg [6:0] count;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)count = 0;
        else if (clk_div_100_negedge)begin
            if(count >= 99) count  = 0;
            else count = count + 1;
        end
    end
    assign pwm = (count < duty) ? 1 : 0;
    
endmodule




module PWM_100s_128step(
    input clk, reset_p,
    input [6:0] duty,
    output pwm);
    
    parameter sys_clk_freq = 100_000_000;
    parameter pwm_freq = 10_000;
    parameter duty_step = 128;
    parameter temp = sys_clk_freq / duty_step / pwm_freq;
    parameter temp_half = temp / 2;
    
    //10ns * 100 = 1us
    reg [6:0] count_sysclk;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)count_sysclk = 0;
        else begin
            if(count_sysclk >= temp-1) count_sysclk  = 0;
            else count_sysclk = count_sysclk + 1;
        end
    end
    assign clk_div_100 = (count_sysclk < temp_half) ? 1 : 0;
    edge_dectector_n ed_sysclk(.clk(clk), .reset_p(reset_p),.cp(clk_div_100), .n_edge(clk_div_100_negedge));
    
    //1us 
    reg [7:0] count;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)count = 0;
        else if (clk_div_100_negedge)begin
             count = count + 1; //dutyrate 128 step.
        end
    end
    assign pwm = (count < duty) ? 1 : 0;
    
endmodule

module PWM_100step(
    input clk, reset_p,
    input [6:0] duty,
    output pwm);
    
    parameter sys_clk_freq = 100_000_000;
    parameter pwm_freq = 10_000;
    parameter duty_step = 100;
    parameter temp = sys_clk_freq / duty_step / pwm_freq;
    parameter temp_half = temp / 2;
    
    //10ns * 100 = 1us
    reg [6:0] count_sysclk;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)count_sysclk = 0;
        else begin
            if(count_sysclk >= temp-1) count_sysclk  = 0;
            else count_sysclk = count_sysclk + 1;
        end
    end
    
    
    assign pwm_freqX100 = (count_sysclk < temp_half) ? 1 : 0;
    wire pwm_freqX100_negedge;
    edge_dectector_n ed_sysclk(.clk(clk), .reset_p(reset_p),.cp(pwm_freqX100), .n_edge(pwm_freqX100_negedge));
    
    //1us 
    reg [6:0] count_duty;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)count_duty = 0;
        else if (pwm_freqX100_negedge)begin
            if(count_duty >= 99)count_duty = 0;
            else count_duty = count_duty + 1; //dutyrate 128 step.
        end
    end
    assign pwm = (count_duty < duty) ? 1 : 0;
    
endmodule


module PWM_Nstep_freq
    #(
        parameter sys_clk_freq = 100_000_000,
        parameter pwm_freq = 10_000,
        parameter duty_step = 100,
        parameter temp = sys_clk_freq / duty_step / pwm_freq,
        parameter temp_half = temp / 2)
    (
    input clk, reset_p,
    input [31:0] duty,
    output pwm);
    
    integer count_sysclk;
    wire clk_freqXstep;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)count_sysclk = 0;
        else begin
            if(count_sysclk >= temp-1) count_sysclk  = 0;
            else count_sysclk = count_sysclk + 1;
        end
    end
    
    
    assign clk_freqXstep = (count_sysclk < temp_half) ? 1 : 0;
    wire clk_freqXstep_negedge;
    edge_dectector_n ed_sysclk(.clk(clk), .reset_p(reset_p),.cp(clk_freqXstep), .n_edge(clk_freqXstep_negedge));
    

    integer count_duty;
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)count_duty = 0;
        else if (clk_freqXstep_negedge)begin
            if(count_duty >= (duty_step - 1))count_duty = 0;
            else count_duty = count_duty + 1; //dutyrate 128 step.
        end
    end
    assign pwm = (count_duty < duty) ? 1 : 0;
    
endmodule

