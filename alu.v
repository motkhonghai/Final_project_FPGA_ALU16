module alu #(
    parameter N = 8
)(
    input clk,
    input rst_n,
    input start,
    input [N-1:0] a,
    input [N-1:0] b,
    input [1:0] opcode, // 00: cong, 01: tru, 10: nhan, 11: chia
    output reg [2*N-1:0] result,
    output reg done,
    output reg overflow,
    output reg div_by_zero,
    output reg zero
);
    localparam IDLE = 2'b00, COMPUTE = 2'b01, DONE = 2'b10;
    reg [1:0] state;

    wire [N-1:0] sum, diff, quotient, remainder;
    wire [2*N-1:0] product;
    wire add_cout, sub_borrow, add_overflow, sub_overflow, mul_overflow, div_done, div_div_by_zero;

    cla_adder #(N) adder (
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(sum),
        .cout(add_cout),
        .overflow(add_overflow)
    );

    subtractor #(N) subtractor (
        .a(a),
        .b(b),
        .diff(diff),
        .borrow(sub_borrow),
        .overflow(sub_overflow)
    );

    multiplier #(N) multiplier (
        .A(a),
        .B(b),
        .P(product),
        .overflow(mul_overflow)
    );

    divider_operator #(N) divider (
        .clk(clk),
        .rst_n(rst_n),
        .start(start && opcode == 2'b11),
        .dividend(a),
        .divisor(b),
        .quotient(quotient),
        .remainder(remainder),
        .done(div_done),
        .div_by_zero(div_div_by_zero)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 0;
            done <= 0;
            overflow <= 0;
            div_by_zero <= 0;
            zero <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    overflow <= 0;
                    div_by_zero <= 0;
                    zero <= 0;
                    if (start) begin
                        state <= COMPUTE;
                    end
                end
                COMPUTE: begin
                    case (opcode)
                        2'b00: begin // Cong
                            result <= {{N{1'b0}}, sum};
                            overflow <= add_overflow;
                            zero <= (sum == 0);
                            state <= DONE;
                        end
                        2'b01: begin // Tru
                            result <= {{N{1'b0}}, diff};
                            overflow <= sub_overflow;
                            zero <= (diff == 0);
                            state <= DONE;
                        end
                        2'b10: begin // Nhan
                            result <= product;
                            overflow <= mul_overflow;
                            zero <= (product == 0);
                            state <= DONE;
                        end
                        2'b11: begin // Chia
                            if (div_done) begin
                                div_by_zero <= div_div_by_zero;
                                if (div_div_by_zero) begin
                                    result <= 0;
                                    zero <= 1;
                                end else begin
                                    result <= {{N{1'b0}}, quotient};
                                    zero <= (quotient == 0);
                                end
                                state <= DONE;
                            end
                        end
                        default: begin
                            result <= 0;
                            overflow <= 0;
                            div_by_zero <= 0;
                            zero <= 1;
                            state <= DONE;
                        end
                    endcase
                end
                DONE: begin
                    done <= 1;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule