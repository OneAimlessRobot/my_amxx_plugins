#define I_WANT_CONSTANTS
#define I_WANT_QUICK_CHECKS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#define I_WANT_CUSTOM_WEAPONS

#include "../my_include/superheromod.inc"
#include "tranq_gun_inc/sh_erica_get_set.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "tranq_gun_inc/sh_tranq_funcs.inc"
#include "../my_include/auxiliar_stuff.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"


#define PLUGIN "Superhero erica tranq funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new gHeroID = -1
new Float:g_Recoil[SH_MAXSLOTS+1][3]
new trigger_is_down_mask = 0
new trigger_was_down_mask = 0
new g_Tranq_Clip[SH_MAXSLOTS+1]


new super_dart_weapon_id
new dmg_source_name_short_super_dart[SAFE_BUFFER_SIZE+1]="super_dart"
new dmg_source_name_log_super_dart[SAFE_BUFFER_SIZE+1]="super_dart"

new weapon_secret_code = -1
public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);
	

	register_forward(FM_CmdStart, "CmdStart");
	RegisterHam(Ham_Item_Deploy, weapon_names_stock_arr[DART_GUN_WEAPON_CLASSID], "fw_ItemDeployPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_names_stock_arr[DART_GUN_WEAPON_CLASSID], "fw_WeaponPrimaryAttackPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_names_stock_arr[DART_GUN_WEAPON_CLASSID], "fw_Weapon_PrimaryAttack_Post", 1,true)
	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack_Player",_,true)
	RegisterHam(Ham_Item_PostFrame, weapon_names_stock_arr[DART_GUN_WEAPON_CLASSID], "fw_Item_PostFrame",_,true)

	RegisterHam(Ham_Weapon_Reload,weapon_names_stock_arr[DART_GUN_WEAPON_CLASSID], "fw_WeaponReloadPre",_,true)
	RegisterHam(Ham_Weapon_Reload, weapon_names_stock_arr[DART_GUN_WEAPON_CLASSID], "fw_Weapon_Reload_Post", 1,true)

	register_entity_as_wall_touchable(DART_CLASSNAME,"FwdTouchWorld")
	register_custom_touchable(DART_CLASSNAME,"chorazy_II_toumpaeeeehm",player_vector,1)

	register_think(DART_CLASSNAME, "tranque_thinque")

	init_gravity_pcvar()

	weapon_secret_code = allocate_weapon_secret_code()


}
public plugin_cfg(){

	gHeroID = tranq_get_hero_id()
	super_dart_weapon_id=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_super_dart,
								dmg_source_name_log_super_dart,
								0)

}
public FwdTouchWorld( dirt, World ) {

	if(!is_valid_ent(dirt)) return

	new Float:origin[3]
	entity_get_vector(dirt,EV_VEC_origin,origin);

	emit_sound(dirt, CHAN_WEAPON, GLASS_BREAK_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	make_sparks(origin);
	gun_shot_decal(origin);

	remove_entity(dirt)
}
public tranque_thinque(ent){


	if ( pev_valid(ent)!=2 ) return

	new owner=entity_get_edict(ent, EV_ENT_owner)

	if(!is_user_alive(owner)){

		remove_entity(ent)
		return
	}


	new parm[2]
	parm[0] = ent
	parm[1] = owner

	orient_entity_with_move_vector(ent)


	projectile_air_drag_update_speed(parm,DART_DRAG_CONST,DART_GRAVITY_MULT,DART_PHYS_UPDATE_TIME)


	entity_set_float( ent, EV_FL_nextthink, floatadd(get_gametime( ) ,DART_PHYS_UPDATE_TIME));


}

public CmdStart(id, uc_handle)
{

	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}

	if (!client_is_hero_user(id, gHeroID)) return FMRES_IGNORED;

	
	
	Assign_BitVar(trigger_was_down_mask, id,Get_BitVar(trigger_is_down_mask, id))

	new button = get_uc(uc_handle, UC_Buttons);
	
	
	Assign_BitVar(trigger_is_down_mask, id,(button & IN_ATTACK))

	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	if(weapon==DART_GUN_WEAPON_CLASSID){
		if(Get_BitVar(trigger_is_down_mask, id))
		{

			button &= ~IN_ATTACK;
			if(Get_BitVar(trigger_was_down_mask, id)||(tranq_get_num_darts(id)<=0)){
				set_uc(uc_handle, UC_Buttons, button);
				return FMRES_SUPERCEDE
			}

		}
	}

	return FMRES_IGNORED;
}

public fw_TraceAttack_Player(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{

	if(Damage<=0.0){
		return HAM_IGNORED
	}
	if(!is_user_connected(Attacker)){
		return HAM_IGNORED
	}
	if(get_user_weapon(Attacker) != DART_GUN_WEAPON_CLASSID || !sh_get_user_has_hero(Attacker,gHeroID) ){
		return HAM_IGNORED
	}

	Damage= 0.0
	SetHamParamFloat(3,Damage)

	return HAM_SUPERCEDE
}

public fw_Item_PostFrame(ent)
{
	new validity=pev_valid(ent);
	if(validity!=2){

		return HAM_IGNORED

	}
	static id; id = get_pdata_cbase(ent, m_pPlayer,XO_WEAPON)
	if(!client_is_hero_user(id, gHeroID)){

		return HAM_IGNORED;
	}
	static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, OFFSET_LINUX_PLAYER)
	static bpammo; bpammo = cs_get_user_bpammo(id, DART_GUN_WEAPON_CLASSID)

	static iClip; iClip = get_pdata_int(ent, m_iClip, XO_WEAPON)
	static fInReload; fInReload = get_pdata_int(ent, m_fInReload, XO_WEAPON)

	if(fInReload && flNextAttack <= 0.0)
	{
		static temp1
		temp1 = min(DART_PISTOL_CLIP_SIZE - iClip, bpammo)

		set_pdata_int(ent, m_iClip, iClip + temp1, XO_WEAPON)
		cs_set_user_bpammo(id, DART_GUN_WEAPON_CLASSID, bpammo - temp1)

		set_pdata_int(ent, m_fInReload, 0, XO_WEAPON)

		fInReload = 0
	}

	return HAM_IGNORED
}

public fw_WeaponReloadPre(entity)
{
	if(pev_valid(entity)!=2){
		return HAM_IGNORED
	}

	static pPlayer; pPlayer = get_pdata_cbase(entity, m_pPlayer,XO_WEAPON)

	if(!client_is_hero_user(pPlayer, gHeroID)){

		return HAM_IGNORED
	}
	g_Tranq_Clip[pPlayer] = -1

	static BPAmmo; BPAmmo = cs_get_user_bpammo(pPlayer, DART_GUN_WEAPON_CLASSID)
	static iClip; iClip = get_pdata_int(entity, m_iClip, XO_WEAPON)

	if(BPAmmo <= 0){
		return HAM_SUPERCEDE
	}
	if(iClip >= DART_PISTOL_CLIP_SIZE){
		return HAM_SUPERCEDE
	}
	g_Tranq_Clip[pPlayer] = iClip
	return HAM_HANDLED
}
public fw_Weapon_Reload_Post(ent)
{
	if(pev_valid(ent)!=2){
		return HAM_IGNORED
	}
	static id; id = get_pdata_cbase(ent, m_pPlayer,XO_WEAPON)
	if(!client_is_hero_user(id, gHeroID)){

		return HAM_IGNORED
	}

	if(g_Tranq_Clip[id] == -1)
		return HAM_IGNORED

	
	set_pdata_int(ent, m_iClip, g_Tranq_Clip[id], XO_WEAPON)
	set_pdata_int(ent, m_fInReload, 1, XO_WEAPON);
	
	return HAM_IGNORED
}
public fw_ItemDeployPre(entity)
{
	if(pev_valid(entity)!=2){
		return HAM_IGNORED
	}
	static pPlayer; pPlayer =get_pdata_cbase(entity, m_pPlayer,XO_WEAPON)

	if(!client_is_hero_user(pPlayer, gHeroID)){
		remove_weapon_secret_code(entity,weapon_secret_code)
		return HAM_IGNORED
	}
	ExecuteHam(Ham_Item_Deploy, entity)
	set_pdata_float(entity, m_flNextPrimaryAttack, DART_DEPLOY_TIME ,XO_WEAPON)
	set_pdata_float(entity, m_flTimeWeaponIdle, DART_DEPLOY_TIME ,XO_WEAPON)
	set_pdata_int(entity, m_iClip,min(DART_PISTOL_CLIP_SIZE,get_pdata_int(entity, m_iClip, XO_WEAPON)), XO_WEAPON)
	set_weapon_secret_code(entity,weapon_secret_code)
	return HAM_SUPERCEDE
}


public fw_WeaponPrimaryAttackPre(entity)
{
	if(pev_valid(entity)!=2){
		return HAM_IGNORED
	}
	static pPlayer; pPlayer = get_pdata_cbase(entity, m_pPlayer,XO_WEAPON)

	if ( !is_user_alive(pPlayer)||!hasRoundStarted()) return HAM_IGNORED;
	if(!sh_get_user_has_hero(pPlayer,gHeroID)){

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
	launch_dart(pPlayer)
	g_Tranq_Clip[pPlayer]=get_pdata_int(entity, m_iClip, XO_WEAPON)
	
	set_pdata_float(entity, m_flNextPrimaryAttack, DART_SHOOT_PERIOD ,XO_WEAPON)
	set_pdata_float(entity, m_flTimeWeaponIdle, DART_SHOOT_PERIOD ,XO_WEAPON)
	entity_get_vector(pPlayer, EV_VEC_punchangle, g_Recoil[pPlayer])
	native_playanim(pPlayer, generate_int(seq_shoot_left1,seq_shoot_rightlast))
	unregister_forward(FM_PlaybackEvent, iPlaybackEvent)

	return HAM_SUPERCEDE
}

public fw_Weapon_PrimaryAttack_Post(Ent)
{
	if(pev_valid(Ent)!=2){
		return
	}

	static id; id = get_pdata_cbase(Ent, m_pPlayer,XO_WEAPON)
	if(!client_is_hero_user(id, gHeroID)){
		return;
	}

	static iClip;iClip = get_pdata_int(Ent, m_iClip, XO_WEAPON)
	if(iClip<=0){

		return
	}
	static Float:Push[3]
	pev(id, pev_punchangle, Push)
	sub_3d_vectors(Push, g_Recoil[id], Push)

	multiply_3d_vector_by_scalar(Push, DART_PISTOL_RECOIL, Push)
	add_3d_vectors(Push, g_Recoil[id], Push)
	set_pev(id, pev_punchangle, Push)
}
launch_dart(id)
{
	if(!client_is_hero_user(id, gHeroID)){

		return
	}
	new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)


	Ent = create_entity("info_target")

	if (!Ent) return

	entity_set_string(Ent, EV_SZ_classname, DART_CLASSNAME)
	entity_set_model(Ent, "models/shell.mdl")

	new Float:MinBox[3] = {-1.0, -1.0, -1.0}
	new Float:MaxBox[3] = {1.0, 1.0, 1.0}
	entity_set_vector(Ent, EV_VEC_mins, MinBox)
	entity_set_vector(Ent, EV_VEC_maxs, MaxBox)

	entity_set_origin(Ent, Origin)
	entity_set_vector(Ent, EV_VEC_angles, vAngle)

	entity_set_int(Ent, EV_INT_effects, 2)
	entity_set_int(Ent, EV_INT_solid, 2)
	entity_set_int(Ent, EV_INT_movetype, MOVETYPE_TOSS)
	entity_set_float(Ent,EV_FL_gravity, DART_GRAVITY_MULT)
	entity_set_edict(Ent, EV_ENT_owner, id)

	velocity_by_aim(id, floatround(DART_SPEED) , Velocity)
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

	tranq_dec_num_darts(id)
	new bool:dart_hurts=false;
	if(tranq_get_is_max_points(id)){
		dart_hurts=true
		//dart will cause damage on top of sleeping
		entity_set_int(Ent,EV_INT_iuser1,dart_hurts)

		//dart launch pos is stored here
		entity_set_vector(Ent,EV_VEC_vuser1,Origin)

	}
	new parm2[1]

	parm2[0]= id
	emit_sound(id, CHAN_WEAPON, SILENT_TRANQS_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	trail(Ent,dart_hurts?RED:WHITE,3,2)

	entity_set_float( Ent, EV_FL_nextthink, floatadd(get_gametime( ) ,DART_PHYS_UPDATE_TIME));
}

public chorazy_II_toumpaeeeehm(pToucher, pTouched)
{

	if(!is_valid_ent(pToucher)) return

	if(is_user_alive(pTouched))
	{
		new oid = entity_get_edict(pToucher, EV_ENT_owner)
		new dart_hurts=entity_get_int(pToucher,EV_INT_iuser1)
		if(dart_hurts){
			static Float:bullet_launch_pos[3],
				Float:origin[3],
				Float:velocity[3],
				Float:speed,
				Float:damage,
				Float:falloff_coeff,
				Float:distance,
				my_hitpoint_enum:the_hitpoint,
				bool:headshot=false



			entity_get_vector(pToucher,EV_VEC_origin,origin);
						
			entity_get_vector(pToucher,EV_VEC_vuser1,bullet_launch_pos)

			entity_get_vector(pToucher,EV_VEC_velocity,velocity)

			speed=floatmax(1.0,vector_length(velocity))

			damage = calculate_nuanced_projectile_damage(pToucher,
								bullet_launch_pos,
								DART_DAMAGE,
								DART_DAMAGE_FALLOFF_DIST,
								DART_SPEED,
								distance,
								falloff_coeff)

			the_hitpoint= get_projectile_hit_hitpoint(pToucher,
												velocity,
												DART_HEADSHOT_THRESHOLD_DIST*3.0,
												speed)
			if(the_hitpoint==MY_HIT_HEAD){

				headshot=true;
				damage*=4.0;
			}
			sh_extra_damage(pTouched,oid,floatround(damage),
						the_hitpoint,
						_,_,_,_,
						SH_NEW_DMG_BLEED,
						super_dart_weapon_id)
			
			if(sh_get_user_has_hero(oid,gHeroID)){

				sh_effect_user_direct(oid,oid,gHeroID,COCAINE)
			}
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
		sh_sleep_user(pTouched,oid,gHeroID)

	}
	remove_entity(pToucher)
}

public fm_UpdateClientDataPost(player, sendWeapons, cd)
{
	if(!client_is_hero_user(player, gHeroID)){
		return FMRES_IGNORED
	}
	new weapon = get_user_weapon(player);
	if(weapon!=DART_GUN_WEAPON_CLASSID){
		return FMRES_IGNORED
	}
	new pEntity = get_pdata_cbase(player, m_pActiveItem,OFFSET_LINUX_PLAYER)
	if(pev_valid(pEntity)==PDATA_SAFE){
		set_cd(cd, CD_flNextAttack, get_gametime()+1.0)
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}
public plugin_precache()
{

	engfunc(EngFunc_PrecacheModel,"models/shell.mdl")
	engfunc(EngFunc_PrecacheSound, GLASS_BREAK_SFX)
	engfunc(EngFunc_PrecacheSound, SILENT_TRANQS_SFX)


}
public fm_PlaybackEventPre() return FMRES_SUPERCEDE
