module restoring_divider (
    input             clk,          // Đồng hồ
    input             rst,          // Reset
    input             start,        // Tín hiệu bắt đầu
    input      [7:0]  dividend,     // Số bị chia
    input      [7:0]  divisor,      // Số chia
    output reg [7:0]  quotient,     // Thương số
    output reg [7:0]  remainder,    // Số dư
    output reg        done,         // Tín hiệu hoàn thành
    output reg        error         // Tín hiệu lỗi (chia cho 0)
);

    // Định nghĩa trạng thái FSM
    parameter IDLE = 2'b00,         // Trạng thái chờ
              DIVIDING = 2'b01;     // Trạng thái đang chia
    reg [1:0] state;

    // Biến nội bộ
    reg [7:0] Q;                    // Thương số tạm
    reg [8:0] R;                    // Số dư tạm (9 bit để xử lý tràn)
    reg [7:0] D;                    // Số chia
    reg [3:0] count;                // Bộ đếm vòng lặp

    // FSM và logic điều khiển
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 1'b0;
            error <= 1'b0;
            quotient <= 8'b0;
            remainder <= 8'b0;
            Q <= 8'b0;
            R <= 9'b0;
            D <= 8'b0;
            count <= 4'b0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    error <= 1'b0;
                    if (start) begin
                        // Kiểm tra chia cho 0
                        if (divisor == 8'b0) begin
                            error <= 1'b1;
                            quotient <= 8'b0;
                            remainder <= dividend;
                            done <= 1'b1;
                            state <= IDLE;
                        end else begin
                            // Khởi tạo các giá trị
                            Q <= 8'b0;
                            R <= {1'b0, dividend};  // Mở rộng dividend thành 9 bit
                            D <= divisor;
                            count <= 4'b0;
                            state <= DIVIDING;
                        end
                    end
                end

                DIVIDING: begin
                    if (count < 8) begin
                        // Dịch trái R và Q
                        R <= {R[7:0], Q[7]};
                        Q <= {Q[6:0], 1'b0};
                        
                        // Trừ R cho D
                        if (R >= {1'b0, D}) begin
                            R <= R - {1'b0, D};
                            Q[0] <= 1'b1;
                        end else begin
                            Q[0] <= 1'b0;  // Phục hồi: đặt bit thương số là 0
                        end
                        
                        count <= count + 1;
                    end else begin
                        quotient <= Q;
                        remainder <= R[7:0];
                        done <= 1'b1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule