`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/26/2020 11:31:31 PM
// Design Name: 
// Module Name: eth_wrapperSim
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

`define SIMULATION
module eth_wrapperSim(

    );

	reg	                user_rst;
    reg	                dclk;
    reg	                sys_reset;
    reg 				sw_rst;
	reg	                axi_aclk;
    reg	                axi_aresetn;
    reg	                chnl_sw;
    reg	                rx_clk;
    reg	                tx_clk;

	wire    [63:0]      S_AXIS_0_tdata;
    wire    [7:0]       S_AXIS_0_tkeep;
    wire                S_AXIS_0_tready;
    wire                S_AXIS_0_tvalid;
    wire                S_AXIS_0_tlast;

    reg 				paused = 1;
	wire 				available;
	wire 	[31:0] 		pktcount;
	wire 				pcapfinished;

	wire    [31:0]      M_AXI_LITE_0_araddr;
    wire    [2:0]       M_AXI_LITE_0_arprot;
    reg                 M_AXI_LITE_0_arready;
    wire                M_AXI_LITE_0_arvalid;
    wire    [31:0]      M_AXI_LITE_0_awaddr;
    wire    [2:0]       M_AXI_LITE_0_awprot;
    wire                M_AXI_LITE_0_awready;
    wire                M_AXI_LITE_0_awvalid;
    wire                M_AXI_LITE_0_bready;
    wire    [1:0]       M_AXI_LITE_0_bresp;
    wire                M_AXI_LITE_0_bvalid;
    reg     [31:0]      M_AXI_LITE_0_rdata;
    wire                M_AXI_LITE_0_rready;
    wire    [1:0]       M_AXI_LITE_0_rresp;
    reg                 M_AXI_LITE_0_rvalid;
    wire    [31:0]      M_AXI_LITE_0_wdata;
    wire                M_AXI_LITE_0_wready;
    wire    [3:0]       M_AXI_LITE_0_wstrb;
    wire                M_AXI_LITE_0_wvalid;

    reg                 axi_rst;
    reg                 axi_rst1;
    reg                 axi_rst2;

	reg 				wc_fifo_pop;
	wire 	[11:0]		wordcount_fout;


    

	eth_wrapper eth_wrapper_inst(
    .sys_reset                  (sys_reset              ),
    .sw_rst                     (sw_rst                 ),
    .gt_refclk_p                (gt_refclk_p            ),
    .gt_refclk_n                (gt_refclk_n            ),
    .dclk                       (dclk                   ),
    .pcie_clk                   (axi_aclk               ),
    
    .gt_rxp_in                  (gt_rxp_in              ),
    .gt_rxn_in                  (gt_rxn_in              ),
    .gt_txp_out                 (gt_txp_out             ),
    .gt_txn_out                 (gt_txn_out             ),
    
    .chnl_sw                    (chnl_sw                ),
    
    .rx_axis_tvalid           	(S_AXIS_0_tvalid       ),
    .rx_axis_tdata            	(S_AXIS_0_tdata        ),
    .rx_axis_tlast            	(S_AXIS_0_tlast        ),
    .rx_axis_tkeep            	(S_AXIS_0_tkeep        ),
    .rx_axis_tready             (S_AXIS_0_tready       ),
    .rx_axis_tuser            	(        ),
    
    .rx_word_count              (wordcount_fout), 
    .pop_rx_count               (wc_fifo_pop),       
    .rx_word_count_valid        (wordcount_fout_valid),
    
//    .rx_axis_tvalid_1           (rx_axis_tvalid_1       ),    
//    .rx_axis_tdata_1            (rx_axis_tdata_1        ),
//    .rx_axis_tlast_1            (rx_axis_tlast_1        ),
//    .rx_axis_tkeep_1            (rx_axis_tkeep_1        ),
//    .rx_axis_tuser_1            (rx_axis_tuser_1        ),
    
    .tx_axis_tready           	(M_AXIS_0_tready       ),
    .tx_axis_tvalid           	(M_AXIS_0_tvalid       ),
    .tx_axis_tdata            	(M_AXIS_0_tdata        ),
    .tx_axis_tlast            	(M_AXIS_0_tlast        ),
    .tx_axis_tkeep            	(M_AXIS_0_tkeep        ),
    .tx_axis_tuser            	(1'b0        ),
    
//    .tx_axis_tready_1           (tx_axis_tready_1       ),
//    .tx_axis_tvalid_1           (tx_axis_tvalid_1       ),
//    .tx_axis_tdata_1            (tx_axis_tdata_1        ),
//    .tx_axis_tlast_1            (tx_axis_tlast_1        ),
//    .tx_axis_tkeep_1            (tx_axis_tkeep_1        ),
//    .tx_axis_tuser_1            (tx_axis_tuser_1        ),
    
//    .rx_clk_out_0               (rx_clk_out_0           ),
//    .tx_clk_out_0               (tx_clk_out_0           ),
//    .rx_clk_out_1               (rx_clk_out_1           ),
//    .tx_clk_out_1               (tx_clk_out_1           ),

//    .user_rx_reset_0            (user_rx_reset_0),
//    .user_rx_reset_1            (user_rx_reset_1),
//    .user_tx_reset_0            (user_tx_reset_0),
//    .user_tx_reset_1            (user_tx_reset_1),

    
    .stat_rx_status_0           (stat_rx_status_0         ),
    .stat_rx_block_lock_0       (stat_rx_block_lock_0     ),
    .stat_rx_status_1           (stat_rx_status_1         ),
    .stat_rx_block_lock_1       (stat_rx_block_lock_1     ),
    .stat_rx_bad_code_0         (stat_rx_bad_code_0       ),
    .stat_rx_valid_ctrl_code_0  (stat_rx_valid_ctrl_code_0),
    .stat_rx_bad_code_1         (stat_rx_bad_code_1       ),
    .stat_rx_valid_ctrl_code_1  (stat_rx_valid_ctrl_code_1),
    .stat_tx_local_fault_0      (stat_tx_local_fault_0    ),
    .stat_tx_local_fault_1      (stat_tx_local_fault_1    ),
    .stat_rx_local_fault_0      (stat_rx_local_fault_0    ),
    .stat_rx_local_fault_1      (stat_rx_local_fault_1    ),
    .stat_rx_remote_fault_0     (stat_rx_remote_fault_0   ),
    .stat_rx_remote_fault_1     (stat_rx_remote_fault_1   ),
    
    .FS                         (FS                     ),
    .qsfp1_rstn                 (qsfp1_rstn             ),
    .mod_present1               (mod_present1           ),
    .qsfp1_lpmode               (qsfp1_lpmode           ),
    .qsfp1_modselL              (qsfp1_modselL          )

    `ifdef SIMULATION
    ,.paused					(paused)
    ,.available					(available)
    ,.pktcount					(pktcount)
    ,.pcapfinished				(pcapfinished)
    ,.fdout_l0					()
    ,.fdout_l1					()

    `endif
    
    
    );

	MAXI_DMA dmaSimInst(
	.axi_clk 				(axi_aclk),
	.axi_resetn 			(axi_aresetn),
	.M_AXI_LITE_0_araddr 	(M_AXI_LITE_0_araddr),
	.M_AXI_LITE_0_arprot 	(M_AXI_LITE_0_arprot),
	.M_AXI_LITE_0_arready	(M_AXI_LITE_0_arready),
	.M_AXI_LITE_0_arvalid	(M_AXI_LITE_0_arvalid),
	.M_AXI_LITE_0_awaddr 	(M_AXI_LITE_0_awaddr),
	.M_AXI_LITE_0_awprot 	(M_AXI_LITE_0_awprot),
	.M_AXI_LITE_0_awready	(M_AXI_LITE_0_awready),
	.M_AXI_LITE_0_awvalid	(M_AXI_LITE_0_awvalid),
	.M_AXI_LITE_0_bready 	(M_AXI_LITE_0_bready),
	.M_AXI_LITE_0_bresp  	(M_AXI_LITE_0_bresp),
	.M_AXI_LITE_0_bvalid 	(M_AXI_LITE_0_bvalid),
	.M_AXI_LITE_0_rdata  	(M_AXI_LITE_0_rdata),
	.M_AXI_LITE_0_rready 	(M_AXI_LITE_0_rready),
	.M_AXI_LITE_0_rresp  	(M_AXI_LITE_0_rresp),
	.M_AXI_LITE_0_rvalid 	(M_AXI_LITE_0_rvalid),
	.M_AXI_LITE_0_wdata  	(M_AXI_LITE_0_wdata),
	.M_AXI_LITE_0_wready 	(M_AXI_LITE_0_wready),
	.M_AXI_LITE_0_wstrb  	(M_AXI_LITE_0_wstrb),
	.M_AXI_LITE_0_wvalid 	(M_AXI_LITE_0_wvalid),

	.S_AXIS_0_tdata 		(S_AXIS_0_tdata),
	.S_AXIS_0_tkeep 		(S_AXIS_0_tkeep),
	.S_AXIS_0_tready		(S_AXIS_0_tready),
	.S_AXIS_0_tvalid		(S_AXIS_0_tvalid),
	.S_AXIS_0_tlast 		(S_AXIS_0_tlast)
    );

    always @(posedge axi_aclk) begin
    	axi_rst1    <= user_rst | (~axi_aresetn);
    	axi_rst2    <= axi_rst1;
    	axi_rst     <= axi_rst2;
	end

    reg [0:0] wc_state;
    

    always@(posedge axi_aclk) begin
        if(axi_rst) begin
            wc_state <= 1'b0;
            wc_fifo_pop <= 1'b0;
            M_AXI_LITE_0_arready  <= 1'b0;
            M_AXI_LITE_0_rvalid   <= 1'b1;
        end
        else begin
            case(wc_state)
                1'b0: begin
                    wc_fifo_pop <= 1'b0;
                    M_AXI_LITE_0_arready   <= 1'b1;
                    if(M_AXI_LITE_0_arvalid & M_AXI_LITE_0_arready) begin
                        M_AXI_LITE_0_arready   <= 1'b0;
                        M_AXI_LITE_0_rvalid    <= 1'b1;
                        wc_state    <= 1'b1;
                    end
                end
                1'b1: begin
                    M_AXI_LITE_0_rvalid    <= 1'b1;
                    if(M_AXI_LITE_0_rvalid & M_AXI_LITE_0_rready) begin
                        M_AXI_LITE_0_rvalid     <= 1'b0;
                        wc_fifo_pop <= wordcount_fout_valid; 
                        wc_state    <= 1'b0;
                    end
                end
            endcase
        end
    end

    always@(posedge axi_aclk) begin
        if(wordcount_fout_valid) begin
            M_AXI_LITE_0_rdata  <= wordcount_fout;
        end
        else begin
            M_AXI_LITE_0_rdata  <= 'h0;
        end
    end

integer i = 0;

    initial begin
    	
    	axi_aclk = 0;
    	sys_reset = 0;
    	chnl_sw = 0;
    	sw_rst = 0;
    	axi_aresetn = 1;

    	#100;
    	sys_reset = 1;
    	sw_rst = 1;
    	axi_aresetn = 0;
    	#100;
    	sys_reset = 0;
    	sw_rst = 0;
    	axi_aresetn = 1;


        $dumpfile("../../../../bin/pcap10gb.lxt");
        $dumpvars(0);

        // Wait 100 ns for global reset to finish
        #400;
        #80;
        // reset <= 1;
        #600;
        paused <= 0;

        while (~pcapfinished ) begin
            //$display("stream: %8d %x %d %c%c %x %c%c%c%c%c%c%c%c", i, paused, pktcount, S_AXIS_0_tvalid ? "v" : " ",  S_AXIS_0_tlast ? "E":".", 
            //        S_AXIS_0_tdata,
            //        printable(S_AXIS_0_tdata[0*8+:8]), printable(S_AXIS_0_tdata[1*8+:8]), printable(S_AXIS_0_tdata[2*8+:8]), printable(S_AXIS_0_tdata[3*8+:8]),
            //        printable(S_AXIS_0_tdata[4*8+:8]), printable(S_AXIS_0_tdata[5*8+:8]), printable(S_AXIS_0_tdata[6*8+:8]), printable(S_AXIS_0_tdata[7*8+:8])
            //);

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

    always #7 axi_aclk = ~axi_aclk;


endmodule
