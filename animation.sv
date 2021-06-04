// 
module Animation
#(parameter CLOCKDIV = 19, parameter SQSIZE = 50)
(
    output logic [10:0] x, y, 
    output logic colour, GameClock,
    input logic forceClear,
    input logic clk, rst,
	 input logic [7:0] xin, yin, titlex, titley,
	 input logic [9:0][7:0] ex, ey
);
    typedef enum { CLEAR, DRAWIN, DRAWLEFT, DRAWTOP, DRAWRIGHT, DRAWBOTTOM, FINISH, WAIT, XXX,
						DrawMarisa, DrawMarisa1, DrawMarisa2, DrawMarisa3, DrawMarisa4, DrawMarisa5, DrawMarisa6, DrawMarisa7, DrawMarisa8, DrawMarisa9, 
						DrawMarisa10, DrawMarisa11, DrawMarisa12, DrawMarisa13, DrawMarisa14, DrawMarisa15, DrawMarisa16, DrawMarisa17, DrawMarisa18, DrawMarisa19, 
						DrawMarisa20, DrawMarisa21, DrawMarisa22, DrawMarisa23, DrawMarisa24, DrawMarisa25, DrawMarisa26, DrawMarisa27, DrawMarisa28, DrawMarisa29, 
						DrawMarisa30, DrawMarisa31, DrawMarisa32, DrawMarisa33, DrawMarisa34,							//34 marisa
						danmaku11, danmaku12, danmaku13, danmaku14, danmaku51, danmaku52, danmaku53, danmaku54, 
						danmaku21, danmaku22, danmaku23, danmaku24, danmaku61, danmaku62, danmaku63, danmaku64,
						danmaku31, danmaku32, danmaku33, danmaku34, danmaku71, danmaku72, danmaku73, danmaku74,
						danmaku41, danmaku42, danmaku43, danmaku44, danmaku81, danmaku82, danmaku83, danmaku84,	//32 danmaku
						rom1, rom2, rom3, rom4, rom5, rom6, rom7, rom8, rom9, rom10, rom11, rom12, rom13, rom14,	//14 rom
						fpga1, fpga2, fpga3, fpga4, fpga5, fpga6, fpga7, fpga8, fpga9, fpga10, 
						fpga11, fpga12, fpga13, fpga14, fpga15, fpga16, fpga17, fpga18, fpga19, fpga20, fpga21,	//21 fpga (enemy)
						uw1, uw2, uw3, uw4, uw5, uw6, uw7, uw8, uw9, uw10, 
						uw11, uw12, uw13, uw14, uw15, uw16, uw17, uw18, uw19, uw20, 
						uw21, uw22, uw23, uw24, uw25, uw26, uw27, uw28, uw29, uw30, 
						uw31, uw32, uw33, uw34, uw35, uw36, uw37, uw38, uw39, uw40, uw41, uw42,							//42 uw
						name1, name2, name3, name4, name5, name6, name7, name8, name9, name10, 
						name11, name12, name13, name14, name15, name16, name17, name18, name19, name20,
						name21, name22, name23, name24, name25, name26, name27, name28, name29, name30,
						name31, name32, name33, name34, 																				//34 name
						kiri1, kiri2, kiri3, kiri4, kiri5, kiri6, kiri7, kiri8, kiri9, kiri10, 
						kiri11, kiri12, kiri13, kiri14, kiri15, kiri16, kiri17, kiri18, kiri19, kiri20, 
						kiri21, kiri22, kiri23, kiri24, kiri25, kiri26, kiri27, kiri28, kiri29, kiri30, 
						kiri31, kiri32, kiri33, kiri34, kiri35, kiri36, kiri37, kiri38, kiri39, kiri40, 
						kiri41, kiri42, kiri43, kiri44, kiri45, kiri46, kiri47, kiri48, kiri49, kiri50, 
						kiri51, kiri52, kiri53, kiri54, kiri55, kiri56, kiri57, kiri58, kiri59, kiri60, 
						kiri61, kiri62, kiri63, kiri64, kiri65, 																				//65 kirisame marisa 
						f1, f2, f3, f4, f5, f6, f7, f8, f9, f10,
						f11, f12, f13, f14, f15, f16, f17, f18, f19, f20,
						f21, f22, f23, f24, f25, f26, f27, f28, f29, f30,
						f31, f32, f33, f34, f35, f36, f37, f38, f39, f40,
						f41, f42, f43, f44, f45, f46, f47, 																			//47 fpga (title)
						ad1, ad2, ad3, ad4, ad5, ad6, ad7, ad8, ad9, ad10,
						ad11, ad12, ad13, ad14, ad15, ad16, ad17, ad18, ad19, ad20,
						ad21, ad22, ad23, ad24, ad25, ad26, ad27, ad28, ad29, ad30,
						ad31, ad32, ad33, ad34, ad35 																					//35 adventure
							} AniState;
    AniState Present, Next;

    localparam HALFSQ = SQSIZE / 2;

    logic [10:0] x0, y0, x1, y1; // the start and end points of the line being drawn
	 logic [$clog2(SQSIZE * 4)-1:0] InternalEndpoint; // Where along the square perimeter the spinning line currently ends
    logic [CLOCKDIV-1:0] FrameClock; // Clock divider to have frames drawn at a reasonable rate
    logic nextFrame, done, start, clear;
    logic movingUp, movingLeft; // Whether the square is currently moving up/left, or down/right.
    logic ColourOut; // The colour to ask the VGA driver to draw


    line_drawer2 lines(.x, .y, .done, .colour(ColourOut), .x0, .y0, .x1, .y1, .start, .clear, .clk, .reset(rst));
	 	 
	 always_ff @(posedge clk) // State register
        if(rst) Present <= DRAWIN;
        else Present <= Next;
    
    always_comb // Next state
    begin
        Next = XXX;
        case(Present)
            CLEAR: if(done && ~forceClear) Next = DRAWIN;
                   else Next = CLEAR; // @LB
            DRAWIN: if(done) Next = DRAWLEFT;
                    else Next = DRAWIN; // @LB
            DRAWLEFT: if(done) Next = DRAWTOP;
                      else Next = DRAWLEFT; // @LB
            DRAWTOP: if(done) Next = DRAWRIGHT;
                     else Next = DRAWTOP; // @LB
            DRAWRIGHT: if(done) Next = DRAWBOTTOM;
                       else Next = DRAWRIGHT; // @LB
            DRAWBOTTOM: if(done) Next = DrawMarisa;
                        else Next = DRAWBOTTOM; // @LB
				DrawMarisa: if(done) Next = DrawMarisa1;
								else Next = DrawMarisa;
				DrawMarisa1: if(done) Next = DrawMarisa2;
								else Next = DrawMarisa1;
				DrawMarisa2: if(done) Next = DrawMarisa3;
								else Next = DrawMarisa2;
				DrawMarisa3: if(done) Next = DrawMarisa4;
								else Next = DrawMarisa3;
				DrawMarisa4: if(done) Next = DrawMarisa5;
								else Next = DrawMarisa4;
				DrawMarisa5: if(done) Next = DrawMarisa6;
								else Next = DrawMarisa5;
				DrawMarisa6: if(done) Next = DrawMarisa7;
								else Next = DrawMarisa6;
				DrawMarisa7: if(done) Next = DrawMarisa8;
								else Next = DrawMarisa7;
				DrawMarisa8: if(done) Next = DrawMarisa9;
								else Next = DrawMarisa8;
				DrawMarisa9: if(done) Next = DrawMarisa10;
								else Next = DrawMarisa9;
				DrawMarisa10: if(done) Next = DrawMarisa11;
								else Next = DrawMarisa10;
				DrawMarisa11: if(done) Next = DrawMarisa12;
								else Next = DrawMarisa11;
				DrawMarisa12: if(done) Next = DrawMarisa13;
								else Next = DrawMarisa12;
				DrawMarisa13: if(done) Next = DrawMarisa14;
								else Next = DrawMarisa13;
				DrawMarisa14: if(done) Next = DrawMarisa15;
								else Next = DrawMarisa14;
				DrawMarisa15: if(done) Next = DrawMarisa16;
								else Next = DrawMarisa15;
				DrawMarisa16: if(done) Next = DrawMarisa17;
								else Next = DrawMarisa16;
				DrawMarisa17: if(done) Next = DrawMarisa18;
								else Next = DrawMarisa17;
				DrawMarisa18: if(done) Next = DrawMarisa19;
								else Next = DrawMarisa18;
				DrawMarisa19: if(done) Next = DrawMarisa20;
								else Next = DrawMarisa19;
				DrawMarisa20: if(done) Next = DrawMarisa21;
								else Next = DrawMarisa20;
				DrawMarisa21: if(done) Next = DrawMarisa22;
								else Next = DrawMarisa21;
				DrawMarisa22: if(done) Next = DrawMarisa23;
								else Next = DrawMarisa22;
				DrawMarisa23: if(done) Next = DrawMarisa24;
								else Next = DrawMarisa23;
				DrawMarisa24: if(done) Next = DrawMarisa25;
								else Next = DrawMarisa24;
				DrawMarisa25: if(done) Next = DrawMarisa26;
								else Next = DrawMarisa25;
				DrawMarisa26: if(done) Next = DrawMarisa27;
								else Next = DrawMarisa26;
				DrawMarisa27: if(done) Next = DrawMarisa28;
								else Next = DrawMarisa27;
				DrawMarisa28: if(done) Next = DrawMarisa29;
								else Next = DrawMarisa28;
				DrawMarisa29: if(done) Next = DrawMarisa30;
								else Next = DrawMarisa29;
				DrawMarisa30: if(done) Next = DrawMarisa31;
								else Next = DrawMarisa30;
				DrawMarisa31: if(done) Next = DrawMarisa32;
								else Next = DrawMarisa31;
				DrawMarisa32: if(done) Next = DrawMarisa33;
								else Next = DrawMarisa32;
				DrawMarisa33: if(done) Next = DrawMarisa34;
								else Next = DrawMarisa33;
				DrawMarisa34: if(done) Next = danmaku11;
								else Next = DrawMarisa34;
								
				danmaku11: if(done) Next = danmaku12;
								else Next = danmaku11;
				danmaku12: if(done) Next = danmaku13;
								else Next = danmaku12;
				danmaku13: if(done) Next = danmaku14;
								else Next = danmaku13;
				danmaku14: if(done) Next = danmaku21;
								else Next = danmaku14;
				danmaku21: if(done) Next = danmaku22;
								else Next = danmaku21;
				danmaku22: if(done) Next = danmaku23;
								else Next = danmaku22;
				danmaku23: if(done) Next = danmaku24;
								else Next = danmaku23;
				danmaku24: if(done) Next = danmaku31;
								else Next = danmaku24;
				danmaku31: if(done) Next = danmaku32;
								else Next = danmaku31;
				danmaku32: if(done) Next = danmaku33;
								else Next = danmaku32;
				danmaku33: if(done) Next = danmaku34;
								else Next = danmaku33;
				danmaku34: if(done) Next = danmaku41;
								else Next = danmaku34;
				danmaku41: if(done) Next = danmaku42;
								else Next = danmaku41;
				danmaku42: if(done) Next = danmaku43;
								else Next = danmaku42;
				danmaku43: if(done) Next = danmaku44;
								else Next = danmaku43;
				danmaku44: if(done) Next = danmaku51;
								else Next = danmaku44;
				danmaku51: if(done) Next = danmaku52;
								else Next = danmaku51;
				danmaku52: if(done) Next = danmaku53;
								else Next = danmaku52;
				danmaku53: if(done) Next = danmaku54;
								else Next = danmaku53;
				danmaku54: if(done) Next = danmaku61;
								else Next = danmaku54;
				danmaku61: if(done) Next = danmaku62;
								else Next = danmaku61;
				danmaku62: if(done) Next = danmaku63;
								else Next = danmaku62;
				danmaku63: if(done) Next = danmaku64;
								else Next = danmaku63;
				danmaku64: if(done) Next = danmaku71;
								else Next = danmaku64;
				danmaku71: if(done) Next = danmaku72;
								else Next = danmaku71;
				danmaku72: if(done) Next = danmaku73;
								else Next = danmaku72;
				danmaku73: if(done) Next = danmaku74;
								else Next = danmaku73;
				danmaku74: if(done) Next = danmaku81;
								else Next = danmaku74;
				danmaku81: if(done) Next = danmaku82;
								else Next = danmaku81;
				danmaku82: if(done) Next = danmaku83;
								else Next = danmaku82;
				danmaku83: if(done) Next = danmaku84;
								else Next = danmaku83;
				danmaku84: if(done) Next = rom1;
								else Next = danmaku84;
				
				rom1: if(done) Next = rom2;
								else Next = rom1;
				rom2: if(done) Next = rom3;
								else Next = rom2;
				rom3: if(done) Next = rom4;
								else Next = rom3;
				rom4: if(done) Next = rom5;
								else Next = rom4;
				rom5: if(done) Next = rom6;
								else Next = rom5;
				rom6: if(done) Next = rom7;
								else Next = rom6;
				rom7: if(done) Next = rom8;
								else Next = rom7;
				rom8: if(done) Next = rom9;
								else Next = rom8;
				rom9: if(done) Next = rom10;
								else Next = rom9;
				rom10: if(done) Next = rom11;
								else Next = rom10;
				rom11: if(done) Next = rom12;
								else Next = rom11;
				rom12: if(done) Next = rom13;
								else Next = rom12;
				rom13: if(done) Next = rom14;
								else Next = rom13;
				rom14: if(done) Next = fpga1;
								else Next = rom14;				
				
				fpga1: if(done) Next = fpga2;
								else Next = fpga1;
				fpga2: if(done) Next = fpga3;
								else Next = fpga2;
				fpga3: if(done) Next = fpga4;
								else Next = fpga3;
				fpga4: if(done) Next = fpga5;
								else Next = fpga4;
				fpga5: if(done) Next = fpga6;
								else Next = fpga5;
				fpga6: if(done) Next = fpga7;
								else Next = fpga6;
				fpga7: if(done) Next = fpga8;
								else Next = fpga7;
				fpga8: if(done) Next = fpga9;
								else Next = fpga8;
				fpga9: if(done) Next = fpga10;
								else Next = fpga9;
				fpga10: if(done) Next = fpga11;
								else Next = fpga10;
				fpga11: if(done) Next = fpga12;
								else Next = fpga11;
				fpga12: if(done) Next = fpga13;
								else Next = fpga12;
				fpga13: if(done) Next = fpga14;
								else Next = fpga13;
				fpga14: if(done) Next = fpga15;
								else Next = fpga14;
				fpga15: if(done) Next = fpga16;
								else Next = fpga15;
				fpga16: if(done) Next = fpga17;
								else Next = fpga16;
				fpga17: if(done) Next = fpga18;
								else Next = fpga17;
				fpga18: if(done) Next = fpga19;
								else Next = fpga18;
				fpga19: if(done) Next = fpga20;
								else Next = fpga19;
				fpga20: if(done) Next = fpga21;
								else Next = fpga20;
				fpga21: if(done) Next = uw1;
								else Next = fpga21;
				
				uw1: if(done) Next = uw2;
								else Next = uw1;
				uw2: if(done) Next = uw3;
								else Next = uw2;
				uw3: if(done) Next = uw4;
								else Next = uw3;
				uw4: if(done) Next = uw5;
								else Next = uw4;
				uw5: if(done) Next = uw6;
								else Next = uw5;
				uw6: if(done) Next = uw7;
								else Next = uw6;
				uw7: if(done) Next = uw8;
								else Next = uw7;
				uw8: if(done) Next = uw9;
								else Next = uw8;
				uw9: if(done) Next = uw10;
								else Next = uw9;
				uw10: if(done) Next = uw11;
								else Next = uw10;
				uw11: if(done) Next = uw12;
								else Next = uw11;
				uw12: if(done) Next = uw13;
								else Next = uw12;
				uw13: if(done) Next = uw14;
								else Next = uw13;
				uw14: if(done) Next = uw15;
								else Next = uw14;
				uw15: if(done) Next = uw16;
								else Next = uw15;
				uw16: if(done) Next = uw17;
								else Next = uw16;
				uw17: if(done) Next = uw18;
								else Next = uw17;
				uw18: if(done) Next = uw19;
								else Next = uw18;
				uw19: if(done) Next = uw20;
								else Next = uw19;
				uw20: if(done) Next = uw21;
								else Next = uw20;
				uw21: if(done) Next = uw22;
								else Next = uw21;
				uw22: if(done) Next = uw23;
								else Next = uw22;
				uw23: if(done) Next = uw24;
								else Next = uw23;
				uw24: if(done) Next = uw25;
								else Next = uw24;
				uw25: if(done) Next = uw26;
								else Next = uw25;
				uw26: if(done) Next = uw27;
								else Next = uw26;
				uw27: if(done) Next = uw28;
								else Next = uw27;
				uw28: if(done) Next = uw29;
								else Next = uw28;
				uw29: if(done) Next = uw30;
								else Next = uw29;
				uw30: if(done) Next = uw31;
								else Next = uw30;
				uw31: if(done) Next = uw32;
								else Next = uw31;
				uw32: if(done) Next = uw33;
								else Next = uw32;
				uw33: if(done) Next = uw34;
								else Next = uw33;
				uw34: if(done) Next = uw35;
								else Next = uw34;
				uw35: if(done) Next = uw36;
								else Next = uw35;
				uw36: if(done) Next = uw37;
								else Next = uw36;
				uw37: if(done) Next = uw38;
								else Next = uw37;
				uw38: if(done) Next = uw39;
								else Next = uw38;
				uw39: if(done) Next = uw40;
								else Next = uw39;
				uw40: if(done) Next = uw41;
								else Next = uw40;
				uw41: if(done) Next = uw42;
								else Next = uw41;
				uw42: if(done) Next = name1;
								else Next = uw42;
								
				name1: if(done) Next = name2;
								else Next = name1;
				name2: if(done) Next = name3;
								else Next = name2;
				name3: if(done) Next = name4;
								else Next = name3;
				name4: if(done) Next = name5;
								else Next = name4;
				name5: if(done) Next = name6;
								else Next = name5;
				name6: if(done) Next = name7;
								else Next = name6;
				name7: if(done) Next = name8;
								else Next = name7;
				name8: if(done) Next = name9;
								else Next = name8;
				name9: if(done) Next = name10;
								else Next = name9;
				name10: if(done) Next = name11;
								else Next = name10;
				name11: if(done) Next = name12;
								else Next = name11;
				name12: if(done) Next = name13;
								else Next = name12;
				name13: if(done) Next = name14;
								else Next = name13;
				name14: if(done) Next = name15;
								else Next = name14;
				name15: if(done) Next = name16;
								else Next = name15;
				name16: if(done) Next = name17;
								else Next = name16;
				name17: if(done) Next = name18;
								else Next = name17;
				name18: if(done) Next = name19;
								else Next = name18;
				name19: if(done) Next = name20;
								else Next = name19;
				name20: if(done) Next = name21;
								else Next = name20;
				name21: if(done) Next = name22;
								else Next = name21;
				name22: if(done) Next = name23;
								else Next = name22;
				name23: if(done) Next = name24;
								else Next = name23;
				name24: if(done) Next = name25;
								else Next = name24;
				name25: if(done) Next = name26;
								else Next = name25;
				name26: if(done) Next = name27;
								else Next = name26;
				name27: if(done) Next = name28;
								else Next = name27;
				name28: if(done) Next = name29;
								else Next = name28;
				name29: if(done) Next = name30;
								else Next = name29;
				name30: if(done) Next = name31;
								else Next = name30;
				name31: if(done) Next = name32;
								else Next = name31;
				name32: if(done) Next = name33;
								else Next = name32;
				name33: if(done) Next = name34;
								else Next = name33;
				name34: if(done) Next = kiri1;
								else Next = name34;
				
				kiri1: if(done) Next = kiri2;
								else Next = kiri1;
				kiri2: if(done) Next = kiri3;
								else Next = kiri2;
				kiri3: if(done) Next = kiri4;
								else Next = kiri3;
				kiri4: if(done) Next = kiri5;
								else Next = kiri4;
				kiri5: if(done) Next = kiri6;
								else Next = kiri5;
				kiri6: if(done) Next = kiri7;
								else Next = kiri6;
				kiri7: if(done) Next = kiri8;
								else Next = kiri7;
				kiri8: if(done) Next = kiri9;
								else Next = kiri8;
				kiri9: if(done) Next = kiri10;
								else Next = kiri9;
				kiri10: if(done) Next = kiri11;
								else Next = kiri10;
				kiri11: if(done) Next = kiri12;
								else Next = kiri11;
				kiri12: if(done) Next = kiri13;
								else Next = kiri12;
				kiri13: if(done) Next = kiri14;
								else Next = kiri13;
				kiri14: if(done) Next = kiri15;
								else Next = kiri14;
				kiri15: if(done) Next = kiri16;
								else Next = kiri15;
				kiri16: if(done) Next = kiri17;
								else Next = kiri16;
				kiri17: if(done) Next = kiri18;
								else Next = kiri17;
				kiri18: if(done) Next = kiri19;
								else Next = kiri18;
				kiri19: if(done) Next = kiri20;
								else Next = kiri19;
				kiri20: if(done) Next = kiri21;
								else Next = kiri20;
				kiri21: if(done) Next = kiri22;
								else Next = kiri21;
				kiri22: if(done) Next = kiri23;
								else Next = kiri22;
				kiri23: if(done) Next = kiri24;
								else Next = kiri23;
				kiri24: if(done) Next = kiri25;
								else Next = kiri24;
				kiri25: if(done) Next = kiri26;
								else Next = kiri25;
				kiri26: if(done) Next = kiri27;
								else Next = kiri26;
				kiri27: if(done) Next = kiri28;
								else Next = kiri27;
				kiri28: if(done) Next = kiri29;
								else Next = kiri28;
				kiri29: if(done) Next = kiri30;
								else Next = kiri29;
				kiri30: if(done) Next = kiri31;
								else Next = kiri30;
				kiri31: if(done) Next = kiri32;
								else Next = kiri31;
				kiri32: if(done) Next = kiri33;
								else Next = kiri32;
				kiri33: if(done) Next = kiri34;
								else Next = kiri33;
				kiri34: if(done) Next = kiri35;
								else Next = kiri34;
				kiri35: if(done) Next = kiri36;
								else Next = kiri35;
				kiri36: if(done) Next = kiri37;
								else Next = kiri36;
				kiri37: if(done) Next = kiri38;
								else Next = kiri37;
				kiri38: if(done) Next = kiri39;
								else Next = kiri38;
				kiri39: if(done) Next = kiri40;
								else Next = kiri39;
				kiri40: if(done) Next = kiri41;
								else Next = kiri40;
				kiri41: if(done) Next = kiri42;
								else Next = kiri41;
				kiri42: if(done) Next = kiri43;
								else Next = kiri42;
				kiri43: if(done) Next = kiri44;
								else Next = kiri43;
				kiri44: if(done) Next = kiri45;
								else Next = kiri44;
				kiri45: if(done) Next = kiri46;
								else Next = kiri45;
				kiri46: if(done) Next = kiri47;
								else Next = kiri46;
				kiri47: if(done) Next = kiri48;
								else Next = kiri47;
				kiri48: if(done) Next = kiri49;
								else Next = kiri48;
				kiri49: if(done) Next = kiri50;
								else Next = kiri49;
				kiri50: if(done) Next = kiri51;
								else Next = kiri50;
				kiri51: if(done) Next = kiri52;
								else Next = kiri51;
				kiri52: if(done) Next = kiri53;
								else Next = kiri52;
				kiri53: if(done) Next = kiri54;
								else Next = kiri53;
				kiri54: if(done) Next = kiri55;
								else Next = kiri54;
				kiri55: if(done) Next = kiri56;
								else Next = kiri55;
				kiri56: if(done) Next = kiri57;
								else Next = kiri56;
				kiri57: if(done) Next = kiri58;
								else Next = kiri57;
				kiri58: if(done) Next = kiri59;
								else Next = kiri58;
				kiri59: if(done) Next = kiri60;
								else Next = kiri59;
				kiri60: if(done) Next = kiri61;
								else Next = kiri60;
				kiri61: if(done) Next = kiri62;
								else Next = kiri61;
				kiri62: if(done) Next = kiri63;
								else Next = kiri62;
				kiri63: if(done) Next = kiri64;
								else Next = kiri63;
				kiri64: if(done) Next = kiri65;
								else Next = kiri64;
				kiri65: if(done) Next = f1;
								else Next = kiri65;
				
				f1: if(done) Next = f2;
								else Next = f1;
				f2: if(done) Next = f3;
								else Next = f2;
				f3: if(done) Next = f4;
								else Next = f3;
				f4: if(done) Next = f5;
								else Next = f4;
				f5: if(done) Next = f6;
								else Next = f5;
				f6: if(done) Next = f7;
								else Next = f6;
				f7: if(done) Next = f8;
								else Next = f7;
				f8: if(done) Next = f9;
								else Next = f8;
				f9: if(done) Next = f10;
								else Next = f9;
				f10: if(done) Next = f11;
								else Next = f10;
				f11: if(done) Next = f12;
								else Next = f11;
				f12: if(done) Next = f13;
								else Next = f12;
				f13: if(done) Next = f14;
								else Next = f13;
				f14: if(done) Next = f15;
								else Next = f14;
				f15: if(done) Next = f16;
								else Next = f15;
				f16: if(done) Next = f17;
								else Next = f16;
				f17: if(done) Next = f18;
								else Next = f17;
				f18: if(done) Next = f19;
								else Next = f18;
				f19: if(done) Next = f20;
								else Next = f19;
				f20: if(done) Next = f21;
								else Next = f20;
				f21: if(done) Next = f22;
								else Next = f21;
				f22: if(done) Next = f23;
								else Next = f22;
				f23: if(done) Next = f24;
								else Next = f23;
				f24: if(done) Next = f25;
								else Next = f24;
				f25: if(done) Next = f26;
								else Next = f25;
				f26: if(done) Next = f27;
								else Next = f26;
				f27: if(done) Next = f28;
								else Next = f27;
				f28: if(done) Next = f29;
								else Next = f28;
				f29: if(done) Next = f30;
								else Next = f29;
				f30: if(done) Next = f31;
								else Next = f30;
				f31: if(done) Next = f32;
								else Next = f31;
				f32: if(done) Next = f33;
								else Next = f32;
				f33: if(done) Next = f34;
								else Next = f33;
				f34: if(done) Next = f35;
								else Next = f34;
				f35: if(done) Next = f36;
								else Next = f35;
				f36: if(done) Next = f37;
								else Next = f36;
				f37: if(done) Next = f38;
								else Next = f37;
				f38: if(done) Next = f39;
								else Next = f38;
				f39: if(done) Next = f40;
								else Next = f39;
				f40: if(done) Next = f41;
								else Next = f40;
				f41: if(done) Next = f42;
								else Next = f41;
				f42: if(done) Next = f43;
								else Next = f42;
				f43: if(done) Next = f44;
								else Next = f43;
				f44: if(done) Next = f45;
								else Next = f44;
				f45: if(done) Next = f46;
								else Next = f45;
				f46: if(done) Next = f47;
								else Next = f46;
				f47: if(done) Next = ad1;
								else Next = f47;

				ad1: if(done) Next = ad2;
								else Next = ad1;
				ad2: if(done) Next = ad3;
								else Next = ad2;
				ad3: if(done) Next = ad4;
								else Next = ad3;
				ad4: if(done) Next = ad5;
								else Next = ad4;
				ad5: if(done) Next = ad6;
								else Next = ad5;		
				ad6: if(done) Next = ad7;
								else Next = ad6;
				ad7: if(done) Next = ad8;
								else Next = ad7;
				ad8: if(done) Next = ad9;
								else Next = ad8;
				ad9: if(done) Next = ad10;
								else Next = ad9;
				ad10: if(done) Next = ad11;
								else Next = ad10;	
				ad11: if(done) Next = ad12;
								else Next = ad11;
				ad12: if(done) Next = ad13;
								else Next = ad12;
				ad13: if(done) Next = ad14;
								else Next = ad13;
				ad14: if(done) Next = ad15;
								else Next = ad14;
				ad15: if(done) Next = ad16;
								else Next = ad15;	
				ad16: if(done) Next = ad17;
								else Next = ad16;
				ad17: if(done) Next = ad18;
								else Next = ad17;
				ad18: if(done) Next = ad19;
								else Next = ad18;
				ad19: if(done) Next = ad20;
								else Next = ad19;
				ad20: if(done) Next = ad21;
								else Next = ad20;	
				ad21: if(done) Next = ad22;
								else Next = ad21;
				ad22: if(done) Next = ad23;
								else Next = ad22;
				ad23: if(done) Next = ad24;
								else Next = ad23;
				ad24: if(done) Next = ad25;
								else Next = ad24;
				ad25: if(done) Next = ad26;
								else Next = ad25;	
				ad26: if(done) Next = ad27;
								else Next = ad26;
				ad27: if(done) Next = ad28;
								else Next = ad27;
				ad28: if(done) Next = ad29;
								else Next = ad28;
				ad29: if(done) Next = ad30;
								else Next = ad29;
				ad30: if(done) Next = ad31;
								else Next = ad30;	
				ad31: if(done) Next = ad32;
								else Next = ad31;
				ad32: if(done) Next = ad33;
								else Next = ad32;
				ad33: if(done) Next = ad34;
								else Next = ad33;
				ad34: if(done) Next = ad35;
								else Next = ad34;
				ad35: if(done) Next = FINISH;
								else Next = ad35;				
					
            FINISH: Next = WAIT;
            WAIT: if(nextFrame) Next = CLEAR;
                  else Next = WAIT; // @LB
            default: Next = XXX;
        endcase
    end

    always_comb // Outputs & combinational state
    begin
		  GameClock = nextFrame;
        colour = ColourOut & (x < 320 && y < 240); // Fixes strange artifacts outside drawing region
        clear = Present == CLEAR;
        start = (Present == CLEAR || Present == DRAWIN || Present == DRAWLEFT || Present == DRAWTOP || Present == DRAWRIGHT || Present == DRAWBOTTOM
					  || Present == DrawMarisa || Present == DrawMarisa1 || Present == DrawMarisa2 || Present == DrawMarisa3 || Present == DrawMarisa4 || Present == DrawMarisa5 || Present == DrawMarisa6 || Present == DrawMarisa7 || Present == DrawMarisa8 || Present == DrawMarisa9 
					  || Present == DrawMarisa10 || Present == DrawMarisa11 || Present == DrawMarisa12 || Present == DrawMarisa13|| Present == DrawMarisa14 || Present == DrawMarisa15 || Present == DrawMarisa16 || Present == DrawMarisa17 || Present == DrawMarisa18 || Present == DrawMarisa19 
					  || Present == DrawMarisa20 || Present == DrawMarisa21 || Present == DrawMarisa22 || Present == DrawMarisa23|| Present == DrawMarisa24 || Present == DrawMarisa25 || Present == DrawMarisa26 || Present == DrawMarisa27 || Present == DrawMarisa28 || Present == DrawMarisa29 
					  || Present == DrawMarisa30 || Present == DrawMarisa31 || Present == DrawMarisa32 || Present == DrawMarisa33|| Present == DrawMarisa34 
					  || Present == danmaku11 || Present == danmaku12 || Present == danmaku13 || Present == danmaku14 || Present == danmaku21 || Present == danmaku22 || Present == danmaku23 || Present == danmaku24 || Present == danmaku31 || Present == danmaku32 
					  || Present == danmaku33 || Present == danmaku34 || Present == danmaku41 || Present == danmaku42 || Present == danmaku43 || Present == danmaku44 || Present == danmaku51 || Present == danmaku52 || Present == danmaku53 || Present == danmaku54 
					  || Present == danmaku61 || Present == danmaku62 || Present == danmaku63 || Present == danmaku64 || Present == danmaku71 || Present == danmaku72 || Present == danmaku73 || Present == danmaku74 || Present == danmaku81 || Present == danmaku82 
					  || Present == danmaku83 || Present == danmaku84
					  || Present == rom1 || Present == rom2 || Present == rom3 || Present == rom4 || Present == rom5 || Present == rom6 || Present == rom7 || Present == rom8 || Present == rom9 || Present == rom10 
					  || Present == rom11 || Present == rom12 || Present == rom13 || Present == rom14 
					  || Present == fpga1 || Present == fpga2 || Present == fpga3 || Present == fpga4 || Present == fpga5 || Present == fpga6 || Present == fpga7 || Present == fpga8 || Present == fpga9 || Present == fpga10 
					  || Present == fpga11 || Present == fpga12 || Present == fpga13 || Present == fpga14 || Present == fpga15 || Present == fpga16 || Present == fpga17 || Present == fpga18 || Present == fpga19 || Present == fpga20 || Present == fpga21 
					  || Present == uw1 || Present == uw2 || Present == uw3 || Present == uw4 || Present == uw5 || Present == uw6 || Present == uw7 || Present == uw8 || Present == uw9 || Present == uw10 
					  || Present == uw11 || Present == uw12 || Present == uw13 || Present == uw14 || Present == uw15 || Present == uw16 || Present == uw17 || Present == uw18 || Present == uw19 || Present == uw20 
					  || Present == uw21 || Present == uw22 || Present == uw23 || Present == uw24 || Present == uw25 || Present == uw26 || Present == uw27 || Present == uw28 || Present == uw29 || Present == uw30 
					  || Present == uw31 || Present == uw32 || Present == uw33 || Present == uw34 || Present == uw35 || Present == uw36 || Present == uw37 || Present == uw38 || Present == uw39 || Present == uw40 
					  || Present == uw41 || Present == uw42 
					  || Present == name1 || Present == name2 || Present == name3 || Present == name4 || Present == name5 || Present == name6 || Present == name7 || Present == name8 || Present == name9 || Present == name10 
					  || Present == name11 || Present == name12 || Present == name13 || Present == name14 || Present == name15 || Present == name16 || Present == name17 || Present == name18 || Present == name19 || Present == name20 
					  || Present == name21 || Present == name22 || Present == name23 || Present == name24 || Present == name25 || Present == name26 || Present == name27 || Present == name28 || Present == name29 || Present == name30 
					  || Present == name31 || Present == name32 || Present == name33 || Present == name34 
					  || Present == kiri1 || Present == kiri2 || Present == kiri3 || Present == kiri4 || Present == kiri5 || Present == kiri6 || Present == kiri7 || Present == kiri8 || Present == kiri9 || Present == kiri10  
					  || Present == kiri11 || Present == kiri12 || Present == kiri13 || Present == kiri14 || Present == kiri15 || Present == kiri16 || Present == kiri17 || Present == kiri18 || Present == kiri19 || Present == kiri20  
					  || Present == kiri21 || Present == kiri22 || Present == kiri23 || Present == kiri24 || Present == kiri25 || Present == kiri26 || Present == kiri27 || Present == kiri28 || Present == kiri29 || Present == kiri30  
					  || Present == kiri31 || Present == kiri32 || Present == kiri33 || Present == kiri34 || Present == kiri35 || Present == kiri36 || Present == kiri37 || Present == kiri38 || Present == kiri39 || Present == kiri40  
					  || Present == kiri41 || Present == kiri42 || Present == kiri43 || Present == kiri44 || Present == kiri45 || Present == kiri46 || Present == kiri47 || Present == kiri48 || Present == kiri49 || Present == kiri50  
					  || Present == kiri51 || Present == kiri52 || Present == kiri53 || Present == kiri54 || Present == kiri55 || Present == kiri56 || Present == kiri57 || Present == kiri58 || Present == kiri59 || Present == kiri60  
					  || Present == kiri61 || Present == kiri62 || Present == kiri63 || Present == kiri64 || Present == kiri65 
					  || Present == f1 || Present == f2 || Present == f3 || Present == f4 || Present == f5 || Present == f6 || Present == f7 || Present == f8 || Present == f9 || Present == f10
					  || Present == f11 || Present == f12 || Present == f13 || Present == f14 || Present == f15 || Present == f16 || Present == f17 || Present == f18 || Present == f19 || Present == f20
					  || Present == f21 || Present == f22 || Present == f23 || Present == f24 || Present == f25 || Present == f26 || Present == f27 || Present == f28 || Present == f29 || Present == f30
					  || Present == f31 || Present == f32 || Present == f33 || Present == f34 || Present == f35 || Present == f36 || Present == f37 || Present == f38 || Present == f39 || Present == f40
					  || Present == f41 || Present == f42 || Present == f43 || Present == f44 || Present == f45 || Present == f46 || Present == f47 
					  || Present == ad1 || Present == ad2 || Present == ad3 || Present == ad4 || Present == ad5 || Present == ad6 || Present == ad7 || Present == ad8 || Present == ad9 || Present == ad10 
					  || Present == ad11 || Present == ad12 || Present == ad13 || Present == ad14 || Present == ad15 || Present == ad16 || Present == ad17 || Present == ad18 || Present == ad19 || Present == ad20 
					  || Present == ad21 || Present == ad22 || Present == ad23 || Present == ad24 || Present == ad25 || Present == ad26 || Present == ad27 || Present == ad28 || Present == ad29 || Present == ad30 
					  || Present == ad31 || Present == ad32 || Present == ad33 || Present == ad34 || Present == ad35 
					  ) & ~done;
        nextFrame = FrameClock[CLOCKDIV-1];
        x0 = '0;
        x1 = '0;
        y0 = '0;
        y1 = '0;
        case(Present)
            DRAWIN:
            begin
				x0 = 200;
				y0 = 0;
				x1 = 200;
				y1 = 239;
            end
            DRAWLEFT:
            begin
				x0 = 0;
				x1 = 0;
				y0 = 0;
				y1 = 239;
            end
            DRAWRIGHT:
            begin
				x0 = 319;
				x1 = 319;
				y0 = 0;
				y1 = 239;
            end
            DRAWTOP:
            begin
				x0 = 0;
				x1 = 319;
				y0 = 0;
				y1 = 0;
            end
            DRAWBOTTOM:
            begin
				x0 = 0;
				x1 = 319;
				y0 = 239;
				y1 = 239;
            end
				DrawMarisa: //hat
				begin
					x0 = xin;
					x1 = xin;
					y0 = yin;
					y1 = yin;
				end
				DrawMarisa1:
				begin
					x0 = xin;
					x1 = xin-2;
					y0 = yin-16;
					y1 = yin-9;
				end
				DrawMarisa2:
				begin
					x0 = xin;
					x1 = xin+2;
					y0 = yin-16;
					y1 = yin-9;
				end
				DrawMarisa3:
				begin
					x0 = xin-1;
					x1 = xin+1;
					y0 = yin-8;
					y1 = yin-8;
				end
				DrawMarisa4:
				begin
					x0 = xin-2;
					x1 = xin-6;
					y0 = yin-12;
					y1 = yin-8;
				end
				DrawMarisa5:
				begin
					x0 = xin+2;
					x1 = xin+6;
					y0 = yin-12;
					y1 = yin-8;
				end
				DrawMarisa6:
				begin
					x0 = xin-6;
					x1 = xin-3;
					y0 = yin-8;
					y1 = yin-5;
				end
				DrawMarisa7:
				begin
					x0 = xin+6;
					x1 = xin+3;
					y0 = yin-8;
					y1 = yin-5;
				end
				DrawMarisa8:
				begin
					x0 = xin-3;
					x1 = xin+3;
					y0 = yin-5;
					y1 = yin-5;
				end
				DrawMarisa9://body
				begin
					x0 = xin-2;
					x1 = xin-5;
					y0 = yin-5;
					y1 = yin+1;
				end
				DrawMarisa10:
				begin
					x0 = xin+2;
					x1 = xin+5;
					y0 = yin-5;
					y1 = yin+1;
				end
				DrawMarisa11:
				begin
					x0 = xin;
					x1 = xin-4;
					y0 = yin-2;
					y1 = yin+2;
				end
				DrawMarisa12:
				begin
					x0 = xin;
					x1 = xin+4;
					y0 = yin-2;
					y1 = yin+2;
				end
				DrawMarisa13:
				begin
					x0 = xin-1;
					x1 = xin-5;
					y0 = yin+1;
					y1 = yin+9;
				end
				DrawMarisa14:
				begin
					x0 = xin+1;
					x1 = xin+5;
					y0 = yin+1;
					y1 = yin+9;
				end
				DrawMarisa15:
				begin
					x0 = xin-3;
					x1 = xin-2;
					y0 = yin+10;
					y1 = yin+11;
				end
				DrawMarisa16:
				begin
					x0 = xin+3;
					x1 = xin+2;
					y0 = yin+10;
					y1 = yin+11;
				end
				DrawMarisa17: //legs
				begin
					x0 = xin-1;
					x1 = xin-1;
					y0 = yin+10;
					y1 = yin+12;
				end
				DrawMarisa18:
				begin
					x0 = xin;
					x1 = xin;
					y0 = yin+10;
					y1 = yin+21;
				end
				DrawMarisa19:
				begin
					x0 = xin+1;
					x1 = xin+1;
					y0 = yin+10;
					y1 = yin+12;
				end
				DrawMarisa20:
				begin
					x0 = xin-2;
					x1 = xin-2;
					y0 = yin+11;
					y1 = yin+14;
				end
				DrawMarisa21:
				begin
					x0 = xin+2;
					x1 = xin+2;
					y0 = yin+11;
					y1 = yin+14;
				end
				DrawMarisa22:
				begin
					x0 = xin-3;
					x1 = xin-3;
					y0 = yin+13;
					y1 = yin+19;
				end
				DrawMarisa23:
				begin
					x0 = xin+3;
					x1 = xin+3;
					y0 = yin+13;
					y1 = yin+19;
				end
				DrawMarisa24:
				begin
					x0 = xin-4;
					x1 = xin-4;
					y0 = yin+19;
					y1 = yin+19;
				end
				DrawMarisa25:
				begin
					x0 = xin+4;
					x1 = xin+4;
					y0 = yin+19;
					y1 = yin+19;
				end
				DrawMarisa26:// tail
				begin
					x0 = xin-1;
					x1 = xin-1;
					y0 = yin+22;
					y1 = yin+23;
				end
				DrawMarisa27:
				begin
					x0 = xin+1;
					x1 = xin+1;
					y0 = yin+22;
					y1 = yin+23;
				end
				DrawMarisa28:
				begin
					x0 = xin-2;
					x1 = xin-2;
					y0 = yin+24;
					y1 = yin+28;
				end
				DrawMarisa29:
				begin
					x0 = xin+2;
					x1 = xin+2;
					y0 = yin+24;
					y1 = yin+28;
				end
				DrawMarisa30:
				begin
					x0 = xin;
					x1 = xin;
					y0 = yin+24;
					y1 = yin+29;
				end
				DrawMarisa31:
				begin
					x0 = xin-1;
					x1 = xin-1;
					y0 = yin+29;
					y1 = yin+31;
				end
				DrawMarisa32:
				begin
					x0 = xin-3;
					x1 = xin-3;
					y0 = yin+29;
					y1 = yin+30;
				end
				DrawMarisa33:
				begin
					x0 = xin+1;
					x1 = xin+1;
					y0 = yin+29;
					y1 = yin+30;
				end
				DrawMarisa34:
				begin
					x0 = xin+3;
					x1 = xin+3;
					y0 = yin+29;
					y1 = yin+30;
				end
				
				danmaku11:
				begin
					x0 = ex[1]-5;
					x1 = ex[1]-5;
					y0 = ey[1]-5;
					y1 = ey[1]+5;
				end
				danmaku12:
				begin
					x0 = ex[1]-5;
					x1 = ex[1]+5;
					y0 = ey[1]-5;
					y1 = ey[1]-5;
				end
				danmaku13:
				begin
					x0 = ex[1]+5;
					x1 = ex[1]-5;
					y0 = ey[1]+5;
					y1 = ey[1]+5;
				end
				danmaku14:
				begin
					x0 = ex[1]+5;
					x1 = ex[1]+5;
					y0 = ey[1]+5;
					y1 = ey[1]-5;
				end
				danmaku21:
				begin
					x0 = ex[2]-5;
					x1 = ex[2]-5;
					y0 = ey[2]-5;
					y1 = ey[2]+5;
				end
				danmaku22:
				begin
					x0 = ex[2]-5;
					x1 = ex[2]+5;
					y0 = ey[2]-5;
					y1 = ey[2]-5;
				end
				danmaku23:
				begin
					x0 = ex[2]+5;
					x1 = ex[2]-5;
					y0 = ey[2]+5;
					y1 = ey[2]+5;
				end
				danmaku24:
				begin
					x0 = ex[2]+5;
					x1 = ex[2]+5;
					y0 = ey[2]+5;
					y1 = ey[2]-5;
				end
				danmaku31:
				begin
					x0 = ex[3]-5;
					x1 = ex[3]-5;
					y0 = ey[3]-5;
					y1 = ey[3]+5;
				end
				danmaku32:
				begin
					x0 = ex[3]-5;
					x1 = ex[3]+5;
					y0 = ey[3]-5;
					y1 = ey[3]-5;
				end
				danmaku33:
				begin
					x0 = ex[3]+5;
					x1 = ex[3]-5;
					y0 = ey[3]+5;
					y1 = ey[3]+5;
				end
				danmaku34:
				begin
					x0 = ex[3]+5;
					x1 = ex[3]+5;
					y0 = ey[3]+5;
					y1 = ey[3]-5;
				end
				danmaku41:
				begin
					x0 = ex[4]-5;
					x1 = ex[4]-5;
					y0 = ey[4]-5;
					y1 = ey[4]+5;
				end
				danmaku42:
				begin
					x0 = ex[4]-5;
					x1 = ex[4]+5;
					y0 = ey[4]-5;
					y1 = ey[4]-5;
				end
				danmaku43:
				begin
					x0 = ex[4]+5;
					x1 = ex[4]-5;
					y0 = ey[4]+5;
					y1 = ey[4]+5;
				end
				danmaku44:
				begin
					x0 = ex[4]+5;
					x1 = ex[4]+5;
					y0 = ey[4]+5;
					y1 = ey[4]-5;
				end
				danmaku51:
				begin
					x0 = ex[5]-5;
					x1 = ex[5]-5;
					y0 = ey[5]-5;
					y1 = ey[5]+5;
				end
				danmaku52:
				begin
					x0 = ex[5]-5;
					x1 = ex[5]+5;
					y0 = ey[5]-5;
					y1 = ey[5]-5;
				end
				danmaku53:
				begin
					x0 = ex[5]+5;
					x1 = ex[5]-5;
					y0 = ey[5]+5;
					y1 = ey[5]+5;
				end
				danmaku54:
				begin
					x0 = ex[5]+5;
					x1 = ex[5]+5;
					y0 = ey[5]+5;
					y1 = ey[5]-5;
				end
				danmaku61:
				begin
					x0 = ex[6]-5;
					x1 = ex[6]-5;
					y0 = ey[6]-5;
					y1 = ey[6]+5;
				end
				danmaku62:
				begin
					x0 = ex[6]-5;
					x1 = ex[6]+5;
					y0 = ey[6]-5;
					y1 = ey[6]-5;
				end
				danmaku63:
				begin
					x0 = ex[6]+5;
					x1 = ex[6]-5;
					y0 = ey[6]+5;
					y1 = ey[6]+5;
				end
				danmaku64:
				begin
					x0 = ex[6]+5;
					x1 = ex[6]+5;
					y0 = ey[6]+5;
					y1 = ey[6]-5;
				end
				danmaku71:
				begin
					x0 = ex[7]-5;
					x1 = ex[7]-5;
					y0 = ey[7]-5;
					y1 = ey[7]+5;
				end
				danmaku72:
				begin
					x0 = ex[7]-5;
					x1 = ex[7]+5;
					y0 = ey[7]-5;
					y1 = ey[7]-5;
				end
				danmaku73:
				begin
					x0 = ex[7]+5;
					x1 = ex[7]-5;
					y0 = ey[7]+5;
					y1 = ey[7]+5;
				end
				danmaku74:
				begin
					x0 = ex[7]+5;
					x1 = ex[7]+5;
					y0 = ey[7]+5;
					y1 = ey[7]-5;
				end
				danmaku81:
				begin
					x0 = ex[8]-5;
					x1 = ex[8]-5;
					y0 = ey[8]-5;
					y1 = ey[8]+5;
				end
				danmaku82:
				begin
					x0 = ex[8]-5;
					x1 = ex[8]+5;
					y0 = ey[8]-5;
					y1 = ey[8]-5;
				end
				danmaku83:
				begin
					x0 = ex[8]+5;
					x1 = ex[8]-5;
					y0 = ey[8]+5;
					y1 = ey[8]+5;
				end
				danmaku84:
				begin
					x0 = ex[8]+5;
					x1 = ex[8]+5;
					y0 = ey[8]+5;
					y1 = ey[8]-5;
				end
				
				rom1:  
				begin
					x0 = ex[9];
					x1 = ex[9]+80;
					y0 = ey[9];
					y1 = ey[9];
				end
				rom2:
				begin
					x0 = ex[9];
					x1 = ex[9];
					y0 = ey[9];
					y1 = ey[9]+40;
				end
				rom3:
				begin
					x0 = ex[9]+80;
					x1 = ex[9]+80;
					y0 = ey[9]+40;
					y1 = ey[9];
				end
				rom4:
				begin
					x0 = ex[9]+80;
					x1 = ex[9];
					y0 = ey[9]+40;
					y1 = ey[9]+40;
				end
				rom5: //r
				begin
					x0 = ex[9]+10;
					x1 = ex[9]+10;
					y0 = ey[9]+10;
					y1 = ey[9]+30;
				end
				rom6:
				begin
					x0 = ex[9]+10;
					x1 = ex[9]+28;
					y0 = ey[9]+15;
					y1 = ey[9]+10;
				end
				rom7:  //o
				begin
					x0 = ex[9]+30;
					x1 = ex[9]+48;
					y0 = ey[9]+10;
					y1 = ey[9]+10;
				end
				rom8:
				begin
					x0 = ex[9]+30;
					x1 = ex[9]+30;
					y0 = ey[9]+10;
					y1 = ey[9]+30;
				end
				rom9:
				begin
					x0 = ex[9]+48;
					x1 = ex[9]+48;
					y0 = ey[9]+30;
					y1 = ey[9]+10;
				end
				rom10:
				begin
					x0 = ex[9]+48;
					x1 = ex[9]+30;
					y0 = ey[9]+30;
					y1 = ey[9]+30;
				end
				rom11: //m
				begin
					x0 = ex[9]+50;
					x1 = ex[9]+55;
					y0 = ey[9]+30;
					y1 = ey[9]+10;
				end
				rom12:
				begin
					x0 = ex[9]+55;
					x1 = ex[9]+60;
					y0 = ey[9]+10;
					y1 = ey[9]+30;
				end
				rom13:
				begin
					x0 = ex[9]+60;
					x1 = ex[9]+65;
					y0 = ey[9]+30;
					y1 = ey[9]+10;
				end
				rom14:
				begin
					x0 = ex[9]+65;
					x1 = ex[9]+70;
					y0 = ey[9]+10;
					y1 = ey[9]+30;
				end
				
				fpga1: 
				begin
					x0 = ex[0];
					x1 = ex[0]+70;
					y0 = ey[0];
					y1 = ey[0];
				end
				fpga2:
				begin
					x0 = ex[0];
					x1 = ex[0];
					y0 = ey[0];
					y1 = ey[0]+70;
				end
				fpga3:
				begin
					x0 = ex[0]+70;
					x1 = ex[0]+70;
					y0 = ey[0]+70;
					y1 = ey[0];
				end
				fpga4:
				begin
					x0 = ex[0]+70;
					x1 = ex[0];
					y0 = ey[0]+70;
					y1 = ey[0]+70;
				end
				fpga5: //F
				begin
					x0 = ex[0]+10;
					x1 = ex[0]+30;
					y0 = ey[0]+10;
					y1 = ey[0]+10;
				end
				fpga6:
				begin
					x0 = ex[0]+10;
					x1 = ex[0]+10;
					y0 = ey[0]+10;
					y1 = ey[0]+30;
				end
				fpga7:
				begin
					x0 = ex[0]+10;
					x1 = ex[0]+30;
					y0 = ey[0]+20;
					y1 = ey[0]+20;
				end
				fpga8: //p
				begin
					x0 = ex[0]+40;
					x1 = ex[0]+40;
					y0 = ey[0]+10;
					y1 = ey[0]+30;
				end
				fpga9:
				begin
					x0 = ex[0]+40;
					x1 = ex[0]+60;
					y0 = ey[0]+10;
					y1 = ey[0]+13;
				end
				fpga10:
				begin
					x0 = ex[0]+60;
					x1 = ex[0]+60;
					y0 = ey[0]+13;
					y1 = ey[0]+17;
				end
				fpga11:
				begin
					x0 = ex[0]+60;
					x1 = ex[0]+40;
					y0 = ey[0]+17;
					y1 = ey[0]+20;
				end
				fpga12: //G
				begin
					x0 = ex[0]+20+10;
					x1 = ex[0]+10+10;
					y0 = ey[0]+7+40;
					y1 = ey[0]+40;
				end
				fpga13:
				begin
					x0 = ex[0]+10+10;
					x1 = ex[0]+10;
					y0 = ey[0]+40;
					y1 = ey[0]+7+40;
				end
				fpga14:
				begin
					x0 = ex[0]+10;
					x1 = ex[0]+10;
					y0 = ey[0]+7+40;
					y1 = ey[0]+13+40;
				end
				fpga15:
				begin
					x0 = ex[0]+10;
					x1 = ex[0]+10+10;
					y0 = ey[0]+13+40;
					y1 = ey[0]+20+40;
				end
				fpga16:
				begin
					x0 = ex[0]+10+10;
					x1 = ex[0]+20+10;
					y0 = ey[0]+20+40;
					y1 = ey[0]+13+40;
				end
				fpga17:
				begin
					x0 = ex[0]+20+10;
					x1 = ex[0]+20+10;
					y0 = ey[0]+13+40;
					y1 = ey[0]+20+40;
				end
				fpga18:
				begin
					x0 = ex[0]+20+10;
					x1 = ex[0]+10+10;
					y0 = ey[0]+13+40;
					y1 = ey[0]+13+40;
				end
				fpga19: //A
				begin
					x0 = ex[0]+40;
					x1 = ex[0]+50;
					y0 = ey[0]+60;
					y1 = ey[0]+40;
				end
				fpga20:
				begin
					x0 = ex[0]+50;
					x1 = ex[0]+60;
					y0 = ey[0]+40;
					y1 = ey[0]+60;
				end
				fpga21:
				begin
					x0 = ex[0]+45;
					x1 = ex[0]+55;
					y0 = ey[0]+50;
					y1 = ey[0]+50;
				end
				
				uw1: //u
				begin 
					x0 = 230;
					x1 = 230;
					y0 = 40;
					y1 = 70;
				end
				uw2:
				begin
					x0 = 230;
					x1 = 240;
					y0 = 70;
					y1 = 80;
				end
				uw3:
				begin
					x0 = 240;
					x1 = 248;
					y0 = 80;
					y1 = 80;
				end
				uw4:
				begin
					x0 = 248;
					x1 = 258;
					y0 = 80;
					y1 = 70;
				end
				uw5:
				begin
					x0 = 258;
					x1 = 258;
					y0 = 70;
					y1 = 40;
				end
				uw6:  //w
				begin
					x0 = 262;
					x1 = 269;
					y0 = 40;
					y1 = 80;
				end
				uw7:
				begin
					x0 = 269;
					x1 = 276;
					y0 = 80;
					y1 = 40;
				end
				uw8:
				begin
					x0 = 276;
					x1 = 283;
					y0 = 40;
					y1 = 80;
				end
				uw9:
				begin
					x0 = 283;
					x1 = 290;
					y0 = 80;
					y1 = 40;
				end
				uw10: //E
				begin
					x0 = 217;
					x1 = 217;
					y0 = 90;
					y1 = 110;
				end
				uw11:
				begin
					x0 = 217;
					x1 = 228;
					y0 = 90;
					y1 = 90;
				end
				uw12:
				begin
					x0 = 217;
					x1 = 225;
					y0 = 100;
					y1 = 100;
				end
				uw13:
				begin
					x0 = 217;
					x1 = 228;
					y0 = 110;
					y1 = 110;
				end
				uw14: //C
				begin
					x0 = 232;
					x1 = 232;
					y0 = 90;
					y1 = 110;
				end
				uw15:
				begin
					x0 = 232;
					x1 = 243;
					y0 = 90;
					y1 = 90;
				end
				uw16:
				begin
					x0 = 232;
					x1 = 243;
					y0 = 110;
					y1 = 110;
				end
				uw17: //E
				begin
					x0 = 247;
					x1 = 247;
					y0 = 90;
					y1 = 110;
				end
				uw18:
				begin
					x0 = 247;
					x1 = 258;
					y0 = 90;
					y1 = 90;
				end
				uw19:
				begin
					x0 = 247;
					x1 = 258;
					y0 = 100;
					y1 = 100;
				end
				uw20:
				begin
					x0 = 247;
					x1 = 258;
					y0 = 110;
					y1 = 110;
				end
				uw21: //3
				begin
					x0 = 262;
					x1 = 273;
					y0 = 90;
					y1 = 90;
				end
				uw22:
				begin
					x0 = 262;
					x1 = 273;
					y0 = 100;
					y1 = 100;
				end
				uw23:
				begin
					x0 = 262;
					x1 = 273;
					y0 = 110;
					y1 = 110;
				end
				uw24:
				begin
					x0 = 273;
					x1 = 273;
					y0 = 90;
					y1 = 110;
				end
				uw25: //7
				begin
					x0 = 277;
					x1 = 288;
					y0 = 90;
					y1 = 90;
				end
				uw26:
				begin
					x0 = 288;
					x1 = 284;
					y0 = 90;
					y1 = 110;
				end
				uw27: //1
				begin
					x0 = 297;
					x1 = 297;
					y0 = 90;
					y1 = 110;
				end
				uw28: //2
				begin
					x0 = 232;
					x1 = 243;
					y0 = 120;
					y1 = 120;
				end
				uw29:
				begin
					x0 = 243;
					x1 = 243;
					y0 = 120;
					y1 = 130;
				end
				uw30:
				begin
					x0 = 243;
					x1 = 232;
					y0 = 130;
					y1 = 130;
				end
				uw31:
				begin
					x0 = 232;
					x1 = 232;
					y0 = 130;
					y1 = 140;
				end
				uw32:
				begin
					x0 = 232;
					x1 = 243;
					y0 = 140;
					y1 = 140;
				end
				uw33: //0
				begin
					x0 = 247;
					x1 = 258;
					y0 = 120;
					y1 = 120;
				end
				uw34:
				begin
					x0 = 258;
					x1 = 258;
					y0 = 120;
					y1 = 140;
				end
				uw35:
				begin
					x0 = 258;
					x1 = 247;
					y0 = 140;
					y1 = 140;
				end
				uw36:
				begin
					x0 = 247;
					x1 = 247;
					y0 = 140;
					y1 = 120;
				end
				uw37: //2
				begin
					x0 = 262;
					x1 = 273;
					y0 = 120;
					y1 = 120;
				end
				uw38:
				begin
					x0 = 273;
					x1 = 272;
					y0 = 120;
					y1 = 130;
				end
				uw39:
				begin
					x0 = 273;
					x1 = 262;
					y0 = 130;
					y1 = 130;
				end
				uw40:
				begin
					x0 = 262;
					x1 = 262;
					y0 = 130;
					y1 = 140;
				end
				uw41:
				begin
					x0 = 263;
					x1 = 273;
					y0 = 140;
					y1 = 140;
				end
				uw42: //1
				begin
					x0 = 282;
					x1 = 282;
					y0 = 120;
					y1 = 140;
				end
				
				name1: //Z
				begin
					x0 = 217;
					x1 = 228;
					y0 = 150;
					y1 = 150;
				end
				name2:
				begin
					x0 = 228;
					x1 = 217;
					y0 = 150;
					y1 = 170;
				end
				name3:
				begin
					x0 = 217;
					x1 = 228;
					y0 = 170;
					y1 = 170;
				end
				name4: //H
				begin
					x0 = 232;
					x1 = 232;
					y0 = 150;
					y1 = 170;
				end
				name5:
				begin
					x0 = 243;
					x1 = 243;
					y0 = 150;
					y1 = 170;
				end
				name6:
				begin
					x0 = 232;
					x1 = 243;
					y0 = 160;
					y1 = 160;
				end
				name7: //A
				begin
					x0 = 247;
					x1 = 252;
					y0 = 170;
					y1 = 150;
				end
				name8:
				begin
					x0 = 252;
					x1 = 258;
					y0 = 150;
					y1 = 170;
				end
				name9:
				begin
					x0 = 250;
					x1 = 255;
					y0 = 160;
					y1 = 160;
				end
				name10: //N
				begin
					x0 = 262;
					x1 = 262;
					y0 = 170;
					y1 = 150;
				end
				name11:
				begin
					x0 = 262;
					x1 = 273;
					y0 = 150;
					y1 = 170;
				end
				name12:
				begin
					x0 = 273;
					x1 = 273;
					y0 = 150;
					y1 = 170;
				end
				name13: //G
				begin
					x0 = 288;
					x1 = 282;
					y0 = 157;
					y1 = 150;
				end
				name14:
				begin
					x0 = 282;
					x1 = 277;
					y0 = 150;
					y1 = 157;
				end
				name15:
				begin
					x0 = 277;
					x1 = 277;
					y0 = 157;
					y1 = 163;
				end
				name16:
				begin
					x0 = 277;
					x1 = 282;
					y0 = 163;
					y1 = 170;
				end
				name17:
				begin
					x0 = 282;
					x1 = 288;
					y0 = 170;
					y1 = 163;
				end
				name18:
				begin
					x0 = 288;
					x1 = 282;
					y0 = 163;
					y1 = 163;
				end
				name19:
				begin
					x0 = 288;
					x1 = 288;
					y0 = 163;
					y1 = 170;
				end
				name20: //Y
				begin
					x0 = 232;
					x1 = 237;
					y0 = 180;
					y1 = 190;
				end
				name21:
				begin
					x0 = 237;
					x1 = 243;
					y0 = 190;
					y1 = 180;
				end
				name22:
				begin
					x0 = 237;
					x1 = 237;
					y0 = 190;
					y1 = 200;
				end
				name23: //I
				begin
					x0 = 252;
					x1 = 252;
					y0 = 180;
					y1 = 200;
				end
				name24:
				begin
					x0 = 250;
					x1 = 254;
					y0 = 180;
					y1 = 180;
				end
				name25:
				begin
					x0 = 250;
					x1 = 254;
					y0 = 200;
					y1 = 200;
				end
				name26: //F
				begin
					x0 = 262;
					x1 = 273;
					y0 = 180;
					y1 = 180;
				end
				name27:
				begin
					x0 = 262;
					x1 = 273;
					y0 = 190;
					y1 = 190;
				end
				name28:
				begin
					x0 = 262;
					x1 = 262;
					y0 = 180;
					y1 = 200;
				end
				name29: //A
				begin
					x0 = 277;
					x1 = 282;
					y0 = 200;
					y1 = 180;
				end
				name30:
				begin
					x0 = 282;
					x1 = 288;
					y0 = 180;
					y1 = 200;
				end
				name31:
				begin
					x0 = 280;
					x1 = 285;
					y0 = 190;
					y1 = 190;
				end
				name32: //N
				begin
					x0 = 292;
					x1 = 292;
					y0 = 180;
					y1 = 200;
				end
				name33:
				begin
					x0 = 292;
					x1 = 303;
					y0 = 180;
					y1 = 200;
				end
				name34:
				begin
					x0 = 303;
					x1 = 303;
					y0 = 180;
					y1 = 200;
				end
				
				
				kiri1: //K
				begin
					x0 = titlex+2;
					x1 = titlex+2;
					y0 = titley;
					y1 = titley+20;
				end
				kiri2:
				begin
					x0 = titlex+2;
					x1 = titlex+18;
					y0 = titley+12;
					y1 = titley;
				end
				kiri3:
				begin
					x0 = titlex+6;
					x1 = titlex+18;
					y0 = titley+9;
					y1 = titley+20;
				end
				kiri4: //i
				begin
					x0 = titlex+30;
					x1 = titlex+30;
					y0 = titley;
					y1 = titley+2;
				end
				kiri5:
				begin
					x0 = titlex+30;
					x1 = titlex+30;
					y0 = titley+6;
					y1 = titley+20;
				end
				kiri6: //r
				begin
					x0 = titlex+42;
					x1 = titlex+42;
					y0 = titley;
					y1 = titley+20;
				end
				kiri7:
				begin
					x0 = titlex+42;
					x1 = titlex+58;
					y0 = titley+5;
					y1 = titley;
				end
				kiri8: //i
				begin
					x0 = titlex+70;
					x1 = titlex+70;
					y0 = titley;
					y1 = titley+2;
				end
				kiri9:
				begin
					x0 = titlex+70;
					x1 = titlex+70;
					y0 = titley+6;
					y1 = titley+20;
				end
				kiri10: //s
				begin
					x0 = titlex+98;
					x1 = titlex+90;
					y0 = titley+7;
					y1 = titley;
				end
				kiri11:
				begin
					x0 = titlex+90;
					x1 = titlex+82;
					y0 = titley;
					y1 = titley+7;
				end
				kiri12:
				begin
					x0 = titlex+82;
					x1 = titlex+98;
					y0 = titley+7;
					y1 = titley+13;
				end
				kiri13:
				begin
					x0 = titlex+98;
					x1 = titlex+90;
					y0 = titley+13;
					y1 = titley+20;
				end
				kiri14:
				begin
					x0 = titlex+90;
					x1 = titlex+82;
					y0 = titley+20;
					y1 = titley+13;
				end
				kiri15: //a
				begin
					x0 = titlex+102;
					x1 = titlex+110;
					y0 = titley+7;
					y1 = titley;
				end
				kiri16:
				begin
					x0 = titlex+110;
					x1 = titlex+118;
					y0 = titley;
					y1 = titley+7;
				end
				kiri17:
				begin
					x0 = titlex+118;
					x1 = titlex+118;
					y0 = titley+7;
					y1 = titley+20;
				end
				kiri18:
				begin
					x0 = titlex+102;
					x1 = titlex+110;
					y0 = titley+13;
					y1 = titley+7;
				end
				kiri19:
				begin
					x0 = titlex+110;
					x1 = titlex+118;
					y0 = titley+7;
					y1 = titley+13;
				end
				kiri20:
				begin
					x0 = titlex+118;
					x1 = titlex+110;
					y0 = titley+13;
					y1 = titley+20;
				end
				kiri21:
				begin
					x0 = titlex+110;
					x1 = titlex+102;
					y0 = titley+20;
					y1 = titley+13;
				end
				kiri22: //m
				begin
					x0 = titlex+122;
					x1 = titlex+126;
					y0 = titley+20;
					y1 = titley;
				end
				kiri23:
				begin
					x0 = titlex+126;
					x1 = titlex+130;
					y0 = titley;
					y1 = titley+20;
				end
				kiri24:
				begin
					x0 = titlex+130;
					x1 = titlex+138;
					y0 = titley+20;
					y1 = titley;
				end
				kiri25:
				begin
					x0 = titlex+138;
					x1 = titlex+142;
					y0 = titley;
					y1 = titley+20;
				end
				kiri26: //e
				begin
					x0 = titlex+142;
					x1 = titlex+150;
					y0 = titley+7;
					y1 = titley;
				end
				kiri27:
				begin
					x0 = titlex+150;
					x1 = titlex+158;
					y0 = titley;
					y1 = titley+7;
				end
				kiri28:
				begin
					x0 = titlex+158;
					x1 = titlex+150;
					y0 = titley+7;
					y1 = titley+13;
				end
				kiri29:
				begin
					x0 = titlex+150;
					x1 = titlex+142;
					y0 = titley+13;
					y1 = titley+7;
				end
				kiri30:
				begin
					x0 = titlex+142;
					x1 = titlex+142;
					y0 = titley+7;
					y1 = titley+13;
				end
				kiri31:
				begin
					x0 = titlex+142;
					x1 = titlex+150;
					y0 = titley+13;
					y1 = titley+20;
				end
				kiri32:
				begin
					x0 = titlex+150;
					x1 = titlex+158;
					y0 = titley+20;
					y1 = titley+13;
				end
				kiri33:  //line2 M
				begin
					x0 = titlex+2;
					x1 = titlex+6;
					y0 = titley+50;
					y1 = titley+30;
				end
				kiri34:
				begin
					x0 = titlex+6;
					x1 = titlex+10;
					y0 = titley+30;
					y1 = titley+50;
				end
				kiri35:
				begin
					x0 = titlex+10;
					x1 = titlex+14;
					y0 = titley+50;
					y1 = titley+30;
				end
				kiri36:
				begin
					x0 = titlex+14;
					x1 = titlex+18;
					y0 = titley+30;
					y1 = titley+50;
				end
				kiri37: //a
				begin
					x0 = titlex+22;
					x1 = titlex+30;
					y0 = titley+37;
					y1 = titley+30;
				end
				kiri38:
				begin
					x0 = titlex+30;
					x1 = titlex+38;
					y0 = titley+30;
					y1 = titley+37;
				end
				kiri39:
				begin
					x0 = titlex+38;
					x1 = titlex+38;
					y0 = titley+37;
					y1 = titley+50;
				end
				kiri40:
				begin
					x0 = titlex+38;
					x1 = titlex+30;
					y0 = titley+43;
					y1 = titley+37;
				end
				kiri41:
				begin
					x0 = titlex+30;
					x1 = titlex+22;
					y0 = titley+37;
					y1 = titley+43;
				end
				kiri42:
				begin
					x0 = titlex+22;
					x1 = titlex+30;
					y0 = titley+43;
					y1 = titley+50;
				end
				kiri43:
				begin
					x0 = titlex+30;
					x1 = titlex+38;
					y0 = titley+50;
					y1 = titley+43;
				end
				kiri44: //r
				begin
					x0 = titlex+42;
					x1 = titlex+42;
					y0 = titley+30;
					y1 = titley+50;
				end
				kiri45:
				begin
					x0 = titlex+42;
					x1 = titlex+58;
					y0 = titley+35;
					y1 = titley+30;
				end
				kiri46: //i
				begin
					x0 = titlex+70;
					x1 = titlex+70;
					y0 = titley+30;
					y1 = titley+32;
				end
				kiri47:
				begin
					x0 = titlex+70;
					x1 = titlex+70;
					y0 = titley+36;
					y1 = titley+50;
				end
				kiri48: //s
				begin
					x0 = titlex+98;
					x1 = titlex+90;
					y0 = titley+37;
					y1 = titley+30;
				end
				kiri49:
				begin
					x0 = titlex+90;
					x1 = titlex+82;
					y0 = titley+30;
					y1 = titley+37;
				end
				kiri50:
				begin
					x0 = titlex+82;
					x1 = titlex+98;
					y0 = titley+37;
					y1 = titley+43;
				end
				kiri51:
				begin
					x0 = titlex+98;
					x1 = titlex+90;
					y0 = titley+43;
					y1 = titley+50;
				end
				kiri52:
				begin
					x0 = titlex+90;
					x1 = titlex+82;
					y0 = titley+50;
					y1 = titley+43;
				end
				kiri53: //a
				begin
					x0 = titlex+102;
					x1 = titlex+110;
					y0 = titley+37;
					y1 = titley+30;
				end
				kiri54:
				begin
					x0 = titlex+110;
					x1 = titlex+118;
					y0 = titley+30;
					y1 = titley+37;
				end
				kiri55:
				begin
					x0 = titlex+118;
					x1 = titlex+118;
					y0 = titley+37;
					y1 = titley+50;
				end
				kiri56:
				begin
					x0 = titlex+118;
					x1 = titlex+110;
					y0 = titley+43;
					y1 = titley+37;
				end
				kiri57:
				begin
					x0 = titlex+110;
					x1 = titlex+102;
					y0 = titley+37;
					y1 = titley+43;
				end
				kiri58:
				begin
					x0 = titlex+102;
					x1 = titlex+110;
					y0 = titley+43;
					y1 = titley+50;
				end
				kiri59:
				begin
					x0 = titlex+110;
					x1 = titlex+118;
					y0 = titley+50;
					y1 = titley+43;
				end
				kiri60: //'
				begin
					x0 = titlex+130;
					x1 = titlex+125;
					y0 = titley+30;
					y1 = titley+35;
				end
				kiri61: //s
				begin
					x0 = titlex+158;
					x1 = titlex+150;
					y0 = titley+37;
					y1 = titley+30;
				end
				kiri62:
				begin
					x0 = titlex+150;
					x1 = titlex+142;
					y0 = titley+30;
					y1 = titley+37;
				end
				kiri63:
				begin
					x0 = titlex+142;
					x1 = titlex+158;
					y0 = titley+37;
					y1 = titley+43;
				end
				kiri64:
				begin
					x0 = titlex+158;
					x1 = titlex+150;
					y0 = titley+43;
					y1 = titley+50;
				end
				kiri65:
				begin
					x0 = titlex+150;
					x1 = titlex+142;
					y0 = titley+50;
					y1 = titley+43;
				end
				
				f1: //FF
				begin
					x0 = titlex+2;
					x1 = titlex+38;
					y0 = titley+60;
					y1 = titley+60;
				end
				f2:
				begin
					x0 = titlex+38;
					x1 = titlex+38;
					y0 = titley+60;
					y1 = titley+66;
				end
				f3:
				begin
					x0 = titlex+38;
					x1 = titlex+8;
					y0 = titley+66;
					y1 = titley+66;
				end
				f4:
				begin
					x0 = titlex+8;
					x1 = titlex+8;
					y0 = titley+66;
					y1 = titley+74;
				end
				f5:
				begin
					x0 = titlex+8;
					x1 = titlex+38;
					y0 = titley+74;
					y1 = titley+74;
				end
				f6:
				begin
					x0 = titlex+38;
					x1 = titlex+38;
					y0 = titley+74;
					y1 = titley+80;
				end
				f7:
				begin
					x0 = titlex+38;
					x1 = titlex+8;
					y0 = titley+80;
					y1 = titley+80;
				end
				f8:
				begin
					x0 = titlex+8;
					x1 = titlex+8;
					y0 = titley+80;
					y1 = titley+100;
				end
				f9:
				begin
					x0 = titlex+8;
					x1 = titlex+2;
					y0 = titley+100;
					y1 = titley+100;
				end
				f10:
				begin
					x0 = titlex+2;
					x1 = titlex+2;
					y0 = titley+100;
					y1 = titley+60;
				end
				f11: //PP
				begin
					x0 = titlex+42;
					x1 = titlex+78;
					y0 = titley+60;
					y1 = titley+60;
				end
				f12:
				begin
					x0 = titlex+78;
					x1 = titlex+78;
					y0 = titley+60;
					y1 = titley+80;
				end
				f13:
				begin
					x0 = titlex+78;
					x1 = titlex+48;
					y0 = titley+80;
					y1 = titley+80;
				end
				f14:
				begin
					x0 = titlex+48;
					x1 = titlex+48;
					y0 = titley+80;
					y1 = titley+100;
				end
				f15:
				begin
					x0 = titlex+48;
					x1 = titlex+42;
					y0 = titley+100;
					y1 = titley+100;
				end
				f16:
				begin
					x0 = titlex+42;
					x1 = titlex+42;
					y0 = titley+100;
					y1 = titley+60;
				end
				f17:
				begin
					x0 = titlex+48;
					x1 = titlex+72;
					y0 = titley+66;
					y1 = titley+66;
				end
				f18:
				begin
					x0 = titlex+72;
					x1 = titlex+72;
					y0 = titley+66;
					y1 = titley+74;
				end
				f19:
				begin
					x0 = titlex+72;
					x1 = titlex+48;
					y0 = titley+74;
					y1 = titley+74;
				end
				f20:
				begin
					x0 = titlex+48;
					x1 = titlex+48;
					y0 = titley+74;
					y1 = titley+66;
				end
				f21: //GG
				begin
					x0 = titlex+118;
					x1 = titlex+100;
					y0 = titley+68;
					y1 = titley+60;
				end
				f22:
				begin
					x0 = titlex+100;
					x1 = titlex+82;
					y0 = titley+60;
					y1 = titley+74;
				end
				f23:
				begin
					x0 = titlex+82;
					x1 = titlex+82;
					y0 = titley+74;
					y1 = titley+86;
				end
				f24:
				begin
					x0 = titlex+82;
					x1 = titlex+100;
					y0 = titley+86;
					y1 = titley+100;
				end
				f25:
				begin
					x0 = titlex+100;
					x1 = titlex+112;
					y0 = titley+100;
					y1 = titley+92;
				end
				f26:
				begin
					x0 = titlex+112;
					x1 = titlex+112;
					y0 = titley+92;
					y1 = titley+100;
				end
				f27:
				begin
					x0 = titlex+112;
					x1 = titlex+118;
					y0 = titley+100;
					y1 = titley+100;
				end
				f28:
				begin
					x0 = titlex+118;
					x1 = titlex+118;
					y0 = titley+100;
					y1 = titley+80;
				end
				f29:
				begin
					x0 = titlex+118;
					x1 = titlex+100;
					y0 = titley+80;
					y1 = titley+80;
				end
				f30:
				begin
					x0 = titlex+100;
					x1 = titlex+100;
					y0 = titley+80;
					y1 = titley+86;
				end
				f31:
				begin
					x0 = titlex+100;
					x1 = titlex+112;
					y0 = titley+86;
					y1 = titley+86;
				end
				f32:
				begin
					x0 = titlex+112;
					x1 = titlex+100;
					y0 = titley+86;
					y1 = titley+94;
				end
				f33:
				begin
					x0 = titlex+100;
					x1 = titlex+88;
					y0 = titley+94;
					y1 = titley+86;
				end
				f34:
				begin
					x0 = titlex+88;
					x1 = titlex+88;
					y0 = titley+86;
					y1 = titley+74;
				end
				f35:
				begin
					x0 = titlex+88;
					x1 = titlex+100;
					y0 = titley+74;
					y1 = titley+66;
				end
				f36:
				begin
					x0 = titlex+100;
					x1 = titlex+118;
					y0 = titley+66;
					y1 = titley+74;
				end
				f37:
				begin
					x0 = titlex+118;
					x1 = titlex+118;
					y0 = titley+74;
					y1 = titley+68;
				end
				f38: //AA
				begin
					x0 = titlex+140;
					x1 = titlex+122;
					y0 = titley+60;
					y1 = titley+100;
				end
				f39:
				begin
					x0 = titlex+122;
					x1 = titlex+128;
					y0 = titley+100;
					y1 = titley+100;
				end
				f40:
				begin
					x0 = titlex+128;
					x1 = titlex+132;
					y0 = titley+100;
					y1 = titley+87;
				end
				f41:
				begin
					x0 = titlex+132;
					x1 = titlex+148;
					y0 = titley+87;
					y1 = titley+89;
				end
				f42:
				begin
					x0 = titlex+148;
					x1 = titlex+152;
					y0 = titley+89;
					y1 = titley+100;
				end
				f43:
				begin
					x0 = titlex+152;
					x1 = titlex+158;
					y0 = titley+100;
					y1 = titley+100;
				end
				f44:
				begin
					x0 = titlex+158;
					x1 = titlex+140;
					y0 = titley+100;
					y1 = titley+60;
				end
				f45:
				begin
					x0 = titlex+140;
					x1 = titlex+134;
					y0 = titley+66;
					y1 = titley+83;
				end
				f46:
				begin
					x0 = titlex+134;
					x1 = titlex+146;
					y0 = titley+83;
					y1 = titley+83;
				end
				f47:
				begin
					x0 = titlex+146;
					x1 = titlex+140;
					y0 = titley+83;
					y1 = titley+66;
				end
				
				ad1: //A
				begin
					x0 = titlex+2;
					x1 = titlex+10;
					y0 = titley+130;
					y1 = titley+110;
				end
				ad2:
				begin
					x0 = titlex+10;
					x1 = titlex+18;
					y0 = titley+110;
					y1 = titley+130;
				end
				ad3:
				begin
					x0 = titlex+6;
					x1 = titlex+14;
					y0 = titley+120;
					y1 = titley+120;
				end
				ad4: //d
				begin
					x0 = titlex+22;
					x1 = titlex+30;
					y0 = titley+125;
					y1 = titley+120;
				end
				ad5:
				begin
					x0 = titlex+30;
					x1 = titlex+38;
					y0 = titley+120;
					y1 = titley+125;
				end
				ad6:
				begin
					x0 = titlex+38;
					x1 = titlex+30;
					y0 = titley+125;
					y1 = titley+130;
				end
				ad7:
				begin
					x0 = titlex+30;
					x1 = titlex+22;
					y0 = titley+130;
					y1 = titley+125;
				end
				ad8:
				begin
					x0 = titlex+38;
					x1 = titlex+38;
					y0 = titley+110;
					y1 = titley+130;
				end
				ad9: //V
				begin
					x0 = titlex+42;
					x1 = titlex+50;
					y0 = titley+110;
					y1 = titley+130;
				end
				ad10:
				begin
					x0 = titlex+50;
					x1 = titlex+58;
					y0 = titley+130;
					y1 = titley+110;
				end
				ad11: //e
				begin
					x0 = titlex+62;
					x1 = titlex+70;
					y0 = titley+117;
					y1 = titley+110;
				end
				ad12:
				begin
					x0 = titlex+70;
					x1 = titlex+78;
					y0 = titley+110;
					y1 = titley+117;
				end
				ad13:
				begin
					x0 = titlex+78;
					x1 = titlex+70;
					y0 = titley+117;
					y1 = titley+123;
				end
				ad14:
				begin
					x0 = titlex+70;
					x1 = titlex+62;
					y0 = titley+123;
					y1 = titley+117;
				end
				ad15:
				begin
					x0 = titlex+62;
					x1 = titlex+62;
					y0 = titley+117;
					y1 = titley+123;
				end
				ad16:
				begin
					x0 = titlex+62;
					x1 = titlex+70;
					y0 = titley+123;
					y1 = titley+130;
				end
				ad17:
				begin
					x0 = titlex+70;
					x1 = titlex+78;
					y0 = titley+130;
					y1 = titley+123;
				end
				ad18:  //n
				begin
					x0 = titlex+82;
					x1 = titlex+82;
					y0 = titley+110;
					y1 = titley+130;
				end
				ad19:
				begin
					x0 = titlex+82;
					x1 = titlex+98;
					y0 = titley+110;
					y1 = titley+130;
				end
				ad20:
				begin
					x0 = titlex+98;
					x1 = titlex+98;
					y0 = titley+110;
					y1 = titley+130;
				end
				ad21: //t
				begin
					x0 = titlex+110;
					x1 = titlex+110;
					y0 = titley+110;
					y1 = titley+130;
				end
				ad22:
				begin
					x0 = titlex+106;
					x1 = titlex+114;
					y0 = titley+117;
					y1 = titley+117;
				end
				ad23:
				begin
					x0 = titlex+110;
					x1 = titlex+114;
					y0 = titley+130;
					y1 = titley+130;
				end
				ad24: //u
				begin
					x0 = titlex+122;
					x1 = titlex+122;
					y0 = titley+110;
					y1 = titley+130;
				end
				ad25:
				begin
					x0 = titlex+122;
					x1 = titlex+138;
					y0 = titley+130;
					y1 = titley+130;
				end
				ad26:
				begin
					x0 = titlex+138;
					x1 = titlex+138;
					y0 = titley+110;
					y1 = titley+130;
				end
				ad27: //r
				begin
					x0 = titlex+142;
					x1 = titlex+142;
					y0 = titley+110;
					y1 = titley+130;
				end
				ad28:
				begin
					x0 = titlex+142;
					x1 = titlex+158;
					y0 = titley+115;
					y1 = titley+110;
				end
				ad29: //e
				begin
					x0 = titlex+162;
					x1 = titlex+170;
					y0 = titley+117;
					y1 = titley+110;
				end
				ad30:
				begin
					x0 = titlex+170;
					x1 = titlex+178;
					y0 = titley+110;
					y1 = titley+117;
				end
				ad31:
				begin
					x0 = titlex+178;
					x1 = titlex+170;
					y0 = titley+117;
					y1 = titley+123;
				end
				ad32:
				begin
					x0 = titlex+170;
					x1 = titlex+162;
					y0 = titley+123;
					y1 = titley+117;
				end
				ad33:
				begin
					x0 = titlex+162;
					x1 = titlex+162;
					y0 = titley+117;
					y1 = titley+123;
				end
				ad34:
				begin
					x0 = titlex+162;
					x1 = titlex+170;
					y0 = titley+123;
					y1 = titley+130;
				end
				ad35:
				begin
					x0 = titlex+170;
					x1 = titlex+178;
					y0 = titley+130;
					y1 = titley+123;
				end
					
        endcase
    end

    always_ff @(posedge clk) // Registered data
    begin
        if(rst)
        begin
            InternalEndpoint <= '0;
        end
        else
        begin
            if(FrameClock[CLOCKDIV-1]) FrameClock <= '0;
            else FrameClock <= FrameClock + 1'd1;

            if(Present == FINISH)
            begin
                if(InternalEndpoint == (SQSIZE * 4)) InternalEndpoint <= '0;
                else InternalEndpoint <= InternalEndpoint + 1'd1;
                
            end
        end
    end
endmodule
