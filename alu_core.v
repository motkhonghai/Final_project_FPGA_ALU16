module alu_core (
    input clk,
    input [15:0] a, b,
    input [3:0] opcode,
    output reg [15:0] result,
    output reg carry, overflow
);
    wire [15:0] arith_res, logic_res, shift_res;
    wire arith_carry, arith_ovf;

    // Mapping opcode
    wire [1:0] arith_op = opcode[1:0];     // 0000 - 0011
    wire [2:0] logic_op = opcode[2:0];     // 0100 - 0111, etc.
    wire [1:0] shift_op = opcode[1:0];     // 1000 - 1011

    alu_arith u_arith (.a(a), .b(b), .op(arith_op), .result(arith_res), .carry(arith_carry), .overflow(arith_ovf));
    alu_logic u_logic (.a(a), .b(b), .op(logic_op), .result(logic_res));
    alu_shift u_shift (.a(a), .op(shift_op), .result(shift_res));

    always @(posedge clk) begin
        carry = 0;
        overflow = 0;
        case (opcode[3:2])
            2'b00: begin // Arithmetic
                result = arith_res;
                carry = arith_carry;
                overflow = arith_ovf;
            end
            2'b01: result = logic_res;
            2'b10: result = shift_res;
            2'b11: result = 16'h0000; // Reserved / Clear
        endcase
    end
endmodule
