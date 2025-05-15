module multiplier #(
    parameter N = 8  // Độ rộng bit
)(
    input  [N-1:0] A,      // Số thứ nhất
    input  [N-1:0] B,      // Số thứ hai
    output [2*N-1:0] P,    // Tích
    output overflow        // Cờ báo overflow
);

    // Tạo ma trận tích từng phần
    wire [N-1:0] pp [N-1:0];
    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_pp
            for (j = 0; j < N; j = j + 1) begin : gen_and
                assign pp[i][j] = A[j] & B[i];
            end
        end
    endgenerate

    // Các dây để lưu kết quả trung gian và carry
    wire [2*N-1:0] sum [N-1:0];
    wire [2*N-1:0] carry [N-1:0];

    // Gán giá trị ban đầu
    assign sum[0] = {{(N){1'b0}}, pp[0]};
    assign carry[0] = {(2*N){1'b0}};

    // Cộng các hàng tích từng phần
    generate
        for (i = 1; i < N; i = i + 1) begin : gen_add
            wire [2*N-1:0] shifted_pp;
            assign shifted_pp = {{(N-i){1'b0}}, pp[i], {(i){1'b0}}};
            assign {carry[i], sum[i]} = sum[i-1] + shifted_pp + carry[i-1];
        end
    endgenerate

    // Kết quả cuối cùng
    assign P = sum[N-1] + carry[N-1];

    // Kiểm tra overflow: nếu bất kỳ bit nào từ P[2*N-1:N] != 0, có overflow
    assign overflow = |P[2*N-1:N];

endmodule