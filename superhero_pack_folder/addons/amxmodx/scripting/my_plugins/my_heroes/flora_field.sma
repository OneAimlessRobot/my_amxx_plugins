#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#define I_WANT_QUICK_CHECKS
#define I_WANT_ENGINE
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt12.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "flora_inc/flora_field.inc"
#include "flora_inc/flora_global.inc"


#define PLUGIN "Superhero flora field funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new g_flora_field_loaded_mask=0,
	
	g_prev_flora_cloaked_mask=0,
 	g_curr_flora_cloaked_mask=0,

	g_curr_flora_noclip_mask=0,
	g_prev_flora_noclip_mask=0;

new const FLORA_HEAL_GLOWING_ON=0
new Float:g_flora_field_cooldown[SH_MAXSLOTS+1];

new g_prev_flora_button[SH_MAXSLOTS+1];
new g_curr_flora_button[SH_MAXSLOTS+1];
new g_flora_num_of_active_fields[SH_MAXSLOTS+1]
new g_flora_prev_inside[SH_MAXSLOTS+1]
new g_flora_curr_inside[SH_MAXSLOTS+1]
new g_flora_curr_charging[SH_MAXSLOTS+1]
new flora_sheltered_values:g_flora_sheltered_value[SH_MAXSLOTS+1]
new flora_sheltered_values:g_flora_prev_sheltered_value[SH_MAXSLOTS+1]
new sh_custom_color:g_flora_dmg_color[SH_MAXSLOTS+1]
new Float:g_flora_curr_dmg_mult[SH_MAXSLOTS+1]

new gHeroID = -1
new gHeroLevel = 0

new generic_suffocation_wpn_id = -1
new pcvar_field_cooldown
new pcvar_field_radius
new pcvar_field_core_radius
new pcvar_flora_field_time
new pcvar_flora_charge_time
new pcvar_flora_dmg_coeff
new pcvar_flora_field_heal_mult
new pcvar_flora_stun_time
new pcvar_flora_invis_alpha_max
new pcvar_flora_base_stun_speed
new pcvar_flora_invis_alpha_min
new pcvar_flora_invis_alpha_dec_per_lvl
new pcvar_flora_teleport_reach_max_distance
new pcvar_flora_field_max_active_ammount
new pcvar_bad_resurface_dmg_penalty_max_hp_ratio

new field_drain_wpn_id
new dmg_source_name_short_field_drain[SAFE_BUFFER_SIZE+1]="field_drain"
new dmg_source_name_log_field_drain[SAFE_BUFFER_SIZE+1]="field_drain"

stock FLORA_COOLDOWN_TASKID,
		FLORA_LOAD_TASKID,
		FLORA_GLOBAL_TASKID



//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	pcvar_flora_field_max_active_ammount = create_cvar("flora_field_max_active_ammount", "10" )
	pcvar_field_cooldown = create_cvar("flora_field_cooldown" ,"9.0" )
	pcvar_field_radius = create_cvar("flora_field_radius" ,"1000.0")
	pcvar_field_core_radius = create_cvar("flora_field_core_radius" ,"1000.0")
	
	pcvar_bad_resurface_dmg_penalty_max_hp_ratio =
					create_cvar("flora_bad_resurface_max_hp_penalty_ratio" ,"0.75")

	pcvar_flora_field_time = create_cvar("flora_field_time" ,"30.0" )
	pcvar_flora_dmg_coeff = create_cvar("flora_dmg_coeff" ,"0.5" )
	pcvar_flora_field_heal_mult = create_cvar("flora_field_heal_mult" ,"0.5" )
	pcvar_flora_charge_time = create_cvar("flora_charge_time" ,"30.0" )
	pcvar_flora_stun_time = create_cvar("flora_stun_time" ,"30.0" )
	pcvar_flora_teleport_reach_max_distance = create_cvar("flora_teleport_reach_max_distance" ,"1000.0" )
	pcvar_flora_invis_alpha_max = create_cvar("flora_invis_alpha_max" ,"0.5" )
	pcvar_flora_invis_alpha_min = create_cvar("flora_invis_alpha_min" ,"0.1" )
	pcvar_flora_invis_alpha_dec_per_lvl = create_cvar("flora_invis_alpha_dec_per_lvl" ,"0.05" )
	pcvar_flora_base_stun_speed = create_cvar("flora_base_stun_speed","210.0")


	FLORA_COOLDOWN_TASKID=allocate_typed_task_id(player_task)
	FLORA_LOAD_TASKID=allocate_typed_task_id(player_task)
	FLORA_GLOBAL_TASKID=allocate_typed_task_id(generic_task)

	register_forward(FM_CmdStart, "flora_noclip_control")

	set_task(0.35,"flora_checks",FLORA_GLOBAL_TASKID,_,_,"b")

	register_think(FLORA_FIELD_CLASSNAME, "field_think")
	init_hud_syncs()

}

public flora_noclip_control(id, uc_handle)
{	
	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)||
			!Get_BitVar(g_curr_flora_noclip_mask,id)){
			return FMRES_IGNORED;
	}
	static buttons;
	buttons = get_uc(uc_handle, UC_Buttons)

	if(buttons & IN_DUCK){

		buttons &= (~IN_DUCK)
		set_uc(uc_handle,UC_Buttons,buttons)
		return FMRES_SUPERCEDE

	}
	return FMRES_IGNORED;

}

public plugin_natives(){

	register_native("clear_fields","_clear_fields");
	register_native("reset_flora_user","_reset_flora_user");
	register_native("field_get_user_field_cooldown","_field_get_user_field_cooldown")
	register_native("field_uncharge_user","_field_uncharge_user")
	register_native("form_field","_form_field")
	register_native("field_loaded","_field_loaded")
	register_native("clear_user_fields","_clear_user_fields")
	register_native("flora_get_cooldown","_flora_get_cooldown")
	register_native("flora_get_user_num_active_fields","_flora_get_user_num_active_fields")
	register_native("flora_set_user_num_active_fields","_flora_set_user_num_active_fields")
	register_native("flora_dec_user_num_active_fields","_flora_dec_user_num_active_fields")
	register_native("flora_inc_user_num_active_fields","_flora_inc_user_num_active_fields")
	
	
	register_native("flora_get_user_is_cloaked","_flora_get_user_is_cloaked")
	register_native("flora_get_curr_inside","_flora_get_curr_inside")
	register_native("flora_get_prev_inside","_flora_get_prev_inside")
	

	

}
public plugin_cfg(){

	gHeroID = flora_get_hero_id()
	gHeroLevel = flora_get_hero_lvl()
	field_drain_wpn_id=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_field_drain,
								dmg_source_name_log_field_drain,
								0)
	generic_suffocation_wpn_id = get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_SUFFOCATION)
}
//this assumes lots of shit
noclip_flora(id){
	if(!Get_BitVar(g_prev_flora_noclip_mask,id)){

		emit_sound(id,CHAN_BODY, FIELD_DIG_SOUND, VOL_NORM, ATTN_NONE, 0, 110)

	}
	Assign_BitVar(g_curr_flora_noclip_mask,id, true_for_macro)
	entity_set_int(id,EV_INT_movetype,MOVETYPE_NOCLIP)
}

unoclip_flora(id){

	Assign_BitVar(g_curr_flora_noclip_mask,id, false_for_macro)
	entity_set_int(id,EV_INT_movetype,MOVETYPE_WALK)
}

public _flora_get_user_num_active_fields(iPlugin,iParams){
	new id=get_param(1)
	
	return g_flora_num_of_active_fields[id]

}
public _flora_set_user_num_active_fields(iPlugin,iParams){
	new id=get_param(1)
	new value=get_param(2)

	g_flora_num_of_active_fields[id]= value

}
public _flora_dec_user_num_active_fields(iPlugin,iParams){
	new id=get_param(1)
	new value=get_param(2)

	g_flora_num_of_active_fields[id]= (g_flora_num_of_active_fields[id]>0)? (g_flora_num_of_active_fields[id]-value):0

}
public _flora_inc_user_num_active_fields(iPlugin,iParams){
	new id=get_param(1)
	new value=get_param(2)

	g_flora_num_of_active_fields[id]=((g_flora_num_of_active_fields[id]+value)>=
		cvar_val(num,pcvar_flora_field_max_active_ammount))?
		cvar_val(num,pcvar_flora_field_max_active_ammount):g_flora_num_of_active_fields[id]+value

}
public _field_uncharge_user(iPlugin,iParams){
	new id=get_param(1)
	uncharge_user(id)


}
public _field_loaded(iPlugin,iParams){
	new id=get_param(1)
	
	return Get_BitVar(g_flora_field_loaded_mask,id)


}
public Float:_flora_get_cooldown(iPlugins, iParams){
	
	return cvar_val(float,pcvar_field_cooldown)
	
}
public _clear_user_fields(iPlugin,iParams){
	
	new id= get_param(1)
	if(!is_user_connected(id)) return
	new grenada = find_ent_by_owner(-1, FLORA_FIELD_CLASSNAME, id);
	while(grenada) {
		destroy_field(grenada,1)
		grenada = find_ent_by_owner(-1, FLORA_FIELD_CLASSNAME, id);
	}
	if(is_user_connected(id)){
		emit_sound(id, CHAN_VOICE, FIELD_HEAL, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		emit_sound(id, CHAN_AUTO, FIELD_TELEPORT, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
	}
	
}
public _clear_fields(iPlugin,iParams){
	
	new grenada = find_ent_by_class(-1, FLORA_FIELD_CLASSNAME)
	while(grenada) {
		
		destroy_field(grenada,1)
		grenada = find_ent_by_class(grenada,  FLORA_FIELD_CLASSNAME)
		
	}
}

public Float:_field_get_user_field_cooldown(iPlugin,iParams){
	new id=get_param(1)
	
	return g_flora_field_cooldown[id]


}
public _flora_get_user_is_cloaked(iPlugin,iParams){
	new id=get_param(1)
	
	return Get_BitVar(g_curr_flora_cloaked_mask,id)


}
public _flora_get_curr_inside(iPlugin,iParams){
	new id=get_param(1)
	
	return g_flora_curr_inside[id]


}
public _flora_get_prev_inside(iPlugin,iParams){
	new id=get_param(1)
	
	return g_flora_prev_inside[id]


}
Float:get_player_alpha(id){
	
	new Float:alphaMult=1.0;
	new player_lvl,lvl_diff;
	if(is_user_alive(id)){
		if(sh_get_user_has_hero(id,gHeroID)){
			player_lvl=sh_get_user_lvl(id)
			lvl_diff=player_lvl-gHeroLevel
			alphaMult=floatmax(
				cvar_val(float, pcvar_flora_invis_alpha_min),
				cvar_val(float, pcvar_flora_invis_alpha_max)-
				(float(lvl_diff)*
				cvar_val(float, pcvar_flora_invis_alpha_dec_per_lvl)))
		}
	}
	return alphaMult
	

}
public _reset_flora_user(iPlugin,iParams){
	
	new id= get_param(1)
	
	clear_user_fields(id)
	uncharge_user(id)
	Assign_BitVar(g_flora_field_loaded_mask,id,true_for_macro);
	g_flora_field_cooldown[id]=0.0;
	g_flora_num_of_active_fields[id]=0;
	Assign_BitVar(g_prev_flora_cloaked_mask,id,false_for_macro);
	Assign_BitVar(g_curr_flora_cloaked_mask,id,false_for_macro);
	g_flora_curr_charging[id]=-1
	g_flora_curr_inside[id]=-1
	g_flora_prev_inside[id]=-1
	
	
}
/*

this function assumes shite

*/
flora_damage_code_reduction(id,Float:the_suffocation_health_fraction=1.0, remove_god=false){

	if(!is_user_alive(id)){
		return
	}
	if(get_user_godmode(id)&&!remove_god){
		return
	}
	new Float:the_hp= entity_get_float(id,EV_FL_health)

	new Float:damage_to_take = (the_hp*the_suffocation_health_fraction)

	sh_screen_shake(id, 6.0,4.0,30.0)
	
	sh_screen_fade(id, 0.5,4.0,100,0,0,200)

	sh_set_stun(id,4.0,130.0)

	user_slap(id,0,1)


	/*
	
	
	breaking myself into piieeceees

	This is my last resooort

	suffocation
	
	no breeeathiiinng
	
	*/

	set_damage_icon(id, 1, DMG_ICON_DROWN,LineColors[FX_STUN],4.0)
	
	if(remove_god){

		set_user_godmode(id)
		
	}
	sh_extra_damage(id,id,floatround(damage_to_take),
		_,_,_,_,_,
		SH_NEW_DMG_SUFFOCATION,
		generic_suffocation_wpn_id)
}
destroy_field(field_id,make_sound=0,planting=0){

	if(is_valid_ent(field_id)){
		new owner=entity_get_edict(field_id,EV_ENT_owner)
		if(make_sound){
			emit_sound(field_id, CHAN_AUTO, FIELD_DESTROYED, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
		suck_in_sound(field_id,0)
		emit_sound(field_id, CHAN_ITEM, FIELD_HUM, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		emit_sound(field_id, CHAN_ITEM, FIELD_CHARGING, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		if(is_user_connected(owner)){
			if(sh_get_user_has_hero(owner,gHeroID)){
				new prev_num_active_here = g_flora_num_of_active_fields[owner]
				if(!planting){
					g_flora_num_of_active_fields[owner]=
								(g_flora_num_of_active_fields[owner]>0)? (g_flora_num_of_active_fields[owner]-1):0

				}
				if(is_user_alive(owner)){
					if(Get_BitVar(g_curr_flora_noclip_mask,owner)){
						new bool:flora_has_to_die = (prev_num_active_here<=1)
							
						
						
						new Float:user_origin[3]
						entity_get_vector(owner,EV_VEC_origin,user_origin)
						if(!sh_hull_vacant(owner,user_origin,HULL_HUMAN)){
							
							sh_chat_message(owner,gHeroID,"You were noclipping and were inside a wall as your last field dies. You die as well")
							
							/*
							
							wake me up inside
							(Cant wake up)
							Wake me up insi--
							(Saaave meeee)
							Call my name
							and saaaaave me
							frooom
							the
							daaaark



							You gotta kill this player fr
							Otherwise they [will] get stuck.
							And it ranges from annoying
							to "Youre 100% gonna die anyway"
							So lets slay them

							We have to remove godmode tho

							So the flag is set to 1 in the parameters

							...


							ooor
							we can just [not] take her noclip away
							if she has fields left...
							this will always result in her dying with no fields

							she is kind of slow

							so lets urge her on, anyway

							She is smart
							but she is slow
							We respect all kinds of minds, here.
							Its an ND friendly institution

							*/
							sh_chat_message(owner, gHeroID, flora_has_to_die?"You had one field left. Im sorry, Flora":"Hey, please go back to a field. You'll suffocate")
							flora_damage_code_reduction(owner,1.0/(float(prev_num_active_here)),flora_has_to_die)

						}

					}
				}
				if(!Get_BitVar(g_curr_flora_noclip_mask,owner)){
					Assign_BitVar(g_curr_flora_cloaked_mask,owner, false_for_macro);
					apply_cloak(owner)
				}
				if(field_id==g_flora_curr_inside[owner]){
			
					g_flora_curr_inside[owner]=-1;
				}
				if(field_id==g_flora_prev_inside[owner]){
			
					g_flora_prev_inside[owner]=-1;
				}
		
			}
		}
		remove_entity(field_id)
	}
	
}
find_next_nearest_flora_field(player_id,field_to_exclude=-1,Float:distance){
	
	if ( !is_user_alive(player_id)||!sh_get_user_has_hero(player_id,gHeroID) ){
		
	
			return -1
	
	}
	new Float:distance_to_contain=
				floatmin(cvar_val(float,pcvar_flora_teleport_reach_max_distance),
				floatmax(distance,cvar_val(float,pcvar_field_radius)*2.0))
	
	
	new Float:best_distance=9999999.0
	new field_id = find_ent_by_owner(-1, FLORA_FIELD_CLASSNAME,player_id)
	new best_id=-1
	while(field_id) {
		new new_field_id= find_ent_by_owner(field_id, FLORA_FIELD_CLASSNAME,player_id)
		
		if(is_valid_ent(field_to_exclude)){
			
			if(field_to_exclude==field_id){
				field_id=new_field_id
				
				continue
			}
			
		}
		
		new Float:distance_between=entity_range(player_id,field_id)
		if((distance_between<distance_to_contain)&&(distance_between<best_distance)){
			
				best_distance=distance_between
				best_id=field_id
			
		}
		field_id=new_field_id
	}
	
	return best_id
	
}
public flora_checks(task_id){

	if(!sh_is_active()||sh_is_freezetime()) return


	new the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "a")
	for (new i = 0; i < pnum; i++) {
		
		id = the_players[i]
		

		if(!sh_get_user_has_hero(id,gHeroID)) continue
		
		if(sh_get_stun(id)) continue
		
		g_prev_flora_button[id]=g_curr_flora_button[id]
		new button = entity_get_int(id,EV_INT_button);
		g_curr_flora_button[id]=button;

		Assign_BitVar(g_prev_flora_noclip_mask,id,Get_BitVar(g_curr_flora_noclip_mask,id));
		Assign_BitVar(g_prev_flora_cloaked_mask,id,Get_BitVar(g_curr_flora_cloaked_mask,id));

		new is_on_the_ground = (entity_get_int( id, EV_INT_flags ) & FL_ONGROUND  ),
			is_crouched= (g_curr_flora_button[id] & IN_DUCK )
		
		if((!is_on_the_ground&&!Get_BitVar(g_curr_flora_noclip_mask,id))){
			g_flora_sheltered_value[id]=enum_zero;
			Assign_BitVar(g_curr_flora_cloaked_mask,id,false_for_macro);
			apply_cloak(id)
			continue
		}
		g_flora_prev_sheltered_value[id]=g_flora_sheltered_value[id]
		new field_id,flora_sheltered_values:flora_sheltered_value=is_flora_user_in_owned_field(id,field_id)
		g_flora_sheltered_value[id]=flora_sheltered_value;
		
		
		new bool:did_we_get_stuck = false
		
		if(Get_BitVar(g_curr_flora_noclip_mask,id)){
			static Float:player_origin[3]
			new the_ent_we_got_stuck_on = 0
			entity_get_vector(id,EV_VEC_origin,player_origin)
			/*
			she doesnt like free air. free air == stuck for her
			*/
			did_we_get_stuck=sh_hull_vacant(id,player_origin,HULL_HUMAN,the_ent_we_got_stuck_on)
			if(did_we_get_stuck){
				unoclip_flora(id)
				if((g_flora_sheltered_value[id]<=OUTSIDE)){
					sh_chat_message(id, gHeroID, "You got stuck on furniture. You shall get punished.")
					
					new Float:max_distance = cvar_val(float,pcvar_flora_teleport_reach_max_distance),
						Float:the_distance=999999.0,
						field_id_nearest=find_next_nearest_flora_field(id,_,the_distance);

					if(is_valid_ent(field_id_nearest)){
						the_distance = entity_range(field_id_nearest,id)
					}
					else{
						the_distance= max_distance
						
					}
					new Float:distance_ratio = floatclamp(the_distance/
								max_distance,0.01,
								cvar_val(float, pcvar_bad_resurface_dmg_penalty_max_hp_ratio))

					flora_damage_code_reduction(id,distance_ratio)
					continue
				}
			}
			else{
				emit_sound(id,CHAN_BODY, FIELD_DIG_SOUND, VOL_NORM, ATTN_NONE, 0, 70)
				engclient_cmd(id, "weapon_knife")
			}
		}
		
		if(g_flora_curr_inside[id]!=field_id){
			g_flora_curr_dmg_mult[id]=((g_flora_sheltered_value[id]>enum_zero?1.0:0.0))
							*floatpower(
							cvar_val(float,pcvar_flora_field_heal_mult),
							float(_:(g_flora_sheltered_value[id]-enum_one)))

			g_flora_prev_inside[id]=g_flora_curr_inside[id]
			g_flora_curr_inside[id]=g_flora_sheltered_value[id]<=OUTSIDE?-1:field_id
		}

		g_flora_dmg_color[id]=flora_damage_colors[g_flora_sheltered_value[id]]
		
		
		/*
		
		if she isnt sheltered, only noclip controls invisibility
		
		*/
		
		if((g_flora_sheltered_value[id]<SHELTERED)){
			Assign_BitVar(g_curr_flora_cloaked_mask,id,Get_BitVar(g_curr_flora_noclip_mask,id));
			apply_cloak(id)
			continue
		}
		
		/*
		
		if she is, either crouch or noclip grant invisibility
		
		*/
		
		Assign_BitVar(g_curr_flora_cloaked_mask,id,is_crouched||Get_BitVar(g_curr_flora_noclip_mask,id));
		apply_cloak(id)
		
		/*

		if (all this crap), make her noclip
		forcing her to uncrouch first
		as to maintain maxspeed

		*/

		if((g_curr_flora_button[id] & IN_RELOAD)&&
			(get_user_weapon(id)==CSW_KNIFE)&&
			!Get_BitVar(g_prev_flora_noclip_mask,id)&&
			!did_we_get_stuck&&
			is_crouched){
			

			new flags= entity_get_int(id,EV_INT_flags)
			flags&= (~FL_DUCKING)
			entity_set_int(id,EV_INT_flags,flags)


			
			noclip_flora(id)

		}
		/*

		If she is not inside of a core,
		continue

		*/

		if((g_flora_sheltered_value[id]<DUNGEON_DWELLER)){
			continue
		}
		/*
		
		we are inside of a core AND we had a positive crouch press?
		Teleport!
		
		*/

		if(!(g_prev_flora_button[id] & IN_DUCK)&&is_crouched){
			
			apply_teleport(id,field_id)
		}

		/*

		You reached your destination

		*/

			
	}
}
flora_sheltered_values:is_flora_user_in_owned_field(player_id,&field_id=-1){
	
	new grenada = find_ent_by_owner(-1, FLORA_FIELD_CLASSNAME,player_id)
	while(grenada) {
		new Float:distance=entity_range(grenada,player_id)
		if(distance<cvar_val(float,pcvar_field_radius)){
			field_id=grenada;
			if(distance<cvar_val(float,pcvar_field_core_radius)){
				return DUNGEON_DWELLER
			}
			return SHELTERED
		}
		grenada = find_ent_by_owner(grenada, FLORA_FIELD_CLASSNAME,player_id)
	}
	field_id=-1
	return OUTSIDE
	
}
public plugin_precache(){


	engfunc(EngFunc_PrecacheModel,SPHERE_MODEL)
	engfunc(EngFunc_PrecacheSound,FIELD_DEPLOYED)
	engfunc(EngFunc_PrecacheSound,FIELD_DESTROYED)
	engfunc(EngFunc_PrecacheSound,FIELD_HUM)
	engfunc(EngFunc_PrecacheSound,FIELD_TELEPORT)
	engfunc(EngFunc_PrecacheSound,FIELD_HEAL)
	engfunc(EngFunc_PrecacheSound,FIELD_CHARGING)
	engfunc(EngFunc_PrecacheSound,FIELD_DIG_SOUND)
	
	
}

public _form_field(iPlugin,iParams)
{
	if(!sh_is_active()||sh_is_freezetime()) return
	new id= get_param(1)
	
	if(!is_user_alive(id)) return

	if(!sh_get_user_has_hero(id,gHeroID)) return
	
	if(!flora_get_user_num_fields(id)){
		
		client_print(id,print_center,"You ran out of fields")
		return
		
	}
	if(!Get_BitVar(g_flora_field_loaded_mask,id)){
		
		sh_chat_message(id,gHeroID,"Field not loaded")
		return
	}

	
	new Float: Origin[3],  Ent
	
	entity_get_vector(id, EV_VEC_origin , Origin)
	
	Origin[2]+=50.0
	Ent = my_create_entity("info_target")
	
	if(pev_valid(Ent)!=2){
		
		sh_chat_message(id,gHeroID,"Field failure!");
		return
	}
	
	entity_set_string(  Ent, EV_SZ_classname, FLORA_FIELD_CLASSNAME );
	entity_set_int(  Ent , EV_INT_solid, SOLID_BBOX);
	entity_set_model(  Ent , SPHERE_MODEL );
	new Float:fl_vecminsx[3]
	new Float:fl_vecmaxsx[3]
	for (new i=0;i<3;i++){
		fl_vecminsx[i]=-cvar_val(float,pcvar_field_core_radius)
		fl_vecmaxsx[i]=cvar_val(float,pcvar_field_core_radius)
	
	}
	entity_set_vector(Ent, EV_VEC_mins,fl_vecminsx)
	entity_set_vector(Ent, EV_VEC_maxs,fl_vecmaxsx)
	
	
	entity_set_edict(Ent, EV_ENT_owner, id)
	entity_set_float(Ent,EV_FL_fuser1,0.0)
	entity_set_origin(Ent,Origin);
	g_flora_curr_charging[id]=Ent;
	Assign_BitVar(g_flora_field_loaded_mask,id,false_for_macro);
	
	entity_set_int(Ent, EV_INT_movetype, MOVETYPE_FLY) //5 = movetype_fly, No grav, but collides.
	entity_set_int(Ent,EV_INT_rendermode,kRenderTransAlpha)
	entity_set_int(Ent,EV_INT_renderfx,kRenderFxGlowShell)
	
	
	
	glow(Ent,LineColors[ORANGE][0],LineColors[ORANGE][1],LineColors[ORANGE][2],100,1)
	//set deployed status
	entity_set_int(Ent,EV_INT_iuser1,0)

	emit_sound(Ent, CHAN_ITEM, FIELD_CHARGING, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	entity_set_float(Ent,EV_FL_nextthink,floatadd(get_gametime(),FLORA_CHARGE_PERIOD))
}
public cooldown_update_task(id){
	
	id-=FLORA_COOLDOWN_TASKID
	g_flora_field_cooldown[id]=g_flora_field_cooldown[id]-FLORA_CHARGE_PERIOD
	if(g_flora_field_cooldown[id]<=0.0){
		Assign_BitVar(g_flora_field_loaded_mask,id,true_for_macro);
	
	}
	
	
}
public end_cooldown_update_tasks(id){
	
	
	remove_task(id+FLORA_COOLDOWN_TASKID)
}
public field_deploy_task(id,field_id){
	
	if(pev_valid(field_id)!=2){
		
		return
	
	}
	entity_set_int(field_id,EV_INT_solid, SOLID_BBOX)
	entity_set_vector(field_id,EV_VEC_velocity,null_vector)
	entity_set_int(field_id,EV_INT_movetype, MOVETYPE_FLY)
	flora_dec_user_num_fields(id,1)
	flora_inc_user_num_active_fields(id,1)
	
	client_print(id,print_center,"You have %d fields left!",flora_get_user_num_fields(id))
	g_flora_field_cooldown[id]=cvar_val(float,pcvar_field_cooldown)
	set_task(FLORA_CHARGE_PERIOD,"cooldown_update_task",id+FLORA_COOLDOWN_TASKID,"", 0,  "a",
			floatround(cvar_val(float,pcvar_field_cooldown)/FLORA_CHARGE_PERIOD)+1)
	
	entity_set_float(field_id,EV_FL_fuser2,floatadd(
			cvar_val(float,pcvar_flora_field_time),FIELD_ACTIVE_TIME_BUFFER))
	g_flora_curr_charging[id]=-1
	
	emit_sound(field_id, CHAN_ITEM, FIELD_HUM, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	entity_set_float(field_id,EV_FL_nextthink,floatadd(get_gametime(),FLORA_THINK_PERIOD))
	
}
public apply_teleport(id,field_inside) {
	
	if(pev_valid(field_inside)!=2){
		
		return
	
	}
	if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)){
		
		return

	}
	new Float: fOrigin[ 3 ],Float:other_field_origin[3]
	entity_get_vector( id, EV_VEC_origin, fOrigin );
	

	if(flora_get_user_num_active_fields(id)>1){
		new field_id=find_next_nearest_flora_field(id,field_inside,999999.0)
		if(is_valid_ent(field_id)){
			entity_get_vector( field_id, EV_VEC_origin, other_field_origin );
			entity_set_vector( id, EV_VEC_origin, other_field_origin );
			emit_sound(id, CHAN_AUTO, FIELD_TELEPORT, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			static entlist[33];
			new numfound = find_sphere_class(field_id,"player", cvar_val(float,pcvar_field_radius) ,entlist, 32);

			for( new i= 0;(i< numfound);i++){
			
				new pid = entlist[i];
				if(pid==id){

					continue
				}
				if(sh_clients_are_same_team(id,pid)){

					sh_chat_message(pid, gHeroID,"Flora asks: ^"Hey! Do you like bugs?^"")
					break;
				}

			}
		}
		else{
			sh_chat_message(id,gHeroID,"Teleporting was not possible (too far)")
			
			
		}
	}
	return
}

apply_cloak(id){
	
	if(!is_user_alive(id)||!sh_get_user_has_hero(id,gHeroID)){
		
		Assign_BitVar(g_curr_flora_cloaked_mask,id,false_for_macro);
		Assign_BitVar(g_prev_flora_cloaked_mask,id,false_for_macro);
		return 

	}
	if(Get_BitVar(g_curr_flora_cloaked_mask,id)==Get_BitVar(g_prev_flora_cloaked_mask,id)){

		return
	}

	new Float:alpha_to_use=get_player_alpha(id)
	new alpha_value_to_use=floatround(float(255)*alpha_to_use)
	if(Get_BitVar(g_curr_flora_cloaked_mask,id)){
		sh_set_rendering(id,0,0,0,alpha_value_to_use,kRenderFxGlowShell,kRenderTransColor);
	}
	else{
		
		sh_set_rendering(id)
	}
}
//----------------------------------------------------------------------------------------------
public field_think(ent)
{
	if ( pev_valid(ent)!=2 ){
		
	
			return
	
	}
	new Float:gametime
	static Float:ent_pos[3]
	static entlist[33];
	gametime = get_gametime()
	new owner=entity_get_edict(ent,EV_ENT_owner)

	//get deployed status
	new deployed=entity_get_int(ent,EV_INT_iuser1)
	if(!deployed){

		charge_iteration(owner,ent)
		return
	}
	if (entity_get_float(ent,EV_FL_fuser2)<FIELD_ACTIVE_TIME_BUFFER) {
		if(pev_valid(ent)==2){
			sh_chat_message(owner,gHeroID,"Field died!")
			
			destroy_field(ent,1)
		}
		return
	}
	else{//60
		entity_get_vector(ent, EV_VEC_origin, ent_pos)
		make_shockwave(ent_pos,cvar_val(float,pcvar_field_radius),{255, 255, 0},_,_,_,_,60)
		make_shockwave(ent_pos,cvar_val(float,pcvar_field_core_radius),{255, 128, 0},_,_,_,_,60)
		new numfound = find_sphere_class(ent,"player", cvar_val(float,pcvar_field_radius) ,entlist, 32);

		for( new i= 0;(i< numfound);i++){
		
			new pid = entlist[i];
			if(pid==owner){

				continue
			}
			if(!is_user_alive(pid)){
				if(is_user_connected(pid)){
					set_render_with_color_const(pid,INVIS,1,10,_,0)
				}
				
				continue
			
			}
			if(sh_clients_are_same_team(pid,owner)){

				continue
			}
			if(g_flora_sheltered_value[owner]>OUTSIDE){
				new Float:fdamage=floatmin(float(get_user_health(owner)) , floatmul(float(get_user_health(pid)),floatmin(floatmax(0.0,cvar_val(float,pcvar_flora_dmg_coeff)*g_flora_curr_dmg_mult[owner]),0.99)))
				new Float: needs_health=float(sh_get_max_hp(owner)-get_user_health(owner))
				new actual_damage=floatround(floatmax(0.0+(g_flora_sheltered_value[owner]>SHELTERED?1.0:0.0),floatmin(needs_health-1.0,fdamage)))
								
				sh_extra_damage(pid,owner,actual_damage,
								_,_,_,_,_,
								SH_NEW_DMG_DRAIN,
								field_drain_wpn_id)
				
				if(actual_damage>0){

					sh_set_stun(pid,cvar_val(float,pcvar_flora_stun_time),cvar_val(float,pcvar_flora_base_stun_speed))
				
				}
				set_render_with_color_const(pid,g_flora_dmg_color[owner],1,255,90,1,_,
								cvar_val(float,pcvar_flora_stun_time))
				set_damage_icon(pid,2,DMG_ICON_BIO,LineColors[g_flora_dmg_color[owner]],1.0)
				generic_heal(heal_hp_hud_msg_sync,owner,fdamage,_,g_flora_dmg_color[owner],FLORA_HEAL_GLOWING_ON,FLORA_HEAL_GLOW_TIME,100,1,1,FIELD_HEAL)
			}
		}
		entity_set_float(ent,EV_FL_nextthink,floatadd(gametime,FLORA_THINK_PERIOD))
		entity_set_float(ent,EV_FL_fuser2,floatsub(entity_get_float(ent,EV_FL_fuser2),FLORA_THINK_PERIOD))
	
	}
}
uncharge_user(id){
	
	if(pev_valid(g_flora_curr_charging[id])==2){
		
		emit_sound(g_flora_curr_charging[id], CHAN_ITEM, NULL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(g_flora_curr_charging[id], CHAN_ITEM, FIELD_CHARGING, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		destroy_field(g_flora_curr_charging[id],0,1)
		Assign_BitVar(g_flora_field_loaded_mask,id,true_for_macro);
		g_flora_curr_charging[id]=-1;
	}
	
	
	
}

public load_field(id){
	id-=FLORA_LOAD_TASKID;
	
	Assign_BitVar(g_flora_field_loaded_mask,id,true_for_macro);
	sh_chat_message(id,gHeroID,"Field loaded");
	
	
}
public charge_iteration(owner,field_id){

	
	
	if(!is_user_alive(owner)||!sh_get_user_has_hero(owner,gHeroID)){
		uncharge_user(owner)
		return
	}
	
	if(pev_valid(field_id)!=2) {
		uncharge_user(owner)
		return
	}
	
	new test_edict=find_next_nearest_flora_field(owner,field_id,0.0)
	if(is_valid_ent(test_edict)){
		sh_sound_deny(owner)
		sh_chat_message(owner,gHeroID,"This spore is too close to another one of yours! Will not plant.")
		uncharge_user(owner)
		return
	}
	
	if(!(entity_get_int( owner, EV_INT_flags ) & FL_ONGROUND  )){
		
		sh_sound_deny(owner)
		sh_chat_message(owner, gHeroID, "Charging stopped. You cannot charge a field while airborne")
		uncharge_user(owner)
		return
		
	}
	new Float:vOrigin[3]
	new Float:vAngles[3]
	new Float:velocity[3]
	entity_get_vector(owner, EV_VEC_origin, vOrigin)
	entity_get_vector(owner, EV_VEC_v_angle, vAngles)
	new notFloat_vOrigin[3]
	notFloat_vOrigin[0] = floatround(vOrigin[0])
	notFloat_vOrigin[1] = floatround(vOrigin[1])
	notFloat_vOrigin[2] = floatround(vOrigin[2])
	
	entity_set_origin(field_id, vOrigin)
	entity_set_vector(field_id, EV_VEC_angles, vAngles)
	entity_get_vector(owner, EV_VEC_velocity, velocity)
	entity_set_vector(field_id, EV_VEC_velocity,  velocity)
	
	// switch to knife
	engclient_cmd(owner, "weapon_knife")
	
	static hud_msg[128];
	entity_set_float(field_id,EV_FL_fuser1,floatadd(entity_get_float(field_id,EV_FL_fuser1),FLORA_CHARGE_PERIOD))
	formatex(hud_msg,127,"[SH] flora: Charging... ^n %0.2f percent done",(entity_get_float(field_id,EV_FL_fuser1)/cvar_val(float,pcvar_flora_charge_time))*100.0);
	client_print(owner,print_center,"%s",hud_msg)
	
	
	if(entity_get_float(field_id,EV_FL_fuser1)>cvar_val(float,pcvar_flora_charge_time)){
		//set deployed status

		emit_sound(field_id, CHAN_ITEM, NULL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(field_id, CHAN_ITEM, FIELD_CHARGING, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
		entity_set_int(field_id,EV_INT_iuser1,1)
		field_deploy_task(owner,field_id)
	}
	entity_set_float(field_id,EV_FL_nextthink,floatadd(get_gametime(),FLORA_CHARGE_PERIOD))
	
	
	
	
	
}
