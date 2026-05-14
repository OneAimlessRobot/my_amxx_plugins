#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS

#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "lara_spear_inc/sh_lara_get_set.inc"
#include "lara_spear_inc/sh_spear_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "../my_include/my_author_header.inc"


#define PLUGIN "Superhero lara mk2 pt2 (spear)"
#define VERSION "1.0.0"

new gHeroID = 0

new spear_mode:player_spear_mode[SH_MAXSLOTS+1]
new player_mode_button_pressed_mask

new spear_armed_mask
new Float:curr_charge[SH_MAXSLOTS+1]


new Float:min_charge_time,Float:max_charge_time


stock SPEAR_CHARGE_TASKID,
	UNSPEAR_CHARGE_TASKID

public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);


	register_forward(FM_CmdStart, "CmdStart");
	register_think(SPEAR_CLASSNAME, "spaar_thaank");
	register_cvar("lara_spear_max_charge_time", "5.0")
	register_cvar("lara_spear_min_charge_time", "1.0")
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "Ham_Weapon_Stab",_,true)
	SPEAR_CHARGE_TASKID=allocate_typed_task_id(player_task)


	
	register_entity_as_wall_touchable(SPEAR_CLASSNAME,"FwdTouchWorld")
	register_custom_touchable(SPEAR_CLASSNAME,"spaaaaeer_touch_player",player_vector,1)

}
public FwdTouchWorld( Spaaaaeerr, World ) {

	if(!is_valid_ent(Spaaaaeerr)) return

	emit_sound(Spaaaaeerr, CHAN_WEAPON, SPEAR_HIT_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	entity_set_vector(Spaaaaeerr, EV_VEC_velocity ,NULL_VECTOR)
	//set pickability status
	entity_set_int(Spaaaaeerr,EV_INT_iuser2,true)
	entity_set_float( Spaaaaeerr, EV_FL_nextthink, floatadd(get_gametime( ) ,SPEAR_SHOOT_PERIOD));
}
public spaar_thaank(ent){


	if ( pev_valid(ent)!=2 ) return
	
	

	remove_entity(ent)


}
public plugin_natives(){


	register_native( "spear_uncharge_spear","_spear_uncharge_spear",0)
	register_native( "spear_get_user_spear_mode","_spear_get_user_spear_mode",0)


}
Float:get_charge_index_from_id(id){

	return (curr_charge[id]/max_charge_time)
}
//----------------------------------------------------------------------------------------------
public CmdStart(id, uc_handle)
{

	if(!sh_is_active()||sh_is_freezetime()) return FMRES_IGNORED;
	
	if ( !is_user_alive(id)||!sh_user_has_hero(id,gHeroID)) return FMRES_IGNORED;
	if(!hasRoundStarted()){
	
		uncharge_user(id)
		return FMRES_IGNORED
	
	}
	if(sh_get_stun(id)) return FMRES_IGNORED
	
	
	new button = get_uc(uc_handle, UC_Buttons);


	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if(button & IN_ALT1){
		button &= ~IN_ALT1;
		if(weapon==CSW_KNIFE){
			if(!Get_BitVar(player_mode_button_pressed_mask,id)){
				Set_BitVar(player_mode_button_pressed_mask,id)
				player_spear_mode[id]=(player_spear_mode[id]+spear_mode_launch)%spear_mode_max
				sh_chat_message(id,gHeroID,"The spear mode has been changed to: ^"%s^"",spear_mode_names[player_spear_mode[id]])
			}
		}
	}
	else{

		UnSet_BitVar(player_mode_button_pressed_mask,id)
	}
	if(weapon==CSW_KNIFE){
	
		if(!spear_get_user_spear_mode(id)) return FMRES_IGNORED

		if(button & IN_ATTACK)
		{
			button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, button);
			if( !(is_user_alive(id))) return FMRES_IGNORED
			if(spear_get_num_spears(id)<=0)
			{
				
				if(!is_user_bot(id)){
					client_print(id, print_center, "You are out of spears")
				}
				return FMRES_IGNORED
			}
			if(!Get_BitVar(spear_armed_mask,id)){
				Set_BitVar(spear_armed_mask,id)
				charge_user(id)
				
			}
			else if((100.0*(curr_charge[id]/max_charge_time))>95.0){
				
				lara_spear_decide_func(id)
				uncharge_user(id)
				return FMRES_IGNORED
			}
			
		}
		else if(Get_BitVar(spear_armed_mask,id)){
			if(curr_charge[id]>=min_charge_time){
				
				lara_spear_decide_func(id)
				
			}
			else if(curr_charge[id]>0.0){
				
				if(!is_user_bot(id)){
					sh_chat_message(id,gHeroID,"Spear not charged! Spear not launched...");
				}
			}
			uncharge_user(id)
		
		}
	}
	else{
	
		uncharge_user(id)
	}
	
	return FMRES_IGNORED;
}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	
	gHeroID = spear_get_hero_id()
	max_charge_time=get_cvar_float("lara_spear_max_charge_time")
	min_charge_time=get_cvar_float("lara_spear_min_charge_time")
}


public charge_task(id){
	id-=SPEAR_CHARGE_TASKID
	static hud_msg[128];
	curr_charge[id]=floatadd(curr_charge[id],SPEAR_CHARGE_PERIOD)
	formatex(hud_msg,127,"[SH]: Curr charge: %0.2f^n",
					100.0*(curr_charge[id]/max_charge_time)
					);
	client_print(id,print_center,"%s",hud_msg)
	
	if(Get_BitVar(spear_armed_mask,id)){
		set_task(SPEAR_CHARGE_PERIOD,"charge_task",id+SPEAR_CHARGE_TASKID)
	}
	

	


}
charge_user(id){
	curr_charge[id]=0.0
	set_task(SPEAR_CHARGE_PERIOD,"charge_task",id+SPEAR_CHARGE_TASKID)



}
public _spear_uncharge_spear(iPlugin,iParams){
	new id=get_param(1)
	uncharge_user(id)

}

uncharge_user(id){

	
	UnSet_BitVar(spear_armed_mask,id)
}

public Ham_Weapon_Stab(weapon_ent)
{
	
	if(pev_valid(weapon_ent)!=2){

		server_print("lara spear hook to weapon faulty???");
		return HAM_IGNORED
	}
	if ( !sh_is_active() ) return HAM_IGNORED

	new owner = get_pdata_cbase(weapon_ent, m_pPlayer,XO_WEAPON)
	if(!client_is_hero_user(owner, gHeroID)){
		
		return HAM_IGNORED
	}
	if ( !spear_get_num_spears(owner)) {
		return HAM_SUPERCEDE
	}

	return HAM_IGNORED
}

public spear_mode:_spear_get_user_spear_mode(iPLugin, iParams){
	new id=get_param(1)
	return player_spear_mode[id]


}
launch_spear(id)
{
	new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)


	Ent = create_entity("info_target")

	if (!Ent) return PLUGIN_HANDLED

	entity_set_string(Ent, EV_SZ_classname, SPEAR_CLASSNAME)
	entity_set_model(Ent, SPEAR_W_MODEL)

	new Float:MinBox[3] = {-1.0, -1.0, -1.0}
	new Float:MaxBox[3] = {1.0, 1.0, 1.0}
	entity_set_vector(Ent, EV_VEC_mins, MinBox)
	entity_set_vector(Ent, EV_VEC_maxs, MaxBox)

	
	Origin[2]+=50.0
	entity_set_origin(Ent, Origin)
	entity_set_vector(Ent, EV_VEC_angles, vAngle)

	entity_set_int(Ent, EV_INT_effects, 2)
	entity_set_int(Ent, EV_INT_solid, 1)
	entity_set_int(Ent, EV_INT_movetype, 10)
	entity_set_edict(Ent, EV_ENT_owner, id)

	velocity_by_aim(id, floatround(SPEAR_SPEED*(curr_charge[id]/max_charge_time)) , Velocity)

	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)
	spear_dec_num_spears(id)

	emit_sound(id, CHAN_WEAPON, THROWABLE_LAUNCH_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	//set pickability status
	entity_set_int(Ent,EV_INT_iuser2,false)
	trail(Ent,WHITE,10,5)
	entity_set_string(id, EV_SZ_viewmodel, NOSPEAR_V_MODEL)
	entity_set_float( Ent, EV_FL_nextthink, floatadd(get_gametime( ) ,SPEAR_SHOOT_PERIOD));
	return PLUGIN_CONTINUE
}


public lara_spear_decide_func(id){

	if ( !is_user_alive(id)||!sh_user_has_hero(id,gHeroID)) return ;

	new spear_mode:the_mode=spear_get_user_spear_mode(id);
	switch(the_mode){
		case spear_mode_launch:{
			launch_spear(id)

			if(!is_user_bot(id)){
				client_print(id,print_center,"You have %d spears left",
				spear_get_num_spears(id)
				);
			}
		}
		case spear_mode_blast:{

			
			explosion(gHeroID,id,
							get_charge_index_from_id(id)*SPEAR_SMASH_EXPLODE_RADIUS,
							get_charge_index_from_id(id)*float(SPEAR_SMASH_DAMAGE),
							get_charge_index_from_id(id)*SPEAR_SMASH_FORCE,
							1)
		}
		default:{
			return
		}
	}

}


public spaaaaeer_touch_player(pToucher, pTouched)
{	
	
	if(!is_valid_ent(pToucher)) return


	new oid = entity_get_edict(pToucher, EV_ENT_owner)
	//new Float:origin[3],dist
	
	if(is_user_alive(pTouched))
	{
		//get pickability status
		new is_pickable=entity_get_int(pToucher,EV_INT_iuser2)
		if(sh_user_has_hero(pTouched,gHeroID)&&(pTouched==oid)&&is_pickable&& SPEAR_RETRIEVE){
		
			spear_set_num_spears(oid,spear_get_num_spears(oid)+1)
			sh_chat_message(oid,gHeroID,"Youve picked up your spear back! You now have %d",spear_get_num_spears(oid))
			remove_entity(pToucher);
		
		}
		else if(pTouched!=oid){
			sh_bleed_user(pTouched,oid,BLEED_NORMAL,gHeroID)
			explosion(gHeroID,pToucher,get_charge_index_from_id(oid)*SPEAR_LAUNCH_EXPLODE_RADIUS,get_charge_index_from_id(oid)*float(SPEAR_LAUNCH_DAMAGE), get_charge_index_from_id(oid)*SPEAR_LAUNCH_FORCE,0)
			emit_sound(pToucher, CHAN_WEAPON, PIERCE_WOUND_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			//set pickability status
			entity_set_int(pToucher,EV_INT_iuser2,true)
			entity_set_float( pToucher, EV_FL_nextthink, floatadd(get_gametime( ) ,SPEAR_SHOOT_PERIOD));
		}
	}
}
public plugin_precache()
{

	
	engfunc(EngFunc_PrecacheModel,SPEAR_W_MODEL)
	engfunc(EngFunc_PrecacheSound, SPEAR_HIT_SFX)
	engfunc(EngFunc_PrecacheSound, THROWABLE_LAUNCH_SFX)
	engfunc(EngFunc_PrecacheSound, PIERCE_WOUND_SFX)
	
}
