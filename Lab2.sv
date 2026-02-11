`default_nettype none

module PaidCostComparator(
    input logic [3:0] Paid,
    input logic [3:0] Cost,
    output logic      ExactAmount,
    output logic      CoughUpMore,
    output logic      PaidGeCost
);

    logic [7:0] Paid8, Cost8;
    logic lt, eq, gt;

    assign Paid8 = {4'b0000, Paid};
    assign Cost8 = {4'b0000, Cost};

    MagComp u_cmp (.A(Paid8),
                   .B(Cost8),
                   .AltB(lt),
                   .AeqB(eq),
                   .AgtB(gt));

    assign CoughUpMore = lt;
    assign PaidGeCost = ~lt;
    assign ExactAmount = eq & (Paid != 4'd0) & (Cost != 4'd0);

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

    MagComp u_cmp (.A(Paid8),
                   .B(Cost8),
                   .AltB(lt),
                   .AeqB(eq),
                   .AgtB(gt));

    Subtracter u_sub (.bout(bout),
                      .bin(1'b0),
                      .diff(diff8),
                      .A(Paid8),
                      .B(Cost8));

    logic [7:0] change8;
    Mux2to1 mux_change (.I0(8'd0),
                        .I1(diff8),
                        .S(~lt),
                        .Y(change8));

    assign Change = change8[3:0];

endmodule : PaidMinusCost

module ChangeBox (
    input logic [3:0] change_in,
    input logic [1:0] Pentagons,
    input logic [1:0] Triangles,
    input logic [1:0] Circles,

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
    MagComp cmp3(.A(ch8),
                 .B(8'd3),
                 .AltB(lt3),
                 .AeqB(eq3),
                 .AgtB(gt3));
    //If circle is needed
    MagComp cmp1(.A(ch8),
                 .B(8'd1),
                 .AltB(lt1),
                 .AeqB(eq1),
                 .AgtB(gt1));

    //Checks change >= value
    logic ge5, ge3, ge1;
    assign ge5 = gt5 | eq5;
    assign ge3 = gt3 | eq3;
    assign ge1 = gt1 | eq1;

    //Check if coins exist
    logic hasP, hasT, hasC;
    assign hasP = (Pentagons != 2'd0);
    assign hasT = (Triangles != 2'd0);
    assign hasC = (Circles != 2'd0);

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

    logic [7:0] m1_out, m2_out, val;

    Mux2to1 m1.(.I0(8'd0),
                .I1(8'd1),
                .S(pickC),
                .Y(m1_out));

    Mux2to1 m2.(.I0(m1_out),
                .I1(8'd3),
                .S(pickT),
                .Y(m2_out));

    Mux2to1 m3.(.I0(m2_out),
                .I1(8'd5),
                .S(pickP),
                .Y(val));

    assign change_out = change_in - val[3:0];

    logic [7:0] pent_keep, pent_dec, pent;
    logic [7:0] tri_keep, tri_dec, tria;
    logic [7:0] circ_keep, circ_dec, circ;

    assign pent_keep = {6'd0, Pentagons};
    assign tri_keep = {6'd0, Triangles};
    assign circ_keep = {6'd0, Circles};

    Mux2to1 mux_p(.I0(pent_keep),
                  .I1(pent_dec),
                  .S(pickP),
                  .Y(pent8));

    Mux2to1 mux_t(.I0(tri_keep),
                  .I1(tri_dec),
                  .S(pickT),
                  .Y(tria));

    Mux2to1 mux_c(.I0(circ_keep),
                  .I1(circ_dec),
                  .S(pickC),
                  .Y(circ));

    assign pent_rem = pent[1:0];
    assign tri_rem = tria[1:0];
    assign circ_rem = circ[1:0];

endmodule : ChangeBox

module ZorgianChangeBox(
    input logic [3:0] Cost,
    input logic [1:0] Pentagons,
    input logic [1:0] Triangles,
    input logic [1:0] Circles,
    input logic [3:0] Paid,

    output logic [2:0] FirstCoin,
    output logic [2:0] SecondCoin,
    output logic [3:0] Remaining,
    output logic ExactAmount,
    output logic NotEnoughChange,
    output logic CoughUpMore
);
    logic PaidGeCost;
    PaidCostComparator u_pc(.Paid(Paid),
                            .Cost(Cost),
                            .ExactAmount(ExactAmount),
                            .CoughUpMore(CoughUpMore),
                            .PaidGeCost(PaidGeCost));

    logic [3:0] Change;
    PaidMinusCost u_chg(.Paid(Paid),
                        .Cost(Cost),
                        .Change(Change));

    logic [3:0] change_mid;
    logic [1:0] P_mid, T_mid, C_mid;
    logic [3:0] change_after;

    ChangeBox box1(.change_in(Change),
                   .Pentagons(Pentagons),
                   .Triangles(Triangles),
                   .Circles(Circles),
                   .coin_out(FirstCoin),
                   .change_out(change_mid),
                   .pent_rem(P_mid),
                   .tri_rem(T_mid),
                   .circ_rem(C_mid));

    ChangeBox box2(.change_in(change_mid),
                   .Pentagons(P_mid),
                   .Triangles(T_mid),
                   .Circles(C_mid),
                   .coin_out(SecondCoin),
                   .change_out(change_after),
                   .pent_rem(),
                   .tri_rem(),
                   .circ_rem());

    assign Remaining = PaidGeCost ? change_after : 4'd0;

    logic PaidGtCost;
    assign PaidGtCost = PaidGeCost & ~ExactAmount & ~CoughUpMore;

    assign NotEnoughChange = PaidGtCost & (Remaining != 4'd0);

endmodule : ZorgianChangeBox






