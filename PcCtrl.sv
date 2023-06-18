/*
    如果 ins_2bit_l0 == 11 那么就是非压缩指令, 否则就是压缩指令
    如果跳转使能 jump_en == 0, 那么根据是否是压缩指令, 判断 next_pc = pc_l0 + 4 还是 + 2
    如果跳转使能 jump_en == 1, 那么 next_pc = jump_addr
    如果 jump_en_l1 和 jump_en_l2 同时为1, 那么 next_pc = jump_addr_l2, 即 l2 更优先
    next_pc_add2 = next_pc + 2;
*/


module PcCtrl (
    input  wire        rstn,
    input  wire [ 1:0] ins_2bit_l0,
    input  wire [31:0] pc_l0,
    input  wire [31:0] jump_addr_l1,
    input  wire        jump_en_l1,
    input  wire [31:0] jump_addr_l2,
    input  wire        jump_en_l2,
    output wire [31:0] next_pc,
    output wire [31:0] next_pc_add2
);

    wire ins_c;

    assign ins_c        = !rstn ? 1'd0 : (ins_2bit_l0 != 2'b11);  //ins_c为高当前指令为压缩指令，为低当前指令为常规指令

    assign jump_en      = jump_en_l1 || jump_en_l2;  //跳转使能，l1，l2任意一个跳转都拉高

    assign next_pc      = !jump_en ? (ins_c ? pc_l0 + 2 : pc_l0 + 4) : (jump_en_l2 ? jump_addr_l2 : jump_addr_l1);

    assign next_pc_add2 = next_pc + 2;


endmodule
