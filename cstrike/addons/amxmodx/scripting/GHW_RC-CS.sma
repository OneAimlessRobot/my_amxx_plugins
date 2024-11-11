/*
*   _______     _      _  __          __
*  | _____/    | |    | | \ \   __   / /
*  | |         | |    | |  | | /  \ | |
*  | |         | |____| |  | |/ __ \| |
*  | |   ___   | ______ |  |   /  \   |
*  | |  |_  |  | |    | |  |  /    \  |
*  | |    | |  | |    | |  | |      | |
*  | |____| |  | |    | |  | |      | |
*  |_______/   |_|    |_|  \_/      \_/
*
*
*
*  Last Edited: 01-08-09
*
*  ============
*   Changelog:
*  ============
*
*  v1.0b
*    -Minor bug fix
*
*  v1.0
*    -Initial Release
*
*/

#define VERSION	"1.0b"

#define CSTRIKE_MONEY	1

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <fakemeta>
#if CSTRIKE_MONEY
 #include <cstrike>
#endif

#define JUMP_HEIGHT	70.0
#define EXPLOSION_SIZE	500.0
#define HEALTH_OFFSET	100000.0

new bool:can_spawn[33]
new bool:in_control[33]
new car[33]
new car_spec[33]

new rc_maxspeed
new rc_accel
new rc_follow
new rc_explode
new rc_health
new rc_delay
new rc_extramodels
new rc_admin
#if CSTRIKE_MONEY
new rc_buyzone
new rc_buytime
new rc_cost

new Float:roundstart
#endif

new fire
new DeathMsg

static const car1[] = "models/RCcar-Red.mdl"
static const car2[] = "models/RCcar-Blue.mdl"
static const car3[] = "models/RCcar-Yellow.mdl"
static const car4[] = "models/RCcar-Green.mdl"
static const blank[] = "models/blank.mdl"
static const sound_fx[] = "RC-vroom.wav"
static const sound_hurt[] = "debris/metal3.wav"
static const sound_die[] = "debris/zap1.wav"

public plugin_init()
{
	register_plugin("RC Car Mod","1.0","GHW_Chronic")
	register_concmd("say /rc","spawn_rc")
	register_concmd("say /norc","unspawn_rc")
	register_concmd("say_team /rc","spawn_rc")
	register_concmd("say_team /norc","unspawn_rc")

	rc_maxspeed = register_cvar("rc_maxspeed","600.0")	//Maxspeed of RC
	rc_accel = register_cvar("rc_accel","10.0")		//Acceleration (Units/Think) (Halved backwards)
	rc_follow = register_cvar("rc_follow","1")		//1=View follows RC, 2=View from Player's Viewpoint
	rc_delay = register_cvar("rc_delay","0.0")		//Delay before can spawn new RC after last RC spawn (time or 0=no delay -1=1 per round (cs/cz))
	rc_explode = register_cvar("rc_explode","1")		//1 = explodable 0=not
	rc_health = register_cvar("rc_health","100.0")		//HP of Car
	rc_admin = register_cvar("rc_adminonly","0")		//0=Everyone | 1=Admin Only | 2=Free to admin but everyone can buy
#if CSTRIKE_MONEY
	rc_cost = register_cvar("rc_cost","1000")		//Cost for CS/CZ
	rc_buyzone = register_cvar("rc_buyzone","0")		//0=Don't have to buy in buyzone | 1=Have to buy in buyzone | 2=Admin's can buy anywhere but everyone else must be in buyzone
	rc_buytime = register_cvar("rc_buytime","0")		//0=Don't have to buy within buytime | 1=Have to buy within buytime | 2=Admin's can buy anytime but everyone else only during buytime
#endif

	register_forward(FM_Think,"Think_Hook")
	register_forward(FM_PlayerPreThink,"PreThink_Hook")
	register_event("DeathMsg","Hook_DeathMsg","a")
	if(cstrike_running()) register_event("SendAudio","endround","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw")

	DeathMsg = get_user_msgid("DeathMsg")
}

public plugin_precache()
{
	precache_model(blank)

	precache_model(car1)
	precache_model(car2)

	if(get_pcvar_num(register_cvar("rc_extramodels","0"))) //Enable this on mods with > 2 teams (IE: TFC)
	{
		rc_extramodels = 1
		precache_model(car3)
		precache_model(car4)
	}

	precache_sound(sound_fx)
	precache_sound(sound_hurt)
	precache_sound(sound_die)

	fire = precache_model("sprites/explode1.spr")
}

public spawn_rc(id)
{
	if(pev_valid(car[id]))
	{
		client_print(id,print_center,"[AMXX] You already have an RC Car")
		return ;
	}
	if(!can_spawn[id])
	{
		client_print(id,print_center,"[AMXX] You must wait before you can have another RC.")
		return ;
	}
	new admin_only = get_pcvar_num(rc_admin)
	if(admin_only==1)
	{
		if(!is_user_admin(id))
		{
			return ;
		}
	}
#if CSTRIKE_MONEY
	new money = cs_get_user_money(id)
	new cost = get_pcvar_num(rc_cost)
	if(admin_only==0 || (admin_only==2 && !is_user_admin(id)))
	{
		if(cs_get_user_money(id)<cost)
		{
			client_print(id,print_center,"[AMXX] You do not have enough money for an RC. Cost: $%d",cost)
			return ;
		}
	}

	new buyzone = get_pcvar_num(rc_buyzone)
	if(buyzone==1 || (buyzone==2 && !is_user_admin(id)))
	{
		if(!cs_get_user_buyzone(id))
		{
			client_print(id,print_center,"[AMXX] Must be in a buyzone to buy an RC.")
			return ;
		}
	}

	new buytime = get_pcvar_num(rc_buytime)
	if(buytime==1 || (buytime==2 && !is_user_admin(id)))
	{
		if((get_gametime() - roundstart) / 60.0 > get_cvar_float("mp_buytime"))
		{
			client_print(id,print_center,"[AMXX] Buytime is over. Cannot buy an RC.")
			return ;
		}
	}

	cs_set_user_money(id,money - cost)
#endif
	new ent = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
	set_pev(ent,pev_classname,"GHW_RC")
	set_pev(ent,pev_owner,id)
	new model[32]
	switch(get_user_team(id))
	{
		case 2: format(model,31,car2)
			case 3:
		{
			if(rc_extramodels) format(model,31,car3)
			else format(model,31,car1)
		}
		case 4:
		{
			if(rc_extramodels) format(model,31,car4)
			else format(model,31,car2)
		}
		default: format(model,31,car1)
	}
	set_pev(ent,pev_model,model)
	engfunc(EngFunc_SetModel,ent,model)
	new Float:origin[3]
	pev(id,pev_origin,origin)
	set_pev(ent,pev_origin,origin)
	set_pev(ent,pev_movetype,MOVETYPE_FLY)
	set_pev(ent,pev_solid,SOLID_BBOX)
	engfunc(EngFunc_SetSize,ent,Float:{-20.0,-20.0,-2.0},Float:{5.0,5.0,3.0})
	set_pev(ent,pev_nextthink,get_gametime())
	set_pev(ent,pev_health,HEALTH_OFFSET + get_pcvar_float(rc_health))
	set_pev(ent,pev_max_health,HEALTH_OFFSET + get_pcvar_float(rc_health))
	set_pev(ent,pev_takedamage,1.0)

	origin[2] -= 10.0
	set_pev(id,pev_origin,origin)

	new ent2 = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
	set_pev(ent2,pev_classname,"GHW_RC_Spec")
	set_pev(ent2,pev_owner,id)
	set_pev(ent2,pev_model,blank)
	engfunc(EngFunc_SetModel,ent2,blank)
	get_offset_origin(ent,Float:{-60.0,0.0,40.0},origin)
	set_pev(ent2,pev_origin,origin)
	set_pev(ent2,pev_movetype,MOVETYPE_FLY)
	set_pev(ent2,pev_solid,SOLID_NOT)
	if(get_pcvar_num(rc_follow)) engfunc(EngFunc_SetView,id,ent2)
	car_spec[id] = ent2

	car[id] = ent
	in_control[id] = true

	new string[20]
	if(get_pcvar_num(rc_explode)) format(string,19,"- Fire to Explode")
	client_print(id,print_center,"[AMXX] RC Created - Use Key to Quit %s",string)

	new Float:delaytime = get_pcvar_float(rc_delay)
	if(delaytime) can_spawn[id] = false
	if(delaytime>0)
	{
		set_task(delaytime,"can_spawn_again",id)
	}

	return ;
}

public can_spawn_again(id) can_spawn[id]=true

public unspawn_rc(id)
{
	if(pev_valid(car[id])) engfunc(EngFunc_RemoveEntity,car[id])
	if(pev_valid(car_spec[id])) engfunc(EngFunc_RemoveEntity,car_spec[id])
	car[id] = 0
	car_spec[id] = 0
	in_control[id] = false
	if(is_user_connected(id))
	{
		if(is_user_alive(id))
		{
			new Float:origin[3]
			pev(id,pev_origin,origin)
			origin[2] += 15.0
			set_pev(id,pev_origin,origin)
		}
		client_print(id,print_center,"[AMXX] RC Deleted")
		engfunc(EngFunc_SetView,id,id)
	}
}

public explode_rc(id)
{
	if(pev_valid(car[id]))
	{
		new origin[3], Float:F_origin[3]
		pev(car[id],pev_origin,F_origin)
		FVecIVec(F_origin,origin)

		message_begin(MSG_BROADCAST,SVC_TEMPENTITY,origin) 
		write_byte(TE_EXPLOSION) 
		write_coord(origin[0])	// start position
		write_coord(origin[1])
		write_coord(origin[2])
		write_short(fire)
		write_byte(20) // byte (scale in 0.1's) 188
		write_byte(10) // byte (framerate)
		write_byte(0) // byte flags (4 = no explode sound)
		message_end()

		new players[32], num, Float:distance
		new team = get_user_team(id)
		get_players(players,num,"ah")
		new Float:P_origin[3]
		for(new i=0;i<num;i++)
		{
			if(get_user_team(players[i])!=team)
			{
				pev(players[i],pev_origin,P_origin)
				distance = get_distance_f(F_origin,P_origin)
				if(distance<EXPLOSION_SIZE)
				{
					distance = EXPLOSION_SIZE * 5.0 / distance

					new old_msgblock = get_msg_block(DeathMsg)
					set_msg_block(DeathMsg,BLOCK_ONCE)
					fm_fakedamage(players[i],id,distance,DMG_BURN)
					set_msg_block(DeathMsg,old_msgblock)
					if(!is_user_alive(players[i]))
					{
						make_deathmsg(id,players[i],0,"A RC Car")
						set_user_frags(id,get_user_frags(id) + 1)
					}
				}
			}
		}
	}

	unspawn_rc(id)
}

public endround()
{
//	new bool:boolholder=false
//	if(get_pcvar_float(rc_delay)<0) boolholder=true
	for(new i=0;i<33;i++)
	{
		if(pev_valid(car[i]))
		{
			unspawn_rc(i)
		}
		can_spawn[i] = true
	}
#if CSTRIKE_MONEY
	roundstart = get_gametime() + 5.0
#endif
}

public Hook_DeathMsg()
{
	new victim = read_data(2)
	if(!is_user_alive(victim))
	{
		unspawn_rc(victim)
	}
}

public client_disconnect(id) unspawn_rc(id)
public client_connect(id) can_spawn[id]=true

//VEN
stock fm_fakedamage(victim,attacker, Float:takedmgdamage, damagetype)
{
	new entity = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"trigger_hurt"))

	new value[16]
	float_to_str(takedmgdamage * 2, value, sizeof value - 1)
	set_kvd(0, KV_ClassName,"trigger_hurt")
	set_kvd(0, KV_KeyName, "dmg")
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)
	dllfunc(DLLFunc_KeyValue,entity,0)

	num_to_str(damagetype, value, sizeof value - 1)
	set_kvd(0, KV_ClassName,"trigger_hurt")
	set_kvd(0, KV_KeyName, "damagetype")
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)
	dllfunc(DLLFunc_KeyValue,entity,0)

	set_kvd(0, KV_ClassName,"trigger_hurt")
	set_kvd(0, KV_KeyName, "origin")
	set_kvd(0, KV_Value, "8192 8192 8192")
	set_kvd(0, KV_fHandled, 0)
	dllfunc(DLLFunc_KeyValue,entity,0)

	dllfunc(DLLFunc_Spawn,entity)

	set_pev(entity,pev_classname,"Spell")
	set_pev(entity,pev_owner,attacker)
	dllfunc(DLLFunc_Touch,entity,victim)
	engfunc(EngFunc_RemoveEntity,entity)

	return 1
}

public PreThink_Hook(id)
{
	if(in_control[id] && pev_valid(car[id]))
	{
		new buttons = pev(id,pev_button)

		static bool:boostup
		static Float:origin[3], Float:origin2[3], Float:velocity[3]
		boostup = false

		pev(car[id],pev_velocity,velocity)
		pev(car[id],pev_origin,origin)
		pev(car[id],pev_oldorigin,origin2)
		set_pev(car[id],pev_oldorigin,origin)

		if(pev(car[id],pev_euser4))
		{
			if(origin[0]==origin2[0] && origin[1]==origin2[1] && origin[2]==origin2[2])
			{
				boostup = true
			}
		}

		origin2[0] = origin[0]
		origin2[1] = origin[1]
		origin2[2] = origin[2] - 25.0
		new Float:hit2[3]
		engfunc(EngFunc_TraceLine,origin,origin2,1,car[id],0)
		get_tr2(0,TR_vecEndPos,hit2)
		if(hit2[0]==origin2[0] && hit2[1]==origin2[1] && hit2[2]==origin2[2])
		{
			engfunc(EngFunc_DropToFloor,car[id])
		}

		set_pev(car[id],pev_euser4,0)

		if(boostup)
		{
			velocity[0] = 0.0
			velocity[1] = 0.0
			velocity[2] = 50.0
		}
		else if((buttons & IN_FORWARD) && !(buttons & IN_BACK))
		{
			static Float:new_velo[3]
			get_addedvelo(car[id],get_pcvar_float(rc_accel) + (vector_length(velocity) * 0.05),new_velo)

			velocity[0] *= 0.95
			velocity[1] *= 0.95
			velocity[0] += new_velo[0]
			velocity[1] += new_velo[1]
			if(velocity[2] > 0)
				velocity[2] -= 1.0

			if(vector_length(velocity) >= get_pcvar_float(rc_maxspeed))
			{
				get_addedvelo(car[id],get_pcvar_float(rc_maxspeed),velocity)
			}

			static Float:hit[3]

			hit[0] = 0.0
			hit[1] = 0.0
			hit[2] = 0.0
			origin2[0] = 0.0
			origin2[1] = 0.0
			origin2[2] = 0.0

			get_offset_origin(car[id],Float:{30.0,0.0,0.0},origin2)

			engfunc(EngFunc_TraceLine,origin,origin2,1,car[id],0)
			get_tr2(0,TR_vecEndPos,hit)
			if(hit[0]!=origin2[0] || hit[1]!=origin2[1] || hit[2]!=origin2[2])
			{
				get_offset_origin(car[id],Float:{30.0,0.0,50.0},origin2)
				engfunc(EngFunc_TraceLine,origin,origin2,1,car[id],0)
				get_tr2(0,TR_vecEndPos,hit)
				if(hit[0]==origin2[0] && hit[1]==origin2[1] && hit[2]==origin2[2])
				{
					get_speed_vector(origin,origin2,get_pcvar_float(rc_maxspeed),new_velo)
					velocity[0] = new_velo[0]
					velocity[1] = new_velo[1]
					velocity[2] = new_velo[2]
				}
			}

			set_pev(car[id],pev_velocity,velocity)
			set_pev(car[id],pev_sequence,1)
			set_pev(car[id],pev_euser4,1)
		}
		else if(!(buttons & IN_FORWARD) && (buttons & IN_BACK))
		{
			static Float:new_velo[3]
			get_addedvelo(car[id],(get_pcvar_float(rc_accel) * -1.00) + (vector_length(velocity) * 0.05),new_velo)

			velocity[0] *= 0.95
			velocity[1] *= 0.95
			velocity[0] += new_velo[0]
			velocity[1] += new_velo[1]

			if(vector_length(velocity) >= get_pcvar_float(rc_maxspeed))
			{
				get_addedvelo(car[id],get_pcvar_float(rc_maxspeed) * -1.0,velocity)
			}

			if(boostup)
			{
				velocity[0] = 0.0
				velocity[1] = 0.0
				velocity[2] = 50.0
			}

			set_pev(car[id],pev_velocity,velocity)
			set_pev(car[id],pev_sequence,2)
			set_pev(car[id],pev_euser4,1)
		}

		if((buttons & IN_MOVELEFT) && !(buttons & IN_MOVERIGHT))
		{
			static Float:vangle[3]
			pev(car[id],pev_angles,vangle)
			vangle[1] += 5.0
			set_pev(car[id],pev_angles,vangle)
			get_offset_origin(car[id],Float:{-60.0,0.0,40.0},vangle)
			set_pev(car_spec[id],pev_origin,vangle)
		}
		else if(!(buttons & IN_MOVELEFT) && (buttons & IN_MOVERIGHT))
		{
			static Float:vangle[3]
			pev(car[id],pev_angles,vangle)
			vangle[1] -= 5.0
			set_pev(car[id],pev_angles,vangle)
			get_offset_origin(car[id],Float:{-60.0,0.0,40.0},vangle)
			set_pev(car_spec[id],pev_origin,vangle)
		}
/* Jump - Removed
		if((buttons & IN_JUMP) && !(pev(id,pev_oldbuttons) & IN_JUMP) && (pev(car[id],pev_flags) & FL_ONGROUND))
		{
			velocity[2] += JUMP_HEIGHT

			//get_pcvar_float(rc_maxspeed)

			//static Float:new_velo[3]
			//get_addedvelo(car[id],get_pcvar_float(rc_accel),new_velo)

			//velocity[0] += new_velo[0]
			//velocity[1] += new_velo[1]

			//if(vector_length(velocity) >= get_pcvar_float(rc_maxspeed))
			//{
			//	get_addedvelo(car[id],get_pcvar_float(rc_maxspeed),velocity)
			//}
			set_pev(car[id],pev_velocity,velocity)
		}
*/
		if(buttons & IN_USE)
		{
			unspawn_rc(id)
			return ;
		}
		else if(get_pcvar_num(rc_explode) && (buttons & IN_ATTACK) && is_user_alive(id))
		{
			explode_rc(id)
			return ;
		}
		set_pev(car[id],pev_framerate,vector_length(velocity) / 6.0)

		if(pev_valid(car_spec[id]))
		{
			get_offset_origin(car[id],Float:{-60.0,0.0,40.0},origin)
			pev(car_spec[id],pev_origin,origin2)
			if(floatabs(origin[2] - origin2[2])>10.0 || get_distance_f(origin,origin2)>25.0)
				set_pev(car_spec[id],pev_origin,origin)

			set_pev(car_spec[id],pev_velocity,velocity)

			static Float:vangle[3]
			pev(car[id],pev_angles,vangle)
			vangle[0] += 30.0
			set_pev(car_spec[id],pev_angles,vangle)
		}
	}
	return ;
}

public get_addedvelo(ent,Float:speed,Float:new_velo[3])
{
	static Float:vangle[3]
	pev(ent,pev_angles,vangle)

	pev(ent,pev_velocity,new_velo)

	angle_vector(vangle,1,new_velo)

	new_velo[0] *= speed
	new_velo[1] *= speed
}

public Think_Hook(ent)
{
	if(!pev_valid(ent))
		return ;

	static classname[32]
	pev(ent,pev_classname,classname,31)
	if(equali(classname,"GHW_RC"))
	{
		new Float:health
		new Float:oldhealth
		pev(ent,pev_health,health)
		pev(ent,pev_max_health,oldhealth)

		if(health<oldhealth)
		{
			set_pev(ent,pev_max_health,health)
			emit_sound(ent,CHAN_VOICE,sound_hurt,VOL_NORM, ATTN_NORM,0,PITCH_NORM)

			static Float:F_origin[3], I_origin[3]
			pev(ent,pev_origin,F_origin)
			FVecIVec(F_origin,I_origin)
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY,I_origin)
			write_byte(TE_SPARKS)
			write_coord(I_origin[0])
			write_coord(I_origin[1])
			write_coord(I_origin[2])
			message_end()

			if(health<=HEALTH_OFFSET)
			{
				emit_sound(ent,CHAN_VOICE,sound_die,VOL_NORM, ATTN_NORM,0,PITCH_NORM)
				unspawn_rc(pev(ent,pev_owner))
			}
		}

		static Float:velocity[3]
		pev(ent,pev_velocity,velocity)
		if(velocity[0] > 5.0) velocity[0] -= 5.0
		else if(velocity[0] < -5.0) velocity[0] += 5.0
		else velocity[0] = 0.0

		if(velocity[1] > 5.0) velocity[1] -= 5.0
		else if(velocity[1] < -5.0) velocity[1] += 5.0
		else velocity[1] = 0.0

		if(!(pev(ent,pev_flags) & FL_ONGROUND)) velocity[2] -= 10.0

		set_pev(ent,pev_velocity,velocity)
		if(!velocity[2] && (pev(ent,pev_flags) & FL_ONGROUND)) engfunc(EngFunc_DropToFloor,ent)
		if(!pev(ent,pev_team))
		{
			emit_sound(ent,CHAN_VOICE,sound_fx,VOL_NORM, ATTN_NORM,0,PITCH_NORM)
			set_pev(ent,pev_team,1)
			set_task(random_float(0.3,1.0),"vroom_again",ent)
		}
		new speccar = car_spec[pev(ent,pev_owner)]
		if(pev_valid(speccar))
			set_pev(speccar,pev_velocity,velocity)

		set_pev(ent,pev_nextthink,1.0)
	}

	return ;
}

public vroom_again(ent) if(pev_valid(ent)) set_pev(ent,pev_team,0)

/******************
  From chr_engine
******************/

get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num

	return 1;
}

get_offset_origin(ent,const Float:offset[3],Float:origin[3])
{
	if(!pev_valid(ent))
		return 0;

	new Float:angle[3]
	pev(ent,pev_origin,origin)
	pev(ent,pev_angles,angle)

	origin[0] += floatcos(angle[1],degrees) * offset[0]
	origin[1] += floatsin(angle[1],degrees) * offset[0]

	origin[2] += floatsin(angle[0],degrees) * offset[0]
	origin[0] += floatcos(angle[0],degrees) * offset[0]

	origin[1] += floatcos(angle[1],degrees) * offset[1]
	origin[0] -= floatsin(angle[1],degrees) * offset[1]

	origin[2] += floatsin(angle[2],degrees) * offset[1]
	origin[1] += floatcos(angle[2],degrees) * offset[1]

	origin[2] += floatcos(angle[2],degrees) * offset[2]
	origin[1] -= floatsin(angle[2],degrees) * offset[2]

	origin[2] += floatcos(angle[0],degrees) * offset[2]
	origin[0] -= floatsin(angle[0],degrees) * offset[2]

	origin[0] -= offset[0]
	origin[1] -= offset[1]
	origin[2] -= offset[2]

	return 1;
}
