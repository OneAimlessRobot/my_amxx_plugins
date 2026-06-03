#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#define I_WANT_CUSTOM_WEAPONS

#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "maria_riveter_inc/maria_general_funcs.inc"
#include "maria_riveter_inc/maria_riveter_funcs.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "../my_include/my_author_header.inc"

#define PLUGIN_VER "1.0"
#define PLUGIN_NAME "SUPERHERO Maria's riveter"

new gHeroID = -1
new Float:g_Recoil[SH_MAXSLOTS+1][3]
new g_Riveter_clip[SH_MAXSLOTS+1]

new trigger_is_down_mask = 0
new trigger_was_down_mask = 0
new semi_automatic_mode_mask = 0
new mode_selector_is_down_mask = 0
new mode_selector_was_down_mask = 0

new maria_riveter_wpn_id
new dmg_source_name_short_riveter[SAFE_BUFFER_SIZE+1]="riveter"
new dmg_source_name_log_riveter[SAFE_BUFFER_SIZE+1]="riveter"

new weapon_secret_code = -1
public plugin_init(){
	

	register_plugin(PLUGIN_NAME, PLUGIN_VER, AUTHOR);

	register_forward(FM_CmdStart, "CmdStart");
	RegisterHam(Ham_Item_Deploy, weapon_data_strings_array[MARIA_WEAPON_CLASSID][wpn_struct_weapon_name], "fw_ItemDeployPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_data_strings_array[MARIA_WEAPON_CLASSID][wpn_struct_weapon_name], "fw_WeaponPrimaryAttackPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_data_strings_array[MARIA_WEAPON_CLASSID][wpn_struct_weapon_name], "fw_Weapon_PrimaryAttack_Post", 1,true)	
	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)
	RegisterHam(Ham_Item_PostFrame, weapon_data_strings_array[MARIA_WEAPON_CLASSID][wpn_struct_weapon_name], "fw_Item_PostFrame",_,true)	
	
	
	RegisterHam(Ham_TraceAttack, "player", "Ham_TraceAttackMariaRiveter",_,true)
	
	RegisterHam(Ham_Weapon_Reload, weapon_data_strings_array[MARIA_WEAPON_CLASSID][wpn_struct_weapon_name], "fw_WeaponReloadPre",_,true)
	RegisterHam(Ham_Weapon_Reload, weapon_data_strings_array[MARIA_WEAPON_CLASSID][wpn_struct_weapon_name], "fw_Weapon_Reload_Post", 1,true)

	register_entity_as_wall_touchable(MARIA_PROJECTILE_CLASSNAME,"rrrrroovvetoooo_touque_playor")
	register_custom_touchable(MARIA_PROJECTILE_CLASSNAME,"rrrrroovvetoooo_touque_playor",player_vector,1)

	register_think(MARIA_PROJECTILE_CLASSNAME, "rivette_thinque")

	init_gravity_pcvar()

	weapon_secret_code = allocate_weapon_secret_code()


}
public plugin_cfg(){


	gHeroID = maria_get_hero_id()
	
	maria_riveter_wpn_id=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_riveter,
								dmg_source_name_log_riveter,
								0)

}
public rivette_thinque(ent){


	if ( pev_valid(ent)!=2 ) return
	
	new owner=entity_get_edict(ent, EV_ENT_owner)

	if(!is_user_alive(owner)){

		my_remove_entity(ent)	
		return
	}

	new parm[2]
	parm[0] = ent
	parm[1] = owner

	
	orient_entity_with_move_vector(ent)

	
	projectile_air_drag_update_speed(parm,MARIA_PROJECTILE_DRAG_CONST,MARIA_PROJECTILE_GRAVITY_MULT,MARIA_PROJECTILE_PHYS_UPDATE_TIME)
	

	entity_set_float( ent, EV_FL_nextthink, floatadd(get_gametime( ) ,MARIA_PROJECTILE_PHYS_UPDATE_TIME));



}
public CmdStart(id, uc_handle)
{	

	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}

	if(!client_is_hero_user(id, gHeroID)){
		
		return FMRES_IGNORED
	}

	
	Assign_BitVar(mode_selector_was_down_mask, id,Get_BitVar(mode_selector_is_down_mask, id));
	
	Assign_BitVar(trigger_was_down_mask, id,Get_BitVar(trigger_is_down_mask, id));

	new button = get_uc(uc_handle, UC_Buttons);
	

	Assign_BitVar(mode_selector_is_down_mask, id,(button & IN_ATTACK2));
	
	Assign_BitVar(trigger_is_down_mask, id,(button & IN_ATTACK));
	
	new  weapon = get_user_weapon(id);
	if((weapon==MARIA_WEAPON_CLASSID)){
		
		if(Get_BitVar(trigger_is_down_mask, id))
		{	
			new bool:cant_shoot = ((maria_riveter_get_num_rivets(id)<=0)) ||
					(Get_BitVar(semi_automatic_mode_mask,id)?(bool:Get_BitVar(trigger_was_down_mask, id)):false)
			
			button &= ~IN_ATTACK;
			if(cant_shoot){
				set_uc(uc_handle, UC_Buttons, button);
				return FMRES_SUPERCEDE
			}
			
		}
		if(Get_BitVar(mode_selector_is_down_mask, id)){
			
			button &= ~IN_ATTACK2;
			if(!Get_BitVar(mode_selector_was_down_mask,id)){
				set_uc(uc_handle, UC_Buttons, button);
				if(!is_user_bot(id)){
					client_print(id,print_center,"You have %s semi automatic mode",Get_BitVar(semi_automatic_mode_mask, id)?"disengaged":"engaged")
				}
				Assign_BitVar(semi_automatic_mode_mask,id,!Get_BitVar(semi_automatic_mode_mask, id))

			}
		}
	}
	return FMRES_IGNORED;
}

public Ham_TraceAttackMariaRiveter(id, idattacker, Float:damage, Float:direction[3], ptr, damagebits)
{
	if(damage<=0.0){
		return HAM_IGNORED
	}

	if(!is_user_connected(idattacker)){
		return HAM_IGNORED	
	}
	if(get_user_weapon(idattacker) != MARIA_WEAPON_CLASSID|| !sh_get_user_has_hero(idattacker,gHeroID)){
		return HAM_IGNORED
	}

	damage= 0.0
	SetHamParamFloat(3,damage)
	
	return HAM_SUPERCEDE
	
}

public fw_Item_PostFrame(ent)
{
	
	if(pev_valid(ent) != 2){
		return HAM_IGNORED
	}
	static id; id = get_pdata_cbase(ent, m_pPlayer,XO_WEAPON)
	if(!client_is_hero_user(id, gHeroID)){
		
		return HAM_IGNORED
	}
	static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, OFFSET_LINUX_PLAYER)
	static bpammo; bpammo = cs_get_user_bpammo(id, MARIA_WEAPON_CLASSID)
	
	static iClip; iClip = get_pdata_int(ent, m_iClip, XO_WEAPON)
	static fInReload; fInReload = get_pdata_int(ent, m_fInReload, XO_WEAPON)
	
	if(fInReload && flNextAttack <= 0.0)
	{
		static temp1
		temp1 = min( RIVETER_CLIP_SIZE - iClip, bpammo)

		set_pdata_int(ent, m_iClip, iClip + temp1, XO_WEAPON)
		cs_set_user_bpammo(id, MARIA_WEAPON_CLASSID, bpammo - temp1)		
		
		set_pdata_int(ent, m_fInReload, 0, XO_WEAPON)
		
		fInReload = 0
	}
	return HAM_IGNORED
}

public fw_WeaponReloadPre(entity)
{
	if(pev_valid(entity)!=2)
		return HAM_IGNORED
	
	static pPlayer; pPlayer = get_pdata_cbase(entity, m_pPlayer,XO_WEAPON)
	
	if(!client_is_hero_user(pPlayer, gHeroID)){
		
		return HAM_IGNORED
	}
	g_Riveter_clip[pPlayer] = -1
	static BPAmmo; BPAmmo = cs_get_user_bpammo(pPlayer, MARIA_WEAPON_CLASSID)
	static iClip; iClip = get_pdata_int(entity, m_iClip, XO_WEAPON)
	
	if(BPAmmo <= 0){
		return HAM_SUPERCEDE
	}
	if(iClip >= RIVETER_CLIP_SIZE){
		return HAM_SUPERCEDE		
	}
	g_Riveter_clip[pPlayer] = iClip		
	return HAM_IGNORED
}
public fw_Weapon_Reload_Post(ent)
{
	if(pev_valid(ent)!=2)
		return HAM_IGNORED
		
	static id; id =  get_pdata_cbase(ent, m_pPlayer,XO_WEAPON)
	if(!client_is_hero_user(id, gHeroID)){
		
		return HAM_IGNORED
	}

	if(g_Riveter_clip[id] == -1)
		return HAM_IGNORED

	
	set_pdata_int(ent, m_iClip, g_Riveter_clip[id] , XO_WEAPON)
	set_pdata_int(ent, m_fInReload, 1, XO_WEAPON);
	
	return HAM_IGNORED
}

public fw_ItemDeployPre(entity)
{
	if(pev_valid(entity)!=2)
		return HAM_IGNORED
		
	static pPlayer; pPlayer = get_pdata_cbase(entity, m_pPlayer, XO_WEAPON)
	
	if(!client_is_hero_user(pPlayer, gHeroID)){
		remove_weapon_secret_code(entity,weapon_secret_code)
		return HAM_IGNORED
	}
	ExecuteHam(Ham_Item_Deploy, entity)
	set_pdata_float(pPlayer, m_flNextAttack, MARIA_PROJECTILE_DEPLOY_TIME,OFFSET_LINUX_PLAYER)
	set_pdata_float(entity, m_flTimeWeaponIdle, MARIA_PROJECTILE_DEPLOY_TIME,XO_WEAPON)
	set_pdata_int(entity, m_iClip,min(RIVETER_CLIP_SIZE,get_pdata_int(entity, m_iClip, XO_WEAPON)), XO_WEAPON)
	set_weapon_secret_code(entity,weapon_secret_code)
	return HAM_SUPERCEDE
}


public fw_WeaponPrimaryAttackPre(entity)
{

	if(pev_valid(entity)!=2)
		return HAM_IGNORED
		
	if (!hasRoundStarted()) return HAM_IGNORED;

	static pPlayer; pPlayer = get_pdata_cbase(entity, m_pPlayer, XO_WEAPON)
	
	if(!client_is_hero_user(pPlayer, gHeroID)){
		return HAM_IGNORED
	}

	static iClip, iPlaybackEvent
	iClip = get_pdata_int(entity, m_iClip, XO_WEAPON)
	if(iClip)
	{
		iPlaybackEvent = register_forward(FM_PlaybackEvent, "fm_PlaybackEventPre")
		
		
	}
	ExecuteHam(Ham_Weapon_PrimaryAttack, entity)
	if(!iClip){
		return HAM_SUPERCEDE
	}
	launch_rivet(pPlayer);
	g_Riveter_clip[pPlayer]=get_pdata_int(entity, m_iClip, XO_WEAPON)
	set_pdata_float(entity, m_flNextPrimaryAttack, MARIA_PROJECTILE_SHOOT_PERIOD,XO_WEAPON)
	set_pdata_float(entity, m_flTimeWeaponIdle, MARIA_PROJECTILE_SHOOT_PERIOD,XO_WEAPON)


	entity_get_vector(pPlayer, EV_VEC_punchangle, g_Recoil[pPlayer])
	native_playanim(pPlayer, generate_int(maria_riveter_anim_shoot1,maria_riveter_anim_shoot3))
	unregister_forward(FM_PlaybackEvent, iPlaybackEvent)
	return HAM_SUPERCEDE
}

public fw_Weapon_PrimaryAttack_Post(Ent)
{
	
	if(pev_valid(Ent)!=2)
		return
		
	static id; id = get_pdata_cbase(Ent, m_pPlayer, XO_WEAPON)
	if(!client_is_hero_user(id, gHeroID)){
		return
	}

	static iClip;iClip = get_pdata_int(Ent, m_iClip, XO_WEAPON)
	if(iClip<=0){

		return
	}
	static Float:Push[3]
	entity_get_vector(id, EV_VEC_punchangle, Push)

	sub_3d_vectors(Push, g_Recoil[id], Push)
	
	multiply_3d_vector_by_scalar(Push, RIVETER_RECOIL, Push)
	add_3d_vectors(Push, g_Recoil[id], Push)
	entity_set_vector(id, EV_VEC_punchangle, Push)
}
launch_rivet(id)
{

if(!client_is_hero_user(id, gHeroID)){
		
	return PLUGIN_CONTINUE
}
new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

entity_get_vector(id, EV_VEC_origin , Origin)
entity_get_vector(id, EV_VEC_v_angle, vAngle)


Ent = my_create_entity("info_target")

if (!Ent){
	return PLUGIN_HANDLED
}
entity_set_string(Ent, EV_SZ_classname, MARIA_PROJECTILE_CLASSNAME)
entity_set_model(Ent, "models/shell.mdl")

new Float:MinBox[3] = {-1.0, -1.0, -1.0}
new Float:MaxBox[3] = {1.0, 1.0, 1.0}
entity_set_vector(Ent, EV_VEC_mins, MinBox)
entity_set_vector(Ent, EV_VEC_maxs, MaxBox)

entity_set_origin(Ent, Origin)
entity_set_vector(Ent, EV_VEC_angles, vAngle)

entity_set_int(Ent, EV_INT_effects, 2)
entity_set_int(Ent, EV_INT_solid, SOLID_BBOX)
entity_set_int(Ent, EV_INT_movetype, MOVETYPE_TOSS)
entity_set_float(Ent,EV_FL_gravity, MARIA_PROJECTILE_GRAVITY_MULT*0.1)
entity_set_edict(Ent, EV_ENT_owner, id)

velocity_by_aim(id, floatround(MARIA_PROJECTILE_SPEED) , Velocity)
if(!Get_BitVar(semi_automatic_mode_mask, id)){

	new Float:coeff_to_multiply_with = 0.0
	new Float:user_movement_velocity[3]
	entity_get_vector(id,EV_VEC_velocity,user_movement_velocity)
	new Float:user_maxspeed=get_user_maxspeed(id);
	new Float:user_current_speed=vector_length(user_movement_velocity)
	new Float:coeff_to_multiply_with_extra=(user_current_speed/user_maxspeed)
	coeff_to_multiply_with=coeff_to_multiply_with_extra*MARIA_PROJECTILE_SHOOT_RANDOMNESS

	randomize_vector_with_coeff(coeff_to_multiply_with,Velocity)
}

entity_set_vector(Ent, EV_VEC_velocity ,Velocity)
maria_riveter_dec_num_rivets(id)

//rivet launch pos
entity_set_vector(Ent,EV_VEC_vuser1,Origin)

new parm[2]
new parm2[1]

parm2[0]= id
parm[0] = Ent
parm[1] = id
emit_sound(id, CHAN_WEAPON, MARIA_RIVETER_SHOTSOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

trail(Ent,LTGREEN,3,5)
entity_set_float( Ent, EV_FL_nextthink, floatadd(get_gametime( ) ,MARIA_PROJECTILE_PHYS_UPDATE_TIME));

return PLUGIN_CONTINUE
}

public fm_UpdateClientDataPost(player, sendWeapons, cd)
{
	if(!client_is_hero_user(player, gHeroID)){
		
		return FMRES_IGNORED
	}
	if((get_user_weapon(player) != MARIA_WEAPON_CLASSID)){
		return FMRES_IGNORED
	}
	new pEntity =  get_pdata_cbase(player, m_pActiveItem,OFFSET_LINUX_PLAYER)
	if(pev_valid(pEntity)==PDATA_SAFE){
		set_cd(cd, CD_flNextAttack, get_gametime()+1.0)
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}



public rrrrroovvetoooo_touque_playor(pToucher, pTouched)
{
	if(!is_valid_ent(pToucher)) return
	
	new Float:origin[3]
	entity_get_vector(pToucher,EV_VEC_origin,origin);
	
	new bool:is_direct_hit = bool:is_user_alive(pTouched);
	new Float:rivet_launch_pos[3]
	entity_get_vector(pToucher,EV_VEC_vuser1,rivet_launch_pos)
	new Float:distance=vector_distance(origin,rivet_launch_pos);
	new Float:falloff_coeff= (is_direct_hit?0.0:floatmin(1.0,distance/MARIA_PROJECTILE_DAMAGE_FALLOFF_DIST));
	new Float:damage=MARIA_PROJECTILE_DAMAGE-(35.0*falloff_coeff)+(is_direct_hit?MARIA_PROJECTILE_DAMAGE_DIRECT_BONUS:0.0);
	explosion(gHeroID,pToucher,
									MARIA_PROJECTILE_EXPLODE_RADIUS,damage,
									MARIA_PROJECTILE_EXPLODE_FORCE-(is_direct_hit?MARIA_PROJECTILE_KNOCKBACK_DIRECT_REDUCED:0.0),
									is_direct_hit,
									is_direct_hit,
									_,_,_,_,
									maria_riveter_wpn_id)
	explosion_custom_entity(pToucher,
									MARIA_PROJECTILE_EXPLODE_RADIUS,damage,
									"func_breakable",
									MARIA_PROJECTILE_EXPLODE_FORCE,0)
	
	my_remove_entity(pToucher)
}
public plugin_precache()
{

engfunc(EngFunc_PrecacheModel,"models/shell.mdl")
engfunc(EngFunc_PrecacheSound, MARIA_RIVETER_SHOTSOUND)
engfunc(EngFunc_PrecacheSound, MARIA_RIVETER_WALLHIT_SOUND)

}
public fm_PlaybackEventPre() return FMRES_SUPERCEDE
