module reg_file(
input         clk,
input  [4:0]  A1,A2,A3,
input  [63:0] WD,
input 	      WE,
output [63:0] RD1,RD2
);
reg [63:0] reg_file[0:31];


import "DPI-C" function void update_regs(int idx, input longint x);

//初始化寄存器堆
integer i;
initial
begin
    for(i=0;i<32;i=i+1) reg_file[i] = 0;
end

//写入寄存器
always@(negedge clk) begin
    if (WE && A3 != 0) begin
        reg_file[A3] <= WD;
    end
end

integer j;

always@(*) begin
    for (j = 0; j < 32; j = j + 1) update_regs(j, reg_file[j]);
end


//读取寄存器
    assign RD1 = reg_file[A1];
    assign RD2 = reg_file[A2];

endmodule