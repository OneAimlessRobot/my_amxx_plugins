#if defined fast_sh_colors_module_aux_inc
  #endinput
#endif
#define fast_sh_colors_module_aux_inc


/* Hero array module
*
* (c) Copyright 2026 ThrashBrat
*
* This file is provided as is (no warranties).
*/

/*

no return value

*/


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

//Colors To Pick From

enum sh_std_color_id{
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
		GODMODE_BLUE
}


enum sh_fx_color_id{
	FX_ID_NONE=0,
	KILL,
	GLOW,
	POISON,
	STUN,
	RADIOACTIVE,
	MORPHINE,
	WEED,
	COCAINE,
	BLIND,
	METYLPHENIDATE,
	BATH
}


#define FX_COLOR_OFFSET(%1) (sh_custom_color-sh_custom_color:fx_id+sh_custom_color:_:%1)

native sh_fetch_std_color(sh_custom_color:color_num, dest_buff[3])
native sh_fetch_fx_color(sh_custom_color:color_num, dest_buff[3])