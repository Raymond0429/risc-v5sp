/*
    做一个内存控制器, 控制4个8bit位宽的ram, 责任重大哟
    可用内存的总大小是2048, 映射到地址范围是0~2047
    外设总线寄存器的地址映射到
    pbus_addr - 65536, 可读可写
    pbus_wdata - 65537, 可读可写
    pbus_rdata - 65538, 只读
    对这些内存地址进行读写, 相当于在读写寄存器
    如果出现非法的地址, 即地址不在映射区域中, 则读取结果为0, 写入无效

    rstn 表示 rst 取非, 当 rstn == 0 或 clear_l3 == 1 时, 所有寄存器清零
*/


module DataRamCtrl (
    input  wire        clk,
    input  wire        rstn,
    input  wire        clear_l3,
    input  wire [31:0] alu_q_l2,      //访存地址
    input  wire [31:0] xrs2_l2,       //要写入内存的数据
    input  wire [31:0] pbus_rdata,    //从外设总线读取到的数据
    input  wire        ins_lb_l2,
    input  wire        ins_lh_l2,
    input  wire        ins_lw_l2,
    input  wire        ins_lbu_l2,
    input  wire        ins_lhu_l2,
    input  wire        ins_sb_l2,
    input  wire        ins_sh_l2,
    input  wire        ins_sw_l2,
    output wire [31:0] ram_rdata_l3,
    output reg  [31:0] pbus_addr,     //外设总线地址, 尚不确定有多少外设, 位宽先按32处理
    output reg  [31:0] pbus_wdata     //要写入外设的数据

);

    parameter addr_width = 9;

    wire                    wea_0;
    wire                    wea_1;
    wire                    wea_2;
    wire                    wea_3;

    wire [addr_width - 1:0] addr_0;
    wire [addr_width - 1:0] addr_1;
    wire [addr_width - 1:0] addr_2;
    wire [addr_width - 1:0] addr_3;

    wire [             7:0] din_0;
    wire [             7:0] din_1;
    wire [             7:0] din_2;
    wire [             7:0] din_3;

    wire [             7:0] dout_0;
    wire [             7:0] dout_1;
    wire [             7:0] dout_2;
    wire [             7:0] dout_3;

    //每个ram都是1字节为一个单元, 大小为512字节, 共4个ram, 这样一次访存刚好是32位
    //ram可以调用IP核, 不需要我们实现
    ram ram0 (
        clk,
        1'd1,
        wea_0,  //写使能
        addr_0,  //每个ram的大小是512字节, 故addr有9位
        din_0,  //要写入的数据
        dout_0  //读取出来的数据
    );
    ram ram1 (
        clk,
        1'd1,
        wea_1,
        addr_1,
        din_1,
        dout_1
    );
    ram ram2 (
        clk,
        1'd1,
        wea_2,
        addr_2,
        din_2,
        dout_2
    );
    ram ram3 (
        clk,
        1'd1,
        wea_3,
        addr_3,
        din_3,
        dout_3
    );

endmodule
