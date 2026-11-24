`timescale 1ns/1ps
`define DEPTH 16 
`define DATA_WIDTH  32
`define PTR_WIDTH  $clog2(`DEPTH) 
module async_fifo (
    input  wr_clk_i,
    input  rd_clk_i,
    input  rst_i,
    input  wr_en_i,
    input  rd_en_i,
    input  [`DATA_WIDTH-1:0] wdata_i,
    output reg [`DATA_WIDTH-1:0] rdata_o,
    output reg full_o,
    output reg empty_o,
    output reg overflow_o,
    output reg underflow_o
);

integer i;

// FIFO Memory
reg [`DATA_WIDTH-1:0] fifo [0:`DEPTH-1];

// Binary pointers
reg [`PTR_WIDTH-1:0] wr_pntr, rd_pntr;

// Toggle bits
reg wr_toggle, rd_toggle;

// Pointer synchronization

// Gray-coded {toggle, pointer} crossing the clock domains
//       (toggle is the MSB so pointer and toggle change together as ONE value)
reg  [`PTR_WIDTH:0] rd_gray_wr_clk;
reg  [`PTR_WIDTH:0] wr_gray_rd_clk;

// [NEW] Binary values recovered in the receiving domain (flag logic below is unchanged)
wire [`PTR_WIDTH:0] rd_bin_wr_clk = gray2bin(rd_gray_wr_clk);
wire [`PTR_WIDTH:0] wr_bin_rd_clk = gray2bin(wr_gray_rd_clk);

wire [`PTR_WIDTH-1:0] rd_pntr_wr_clk   = rd_bin_wr_clk[`PTR_WIDTH-1:0];
wire                  rd_toggle_wr_clk = rd_bin_wr_clk[`PTR_WIDTH];
wire [`PTR_WIDTH-1:0] wr_pntr_rd_clk   = wr_bin_rd_clk[`PTR_WIDTH-1:0];
wire                  wr_toggle_rd_clk = wr_bin_rd_clk[`PTR_WIDTH];

// [NEW] Binary -> Gray: g = b ^ (b >> 1)
function [`PTR_WIDTH:0] bin2gray(input [`PTR_WIDTH:0] b);
    bin2gray = b ^ (b >> 1);
endfunction

// [NEW] Gray -> Binary: each bit is the XOR of all Gray bits at or above it
function [`PTR_WIDTH:0] gray2bin(input [`PTR_WIDTH:0] g);
    integer k;
    begin
        gray2bin[`PTR_WIDTH] = g[`PTR_WIDTH];
        for (k = `PTR_WIDTH-1; k >= 0; k = k - 1)
            gray2bin[k] = gray2bin[k+1] ^ g[k];
    end
endfunction

// Write Logic

always @(posedge wr_clk_i or negedge rst_i)
begin
    if(rst_i==0) begin
        wr_pntr      <= 0;
        wr_toggle    <= 0;
        overflow_o   <= 0;

        for(i=0;i<`DEPTH;i=i+1)
            fifo[i] <= 0;
    end
    else begin

        overflow_o <= 0;

        if(wr_en_i) begin

            if(full_o)
                overflow_o <= 1;

            else begin

                fifo[wr_pntr] <= wdata_i;

                if(wr_pntr == `DEPTH-1) begin
                    wr_pntr   <= 0;
                    wr_toggle <= ~wr_toggle;
                end
                else
                    wr_pntr <= wr_pntr + 1;

            end
        end
    end
end

// Read Logic

always @(posedge rd_clk_i or negedge rst_i)
begin
    if(rst_i==0) begin
        rd_pntr      <= 0;
        rd_toggle    <= 0;
        rdata_o      <= 0;
        underflow_o  <= 0;
    end
    else begin

        underflow_o <= 0;

        if(rd_en_i) begin

            if(empty_o)
                underflow_o <= 1;

            else begin

                rdata_o <= fifo[rd_pntr];

                if(rd_pntr == `DEPTH-1) begin
                    rd_pntr   <= 0;
                    rd_toggle <= ~rd_toggle;
                end
                else
                    rd_pntr <= rd_pntr + 1;

            end
        end
    end
end

// Synchronize Read Pointer into Write Clock
// Two separate regs (pointer, toggle) replaced by one Gray-coded vector

always @(posedge wr_clk_i or negedge rst_i)
begin
    if(rst_i==0) begin
        rd_gray_wr_clk <= 0;
    end
    else begin
        rd_gray_wr_clk <= bin2gray({rd_toggle, rd_pntr});
    end
end

// Synchronize Write Pointer into Read Clock
// Two separate regs (pointer, toggle) replaced by one Gray-coded vector

always @(posedge rd_clk_i or negedge rst_i)
begin
    if(rst_i==0) begin
        wr_gray_rd_clk <= 0;
    end
    else begin
        wr_gray_rd_clk <= bin2gray({wr_toggle, wr_pntr});
    end
end

// Full Flag
//  now fed by the Gray->binary decoded values above

always @(*)
begin
    if(rst_i==0)
        full_o <= 0;
    else
        full_o <= (wr_pntr == rd_pntr_wr_clk) &&
                  (wr_toggle != rd_toggle_wr_clk);
end

// Empty Flag
// now fed by the Gray->binary decoded values above

always @(*)
begin
    if(rst_i==0)
        empty_o <= 1;
    else
        empty_o <= (wr_pntr_rd_clk == rd_pntr) &&
                   (wr_toggle_rd_clk == rd_toggle);
end

endmodule
