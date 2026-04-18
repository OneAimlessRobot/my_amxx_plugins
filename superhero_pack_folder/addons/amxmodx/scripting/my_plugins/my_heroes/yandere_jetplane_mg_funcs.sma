
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
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


new Float:jetplane_mg_dmg,
Float:jetplane_mg_bulletspeed;
stock Float:mg_think_period
new user_mg[SH_MAXSLOTS+1]
new jetplane_mg_ammo;




public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_cvar("yandere_jetplane_mg_ammo", "5")
	register_cvar("yandere_jetplane_mg_dmg", "5")
	register_cvar("yandere_jetplane_mg_bulletspeed", "5")
	register_cvar("yandere_jetplane_mg_think_period", "5")
	register_forward(FM_CmdStart, "CmdStart");
	register_think(JETPLANE_MG_CLASSNAME, "mg_think")


	register_entity_as_wall_touchable(JETPLANE_SHELL_CLASSNAME,"shell_hit_wall")
	static const jetplane_classid_vector[][]={JETPLANE_FUSELAGE_CLASSNAME}
	register_custom_touchable(JETPLANE_SHELL_CLASSNAME,"shell_hit_jet",jetplane_classid_vector,1)
	register_custom_touchable(JETPLANE_SHELL_CLASSNAME,"shell_hit_player",player_vector,1)
	
}


public plugin_cfg(){
	
	loadCVARS()
}
public loadCVARS(){
	jetplane_mg_dmg=get_cvar_float("yandere_jetplane_mg_dmg");
	jetplane_mg_bulletspeed=get_cvar_float("yandere_jetplane_mg_bulletspeed");
	jetplane_mg_ammo=get_cvar_num("yandere_jetplane_mg_ammo");
	mg_think_period=get_cvar_float("yandere_jetplane_mg_think_period");
}
public plugin_natives(){
	
	register_native("get_jet_shells","_get_jet_shells",0);
	register_native("mg_destroy","_mg_destroy",0);
	register_native("spawn_jetplane_mg","_spawn_jetplane_mg",0);
	register_native("set_jet_shells","_set_jet_shells",0);
	register_native("get_mg_think_period","_get_mg_think_period",0);
	register_native("get_user_jet_shells","_get_user_jet_shells",0);
	register_native("set_user_jet_shells","_set_user_jet_shells",0);
	register_native("reset_jet_shells","_reset_jet_shells",0);
	register_native("reset_user_jet_shells","_reset_user_jet_shells",0);
	register_native("get_user_mg","_get_user_mg",0);
	
}
public _get_jet_shells(iPlugins,iParams){
	new jet_id=get_param(1)
	
	new num_shells=pev(jet_id,pev_iuser2)
	return num_shells;
	
}
public Float:_get_mg_think_period(iPlugins,iParams){
	
	return mg_think_period
	
}
public _set_jet_shells(iPlugins,iParams){
	new jet_id=get_param(1)
	new the_shells=get_param(2)
	
	set_pev(jet_id,pev_iuser2,the_shells)
}
public _reset_jet_shells(iPlugins,iParams){
	new jet_id=get_param(1)
	
	set_pev(jet_id,pev_iuser2,jetplane_mg_ammo)
}
public _get_user_jet_shells(iPlugins,iParams){
	
	new id=get_param(1)
	return get_jet_shells(jet_get_user_jet(id))
	
}
public _set_user_jet_shells(iPlugins,iParams){
	
	new id=get_param(1)
	new the_shells=get_param(2)
	return set_jet_shells(jet_get_user_jet(id),the_shells)
	
}
public _reset_user_jet_shells(iPlugins,iParams){
	
	new id=get_param(1)
	return reset_jet_shells(jet_get_user_jet(id))
	
}
public _get_user_mg(iPlugins,iParams){
	new id=get_param(1)
	new result=is_user_connected(id)
	if(result){
		new result2=pev_valid(jet_get_user_jet(id))
		if(result2){
			
			
			return user_mg[id]
		}
		else{
			return -1
			
		}
	}
	return -1
	
}
public _spawn_jetplane_mg(iPlugins,iParams){
	
	new id=get_param(1)
	new jetplane_id=jet_get_user_jet(id)
	
	
	new material[128]
	new health[128]	
	new Float:jetplane_orig[3]
	pev(jetplane_id,pev_origin,jetplane_orig)
	new mg_id = create_entity( "func_breakable" );
	if(!is_valid_ent(mg_id)||(mg_id <= 0)) {
		
		sh_chat_message(id,yandere_get_hero_id(),"Mg failed to spawn")
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
	DispatchKeyValue(  mg_id , "material", material );
	DispatchKeyValue(  mg_id , "health", health );
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
	set_pev(mg_id, pev_nextthink, get_gametime() + get_mg_think_period())
}
public CmdStart(id, uc_handle)
{
	if(!hasRoundStarted()){

		return FMRES_IGNORED
	}
	if(!client_hittable(id)){
			
		return FMRES_IGNORED
	}
	if(!jet_deployed(id)){
		return FMRES_IGNORED
	}
	if(sh_get_stun(id)) return FMRES_IGNORED

	new button = get_uc(uc_handle, UC_Buttons);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if((weapon==CSW_KNIFE)&&jet_deployed(id)){
		if(get_user_mg(id)>0){
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
	if ( !pev_valid(ent) ) return FMRES_IGNORED
	
	
	static Float:vEnd[3], Float:gametime,Float:Pos[3]
	pev(ent, pev_origin, Pos)
	pev(ent, pev_vuser1, vEnd)
	gametime = get_gametime()
	new owner=pev(ent,pev_owner)
	if ( !jet_deployed(owner)) {
		if(pev_valid(ent)){
			mg_destroy(owner)
			sh_chat_message(owner,yandere_get_hero_id(),"jet mg died cuz of plane dying!!")
		}
		return FMRES_IGNORED
	}
	new Float:mg_health=float(pev(ent,pev_health))
	
	if ( (mg_health<1000.0)) {
		if(pev_valid(ent)){
			mg_destroy(owner)
			sh_chat_message(owner,yandere_get_hero_id(),"jet mg died!")
		}
		return FMRES_IGNORED
	}
	if(jet_deployed(owner)){
		
		new Float:vOrigin[3]
		entity_get_vector(jet_get_user_jet(owner), EV_VEC_origin, vOrigin)
		vOrigin[0]+=jetplane_origin_mg_offsets[0]
		vOrigin[1]+=jetplane_origin_mg_offsets[1]
		vOrigin[2]+=jetplane_origin_mg_offsets[2]
		entity_set_origin(ent, vOrigin)
		
		new Float:angles[3]
		entity_get_vector(jet_get_user_jet(owner), EV_VEC_v_angle, angles)
		entity_set_vector(ent, EV_VEC_v_angle, angles)
		entity_get_vector(jet_get_user_jet(owner), EV_VEC_angles, angles)
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
		set_pev(ent, pev_nextthink, gametime + (MG_THINK_PERIOD))
	}
	return FMRES_IGNORED
}

launch_shell(id)
{
	
	if(!is_valid_ent(get_user_mg(id))) return PLUGIN_HANDLED

	new Float: Origin[3], Float: vAngle[3], Ent

	entity_get_vector(get_user_mg(id), EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)
	
	Origin[2]+=(jetplane_mg_max_dims[2]+10.0)
	
	Ent = create_entity("info_target")
	
	if (!Ent){
		sh_chat_message(id,yandere_get_hero_id(),"shell failed!");
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

	velocity_by_aim(jet_get_user_jet(id), LAUNCH_SAFETY_DIST, bullet_place_dir_vec)
	
	add_3d_vectors(Origin,bullet_place_dir_vec,dest_origin)

	entity_set_origin(Ent, dest_origin)

	velocity_by_aim(jet_get_user_jet(id), floatround(jetplane_mg_bulletspeed), Velocity)
	

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


	new Float:origin[3]
	entity_get_vector(pToucher,EV_VEC_origin,origin);

	make_sparks(origin);
	gun_shot_decal(origin)

	remove_entity(pToucher)

}
public shell_hit_player(pToucher, pTouched){

	if(client_hittable(pTouched))
	{
		
		new oid = entity_get_edict(pToucher, EV_ENT_owner)
		new Float:origin[3]
		entity_get_vector(pToucher,EV_VEC_origin,origin);
		tank_impact_shot_fx(pToucher,origin,3);
		new Float:vic_origin[3];
		new Float:vic_origin_eyes[3];
		new vic_origin_eyes_int[3];
		
		entity_get_vector(pTouched,EV_VEC_origin,vic_origin);
		get_user_origin(pTouched,vic_origin_eyes_int,1);
		IVecFVec(vic_origin_eyes_int,vic_origin_eyes);
		new Float:head_distance=vector_distance(vic_origin_eyes,origin);
		new Float:damage=jetplane_mg_dmg
		new headshot=0;
		if(head_distance<MG_SHELL_HEADSHOT_DIST_THRESHOLD){
			
			headshot=1;
			damage*=4;
		}
		new CsTeams:att_team=cs_get_user_team(oid),
				CsTeams:vic_team=cs_get_user_team(pTouched);
		if(att_team!=vic_team){
			ExecuteHam(Ham_TakeDamage,pTouched,pToucher,oid,damage,DMG_BULLET);
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
	remove_entity(pToucher)
}
public shell_hit_jet(pToucher, pTouched)
{
	new the_owner=entity_get_edict(pToucher,EV_ENT_owner)
	if((pTouched==jet_get_user_jet(the_owner))){

		remove_entity(pToucher)
		return

	}

	new jet_owner=entity_get_edict(pTouched,EV_ENT_owner)

	if(client_hittable(jet_owner)){
		new CsTeams:att_team=cs_get_user_team(the_owner),
			CsTeams:vic_team=cs_get_user_team(jet_owner);
		if(att_team!=vic_team){
			jet_hurt_user_jet(jet_owner,the_owner,pToucher,jetplane_mg_dmg)
		}
	}
	remove_entity(pToucher)
}
public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel,GUN_SHELL)
	engfunc(EngFunc_PrecacheModel,P_MACHINEGUN_MODEL)
	engfunc(EngFunc_PrecacheSound, MACHINE_GUN_SOUND)
	
}

public _mg_destroy(iPlugin,iParams){
	
	new id= get_param(1)
	
	if(is_valid_ent(get_user_mg(id))){
		draw_bbox(get_user_mg(id),true)
		remove_entity(get_user_mg(id));
		user_mg[id]=-1;
	}
}