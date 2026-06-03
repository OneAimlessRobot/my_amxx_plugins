#define I_WANT_CONSTANTS
#define I_WANT_QUICK_CHECKS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#include "../my_include/superheromod.inc"
#include "jetplane_inc/sh_jetplane_funcs.inc"
#include "jetplane_inc/sh_jetplane_mg_funcs.inc"
#include "jetplane_inc/sh_jetplane_rocket_funcs.inc"
#include "jetplane_inc/sh_yandere_get_set.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"


#define PLUGIN "Superhero yandere JETGATLING funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new user_mg[SH_MAXSLOTS+1]

new gHeroID = -1

new pcvar_jetplane_mg_dmg,
pcvar_jetplane_mg_bulletspeed,
pcvar_jetplane_mg_ammo;


new dmg_source_name_short_mg_gatling[SAFE_BUFFER_SIZE+1]="yandere_bullet"
new dmg_source_name_log_mg_gatling[SAFE_BUFFER_SIZE+1]="yandere_bullet"
new custom_dmg_id_mg_gatling

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	pcvar_jetplane_mg_ammo = create_cvar("yandere_jetplane_mg_ammo", "5")
	pcvar_jetplane_mg_dmg = create_cvar("yandere_jetplane_mg_dmg", "5")
	pcvar_jetplane_mg_bulletspeed = create_cvar("yandere_jetplane_mg_bulletspeed", "5")
	register_forward(FM_CmdStart, "CmdStart");
	register_think(JETPLANE_MG_CLASSNAME, "mg_think")


	register_entity_as_wall_touchable(JETPLANE_SHELL_CLASSNAME,"shell_hit_wall")
	static const jetplane_classid_vector[][]={JETPLANE_FUSELAGE_CLASSNAME}
	register_custom_touchable(JETPLANE_SHELL_CLASSNAME,"shell_hit_jet",jetplane_classid_vector,1)
	register_custom_touchable(JETPLANE_SHELL_CLASSNAME,"shell_hit_player",player_vector,1)
	
}

public plugin_natives(){

	register_native("mg_destroy","_mg_destroy");
	register_native("spawn_jetplane_mg","_spawn_jetplane_mg");
	register_native("get_user_jet_shells","_get_user_jet_shells");
	register_native("reset_jet_shells","_reset_jet_shells");
	
}
public plugin_cfg(){

	gHeroID = yandere_get_hero_id()

	custom_dmg_id_mg_gatling=sh_log_custom_damage_source(gHeroID,
				dmg_source_name_short_mg_gatling,
				dmg_source_name_log_mg_gatling,
				0)
}
get_jet_shells(jet_id){

	new num_shells=pev(jet_id,pev_iuser2)
	return num_shells;
	
}
set_jet_shells(jet_id, the_shells){

	set_pev(jet_id,pev_iuser2,the_shells)
}
public _reset_jet_shells(iPlugins,iParams){
	new jet_id=get_param(1)
	
	set_pev(jet_id,pev_iuser2,cvar_val(num, pcvar_jetplane_mg_ammo))
}
public _get_user_jet_shells(iPlugins,iParams){
	
	new id=get_param(1)
	return get_jet_shells(jet_get_user_jet(id))
	
}
set_user_jet_shells(id, the_shells){

	set_jet_shells(jet_get_user_jet(id),the_shells)
	
}
public _spawn_jetplane_mg(iPlugins,iParams){
	
	new id=get_param(1)
	new jetplane_id=jet_get_user_jet(id)
	
	
	new material[128]
	new health[128]	
	new Float:jetplane_orig[3]
	pev(jetplane_id,pev_origin,jetplane_orig)
	new mg_id = my_create_entity( "func_breakable" );
	if(!is_valid_ent(mg_id)||(mg_id <= 0)) {
		
		sh_chat_message(id,gHeroID,"Mg failed to spawn")
		return
	}
	user_mg[id]=mg_id
	set_pev(mg_id,pev_owner,id)
	set_pev(mg_id, pev_takedamage, DAMAGE_YES)
	set_pev(mg_id, pev_solid, SOLID_TRIGGER)
	set_pev(mg_id , pev_classname, JETPLANE_MG_CLASSNAME)
	engfunc(EngFunc_SetModel, mg_id , P_MACHINEGUN_MODEL)
	float_to_str(1250.0,health,127)
	num_to_str(2,material,127)
	my_set_kvd(  mg_id , "material", material );
	my_set_kvd(  mg_id , "health", health );
	set_pev(mg_id,pev_rendermode,kRenderTransAlpha)
	set_pev(mg_id,pev_renderfx,kRenderFxGlowShell)
	new alpha=255;
	set_pev(mg_id,pev_renderamt,float(alpha))
	entity_set_vector(mg_id, EV_VEC_mins,jetplane_mg_min_dims)
	entity_set_vector(mg_id, EV_VEC_maxs,jetplane_mg_max_dims)
	jetplane_orig[0]+=jetplane_origin_mg_offsets[0]
	jetplane_orig[1]+=jetplane_origin_mg_offsets[1]
	jetplane_orig[2]+=jetplane_origin_mg_offsets[2]
	set_pev(mg_id,pev_origin,jetplane_orig)
	set_pev(mg_id, pev_nextthink, get_gametime() + MG_THINK_PERIOD)
}
public CmdStart(id, uc_handle)
{
	
	
	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if(!is_user_alive(id)){
			
		return FMRES_IGNORED
	}
	if(!jet_deployed(id)){
		return FMRES_IGNORED
	}
	if(sh_get_stun(id)) return FMRES_IGNORED

	new button = get_uc(uc_handle, UC_Buttons);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if((weapon==CSW_KNIFE)){
		if(user_mg[id]>0){
			if(button & IN_ATTACK)
			{
				button &= ~IN_ATTACK;
				set_uc(uc_handle, UC_Buttons, button);
				//retrieve gatling loaded
				new gatling_loaded=entity_get_int(user_mg[id],EV_INT_iuser1)
				if(!gatling_loaded) return FMRES_IGNORED
				if(!get_user_jet_shells(id))
				{
					client_print(id, print_center, "You are out of shells")
					return FMRES_IGNORED
				}
				launch_shell(id)
				
			}
		}
		else{
			
			client_print(id, print_center, "MG is unnavailable. Please try again later.")
			
		}
	}
	
	return FMRES_IGNORED;
}


//----------------------------------------------------------------------------------------------
public mg_think(ent)
{
	if ( !is_valid_ent(ent) ) return
	
	
	static Float:vEnd[3], Float:gametime,Float:Pos[3]
	pev(ent, pev_origin, Pos)
	pev(ent, pev_vuser1, vEnd)
	gametime = get_gametime()
	new owner=pev(ent,pev_owner)
	new bool:jet_deployed_here = bool:jet_deployed(owner)

	if ( !jet_deployed_here) {
		if(pev_valid(ent)){
			mg_destroy(owner)
			sh_chat_message(owner,gHeroID,"jet mg died cuz of plane dying!!")
		}
		return
	}
	new Float:mg_health=float(pev(ent,pev_health))
	
	if ( (mg_health<1000.0)) {
		if(pev_valid(ent)){
			mg_destroy(owner)
			sh_chat_message(owner,gHeroID,"jet mg died!")
		}
		return
	}
	if(jet_deployed_here){
		new user_jet=jet_get_user_jet(owner)
		new Float:vOrigin[3]
		entity_get_vector(user_jet, EV_VEC_origin, vOrigin)
		vOrigin[0]+=jetplane_origin_mg_offsets[0]
		vOrigin[1]+=jetplane_origin_mg_offsets[1]
		vOrigin[2]+=jetplane_origin_mg_offsets[2]
		entity_set_origin(ent, vOrigin)
		
		new Float:angles[3]
		entity_get_vector(user_jet, EV_VEC_v_angle, angles)
		entity_set_vector(ent, EV_VEC_v_angle, angles)
		entity_get_vector(user_jet, EV_VEC_angles, angles)
		entity_set_vector(ent, EV_VEC_angles, angles)
		entity_set_vector(ent, EV_VEC_velocity, NULL_VECTOR)
		new Float:current_mg_loading_time=entity_get_float(ent,EV_FL_fuser1)
		if(!entity_get_int(ent,EV_INT_iuser1)){
		
			if(current_mg_loading_time>0.0){
				entity_set_float(ent,EV_FL_fuser1,current_mg_loading_time-MG_THINK_PERIOD)
			}
			else{
				entity_set_int(ent,EV_INT_iuser1,1)
				entity_set_float(ent,EV_FL_fuser1,0.0)

			}
		}
		set_pev(ent, pev_nextthink, gametime + MG_THINK_PERIOD)
	}
}

launch_shell(id)
{
	
	if(!is_valid_ent(user_mg[id])) return PLUGIN_HANDLED

	new Float: Origin[3], Float: vAngle[3], Ent

	entity_get_vector(user_mg[id], EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)
	
	Origin[2]+=(jetplane_mg_max_dims[2]+10.0)
	
	Ent = my_create_entity("info_target")
	
	if (!Ent){
		sh_chat_message(id,gHeroID,"shell failed!");
		return PLUGIN_HANDLED
	}
	entity_set_string(Ent, EV_SZ_classname, JETPLANE_SHELL_CLASSNAME)
	entity_set_model(Ent, GUN_SHELL)
	
	new Float:MinBox[3] = {-1.0, -1.0, -1.0}
	new Float:MaxBox[3] = {1.0, 1.0, 1.0}
	entity_set_vector(Ent, EV_VEC_mins, MinBox)
	entity_set_vector(Ent, EV_VEC_maxs, MaxBox)
	
	
	entity_set_origin(Ent, Origin)
	entity_set_vector(Ent, EV_VEC_angles, vAngle)
	
	entity_set_int(Ent, EV_INT_solid, 2)
	entity_set_int(Ent, EV_INT_movetype, MOVETYPE_BOUNCEMISSILE)
	entity_set_edict(Ent, EV_ENT_owner, id)
	
	new Float:bullet_place_dir_vec[3],
			Float:Velocity[3],
			Float:dest_origin[3]
	new user_jet=jet_get_user_jet(id)
	velocity_by_aim(user_jet, LAUNCH_SAFETY_DIST, bullet_place_dir_vec)
	
	add_3d_vectors(Origin,bullet_place_dir_vec,dest_origin)

	entity_set_origin(Ent, dest_origin)

	velocity_by_aim(user_jet, floatround(cvar_val(float, pcvar_jetplane_mg_bulletspeed)), Velocity)
	

	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)
	
	new parm[1]
	set_user_jet_shells(id,get_user_jet_shells(id)-1)
	parm[0]=id
	//set gatling loaded
	entity_set_int(user_mg[id],EV_INT_iuser1,0)
	//set gatling loading timeout
	entity_set_float(user_mg[id],EV_FL_fuser1,MG_SHELL_PERIOD)
	
	
	emit_sound(id, CHAN_WEAPON, MACHINE_GUN_SOUND , VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	trail(Ent,PINK,10,2)
	
	return PLUGIN_CONTINUE
}

public shell_hit_wall(pToucher, pTouched){


	if(!is_valid_ent(pToucher)) return


	new Float:origin[3]
	entity_get_vector(pToucher,EV_VEC_origin,origin);

	make_sparks(origin);
	gun_shot_decal(origin)

	if(!is_valid_ent(pTouched)){
		
		my_remove_entity(pToucher)
		return
	}
	
	static szClassname[32]
	entity_get_string(pTouched,EV_SZ_classname,szClassname, charsmax(szClassname))
	if(equal(szClassname,"func_breakable")){
		static Float:bullet_launch_pos[3]
				
		entity_get_vector(pToucher,EV_VEC_vuser1,bullet_launch_pos)

		new owner=entity_get_edict(pToucher,EV_ENT_owner)
		
		ExecuteHam(Ham_TakeDamage, pTouched, pToucher, owner,
				cvar_val(float, pcvar_jetplane_mg_dmg),
				0);

	} 
	my_remove_entity(pToucher)

}
public shell_hit_player(pToucher, pTouched){

	if(!is_valid_ent(pToucher)) return

	if(is_user_alive(pTouched))
	{
		
		static Float:origin[3],
			Float:velocity[3],
			Float:speed,
			my_hitpoint_enum:the_hitpoint,
			bool:headshot=false
			
		entity_get_vector(pToucher,EV_VEC_origin,origin);
		entity_get_vector(pToucher,EV_VEC_velocity,velocity)
		speed=floatmin(1.0,vector_length(velocity))
		new oid = entity_get_edict(pToucher, EV_ENT_owner)
		
		new Float:damage=cvar_val(float, pcvar_jetplane_mg_dmg);
		the_hitpoint= get_projectile_hit_hitpoint(pToucher,
											velocity,
											20.0*3.0,
											speed)
		if(the_hitpoint==MY_HIT_HEAD){
			
			headshot=true;
			damage*=4;
		}
		if(!sh_clients_are_same_team(pTouched,oid)&&(pTouched!=oid)){
			sh_extra_damage(pTouched,oid,floatround(damage),
				the_hitpoint,
				SH_DMG_NORM,
				_,_,
				DMG_BULLET,
				SH_NEW_DMG_SUPER_BULLET,
				custom_dmg_id_mg_gatling);

			if(is_user_alive(pTouched)){
				new CsArmorType:armor_type;
				cs_get_user_armor(pTouched,armor_type);
				switch(armor_type){
					
					case CS_ARMOR_NONE:{
						
						
						emit_sound(pTouched, CHAN_VOICE,headshot?"player/headshot1.wav":"player/bhit_flesh-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						
						blood_spray(origin, headshot?10:5)
						
						
					}
					case CS_ARMOR_KEVLAR:{
						
						emit_sound(pTouched, CHAN_VOICE,headshot?"player/headshot1.wav":"player/bhit_kevlar-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						
						if(headshot){
							blood_spray(origin, 5)
						}
						else{
							
							make_sparks(origin);
						}
					}
					case CS_ARMOR_VESTHELM:{
						emit_sound(pTouched, CHAN_VOICE,headshot?"player/bhit_helmet-1.wav":"player/bhit_kevlar-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						make_sparks(origin);
					}
				}
			}
			
		}
	}
	my_remove_entity(pToucher)
}
public shell_hit_jet(pToucher, pTouched)
{

	if(!is_valid_ent(pToucher)) return

	new the_owner=entity_get_edict(pToucher,EV_ENT_owner)
	if((pTouched==jet_get_user_jet(the_owner))){

		my_remove_entity(pToucher)
		return

	}

	new jet_owner=entity_get_edict(pTouched,EV_ENT_owner)

	if(is_user_alive(jet_owner)){
		new CsTeams:att_team=cs_get_user_team(the_owner),
			CsTeams:vic_team=cs_get_user_team(jet_owner);
		if(att_team!=vic_team){
			jet_hurt_user_jet(jet_owner,the_owner,pToucher,cvar_val(float, pcvar_jetplane_mg_dmg))
		}
	}
	my_remove_entity(pToucher)
}
public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel,GUN_SHELL)
	engfunc(EngFunc_PrecacheModel,P_MACHINEGUN_MODEL)
	engfunc(EngFunc_PrecacheSound, MACHINE_GUN_SOUND)
	
}

public _mg_destroy(iPlugin,iParams){
	
	new id= get_param(1)
	
	if(is_valid_ent(user_mg[id])){
		my_remove_entity(user_mg[id]);
		user_mg[id]=-1;
	}
}