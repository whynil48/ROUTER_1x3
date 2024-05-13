module register(input clk,reset,packet_valid,input [7:0] datain,
input fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,
output reg err,parity_done,low_packet_valid,output reg [7:0] dout);			  
reg [7:0] hb,ffb,ip,ppb;

always@(posedge clk)
begin
if(!reset)
begin
dout<=8'd0;
end
else if (detect_add && packet_valid)
hb<=datain;
else if (lfd_state)
dout<=hb;
else if (ld_state && !fifo_full)
dout<=datain;
else if (ld_state && fifo_full)
ffb<=datain;
else if (laf_state)
dout<=ffb;
else
dout<=8'd0;
end

always@(posedge clk)
begin
if(!reset)
low_packet_valid<=1'b0;
else if(ld_state==1'b1 && packet_valid==1'b0)
low_packet_valid<=1'b1;
else
low_packet_valid<=1'b0;
end

always@(posedge clk)
begin
if(!reset)
begin
parity_done<=1'b0;
end
else if(ld_state && !fifo_full && !packet_valid)
parity_done<=1'b1;
else if (laf_state && !packet_valid)
parity_done<=1'b1;
else
parity_done<=1'b0;
end

always@(posedge clk)
begin
if(!reset)
begin
ip<=8'd0;
end
else if(rst_int_reg) 
begin
ip<=8'd0;
end
else if(lfd_state)
ip<=ip ^ hb;
else if(ld_state && packet_valid && !full_state)
ip<=ip ^ datain;
else
begin
if (detect_add)
ip<=8'b0;
end
end

always@(posedge clk)
begin
if(!reset || rst_int_reg)
ppb<=8'b0;
else 
begin
if(!packet_valid && ld_state)
ppb<=datain;
end
end

always@(posedge clk)
begin
if(!reset)
err<=1'b0;
else 
begin
if(parity_done)
begin
if(ip!=ppb)
err<=1'b1;
else
err<=1'b0;
end
end
end
endmodule

