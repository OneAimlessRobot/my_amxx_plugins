#define I_WANT_CONSTANTS
#define I_WANT_QUICK_CHECKS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#include "../my_include/superheromod.inc"
#include "tranq_gun_inc/sh_erica_get_set.inc"
#include <reapi>
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "tranq_gun_inc/sh_tranq_funcs.inc"
#include "../my_include/auxiliar_stuff.inc"
#include "../my_include/weapons_const.inc"


#define PLUGIN "Superhero erica tranq funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new gHeroID = 0
new Float:g_Recoil[SH_MAXSLOTS+1][3]
new trigger_is_down_mask = 0
new trigger_was_down_mask = 0
new g_Tranq_Clip[SH_MAXSLOTS+1]


new super_dart_weapon_id
new dmg_source_name_short_super_dart[SAFE_BUFFER_SIZE+1]="super_dart"
new dmg_source_name_long_super_dart[SAFE_BUFFER_SIZE+1]="super_dart"


public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	gHeroID = tranq_get_hero_id()

	register_forward(FM_CmdStart, "CmdStart");
	RegisterHam(Ham_Item_Deploy, STRN_ELITE, "fw_ItemDeployPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, STRN_ELITE, "fw_WeaponPrimaryAttackPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, STRN_ELITE, "fw_Weapon_PrimaryAttack_Post", 1,true)
	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack_Player",_,true)
	RegisterHam(Ham_Item_PostFrame, STRN_ELITE, "fw_Item_PostFrame",_,true)

	RegisterHam(Ham_Weapon_Reload,STRN_ELITE, "fw_WeaponReloadPre",_,true)
	RegisterHam(Ham_Weapon_Reload, STRN_ELITE, "fw_Weapon_Reload_Post", 1,true)

	register_entity_as_wall_touchable(DART_CLASSNAME,"FwdTouchWorld")
	register_custom_touchable(DART_CLASSNAME,"chorazy_II_toumpaeeeehm",player_vector,1)

	register_think(DART_CLASSNAME, "tranque_thinque")



	super_dart_weapon_id=sh_log_custom_damage_source(
								gHeroID,
								dmg_source_name_short_super_dart,
								dmg_source_name_long_super_dart,
								0)

	init_gravity_pcvar()



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


	if ( pev_valid(ent)!=2 ) return FMRES_IGNORED

	new owner=entity_get_edict(ent, EV_ENT_owner)

	if(!is_user_alive(owner)){

		remove_entity(ent)
		return FMRES_IGNORED
	}


	new parm[2]
	parm[0] = ent
	parm[1] = owner

	static Float:fl_NewAngle[3],Float:fl_Velocity[3]
	entity_get_vector(ent,EV_VEC_velocity,fl_Velocity)
	vector_to_angle(fl_Velocity, fl_NewAngle)
	entity_set_vector(ent, EV_VEC_angles, fl_NewAngle)
	entity_set_vector(ent, EV_VEC_v_angle, fl_NewAngle)


	projectile_air_drag_update_speed(parm,DART_DRAG_CONST,DART_GRAVITY_MULT,DART_PHYS_UPDATE_TIME)


	entity_set_float( ent, EV_FL_nextthink, floatadd(get_gametime( ) ,DART_PHYS_UPDATE_TIME));

	return FMRES_IGNORED


}

public CmdStart(id, uc_handle)
{
	if (!hasRoundStarted()||!client_is_hero_user(id, gHeroID)) return FMRES_IGNORED;

	
	if(Get_BitVar(trigger_is_down_mask, id)){
		Set_BitVar(trigger_was_down_mask, id)
	}
	else{

		UnSet_BitVar(trigger_was_down_mask, id)
	}
	new button = get_uc(uc_handle, UC_Buttons);
	
	if((button & IN_ATTACK)){

		Set_BitVar(trigger_is_down_mask, id)
	}
	else{
		
		UnSet_BitVar(trigger_is_down_mask, id)
	}
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	if(weapon==CSW_ELITE){
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

	if(!is_user_connected(Attacker)){
		return HAM_IGNORED
	}
	if(get_user_weapon(Attacker) != CSW_ELITE || !sh_user_has_hero(Attacker,gHeroID) ){
		return HAM_IGNORED
	}

	Damage=0.0;

	return HAM_SUPERCEDE
}

public fw_Item_PostFrame(ent)
{
	new validity=pev_valid(ent);
	if(validity!=2){

		server_print("weapon_elite entity has invalid private data @ fw_Item_PostFrame.^nValidity is: %d^n",validity)
		return HAM_IGNORED

	}
	static id; id = pev(ent, pev_owner)
	if(!client_is_hero_user(id, gHeroID)){

		return HAM_IGNORED;
	}
	static Float:flNextAttack; flNextAttack = get_pdata_float(id, 83, 5)
	static bpammo; bpammo = cs_get_user_bpammo(id, CSW_ELITE)

	static iClip; iClip = get_pdata_int(ent, 51, 4)
	static fInReload; fInReload = get_pdata_int(ent, 54, 4)

	if(fInReload && flNextAttack <= 0.0)
	{
		static temp1
		temp1 = min(CLIP_SIZE - iClip, bpammo)

		set_pdata_int(ent, 51, iClip + temp1, 4)
		cs_set_user_bpammo(id, CSW_ELITE, bpammo - temp1)

		set_pdata_int(ent, 54, 0, 4)

		fInReload = 0
	}

	return HAM_IGNORED
}

public fw_WeaponReloadPre(entity)
{
	if(pev_valid(entity)!=2){
		return HAM_IGNORED
	}

	new pPlayer = get_member(entity, m_pPlayer)

	if(!client_is_hero_user(pPlayer, gHeroID)){

		return HAM_IGNORED
	}
	g_Tranq_Clip[pPlayer] = -1

	static BPAmmo; BPAmmo = cs_get_user_bpammo(pPlayer, CSW_ELITE)
	static iClip; iClip = get_pdata_int(entity, 51, 4)

	if(BPAmmo <= 0){
		return HAM_SUPERCEDE
	}
	if(iClip >= CLIP_SIZE){
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
	static id; id = pev(ent, pev_owner)
	if(!client_is_hero_user(id, gHeroID)){

		return HAM_IGNORED
	}
	if((get_pdata_int(ent, 54, 4) == 1))
	{ // Reload
		if(g_Tranq_Clip[id] == -1)
		return HAM_IGNORED

		set_pdata_int(ent, 51, g_Tranq_Clip[id], 4)
	}


	return HAM_HANDLED
}
public fw_ItemDeployPre(entity)
{
	if(pev_valid(entity)!=2){
		return HAM_IGNORED
	}
	new pPlayer = get_member(entity, m_pPlayer)

	if(!sh_user_has_hero(pPlayer,gHeroID) ){

		return HAM_IGNORED
	}
	ExecuteHam(Ham_Item_Deploy, entity)
	set_member(pPlayer, m_flNextAttack, DART_DEPLOY_TIME)
	set_member(entity, m_Weapon_flTimeWeaponIdle,  DART_DEPLOY_TIME)
	set_pdata_int(entity, 51,min(CLIP_SIZE,get_pdata_int(entity, 51, 4)), 4)
	return HAM_SUPERCEDE
}


public fw_WeaponPrimaryAttackPre(entity)
{
	if(pev_valid(entity)!=2){
		return HAM_IGNORED
	}
	new pPlayer = get_member(entity, m_pPlayer)

	if ( !is_user_alive(pPlayer)||!hasRoundStarted()) return HAM_IGNORED;
	if(!sh_user_has_hero(pPlayer,gHeroID)){

		return HAM_IGNORED
	}
	static iClip, iPlaybackEvent
	iClip = get_member(entity, m_Weapon_iClip)
	if(iClip)
	{
		iPlaybackEvent = register_forward(FM_PlaybackEvent, "fm_PlaybackEventPre")

	}
	ExecuteHam(Ham_Weapon_PrimaryAttack, entity)
	if(!iClip){
		return HAM_SUPERCEDE
	}
	launch_dart(pPlayer)
	g_Tranq_Clip[pPlayer]=get_pdata_int(entity, 51, 4)
	set_member(entity, m_Weapon_flTimeWeaponIdle, DART_SHOOT_PERIOD)
	set_member(entity, m_Weapon_flNextPrimaryAttack, DART_SHOOT_PERIOD)

	pev(pPlayer, pev_punchangle, g_Recoil[pPlayer])
	set_entvar(pPlayer, var_weaponanim,  generate_int(seq_shoot_left1,seq_shoot_rightlast))
	unregister_forward(FM_PlaybackEvent, iPlaybackEvent)

	return HAM_SUPERCEDE
}

public fw_Weapon_PrimaryAttack_Post(Ent)
{
	if(pev_valid(Ent)!=2){
		return
	}

	static id; id = pev(Ent, pev_owner)
	if(!client_is_hero_user(id, gHeroID)){
		return;
	}
	static Float:Push[3]
	pev(id, pev_punchangle, Push)
	sub_3d_vectors(Push, g_Recoil[id], Push)

	multiply_3d_vector_by_scalar(Push, RECOIL, Push)
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
		
		static Float:origin[3]
		entity_get_vector(pToucher,EV_VEC_origin,origin);
		new oid = entity_get_edict(pToucher, EV_ENT_owner)
		new dart_hurts=entity_get_int(pToucher,EV_INT_iuser1)
		if(dart_hurts){
			
			static Float:vic_origin[3],
				Float:velocity[3],
				Float:dart_launch_pos[3],
				Float:trace_vector_direction[3],
				Float:trace_vector_end[3],
				Float:speed,
				hitgroup
		


			entity_get_vector(pToucher,EV_VEC_velocity,velocity);
			speed=vector_length(velocity);
			new Float:speed_coeff=(speed/DART_SPEED)
			new vic_origin_eyes_int[3];
			entity_get_vector(pToucher,EV_VEC_vuser1,dart_launch_pos)
			get_user_origin(pTouched,vic_origin_eyes_int,1);
			new Float:distance=vector_distance(vic_origin,dart_launch_pos);
			new Float:falloff_coeff= floatmin(1.0,distance/DART_DAMAGE_FALLOFF_DIST);
			new Float:normal_damage=DART_DAMAGE-(35.0*falloff_coeff);
			new Float:damage=normal_damage*speed_coeff;
			new tr_handle=create_tr2()
			multiply_3d_vector_by_scalar(velocity,
							(DART_HEADSHOT_THRESHOLD_DIST*3.0)/speed,trace_vector_direction)
			add_3d_vectors(origin,trace_vector_direction,trace_vector_end)
			engfunc(EngFunc_TraceLine,
				origin,
				trace_vector_end,
				0,
				pToucher,
				tr_handle
			)
			hitgroup = get_tr2(tr_handle, TR_iHitgroup)

			free_tr2(tr_handle)
			new headshot=0;
			if(hitgroup==HIT_HEAD){

				headshot=1;
				damage*=4;
			}
			sh_extra_damage(pTouched,oid,floatround(damage),dmg_source_name_short_super_dart,
						my_hitpoint_enum:hitgroup,
						_,_,_,_,_,
						SH_NEW_DMG_BLEED,super_dart_weapon_id)
						
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
	if(weapon!=CSW_ELITE){
		return FMRES_IGNORED
	}
	new pEntity = get_member(player, m_pActiveItem)
	if(is_valid_ent(pEntity)){
		set_cd(cd, CD_flNextAttack, get_gametime()+9999.0)
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
