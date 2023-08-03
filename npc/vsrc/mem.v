module mem(
input           clk,
input   [63:0]  im_addr,
output  [31:0]  im_dout,
input   [2:0]   dm_rd_ctrl,
input   [2:0]   dm_wr_ctrl,
input   [63:0]  dm_addr,
input   [63:0]  dm_din,
output reg  [63:0]  dm_dout
);

import "DPI-C" function int get_inst(input longint addr);
import "DPI-C" function longint read_mem(input longint addr, int len);
import "DPI-C" function void write_mem(input longint addr, int len, input longint date);

reg     [3:0]   byte_en;
reg     [63:0]  mem_out;

assign im_dout = get_inst(im_addr[63:0]);

/*由于不能跨单位读取数据，地址最低两位的数值决定了当前单位能读取到的数据，即mem_out,
  dm_addr[2:0]相当于一条数据的内部地址，即对应的字节*/

always@(negedge clk)
begin
    case(dm_rd_ctrl)                                         
        3'b001: begin
            mem_out = read_mem(dm_addr, 1);
            dm_dout = {{57{mem_out[7]}}, mem_out[6:0]};
        end
        3'b010: begin 
            mem_out = read_mem(dm_addr, 1);
            dm_dout = {56'd0, mem_out[7:0]};
        end
        3'b011: begin
            mem_out = read_mem(dm_addr, 2);
            dm_dout = {{49{mem_out[15]}}, mem_out[14:0]};
        end
        3'b100: begin
            mem_out = read_mem(dm_addr, 2);
            dm_dout = {48'd0, mem_out[15:0]};
        end
        3'b101: begin
            mem_out = read_mem(dm_addr, 4);
            dm_dout = {{33{mem_out[31]}}, mem_out[30:0]};
        end
        3'b110: begin
            mem_out = read_mem(dm_addr, 4);
            dm_dout = {32'd0, mem_out[31:0]};
        end
        3'b111: begin
            mem_out = read_mem(dm_addr, 8);
            dm_dout = mem_out;
        end
        default: begin 
            mem_out = 0;
            dm_dout = 0;
        end
    endcase
end

always@(negedge clk)
begin
   case(dm_wr_ctrl)
        3'b001: write_mem(dm_addr, 1, dm_din);
        3'b010: write_mem(dm_addr, 2, dm_din);
        3'b011: write_mem(dm_addr, 4, dm_din);
        3'b100: write_mem(dm_addr, 8, dm_din);
        default: ;
   endcase
end

endmodule