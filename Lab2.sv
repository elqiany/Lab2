`default_nettype none

module PaidCostComparator(
    input logic [3:0] Paid,
    input logic [3:0] Cost,
    output logic      ExactAmount,
    output logic      CoughUpMore,
    output logic      PaidGeCost);

    logic [7:0] Paid8, Cost8;
    logic lt, eq, gt;

    assign Paid8 = {4'b0000, Paid};
    assign Cost8 = {4'b0000, Cost};

    MagComp u_cmp (
        .A(Paid8),
        .B(Cost8),
        .AltB(lt),
        .AeqB(eq),
        .AgtB(gt)
    );

    assign CoughUpMore = lt;
    assign PaidGeCost = ~lt;
    assign ExactAmount = eq;

endmodule : PaidCostComparator

module PaidMinusCost (
    input logic [3:0] Paid,
    input logic [3:0] Cost,
    output logic [3:0] Change
);
    logic [7:0] Paid8, Cost8;
    logic [7:0] diff8;
    logic lt, eq, gt;
    logic bout;

    assign Paid8 = {4'b0000, Paid};
    assign Cost8 = {4'b0000, Cost};

    MagComp u_cmp (
        .A(Paid8),
        .B(Cost8),
        .AltB(lt),
        .AeqB(eq),
        .AgtB(gt)
    );

    Subtracter u_sub (
        .bout(bout),
        .bin(1'b0),
        .diff(diff8),
        .A(Paid8),
        .B(Cost8)
    );

    always_comb begin
        if (lt) Change = 4'd0;
        else    Change = diff8[3:0];
    end

endmodule : PaidMinusCost

