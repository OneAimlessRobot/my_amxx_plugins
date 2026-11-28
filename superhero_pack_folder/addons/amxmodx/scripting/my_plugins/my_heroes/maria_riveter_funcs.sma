#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#define I_WANT_PDATA_ALIASES
#define I_WANT_ENTITY_VECTORS
#define I_WANT_QUICK_CHECKS
#define I_WANT_CUSTOM_COLORS
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_BASIC_MACROS
#define I_WANT_MISC_FUNCS_3

#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "maria_riveter_inc/maria_general_funcs.inc"
#include "maria_riveter_inc/maria_riveter_funcs.inc"
#include "sh_aux_stuff/sh_pokemon_dmg_framework.inc"
#include "../my_include/my_author_header.inc"


#define PLUGIN_VER "1.0"
#define PLUGIN_NAME "SUPERHERO Maria's riveter"


#define MARIA_PROJECTILE_CLASSNAME "maria_rivet"


#define MARIA_RIVETER_SHOTSOUND "weapons/m60-1.wav"
#define MARIA_RIVETER_WALLHIT_SOUND "weapons/xbow_hit1.wav"


#define MARIA_PROJECTILE_EXPLODE_RADIUS 90.0
#define MARIA_PROJECTILE_EXPLODE_FORCE 2000.0
#define MARIA_PROJECTILE_KNOCKBCK_DIRECT_RED_PCT 50.0
#define MARIA_PROJECTILE_KNOCKBACK_DIRECT_REDUCED (MARIA_PROJECTILE_EXPLODE_FORCE* ((MARIA_PROJECTILE_KNOCKBCK_DIRECT_RED_PCT)/100.0))

#define MARIA_PROJECTILE_DAMAGE 125.0
#define MARIA_PROJECTILE_DAMAGE_DIRECT_BONUS_PCT 50.0
#define MARIA_PROJECTILE_DAMAGE_AIRSHOT_BONUS_PCT 100.0
#define MARIA_PROJECTILE_DAMAGE_DIRECT_BONUS (MARIA_PROJECTILE_DAMAGE* ((MARIA_PROJECTILE_DAMAGE_DIRECT_BONUS_PCT)/100.0))
#define MARIA_PROJECTILE_DAMAGE_AIRSHOT_BONUS (MARIA_PROJECTILE_DAMAGE* ((MARIA_PROJECTILE_DAMAGE_AIRSHOT_BONUS_PCT)/100.0))
#define MARIA_PROJECTILE_DAMAGE_FALLOFF_DIST 2500.0


#define MARIA_PROJECTILE_DEPLOY_TIME 1.0
#define MARIA_PROJECTILE_SHOOT_PERIOD 0.25

#define MARIA_PROJECTILE_SHOOT_RANDOMNESS 0.3


#define MARIA_PROJECTILE_SPEED 3000.0
#define MARIA_PROJECTILE_GRAVITY_MULT 1.0
#define MARIA_PROJECTILE_PHYS_UPDATE_TIME 0.05

#define MARIA_PROJECTILE_MASS 1.0
#define MARIA_PROJECTILE_CAR 0.1073
#define MARIA_PROJECTILE_DIAMETER 2.0
#define MARIA_PROJECTILE_AREA ((MARIA_PROJECTILE_DIAMETER*MARIA_PROJECTILE_DIAMETER)*M_PI)
#define MARIA_AIR_RESISTANCE 0.25
#define MARIA_PROJECTILE_DRAG_CONST (MARIA_PROJECTILE_AREA*MARIA_PROJECTILE_CAR*MARIA_AIR_RESISTANCE)

#define RIVETER_RECOIL 3.0



#define RIVETER_CLIP_SIZE 117

new Float:g_Recoil[SH_MAXSLOTS+1][3]
new g_Riveter_clip[SH_MAXSLOTS+1]

new trigger_is_down_mask = 0
new trigger_was_down_mask = 0
new semi_automatic_mode_mask = 0
new mode_selector_is_down_mask = 0
new mode_selector_was_down_mask = 0
new wpn_name_for_future_lookup[50]
new maria_riveter_wpn_id
new dmg_source_name_short_riveter[SAFE_BUFFER_SIZE+1]="riveter"
new dmg_source_name_log_riveter[SAFE_BUFFER_SIZE+1]="riveter"
new gNumRivets[SH_MAXSLOTS+1]

new bool:is_hostage_map = false

enum {
	MARIA_NO_ZOOM=0,
	MARIA_FIRST_ZOOM=1,
	MARIA_SECOND_ZOOM=2,
	MARIA_MAX_ZOOM=3
}

enum maria_riveter_anims
{
	maria_riveter_anim_idle = 0,
	maria_riveter_anim_reload,
	maria_riveter_anim_draw,
	maria_riveter_anim_shoot1,
	maria_riveter_anim_shoot2,
	maria_riveter_anim_shoot3
}
public plugin_init(){
	

	register_plugin(PLUGIN_NAME, PLUGIN_VER, AUTHOR);

	register_forward(FM_CmdStart, "CmdStart");
	
	
	wlt_get_def_name(MARIA_WEAPON_CLASSID,wpn_name_for_future_lookup,charsmax(wpn_name_for_future_lookup))
	RegisterHam(Ham_Item_Deploy, wpn_name_for_future_lookup, "fw_ItemDeployPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, wpn_name_for_future_lookup, "fw_WeaponPrimaryAttackPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, wpn_name_for_future_lookup, "fw_Weapon_PrimaryAttack_Post", 1,true)	
	RegisterHam(Ham_Item_PostFrame, wpn_name_for_future_lookup, "fw_Item_PostFrame",_,true)	
	
	
	RegisterHam(Ham_Weapon_Reload, wpn_name_for_future_lookup, "fw_WeaponReloadPre",_,true)
	RegisterHam(Ham_Weapon_Reload, wpn_name_for_future_lookup, "fw_Weapon_Reload_Post", 1,true)

	register_entity_as_wall_touchable(MARIA_PROJECTILE_CLASSNAME,"rrrrroovvetoooo_touque_playor")
	register_custom_touchable(MARIA_PROJECTILE_CLASSNAME,"rrrrroovvetoooo_touque_playor",player_vector,1)

	is_hostage_map =  (engfunc(EngFunc_FindEntityByString, -1, "classname", "hostage_entity") > 0)
	
	if(is_hostage_map){
		register_custom_touchable(MARIA_PROJECTILE_CLASSNAME,"rrrrroovvetoooo_touque_playor",hostage_vector,1)
	}
	

	register_think(MARIA_PROJECTILE_CLASSNAME, "rivette_thinque")

	init_gravity_pcvar()


}
public plugin_natives(){

	register_native("riveter_set_num_rivets","_riveter_set_num_rivets");
	register_native("riveter_set_user_riveter","_riveter_set_user_riveter");
	
}

public _riveter_set_user_riveter(iPlugin,iParams){
	
	new id = get_param(1),
		bool:value = bool:get_param(2),
		start_ammo = get_param(3)
	
	gNumRivets[id] = 0
	sh_assign_id_custom_weapon_bit(id, SH_RIVETER, value);
	if(value){
		gNumRivets[id] = max_macro(1,start_ammo)
		sh_give_weapon(id, MARIA_WEAPON_CLASSID,true)
		new weapon_id=get_weapon_ent_of_player(id,MARIA_WEAPON_CLASSID)
		if(is_valid_ent(weapon_id)){
			
			set_pdata_int(weapon_id, m_iClip, RIVETER_CLIP_SIZE, XO_WEAPON);
			cs_set_user_bpammo(id, MARIA_WEAPON_CLASSID,gNumRivets[id]-RIVETER_CLIP_SIZE);
		}
	}
	else{
		if ( is_user_alive(id) ) {
			sh_drop_weapon(id,MARIA_WEAPON_CLASSID,true);
		}
	}

}
public _riveter_set_num_rivets(iPlugin,iParams){
	new id= get_param(1)
	new value_to_set=get_param(2)
	gNumRivets[id]=value_to_set;
}

public sh_round_end(){

	remove_entity_name(MARIA_PROJECTILE_CLASSNAME)

}
public plugin_cfg(){


	gHeroID = maria_get_hero_id()
	
	maria_riveter_wpn_id=sh_log_custom_damage_source(
								-1,
								dmg_source_name_short_riveter,
								dmg_source_name_log_riveter,
								0)

}
public rivette_thinque(ent){


	if (!is_valid_ent(ent)) return
	
	new owner=entity_get_edict(ent, EV_ENT_owner)

	if(!is_user_alive(owner)){

		remove_entity_safe(ent)	
		return
	}

	
	orient_entity_with_move_vector(ent)

	
	projectile_air_drag_update_speed(ent,MARIA_PROJECTILE_DRAG_CONST,MARIA_PROJECTILE_GRAVITY_MULT,MARIA_PROJECTILE_PHYS_UPDATE_TIME)
	

	entity_set_float( ent, EV_FL_nextthink, floatadd(get_gametime( ) ,MARIA_PROJECTILE_PHYS_UPDATE_TIME));



}
public CmdStart(id, uc_handle)
{	

	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}

	if(!client_is_weapon_user(id, SH_RIVETER)){
		
		return FMRES_IGNORED
	}

	
	Assign_BitVar(mode_selector_was_down_mask, id,Get_BitVar(mode_selector_is_down_mask, id));
	
	Assign_BitVar(trigger_was_down_mask, id,Get_BitVar(trigger_is_down_mask, id));

	new button = get_uc(uc_handle, UC_Buttons);
	

	Assign_BitVar(mode_selector_is_down_mask, id,(button & IN_ATTACK2));
	
	Assign_BitVar(trigger_is_down_mask, id,(button & IN_ATTACK));
	
	new  weapon = get_user_weapon(id);
	if((weapon==_:MARIA_WEAPON_CLASSID)){
		
		if(Get_BitVar(trigger_is_down_mask, id))
		{	
			new bool:cant_shoot = ((gNumRivets[id]<=0)) ||
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
				Assign_BitVar(semi_automatic_mode_mask,id,!Get_BitVar(semi_automatic_mode_mask, id))

				if(!is_user_bot(id)){
					client_print(id,print_center,"Riveter: %s",Get_BitVar(semi_automatic_mode_mask, id)?"semi auto":"full auto")
				}

			}
		}
	}
	return FMRES_IGNORED;
}


public fw_Item_PostFrame(ent)
{
	
	if(pev_valid(ent) != 2){
		return HAM_IGNORED
	}
	static id; id = get_pdata_cbase(ent, m_pPlayer,XO_WEAPON)
	if(!client_is_weapon_user(id, SH_RIVETER)){
		
		return HAM_IGNORED
	}
	static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, XO_PLAYER)
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
	
	if(!client_is_weapon_user(pPlayer, SH_RIVETER)){
		
		return HAM_IGNORED
	}
	g_Riveter_clip[pPlayer] = -1
	static BPAmmo; BPAmmo = cs_get_user_bpammo(pPlayer, _:MARIA_WEAPON_CLASSID)
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
	if(!client_is_weapon_user(id, SH_RIVETER)){
		
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
	
	if(!client_is_weapon_user(pPlayer, SH_RIVETER)){
		return HAM_IGNORED
	}
	ExecuteHam(Ham_Item_Deploy, entity)
	set_pdata_float(pPlayer, m_flNextAttack, MARIA_PROJECTILE_DEPLOY_TIME,XO_PLAYER)
	set_pdata_float(entity, m_flTimeWeaponIdle, MARIA_PROJECTILE_DEPLOY_TIME,XO_WEAPON)
	set_pdata_int(entity, m_iClip,min(RIVETER_CLIP_SIZE,get_pdata_int(entity, m_iClip, XO_WEAPON)), XO_WEAPON)
	return HAM_SUPERCEDE
}


public fw_WeaponPrimaryAttackPre(entity)
{

	if(pev_valid(entity)!=2)
		return HAM_IGNORED
		
	if (sh_is_freezetime()) return HAM_IGNORED;

	static pPlayer; pPlayer = get_pdata_cbase(entity, m_pPlayer, XO_WEAPON)
	
	if(!client_is_weapon_user(pPlayer, SH_RIVETER)){
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
	if(!client_is_weapon_user(id, SH_RIVETER)){
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

if(!client_is_weapon_user(id, SH_RIVETER)){
		
	return PLUGIN_CONTINUE
}
static Float:Origin[3], Float:Velocity[3], Float:vAngle[3], Ent

entity_get_vector(id, EV_VEC_origin , Origin)
entity_get_vector(id, EV_VEC_v_angle, vAngle)


Ent = create_entity("info_target")

if (!Ent){
	return PLUGIN_HANDLED
}
entity_set_string(Ent, EV_SZ_classname, MARIA_PROJECTILE_CLASSNAME)
entity_set_model(Ent, "models/shell.mdl")

static Float:MinBox[3] = {-1.0, -1.0, -1.0},
	Float:MaxBox[3] = {1.0, 1.0, 1.0}
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
gNumRivets[id]-= (gNumRivets[id]>0)? 1:0

//rivet launch pos
entity_set_vector(Ent,EV_VEC_vuser1,Origin)

emit_sound(id, CHAN_WEAPON, MARIA_RIVETER_SHOTSOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

trail(Ent,LTGREEN,3,5)
entity_set_float( Ent, EV_FL_nextthink, floatadd(get_gametime( ) ,MARIA_PROJECTILE_PHYS_UPDATE_TIME));

return PLUGIN_CONTINUE
}



public rrrrroovvetoooo_touque_playor(pToucher, pTouched)
{
	if(!is_valid_ent(pToucher)) return

	static Float:origin[3]
	entity_get_vector(pToucher,EV_VEC_origin,origin);

	new bool:is_direct_hit = bool:is_user_alive(pTouched);
	new bool:is_air_shot = false;
	if(is_direct_hit){

		is_air_shot= bool:!(FL_ONGROUND & entity_get_int(pTouched, EV_INT_flags));

	}
	new owner = entity_get_edict(pToucher,EV_ENT_owner);

	static Float:rivet_launch_pos[3]
	entity_get_vector(pToucher,EV_VEC_vuser1,rivet_launch_pos)
	new Float:distance=vector_distance(origin,rivet_launch_pos);
	new Float:falloff_coeff= (is_direct_hit?0.0:min_macro(1.0,distance/MARIA_PROJECTILE_DAMAGE_FALLOFF_DIST));

	new Float:damage_bonus = is_direct_hit?(is_air_shot?(MARIA_PROJECTILE_DAMAGE_AIRSHOT_BONUS + MARIA_PROJECTILE_DAMAGE_DIRECT_BONUS):MARIA_PROJECTILE_DAMAGE_DIRECT_BONUS):0.0;

	new Float:damage=MARIA_PROJECTILE_DAMAGE-(35.0*falloff_coeff)+damage_bonus;
	explosion(gHeroID,pToucher,
									MARIA_PROJECTILE_EXPLODE_RADIUS,damage,
									MARIA_PROJECTILE_EXPLODE_FORCE-(is_direct_hit?MARIA_PROJECTILE_KNOCKBACK_DIRECT_REDUCED:0.0),
									is_direct_hit,
									is_direct_hit,
									_,_,_,_,
									maria_riveter_wpn_id,_,true)
	explosion_custom_entity(pToucher,
									MARIA_PROJECTILE_EXPLODE_RADIUS,damage,
									"func_breakable",
									MARIA_PROJECTILE_EXPLODE_FORCE,
									explosion_sfx_show_nothing)
	if(is_hostage_map){
		explosion_custom_entity(pToucher,
										MARIA_PROJECTILE_EXPLODE_RADIUS,damage,
										"hostage_entity",
										MARIA_PROJECTILE_EXPLODE_FORCE,
										explosion_sfx_show_nothing)
	}
	remove_entity_safe(pToucher)

	if(is_user_connected(owner)&&is_user_alive(pTouched)&&!sh_clients_are_same_team(pTouched,owner)){
		sh_apply_staged_stat_boost(pTouched,owner,STAT_DEFENSE_MULT,_:(is_direct_hit)+_:(is_air_shot),false)
		
		sh_apply_staged_stat_boost(owner,owner,STAT_DEFENSE_MULT,_:(is_direct_hit)+_:(is_air_shot),true)
	}
}
public plugin_precache()
{

engfunc(EngFunc_PrecacheModel,"models/shell.mdl")
engfunc(EngFunc_PrecacheSound, MARIA_RIVETER_SHOTSOUND)
engfunc(EngFunc_PrecacheSound, MARIA_RIVETER_WALLHIT_SOUND)

}
public fm_PlaybackEventPre() return FMRES_SUPERCEDE
