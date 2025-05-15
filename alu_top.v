module alu_top (
    input CLOCK_50,            // Clock 50 MHz
    input [17:0] SW,           // Switches: SW[7:0] = a, SW[15:8] = b, SW[17:16] = opcode
    input [3:0] KEY,           // Push-buttons: KEY[0] = rst_n, KEY[1] = start
    output [7:0] LEDR,         // LEDs: LEDR[0] = overflow, LEDR[1] = div_by_zero, LEDR[2] = zero, LEDR[3] = done
    output [6:0] HEX0, HEX1, HEX2, HEX3 // 7-segment displays for result
);

    // Dau vao ALU
    wire clk = CLOCK_50;
    wire rst_n = KEY[0];       // Active-low
    wire start = ~KEY[1];      // Active-low, nghich dao de active-high
    wire [7:0] a = SW[7:0];
    wire [7:0] b = SW[15:8];
    wire [1:0] opcode = SW[17:16];

    // Dau ra ALU
    wire [15:0] result;
    wire done, overflow, div_by_zero, zero;

    // Khoi tao ALU
    alu #(8) alu_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .done(done),
        .overflow(overflow),
        .div_by_zero(div_by_zero),
        .zero(zero)
    );

    // Gan cac co trang thai toi LED
    assign LEDR[0] = overflow;
    assign LEDR[1] = div_by_zero;
    assign LEDR[2] = zero;
    assign LEDR[3] = done;
    assign LEDR[7:4] = 4'b0000; // Tat cac LED con lai

    // Chuyen doi result (16-bit) thanh 4 chu so hex cho 7-segment
    reg [3:0] digit0, digit1, digit2, digit3;
    always @(result) begin
        digit0 = result[3:0];
        digit1 = result[7:4];
        digit2 = result[11:8];
        digit3 = result[15:12];
    end

    // Module hien thi 7-segment (moi HEX la 1 chu so hex)
    sevenseg_display seg0 (.digit(digit0), .seg(HEX0));
    sevenseg_display seg1 (.digit(digit1), .seg(HEX1));
    sevenseg_display seg2 (.digit(digit2), .seg(HEX2));
    sevenseg_display seg3 (.digit(digit3), .seg(HEX3));

endmodule

// Module hien thi 7-segment cho 1 chu so hex
module sevenseg_display (
    input [3:0] digit,
    output reg [6:0] seg
);
    // DE2 7-segment: active-low (0 bat, 1 tat)
    always @(digit) begin
        case (digit)
            4'h0: seg = 7'b1000000; // 0
            4'h1: seg = 7'b1111001; // 1
            4'h2: seg = 7'b0100100; // 2
            4'h3: seg = 7'b0110000; // 3
            4'h4: seg = 7'b0011001; // 4
            4'h5: seg = 7'b0010010; // 5
            4'h6: seg = 7'b0000010; // 6
            4'h7: seg = 7'b1111000; // 7
            4'h8: seg = 7'b0000000; // 8
            4'h9: seg = 7'b0010000; // 9
            4'hA: seg = 7'b0001000; // A
            4'hB: seg = 7'b0000011; // B
            4'hC: seg = 7'b1000110; // C
            4'hD: seg = 7'b0100001; // D
            4'hE: seg = 7'b0000110; // E
            4'hF: seg = 7'b0001110; // F
            default: seg = 7'b1111111; // Tat
        endcase
    end
endmodule