/*
    前递可分为
    1.当 rs1_l2 == rd_l3 时, wval 前递 alu_a 
    2.当 rs2_l2 == rd_l3 时, wval 前递 alu_b

    不发生前递时 alu_a = xrs1
    不发生前递时 alu_b = xrs2

*/

module ForwardCtrl (
    input  wire [ 4:0] rd_l3,
    input  wire [ 4:0] rs1_l2,
    input  wire [ 4:0] rs2_l2,
    input  wire [31:0] xrs1_l2,
    input  wire [31:0] xrs2_l2,
    input  wire [31:0] wval_l3,
    output wire [31:0] alu_a_l2,
    output wire [31:0] alu_b_l2

);
	
	assign alu_a_l2 = ((rs1_l2 == rd_l3) && rs1_l2 != 5'd0)? wval_l3: xrs1_l2; //当 rs1_l2 == rd_l3 时, wval前递 alu_a,为x0不前递
	assign alu_b_l2 = ((rs2_l2 == rd_l3) && rs2_l2 != 5'd0)? wval_l3: xrs2_l2; //当 rs2_l2 == rd_l3 时, wval前递 alu_b,为x0不前递
	

endmodule
