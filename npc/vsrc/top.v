module top(
input clk,
input rst,
output [63:0] pc_cur
);

reg [63:0] pc;
reg [63:0] dnpc;
initial begin
    pc = 64'h80000000;
    dnpc = 64'h80000000;
end

assign pc_cur = dnpc;
always @(posedge clk) begin
    pc <= dnpc;
end

wire    [31:0]  inst;

wire    [2:0]   rf_wr_sel;
reg     [63:0]  rf_wd;  
wire            rf_wr_en;
wire    [63:0]  rf_rd1,rf_rd2;
  
wire [63:0] pc_plus4;
wire do_jump;
wire JUMP;
wire jalr_jump;
  
wire    [2:0]   imm_code;
wire    [63:0]  imm_out;
  
wire    [2:0]   comp_ctrl;
wire		BrE;

wire            alu_a_sel;
wire            alu_b_sel;
wire    [63:0]  alu_a,alu_b,alu_out; 
wire    [4:0]   alu_ctrl;
  
wire    [2:0]   dm_rd_ctrl;
wire    [2:0]   dm_wr_ctrl;
wire    [63:0]  dm_dout;
  
always@(*)
begin
    case(rf_wr_sel)
        3'b001:  rf_wd = pc_plus4;
        3'b010:  rf_wd = alu_out;
        3'b011:  rf_wd = dm_dout;
        3'b100:  rf_wd = imm_out;
        default:rf_wd = 64'h0;
    endcase
end
assign		pc_plus4 = pc + 64'h4;
assign		JUMP = BrE || do_jump;
assign      alu_a = alu_a_sel ? rf_rd1 : pc ;
assign      alu_b = alu_b_sel ? imm_out : rf_rd2 ;

reg_file reg_file0(
    .clk        (clk),
    .A1         (inst[19:15]),
    .A2         (inst[24:20]),
    .A3         (inst[11:7]),
	.WD         (rf_wd),
	.WE         (rf_wr_en),
	.RD1        (rf_rd1),
    .RD2        (rf_rd2)
);
pc	pc0(
    .clk        (clk),
    .rst		(rst),
    .JUMP		(JUMP),
    .jalr_jump  (jalr_jump),
    .JUMP_PC    (pc + imm_out),
    .jalr_pc    (rf_rd1 + imm_out),
    .PC         (pc),
    .DNPC       (dnpc)
);
imm	imm0(
    .inst		(inst),
    .func       (imm_code),
	.out    	(imm_out)
);
branch branch0(
	.REG1		(rf_rd1),
    .REG2		(rf_rd2),
	.Type		(comp_ctrl),
    .BrE		(BrE)
);
alu alu0(
    .SrcA     	(alu_a),
    .SrcB      	(alu_b),
	.func   	(alu_ctrl),
    .ALUout    	(alu_out)
);
mem mem0(
    .clk        (clk),
    .im_addr    (pc),
    .im_dout    (inst),
	.dm_rd_ctrl (dm_rd_ctrl),
	.dm_wr_ctrl (dm_wr_ctrl),
    .dm_addr    (alu_out),
	.dm_din     (rf_rd2),
	.dm_dout    (dm_dout)
);
ctrl ctrl0(
	.inst       (inst),
	.rf_wr_en   (rf_wr_en),
	.rf_wr_sel  (rf_wr_sel),
    .do_jump    (do_jump),
	.BrType		(comp_ctrl),
	.alu_a_sel  (alu_a_sel),
    .alu_b_sel  (alu_b_sel),
	.alu_ctrl   (alu_ctrl),
	.dm_rd_ctrl (dm_rd_ctrl),
    .dm_wr_ctrl (dm_wr_ctrl),
    .type_code  (imm_code),
    .jalr_jump  (jalr_jump)
);

endmodule