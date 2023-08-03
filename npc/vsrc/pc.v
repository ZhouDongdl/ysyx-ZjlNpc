module pc(
input              clk,
input              rst,
input              JUMP,
input              jalr_jump,
input       [63:0] JUMP_PC,
input       [63:0] jalr_pc,
input       [63:0] PC,
output reg  [63:0] DNPC);

wire [63:0] pc_plus4;
assign pc_plus4 = PC + 64'h4;

//计算PC
always@(*)
begin
    if (rst) DNPC = 64'h80000000;
    else if (jalr_jump) DNPC = jalr_pc & (~1);
    else if (JUMP) DNPC = JUMP_PC;
    else DNPC = pc_plus4;
end

endmodule