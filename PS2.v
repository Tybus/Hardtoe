//-----------------------------------------------------------------------------------
//  Laboratorio de Circuitos Digitales 1 | Experimento 4
//  archivo: PS2.v
//
//  Descripción:
//  Máquina de estados para el procesamiento de señales del teclado a través de 
//  la interfaz del puerto PS2 de la tarjeta.  Las señales se pasan a través de
//  los puertos 1 y 5 del PS2, los cuales se mapean a los pines M15 y M16 de la
//  Spartan 3E.  Dichos puertos se agregaron al .ucf siguiendo estos nombres:
//
//  NET "iPS2D" LOC = "M15" | IOSTANDARD = LVTTL | DRIVE = 8 | SLEW = FAST ;
//  NET "iPS2CLK" LOC = "M16" | IOSTANDARD = LVTTL | DRIVE = 8 | SLEW = FAST ;
//------------------------------------------------------------------------------------
`timescale 1ns / 1ps

//Definición de estados
//--------------------------------
`define START                  0
`define WAITCLK_L1             1
`define WAITCLK_H1             2
`define GET_KEY1               3
`define WAITCLK_L2             4
`define WAITCLK_H2             5
`define GET_KEY2               6
`define WAITCLK_L3             7
`define WAITCLK_H3             8
`define GET_KEY3               9
`define BREAK_KEY              10
//--------------------------------


module PS2_Control(
    input wire iPS2CLK,
	input wire Reset,
    input wire iPS2D,
	output reg [3:0] o_direccion
);


reg rCurrentState, rNextState;

// regs para los valores de cada make code y scan code
reg [7:0] rKeyval1;
reg [7:0] rKeyval2;
reg [7:0] rKeyval3;

reg [10:0] r_shift1, r_shift2, r_shift3;
reg [3:0] r_bitcount;   //contador de 4 bits para contar hasta 11 y pasar una ráfaga de bits al puerto PS2

/*
una trama se compone de 11 bits que se distribuyen así en PS2 y se guardan en r_shift1, r_shift2 y r_shift3:

iPS2D--> | STOP bit = 1 | bit Paridad |  SCAN CODE (8 bits) | START bit = 0 | 

*/


//----------------------------------------------
//Next State and delay logic
always @ ( negedge iPS2CLK )
	begin
		if (Reset)
			begin
				rCurrentState <= `START;
				r_bitcount <= 4'b0;
				r_shift1 <= 11'b0;
				r_shift2 <= 11'b0;
				r_shift3 <= 11'b0;
				rKeyval1 <= 8'b0;
				rKeyval2 <= 8'b0;
				rKeyval3 <= 8'b0;
			end
        else
            begin
                rCurrentState <= rNextState;
            end
	end

//----------------------------------------------
//Current state and output logic

always @ ( * )
	begin
		case (rCurrentState)

		//----------------------
		`START:
		begin
			if (iPS2D == 1)
				begin
					rNextState = `START;
				end
			else
				begin
					rNextState = `WAITCLK_L1;
				end
		end

		//---wait for clock low
		`WAITCLK_L1:
		begin
			if (r_bitcount < 11)
				begin
					if (iPS2CLK)
						begin
							rNextState = `WAITCLK_L1;
						end
					else
						begin
							rNextState = `WAITCLK_H1;
							r_shift1 = r_shift1 << 1;
							r_shift1[0] = iPS2D;       // en el nivel bajo, meta el MSB de iPS2D en el reg shift1
						end
				end
			else
				begin
					rNextState = `GET_KEY1;
				end	  
		end

		//---wait for clock hi
		`WAITCLK_H1:
		begin
		  	if (!iPS2CLK)
				  begin
					  rNextState = `WAITCLK_H1;
				  end
			  else
				  begin
					  rNextState = `WAITCLK_L1;
					  r_bitcount = r_bitcount + 1;
				  end
		end
		//--- GET_KEY1
		`GET_KEY1:
		begin
		  	rKeyval1 = r_shift1[8:1];  // toma el primer Make Code
			r_bitcount = 0;            // resetear el bit count
			rNextState = `WAITCLK_L2;
		end

		//---wait for clock low 2
		`WAITCLK_L2:
		begin
			if (r_bitcount < 11)
				begin
					if (iPS2CLK)
						begin
							rNextState = `WAITCLK_L2;
						end
					else
						begin
							rNextState = `WAITCLK_H2;
							r_shift2 = r_shift2 << 1;
							r_shift2[0] = iPS2D;       // en el nivel bajo, meta el MSB de iPS2D en el reg shift2
						end
				end
			else
				begin
					rNextState <= `GET_KEY2;
				end	  
		end
		//---wait for clock hi 2
		`WAITCLK_H2:
		begin
		  	if (!iPS2CLK)
				  begin
					  rNextState = `WAITCLK_H2;
				  end
			  else
				  begin
					  rNextState = `WAITCLK_L2;
					  r_bitcount = r_bitcount + 1;
				  end
		end	
		//---GET_KEY2
		`GET_KEY2:
		begin
		  	rKeyval2 = r_shift2[8:1];  // toma el segundo código para verificar si se trata del Break code o no
			r_bitcount = 0;            // resetear el bit count
			rNextState = `BREAK_KEY;   // vamos al estado BREAK_KEY para detectar el caracter de salida F0
		end

		//---BREAK_KEY
		`BREAK_KEY:
		begin
			if (rKeyval2 == 8'hF0)              // comparamos con 0xF0 dado que es así como inicia el Break Code
				begin
					rNextState = `WAITCLK_L3;
				end
			else
				begin
					if (rKeyval1 == 8'hE0)      // esto es en caso que se presione una tecla especial
						begin
							rNextState = `WAITCLK_L1;
						end
					else
						begin
							rNextState = `WAITCLK_L2;
						end
				end
		end

		//---wait for clock lo 3
		`WAITCLK_L3:
		begin
			if (r_bitcount < 11)
				begin
					if (iPS2CLK)
						begin
							rNextState = `WAITCLK_L3;
						end
					else
						begin
							rNextState = `WAITCLK_H3;
							r_shift3 = r_shift3 << 1;
							r_shift3[0] = iPS2D;       // en el nivel bajo, meta el MSB de iPS2D en el reg shift3
						end
				end
			else
				begin
					rNextState <= `GET_KEY3;
				end	  
		end

		//---wait for clock hi 3
		`WAITCLK_H3:
		begin
		  	if (!iPS2CLK)
				  begin
					  rNextState = `WAITCLK_H3;
				  end
			  else
				  begin
					  rNextState = `WAITCLK_L3;
					  r_bitcount = r_bitcount + 1;
				  end
		end

		//---GET_KEY3
		`GET_KEY3:
		begin
		  	rKeyval3 = r_shift3[8:1];  // toma el ultimo código
			r_bitcount = 0;            // resetear el bit count
			rNextState = `WAITCLK_L1;   // vamos al estado WAITCLK_L1
		end		
		//----------------------
		default:
		begin
			rNextState = `START;
			r_bitcount = 4'b0;
			r_shift1 = 11'b0;
			r_shift2 = 11'b0;
			r_shift3 = 11'b0;
			rKeyval1 = 8'b0;
			rKeyval2 = 8'b0;
			rKeyval3 = 8'b0;
		end

		endcase

//--------------------------------------------------------------------------------
// AQUÍ SE DEFINE LA DIRECCIÓN EN FUNCIÓN DE QUÉ TECLA SE PRESIONÓN EN EL TECLADO
//--------------------------------------------------------------------------------
		case (rKeyval1)
			8'h1C:
			begin
				o_direccion = 4'b0001;  //presionó A => izquierda
			end
			8'h1B:
			begin
				o_direccion = 4'b0010;  //presionó S => abajo
			end
			8'h23:
			begin
				o_direccion = 4'b0100;  //presionó D => derecha
			end
			8'h1D:
			begin
				o_direccion = 4'b1000; //presionó W => arriba
			end
		default: 
		begin
				o_direccion = 4'b0000; // en este caso no se presióno ninguna tecla de dirección
		end
		endcase
	
	end //always comb

endmodule