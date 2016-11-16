`timescale 1ns / 1ps
//------------------------------------------------
module UPCOUNTER_POSEDGE # (parameter SIZE=16)
(
input wire Clock, Reset,
input wire [SIZE-1:0] Initial,
input wire Enable,
output reg [SIZE-1:0] Q
);


  always @(posedge Clock )
  begin
      if (Reset)
        Q = Initial;
      else
		begin
		if (Enable)
			Q = Q + 1;
			
		end			
  end

endmodule

//----------------------------------------------------

module FFD_POSEDGE_SYNCRONOUS_RESET # ( parameter SIZE=8 )
(
	input wire				Clock,
	input wire				Reset,
	input wire				Enable,
	input wire [SIZE-1:0]	D,
	output reg [SIZE-1:0]	Q
);
	

always @ (posedge Clock) 
begin
	if ( Reset )
		Q <= 0;
	else
	begin	
		if (Enable) 
			Q <= D; 
	end	
 
end//always

endmodule


//----------------------------------------------------------------------

module RAM_SINGLE_READ_PORT # ( parameter DATA_WIDTH= 16, parameter
ADDR_WIDTH=8, parameter MEM_SIZE=8 )
(
	input wire Clock,
	input wire iWriteEnable,
	input wire[ADDR_WIDTH-1:0] iReadAddress,
	input wire[ADDR_WIDTH-1:0] iWriteAddress,
	input wire[DATA_WIDTH-1:0] iDataIn,
	output reg [DATA_WIDTH-1:0] oDataOut
);

reg [DATA_WIDTH-1:0] Ram [MEM_SIZE:0];

always @(posedge Clock)
	begin
	if (iWriteEnable)
		Ram[iWriteAddress] <= iDataIn;
	oDataOut <= Ram[iReadAddress];
	end
endmodule

//----------------------------------------------------

module ClockDiv2 
(	
	input wire Reset,
	input wire Clock,
	output reg Clock2
);

always@(posedge Clock)
	begin
	if(Reset)
		Clock2 =0;
	else
		Clock2 = ! Clock2;
	end	
	
endmodule

//----------------------------------------------------

module Reseter
(
	input wire Reset,
	input wire Clock,
	output reg newReset
);
reg [1:0] cuente;
reg [3:0] cuente2;

always@(posedge Clock)
	begin
	
		if(Reset)
		begin
			cuente <=0;
			newReset <=0;
			cuente2 <=0;
		end
		
		else if(cuente2 == 15)
		begin	
			newReset<=0;
			cuente <= cuente;
			cuente2 <= cuente2;
		end
		
		else if(cuente == 3)
		begin
			newReset <= 1;
			cuente2<= cuente2+1;
			cuente <= cuente;
		end
		
		else
		begin
			cuente <= cuente +1;
			newReset<=0;
			cuente2 <=0;
		end	
	end
endmodule

//----------------------------------------------------

/*module VGA 
(
input wire Clock, Reset2,
input wire [2:0] iColor,
output wire oHs,oVs,
output wire [2:0] oRGB,
output wire [15:0] oColorAddress
);
	wire Clock2;
	wire enableFila;
	wire ResetCol;
	wire ResetFila;
	wire [9:0] numColumna;
	wire [9:0] numFila;
	wire Reset, FinFila, FinColumna;
	
	ClockDiv2 clocker
	(
		.Clock(Clock),
		.Reset(Reset2),
		.Clock2(Clock2)
	);
	
	UPCOUNTER_POSEDGE #(.SIZE(10)) columnas  
	(
		.Clock(Clock2),
		.Reset(ResetCol),
		.Initial(10'd0),
		.Enable(1'b1),
		.Q(numColumna)
	);
	
	UPCOUNTER_POSEDGE #(.SIZE(10)) filas 
	(
		.Clock(Clock2),
		.Reset(ResetFila),
		.Initial(10'd0),
		.Enable(enableFila),
		.Q(numFila)
	);
	
	Reseter reseteador
	(
		.Clock(Clock),
		.Reset(Reset2),
		.newReset(Reset)
	);
	
	assign FinFila = (numFila == 521)? 1'b1 : 1'b0;
	assign FinColumna = (numColumna == 800)? 1'b1 : 1'b0;
	
	assign oHs = (numColumna >= 656 && numColumna <= 752)? 1'b0 : 1'b1;
	assign oVs = (numFila >= 490 && numFila <= 492)? 1'b0 : 1'b1;
	
	assign ResetCol = (FinColumna == 1 || Reset == 1)? 1'b1 : 1'b0;
	assign ResetFila = (FinFila == 1 || Reset == 1)? 1'b1 : 1'b0;
	
	assign enableFila = (FinColumna == 1)? 1'b1 : 1'b0;
	
	assign oRGB = ((numColumna > 192 && numColumna < 448) && (numFila > 112  && numFila < 368))? iColor : 3'd0;
	
	assign oColorAddress = ((numColumna > 192 && numColumna < 448) && (numFila > 112  && numFila < 368))? (numFila-113) * 256 + (numColumna-193) : 14'd0;

endmodule */