#include "../include/nvault.inc"
#include "../include/amxmod.inc"
#include "../include/amxmodx.inc"
#include "../include/amxmisc.inc"
#include "../include/hamsandwich.inc"
#include "../include/fakemeta.inc"
#include "../include/fakemeta_util.inc"
#include "../include/colorchat.inc"
#include "../include/engine.inc"
#include "../include/fun.inc"
#include "../include/csx.inc"
#include "../include/cstrike.inc"
#include "../include/Vexd_Utilities.inc"
#include "my_include/codmw4_perks.inc"


#define PLUGIN "Call of Duty: MW4 Mod perks"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new const naziv_predmeta[][] = 
{
"None",				// 0 
"Silent boots", 		// 1
"Double armors", 		// 2
"Reinforced Armors", 		// 3
"Veteran with a knife", 	// 4
"Surprise enemies", 	        // 5
"Invisibility", 		// 6 
"Respawn",	  		// 7
"Knife Master", 		// 8
"Camouflage", 			// 9
"HE Expert", 			//10
"Double Jump", 			//11
"War Secret", 			//12
"AWP Master",			//13
"Adrenalin",			//14
"Rambova secret",		//15
"Deagle Maniac",		//16
"Super Armors",			//17
"Extra HP++",			//18
"First aid kit",	        //19
"No Recoil",			//20
"Titanium Bullets ",		//21
"Colonel Bullets",		//22
"Limited no-recoil",		//23
"SWAT Shield",			//24
"50 HP++",			//25
"Nano Armors",			//26
"BulletProof",			//27
"Jetpack",			//28
"Gravity",			//29
"Speed",			//30
"Set Stunter",			//31
"M4 Master",			//32
"Deagle Master",		//33
"Scout Master",			//34
"General Equipment",		//35
"Expert M3",			//36
"HE Skills",			//37
"Super Galil",			//38
"Sniper Kit",		        //39
"Assassin cloak",		//40
"Only Headshot",		//41
"M4a1-Aim",			//42
"Ak47-Aim",			//43
"Infinite Ammo",		//44
"Silver Bullets",		//45
"Fast XP",			//46
"Triple Jump",			//47
"Money",			//48
"Drugs",			//49
"Super Jetpack"                   //50

};
new const opis_predmet[][] = 
{
"Kill someone and you will get a Item",
"Silent running.",
"Reduces damage to LW %.",
"Reduces damage to LW %.",
"With knife apply more DMG.",
"When you shoot an opponent from behind, apply it 2x more damage.",
"You get LW % invisibility.",
"1/LW chance to revive you after death.",
"Instant kill with knife.",
"Do 1/LW chance to kill with HE . Also have camouflage.",
"Instant kill with HE.Zadajes LW % additional damage.",
"You can jump two times.",
"Your injuries are reduced by 5 %.1/LW You have a chance to blinded opponents.",
"Instant kill with AWP.",
"For each kill you get 50hp.",
"For each kill you get a full clip and 20hp.",
"You get a Deagle.",
"You get 500 armors each round.",
"Every round you get 100 HP , but reduced speed.",
"Use the kit to regain HP itself.",
"No recoil.",
"Apply 10 DMG more harm.",
"Apply 20 DMG more harm.",
"Minimum rifle recoil when shooting.",
"You are resistant to Dynamite , Rockets, Mines and Cases.",
"Every round you get 50 HP , but reduced speed.",
"1/LW chance to fight back the enemy 's shot, so he apply damage.",
"You are resistant to three bullets in each round.",
"Use the Ctrl and Space.",
"Lower your gravity.",
"Increasing your speed.",
"You get a MP5 and USP , you have 1/2 chance of instant kill with the USP and 1/5 with MP5.",
"You get a M4A1 , you have 1/4 chance of instant kill with it.",
"You get a Deagle , INstant kill with AWP.",
"You get a Scout , Instant kill with SCOUT.",
"You get Ak47 , AWP , 1/2 chance of instant kill with AWP.",
"You get the M5 , you have 1/3 chance with M5 to kill.",
"You have 1/3 chance to kill with He.",
"You get a Galil , you have a 1/5 chance of instant kill.",
"You get AWP + Deagle , AWP have a 1/1 , with Deagle half chances to kill.",
"You are invisible when you take a knife.",
"Only you can kill with headshot.",
"You get a M4A1 , you have a 1/3 chance to kill with a headshot.",
"You get Ak47 , you have a 1/3 chance to kill with a headshot.",
"Need the end of ammunition.",
"Apply 48 dmg more harm.",
"For each kill you get 2x more EXP - rather than the other.",
"You can jump three times in the air.",
"You get +8000 U.S. dollars every round.",
"You've been drugged.",
"Jetpack but more powerfull"
}



public plugin_init(){
register_plugin(PLUGIN, VERSION, AUTHOR);

register_concmd("cod_num_perks","printNPerks") 

}

public printNPerks(id, level, cid){

	console_print(id,"Number of perks registered: %i, size of array: %i",sizeof naziv_predmeta,50);

}
public get_NumPerks(){

	return sizeof naziv_predmeta
}

public get_PerkName(perkid,buff[]){

	copy(buff, 127, naziv_predmeta[perkid] );
	return PLUGIN_CONTINUE
	

}
public get_PerkDesc(perkid,buff[]){

	copy(buff, 511, opis_predmet[perkid] );
	return PLUGIN_CONTINUE
}

