module router_top(input clock, resetn, read_enb_0,read_enb_1,read_enb_2, pkt_valid,
                  input [7:0] data_in,
                  output [7:0]data_out_0, data_out_1, data_out_2,
                  output  vld_out_0, vld_out_1, vld_out_2, busy, err);

wire parity_done, soft_reset_0,soft_reset_1, soft_reset_2, fifo_full, low_pkt_valid, empty_0, empty_1, empty_2,detect_add, ld_state,laf_state,full_state, write_en_reg, rst_int_reg, lfd_state,full_0,full_1,full_2;
wire [2:0] write_enb;
wire [7:0] data_out;

//FIFO_SUB_BLOCK
fifo fdut0(clock, resetn, write_enb[0], read_enb_0, soft_reset_0, lfd_state,data_out,empty_0, full_0,data_out_0);
fifo fdut1(clock, resetn, write_enb[1], read_enb_1, soft_reset_1, lfd_state,data_out,empty_1, full_1,data_out_1);
fifo fdut2(clock, resetn, write_enb[2], read_enb_2, soft_reset_2, lfd_state,data_out,empty_2, full_2,data_out_2);

//FSM_SUB_BLOCK
fsm  fsdut(clock, resetn, pkt_valid, parity_done, soft_reset_0,soft_reset_1, soft_reset_2, fifo_full, 
                low_pkt_valid, empty_0, empty_1, empty_2, data_in[1:0],
                 busy, detect_add, ld_state,laf_state, full_state, write_en_reg, rst_int_reg, lfd_state);
				 
//SYNCRONISER_SUB_BLOCK
sync sdut(clock,resetn,detect_add,write_en_reg,read_enb_0,read_enb_1,read_enb_2,
                 empty_0,empty_1,empty_2,full_0,full_1,full_2,data_in[1:0], vld_out_0,vld_out_1,vld_out_2,
                 write_enb, fifo_full, soft_reset_0,soft_reset_1,soft_reset_2);

//REGISTER_SUB_BLOCK
register  dut3(clock,resetn,pkt_valid,data_in,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err, parity_done,low_pkt_valid,data_out);


endmodule
