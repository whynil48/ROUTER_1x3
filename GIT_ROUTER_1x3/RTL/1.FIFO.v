module fifo(input clock, resetn, write_en, read_en, soft_reset, lfd_state,
input [7:0] data_in,
output empty, full,
output reg [7:0] data_out);

reg [7:0] wptr = 4'b0;
reg [7:0] rptr = 4'b0;
reg [8:0]mem[15:0];
integer i;
reg [7:0] temp_variable;

assign empty = (rptr == wptr)? 1'b1: 1'b0;
assign full = (wptr == 8'b1 && rptr == 8'b1)? 1'b1: 1'b0;

always @ (posedge clock) begin
if(!resetn)begin
for(i = 0; i<16 ; i= i+1)
mem[i] <= 8'b0;
wptr <= 8'b0;
end 
else begin
if(soft_reset)begin
for(i = 0; i<16 ; i= i+1)
mem[i] <= 8'b0;
wptr <= 8'b0; 
end 
else begin
if(write_en == 1'b1 && full == 1'b0)begin
mem[wptr] <= {lfd_state,data_in};
wptr <= wptr + 1;
end
else 
wptr <= wptr; 
end 
end

end 

always @ (posedge clock) begin
if(!resetn)begin
data_out <= 1'bz;
rptr <= 8'b0;
end 
else begin
if(soft_reset)begin
data_out <= 8'bz;
rptr <= 8'b0;

end 
else begin
if(read_en == 1'b1 && empty == 1'b0)begin
data_out <= mem[rptr];
rptr <= rptr + 1;
end 
// temp_variable <= temp_variable -1;
else if(!temp_variable)begin
data_out <= 8'bz;
rptr <= 8'b0;
end
else 
rptr <= rptr; 
end 
end
end

always @(posedge clock)begin
if(lfd_state)begin
temp_variable <= 1+ mem[wptr][7:2];
end
else begin
temp_variable <= temp_variable -1; 
end     
end 

endmodule 
