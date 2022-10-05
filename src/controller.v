`timescale 1ns/1ns

module controller(Zero, OPC, func,RegDst, RegWrite, ALUSrc, ALUOperation, MemRead, MemWrite, JalReg, JalWrite, MemtoReg, PCSrc, Jump);
  input  Zero;
  input [5:0] OPC, func;
  output RegDst, RegWrite, ALUSrc, MemRead, MemWrite, JalReg, JalWrite, MemtoReg, PCSrc;
  output [1:0] Jump;
  output [2:0] ALUOperation;
  reg RegDst, RegWrite, ALUSrc, MemRead, MemWrite, JalReg, JalWrite, MemtoReg;
  reg [1:0] Jump;
  reg [2:0] ALUOperation;
  reg [1:0] ALUOp;
  reg branchEq,branchNe;
  always@(OPC, func)begin
    Jump = 2'b00;
    {RegDst, RegWrite, ALUSrc, MemRead, MemWrite, JalReg, JalWrite, MemtoReg, branchEq ,branchNe} = 10'd0;
    ALUOp = 2'b00;
    case(OPC)
      6'b000000: begin 
        if(func == 6'b001000)//jr
          Jump = 2'b10;
        else begin//R-type
          RegDst = 1'b1;
          RegWrite = 1'b1;
          ALUOp = 2'b10;
        end
      end
      6'b001000: begin//addi
        RegWrite = 1'b1;
        ALUSrc = 1'b1;
        ALUOp = 2'b00;
      end
      6'b001010: begin//slti
        RegWrite = 1'b1;
        ALUSrc = 1'b1;
        ALUOp = 2'b11;
      end
      6'b100011: begin//lw
        RegWrite = 1'b1;
        ALUSrc = 1'b1;
        MemtoReg = 1'b1;
        MemRead = 1'b1;
        ALUOp = 2'b00;
      end
      6'b101011: begin//sw
        ALUSrc = 1'b1;
        MemWrite = 1'b1;
        ALUOp = 2'b00;
      end
      6'b000010: begin//j
        Jump = 2'b01;
      end
      6'b000011: begin//jal
        Jump = 2'b01;
        JalReg = 1'b1;
        JalWrite = 1'b1;
        RegWrite = 1'b1;
      end
      6'b000100: begin //beq
        branchEq = 1'b1;
        ALUOp = 2'b01;
      end
      6'b000101: begin//bne
        branchNe = 1'b1;
        ALUOp = 2'b01;
      end
  endcase
  end
  always @(ALUOp, func)begin
    ALUOperation = 3'b010;
    case(ALUOp)
      2'b00 : ALUOperation = 3'b010;
      2'b01 : ALUOperation = 3'b110;
      2'b10 : begin
        case(func)
          6'b100000 : ALUOperation = 3'b010;
          6'b100010 : ALUOperation = 3'b110;
          6'b101010 : ALUOperation = 3'b111;
        endcase
      end
      2'b11 : ALUOperation = 3'b111;
    endcase
  end     
  assign PCSrc = (branchEq & Zero) | (branchNe & ~Zero);
endmodule