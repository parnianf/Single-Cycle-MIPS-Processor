`timescale 1ns/1ns

module MIPS(clk, rst);
  input clk, rst;
  wire [5:0] OPC, func; 
  wire [1:0] Jump;
  wire [2:0] ALUOperation;
  wire Zero,RegDst, RegWrite, ALUSrc, MemRead, MemWrite, JalReg, JalWrite, MemtoReg, PCSrc;
  controller CU(Zero, OPC, func,RegDst, RegWrite, ALUSrc, ALUOperation, MemRead, MemWrite, JalReg, JalWrite, MemtoReg, PCSrc, Jump);
  datapath DP(clk, rst, RegDst, RegWrite, ALUSrc, ALUOperation, MemRead, MemWrite, JalReg, JalWrite, MemtoReg, PCSrc, Jump, Zero, OPC, func);
endmodule

module MIPS_TB();
  reg clk = 1'b0, rst = 1'b1;
  MIPS CUT(clk, rst);
  always #50 clk = ~clk;
  initial begin
    #100 rst = 1'b0;
    #10000 $stop;
  end
endmodule
    

