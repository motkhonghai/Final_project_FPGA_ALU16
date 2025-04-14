module alu_shift (
    input [15:0] a,
    input [1:0] op, // 00=SHL, 01=SHR, 10=SAR, 11=ROL (not implemented here)
    output reg [15:0] result
);
    always @(*) begin
        case (op)
            2'b00: result = a << 1;                   // SHL
            2'b01: result = a >> 1;                   // SHR (logic)
            2'b10: result = $signed(a) >>> 1;         // SAR
            default: result = a;
        endcase
    end
endmodule
