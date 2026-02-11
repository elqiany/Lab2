`default_nettype none

module tb_lab2;

  int errors = 0;

  //PaidCostComparator test

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
    $display("\nPaidCostComparator");
    $monitor($time,,
      "Paid=%b Cost=%b, Exact=%b GE=%b More=%b",
      pc_Paid, pc_Cost, pc_ExactAmount, pc_PaidGeCost, pc_CoughUpMore
    );

    // Base
    pc_Paid=0; pc_Cost=0; #5;

    // Paid < Cost
    pc_Paid=4; pc_Cost=7; #5;
    if (pc_CoughUpMore !== 1) begin
        $display("test failed :(");
    errors++;
    end
    if (pc_PaidGeCost  !== 0) begin
        $display("test failed :(");
        errors++;
    end
    if (pc_ExactAmount !== 0) begin
        $display("test failed :(");
        errors++;
    end

    // Paid == Cost != 0
    pc_Paid=9; pc_Cost=9; #5;
    if (pc_CoughUpMore !== 0) begin
        $display("test failed :(");
        errors++;
    end
    if (pc_PaidGeCost  !== 1) begin
        $display("test failed :(");
        errors++;
    end
    if (pc_ExactAmount !== 1) begin
        $display("test failed :(");
        errors++;
    end
    // Paid == Cost == 0, exact amount should b 0
    pc_Paid=0; pc_Cost=0; #5;
    if (pc_CoughUpMore !== 0) begin
        $display("test failed :(");
        errors++;
    end
    if (pc_PaidGeCost  !== 1) begin
        $display("test failed :(");
        errors++;
    end
    if (pc_ExactAmount !== 0) begin $display("test failed :("); errors++; end

    // Paid > Cost
    pc_Paid=12; pc_Cost=3; #5;
    if (pc_CoughUpMore !== 0) begin
        $display("test failed :(");
        errors++;
    end
    if (pc_PaidGeCost  !== 1) begin
        $display("test failed :(");
        errors++;
    end
    if (pc_ExactAmount !== 0) begin
        $display("test failed :(");
        errors++;
    end

    $display("Done: PaidCostComparator\n");
  end


  //PaidMinusCost

  logic [3:0] pm_Paid, pm_Cost, pm_Change;

  PaidMinusCost dut_pm (
    .Paid(pm_Paid),
    .Cost(pm_Cost),
    .Change(pm_Change)
  );

  initial begin
    #10;
    $display("\nPaidMinusCost");
    $monitor($time,,
      "Paid=%b Cost=%0b, Change=%b",
      pm_Paid, pm_Cost, pm_Change
    );

    pm_Paid=0; pm_Cost=0; #5;

    // Paid < Cost, outputs 0
    pm_Paid=2; pm_Cost=8; #5;
    if (pm_Change !== 4'd0) begin
        $display("test failed :(");
        errors++;
    end

    // Paid == Cost, outputs 0
    pm_Paid=5; pm_Cost=5; #5;
    if (pm_Change !== 4'd0) begin
        $display("test failed :(");
        errors++;
    end

    // Paid > Cost, difference
    pm_Paid=14; pm_Cost=9; #5;
    if (pm_Change !== 4'd5) begin
        $display("test failed :(");
        errors++;
    end

    $display("Passed PaidMinusCost\n");
  end

  //ChangeBox

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
    #10;
    $display("\nChangeBox");
    $monitor($time,,
      "chg_in=%b P=%b T=%b C=%b , coin=%b chg_out=%b , Prem=%b Trem=%b Crem=%b",
      cb_change_in, cb_P, cb_T, cb_C,
      cb_coin_out, cb_change_out,
      cb_Prem, cb_Trem, cb_Crem
    );

    cb_change_in=0; cb_P=0; cb_T=0; cb_C=0; #5;

    // change=8, P available
    cb_change_in=8; cb_P=1; cb_T=3; cb_C=3; #5;
    if (cb_coin_out   !== 3'b101) begin
        $display("test failed :(");
        errors++;
    end
    if (cb_change_out !== 4'd3)  begin
        $display("test failed :(");
        errors++;
    end
    if (cb_Prem !== 2'd0)  begin
        $display("test failed :(");
        errors++;
    end

    // change=4, no P, T available
    cb_change_in=4; cb_P=0; cb_T=1; cb_C=3; #5;
    if (cb_coin_out !== 3'b011) begin
        $display("test failed :(");
        errors++;
    end
    if (cb_change_out !== 4'd1) begin
        $display("test failed :(");
        errors++;
    end
    if (cb_Trem !== 2'd0) begin
        $display("test failed");
        errors++;
    end

    // change=2, only circles
    cb_change_in=2; cb_P=0; cb_T=0; cb_C=2; #5;
    if (cb_coin_out !== 3'b001) begin
        $display("test failed :(");
        errors++;
    end
    if (cb_change_out !== 4'd1) begin
        $display("test failed");
        errors++;
    end
    if (cb_Crem !== 2'd1) begin
        $display("test failed");
        errors++;
    end

    // change=0, no coin
    cb_change_in=0; cb_P=3; cb_T=3; cb_C=3; #5;
    if (cb_coin_out !== 3'b000) begin
        $display("test failed");
        errors++;
    end
    if (cb_change_out !== 4'd0) begin
        $display("test failed");
        errors++;
    end

    $display("Passed ChangeBox\n");
  end

  // ZorgianChangeBox
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
    #10;
    $display("\nZorgianChangeBox");
    $monitor($time,,
      "Cost=%b Paid=%b P=%b T=%b C=%b , F=%b S=%b Rem=%b , Exact=%b NE=%b More=%b",
      Cost, Paid, Pentagons, Triangles, Circles,
      FirstCoin, SecondCoin, Remaining,
      ExactAmount, NotEnoughChange, CoughUpMore
    );

    // baseline
    Cost=0; Paid=0; Pentagons=0; Triangles=0; Circles=0; #10;

    // Paid < Cost, CoughUpMore=1, Remaining=0, coins=0
    Cost=10; Paid=4; Pentagons=3; Triangles=3; Circles=3; #10;
    if (CoughUpMore !== 1) begin
        $display("test failed :(");
        errors++;
    end
    if (Remaining !== 0) begin
        $display("test failed :(");
        errors++;
    end
    if (FirstCoin !== 0 || SecondCoin !== 0) begin
        $display("test failed :(");
        errors++;
    end

    // Paid == Cost != 0, ExactAmount=1, Remaining=0, coins=0
    Cost=7; Paid=7; Pentagons=3; Triangles=3; Circles=3; #10;
    if (ExactAmount !== 1) begin
        $display("test failed :(");
        errors++;
    end
    if (Remaining !== 0) begin
        $display("test failed :(");
        errors++;
    end
    if (FirstCoin !== 0 || SecondCoin !== 0) begin
        $display("test failed :(");
        errors++;
    end

    // Change=8, stock, should be 5 then 3, Remaining 0
    Cost=2; Paid=10; Pentagons=3; Triangles=3; Circles=3; #10;

    // Change=10, P=2, 5 then 5, Remaining 0
    Cost=1; Paid=11; Pentagons=2; Triangles=3; Circles=3; #10;

    // Change=10, P=1 T=2, 5 then 3, Remaining 2 => NotEnoughChange=1
    Cost=1; Paid=11; Pentagons=1; Triangles=2; Circles=3; #10;
    if (NotEnoughChange !== 1) begin
        $display("test failed :(");
        errors++;
    end

    // Change=6, no P, T=2, 3 then 3, Remaining 0
    Cost=4; Paid=10; Pentagons=0; Triangles=2; Circles=3; #10;

    // Change=2, only one circle, 1 then 0, Remaining 1, NotEnoughChange=1
    Cost=5; Paid=7; Pentagons=0; Triangles=0; Circles=1; #10;
    if (NotEnoughChange !== 1) begin
        $display("test failed NotEnoughChange");
        errors++;
    end

    if (errors == 0) $display("\nyayyy tests passed");
    else  $display("\ntests failed", errors);

    $finish;
  end

endmodule : tb_lab2
