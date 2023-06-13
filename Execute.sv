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
    input  wire [31:0] alu_a_l2,   //x[rs1]
    input  wire [31:0] alu_b_l2,   //x[rs2]
    input  wire [31:0] pc_l2,     //pc pointer
    input  wire [31:0] imm_l2,    //immediate
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
    output reg [31:0] alu_q_l2,     //x[rd]
    output reg        jump_en_l2,
    output reg [31:0] jump_addr_l2,
    output reg clear_l1,
    output reg clear_l2

);
//=================================================================================
// Signal declaration
//=================================================================================

    wire [31:0] SRA_mask;
    wire [31:0] data0;
    wire [31:0] data1;
    wire [31:0] sum1;
    wire [31:0] data2;
    wire [31:0] data3;
    wire [31:0] data4;
    wire [31:0] data5;
    wire [31:0] sumadd;
    wire [31:0] sumadd1;
    wire [31:0] alu_a_shift_right_alu_b;
    wire [31:0] alu_a_shift_right_imm;
    wire op1_ge_op2_signed;
    wire op1_ge_op2_unsigned;
    wire  con_flag = (alu_a_l2[31] == alu_b_l2[31]); //rs1 rs2符号位是否一致
    /* 建议的写法 wire con_flag = data0[31] == data1[31] */
    wire  con_flag1 = (alu_a_l2[31] == imm_l2[31]); //rs1 imm符号位是否一致
    assign alu_a_shift_right_alu_b 	= alu_a_l2 >> alu_b_l2[4:0];
    assign alu_a_shift_right_imm 	= alu_a_l2 >> imm_l2[4:0];
    assign 	SRA_mask = ins_sra_l2 ? (32'hffff_ffff) >> alu_b_l2[4:0] : (32'hffff_ffff) >> imm_l2[4:0]; //算数右移判断移位,由于alu_a_l2只有32位,故只需要用alu_b_l2的0-4位表示即可
    //assign data0 = imm_l2;
    assign data0 = (ins_jalr_l2 == 1'b1 ) ? (ins_c_l2 ? 32'd2 : 32'd4): imm_l2;
    assign data1 = pc_l2;    
    assign op1_ge_op2_signed = $signed(alu_a_l2) >= $signed(alu_b_l2);
    assign op1_ge_op2_unsigned = alu_a_l2 >= alu_b_l2;
    alu_add myadd(          
        .data0(data0),
        .data1(data1),
        .ALU_result(sum1)    //sum = pc_l2 + imm_l2
    );

    //assign data2 = alu_a_l2;    //立即数加法操作TODO:为add时data2为alu_b_l2,sub指令为减法
    //assign data3 = imm_l2;
    assign data2 = ins_jal_l2 ? (ins_c_l2 ? 32'd2 : 32'd4) : alu_a_l2;
    assign data3 = (ins_jal_l2 == 1'b1 ) ? pc_l2: imm_l2 ;
    alu_add myadd1(          
        .data0(data2),
        .data1(data3),
        .ALU_result(sumadd)    //sum = rs1 + imm_l2
    );

    /* 可以只使用2个加法器, 你看看能否优化掉一个, 如果想不到就算了 ^v^ */

    assign data4 = alu_a_l2;    //rs1+(or-)rs2
    assign data5 = (ins_sub_l2 == 1'b1) ? (~alu_b_l2 + 1'b1): alu_b_l2;   //若为减法指令则对rs2取反加一将减法转为加法
    //assign data3 = alu_b_l2;
    alu_add myadd2(          //TODO：输入端口
        .data0(data4),
        .data1(data5),
        .ALU_result(sumadd1)    //sum = rs1 +(-) rs2
    );

    always @(*)begin
        unique if(ins_lui_l2)begin
            alu_q_l2 = imm_l2; /* 每个分支必须考虑所有信号, 比如在下面的标记 "!" 处, 对 jump_en_l2 进行赋值, 但是在此行的分支中却没有对 jump_en_l2 赋值, 会综合出锁存结构, 即 jump_en_l2 = jump_en_l2 */
            jump_en_l2 = 1'b0;
            jump_addr_l2 = 32'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;            
        end 
        else if(ins_auipc_l2)begin 
            alu_q_l2 = sum1;
            jump_en_l2 = 1'b0;
            jump_addr_l2 = 32'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;   
        end
        else if(ins_jal_l2)  begin
            jump_en_l2 = 1'b1; /* ! */
            alu_q_l2 = sumadd;
            jump_addr_l2 = sum1;
            clear_l1 = 1'b1;
            clear_l2 = 1'b1;  
            end
        else if(ins_jalr_l2) begin
            jump_addr_l2 = sumadd;
            alu_q_l2 = sum1;
            jump_en_l2 = 1'b1;
            clear_l1 = 1'b1;
            clear_l2 = 1'b1;  
        end
        else if(ins_beq_l2) begin
            if(alu_a_l2 == alu_b_l2) begin    //rs1==rs2
                jump_addr_l2 = sum1;
                jump_en_l2 = 1'b1;      //跳转使能开
                clear_l1 = 1'b1;
                clear_l2 = 1'b1;  
                alu_q_l2 = 32'b0;
            end
            else begin
                jump_en_l2 = 1'b0;
                jump_addr_l2 = 32'b0;  
                clear_l1 = 1'b0;
                clear_l2 = 1'b0;  
                alu_q_l2 = 32'b0;
            end
        end
        else if(ins_bne_l2) begin
            if(alu_a_l2 != alu_b_l2) begin  //rs1!=rs2
                jump_addr_l2 = sum1;
                jump_en_l2 = 1'b1;      //跳转使能开
                clear_l1 = 1'b1;
                clear_l2 = 1'b1;  
                alu_q_l2 = 32'b0;
            end
            else begin
                jump_en_l2 = 1'b0;
                jump_addr_l2 = 32'b0;  
                clear_l1 = 1'b0;
                clear_l2 = 1'b0;  
                alu_q_l2 = 32'b0;
            end
        end
        else if(ins_blt_l2) begin     //有符号比较
            if(op1_ge_op2_signed==0) begin
            //if(alu_a_l2 < alu_b_l2)   
                jump_addr_l2 = sum1;
                jump_en_l2 = 1'b1;      //跳转使能开
                clear_l1 = 1'b1;
                clear_l2 = 1'b1;  
                alu_q_l2 = 32'b0;
            end
            else begin
                jump_en_l2 = 1'b0;
                jump_addr_l2 = 32'b0;
                clear_l1 = 1'b0;
                clear_l2 = 1'b0;  
                alu_q_l2 = 32'b0;
            end 
        end
        else if(ins_bge_l2) begin      //有符号比较使用$signed来比较
            if(op1_ge_op2_signed==1) begin
            //if(alu_a_l2 >= alu_b_l2)   
                jump_addr_l2 = sum1;
                jump_en_l2 = 1'b1;      //跳转使能开
                clear_l1 = 1'b1;
                clear_l2 = 1'b1;  
                alu_q_l2 = 32'b0;
            end
            else begin
                jump_en_l2 = 1'b0;
                jump_addr_l2 = 32'b0;
                clear_l1 = 1'b0;
                clear_l2 = 1'b0;  
                alu_q_l2 = 32'b0;
            end 
        end
        else if(ins_bltu_l2) begin
            if(op1_ge_op2_unsigned==0)begin
            //if(alu_a_l2 < alu_b_l2)   
                jump_addr_l2 = sum1;
                jump_en_l2 = 1'b1;      //跳转使能开
                clear_l1 = 1'b1;
                clear_l2 = 1'b1;  
                alu_q_l2 = 32'b0;
            end
            else begin
                jump_en_l2 = 1'b0;
                jump_addr_l2 = 32'b0;
                clear_l1 = 1'b0;
                clear_l2 = 1'b0;  
                alu_q_l2 = 32'b0;
            end 
        end
        else if(ins_bgeu_l2) begin
            if(op1_ge_op2_unsigned==1)begin
            //if(alu_a_l2 >= alu_b_l2)   
                jump_addr_l2 = sum1;
                jump_en_l2 = 1'b1;      //跳转使能开
                clear_l1 = 1'b1;
                clear_l2 = 1'b1;  
                alu_q_l2 = 32'b0;
            end
            else begin
                jump_en_l2 = 1'b0;
                jump_addr_l2 = 32'b0;
                clear_l1 = 1'b0;
                clear_l2 = 1'b0;  
                alu_q_l2 = 32'b0;
            end 
        end
        else if(ins_lb_l2) begin       //访存操作只需要给出地址即可
            alu_q_l2 = sumadd;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;  
            jump_addr_l2 = 32'b0;
        end
        else if(ins_lh_l2) begin
            alu_q_l2 = sumadd;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;  
            jump_addr_l2 = 32'b0;
        end
        else if(ins_lw_l2) begin
            alu_q_l2 = sumadd;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;  
            jump_addr_l2 = 32'b0;
        end
        else if(ins_lhu_l2) begin
            alu_q_l2 = sumadd;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;  
            jump_addr_l2 = 32'b0;
        end
        else if(ins_lbu_l2) begin
            alu_q_l2 = sumadd;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;  
            jump_addr_l2 = 32'b0;
        end
        else if(ins_sb_l2) begin
            alu_q_l2 = sumadd;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;  
            jump_addr_l2 = 32'b0;
        end
        else if(ins_sh_l2) begin
            alu_q_l2 = sumadd;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;  
            jump_addr_l2 = 32'b0;
        end
        else if(ins_sw_l2) begin
            alu_q_l2 = sumadd;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;  
            jump_addr_l2 = 32'b0;
        end

        else if(ins_addi_l2) begin   //加法操作
            alu_q_l2 = sumadd;
            jump_addr_l2 = 32'b0;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;
        end
        else if(ins_slti_l2)begin
                    if(con_flag1 == 1'b1) begin
                        if(alu_a_l2[30:0] < imm_l2[30:0])begin
                            alu_q_l2 = 32'd1;
                            jump_addr_l2 = 32'b0;
                            jump_en_l2 = 1'b0;
                            clear_l1 = 1'b0;
                            clear_l2 = 1'b0;end
                        else begin
                            alu_q_l2 = 32'd0;
                            jump_addr_l2 = 32'b0;
                            jump_en_l2 = 1'b0;
                            clear_l1 = 1'b0;
                            clear_l2 = 1'b0;end
                    end
                    else begin
                        if(alu_a_l2[31] == 1'b1)begin
                            alu_q_l2 = 32'd1;
                            jump_addr_l2 = 32'b0;
                            jump_en_l2 = 1'b0;
                            clear_l1 = 1'b0;
                            clear_l2 = 1'b0;end
                        else begin
                            alu_q_l2 = 32'd0;
                            jump_addr_l2 = 32'b0;
                            jump_en_l2 = 1'b0;
                            clear_l1 = 1'b0;
                            clear_l2 = 1'b0;end
                    end
        end      
        else if(ins_sltiu_l2)begin
            if(alu_a_l2[31:0] < imm_l2[31:0])begin
                alu_q_l2 = 32'd1;
                jump_addr_l2 = 32'b0;
                jump_en_l2 = 1'b0;
                clear_l1 = 1'b0;
                clear_l2 = 1'b0;end 
            else begin
                alu_q_l2 = 32'd0;
                jump_addr_l2 = 32'b0;
                jump_en_l2 = 1'b0;
                clear_l1 = 1'b0;
                clear_l2 = 1'b0;end
        end      
        else if(ins_xori_l2) begin   //
            alu_q_l2 = alu_a_l2 ^ imm_l2;
            jump_addr_l2 = 32'b0;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;
        end   
        else if(ins_ori_l2) begin   //
            alu_q_l2 = alu_a_l2 | imm_l2;
            jump_addr_l2 = 32'b0;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;
        end   
        else if(ins_andi_l2) begin   //
            alu_q_l2 = alu_a_l2 & imm_l2;
            jump_addr_l2 = 32'b0;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;
        end  
        else if(ins_slli_l2) begin   //逻辑移位操作
            alu_q_l2 = alu_a_l2 << imm_l2;
            jump_addr_l2 = 32'b0;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;
        end
        else if(ins_srli_l2) begin   //逻辑移位操作
            alu_q_l2 = alu_a_l2 >> imm_l2;
            jump_addr_l2 = 32'b0;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;
        end    
        else if(ins_srai_l2) begin   
            //alu_q_l2 = alu_a_l2 >>> imm_l2;
            alu_q_l2 = ((alu_a_shift_right_imm) & SRA_mask) | ({32{alu_a_l2[31]}} & (~SRA_mask));
            jump_addr_l2 = 32'b0;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;            
        end 
        else if(ins_add_l2) begin   
            alu_q_l2 = sumadd1;
            jump_addr_l2 = 32'b0;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;
        end   

        else if(ins_sll_l2) begin   
            alu_q_l2 = alu_a_l2 << alu_b_l2;
            jump_addr_l2 = 32'b0;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;
        end      
        else if(ins_slt_l2)begin
            if(op1_ge_op2_signed==0)begin
                alu_q_l2 = 32'd1;
                jump_addr_l2 = 32'b0;
                jump_en_l2 = 1'b0;
                clear_l1 = 1'b0;
                clear_l2 = 1'b0;end
            else begin
                alu_q_l2 = 32'b0;
                jump_addr_l2 = 32'b0;
                jump_en_l2 = 1'b0;
                clear_l1 = 1'b0;
                clear_l2 = 1'b0;end
        end            
        else if(ins_sltu_l2)begin
            if(op1_ge_op2_unsigned==0)begin
                alu_q_l2 = 32'd1;
                jump_addr_l2 = 32'b0;
                jump_en_l2 = 1'b0;
                clear_l1 = 1'b0;
                clear_l2 = 1'b0;end
            else begin
                alu_q_l2 = 32'b0;
                jump_addr_l2 = 32'b0;
                jump_en_l2 = 1'b0;
                clear_l1 = 1'b0;
                clear_l2 = 1'b0;end
        end
        else if(ins_sub_l2)begin
            alu_q_l2 = sumadd1;
            jump_addr_l2 = 32'b0;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;
        end
        else if(ins_xor_l2)begin
            alu_q_l2 = alu_a_l2 ^ alu_b_l2;
            jump_addr_l2 = 32'b0;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;
        end
        else if(ins_srl_l2)begin
            alu_q_l2 = alu_a_l2 >> alu_b_l2;
            jump_addr_l2 = 32'b0;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;
        end
        else if(ins_sra_l2)begin              
            //alu_q_l2 = alu_a_l2 >>> alu_b_l2;
            alu_q_l2 = ((alu_a_shift_right_alu_b) & SRA_mask) | ({32{alu_a_l2[31]}} & (~SRA_mask));
            jump_addr_l2 = 32'b0;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;
        end     
        else if(ins_or_l2)begin
            alu_q_l2 = alu_a_l2 | alu_b_l2;
            jump_addr_l2 = 32'b0;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;
        end  
        else if(ins_and_l2)begin
            alu_q_l2 = alu_a_l2 & alu_b_l2;
            jump_addr_l2 = 32'b0;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;
        end  
        else begin
            alu_q_l2 = 32'b0;   
            jump_addr_l2 = 32'b0;
            jump_en_l2 = 1'b0;
            clear_l1 = 1'b0;
            clear_l2 = 1'b0;  
            end   
    end

endmodule


module alu_add (
    input  wire [31:0] data0,
    input  wire [31:0] data1,
    output wire [31:0] ALU_result
);

    assign ALU_result = data0 + data1;

endmodule