`timescale 1ns / 1ps
`define NULL 0

module pcapparser_10gbmac
	#(
		parameter pcap_filename = "none",
		parameter ipg = 32
	) (
		input 				pause,
		output reg 			available,

        output       		rx_clk_out_0,           // clock_out.clk
        output       		rx_clk_out_1, 

		output reg [31:0] 	pktcount,
		output reg 			newpkt = 0,
		output reg 			pcapfinished = 0,

		output reg 	[63:0]	rx_axis_tdata_o,
		output reg 			rx_axis_tvalid_o,
		output reg 			rx_axis_tlast_o,
		output reg 	[7:0]	rx_axis_tkeep_o, 
    	output reg 			rx_axis_tuser_o
	);

	reg clk_out;

	always #10 clk_out = ~clk_out;

	assign rx_clk_out_0 = clk_out;
	assign rx_clk_out_1 = clk_out;

	

	// buffers for message
	reg [7:0] global_header [0:23];
	reg [7:0] packet_header [0:15];

	reg  [2:0]  aso_out_empty = 0;

	integer swapped = 0;
	integer toNanos = 0;
	integer file = 0;
	integer r    = 0;
	integer eof  = 0;
	integer i    = 0;
	integer pktSz  = 0;
	integer diskSz = 0;
	integer countIPG = 0;

	initial begin
		available = 0;
		pktcount = 0;
		clk_out = 0;

		// open pcap file
		if (pcap_filename == "none") begin
			$display("pcap filename parameter not set");
			$finish();
		end

		file = $fopen(pcap_filename, "rb");
		if (file == `NULL) begin
			$display("can't read pcap input %s", pcap_filename);
			$finish();
		end

		// Initialize Inputs
		$display("PCAP: %m reading from %s", pcap_filename);

		// read binary global_header
		// r = $fread(file, global_header);
		r = $fread(global_header,file);

		// check magic signature to determine byte ordering
		if (global_header[0] == 8'hD4 && global_header[1] == 8'hC3 && global_header[2] == 8'hB2) begin
			$display(" pcap endian: swapped, ms");
			swapped = 1;
			toNanos = 32'd1000000;
		end else if (global_header[0] == 8'hA1 && global_header[1] == 8'hB2 && global_header[2] == 8'hC3) begin
			$display(" pcap endian: native, ms");
			swapped = 0;
			toNanos = 32'd1000000;
		end else if (global_header[0] == 8'h4D && global_header[1] == 8'h3C && global_header[2] == 8'hb2) begin
			$display(" pcap endian: swapped, nanos");
			swapped = 1;
			toNanos = 32'd1;
		end else if (global_header[0] == 8'hA1 && global_header[1] == 8'hB2 && global_header[2] == 8'h3c) begin
			$display(" pcap endian: native, nanos");
			swapped = 0;
			toNanos = 32'd1;
		end else begin
			$display(" pcap endian: unrecognised format %02x%02x%02x%02x", global_header[0], global_header[1], global_header[2], global_header[3] );
			$finish();
		end
	end

	always @(posedge clk_out)
	begin
		if (eof == 0 && diskSz == 0 && countIPG == 0) begin
			// read packet header
			// fields of interest are U32 so bear in mind the byte ordering when assembling
			// multibyte fields
			r = $fread(packet_header, file);
			if (swapped == 1) begin
				pktSz  	= {packet_header[11],packet_header[10],packet_header[9] ,packet_header[8] };
				diskSz 	= {packet_header[15],packet_header[14],packet_header[13],packet_header[12]};
			end else begin
				pktSz 	=  {packet_header[ 8],packet_header[ 9],packet_header[10],packet_header[11]};
				diskSz 	= {packet_header[12],packet_header[13],packet_header[14],packet_header[15]};
			end

			$display("PCAP:  packet %0d: incl_length %0d orig_length %0d", pktcount, pktSz, diskSz );

			available 	<= 1;
			newpkt 		<= 1;
			pktcount 	<= pktcount + 1;
			countIPG 	<= ipg;	// reload interpacket gap counter

			rx_axis_tlast_o 	<= 0;
			rx_axis_tvalid_o 	<= 0;

			// bytes before EOP should be "07070707FB555555", MAC framing check digit
			rx_axis_tdata_o <= 64'h07070707FB555555;
		end else if ( diskSz > 0) begin

			// packet content is byte-aligned, no swapping required
			if (~pause) begin

				newpkt <= 0;
				diskSz <= (diskSz > 7) ? diskSz - 8 : 0;

				aso_out_empty 	<= (diskSz > 8) ? 0 : 8 - diskSz;
				rx_axis_tlast_o <= diskSz <= 8;


				rx_axis_tdata_o[7*8+:8] <= diskSz > 7 ? $fgetc(file) : 8'bx;
				rx_axis_tdata_o[6*8+:8] <= diskSz > 6 ? $fgetc(file) : 8'bx;
				rx_axis_tdata_o[5*8+:8] <= diskSz > 5 ? $fgetc(file) : 8'bx;
				rx_axis_tdata_o[4*8+:8] <= diskSz > 4 ? $fgetc(file) : 8'bx;
				rx_axis_tdata_o[3*8+:8] <= diskSz > 3 ? $fgetc(file) : 8'bx;
				rx_axis_tdata_o[2*8+:8] <= diskSz > 2 ? $fgetc(file) : 8'bx;
				rx_axis_tdata_o[1*8+:8] <= diskSz > 1 ? $fgetc(file) : 8'bx;
				rx_axis_tdata_o[0*8+:8] <= diskSz > 0 ? $fgetc(file) : 8'bx;

				rx_axis_tkeep_o[7] <= diskSz > 7 ? 1'b1 : 1'b0;
				rx_axis_tkeep_o[6] <= diskSz > 6 ? 1'b1 : 1'b0;
				rx_axis_tkeep_o[5] <= diskSz > 5 ? 1'b1 : 1'b0;
				rx_axis_tkeep_o[4] <= diskSz > 4 ? 1'b1 : 1'b0;
				rx_axis_tkeep_o[3] <= diskSz > 3 ? 1'b1 : 1'b0;
				rx_axis_tkeep_o[2] <= diskSz > 2 ? 1'b1 : 1'b0;
				rx_axis_tkeep_o[1] <= diskSz > 1 ? 1'b1 : 1'b0;
				rx_axis_tkeep_o[0] <= diskSz > 0 ? 1'b1 : 1'b0;
				// $display("diskSz %d", diskSz);

				eof = $feof(file);
				if ( eof != 0 || diskSz == 1) begin
					available 		<= 0;
				end else begin
					rx_axis_tvalid_o<= 1;
				end
			end else begin
				rx_axis_tvalid_o 	<= 0;
			end

		end else if (countIPG > 0) begin
			countIPG 			<= countIPG - 1;
			rx_axis_tlast_o 	<= 0;
			rx_axis_tvalid_o 	<= 0;
			// byte after EOP should be "FD", MAC framing check digit
			rx_axis_tdata_o 	<= (aso_out_empty == 0 && rx_axis_tlast_o) ? 64'hFD00000000000000 : 64'b0;

		end else if (eof != 0) begin
			pcapfinished 		<= 1;	// terminal loop here
			rx_axis_tlast_o 	<= 0;
			rx_axis_tvalid_o 	<= 0;
			rx_axis_tdata_o 	<= 64'bx;
		end


	end

endmodule