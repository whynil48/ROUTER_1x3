module fsm (input clk, resetn, pkt_valid, parity_done,soft_reset_0, soft_reset_1, soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0, fifo_empty_1, fifo_empty_2,
input [1:0] data_in, 
output busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);
    
parameter Decode_address =  4'b0000,Load_First_Data = 4'b0001,Load_Data = 4'b0010,Wait_Till_Empty = 4'b011,Fifo_Full_State = 4'b0100,Load_After_Full = 4'b0101,Load_Parity = 4'b0110,Check_Parity_error = 4'b0111;

reg [3:0] present, next;
reg [1:0] temp;

always@(posedge clk)
begin
if(!resetn)
temp<=2'b00;
else if(detect_add)
temp<=data_in;
end			

always@(posedge clk)
begin
if(!resetn)
present <=Decode_address;
else if (((soft_reset_0) && (temp==2'b00)) || ((soft_reset_1) && (temp==2'b01)) || ((soft_reset_2) && (temp==2'b10)))		//if there is soft_reset and also using same channel so we do here and opertion
present<=Decode_address;
else
present<=next;
end

always@ (*)
begin
case(present)
Decode_address :begin 
if((pkt_valid && (data_in==2'b00) && fifo_empty_0)|| (pkt_valid && (data_in==2'b01) && fifo_empty_1)|| (pkt_valid && (data_in==2'b10) && fifo_empty_2))
begin
next <= Load_First_Data;
end 
else if((pkt_valid & (data_in == 2'b00) & !fifo_empty_0) | (pkt_valid & (data_in == 2'b01) & !fifo_empty_1) | (pkt_valid & (data_in == 2'b10) & !fifo_empty_2))
begin
next <= Wait_Till_Empty; 
end
else
next <= Decode_address;	
end							
Load_First_Data : next <= Load_Data;
Load_Data :  begin
if(fifo_full == 1'b1)
begin
next <= Fifo_Full_State;
end
else 
begin
if(!fifo_full && !pkt_valid)
next <= Load_Parity;
else
next <= Load_Data;					   
end
end						
Wait_Till_Empty: begin
if ( (fifo_empty_0 && (temp == 2'b00)) || (fifo_empty_1 && (temp == 2'b01)) || (fifo_empty_2 && (temp == 2'b10)))
begin
next <= Load_First_Data;
end  
else
begin
next <= Wait_Till_Empty;
end
end	
Fifo_Full_State:begin
if (fifo_full == 0)
begin
next <= Load_After_Full;
end
else if (fifo_full == 1)
begin
next <= Fifo_Full_State;
end
end
Load_After_Full:begin
if(!parity_done && !low_pkt_valid)
begin
next <= Load_Data;
end
else if(!parity_done && low_pkt_valid)
begin
next <= Load_Parity;
end
else 
begin
if(parity_done == 1'b1)
next <= Decode_address;
else
next <= Load_After_Full; 							
end
end   
Load_Parity : begin 
next <= Check_Parity_error;
end	
Check_Parity_error:begin
if (fifo_full)
begin
next <= Fifo_Full_State;
end
else if(!fifo_full)
begin
next <= Decode_address;
end
end 
default : next <= Decode_address;							   
endcase
end

assign busy = ((present==Load_First_Data) || (present==Load_Parity) || (present==Fifo_Full_State) || (present==Load_After_Full) || (present==Wait_Till_Empty) || (present==Check_Parity_error)) ? 1'b1:1'b0; 
assign detect_add = ((present == Decode_address)) ? 1'b1:1'b0;
assign ld_state = ((present == Load_Data)) ? 1'b1:1'b0;
assign laf_state = ((present == Load_After_Full)) ? 1'b1:1'b0;
assign full_state = ((present == Fifo_Full_State)) ? 1'b1:1'b0;
assign write_enb_reg = ((present == Load_Data) || (present == Load_After_Full) || (present == Load_Parity)) ? 1'b1:1'b0;
assign rst_int_reg = ((present == Check_Parity_error)) ? 1'b1: 1'b0;
assign lfd_state = ((present == Load_First_Data)) ? 1'b1:1'b0;

endmodule