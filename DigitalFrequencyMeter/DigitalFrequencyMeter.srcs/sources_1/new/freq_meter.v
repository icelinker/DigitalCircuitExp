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
//======================= 输入输出及变量声明=======================//
    input rst;//系统复位
    input CLK100MHZ; //板上输入时钟
    input signal; // 外部输入时钟
    input [7:0] sw;
    output reg [3:0]an;//LED使能
    output reg [7:0]seg;//LED段码
    output reg clk_out=0;//时钟输出
    //内部变量
    reg clk_1k=0;//1kHz分频时钟
    reg clk_1=0;//1Hz分频时钟
    reg [32:0]cnt=0 ;//分频计数器
    reg [2:0]cnt_d =0;//5ms计数器
    reg  [15:0] cnt_1=0 ;//1HZ分频计数
    reg  [7:0] cnt_out=0 ;//1HZ分频计数
    reg [1:0]pos; // 共阳LED扫描显示控制计数，5ms*4  200Hz/4
    reg  [15:0]m;// 测频法计数器(自动十进位)
    reg [15:0]digibuf; // 结果缓冲(自动十进位)
    reg [3:0] dispdat=0;
    reg gate=0;//门控
    wire unsigned [15:0]digiBCD;//个位
    wire signal_f;
    wire busy;
    // 注：板子上使用100MHz时钟源，分频值10kHz，此处分频系数为'd50000 - 'd1
    // 仿真时，为了让仿真速度更快，使用10kHz时钟源，将此处预分频系数改为'd5-'d1
    parameter pre_div = 'd50000 - 'd1; // 下载到电路时请改为：10k:5-1, 100M:50000-1
    assign signal_f=(sw>0)?clk_out:signal;//选择输入信号sw>0时候，使用SW配置频率，否则测量外部频率
    //assign signal_f=clk_out;//选择输入信号
    //======================= 分频器=======================//
    // 基础分频：100M(10k) --> 1k , div = 5_0000(div = 5_0000)
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
    //用于LED扫描显示控制计数： 20ms扫描4个LED，每个LED 5ms,1k --> 5ms, div = 5
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
    // 1kz --> 1Hz, 1ms->500ms， div = 500,控制计数间隔
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
    begin//产生周期由sw[7:0]配置的频率时钟
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
    //======================= 计数和计算部分 =======================//
    /** MUX
     *  模    式: 0 测频法 统计1s内脉冲数   
     *  门控信号: clk_1      
     *  计数信号: signal_f    
     */
    //门控信号切换计数和计算,1s计数1s计算
    //gate=1:计数
    //gate=0:计算
    always@(posedge clk_1 ) 
    begin
        if (!rst) gate<=~gate;
        else  gate<=0;
    end
    // clear and count
    always @(posedge signal_f or posedge rst) //rst 异步清零
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
            digibuf <= digibuf;//digi_buf 保持
         end
         else//gate 高电平计数
         begin
            m <= m + 1'b1;
            digibuf <= m;//刷新digibuf
         end
    end
    //======================= 显示 =======================//
    //提取各位
    Bin2BCD bin2bcd_ins(.sys_clk(CLK100MHZ&(~gate)),
        .BinIn(digibuf),
        .BCD_out(digiBCD),
        .busy(busy),
        .rst(rst)
    );
    
    //选通
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
    //译码
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

