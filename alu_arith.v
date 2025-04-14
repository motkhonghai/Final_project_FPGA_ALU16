module alu_arith (
    input [15:0] a, b,
    input [1:0] op, // 00=add, 01=sub, 10=mul, 11=div
    output reg [15:0] result,
    output reg carry, overflow
);
    always @(*) begin
        carry = 0;
        overflow = 0;
        case (op)
            2'b00: begin
                {carry, result} = a + b;
                overflow = (a[15] == b[15]) && (result[15] != a[15]);
            end
            2'b01: begin
                {carry, result} = a - b;
                overflow = (a[15] != b[15]) && (result[15] != a[15]);
            end
            2'b10: result = a * b;
            2'b11: result = (b != 0) ? a / b : 16'hFFFF;
            default: result = 16'd0;
        endcase
    end
endmodule
