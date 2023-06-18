/*
    注意事项:
    rstn 表示 rst 取非
    当 block_l2 == 1 时, 所有寄存器保持原值
    当 rstn == 0 或 clear_l2 == 1 时, 所有寄存器清零
    其他情况 xxx_l2 = xxx_l1

*/


module L2 (
    input  wire        clk,
    input  wire        rstn,
    input  wire        clear_l2,
    input  wire        block_l2,
    input  wire [31:0] pc_l1,
    input  wire [31:0] imm_l1,
    input  wire [ 4:0] rd_l1,
    input  wire [ 4:0] rs1_l1,
    input  wire [ 4:0] rs2_l1,
    input  wire        ins_c_l1,
    input  wire        ins_lui_l1,
    input  wire        ins_auipc_l1,
    input  wire        ins_jal_l1,
    input  wire        ins_jalr_l1,
    input  wire        ins_beq_l1,
    input  wire        ins_bne_l1,
    input  wire        ins_blt_l1,
    input  wire        ins_bge_l1,
    input  wire        ins_bltu_l1,
    input  wire        ins_bgeu_l1,
    input  wire        ins_lb_l1,
    input  wire        ins_lh_l1,
    input  wire        ins_lw_l1,
    input  wire        ins_lbu_l1,
    input  wire        ins_lhu_l1,
    input  wire        ins_sb_l1,
    input  wire        ins_sh_l1,
    input  wire        ins_sw_l1,
    input  wire        ins_addi_l1,
    input  wire        ins_slti_l1,
    input  wire        ins_sltiu_l1,
    input  wire        ins_xori_l1,
    input  wire        ins_ori_l1,
    input  wire        ins_andi_l1,
    input  wire        ins_slli_l1,
    input  wire        ins_srli_l1,
    input  wire        ins_srai_l1,
    input  wire        ins_add_l1,
    input  wire        ins_sub_l1,
    input  wire        ins_sll_l1,
    input  wire        ins_slt_l1,
    input  wire        ins_sltu_l1,
    input  wire        ins_xor_l1,
    input  wire        ins_srl_l1,
    input  wire        ins_sra_l1,
    input  wire        ins_or_l1,
    input  wire        ins_and_l1,
    output wire [31:0] pc_l2,
    output wire [31:0] imm_l2,
    output wire [ 4:0] rd_l2,
    output wire [ 4:0] rs1_l2,
    output wire [ 4:0] rs2_l2,
    output wire        ins_c_l2,
    output wire        ins_lui_l2,
    output wire        ins_auipc_l2,
    output wire        ins_jal_l2,
    output wire        ins_jalr_l2,
    output wire        ins_beq_l2,
    output wire        ins_bne_l2,
    output wire        ins_blt_l2,
    output wire        ins_bge_l2,
    output wire        ins_bltu_l2,
    output wire        ins_bgeu_l2,
    output wire        ins_lb_l2,
    output wire        ins_lh_l2,
    output wire        ins_lw_l2,
    output wire        ins_lbu_l2,
    output wire        ins_lhu_l2,
    output wire        ins_sb_l2,
    output wire        ins_sh_l2,
    output wire        ins_sw_l2,
    output wire        ins_addi_l2,
    output wire        ins_slti_l2,
    output wire        ins_sltiu_l2,
    output wire        ins_xori_l2,
    output wire        ins_ori_l2,
    output wire        ins_andi_l2,
    output wire        ins_slli_l2,
    output wire        ins_srli_l2,
    output wire        ins_srai_l2,
    output wire        ins_add_l2,
    output wire        ins_sub_l2,
    output wire        ins_sll_l2,
    output wire        ins_slt_l2,
    output wire        ins_sltu_l2,
    output wire        ins_xor_l2,
    output wire        ins_srl_l2,
    output wire        ins_sra_l2,
    output wire        ins_or_l2,
    output wire        ins_and_l2
);

	dff_set #(32) dff1(clk, rstn, clear_l2, block_l2, 32'b0, pc_l1, pc_l2);	

	dff_set #(32) dff2(clk, rstn, clear_l2, block_l2, 32'b0, imm_l1, imm_l2);
	
	dff_set #(5)  dff3(clk, rstn, clear_l2, block_l2, 5'b0, rd_l1, rd_l2);	

	dff_set #(5)  dff4(clk, rstn, clear_l2, block_l2, 5'b0, rs1_l1, rs1_l2);
	
	dff_set #(5)  dff5(clk, rstn, clear_l2, block_l2, 5'b0, rs2_l1, rs2_l2);	

	dff_set #(1)  dff6(clk, rstn, clear_l2, block_l2, 1'b0, ins_c_l1, ins_c_l2);
	
	dff_set #(1)  dff7(clk, rstn, clear_l2, block_l2, 1'b0, ins_lui_l1, ins_lui_l2);
	
	dff_set #(1)  dff8(clk, rstn, clear_l2, block_l2, 1'b0, ins_auipc_l1, ins_auipc_l2);
	
	dff_set #(1)  dff9(clk, rstn, clear_l2, block_l2, 1'b0, ins_jal_l1, ins_jal_l2);
	
	dff_set #(1)  dff10(clk, rstn, clear_l2, block_l2, 1'b0, ins_jalr_l1, ins_jalr_l2);
	
	dff_set #(1)  dff11(clk, rstn, clear_l2, block_l2, 1'b0, ins_beq_l1, ins_beq_l2);
	
	dff_set #(1)  dff12(clk, rstn, clear_l2, block_l2, 1'b0, ins_bne_l1, ins_bne_l2);
	
	dff_set #(1)  dff13(clk, rstn, clear_l2, block_l2, 1'b0, ins_blt_l1, ins_blt_l2);
	
	dff_set #(1)  dff14(clk, rstn, clear_l2, block_l2, 1'b0, ins_bge_l1, ins_bge_l2);
	
	dff_set #(1)  dff15(clk, rstn, clear_l2, block_l2, 1'b0, ins_bltu_l1, ins_bltu_l2);	

	dff_set #(1)  dff16(clk, rstn, clear_l2, block_l2, 1'b0, ins_bgeu_l1, ins_bgeu_l2);
	
	dff_set #(1)  dff17(clk, rstn, clear_l2, block_l2, 1'b0, ins_lb_l1, ins_lb_l2);
	
	dff_set #(1)  dff18(clk, rstn, clear_l2, block_l2, 1'b0, ins_lh_l1, ins_lh_l2);
	
	dff_set #(1)  dff19(clk, rstn, clear_l2, block_l2, 1'b0, ins_lw_l1, ins_lw_l2);
	
	dff_set #(1)  dff20(clk, rstn, clear_l2, block_l2, 1'b0, ins_lbu_l1, ins_lbu_l2);
	
	dff_set #(1)  dff21(clk, rstn, clear_l2, block_l2, 1'b0, ins_lhu_l1, ins_lhu_l2);
	
	dff_set #(1)  dff22(clk, rstn, clear_l2, block_l2, 1'b0, ins_sb_l1, ins_sb_l2);
	
	dff_set #(1)  dff23(clk, rstn, clear_l2, block_l2, 1'b0, ins_sh_l1, ins_sh_l2);
	
	dff_set #(1)  dff24(clk, rstn, clear_l2, block_l2, 1'b0, ins_sw_l1, ins_sw_l2);
	
	dff_set #(1)  dff25(clk, rstn, clear_l2, block_l2, 1'b0, ins_addi_l1, ins_addi_l2);
	
	dff_set #(1)  dff26(clk, rstn, clear_l2, block_l2, 1'b0, ins_slli_l1, ins_slli_l2);
	
	dff_set #(1)  dff27(clk, rstn, clear_l2, block_l2, 1'b0, ins_srli_l1, ins_srli_l2);	

	dff_set #(1)  dff28(clk, rstn, clear_l2, block_l2, 1'b0, ins_srai_l1, ins_srai_l2);
	
	dff_set #(1)  dff29(clk, rstn, clear_l2, block_l2, 1'b0, ins_add_l1, ins_add_l2);
	
	dff_set #(1)  dff30(clk, rstn, clear_l2, block_l2, 1'b0, ins_sub_l1, ins_sub_l2);
	
	dff_set #(1)  dff31(clk, rstn, clear_l2, block_l2, 1'b0, ins_sll_l1, ins_sll_l2);
	
	dff_set #(1)  dff32(clk, rstn, clear_l2, block_l2, 1'b0, ins_slt_l1, ins_slt_l2);
	
	dff_set #(1)  dff33(clk, rstn, clear_l2, block_l2, 1'b0, ins_sltu_l1, ins_sltu_l2);
	
	dff_set #(1)  dff34(clk, rstn, clear_l2, block_l2, 1'b0, ins_xor_l1, ins_xor_l2);
	
	dff_set #(1)  dff35(clk, rstn, clear_l2, block_l2, 1'b0, ins_srl_l1, ins_srl_l2);
	
	dff_set #(1)  dff36(clk, rstn, clear_l2, block_l2, 1'b0, ins_sra_l1, ins_sra_l2);	

	dff_set #(1)  dff37(clk, rstn, clear_l2, block_l2, 1'b0, ins_or_l1, ins_or_l2);
	
	dff_set #(1)  dff38(clk, rstn, clear_l2, block_l2, 1'b0, ins_and_l1, ins_and_l2);
	
	dff_set #(1)  dff39(clk, rstn, clear_l2, block_l2, 1'b0, ins_slti_l1, ins_slti_l2);
	
	dff_set #(1)  dff40(clk, rstn, clear_l2, block_l2, 1'b0, ins_sltiu_l1, ins_sltiu_l2);
	
	dff_set #(1)  dff41(clk, rstn, clear_l2, block_l2, 1'b0, ins_xori_l1, ins_xori_l2);	

	dff_set #(1)  dff42(clk, rstn, clear_l2, block_l2, 1'b0, ins_ori_l1, ins_ori_l2);
	
	dff_set #(1)  dff43(clk, rstn, clear_l2, block_l2, 1'b0, ins_andi_l1, ins_andi_l2);
	
endmodule
