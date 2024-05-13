module fifo_tb();

reg clk, rstn, we, re, sft, lfd;
reg [7:0] din;
wire empty, full;
wire [7:0] dout;
integer k ;

fifo UUT(clk,rstn,we,re,sft,lfd,din,empty,full,dout);

initial begin
clk = 1'b0;
forever #10 clk = ~clk;
end

task start;
begin
din = 8'b0;
we  = 1'b0;
re  = 1'b0;
end
endtask

task RESET;
begin
@ (negedge clk) rstn = 1'b0;
@ (negedge clk) rstn = 1'b1;
end
endtask

task SRESET;
begin
@ (negedge clk) sft = 1'b1;
@ (negedge clk) sft = 1'b0;
end
endtask

task write;
reg [7:0] PLD, parity, header;
reg [5:0] PLD_len;
reg [1:0] addr;
begin
@ (negedge clk)
PLD_len = 6'd14;
addr = 2'd1;
header = {PLD_len, addr};
lfd = 1'b1;
we = 1'b1;
for( k = 0; k<PLD_len ; k = k+1) begin
@(negedge clk)
lfd = 1'b0;
PLD = {$random}%256;
din = PLD;
end 
@(negedge clk)
parity = $random%256;
din = parity;
end 
endtask

task read;
begin
@(negedge clk)
re = 1'b1;
end 
endtask

initial begin
start;
RESET;
SRESET;
write;
read;
#350
RESET; 
SRESET;
we = 1'b0;  
fork
write;
read;
join
#1000 $finish;
end 

endmodule 
