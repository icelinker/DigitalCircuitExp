`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/04/14 16:23:49
// Design Name: 
// Module Name: freq_meter
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


`timescale 1ns / 1ps
module freq_meter (CLK100MHZ, signal,seg,an,clk_out,sw,rst);
//======================= �����������������=======================//
    input rst;//ϵͳ��λ
    input CLK100MHZ; //��������ʱ��
    input signal; // �ⲿ����ʱ��
    input [7:0] sw;
    output reg [3:0]an;//LEDʹ��
    output reg [7:0]seg;//LED����
    output reg clk_out=0;//ʱ�����
    //�ڲ�����
    reg clk_1k=0;//1kHz��Ƶʱ��
    reg clk_1=0;//1Hz��Ƶʱ��
    reg [32:0]cnt=0 ;//��Ƶ������
    reg [2:0]cnt_d =0;//5ms������
    reg  [15:0] cnt_1=0 ;//1HZ��Ƶ����
    reg  [7:0] cnt_out=0 ;//1HZ��Ƶ����
    reg [1:0]pos; // ����LEDɨ����ʾ���Ƽ�����5ms*4  200Hz/4
    reg  [15:0]m;// ��Ƶ��������(�Զ�ʮ��λ)
    reg [15:0]digibuf; // �������(�Զ�ʮ��λ)
    reg [3:0] dispdat=0;
    reg gate=0;//�ſ�
    wire unsigned [15:0]digiBCD;//��λ
    wire signal_f;
    wire busy;
    // ע��������ʹ��100MHzʱ��Դ����Ƶֵ10kHz���˴���Ƶϵ��Ϊ'd50000 - 'd1
    // ����ʱ��Ϊ���÷����ٶȸ��죬ʹ��10kHzʱ��Դ�����˴�Ԥ��Ƶϵ����Ϊ'd5-'d1
    parameter pre_div = 'd50000 - 'd1; // ���ص���·ʱ���Ϊ��10k:5-1, 100M:50000-1
    assign signal_f=(sw>0)?clk_out:signal;//ѡ�������ź�sw>0ʱ��ʹ��SW����Ƶ�ʣ���������ⲿƵ��
    //assign signal_f=clk_out;//ѡ�������ź�
    //======================= ��Ƶ��=======================//
    // ������Ƶ��100M(10k) --> 1k , div = 5_0000(div = 5_0000)
    always @(posedge CLK100MHZ) 
    begin
        if (!rst) 
        begin
            if(cnt >= pre_div) 
            begin
                cnt <= 'd0;
                clk_1k <= ~clk_1k;
            end
            else cnt <= cnt + 1;
        end
        else 
        begin
            cnt<='d0;
            clk_1k<=0;
        end
    end
    //����LEDɨ����ʾ���Ƽ����� 20msɨ��4��LED��ÿ��LED 5ms,1k --> 5ms, div = 5
    always @(posedge clk_1k) 
    begin
        if (!rst) 
        begin
            if(cnt_d >= 4) 
            begin
                cnt_d <= 0;
                pos <= pos + 1'b1;
            end
            else cnt_d <= cnt_d + 1;
        end
        else 
        begin
           cnt_d<=0;
           pos<=0;
        end
    end
    // 1kz --> 1Hz, 1ms->500ms�� div = 500,���Ƽ������
    always @(posedge clk_1k ) 
    begin
        if (!rst) 
        begin
            if(cnt_1 >= 'd499) 
            begin
                cnt_1 <= 'd0;
                clk_1 <= ~clk_1;
            end
            else cnt_1 <= cnt_1 + 1;
        end
        else 
        begin
            cnt_1<=0;
            clk_1<=0;
        end
    end
    always @(posedge clk_1k ) 
    begin//����������sw[7:0]���õ�Ƶ��ʱ��
        if ((!rst) && (sw>=1)) 
        begin
            if(cnt_out >= (sw-1)) 
            begin
                cnt_out <= 'd0;
                clk_out <= ~clk_out;
            end
            else cnt_out <= cnt_out + 1'b1;
        end
        else 
        begin
            cnt_out<=0;
            clk_out<=0;
        end
    end 
    //======================= �����ͼ��㲿�� =======================//
    /** MUX
     *  ģ    ʽ: 0 ��Ƶ�� ͳ��1s��������   
     *  �ſ��ź�: clk_1      
     *  �����ź�: signal_f    
     */
    //�ſ��ź��л������ͼ���,1s����1s����
    //gate=1:����
    //gate=0:����
    always@(posedge clk_1 ) 
    begin
        if (!rst) gate<=~gate;
        else  gate<=0;
    end
    // clear and count
    always @(posedge signal_f or posedge rst) //rst �첽����
    if(rst)
    begin
    digibuf <=0;
    m<=0;
    end
    else 
    begin
        if(!gate)
        begin
            m<=0;
            digibuf <= digibuf;//digi_buf ����
         end
         else//gate �ߵ�ƽ����
         begin
            m <= m + 1'b1;
            digibuf <= m;//ˢ��digibuf
         end
    end
    //======================= ��ʾ =======================//
    //��ȡ��λ
    Bin2BCD bin2bcd_ins(.sys_clk(CLK100MHZ&(~gate)),
        .BinIn(digibuf),
        .BCD_out(digiBCD),
        .busy(busy),
        .rst(rst)
    );
    
    //ѡͨ
    always @(pos) 
    begin
        case(pos)
        0: begin an <= 4'b1110; dispdat[3:0] <= digiBCD[3:0];end
        1: begin an <= 4'b1101; dispdat[3:0] <= digiBCD[7:4];end
        2: begin an <= 4'b1011; dispdat[3:0] <= digiBCD[11:8];end
        3: begin an <= 4'b0111; dispdat[3:0] <= digiBCD[15:12];end
        default:begin an <= 4'b1110; dispdat[3:0] <= 0;end
        endcase
    end
    //����
    always @(dispdat)
    begin
        case (dispdat)
              4'h0: seg[6:0] = 7'b1000000;
              4'h1: seg[6:0] = 7'b1111001;
              4'h2: seg[6:0] = 7'b0100100;
              4'h3: seg[6:0] = 7'b0110000;
              4'h4: seg[6:0] = 7'b0011001;
              4'h5: seg[6:0] = 7'b0010010;
              4'h6: seg[6:0] = 7'b0000010;
              4'h7: seg[6:0] = 7'b1111000;
              4'h8: seg[6:0] = 7'b0000000;
              4'h9: seg[6:0] = 7'b0011000;
              default:seg[6:0] = 7'b1000000;
        endcase
    end
endmodule

