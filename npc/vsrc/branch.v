module branch(         
input [63:0]	REG1,
input [63:0] 	REG2,
input [2:0]		Type,
output     reg     BrE
);
wire signed 	[63:0] signed_REG1;
wire signed 	[63:0] signed_REG2;
wire unsigned 	[63:0] unsigned_REG1;
wire unsigned 	[63:0] unsigned_REG2;

assign signed_REG1 = REG1;
assign signed_REG2 = REG2; 
assign unsigned_REG1 = REG1;
assign unsigned_REG2 = REG2; 
always@(*)
begin
	case(Type)
        3'b001: BrE = (signed_REG1 == signed_REG2)?1:0;
        3'b010: BrE = (signed_REG1 >= signed_REG2)?1:0;
        3'b011: BrE = (unsigned_REG1 >= unsigned_REG2)?1:0;
        3'b100: BrE = (signed_REG1 < signed_REG2)?1:0;
        3'b101: BrE = (unsigned_REG1 < unsigned_REG2)?1:0;
        3'b110: BrE = (unsigned_REG1 != unsigned_REG2)?1:0;
        default: BrE = 0;
	endcase
end
endmodule