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
    output reg  [31:0] xrs1_l2,
    output reg  [31:0] xrs2_l2,
    output wire [31:0] wval_l3

);

    wire [31:0] wval;
    assign wval = load_l3 ? ram_rdata_l3 : alu_q_l3;

    reg [31:0] reg_file[31:1];

    //rs1读操作，x0寄存器始终为0
    always @(*) begin
        if (rs1_l2 == 5'b0) begin
            xrs1_l2 = 32'b0;
        end else begin
            xrs1_l2 = reg_file[rs1_l2];
        end
    end

    //rs2读操作，x0寄存器始终为0
    always @(*) begin
        if (rs2_l2 == 5'b0) begin
            xrs2_l2 = 32'b0;
        end else begin
            xrs2_l2 = reg_file[rs2_l2];
        end
    end

    genvar i;
    //reg写操作，x0寄存器始终为0，不能被写入
    generate
        for (i = 1; i <= 31; i = i + 1) begin
            always @(posedge clk) begin
                if (!rstn) begin
                    reg_file[i] = 32'b0;
                end else if (rd_l3 == i) begin
                    reg_file[i] <= wval;
                end
            end
        end
    endgenerate


    assign wval_l3 = wval;

endmodule
