module alu_tb;
    parameter N = 8;
    reg clk, rst_n, start;
    reg [N-1:0] a, b;
    reg [1:0] opcode;
    wire [2*N-1:0] result;
    wire done, overflow, div_by_zero, zero;

    // Khoi tao ALU
    alu #(N) uut (
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

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Bien kiem tra
    integer errors = 0;
    reg [2*N-1:0] expected_result;
    reg expected_overflow, expected_div_by_zero, expected_zero;

    initial begin
        $display("Testing %d-bit ALU...", N); // Sửa dòng 36: thêm N

        // Reset
        rst_n = 0; start = 0; a = 0; b = 0; opcode = 0;
        #10 rst_n = 1;

        // Truong hop 1: Cong (100 + 50 = 150)
        a = 100; b = 50; opcode = 2'b00; start = 1; #10 start = 0;
        wait(done);
        expected_result = 150; expected_overflow = 0; expected_div_by_zero = 0; expected_zero = 0;
        $display("ADD: a=%d, b=%d, result=%d, overflow=%b, zero=%b (expected result=%d, overflow=%b, zero=%b)", 
                 a, b, result, overflow, zero, expected_result, expected_overflow, expected_zero);
        if (result !== expected_result || overflow !== expected_overflow || zero !== expected_zero) begin
            $display("Error: ADD failed");
            errors = errors + 1;
        end
        #10;

        // Truong hop 2: Tru (100 - 50 = 50)
        a = 100; b = 50; opcode = 2'b01; start = 1; #10 start = 0;
        wait(done);
        expected_result = 50; expected_overflow = 0; expected_div_by_zero = 0; expected_zero = 0;
        $display("SUB: a=%d, b=%d, result=%d, overflow=%b, zero=%b (expected result=%d, overflow=%b, zero=%b)", 
                 a, b, result, overflow, zero, expected_result, expected_overflow, expected_zero);
        if (result !== expected_result || overflow !== expected_overflow || zero !== expected_zero) begin
            $display("Error: SUB failed");
            errors = errors + 1;
        end
        #10;

        // Truong hop 3: Nhan (10 * 20 = 200)
        a = 10; b = 20; opcode = 2'b10; start = 1; #10 start = 0;
        wait(done);
        expected_result = 200; expected_overflow = 0; expected_div_by_zero = 0; expected_zero = 0;
        $display("MUL: a=%d, b=%d, result=%d, overflow=%b, zero=%b (expected result=%d, overflow=%b, zero=%b)", 
                 a, b, result, overflow, zero, expected_result, expected_overflow, expected_zero);
        if (result !== expected_result || overflow !== expected_overflow || zero !== expected_zero) begin
            $display("Error: MUL failed");
            errors = errors + 1;
        end
        #10;

        // Truong hop 4: Chia (200 / 50 = 4)
        a = 200; b = 50; opcode = 2'b11; start = 1; #10 start = 0;
        wait(done);
        expected_result = 4; expected_overflow = 0; expected_div_by_zero = 0; expected_zero = 0;
        $display("DIV: a=%d, b=%d, result=%d, div_by_zero=%b, zero=%b (expected result=%d, div_by_zero=%b, zero=%b)", 
                 a, b, result, div_by_zero, zero, expected_result, expected_div_by_zero, expected_zero);
        if (result !== expected_result || div_by_zero !== expected_div_by_zero || zero !== expected_zero) begin
            $display("Error: DIV failed");
            errors = errors + 1;
        end
        #10;

        // Truong hop 5: Chia cho 0 (100 / 0)
        a = 100; b = 0; opcode = 2'b11; start = 1; #10 start = 0;
        wait(done);
        expected_result = 0; expected_overflow = 0; expected_div_by_zero = 1; expected_zero = 1;
        $display("DIV_ZERO: a=%d, b=%d, result=%d, div_by_zero=%b, zero=%b (expected result=%d, div_by_zero=%b, zero=%b)", 
                 a, b, result, div_by_zero, zero, expected_result, expected_div_by_zero, expected_zero);
        if (result !== expected_result || div_by_zero !== expected_div_by_zero || zero !== expected_zero) begin
            $display("Error: DIV_ZERO failed");
            errors = errors + 1;
        end
        #10;

        // Truong hop 6: Cong tran (255 + 1 = 0)
        a = 255; b = 1; opcode = 2'b00; start = 1; #10 start = 0;
        wait(done);
        expected_result = 0; expected_overflow = 1; expected_div_by_zero = 0; expected_zero = 1;
        $display("ADD_OVF: a=%d, b=%d, result=%d, overflow=%b, zero=%b (expected result=%d, overflow=%b, zero=%b)", 
                 a, b, result, overflow, zero, expected_result, expected_overflow, expected_zero);
        if (result !== expected_result || overflow !== expected_overflow || zero !== expected_zero) begin
            $display("Error: ADD_OVF failed");
            errors = errors + 1;
        end
        #10;

        // Truong hop 7: Nhan tran (255 * 255 = 65025)
        a = 255; b = 255; opcode = 2'b10; start = 1; #10 start = 0;
        wait(done);
        expected_result = 65025; expected_overflow = 1; expected_div_by_zero = 0; expected_zero = 0;
        $display("MUL_OVF: a=%d, b=%d, result=%d, overflow=%b, zero=%b (expected result=%d, overflow=%b, zero=%b)", 
                 a, b, result, overflow, zero, expected_result, expected_overflow, expected_zero);
        if (result !== expected_result || overflow !== expected_overflow || zero !== expected_zero) begin
            $display("Error: MUL_OVF failed");
            errors = errors + 1;
        end
        #10;

        // Truong hop 8: Tru am (50 - 100 = 206)
        a = 50; b = 100; opcode = 2'b01; start = 1; #10 start = 0;
        wait(done);
        expected_result = 206; expected_overflow = 1; expected_div_by_zero = 0; expected_zero = 0;
        $display("SUB_OVF: a=%d, b=%d, result=%d, overflow=%b, zero=%b (expected result=%d, overflow=%b, zero=%b)", 
                 a, b, result, overflow, zero, expected_result, expected_overflow, expected_zero);
        if (result !== expected_result || overflow !== expected_overflow || zero !== expected_zero) begin
            $display("Error: SUB_OVF failed");
            errors = errors + 1;
        end
        #10;

        // Truong hop 9: Nhan voi 0 (100 * 0 = 0)
        a = 100; b = 0; opcode = 2'b10; start = 1; #10 start = 0;
        wait(done);
        expected_result = 0; expected_overflow = 0; expected_div_by_zero = 0; expected_zero = 1;
        $display("MUL_ZERO: a=%d, b=%d, result=%d, overflow=%b, zero=%b (expected result=%d, overflow=%b, zero=%b)", 
                 a, b, result, overflow, zero, expected_result, expected_overflow, expected_zero);
        if (result !== expected_result || overflow !== expected_overflow || zero !== expected_zero) begin
            $display("Error: MUL_ZERO failed");
            errors = errors + 1;
        end
        #10;

        // Truong hop 10: Tru ve 0 (50 - 50 = 0)
        a = 50; b = 50; opcode = 2'b01; start = 1; #10 start = 0;
        wait(done);
        expected_result = 0; expected_overflow = 0; expected_div_by_zero = 0; expected_zero = 1;
        $display("SUB_ZERO: a=%d, b=%d, result=%d, overflow=%b, zero=%b (expected result=%d, overflow=%b, zero=%b)", 
                 a, b, result, overflow, zero, expected_result, expected_overflow, expected_zero);
        if (result !== expected_result || overflow !== expected_overflow || zero !== expected_zero) begin
            $display("Error: SUB_ZERO failed");
            errors = errors + 1;
        end
        #10;

        // Truong hop 11: Chia cho 1 (255 / 1 = 255)
        a = 255; b = 1; opcode = 2'b11; start = 1; #10 start = 0;
        wait(done);
        expected_result = 255; expected_overflow = 0; expected_div_by_zero = 0; expected_zero = 0;
        $display("DIV_ONE: a=%d, b=%d, result=%d, div_by_zero=%b, zero=%b (expected result=%d, div_by_zero=%b, zero=%b)", 
                 a, b, result, div_by_zero, zero, expected_result, expected_div_by_zero, expected_zero);
        if (result !== expected_result || div_by_zero !== expected_div_by_zero || zero !== expected_zero) begin
            $display("Error: DIV_ONE failed");
            errors = errors + 1;
        end
        #10;

        // Bao cao ket qua
        $display("\nFinal report: %d errors detected", errors);
        if (errors == 0)
            $display("All representative test cases passed!");
        else
            $display("Test failed with %d errors.", errors);

        $finish;
    end
endmodule