module router_top_testbench();

reg clock, resetn,  read_enb_0,read_enb_1,read_enb_2, pkt_valid;
reg [7:0] data_in;
wire[7:0]dataout0, dataout1, dataout2;
wire validout0, validout1, validout2, busy, error;
integer i;

router_top  DUT(clock, resetn, read_enb_0,read_enb_1,read_enb_2, pkt_valid,
                data_in, dataout0, dataout1, dataout2,
                validout0, validout1, validout2, busy, error);
//router_top dut(clock,resetn,pkt_valid,read_enb_0,read_enb_1,read_enb_2,data_in,data_out_0,data_out_1,data_out_2,vld_out_0,vld_out_1,vld_out_2,err,busy);

initial begin
   clock = 1'b0;
   forever #2 clock = ~clock;
end 

task reset;
	begin
		@(negedge clock) resetn = 1'b0;
		@(negedge clock) resetn = 1'b1;
	end 
endtask 

task init;
	begin
		data_in = 8'b0;
		{read_enb_0,read_enb_1,read_enb_2, pkt_valid} = 4'b0;
	end
endtask

task pl_14;
reg [7:0]payload,header,parity;
reg [5:0]paylen;
reg [1:0]addr;
	begin
	        @(negedge clock)
                wait(~busy) begin
                @(negedge clock)
                paylen = 6'd14;
                addr = 2'b01;
                header = {paylen,addr};
                data_in = header;
                pkt_valid = 1;
                parity = parity ^ header;
                end
                @ (negedge clock)
                wait(~busy)
                begin
                for(i = 0; i<paylen;i=i+1)
                    begin
                      @ (negedge clock)
                      wait(~busy)
                      payload = {$random}%256;
                      data_in = payload;
                      parity = parity^payload;
                    end
                 end
                  @(negedge clock)
                   wait(~busy)begin
                   pkt_valid = 0;
                   data_in = parity;
                   end

	end
endtask 

task pl_05;
reg [7:0]payload,header,parity;
reg [5:0]paylen;
reg [1:0]addr;
	begin
		@(negedge clock)
                wait(~busy)
                @(negedge clock)
                begin
                paylen = 6'd05;
                addr = 2'b00;
                header = {paylen,addr};
                data_in = header;
                pkt_valid = 1;
                parity = parity ^ header;
                end
                @ (negedge clock)
                wait(~busy)
                begin
                for(i = 0; i<paylen;i=i+1)
                    begin
                      @ (negedge clock)
                      wait(~busy)
                      payload = {$random}%256;
                      data_in = payload;
                      parity = parity^payload;
                    end
                end 
                 @(negedge clock)
                 wait(~busy)begin
                 pkt_valid = 0;
                 data_in = parity;
                 end 

	end
endtask 

task pl_16;
reg [7:0]payload,header,parity;
reg [5:0]paylen;
reg [1:0]addr;
	begin
		@(negedge clock)
                wait(~busy)begin
                @(negedge clock)
                paylen = 6'd16;
                addr = 2'b10;
                header = {paylen,addr};
                data_in = header;
                pkt_valid = 1;
                parity = parity ^ header;
                end
                @ (negedge clock)
                wait(~busy)begin
                @ (negedge clock)
                for(i = 0; i<paylen;i=i+1)
                    begin
                      @ (negedge clock)
                      wait(~busy)
                      payload = {$random}%256;
                      data_in = payload;
                      parity = parity^payload;
                    end
                 end
                 @(negedge clock)
                 wait(~busy) begin
                 pkt_valid = 0;
                 data_in = parity;
                  end
	end
endtask 

initial begin
   init;
   reset;
   @(negedge clock) 
   pl_14;
   @(negedge clock)
   read_enb_1 = 1;
   wait(~validout1)
   @(negedge clock)
   //read_enb_1 = 0;
   #100;
   reset;
   @(negedge clock) 
   pl_05;
   @(negedge clock)
   read_enb_0 = 1;
   wait(~validout0)
   @(negedge clock)
   read_enb_0 = 0;
   #100;
   reset;
   @(negedge clock) 
   pl_16;
   @(negedge clock)
   read_enb_2 = 1;
   wait(~validout2)
   @(negedge clock);
   read_enb_2 = 0;

   $finish;
end 

endmodule 