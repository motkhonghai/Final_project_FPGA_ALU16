// Module Subtractor
module subtractor #(
    parameter WIDTH = 8
) (
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] diff,
    output wire             borrow,
    output wire             overflow
);
    wire [WIDTH-1:0] b_inv = ~b;
    wire [WIDTH-1:0] sum_temp;
    wire             cout_temp;

    cla_adder #(WIDTH) cla_inst (
        .a(a),
        .b(b_inv),
        .cin(1'b1),
        .sum(sum_temp),
        .cout(cout_temp),
        .overflow(overflow)
    );

    assign diff = sum_temp;
    assign borrow = ~cout_temp;
endmodule