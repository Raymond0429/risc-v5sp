/*
    注意事项:
    你可以把 alu_a 当成 x[rs1], 把 alu_b 当成 x[rs2], 把 alu_q 当成 x[rd]
    imm 为立即数, 在译码阶段已经为你拼接和扩展, 直接拿来用即可
    如果是访存指令, 那么 alu_q 输出访存地址
    如果是跳转指令且成功跳转, 你需要输出 jump_en = 1, 并输出正确的跳转地址 jump_addr
    跳转成功时还需要清空流水线, 故输出 clear_l1 和 clear_l2 = 1
    注意跳转指令 jal 比较特殊, 在译码阶段就已经确定跳转地址, 不需要你输出 jump_en = 1 和 jump_addr, 只需要执行 x[rd] = pc + 4
    注意压缩指令, 当出现压缩指令的 c.jal 和 c.jalr 时, x[rd] = pc + 2, 当指令为压缩指令时, ins_c = 1
*/

module Execute (
    input  wire [31:0] alu_a_l2,
    input  wire [31:0] alu_b_l2,
    input  wire [31:0] pc_l2,
    input  wire [31:0] imm_l2,
    input  wire        ins_c_l2,
    input  wire        ins_lui_l2,
    input  wire        ins_auipc_l2,
    input  wire        ins_jal_l2,
    input  wire        ins_jalr_l2,
    input  wire        ins_beq_l2,
    input  wire        ins_bne_l2,
    input  wire        ins_blt_l2,
    input  wire        ins_bge_l2,
    input  wire        ins_bltu_l2,
    input  wire        ins_bgeu_l2,
    input  wire        ins_lb_l2,
    input  wire        ins_lh_l2,
    input  wire        ins_lw_l2,
    input  wire        ins_lbu_l2,
    input  wire        ins_lhu_l2,
    input  wire        ins_sb_l2,
    input  wire        ins_sh_l2,
    input  wire        ins_sw_l2,
    input  wire        ins_addi_l2,
    input  wire        ins_slti_l2,
    input  wire        ins_sltiu_l2,
    input  wire        ins_xori_l2,
    input  wire        ins_ori_l2,
    input  wire        ins_andi_l2,
    input  wire        ins_slli_l2,
    input  wire        ins_srli_l2,
    input  wire        ins_srai_l2,
    input  wire        ins_add_l2,
    input  wire        ins_sub_l2,
    input  wire        ins_sll_l2,
    input  wire        ins_slt_l2,
    input  wire        ins_sltu_l2,
    input  wire        ins_xor_l2,
    input  wire        ins_srl_l2,
    input  wire        ins_sra_l2,
    input  wire        ins_or_l2,
    input  wire        ins_and_l2,
    output wire [31:0] alu_q_l2,
    output wire        jump_en_l2,
    output wire [31:0] jump_addr_l2,
    output wire clear_l1,
    output wire clear_l2

);


endmodule
