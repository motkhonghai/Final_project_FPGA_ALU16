module divider_operator #(
    parameter N = 8  // Độ rộng bit
)(
    input clk,              // Clock
    input rst_n,            // Reset active-low
    input start,            // Bắt đầu chia
    input [N-1:0] dividend, // Số bị chia
    input [N-1:0] divisor,  // Số chia
    output reg [N-1:0] quotient,  // Thương
    output reg [N-1:0] remainder, // Dư
    output reg done,        // Hoàn thành
    output reg div_by_zero  // Lỗi chia cho 0
);

    reg [1:0] state;        // Trạng thái FSM
    localparam IDLE = 2'b00, COMPUTE = 2'b01, DONE = 2'b10;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            quotient <= 0;
            remainder <= 0;
            done <= 0;
            div_by_zero <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    div_by_zero <= 0;
                    if (start) begin
                        if (divisor == 0) begin
                            div_by_zero <= 1;
                            state <= DONE;
                        end else begin
                            quotient <= dividend / divisor;
                            remainder <= dividend % divisor;
                            state <= COMPUTE;
                        end
                    end
                end
                COMPUTE: begin
                    state <= DONE;
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