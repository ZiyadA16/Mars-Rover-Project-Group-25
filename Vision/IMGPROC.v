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

//HSV Conversion:
assign cmax = (blue > green) ? ((blue > red) ? blue[7:0] : red[7:0]) : (green > red) ? green [7:0] : red[7:0];
assign cmin = (blue < green) ? ((blue < red) ? blue[7:0] : red[7:0]) : (green < red) ? green [7:0] : red[7:0];
assign hue = (cmax == cmin) ? 0 
: (cmax == red) ? ( (green>blue) ? ((((15*((green - blue) / ((cmax - cmin)>>2)))>>1)+180)%180) : ((180-((15*((blue - green) / ((cmax - cmin)>>2)))>>1))%180) ) 
: (cmax == green) ? ( (blue>red) ? ((((15*((blue - red) / ((cmax - cmin)>>2)))>>1)+60)%180) : ((60-((15*((red - blue) / ((cmax - cmin)>>2)))>>1))%180) ) 
:               ( (red>green) ? ((((15*((red - green) / ((cmax - cmin)>>2)))>>1)+120)%180) : ((120-((15*((green - red) / ((cmax - cmin)>>2)))>>1))%180) ); //0 to 180
assign saturation = (cmax == 0) ? 0 : ((cmax - cmin)* 100 / cmax); // 0 to 100%
assign value = (cmax); //0 to 255


//Detect Ping Pong Balls:
wire red_detect, violet_detect, blue_detect, orange_detect, /*pink_detect,*/ yellow_detect, lime_detect, teal_detect/*, building_detect*/;

//assign violet_detect = (hue >= 120 && hue <= 140) && (saturation > 40 && saturation < 60 && value >= 115 );  //>270  <280
//assign orange_detect = (hue >= 25 && hue <= 35); /*&& (saturation > 40 && saturation < 100 && value >= 15 && value <= 70)) 70,50*/

assign blue_detect = (hue >= 78 && hue <= 122) && (saturation > 24 && saturation <= 100 && value <= 108 );  //>300 <10
assign red_detect = (hue >= 0 && hue  <= 23) && (saturation > 73 && saturation <= 100 && value >= 93 ); //&& value >= 50 && value <= 80));    /*300,10*/
assign teal_detect = (hue >= 39 && hue  <= 90) && (saturation > 38 && saturation <= 100 && value <= 151);
//assign pink_detect = 0;//( (hue >= 150 && hue <= 180) || (hue <= 32 && hue >= 0) ) && (saturation > 41 && saturation <= 100 && value >= 85); // hue 0.922 to 0.114 (convert), saturation 0.438 to 1, value 0.545 to 1 (convert) &red
//assign pink_detect = 0; //(hue >= 2 && hue <= 25) && (saturation > 60 && saturation <= 100 && value >= 83);
assign yellow_detect = (hue >= 10 && hue <= 50) && (saturation > 58 && saturation <= 100 && value >= 65); //hue , sat , val
assign lime_detect = (hue >= 38  && hue <= 73) && (saturation > 22 && saturation <= 91 && value >= 68);
//assign building_detect = (value <= 5) || (value >= 250);


/* Detect red areas (using rgb)
wire red_detect;
assign red_detect = red[7] & ~green[7] & ~blue[7]; */

// Find boundary of cursor box


/*Filter*/
reg prev_b, prev_b1, prev_b2;
reg prev_r, prev_r1, prev_r2;
reg prev_t, prev_t1, prev_t2;
reg prev_y, prev_y1, prev_y2;
reg prev_l, prev_l1, prev_l2;
/*reg prev_p, prev_p1, prev_p2;*/


initial begin 
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
	/*prev_p<=0;
	prev_p1<=0;
	prev_p2<=0;*/
end


always@(negedge clk) begin

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
	
	/*prev_p2 = prev_p1;
	prev_p1 = prev_p;
	prev_p = pink_detect;	*/
	
end



/* Highlight detected areas
wire [23:0] red_high;
assign grey = green[7:1] + red[7:2] + blue[7:2]; //Grey = green/2 + red/4 + blue/4
assign red_high  =  red_detect ? {8'hff, 8'h0, 8'h0} : {grey, grey, grey}; */
wire [23:0] highlight;
assign grey = green[7:1] + red[7:2] + blue[7:2];
//assign highlight = (orange_detect || red_detect || violet_detect || blue_detect) ? {8'h04,8'hbd,8'h42} : {grey, grey, grey};
assign highlight = 
		  (red_detect && prev_r && prev_r1 && prev_r2) ? {8'hff, 8'h0, 8'h0}
		: (blue_detect && prev_b && prev_b1 && prev_b2) ? {8'h0,8'h0,8'hff}
		: (yellow_detect && prev_y && prev_y1 && prev_y2) ? {8'hff,8'hff,8'h0} 
		: (teal_detect && prev_t && prev_t1 && prev_t2) ? {8'h0,8'h80,8'h80}
		: (lime_detect && prev_l && prev_l1 && prev_l2) ? {8'h32,8'hcd,8'h32} 
		//: (pink_detect && prev_p && prev_p1 && prev_p2) ? {8'hff,8'hc0,8'cb}
		//: (building_detect) ? {8'hff,8'hff,8'hff} 
		: {grey, grey, grey};
		

/*
assign highlight = (red_detect && prev_r && prev_r1 && prev_r2) ? {8'hec,8'h42,8'h27} 
: ((blue_detect && prev_b && prev_b1 && prev_b2) ? {8'h04,8'h48,8'hd4}
: ((teal_detect && prev_t && prev_t1 && prev_t2) ? {8'h36,8'hcb,8'hff}
: ((yellow_detect && prev_y && prev_y1 && prev_y2) ? {8'he3,8'hd5,8'h09}
: ((lime_detect && prev_l && prev_l1 && prev_l2) ? {8'h36,8'hcb,8'hff}
: ((white_detect && prev_w && prev_w1 && prev_w2) ? {8'hff,8'hff,8'hff}
: ((black_detect && prev_bl && prev_bl1 && prev_bl2) ? {8'hff,8'hff,8'hff}
: {grey, grey, grey}))))));
*/




//(red_detect || teal_detect || pink_detect || blue_detect || yellow_detect || lime_detect) ? {8'h04,8'hbd,8'h42} : {grey, grey, grey};

//red:{8'hff, 8'h0, 8'h0}
//blue:{8'h0,8'h0,8'hff}
//teal:{8'h0,8'h80,8'h80} 
//pink:{8'hff,8'hc0,8'cb} 
//yellow:{8'hff,8'hff,8'h0} 
//lime:{8'h32,8'hcd,8'h32} 
//white:{8'hff,8'hff,8'hff} 


// Show bounding box
wire [23:0] red_new_image;
wire red_bb_active;
assign red_bb_active = (x == red_left) | (x == red_right) | (y == red_top) | (y == red_bottom);
assign red_new_image = red_bb_active ? {24'hff0000} : highlight;

wire [23:0] blue_new_image;
wire blue_bb_active;
assign blue_bb_active = (x == blue_left) | (x == blue_right) | (y == blue_top) | (y == blue_bottom);
assign blue_new_image = blue_bb_active ? {24'h0000ff} : red_new_image;

wire [23:0] teal_new_image;
wire teal_bb_active;
assign teal_bb_active = (x == teal_left) | (x == teal_right) | (y == teal_top) | (y == teal_bottom);
assign teal_new_image = teal_bb_active ? {24'h008080} : blue_new_image;

/*wire [23:0] pink_new_image;
wire pink_bb_active;
assign pink_bb_active = (x == pink_left) | (x == pink_right) | (y == pink_top) | (y == pink_bottom);
assign pink_new_image = pink_bb_active ? {24'hffc0cb} : teal_new_image;*/

wire [23:0] yellow_new_image;
wire yellow_bb_active;
assign yellow_bb_active = (x == yellow_left) | (x == yellow_right) | (y == yellow_top) | (y == yellow_bottom);
assign yellow_new_image = yellow_bb_active ? {24'hffff00} : teal_new_image;/*pink_new_image;*/

wire [23:0] lime_new_image;
wire lime_bb_active;
assign lime_bb_active = (x == lime_left) | (x == lime_right) | (y == lime_top) | (y == lime_bottom);
assign lime_new_image = lime_bb_active ? {24'h32cd32} : yellow_new_image;



// Switch output pixels depending on mode switch
// Don't modify the start-of-packet word - it's a packet discriptor
// Don't modify data in non-video packets
assign {red_out, green_out, blue_out} = (mode & ~sop & packet_video) ? lime_new_image : {red,green,blue};

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
reg [10:0] red_x_min, red_x_max, red_y_min, red_y_max,
			  blue_x_min, blue_x_max, blue_y_min, blue_y_max,
			  yellow_x_min, yellow_x_max, yellow_y_min, yellow_y_max,
			  teal_x_min, teal_x_max, teal_y_min, teal_y_max, 
			  lime_x_min, lime_x_max, lime_y_min, lime_y_max/*,
			  pink_x_min, pink_x_max,pink_y_min, pink_y_max*/
			  ;
always@(posedge clk) begin
	/*if ((teal_detect || red_detect || pink_detect || blue_detect || yellow_detect || lime_detect || building_detect)& in_valid) begin	//Update bounds when the pixel is red
		if (x < x_min) x_min <= x;
		if (x > x_max) x_max <= x;
		if (y < y_min) y_min <= y;
		y_max <= y;
	end
	*/
	if ((red_detect && prev_r && prev_r1 && prev_r2)& in_valid) begin
		if (x < red_x_min) red_x_min <= x;
		if (x < red_x_max) red_x_max <= x;
		if (y < red_y_min) red_y_min <= y;
		red_y_max <= y;	
	end
	
	if ((blue_detect && prev_b && prev_b1 && prev_b2)& in_valid) begin
		if (x < blue_x_min) blue_x_min <= x;
		if (x < blue_x_max) blue_x_max <= x;
		if (y < blue_y_min) blue_y_min <= y;
		blue_y_max <= y;	
	end
	
	if ((yellow_detect && prev_y && prev_y1 && prev_y2)& in_valid) begin
		if (x < yellow_x_min) yellow_x_min <= x;
		if (x < yellow_x_max) yellow_x_max <= x;
		if (y < yellow_y_min) yellow_y_min <= y;
		yellow_y_max <= y;	
	end
	
	if ((teal_detect && prev_t && prev_t1 && prev_t2)& in_valid) begin
		if (x < teal_x_min) teal_x_min <= x;
		if (x < red_x_max) red_x_max <= x;
		if (y < red_y_min) red_y_min <= y;
		red_y_max <= y;	
	end

	if ((lime_detect && prev_l && prev_l1 && prev_l2)& in_valid) begin
		if (x < lime_x_min) lime_x_min <= x;
		if (x < lime_x_max) lime_x_max <= x;
		if (y < lime_y_min) lime_y_min <= y;
		lime_y_max <= y;		
	end
		
	/*if ((pink_detect && prev_p && prev_p1 && prev_p2)& in_valid) begin
		if (x < pink_x_min) pink_x_min <= x;
		if (x < pink_x_max) pink_x_max <= x;
		if (y < pink_y_min) pink_y_min <= y;
		pink_y_max <= y;	
	end*/

	if (sop & in_valid) begin	//Reset bounds on start of packet
		red_x_min <= IMAGE_W-11'h1;
		red_x_max <= 0;
		red_y_min <= IMAGE_H-11'h1;
		red_y_max <= 0;
		
		blue_x_min <= IMAGE_W-11'h1;
		blue_x_max <= 0;
		blue_y_min <= IMAGE_H-11'h1;
		blue_y_max <= 0;
		
		teal_x_min <= IMAGE_W-11'h1;
		teal_x_max <= 0;
		teal_y_min <= IMAGE_H-11'h1;
		teal_y_max <= 0;

		yellow_x_min <= IMAGE_W-11'h1;
		yellow_x_max <= 0;
		yellow_y_min <= IMAGE_H-11'h1;
		yellow_y_max <= 0;

		lime_x_min <= IMAGE_W-11'h1;
		lime_x_max <= 0;
		lime_y_min <= IMAGE_H-11'h1;
		lime_y_max <= 0;

		/*pink_x_min <= IMAGE_W-11'h1;
		pink_x_max <= 0;
		pink_y_min <= IMAGE_H-11'h1;
		pink_y_max <= 0;*/
	end
end


//Process bounding box at the end of the frame.
reg [4:0] msg_state;
reg [10:0] red_left, red_right, red_top, red_bottom,
			  blue_left, blue_right, blue_top, blue_bottom,
			  yellow_left, yellow_right, yellow_top, yellow_bottom,
			  teal_left, teal_right, teal_top, teal_bottom,
			  /*pink_left, pink_right, pink_top, pink_bottom,*/
			  lime_left, lime_right, lime_top, lime_bottom;


reg [7:0] frame_count;
always@(posedge clk) begin
	if (eop & in_valid & packet_video) begin  //Ignore non-video packets
		
		//Latch edges for display overlay on next frame
		red_left <= red_x_min;
		red_right <= red_x_max;
		red_top <= red_y_min;
		red_bottom <= red_y_max;
		
		blue_left <= blue_x_min;
		blue_right <= blue_x_max;
		blue_top <= blue_y_min;
		blue_bottom <= blue_y_max;
		
		teal_left <= teal_x_min;
		teal_right <= teal_x_max;
		teal_top <= teal_y_min;
		teal_bottom <= teal_y_max;
		
		yellow_left <= yellow_x_min;
		yellow_right <= yellow_x_max;
		yellow_top <= yellow_y_min;
		yellow_bottom <= yellow_y_max;
		
		/*pink_left <= pink_x_min;
		pink_right <= pink_x_max;
		pink_top <= pink_y_min;
		pink_bottom <= pink_y_max;*/
		
		lime_left <= lime_x_min;
		lime_right <= lime_x_max;
		lime_top <= lime_y_min;
		lime_bottom <= lime_y_max;
		
		
		//Start message writer FSM once every MSG_INTERVAL frames, if there is room in the FIFO
		frame_count <= frame_count - 1;
		
		if (frame_count == 0 && msg_buf_size < MESSAGE_BUF_MAX - 3) begin
			msg_state <= 4'b0001;
			frame_count <= MSG_INTERVAL-1;
		end
	end
	
	//Cycle through message writer states once started
	if (msg_state != 4'b0000) msg_state <= msg_state + 4'b0001;

end



	
//Generate output messages for CPU
reg [31:0] msg_buf_in; 
wire [31:0] msg_buf_out;
reg msg_buf_wr;
wire msg_buf_rd, msg_buf_flush;
wire [7:0] msg_buf_size;
wire msg_buf_empty;

`define RED_BOX_MSG_ID "RBB"
`define BLUE_BOX_MSG_ID "BBB"
`define TEAL_BOX_MSG_ID "TBB"
/*`define PINK_BOX_MSG_ID "PBB"*/
`define YELLOW_BOX_MSG_ID "YBB"
`define LIME_BOX_MSG_ID "LBB"

always@(*) begin	//Write words to FIFO as state machine advances

//walls

	case(msg_state)
		4'b0000: begin
			msg_buf_in = 32'b0;
			msg_buf_wr = 1'b0;
		end
	/*red*/
		4'b0001: begin
			msg_buf_in = `RED_BOX_MSG_ID;	//Message ID
			msg_buf_wr = 1'b1;
		end
		4'b0010: begin
			msg_buf_in = {5'b0, red_x_min, 5'b0, red_x_max};	//left & Right Most coordinate
			msg_buf_wr = 1'b1;
		end

	/*blue*/
		4'b0011: begin
			msg_buf_in = `BLUE_BOX_MSG_ID;	//Message ID
			msg_buf_wr = 1'b1;
		end
		4'b0101: begin
			msg_buf_in = {5'b0, blue_x_min, 5'b0, blue_x_max};	//left & Right Most coordinate
			msg_buf_wr = 1'b1;
		end

	/*teal*/
		4'b0110: begin
			msg_buf_in = `TEAL_BOX_MSG_ID;	//Message ID
			msg_buf_wr = 1'b1;
		end
		4'b0111: begin
			msg_buf_in = {5'b0, teal_x_min, 5'b0, teal_x_max};	//left & Right Most coordinate
			msg_buf_wr = 1'b1;
		end

	/*lime*/
		4'b1000: begin
			msg_buf_in = `LIME_BOX_MSG_ID;	//Message ID
			msg_buf_wr = 1'b1;
		end
		4'b1001: begin
			msg_buf_in = {5'b0, lime_x_min, 5'b0, lime_x_max};	//left & Right Most coordinate
			msg_buf_wr = 1'b1;
		end
		
	/*yellow*/
		4'b1010: begin
			msg_buf_in = `YELLOW_BOX_MSG_ID;	//Message ID
			msg_buf_wr = 1'b1;
		end
		4'b1011: begin
			msg_buf_in = {5'b0, yellow_x_min, 5'b0, yellow_x_max};	//left & Right Most coordinate
			msg_buf_wr = 1'b1;
		end
 			
	/*pink
		4'b1100: begin
			msg_buf_in = `PINK_BOX_MSG_ID;	//Message ID
			msg_buf_wr = 1'b1;
		end
		4'b1101: begin
			msg_buf_in = {5'b0, pink_x_min, 5'b0, pink_x_max};	//left & Right Most coordinate
			msg_buf_wr = 1'b1;
		end*/
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
						

endmodule
