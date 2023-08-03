module ctrl(
input     [31:0]  inst,
output            rf_wr_en,
output reg    [2:0]   rf_wr_sel,
output            do_jump,
output reg    [2:0]   BrType,
output            alu_a_sel,
output            alu_b_sel,
output reg    [4:0]   alu_ctrl,
output reg    [2:0]   dm_rd_ctrl,
output reg    [2:0]   dm_wr_ctrl,
output reg    [2:0]   type_code,
output            jalr_jump
);

import "DPI-C" function void set_npctrap(int i);
import "DPI-C" function void set_npcinv(int i);

wire    [6:0]   opcode;
wire    [2:0]   funct3;
wire    [6:0]   funct7;

wire    is_add;
wire    is_addi;
wire    is_addiw;
wire    is_addw;
wire    is_and;
wire    is_andi;
wire    is_auipc;
wire    is_beq;
wire    is_bge;
wire    is_bgeu;
wire    is_blt;
wire    is_bltu;
wire    is_bne;
wire    is_ebreak;
wire    is_ecall;
wire    is_jal;
wire    is_jalr;
wire    is_lb;
wire    is_lbu;
wire    is_ld;
wire    is_lh;
wire    is_lhu;
wire    is_lw;
wire    is_lwu;
wire    is_lui;
wire    is_mret;
wire    is_or;
wire    is_ori;
wire    is_sb;
wire    is_sd;
wire    is_sh;
wire    is_sw;
wire    is_sll;
wire    is_slli;
wire    is_slliw;
wire    is_sllw;
wire    is_slt;
wire    is_slti;
wire    is_sltiu;
wire    is_sltu;
wire    is_sra;
wire    is_srai;
wire    is_sraiw;
wire    is_sraw;
wire    is_sret;
wire    is_srl;
wire    is_srli;
wire    is_srliw;
wire    is_srlw;
wire    is_sub;
wire    is_subw;
wire    is_xor;
wire    is_xori;
wire    is_remw;
wire    is_divw;
wire    is_mulw;
wire    is_mul;

wire    is_inv_inst;

wire    is_add64_type;
wire    is_add32_type;
wire    is_add_type;
wire    is_load_type;
wire    is_u_type;
wire    is_jump_type;
wire    is_b_type;
wire    is_r_type;
wire    is_i_type;
wire    is_s_type;
wire    is_c_type;

assign  opcode  = inst[6:0];
assign  funct7  = inst[31:25];
assign  funct3  = inst[14:12];

assign  is_add   = (opcode == 7'b0110011) && (funct3 == 3'b0) && (funct7 == 7'b0);
assign  is_addi  = (opcode == 7'b0010011) && (funct3 == 3'b0);
assign  is_addiw = (opcode == 7'b0011011) && (funct3 == 3'b0);
assign  is_addw  = (opcode == 7'b0111011) && (funct3 == 3'b0) && (funct7 == 7'b0);
assign  is_and   = (opcode == 7'b0110011) && (funct3 == 3'b111) && (funct7 == 7'b0);
assign  is_andi  = (opcode == 7'b0010011) && (funct3 == 3'b111);
assign  is_auipc = (opcode == 7'b0010111);
assign  is_beq   = (opcode == 7'b1100011) && (funct3 == 3'b0);
assign  is_bge   = (opcode == 7'b1100011) && (funct3 == 3'b101);
assign  is_bgeu  = (opcode == 7'b1100011) && (funct3 == 3'b111);
assign  is_blt   = (opcode == 7'b1100011) && (funct3 == 3'b100);
assign  is_bltu  = (opcode == 7'b1100011) && (funct3 == 3'b110);
assign  is_bne   = (opcode == 7'b1100011) && (funct3 == 3'b001);
assign  is_ebreak = (inst == 32'b00000000000100000000000001110011);
assign  is_ecall  = (inst == 32'b00000000000000000000000001110011);
assign  is_jal   = (opcode == 7'b1101111);
assign  is_jalr  = (opcode == 7'b1100111) && (funct3 == 3'b000);
assign  is_lb    = (opcode == 7'b0000011) && (funct3 == 3'b0);
assign  is_lbu   = (opcode == 7'b0000011) && (funct3 == 3'b100);
assign  is_ld    = (opcode == 7'b0000011) && (funct3 == 3'b011);
assign  is_lh    = (opcode == 7'b0000011) && (funct3 == 3'b001);
assign  is_lhu   = (opcode == 7'b0000011) && (funct3 == 3'b101);
assign  is_lw    = (opcode == 7'b0000011) && (funct3 == 3'b010);
assign  is_lwu   = (opcode == 7'b0000011) && (funct3 == 3'b110);
assign  is_lui   = (opcode == 7'b0110111);
assign  is_mret  = (inst == 32'b00110000001000000000000001110011);
assign  is_or    = (opcode == 7'b0110011) && (funct3 == 3'b110) && (funct7 == 7'b0);
assign  is_ori   = (opcode == 7'b0010011) && (funct3 == 3'b110);
assign  is_sb    = (opcode == 7'b0100011) && (funct3 == 3'b0);
assign  is_sd    = (opcode == 7'b0100011) && (funct3 == 3'b011);
assign  is_sh    = (opcode == 7'b0100011) && (funct3 == 3'b001);
assign  is_sw    = (opcode == 7'b0100011) && (funct3 == 3'b010);
assign  is_sll   = (opcode == 7'b0110011) && (funct3 == 3'b001) && (funct7 == 7'b0);
assign  is_slli  = (opcode == 7'b0010011) && (funct3 == 3'b001) && (inst[31:26] == 6'b0);
assign  is_slliw = (opcode == 7'b0011011) && (funct3 == 3'b001) && (funct7 == 7'b0);
assign  is_sllw  = (opcode == 7'b0111011) && (funct3 == 3'b001) && (funct7 == 7'b0);
assign  is_slt   = (opcode == 7'b0110011) && (funct3 == 3'b010) && (funct7 == 7'b0);
assign  is_slti  = (opcode == 7'b0010011) && (funct3 == 3'b010);
assign  is_sltiu = (opcode == 7'b0010011) && (funct3 == 3'b011);
assign  is_sltu  = (opcode == 7'b0110011) && (funct3 == 3'b011) && (funct7 == 7'b0);
assign  is_sra   = (opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0100000);
assign  is_srai  = (opcode == 7'b0010011) && (funct3 == 3'b101) && (inst[31:26] == 6'b010000);
assign  is_sraiw = (opcode == 7'b0011011) && (funct3 == 3'b101) && (funct7 == 7'b0100000);
assign  is_sraw  = (opcode == 7'b0111011) && (funct3 == 3'b101) && (funct7 == 7'b0100000);
assign  is_sret  = (inst == 32'b00010000001000000000000001110011);
assign  is_srl   = (opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0);
assign  is_srli  = (opcode == 7'b0010011) && (funct3 == 3'b101) && (inst[31:26] == 6'b0);
assign  is_srliw = (opcode == 7'b0011011) && (funct3 == 3'b101) && (funct7 == 7'b0);
assign  is_srlw  = (opcode == 7'b0111011) && (funct3 == 3'b101) && (funct7 == 7'b0);
assign  is_sub   = (opcode == 7'b0110011) && (funct3 == 3'b0) && (funct7 == 7'b0100000);
assign  is_subw  = (opcode == 7'b0111011) && (funct3 == 3'b0) && (funct7 == 7'b0100000);
assign  is_xor   = (opcode == 7'b0110011) && (funct3 == 3'b100) && (funct7 == 7'b0);
assign  is_xori  = (opcode == 7'b0010011) && (funct3 == 3'b100);
assign  is_remw  = (opcode == 7'b0111011) && (funct3 == 3'b110) && (funct7 == 7'b0000001);
assign  is_divw  = (opcode == 7'b0111011) && (funct3 == 3'b100) && (funct7 == 7'b0000001);
assign  is_mulw  = (opcode == 7'b0111011) && (funct3 == 3'b0) && (funct7 == 7'b0000001);
assign  is_mul   = (opcode == 7'b0110011) && (funct3 == 3'b0) && (funct7 == 7'b0000001);

assign  is_inv_inst = !(is_add | is_addi | is_addiw | is_addw | is_and | is_andi | is_auipc |
                        is_beq | is_bge | is_bgeu | is_blt | is_bltu | is_bne | is_ebreak |
                        is_ecall | is_jal | is_jalr | is_lb | is_lbu | is_ld | is_lh | is_lhu |
                        is_lw | is_lwu | is_lui | is_mret | is_or | is_ori | is_sb | is_sd |
                        is_sh | is_sw | is_sll | is_slli | is_slliw | is_sllw | is_slt | is_slti |
                        is_sltiu | is_sltu | is_sra | is_srai | is_sraiw | is_sraw | is_sret | is_srl |
                        is_srli | is_srliw | is_srlw | is_sub | is_subw | is_xor | is_xori | is_remw |
                        is_divw | is_mulw | is_mul);

assign  jalr_jump   = is_jalr;

assign  is_i_type    = is_addi | is_addiw | is_andi | is_jalr | is_lb | is_lbu
                        | is_ld | is_lh | is_lhu | is_lw | is_lwu | is_ori
                        | is_slti | is_sltiu | is_xori | is_slli | is_srli | is_srai
                        | is_srliw | is_slliw | is_sraiw;
assign  is_u_type   = is_auipc | is_lui;
assign  is_b_type   = is_beq | is_bge | is_bgeu | is_blt | is_bltu | is_bne;
assign  is_jump_type= is_jal | is_jalr;
assign  is_s_type   = is_sb | is_sd | is_sh | is_sw;

assign  is_add64_type = is_add | is_addi | is_auipc | is_load_type | is_s_type;
assign  is_add32_type = is_addiw | is_addw;
assign  is_add_type   = is_add64_type | is_add32_type;
assign  is_load_type  = is_lb | is_lbu | is_ld | is_lh | is_lhu | is_lw | is_lwu;

assign  is_r_type   = is_add | is_sub | is_sll | is_slt | is_sltu | is_xor 
                    | is_srl | is_sra | is_or | is_and | is_addw | is_subw | is_sllw
                    | is_remw | is_divw | is_mulw | is_mul | is_sraw | is_srlw;


// counting-type insts in i-type
assign is_c_type = is_jalr | is_addi | is_slti | is_sltiu | is_xori | is_ori | is_andi
                    | is_slli | is_srli | is_srai | is_addiw | is_srliw | is_slliw 
                    | is_sraiw;
//rf_wr_en  
assign rf_wr_en     =  (is_u_type | is_jump_type | is_load_type | is_i_type | is_r_type) ? 1 : 0;  

//[2:0]rf_wr_sel
always@(*)
begin
    if (is_jalr | is_jal)
        rf_wr_sel = 3'b001;
    else if (is_lui)
        rf_wr_sel = 3'b100;
    else if (is_c_type | is_r_type | is_u_type)
        rf_wr_sel = 3'b010;
    else if (is_load_type)
        rf_wr_sel = 3'b011;
    else rf_wr_sel = 3'b000;
end  
  
//do_jump
assign do_jump      =  (is_jal | is_jalr)?1:0 ;
  
//[2:0]BrType
always@(*)
begin
	if (is_beq)
        BrType = 3'b001;
    else if (is_bge)
        BrType = 3'b010;
    else if (is_bgeu)
        BrType = 3'b011;
    else if (is_blt)
        BrType = 3'b100;
    else if (is_bltu)
        BrType = 3'b101;
    else if (is_bne)
        BrType = 3'b110;
    else BrType = 0;
end
  
//alu_a_sel
assign alu_a_sel    =  (is_r_type | is_i_type | is_s_type)?1:0;

//alu_b_sel  
assign alu_b_sel    =  is_r_type?0:1 ;

//alu_ctrl
always@(*)
begin
    if (is_add64_type)
        alu_ctrl = 5'b00001;
    else if (is_add32_type) 
        alu_ctrl = 5'b00010;
    else if (is_and | is_andi)
        alu_ctrl = 5'b00011;
    else if (is_or | is_ori)
        alu_ctrl = 5'b00101;
    else if (is_sll | is_slli)
        alu_ctrl = 5'b00110;
    else if (is_slliw | is_sllw)
        alu_ctrl = 5'b00111;
    else if (is_slt | is_slti)
        alu_ctrl = 5'b01000;
    else if (is_sltiu | is_sltu)
        alu_ctrl = 5'b01001;
    else if (is_sra | is_srai)
        alu_ctrl = 5'b01010;
    else if (is_sraiw | is_sraw)
        alu_ctrl = 5'b01011;
    else if (is_srl | is_srli)
        alu_ctrl = 5'b01100;
    else if (is_srliw | is_srlw)
        alu_ctrl = 5'b01101;
    else if (is_sub)
        alu_ctrl = 5'b01110;
    else if (is_subw) 
        alu_ctrl = 5'b01111;
    else if (is_xor | is_xori)
        alu_ctrl = 5'b10000;
    else if (is_remw) 
        alu_ctrl = 5'b10001;
    else if (is_divw)
        alu_ctrl = 5'b10010;
    else if (is_mulw)
        alu_ctrl = 5'b10011;
    else if (is_mul)
        alu_ctrl = 5'b10100;
    else alu_ctrl = 0;
end

//[2:0]dm_rd_ctrl
always@(*)
begin
    if (is_lb)
        dm_rd_ctrl = 3'b001;
    else if (is_lbu)
        dm_rd_ctrl = 3'b010;
    else if (is_lh)
        dm_rd_ctrl = 3'b011;
    else if (is_lhu)
        dm_rd_ctrl = 3'b100;
    else if (is_lw)
        dm_rd_ctrl = 3'b101;
    else if (is_lwu)
        dm_rd_ctrl = 3'b110;
    else if (is_ld)
        dm_rd_ctrl = 3'b111;
    else dm_rd_ctrl = 0;
end

//[2:0]dm_wr_ctrl
always@(*)
begin
    if (is_sb)
        dm_wr_ctrl = 3'b001;
    else if (is_sh)
        dm_wr_ctrl = 3'b010;
    else if (is_sw)
        dm_wr_ctrl = 3'b011;
    else if (is_sd)
        dm_wr_ctrl = 3'b100;
    else dm_wr_ctrl = 0;
end  

//[2:0]type_code
always@(*)
begin
    if (is_i_type)
        type_code = 3'b001;
    else if (is_u_type)
        type_code = 3'b010;
    else if (is_b_type)
        type_code = 3'b011;
    else if (is_jal)
        type_code = 3'b100;
    else if (is_s_type)
        type_code = 3'b101;
    else
        type_code = 3'b0;
end

//npc_trap
always@(*) begin
    if (is_ebreak) set_npctrap(1);
    else set_npctrap(0);
end

//npc invalid instruction
always@(*) begin
    if (is_inv_inst) set_npcinv(1);
    else set_npcinv(0);
end

endmodule
