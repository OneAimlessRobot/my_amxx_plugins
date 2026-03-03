// Naruto Uzumaki (Shadow Clone Jutsu Version)

/* CVARS - copy and paste to shconfig.cfg

//Naruto Uzumaki
naruto_level 25
naruto_damage 1		//The amount of damage each bullet does
naruto_rdamage 100	//The Rasengan damage
naruto_cooldown 20	//The time players have to wait to summon the shadow clone again
naruto_delayshot 0.1	//How fast the shadow clone shoots his gun, the lower the number, the faster the gun shoots
naruto_maxchakra 15	//The max chakra the player can use
naruto_rasengancost 7	//How much chakra the Rasengan uses
naruto_sfxradius 100	//Summon effects radius, how far the cylinder goes while a player is summoning
naruto_hitchance 65	//How often the shadow clone hits its target the given percentage

*//*

	Change Log:
	------------------

	v 0.9.29 beta - August 12 ,2010
		- modified where and how the shadow clone would spawn
	v 0.9.28 beta - August 11 ,2010
		- added another check to check if there is a shadow clone without an owner
		- added a return function on bot death
		- modified think function
		- removed a paradox that made no sense that was added in the last update
	v 0.9.2 beta - August 10 ,2010
		- removed all friction modifiers from the last update
		- added another check to see if players don't have Naruto but still have bot
	v 0.9.0 beta - August 10 ,2010
		- improved the showdow clone's move function
		- optimized various parts of the code
		- removed the need the modify the bots origin due to it getting stuck
	v 0.8.43 beta - August 7 ,2010
		- fixed a minor run time error
		- changed function so the weapon removes before the shadow clone
	v 0.8.42 beta - August 7 ,2010
		- fixed another minor bug
	v 0.8.41 beta - August 7 ,2010
		- fixed a minor bug that was accidentally added in the last version
	v 0.8.4 beta - August 7 ,2010
		- removed useless bools
		- using fm_remove_entity(index) instead of engfunc(EngFunc_RemoveEntity,index)
		- added new stock naruto_remove_entity(index) to set the entities to the right conditions before removing them
	v 0.8.3 beta - August 6, 2010
		- optimized code
		- weakened shadow clone
		- all known major and minor crash problems have been fixed
		- modified sprite
	v 0.8.2 beta - August 3, 2010
		- added more checks to prevent crashes
		- removed death animation function and replaced it with a sound, just like in the anime
		- fixed a minor disconnection error
	v 0.8.0 beta - August 2, 2010	
		- optimized code
		- added more checks
		- added new bools for better checking
		- added new sounds
	v 0.7.0 beta - August 1, 2010
		- resumed project
		- modified health function
		- rennamed to Naruto Uzumaki (Shadow Clone Jutsu Version) anything referencing a Puppet is
		  now referenced as a Shadow Clone
		- the shadow clone's walk function is smoother and more efficient
		- added rasengan function!
		- added a defect function to help reduce server crashes
	v 0.6.5 beta - July 24, 2009
		- fixed a small runtime error with the cs_get_user_team native by adding a small check
		  to see if the owner is in the server and is alive
	v 0.6.4 beta - July 22, 2009
		- fixed a problem that would cause a server crash when the puppet owner would
		  type 'kill' in his console by using a different method than sh_client_death
	v 0.6.31 beta - July 20, 2009
		- a minor message fix
	v 0.6.3 beta - July 20, 2009
		- now the puppet will successfully hit players at a given success rate via pcvar
		- removed a small bug where the puppet would still be alive after its owner has died
	v 0.6.2 beta - July 18, 2009
		- fixed a rare case where players would disconnect and crash the server
		- added an extra check to see if players have the puppet upon disconnection
	v 0.5.3 beta - July 10, 2009
		- cooldown now takes place after bot dies
		- fixed a case where the cooldown would not reset on spawn
	v 0.5.1 beta - July 8, 2009
		- fixed minor problem where bot would crouch and it's origin would be skewed 
		- added some movement function checks and fixes to help the bot run smoothly
	v 0.5 beta - July 6, 2009
		- slight changes to the movement function to make it more efficient
		- fixed some glitches in the bots origin while ducking and standing
	v 0.4.6 beta - July 4, 2009
		- fixed a problem which would cause the server to crash when players with
		  puppet master would disconnect while the bot is in the process of dying
	v 0.4.53 beta - July 4, 2009
		- updated some parts of the code to prevent some cases causing the server to crash
	v 0.4.5 beta - July 4, 2009
		- rolled back code to v 0.4.3 with some slight improvements
		- versions 0.4.4 till 0.4.5 has major problems where the bot would not function
		  properly most of the time after spawning a second time
	v 0.4.42 beta - July 4, 2009
		- a quickfix to the drophero function
		- fixed a slight code problem where, if players disconnect and doesn't have
		  a bot spawned, the plugin will try to remove an entity that is not there
	v 0.4.4 beta - July 4, 2009
		- added more checks in various functions to tell when bot is dying
		- fixed animation sequence bug where the puppet would show the wrong animation
	v 0.4.3 beta - July 4, 2009
		- fixed a big error when the puppet owner dies, and the bot is triggering the death 
		  fucntion and players kill the bot, which causes the death function to be
		  triggered twice, causing the server to crash
		- fixed problem where puppet would continue to attack players when the owner died
		- added comments on some confusing parts to describe their purpose and function
	v 0.4.2 beta - July 3, 2009
		- fixed a minor runtime error with removing the puppets weapon
	v 0.4.1 beta - July 3, 2009
		- moved onto beta testing
		- hero renamed to Puppet Master
		- added effects to player while summoning a puppet
		- puppet no longer attacks while its not a solid (or when user is inside entity)
		- added sounds to various functions
		- modified the method and function of the puppets death and added animation to it
		- fixed a minor bug where players disconnect and the bot entity is still registered
		- modified the puppets movement function
		- removed useless, repetitive, and ineffective strings
	v 0.3 alpha - July 3, 2009
		- bot now shoots one bullets per every second multiplied by the gun cooldown cvar
		  instead of just shooting bursts of bullets
		- cooldown functions changed
		- fixed more cases when player gets stuck on guardian
	v 0.2 alpha - July 1, 2009
		- guardian now only attacks the person he's aiming at
		- movement function more efficient
		- fixed problems where owner would get stuck within the guardian
		- fixed some cases where guardian would get stuck on the floor while walking
		- made it possible for owner to walk through guardian
		- changed gun model
		- cleaned up code
	v 0.1 alpha - June 30, 2009
		- alpha testing
		- created
*/

#include "../my_include/superheromod.inc"
#include <chr_engine>
#include <fakemeta_util>

// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Naruto Uzumaki"
new bool:gHasNaruto[SH_MAXSLOTS+1]
new bool:aimtargetfound[SH_MAXSLOTS+1] = false
new bool:doingrasengan[SH_MAXSLOTS+1] = false
new bool:rasenganover[SH_MAXSLOTS+1] = false
new bool:bot_summonwait[SH_MAXSLOTS+1] = false
new bool:roundfreeze
new player_chakra[SH_MAXSLOTS+1] = 0
new bot_cooldownwait[SH_MAXSLOTS+1] = 0
new botEnt[SH_MAXSLOTS+1]
new entWeapon[SH_MAXSLOTS+1]
new DoOnce[SH_MAXSLOTS+1]
new round_delay
new gSpriteCircle, gSpriteSmoke
new pCvardamage, pCvarrdamage
new pCvarCooldown, pCvarGunCooldown
new pCvarMaxChakra, pCvarRasenganCost
new pCvarSFXRadius, pCvarHitChance

public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Naruto Uzumaki","0.9.29b","1sh0t2killz")

	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	new pcvarLevel 		= 	register_cvar("naruto_level", "4")
	pCvardamage 		= 	register_cvar("naruto_damage", "1")
	pCvarrdamage		= 	register_cvar("naruto_rdamage", "100")
	pCvarCooldown 		= 	register_cvar("naruto_cooldown", "20")
	pCvarGunCooldown 	= 	register_cvar("naruto_delayshot", "0.1")
	pCvarMaxChakra 		= 	register_cvar("naruto_maxchakra", "15")
	pCvarRasenganCost 	= 	register_cvar("naruto_rasengancost", "7")
	pCvarSFXRadius 		= 	register_cvar("naruto_sfxradius", "100")
	pCvarHitChance 		= 	register_cvar("naruto_hitchance", "65")

	// FIRE THE EVENTS TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_info(gHeroID, "Shadow Clone Jutsu", "Summon a shadow clone which follows you and shoots down any nearby enemies with his gun, press keydown again to use the rasengan")
	sh_set_hero_bind(gHeroID)
	
	// EVENTS
	register_logevent("round_start", 2, "1=Round_Start")
	register_logevent("round_end", 2, "1=Round_End")
	register_logevent("round_end", 2, "1&Restart_Round_")
	
	// LOOP
	set_task(1.0, "naruto_loop", _, _, _, "b")
	
	// Register Thinks
	register_forward(FM_Think,"FM_Think_hook")
}

public plugin_precache()
{
	precache_model("models/shmod/t800_minigun.mdl")
	precache_model("sprites/shmod/esf_exp_blue.spr")
	precache_sound("weapons/m249-1.wav")
	precache_sound("shmod/naruto/rasengan1.wav")
	precache_sound("shmod/naruto/rasengan2.wav")
	precache_sound("shmod/naruto/rasenganexp.wav")
	precache_sound("shmod/naruto/narutoclonesd.wav")
	precache_sound("shmod/naruto/narutoclone.wav")
	gSpriteCircle = precache_model("sprites/shockwave.spr")
	gSpriteSmoke = precache_model("sprites/wall_puff4.spr")
}

public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return

	switch(mode) {
		case SH_HERO_ADD: {
			gHasNaruto[id] = true
			bot_cooldownwait[id] = 0
			sh_chat_message(id, gHeroID, "Believe it!")
		}
		case SH_HERO_DROP: {
			gHasNaruto[id] = false
		}
	}

	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}

public naruto_loop()
{
	if ( !sh_is_active() ) return

	static players[SH_MAXSLOTS], playerCount, player, i
	get_players(players, playerCount, "ah")

	for ( i = 0; i < playerCount; i++ ) {
		player = players[i]

		if ( gHasNaruto[player] && player_chakra[player] < get_pcvar_num(pCvarMaxChakra) ) {
			player_chakra[player] += 1
		}
	}
}

public round_start()
{
	roundfreeze = false
	
	if ( !round_delay) 
	{
		round_delay = 1
		set_task(5.0,"roundstart_delay")
	}
}

public sh_client_spawn(id)
{
	gPlayerInCooldown[id] = false
	aimtargetfound[id] = false
	player_chakra[id] = 0
	
	if (bot_cooldownwait[id] > 0)
	{
		bot_cooldownwait[id] = 0
	}
}

public roundstart_delay()
{
	round_delay = 0
}

public round_end()
{
	roundfreeze = true
}

public sh_client_death(id)
{
	if(botEnt[id] && pev_valid(botEnt[id]))
	{	
		if( pev_valid(entWeapon[id]) ) 
		{
			naruto_remove_entity(entWeapon[id])
		}
		if( pev_valid(botEnt[id]) )
		{
			naruto_remove_entity(botEnt[id])
			botent_clearbools(id)
			
			emit_sound(id, CHAN_ITEM, "shmod/naruto/narutoclonesd.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			emit_sound(id, CHAN_STATIC, "shmod/naruto/narutoclonesd.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
	}
}

public botent_clearbools(id)
{
	if( pev_valid(entWeapon[id]) ) 	//another check to make sure the weapon
	{
		naruto_remove_entity(entWeapon[id])
	}
	if(pev_valid(botEnt[id]))	//another check to make sure the bot is gone
	{
		naruto_remove_entity(botEnt[id])
	}
	botEnt[id] = 0
}

public sh_hero_key(id, heroID, key)
{
	if ( gHeroID != heroID || !sh_is_inround() ) return
	if ( !is_user_alive(id) || !gHasNaruto[id] ) return

	if ( key == SH_KEYDOWN ) 
	{
		if (bot_summonwait[id])
		{
			sh_chat_message(id, gHeroID, "You have already summoned a shadow clone, he will be here shortly")
			sh_sound_deny(id)
			return
		}
		if (roundfreeze || round_delay) 
		{
			sh_chat_message(id, gHeroID, "You must wait 5 seconds after the round has started to summon")
			sh_sound_deny(id)
			return
		}
		if (botEnt[id] && doingrasengan[id] == false && aimtargetfound[id] == true && player_chakra[id] >= get_pcvar_num(pCvarRasenganCost))
		{
			sh_chat_message(id, gHeroID, "Rasengan!")
			naruto_rasengan(id)
			player_chakra[id] -= get_pcvar_num(pCvarRasenganCost)
			
			if ( pev_valid(entWeapon[id]) )
			{
				entity_set_model(entWeapon[id], "sprites/shmod/esf_exp_blue.spr")
				entity_set_int(entWeapon[id], EV_INT_rendermode, 5) 
				entity_set_float(entWeapon[id], EV_FL_renderamt, 255.0)
			}
			
			new rsound = random_num(1,2)
			
			switch(rsound)
			{
				case 1: 
				{
					emit_sound(id, CHAN_ITEM, "shmod/naruto/rasengan1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					emit_sound(id, CHAN_STATIC, "shmod/naruto/rasengan1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					emit_sound(botEnt[id], CHAN_ITEM, "shmod/naruto/rasengan1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					emit_sound(botEnt[id], CHAN_STATIC, "shmod/naruto/rasengan1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
				case 2: 
				{
					emit_sound(id, CHAN_ITEM, "shmod/naruto/rasengan2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					emit_sound(id, CHAN_STATIC, "shmod/naruto/rasengan2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					emit_sound(botEnt[id], CHAN_ITEM, "shmod/naruto/rasengan2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					emit_sound(botEnt[id], CHAN_STATIC, "shmod/naruto/rasengan2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
			}
			
			set_task(2.0, "rasenganmissed", id)

			return
		} else if (botEnt[id] && player_chakra[id] < get_pcvar_num(pCvarRasenganCost))
		{
			sh_chat_message(id, gHeroID, "You need to rest before using your Rasengan again.")
			sh_sound_deny(id)
			return
		}else if (botEnt[id])
		{
			sh_sound_deny(id)
			return
		}
		else if (halflife_time()-bot_cooldownwait[id] < get_pcvar_num(pCvarCooldown))
		{
			sh_chat_message(id, gHeroID, "You must wait a couple of moments to summon another shadow clone")
			sh_sound_deny(id)
			return
		}
		else if(!is_user_alive(id))
		{
			sh_chat_message(id, gHeroID, "You have to be alive to perform the shadow clone jutsu")
			sh_sound_deny(id)
			return
		}
		sh_chat_message(id, gHeroID, "Shadow Clone Jutsu!")
		set_task( 3.0, "shadowclone", id)
		bot_summonwait[id] = true
		
		summoning_ring_effects(id)
		set_task(0.2,"summoning_ring_effects",id)
		set_task(0.4,"summoning_ring_effects",id)
		set_task(0.6,"summoning_ring_effects",id)
		set_task(0.8,"summoning_ring_effects",id)
		set_task(1.0,"summoning_ring_effects",id)
		set_task(1.2,"summoning_ring_effects",id)
		set_task(1.4,"summoning_ring_effects",id)
		set_task(1.6,"summoning_ring_effects",id)
		set_task(1.8,"summoning_ring_effects",id)
		set_task(2.0,"summoning_ring_effects",id)
		set_task(2.2,"summoning_ring_effects",id)
		set_task(2.4,"summoning_ring_effects",id)
		set_task(2.6,"summoning_ring_effects",id)
		set_task(2.8,"summoning_ring_effects",id)
		
		emit_sound(id, CHAN_ITEM, "shmod/naruto/narutoclone.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(id, CHAN_STATIC, "shmod/naruto/narutoclone.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
}

public client_authorized(id)
{
	gHasNaruto[id] = false
	botEnt[id] = 0
}

public client_disconnected(id) 
{
	if(! gHasNaruto[id]) return 

	if(pev_valid(entWeapon[id]))
	{
		naruto_remove_entity(entWeapon[id])
	}
	if(pev_valid(botEnt[id]))
	{
		naruto_remove_entity(botEnt[id])
		botent_clearbools(id)
	}
}

public naruto_rasengan(id)
{
	doingrasengan[id] = true
}

public shadowclone(id)
{
	if (!is_user_alive(id)) 
	{
		sh_chat_message(id, gHeroID, "You have to be alive to summon a shadow clone")
		sh_sound_deny(id)
		bot_summonwait[id] = false
		return
	}
	
	botEnt[id] = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
	set_pev(botEnt[id],pev_classname,"npc_shadowclone")

	new model[32],modelchange[128]
	get_user_info(id,"model",model,31)
	format(modelchange,127,"models/player/%s/%s.mdl",model,model)
	sh_chat_message(id, gHeroID, "Your shadow clone has arrived")
	engfunc(EngFunc_SetModel,botEnt[id],modelchange)
	//This will make it so that the ent appears in front of the user	
	new Float:fl_Origin[3], Float:viewing_angles[3]
	new distance_from_user = 70
	entity_get_vector(id, EV_VEC_angles, viewing_angles)
	fl_Origin[0] += (floatcos(viewing_angles[1], degrees) * distance_from_user)
	fl_Origin[1] += (floatsin(viewing_angles[1], degrees) * distance_from_user)
	fl_Origin[2] += (floatsin(-viewing_angles[0], degrees) * distance_from_user)+70
	new Float:spawnorigin[3]
	pev(id,pev_origin,spawnorigin)
	
	new Float:tmpVec[3] 
	tmpVec[0] = 20.0
	tmpVec[1] = 20.0
	tmpVec[2] = 40.0
	set_pev(botEnt[id],pev_size,tmpVec)
	
	set_pev(botEnt[id],pev_health, 5000000.0)
	set_pev(botEnt[id],pev_takedamage, 1.0)
	set_pev(botEnt[id],pev_dmg_take, 1.0)

	give_weapon(botEnt[id],id)
	if(is_user_crouching(id)) spawnorigin[2] += 2.0
	else spawnorigin[2] += 2.0
	set_pev(botEnt[id],pev_origin,fl_Origin)
	set_pev(botEnt[id],pev_solid, SOLID_BBOX)
	set_pev(botEnt[id],pev_movetype,MOVETYPE_NOCLIP)
	set_pev(botEnt[id],pev_owner,33)
	set_pev(botEnt[id],pev_nextthink,get_gametime() + 0.1)
	set_pev(botEnt[id],pev_sequence,1)
	set_pev(botEnt[id],pev_gaitsequence,1)
	set_pev(botEnt[id],pev_framerate,1.0)

	emit_sound(id, CHAN_ITEM, "shmod/naruto/narutoclonesd.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(id, CHAN_STATIC, "shmod/naruto/narutoclonesd.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

	bot_summonwait[id] = false
}

public give_weapon(ent,id)
{
	entWeapon[id] = create_entity("info_target")
	
	entity_set_string(entWeapon[id], EV_SZ_classname, "npc_weapon")
	
	entity_set_int(entWeapon[id], EV_INT_movetype, MOVETYPE_FOLLOW)
	entity_set_int(entWeapon[id], EV_INT_solid, SOLID_NOT)
	entity_set_edict(entWeapon[id], EV_ENT_aiment, ent)
	entity_set_model(entWeapon[id], "models/shmod/t800_minigun.mdl")
	entity_set_int(entWeapon[id], EV_INT_rendermode, kRenderFxNone) 
	entity_set_float(entWeapon[id], EV_FL_renderamt, 255.0)
}

public FM_Think_hook(ent)
{
	for(new i=0;i<=SH_MAXSLOTS;i++)
	{	
		if(gHasNaruto[i]) 
		{
			if(ent==botEnt[i])
			{
				if (pev_valid(botEnt[i]) && pev_valid(ent))
				{
					if (roundfreeze || round_delay) 
					{
						if(pev_valid(ent) && ent==botEnt[i])
						{
							set_pev(botEnt[i],pev_health, 5000000.0)
						}
					}
					if(!pev_valid(botEnt[i]) && gHasNaruto[i] && ent==botEnt[i])
					{
						naruto_remove_entity(entWeapon[i])
						naruto_remove_entity(botEnt[i])
						botent_clearbools(i)
	
						sh_chat_message(i, gHeroID, "Your shadow clone defected! He will now vanish.")
						
						return FMRES_IGNORED
					}
					if(pev_valid(ent) && ent==botEnt[i])
					{
						static Float:origin[3]
						static Float:origin2[3]
						static Float:velocity[3]
						new Float: Naruto_Distance = get_distance_f(origin,origin2)
						pev(ent,pev_origin,origin2)
						get_offset_origin_body(i,Float:{0.0,0.0,0.0},origin)
						if(is_user_crouching(i)) origin[2] += 2.0
						else origin[2] += 2.0
						
						new Float:MinBox[3]
						new Float:MaxBox[3]
						
						if (is_user_crouching(i)) {
							MinBox[0] = -20.0 
							MinBox[1] = -20.0 
							MinBox[2] = -20.0 
							MaxBox[0] = 20.0 
							MaxBox[1] = 20.0 
							MaxBox[2] = 20.0 
						}else{
							MinBox[0] = -20.0 
							MinBox[1] = -20.0 
							MinBox[2] = -38.0 
							MaxBox[0] = 20.0 
							MaxBox[1] = 20.0 
							MaxBox[2] = 40.0 
						}
						set_pev(ent,pev_mins, MinBox) 
						set_pev(ent,pev_maxs, MaxBox) 
			
						//check health and remove entity with some effects       
						new health = pev(ent,pev_health) 
						
						if( health <= 4999800.0 ) 
						{
							if( pev_valid(entWeapon[i]))
							{
								naruto_remove_entity(entWeapon[i])
							}
							if( pev_valid(botEnt[i])) 
							{
								naruto_remove_entity(botEnt[i])
								botent_clearbools(i)
								bot_cooldownwait[i] = floatround(halflife_time())
								
								emit_sound(i, CHAN_ITEM, "shmod/naruto/narutoclonesd.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
								emit_sound(i, CHAN_STATIC, "shmod/naruto/narutoclonesd.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
							}
							return FMRES_IGNORED
						}
						find_target(ent,i)
					
						if (rasenganover[i] == true)
						{
							doingrasengan[i] = false
							rasenganover[i] = false
							entity_set_model(entWeapon[i], "models/shmod/t800_minigun.mdl")
							entity_set_int(entWeapon[i], EV_INT_rendermode, kRenderFxNone) 
							entity_set_float(entWeapon[i], EV_FL_renderamt, 255.0)
						}
							
						if (doingrasengan[i] == false && pev_valid(ent) && botEnt[i])
						{
							if(get_user_button(i)&IN_DUCK && pev(ent,pev_solid) != SOLID_NOT)
							{
								if (DoOnce[i]) {
									origin2[2] -= 20
									set_pev(ent,pev_origin,origin2)
									DoOnce[i] = false
								}
								set_pev(ent,pev_sequence,5)
								set_pev(ent,pev_gaitsequence,5)
								set_pev(ent,pev_framerate,1.0)
							} 
							else if(get_user_button(i)&IN_DUCK && pev(ent,pev_solid) == SOLID_NOT)
							{
								if (DoOnce[i]) {
									origin2[2] -= 20
									set_pev(ent,pev_origin,origin2)
									DoOnce[i]=false
								}
								set_pev(ent,pev_sequence,2)
								set_pev(ent,pev_gaitsequence,2)
								set_pev(ent,pev_framerate,1.0)
							} else if (!DoOnce[i] && !is_user_crouching(i))
							{	
								origin2[2] += 20
								set_pev(ent,pev_origin,origin2)
								DoOnce[i] = true
				
							} else if(get_user_button(i)&IN_JUMP)
							{
								set_pev(ent,pev_sequence,5)
								set_pev(ent,pev_gaitsequence,5)
								set_pev(ent,pev_framerate,1.0)
							} 
							else if(Naruto_Distance>=95.0)
							{
								set_pev(ent,pev_sequence,4)
								set_pev(ent,pev_gaitsequence,4)
								set_pev(ent,pev_framerate,1.0)
							} 
							else if(Naruto_Distance<95.0)
							{
								set_pev(ent,pev_sequence,1)
								set_pev(ent,pev_gaitsequence,1)
								set_pev(ent,pev_framerate,1.0)
							} 
							/*else if(pev_valid(ent))
							{
								set_pev(ent,pev_sequence,1)
								set_pev(ent,pev_gaitsequence,1)
								set_pev(ent,pev_framerate,1.0)
							}
							else if(!pev_valid(ent))
							{
								naruto_remove_entity(entWeapon[i])
								naruto_remove_entity(botEnt[i])
								botent_clearbools(i)
								
								sh_chat_message(i, gHeroID, "Your shadow clone defected! He will now vanish.")
								
								return FMRES_IGNORED
							}
							else
							{
								if( pev_valid(entWeapon[i]))
								{
									naruto_remove_entity(entWeapon[i])
								}
								if( pev_valid(botEnt[i])) 
								{
									naruto_remove_entity(botEnt[i])
									botent_clearbools(i)
								}
								
								sh_chat_message(i, gHeroID, "Your shadow clone defected! He will now vanish.")
								
								return FMRES_IGNORED
							}*/
							
							if(Naruto_Distance>450.0)
							{
								set_pev(ent,pev_origin,origin)
							}
							else if(Naruto_Distance>375.0)
							{ 
								get_speed_vector(origin2,origin,2000.0,velocity)
								set_pev(ent,pev_velocity,velocity)
				
								if(pev(ent,pev_solid) != SOLID_BBOX)
								{
									set_pev(ent,pev_solid, SOLID_BBOX)
								}
							}
							else if(Naruto_Distance>350.0)
							{ 
								get_speed_vector(origin2,origin,get_user_maxspeed(i)*2.0,velocity)
								set_pev(ent,pev_velocity,velocity)
								
								if(pev(ent,pev_solid) != SOLID_BBOX)
								{
									set_pev(ent,pev_solid, SOLID_BBOX)
								}
							}
							else if(Naruto_Distance>300.0)
							{ 
								get_speed_vector(origin2,origin,get_user_maxspeed(i)+200.0,velocity)
								set_pev(ent,pev_velocity,velocity)
								
								if(pev(ent,pev_solid) != SOLID_BBOX)
								{
									set_pev(ent,pev_solid, SOLID_BBOX)
								}
							}
							else if(Naruto_Distance>250.0)
							{ 
								get_speed_vector(origin2,origin,get_user_maxspeed(i)+140.0,velocity)
								set_pev(ent,pev_velocity,velocity)
				
								if(pev(ent,pev_solid) != SOLID_BBOX)
								{
									set_pev(ent,pev_solid, SOLID_BBOX)
								}
							}
							else if(Naruto_Distance>200.0)
							{ 
								get_speed_vector(origin2,origin,get_user_maxspeed(i)+75.0,velocity)
								set_pev(ent,pev_velocity,velocity)
				
								if(pev(ent,pev_solid) != SOLID_BBOX)
								{
									set_pev(ent,pev_solid, SOLID_BBOX)
								}
							}
							else if(Naruto_Distance>140.0)
							{
								get_speed_vector(origin2,origin,get_user_maxspeed(i)+55.0,velocity)
								set_pev(ent,pev_velocity,velocity)
				
								if(pev(ent,pev_solid) != SOLID_BBOX)
								{
									set_pev(ent,pev_solid, SOLID_BBOX)
								}
							}
							else if(Naruto_Distance>120.0)
							{
								get_speed_vector(origin2,origin,get_user_maxspeed(i)-20.0,velocity)
								set_pev(ent,pev_velocity,velocity)
				
								if(pev(ent,pev_solid) != SOLID_BBOX)
								{
									set_pev(ent,pev_solid, SOLID_BBOX)
								}
							}
							else if(Naruto_Distance>=95.0)
							{
								get_speed_vector(origin2,origin,get_user_maxspeed(i)-20.0,velocity)
								set_pev(ent,pev_velocity,velocity)
				
								if(pev(ent,pev_solid) != SOLID_BBOX)
								{
									set_pev(ent,pev_solid, SOLID_BBOX)
								}
							}
							else if(Naruto_Distance>=75.0)
							{
								drop_to_floor(ent)
				
								set_pev(ent,pev_velocity,Float:{0.0,0.0,0.0})
								
								if(pev(ent,pev_solid) != SOLID_BBOX)
								{
									set_pev(ent,pev_solid, SOLID_BBOX)
								}
							}
							else if(Naruto_Distance<75.0)
							{
								drop_to_floor(ent)
				
								set_pev(ent,pev_velocity,Float:{0.0,0.0,0.0})
								
								if(pev(ent,pev_solid) != SOLID_NOT)
								{
									set_pev(ent,pev_solid, SOLID_NOT)
								}
							}
						}
						set_pev(botEnt[i],pev_nextthink, 0.1)
							
						return FMRES_IGNORED
					}
				}
			}
		} else if (botEnt[i])
		{
			botent_clearbools(i)
		} /*else 
		{	
			return FMRES_IGNORED
		}
		if ((!gHasNaruto[i] && ent==botEnt[i]) || (!is_user_alive(i) && ent==botEnt[i]))
		{
			botent_clearbools(i)	
		}*/
	}
	return FMRES_IGNORED
}

public find_target(ent,i)
{
	if( pev_valid(ent) && ent==botEnt[i] )
	{
		new Float:TargetOrigin[3]
		new Float:entorigin[3]
		new shortestDistance = 1000
		new nearestPlayer = 0
		new distance
		
		pev(ent,pev_origin,entorigin)

		if ( !is_user_alive(i) || !is_user_connected(i) || !pev_valid(i) ) return FMRES_IGNORED
		
		if ( aimtargetfound[i] == false )
		{
			new Float:idorigin[3]
			
			pev(i,pev_origin,idorigin)
			entity_set_aim(ent,idorigin)
		}
		
		// Find the closest enemy
		for (new vic = 0; vic < SH_MAXSLOTS; vic++) {
			if ( !is_user_alive(vic) ) continue

			if ( get_user_team(i) != get_user_team(vic) )
			{
				distance =  get_entity_distance(vic, ent)
	
				if ( distance <= shortestDistance ) {
					shortestDistance = distance
					nearestPlayer = vic
				}
	
				if ( nearestPlayer > 0 ) 
				{
					pev(nearestPlayer ,pev_origin,TargetOrigin)
					TargetOrigin[2] = entorigin[2]
					entity_set_aim(ent,TargetOrigin)
					aimtargetfound[i] = true
					new Float:gun_cooldown = get_pcvar_float(pCvarGunCooldown)
					if (fm_is_ent_visible(ent,nearestPlayer) && !gPlayerInCooldown[i])
					{
						target_found(ent,i,nearestPlayer )
						if ( gun_cooldown > 0.0 ) sh_set_cooldown(i, gun_cooldown)
					}
					return FMRES_IGNORED
				} else {
					aimtargetfound[i] = false
				}
			}
		}
	}
	return FMRES_IGNORED
}

public target_found(ent,owner,target)
{
	if ( !pev_valid(ent) || !pev_valid(owner) || !pev_valid(target) || botEnt[owner] == 0 ) return PLUGIN_HANDLED
	
	new Float:entOrigin[3], Float:targetOrigin[3]
	new Float:entOriginR[3]
	pev(ent,pev_origin,entOrigin)
	pev(target,pev_origin,targetOrigin)
	
	if (doingrasengan[owner] == false)
	{
		tracer(entOrigin, targetOrigin)
		if (random_num(1,100) <= get_pcvar_num(pCvarHitChance))
		{
			duplicate_damage(target,owner)
		}
		emit_sound(ent, CHAN_VOICE, "weapons/m249-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	if (doingrasengan[owner] == true)
	{
		static Float:velocityR[3]
		get_speed_vector(entOrigin,targetOrigin,get_user_maxspeed(owner)+395.0,velocityR)
		set_pev(ent,pev_velocity,velocityR)
		
		set_pev(ent,pev_sequence,8)
		set_pev(ent,pev_gaitsequence,8)
		set_pev(ent,pev_framerate,1.0)

		if(pev(ent,pev_solid) != SOLID_NOT || pev(ent,pev_movetype) != MOVETYPE_NOCLIP)
		{
			set_pev(ent,pev_solid, SOLID_NOT) 
			set_pev(ent,pev_movetype,MOVETYPE_NOCLIP)
		}
		
		if(get_distance_f(entOrigin,targetOrigin)<60.0)
		{
			entity_get_vector(ent, EV_VEC_origin, entOriginR)
			
			new RasenganExp[3]
			RasenganExp[0] = floatround(entOriginR[0])
			RasenganExp[1] = floatround(entOriginR[1])
			RasenganExp[2] = floatround(entOriginR[2])
			
			// Explosion (smoke, sound/effects)
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(3)				//TE_EXPLOSION
			write_coord(RasenganExp[0])
			write_coord(RasenganExp[1])
			write_coord(RasenganExp[2])
			write_short(gSpriteSmoke)		// model
			write_byte(50)				// scale in 0.1's
			write_byte(20)				// framerate
			write_byte(10)				// flags
			message_end()
			
			emit_sound(owner, CHAN_STATIC, "shmod/naruto/rasenganexp.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			emit_sound(ent, CHAN_STATIC, "shmod/naruto/rasenganexp.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			doingrasengan[owner] = false
			rasenganover[owner] = false
			
			if ( pev_valid(entWeapon[owner]) )
			{
				entity_set_model(entWeapon[owner], "models/shmod/t800_minigun.mdl")
				entity_set_int(entWeapon[owner], EV_INT_rendermode, kRenderFxNone) 
				entity_set_float(entWeapon[owner], EV_FL_renderamt, 255.0)
			}
			
			if(pev_valid(target))
			{
				rasengan_damage(target,owner)
				emit_sound(target, CHAN_STATIC, "shmod/naruto/rasenganexp.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		} 
	}
	
	return PLUGIN_HANDLED
}

public rasenganmissed(id)
{
	if (doingrasengan[id] == false) return
	rasenganover[id] = true
	sh_chat_message(id, gHeroID, "Your Rasengan Missed!")
	
	if ( pev_valid(entWeapon[id]) )
	{
		entity_set_model(entWeapon[id], "models/shmod/t800_minigun.mdl")
		entity_set_int(entWeapon[id], EV_INT_rendermode, kRenderFxNone) 
		entity_set_float(entWeapon[id], EV_FL_renderamt, 255.0)
	}
}

public tracer(Float:start[3], Float:end[3]) 
{
	new startx[3], endx[3]
	FVecIVec( start, startx )
	FVecIVec( end, endx )
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( TE_TRACER )
	write_coord( startx[0] )
	write_coord( startx[1] )
	write_coord( startx[2] )
	write_coord( endx[0] )
	write_coord( endx[1] )
	write_coord( endx[2] )
	message_end()
}

public duplicate_damage(id,attacker_id)
{
	sh_extra_damage(id, attacker_id, get_pcvar_num(pCvardamage), "Shadow Clone")
}
public rasengan_damage(id,attacker_id)
{
	sh_extra_damage(id, attacker_id, get_pcvar_num(pCvarrdamage), "Rasengan")
}

public summoning_ring_effects(id)
{
	new summonorigin[3]
	get_user_origin(id,summonorigin)
			
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, summonorigin )
	write_byte( TE_BEAMCYLINDER )
	write_coord( summonorigin[0])
	write_coord( summonorigin[1])
	write_coord( summonorigin[2] - 16)
	write_coord( summonorigin[0])
	write_coord( summonorigin[1])
	write_coord( summonorigin[2] - 16 + ( get_pcvar_num(pCvarSFXRadius) ))
	write_short( gSpriteCircle )
	write_byte( 0 ) 		// startframe
	write_byte( 0 ) 		// framerate
	write_byte( 5 ) 		// life
	write_byte( 150 )  	// width
	write_byte( 0 )		// noise
	write_byte( 255 ) 	// r, g, b
	write_byte( 255 ) 	// r, g, b
	write_byte( 150 ) 	// r, g, b
	write_byte( 220 ) 	// brightness
	write_byte( 0 ) 		// speed
	message_end()
}

stock naruto_remove_entity(index) 
{	
	set_pev(index, pev_solid, SOLID_NOT)

	fm_remove_entity(index)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
