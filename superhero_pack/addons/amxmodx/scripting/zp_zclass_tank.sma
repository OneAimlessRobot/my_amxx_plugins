#include <amxmodx>
#include <zombieplague>
#include <fakemeta>
#include <engine>
#include <fun>
#include <xs>
#include <hamsandwich>
#include <cs_ham_bots_api>
/*                      L4D Tank Zombie
				by x[L]eoNNN
	
	#Description :
	
		this is a Zombie Class of Famous Game, "L4d" with the ability to throw rocks at enemies,
		either killing him, infecting taking life, etc. (controlled by a cvar)
	
	#Cvars :
	
		zp_tank_rockspeed 700 // Rock Speed Launched by Tank
		zp_tank_rockdamage 70 // damage done by the rock
		zp_tank_rockreward 1 // Ammo Pack's Reward by touching the enemy with the rock
		zp_tank_rockmode 1 // Rock Mode :
					1 = Take Damage
					2 = Killing
					3 = Infect
					4 = Bad Aim
		zp_tank_rock_energynesesary 20 // energy nesesary to launch a rock

	#Changelog :
	
		v1.0: public release
		v1.1: print messages changed to hudmessages (for spam), fix time reload bug,add effect touching rock
		v1.2: fix a survivor bugs', To break an entity "func_breakable" when the rock touches the entity, 
		      fix a problem with logs : native error : get_user_origin.
*/

#define PA_LOW  25.0 // min screen shake
#define PA_HIGH 50.0 // max screen shake

new const zclass_name[] = { "L4D Tank Zombie" } 
new const zclass_info[] = { "Launch Rocks" } 
new const zclass_model[] = { "l4d_tank" } 
new const zclass_clawmodel[] = { "v_tank.mdl" } 
const zclass_health = 4800 
const zclass_speed = 440
const Float:zclass_gravity = 0.6 
const Float:zclass_knockback = 0.4  

new g_L4dTank, g_is_tanker[33]

new g_trailSprite, rockmodel
new g_trail[] = "sprites/xbeam3.spr"
new rock_model[] = "models/rockgibs.mdl"
new rock_model2[] = "models/rockgibs.mdl"
new tank_rocklaunch[] = "zombie_plague/tank_rocklaunch.wav"


new g_power[33]

new cvar_rock_damage, cvar_rock_reward, cvar_rockmode, cvar_rockEnergyNesesary, cvar_rock_speed, cvar_reloadpower

public plugin_init()
{
	register_plugin("[ZP] Zombie Class: L4D Tank Zombie", "1.2", "x[L]eoNNN") 
 
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHamBots(Ham_TakeDamage, "fw_TakeDamage") 

	cvar_rock_speed = register_cvar("zp_tank_rockspeed", "700")
	cvar_rock_damage = register_cvar("zp_tank_rockdamage", "70")
	cvar_rock_reward = register_cvar("zp_tank_rockreward", "1")
	cvar_rockmode = register_cvar("zp_tank_rockmode", "1")
	cvar_rockEnergyNesesary = register_cvar("zp_tank_rock_energynesesary", "20")
	cvar_reloadpower = register_cvar("zp_tank_reload_power", "1")
	register_touch("rock_ent","*","RockTouch")
	register_forward(FM_CmdStart, "CmdStart" )
} 

public plugin_precache()
{
	g_L4dTank = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback) 
	g_trailSprite = precache_model(g_trail)
	rockmodel = precache_model(rock_model)
	precache_sound(tank_rocklaunch)
}
	
public zp_user_infected_post ( id, infector )
{
             if (zp_get_user_zombie_class(id) == g_L4dTank)
             {
	     	g_is_tanker[id] = true
		print_chatColor(id, "\g[ZP]\n You Are A \gL4D Tank\n, You Cant Launch Rock With \tIN_USE [+E]") 
		g_power[id] = get_pcvar_num(cvar_rockEnergyNesesary)
		set_task(get_pcvar_float(cvar_reloadpower), "power1", id, _, _, "b")
             }
}  

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
	if ( is_user_alive( attacker ) && get_user_weapon(attacker) == CSW_KNIFE && g_is_tanker[attacker] && zp_get_user_zombie_class(attacker) == g_L4dTank && zp_get_user_zombie(attacker))
	{			
		SetHamParamFloat(4, damage * 2.0 )
		toco(victim, attacker)
	}
}

public toco(iVictim, id)
{
	if(!is_user_alive(id) || !is_user_connected(id) || !zp_get_user_zombie(id) || zp_get_user_nemesis(id) || zp_get_user_zombie_class(id) != g_L4dTank)
		return PLUGIN_HANDLED
	
	if(!is_user_alive(iVictim) || !is_user_connected(iVictim) || zp_get_user_zombie(iVictim) || zp_get_user_nemesis(iVictim))
		return PLUGIN_HANDLED
		
	new Float:start_origin[3], Float:end_origin[3]
	pev(id, pev_origin, start_origin)
	pev(iVictim, pev_origin, end_origin)
	
	start_origin[0] = end_origin[0] - start_origin[0]
	start_origin[1] = end_origin[1] - start_origin[1]
	start_origin[2] = 0.0
	
	xs_vec_normalize(start_origin, end_origin)
	
	end_origin[0] *= 1500.0
	end_origin[1] *= 1000.0
	end_origin[2] = 500.0
	
	set_pev(iVictim, pev_velocity, end_origin)
	
	new hp = get_user_health(iVictim)
	new damage = 10
	
	if(hp > damage)
	{		
		new origin[3]
		get_user_origin(iVictim, origin)
		
		message_begin(MSG_ONE, get_user_msgid("Damage"), _, iVictim)			
		write_byte(21)
		write_byte(20)
		write_long(0)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		message_end()
		
		message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0,0,0}, iVictim)
		write_short(255<<14) // ammount
		write_short(1<<12) // lasts this long
		write_short(255<<14) // frequency
		message_end()
		
		new Float:fVec[3]
		fVec[0] = random_float(PA_LOW, PA_HIGH)
		fVec[1] = 0.0
		fVec[2] = random_float(PA_LOW, PA_HIGH)
		
		set_pev(iVictim, pev_punchangle, fVec)
		
		set_user_health(iVictim, get_user_health(iVictim)-damage)
	}
	else
	{
		user_kill(iVictim, id)
	}
	
	emit_sound(id, CHAN_STREAM, tank_rocklaunch, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	return PLUGIN_HANDLED;
}

public CmdStart( const id, const uc_handle, random_seed )
{
	if(!is_user_alive(id))
		return FMRES_IGNORED;
	
	if(!zp_get_user_zombie(id) || zp_get_user_nemesis(id))
		return FMRES_IGNORED;
		
	new button = pev(id, pev_button)
	new oldbutton = pev(id, pev_oldbuttons)
	
	if (zp_get_user_zombie(id) && (zp_get_user_zombie_class(id) == g_L4dTank))
		if(oldbutton & IN_USE && !(button & IN_USE))
		{
			if(g_power[id] >= get_pcvar_num(cvar_rockEnergyNesesary))
			{
				MakeRock(id)
				emit_sound(id, CHAN_STREAM, tank_rocklaunch, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				g_power[id] = 0
			}
			else
			{
				set_hudmessage(255, 0, 0, 0.0, 0.6, 0, 6.0, 3.0)
				show_hudmessage(id, "[ZP] Energy Nesesary To Launch Rock [%d] || You Energy [%d]", get_pcvar_num(cvar_rockEnergyNesesary), g_power[id])
			}
			
		}
			
	return FMRES_IGNORED
}

public power1(id)
{
	g_power[id] += 1
	
	if( g_power[id] > get_pcvar_num(cvar_rockEnergyNesesary) )
	{
		g_power[id] = get_pcvar_num(cvar_rockEnergyNesesary)
	}
}

public RockTouch( RockEnt, Touched )
{
	if ( !pev_valid ( RockEnt ) )
		return
		
	static Class[ 32 ]
	entity_get_string( Touched, EV_SZ_classname, Class, charsmax( Class ) )
	new Float:origin[3]
		
	pev(Touched,pev_origin,origin)
	
	if( equal( Class, "player" ) )
		if (is_user_alive(Touched))
		{
			if(!zp_get_user_zombie(Touched))
			{
				new TankKiller = entity_get_edict( RockEnt, EV_ENT_owner )
				
				switch(get_pcvar_num(cvar_rockmode))
				{
					case 1: // Health
					{
						new iHealth = get_user_health(Touched)

						if( iHealth >= 1 && iHealth <= get_pcvar_num(cvar_rock_damage))
						{
							ExecuteHamB( Ham_Killed, Touched, TankKiller, 0 )
							print_chatColor(TankKiller, "\g[ZP]\n You Receive \t%d\n Ammo Packs To Reach a Rock a Enemy", get_pcvar_num(cvar_rock_reward))
							zp_set_user_ammo_packs(TankKiller, zp_get_user_ammo_packs(TankKiller) + get_pcvar_num(cvar_rock_reward))
						}
						else
						{
							set_user_health(Touched, get_user_health(Touched) - get_pcvar_num(cvar_rock_damage))
							print_chatColor(TankKiller, "\g[ZP]\n You Receive \t%d\n Ammo Packs To Reach a Rock a Enemy", get_pcvar_num(cvar_rock_reward))
							zp_set_user_ammo_packs(TankKiller, zp_get_user_ammo_packs(TankKiller) + get_pcvar_num(cvar_rock_reward))
						}
					}
					case 2: // Kill
					{
						if(zp_get_user_survivor(Touched))
							return
								
						ExecuteHamB( Ham_Killed, Touched, TankKiller, 0 )
						zp_set_user_ammo_packs(TankKiller, zp_get_user_ammo_packs(TankKiller) + get_pcvar_num(cvar_rock_reward))
						print_chatColor(TankKiller, "\g[ZP]\n You Receive \t%d\n Ammo Packs To Reach a Rock a Enemy", get_pcvar_num(cvar_rock_reward))
					}
					case 3: //infect
					{
						if(zp_get_user_survivor(Touched))
							return
							
						zp_infect_user(Touched, TankKiller, 1, 1)
						print_chatColor(TankKiller, "\g[ZP]\n You Receive \t%d\n Ammo Packs To Reach a Rock a Enemy", get_pcvar_num(cvar_rock_reward))
						zp_set_user_ammo_packs(TankKiller, zp_get_user_ammo_packs(TankKiller) + get_pcvar_num(cvar_rock_reward))

					}
					case 4: //BadAim
					{
						new Float:vec[3] = {100.0,100.0,100.0}
						
						entity_set_vector(Touched,EV_VEC_punchangle,vec)  
						entity_set_vector(Touched,EV_VEC_punchangle,vec)
						entity_set_vector(Touched,EV_VEC_punchangle,vec) 
						
						print_chatColor(TankKiller, "\g[ZP]\n You Receive \t%d\n Ammo Packs To Reach a Rock a Enemy", get_pcvar_num(cvar_rock_reward))
						zp_set_user_ammo_packs(TankKiller, zp_get_user_ammo_packs(TankKiller) + get_pcvar_num(cvar_rock_reward))
						set_task(1.50, "EndVictimAim", Touched)
					}
				}
			}
		}
		
	if(equal(Class, "func_breakable") && entity_get_int(Touched, EV_INT_solid) != SOLID_NOT)
		force_use(RockEnt, Touched)
		
	remove_entity(RockEnt)
	
	if(!is_user_alive(Touched))
		return
		
	static origin1[3]
	get_user_origin(Touched, origin1)
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, origin1);
	write_byte(TE_BREAKMODEL); 
	write_coord(origin1[0]);  
	write_coord(origin1[1]);
	write_coord(origin1[2] + 24); 
	write_coord(16); 
	write_coord(16); 
	write_coord(16); 
	write_coord(random_num(-50,50)); 
	write_coord(random_num(-50,50)); 
	write_coord(25);
	write_byte(10); 
	write_short(rockmodel); 
	write_byte(10); 
	write_byte(25);
	write_byte(0x01); 
	message_end();
}

public EndVictimAim(Touched)
{
	new Float:vec[3] = {-100.0,-100.0,-100.0}
	entity_set_vector(Touched,EV_VEC_punchangle,vec)  
	entity_set_vector(Touched,EV_VEC_punchangle,vec)
	entity_set_vector(Touched,EV_VEC_punchangle,vec)
}

public MakeRock(id)
{
			
	new Float:Origin[3]
	new Float:Velocity[3]
	new Float:vAngle[3]

	new RockSpeed = get_pcvar_num(cvar_rock_speed)

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)

	new NewEnt = create_entity("info_target")

	entity_set_string(NewEnt, EV_SZ_classname, "rock_ent")

	entity_set_model(NewEnt, rock_model2)

	entity_set_size(NewEnt, Float:{-1.5, -1.5, -1.5}, Float:{1.5, 1.5, 1.5})

	entity_set_origin(NewEnt, Origin)
	entity_set_vector(NewEnt, EV_VEC_angles, vAngle)
	entity_set_int(NewEnt, EV_INT_solid, 2)

	entity_set_int(NewEnt, EV_INT_rendermode, 5)
	entity_set_float(NewEnt, EV_FL_renderamt, 200.0)
	entity_set_float(NewEnt, EV_FL_scale, 1.00)

	entity_set_int(NewEnt, EV_INT_movetype, 5)
	entity_set_edict(NewEnt, EV_ENT_owner, id)

	velocity_by_aim(id, RockSpeed  , Velocity)
	entity_set_vector(NewEnt, EV_VEC_velocity ,Velocity)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW) 
	write_short(NewEnt) 
	write_short(g_trailSprite) 
	write_byte(10) 
	write_byte(10) 
	write_byte(255) 
	write_byte(0) 
	write_byte(0) 
	write_byte(200) 
	message_end()
	
	return PLUGIN_HANDLED
}

stock print_chatColor(const id,const input[], any:...)
{
	new msg[191], players[32], count = 1;
	vformat(msg,190,input,3);
	replace_all(msg,190,"\g","^4");// green
	replace_all(msg,190,"\n","^1");// normal
	replace_all(msg,190,"\t","^3");// team
	
	if (id) players[0] = id; else get_players(players,count,"ch");
	for (new i=0;i<count;i++)
	if (is_user_connected(players[i]))
	{
		message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("SayText"),_,players[i]);
		write_byte(players[i]);
		write_string(msg);
		message_end();
	}
} 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
