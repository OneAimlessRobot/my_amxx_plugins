#define I_WANT_QUICK_CHECKS
#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "ksun_inc/ksun_global.inc"
#include "ksun_inc/ksun_particle.inc"
#include "ksun_inc/ksun_spore_launcher.inc"
#include "ksun_inc/ksun_scanner.inc"
#include "ksun_inc/ksun_ultimate.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "../my_include/my_author_header.inc"

new gHeroID = 0

new pcvar_ksun_spore_damage, 
	pcvar_ksun_spore_speed,
	pcvar_ksun_heal_coeff,
	pcvar_particle_follow_time,
	pcvar_ksun_spore_track_detect_distance,
	pcvar_ksun_spore_base_health;

new g_times_player_spiked_player[SH_MAXSLOTS+1][SH_MAXSLOTS+1]
new g_times_player_spiked_by_player[SH_MAXSLOTS+1][SH_MAXSLOTS+1]

new dmg_source_name_short_spore[SAFE_BUFFER_SIZE+1]="ksun_spore"
new dmg_source_name_long_spore[SAFE_BUFFER_SIZE+1]="ksun_spore"
new spore_wpn_id

new dmg_source_name_short_slay[SAFE_BUFFER_SIZE+1]="dream_eater"
new dmg_source_name_long_slay[SAFE_BUFFER_SIZE+1]="dream_eater"
new slay_wpn_id

//cvar_val(float, pcvar_

public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO ksun spores","1.1",AUTHOR)
	pcvar_ksun_spore_damage = register_cvar("ksun_spore_damage", "100.0" )
	pcvar_ksun_spore_speed = register_cvar("ksun_spore_speed", "900.0" )
	pcvar_particle_follow_time = register_cvar("ksun_follow_time", "5.0")
	pcvar_ksun_spore_track_detect_distance = register_cvar("ksun_spore_track_detect_dist", "500.0")
	pcvar_ksun_heal_coeff = register_cvar("ksun_heal_coeff", "0.5" )
	pcvar_ksun_spore_base_health = register_cvar("ksun_spore_health", "100.0" )
	
	register_entity_as_wall_touchable(SPORE_CLASSNAME,"touch_wall")
	register_custom_touchable(SPORE_CLASSNAME,"touch_player",player_vector,1)
	
	register_think(SPORE_CLASSNAME, "spore_think")

}

public plugin_natives(){
	
	
	
	register_native("spore_launch","_spore_launch",0)
	register_native("get_times_player_spiked_player","_get_times_player_spiked_player",0)
	register_native("inc_times_player_spiked_player","_inc_times_player_spiked_player",0)
	register_native("dec_times_player_spiked_player","_dec_times_player_spiked_player",0)
	
	register_native("get_times_player_spiked_by_player","_get_times_player_spiked_by_player",0)
	register_native("inc_times_player_spiked_by_player","_inc_times_player_spiked_by_player",0)
	register_native("dec_times_player_spiked_by_player","_dec_times_player_spiked_by_player",0)
	register_native("ksun_heal","_ksun_heal",0)
	
	register_native("ksun_glisten","_ksun_glisten",0)
	
	register_native("clean_ksun_spores_from_players","_clean_ksun_spores_from_players",0)
	register_native("check_by_whom_player_spored","_check_by_whom_player_spored",0)
	register_native("check_who_player_is_sporing","_check_who_player_is_sporing",0)
	
	
	
}
public plugin_cfg(){


	gHeroID = spores_ksun_hero_id()


	spore_wpn_id=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_spore,
								dmg_source_name_long_spore,
								0)


	slay_wpn_id=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_slay,
								dmg_source_name_long_slay,
								0)
}
//----------------------------------------------------------------------------------------------
untrack_spore(spore){
	if(pev_valid(spore)){
		new spore_owner= entity_get_edict(spore,EV_ENT_euser1)
		emit_sound(spore, CHAN_STATIC, SPORE_TRAVEL_SFX, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		emit_sound(spore, CHAN_STATIC, SPORE_READY_SFX, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		entity_set_float( spore, EV_FL_fuser1, 0.0);
		new Float:origin[3]
		entity_get_vector(spore,EV_VEC_origin,origin)
		make_sparks(origin)
		remove_entity(spore)
		dec_player_num_victims(spore_owner)
		ksun_dec_num_available_spores(spore_owner)
	}
	return 0

}
public bool:_ksun_heal(iPlugins, iParms){
	new id= get_param(1)
	new Float:damage=get_param_f(2)
	
	new Float: mate_health=float(get_user_health(id))
	if(mate_health>=sh_get_max_hp(id)){
		return false
	
	}
	damage*=cvar_val(float, pcvar_ksun_heal_coeff)
	new new_damage= min(floatround(damage), clamp(0,sh_get_max_hp(id)-get_user_health(id)))
	ksun_glisten(id)
	ksun_inc_player_supply_points(id,new_damage)
	emit_sound(id, CHAN_STATIC, SPORE_HEAL_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	new Float: new_health=floatadd(mate_health,damage)
	set_user_health(id,min(sh_get_max_hp(id),floatround(new_health)))
	return true

}

public _ksun_glisten(iPlugins,iParms){
	
	new id= get_param(1)
	
	set_render_with_color_const(id,PURPLE,1,180,100,1,0)
	remove_glow_user(id,KSUN_HEAL_GLOW_TIME)
	static arr[3]
	arr[0]=LineColors[PURPLE][0]
	arr[1]=LineColors[PURPLE][1]
	arr[2]=LineColors[PURPLE][2]
	aura(id,arr)
	
}
public _clean_ksun_spores_from_players(iPlugins,iParam){
	new dying_or_new_round=get_param(1);
	new everyone=get_param(2);
	new player=get_param(3);
	new player_to_reset=everyone?-1:player
	if(ksun_get_when_reset_spores()&(dying_or_new_round?reset_on_death:reset_on_new_round)){
		if(player<0){
			for(new i=0;i<sh_maxplayers()+1;i++){
				clear_spores_from_player(i)
			}
		}
		else{
			clear_spores_from_player(player_to_reset)
		}
	}
	
}
public _check_who_player_is_sporing(iPlugins,iParam){
	new id=get_param(1);
	if(is_user_connected(id)){
		if(sh_user_has_hero(id,gHeroID)){
			
			new username[128];
			get_user_name(id,username,127);
			server_print("[SH] ksun: this ksun user named %s is sporing the following players...:^n",username)
			for(new i=0;i<sh_maxplayers()+1;i++){
				
				if(is_user_connected(i)){
					
					new tgname[128];
					get_user_name(i, tgname,127);
					server_print("[SH] ksun:... %s: %d times!^n",tgname,g_times_player_spiked_player[id][i])
				}
				
				
			}
		}
	}
}
public _check_by_whom_player_spored(iPlugins,iParam){
	new id=get_param(1);
	if(is_user_connected(id)){
		new username[128];
		get_user_name(id,username,127);
		server_print("[SH] ksun: this player named %s is being spored by the following players...:^n",username)
		for(new i=0;i<sh_maxplayers()+1;i++){
			if(is_user_connected(i)){
				if(sh_user_has_hero(i,gHeroID)){
					
					new tgname[128];
					get_user_name(i, tgname,127);
					server_print("[SH] ksun:... ksun user %s: %d times!^n",tgname,g_times_player_spiked_by_player[id][i])
				}
			}
		}
	}
}

stock clear_spores_from_player(id){
	
	if(is_user_connected(id)){
		arrayset(g_times_player_spiked_player[id],0,SH_MAXSLOTS+1)
		for(new i=0;i<sh_maxplayers()+1;i++){
			if(is_user_connected(i)){
				g_times_player_spiked_by_player[i][id]=0;
			}
		}
	}
}
public sh_round_end(){
	
	remove_entity_name(SPORE_CLASSNAME)
	if(!sh_is_active()) return PLUGIN_CONTINUE
	clean_ksun_spores_from_players(false,1,0);
	return PLUGIN_CONTINUE
}
public spawn_spore(id){
	if(!sh_user_has_hero(id,gHeroID)||!is_user_alive(id)){
	
		return 0
	}
	new material[128]
	new health[128]	
	new spore = create_entity( "func_breakable" );

	if ( (spore == 0) || !pev_valid(spore)||!is_valid_ent(spore)) {
		client_print(id, print_chat, "[SH](ksun) Spore Creation Failure")
		return 0
	}

	new Float:b_orig[3]

	new originplayer[3], originlook[3], aimvec[3]

	get_user_origin(id, originplayer)
	get_user_origin(id, originlook, 2)


	new distance[2]

	distance[0] = originlook[0]-originplayer[0]
	distance[1] = originlook[1]-originplayer[1]


	new unitsinfront = 80

	aimvec[0]=originplayer[0]+(unitsinfront*distance[0])/sqrt(distance[0]*distance[0]+distance[1]*distance[1])
	aimvec[1]=originplayer[1]+(unitsinfront*distance[1])/sqrt(distance[0]*distance[0]+distance[1]*distance[1])
	aimvec[2]=originplayer[2]+UNITS_ABOVE

	b_orig[0] = float(aimvec[0]);
	b_orig[1] = float(aimvec[1]);
	b_orig[2] = float(aimvec[2]);

	entity_set_string(spore, EV_SZ_classname, SPORE_CLASSNAME)


	entity_set_model(spore, KSUN_SPORE_MDL)

	float_to_str(SPORE_DEAD_HP+cvar_val(float, pcvar_ksun_spore_base_health),health,127)
	num_to_str(2,material,127)
	DispatchKeyValue( spore, "material", material );
	DispatchKeyValue( spore, "health", health );


	set_pev(spore, pev_health, SPORE_DEAD_HP+cvar_val(float, pcvar_ksun_spore_base_health))
	engfunc(EngFunc_SetSize, spore, Float:{-SPORE_RADIUS, -SPORE_RADIUS,-SPORE_RADIUS}, Float:{SPORE_RADIUS, SPORE_RADIUS, SPORE_RADIUS})

	entity_set_float( spore, EV_FL_fuser1, 0.0);

	set_pev(spore, pev_takedamage, DAMAGE_YES)
	set_pev(spore, pev_solid, SOLID_BBOX)
	entity_set_int(spore,EV_INT_movetype, MOVETYPE_FLY)
	entity_set_origin(spore, b_orig)

	//Sets who the owner of the entity is
	entity_set_edict(spore, EV_ENT_euser1,id)
	entity_set_edict(spore, EV_ENT_owner,get_player_launcher(id))

	return spore
}
//----------------------------------------------------------------------------------------------
public _get_times_player_spiked_player(iPlugin,iParms){
	
		new killer= get_param(1)
		new victim= get_param(2)
		
		return g_times_player_spiked_player[killer][victim]
	
	
}
public _inc_times_player_spiked_player(iPlugin,iParms){

		new killer= get_param(1)
		new victim= get_param(2)

		g_times_player_spiked_player[killer][victim]++
}
public _dec_times_player_spiked_player(iPlugin,iParms){

		new killer= get_param(1)
		new victim= get_param(2)

		g_times_player_spiked_player[killer][victim]= (g_times_player_spiked_player[killer][victim]>0)? (g_times_player_spiked_player[killer][victim]-1):0
		
}
//----------------------------------------------------------------------------------------------
public _get_times_player_spiked_by_player(iPlugin,iParms){
	
		
		new victim= get_param(1)
		new killer= get_param(2)
		
		return g_times_player_spiked_by_player[victim][killer]
	
	
}
public _inc_times_player_spiked_by_player(iPlugin,iParms){

		new victim= get_param(1)
		new killer= get_param(2)

		g_times_player_spiked_by_player[victim][killer]++
}

public _dec_times_player_spiked_by_player(iPlugin,iParms){

		new victim= get_param(1)
		new killer= get_param(2)

		g_times_player_spiked_by_player[victim][killer]= (g_times_player_spiked_by_player[victim][killer]>0)? (g_times_player_spiked_by_player[victim][killer]-1):0
		
}
//----------------------------------------------------------------------------------------------
public _spore_launch(iPlugins,iParms)
{
new id= get_param(1)
if(!sh_user_has_hero(id,gHeroID)||!is_user_alive(id)){
	
	return
}
new spore
switch(get_player_launcher_phase(id)){
	case PHASE_DEPLOY:{
		spore= spawn_spore(id)
		if(!spore){
			
			return
		}

		emit_sound(spore, CHAN_STATIC, SPORE_SEND_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		set_spore_at_player_spores(id,get_player_num_deployed_spores(id),spore)
		entity_set_edict(spore,EV_ENT_euser1,id)
		}
	case PHASE_SEND:{
		
		spore=get_spore_from_player_spores(id,get_player_num_launched_spores(id))
		entity_set_edict(spore,EV_ENT_euser2,
						get_target_from_player_targets(id,get_player_num_launched_spores(id)))
		//bumped status. lets set it to off upon launch
		entity_set_int(spore,EV_INT_iuser1,0)
		trail(spore,PURPLE,20,3)
		entity_set_float(spore, EV_FL_nextthink, floatadd(get_gametime() ,SPORE_THINK_PERIOD));
	}
}
}


public spore_think(spore){

	if ( !is_valid_ent(spore) ) return FMRES_IGNORED


	new Float:spore_hp=float(pev(spore,pev_health))

	new	spore_owner=entity_get_edict(spore,EV_ENT_euser1),
		spore_target=entity_get_edict(spore,EV_ENT_euser2)

	new Float:current_track_time=entity_get_float(spore, EV_FL_fuser1)

	if ( (spore_hp<SPORE_DEAD_HP)|| !is_user_alive(spore_owner) ||
						!is_user_alive(spore_target)){
		
		untrack_spore(spore)
		return FMRES_IGNORED
		
	}

	else if(current_track_time>cvar_val(float, pcvar_particle_follow_time)){
		untrack_spore(spore)
		return FMRES_IGNORED
	}

	new trackresult=entity_set_follow(spore, spore_target,spore_owner)

	if(trackresult){

		if(trackresult<0){
			untrack_spore(spore)
			set_scanner_player_tracks_player(spore_owner,spore_target,0)
			return FMRES_IGNORED
		}
		else{
			emit_sound(spore, CHAN_STATIC, SPORE_TRAVEL_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			entity_set_float(spore, EV_FL_fuser1, floatadd(current_track_time,SPORE_THINK_PERIOD));
		}
	}
	else{

		entity_set_float(spore, EV_FL_fuser1, floatmax(0.0,floatsub(current_track_time,SPORE_THINK_PERIOD)));
			
	}
	new bool:had_trail=bool:entity_get_int(spore,EV_INT_iuser2),
		bool:has_trail=(!(bool:entity_get_int(spore,EV_INT_iuser1)))&&trackresult
	
	entity_set_int(spore,EV_INT_iuser2,has_trail)

	if(!had_trail){
		
		if(has_trail){

			trail(spore,PURPLE,20,3)
			glow(spore,LineColors[PURPLE][0],
							LineColors[PURPLE][1],
							LineColors[PURPLE][2],
							100,1)
		}
	}
	else if(!has_trail){
		sh_set_rendering(spore)

	}
	
	entity_set_float( spore, EV_FL_nextthink, floatadd(get_gametime( ) ,SPORE_THINK_PERIOD));

	return FMRES_IGNORED
}
bump_spore(spore){

//We bumped into a wall.
entity_set_int(spore,EV_INT_iuser1,1)

static Float:velocity[3],
		Float:bump_reverse[3],
		Float:origin[3],
		Float:new_origin[3]

entity_get_vector(spore,EV_VEC_velocity,velocity)
entity_get_vector(spore,EV_VEC_origin,origin)

multiply_3d_vector_by_scalar(velocity,
				-1.0*(WALL_BUMP_LENGTH/floatmax(0.001,vector_length(velocity))),
				bump_reverse)

add_3d_vectors(origin,bump_reverse,new_origin)

entity_set_origin(spore,new_origin)

}
//https://huggingface.co/datasets/RichieBurundi/Amxxprogramer/blob/main/EngFunc_TraceLine%20Explanation.txt
stock is_wall_between_points(Float:start[3], Float:end[3], Float:hit_end[3], &Float:stored_frac,ignore_ent)
{
	// Create the trace handle! It is best to create it!
	new ptr = create_tr2()

	// --- 1. Trace HULL (volume check) ---
	engfunc(EngFunc_TraceHull,
		start,
		end,
		IGNORE_GLASS | IGNORE_MONSTERS | IGNORE_MISSILE,
		HULL_HUMAN,
		ignore_ent,
		ptr
	)

	get_tr2(ptr, TR_flFraction, stored_frac)
	get_tr2(ptr,TR_EndPos,hit_end)
	// If hull hit → definitely blocked
	if (stored_frac < 0.90)
	{
		free_tr2(ptr)
		return true
	}

	// --- 2. Trace LINE (thin geometry / edges / corners) ---
	engfunc(EngFunc_TraceLine,
		start,
		end,
		IGNORE_GLASS | IGNORE_MONSTERS | IGNORE_MISSILE,
		ignore_ent,
		ptr
	)


	get_tr2(ptr, TR_flFraction, stored_frac)
	get_tr2(ptr,TR_EndPos,hit_end)

	free_tr2(ptr)

	if (stored_frac < 0.90)
	{
		return true
	}

	return false
}
//----------------------------------------------------------------------------------------------
stock entity_set_follow(entity, target,spore_owner)
{
	if ( !is_valid_ent(entity) || !is_user_alive(target) ||!is_user_alive(spore_owner)) return -1


	new Float:fl_Origin[3], Float:fl_EntOrigin[3], Float:entity_in_the_way_origin[3],
	Float:in_the_way_vector[3]
	entity_get_vector(target, EV_VEC_origin, fl_Origin)
	entity_get_vector(entity, EV_VEC_origin, fl_EntOrigin)
	new Float: distance=vector_distance(fl_Origin, fl_EntOrigin)
	
	new Float:fl_InvTime = (cvar_val(float, pcvar_ksun_spore_speed) / distance)

	new Float:fl_Distance[3]
	fl_Distance[0] = fl_Origin[0] - fl_EntOrigin[0]
	fl_Distance[1] = fl_Origin[1] - fl_EntOrigin[1]
	fl_Distance[2] = fl_Origin[2] - fl_EntOrigin[2]

	new Float:fl_Velocity[3]
	fl_Velocity[0] = fl_Distance[0] * fl_InvTime
	fl_Velocity[1] = fl_Distance[1] * fl_InvTime
	fl_Velocity[2] = fl_Distance[2] * fl_InvTime

	new Float:fl_NewAngle[3]
	vector_to_angle(fl_Velocity, fl_NewAngle)
	fl_NewAngle[0]*=-1.0
	entity_set_vector(entity, EV_VEC_angles, fl_NewAngle)
	entity_set_vector(entity, EV_VEC_v_angle, fl_NewAngle)
	
	if(distance> cvar_val(float, pcvar_ksun_spore_track_detect_distance)){

		return 0
	}

	sub_3d_vectors(fl_Origin,fl_EntOrigin,in_the_way_vector)

	//and "WALLBUMP LENGTH AS WELL"
	multiply_3d_vector_by_scalar(in_the_way_vector,(1.0/distance)*WALL_BUMP_LENGTH*7.0,in_the_way_vector)
	add_3d_vectors(fl_EntOrigin,in_the_way_vector,entity_in_the_way_origin)
	new Float:hit_end[3]
	new Float:the_fraction=0.0
	new wall_in_the_way=is_wall_between_points(fl_EntOrigin, entity_in_the_way_origin, hit_end,the_fraction, entity)
	if(wall_in_the_way&&bool:entity_get_int(entity,EV_INT_iuser1)){
		return 0
	}

	entity_set_vector(entity, EV_VEC_velocity, fl_Velocity)

	entity_set_int(entity,EV_INT_iuser1,0)

	return 1
}
//----------------------------------------------------------------------------------------------
public touch_player(pToucher, pTouched)  //This is triggered when two entites touch
{
if(!is_valid_ent(pToucher)) return

if(!is_user_alive(pTouched)){
	return
}

new killer = entity_get_edict(pToucher, EV_ENT_euser1)

if(!is_user_alive(killer)) return

new victim = pTouched
new ffOn = get_cvar_num("mp_friendlyfire")
if ( (get_user_team(victim) != get_user_team(killer)) || ffOn )
{
	new tger_name[128], vic_name[128]
	get_user_name(victim,vic_name,127)
	get_user_name(killer,tger_name,127)
	new damage_to_do=sh_get_user_is_asleep(pTouched)?get_user_health(pTouched)*10:
						floatround(cvar_val(float, pcvar_ksun_spore_damage))
	new bool:remove_godmode=bool:sh_get_user_is_asleep(pTouched)
	
	if(get_user_godmode(pTouched)&&remove_godmode){
		
		set_user_godmode(pTouched,!remove_godmode);
		sh_chat_message(killer,gHeroID,"You removed the godmode of your tg named %s!",tger_name);
	}

	sh_bleed_user(victim,killer,BLEED_NORMAL,gHeroID)
	ksun_heal(killer,float(damage_to_do))
	ksun_inc_player_supply_points(killer,damage_to_do)
	emit_sound(victim, CHAN_STATIC, PIERCE_WOUND_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_scanner_player_tracks_player(killer,victim,0)
	g_times_player_spiked_player[killer][victim]++
	g_times_player_spiked_by_player[victim][killer]++
	untrack_spore(pToucher)

	sh_extra_damage(victim, killer, damage_to_do, remove_godmode?dmg_source_name_short_slay:dmg_source_name_short_spore,
					remove_godmode?MY_HIT_HEAD:MY_HIT_GENERIC,_,_,_,_,_,
					SH_NEW_DMG_DRAIN,
					remove_godmode?slay_wpn_id:spore_wpn_id)
}
}//----------------------------------------------------------------------------------------------
public touch_wall(pToucher, pTouched)
{
if(!is_valid_ent(pToucher)) return FMRES_IGNORED

bump_spore(pToucher)

return FMRES_IGNORED

}

//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel,KSUN_SPORE_MDL)
	engfunc(EngFunc_PrecacheSound, SPORE_PREPARE_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_SEND_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_HEAL_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_READY_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_TRAVEL_SFX)
	
}
