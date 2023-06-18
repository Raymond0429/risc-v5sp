/*
    注意事项:
    把压缩指令集翻译成标准指令集
    ins 为传入的指令, 如果是压缩指令, 你只需要对低16位进行解码, 无视掉高16位
    jal 在译码阶段就确定跳转地址, 但x[rd] = pc + 4 或 + 2 这个操作还需要甩给执行阶段
    当译码到 jal 指令时, 得出正确的跳转地址 jump_addr_l1 并使 jump_en_l1 = 1, 并输出 clear_l1 = 1, 以清空流水线 l1

    当指令为压缩指令时, ins_c = 1 
*/

module Decode (
    input  logic [31:0] ins_l1,
    input  logic [31:0] pc_l1,
    output logic [31:0] imm_l1,
    output logic [ 4:0] rd_l1,
    output logic [ 4:0] rs1_l1,
    output logic [ 4:0] rs2_l1,
    output logic        clear_l1,
    output logic [31:0] jump_addr_l1,
    output logic        jump_en_l1,
    output logic        ins_c_l1,
    output logic        ins_lui_l1,
    output logic        ins_auipc_l1,
    output logic        ins_jal_l1,
    output logic        ins_jalr_l1,
    output logic        ins_beq_l1,
    output logic        ins_bne_l1,
    output logic        ins_blt_l1,
    output logic        ins_bge_l1,
    output logic        ins_bltu_l1,
    output logic        ins_bgeu_l1,
    output logic        ins_lb_l1,
    output logic        ins_lh_l1,
    output logic        ins_lw_l1,
    output logic        ins_lbu_l1,
    output logic        ins_lhu_l1,
    output logic        ins_sb_l1,
    output logic        ins_sh_l1,
    output logic        ins_sw_l1,
    output logic        ins_addi_l1,
    output logic        ins_slti_l1,
    output logic        ins_sltiu_l1,
    output logic        ins_xori_l1,
    output logic        ins_ori_l1,
    output logic        ins_andi_l1,
    output logic        ins_slli_l1,
    output logic        ins_srli_l1,
    output logic        ins_srai_l1,
    output logic        ins_add_l1,
    output logic        ins_sub_l1,
    output logic        ins_sll_l1,
    output logic        ins_slt_l1,
    output logic        ins_sltu_l1,
    output logic        ins_xor_l1,
    output logic        ins_srl_l1,
    output logic        ins_sra_l1,
    output logic        ins_or_l1,
    output logic        ins_and_l1
);

    wire [1:0] c_opcode = ins_l1[1:0];
    assign ins_c_l1 = c_opcode != 2'b11;

    wire [6:0] opcode = ins_l1[6:0];
    wire [2:0] funct3 = ins_l1[14:12];
    wire [6:0] funct7 = ins_l1[31:25];

    wire has_rd;

    wire [4:0] rd = has_rd ? ins_l1[11:7] : 5'd0;
    wire [4:0] rs1 = ins_l1[19:15];
    wire [4:0] rs2 = ins_l1[24:20];

    wire funct3_000 = funct3 == 3'b000;
    wire funct3_001 = funct3 == 3'b001;
    wire funct3_010 = funct3 == 3'b010;
    wire funct3_011 = funct3 == 3'b011;
    wire funct3_100 = funct3 == 3'b100;
    wire funct3_101 = funct3 == 3'b101;
    wire funct3_110 = funct3 == 3'b110;
    wire funct3_111 = funct3 == 3'b111;

    wire funct7_00 = funct7 == 7'b0000000;
    wire funct7_01 = funct7 == 7'b0100000;

    wire ins_lui = opcode == 7'b0110111;
    wire ins_auipc = opcode == 7'b0010111;
    wire type_u = ins_lui || ins_auipc;

    wire ins_jal = opcode == 7'b1101111;
    wire type_uj = ins_jal;

    wire ins_jalr = opcode == 7'b1100111;
    wire type_i_jalr = ins_jalr;

    wire type_sb = opcode == 7'b1100011;
    wire ins_beq = type_sb && funct3_000;
    wire ins_bne = type_sb && funct3_001;
    wire ins_blt = type_sb && funct3_100;
    wire ins_bge = type_sb && funct3_101;
    wire ins_bltu = type_sb && funct3_110;
    wire ins_bgeu = type_sb && funct3_111;

    wire type_i_ld = opcode == 7'b0000011;
    wire ins_lb = type_i_ld && funct3_000;
    wire ins_lh = type_i_ld && funct3_001;
    wire ins_lw = type_i_ld && funct3_010;
    wire ins_lbu = type_i_ld && funct3_100;
    wire ins_lhu = type_i_ld && funct3_101;

    wire type_s = opcode == 7'b0100011;
    wire ins_sb = type_s && funct3_000;
    wire ins_sh = type_s && funct3_001;
    wire ins_sw = type_s && funct3_010;

    wire type_i_ai = opcode == 7'b0010011;
    wire type_i = type_i_jalr || type_i_ld || type_i_ai;
    wire ins_addi = type_i_ai && funct3_000;
    wire ins_slti = type_i_ai && funct3_010;
    wire ins_sltiu = type_i_ai && funct3_011;
    wire ins_xori = type_i_ai && funct3_100;
    wire ins_ori = type_i_ai && funct3_110;
    wire ins_andi = type_i_ai && funct3_111;
    wire ins_slli = type_i_ai && funct3_001 && funct7_00;
    wire ins_srli = type_i_ai && funct3_101 && funct7_00;
    wire ins_srai = type_i_ai && funct3_101 && funct7_01;

    wire type_r = opcode == 7'b0110011;
    wire ins_add = type_r && funct3_000 && funct7_00;
    wire ins_sub = type_r && funct3_000 && funct7_01;
    wire ins_sll = type_r && funct3_001 && funct7_00;
    wire ins_slt = type_r && funct3_010 && funct7_00;
    wire ins_sltu = type_r && funct3_011 && funct7_00;
    wire ins_xor = type_r && funct3_100 && funct7_00;
    wire ins_srl = type_r && funct3_101 && funct7_00;
    wire ins_sra = type_r && funct3_101 && funct7_01;
    wire ins_or = type_r && funct3_110 && funct7_00;
    wire ins_and = type_r && funct3_111 && funct7_00;

    wire [31:0] imm =
        (type_i                             ? {{20{ins_l1[31]}}, ins_l1[31:20]}                                             : 32'd0) |
        (type_s                             ? {{20{ins_l1[31]}}, ins_l1[31:25], ins_l1[11:7]}                               : 32'd0) |
        (type_sb                            ? {{19{ins_l1[31]}}, ins_l1[31], ins_l1[7], ins_l1[30:25], ins_l1[11:8], 1'b0}  : 32'd0) |
        (type_u                             ? {ins_l1[31:12], 12'd0}                                                        : 32'd0) |
        (type_uj                            ? {{11{ins_l1[31]}}, ins_l1[31], ins_l1[19:12], ins_l1[20], ins_l1[30:21], 1'b0}: 32'd0) |
        ((ins_srli || ins_srai || ins_slli) ? {27'd0, ins_l1[24:20]}                                                        : 32'd0)
    ;

    assign has_rd = type_r || type_i || type_u || type_uj;

    //压缩指令译码

    wire c_opcode_00 = c_opcode == 2'b00;
    wire c_opcode_01 = c_opcode == 2'b01;
    wire c_opcode_10 = c_opcode == 2'b10;

    wire [1:0] cs_funct2 = ins_l1[6:5];
    wire [1:0] cb_funct2 = ins_l1[11:10];
    wire [2:0] c_funct3 = ins_l1[15:13];

    wire c_funct3_000 = c_funct3 == 3'b000;
    wire c_funct3_001 = c_funct3 == 3'b001;
    wire c_funct3_010 = c_funct3 == 3'b010;
    wire c_funct3_011 = c_funct3 == 3'b011;
    wire c_funct3_100 = c_funct3 == 3'b100;
    wire c_funct3_101 = c_funct3 == 3'b101;
    wire c_funct3_110 = c_funct3 == 3'b110;
    wire c_funct3_111 = c_funct3 == 3'b111;

    wire cb_funct2_00 = cb_funct2 == 2'b00;
    wire cb_funct2_01 = cb_funct2 == 2'b01;
    wire cb_funct2_10 = cb_funct2 == 2'b10;
    wire cb_funct2_11 = cb_funct2 == 2'b11;

    wire c_funct6_100011 = c_funct3_100 && ins_l1[12:10] == 3'b011;

    wire cs_funct2_00 = cs_funct2 == 2'b00;
    wire cs_funct2_01 = cs_funct2 == 2'b01;
    wire cs_funct2_10 = cs_funct2 == 2'b10;
    wire cs_funct2_11 = cs_funct2 == 2'b11;

    wire c_funct4_1000 = c_funct3_100 && ins_l1[12] == 1'd0;
    wire c_funct4_1001 = c_funct3_100 && ins_l1[12] == 1'd1;

    wire c_ins_lw = c_opcode_00 && c_funct3_010;
    wire type_cl = c_ins_lw;

    wire c_ins_sw = c_opcode_00 && c_funct3_110;
    wire c_ins_and_or_xor_sub = c_opcode_01 && c_funct6_100011;
    wire c_ins_and = c_ins_and_or_xor_sub && cs_funct2_11;
    wire c_ins_or = c_ins_and_or_xor_sub && cs_funct2_10;
    wire c_ins_xor = c_ins_and_or_xor_sub && cs_funct2_01;
    wire c_ins_sub = c_ins_and_or_xor_sub && cs_funct2_00;
    wire type_cs = c_ins_sw || c_ins_and_or_xor_sub;

    wire c_ins_j = c_opcode_01 && c_funct3_101;
    wire c_ins_jal = c_opcode_01 && c_funct3_001;
    wire type_cj = c_ins_j || c_ins_jal;

    wire c_ins_beqz = c_opcode_01 && c_funct3_110;
    wire c_ins_bneqz = c_opcode_01 && c_funct3_111;
    wire c_ins_srli = c_opcode_01 && c_funct3_100 && cb_funct2_00;
    wire c_ins_srai = c_opcode_01 && c_funct3_100 && cb_funct2_01;
    wire c_ins_andi = c_opcode_01 && c_funct3_100 && cb_funct2_10;
    wire type_cb = c_ins_beqz || c_ins_bneqz || c_ins_srli || c_ins_srai || c_ins_andi;

    wire c_ins_lwsp = c_opcode_10 && c_funct3_010;
    wire c_ins_li = c_opcode_01 && c_funct3_010;
    wire c_ins_lui_addi16sp = c_opcode_01 && c_funct3_011;
    wire c_rd_eq_2 = ins_l1[11:7] == 5'd2;
    wire c_ins_lui = c_ins_lui_addi16sp && !c_rd_eq_2;
    wire c_ins_addi = c_opcode_01 && c_funct3_000;
    wire c_ins_addi16sp = c_ins_lui_addi16sp && c_rd_eq_2;
    wire c_ins_slli = c_opcode_10 && c_funct3_000;
    wire type_ci = c_ins_lwsp || c_ins_li || c_ins_lui_addi16sp || c_ins_addi || c_ins_slli;

    wire c_ins_addi4spn = c_opcode_00 && c_funct3_000;
    wire type_ciw = c_ins_addi4spn;

    wire c_ins_swsp = c_opcode_10 && c_funct3_110;
    wire type_css = c_ins_swsp;

    wire c_ins_jr_mv = c_opcode_10 && c_funct4_1000;
    wire c_ins_jalr_add = c_opcode_10 && c_funct4_1001;
    wire c_rs2_eq_0 = ins_l1[6:2] == 5'd0;
    wire c_ins_jr = c_ins_jr_mv && c_rs2_eq_0;
    wire c_ins_mv = c_ins_jr_mv && !c_rs2_eq_0;
    wire c_ins_jalr = c_ins_jalr_add && c_rs2_eq_0;
    wire c_ins_add = c_ins_jalr_add && !c_rs2_eq_0;
    wire type_cr = c_ins_jr_mv || c_ins_jalr_add;

    wire [4:0] c_rd =
        ((c_ins_jal || c_ins_jalr)                                          ? 5'd1                  : 5'd0) |
        (((type_cr && !c_ins_jr && !c_ins_jalr) || type_ci)                 ? ins_l1[11:7]          : 5'd0) |
        ((type_ciw || type_cl)                                              ? {2'b01, ins_l1[4:2]}  : 5'd0) |
        (((type_cs && !c_ins_sw) || c_ins_slli || c_ins_srli || c_ins_srai) ? {2'b01, ins_l1[9:7]}  : 5'd0)
    ;

    wire [4:0] c_rs1 =
        ((type_cr && !c_ins_mv)                ? ins_l1[11:7]          : 5'd0) |
        ((c_ins_lwsp || type_css || type_ciw)  ? 5'd2                  : 5'd0) |
        ((type_ci && !c_ins_lwsp && !c_ins_li) ? ins_l1[11:7]          : 5'd0) |
        ((type_cl || type_cs || type_cb)       ? {2'b01, ins_l1[9:7]}  : 5'd0)
    ;

    wire [4:0] c_rs2 =  
        ((c_ins_mv || c_ins_add)  ? ins_l1[6:2]           : 5'd0) |
        (type_css                 ? ins_l1[6:2]           : 5'd0) |
        (type_cs                  ? {2'b01, ins_l1[4:2]}  : 5'd0)
    ;
    wire [31:0] c_imm =  
        (c_ins_lwsp                                ? {24'd0, ins_l1[3:2], ins_l1[12], ins_l1[6:4], 2'b00}                                                                      : 32'd0) |  
        ((c_ins_li || c_ins_addi || c_ins_andi)    ? {{26{ins_l1[12]}}, ins_l1[12], ins_l1[6:2]}                                                                               : 32'd0) |  
        (c_ins_lui                                 ? {{14{ins_l1[12]}}, ins_l1[12], ins_l1[6:2], 12'd0}                                                                        : 32'd0) |  
        (c_ins_addi16sp                            ? {{22{ins_l1[12]}}, ins_l1[12], ins_l1[4:3], ins_l1[5], ins_l1[2], ins_l1[6], 4'd0}                                        : 32'd0) |  
        ((c_ins_slli || c_ins_srli || c_ins_srai)  ? {26'd0, ins_l1[12], ins_l1[6:2]}                                                                                          : 32'd0) |  
        (type_css                                  ? {24'd0, ins_l1[8:7], ins_l1[12:9], 2'b00}                                                                                 : 32'd0) |  
        (type_ciw                                  ? {22'd0, ins_l1[10:7], ins_l1[12:11], ins_l1[5], ins_l1[6], 2'b0}                                                          : 32'd0) |  
        ((type_cl || c_ins_sw)                     ? {25'd0, ins_l1[5], ins_l1[12:10], ins_l1[6], 2'b0}                                                                        : 32'd0) |  
        ((c_ins_beqz || c_ins_bneqz)               ? {{23{ins_l1[12]}}, ins_l1[12], ins_l1[6:5], ins_l1[2], ins_l1[11:10], ins_l1[4:3], 1'd0}                                  : 32'd0) |  
        ((c_ins_j || c_ins_jal)                    ? {{20{ins_l1[12]}}, ins_l1[12], ins_l1[8], ins_l1[10:9], ins_l1[6], ins_l1[7], ins_l1[2], ins_l1[11], ins_l1[5:3], 1'd0}   : 32'd0)
    ;

    assign jump_en_l1   = ins_jal_l1;
    assign clear_l1     = ins_jal_l1;
    assign jump_addr_l1 = pc_l1 + imm_l1;

    assign imm_l1       = ins_c_l1 ? c_imm : imm;
    assign rd_l1        = ins_c_l1 ? c_rd : rd;
    assign rs1_l1       = ins_c_l1 ? c_rs1 : rs1;
    assign rs2_l1       = ins_c_l1 ? c_rs2 : rs2;

    assign ins_lui_l1   = ins_lui || c_ins_lui;
    assign ins_auipc_l1 = ins_auipc;
    assign ins_jal_l1   = ins_jal || c_ins_j || c_ins_jal;
    assign ins_jalr_l1  = ins_jalr || c_ins_jr || c_ins_jalr;
    assign ins_beq_l1   = ins_beq || c_ins_beqz;
    assign ins_bne_l1   = ins_bne || c_ins_bneqz;
    assign ins_blt_l1   = ins_blt;
    assign ins_bge_l1   = ins_bge;
    assign ins_bltu_l1  = ins_bltu;
    assign ins_bgeu_l1  = ins_bgeu;
    assign ins_lb_l1    = ins_lb;
    assign ins_lh_l1    = ins_lh;
    assign ins_lw_l1    = ins_lw || c_ins_lwsp || c_ins_lw;
    assign ins_lbu_l1   = ins_lbu;
    assign ins_lhu_l1   = ins_lhu;
    assign ins_sb_l1    = ins_sb;
    assign ins_sh_l1    = ins_sh;
    assign ins_sw_l1    = ins_sw || c_ins_sw || c_ins_swsp;
    assign ins_addi_l1  = ins_addi || c_ins_li || c_ins_addi || c_ins_addi16sp || c_ins_addi4spn;
    assign ins_slti_l1  = ins_slti;
    assign ins_sltiu_l1 = ins_sltiu;
    assign ins_xori_l1  = ins_xori;
    assign ins_ori_l1   = ins_ori;
    assign ins_andi_l1  = ins_andi || c_ins_andi;
    assign ins_slli_l1  = ins_slli || c_ins_slli;
    assign ins_srli_l1  = ins_srli || c_ins_srli;
    assign ins_srai_l1  = ins_srai || c_ins_srai;
    assign ins_add_l1   = ins_add || c_ins_mv || c_ins_add;
    assign ins_sub_l1   = ins_sub || c_ins_sub;
    assign ins_sll_l1   = ins_sll;
    assign ins_slt_l1   = ins_slt;
    assign ins_sltu_l1  = ins_sltu;
    assign ins_xor_l1   = ins_xor || c_ins_xor;
    assign ins_srl_l1   = ins_srl;
    assign ins_sra_l1   = ins_sra;
    assign ins_or_l1    = ins_or || c_ins_or;
    assign ins_and_l1   = ins_and || c_ins_and;




endmodule
