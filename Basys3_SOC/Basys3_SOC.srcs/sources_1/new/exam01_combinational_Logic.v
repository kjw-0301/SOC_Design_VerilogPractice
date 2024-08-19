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

//��� ����� ���� ������ ()�ȿ� �Է°� ����� ����. �̶� �Լ��� ������ �ƴ� ���Ž�. �ĸ��θ� �̷���� �����ϰ� ������ (); �ڿ� �ݷ��� ��´�.
//��� ������ ������ endmodule�� �������Ѵ�.
module AND_Gate(
    output reg q,
    input a,b
    );
    //�Ϲ����� case���� �ٸ���. case���� endcase�� �ݴ´�.
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
//�츮�� ������ AND����Ʈ�� ��������� ���� VIVADO������ �⺻���� �Ҵ�� ���� �����Ѵ�.
// �����ϴ� ������ ����� �� (���, �Է�,�Է�)������ �ۼ�������Ѵ�.
//�̶� �츮�� ��⿡�� ������ �Է°� ����� ����Ҷ� �Ϲ������δ� .a(a)�� �����ص� ������ �׳� a �� �ۼ��ص� ��������.
     and carry(c,a,b);
     xor(s,a,b);
endmodule

//always���� ����ϸ� behavioral ���̶� �Ѵ�.
module Half_adder_behavioral(
    input a,b,
    output reg s,c);
    //always���� begin���� ������ end�� ������.
     always@(a,b)begin
     //case�� �ȿ� ��� ����� ���� ������� default�� �� ����ؼ� ����Ǽ��� ���������Ѵ�.
     //���� case ���� �ٸ����� csae�� �ȿ� ������ 2�� �̻��̸� begin end �� ��������Ѵ�. c���� if�� �ȿ� ������ ��ȣ�� ��ġ���� verilog�� ������ 
     //�������� ��ȣ�� �����Ѱ��̴�.
        case({a,b})
            2'b00: begin s = 0; c =0; end // b�� binary��� �ǹ�!! 2����
            2'b01: begin s = 1; c =0; end
            2'b10: begin s = 1; c =0; end
            2'b11: begin s = 0; c =1; end
        endcase
     end
endmodule

//�������� ó���ϴ� Half adder�� dataFlow ver. 
// 2bit �� ��� sum_value�� wire�� ����.
//sumvalue��� ������ ����� �Է� a�� b�� �������� ����
//half_adder�� ����� s(sum)�� 2bit���� ������ sum_value�� 0��° bit�� c(carry)�� 1��° ��Ʈ�� ��µǵ��� ����.
module Half_adder_dataflow(
    input a,b,
    output s,c
);

    wire[1:0] sum_value;//1�� BIT ���� 2�� BIT���� 2bit�� �����Ѱ�.>> wire[1:0] 
                        // 2bit���� �̷���� ���ἱ ����.
    
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
    
    always@(*)begin // * �� �ǹ̴�  ��ȭ�� ����� always�� �ȿ� input�� a,b,c������ sum�� carry�� ���� �־��ݴϴ�.
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
  
  
  
  
//assign ���� ������ ��� �ص� ������� �ٸ� wire�� ������ ������ wire�� ���������Ƿ� �Ʒ� ����� wire�� ����ؾ�
//������ �Ǿ� ������ �Ѵ�.
module Full_adder_DataFlow(
    input a,b,c,
    output  sum, carry);
    
    wire[1:0] sum_Value;
    
    assign sum_Value = a + b + c;
    
    assign sum = sum_Value[0]; 
    assign carry = sum_Value[1]; 
endmodule



//������ �𵨸��� �ϸ� �ڵ尡 �������. �׷��� dataFlow �𵨸��� ���.
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
    
    //��������� b ������ xor�ο��� >> 2�� ������ ���� ���������� �ϱ����ؼ�.
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
    
    assign Ad_Sub_Res = sign ? a-b : a+b; // 1 �̸� �� , 0�̸� ���� 1�̸� a-b, 0�̸�  a+b
    assign sum = Ad_Sub_Res[3:0];
    assign carry = sign ? ~Ad_Sub_Res[4] : Ad_Sub_Res[4];//������ �𵨸��� ����� ���߱����ؼ� 4��° ��Ʈ�� ������Ŵ.
    

endmodule


module comperator_df(
    input a, b,
    output equal, greater, less);
    
    assign equal = (a==b) ? 1'b1: 1'b0;
    assign greater = (a>b) ? 1'b1: 1'b0;
    assign less = (a<b) ? 1'b1: 1'b0;
      
endmodule


//�񱳱�� ��Ʈ���� ����  parameter���� �����ϸ� ���ϴ� ��Ʈ���� �񱳱⸦ ���� �� �ִ�.
module comperator #(parameter N = 8)(
    input[N-1:0] a, b, // 0~8�� ��Ʈ���� �� 8���� ��Ʈ�� ���� a�� b ���� 4���� �Է��� ����.
    output equal, greater, less);
    
    assign equal = (a==b) ? 1'b1: 1'b0;
    assign greater = (a>b) ? 1'b1: 1'b0;
    assign less = (a<b) ? 1'b1: 1'b0;
      
endmodule



module comperator_n_bits_test(
    input[1:0] a,b,
    output eq, gr,le);
    
    //���� �� module comperator #(parameter N=8)�� ����� ���� ������ ������ ������� �ۼ��ϸ� ������ ���� �ۼ��Ϲ��ȴ�.
    //������ �����Ѵٸ� .a(a), .b(b), .equal(eq) ... �� ���� �����������Ѵ�.
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