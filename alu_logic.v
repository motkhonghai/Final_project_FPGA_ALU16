module alu_logic (
    input [15:0] a, b,
    input [2:0] op, // 000=AND, 001=OR, 010=XOR, 011=NOT, 100=PASS A, 101=PASS B
    output reg [15:0] result
);
    always @(*) begin
        case (op)
            3'b000: result = a & b;
            3'b001: result = a | b;
            3'b010: result = a ^ b;
            3'b011: result = ~a;
            3'b100: result = a;
            3'b101: result = b;
            default: result = 16'd0;
        endcase
    end
endmodule
