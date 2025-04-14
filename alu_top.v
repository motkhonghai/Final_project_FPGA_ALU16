module alu_top (
    input clk,               // 50MHz from DE2 board
    input [17:0] SW,         // SW[15:0] for a, b
    input [3:0] KEY,         // opcode
    output [17:0] LEDR,      // result
    output [8:0] LEDG        // carry, overflow, zero
);
    wire [15:0] a = SW[15:8];
    wire [15:0] b = SW[7:0];
    wire [3:0] opcode = KEY[3:0];

    wire [15:0] result;
    wire carry, overflow;

    alu_core u_core (
        .clk(clk),
        .a(a), .b(b),
        .opcode(opcode),
        .result(result),
        .carry(carry),
        .overflow(overflow)
    );

    assign LEDR[15:0] = result;
    assign LEDG[0] = carry;
    assign LEDG[1] = overflow;
    assign LEDG[2] = (result == 16'd0) ? 1'b1 : 1'b0;
endmodule
