`timescale 1ns/1ns

module ALU(A, B, ALUOperation, Zero, ALUResult);
  input [31:0] A, B;
  input [2:0] ALUOperation;
  output [31:0] ALUResult;
  reg [31:0] ALUResult;
  output Zero;
  assign Zero = (ALUResult == 32'd0);
  always @(ALUOperation, A, B)begin
    case(ALUOperation)
        3'b000 : ALUResult = A & B;
        3'b001 : ALUResult = A | B;
        3'b010 : ALUResult = A + B;
        3'b110 : ALUResult = A - B;
        3'b111 : ALUResult = A < B ? 32'd1 : 32'd0;
    endcase
  end
endmodule

module SignExtend (in, out);
  input [15:0] in;
  output [31:0] out;
  assign out[15:0] = in[15:0];
  assign out[31:16] = in[15];
endmodule

module Multiplexer2to1 #(parameter N = 2)(A, B, sel, out);
  input [N-1:0] A, B;
  input sel;
  output [N-1:0] out;
  assign out = sel ? B : A;
endmodule

module Multiplexer3to1 #(parameter N = 2)(A, B, C, sel, out);
  input [N-1:0] A, B, C;
  input [1:0] sel;
  output [N-1:0] out;
  reg [N-1:0] out;
  always @(A, B, C, sel)begin
    case(sel)
      2'b00: out = A;
      2'b01: out = B;
      2'b10: out = C;
    endcase
  end
endmodule

module ShiftLeft32(in, out);
  input [31:0] in;
  output [31:0] out;
  assign out = {in[29:0],2'b00};
endmodule


module ShiftLeft26(in, out);
  input [25:0] in;
  output [27:0] out;
  assign out = {in[25:0],2'b00};
endmodule


module DataMemory(Address, WriteData, MemWrite, MemRead, clk, ReadData);
  input [31:0] Address, WriteData;
  input MemWrite, MemRead, clk;
  output [31:0] ReadData;
  reg [31:0] memory [0:2048];
  always @(posedge clk)begin
    if(MemWrite)
      memory[Address] <= WriteData;
  end
  initial begin
    $readmemb("array.txt",memory);
  end
  assign ReadData = MemRead ? memory[Address] : 32'd0;
endmodule

module RegisterFile(ReadRegister1, ReadRegister2, WriteRegister, WriteData, RegWrite, clk, ReadData1, ReadData2);
  input [4:0] ReadRegister1, ReadRegister2, WriteRegister;
  input [31:0] WriteData;
  input RegWrite, clk;
  output [31:0]  ReadData1, ReadData2;
  reg [31:0] registers [0:31];
  initial begin
    registers[0] = 32'd0;
  end
  assign ReadData1 = (ReadRegister1 == 5'd0) ? 32'd0 : registers[ReadRegister1];
  assign ReadData2 = (ReadRegister2 == 5'd0) ? 32'd0 : registers[ReadRegister2];
  always @(posedge clk)begin
    if(RegWrite)
      registers[WriteRegister] <= WriteData;
    end
endmodule

module Adder(A, B, out);
  input [31:0] A, B;
  output [31:0] out;
  assign out = A + B;
endmodule

module InstructionMemory(Address, instruction);
  input [31:0] Address;
  output [31:0] instruction;
  reg [31:0] memory [0:2047];  
  initial begin
    $readmemb("instructions.txt",memory);
  end
  assign instruction = memory[Address];
endmodule

module PC(pc, clk, rst, next_pc);
  input [31:0] pc;
  input clk, rst;
  output [31:0] next_pc;
  reg [31:0] next_pc;
  always @(posedge clk, posedge rst)begin
    if(rst)
      next_pc <= 32'd0;
    else
      next_pc <= pc;
  end
endmodule
  
module datapath(clk, rst, RegDst, RegWrite, ALUSrc, ALUOperation, MemRead, MemWrite, JalReg, JalWrite, MemtoReg, PCSrc, Jump, Zero, OPC, func);
  input clk, rst, RegDst, RegWrite, ALUSrc, MemRead, MemWrite, JalReg, JalWrite, MemtoReg, PCSrc;
  input [1:0] Jump;
  input [2:0] ALUOperation;
  output [5:0] OPC, func;
  output Zero;
  wire [31:0] PCIn, PCOut, inst, SEOut, SHL32Out, adder1Out, adder2Out, ReadData1, ReadData2, ALUResult, ReadData;
  wire [4:0] mux1Out, mux2Out;
  wire [31:0] mux3Out, mux4Out, mux6Out, mux7Out;
  wire [27:0] shl26out;
  assign OPC = inst[31:26];
  assign func = inst[5:0];
  
  PC pc(PCIn, clk, rst, PCOut);
  InstructionMemory IM(PCOut, inst);
  Multiplexer2to1 #(5) mux1(inst[20:16], inst[15:11], RegDst, mux1Out);
  Multiplexer2to1 #(5) mux2(mux1Out, 5'd31, JalReg, mux2Out);
  Multiplexer2to1 #(32) mux3(mux7Out, adder1Out, JalWrite, mux3Out);
  RegisterFile RF(inst[25:21], inst[20:16], mux2Out, mux3Out, RegWrite, clk, ReadData1, ReadData2);
  SignExtend SE(inst[15:0], SEOut);
  ShiftLeft32 SHL32(SEOut, SHL32Out);
  ShiftLeft26 SHL26(inst[25:0], shl26out);
  Adder adder1(32'd4, PCOut, adder1Out);
  Adder adder2(SHL32Out, adder1Out, adder2Out);
  Multiplexer2to1 #(32) mux4(adder1Out, adder2Out, PCSrc, mux4Out);
  Multiplexer3to1 #(32) mux5(mux4Out,{adder1Out[31:28], shl26out}, ReadData1, Jump,PCIn);
  Multiplexer2to1 #(32) mux6(ReadData2, SEOut, ALUSrc, mux6Out);
  ALU alu(ReadData1, mux6Out, ALUOperation, Zero, ALUResult);
  DataMemory DM(ALUResult, ReadData2, MemWrite, MemRead, clk, ReadData);
  Multiplexer2to1 #(32) mux7(ALUResult, ReadData, MemtoReg, mux7Out);
  
endmodule


  
  
  
