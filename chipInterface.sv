module chipInterface
(
    output logic [7:0]  D2_SEG, D1_SEG,
    output logic [3:0]  D2_AN,  D1_AN,
    output logic [15:0] LD,
    input  logic [15:0] SW,
    input  logic [3:0]  BTN,
    input  logic        CLOCK_100
);

    logic [3:0] Cost, Paid;
    logic [1:0] Pentagons, Triangles, Circles;

    assign Cost      = SW[15:12];
    assign Pentagons = SW[11:10];
    assign Triangles = SW[9:8];
    assign Circles   = SW[7:6];
    assign Paid      = SW[3:0];

    logic [2:0] FirstCoin, SecondCoin;
    logic [3:0] Remaining;
    logic       ExactAmount, NotEnoughChange, CoughUpMore;

    ZorgianChangeBox dut (
        .Cost(Cost),
        .Paid(Paid),
        .Pentagons(Pentagons),
        .Triangles(Triangles),
        .Circles(Circles),
        .FirstCoin(FirstCoin),
        .SecondCoin(SecondCoin),
        .Remaining(Remaining),
        .ExactAmount(ExactAmount),
        .NotEnoughChange(NotEnoughChange),
        .CoughUpMore(CoughUpMore)
    );

    assign LD[15]   = ExactAmount;
    assign LD[14]   = NotEnoughChange;
    assign LD[13]   = CoughUpMore;
    assign LD[12:0] = 13'b0;

    logic [3:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;

    logic [3:0] first_hex, second_hex;

    always_comb begin
      case (FirstCoin)
        3'b001: first_hex  = 4'd1;
        3'b011: first_hex  = 4'd3;
        3'b101: first_hex  = 4'd5;
        default: first_hex = 4'd0;
      endcase

      case (SecondCoin)
        3'b001: second_hex  = 4'd1;
        3'b011: second_hex  = 4'd3;
        3'b101: second_hex  = 4'd5;
        default: second_hex = 4'd0;
      endcase
    end

    logic [3:0] rem_tens, rem_ones;

    always_comb begin
        // Default blank unused displays 
        HEX0 = 4'hF;
        HEX1 = 4'hF;
        HEX2 = 4'hF;
        HEX3 = 4'hF;

        // Coin displays
        HEX7 = coin_to_hex4(FirstCoin);
        HEX6 = coin_to_hex4(SecondCoin);

        if (Remaining >= 4'd10) begin
            rem_tens = 4'd1;
            rem_ones = Remaining - 4'd10;
        end else begin
            rem_tens = 4'd0;
            rem_ones = Remaining;
        end

        // Blank HEX5 if tens digit is zero; show ones on HEX4
        HEX5 = (rem_tens == 4'd0) ? 4'hF : rem_tens;
        HEX4 = rem_ones;
    end

    EightSevenSegmentDisplays disp (
        .reset(BTN[2]),
        .*
    );

endmodule : chipInterface