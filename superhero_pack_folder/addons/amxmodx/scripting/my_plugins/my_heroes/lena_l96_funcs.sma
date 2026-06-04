#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#define I_WANT_CUSTOM_WEAPONS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "track_fx_inc/track_fx.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "lena_inc/sh_lena_l96_include.inc"
#include "lena_inc/sh_lena_general_include.inc"
#include "../my_include/my_author_header.inc"
#include "../my_include/auxiliar_stuff.inc"

#define PLUGIN_VER "1.0"
#define PLUGIN_NAME "SUPERHERO Lena de Verias: L96 weapon_thingie"

new gHeroID = -1

new trigger_is_down_mask = 0
new trigger_was_down_mask = 0
new Float:g_Recoil[SH_MAXSLOTS+1][3]
new g_L96_clip[SH_MAXSLOTS+1]
new pcvar_dmg_headshot_mult,
	pcvar_xp_distance_mult;

new dmg_source_name_short_l96[SAFE_BUFFER_SIZE+1]="L96A1"
new dmg_source_name_log_l96[SAFE_BUFFER_SIZE+1]="Lena_s_L96A1"
new custom_dmg_id_l96

new weapon_secret_code = -1
//new HamHook:TakeDamage
public plugin_init(){
	
	
	register_plugin(PLUGIN_NAME, PLUGIN_VER, AUTHOR);

	pcvar_dmg_headshot_mult = create_cvar("lena_dmg_headshot_mult","5")
	pcvar_xp_distance_mult = create_cvar("lena_xp_distance_mult","4")

	register_forward(FM_CmdStart, "CmdStart");
	RegisterHam(Ham_Item_Deploy, weapon_data_structs_array[LENA_WEAPON_CLASSID][wpn_struct_weapon_name], "fw_ItemDeployPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_data_structs_array[LENA_WEAPON_CLASSID][wpn_struct_weapon_name], "fw_WeaponPrimaryAttackPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_data_structs_array[LENA_WEAPON_CLASSID][wpn_struct_weapon_name], "fw_Weapon_PrimaryAttack_Post", 1,true)	
	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)
	RegisterHam(Ham_Item_PostFrame, weapon_data_structs_array[LENA_WEAPON_CLASSID][wpn_struct_weapon_name], "fw_Item_PostFrame",_,true)	
	
	
	RegisterHam(Ham_TraceAttack, "player", "Ham_TraceAttackLenaL96",_,true)
	
	RegisterHam(Ham_Weapon_Reload,weapon_data_structs_array[LENA_WEAPON_CLASSID][wpn_struct_weapon_name], "fw_WeaponReloadPre",_,true)
	RegisterHam(Ham_Weapon_Reload, weapon_data_structs_array[LENA_WEAPON_CLASSID][wpn_struct_weapon_name], "fw_Weapon_Reload_Post", 1,true)
	
	
	register_entity_as_wall_touchable(LENA_PROJECTILE_CLASSNAME,"FwdTouchWorld")
	register_custom_touchable(LENA_PROJECTILE_CLASSNAME,"bulletina_touque_playor",player_vector,1)

	register_think(LENA_PROJECTILE_CLASSNAME, "bulette_thinque")
	init_explosion_defaults()
	init_gravity_pcvar()

	weapon_secret_code = allocate_weapon_secret_code()

}
public plugin_cfg(){

	gHeroID = lena_get_hero_id()
	custom_dmg_id_l96=sh_log_custom_damage_source(gHeroID,dmg_source_name_short_l96,dmg_source_name_log_l96,0)

}
public bulette_thinque(ent){


	if ( pev_valid(ent)!=2 ) return
	
	new owner=entity_get_edict(ent, EV_ENT_owner)

	if(!is_user_alive(owner)){

		my_remove_entity(ent)	
		return
	}


	new parm[2]
	parm[0] = ent
	parm[1] = owner
	new Float:current_bullet_reverb_time=entity_get_float(ent,EV_FL_fuser1)
	if(!entity_get_int(ent,EV_INT_iuser1)){
		
		if(current_bullet_reverb_time>0.0){
			entity_set_float(ent,EV_FL_fuser1,current_bullet_reverb_time-LENA_PROJECTILE_PHYS_UPDATE_TIME)
		}
		else{
			entity_set_int(ent,EV_INT_iuser1,1)
			entity_set_float(ent,EV_FL_fuser1,0.0)
			emit_sound(owner, CHAN_WEAPON, LENA_L96_SHOTSOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

		}
	}
	
	orient_entity_with_move_vector(ent)

	projectile_air_drag_update_speed(parm,LENA_PROJECTILE_DRAG_CONST,LENA_PROJECTILE_GRAVITY_MULT,LENA_PROJECTILE_PHYS_UPDATE_TIME)
	

	entity_set_float( ent, EV_FL_nextthink, floatadd(get_gametime( ) ,LENA_PROJECTILE_PHYS_UPDATE_TIME));


}
public CmdStart(id, uc_handle)
{

	
	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if(!client_is_hero_user(id, gHeroID)){
		
		return FMRES_IGNORED
	}
	
	Assign_BitVar(trigger_was_down_mask, id,Get_BitVar(trigger_is_down_mask, id))

	new button = get_uc(uc_handle, UC_Buttons);
	
	
	Assign_BitVar(trigger_is_down_mask, id,(button & IN_ATTACK))


	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	if((weapon==LENA_WEAPON_CLASSID)){
		if(Get_BitVar(trigger_is_down_mask, id))
		{

			button &= ~IN_ATTACK;
			if(Get_BitVar(trigger_was_down_mask, id)||(lena_l96_get_num_bullets(id)<=0)){
				set_uc(uc_handle, UC_Buttons, button);
				return FMRES_SUPERCEDE
			}
			
		}
	}
	return FMRES_IGNORED;
}

public Ham_TraceAttackLenaL96(id, idattacker, Float:damage, Float:direction[3], ptr, damagebits)
{
	if(damage<=0.0){
		return HAM_IGNORED
	}
	
	if(!is_user_connected(idattacker)){
		return HAM_IGNORED	
	}
	if(get_user_weapon(idattacker) != LENA_WEAPON_CLASSID|| !sh_get_user_has_hero(idattacker,gHeroID)){
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
	static bpammo; bpammo = cs_get_user_bpammo(id, LENA_WEAPON_CLASSID)
	
	static iClip; iClip = get_pdata_int(ent, m_iClip, XO_WEAPON)
	static fInReload; fInReload = get_pdata_int(ent, m_fInReload, XO_WEAPON)
	
	if(fInReload && flNextAttack <= 0.0)
	{
		static temp1
		temp1 = min(LENA_L96_CLIP_SIZE - iClip, bpammo)

		set_pdata_int(ent, m_iClip, iClip + temp1, XO_WEAPON)
		cs_set_user_bpammo(id, LENA_WEAPON_CLASSID, bpammo - temp1)		
		
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
	g_L96_clip[pPlayer] = -1
	static BPAmmo; BPAmmo = cs_get_user_bpammo(pPlayer, LENA_WEAPON_CLASSID)
	static iClip; iClip = get_pdata_int(entity, m_iClip, XO_WEAPON)
	
	if(BPAmmo <= 0){
		return HAM_SUPERCEDE
	}
	if(iClip >= LENA_L96_CLIP_SIZE){
		return HAM_SUPERCEDE		
	}
	g_L96_clip[pPlayer] = iClip		
	return HAM_IGNORED
}
public fw_Weapon_Reload_Post(ent)
{
	if(pev_valid(ent)!=2)
		return HAM_IGNORED
		
	static id; id = get_pdata_cbase(ent, m_pPlayer,XO_WEAPON)
	if(!client_is_hero_user(id, gHeroID)){
		
		return HAM_IGNORED
	}

	if(g_L96_clip[id] == -1)
		return HAM_IGNORED

	
	set_pdata_int(ent, m_iClip, g_L96_clip[id] , XO_WEAPON)
	set_pdata_int(ent, m_fInReload, 1, XO_WEAPON);
	
	return HAM_IGNORED
}

public fw_ItemDeployPre(entity)
{
	if(pev_valid(entity)!=2)
		return HAM_IGNORED
		
	static pPlayer; pPlayer = get_pdata_cbase(entity, m_pPlayer,XO_WEAPON)
	
	if(!client_is_hero_user(pPlayer, gHeroID)){
		
		remove_weapon_secret_code(entity,weapon_secret_code)
		
		return HAM_IGNORED
	}
	ExecuteHam(Ham_Item_Deploy, entity)
	set_pdata_float(pPlayer, m_flNextAttack, LENA_PROJECTILE_DEPLOY_TIME ,OFFSET_LINUX_PLAYER)
	set_pdata_float(entity, m_flTimeWeaponIdle, LENA_PROJECTILE_DEPLOY_TIME ,XO_WEAPON)
	set_pdata_int(entity, m_iClip ,min(LENA_L96_CLIP_SIZE,get_pdata_int(entity, m_iClip, XO_WEAPON)), XO_WEAPON)
	set_weapon_secret_code(entity,weapon_secret_code)
	return HAM_SUPERCEDE
}

public fw_WeaponPrimaryAttackPre(entity)
{
	
	if(pev_valid(entity)!=2)
		return HAM_IGNORED
		
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
	launch_bullet(pPlayer)
	g_L96_clip[pPlayer]=get_pdata_int(entity, m_iClip, XO_WEAPON)
	set_pdata_float(entity, m_flNextPrimaryAttack, LENA_PROJECTILE_SHOOT_PERIOD ,XO_WEAPON)
	set_pdata_float(entity, m_flTimeWeaponIdle, LENA_PROJECTILE_SHOOT_PERIOD ,XO_WEAPON)
	
	entity_get_vector(pPlayer, EV_VEC_punchangle, g_Recoil[pPlayer])
	native_playanim(pPlayer, SEQ_SHOOT1)
	
	unregister_forward(FM_PlaybackEvent, iPlaybackEvent)
	return HAM_SUPERCEDE
}

public fw_Weapon_PrimaryAttack_Post(Ent)
{
	
	if(pev_valid(Ent)!=2)
		return
		
	static id; id = get_pdata_cbase(Ent, m_pPlayer,XO_WEAPON)
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
	
	multiply_3d_vector_by_scalar(Push, LENA_L96_RECOIL, Push)
	add_3d_vectors(Push, g_Recoil[id], Push)
	entity_set_vector(id, EV_VEC_punchangle, Push)
}
launch_bullet(id)
{

if(!client_is_hero_user(id, gHeroID)){
		
	return
}

new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

entity_get_vector(id, EV_VEC_origin , Origin)
entity_get_vector(id, EV_VEC_v_angle, vAngle)


Ent = my_create_entity("info_target")

if (!Ent){
	return
}
entity_set_string(Ent, EV_SZ_classname, LENA_PROJECTILE_CLASSNAME)
entity_set_model(Ent, "models/grenade.mdl")

new Float:MinBox[3] = {-1.0, -1.0, -1.0}
new Float:MaxBox[3] = {1.0, 1.0, 1.0}
entity_set_vector(Ent, EV_VEC_mins, MinBox)
entity_set_vector(Ent, EV_VEC_maxs, MaxBox)

entity_set_origin(Ent, Origin)
entity_set_vector(Ent, EV_VEC_angles, vAngle)

entity_set_int(Ent, EV_INT_effects, 2)
entity_set_int(Ent, EV_INT_solid, SOLID_BBOX)
entity_set_int(Ent, EV_INT_movetype, MOVETYPE_TOSS)
entity_set_float(Ent,EV_FL_gravity, LENA_PROJECTILE_GRAVITY_MULT*0.5)
entity_set_edict(Ent, EV_ENT_owner, id)

velocity_by_aim(id, floatround(LENA_PROJECTILE_SPEED) , Velocity)
new Float:coeff_to_multiply_with
new resume_zoom=get_pdata_bool(id,m_bResumeZoom,OFFSET_LINUX_PLAYER*4)
if(!(resume_zoom)){
	coeff_to_multiply_with=LENA_PROJECTILE_SHOOT_RANDOMNESS;
}
else{
	
	new Float:user_movement_velocity[3]
	entity_get_vector(id,EV_VEC_velocity,user_movement_velocity)
	new Float:user_maxspeed=get_user_maxspeed(id);
	new Float:user_current_speed=vector_length(user_movement_velocity)
	new Float:coeff_to_multiply_with_extra=(user_current_speed/user_maxspeed)
	coeff_to_multiply_with=coeff_to_multiply_with_extra*LENA_PROJECTILE_SHOOT_RANDOMNESS
	
}
randomize_vector_with_coeff(coeff_to_multiply_with,Velocity)

entity_set_vector(Ent, EV_VEC_velocity ,Velocity)
lena_l96_dec_num_bullets(id)
sh_chat_message(id, gHeroID,"%d l96 bullets left",lena_l96_get_num_bullets(id))

//bullet launch pos
entity_set_vector(Ent,EV_VEC_vuser1,Origin)

entity_set_float(Ent,EV_FL_fuser1,LENA_REVERB_SHOT_DELAY)
entity_set_int(Ent,EV_INT_iuser1,0)
new parm2[1]

parm2[0]= id
emit_sound(id, CHAN_WEAPON, LENA_L96_SHOTSOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
create_fired_shot_disk(Origin,id,true)

trail(Ent,ORANGE,6,4,200)


entity_set_float( Ent, EV_FL_nextthink, floatadd(get_gametime( ) ,LENA_PROJECTILE_PHYS_UPDATE_TIME));

}

public fm_UpdateClientDataPost(player, sendWeapons, cd)
{
	if(!client_is_hero_user(player, gHeroID)){
		
		return FMRES_IGNORED
	}
	if((get_user_weapon(player) != LENA_WEAPON_CLASSID)){
		return FMRES_IGNORED
	}
	new pEntity = get_pdata_cbase(player, m_pActiveItem,OFFSET_LINUX_PLAYER)
	if(pev_valid(pEntity)==PDATA_SAFE){
		set_cd(cd, CD_flNextAttack, get_gametime()+1.0)
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}
public FwdTouchWorld( bull_et, World ) {

	if(!is_valid_ent(bull_et)) return

	static Float:origin[3]
	entity_get_vector(bull_et,EV_VEC_origin,origin);

	emit_sound(bull_et, CHAN_WEAPON, LENA_L96_WALLHIT_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	make_sparks(origin);
	gun_shot_decal(origin);

	tank_impact_shot_fx(bull_et,origin,17)
	
	if(!is_valid_ent(World)){
		
		my_remove_entity(bull_et)
		return
	}
	
	static szClassname[32]
	entity_get_string(World,EV_SZ_classname,szClassname, charsmax(szClassname))
	if(equal(szClassname,"func_breakable")){
		static Float:bullet_launch_pos[3]
				
		entity_get_vector(bull_et,EV_VEC_vuser1,bullet_launch_pos)

		new Float:damage = calculate_nuanced_projectile_damage(bull_et,
							bullet_launch_pos,
							LENA_PROJECTILE_DAMAGE,
							LENA_PROJECTILE_DAMAGE_FALLOFF_DIST,
							LENA_PROJECTILE_SPEED)

		new owner=entity_get_edict(bull_et,EV_ENT_owner)
		ExecuteHam(Ham_TakeDamage, World, bull_et, owner, damage, 0);

	} 
	my_remove_entity(bull_et)
}
public bulletina_touque_playor(pToucher, pTouched)
{
	if(!is_valid_ent(pToucher)) return

	static Float:bullet_launch_pos[3],
		Float:origin[3],
		Float:velocity[3],
		Float:speed,
		Float:damage,
		Float:falloff_coeff,
		Float:distance,
		my_hitpoint_enum:the_hitpoint,
		bool:headshot=false,
		owner


	
	entity_get_vector(pToucher,EV_VEC_origin,origin);
				
	entity_get_vector(pToucher,EV_VEC_vuser1,bullet_launch_pos)

	entity_get_vector(pToucher,EV_VEC_velocity,velocity)

	speed=floatmax(1.0,vector_length(velocity))

	damage = calculate_nuanced_projectile_damage(pToucher,
						bullet_launch_pos,
						LENA_PROJECTILE_DAMAGE,
						LENA_PROJECTILE_DAMAGE_FALLOFF_DIST,
						LENA_PROJECTILE_SPEED,
						distance,
						falloff_coeff)

	owner=entity_get_edict(pToucher,EV_ENT_owner)
	the_hitpoint= get_projectile_hit_hitpoint(pToucher,
										velocity,
										LENA_PROJECTILE_HEADSHOT_THRESHOLD_DIST*3.0,
										speed)
	if(the_hitpoint==MY_HIT_HEAD){
		
		headshot=true;
		damage*=float(cvar_val(num, pcvar_dmg_headshot_mult));
	}
	new Float:the_period=(headshot?0.33:1.0);
	new Float:the_time=(headshot?float(cvar_val(num, pcvar_dmg_headshot_mult)):the_period)*10.0;
	new CsTeams:att_team=cs_get_user_team(owner)
	new CsTeams:vic_team=cs_get_user_team(pTouched)
	if(att_team!=vic_team){
		sh_extra_damage(pTouched,owner,floatround(damage),
			the_hitpoint,
			_,_,_,
			DMG_BULLET,
			SH_NEW_DMG_SUPER_BULLET,
			custom_dmg_id_l96);

		sh_screen_shake(pTouched,14.5,the_time/3.0,20.0)

		sh_set_stun(pTouched,the_time/3.0,default_stun_speed)
		unfade_screen_user(pTouched)
		set_velocity_from_origin(pTouched,origin,LENA_PROJECTILE_KNOCKBACK-(35.0*falloff_coeff))
		if(gatling_get_fx_num(pTouched)!=RADIOACTIVE){
				track_user(pTouched,owner,1,0.07,the_period,the_time,ORANGE)
		}
		
		sh_set_user_xp(owner,floatround(distance)*(headshot?
				cvar_val(num, pcvar_dmg_headshot_mult):1)*
				cvar_val(num, pcvar_xp_distance_mult),true);
		new random_number=generate_int(0,(sizeof lena_poems)-1)
		
		if(!is_user_bot(pTouched)){
			send_poem_function(pTouched, lena_poems[random_number]);
		}
		
		if(!is_user_alive(pTouched)){

			gross_kill_gibs_fx(pTouched,origin,origin)

		}
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
	tank_impact_shot_fx(pToucher,origin,9)


	my_remove_entity(pToucher)
	
}
public plugin_precache()
{

engfunc(EngFunc_PrecacheModel,"models/grenade.mdl")
engfunc(EngFunc_PrecacheSound, LENA_L96_SHOTSOUND)
engfunc(EngFunc_PrecacheSound, LENA_L96_WALLHIT_SOUND)

}
public fm_PlaybackEventPre() return FMRES_SUPERCEDE