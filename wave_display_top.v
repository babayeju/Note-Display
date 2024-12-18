module wave_display_top(
    input clk,
    input reset,
    input new_sample,
    input [15:0] sample,
    input [10:0] x,  // [0..1279]
    input [9:0]  y,  // [0..1023]     
    input valid,
    input vsync,
    output [7:0] r,
    output [7:0] g,
    output [7:0] b,
    
    //ADDED
    input [17:0] buffer
    //ADED
    
);

    wire [7:0] read_sample, write_sample;
    wire [8:0] read_address, write_address;
    wire read_index;
    wire write_en;
    wire wave_display_idle = ~vsync;

    wave_capture wc(
        .clk(clk),
        .reset(reset),
        .new_sample_ready(new_sample),
        .new_sample_in(sample),
        .write_address(write_address),
        .write_enable(write_en),
        .write_sample(write_sample),
        .wave_display_idle(wave_display_idle),
        .read_index(read_index)
    );
    
    ram_1w2r #(.WIDTH(8), .DEPTH(9)) sample_ram(
        .clka(clk),
        .clkb(clk),
        .wea(write_en),
        .addra(write_address),
        .dina(write_sample),
        .douta(),
        .addrb(read_address),
        .doutb(read_sample)
    );
    
    //ADDED
    wire [7:0] rn, gn, bn;
    note_top nt(
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y),
        .past(buffer[17:12]),
        .current(buffer[11:6]),
        .future(buffer[5:0]),
        .rn(rn),
        .gn(gn),
        .bn(bn)
    );
    //ADDED
 
    wire valid_pixel;
    wire [7:0] wd_r, wd_g, wd_b;
    
    //ADDED
    wire valid_note;
    //ADDED
    
    wave_display wd(
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y),
        .valid(valid),
        .read_address(read_address),
        .read_value(read_sample),
        .read_index(read_index),
        .valid_pixel(valid_pixel),
        .r(wd_r), .g(wd_g), .b(wd_b),
        //ADDED
        .rn(rn), .gn(gn), .bn(bn),
        .valid_note(valid_note)
        //ADDED
    );
    
    //CHANGED
    assign {r, g, b} = (valid_pixel | valid_note) ? {wd_r, wd_g, wd_b} : {3{8'b0}};
    //CHANGED

endmodule
