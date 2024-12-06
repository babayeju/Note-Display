`timescale 1ns / 1ps

// CHANGED
//`define Y_LOC 200
`define Y_LOC 400
//CHANGED

`define log2NUM_COLS 11
`define log2NUM_ROWS 10

module note_display #(parameter X_LOC = 16) (
    input clk, 
    input reset,
    input [10:0] x,
    input [9:0] y,
    input [5:0] note,
    output wire [7:0] rn,
    output wire [7:0] gn,
    output wire [7:0] bn 
    );
    
    reg [8:0] rom_base_addr;
    wire [8:0] rom_addr;
    	
	assign rom_addr = rom_base_addr + y[2:0];
    wire [7:0] rom_data;
	
    tcgrom char_rom (.addr(rom_addr), .data(rom_data));
    
    reg [1:0] color;
    
    //SHAKY
    wire [5:0] pitch;
    assign pitch = ((note > 6'd25 && note < 6'd50) ? (note + 6'd1) - 6'd25 : ((note >= 6'd50) ? (note + 6'd2) - 6'd50 : note));
    
    always @(*) begin
    if (y >= `Y_LOC && y < (`Y_LOC + 7)) begin
        color = 2'd0;
        case (x[`log2NUM_COLS-1:3])  // Check x location
            X_LOC: begin  // Handle X_LOC
                if (note == 6'd0) begin
                    rom_base_addr = (9'd32 << 3); // blank
                end else if (note <= 6'd25) begin
                    if (pitch <= 6'd12)
                        rom_base_addr = (9'd49 << 3); // 1
                    else if (pitch <= 6'd24)
                        rom_base_addr = (9'd50 << 3); // 2
                    else
                        rom_base_addr = (9'd51 << 3); // 3
                end else if (note <= 6'd49) begin
                    if (pitch <= 6'd12)
                        rom_base_addr = (9'd53 << 3); // 5
                    else if (pitch <= 6'd24)
                        rom_base_addr = (9'd52 << 3); // 4
                    else
                        rom_base_addr = (9'd53 << 3); // 3 // CHANGED TO 5 MAY NOT WORK!
                end else begin
                    if (pitch <= 6'd12)
                        rom_base_addr = (9'd53 << 3); // 5
                    else
                        rom_base_addr = (9'd54 << 3); // 6
                end
            end
            X_LOC + 1: begin  // Handle X_LOC + 1
                case (pitch)
                    6'd1, 6'd2, 6'd13, 6'd14, 6'd25: rom_base_addr = (9'd1 << 3);   // A
                    6'd3, 6'd15: rom_base_addr = (9'd2 << 3);    // B
                    6'd4, 6'd5, 6'd16, 6'd17: rom_base_addr = (9'd3 << 3);    // C
                    6'd6, 6'd7, 6'd18, 6'd19: rom_base_addr = (9'd4 << 3);    // D
                    6'd8, 6'd20: rom_base_addr = (9'd5 << 3);    // E
                    6'd9, 6'd10, 6'd21, 6'd22: rom_base_addr = (9'd6 << 3);    // F
                    6'd11, 6'd12, 6'd23, 6'd24: rom_base_addr = (9'd7 << 3);    // G
                    default: rom_base_addr = 9'h100;        // Default blank space
                endcase
            end
            X_LOC + 2: begin  // Handle X_LOC + 2
                rom_base_addr = ((pitch == 6'd2 || pitch == 6'd5 || pitch == 6'd7 || pitch == 6'd10 || 
                                  pitch == 6'd12 || pitch == 6'd14 || pitch == 6'd17 || pitch == 6'd19 || 
                                  pitch == 6'd22 || pitch == 6'd24) ? (9'd35 << 3) : 9'h100);
            end
            default: rom_base_addr = 9'h100; // Default for all other x locations
        endcase
    end else begin
        rom_base_addr = 9'h100; // Outside Y range
    end
end


    //SHAKY
    
    wire [7:0] rom_bit_select; 
	assign rom_bit_select = 8'b10000000 >> x[2:0];
	
    wire char_px; 
	assign char_px = |(rom_data & rom_bit_select);
    
    assign rn = (char_px && (color==2'd0)) ? 8'hFF : 8'h00;
    assign gn = (char_px && (color==2'd0)) ? 8'hFF : 8'h00;
    assign bn = (char_px && (color==2'd0)) ? 8'hFF : 8'h00;
    
    always @(*)
    $display("X=%d | Y=%d | char_px=%b | R=%h | G=%h | B=%h | rom_data=%b | rom_bit_select=%b | rom_base_addr=%h | X_LOC=%d | note=%d | pitch=%d | color=%d", 
                     x, y, char_px, rn, gn, bn, rom_data, rom_bit_select, rom_base_addr, X_LOC, note, pitch, color);
        
endmodule
