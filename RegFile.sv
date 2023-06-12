/*
    注意事项:
    rstn 表示 rst 取非
    当 rs1 == 0 时, xrs1 = 0 否则 xrs1 = reg_file[rs1]
    当 rs2 == 0 时, xrs2 = 0 否则 xrs2 = reg_file[rs2]
    当 load_l3 == 1 时, wval_l3 = ram_rdata_l3 否则 wval_l3 = alu_q_l3

    当 rstn == 0, reg_file清零
    当 rd != 0 时, reg_file[rd] = wval_l3

*/


module RegFile (
    input  wire        clk,
    input  wire        rstn,
    input  wire [ 4:0] rd_l3,
    input  wire [ 4:0] rs1_l2,
    input  wire [ 4:0] rs2_l2,
    input  wire [31:0] alu_q_l3,
    input  wire [31:0] ram_rdata_l3,
    input  wire        load_l3,
    output wire [31:0] xrs1_l2,
    output wire [31:0] xrs2_l2,
    output wire [31:0] wval_l3

);

    reg [31:0] reg_file[31:1];



endmodule
