module PROTO (
	input wire Clock,Reset2,
	output wire oHs,oVs,iPS2CLK,iPS2D,
	output wire [2:0] oRGB
); 

	wire [2:0] wColor;
	wire [15:0] wColorAddress;
	reg [15:0]	wWriteAddress;
	reg [2:0] 	wDataIn;
	wire [7:0] numC, numF;
	wire [3:0] Tec_Result;
	
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
						wDataIn = 3'd0;
						
					wWriteAddress = wWriteAddress + 1;
				end
		
		end	
		
endmodule