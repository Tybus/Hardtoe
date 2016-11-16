module VGA 
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

endmodule