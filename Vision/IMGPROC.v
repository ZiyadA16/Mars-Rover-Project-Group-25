module EEE_IMGPROC(
	// global clock & reset
	clk,
	reset_n,
	
	// mm slave
	s_chipselect,
	s_read,
	s_write,
	s_readdata,
	s_writedata,
	s_address,

	// stream sink
	sink_data,
	sink_valid,
	sink_ready,
	sink_sop,
	sink_eop,
	
	// streaming source
	source_data,
	source_valid,
	source_ready,
	source_sop,
	source_eop,
	
	// conduit
	mode
	
);


// global clock & reset
input	clk;
input	reset_n;

// mm slave
input							s_chipselect;
input							s_read;
input							s_write;
output	reg	[31:0]	s_readdata;
input	[31:0]				s_writedata;
input	[2:0]					s_address;


// streaming sink
input	[23:0]            	sink_data;
input								sink_valid;
output							sink_ready;
input								sink_sop;
input								sink_eop;

// streaming source
output	[23:0]			  	   source_data;
output								source_valid;
input									source_ready;
output								source_sop;
output								source_eop;

// conduit export
input                         mode;

////////////////////////////////////////////////////////////////////////
//
parameter IMAGE_W = 11'd640;
parameter IMAGE_H = 11'd480;
parameter MESSAGE_BUF_MAX = 256;
parameter MSG_INTERVAL = 6;
parameter BB_COL_DEFAULT = 24'h00ff00;


wire [7:0]   red, green, blue, grey;
wire [7:0]   red_out, green_out, blue_out;

wire         sop, eop, in_valid, out_ready;
////////////////////////////////////////////////////////////////////////

//HSV Conversion Variable Declaration:
wire [7:0] hue, saturation, value, cmax, cmin;

//HSV Conversion: (this is for decimal values, not binary) -> need to consider whether i should divide by 255, multiply by 100 etc or not!
assign cmax = (blue > green) ? ((blue > red) ? blue[7:0] : red[7:0]) : (green > red) ? green [7:0] : red[7:0];
assign cmin = (blue < green) ? ((blue < red) ? blue[7:0] : red[7:0]) : (green < red) ? green [7:0] : red[7:0];
assign hue = (cmax == cmin) ? 0 
: (cmax == red) ? ( (green>blue) ? ((((15*((green - blue) / ((cmax - cmin)>>2)))>>1)+180)%180) : ((180-((15*((blue - green) / ((cmax - cmin)>>2)))>>1))%180) ) 
: (cmax == green) ? ( (blue>red) ? ((((15*((blue - red) / ((cmax - cmin)>>2)))>>1)+60)%180) : ((60-((15*((red - blue) / ((cmax - cmin)>>2)))>>1))%180) ) 
:               ( (red>green) ? ((((15*((red - green) / ((cmax - cmin)>>2)))>>1)+120)%180) : ((120-((15*((green - red) / ((cmax - cmin)>>2)))>>1))%180) ); //0 to 180
assign saturation = (cmax == 0) ? 0 : ((cmax - cmin)* 100 / cmax); // 0 to 100%
assign value = (cmax); //0 to 255


//Detect Ping Pong Balls: (Only green for now) (Filter declaration too)
//Detect Ping Pong Balls:
wire red_detect, violet_detect, blue_detect, orange_detect, /*pink_detect,*/ yellow_detect, lime_detect, teal_detect, white_detect, black_detect;

//assign violet_detect = (hue >= 120 && hue <= 140) && (saturation > 40 && saturation < 60 && value >= 115 );  //>270  <280
//assign orange_detect = (hue >= 25 && hue <= 35); /*&& (saturation > 40 && saturation < 100 && value >= 15 && value <= 70)) 70,50*/

assign blue_detect = (hue >= 78 && hue <= 122) && (saturation > 24 && saturation <= 100 && value <= 108 );  //>300 <10
assign red_detect = (hue >= 0 && hue  <= 23) && (saturation > 73 && saturation <= 100 && value >= 93 ); //&& value >= 50 && value <= 80));    /*300,10*/
assign teal_detect = (hue >= 39 && hue  <= 90) && (saturation > 38 && saturation <= 100 && value <= 151);
//assign pink_detect = 0;//( (hue >= 150 && hue <= 180) || (hue <= 32 && hue >= 0) ) && (saturation > 41 && saturation <= 100 && value >= 85); // hue 0.922 to 0.114 (convert), saturation 0.438 to 1, value 0.545 to 1 (convert) &red
//assign pink_detect = 0; //(hue >= 2 && hue <= 25) && (saturation > 60 && saturation <= 100 && value >= 83);
assign yellow_detect = (hue >= 10 && hue <= 50) && (saturation > 58 && saturation <= 100 && value >= 65); //hue , sat , val
assign lime_detect = (hue >= 38  && hue <= 73) && (saturation > 22 && saturation <= 91 && value >= 68);
assign white_detect = (saturation <= 2 && value >= 250);
assign black_detect = (value <= 10);


/*
H 150 180
s 40 80
v 50 80 */

/* Detect red areas (using rgb)
wire red_detect;
assign red_detect = red[7] & ~green[7] & ~blue[7]; */

// Find boundary of cursor box

/*Filter*/
reg prev_v, prev_v1, prev_v2;
reg prev_b, prev_b1, prev_b2;
reg prev_r, prev_r1, prev_r2;
reg prev_t, prev_t1, prev_t2;
reg prev_y, prev_y1, prev_y2;
reg prev_l, prev_l1, prev_l2;
reg prev_w, prev_w1, prev_w2;
reg prev_bl, prev_bl1, prev_bl2;



/* Highlight detected areas
wire [23:0] red_high;
assign grey = green[7:1] + red[7:2] + blue[7:2]; //Grey = green/2 + red/4 + blue/4
assign red_high  =  red_detect ? {8'hff, 8'h0, 8'h0} : {grey, grey, grey}; */
wire [23:0] highlight;
assign grey = green[7:1] + red[7:2] + blue[7:2];
//assign highlight = (orange_detect || red_detect || violet_detect || blue_detect) ? {8'h04,8'hbd,8'h42} : {grey, grey, grey};


// Show bounding box
wire [23:0] new_image;
wire bb_active;
assign bb_active = (x == left) | (x == right) | (y == top) | (y == bottom);
assign new_image = bb_active ? bb_col : highlight;

// Switch output pixels depending on mode switch
// Don't modify the start-of-packet word - it's a packet discriptor
// Don't modify data in non-video packets
assign {red_out, green_out, blue_out} = (mode & ~sop & packet_video) ? new_image : {red,green,blue};

initial begin 
	prev_v<=0;
	prev_v1<=0;
	prev_v2<=0;
	prev_b<=0;
	prev_b1<=0;
	prev_b2<=0;
	prev_r<=0;
	prev_r1<=0;
	prev_r2<=0;
	prev_t<=0;
	prev_t1<=0;
	prev_t2<=0;
	prev_y<=0;
	prev_y1<=0;
	prev_y2<=0;
	prev_l<=0;
	prev_l1<=0;
	prev_l2<=0;
	prev_w<=0;
	prev_w1<=0;
	prev_w2<=0;
	prev_bl<=0;
	prev_bl1<=0;
	prev_bl2<=0;
end

always@(negedge clk) begin
/*
	prev_violet = violet_detect;
	prev_violet1 = prev_violet;
	prev_violet2 = prev_violet1;
	*/
	prev_b2 = prev_b1;
	prev_b1 = prev_b;
	prev_b = blue_detect;	
	
	prev_r2 = prev_r1;
	prev_r1 = prev_r;
	prev_r = red_detect;	
	
	prev_t2 = prev_t1;
	prev_t1 = prev_t;
	prev_t = teal_detect;
	
	prev_y2 = prev_y1;
	prev_y1 = prev_y;
	prev_y = yellow_detect;
	
	prev_l2 = prev_l1;
	prev_l1 = prev_l;
	prev_l = lime_detect;
	
	prev_w2 = prev_w1;
	prev_w1 = prev_w;
	prev_w = white_detect;
	
	prev_bl2 = prev_bl1;
	prev_bl1 = prev_bl;
	prev_bl = black_detect;
	
	
end

//(violet_detect && prev_violet && prev_violet1 && prev_violet2) ? {8'h04,8'hbd,8'h42} 
assign highlight = (red_detect && prev_r && prev_r1 && prev_r2) ? {8'hec,8'h42,8'h27} 
: ((blue_detect && prev_b && prev_b1 && prev_b2) ? {8'h04,8'h48,8'hd4}
: ((teal_detect && prev_t && prev_t1 && prev_t2) ? {8'h36,8'hcb,8'hff}
: ((yellow_detect && prev_y && prev_y1 && prev_y2) ? {8'he3,8'hd5,8'h09}
: ((lime_detect && prev_l && prev_l1 && prev_l2) ? {8'h36,8'hcb,8'hff}
: ((white_detect && prev_w && prev_w1 && prev_w2) ? {8'hff,8'hff,8'hff}
: ((black_detect && prev_bl && prev_bl1 && prev_bl2) ? {8'hff,8'hff,8'hff}
: {grey, grey, grey}))))));


//Count valid pixels to get the image coordinates. Reset and detect packet type on Start of Packet.
reg [10:0] x, y;
reg packet_video;
always@(posedge clk) begin
	if (sop) begin
		x <= 11'h0;
		y <= 11'h0;
		packet_video <= (blue[3:0] == 3'h0);
	end
	else if (in_valid) begin
		if (x == IMAGE_W-1) begin
			x <= 11'h0;
			y <= y + 11'h1;
		end
		else begin
			x <= x + 11'h1;
		end
	end
end

//Find first and last red pixels
reg [10:0] x_min, x_max, y_min, y_max;
always@(posedge clk) begin
	if ((red_detect)& in_valid) begin	//Update bounds when the pixel is red
		if (x < x_min) x_min <= x;
		if (x > x_max) x_max <= x;
		if (y < y_min) y_min <= y;
		y_max <= y;
	end
	if (sop & in_valid) begin	//Reset bounds on start of packet
		x_min <= IMAGE_W-11'h1;
		x_max <= 0;
		y_min <= IMAGE_H-11'h1;
		y_max <= 0;
	end
end
/*
reg [10:0] x_min_b, x_max_B;
always@(posedge clk) begin
	if ((red_detect)& in_valid) begin	//Update bounds when the pixel is blue
		if (x < x_min) x_min <= x;
		if (x > x_max) x_max <= x;
		if (y < y_min) y_min <= y;
		y_max <= y;
	end
	if (sop & in_valid) begin	//Reset bounds on start of packet
		x_min <= IMAGE_W-11'h1;
		x_max <= 0;
		y_min <= IMAGE_H-11'h1;
		y_max <= 0;
	end
end

reg [10:0] x_min, x_max;
always@(posedge clk) begin
	if ((red_detect)& in_valid) begin	//Update bounds when the pixel is teal
		if (x < x_min) x_min <= x;
		if (x > x_max) x_max <= x;
		if (y < y_min) y_min <= y;
		y_max <= y;
	end
	if (sop & in_valid) begin	//Reset bounds on start of packet
		x_min <= IMAGE_W-11'h1;
		x_max <= 0;
		y_min <= IMAGE_H-11'h1;
		y_max <= 0;
	end
end

reg [10:0] x_min, x_max;
always@(posedge clk) begin
	if ((red_detect)& in_valid) begin	//Update bounds when the pixel is yellow
		if (x < x_min) x_min <= x;
		if (x > x_max) x_max <= x;
		if (y < y_min) y_min <= y;
		y_max <= y;
	end
	if (sop & in_valid) begin	//Reset bounds on start of packet
		x_min <= IMAGE_W-11'h1;
		x_max <= 0;
		y_min <= IMAGE_H-11'h1;
		y_max <= 0;
	end
end

reg [10:0] x_min, x_max;
always@(posedge clk) begin
	if ((red_detect)& in_valid) begin	//Update bounds when the pixel is lime
		if (x < x_min) x_min <= x;
		if (x > x_max) x_max <= x;
		if (y < y_min) y_min <= y;
		y_max <= y;
	end
	if (sop & in_valid) begin	//Reset bounds on start of packet
		x_min <= IMAGE_W-11'h1;
		x_max <= 0;
		y_min <= IMAGE_H-11'h1;
		y_max <= 0;
	end
end

reg [10:0] x_min, x_max;
always@(posedge clk) begin
	if ((red_detect)& in_valid) begin	//Update bounds when the pixel is white/black
		if (x < x_min) x_min <= x;
		if (x > x_max) x_max <= x;
		if (y < y_min) y_min <= y;
		y_max <= y;
	end
	if (sop & in_valid) begin	//Reset bounds on start of packet
		x_min <= IMAGE_W-11'h1;
		x_max <= 0;
		y_min <= IMAGE_H-11'h1;
		y_max <= 0;
	end
end
*/
//Drive & Distance Instr




//Process bounding box at the end of the frame.
reg [1:0] msg_state;
reg [10:0] left, right, top, bottom;
reg [7:0] frame_count;
always@(posedge clk) begin
	if (eop & in_valid & packet_video) begin  //Ignore non-video packets
		
		//Latch edges for display overlay on next frame
		left <= x_min;
		right <= x_max;
		top <= y_min;
		bottom <= y_max;
		
		
		//Start message writer FSM once every MSG_INTERVAL frames, if there is room in the FIFO
		frame_count <= frame_count - 1;
		
		if (frame_count == 0 && msg_buf_size < MESSAGE_BUF_MAX - 3) begin
			msg_state <= 2'b01;
			frame_count <= MSG_INTERVAL-1;
		end
	end
	
	//Cycle through message writer states once started
	if (msg_state != 2'b00) msg_state <= msg_state + 2'b01;

end
	
//Generate output messages for CPU
reg [31:0] msg_buf_in; 
wire [31:0] msg_buf_out;
reg msg_buf_wr;
wire msg_buf_rd, msg_buf_flush;
wire [7:0] msg_buf_size;
wire msg_buf_empty;

`define RED_BOX_MSG_ID "RBB"

always@(*) begin	//Write words to FIFO as state machine advances
	case(msg_state)
		2'b00: begin
			msg_buf_in = 32'b0;
			msg_buf_wr = 1'b0;
		end
		2'b01: begin
			msg_buf_in = `RED_BOX_MSG_ID;	//Message ID
			msg_buf_wr = 1'b1;
		end
		2'b10: begin
			msg_buf_in = {5'b0, x_min, 5'b0, y_min};	//Top left coordinate
			msg_buf_wr = 1'b1;
		end
		2'b11: begin
			msg_buf_in = {5'b0, x_max, 5'b0, y_max}; //Bottom right coordinate
			msg_buf_wr = 1'b1;
		end
	endcase
end


//Output message FIFO
MSG_FIFO	MSG_FIFO_inst (
	.clock (clk),
	.data (msg_buf_in),
	.rdreq (msg_buf_rd),
	.sclr (~reset_n | msg_buf_flush),
	.wrreq (msg_buf_wr),
	.q (msg_buf_out),
	.usedw (msg_buf_size),
	.empty (msg_buf_empty)
	);


//Streaming registers to buffer video signal
STREAM_REG #(.DATA_WIDTH(26)) in_reg (
	.clk(clk),
	.rst_n(reset_n),
	.ready_out(sink_ready),
	.valid_out(in_valid),
	.data_out({red,green,blue,sop,eop}),
	.ready_in(out_ready),
	.valid_in(sink_valid),
	.data_in({sink_data,sink_sop,sink_eop})
);

STREAM_REG #(.DATA_WIDTH(26)) out_reg (
	.clk(clk),
	.rst_n(reset_n),
	.ready_out(out_ready),
	.valid_out(source_valid),
	.data_out({source_data,source_sop,source_eop}),
	.ready_in(source_ready),
	.valid_in(in_valid),
	.data_in({red_out, green_out, blue_out, sop, eop})
);


/////////////////////////////////
/// Memory-mapped port		 /////
/////////////////////////////////

// Addresses
`define REG_STATUS    			0
`define READ_MSG    				1
`define READ_ID    				2
`define REG_BBCOL					3

//Status register bits
// 31:16 - unimplemented
// 15:8 - number of words in message buffer (read only)
// 7:5 - unused
// 4 - flush message buffer (write only - read as 0)
// 3:0 - unused


// Process write

reg  [7:0]   reg_status;
reg	[23:0]	bb_col;

always @ (posedge clk)
begin
	if (~reset_n)
	begin
		reg_status <= 8'b0;
		bb_col <= BB_COL_DEFAULT;
	end
	else begin
		if(s_chipselect & s_write) begin
		   if      (s_address == `REG_STATUS)	reg_status <= s_writedata[7:0];
		   if      (s_address == `REG_BBCOL)	bb_col <= s_writedata[23:0];
		end
	end
end


//Flush the message buffer if 1 is written to status register bit 4
assign msg_buf_flush = (s_chipselect & s_write & (s_address == `REG_STATUS) & s_writedata[4]);


// Process reads
reg read_d; //Store the read signal for correct updating of the message buffer

// Copy the requested word to the output port when there is a read.
always @ (posedge clk)
begin
   if (~reset_n) begin
	   s_readdata <= {32'b0};
		read_d <= 1'b0;
	end
	
	else if (s_chipselect & s_read) begin
		if   (s_address == `REG_STATUS) s_readdata <= {16'b0,msg_buf_size,reg_status};
		if   (s_address == `READ_MSG) s_readdata <= {msg_buf_out};
		if   (s_address == `READ_ID) s_readdata <= 32'h1234EEE2;
		if   (s_address == `REG_BBCOL) s_readdata <= {8'h0, bb_col};
	end
	
	read_d <= s_read;
end

//Fetch next word from message buffer after read from READ_MSG
assign msg_buf_rd = s_chipselect & s_read & ~read_d & ~msg_buf_empty & (s_address == `READ_MSG);
						
/*TODO:-Test and Adjust code for different colours
-Filter
-Communication with other modules
-Distance/pixel calculations?
-Autonomous drive instructions? */

endmodule

