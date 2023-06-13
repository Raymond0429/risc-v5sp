/*
    注意事项:
    把压缩指令集翻译成标准指令集
    ins 为传入的指令, 如果是压缩指令, 你只需要对低16位进行解码, 无视掉高16位
    jal 在译码阶段就确定跳转地址, 但x[rd] = pc + 4 或 + 2 这个操作还需要甩给执行阶段
    当译码到 jal 指令时, 得出正确的跳转地址 jump_addr_l1 并使 jump_en_l1 = 1, 并输出 clear_l1 = 1, 以清空流水线 l1

    当指令为压缩指令时, ins_c = 1 
*/

module Decoder (
    input  logic [31:0] ins_l1,
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

logic [6 : 0]   opcode;
logic [2: 0]    funct3;
logic [3 : 0]   funct4;
logic [5 : 0]   funct6;
logic [6 : 0]   funct7;

logic c4sp_ins_addi_l1,c_ins_lw_l1,c_ins_sw_l1;
logic c_jump_en_l1, c_clear_l1, c_ins_addi_l1, c_ins_lui_l1, c16sp_ins_addi_l1, c_ins_srli_l1, c_ins_srai_l1, c_ins_andi_l1, c_ins_and_l1, c_ins_or_l1, c_ins_xor_l1, c_ins_sub_l1, c_ins_beq_l1, c_ins_bne_l1, csp_ins_sw_l1;
logic c_ins_slli_l1, csp_ins_lw_l1, c_ins_jalr_l1, cmv_ins_add_l1, c_ins_add_l1, c_ins_jal_l1;

//standard ins op code
assign ins_c_l1 = (ins_l1[1:0] == 'b11);
assign opcode = (ins_c_l1) ? {5'b0,ins_l1[1:0]} : ins_l1[6 : 0]; /* 位数注意, 压缩指令的 opcode 可以补0 */ // check 
assign funct3 = (ins_c_l1) ? ins_l1[15 : 13] : ins_l1[14 : 12];
assign funct7 = ins_l1[31 : 25];

//only C-ins op code
//assign funct4 = ins_l1[15 : 12];
//assign funct6 = ins_l1[15 : 10];

///////////////////////////////////////////
//standard ins decode
///////////////////////////////////////////
always_comb begin
    if(opcode == 7'b0110111)
        ins_lui_l1 = 1;
    else
        ins_lui_l1 = c_ins_lui_l1;    
end

always_comb begin
    if(opcode == 'b0010111)
        ins_auipc_l1 = 1;
    else
        ins_auipc_l1 = 0;    
end

always_comb begin 
    if(opcode == 'b1101111) begin
        clear_l1 = 1;
        jump_en_l1 = 1;
    end
    else begin
        clear_l1 = c_clear_l1;
        jump_en_l1 = c_jump_en_l1;
    end    
end

always_comb begin
    if(opcode == 'b1101111)
        ins_jal_l1 = 1;
    else 
        ins_jal_l1 = c_ins_jal_l1;
end

always_comb begin
    if(opcode == 'b1100111)
        ins_jalr_l1 = 1;
    else
        ins_jalr_l1 = c_ins_jalr_l1;    
end

always_comb begin
    if(opcode == 'b1100011)
        unique if (funct3 == 'b000) begin /* 建议使用 unique if 优化时序 check*/
            ins_beq_l1  = 1;  /* 这样写是无法通过综合的, 比如说此分支成立时的 ins_bne_l1 信号是几你并没有定义, 包括后面写的 if 和 case 都有同样的问题 check*/
            ins_bne_l1  = 0; 
            ins_blt_l1  = 0; 
            ins_bge_l1  = 0; 
            ins_bltu_l1 = 0;    
            ins_bgeu_l1 = 0;
        end
        else if(funct3 == 'b001)begin
            ins_beq_l1  = 0;  
            ins_bne_l1 = 1;
            ins_blt_l1  = 0; 
            ins_bge_l1  = 0; 
            ins_bltu_l1 = 0;    
            ins_bgeu_l1 = 0;
        end
        else if(funct3 == 'b100) begin
            ins_blt_l1 = 1;
            ins_beq_l1  = 0;   
            ins_bne_l1  = 0; 
            ins_bge_l1  = 0; 
            ins_bltu_l1 = 0;    
            ins_bgeu_l1 = 0;
        end
        else if(funct3 == 'b101) begin
            ins_bge_l1 = 1;
            ins_beq_l1  = 0;   
            ins_bne_l1  = 0; 
            ins_blt_l1  = 0; 
            ins_bltu_l1 = 0;    
            ins_bgeu_l1 = 0;
        end
        else if(funct3 == 'b110) begin
            ins_bltu_l1 = 1;
            ins_beq_l1  = 0;   
            ins_bne_l1  = 0; 
            ins_blt_l1  = 0; 
            ins_bge_l1  = 0;   
            ins_bgeu_l1 = 0;
        end
        else if(funct3 == 'b111) begin
            ins_bgeu_l1 = 1; 
            ins_beq_l1  = 0;   
            ins_bne_l1  = 0; 
            ins_blt_l1  = 0; 
            ins_bge_l1  = 0; 
            ins_bltu_l1 = 0; 
        end
        else begin
            ins_beq_l1  = 0;   
            ins_bne_l1  = 0; 
            ins_blt_l1  = 0; 
            ins_bge_l1  = 0; 
            ins_bltu_l1 = 0;    
            ins_bgeu_l1 = 0;
        end
    else begin
        ins_beq_l1  = c_ins_beq_l1;   
        ins_bne_l1  = c_ins_bne_l1; 
        ins_blt_l1  = 0; 
        ins_bge_l1  = 0; 
        ins_bltu_l1 = 0;    
        ins_bgeu_l1 = 0;
    end
end

//TODO: whether ins have priority or it doesn't matter?
always_comb begin
    if(opcode == 'b0000011)
        unique if(funct3 == 'b000) begin
            ins_lb_l1   = 1;
            ins_lh_l1   = 0; 
            ins_lw_l1   = 0;
            ins_lbu_l1  = 0;
            ins_lhu_l1  = 0;
        end
        else if(funct3 == 'b001) begin
            ins_lh_l1   = 1;
            ins_lb_l1   = 0;
            ins_lw_l1   = 0;
            ins_lbu_l1  = 0;
            ins_lhu_l1  = 0;
        end
        else if(funct3 == 'b010) begin
            ins_lw_l1   = 1;
            ins_lb_l1   = 0;
            ins_lh_l1   = 0; 
            ins_lbu_l1  = 0;
            ins_lhu_l1  = 0;
        end
        else if(funct3 == 'b100) begin
            ins_lbu_l1 = 1;
            ins_lb_l1   = 0;
            ins_lh_l1   = 0; 
            ins_lw_l1   = 0;
            ins_lhu_l1  = 0;
        end
        else if(funct3 == 'b101) begin
            ins_lhu_l1  = 1;
            ins_lb_l1   = 0;
            ins_lh_l1   = 0; 
            ins_lw_l1   = 0;
            ins_lbu_l1  = 0;
        end
        else begin
            ins_lb_l1   = 0;
            ins_lh_l1   = 0; 
            ins_lw_l1   = 0;
            ins_lbu_l1  = 0;
            ins_lhu_l1  = 0;
        end
    else begin
        ins_lb_l1   = 0;
        ins_lh_l1   = 0; 
        ins_lw_l1   = c_ins_lw_l1 | csp_ins_lw_l1;
        ins_lbu_l1  = 0;
        ins_lhu_l1  = 0;
    end
end

always_comb begin
    if(opcode == 'b0100011)
        if(funct3 == 'b000) begin
            ins_sb_l1   = 1;
            ins_sh_l1   = 0;        
            ins_sw_l1   = 0;
        end
        else if(funct3 == 'b001) begin
            ins_sh_l1   = 1;
            ins_sb_l1   = 0;          
            ins_sw_l1   = 0;
        end
        else if(funct3 == 'b010) begin
            ins_sw_l1   = 1;
            ins_sb_l1   = 0;    
            ins_sh_l1   = 0;
        end
        else begin
            ins_sb_l1   = 0;    
            ins_sh_l1   = 0;        
            ins_sw_l1   = 0;   
        end
    else begin
        ins_sb_l1   = 0;    
        ins_sh_l1   = 0;        
        ins_sw_l1   = c_ins_sw_l1 | csp_ins_sw_l1;   
    end
end

//TODO: whether used case function
always_comb begin
    if(opcode == 'b0010011)
        case(funct3)
            3'b000: begin
                ins_addi_l1   = 1;
                ins_slti_l1   = 0;
                ins_xori_l1   = 0;
                ins_sltiu_l1  = 0;   
                ins_ori_l1    = 0;
                ins_andi_l1   = 0;
                ins_slli_l1   = 0;
                ins_srli_l1   = 0;
                ins_srai_l1   = 0;
            end
            3'b001:  begin
                ins_slli_l1   = 1; 
                ins_addi_l1   = 0;
                ins_slti_l1   = 0;
                ins_xori_l1   = 0;
                ins_sltiu_l1  = 0;   
                ins_ori_l1    = 0;
                ins_andi_l1   = 0;
                ins_srli_l1   = 0;
                ins_srai_l1   = 0;
            end
            3'b010: begin
                ins_slti_l1   = 1;
                ins_addi_l1   = 0;
                ins_xori_l1   = 0;
                ins_sltiu_l1  = 0;   
                ins_ori_l1    = 0;
                ins_andi_l1   = 0;
                ins_slli_l1   = 0;
                ins_srli_l1   = 0;
                ins_srai_l1   = 0;
            end 
            3'b011: begin
                ins_sltiu_l1  = 1;
                ins_addi_l1   = 0;
                ins_slti_l1   = 0;
                ins_xori_l1   = 0;   
                ins_ori_l1    = 0;
                ins_andi_l1   = 0;
                ins_slli_l1   = 0;
                ins_srli_l1   = 0;
                ins_srai_l1   = 0;
            end 
            3'b100: begin 
                    ins_xori_l1 = 1;
                    ins_addi_l1   = 0;
                    ins_slti_l1   = 0;
                    ins_sltiu_l1  = 0;   
                    ins_ori_l1    = 0;
                    ins_andi_l1   = 0;
                    ins_slli_l1   = 0;
                    ins_srli_l1   = 0;
                    ins_srai_l1   = 0;
            end
            3'b101: begin
                ins_addi_l1   = 0;
                ins_slti_l1   = 0;
                ins_xori_l1   = 0;
                ins_sltiu_l1  = 0;   
                ins_ori_l1    = 0;
                ins_andi_l1   = 0;
                ins_slli_l1   = 0;
                unique if(funct7[5] == 'b0) begin ins_srli_l1 = 1; ins_srai_l1 = 0; end
                else if(funct7[5] == 'b1)   begin ins_srli_l1 = 0; ins_srai_l1 = 1; end
                else                        begin ins_srli_l1 = 0; ins_srai_l1 = 0; end
            end 
            3'b110: begin 
                ins_ori_l1    = 1;
                ins_addi_l1   = 0;
                ins_slti_l1   = 0;
                ins_xori_l1   = 0;
                ins_sltiu_l1  = 0;   
                ins_ori_l1    = 0;
                ins_andi_l1   = 0;
                ins_slli_l1   = 0;
                ins_srli_l1   = 0;
                ins_srai_l1   = 0;
            end
            3'b111: begin
                ins_andi_l1   = 1;
                ins_addi_l1   = 0;
                ins_slti_l1   = 0;
                ins_xori_l1   = 0;
                ins_sltiu_l1  = 0;   
                ins_ori_l1    = 0;
                ins_slli_l1   = 0;
                ins_srli_l1   = 0;
                ins_srai_l1   = 0;
            end
            default:   
                begin
                    ins_addi_l1   = 0;
                    ins_slti_l1   = 0;
                    ins_xori_l1   = 0;
                    ins_sltiu_l1  = 0;   
                    ins_ori_l1    = 0;
                    ins_andi_l1   = 0;
                    ins_slli_l1   = 0;
                    ins_srli_l1   = 0;
                    ins_srai_l1   = 0;
                end
        endcase
    //    if(funct3 == 'b000)
    //        ins_addi_l1 = 1;
    //    else if(funct3 == 'b010)
    //        ins_slti_l1 = 1;
    //    else if(funct3 == 'b011)
    //        ins_sltiu_l1 = 1;
    //    else if(funct3 == 'b100)
    //        ins_xori_l1 = 1;
    //    else if(funct3 == 'b110)
    //        ins_ori_l1 = 1;
    //    else if(funct3 == 'b111)
    //        ins_andi_l1 = 1;
    //    else if(funct3 == 'b001)
    //        ins_slli_l1 = 1;
    //    else if(funct3 == 'b101)
    //        if(funct7[5] == 'b0)
    //            ins_srli_l1 = 1;
    //        else if(funct7[5] == 'b1)
    //            ins_srai_l1 = 1;
    else begin
        ins_addi_l1   = c_ins_addi_l1 | c4sp_ins_addi_l1 | c16sp_ins_addi_l1;
        ins_slti_l1   = 0;
        ins_xori_l1   = 0;
        ins_sltiu_l1  = 0;   
        ins_ori_l1    = 0;
        ins_andi_l1   = c_ins_andi_l1;
        ins_slli_l1   = c_ins_slli_l1;
        ins_srli_l1   = c_ins_srli_l1;
        ins_srai_l1   = c_ins_srai_l1;
    end   
end

always_comb begin
    if(opcode == 'b0110011)
        case(funct3)
            3'b000: begin 
                unique if(funct7[5] == 'b0) begin ins_add_l1 = 1; ins_sub_l1 = 0; end
                else if(funct7[5] == 'b1)   begin ins_sub_l1 = 1; ins_add_l1 = 0; end
                else                        begin ins_add_l1 = 0; ins_sub_l1 = 0; end
                ins_sll_l1  = 0;
                ins_slt_l1  = 0;
                ins_sltu_l1 = 0;
                ins_xor_l1  = 0;
                ins_srl_l1  = 0;
                ins_sra_l1  = 0;
                ins_or_l1   = 0;
                ins_and_l1  = 0;
            end
            3'b001: 
                begin
                    ins_add_l1  = 0;
                    ins_sub_l1  = 0;
                    ins_sll_l1  = 1;
                    ins_slt_l1  = 0;
                    ins_sltu_l1 = 0;
                    ins_xor_l1  = 0;
                    ins_srl_l1  = 0;
                    ins_sra_l1  = 0;
                    ins_or_l1   = 0;
                    ins_and_l1  = 0;
                end
            3'b010: 
                begin
                    ins_add_l1  = 0;
                    ins_sub_l1  = 0;
                    ins_sll_l1  = 0;
                    ins_slt_l1  = 1;
                    ins_sltu_l1 = 0;
                    ins_xor_l1  = 0;
                    ins_srl_l1  = 0;
                    ins_sra_l1  = 0;
                    ins_or_l1   = 0;
                    ins_and_l1  = 0;
                end
            3'b011: 
                begin
                    ins_add_l1  = 0;
                    ins_sub_l1  = 0;
                    ins_sll_l1  = 0;
                    ins_slt_l1  = 0;
                    ins_sltu_l1 = 1;
                    ins_xor_l1  = 0;
                    ins_srl_l1  = 0;
                    ins_sra_l1  = 0;
                    ins_or_l1   = 0;
                    ins_and_l1  = 0;
                end
            3'b100: 
                begin
                    ins_add_l1  = 0;
                    ins_sub_l1  = 0;
                    ins_sll_l1  = 0;
                    ins_slt_l1  = 0;
                    ins_sltu_l1 = 0;
                    ins_xor_l1  = 1;
                    ins_srl_l1  = 0;
                    ins_sra_l1  = 0;
                    ins_or_l1   = 0;
                    ins_and_l1  = 0;
                end
            3'b101: 
                begin
                    ins_add_l1  = 0;
                    ins_sub_l1  = 0;
                    ins_sll_l1  = 0;
                    ins_slt_l1  = 0;
                    ins_sltu_l1 = 0;
                    ins_xor_l1  = 0;
                    unique if(funct7[5] == 0)   begin ins_srl_l1 = 1; ins_sra_l1 = 0; end
                    else if(funct7[5] == 1)     begin ins_sra_l1 = 1; ins_srl_l1 = 0; end
                    else                        begin ins_srl_l1 = 0; ins_sra_l1 = 0; end
                    ins_or_l1   = 0;
                    ins_and_l1  = 0;
                end
            3'b110: 
                begin
                    ins_add_l1  = 0;
                    ins_sub_l1  = 0;
                    ins_sll_l1  = 0;
                    ins_slt_l1  = 0;
                    ins_sltu_l1 = 0;
                    ins_xor_l1  = 0;
                    ins_srl_l1  = 0;
                    ins_sra_l1  = 0;
                    ins_or_l1   = 1;
                    ins_and_l1  = 0;
                end
            3'b111:
                begin
                    ins_add_l1  = 0;
                    ins_sub_l1  = 0;
                    ins_sll_l1  = 0;
                    ins_slt_l1  = 0;
                    ins_sltu_l1 = 0;
                    ins_xor_l1  = 0;
                    ins_srl_l1  = 0;
                    ins_sra_l1  = 0;
                    ins_or_l1   = 0;
                    ins_and_l1  = 1;
                end
            default:
                begin
                    ins_add_l1  = 0;
                    ins_sub_l1  = 0;
                    ins_sll_l1  = 0;
                    ins_slt_l1  = 0;
                    ins_sltu_l1 = 0;
                    ins_xor_l1  = 0;
                    ins_srl_l1  = 0;
                    ins_sra_l1  = 0;
                    ins_or_l1   = 0;
                    ins_and_l1  = 0;
                end
        endcase
        //if(funct3 == 'b000)
        //    if(funct7[5] == 'b0)
        //        ins_add_l1 = 1;
        //    else if(funct7[5] == 'b1)
        //        ins_sub_l1 = 1;
        //else if(funct3 == 'b001)
        //    ins_sll_l1 = 1;
        //else if(funct3 == 'b010)
        //    ins_slt_l1 = 1;
        //else if(funct3 == 'b011)
        //    ins_sltu_l1 = 1;
        //else if(funct3 == 'b100)
        //    ins_xor_l1 = 1;
        //else if(funct3 == 'b101)
        //    ins_srl_l1 = 1;
    else begin
        ins_sll_l1  = 0;
        ins_slt_l1  = 0;
        ins_sltu_l1 = 0;
        ins_xor_l1  = c_ins_xor_l1;
        ins_srl_l1  = 0;
        ins_sra_l1  = 0;
        ins_or_l1   = c_ins_or_l1;
        ins_and_l1  = c_ins_and_l1;
        ins_sub_l1  = c_ins_sub_l1;
        ins_add_l1  = c_ins_add_l1 | cmv_ins_add_l1;
    end
end

///////////////////////////////////////////
//compression ins decode
///////////////////////////////////////////
always_comb begin
    if(opcode[1 : 0] == 2'b00)
        case(funct3)
            3'b000: begin
                c4sp_ins_addi_l1    = 1;
                c_ins_lw_l1         = 0;
                c_ins_sw_l1         = 0;
            end
            3'b010: begin
                c4sp_ins_addi_l1    = 0;
                c_ins_lw_l1         = 1;
                c_ins_sw_l1         = 0;  
            end
            3'b110: begin
                c4sp_ins_addi_l1    = 0;
                c_ins_lw_l1         = 0;
                c_ins_sw_l1         = 1;
            end
            default:
                begin
                    c4sp_ins_addi_l1 = 0;
                    c_ins_lw_l1 = 0;
                    c_ins_sw_l1 = 0;
                end
        endcase
    else begin
        c4sp_ins_addi_l1 = 0;
        c_ins_lw_l1 = 0;
        c_ins_sw_l1 = 0;
    end
end

//c.jal
always_comb begin
    if(opcode[1:0] == 2'b01 || funct3 == 3'b001) c_ins_jal_l1 = 1;
    else c_ins_jal_l1 = 0;
end

always_comb begin
    if(opcode[1 : 0] == 2'b01)
        case(funct3)
            3'b001: begin 
                c_jump_en_l1        = 1; 
                c_clear_l1          = 1; 
                c_ins_addi_l1       = 0;     
                c_ins_lui_l1        = 0;     
                c16sp_ins_addi_l1   = 0;         
                c_ins_srli_l1       = 0;     
                c_ins_srai_l1       = 0;     
                c_ins_andi_l1       = 0;     
                c_ins_and_l1        = 0;     
                c_ins_or_l1         = 0;     
                c_ins_xor_l1        = 0;     
                c_ins_sub_l1        = 0;     
                c_ins_beq_l1        = 0;     
                c_ins_bne_l1        = 0; 
            end //TODO: rd is x0
            3'b010: begin
                c_jump_en_l1        = 0;     
                c_clear_l1          = 0; 
                c_ins_addi_l1       = 1;     
                c_ins_lui_l1        = 0;     
                c16sp_ins_addi_l1   = 0;         
                c_ins_srli_l1       = 0;     
                c_ins_srai_l1       = 0;     
                c_ins_andi_l1       = 0;     
                c_ins_and_l1        = 0;     
                c_ins_or_l1         = 0;     
                c_ins_xor_l1        = 0;     
                c_ins_sub_l1        = 0;     
                c_ins_beq_l1        = 0;     
                c_ins_bne_l1        = 0;    
            end
            3'b011: begin
                unique if(rd_l1 == 'd2) begin c_ins_lui_l1 = 1; c16sp_ins_addi_l1 = 0; end
                else if(rd_l1 != 'd0)   begin c16sp_ins_addi_l1 = 1; c_ins_lui_l1 = 0; end
                else                    begin c_ins_lui_l1 = 0; c16sp_ins_addi_l1 = 0; end
                c_jump_en_l1        = 0;     
                c_clear_l1          = 0; 
                c_ins_addi_l1       = 0;             
                c_ins_srli_l1       = 0;     
                c_ins_srai_l1       = 0;     
                c_ins_andi_l1       = 0;     
                c_ins_and_l1        = 0;     
                c_ins_or_l1         = 0;     
                c_ins_xor_l1        = 0;     
                c_ins_sub_l1        = 0;     
                c_ins_beq_l1        = 0;     
                c_ins_bne_l1        = 0;
            end
            3'b100: begin 
                c_jump_en_l1        = 0;     
                c_clear_l1          = 0; 
                c_ins_addi_l1       = 0;     
                c_ins_lui_l1        = 0;     
                c16sp_ins_addi_l1   = 0; 
                unique if(ins_l1[11:10] == 2'b00)                           begin c_ins_srli_l1 = 1; c_ins_srai_l1 = 0; c_ins_andi_l1 = 0; c_ins_or_l1 = 0; c_ins_xor_l1 = 0; c_ins_sub_l1 = 0; c_ins_and_l1 = 0; end
                else if(ins_l1[11:10] == 2'b01)                             begin c_ins_srai_l1 = 1; c_ins_srli_l1 = 0; c_ins_andi_l1 = 0; c_ins_or_l1 = 0; c_ins_xor_l1 = 0; c_ins_sub_l1 = 0; c_ins_and_l1 = 0; end
                else if(ins_l1[11:10] == 'b10)                              begin c_ins_andi_l1 = 1; c_ins_srli_l1 = 0; c_ins_srai_l1 = 0; c_ins_or_l1 = 0; c_ins_xor_l1 = 0; c_ins_sub_l1 = 0; c_ins_and_l1 = 0; end
                else if((ins_l1[12:10] == 'b011) && (ins_l1[6:5] == 'b11))  begin c_ins_and_l1 = 1;  c_ins_srli_l1 = 0; c_ins_srai_l1 = 0; c_ins_andi_l1 = 0; c_ins_or_l1 = 0; c_ins_xor_l1 = 0; c_ins_sub_l1 = 0; end
                else if((ins_l1[12:10] == 'b011) && (ins_l1[6:5] == 'b10))  begin c_ins_or_l1 = 1;   c_ins_srli_l1 = 0; c_ins_srai_l1 = 0; c_ins_andi_l1 = 0; c_ins_xor_l1 = 0; c_ins_sub_l1 = 0; c_ins_and_l1 = 0; end
                else if((ins_l1[12:10] == 'b011) && (ins_l1[6:5] == 'b01))  begin c_ins_xor_l1 = 1;  c_ins_srli_l1 = 0; c_ins_srai_l1 = 0; c_ins_andi_l1 = 0; c_ins_or_l1 = 0; c_ins_sub_l1 = 0; c_ins_and_l1 = 0; end
                else if((ins_l1[12:10] == 'b011) && (ins_l1[6:5] == 'b00))  begin c_ins_sub_l1 = 1;  c_ins_srli_l1 = 0; c_ins_srai_l1 = 0; c_ins_andi_l1 = 0; c_ins_or_l1 = 0; c_ins_xor_l1 = 0; c_ins_and_l1 = 0; end
                else begin
                    c_ins_and_l1    = 0;
                    c_ins_or_l1     = 0;
                    c_ins_xor_l1    = 0;
                    c_ins_sub_l1    = 0;
                    c_ins_srli_l1   = 0;
                    c_ins_srai_l1   = 0;
                    c_ins_andi_l1   = 0;
                end
                c_ins_beq_l1        = 0;     
                c_ins_bne_l1        = 0; 
            end
            3'b101: begin 
                c_jump_en_l1        = 1; 
                c_clear_l1          = 1; 
                c_ins_addi_l1       = 0;     
                c_ins_lui_l1        = 0;     
                c16sp_ins_addi_l1   = 0;         
                c_ins_srli_l1       = 0;     
                c_ins_srai_l1       = 0;     
                c_ins_andi_l1       = 0;     
                c_ins_and_l1        = 0;     
                c_ins_or_l1         = 0;     
                c_ins_xor_l1        = 0;     
                c_ins_sub_l1        = 0;     
                c_ins_beq_l1        = 0;     
                c_ins_bne_l1        = 0;  
            end //TODO: rd is x1
            3'b110: 
                begin
                    c_jump_en_l1        = 0;     
                    c_clear_l1          = 0; 
                    c_ins_addi_l1       = 0;     
                    c_ins_lui_l1        = 0;     
                    c16sp_ins_addi_l1   = 0;         
                    c_ins_srli_l1       = 0;     
                    c_ins_srai_l1       = 0;     
                    c_ins_andi_l1       = 0;     
                    c_ins_and_l1        = 0;     
                    c_ins_or_l1         = 0;     
                    c_ins_xor_l1        = 0;     
                    c_ins_sub_l1        = 0;     
                    c_ins_beq_l1        = 1;     
                    c_ins_bne_l1        = 0;    
                end 
            3'b111: 
                begin
                    c_jump_en_l1        = 0;     
                    c_clear_l1          = 0; 
                    c_ins_addi_l1       = 0;     
                    c_ins_lui_l1        = 0;     
                    c16sp_ins_addi_l1   = 0;         
                    c_ins_srli_l1       = 0;     
                    c_ins_srai_l1       = 0;     
                    c_ins_andi_l1       = 0;     
                    c_ins_and_l1        = 0;     
                    c_ins_or_l1         = 0;     
                    c_ins_xor_l1        = 0;     
                    c_ins_sub_l1        = 0;     
                    c_ins_beq_l1        = 0;     
                    c_ins_bne_l1        = 1;    
                end 
            default:
                begin
                    c_jump_en_l1        = 0;     
                    c_clear_l1          = 0; 
                    c_ins_addi_l1       = 0;     
                    c_ins_lui_l1        = 0;     
                    c16sp_ins_addi_l1   = 0;         
                    c_ins_srli_l1       = 0;     
                    c_ins_srai_l1       = 0;     
                    c_ins_andi_l1       = 0;     
                    c_ins_and_l1        = 0;     
                    c_ins_or_l1         = 0;     
                    c_ins_xor_l1        = 0;     
                    c_ins_sub_l1        = 0;     
                    c_ins_beq_l1        = 0;     
                    c_ins_bne_l1        = 0;    
                end 
        endcase
    else begin
        c_jump_en_l1        = 0;     
        c_clear_l1          = 0; 
        c_ins_addi_l1       = 0;     
        c_ins_lui_l1        = 0;     
        c16sp_ins_addi_l1   = 0;         
        c_ins_srli_l1       = 0;     
        c_ins_srai_l1       = 0;     
        c_ins_andi_l1       = 0;     
        c_ins_and_l1        = 0;     
        c_ins_or_l1         = 0;     
        c_ins_xor_l1        = 0;     
        c_ins_sub_l1        = 0;     
        c_ins_beq_l1        = 0;     
        c_ins_bne_l1        = 0; 
    end
end

always_comb begin
    if(opcode[1 : 0] == 2'b10)
        case(funct3)
            3'b000: begin
                c_ins_slli_l1   = 1;
                csp_ins_lw_l1   = 0;
                c_ins_jalr_l1   = 0;
                cmv_ins_add_l1  = 0;
                c_ins_add_l1    = 0;
                csp_ins_sw_l1   = 0;
            end
            3'b010: begin 
                c_ins_slli_l1   = 0;
                csp_ins_lw_l1   = 1;
                c_ins_jalr_l1   = 0;
                cmv_ins_add_l1  = 0;
                c_ins_add_l1    = 0;
                csp_ins_sw_l1   = 0;
            end
            3'b100: begin
                    c_ins_slli_l1   = 0;
                    csp_ins_lw_l1   = 0;
                    csp_ins_sw_l1   = 0;
                    unique if((ins_l1[12] == 1) && (rs1_l1 != 'd0) && (rs2_l1 == 'd0))      begin c_ins_jalr_l1 = 1; cmv_ins_add_l1 = 0; c_ins_add_l1 = 0;  end
                    else if(ins_l1[12] == 0)                                                begin cmv_ins_add_l1  = 1; c_ins_jalr_l1 = 0; c_ins_add_l1 = 0; end 
                    else if((ins_l1[12] == 1) && (rs2_l1 != 'd0) && (rs2_l1 != 'd0))        begin c_ins_add_l1 = 1; c_ins_jalr_l1 = 0; cmv_ins_add_l1 = 0;  end//TODO
                    else                                                                    begin c_ins_add_l1 = 0; c_ins_jalr_l1 = 0; cmv_ins_add_l1 = 0;  end
                end
            3'b110: begin
                    c_ins_slli_l1   = 0;
                    csp_ins_lw_l1   = 0;
                    c_ins_jalr_l1   = 0;
                    cmv_ins_add_l1  = 0;
                    c_ins_add_l1    = 0;
                    csp_ins_sw_l1   = 1;
                end

            default:
                begin
                    c_ins_slli_l1   = 0;
                    csp_ins_lw_l1   = 0;
                    c_ins_jalr_l1   = 0;
                    cmv_ins_add_l1  = 0;
                    c_ins_add_l1    = 0;
                    csp_ins_sw_l1   = 0;
                end
        endcase
    else begin
        c_ins_slli_l1   = 0;
        csp_ins_lw_l1   = 0;
        c_ins_jalr_l1   = 0;
        cmv_ins_add_l1  = 0;
        c_ins_add_l1    = 0;
        csp_ins_sw_l1   = 0;
    end
end

///////////////////////////////////////////
//get registers
///////////////////////////////////////////
//rd
always_comb begin
    if(ins_c_l1) 
        if(opcode[1:0] == 'b00 && funct3 < 'b100)
            rd_l1 = {2'b01, ins_l1[4 : 2]}; /* 高位没有补01, 你需要把3位扩成5位, 同时+8, 所以补01, 下面的 rs1 和 rs2 也要改 check*/
        else if(opcode[1:0] == 'b01 && funct3 == 'b100)
            rd_l1 = {2'b01, ins_l1[9 : 7]};
        else
            rd_l1 = ins_l1[11 : 7];
    else
        rd_l1 = ins_l1[11 : 7];
end

//rs1
always_comb begin
    if(ins_c_l1) begin
        if(((opcode == 2'b01) && (funct3 == 3'b100)) || (opcode == 2'b00))
            rs1_l1 = {2'b01, ins_l1[9 : 7]};
        else if(opcode == 2'b10 && funct3 == 3'b100 && ins_l1[12] == 0)
            rs1_l1 = 5'd0;       
        else
            rs1_l1 = ins_l1[11 : 7];
    end
    else
        rs1_l1 = ins_l1[19 : 15];
end

//rs2
always_comb begin
    if(ins_c_l1) begin
        rs2_l1 = {2'b01, ins_l1[4 : 2]};
    end    
    else 
        rs2_l1 = ins_l1[24 : 20];
end

///////////////////////////////////////////
//get imm & jal_addr operate
///////////////////////////////////////////
always_comb begin
    if(ins_c_l1) begin
        if(opcode[1 : 0] == 2'b00)
            case(funct3)
                3'b000: begin imm_l1 = {{25{ins_l1[10]}}, ins_l1[9:7], ins_l1[12:11], ins_l1[5], ins_l1[6]};jump_addr_l1 = 32'h00;  end //sign
                3'b010: begin imm_l1 = {{26'b0},ins_l1[12:10],ins_l1[6],2'b00}; jump_addr_l1 = 32'h00;                      end
                3'b110: begin imm_l1 = {{25'b0},ins_l1[12:10],ins_l1[6],2'b00}; jump_addr_l1 = 32'h00;                      end
                default:
                    begin
                        imm_l1 = 32'h00;
                        jump_addr_l1 = 32'h00;  
                    end
            endcase
        else if(opcode[1 : 0] == 2'b01)
            case(funct3)
                3'b001: 
                    begin
                        imm_l1  = {{21{ins_l1[12]}}, ins_l1[8], ins_l1[10:9], ins_l1[6], ins_l1[7],ins_l1[2], ins_l1[11],ins_l1[5:3],1'b0};
                        jump_addr_l1 = {{21{ins_l1[12]}}, ins_l1[8], ins_l1[10:9], ins_l1[6], ins_l1[7],ins_l1[2], ins_l1[11],ins_l1[5:3],1'b0};
                    end
                3'b010: begin imm_l1 = {26'b0,ins_l1[12],ins_l1[6:2]}; jump_addr_l1 = 32'h00; end
                3'b101: 
                    begin
                        imm_l1 = {{21{ins_l1[12]}}, ins_l1[8], ins_l1[10:9], ins_l1[6], ins_l1[7],ins_l1[2], ins_l1[11],ins_l1[5:3],1'b0};
                        jump_addr_l1 = {{21{ins_l1[12]}}, ins_l1[8], ins_l1[10:9], ins_l1[6], ins_l1[7],ins_l1[2], ins_l1[11],ins_l1[5:3],1'b0};
                    end
                3'b110: begin imm_l1 = {{24{ins_l1[12]}}, ins_l1[6:5], ins_l1[2], ins_l1[11:10], ins_l1[4:3], 1'b0}; jump_addr_l1 = 32'h00; end
                3'b111: begin imm_l1 = {{24{ins_l1[12]}}, ins_l1[6:5], ins_l1[2], ins_l1[11:10], ins_l1[4:3], 1'b0}; jump_addr_l1 = 32'h00; end
                default:
                    begin
                        imm_l1 = 32'h00;
                        jump_addr_l1 = 32'h00;
                    end
            endcase
        else if(opcode[1 : 0] == 2'b10)
            case(funct3)
                3'b010: begin imm_l1 = {{24'b0},ins_l1[3:2], ins_l1[12], ins_l1[6:4],2'b00}; jump_addr_l1 = 32'h00;  end           
                3'b110: begin imm_l1 = {{25'b0}, ins_l1[8:7], ins_l1[11:9], 2'b00};           jump_addr_l1 = 32'h00;  end   
                default:
                    begin
                        imm_l1 = 32'h00;
                        jump_addr_l1 = 32'h00;  
                    end
            endcase
    end
    else if(opcode == 'b0110111 || opcode == 'b0010111) begin
        imm_l1 = {{12'b0},ins_l1[31 : 12]};
        jump_addr_l1 = 32'h00;  
    end
    else if((opcode == 'b1100011)) begin
        imm_l1 = {{21{ins_l1[31]}}, ins_l1[7], ins_l1[30:25], ins_l1[11:8]}; //sign imm
        jump_addr_l1 = 32'h00;  
    end
    else if((opcode == 'b0000011) || (opcode == 'b0010011)) begin
        jump_addr_l1 = 32'h00;  
        imm_l1 = {22'b0, ins_l1[31 : 20]};
    end
    else if(opcode == 'b0011011) begin
        jump_addr_l1 = 32'h00;  
        if(funct3 == 3'b000 || funct3 == 3'b010)
            imm_l1 = {{21{ins_l1[11]}},ins_l1[10:0]}; //sign imm
        else    
            imm_l1 = {22'b0, ins_l1[31 : 20]};
    end
    else if(opcode == 'b1101111) begin
        jump_addr_l1 = {{19{ins_l1[31]}}, ins_l1[19:12], ins_l1[20], ins_l1[30:21]};
        imm_l1 = jump_addr_l1; //sign imm and jal_addr!!
    end
    else if((opcode == 'b0100011)) begin
        imm_l1 = {20'b0, ins_l1[31 : 25], ins_l1[11 : 7]};
        jump_addr_l1 = 32'h00;  
    end
    else    
        imm_l1 = 32'h00; /* 虽然这么写没问题, 但是为啥要写5个0 ^v^ check*/
        jump_addr_l1 = 32'h00;
end
endmodule
