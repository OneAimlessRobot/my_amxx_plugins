//DarkPredator 1.0 (By kanu | DarkPredator)

/*Credit goes to: 

jtp10181 - Invisible Man code, Agent Deagle
AssKicR - Superhero Scripting Tutorial
{HOJ} Batman/JTP10181 - ESP Rings
AssKicR / ArtofDrowning07 - Lazer Bullets (Green Arrow)
vittu - MasterChief Morphing code

CVARS - COPY AND PASTE TO SHCONFIG.CFG

darkpred_level 10		//What level should DarkPredator be? Default=10
darkpred_armor 400		//How much armor should DarkPredator get? Default=400
darkpred_alpha 10		//What is the alpha level when invisible? | 0 = invisible, 255 = full visibility. | Default=10
darkpred_delay 2		//How long should a player wait to become fully invisible? (seconds) Default=2
darkpred_checkmove 0 		//Should movement be checked, or only shooting? | 0 = only check shooting | Default=0
darkpred_radius 900		//What is the radius of the rings? Default=900
darkpred_bright 192		//How bright should the rings be? Default=192
darkpred_healpoints 4		//How much HP does Darkpredator heal per second? Default=4
darkpred_bullets 6		//How many lazer bullets does he get? Default=6

*/
#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt5.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt9.inc"



#define MAX_PICKED 0

// VARIABLES
new gHeroName[]="DarkPredator" 

new gIsInvisible[SH_MAXSLOTS+1]
new gStillTime[SH_MAXSLOTS+1]
new gSpriteWhite, gRadius, gBright
new gHealPoints
new gHeroID
new accessLevel[10]
new gBullets[SH_MAXSLOTS+1]
new gLastWeapon[SH_MAXSLOTS+1]
new gLastClipCount[SH_MAXSLOTS+1]
new laser,laser_impact,blast_shroom
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	my_authored_register_func("SUPERHERO DarkPredator","1.0","kanu | DarkPredator",true,AUTHOR )
	
	register_cvar("darkpred_level", "10" )
	
	gHeroID=shCreateHero(gHeroName, "Deagle/Invisibility (ADMIN A ONLY)", "Free deagle and invisibility. Plus ESP rings, Predator Armour and Regeneration.", false, "darkpred_level" )
	sh_register_superheromod_model(gHeroID,
							"models/player/sh_darkpredator/sh_darkpredator.mdl",
							"models/player/sh_darkpredator/sh_darkpredator.mdl",
							"sh_darkpredator",
							"You now wear your Predator battle armour.",
							"You are not wearing your Predator battle armour.")
	
	
	// WEAPON EVENT To give DarkPredator unlimited deagle ammo
	register_event("CurWeapon","changeWeapon","be","1=1")  
	//Damage
	register_event("Damage", "darkpred_damage", "b", "2!0")
		
	
	// DEFAULT THE CVARS
	register_cvar("darkpred_armor", "400") 
	register_cvar("darkpred_alpha", "10")
	register_cvar("darkpred_delay", "2")
	register_cvar("darkpred_checkmove", "0")
	register_cvar("darkpred_healpoints", "4" )
	register_cvar("darkpred_radius", "900")
	register_cvar("darkpred_bright", "192")
	register_cvar("darkpred_bullets", "6")
	register_cvar("darkpred_adminflag", "a")
	
	// Let Server know about DarkPredators Variables
	// It is possible that another hero has more hps, less gravity, or more armor
	// so rather than just setting these - let the superhero module decide each round
	shSetMaxArmor(gHeroName, "darkpred_armor" )
	
	// CHECK SOME BUTTONS
	set_task(0.1,"checkButtons",0,"",0,"b")
	
	// HEAL LOOP
	set_task(1.0,"darkpred_loop",0,"",0,"b" )
	
	//ESP Rings Task
	set_task(2.0, "darkpred_esploop", 0, "", 0, "b")
	
	gHealPoints = get_cvar_num("darkpred_healpoints")
	// BULLETS FIRED
	register_event("CurWeapon","darkpred_fire", "be", "1=1", "3>0") 
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	gSpriteWhite = engfunc(EngFunc_PrecacheModel,"sprites/white.spr")
	laser = engfunc(EngFunc_PrecacheModel,"sprites/laserbeam.spr") 
	laser_impact = engfunc(EngFunc_PrecacheModel,"sprites/zerogxplode.spr") 
	blast_shroom = engfunc(EngFunc_PrecacheModel,"sprites/mushroom.spr")
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode){
	if(heroID!=gHeroID) return
	
	if ( sh_user_has_hero(id,gHeroID) ) //Check if person selected this hero
	{
		remInvisibility(id)
		sh_give_weapon(id,CSW_DEAGLE)
	}
	// Got to slow down DarkPredator that lost his powers...
	if ( !sh_user_has_hero(id,gHeroID)  && is_user_connected(id) ) //Check if person dropped this hero
	{
		remInvisibility(id)
	}
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
	remInvisibility(id)
	if (is_user_alive(id) && sh_is_active() ) {
		if(sh_user_has_hero(id,gHeroID)){
			gBullets[id] = get_cvar_num("darkpred_bullets")
			gLastWeapon[id] = -1
			set_task(0.1, "darkpred_deagle",id)
		}
	}
}
//----------------------------------------------------------------------------------------------
public setInvisibility(id, alpha)
{
	
	if (alpha < 125) {
		set_user_rendering(id,kRenderFxGlowShell,1,1,1,kRenderTransAlpha,alpha)
	}
	else {
		set_user_rendering(id,kRenderFxNone,0,0,0,kRenderTransAlpha,alpha)
	}
}
//----------------------------------------------------------------------------------------------
public remInvisibility(id)
{
	gStillTime[id] = -1
	
	if (gIsInvisible[id] > 0) {
		shUnglow(id)
		client_print(id,print_center,"[SH]DarkPredator: You are no longer cloaked")
	}
	
	gIsInvisible[id] = 0
}
//----------------------------------------------------------------------------------------------
public checkButtons()
{
	if ( !hasRoundStarted() || !sh_is_active()) return
	
	new bool:setVisible
	new butnprs
	
	for(new id = 1; id < sh_maxplayers()+1; id++) {
		if (!is_user_alive(id) || !sh_user_has_hero(id,gHeroID)) continue
		
		setVisible = false
		butnprs = entity_get_int(id, EV_INT_button)
		
		//Always check these
		if (butnprs&IN_ATTACK || butnprs&IN_ATTACK2 || butnprs&IN_RELOAD || butnprs&IN_USE) setVisible = true
		
		//Only check these if darkpredator_checkmove is off
		if ( get_cvar_num("darkpred_checkmove") ) {
			if (butnprs&IN_JUMP) setVisible = true
			if (butnprs&IN_FORWARD || butnprs&IN_BACK || butnprs&IN_LEFT || butnprs&IN_RIGHT) setVisible = true
			if (butnprs&IN_MOVELEFT || butnprs&IN_MOVERIGHT) setVisible = true
		}
		
		if (setVisible) remInvisibility(id)
		else {
			new sysTime = get_systime()
			new delay = get_cvar_num("darkpred_delay")
			
			if ( gStillTime[id] < 0 ) {
				gStillTime[id] = sysTime
			}
			if ( sysTime - delay >= gStillTime[id] ) {
				if (gIsInvisible[id] != 100) client_print(id,print_center,"[SH]DarkPredator: 100%s cloaked", "%")
				gIsInvisible[id] = 100
				setInvisibility(id, get_cvar_num("darkpred_alpha"))
			}
			else if ( sysTime > gStillTime[id] ) {
				new alpha = get_cvar_num("darkpred_alpha")
				new Float:prcnt =  float(sysTime - gStillTime[id]) / float(delay)
				new rPercent = floatround(prcnt * 100)
				alpha = floatround(255 - ((255 - alpha) * prcnt) )
				client_print(id,print_center,"[SH]DarkPredator: %d%s cloaked", rPercent, "%")
				gIsInvisible[id] = rPercent
				setInvisibility(id, alpha)
			}
		}
	}
}
//----------------------------------------------------------------------------------------------
public changeWeapon(id)
{
	if ( !sh_user_has_hero(id,gHeroID) || !sh_is_active() ) return
	
	new wpnid = read_data(2)
	new clip = read_data(3)
	
	// Never Run Out of Ammo!
	if ( wpnid == CSW_DEAGLE && clip == 0 ) {
		sh_reload_ammo(id)
	}
}
public plugin_cfg(){


	get_cvar_string("leviathan_adminflag", accessLevel, 9)
	sh_register_admin_only_hero(gHeroID,read_flags(accessLevel),MAX_PICKED,
			"You are not an admin. No acess was granted")

}
//----------------------------------------------------------------------------------------------
public darkpred_damage(id)
{
	if (!sh_is_active() || !is_user_alive(id)) return PLUGIN_CONTINUE
	
	new damage = read_data(2)
	new weapon, bodypart, attacker = get_user_attacker(id,weapon,bodypart)
	
	if ( attacker < 0 || attacker > SH_MAXSLOTS||attacker == id ) return PLUGIN_CONTINUE
	
	if ( sh_user_has_hero(attacker,gHeroID) && weapon == CSW_DEAGLE && gBullets[attacker] >= 0 && is_user_alive(id) )
	{ 
		new health = get_user_health(id)
		
		// damage is less than 10% 
		if ( ( (1.0 * damage) / (1.0 * (health + damage) ) ) < 0.01 ) return PLUGIN_CONTINUE 
		
		new origin[3] 
		get_user_origin(id, origin) 
		
		// player fades.. 
		set_user_rendering(id, kRenderFxFadeSlow, 255, 255, 255, kRenderTransColor, 4); 
		
		// beeeg explody! 
		message_begin(MSG_ALL, SVC_TEMPENTITY) 
		write_byte(3)			// TE_EXPLOSION 
		write_coord(origin[0]) 
		write_coord(origin[1]) 
		write_coord(origin[2]-22) 
		write_short(blast_shroom)	// mushroom cloud 
		write_byte(40)			// scale in 0.1's
		write_byte(12)			// frame rate 
		write_byte(12)			// TE_EXPLFLAG_NOPARTICLES & TE_EXPLFLAG_NOSOUND 
		message_end() 
		
		// do turn down that awful racket..to be replaced by a blood spurt! 
		message_begin(MSG_ALL, SVC_TEMPENTITY) 
		write_byte(10)	// TE_LAVASPLASH 
		write_coord(origin[0]) 
		write_coord(origin[1]) 
		write_coord(origin[2]-26) 
		message_end() 
		
		// kill victim
		user_kill(id, 1)
		
		message_begin( MSG_ALL, get_user_msgid("DeathMsg"),{0,0,0},0 )
		write_byte(attacker)
		write_byte(id)
		write_byte(0)
		write_string("Puta_de_jarda_na_boca")
		message_end()
		
		//Save Hummiliation
		new namea[24],namev[24],authida[20],authidv[20],teama[8],teamv[8]
		//Info On Attacker
		get_user_name(attacker,namea,23) 
		get_user_team(attacker,teama,7) 
		get_user_authid(attacker,authida,19)
		//Info On Victim
		get_user_name(id,namev,23) 
		get_user_team(id,teamv,7) 
		get_user_authid(id,authidv,19)
		//Log This Kill
		log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"Dark Deagle^"", 
		namea,get_user_userid(attacker),authida,teama,namev,get_user_userid(id),authidv,teamv)		  
		
		// team check! 
		new attacker_team[2], victim_team[2]
		get_user_team(attacker, attacker_team, 1) 
		get_user_team(id, victim_team, 1) 
		
		// for some reason this doesn't update in the hud until the next round.. whatever. 
		if (!equali(attacker_team, victim_team)) 
		{ 
			// diff. team;	$attacker gets credited for the kill and $250 and XP.
			//		$id gets their suicidal -1 frag back. 
			set_user_frags(attacker, get_user_frags(attacker)+1)
			cs_set_user_money(attacker, cs_get_user_money(attacker)+150)
			shAddXP(attacker, id, 1.0)
		} 
		else{
			// same team;	$attacker loses a frag and $500 and XP.
			set_user_frags(attacker, get_user_frags(attacker)-1)
			cs_set_user_money(attacker, cs_get_user_money(attacker)-500, 0)
			shAddXP(attacker, id, -1.0)
		}
		return PLUGIN_CONTINUE
	} 
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public darkpred_fire(id)
{ 
	
	if ( !sh_user_has_hero(id,gHeroID) ) return PLUGIN_CONTINUE 
	
	new weap = read_data(2)		// id of the weapon 
	new ammo = read_data(3)		// ammo left in clip 
	
	if ( weap == CSW_DEAGLE && is_user_alive(id) )
	{
		if (gLastWeapon[id] == 0) gLastWeapon[id] = weap 
		
		if ( gLastClipCount[id] > ammo && gLastWeapon[id] == weap && gBullets[id] > 0 )
		{ 
			new vec1[3], vec2[3] 
			get_user_origin(id, vec1, 1) // origin; where you are 
			get_user_origin(id, vec2, 4) // termina; where your bullet goes 
			
			// tracer beam 
			message_begin(MSG_PAS, SVC_TEMPENTITY, vec1) 
			write_byte(0)		// TE_BEAMPOINTS 
			write_coord(vec1[0]) 
			write_coord(vec1[1]) 
			write_coord(vec1[2]) 
			write_coord(vec2[0]) 
			write_coord(vec2[1]) 
			write_coord(vec2[2]) 
			write_short(laser)	// laserbeam sprite 
			write_byte(0)		// starting frame 
			write_byte(10)		// frame rate 
			write_byte(2)		// life in 0.1s 
			write_byte(4)		// line width in 0.1u 
			write_byte(1)		// noise in 0.1u 
			write_byte(255)		// red
			write_byte(0)		// green 
			write_byte(0)		// blue
			write_byte(80)		// brightness 
			write_byte(100)		// scroll speed 
			message_end() 
			
			// bullet impact explosion 
			message_begin(MSG_PAS, SVC_TEMPENTITY, vec2) 
			write_byte(3)		// TE_EXPLOSION 
			write_coord(vec2[0])	// end point of beam 
			write_coord(vec2[1]) 
			write_coord(vec2[2]) 
			write_short(laser_impact)	// blast sprite 
			write_byte(10)			// scale in 0.1u 
			write_byte(30)			// frame rate 
			write_byte(8)			// TE_EXPLFLAG_NOPARTICLES 
			message_end()			// ..unless i'm mistaken, noparticles helps avoid a crash
			
			gBullets[id]--
			client_print(id,print_center,"You Have %d bullet(s) left",gBullets[id])
			
			if ( gBullets[id] == 0 ) gBullets[id] = -1
		}
		
		gLastClipCount[id] = ammo
		gLastWeapon[id] = weap
	}
	return PLUGIN_CONTINUE 
}
//----------------------------------------------------------------------------------------------
public darkpred_deagle(id)
{
		sh_give_weapon(id, CSW_DEAGLE)
}
//----------------------------------------------------------------------------------------------
public darkpred_esploop()
{
	if (!sh_is_active()) return
	
	new players[SH_MAXSLOTS]
	new pnum, vec1[3]
	new idring, id
	
	gRadius = get_cvar_num("darkpred_radius")
	gBright = get_cvar_num("darkpred_bright")
	
	get_players(players,pnum,"a")
	
	for(new i = 0; i < pnum; i++) {
		idring = players[i]
		if (!is_user_alive(idring)) continue
		if (!get_user_origin(idring,vec1,0)) continue
		for (new j = 0; j < pnum; j++) {
			id = players[j]
			if (!sh_user_has_hero(id,gHeroID)) continue
			if (!is_user_alive(id)) continue
			if (idring == id) continue
			message_begin(MSG_ONE,SVC_TEMPENTITY,vec1,id)
			write_byte( 21 )
			write_coord(vec1[0])
			write_coord(vec1[1])
			write_coord(vec1[2] + 16)
			write_coord(vec1[0])
			write_coord(vec1[1])
			write_coord(vec1[2] + gRadius )
			write_short( gSpriteWhite )
			write_byte( 0 ) // startframe
			write_byte( 1 ) // framerate
			write_byte( 6 ) // 3 life 2
			write_byte( 8 ) // width 16
			write_byte( 1 ) // noise
			write_byte( 255 ) // r
			write_byte( 215 ) // g
			write_byte( 0 ) // b
			write_byte( gBright ) //brightness
			write_byte( 0 ) // speed
			message_end()
		}
	}
}
//----------------------------------------------------------------------------------------------
public darkpred_loop()
{
	if (!sh_is_active()) return
	for ( new id = 1; id <= SH_MAXSLOTS; id++ ) {
		if (  sh_user_has_hero(id,gHeroID) && is_user_alive(id)  )   {
			// Let the server add the hps back since the # of max hps is controlled by it
			// I.E. Superman has more than 100 hps etc.
			shAddHPs(id, gHealPoints,sh_get_max_hp(id))
		}
	}
}