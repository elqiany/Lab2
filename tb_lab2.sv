`default_nettype none

module tb_lab2;

  int errors = 0;

  // UNIT TEST 1: PaidCostComparator

  logic [3:0] pc_Paid, pc_Cost;
  logic pc_ExactAmount, pc_CoughUpMore, pc_PaidGeCost;

  PaidCostComparator dut_pc (
    .Paid(pc_Paid),
    .Cost(pc_Cost),
    .ExactAmount(pc_ExactAmount),
    .CoughUpMore(pc_CoughUpMore),
    .PaidGeCost(pc_PaidGeCost)
  );

  initial begin
    $display("\n=== UNIT TEST: PaidCostComparator ===");
    $monitor($time,,
      "Paid=%0d Cost=%0d | Exact=%b GE=%b More=%b",
      pc_Paid, pc_Cost, pc_ExactAmount, pc_PaidGeCost, pc_CoughUpMore
    );

    // baseline
    pc_Paid=0; pc_Cost=0; #5;

    // Paid < Cost
    pc_Paid=4; pc_Cost=7; #5;
    if (pc_CoughUpMore !== 1) begin $display("FAIL PC lt: CoughUpMore"); errors++; end
    if (pc_PaidGeCost  !== 0) begin $display("FAIL PC lt: PaidGeCost");  errors++; end
    if (pc_ExactAmount !== 0) begin $display("FAIL PC lt: ExactAmount"); errors++; end

    // Paid == Cost != 0  (ExactAmount should be 1)
    pc_Paid=9; pc_Cost=9; #5;
    if (pc_CoughUpMore !== 0) begin $display("FAIL PC eq!=0: CoughUpMore"); errors++; end
    if (pc_PaidGeCost  !== 1) begin $display("FAIL PC eq!=0: PaidGeCost");  errors++; end
    if (pc_ExactAmount !== 1) begin $display("FAIL PC eq!=0: ExactAmount"); errors++; end

    // Paid == Cost == 0  (ExactAmount should be 0)
    pc_Paid=0; pc_Cost=0; #5;
    if (pc_CoughUpMore !== 0) begin $display("FAIL PC eq==0: CoughUpMore"); errors++; end
    if (pc_PaidGeCost  !== 1) begin $display("FAIL PC eq==0: PaidGeCost");  errors++; end
    if (pc_ExactAmount !== 0) begin $display("FAIL PC eq==0: ExactAmount"); errors++; end

    // Paid > Cost
    pc_Paid=12; pc_Cost=3; #5;
    if (pc_CoughUpMore !== 0) begin $display("FAIL PC gt: CoughUpMore"); errors++; end
    if (pc_PaidGeCost  !== 1) begin $display("FAIL PC gt: PaidGeCost");  errors++; end
    if (pc_ExactAmount !== 0) begin $display("FAIL PC gt: ExactAmount"); errors++; end

    $display("Done: PaidCostComparator\n");
  end


  // UNIT TEST 2: PaidMinusCost

  logic [3:0] pm_Paid, pm_Cost, pm_Change;

  PaidMinusCost dut_pm (
    .Paid(pm_Paid),
    .Cost(pm_Cost),
    .Change(pm_Change)
  );

  initial begin
    #1;

    $display("\n=== UNIT TEST: PaidMinusCost ===");
    $monitor($time,,
      "Paid=%0d Cost=%0d | Change=%0d",
      pm_Paid, pm_Cost, pm_Change
    );

    pm_Paid=0; pm_Cost=0; #5;

    // Paid < Cost => outputs 0
    pm_Paid=2; pm_Cost=8; #5;
    if (pm_Change !== 4'd0) begin $display("FAIL PM lt: Change not 0"); errors++; end

    // Paid == Cost => 0
    pm_Paid=5; pm_Cost=5; #5;
    if (pm_Change !== 4'd0) begin $display("FAIL PM eq: Change not 0"); errors++; end

    // Paid > Cost => difference
    pm_Paid=14; pm_Cost=9; #5;
    if (pm_Change !== 4'd5) begin $display("FAIL PM gt: Change wrong"); errors++; end

    $display("Done: PaidMinusCost\n");
  end


  // UNIT TEST 3: ChangeBox

  logic [3:0] cb_change_in, cb_change_out;
  logic [1:0] cb_P, cb_T, cb_C, cb_Prem, cb_Trem, cb_Crem;
  logic [2:0] cb_coin_out;

  ChangeBox dut_cb (
    .change_in(cb_change_in),
    .Pentagons(cb_P),
    .Triangles(cb_T),
    .Circles(cb_C),
    .coin_out(cb_coin_out),
    .change_out(cb_change_out),
    .pent_rem(cb_Prem),
    .tri_rem(cb_Trem),
    .circ_rem(cb_Crem)
  );

  initial begin
    #2;
    $display("\n=== UNIT TEST: ChangeBox ===");
    $monitor($time,,
      "chg_in=%0d P=%0d T=%0d C=%0d | coin=%b chg_out=%0d | Prem=%0d Trem=%0d Crem=%0d",
      cb_change_in, cb_P, cb_T, cb_C,
      cb_coin_out, cb_change_out,
      cb_Prem, cb_Trem, cb_Crem
    );

    cb_change_in=0; cb_P=0; cb_T=0; cb_C=0; #5;

    // change=8, P available => pick 5
    cb_change_in=8; cb_P=1; cb_T=3; cb_C=3; #5;
    if (cb_coin_out   !== 3'b101) begin $display("FAIL CB: should pick 5"); errors++; end
    if (cb_change_out !== 4'd3)   begin $display("FAIL CB: change_out should be 3"); errors++; end
    if (cb_Prem       !== 2'd0)   begin $display("FAIL CB: pent_rem should decrement"); errors++; end

    // change=4, no P, T available => pick 3
    cb_change_in=4; cb_P=0; cb_T=1; cb_C=3; #5;
    if (cb_coin_out   !== 3'b011) begin $display("FAIL CB: should pick 3"); errors++; end
    if (cb_change_out !== 4'd1)   begin $display("FAIL CB: change_out should be 1"); errors++; end
    if (cb_Trem       !== 2'd0)   begin $display("FAIL CB: tri_rem should decrement"); errors++; end

    // change=2, only circles => pick 1
    cb_change_in=2; cb_P=0; cb_T=0; cb_C=2; #5;
    if (cb_coin_out   !== 3'b001) begin $display("FAIL CB: should pick 1"); errors++; end
    if (cb_change_out !== 4'd1)   begin $display("FAIL CB: change_out should be 1"); errors++; end
    if (cb_Crem       !== 2'd1)   begin $display("FAIL CB: circ_rem should decrement"); errors++; end

    // change=0 => no coin
    cb_change_in=0; cb_P=3; cb_T=3; cb_C=3; #5;
    if (cb_coin_out   !== 3'b000) begin $display("FAIL CB: should pick none"); errors++; end
    if (cb_change_out !== 4'd0)   begin $display("FAIL CB: change_out should be 0"); errors++; end

    $display("Done: ChangeBox\n");
  end


  // TEST: ZorgianChangeBox

  logic [3:0] Cost, Paid, Remaining;
  logic [1:0] Pentagons, Triangles, Circles;
  logic [2:0] FirstCoin, SecondCoin;
  logic ExactAmount, NotEnoughChange, CoughUpMore;

  ZorgianChangeBox dut_top (
    .Cost(Cost),
    .Pentagons(Pentagons),
    .Triangles(Triangles),
    .Circles(Circles),
    .Paid(Paid),
    .FirstCoin(FirstCoin),
    .SecondCoin(SecondCoin),
    .Remaining(Remaining),
    .ExactAmount(ExactAmount),
    .NotEnoughChange(NotEnoughChange),
    .CoughUpMore(CoughUpMore)
  );

  initial begin
    #3;
    $display("\n=== TOP TEST: ZorgianChangeBox ===");
    $monitor($time,,
      "Cost=%0d Paid=%0d P=%0d T=%0d C=%0d | F=%b S=%b Rem=%0d | Exact=%b NE=%b More=%b",
      Cost, Paid, Pentagons, Triangles, Circles,
      FirstCoin, SecondCoin, Remaining,
      ExactAmount, NotEnoughChange, CoughUpMore
    );

    // baseline
    Cost=0; Paid=0; Pentagons=0; Triangles=0; Circles=0; #10;

    // Paid < Cost => CoughUpMore=1, Remaining=0, coins=0
    Cost=10; Paid=4; Pentagons=3; Triangles=3; Circles=3; #10;
    if (CoughUpMore !== 1) begin $display("FAIL TOP Paid<Cost: CoughUpMore"); errors++; end
    if (Remaining   !== 0) begin $display("FAIL TOP Paid<Cost: Remaining"); errors++; end
    if (FirstCoin   !== 0 || SecondCoin !== 0) begin $display("FAIL TOP Paid<Cost: coins should be 0"); errors++; end

    // Paid == Cost != 0 => ExactAmount=1, Remaining=0, coins=0
    Cost=7; Paid=7; Pentagons=3; Triangles=3; Circles=3; #10;
    if (ExactAmount !== 1) begin $display("FAIL TOP Paid==Cost!=0: ExactAmount"); errors++; end
    if (Remaining   !== 0) begin $display("FAIL TOP Paid==Cost!=0: Remaining"); errors++; end
    if (FirstCoin   !== 0 || SecondCoin !== 0) begin $display("FAIL TOP Paid==Cost!=0: coins should be 0"); errors++; end

    // Change=8, stock => should be 5 then 3, Remaining 0
    Cost=2; Paid=10; Pentagons=3; Triangles=3; Circles=3; #10;

    // Change=10, P=2 => 5 then 5, Remaining 0
    Cost=1; Paid=11; Pentagons=2; Triangles=3; Circles=3; #10;

    // Change=10, P=1 T=2 => 5 then 3, Remaining 2 => NotEnoughChange=1
    Cost=1; Paid=11; Pentagons=1; Triangles=2; Circles=3; #10;
    if (NotEnoughChange !== 1) begin $display("FAIL TOP change=10 P=1 T=2: NotEnoughChange"); errors++; end

    // Change=6, no P, T=2 => 3 then 3, Remaining 0
    Cost=4; Paid=10; Pentagons=0; Triangles=2; Circles=3; #10;

    // Change=2, only one circle => 1 then 0, Remaining 1 => NotEnoughChange=1
    Cost=5; Paid=7; Pentagons=0; Triangles=0; Circles=1; #10;
    if (NotEnoughChange !== 1) begin $display("FAIL TOP change=2 only1C: NotEnoughChange"); errors++; end

    if (errors == 0) $display("\nyayyy tests passed");
    else             $display("\ntests failed", errors);

    $finish;
  end

endmodule : tb_lab2
