module PROTO (
	input wire Clock,Reset2,
	output wire oHs,oVs,iPS2CLK,iPS2D,
	output wire [2:0] oRGB
); 
	reg [7:0] offsetCol [9:0];
	reg [7:0] offsetFil [9:0];
	
	wire [15:0] squareCol;
	wire [15:0] squareFil;
	wire [2:0] wColor;
	wire [15:0] wColorAddress;
	reg [15:0]	wWriteAddress;
	reg [2:0] 	wDataIn;
	wire [7:0] numC, numF;
	wire [3:0] Tec_Result;
	wire [8:0] Square_active;
	reg [8:0] Active_p1;
	reg [8:0] Active_p2;
	
	assign squareCol[0] = (numC - 39)*(numC - 39);
	assign squareFil[0] = (numF - 39)*(numF - 39);
	assign squareCol[1] = (numC - 39-79)*(numC - 39-79);
	assign squareFil[1] = (numF - 39)*(numF - 39);
	assign squareCol[2] = (numC - 39-79-79)*(numC - 39-79-79);
	assign squareFil[2] = (numF - 39)*(numF - 39);
	assign squareCol[3] = (numC - 39)*(numC - 39);
	assign squareFil[3] = (numF - 39-79)*(numF - 39-79);
	assign squareCol[4] = (numC - 39-79)*(numC - 39-79);
	assign squareFil[4] = (numF - 39-79)*(numF - 39-79);
	assign squareCol[5] = (numC - 39-79-79)*(numC - 39-79-79);
	assign squareFil[5] = (numF - 39-79)*(numF - 39-79);
	assign squareCol[6] = (numC - 39)*(numC - 39);
	assign squareFil[6] = (numF - 39-79-79)*(numF - 39-79-79);
	assign squareCol[7] = (numC - 39-79)*(numC - 39-79);
	assign squareFil[7] = (numF - 39-79-79)*(numF - 39-79-79);
	assign squareCol[8] = (numC - 39-79-79)*(numC - 39-79-79);
	assign squareFil[8] = (numF - 39-79-79)*(numF - 39-79-79);
	
	
	RAM_SINGLE_READ_PORT # (3,16,256*256) VideoMemory(
		.Clock(Clock),
		.iWriteEnable(1'b1),
		.iReadAddress(wColorAddress),
		.iWriteAddress(wWriteAddress),
		.iDataIn(wDataIn),
		.oDataOut(wColor)
	);
	
	VGA	VGA_1 (
		.Clock(Clock),
		.Reset2(Reset2),
		.iColor(wColor),
		.oHs(oHs),
		.oVs(oVs),
		.oRGB(oRGB),
		.oColorAddress(wColorAddress)
	);
	
	PS2_Control Teclado(
		.iPS2CLK(iPS2CLK),
		.Reset(Reset2),
		.iPS2D(iPS2D),
		.o_direccion(Tec_Result)
);
	
	assign numF = wWriteAddress / 256;
	assign numC = wWriteAddress % 256;					 
	assign Square_Active = 1;
	always@(posedge Clock)
		begin
			if(Reset2)
				begin
					wWriteAddress = 0;
					wDataIn = 0;
				end
			else
				begin
					if((numC > 79 ) && (numC < 89))
						wDataIn = 3'd7;
					else if((numC > 89 + 79 ) && (numC < 89 + 89))
						wDataIn = 3'd7;
					else if((numF > 79) && (numF < 89))
						wDataIn = 3'd7;
					else if((numF > 79) && (numF < 89))
						wDataIn = 3'd7;
					else if((numF > 89 + 79) && (numF < 89 + 89))
						wDataIn = 3'd7;
					else 
					begin
						//if(Square_Active[0]) //Primera Casilla
						//begin
						//	if(Active_p1[0])
						//	begin
							if(squareCol[0]+squareFil[0] <= 16'd1225 && squareCol[0]+squareFil[0] > 16'd900 ) //Modificar 10 de coso
								wDataIn = 3'd1; //Anadir selector de juego
							//end
					/*		else if(Active_p2[0])
						   begin
							if(squareCol+squareFil <= 16'd1225 && squareCol+squareFil > 16'd900 ) //Modificar 10 de coso
								wDataIn = 3'd1; //Anadir selector de juego
							end
						end
					/*	if(Square_Active[1]) // Segunda casilla
						begin
							if(Active_p1[1])
							begin
							if(squareCol+squareFil <= 16'd1225 && squareCol+squareFil > 16'd900 ) //Modificar 10 de coso
								wDataIn = 3'd1; //Anadir selector de juego
							end
							else if(Active_p2[1])
							begin
							if(squareCol+squareFil <= 16'd1225 && squareCol+squareFil > 16'd900 ) //Modificar 10 de coso
								wDataIn = 3'd1; //Anadir selector de juego
							end
						end						
					*/	
						else
						wDataIn = 3'd0;
					end
					wWriteAddress = wWriteAddress + 1;
				end
		
		end	
		
endmodule