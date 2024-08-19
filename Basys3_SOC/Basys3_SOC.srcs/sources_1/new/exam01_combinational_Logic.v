`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/12 15:04:15
// Design Name: 
// Module Name: exam01_combinational_Logic
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

//모듈 선언시 모듈명 선언후 ()안에 입력과 출력을 선언. 이때 함수식 선언이 아닌 열거식. 컴마로만 이루어져 선언하고 마지막 (); 뒤에 콜론을 찍는다.
//모듈 선언이 끝나면 endmodule로 마무리한다.
module AND_Gate(
    output reg q,
    input a,b
    );
    //일반적인 case문과 다르다. case문은 endcase로 닫는다.
    always @(a,b)begin
         case({a,b})
             2'b00: q = 0;
             2'b01: q = 0;
             2'b10: q = 0;
             2'b11: q = 1;
        endcase
    end
    
endmodule



module Half_adder_structural(
    input a,b,
    output s,c);
//우리가 위에서 AND게이트를 만들었지만 원래 VIVADO툴에서 기본적인 불대수 식을 제공한다.
// 제공하는 논리식을 사용할 때 (출력, 입력,입력)순으로 작성해줘야한다.
//이때 우리가 모듈에서 선언한 입력과 출력을 사용할때 일반적으로는 .a(a)로 선언해도 되지만 그냥 a 로 작성해도 문제없다.
     and carry(c,a,b);
     xor(s,a,b);
endmodule

//always문을 사용하면 behavioral 모델이라 한다.
module Half_adder_behavioral(
    input a,b,
    output reg s,c);
    //always문은 begin으로 시작해 end로 끝난다.
     always@(a,b)begin
     //case문 안에 모든 경우의 수가 없을경우 default를 꼭 사용해서 경우의수를 만들어줘야한다.
     //위의 case 문과 다른점은 csae문 안에 내용이 2줄 이상이면 begin end 로 묶어줘야한다. c언어에서 if문 안에 한줄은 괄호를 안치듯이 verilog문 에서도 
     //위에서는 괄호를 생략한것이다.
        case({a,b})
            2'b00: begin s = 0; c =0; end // b는 binary라는 의미!! 2진수
            2'b01: begin s = 1; c =0; end
            2'b10: begin s = 1; c =0; end
            2'b11: begin s = 0; c =1; end
        endcase
     end
endmodule

//수식으로 처리하는 Half adder의 dataFlow ver. 
// 2bit 의 결과 sum_value를 wire로 선언.
//sumvalue라는 덧셈의 결과를 입력 a와 b의 덧셈으로 선언
//half_adder의 계산결과 s(sum)를 2bit으로 선언한 sum_value의 0번째 bit에 c(carry)를 1번째 비트에 출력되도록 설정.
module Half_adder_dataflow(
    input a,b,
    output s,c
);

    wire[1:0] sum_value;//1번 BIT 부터 2번 BIT까지 2bit를 선언한것.>> wire[1:0] 
                        // 2bit으로 이루어진 연결선 느낌.
    
    assign sumvalue = a + b;
    
    assign s = sum_value[0];
    assign c = sum_value[1];
    
endmodule


//  
module Full_adder_structural(
    input a,b,c,
    output sum, carry
);
    wire sum_0,carry_0,carry_1;
    Half_adder_structural ha0(.a(a),.b(b), .s(sum_0), .c(carry_0));
    Half_adder_structural ha1(.a(sum_0),.b(c), .s(sum), .c(carry_1));
    
    or(carry,carry_0,carry_1);
endmodule
    

module Full_adder_behavioral(
    input a,b,c,
    output reg sum, carry);
    
    always@(*)begin // * 의 의미는  변화가 생기면 always문 안에 input값 a,b,c에따라 sum과 carry의 값을 넣어줍니다.
        case({a,b,c})
            3'b000: begin sum = 0; carry = 0; end
            3'b001: begin sum = 1; carry = 0; end
            3'b010: begin sum = 1; carry = 0; end
            3'b011: begin sum = 0; carry = 1; end
            3'b100: begin sum = 1; carry = 0; end
            3'b101: begin sum = 0; carry = 1; end
            3'b110: begin sum = 0; carry = 1; end
            3'b111: begin sum = 1; carry = 1; end
            default: begin sum = 0; carry = 0; end
        endcase    
    end
endmodule
  
  
  
  
//assign 변수 선언은 어떻게 해도 상관없다 다만 wire에 선언한 변수는 wire로 선언했으므로 아래 연결된 wire를 사용해야
//연결이 되어 연산을 한다.
module Full_adder_DataFlow(
    input a,b,c,
    output  sum, carry);
    
    wire[1:0] sum_Value;
    
    assign sum_Value = a + b + c;
    
    assign sum = sum_Value[0]; 
    assign carry = sum_Value[1]; 
endmodule



//구조적 모델링을 하면 코드가 길어진다. 그래서 dataFlow 모델링을 사용.
module FA_4bits_structural(
    input [3:0]a,b,
    input cin,
    output[3:0] sum,
    output carry);
    
    wire [2:0] carry_w;
    
    Full_adder_structural fa0( .a(a[0]), .b(b[0]), .c(cin), .sum(sum[0]), .carry(carry_w[0]));
    Full_adder_structural fa1( .a(a[1]), .b(b[1]), .c(carry_w[0]), .sum(sum[1]), .carry(carry_w[1]));
    Full_adder_structural fa2( .a(a[2]), .b(b[2]), .c(carry_w[1]), .sum(sum[2]), .carry(carry_w[2]));
    Full_adder_structural fa3( .a(a[3]), .b(b[3]), .c(carry_w[2]), .sum(sum[3]), .carry(carry));
        
        
endmodule






module FA_4bits_dataFlow(
    input [3:0]a,b,
    input cin,
    output[3:0] sum, 
    output carry);
    
    wire[4:0] sum_Value;
    
    assign sum_Value = a + b + cin;
    
    assign sum = sum_Value[3:0]; 
    assign carry = sum_Value[4]; 
    
endmodule





module FA_8bits_Df(
    input [7:0] a, b,
    input cin,
    output [7:0] sum,
    output carry);
    
    wire[8:0] sum_Res;
    
    assign sum_Res = a + b +cin;
    
    assign sum = sum_Res[7:0];
    assign carry = sum_Res[8]; 
    
    
endmodule




module FA_Add_Sub(
    input [3:0] a,b,
    input sign,
    output[3:0] sum,
    output carry);
    
    wire [2:0] carry_w;
    wire [3:0] b_w;
    
    //전가산기의 b 연산을 xor로연산 >> 2의 보수로 만들어서 뺄셈연산을 하기위해서.
    xor(b_w[0], b[0],sign);
    xor(b_w[1], b[1],sign);
    xor(b_w[2], b[2],sign);
    xor(b_w[3], b[3],sign);
    
    Full_adder_structural fa0( .a(a[0]), .b(b_w[0]), .c(sign), .sum(sum[0]), .carry(carry_w[0]));
    Full_adder_structural fa1( .a(a[1]), .b(b_w[1]), .c(carry_w[0]), .sum(sum[1]), .carry(carry_w[1]));
    Full_adder_structural fa2( .a(a[2]), .b(b_w[2]), .c(carry_w[1]), .sum(sum[2]), .carry(carry_w[2]));
    Full_adder_structural fa3( .a(a[3]), .b(b_w[3]), .c(carry_w[2]), .sum(sum[3]), .carry(carry));
     
endmodule


module FA_AddSub_4bit_DataFlow(
    input [3:0] a,b,
    input sign,
    output [4:0] sum,
    output carry);
    
    wire[4:0] Ad_Sub_Res;
    
    assign Ad_Sub_Res = sign ? a-b : a+b; // 1 이면 참 , 0이면 거짓 1이면 a-b, 0이면  a+b
    assign sum = Ad_Sub_Res[3:0];
    assign carry = sign ? ~Ad_Sub_Res[4] : Ad_Sub_Res[4];//구조적 모델링과 결과를 맞추기위해서 4번째 비트를 반전시킴.
    

endmodule


module comperator_df(
    input a, b,
    output equal, greater, less);
    
    assign equal = (a==b) ? 1'b1: 1'b0;
    assign greater = (a>b) ? 1'b1: 1'b0;
    assign less = (a<b) ? 1'b1: 1'b0;
      
endmodule


//비교기는 비트수에 따라  parameter값을 변경하면 원하는 비트수의 비교기를 만들 수 있다.
module comperator #(parameter N = 8)(
    input[N-1:0] a, b, // 0~8번 비트부터 총 8개의 비트를 선언 a와 b 각각 4개의 입력이 존재.
    output equal, greater, less);
    
    assign equal = (a==b) ? 1'b1: 1'b0;
    assign greater = (a>b) ? 1'b1: 1'b0;
    assign less = (a<b) ? 1'b1: 1'b0;
      
endmodule



module comperator_n_bits_test(
    input[1:0] a,b,
    output eq, gr,le);
    
    //상위 모델 module comperator #(parameter N=8)의 입출력 모델의 변수를 선언한 순서대로 작성하면 다음과 같이 작성하묜된다.
    //순서를 무시한다면 .a(a), .b(b), .equal(eq) ... 와 같이 연결시켜줘야한다.
    //comperator #(.N(2)) comp_2bit( a,b,eq,gr,le); 
   comperator_n_bits_behavior #(.N(2)) comp_2bit (a,b,eq,gr,le);
endmodule

module comperator_n_bits_behavior #(parameter N = 8)(
    input[N-1:0] a,b,
    output reg eq, gr,le);
    
    always@(a,b)begin
        eq = 0;
        gr = 0;
        le = 0;
        if(a==b) 
            eq = 1;
        else if(a > b)
            gr = 1;
        else
            le = 1;
    end
endmodule



module decoder_2X4(
    input [1:0]code,
    output reg[3:0]signal);

//    always@(code)begin
//        if(code == 2'b00) signal = 4'b0001;
//        else if(code == 2'b01) signal = 4'b0010;
//        else if(code == 2'b10) signal = 4'b0100;
//        else if(code == 2'b11) signal = 4'b1000;
//    end
    
    always @ (code)begin
        case(code)
        2'b00 : signal = 4'b0001;
        2'b01 : signal = 4'b0010;
        2'b10 : signal = 4'b0100;
        2'b11 : signal = 4'b1000;
        default : signal = 4'b0001;
        endcase
    end
endmodule


module decoder_2X4_dataFlow(
    input [1:0]code,
    output[3:0]signal);
    
    assign signal = (code == 2'b00) ? 4'b0001 : 
                   ((code == 2'b01) ? 4'b0010 :
                   ((code == 2'b10) ? 4'b0100 : 4'b1000));
endmodule

module decoder_7seg(
    input [3:0] hex_value,
    output reg[7:0] seg_7);
    
    always@(hex_value)begin
        case(hex_value)
            //             abcd_efgp
            0 : seg_7 = 8'b0000_0011; //0
            1 : seg_7 = 8'b1001_1111; //1
            2 : seg_7 = 8'b0010_0101; //2
            3 : seg_7 = 8'b0000_1101; //3
            4 : seg_7 = 8'b1001_1001; //4
            5 : seg_7 = 8'b0100_1001; //5
            6 : seg_7 = 8'b0100_0001; //6
            7 : seg_7 = 8'b0001_1011; //7
            8 : seg_7 = 8'b0000_0000; //8
            9 : seg_7 = 8'b0000_1000; //9
            10 : seg_7 = 8'b0001_0000; //A
            11 : seg_7 = 8'b1100_0001; //B
            12 : seg_7 = 8'b1110_0101; //C
            13 : seg_7 = 8'b1000_0101; //D
            14 : seg_7 = 8'b0110_0001; //E
            15 : seg_7 = 8'b0111_0001; //F
        endcase
    end
endmodule


module encoder_4X2(
    input[3:0] signal,
    output reg[1:0] code);
    
//    always @(signal)begin
//        if(signal == 4'b0001) code = 2'b00;
//        else if(signal == 4'b0010) code = 2'b01;
//        else if(signal == 4'b0100) code = 2'b10;
//        else if(signal == 4'b1000) code = 2'b11;
//        else code = 2'b00;
//    end
    always @(signal)begin
        case(signal)
            4'b0001 : code = 2'b00;
            4'b0010 : code = 2'b01;
            4'b0100 : code = 2'b10;
            4'b1000 : code = 2'b11;
            default : code = 2'b00;
        endcase
    end 
endmodule



module encoder_4X2_dataflow(
    input [3:0] signal,
    output wire[1:0] code);
    
    assign code = (signal == 4'b0001) ? 2'b00 :
                 ((signal == 4'b0010) ? 2'b01 :
                 ((signal == 4'b0100) ? 2'b10 : 
                 ((signal == 4'b1000) ? 2'b11 : 2'b00)));
endmodule


module MUX_2in1(
    input[1:0]d,
    input s,
    output f);
    
    assign f = s ? d[1] : d[0]; // s = 0 >> d0 , s = 1 >> d1
    
endmodule

module MUX_4in1(
    input[3:0]d,
    input [1:0]s,
    output f);
    
    assign f = d[s];
    
endmodule

module MUX_8in1(
    input[7:0]d,
    input [3:0]s,
    output f);
    
    assign f = d[s];
    
endmodule


module DEMUX_1in4(
    input d,
    input[1:0] s,
    output[3:0] f);
    
    assign f = (s==2'b00) ? {3'd000,d} : 
              ((s==2'b01) ? {2'd00,d,1'b0} : 
              ((s==2'b10) ? {1'b0,d,2'b00} : {d,3'b000})); 
endmodule


module demux_1to4(
    input enable,
    input[1:0] s,
    output reg[3:0] f);
    
    always @* begin
        f = 0;
        f[s] = enable;
    end

endmodule

module mux_demux_test(
    input[3:0] d,
    input[1:0] mux_s, demux_s,
    output[3:0] f);
    
    wire line;
    
    MUX_4in1 mux (.d(d), .s(mux_s), .f(line));
    DEMUX_1in4 demux(.d(line), .s(demux_s), .f(f));
endmodule



module bin_to_dec(
        input [11:0] bin,
        output reg [15:0] bcd
    );

    reg [3:0] i;

    always @(bin) begin
        bcd = 0;
        for (i=0;i<12;i=i+1)begin
            bcd = {bcd[14:0], bin[11-i]};
            if(i < 11 && bcd[3:0] > 4) bcd[3:0] = bcd[3:0] + 3;
            if(i < 11 && bcd[7:4] > 4) bcd[7:4] = bcd[7:4] + 3;
            if(i < 11 && bcd[11:8] > 4) bcd[11:8] = bcd[11:8] + 3;
            if(i < 11 && bcd[15:12] > 4) bcd[15:12] = bcd[15:12] + 3;
        end
    end
endmodule

////////////////SL