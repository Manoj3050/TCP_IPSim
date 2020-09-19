`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2020 09:42:09 AM
// Design Name: 
// Module Name: pcapparser_10gbmac_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps
`define NULL 0

// Engineer:	Chris Shucksmith
// Description:
//	Utility to replay a pcap file and record the result. It should yield the same
//  packets with capture times updated to simulation times. Compare tcpdump output
//  with times supressed to check correctness.

module pcapparser_10gbmac_test;

	// Inputs
	wire CLOCK;
	reg paused = 1;
	wire available;
	wire [7:0] pktcount;
	wire pcapfinished;

    wire 	[63:0]	rx_axis_tdata;
	wire 			rx_axis_tvalid;
	wire 			rx_axis_tlast;
	wire 	[7:0]	rx_axis_tkeep;
    wire 			rx_axis_tuser;



	reg reset = 1;

	// Instantiate the Unit Under Test (UUT)
	pcapparser_10gbmac #(
		.pcap_filename( "../../../../pcap/capture.pcap" ),
		.ipg(4)
	) pcap (
		.rx_clk_out_0(CLOCK),
		.rx_clk_out_1(),
		.pause(paused),
		.available(available),
		.pktcount(pktcount),
		.pcapfinished(pcapfinished),

		.rx_axis_tdata_o 	(rx_axis_tdata),
		.rx_axis_tvalid_o	(rx_axis_tvalid),
		.rx_axis_tlast_o 	(rx_axis_tlast),
		.rx_axis_tkeep_o 	(rx_axis_tkeep), 
		.rx_axis_tuser_o	(rx_axis_tuser)
	);

	/*pcapwriter_10gbmac #(
		.pcap_filename( "bin/tcp-4846-connect-disconnect.output.pcap" )
	) pcapwr (
		.clk_in(CLOCK),

		// Avalon-ST output bus
		.aso_in_data(aso_out_data),
		.aso_in_ready(aso_out_ready),
		.aso_in_valid(aso_out_valid),
		.aso_in_sop(aso_out_sop),
		.aso_in_empty(aso_out_empty),
		.aso_in_eop(aso_out_eop),
		.aso_in_error(aso_out_error)
	);*/


	//always #10 CLOCK = ~CLOCK;
	// always #100 paused = ~paused;

	integer i = 0;

	initial begin

		$dumpfile("../../../../bin/pcap10gb.lxt");
		$dumpvars(0);

		// Wait 100 ns for global reset to finish
		#400;
		reset <= 0;
		#80;
		// reset <= 1;
		#600;
		paused <= 0;

		while (~pcapfinished ) begin
			$display("stream: %8d %x %d %c%c %x %c%c%c%c%c%c%c%c", i, paused, pktcount, rx_axis_tvalid ? "v" : " ",  rx_axis_tlast ? "E":".", 
					rx_axis_tdata,
					printable(rx_axis_tdata[0*8+:8]), printable(rx_axis_tdata[1*8+:8]), printable(rx_axis_tdata[2*8+:8]), printable(rx_axis_tdata[3*8+:8]),
					printable(rx_axis_tdata[4*8+:8]), printable(rx_axis_tdata[5*8+:8]), printable(rx_axis_tdata[6*8+:8]), printable(rx_axis_tdata[7*8+:8])
				);

			#20
			i = i+1;
		end

		$finish;

	end

	function [7:0] printable;
        input [7:0] a;
        begin
            printable = (a === 8'bx) ? "x" : ((a > 31 && a < 127) ? a : ".");
        end
    endfunction

endmodule

