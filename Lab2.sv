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

module ChangeBox (
    input logic [3:0] change_in,
    input logic [1:0] pent_in,
    input logic [1:0] tri_in,
    input logic [1:0] circ_in,

    output logic [2:0] coin_out,
    output logic [3:0] change_out,
    output logic [1:0] pent_rem,
    output logic [1:0] tri_rem,
    output logic [1:0] circ_rem
);

    logic [7:0] ch8;
    assign ch8 = {4'b0000, change_in};

    logic lt5, eq5, gt5;
    logic lt3, eq3, gt3;
    logic lt1, eq1, gt1;

    //If pentagon is needed
    MagComp cmp5(.A(ch8),
                 .B(8'd5),
                 .AltB(lt5),
                 .AeqB(eq5),
                 .AgtB(gt5));
    //If triangle is needed
    MagComp cmp5(.A(ch8),
                 .B(8'd5),
                 .AltB(lt3),
                 .AeqB(eq3),
                 .AgtB(gt3));
    //If circle is needed
    MagComp cmp5(.A(ch8),
                 .B(8'd5),
                 .AltB(lt1),
                 .AeqB(eq1),
                 .AgtB(gt1));

    //change >= value
    logic ge5, ge3, ge1;
    assign ge5 = gt5 | eq5;
    assign ge3 = gt3 | eq3;
    assign ge1 = gt1 | eq1;

    //Check if coins exist
    logic hasP, hasT, hasC;
    assign hasP = (pent_in != 2'd0);
    assign hasT = (tri_in != 2'd0);
    assign hasC = (circ_in != 2'd0);

    logic canP, canT, canC;
    assign canP = ge5 & hasP;
    assign canT = ge3 & hasT;
    assign canC = ge1 & hasC;

    logic pickP, pickT, pickC;

    assign pickP = canP;
    assign pickT = (~pickP) & canT;
    assign pickC = (~pickP) & (~pickT) & canC;

    assign coin_out[2] = pickP;
    assign coin_out[1] = pickT;
    assign coin_out[0] = pickP | pickT | pickC;

    logic [3:0] subval;

    assign subval =
        pickP ? 4'd5 :
        pickT ? 4'd3 :
        pickC ? 4'd1 :
                4'd0;

    assign change_out = chang_in - subval;






