`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2020 10:47:13 AM
// Design Name: 
// Module Name: MAXI_DMA
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


module MAXI_DMA(
	input 						axi_clk,
	input 						axi_resetn,
	output reg    	[31:0]		M_AXI_LITE_0_araddr ,
	output reg    	[2:0] 		M_AXI_LITE_0_arprot ,
	input           			M_AXI_LITE_0_arready,
	output reg          		M_AXI_LITE_0_arvalid,
	output reg    	[31:0]		M_AXI_LITE_0_awaddr ,
	output reg    	[2:0] 		M_AXI_LITE_0_awprot ,
	output reg          		M_AXI_LITE_0_awready,
	output reg          		M_AXI_LITE_0_awvalid,
	output reg          		M_AXI_LITE_0_bready ,
	output reg    	[1:0] 		M_AXI_LITE_0_bresp  ,
	output reg          		M_AXI_LITE_0_bvalid ,
	input     		[31:0]		M_AXI_LITE_0_rdata  ,
	output reg          		M_AXI_LITE_0_rready ,
	output reg    	[1:0] 		M_AXI_LITE_0_rresp  ,
	input		  	         	M_AXI_LITE_0_rvalid ,
	output reg    	[31:0]		M_AXI_LITE_0_wdata  ,
	output reg    	      		M_AXI_LITE_0_wready ,
	output reg    	[3:0] 		M_AXI_LITE_0_wstrb  ,
	output reg          		M_AXI_LITE_0_wvalid ,

	input    		[63:0]		S_AXIS_0_tdata ,
	input    		[7:0] 		S_AXIS_0_tkeep ,
	output reg     				S_AXIS_0_tready,
	input          				S_AXIS_0_tvalid,
	input          				S_AXIS_0_tlast 
    );

	reg [11:0]					pktSizeFrmLiteIntf;
	reg [11:0]					pktSizeCalced;
	reg [11:0]					pktSizeCalcedReg;
	reg [11:0]					pktSizeCalcedNext;

	initial begin
		M_AXI_LITE_0_araddr = 0;
		M_AXI_LITE_0_arprot = 0;
		M_AXI_LITE_0_arvalid= 0;
		M_AXI_LITE_0_awaddr = 0;
		M_AXI_LITE_0_awprot = 0;
		M_AXI_LITE_0_awready= 0;
		M_AXI_LITE_0_awvalid= 0;
		M_AXI_LITE_0_bready = 0;
		M_AXI_LITE_0_bresp  = 0;
		M_AXI_LITE_0_bvalid = 0;
		M_AXI_LITE_0_rready = 0;
		M_AXI_LITE_0_rresp  = 0;
		M_AXI_LITE_0_wdata  = 0;
		M_AXI_LITE_0_wready = 0;
		M_AXI_LITE_0_wstrb  = 0;
		M_AXI_LITE_0_wvalid = 0;
	end

	task readAXILiteIntf();
		begin
			M_AXI_LITE_0_araddr = 1;
			M_AXI_LITE_0_arvalid = 1;
			S_AXIS_0_tready = 0;
			wait(M_AXI_LITE_0_arready);
			@(posedge axi_clk);
			#1;
			M_AXI_LITE_0_rready = 1;
			M_AXI_LITE_0_araddr = 0;
			M_AXI_LITE_0_arvalid = 0;
			wait(M_AXI_LITE_0_rvalid);
			@(posedge axi_clk);
			#1;
			pktSizeFrmLiteIntf = M_AXI_LITE_0_rdata;
			M_AXI_LITE_0_rready = 0;
			if(pktSizeFrmLiteIntf != 0) begin // discard if 0
				@(posedge axi_clk);
				@(posedge axi_clk);
				@(posedge axi_clk);
				// let AXIS to receive data
				#1;
				S_AXIS_0_tready = 1;
				wait(pktSizeFrmLiteIntf == pktSizeCalcedNext);
				@(posedge axi_clk);
				#1;
				S_AXIS_0_tready = 0;
			end
			else begin
				@(posedge axi_clk);
			end
		end
	endtask

	task callAXILiteRead();
		integer randomWait;
		integer i;
		begin
			randomWait = $random()%10 + 1700;
			for(i=0; i<randomWait; i=i+1)
				@(posedge axi_clk);
			for(i=0; i < $random()%50 + 1000; i = i +1)
				readAXILiteIntf();
		end
	endtask

	always@(posedge axi_clk) begin
		callAXILiteRead();
	end

	always@(posedge axi_clk) begin
		if(~axi_resetn) begin
			pktSizeCalced <= 0;
			pktSizeCalcedReg <= 0;
		end
		else begin
			if(S_AXIS_0_tvalid  & S_AXIS_0_tready) begin
				pktSizeCalced <= pktSizeCalcedNext ;
				if(S_AXIS_0_tlast) begin
					pktSizeCalcedReg <= pktSizeCalcedNext;
					pktSizeCalced <= 0;
				end
			end
		end
	end

	always@(*) begin
		case(S_AXIS_0_tkeep) 
			8'h01: pktSizeCalcedNext =  pktSizeCalced + 11'd1;
			8'h03: pktSizeCalcedNext =  pktSizeCalced + 11'd2;
			8'h07: pktSizeCalcedNext =  pktSizeCalced + 11'd3;
			8'h0f: pktSizeCalcedNext =  pktSizeCalced + 11'd4;
			8'h1f: pktSizeCalcedNext =  pktSizeCalced + 11'd5;
			8'h3f: pktSizeCalcedNext =  pktSizeCalced + 11'd6;
			8'h7f: pktSizeCalcedNext =  pktSizeCalced + 11'd7;
			8'hff: pktSizeCalcedNext =  pktSizeCalced + 11'd8;
			default: pktSizeCalcedNext = pktSizeCalced + 11'd0;
		endcase // S_AXIS_0_tkeep
	end

	always@(posedge axi_clk) begin
		if(S_AXIS_0_tlast & S_AXIS_0_tvalid & S_AXIS_0_tready) begin
			if(pktSizeCalcedNext == pktSizeFrmLiteIntf)
				$display("Correct pkt Size : %d", pktSizeFrmLiteIntf);
			else begin
				$error("PktSize mismatch received: %d, calculated: %d", pktSizeFrmLiteIntf,pktSizeCalcedNext);
				$finish();
			end
		end
	end
endmodule
