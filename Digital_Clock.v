
// UNIVERSITY OF SEOUL
// ELECTRICITY, ELECTRONICS, AND COMPUTER ENGINEERING DESIGN LAB II - FINAL PROJECT
// STUDENT ID NUMBER : 2015440029
// NAME : KIM YOUNG JUN
// DATE : 2016. 12. 12
// PROJECT NAME : DIGITAL CLOCK

module Digital_Clock(RESETN, CLK, CLK_1MHz, LCD_E, LCD_RS, LCD_RW, LCD_DATA, PIEZO, BUS, BUT, LED);

	input RESETN, CLK, CLK_1MHz;
	input [7:0] BUS; // BUS_SWITCH
	input [15:0] BUT; // BUTTON_SWITCH
	
	output LCD_E, LCD_RS, LCD_RW, PIEZO;
	output [7:0] LCD_DATA;
	output [7:0] LED;
	
	wire LCD_E, PIEZO;
	
	reg LCD_RS, LCD_RW;
	reg [2:0] STATE;
	reg [7:0] LCD_DATA, LED;
	reg [6:0] CNT_CYCLE, CNT_H10, CNT_H1, CNT_M10, CNT_M1, CNT_S10, CNT_S1, CNT_MS10, CNT_MS1; // Registers for default time
	reg [6:0] SET_H10, SET_H1, SET_M10, SET_M1; // Register for time setting
	reg [6:0] STOP_M10, STOP_M1, STOP_S10, STOP_S1, STOP_MS10, STOP_MS1; // Registers for STOPWATCH
	reg [6:0] ALARM_H10, ALARM_H1, ALARM_M10, ALARM_M1; // Registers for ALARM
	reg [6:0] TIMER_M10, TIMER_M1, TIMER_S10, TIMER_S1, TIMER_MS10, TIMER_MS1; // Registers for TIMER
	reg [6:0] SET_TIMER_M10, SET_TIMER_M1, SET_TIMER_S10, SET_TIMER_S1, SET_TIMER_MS10, SET_TIMER_MS1; // Registers for TIMER
	reg [6:0] YEAR, MONTH, DAY; // Registers for CALENDAR
	reg [6:0] SET_YEAR, SET_MONTH, SET_DAY; // Registers for SET_CALENDAR
	
	parameter DELAY = 4'b0000, FUNCTION_SET = 4'b0001, ENTRY_MODE = 4'b0010, DISP_ONOFF = 4'b0011, 
				 LINE1 = 4'b0100, LINE2 = 4'b0101, DELAY_T = 4'b0110, CLEAR_DISP = 4'b0111;
				 
	integer CNT, CNT_M;
	reg CLK_M;
	reg PASSWORD1, PASSWORD2, PASSWORD3, PASSWORD4;
	reg TEMP, LOCK;
	reg [1:0] WORLD; // 0:NY, 1:HK, 2:LD
	reg [7:0] BUS_EN; // BUS_SWITCH ENABLE
	// BUS_EN[0] : MENU_1 SET DEFAULT TIME
	// BUS_EN[1] : MENU_2 SET ALARM TIME
	// BUS_EN[2] : MENU_3 STOPWATCH
	// BUS_EN[3] : MENU_4 TIMER
	// BUS_EN[4] : MENU_5 WORLD TIME
	// BUS_EN[5] : MENU_6 SET CALENDAR
	// BUS_EN[6] : MENU_7 CALENDAR
	// BUS_EN[7] : MENU_8 GAME
	// DEFAULT : DEFAULT TIME (SEOUL)
	
	reg [15:0] BUT_EN; // BUTTON_SWTICH ENABLE
	// BUT_EN[0] : ENABLE CHANGE
	// BUT_EN[1] : SAVE TIME
	// BUT_EN[2] : SAVE TIMER
	// BUT_EN[3] : WORLD TIME CHANGE
	// BUT_EN[4] : STOPWATCH START / PASSWORD[0]
	// BUT_EN[5] : STOPWATCH STOP / PASSWORD[1]
	// BUT_EN[6] : TIMER START / PASSWORD[2]
	// BUT_EN[7] : TIMER STOP / PASSWORD[3]
	// BUT_EN[8] : STOPWATCH RESET
	// BUT_EN[9] : TIMER RESET
	// BUT_EN[10] : UP1
	// BUT_EN[11] : DOWN1
	// BUT_EN[12] : UP2 / ROCK
	// BUT_EN[13] : DOWN2 / PAPER
	// BUT_EN[14] : UP3 / SCISSOR
	// BUT_EN[15] : DOWN3 / GAME EXECUTE

initial begin
	LOCK = 0;
	BUT_EN = 0;
	BUS_EN = 0;
	PASSWORD1 = 0;
	PASSWORD2 = 0;
	PASSWORD3 = 0;
	PASSWORD4 = 0;
	WORLD = 0;
end

always @(posedge CLK) begin // BUT/BUS input enable
	BUT_EN <= BUT;
	BUS_EN <= BUS;
end

always @(posedge CLK) begin // Password input
	if(BUT_EN[4] == 1) PASSWORD1 = 1;
	else if(BUT_EN[5] == 1) PASSWORD2 = 1;
	else if(BUT_EN[6] == 1) PASSWORD3 = 1;
	else if(BUT_EN[7] == 1) PASSWORD4 = 1;
	else if(PASSWORD1 && PASSWORD2 && PASSWORD3 && PASSWORD4) LOCK = 1;
end	


always @(posedge BUT_EN[0]) begin // DEFAULT time change
	if(LOCK && BUS_EN[0] && ~BUS_EN[1] && ~BUS_EN[2] && ~BUS_EN[3] && ~BUS_EN[4] && ~BUS_EN[5] && ~BUS_EN[6] && ~BUS_EN[7]) begin
		if(BUT_EN[10]) begin
			if(SET_H1 >= 23) SET_H1 = 0;
			else SET_H1 = SET_H1 + 1;
		end
		else if(BUT_EN[11]) begin
			if(SET_H1 <= 0) SET_H1 = 23;
			else SET_H1 = SET_H1 - 1;
		end
		else if(BUT_EN[12]) begin
			if(SET_M10 >= 5) SET_M10 = 0;
			else SET_M10 = SET_M10 + 1;
		end
		else if(BUT_EN[13]) begin
			if(SET_M10 <= 0) SET_M10 = 5;
			else SET_M10 = SET_M10 - 1;
		end
		else if(BUT_EN[14]) begin
			if(SET_M1 >= 9) SET_M1 = 0;
			else SET_M1 = SET_M1 + 1;
		end		
		else if(BUT_EN[15]) begin
			if(SET_M1 <= 0) SET_M1 = 9;
			else SET_M1 = SET_M1 - 1;
		end
	end
end


initial begin // initial date : 2016.12.12
	SET_DAY = 12;
	SET_MONTH = 12;
	SET_YEAR = 16;
end
always @(posedge BUT_EN[0]) begin // CALENDAR change
	if(LOCK && ~BUS_EN[0] && ~BUS_EN[1] && ~BUS_EN[2] && ~BUS_EN[3] && ~BUS_EN[4] && BUS_EN[5] && ~BUS_EN[6] && ~BUS_EN[7]) begin
		if(BUT_EN[10]) begin
			if(SET_YEAR >= 99) SET_YEAR = 0;
			else SET_YEAR = SET_YEAR + 1;
		end
		else if(BUT_EN[11]) begin
			if(SET_YEAR <= 0) SET_YEAR = 99;
			else SET_YEAR = SET_YEAR - 1;
		end
		else if(BUT_EN[12]) begin
			if(SET_MONTH >= 12) SET_MONTH = 1;
			else SET_MONTH = SET_MONTH + 1;
		end
		else if(BUT_EN[13]) begin
			if(SET_MONTH <= 1) SET_MONTH = 12;
			else SET_MONTH = SET_MONTH - 1;
		end
		else if(BUT_EN[14]) begin
			if(SET_DAY >= 30) SET_DAY = 1;
			else SET_DAY = SET_DAY + 1;
		end		
		else if(BUT_EN[15]) begin
			if(SET_DAY <= 1) SET_DAY = 30;
			else SET_DAY = SET_DAY - 1;
		end
	end
end


always @(posedge BUT_EN[0]) begin // ALARM time change
	if(LOCK && ~BUS_EN[0] && BUS_EN[1] && ~BUS_EN[2] && ~BUS_EN[3] && ~BUS_EN[4] && ~BUS_EN[5] && ~BUS_EN[6] && ~BUS_EN[7]) begin
		if(BUT_EN[10]) begin
			if(ALARM_H1 >= 23) ALARM_H1 = 0;
			else ALARM_H1 = ALARM_H1 + 1;
		end
		else if(BUT_EN[11]) begin
			if(ALARM_H1 <= 0) ALARM_H1 = 23;
			else ALARM_H1 = ALARM_H1 - 1;
		end
		else if(BUT_EN[12]) begin
			if(ALARM_M10 >= 5) ALARM_M10 = 0;
			else ALARM_M10 = ALARM_M10 + 1;
		end
		else if(BUT_EN[13]) begin
			if(ALARM_M10 <= 0) ALARM_M10 = 5;
			else ALARM_M10 = ALARM_M10 - 1;
		end
		else if(BUT_EN[14]) begin
			if(ALARM_M1 >= 9) ALARM_M1 = 0;
			else ALARM_M1 = ALARM_M1 + 1;
		end		
		else if(BUT_EN[15]) begin
			if(ALARM_M1 <= 0) ALARM_M1 = 9;
			else ALARM_M1 = ALARM_M1 - 1;
		end
	end
end


initial SET_TIMER_M1 = 1;
always @(posedge BUT_EN[0]) begin // TIMER time change
	if(LOCK && ~BUS_EN[0] && ~BUS_EN[1] && ~BUS_EN[2] && BUS_EN[3] && ~BUS_EN[4] && ~BUS_EN[5] && ~BUS_EN[6] && ~BUS_EN[7]) begin
		if(BUT_EN[10]) begin
			if(SET_TIMER_M1 >= 59) SET_TIMER_M1 = 0;
			else SET_TIMER_M1 = SET_TIMER_M1 + 1;
		end
		else if(BUT_EN[11]) begin
			if(SET_TIMER_M1 <= 0) SET_TIMER_M1 = 59;
			else SET_TIMER_M1 = SET_TIMER_M1 - 1;
		end
		else if(BUT_EN[12]) begin
			if(SET_TIMER_S10 >= 5) SET_TIMER_S10 = 0;
			else SET_TIMER_S10 = SET_TIMER_S10 + 1;
		end
		else if(BUT_EN[13]) begin
			if(SET_TIMER_S10 <= 0) SET_TIMER_S10 = 5;
			else SET_TIMER_S10 = SET_TIMER_S10 - 1;
		end
		else if(BUT_EN[14]) begin
			if(SET_TIMER_S1 >= 9) SET_TIMER_S1 = 0;
			else SET_TIMER_S1 = SET_TIMER_S1 + 1;
		end		
		else if(BUT_EN[15]) begin
			if(SET_TIMER_S1 <= 0) SET_TIMER_S1 = 9;
			else SET_TIMER_S1 = SET_TIMER_S1 - 1;
		end
	end
end


always @(posedge CLK) begin // 100Hz CLK counter
	if(~RESETN) begin
		CNT_M = 0;
		CLK_M = 0;
	end
	else if (CNT_M >= 4) begin
		CNT_M = 0;
		CLK_M = ~CLK_M;
	end
	else CNT_M = CNT_M + 1;
end

always @(posedge CLK_M) begin // 0.01 second counter
	if(~RESETN) CNT_MS1 = 0;
	else begin
		if (CNT_MS1 >= 9) CNT_MS1 = 0;
		else CNT_MS1 = CNT_MS1 + 1;
	end
end

always @(posedge CLK_M) begin // 0.1 second counter
	if(~RESETN) CNT_MS10 = 0;
	else begin
		if (CNT_MS1 == 9) begin
			if (CNT_MS10 >= 9) CNT_MS10 = 0;
			else CNT_MS10 = CNT_MS10 + 1;
		end
	end
end

always @(posedge CLK_M) begin // 1 second counter
	if(~RESETN) CNT_S1 = 0;
	else begin
		if ((CNT_MS1 == 9) && (CNT_MS10 == 9)) begin
			if (CNT_S1 >= 9) CNT_S1 = 0;
			else CNT_S1 = CNT_S1 + 1;
		end
	end
end

always @(posedge CLK_M) begin // 10 second counter
	if(~RESETN) CNT_S10 = 0;
	else begin
		if ((CNT_MS1 == 9) && (CNT_MS10 == 9) && (CNT_S1 == 9)) begin
			if (CNT_S10 >= 5) CNT_S10 = 0;
			else CNT_S10 = CNT_S10 + 1;
		end
	end
end

always @(posedge CLK_M) begin // 1 minute counter
	if(~RESETN) CNT_M1 = 0;
	if(BUT_EN[1]) CNT_M1 = SET_M1;
	else begin
		if ((CNT_MS1 == 9) && (CNT_MS10 == 9) && (CNT_S1 == 9) && (CNT_S10 == 5)) begin
			if (CNT_M1 >= 9) CNT_M1 = 0;
			else CNT_M1 = CNT_M1 + 1;
		end
	end
end

always @(posedge CLK_M) begin // 10 minute counter
	if(~RESETN) CNT_M10 = 0;
	if(BUT_EN[1]) CNT_M10 = SET_M10;
	else begin
		if ((CNT_MS1 == 9) && (CNT_MS10 == 9) && (CNT_S1 == 9) && (CNT_S10 == 5) && (CNT_M1 == 9)) begin
			if (CNT_M10 >= 5) CNT_M10 = 0;
			else CNT_M10 = CNT_M10 + 1;
		end
	end
end

always @(posedge CLK_M) begin // hour counter
	if(~RESETN) CNT_H1 = 0;
	if(BUT_EN[1]) CNT_H1 = SET_H1;
	else begin
		if ((CNT_MS1 == 9) && (CNT_MS10 == 9) && (CNT_S1 == 9) && (CNT_S10 == 5) && (CNT_M1 == 9) && (CNT_M10 == 5)) begin
			if (CNT_H1 >= 23) CNT_H1 = 0;
			else CNT_H1 = CNT_H1 + 1;
		end
	end
end

always @(posedge CLK_M) begin // AM/PM counter
	if(~RESETN) CNT_CYCLE = 0;
	else begin
		if (CNT_H1 <= 11) CNT_CYCLE = 0; // AM
		else CNT_CYCLE = 1; // PM
	end
end

always @(posedge CLK_M) begin // day counter
	if(~RESETN) DAY = 12;
	if(BUT_EN[1]) DAY = SET_DAY;
	else begin
		if ((CNT_MS1 == 9) && (CNT_MS10 == 9) && (CNT_S1 == 9) && (CNT_S10 == 5) && (CNT_M1 == 9) && (CNT_M10 == 5) && (CNT_H1 == 23)) begin
			if (DAY >= 30) DAY = 1;
			else DAY = DAY + 1;
		end
	end
end

always @(posedge CLK_M) begin // month counter
	if(~RESETN) MONTH = 12;
	if(BUT_EN[1]) MONTH = SET_MONTH;
	else begin
		if ((CNT_MS1 == 9) && (CNT_MS10 == 9) && (CNT_S1 == 9) && (CNT_S10 == 5) && (CNT_M1 == 9) && (CNT_M10 == 5) && (CNT_H1 == 23) && (DAY == 30)) begin
			if (MONTH >= 12) MONTH = 1;
			else MONTH = MONTH + 1;
		end
	end
end

always @(posedge CLK_M) begin // year counter
	if(~RESETN) YEAR = 16;
	if(BUT_EN[1]) YEAR = SET_YEAR;
	else begin
		if ((CNT_MS1 == 9) && (CNT_MS10 == 9) && (CNT_S1 == 9) && (CNT_S10 == 5) && (CNT_M1 == 9) && (CNT_M10 == 5) && (CNT_H1 == 23) && (DAY == 30) && (MONTH == 12)) begin
			if (YEAR >= 99) YEAR = 0;
			else YEAR = YEAR + 1;
		end
	end
end



// LCD PROPERTIES
always @(negedge RESETN or posedge CLK_M) begin
	if(~RESETN) STATE = DELAY;
	else begin 
		case(STATE)
			DELAY : if (CNT == 70) STATE = FUNCTION_SET;
			FUNCTION_SET : if (CNT == 30) STATE = DISP_ONOFF;
			DISP_ONOFF : if (CNT == 30) STATE = ENTRY_MODE;
			ENTRY_MODE : if (CNT == 30) STATE = LINE1;
			LINE1 : if (CNT == 20) STATE = LINE2;
			LINE2 : if (CNT == 20) STATE = LINE1;
			default : STATE = DELAY;
		endcase
	end
end

// LCD CNT DELAY
always @(negedge RESETN or posedge CLK_M) begin
	if(~RESETN) CNT = 0;
	else begin
		case(STATE)
			DELAY : if(CNT >= 70) CNT = 0; else CNT = CNT + 1;
			FUNCTION_SET : if(CNT >= 30) CNT = 0; else CNT = CNT + 1;
			DISP_ONOFF : if(CNT >= 30) CNT = 0; else CNT = CNT + 1;
			ENTRY_MODE : if(CNT >= 30) CNT = 0; else CNT = CNT + 1;
			LINE1 : if(CNT >= 20) CNT = 0; else CNT = CNT + 1;
			LINE2 : if(CNT >= 20) CNT = 0; else CNT = CNT + 1;
			default : CNT = 0;
		endcase
	end
end


// GAME CONTROLS
// BUT_EN[12] : ROCK
// BUT_EN[13] : PAPER
// BUT_EN[14] : SCISSOR
// BUT_EN[15] : GAME RESET
reg [3:0] WIN, LOSE, DRAW;
reg GAME_SET, GAME_RESET;
reg [1:0] COM_PLAY, COM_PLAY_CNT, YOU_PLAY; // 1 = ROCK, 2 = SCISSOR, 3 = PAPER, 0 = _
initial begin
	COM_PLAY = 0; YOU_PLAY = 0;
	WIN = 0; LOSE = 0; DRAW = 0; GAME_SET = 0; GAME_RESET = 0;
end

always @(posedge CLK) begin // Your play cases
	if(LOCK && ~BUS_EN[0] && ~BUS_EN[1] && ~BUS_EN[2] && ~BUS_EN[3] && ~BUS_EN[4] && ~BUS_EN[5] && ~BUS_EN[6] && BUS_EN[7]) begin
		if(BUT_EN[12]) begin YOU_PLAY = 1; COM_PLAY = COM_PLAY_CNT; end // ROCK
		else if(BUT_EN[13]) begin YOU_PLAY = 2; COM_PLAY = COM_PLAY_CNT; end // PAPER
		else if(BUT_EN[14]) begin YOU_PLAY = 3; COM_PLAY = COM_PLAY_CNT; end // SCISSOR
		if(WIN == 5) GAME_SET = 1; // WIN = 5 : GAME WIN
		else GAME_SET = 0;
	end
end

always @(posedge CLK_M) begin // COMPUTER PLAY counter
	if (COM_PLAY_CNT == 3) COM_PLAY_CNT = 1;
	else if (COM_PLAY_CNT == 2) COM_PLAY_CNT = 3;
	else if (COM_PLAY_CNT == 1) COM_PLAY_CNT = 2;
	else COM_PLAY_CNT = 1;
end

always @(posedge BUT_EN[15]) begin
	if(WIN >= 5) begin WIN = 0; LOSE = 0; DRAW = 0; end // RESET
	if(YOU_PLAY == COM_PLAY) DRAW = DRAW + 1;
	else if(((YOU_PLAY == 1) && (COM_PLAY == 3)) || ((YOU_PLAY == 2) && (COM_PLAY == 1)) || ((YOU_PLAY == 3) && (COM_PLAY == 2)))
		WIN = WIN + 1;
	else if(((YOU_PLAY == 3) && (COM_PLAY == 1)) || ((YOU_PLAY == 1) && (COM_PLAY == 2)) || ((YOU_PLAY == 2) && (COM_PLAY == 3)))
		LOSE = LOSE + 1;
end


always @(posedge BUT_EN[3]) begin // WORLD Change counter
	if (WORLD == 2) WORLD = 0;
	else if (WORLD == 1) WORLD = 2;
	else if (WORLD == 0) WORLD = 1;
end






///////////////////////////////////////////////
///////////////// LCD START ///////////////////
///////////////////////////////////////////////
always @(negedge RESETN or posedge CLK_M) begin
	if(~RESETN) begin
		LCD_RS = 1; LCD_RW = 1; LCD_DATA = 8'b00000000;
	end


	// <INITAL : PASSWORD>
	// LINE1 : PASSWORD , LINE2: _ _ _ _
	else if(LOCK == 0) begin
		case (STATE)
			DELAY : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000000; end
			FUNCTION_SET : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00111100; end
			DISP_ONOFF : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00001110; end
			ENTRY_MODE : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000110; end
			LINE1 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b10000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					2 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					3 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					4 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					5 : begin LCD_RS = 1; LCD_DATA = 8'b01010000; end // P
					6 : begin LCD_RS = 1; LCD_DATA = 8'b01000001; end // A
 					7 : begin LCD_RS = 1; LCD_DATA = 8'b01010011; end // S
					8 : begin LCD_RS = 1; LCD_DATA = 8'b01010011; end // S
					9 : begin LCD_RS = 1; LCD_DATA = 8'b01010111; end // W
					10 : begin LCD_RS = 1; LCD_DATA = 8'b01001111; end // O
					11 : begin LCD_RS = 1; LCD_DATA = 8'b01010010; end // R
					12 : begin LCD_RS = 1; LCD_DATA = 8'b01000100; end // D
					13 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					14 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					15 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			LINE2 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b11000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					2 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					3 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					4 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					5 : begin LCD_RS = 1;
							if(PASSWORD1 == 1) LCD_DATA = 8'b00101010; // *
							else LCD_DATA = 8'b01011111; // _
						 end
					6 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					7 : begin LCD_RS = 1;
							if(PASSWORD2 == 1) LCD_DATA = 8'b00101010; // *
							else LCD_DATA = 8'b01011111; // _
						 end
					8 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					9 : begin LCD_RS = 1;
							if(PASSWORD3 == 1) LCD_DATA = 8'b00101010; // *
							else LCD_DATA = 8'b01011111; // _
						 end
					10 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					11 : begin LCD_RS = 1;
							if(PASSWORD4 == 1) LCD_DATA = 8'b00101010; // *
							else LCD_DATA = 8'b01011111; // _
						 end
					12 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					13 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					14 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					15 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			default : begin LCD_RS = 1; LCD_RW = 1; LCD_DATA = 8'b00000000; end
		endcase
	end
	
	
	// <MENU_1 : SET TIME>
	// LINE1 : MENU2 SET TIME , LINE2: AM/PM HH:MM
	else if(LOCK && BUS_EN[0] && ~BUS_EN[1] && ~BUS_EN[2] && ~BUS_EN[3] && ~BUS_EN[4] && ~BUS_EN[5] && ~BUS_EN[6] && ~BUS_EN[7]) begin
		case (STATE)
			DELAY : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000000; end
			FUNCTION_SET : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00111100; end
			DISP_ONOFF : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00001110; end
			ENTRY_MODE : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000110; end
			LINE1 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b10000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M
					2 : begin LCD_RS = 1; LCD_DATA = 8'b01000101; end // E
					3 : begin LCD_RS = 1; LCD_DATA = 8'b01001110; end // N
					4 : begin LCD_RS = 1; LCD_DATA = 8'b01010101; end // U
					5 : begin LCD_RS = 1; LCD_DATA = 8'b00110001; end // 1
					6 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					7 : begin LCD_RS = 1; LCD_DATA = 8'b01010011; end // S
					8 : begin LCD_RS = 1; LCD_DATA = 8'b01000101; end // E
					9 : begin LCD_RS = 1; LCD_DATA = 8'b01010100; end // T
					10 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					11 : begin LCD_RS = 1; LCD_DATA = 8'b01010100; end // T
					12 : begin LCD_RS = 1; LCD_DATA = 8'b01001001; end // I
					13 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M
					14 : begin LCD_RS = 1; LCD_DATA = 8'b01000101; end // E
					15 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			LINE2 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b11000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					2 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					3 : begin
							LCD_RS = 1; 
							if(SET_H1 <= 11) LCD_DATA = 8'b01000001; // A
							else LCD_DATA = 8'b01010000; // P
						 end
					4 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M
					5 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					6 : begin // SET_H10
							LCD_RS = 1;
							if(SET_H1 <= 9) LCD_DATA = 8'b00110000; // 0
							else if((SET_H1 >= 10) && (SET_H1 <= 19)) LCD_DATA = 8'b00110001; // 1
							else if(SET_H1 >= 20) LCD_DATA = 8'b00110010; // 2
						 end
					7 : begin // SET_H1
							LCD_RS = 1;
							case(SET_H1)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								10 : LCD_DATA = 8'b00110000; // 0
								11 : LCD_DATA = 8'b00110001; // 1
								12 : LCD_DATA = 8'b00110010; // 2
								13 : LCD_DATA = 8'b00110011; // 3
								14 : LCD_DATA = 8'b00110100; // 4
								15 : LCD_DATA = 8'b00110101; // 5
								16 : LCD_DATA = 8'b00110110; // 6
								17 : LCD_DATA = 8'b00110111; // 7
								18 : LCD_DATA = 8'b00111000; // 8
								19 : LCD_DATA = 8'b00111001; // 9
								20 : LCD_DATA = 8'b00110000; // 0
								21 : LCD_DATA = 8'b00110001; // 1
								22 : LCD_DATA = 8'b00110010; // 2
								23 : LCD_DATA = 8'b00110011; // 3
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					8 : begin LCD_RS = 1; LCD_DATA = 8'b00111010; end // :
					9 : begin LCD_RS = 1; // SET_M10
							case(SET_M10)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					10 : begin LCD_RS = 1; // SET_M1
							case(SET_M1)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								default: LCD_DATA = 8'b00100000;
							endcase
						  end
					11 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					12 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					13 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					14 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					15 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			default : begin LCD_RS = 1; LCD_RW = 1; LCD_DATA = 8'b00000000; end
		endcase
	end

	
	// <MENU_2 : ALARM>
	// LINE1 : MENU2 SET ALARM , LINE2: AM/PM HH:MM
	else if(LOCK && ~BUS_EN[0] && BUS_EN[1] && ~BUS_EN[2] && ~BUS_EN[3] && ~BUS_EN[4] && ~BUS_EN[5] && ~BUS_EN[6] && ~BUS_EN[7]) begin
		case (STATE)
			DELAY : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000000; end
			FUNCTION_SET : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00111100; end
			DISP_ONOFF : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00001110; end
			ENTRY_MODE : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000110; end
			LINE1 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b10000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M
					2 : begin LCD_RS = 1; LCD_DATA = 8'b01000101; end // E
					3 : begin LCD_RS = 1; LCD_DATA = 8'b01001110; end // N
					4 : begin LCD_RS = 1; LCD_DATA = 8'b01010101; end // U
					5 : begin LCD_RS = 1; LCD_DATA = 8'b00110010; end // 2
					6 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					7 : begin LCD_RS = 1; LCD_DATA = 8'b01010011; end // S
					8 : begin LCD_RS = 1; LCD_DATA = 8'b01000101; end // E
					9 : begin LCD_RS = 1; LCD_DATA = 8'b01010100; end // T
					10 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					11 : begin LCD_RS = 1; LCD_DATA = 8'b01000001; end // A
					12 : begin LCD_RS = 1; LCD_DATA = 8'b01001100; end // L
					13 : begin LCD_RS = 1; LCD_DATA = 8'b01000001; end // A
					14 : begin LCD_RS = 1; LCD_DATA = 8'b01010010; end // R
					15 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			LINE2 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b11000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					2 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					3 : begin
							LCD_RS = 1; 
							if(ALARM_H1 <= 11) LCD_DATA = 8'b01000001; // A
							else LCD_DATA = 8'b01010000; // P
						 end
					4 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M
					5 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					6 : begin // ALARM_H10
							LCD_RS = 1;
							if(ALARM_H1 <= 9) LCD_DATA = 8'b00110000; // 0
							else if((ALARM_H1 >= 10) && (ALARM_H1 <= 19)) LCD_DATA = 8'b00110001; // 1
							else if(ALARM_H1 >= 20) LCD_DATA = 8'b00110010; // 2
						 end
					7 : begin // ALARM_H1
							LCD_RS = 1;
							case(ALARM_H1)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								10 : LCD_DATA = 8'b00110000; // 0
								11 : LCD_DATA = 8'b00110001; // 1
								12 : LCD_DATA = 8'b00110010; // 2
								13 : LCD_DATA = 8'b00110011; // 3
								14 : LCD_DATA = 8'b00110100; // 4
								15 : LCD_DATA = 8'b00110101; // 5
								16 : LCD_DATA = 8'b00110110; // 6
								17 : LCD_DATA = 8'b00110111; // 7
								18 : LCD_DATA = 8'b00111000; // 8
								19 : LCD_DATA = 8'b00111001; // 9
								20 : LCD_DATA = 8'b00110000; // 0
								21 : LCD_DATA = 8'b00110001; // 1
								22 : LCD_DATA = 8'b00110010; // 2
								23 : LCD_DATA = 8'b00110011; // 3
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					8 : begin LCD_RS = 1; LCD_DATA = 8'b00111010; end // :
					9 : begin LCD_RS = 1; // ALARM_M10
							case(ALARM_M10)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					10 : begin LCD_RS = 1; // ALARM_M1
							case(ALARM_M1)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								default: LCD_DATA = 8'b00100000;
							endcase
						  end
					11 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					12 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					13 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					14 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					15 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			default : begin LCD_RS = 1; LCD_RW = 1; LCD_DATA = 8'b00000000; end
		endcase
	end
	
	
	
	
	// <MENU_3 : STOPWATCH>
	// LINE 1 : MENU3 STOPWATCH , LINE 2 : MM:SS:MS
	else if(LOCK && ~BUS_EN[0] && ~BUS_EN[1] && BUS_EN[2] && ~BUS_EN[3] && ~BUS_EN[4] && ~BUS_EN[5] && ~BUS_EN[6] && ~BUS_EN[7]) begin
		case (STATE)
			DELAY : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000000; end
			FUNCTION_SET : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00111100; end
			DISP_ONOFF : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00001110; end
			ENTRY_MODE : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000110; end
			LINE1 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b10000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M
					2 : begin LCD_RS = 1; LCD_DATA = 8'b01000101; end // E
					3 : begin LCD_RS = 1; LCD_DATA = 8'b01001110; end // N
					4 : begin LCD_RS = 1; LCD_DATA = 8'b01010101; end // U
					5 : begin LCD_RS = 1; LCD_DATA = 8'b00110011; end // 3
					6 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					7 : begin LCD_RS = 1; LCD_DATA = 8'b01010011; end // S
					8 : begin LCD_RS = 1; LCD_DATA = 8'b01010100; end // T
					9 : begin LCD_RS = 1; LCD_DATA = 8'b01001111; end // O
					10 : begin LCD_RS = 1; LCD_DATA = 8'b01010000; end // P
					11 : begin LCD_RS = 1; LCD_DATA = 8'b01010111; end // W
					12 : begin LCD_RS = 1; LCD_DATA = 8'b01000001; end // A
					13 : begin LCD_RS = 1; LCD_DATA = 8'b01010100; end // T
					14 : begin LCD_RS = 1; LCD_DATA = 8'b01000011; end // C
					15 : begin LCD_RS = 1; LCD_DATA = 8'b01001000; end // H
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			LINE2 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b11000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					2 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					3 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					4 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					5 : begin LCD_RS = 1; // M10
							case(STOP_M10)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					6 : begin LCD_RS = 1; // M1
							case(STOP_M1)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								default: LCD_DATA = 8'b00100000;
							endcase
						  end
					7 : begin LCD_RS = 1; LCD_DATA = 8'b00111010; end // :
					8 : begin LCD_RS = 1; // S10
							case(STOP_S10)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					9 : begin LCD_RS = 1; // S1
							case(STOP_S1)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								default: LCD_DATA = 8'b00100000;
							endcase
						  end
					10 : begin LCD_RS = 1; LCD_DATA = 8'b00111010; end // :
					11 : begin LCD_RS = 1; // MS10
							case(STOP_MS10)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					12 : begin LCD_RS = 1; // MS1
							case(STOP_MS1)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								default: LCD_DATA = 8'b00100000;
							endcase
						  end
					13 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					14 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					15 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			default : begin LCD_RS = 1; LCD_RW = 1; LCD_DATA = 8'b00000000; end
		endcase
	end
	

	// <MENU_4 : TIMER>
	// LINE 1 : MENU4 TIMER , LINE 2 : MM:SS:MS
	else if(LOCK && ~BUS_EN[0] && ~BUS_EN[1] && ~BUS_EN[2] && BUS_EN[3] && ~BUS_EN[4] && ~BUS_EN[5] && ~BUS_EN[6] && ~BUS_EN[7]) begin
		case (STATE)
			DELAY : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000000; end
			FUNCTION_SET : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00111100; end
			DISP_ONOFF : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00001110; end
			ENTRY_MODE : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000110; end
			LINE1 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b10000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M
					2 : begin LCD_RS = 1; LCD_DATA = 8'b01000101; end // E
					3 : begin LCD_RS = 1; LCD_DATA = 8'b01001110; end // N
					4 : begin LCD_RS = 1; LCD_DATA = 8'b01010101; end // U
					5 : begin LCD_RS = 1; LCD_DATA = 8'b00110100; end // 4
					6 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					7 : begin LCD_RS = 1; LCD_DATA = 8'b01010100; end // T
					8 : begin LCD_RS = 1; LCD_DATA = 8'b01001001; end // I
					9 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M
					10 : begin LCD_RS = 1; LCD_DATA = 8'b01000101; end // E
					11 : begin LCD_RS = 1; LCD_DATA = 8'b01010010; end // R
					12 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					13 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					14 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					15 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			LINE2 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b11000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					2 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					3 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					4 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					5 : begin // TIMER_M10
							LCD_RS = 1;
							if(TIMER_M1 <= 9) LCD_DATA = 8'b00110000; // 0
							else if((TIMER_M1 >= 10) && (TIMER_M1 <= 19)) LCD_DATA = 8'b00110001; // 1
							else if((TIMER_M1 >= 20) && (TIMER_M1 <= 29)) LCD_DATA = 8'b00110010; // 2
							else if((TIMER_M1 >= 30) && (TIMER_M1 <= 39)) LCD_DATA = 8'b00110011; // 3
							else if((TIMER_M1 >= 40) && (TIMER_M1 <= 49)) LCD_DATA = 8'b00110100; // 4
							else if((TIMER_M1 >= 50) && (TIMER_M1 <= 59)) LCD_DATA = 8'b00110101; // 5
						 end
					6 : begin LCD_RS = 1; // M1
							case(TIMER_M1)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								10 : LCD_DATA = 8'b00110000; // 0
								11 : LCD_DATA = 8'b00110001; // 1
								12 : LCD_DATA = 8'b00110010; // 2
								13 : LCD_DATA = 8'b00110011; // 3
								14 : LCD_DATA = 8'b00110100; // 4
								15 : LCD_DATA = 8'b00110101; // 5
								16 : LCD_DATA = 8'b00110110; // 6
								17 : LCD_DATA = 8'b00110111; // 7
								18 : LCD_DATA = 8'b00111000; // 8
								19 : LCD_DATA = 8'b00111001; // 9
								20 : LCD_DATA = 8'b00110000; // 0
								21 : LCD_DATA = 8'b00110001; // 1
								22 : LCD_DATA = 8'b00110010; // 2
								23 : LCD_DATA = 8'b00110011; // 3
								24 : LCD_DATA = 8'b00110100; // 4
								25 : LCD_DATA = 8'b00110101; // 5
								26 : LCD_DATA = 8'b00110110; // 6
								27 : LCD_DATA = 8'b00110111; // 7
								28 : LCD_DATA = 8'b00111000; // 8
								29 : LCD_DATA = 8'b00111001; // 9
								30 : LCD_DATA = 8'b00110000; // 0
								31 : LCD_DATA = 8'b00110001; // 1
								32 : LCD_DATA = 8'b00110010; // 2
								33 : LCD_DATA = 8'b00110011; // 3
								34 : LCD_DATA = 8'b00110100; // 4
								35 : LCD_DATA = 8'b00110101; // 5
								36 : LCD_DATA = 8'b00110110; // 6
								37 : LCD_DATA = 8'b00110111; // 7
								38 : LCD_DATA = 8'b00111000; // 8
								39 : LCD_DATA = 8'b00111001; // 9
								40 : LCD_DATA = 8'b00110000; // 0
								41 : LCD_DATA = 8'b00110001; // 1
								42 : LCD_DATA = 8'b00110010; // 2
								43 : LCD_DATA = 8'b00110011; // 3
								44 : LCD_DATA = 8'b00110100; // 4
								45 : LCD_DATA = 8'b00110101; // 5
								46 : LCD_DATA = 8'b00110110; // 6
								47 : LCD_DATA = 8'b00110111; // 7
								48 : LCD_DATA = 8'b00111000; // 8
								49 : LCD_DATA = 8'b00111001; // 9
								50 : LCD_DATA = 8'b00110000; // 0
								51 : LCD_DATA = 8'b00110001; // 1
								52 : LCD_DATA = 8'b00110010; // 2
								53 : LCD_DATA = 8'b00110011; // 3
								54 : LCD_DATA = 8'b00110100; // 4
								55 : LCD_DATA = 8'b00110101; // 5
								56 : LCD_DATA = 8'b00110110; // 6
								57 : LCD_DATA = 8'b00110111; // 7
								58 : LCD_DATA = 8'b00111000; // 8
								59 : LCD_DATA = 8'b00111001; // 9
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					7 : begin LCD_RS = 1; LCD_DATA = 8'b00111010; end // :
					8 : begin LCD_RS = 1; // S10
							case(TIMER_S10)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					9 : begin LCD_RS = 1; // S1
							case(TIMER_S1)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								default: LCD_DATA = 8'b00100000;
							endcase
						  end
					10 : begin LCD_RS = 1; LCD_DATA = 8'b00111010; end // :
					11 : begin LCD_RS = 1; // MS10
							case(TIMER_MS10)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					12 : begin LCD_RS = 1; // MS1
							case(TIMER_MS1)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								default: LCD_DATA = 8'b00100000;
							endcase
						  end
					13 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					14 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					15 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			default : begin LCD_RS = 1; LCD_RW = 1; LCD_DATA = 8'b00000000; end
		endcase
	end
	


	// <MENU_5 : WORLD TIME> WORLD TIME CHANGE : BUT_EN[3], WORLD = 0:NY, 1:HK, 2:LD
	// LINE 1 : MENU5 WORLD TIME , LINE 2 : NY/HK/LD HH:MM:SS
	else if(LOCK && ~BUS_EN[0] && ~BUS_EN[1] && ~BUS_EN[2] && ~BUS_EN[3] && BUS_EN[4] && ~BUS_EN[5] && ~BUS_EN[6] && ~BUS_EN[7]) begin
		case (STATE)
			DELAY : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000000; end
			FUNCTION_SET : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00111100; end
			DISP_ONOFF : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00001110; end
			ENTRY_MODE : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000110; end
			LINE1 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b10000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M
					2 : begin LCD_RS = 1; LCD_DATA = 8'b01000101; end // E
					3 : begin LCD_RS = 1; LCD_DATA = 8'b01001110; end // N
					4 : begin LCD_RS = 1; LCD_DATA = 8'b01010101; end // U
					5 : begin LCD_RS = 1; LCD_DATA = 8'b00110101; end // 5
					6 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					7 : begin LCD_RS = 1; LCD_DATA = 8'b01010111; end // W
					8 : begin LCD_RS = 1; LCD_DATA = 8'b01001111; end // O
					9 : begin LCD_RS = 1; LCD_DATA = 8'b01010010; end // R
					10 : begin LCD_RS = 1; LCD_DATA = 8'b01001100; end // L
					11 : begin LCD_RS = 1; LCD_DATA = 8'b01000100; end // D
					12 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					13 : begin LCD_RS = 1; LCD_DATA = 8'b01010100; end // T
					14 : begin LCD_RS = 1; LCD_DATA = 8'b01001001; end // I
					15 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M
					16 : begin LCD_RS = 1; LCD_DATA = 8'b01000101; end // E
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			LINE2 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b11000000; end
					1 : begin 
							LCD_RS = 1; 
							if(WORLD == 0) LCD_DATA = 8'b01001110; // N
							else if(WORLD == 1) LCD_DATA = 8'b01001000; // H
							else if(WORLD == 2) LCD_DATA = 8'b01001100; // L
						 end
					2 : begin 
							LCD_RS = 1; 
							if(WORLD == 0) LCD_DATA = 8'b01011001; // Y
							else if(WORLD == 1) LCD_DATA = 8'b01001011; // K
							else if(WORLD == 2) LCD_DATA = 8'b01000100; // D
						 end 
					3 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					4 : begin
							LCD_RS = 1; 
							if(WORLD == 0) begin
								if(((CNT_H1 >= 14) && (CNT_H1 <= 23)) || ((CNT_H1 >= 0) && CNT_H1 <= 1)) LCD_DATA = 8'b01000001; // A
								else LCD_DATA = 8'b01010000; // P
							end
							else if(WORLD == 1) begin
								if((CNT_H1 >= 1) && (CNT_H1 <= 12)) LCD_DATA = 8'b01000001; // A
								else LCD_DATA = 8'b01010000; // P
							end
							else if(WORLD == 2) begin
								if((CNT_H1 >= 9) && (CNT_H1 <= 20)) LCD_DATA = 8'b01000001; // A
								else LCD_DATA = 8'b01010000; // P
							end
						 end
					5 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M 
					6 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					7 : begin // H10
							LCD_RS = 1;
							if(WORLD == 0) begin
								if((CNT_H1 >= 14) && (CNT_H1 <= 23)) LCD_DATA = 8'b00110000; // 0
								else if((CNT_H1 >= 0) && (CNT_H1 <= 9)) LCD_DATA = 8'b00110001; // 1
								else if((CNT_H1 == 10) || (CNT_H1 == 11) || (CNT_H1 == 12) || (CNT_H1 == 13)) LCD_DATA = 8'b00110010; // 2
							end
							else if(WORLD == 1) begin // Seoul - 1hr
								if((CNT_H1 >= 1) && (CNT_H1 <= 10)) LCD_DATA = 8'b00110000; // 0
								else if((CNT_H1 >= 11) && (CNT_H1 <= 20)) LCD_DATA = 8'b00110001; // 1
								else if((CNT_H1 == 0) || (CNT_H1 == 21) || (CNT_H1 == 22) || (CNT_H1 == 23)) LCD_DATA = 8'b00110010; // 2
							end
							else if(WORLD == 2) begin
								if((CNT_H1 >= 9) && (CNT_H1 <= 18)) LCD_DATA = 8'b00110000; // 0
								else if(((CNT_H1 >= 0) && (CNT_H1 <= 4)) || ((CNT_H1 >= 19) && (CNT_H1 <= 23))) LCD_DATA = 8'b00110001; // 1
								else if((CNT_H1 == 5) || (CNT_H1 == 6) || (CNT_H1 == 7) || (CNT_H1 == 8)) LCD_DATA = 8'b00110010; // 2
							end
						 end
					8 : begin // H1
							LCD_RS = 1;
							case(CNT_H1)
								0 : if(WORLD == 0) LCD_DATA = 8'b00110000; // 10
									 else if(WORLD == 1) LCD_DATA = 8'b00110011; // 23
									 else if(WORLD == 2) LCD_DATA = 8'b00110101; // 15
								1 : if(WORLD == 0) LCD_DATA = 8'b00110001; // 11
									 else if(WORLD == 1) LCD_DATA = 8'b00110000; // 0
									 else if(WORLD == 2) LCD_DATA = 8'b00110110; // 16
								2 : if(WORLD == 0) LCD_DATA = 8'b00110010; // 12
									 else if(WORLD == 1) LCD_DATA = 8'b00110001; // 1
									 else if(WORLD == 2) LCD_DATA = 8'b00110111; // 17
								3 : if(WORLD == 0) LCD_DATA = 8'b00110011; // 13
									 else if(WORLD == 1) LCD_DATA = 8'b00110010; // 2
									 else if(WORLD == 2) LCD_DATA = 8'b00111000; // 18
								4 : if(WORLD == 0) LCD_DATA = 8'b00110100; // 14
									 else if(WORLD == 1) LCD_DATA = 8'b00110011; // 3
									 else if(WORLD == 2) LCD_DATA = 8'b00111001; // 19
								5 : if(WORLD == 0) LCD_DATA = 8'b00110101; // 15
									 else if(WORLD == 1) LCD_DATA = 8'b00110100; // 4
									 else if(WORLD == 2) LCD_DATA = 8'b00110000; // 20
								6 : if(WORLD == 0) LCD_DATA = 8'b00110110; // 16
									 else if(WORLD == 1) LCD_DATA = 8'b00110101; // 5
									 else if(WORLD == 2) LCD_DATA = 8'b00110001; // 21
								7 : if(WORLD == 0) LCD_DATA = 8'b00110111; // 17
									 else if(WORLD == 1) LCD_DATA = 8'b00110110; // 6
									 else if(WORLD == 2) LCD_DATA = 8'b00110010; // 22
								8 : if(WORLD == 0) LCD_DATA = 8'b00111000; // 18
									 else if(WORLD == 1) LCD_DATA = 8'b00110111; // 7
									 else if(WORLD == 2) LCD_DATA = 8'b00110011; // 23
								9 : if(WORLD == 0) LCD_DATA = 8'b00111001; // 19
									 else if(WORLD == 1) LCD_DATA = 8'b00111000; // 8
									 else if(WORLD == 2) LCD_DATA = 8'b00110000; // 0
								10 : if(WORLD == 0) LCD_DATA = 8'b00110000; // 20
									  else if(WORLD == 1) LCD_DATA = 8'b00111001; // 9
									  else if(WORLD == 2) LCD_DATA = 8'b00110001; // 1
								11 : if(WORLD == 0) LCD_DATA = 8'b00110001; // 21
									  else if(WORLD == 1) LCD_DATA = 8'b00110000; // 10
									  else if(WORLD == 2) LCD_DATA = 8'b00110010; // 2
								12 : if(WORLD == 0) LCD_DATA = 8'b00110010; // 22
									  else if(WORLD == 1) LCD_DATA = 8'b00110001; // 11
									  else if(WORLD == 2) LCD_DATA = 8'b00110011; // 3
								13 : if(WORLD == 0) LCD_DATA = 8'b00110011; // 23
									  else if(WORLD == 1) LCD_DATA = 8'b00110010; // 12
									  else if(WORLD == 2) LCD_DATA = 8'b00110100; // 4
								14 : if(WORLD == 0) LCD_DATA = 8'b00110000; // 0
									  else if(WORLD == 1) LCD_DATA = 8'b00110011; // 13
									  else if(WORLD == 2) LCD_DATA = 8'b00110101; // 5
								15 : if(WORLD == 0) LCD_DATA = 8'b00110001; // 1
									  else if(WORLD == 1) LCD_DATA = 8'b00110100; // 14
									  else if(WORLD == 2) LCD_DATA = 8'b00110110; // 6
								16 : if(WORLD == 0) LCD_DATA = 8'b00110010; // 2
									  else if(WORLD == 1) LCD_DATA = 8'b00110101; // 15
									  else if(WORLD == 2) LCD_DATA = 8'b00110111; // 7
								17 : if(WORLD == 0) LCD_DATA = 8'b00110011; // 3
									  else if(WORLD == 1) LCD_DATA = 8'b00110110; // 16
									  else if(WORLD == 2) LCD_DATA = 8'b00111000; // 8
								18 : if(WORLD == 0) LCD_DATA = 8'b00110100; // 4
									  else if(WORLD == 1) LCD_DATA = 8'b00110111; // 17
									  else if(WORLD == 2) LCD_DATA = 8'b00111001; // 9
								19 : if(WORLD == 0) LCD_DATA = 8'b00110101; // 5
									  else if(WORLD == 1) LCD_DATA = 8'b00111000; // 18
									  else if(WORLD == 2) LCD_DATA = 8'b00110000; // 10
								20 : if(WORLD == 0) LCD_DATA = 8'b00110110; // 6
									  else if(WORLD == 1) LCD_DATA = 8'b00111001; // 19
									  else if(WORLD == 2) LCD_DATA = 8'b00110001; // 11
								21 : if(WORLD == 0) LCD_DATA = 8'b00110111; // 7
									  else if(WORLD == 1) LCD_DATA = 8'b00110000; // 20
									  else if(WORLD == 2) LCD_DATA = 8'b00110010; // 12
								22 : if(WORLD == 0) LCD_DATA = 8'b00111000; // 8
									  else if(WORLD == 1) LCD_DATA = 8'b00110001; // 21
									  else if(WORLD == 2) LCD_DATA = 8'b00110011; // 13
								23 : if(WORLD == 0) LCD_DATA = 8'b00111001; // 9
									  else if(WORLD == 1) LCD_DATA = 8'b00110010; // 22
									  else if(WORLD == 2) LCD_DATA = 8'b00110100; // 14
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					9 : begin LCD_RS = 1; LCD_DATA = 8'b00111010; end // :
					10 : begin LCD_RS = 1; // M10
							case(CNT_M10)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					11 : begin LCD_RS = 1; // M1
							case(CNT_M1)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								default: LCD_DATA = 8'b00100000;
							endcase
						  end
					12 : begin LCD_RS = 1; LCD_DATA = 8'b00111010; end // :
					13 : begin LCD_RS = 1; // S10
							case(CNT_S10)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					14 : begin LCD_RS = 1; // S1
							case(CNT_S1)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								default: LCD_DATA = 8'b00100000;
							endcase
						  end
					15 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			default : begin LCD_RS = 1; LCD_RW = 1; LCD_DATA = 8'b00000000; end
		endcase
	end	



	// <MENU_6 : SET CALENDAR>
	// LINE1 : MENU6 SET DATE , LINE2: 20YY.MM.DD
	else if(LOCK && ~BUS_EN[0] && ~BUS_EN[1] && ~BUS_EN[2] && ~BUS_EN[3] && ~BUS_EN[4] && BUS_EN[5] && ~BUS_EN[6] && ~BUS_EN[7]) begin
		case (STATE)
			DELAY : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000000; end
			FUNCTION_SET : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00111100; end
			DISP_ONOFF : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00001110; end
			ENTRY_MODE : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000110; end
			LINE1 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b10000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M
					2 : begin LCD_RS = 1; LCD_DATA = 8'b01000101; end // E
					3 : begin LCD_RS = 1; LCD_DATA = 8'b01001110; end // N
					4 : begin LCD_RS = 1; LCD_DATA = 8'b01010101; end // U
					5 : begin LCD_RS = 1; LCD_DATA = 8'b00110110; end // 6
					6 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					7 : begin LCD_RS = 1; LCD_DATA = 8'b01010011; end // S
					8 : begin LCD_RS = 1; LCD_DATA = 8'b01000101; end // E
					9 : begin LCD_RS = 1; LCD_DATA = 8'b01010100; end // T
					10 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					11 : begin LCD_RS = 1; LCD_DATA = 8'b01000100; end // D
					12 : begin LCD_RS = 1; LCD_DATA = 8'b01000001; end // A
					13 : begin LCD_RS = 1; LCD_DATA = 8'b01010100; end // T
					14 : begin LCD_RS = 1; LCD_DATA = 8'b01000101; end // E
					15 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			LINE2 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b11000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					2 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					3 : begin LCD_RS = 1; LCD_DATA = 8'b00110010; end // 2
					4 : begin LCD_RS = 1; LCD_DATA = 8'b00110000; end // 0
					5 : begin // SET_YEAR10
							LCD_RS = 1;
							if(SET_YEAR <= 9) LCD_DATA = 8'b00110000; // 0
							else if((SET_YEAR >= 10) && (SET_YEAR <= 19)) LCD_DATA = 8'b00110001; // 1
							else if((SET_YEAR >= 20) && (SET_YEAR <= 29)) LCD_DATA = 8'b00110010; // 2
							else if((SET_YEAR >= 30) && (SET_YEAR <= 39)) LCD_DATA = 8'b00110011; // 3
							else if((SET_YEAR >= 40) && (SET_YEAR <= 49)) LCD_DATA = 8'b00110100; // 4
							else if((SET_YEAR >= 50) && (SET_YEAR <= 59)) LCD_DATA = 8'b00110101; // 5
							else if((SET_YEAR >= 60) && (SET_YEAR <= 69)) LCD_DATA = 8'b00110110; // 6
							else if((SET_YEAR >= 70) && (SET_YEAR <= 79)) LCD_DATA = 8'b00110111; // 7
							else if((SET_YEAR >= 80) && (SET_YEAR <= 89)) LCD_DATA = 8'b00111000; // 8
							else if((SET_YEAR >= 90) && (SET_YEAR <= 99)) LCD_DATA = 8'b00111001; // 9
						 end
					6 : begin // SET_YEAR1
							LCD_RS = 1;
							case(SET_YEAR)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								10 : LCD_DATA = 8'b00110000; // 0
								11 : LCD_DATA = 8'b00110001; // 1
								12 : LCD_DATA = 8'b00110010; // 2
								13 : LCD_DATA = 8'b00110011; // 3
								14 : LCD_DATA = 8'b00110100; // 4
								15 : LCD_DATA = 8'b00110101; // 5
								16 : LCD_DATA = 8'b00110110; // 6
								17 : LCD_DATA = 8'b00110111; // 7
								18 : LCD_DATA = 8'b00111000; // 8
								19 : LCD_DATA = 8'b00111001; // 9
								20 : LCD_DATA = 8'b00110000; // 0
								21 : LCD_DATA = 8'b00110001; // 1
								22 : LCD_DATA = 8'b00110010; // 2
								23 : LCD_DATA = 8'b00110011; // 3
								24 : LCD_DATA = 8'b00110100; // 4
								25 : LCD_DATA = 8'b00110101; // 5
								26 : LCD_DATA = 8'b00110110; // 6
								27 : LCD_DATA = 8'b00110111; // 7
								28 : LCD_DATA = 8'b00111000; // 8
								29 : LCD_DATA = 8'b00111001; // 9
								30 : LCD_DATA = 8'b00110000; // 0
								31 : LCD_DATA = 8'b00110001; // 1
								32 : LCD_DATA = 8'b00110010; // 2
								33 : LCD_DATA = 8'b00110011; // 3
								34 : LCD_DATA = 8'b00110100; // 4
								35 : LCD_DATA = 8'b00110101; // 5
								36 : LCD_DATA = 8'b00110110; // 6
								37 : LCD_DATA = 8'b00110111; // 7
								38 : LCD_DATA = 8'b00111000; // 8
								39 : LCD_DATA = 8'b00111001; // 9
								40 : LCD_DATA = 8'b00110000; // 0
								41 : LCD_DATA = 8'b00110001; // 1
								42 : LCD_DATA = 8'b00110010; // 2
								43 : LCD_DATA = 8'b00110011; // 3
								44 : LCD_DATA = 8'b00110100; // 4
								45 : LCD_DATA = 8'b00110101; // 5
								46 : LCD_DATA = 8'b00110110; // 6
								47 : LCD_DATA = 8'b00110111; // 7
								48 : LCD_DATA = 8'b00111000; // 8
								49 : LCD_DATA = 8'b00111001; // 9
								50 : LCD_DATA = 8'b00110000; // 0
								51 : LCD_DATA = 8'b00110001; // 1
								52 : LCD_DATA = 8'b00110010; // 2
								53 : LCD_DATA = 8'b00110011; // 3
								54 : LCD_DATA = 8'b00110100; // 4
								55 : LCD_DATA = 8'b00110101; // 5
								56 : LCD_DATA = 8'b00110110; // 6
								57 : LCD_DATA = 8'b00110111; // 7
								58 : LCD_DATA = 8'b00111000; // 8
								59 : LCD_DATA = 8'b00111001; // 9
								60 : LCD_DATA = 8'b00110000; // 0
								61 : LCD_DATA = 8'b00110001; // 1
								62 : LCD_DATA = 8'b00110010; // 2
								63 : LCD_DATA = 8'b00110011; // 3
								64 : LCD_DATA = 8'b00110100; // 4
								65 : LCD_DATA = 8'b00110101; // 5
								66 : LCD_DATA = 8'b00110110; // 6
								67 : LCD_DATA = 8'b00110111; // 7
								68 : LCD_DATA = 8'b00111000; // 8
								69 : LCD_DATA = 8'b00111001; // 9
								70 : LCD_DATA = 8'b00110000; // 0
								71 : LCD_DATA = 8'b00110001; // 1
								72 : LCD_DATA = 8'b00110010; // 2
								73 : LCD_DATA = 8'b00110011; // 3
								74 : LCD_DATA = 8'b00110100; // 4
								75 : LCD_DATA = 8'b00110101; // 5
								76 : LCD_DATA = 8'b00110110; // 6
								77 : LCD_DATA = 8'b00110111; // 7
								78 : LCD_DATA = 8'b00111000; // 8
								79 : LCD_DATA = 8'b00111001; // 9
								80 : LCD_DATA = 8'b00110000; // 0
								81 : LCD_DATA = 8'b00110001; // 1
								82 : LCD_DATA = 8'b00110010; // 2
								83 : LCD_DATA = 8'b00110011; // 3
								84 : LCD_DATA = 8'b00110100; // 4
								85 : LCD_DATA = 8'b00110101; // 5
								86 : LCD_DATA = 8'b00110110; // 6
								87 : LCD_DATA = 8'b00110111; // 7
								88 : LCD_DATA = 8'b00111000; // 8
								89 : LCD_DATA = 8'b00111001; // 9
								90 : LCD_DATA = 8'b00110000; // 0
								91 : LCD_DATA = 8'b00110001; // 1
								92 : LCD_DATA = 8'b00110010; // 2
								93 : LCD_DATA = 8'b00110011; // 3
								94 : LCD_DATA = 8'b00110100; // 4
								95 : LCD_DATA = 8'b00110101; // 5
								96 : LCD_DATA = 8'b00110110; // 6
								97 : LCD_DATA = 8'b00110111; // 7
								98 : LCD_DATA = 8'b00111000; // 8
								99 : LCD_DATA = 8'b00111001; // 9
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					7 : begin LCD_RS = 1; LCD_DATA = 8'b00101110; end // .
					8 : begin // SET_MONTH10
							LCD_RS = 1;
							if(SET_MONTH <= 9) LCD_DATA = 8'b00110000; // 0
							else if((SET_MONTH >= 10) && (SET_MONTH <= 12)) LCD_DATA = 8'b00110001; // 1
						 end
					9 : begin LCD_RS = 1; // SET_MONTH1
							case(SET_MONTH)
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								10 : LCD_DATA = 8'b00110000; // 0
								11 : LCD_DATA = 8'b00110001; // 1
								12 : LCD_DATA = 8'b00110010; // 2
								default: LCD_DATA = 8'b00100001;
							endcase
						  end
					10 : begin LCD_RS = 1; LCD_DATA = 8'b00101110; end // .
					11 : begin // SET_DAY10
							LCD_RS = 1;
							if(SET_DAY <= 9) LCD_DATA = 8'b00110000; // 0
							else if((SET_DAY >= 10) && (SET_DAY <= 19)) LCD_DATA = 8'b00110001; // 1
							else if((SET_DAY >= 10) && (SET_DAY <= 29)) LCD_DATA = 8'b00110010; // 2
							else if(SET_DAY == 30) LCD_DATA = 8'b00110011; // 3
						 end
					12 : begin LCD_RS = 1; // SET_DAY1
							case(SET_DAY)
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								10 : LCD_DATA = 8'b00110000; // 0
								11 : LCD_DATA = 8'b00110001; // 1
								12 : LCD_DATA = 8'b00110010; // 2
								13 : LCD_DATA = 8'b00110011; // 3
								14 : LCD_DATA = 8'b00110100; // 4
								15 : LCD_DATA = 8'b00110101; // 5
								16 : LCD_DATA = 8'b00110110; // 6
								17 : LCD_DATA = 8'b00110111; // 7
								18 : LCD_DATA = 8'b00111000; // 8
								19 : LCD_DATA = 8'b00111001; // 9
								20 : LCD_DATA = 8'b00110000; // 0
								21 : LCD_DATA = 8'b00110001; // 1
								22 : LCD_DATA = 8'b00110010; // 2
								23 : LCD_DATA = 8'b00110011; // 3
								24 : LCD_DATA = 8'b00110100; // 4
								25 : LCD_DATA = 8'b00110101; // 5
								26 : LCD_DATA = 8'b00110110; // 6
								27 : LCD_DATA = 8'b00110111; // 7
								28 : LCD_DATA = 8'b00111000; // 8
								29 : LCD_DATA = 8'b00111001; // 9
								30 : LCD_DATA = 8'b00110000; // 0
								default: LCD_DATA = 8'b00100001;
							endcase
						  end
					13 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					14 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					15 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			default : begin LCD_RS = 1; LCD_RW = 1; LCD_DATA = 8'b00000000; end
		endcase
	end



	// <MENU_7 : CALENDAR>
	// LINE1 : MENU7 DATE , LINE2: 20YY.MM.DD
	else if(LOCK && ~BUS_EN[0] && ~BUS_EN[1] && ~BUS_EN[2] && ~BUS_EN[3] && ~BUS_EN[4] && ~BUS_EN[5] && BUS_EN[6] && ~BUS_EN[7]) begin
		case (STATE)
			DELAY : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000000; end
			FUNCTION_SET : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00111100; end
			DISP_ONOFF : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00001110; end
			ENTRY_MODE : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000110; end
			LINE1 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b10000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M
					2 : begin LCD_RS = 1; LCD_DATA = 8'b01000101; end // E
					3 : begin LCD_RS = 1; LCD_DATA = 8'b01001110; end // N
					4 : begin LCD_RS = 1; LCD_DATA = 8'b01010101; end // U
					5 : begin LCD_RS = 1; LCD_DATA = 8'b00110111; end // 7
					6 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					7 : begin LCD_RS = 1; LCD_DATA = 8'b01000100; end // D
					8 : begin LCD_RS = 1; LCD_DATA = 8'b01000001; end // A
					9 : begin LCD_RS = 1; LCD_DATA = 8'b01010100; end // T
					10 : begin LCD_RS = 1; LCD_DATA = 8'b01000101; end // E
					11 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					12 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					13 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					14 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					15 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			LINE2 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b11000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					2 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					3 : begin LCD_RS = 1; LCD_DATA = 8'b00110010; end // 2
					4 : begin LCD_RS = 1; LCD_DATA = 8'b00110000; end // 0
					5 : begin // YEAR10
							LCD_RS = 1;
							if(YEAR <= 9) LCD_DATA = 8'b00110000; // 0
							else if((YEAR >= 10) && (YEAR <= 19)) LCD_DATA = 8'b00110001; // 1
							else if((YEAR >= 20) && (YEAR <= 29)) LCD_DATA = 8'b00110010; // 2
							else if((YEAR >= 30) && (YEAR <= 39)) LCD_DATA = 8'b00110011; // 3
							else if((YEAR >= 40) && (YEAR <= 49)) LCD_DATA = 8'b00110100; // 4
							else if((YEAR >= 50) && (YEAR <= 59)) LCD_DATA = 8'b00110101; // 5
							else if((YEAR >= 60) && (YEAR <= 69)) LCD_DATA = 8'b00110110; // 6
							else if((YEAR >= 70) && (YEAR <= 79)) LCD_DATA = 8'b00110111; // 7
							else if((YEAR >= 80) && (YEAR <= 89)) LCD_DATA = 8'b00111000; // 8
							else if((YEAR >= 90) && (YEAR <= 99)) LCD_DATA = 8'b00111001; // 9
						 end
					6 : begin // YEAR1
							LCD_RS = 1;
							case(YEAR)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								10 : LCD_DATA = 8'b00110000; // 0
								11 : LCD_DATA = 8'b00110001; // 1
								12 : LCD_DATA = 8'b00110010; // 2
								13 : LCD_DATA = 8'b00110011; // 3
								14 : LCD_DATA = 8'b00110100; // 4
								15 : LCD_DATA = 8'b00110101; // 5
								16 : LCD_DATA = 8'b00110110; // 6
								17 : LCD_DATA = 8'b00110111; // 7
								18 : LCD_DATA = 8'b00111000; // 8
								19 : LCD_DATA = 8'b00111001; // 9
								20 : LCD_DATA = 8'b00110000; // 0
								21 : LCD_DATA = 8'b00110001; // 1
								22 : LCD_DATA = 8'b00110010; // 2
								23 : LCD_DATA = 8'b00110011; // 3
								24 : LCD_DATA = 8'b00110100; // 4
								25 : LCD_DATA = 8'b00110101; // 5
								26 : LCD_DATA = 8'b00110110; // 6
								27 : LCD_DATA = 8'b00110111; // 7
								28 : LCD_DATA = 8'b00111000; // 8
								29 : LCD_DATA = 8'b00111001; // 9
								30 : LCD_DATA = 8'b00110000; // 0
								31 : LCD_DATA = 8'b00110001; // 1
								32 : LCD_DATA = 8'b00110010; // 2
								33 : LCD_DATA = 8'b00110011; // 3
								34 : LCD_DATA = 8'b00110100; // 4
								35 : LCD_DATA = 8'b00110101; // 5
								36 : LCD_DATA = 8'b00110110; // 6
								37 : LCD_DATA = 8'b00110111; // 7
								38 : LCD_DATA = 8'b00111000; // 8
								39 : LCD_DATA = 8'b00111001; // 9
								40 : LCD_DATA = 8'b00110000; // 0
								41 : LCD_DATA = 8'b00110001; // 1
								42 : LCD_DATA = 8'b00110010; // 2
								43 : LCD_DATA = 8'b00110011; // 3
								44 : LCD_DATA = 8'b00110100; // 4
								45 : LCD_DATA = 8'b00110101; // 5
								46 : LCD_DATA = 8'b00110110; // 6
								47 : LCD_DATA = 8'b00110111; // 7
								48 : LCD_DATA = 8'b00111000; // 8
								49 : LCD_DATA = 8'b00111001; // 9
								50 : LCD_DATA = 8'b00110000; // 0
								51 : LCD_DATA = 8'b00110001; // 1
								52 : LCD_DATA = 8'b00110010; // 2
								53 : LCD_DATA = 8'b00110011; // 3
								54 : LCD_DATA = 8'b00110100; // 4
								55 : LCD_DATA = 8'b00110101; // 5
								56 : LCD_DATA = 8'b00110110; // 6
								57 : LCD_DATA = 8'b00110111; // 7
								58 : LCD_DATA = 8'b00111000; // 8
								59 : LCD_DATA = 8'b00111001; // 9
								60 : LCD_DATA = 8'b00110000; // 0
								61 : LCD_DATA = 8'b00110001; // 1
								62 : LCD_DATA = 8'b00110010; // 2
								63 : LCD_DATA = 8'b00110011; // 3
								64 : LCD_DATA = 8'b00110100; // 4
								65 : LCD_DATA = 8'b00110101; // 5
								66 : LCD_DATA = 8'b00110110; // 6
								67 : LCD_DATA = 8'b00110111; // 7
								68 : LCD_DATA = 8'b00111000; // 8
								69 : LCD_DATA = 8'b00111001; // 9
								70 : LCD_DATA = 8'b00110000; // 0
								71 : LCD_DATA = 8'b00110001; // 1
								72 : LCD_DATA = 8'b00110010; // 2
								73 : LCD_DATA = 8'b00110011; // 3
								74 : LCD_DATA = 8'b00110100; // 4
								75 : LCD_DATA = 8'b00110101; // 5
								76 : LCD_DATA = 8'b00110110; // 6
								77 : LCD_DATA = 8'b00110111; // 7
								78 : LCD_DATA = 8'b00111000; // 8
								79 : LCD_DATA = 8'b00111001; // 9
								80 : LCD_DATA = 8'b00110000; // 0
								81 : LCD_DATA = 8'b00110001; // 1
								82 : LCD_DATA = 8'b00110010; // 2
								83 : LCD_DATA = 8'b00110011; // 3
								84 : LCD_DATA = 8'b00110100; // 4
								85 : LCD_DATA = 8'b00110101; // 5
								86 : LCD_DATA = 8'b00110110; // 6
								87 : LCD_DATA = 8'b00110111; // 7
								88 : LCD_DATA = 8'b00111000; // 8
								89 : LCD_DATA = 8'b00111001; // 9
								90 : LCD_DATA = 8'b00110000; // 0
								91 : LCD_DATA = 8'b00110001; // 1
								92 : LCD_DATA = 8'b00110010; // 2
								93 : LCD_DATA = 8'b00110011; // 3
								94 : LCD_DATA = 8'b00110100; // 4
								95 : LCD_DATA = 8'b00110101; // 5
								96 : LCD_DATA = 8'b00110110; // 6
								97 : LCD_DATA = 8'b00110111; // 7
								98 : LCD_DATA = 8'b00111000; // 8
								99 : LCD_DATA = 8'b00111001; // 9
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					7 : begin LCD_RS = 1; LCD_DATA = 8'b00101110; end // .
					8 : begin // MONTH10
							LCD_RS = 1;
							if(MONTH <= 9) LCD_DATA = 8'b00110000; // 0
							else if((MONTH >= 10) && (MONTH <= 12)) LCD_DATA = 8'b00110001; // 1
						 end
					9 : begin LCD_RS = 1; // MONTH1
							case(MONTH)
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								10 : LCD_DATA = 8'b00110000; // 0
								11 : LCD_DATA = 8'b00110001; // 1
								12 : LCD_DATA = 8'b00110010; // 2
								default: LCD_DATA = 8'b00100001;
							endcase
						  end
					10 : begin LCD_RS = 1; LCD_DATA = 8'b00101110; end // .
					11 : begin // DAY10
							LCD_RS = 1;
							if(DAY <= 9) LCD_DATA = 8'b00110000; // 0
							else if((DAY >= 10) && (DAY <= 19)) LCD_DATA = 8'b00110001; // 1
							else if((DAY >= 10) && (DAY <= 29)) LCD_DATA = 8'b00110010; // 2
							else if(DAY == 30) LCD_DATA = 8'b00110011; // 3
						 end
					12 : begin LCD_RS = 1; // DAY1
							case(DAY)
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								10 : LCD_DATA = 8'b00110000; // 0
								11 : LCD_DATA = 8'b00110001; // 1
								12 : LCD_DATA = 8'b00110010; // 2
								13 : LCD_DATA = 8'b00110011; // 3
								14 : LCD_DATA = 8'b00110100; // 4
								15 : LCD_DATA = 8'b00110101; // 5
								16 : LCD_DATA = 8'b00110110; // 6
								17 : LCD_DATA = 8'b00110111; // 7
								18 : LCD_DATA = 8'b00111000; // 8
								19 : LCD_DATA = 8'b00111001; // 9
								20 : LCD_DATA = 8'b00110000; // 0
								21 : LCD_DATA = 8'b00110001; // 1
								22 : LCD_DATA = 8'b00110010; // 2
								23 : LCD_DATA = 8'b00110011; // 3
								24 : LCD_DATA = 8'b00110100; // 4
								25 : LCD_DATA = 8'b00110101; // 5
								26 : LCD_DATA = 8'b00110110; // 6
								27 : LCD_DATA = 8'b00110111; // 7
								28 : LCD_DATA = 8'b00111000; // 8
								29 : LCD_DATA = 8'b00111001; // 9
								30 : LCD_DATA = 8'b00110000; // 0
								default: LCD_DATA = 8'b00100001;
							endcase
						  end
					13 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					14 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					15 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			default : begin LCD_RS = 1; LCD_RW = 1; LCD_DATA = 8'b00000000; end
		endcase
	end
	


	// <MENU_8 : ROCK & PAPER & SCISSOR GAME>
	// LINE1 : GAME1 W_ L_ D_, LINE2: COM-R/P/S YOU-R/P/S
	else if(LOCK && ~BUS_EN[0] && ~BUS_EN[1] && ~BUS_EN[2] && ~BUS_EN[3] && ~BUS_EN[4] && ~BUS_EN[5] && ~BUS_EN[6] && BUS_EN[7]) begin
		case (STATE)
			DELAY : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000000; end
			FUNCTION_SET : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00111100; end
			DISP_ONOFF : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00001110; end
			ENTRY_MODE : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000110; end
			LINE1 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b10000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					2 : begin LCD_RS = 1; LCD_DATA = 8'b01000111; end // G
					3 : begin LCD_RS = 1; LCD_DATA = 8'b01000001; end // A
					4 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M
					5 : begin LCD_RS = 1; LCD_DATA = 8'b01000101; end // E
					6 : begin LCD_RS = 1; LCD_DATA = 8'b00110001; end // 1
					7 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					8 : begin LCD_RS = 1; LCD_DATA = 8'b01010111; end // W
					9 : begin LCD_RS = 1;
							case(WIN)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								default : LCD_DATA = 8'b00110000; // 0
							endcase
						end
					10 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					11 : begin LCD_RS = 1; LCD_DATA = 8'b01001100; end // L
					12 : begin LCD_RS = 1;
							case(LOSE)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								default : LCD_DATA = 8'b00110000; // 0
							endcase
						end
					13 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					14 : begin LCD_RS = 1; LCD_DATA = 8'b01000100; end // D
					15 : begin LCD_RS = 1;
							case(DRAW)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								default : LCD_DATA = 8'b00110000; // 0
							endcase
						end
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			LINE2 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b11000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					2 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					3 : begin LCD_RS = 1; LCD_DATA = 8'b01000011; end // C
					4 : begin LCD_RS = 1; LCD_DATA = 8'b01001111; end // O
					5 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M
					6 : begin LCD_RS = 1; LCD_DATA = 8'b00101101; end // -
					7 : begin LCD_RS = 1;
							case(COM_PLAY)
								0 : LCD_DATA = 8'b01011111; // _
								1 : LCD_DATA = 8'b01010010; // R (ROCK)
								2 : LCD_DATA = 8'b01010000; // P (PAPER)
								3 : LCD_DATA = 8'b01010011; // S (SCISSOR)
								default : LCD_DATA = 8'b01011111; // _
							endcase
						end
					8 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					9 : begin LCD_RS = 1; LCD_DATA = 8'b01011001; end // Y
					10 : begin LCD_RS = 1; LCD_DATA = 8'b01001111; end // O
					11 : begin LCD_RS = 1; LCD_DATA = 8'b01010101; end // U
					12 : begin LCD_RS = 1; LCD_DATA = 8'b00101101; end // -
					13 : begin LCD_RS = 1;
							case(YOU_PLAY)
								0 : LCD_DATA = 8'b01011111; // _
								1 : LCD_DATA = 8'b01010010; // R (ROCK)
								2 : LCD_DATA = 8'b01010000; // P (PAPER)
								3 : LCD_DATA = 8'b01010011; // S (SCISSOR)
								default : LCD_DATA = 8'b01011111; // _
							endcase
						end
					14 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					15 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			default : begin LCD_RS = 1; LCD_RW = 1; LCD_DATA = 8'b00000000; end
		endcase
	end
	

	// <DEFAULT : DIGITAL CLOCK (SEOUL)>
	// LINE1 : 2015440029 KYJ , LINE2: AM/PM HH:MM:SS
	else begin
		case (STATE)
			DELAY : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000000; end
			FUNCTION_SET : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00111100; end
			DISP_ONOFF : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00001110; end
			ENTRY_MODE : begin LCD_RS = 0; LCD_RW = 0; LCD_DATA = 8'b00000110; end
			LINE1 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b10000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					2 : begin LCD_RS = 1; LCD_DATA = 8'b00110010; end // 2
					3 : begin LCD_RS = 1; LCD_DATA = 8'b00110000; end // 0
					4 : begin LCD_RS = 1; LCD_DATA = 8'b00110001; end // 1
					5 : begin LCD_RS = 1; LCD_DATA = 8'b00110101; end // 5
					6 : begin LCD_RS = 1; LCD_DATA = 8'b00110100; end // 4
					7 : begin LCD_RS = 1; LCD_DATA = 8'b00110100; end // 4
					8 : begin LCD_RS = 1; LCD_DATA = 8'b00110000; end // 0
					9 : begin LCD_RS = 1; LCD_DATA = 8'b00110000; end // 0
					10 : begin LCD_RS = 1; LCD_DATA = 8'b00110010; end // 2
					11 : begin LCD_RS = 1; LCD_DATA = 8'b00111001; end // 9
					12 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					13 : begin LCD_RS = 1; LCD_DATA = 8'b01001011; end // K
					14 : begin LCD_RS = 1; LCD_DATA = 8'b01011001; end // Y
					15 : begin LCD_RS = 1; LCD_DATA = 8'b01001010; end // J
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			LINE2 : begin
				LCD_RW = 0;
				case(CNT)
					0 : begin LCD_RS = 0; LCD_DATA = 8'b11000000; end
					1 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					2 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					3 : begin
							LCD_RS = 1; 
							if(CNT_CYCLE == 0) LCD_DATA = 8'b01000001; // A
							else LCD_DATA = 8'b01010000; // P
						 end
					4 : begin LCD_RS = 1; LCD_DATA = 8'b01001101; end // M
					5 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					6 : begin // H10
							LCD_RS = 1;
							if((CNT_H1 <= 9) || ((CNT_H1 <= 21) && (CNT_H1 >= 13))) LCD_DATA = 8'b00110000; // 0
							else LCD_DATA = 8'b00110001; // 1
						 end
					7 : begin // H1
							LCD_RS = 1;
							case(CNT_H1)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								10 : LCD_DATA = 8'b00110000; // 10
								11 : LCD_DATA = 8'b00110001; // 11
								12 : LCD_DATA = 8'b00110010; // 12
								13 : LCD_DATA = 8'b00110001; // 1
								14 : LCD_DATA = 8'b00110010; // 2
								15 : LCD_DATA = 8'b00110011; // 3
								16 : LCD_DATA = 8'b00110100; // 4
								17 : LCD_DATA = 8'b00110101; // 5
								18 : LCD_DATA = 8'b00110110; // 6
								19 : LCD_DATA = 8'b00110111; // 7
								20 : LCD_DATA = 8'b00111000; // 8
								21 : LCD_DATA = 8'b00111001; // 9
								22 : LCD_DATA = 8'b00110001; // 10
								23 : LCD_DATA = 8'b00110001; // 11
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					8 : begin LCD_RS = 1; LCD_DATA = 8'b00111010; end // :
					9 : begin LCD_RS = 1; // M10
							case(CNT_M10)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					10 : begin LCD_RS = 1; // M1
							case(CNT_M1)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								default: LCD_DATA = 8'b00100000;
							endcase
						  end
					11 : begin LCD_RS = 1; LCD_DATA = 8'b00111010; end // :
					12 : begin LCD_RS = 1; // S10
							case(CNT_S10)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								default: LCD_DATA = 8'b00100000;
							endcase
						 end
					13 : begin LCD_RS = 1; // S1
							case(CNT_S1)
								0 : LCD_DATA = 8'b00110000; // 0
								1 : LCD_DATA = 8'b00110001; // 1
								2 : LCD_DATA = 8'b00110010; // 2
								3 : LCD_DATA = 8'b00110011; // 3
								4 : LCD_DATA = 8'b00110100; // 4
								5 : LCD_DATA = 8'b00110101; // 5
								6 : LCD_DATA = 8'b00110110; // 6
								7 : LCD_DATA = 8'b00110111; // 7
								8 : LCD_DATA = 8'b00111000; // 8
								9 : LCD_DATA = 8'b00111001; // 9
								default: LCD_DATA = 8'b00100000;
							endcase
						  end
					14 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end // 
					15 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					16 : begin LCD_RS = 1; LCD_DATA = 8'b00100000; end //
					default: begin LCD_RS = 1; LCD_DATA = 8'b00100000; end
				endcase
			end
			default : begin LCD_RS = 1; LCD_RW = 1; LCD_DATA = 8'b00000000; end
		endcase
	end
	

end

assign LCD_E = CLK_M; // LCD Signal speed



// Time counters for STOPWATCH & TIMER
// BUT_EN[4] = SW_START, BUT_EN[5] = SW_STOP, BUT_EN[6] = T_START, BUT_EN[7] = T_STOP, BUT_EN[8] = SW_RESET, BUT_EN[9] = T_RESET
reg SW_START, SW_STOP, T_START, T_STOP, SW_RESET, T_RESET;
initial begin 
	SW_START = 0; SW_STOP = 0;
	T_START = 0; T_STOP = 0;
	SW_RESET = 0; T_RESET = 0;
end


always @(posedge BUT_EN[4] or posedge BUT_EN[5] or posedge BUT_EN[8]) begin
	if(BUT_EN[8]) begin SW_START = 0; SW_STOP = 0; SW_RESET = 1; end
	else if(BUT_EN[4]) begin SW_START = 1; SW_STOP = 0; SW_RESET = 0; end
	else if(BUT_EN[5]) begin SW_START = 0; SW_STOP = 1; SW_RESET = 0; end
end

// STOPWATCH Counters
always @(posedge CLK_M) begin // 0.01 second counter
	if(SW_RESET) STOP_MS1 = 0;
	else if (SW_START) begin // START
		if (STOP_MS1 >= 9) STOP_MS1 = 0;
		else STOP_MS1 = STOP_MS1 + 1;
	end
end

always @(posedge CLK_M) begin // 0.1 second counter
	if(SW_RESET) STOP_MS10 = 0;
	else if (SW_START) begin // START
		if (STOP_MS1 == 9) begin
			if (STOP_MS10 >= 9) STOP_MS10 = 0;
			else STOP_MS10 = STOP_MS10 + 1;
		end
	end
end

always @(posedge CLK_M) begin // 1 second counter
	if(SW_RESET) STOP_S1 = 0;
	else if (SW_START) begin // START
		if ((STOP_MS1 == 9) && (STOP_MS10 == 9)) begin
			if (STOP_S1 >= 9) STOP_S1 = 0;
			else STOP_S1 = STOP_S1 + 1;
		end
	end
end

always @(posedge CLK_M) begin // 10 second counter
	if(SW_RESET) STOP_S10 = 0;
	else if (SW_START) begin // START
		if ((STOP_MS1 == 9) && (STOP_MS10 == 9) && (STOP_S1 == 9)) begin
			if (STOP_S10 >= 5) STOP_S10 = 0;
			else STOP_S10 = STOP_S10 + 1;
		end
	end
end

always @(posedge CLK_M) begin // 1 minute counter
	if(SW_RESET) STOP_M1 = 0;
	else if (SW_START) begin // START
		if ((STOP_MS1 == 9) && (STOP_MS10 == 9) && (STOP_S1 == 9) && (STOP_S10 == 5)) begin
			if (STOP_M1 >= 9) STOP_M1 = 0;
			else STOP_M1 = STOP_M1 + 1;
		end
	end
end

always @(posedge CLK_M) begin // 10 minute counter
	if(SW_RESET) STOP_M10 = 0;
	else if (SW_START) begin // START
		if ((STOP_MS1 == 9) && (STOP_MS10 == 9) && (STOP_S1 == 9) && (STOP_S10 == 5) && (STOP_M1 == 9)) begin
			if (STOP_M10 >= 5) STOP_M10 = 0;
			else STOP_M10 = STOP_M10 + 1;
		end
	end
end



// TIMER Counters
reg TIMER_FIN, TIMER_EN;
initial begin TIMER_FIN = 0; TIMER_EN = 0; TIMER_M1 = 1; TIMER_S10 = 0; TIMER_S1 = 0; TIMER_MS10 = 0; TIMER_MS1 = 0; end

always @(posedge CLK_M) begin
	if((TIMER_M1 == 0) && (TIMER_S10 == 0) && (TIMER_S1 == 0)) TIMER_FIN = 1; // TIMER FINISH condition
	if(BUT_EN[9]) begin T_START = 0; T_STOP = 0; T_RESET = 1; TIMER_FIN = 0; end
	else if(BUT_EN[6]) begin T_START = 1; T_STOP = 0; T_RESET = 0; end
	else if(BUT_EN[7]) begin T_START = 0; T_STOP = 1; T_RESET = 0; TIMER_FIN = 0; end
end

always @(posedge CLK_M) begin // TIMER Sound condition
	if((TIMER_FIN == 1) && (T_STOP == 0) && (BUS_EN[3] == 1)) TIMER_EN = 1;
	else TIMER_EN = 0;
end

always @(posedge CLK_M) begin // 0.01 second counter
	if(T_RESET) TIMER_MS1 = 0;
	if(TIMER_FIN == 0) begin	
		if (T_START) begin // START
			if (TIMER_MS1 <= 0) TIMER_MS1 = 9;
			else TIMER_MS1 = TIMER_MS1 - 1;
		end
	end
	else if(TIMER_FIN == 1) TIMER_MS1 = 0;
end

always @(posedge CLK_M) begin // 0.1 second counter
	if(T_RESET) TIMER_MS10 = 0;
	if(TIMER_FIN == 0) begin	
		if (T_START) begin // START
			if (TIMER_MS1 == 0) begin
				if (TIMER_MS10 <= 0) TIMER_MS10 = 9;
				else TIMER_MS10 = TIMER_MS10 - 1;
			end
		end
	end
	else if(TIMER_FIN == 1) TIMER_MS10 = 0;
end

always @(posedge CLK_M) begin // 1 second counter
	if(T_RESET) TIMER_S1 = 0;
	if(BUT_EN[2]) TIMER_S1 = SET_TIMER_S1;
	if(TIMER_FIN == 0) begin	
		if (T_START) begin // START
			if ((TIMER_MS1 == 0) && (TIMER_MS10 == 0)) begin
				if (TIMER_S1 <= 0) TIMER_S1 = 9;
				else TIMER_S1 = TIMER_S1 - 1;
			end
		end
	end
end

always @(posedge CLK_M) begin // 10 second counter
	if(T_RESET) TIMER_S10 = 0;
	if(BUT_EN[2]) TIMER_S10 = SET_TIMER_S10;
	if(TIMER_FIN == 0) begin	
		if (T_START) begin // START
			if ((TIMER_MS1 == 0) && (TIMER_MS10 == 0) && (TIMER_S1 == 0)) begin
				if (TIMER_S10 <= 0) TIMER_S10 = 5;
				else TIMER_S10 = TIMER_S10 - 1;
			end
		end
	end
end

always @(posedge CLK_M) begin // 1 minute counter
	if(T_RESET) TIMER_M1 = 1;
	if(BUT_EN[2]) TIMER_M1 = SET_TIMER_M1;
	if(TIMER_FIN == 0) begin	
		if (T_START) begin // START
			if ((TIMER_MS1 == 0) && (TIMER_MS10 == 0) && (TIMER_S1 == 0) && (TIMER_S10 == 0)) begin
				if (TIMER_M1 <= 0) TIMER_M1 = 0;
				else TIMER_M1 = TIMER_M1 - 1;
			end
		end
	end
end



// ALARM MUSIC & LED
integer CNT_BEAT, CNT_NOTE, CNT_SOUND, CNT_LIGHT, CNT_LED;
reg MUSIC_EN, LED_EN, BUFF;
reg [15:0] SOUND;

initial begin
	MUSIC_EN = 0;
	LED_EN = 0;
	CNT_BEAT = 0;
	CNT_NOTE = 0;
	CNT_LIGHT = 0;
	CNT_LED = 0;
end

always @(posedge CLK) begin // ALARM
	if((ALARM_H1 == CNT_H1) && (ALARM_M10 == CNT_M10) && (ALARM_M1 == CNT_M1)) begin
		MUSIC_EN = 1; // ALARM MUSIC_EN
		LED_EN = 1; // ALARM LED_EN
	end
	else begin
		MUSIC_EN = 0; // ALARM  MUSIC Disable
		LED_EN = 0; // ALARM LED Disable
	end
end

always @(posedge CLK_1MHz) begin // Sound Counter
	if (~RESETN) begin
		BUFF = 1'b0;
		CNT_SOUND = 0;
	end
	else if(MUSIC_EN || TIMER_EN || GAME_SET) begin
		if (CNT_SOUND >= SOUND)
			begin
				CNT_SOUND = 0;
				BUFF = ~BUFF;
			end
		else CNT_SOUND = CNT_SOUND + 1;
	end
end
assign PIEZO = BUFF;


always @(posedge CLK_M) begin // LED Counter
	if(LED_EN || TIMER_EN || GAME_SET) begin
		if (CNT_LIGHT >= 33) begin // LED Speed
			CNT_LIGHT = 0;
			CNT_LED = CNT_LED + 1;
		end
		else CNT_LIGHT = CNT_LIGHT + 1;
		if(CNT_LED == 8) CNT_LED = 0;
	end
end

always @(posedge CLK_M) begin // LED Cases
	case (CNT_LED)
		0 : begin LED = 8'b00000001; end
		1 : begin LED = 8'b00000010; end
		2 : begin LED = 8'b00000100; end
		3 : begin LED = 8'b00001000; end
		4 : begin LED = 8'b00010000; end
		5 : begin LED = 8'b00100000; end
		6 : begin LED = 8'b01000000; end
		7 : begin LED = 8'b10000000; end
		default : begin LED = 8'b00000000; end
	endcase
end


always@(posedge CLK_M) begin // Counter for the music beat
	if(MUSIC_EN || TIMER_EN || GAME_SET) begin
		if(CNT_BEAT >= 11) begin //MUSIC beat
			CNT_BEAT = 0;
			CNT_NOTE = CNT_NOTE + 1;
		end
		else CNT_BEAT = CNT_BEAT + 1;
		if(CNT_NOTE == 48) CNT_NOTE = 0; //Number of notes : 140
	end
end

always @(posedge CLK_M) begin // Sound Cases
	case (CNT_NOTE) 
		1:begin SOUND = 16'd0319; end
		2:begin SOUND = 16'd0253; end
		3:begin SOUND = 16'd0425; end
		4:begin SOUND = 16'd0319; end
		5:begin SOUND = 16'd0379; end
		6:begin SOUND = 16'd0319; end
		7:begin SOUND = 16'd0426; end
		8:begin SOUND = 16'd0319; end
		9:begin SOUND = 16'd0506; end
		10:begin SOUND = 16'd0426; end
		11:begin SOUND = 16'd0638; end
		12:begin SOUND = 16'd0506; end
		13:begin SOUND = 16'd0638; end
		14:begin SOUND = 16'd0506; end
		15:begin SOUND = 16'd0851; end
		16:begin SOUND = 16'd0638; end
		17:begin SOUND = 16'd0758; end
		18:begin SOUND = 16'd0638; end
		19:begin SOUND = 16'd0851; end
		20:begin SOUND = 16'd0638; end
		21:begin SOUND = 16'd1012; end
		22:begin SOUND = 16'd0851; end
		23:begin SOUND = 16'd1276; end
		24:begin SOUND = 16'd1012; end
		25:begin SOUND = 16'd1703; end
		26:begin SOUND = 16'd0851; end
		27:begin SOUND = 16'd1136; end
		28:begin SOUND = 16'd0851; end
		29:begin SOUND = 16'd1136; end
		30:begin SOUND = 16'd0568; end
		31:begin SOUND = 16'd1136; end
		32:begin SOUND = 16'd0589; end
		33:begin SOUND = 16'd0758; end
		34:begin SOUND = 16'd0568; end
		35:begin SOUND = 16'd0758; end
		36:begin SOUND = 16'd0379; end
		37:begin SOUND = 16'd0758; end
		38:begin SOUND = 16'd0379; end
		39:begin SOUND = 16'd0568; end
		40:begin SOUND = 16'd0379; end
		41:begin SOUND = 16'd0568; end
		42:begin SOUND = 16'd0284; end
		43:begin SOUND = 16'd0568; end
		44:begin	SOUND = 16'd0284; end
		45:begin	SOUND = 16'd0379; end
		46:begin SOUND = 16'd0284; end
		47:begin SOUND = 16'd0426; end
		48:begin SOUND = 16'd0213; end
		default: SOUND = 65535;
	endcase
end


endmodule
