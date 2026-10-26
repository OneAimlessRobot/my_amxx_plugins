/*
(c) Copyright 2026, ThrashBrat

check pawn include for interface
  */

#ifndef __COLORS_LOOKUP_TABLE_H__
#define __COLORS_LOOKUP_TABLE_H__

#define min(a,b) ((a < b) ? a : b)
#define max(a,b) ((a > b) ? a : b)
#define clamp(v,m,M) ((m < M)?( ( v <= m) ? m : ( ( v >= M )? M : v) ) : ( ( v <= M) ? M : ( ( v >= m )? m : v) ) )

typedef uint32_t state_cell_type_t;

typedef struct color_t{
	uint8_t color_values[3];
	
	
}color_t;

// this list includes the alphas that are meant to be applied

// chucky blue 75, 75, 255 16 
// grandmaster yellow 255, 255, 0, 16,
// blink pink 219, 112, 147 16
// breaker blue 0 255, 255, 50
// dr strange green 0, 240, 100 16
// exodus yellow 200, 187, 0 16
// phoenix red 248, 20, 25 16
// steel grey 35, 40, 50 16
// iceman blue 50,50,250 16
// static shock blue 50,50,250 16
// invisible man grey 8, 8, 8
// palpatine purple 175,0,255 25
// godmode blue 0, 0, 128 16


typedef enum sh_custom_color{
		CUSTOM=0,
		RED,
		GREEN,
		BLUE,
		LTBLUE,
		YELLOW,
		PURPLE,
		ORANGE,
		WHITE,
		PINK,
		LTGREEN,
		INVIS,
		BLACK,
		MAGENTA,
		FROZEN_BLUE,
		BABY_BLUE,
		LAVENDER,
		GRIM_REAPER_GLOW,
		ELELCTROBOOM_VIOLET,
		CHUCKY_BLUE,
		GRANDMASTER_YELLOW,
		BLINK_PINK,
		BREAKER_BLUE,
		DR_STRANGE_GREEN,
		EXODUS_YELLOW,
		PHOENIX_RED,
		STEEL_GREY,
		ICEMAN_BLUE,
		STATIC_SHOCK_BLUE,
		INVISIBLE_MAN_GREY,
		PALPATINE_PURPLE,
		GODMODE_BLUE,
		NUM_COLORS
}sh_custom_color;

//Color definitions
static const color_t standard_colors_to_use[NUM_COLORS] = {
	{150, 150, 150},	//Custom
	{255, 0, 0},		//Red
	{0, 255, 0},		//Green
	{0, 0, 255},		//Blue
	{0, 255, 255},		//Light Blue
	{255, 255, 0},		//Yellow
	{255, 0, 255},		//Purple
	{255, 128, 0},		//Orange
	{255, 255, 255},	//White
	{250, 92, 163},      //Pink
	{111,255,111},      //Light Green
	{10,10,10},      //invisible
	{1,1,1},      //Black
	{255,0,127},      //Magenta
	{5, 30, 125}, //Frozen Blue
	{111, 111, 255}, //Baby Blue
	{139, 122, 158}, //Lavender
	{50, 8, 8}, //grim reaper glow
	{184, 105, 255}, //electroboom violet
	{75, 75, 255 }, // chucky blue
	{255, 255, 0}, // grandmaster yellow 
	{219, 112, 147}, // blink pink
	{0, 255, 255 }, // Breaker blue
	{0, 240, 100 }, // dr strange green
	{200, 187, 0 }, // exodus yellow
	{248, 20, 25 }, // Phoenix red
	{35, 40, 50 }, // Steel grey
	{50, 50, 250 }, // iceman blue
	{50, 50, 250 }, // static shock blue
	{8, 8, 8 }, // invisible man grey
	{175,0,255 }, // palpatine purple
	{0, 0, 128 } // godmode blue

};

typedef enum sh_fx_color{

	FX_NONE = 0,
	FX_KILL,
	FX_GLOW,
	FX_POISON,
	FX_STUN,
	FX_RADIOACTIVE,
	FX_MORPHINE,
	FX_WEED,
	FX_COCAINE,
	FX_BLIND,
	FX_METYLPHENIDATE,
	FX_BATH,
	NUM_FX_COLORS
	
}sh_fx_color;


//Color definitions
const color_t fx_colors_to_use[NUM_FX_COLORS] = {
	{0,0,0}, //fx_none
	{1, 255, 255}, //fx_cyanide
	{255, 255, 255}, //fx_glow
	{80, 240, 30},	//fx_poison
	{100, 100, 100}, //fx_stun
	{240, 80, 30}, //fx_radioactive
	{80, 240, 1}, //fx_morphine
	{80, 240, 90}, //fx_weed
	{250, 10, 30},  //fx_cocaine
	{255, 255, 255}, //fx_blind
	{50, 50, 50},  //fx_metylphenidate
	{179, 66, 5} //fx_bath

};

#endif
