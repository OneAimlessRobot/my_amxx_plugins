#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_QUICK_CHECKS
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_CUSTOM_COLORS
#define I_WANT_ENTITY_VECTORS
#define I_WANT_PDATA_ALIASES
#define I_WANT_BASIC_MACROS
#define I_WANT_MISC_FUNCS_3
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "laralel_spear_inc/sh_laralel_get_set.inc"
#include "laralel_spear_inc/sh_spear_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt15.inc"
#include "../my_include/my_author_header.inc"

new const DEBUG = 0

#define SPEAR_CLASSNAME "laralel_spear"

#define SPEAR_RETRIEVE true


#define SPEAR_SPEED 3000.0

#define SPEAR_SHOOT_PERIOD 1.0

#define SPEAR_LAUNCH_DAMAGE 500.0
#define SPEAR_LAUNCH_FORCE 1600.0
#define SPEAR_LAUNCH_EXPLODE_RADIUS 200.0

#define SPEAR_SMASH_DAMAGE 500.0
#define SPEAR_SMASH_FORCE 3000.0
#define SPEAR_SMASH_EXPLODE_RADIUS 500.0


#define SPEAR_SHOOT_RANDOMNESS 0.0

#define SPEAR_CHARGE_PERIOD 0.1

new dmg_source_name_short_laralel_spear[SAFE_BUFFER_SIZE+1]="laralel_spear"
new dmg_source_name_log_laralel_spear[SAFE_BUFFER_SIZE+1]="laralel_spear"
new custom_dmg_id_laralel_spear

enum spear_mode{
	spear_mode_off=0,
	spear_mode_launch=1,
	spear_mode_blast=2,
  	spear_mode_max=3
};

stock const spear_mode_names[spear_mode_max][]={
        "No mode",
        "Launch",
        "Blast"
};

#define PLUGIN "Superhero lara mk2 pt2 (spear)"
#define VERSION "1.0.0"


new spear_mode:player_spear_mode[SH_MAXSLOTS+1]
new player_mode_button_pressed_mask

new gNumSpears[SH_MAXSLOTS+1]

new spear_armed_mask
new Float:curr_charge[SH_MAXSLOTS+1]




stock SPEAR_CHARGE_TASKID,
	UNSPEAR_CHARGE_TASKID

new PLUGIN_ID_HERE;

/*


	float pcvars!

*/

new pcvar_max_charge_time,
	pcvar_min_charge_time
	
public plugin_init(){


	PLUGIN_ID_HERE = register_plugin(PLUGIN, VERSION, AUTHOR);


	register_forward(FM_CmdStart, "CmdStart");
	register_think(SPEAR_CLASSNAME, "spaar_thaank");
	pcvar_max_charge_time = create_cvar("laralel_spear_max_charge_time", "5.0")
	pcvar_min_charge_time = create_cvar("laralel_spear_min_charge_time", "1.0")
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "Ham_Weapon_Stab",_,true)
	
	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)

	SPEAR_CHARGE_TASKID=allocate_typed_task_id(player_task)

	register_event("CurWeapon", "weaponChange", "be", "1=1")

	
	register_entity_as_wall_touchable(SPEAR_CLASSNAME,"FwdTouchWorld")
	register_custom_touchable(SPEAR_CLASSNAME,"spaaaaeer_touch_player",player_vector,1)
	RegisterHam(Ham_TakeDamage,"player","Laralel_ham_damage",1,true)
	
	

		
}

public Laralel_ham_damage(id, idinflictor, attacker, Float:damage, damagebits)
{
	if(damage <= 0.0){

		return HAM_IGNORED
	}
	if ( !sh_is_active() || !is_user_alive(id)||!is_user_alive(attacker)){

		return HAM_IGNORED
	}

	if(attacker == id) return HAM_IGNORED 

	new my_hitpoint_enum:the_hitpoint = my_hitpoint_enum:get_pdata_int(id, m_iLastHitGroup, XO_PLAYER)
	
	pev(id, pev_dmg_take, damage)

	return do_bleed_knife_attack(id,attacker,gHeroID,SPEAR_SLASH_DAMAGE,SPEAR_STAB_DAMAGE,
						client_is_weapon_user(attacker, SH_LARALEL_HARPOON_SPEAR) ,
								custom_dmg_id_laralel_spear,_,_,the_hitpoint);
	
}
public plugin_natives(){


	
	register_native("spear_set_user_spear","_spear_set_user_spear")
	register_native("spear_set_num_spears","_spear_set_num_spears");
	
	

}

public _spear_set_user_spear(iPlugin,iParams){
	
	new id = get_param(1),
		bool:value = bool:get_param(2),
		start_ammo = get_param(3)
	
	gNumSpears[id] = 0
	sh_assign_id_custom_weapon_bit(id, SH_LARALEL_HARPOON_SPEAR, value);
	if(value){
		gNumSpears[id] = max_macro(1,start_ammo)
		
	}
}
public sh_round_end(){

	remove_entity_name(SPEAR_CLASSNAME)

}

public sh_client_death(id)
{
	if(!is_user_connected(id)||!client_is_weapon_user(id, SH_LARALEL_HARPOON_SPEAR) ) return
	
	uncharge_user(id)
}

public weaponChange(id)
{
	if (!client_is_weapon_user(id, SH_LARALEL_HARPOON_SPEAR) ||!sh_is_active()) return PLUGIN_CONTINUE

	new wpnid = read_data(2)
	if (wpnid == CSW_KNIFE) {
		if(!gNumSpears[id]){
			entity_set_string(id, EV_SZ_viewmodel, NOSPEAR_V_MODEL)
		}
	}
	return PLUGIN_CONTINUE

}
public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel,SPEAR_W_MODEL)
	engfunc(EngFunc_PrecacheSound, SPEAR_HIT_SFX)
	engfunc(EngFunc_PrecacheSound, THROWABLE_LAUNCH_SFX)
	engfunc(EngFunc_PrecacheSound, PIERCE_WOUND_SFX)
	engfunc(EngFunc_PrecacheModel,NOSPEAR_V_MODEL)
		
}

public _spear_set_num_spears(iPlugin,iParams){
	new id= get_param(1)
	new value_to_set=get_param(2)
	gNumSpears[id]=value_to_set;
}

public fm_UpdateClientDataPost(player, sendWeapons, cd)
{
	
	if(!is_user_alive(player)){
		return FMRES_IGNORED
	}

	if(!client_is_weapon_user(player, SH_LARALEL_HARPOON_SPEAR)){

		return FMRES_IGNORED
	}
	new weapon = get_user_weapon(player);
	if(weapon!=CSW_KNIFE){
		return FMRES_IGNORED
	}

	if ( !gNumSpears[player]) {
		set_cd(cd, CD_flNextAttack, get_gametime()+1.0)
		return FMRES_HANDLED
	}	
	return FMRES_IGNORED
}
public FwdTouchWorld( Spaaaaeerr, World ) {

	if(!is_valid_ent(Spaaaaeerr)) return

	emit_sound(Spaaaaeerr, CHAN_WEAPON, SPEAR_HIT_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	entity_set_vector(Spaaaaeerr, EV_VEC_velocity ,NULL_VECTOR)
	//set pickability status
	new pickability = entity_get_int(Spaaaaeerr,EV_INT_iuser2)
	
	if(!pickability){
		entity_set_int(Spaaaaeerr,EV_INT_iuser2,true)
		entity_set_float( Spaaaaeerr, EV_FL_nextthink, floatadd(get_gametime( ) ,SPEAR_SHOOT_PERIOD));
	}
}
public spaar_thaank(ent){


	if (!is_valid_ent(ent) ) return
	
	

	remove_entity_safe(ent)


}
public sh_client_spawn(id){

	UnSet_BitVar(player_mode_button_pressed_mask,id)

}
Float:get_charge_index_from_id(id){

	return (curr_charge[id]/cvar_val(float, pcvar_max_charge_time))
}
//----------------------------------------------------------------------------------------------
public CmdStart(id, uc_handle)
{

	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if ( !is_user_alive(id)||!client_is_weapon_user(id, SH_LARALEL_HARPOON_SPEAR)) return FMRES_IGNORED;
	if(sh_is_freezetime()){
	
		uncharge_user(id)
		return FMRES_IGNORED
	
	}
	if(sh_get_stun(id)) return FMRES_IGNORED
	if(sh_get_id_bit(id, SH_CONTROLLING_VEHICLE)) return FMRES_IGNORED
	new weapon = get_user_weapon(id);
	static button;
	button= get_uc(uc_handle, UC_Buttons);
	
	static prev_button;
	prev_button = entity_get_int(id, EV_INT_oldbuttons)
	if((button & IN_ALT1)&&!(prev_button & IN_ALT1)){

		
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
	
		

		if((button & IN_ATTACK2)&&((player_spear_mode[id]>enum_zero)||(gNumSpears[id]<=0)))
		{
			button &= ~IN_ATTACK2;
			set_uc(uc_handle, UC_Buttons, button);
		}

		if(button & IN_ATTACK)
		{
			button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, button);
			if(!player_spear_mode[id]) return FMRES_IGNORED
			
			if(gNumSpears[id]<=0)
			{
				return FMRES_IGNORED
			}
			if(!Get_BitVar(spear_armed_mask,id)){
				Set_BitVar(spear_armed_mask,id)
				charge_user(id)
				
			}
		}
		else if(Get_BitVar(spear_armed_mask,id)){
			if(curr_charge[id]>=cvar_val(float, pcvar_min_charge_time)){
				
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
	
	gHeroID = laralel_get_hero_id()
	
	custom_dmg_id_laralel_spear=sh_log_custom_damage_source(gHeroID,
		dmg_source_name_short_laralel_spear,
		dmg_source_name_log_laralel_spear,1)
}


public charge_task(id){
	id-=SPEAR_CHARGE_TASKID
	static hud_msg[128];
	curr_charge[id]=floatadd(curr_charge[id],SPEAR_CHARGE_PERIOD)
	formatex(hud_msg,127,"[SH]: Curr charge: %0.2f^n",
					100.0*(curr_charge[id]/cvar_val(float, pcvar_max_charge_time))
					);
	client_print(id,print_center,"%s",hud_msg)
	
	if(Get_BitVar(spear_armed_mask,id)){
		if((100.0*(curr_charge[id]/cvar_val(float, pcvar_max_charge_time)))>100.0){
				
				lara_spear_decide_func(id)
				uncharge_user(id)
		}
		else{	
			set_task(SPEAR_CHARGE_PERIOD,"charge_task",id+SPEAR_CHARGE_TASKID)
		}
	}
	

	


}
charge_user(id){
	curr_charge[id]=0.0
	if(task_exists(id+SPEAR_CHARGE_TASKID)){
		
		return
		
	}
	charge_task(id+SPEAR_CHARGE_TASKID)


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

	static owner; owner = get_pdata_cbase(weapon_ent, m_pPlayer,XO_WEAPON)
	if(!client_is_weapon_user(owner, SH_LARALEL_HARPOON_SPEAR)){
		
		return HAM_IGNORED
	}
	if ( !gNumSpears[owner]) {
		return HAM_SUPERCEDE
	}

	return HAM_IGNORED
}
public spear_post_launch_callback(Ent, id, Float:Velocity[3], &bool:modified_speed_flag){

	if(!is_valid_ent(Ent)){

		return
	}

	entity_set_edict(Ent, EV_ENT_owner,0)
	entity_set_edict(Ent, EV_ENT_euser1, id)
	//has touched ENEMY player
	entity_set_int(Ent, EV_INT_iuser1, false)
	entity_set_float(Ent, EV_FL_fuser1, get_charge_index_from_id(id))

	//set pickability status
	entity_set_int(Ent,EV_INT_iuser2,false)
	emit_sound(id, CHAN_WEAPON, THROWABLE_LAUNCH_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	trail(Ent,WHITE,10,5)
	entity_set_string(id, EV_SZ_viewmodel, NOSPEAR_V_MODEL)
	gNumSpears[id]-= (gNumSpears[id]>0)? 1:0

}
launch_spear(id)
{
	static func_id;
	func_id = get_func_id("spear_post_launch_callback",PLUGIN_ID_HERE)

	if(!is_user_alive(id)){

		return
	}


	launch_projectile_native(id,
		SPEAR_SPEED*(get_charge_index_from_id(id)),
		SPEAR_SHOOT_PERIOD,
		SPEAR_CLASSNAME,
		SPEAR_W_MODEL,
		"info_target",
		Float:{-10.0,-10.0, 0.0},
		Float:{10.0,10.0,7.0},
		50.0,
		SOLID_TRIGGER,
		MOVETYPE_TOSS,
		2,
		1.0,
		PLUGIN_ID_HERE,
		func_id)

}


public lara_spear_decide_func(id){

	if ( !is_user_alive(id)||!client_is_weapon_user(id, SH_LARALEL_HARPOON_SPEAR)) return ;

	new spear_mode:the_mode=player_spear_mode[id],
		Float:charge_index = get_charge_index_from_id(id)

	switch(the_mode){
		case spear_mode_launch:{
			launch_spear(id)

			if(is_user_bot(id)){
				return

			}
			if(gNumSpears[id]<=0)
			{
				
				client_print(id, print_center, "You are out of spears")

			}
			else{

				client_print(id,print_center,"You have %d spears left",
				gNumSpears[id]
				);
			}
		}
		case spear_mode_blast:{

			
			explosion(gHeroID,id,
							charge_index*SPEAR_SMASH_EXPLODE_RADIUS,
							charge_index*SPEAR_SMASH_DAMAGE,
							charge_index*SPEAR_SMASH_FORCE,
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


	static oid,
		Float:charge_index
		
	oid = entity_get_edict(pToucher, EV_ENT_euser1),
	charge_index = entity_get_float(pToucher, EV_FL_fuser1)

	//new Float:origin[3],dist
	
	if(is_user_alive(pTouched))
	{

		//get pickability status
		new is_pickable=entity_get_int(pToucher,EV_INT_iuser2)
		if(client_is_weapon_user(pTouched, SH_LARALEL_HARPOON_SPEAR)&&(pTouched==oid)&&is_pickable&& SPEAR_RETRIEVE){
			if(is_user_alive(oid)){
				gNumSpears[oid]++
				sh_chat_message(oid,gHeroID,"Youve picked up your spear back! You now have %d",gNumSpears[oid])
				if(DEBUG){

					sh_chat_message(oid,gHeroID,"The launching charge of this spear was: %0.2f",charge_index)

				}
				remove_entity_safe(pToucher);
			}
			return
		}
		
		//has touched ENEMY player
		
		static bool:has_touched_enemy_player;
		
		has_touched_enemy_player = bool:entity_get_int(pTouched, EV_INT_iuser1)

		if(!sh_clients_are_same_team(pTouched,oid)&&(pTouched!=oid)&&!has_touched_enemy_player){
			
			//has touched ENEMY player

			entity_set_int(pToucher, EV_INT_iuser1, true)

			sh_bleed_user(pTouched,oid,BLEED_NORMAL,gHeroID)
			static Float:here_origin_of_explosion[3]

			entity_get_vector(pToucher, EV_VEC_origin, here_origin_of_explosion)

			explosion_with_origin(gHeroID,oid,here_origin_of_explosion,charge_index*SPEAR_LAUNCH_EXPLODE_RADIUS,charge_index*SPEAR_LAUNCH_DAMAGE, charge_index*SPEAR_LAUNCH_FORCE,0,
									_,_,_,_,_,_,true)
			
			if(!is_valid_ent(pToucher)){

				return
			}
			//set pickability status
			entity_set_int(pToucher,EV_INT_iuser2,true)
			entity_set_float( pToucher, EV_FL_nextthink, floatadd(get_gametime( ) ,SPEAR_SHOOT_PERIOD));
		}
	}
}