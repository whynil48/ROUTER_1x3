module fsm_tb();

reg clk, resetn, pkt_valid, parity_done, soft_reset_0,soft_reset_1,soft_reset_2, fifo_full, low_pkt_valid, fifo_empty0, fifo_empty1, fifo_empty2; 
reg [1:0] datain;
wire busy, detect_add, ld_state,laf_state, full_state, write_en_reg, rst_int_reg, lfd_state;

fsm DUT         (.clk(clk),
				  .resetn(resetn), 
				  .pkt_valid(pkt_valid), 
				  .data_in(datain), 
				  .fifo_full(fifo_full), 
				  .fifo_empty_0(fifo_empty0), 
				  .fifo_empty_1(fifo_empty1), 
				  .fifo_empty_2(fifo_empty2), 
				  .soft_reset_0(soft_reset_0), 
				  .soft_reset_1(soft_reset_1), 
				  .soft_reset_2(soft_reset_2), 
				  .parity_done(parity_done), 
				  .low_pkt_valid(low_pkt_valid), 
				  .write_enb_reg(write_en_reg), 
				  .detect_add(detect_add), 
				  .ld_state(ld_state), 
				  .laf_state(laf_state), 
				  .lfd_state(lfd_state),
				  .full_state(full_state), 
				  .rst_int_reg(rst_int_reg), 
				  .busy(busy));

initial 
begin
clk = 1'b0;
forever #10 clk = ~ clk;
end 

task reset();
begin
@ (negedge clk) resetn = 1'b0;
@ (negedge clk) resetn = 1'b1;
end 
endtask 

task softreset(input i, input j, input k);
begin
soft_reset_0 = i;
soft_reset_1 = j;
soft_reset_2 = k;
end 
endtask

task init;
begin
fifo_full = 1'b0;
pkt_valid = 1'b0;
parity_done= 1'b0;
low_pkt_valid = 1'b0;
{fifo_empty0, fifo_empty1, fifo_empty2} = 3'b000;
datain = 2'b00;
end 
endtask

task cycle1();
begin
@(negedge clk) 
pkt_valid = 1'b1;
datain = 2'b01;
fifo_empty1 = 1'b1;
@(negedge clk)
@(negedge clk)
fifo_full = 1'b0;
pkt_valid = 1'b0;
@(negedge clk)
@(negedge clk)
fifo_full = 1'b0;
end
endtask

task cycle2();
begin
@(negedge clk) 
pkt_valid = 1'b1;
datain = 2'b01;
fifo_empty1 = 1'b1;
@(negedge clk)
@(negedge clk)
fifo_full = 1'b1;
@(negedge clk)
fifo_full = 1'b0;
@(negedge clk)
parity_done = 1'b0;
low_pkt_valid = 1'b1;
@(negedge clk)
@(negedge clk)
fifo_full = 1'b0;
end
endtask

task cycle3();
begin
@(negedge clk) 
pkt_valid = 1'b1;
datain = 2'b01;
fifo_empty1 = 1'b1;
@(negedge clk)
@(negedge clk)
fifo_full = 1'b1;
@(negedge clk)
fifo_full = 1'b0;
@(negedge clk)
parity_done = 1'b0;
low_pkt_valid = 1'b0;
@(negedge clk)
fifo_full = 1'b0;
pkt_valid = 1'b0;
@(negedge clk)
@(negedge clk)
fifo_full = 1'b0;
end
endtask

task cycle4();
begin
@(negedge clk) 
pkt_valid = 1'b1;
datain = 2'b01;
fifo_empty1 = 1'b1;
@(negedge clk)
@(negedge clk)
fifo_full = 1'b0;
pkt_valid = 1'b0;
@(negedge clk)
@(negedge clk)
fifo_full = 1'b1;
@(negedge clk)
fifo_full = 1'b0;
@(negedge clk)
parity_done = 1'b1;
end
endtask

initial begin
init;
reset();
softreset(0,0,0);
cycle1();
#200;
reset();
softreset(0,0,0);
cycle2();
#200;
reset();
softreset(0,0,0);
cycle3();
#200;
reset();
softreset(0,0,0);
cycle4();
#1000 $finish;   
end 

endmodule 