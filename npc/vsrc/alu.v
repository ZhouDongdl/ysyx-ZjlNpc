module alu(
input [63:0] SrcA,SrcB,
input [4:0]  func,
output reg [63:0] ALUout
);

wire signed [63:0] signed_a;
wire signed [63:0] signed_b;
wire unsigned [63:0] unsigned_a;
wire unsigned [63:0] unsigned_b;
reg [63:0] out;

assign signed_a = SrcA;
assign signed_b = SrcB;
assign unsigned_a = SrcA;
assign unsigned_b = SrcB;

always@(*)
begin
	case(func)
		    5'b00001: begin
          out = signed_a + signed_b;
          ALUout = out;
        end
        5'b00010: begin
          out = signed_a + signed_b;
          ALUout = {{33{out[31]}}, out[30:0]};
        end
        5'b00011: begin
          out = signed_a & signed_b;
          ALUout = out;
        end
        5'b00101: begin
          out = signed_a | signed_b;
          ALUout = out;
        end
        5'b00110: begin
          out = signed_a << signed_b[5:0];
          ALUout = out;
        end
        5'b00111: begin
          out = signed_a << signed_b;
          ALUout = {{33{out[31]}}, out[30:0]};
        end
        5'b01000: begin
          out = 0;
          ALUout = (signed_a < signed_b) ? 1 : 0;
        end
        5'b01001: begin
          out = 0;
          ALUout = (unsigned_a < unsigned_b) ? 1 : 0;
        end
        5'b01010: begin
          out = signed_a >>> signed_b[5:0];
          ALUout = out;
        end
        5'b01011: begin
          out = {{32{signed_a[31]}}, signed_a[31:0]} >>> signed_b[4:0];
          ALUout = {{33{out[31]}}, out[30:0]};
        end
        5'b01100: begin
          out = unsigned_a >> unsigned_b[5:0];
          ALUout = out;
        end
        5'b01101: begin
          out = {32'b0, unsigned_a[31:0] >> unsigned_b[4:0]};
          ALUout = {{33{out[31]}}, out[30:0]};
        end
        5'b01110: begin
          out = signed_a - signed_b;
          ALUout = out;
        end
        5'b01111: begin
          out = signed_a - signed_b;
          ALUout = {{33{out[31]}}, out[30:0]};
        end
        5'b10000: begin
          out = signed_a ^ signed_b;
          ALUout = {{33{out[31]}}, out[30:0]};
        end
        5'b10001: begin
          out = {32'b0, {signed_a[31:0]}} % {32'b0, {signed_b[31:0]}};
          ALUout = {{33{out[31]}}, out[30:0]};
        end
        5'b10010: begin
          out = {32'b0, {signed_a[31:0]}} / {32'b0, {signed_b[31:0]}};
          ALUout = {{33{out[31]}}, out[30:0]};
        end
        5'b10011: begin
          out = signed_a * signed_b;
          ALUout = {{33{out[31]}}, out[30:0]};
        end
        5'b10100: begin
          out = signed_a * signed_b;
          ALUout = out;
        end
        default: begin
          out = 0;
          ALUout = 0;
        end
	endcase
end 

endmodule