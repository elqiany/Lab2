module ChipInterface
    (output logic [7:0] D2_SEG, D1_SEG,
     output logic [3:0] D2_AN, 21_AN,
     output logic [15:0] LD,
     input logic  [15:0] SW,
     input logic  [ 3:0] BTN,
     input logic         CLOCK_100);

    EightSevenSegmentDisplays disp(.reset(BTN[2]),
                                    //other connections
                                    .*);


endmodule : ChipInterface
