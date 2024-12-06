`timescale 1ns / 1ps

module note_top(
    input clk,
    input reset,
    input [10:0] x,
    input [9:0] y,
    input [5:0] past,
    input [5:0] current,
    input [5:0] future,
    output wire [7:0] rn,
    output wire [7:0] gn,
    output wire [7:0] bn
    );
    
    wire [7:0] rpast, gpast, bpast;
    wire [7:0] rcurrent, gcurrent, bcurrent;
    wire [7:0] rfuture, gfuture, bfuture;
    
    note_display #(50) nd_past(
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y),
        .note(past),
        .rn(rpast),
        .gn(gpast),
        .bn(bpast)
    );
    
    note_display #(58) nd_current(
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y),
        .note(current),
        .rn(rcurrent),
        .gn(gcurrent),
        .bn(bcurrent) 
    );
    
    note_display #(66) nd_future(
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y),
        .note(future),
        .rn(rfuture),
        .gn(gfuture),
        .bn(bfuture) 
    );
    
    assign rn = rpast | rcurrent | rfuture;
    assign gn = gpast | gcurrent | gfuture;
    assign bn = bpast | bcurrent | bfuture;
    
    always @(*)
    $display("X=%d | Y=%d | past=%d | rpast=%h | gpast=%h | bpast=%h |rc=%h | gc=%h | bc=%h | rn=%h | gn=%h | bn=%h", 
                     x, y, past, rpast, gpast, bpast, rcurrent, gcurrent, bcurrent, rn, gn, bn);
        
    
endmodule
