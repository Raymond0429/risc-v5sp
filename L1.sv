/*
    注意事项:
    rstn 表示 rst 取非
    当 block_l1 == 1 时, 所有寄存器保持原值
    当 rstn == 0 或 clear_l1 == 1 时, ins_l1 = 0x13, pc_l1 = 0, 0x13为 nop 指令
    其他情况 ins_l1 = ins_l0, pc_l1 = pc_l0

*/


module L1(
    input  wire clk,
    input  wire rstn,
    input  wire clear_l1,
    input  wire block_l1,
    input  wire [31:0] ins_l0,
    input  wire [31:0] pc_l0,
    output wire [31:0] ins_l1,
    output wire [31:0] pc_l1
);
	
	//对指令ins及pc进行打拍寄存
	dff_set #(32) dff1(clk, rstn, clear_l1, block_l1, 32'h0000_0013, ins_l0, ins_l1);	

	dff_set #(32) dff2(clk, rstn, clear_l1, block_l1, 32'b0, pc_l0, pc_l1);
	
endmodule
