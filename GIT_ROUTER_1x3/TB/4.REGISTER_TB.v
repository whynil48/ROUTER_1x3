module register_tb();
reg clk,reset,packet_valid;
reg [7:0] datain;
reg fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg;
wire err,parity_done,low_packet_valid;
wire [7:0] dout;

router_register dut ( clk,reset,packet_valid,datain,
fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,
err,parity_done,low_packet_valid, dout);

initial
begin
clk=1'b1;
forever
begin
clk=~clk;
#10;
end
end

task initialize;
begin
reset = 0;
datain=8'd0;

end
endtask

task RESET();
begin
@(negedge clk) reset = 1'b0;
@(negedge clk) reset = 1'b1;
end
endtask

//good packet
task packet_generation_good;
reg [7:0] payload_data, parity, header;
reg [5:0] payload_len;
reg [1:0] addr;
integer i;
begin
@(negedge clk)
payload_len=6'd14;
addr=2'b10; //valid packet
packet_valid=1;
detect_add=1;
header={payload_len,addr};
parity= 8'd0^header;
datain=header;
@(negedge clk)
detect_add=0;
lfd_state=1;
full_state=0;
fifo_full=0;
laf_state=0;
for(i=0;i<payload_len;i=i+1)
begin
@(negedge clk)
lfd_state=0;
ld_state=1;
payload_data={$random}%256;
datain= payload_data;
parity=parity^datain;
end
@(negedge clk)
packet_valid=0;
datain=parity;
@(negedge clk)
ld_state=0;
end
endtask

//bad packet
task packet_generation_bad;
reg [7:0] payload_data, parity, header;
reg [5:0] payload_len;
reg [1:0] addr;
integer j;
begin
@(negedge clk)
payload_len=6'd20;
addr=2'b10; //valid packet
packet_valid=1;
detect_add=1;
header={payload_len,addr};
parity= 8'd0^header;
datain=header;
@(negedge clk)
detect_add=0;
lfd_state=1;
full_state=0;
fifo_full=0;
laf_state=0;
for(j=0;j<payload_len;j=j+1)
begin
@(negedge clk)
lfd_state=0;
ld_state=1;
payload_data={$random}%256;
datain= payload_data;
parity=parity^datain;
end
@(negedge clk)
packet_valid=0;
datain={$random}%256;
@(negedge clk)
ld_state=0;
end
endtask

initial
begin
initialize;
RESET;
packet_generation_good;
packet_generation_bad;
#500 $finish;
end
endmodule

