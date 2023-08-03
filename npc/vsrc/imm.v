module imm(
input 	    [31:0] inst,
input       [2:0] func,
output reg	[63:0] out
);

//立即数扩展
always@(*)
begin
	case(func)
        3'b001: out = {{53{inst[31]}}, inst[30:20]}; //I
        3'b010: out = {{33{inst[31]}}, inst[30:12], 12'b0}; //U
        3'b011: out = {{52{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0}; //B
        3'b100: out = {{44{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0}; //J
        3'b101: out = {{53{inst[31]}}, inst[30:25], inst[11:7]}; //S
        default: out = 64'h0; //其他
	endcase
end 

endmodule