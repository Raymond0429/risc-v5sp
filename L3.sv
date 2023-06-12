/*
    注意事项:
    rstn 表示 rst 取非
    当 block_l3 == 1 时, 所有寄存器保持原值
    当 rstn == 0 或 clear_l3 == 1 时, 所有寄存器清零
    其他情况 xxx_l3 = xxx_l2

    load_l3 = ins_lb_l3 || ins_lh_l3 || ins_lw_l3 

*/

module L3 (
    input  wire        clk,
    input  wire        rstn,
    input  wire        clear_l3,
    input  wire        block_l3,
    input  wire        ins_lb_l3,
    input  wire        ins_lh_l3,
    input  wire        ins_lw_l3,
    input  wire [ 4:0] rd_l2,
    input  wire [31:0] alu_q_l2,
    output reg  [ 4:0] rd_l3,
    output reg  [31:0] alu_q_l3,
    output reg         load_l3
);


endmodule
