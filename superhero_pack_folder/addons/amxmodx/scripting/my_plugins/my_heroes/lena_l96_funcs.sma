#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "lena_inc/sh_lena_l96_include.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "lena_inc/sh_lena_general_include.inc"
#include "../my_include/my_author_header.inc"

#include <fakemeta_util>
#include <reapi>
#include "../my_include/weapons_const.inc"

#define PLUGIN_VER "1.0"
#define PLUGIN_NAME "SUPERHERO Lena de Verias: L96 weapon_thingie"


new bool:bullet_loaded[SH_MAXSLOTS+1]
new Float:g_Recoil[SH_MAXSLOTS+1][3]
new Float:bullet_launch_pos[MAX_ENTITIES][3];
new g_L96_clip[SH_MAXSLOTS+1]
new dmg_headshot_mult,
	xp_distance_mult;

new dmg_source_name_short_l96[SAFE_BUFFER_SIZE+1]="L96A1"
new dmg_source_name_long_l96[SAFE_BUFFER_SIZE+1]="Lena_s_L96A1"
new custom_dmg_id_l96


stock LENA_PROJECTILE_RELOAD_TASKID,
		LENA_HIT_STAGGER_TASKID

//new HamHook:TakeDamage
public plugin_init(){
	
	
	register_cvar("lena_xp_distance_mult","4")
	register_cvar("lena_dmg_headshot_mult","5")

	register_plugin(PLUGIN_NAME, PLUGIN_VER, AUTHOR);
	for(new i=0;i<MAX_ENTITIES;i++){
		
		arrayset(bullet_launch_pos[i],0.0,3);
		
	}
	arrayset(bullet_loaded,true,SH_MAXSLOTS+1)
	register_forward(FM_CmdStart, "CmdStart");
	RegisterHam(Ham_Item_Deploy, LENA_WEAPON, "fw_ItemDeployPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, LENA_WEAPON, "fw_WeaponPrimaryAttackPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, LENA_WEAPON, "fw_Weapon_PrimaryAttack_Post", 1,true)	
	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)
	RegisterHam(Ham_Item_PostFrame, LENA_WEAPON, "fw_Item_PostFrame",_,true)	
	
	
	RegisterHam(Ham_TraceAttack, "player", "Ham_TraceAttackLenaL96",_,true)
	console_print(0,"Ham error value: %d^n",IsHamValid(Ham_TakeDamage))
	
	RegisterHam(Ham_Weapon_Reload,LENA_WEAPON, "fw_WeaponReloadPre",_,true)
	RegisterHam(Ham_Weapon_Reload, LENA_WEAPON, "fw_Weapon_Reload_Post", 1,true)
	custom_dmg_id_l96=sh_log_custom_damage_source(lena_get_hero_id(),dmg_source_name_short_l96,dmg_source_name_long_l96,0)
	LENA_PROJECTILE_RELOAD_TASKID=allocate_typed_task_id(player_task)
	LENA_HIT_STAGGER_TASKID=allocate_typed_task_id(player_task)

	register_forward(FM_Think, "bulette_thinque")
	init_explosion_defaults()
	init_gravity_pcvar()


}

public bulette_thinque(ent){


	if ( !pev_valid(ent) ) return FMRES_IGNORED
	
	static classname[32]
	classname[0] = '^0'
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, LENA_PROJECTILE_CLASSNAME) ) return FMRES_IGNORED
	new owner=entity_get_edict(ent, EV_ENT_owner)

	if(!client_hittable(owner)){

		remove_bullet(ent)	
		return FMRES_IGNORED
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
			emit_sound(owner, CHAN_WEAPON, NULL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			emit_sound(owner, CHAN_WEAPON, LENA_L96_SHOTSOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

		}
	}
	projectile_air_drag_update_speed(parm,LENA_PROJECTILE_DRAG_CONST,LENA_PROJECTILE_GRAVITY_MULT,LENA_PROJECTILE_PHYS_UPDATE_TIME)
	

	entity_set_float( ent, EV_FL_nextthink, floatadd(get_gametime( ) ,LENA_PROJECTILE_PHYS_UPDATE_TIME));

	return FMRES_IGNORED


}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	xp_distance_mult=get_cvar_num("lena_xp_distance_mult");
	dmg_headshot_mult=get_cvar_num("lena_dmg_headshot_mult");


}//----------------------------------------------------------------------------------------------
public plugin_natives(){
	
	register_native( "lena_l96_clear_bullets","_lena_l96_clear_bullets",0)
	
	
}
public bool:client_isnt_hitter(id){
	
	return !client_hittable(id,sh_user_has_hero(id,lena_get_hero_id()))
	
}
public CmdStart(id, uc_handle)
{
	if(client_isnt_hitter(id)){
		
		return FMRES_IGNORED
	}
	if(sh_get_user_is_asleep(id)) return FMRES_IGNORED
	
	new button = get_uc(uc_handle, UC_Buttons);
	
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	if((weapon==LENA_WEAPON_CLASSID)){
		if(button & IN_ATTACK)
		{
			if(!bullet_loaded[id]||(lena_l96_get_num_bullets(id)<=0)){
				button &= ~IN_ATTACK;
				set_uc(uc_handle, UC_Buttons, button);
				return FMRES_SUPERCEDE
			}
			
		}
	}
	return FMRES_IGNORED;
}

public Ham_TraceAttackLenaL96(id, idattacker, Float:damage, Float:direction[3], ptr, damagebits)
{
	
	if(!is_user_connected(idattacker)){
		return HAM_IGNORED	
	}
	if(get_user_weapon(idattacker) != LENA_WEAPON_CLASSID|| !sh_user_has_hero(idattacker,lena_get_hero_id())){
		return HAM_IGNORED
	}
		
		
	
	damage=0.0;
	return HAM_SUPERCEDE
	
}
public fw_Item_PostFrame(ent)
{
	if(pev_valid(ent) != 2){
		return HAM_IGNORED
	}
	static id; id = pev(ent, pev_owner)
	if(client_isnt_hitter(id)){
		
		return HAM_IGNORED
	}
	static Float:flNextAttack; flNextAttack = get_pdata_float(id, 83, 5)
	static bpammo; bpammo = cs_get_user_bpammo(id, LENA_WEAPON_CLASSID)
	
	static iClip; iClip = get_pdata_int(ent, 51, 4)
	static fInReload; fInReload = get_pdata_int(ent, 54, 4)
	
	if(fInReload && flNextAttack <= 0.0)
	{
		static temp1
		temp1 = min(CLIP_SIZE - iClip, bpammo)

		set_pdata_int(ent, 51, iClip + temp1, 4)
		cs_set_user_bpammo(id, LENA_WEAPON_CLASSID, bpammo - temp1)		
		
		set_pdata_int(ent, 54, 0, 4)
		
		fInReload = 0
	}		
	
	return HAM_IGNORED
}

public fw_WeaponReloadPre(entity)
{
	if(pev_valid(entity)!=2)
		return HAM_IGNORED
	new pPlayer = get_member(entity, m_pPlayer)
	
	if(client_isnt_hitter(pPlayer)){
		
		return HAM_IGNORED
	}
	g_L96_clip[pPlayer] = -1
	static BPAmmo; BPAmmo = cs_get_user_bpammo(pPlayer, LENA_WEAPON_CLASSID)
	static iClip; iClip = get_pdata_int(entity, 51, 4)
	
	if(BPAmmo <= 0){
		return HAM_SUPERCEDE
	}
	if(iClip >= CLIP_SIZE){
		return HAM_SUPERCEDE		
	}
	g_L96_clip[pPlayer] = iClip		
	return HAM_HANDLED
}
public fw_Weapon_Reload_Post(ent)
{
	if(pev_valid(ent)!=2)
		return HAM_IGNORED
		
	static id; id = pev(ent, pev_owner)
	if(client_isnt_hitter(id)){
		
		return HAM_IGNORED
	}
	if((get_pdata_int(ent, 54, 4) == 1))
	{ 
	
		if(g_L96_clip[id] == -1)
			return HAM_IGNORED
		
		set_pdata_int(ent, 51, g_L96_clip[id], 4)
	}
	
	
	return HAM_HANDLED
}

public fw_ItemDeployPre(entity)
{
	if(pev_valid(entity)!=2)
		return HAM_IGNORED
		
	new pPlayer = get_member(entity, m_pPlayer)
	
	if(client_isnt_hitter(pPlayer)){
		
		return HAM_IGNORED
	}
	ExecuteHam(Ham_Item_Deploy, entity)
	set_member(pPlayer, m_flNextAttack, LENA_PROJECTILE_DEPLOY_TIME)
	set_member(entity, m_Weapon_flTimeWeaponIdle, LENA_PROJECTILE_DEPLOY_TIME)
	set_pdata_int(entity, 51,min(CLIP_SIZE,get_pdata_int(entity, 51, 4)), 4)
	return HAM_SUPERCEDE
}

public fw_WeaponPrimaryAttackPre(entity)
{
	
	if(pev_valid(entity)!=2)
		return HAM_IGNORED
		
	new pPlayer = get_member(entity, m_pPlayer)
	if(client_isnt_hitter(pPlayer)||!hasRoundStarted()){
		
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
	launch_bullet(pPlayer)
	bullet_loaded[pPlayer]=false;
	g_L96_clip[pPlayer]=get_pdata_int(entity, 51, 4)
	set_member(entity, m_Weapon_flTimeWeaponIdle, LENA_PROJECTILE_SHOOT_PERIOD)
	set_member(entity, m_Weapon_flNextPrimaryAttack, LENA_PROJECTILE_SHOOT_PERIOD)
	
	pev(pPlayer, pev_punchangle, g_Recoil[pPlayer])
	set_entvar(pPlayer, var_weaponanim,  SEQ_SHOOT1)
	
	unregister_forward(FM_PlaybackEvent, iPlaybackEvent)
	return HAM_SUPERCEDE
}

public fw_Weapon_PrimaryAttack_Post(Ent)
{
	
	if(pev_valid(Ent)!=2)
		return
		
	static id; id = pev(Ent, pev_owner)
	if(client_isnt_hitter(id)){
		
		return
	}
	static Float:Push[3]
	pev(id, pev_punchangle, Push)
	xs_vec_sub(Push, g_Recoil[id], Push)
	
	xs_vec_mul_scalar(Push, RECOIL, Push)
	xs_vec_add(Push, g_Recoil[id], Push)
	set_pev(id, pev_punchangle, Push)
}
stock randomize_vector_with_coeff(Float:coeff,Float:vec_to_randomize[3]){
	
	
	new Float:normal_speed[3];
	new Float:norm_speed_random[3];
	new Float:speed=VecLength(vec_to_randomize)
	new Float:norm_random_speed;
	multiply_3d_vector_by_scalar(vec_to_randomize,1.0/speed,normal_speed);
	norm_speed_random[0]=normal_speed[0]+floatclamp(random_float(-coeff,coeff),0.0,1.0);
	norm_speed_random[1]=normal_speed[1]+floatclamp(random_float(-coeff,coeff),0.0,1.0);
	norm_speed_random[2]=normal_speed[2]+floatclamp(random_float(-coeff,coeff),0.0,1.0);
	norm_random_speed=VecLength(norm_speed_random);
	multiply_3d_vector_by_scalar(norm_speed_random,speed/norm_random_speed,norm_speed_random);
	multiply_3d_vector_by_scalar(norm_speed_random,1.0,vec_to_randomize);
	
}
launch_bullet(id)
{

if(client_isnt_hitter(id)){
		
	return
}
entity_set_int(id, EV_INT_weaponanim, 3)

new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

entity_get_vector(id, EV_VEC_origin , Origin)
entity_get_vector(id, EV_VEC_v_angle, vAngle)


Ent = create_entity("info_target")

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
entity_set_int(Ent, EV_INT_solid, 2)
entity_set_int(Ent, EV_INT_movetype, MOVETYPE_TOSS)
entity_set_float(Ent,EV_FL_gravity, LENA_PROJECTILE_GRAVITY_MULT*0.5)
entity_set_edict(Ent, EV_ENT_owner, id)

VelocityByAim(id, floatround(LENA_PROJECTILE_SPEED) , Velocity)
new Float:coeff_to_multiply_with
new resume_zoom=get_member(id,m_bResumeZoom);
if(!(resume_zoom)){
	coeff_to_multiply_with=LENA_PROJECTILE_SHOOT_RANDOMNESS;
}
else{
	
	new Float:user_movement_velocity[3]
	entity_get_vector(id,EV_VEC_velocity,user_movement_velocity)
	new Float:user_maxspeed=get_user_maxspeed(id);
	new Float:user_current_speed=VecLength(user_movement_velocity)
	new Float:coeff_to_multiply_with_extra=(user_current_speed/user_maxspeed)
	coeff_to_multiply_with=coeff_to_multiply_with_extra*LENA_PROJECTILE_SHOOT_RANDOMNESS
	
}
randomize_vector_with_coeff(coeff_to_multiply_with,Velocity)

entity_set_vector(Ent, EV_VEC_velocity ,Velocity)
lena_l96_dec_num_bullets(id)
sh_chat_message(id, lena_get_hero_id(),"%d l96 bullets left",lena_l96_get_num_bullets(id))

bullet_launch_pos[Ent][0]=Origin[0]
bullet_launch_pos[Ent][1]=Origin[1]
bullet_launch_pos[Ent][2]=Origin[2]

entity_set_float(Ent,EV_FL_fuser1,LENA_REVERB_SHOT_DELAY)
entity_set_int(Ent,EV_INT_iuser1,0)
new parm2[1]

parm2[0]= id
emit_sound(id, CHAN_WEAPON, LENA_L96_SHOTSOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
create_fired_shot_disk(bullet_launch_pos[Ent],id,true)

trail(Ent,ORANGE,6,13,200)

set_task(LENA_PROJECTILE_SHOOT_PERIOD, "bullet_reload",id+LENA_PROJECTILE_RELOAD_TASKID,parm2,1,"a",1)

entity_set_float( Ent, EV_FL_nextthink, floatadd(get_gametime( ) ,LENA_PROJECTILE_PHYS_UPDATE_TIME));

}

public bullet_reload(parm[],id)
{
id-=LENA_PROJECTILE_RELOAD_TASKID

bullet_loaded[parm[0]] = true
}


public _lena_l96_clear_bullets(iPlugin,iParams){

new grenada = find_ent_by_class(-1, LENA_PROJECTILE_CLASSNAME)
while(grenada) {
	remove_bullet(grenada)
	arrayset(bullet_launch_pos[grenada],0.0,3);
	grenada = find_ent_by_class(grenada, LENA_PROJECTILE_CLASSNAME)
}
}

public fm_UpdateClientDataPost(player, sendWeapons, cd)
{
	if(client_isnt_hitter(player)){
		
		return
	}
	if((get_user_weapon(player) != LENA_WEAPON_CLASSID)){
		return
	}
	new pEntity = get_member(player, m_pActiveItem)
	if(is_valid_ent(pEntity)){
		set_cd(cd, CD_flNextAttack, 99999.0)
	}
}


public vexd_pfntouch(pToucher, pTouched)
{

	if (pev_valid(pToucher)!=2){
		
		return
	}

	new szClassName[32]
	entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)
	if(equal(szClassName, LENA_PROJECTILE_CLASSNAME))
	{
		new oid = entity_get_edict(pToucher, EV_ENT_owner)
		new Float:origin[3]
		entity_get_vector(pToucher,EV_VEC_origin,origin);
		if((pev(pTouched,pev_solid)==SOLID_SLIDEBOX)){
			if(client_hittable(pTouched))
			{
				new Float:vic_origin[3]
				entity_get_vector(pToucher,EV_VEC_origin,vic_origin);
				
				new Float:speed
				new Float:velocity[3]
				
				
				entity_get_vector(pToucher,EV_VEC_velocity,velocity);
				speed=VecLength(velocity);
				new Float:speed_coeff=(speed/LENA_PROJECTILE_SPEED)
				new Float:vic_origin_eyes[3];
				new vic_origin_eyes_int[3];
				entity_get_vector(pTouched,EV_VEC_origin,vic_origin);
				get_user_origin(pTouched,vic_origin_eyes_int,1);
				IVecFVec(vic_origin_eyes_int,vic_origin_eyes);
				new Float:distance=vector_distance(vic_origin,bullet_launch_pos[pToucher]);
				new Float:head_distance=vector_distance(vic_origin_eyes,origin);
				new Float:falloff_coeff= floatmin(1.0,distance/LENA_PROJECTILE_DAMAGE_FALLOFF_DIST);
				new Float:normal_damage=LENA_PROJECTILE_DAMAGE-(35.0*falloff_coeff);
				new Float:damage=normal_damage*speed_coeff;
				new headshot=0;
				if(head_distance<LENA_PROJECTILE_HEADSHOT_THRESHOLD_DIST){
					
					headshot=1;
					damage*=dmg_headshot_mult;
				}
				new Float:the_period=(headshot?0.33:1.0);
				new Float:the_time=(headshot?float(dmg_headshot_mult):the_period)*10.0;
				new CsTeams:att_team=cs_get_user_team(oid)
				new CsTeams:vic_team=cs_get_user_team(pTouched)
				if(att_team!=vic_team){
					new health = get_user_health(pTouched)
					sh_extra_damage(pTouched,oid,floatround(damage),dmg_source_name_long_l96, headshot,_,_,_,_,DMG_BULLET,_,custom_dmg_id_l96);
					sh_screen_shake(pTouched,14.5,the_time/3.0,20.0)

					sh_set_stun(pTouched,the_time/3.0,default_stun_speed)
					fade_screen_user(pTouched)
					set_task(0.5,"unfade_screen_user_task",pTouched+LENA_HIT_STAGGER_TASKID)
					set_velocity_from_origin(pTouched,origin,LENA_PROJECTILE_KNOCKBACK*(35.0*falloff_coeff))
					if(gatling_get_fx_num(pTouched)!=_:RADIOACTIVE){
							track_user(pTouched,oid,0,_,the_period,the_time,ORANGE)
					}
					
					sh_set_user_xp(oid,floatround(distance)*(headshot?dmg_headshot_mult:1)*xp_distance_mult,true);
					new random_number=random_num(0,(sizeof lena_poems)-1)
					
					if(!is_user_bot(pTouched)){
						send_poem_function(pTouched, lena_poems[random_number]);
					}
					if(floatround(damage)>=health){

						gross_kill_gibs_fx(pTouched,vic_origin,origin)

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
				
			}
		}
		if(pev(pTouched,pev_solid)==SOLID_BSP){
		
			emit_sound(pToucher, CHAN_WEAPON, LENA_L96_WALLHIT_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			make_sparks(origin);
			gun_shot_decal(origin);

		}

		tank_impact_shot_fx(pToucher,origin,17)

		
		remove_bullet(pToucher)	

		arrayset(bullet_launch_pos[pToucher],0.0,3);
	}
}
public unfade_screen_user_task(id){
	id-=LENA_HIT_STAGGER_TASKID
	if(is_user_connected(id)){
		
		unfade_screen_user(id)

	}

}

public remove_bullet(id_bullet){
	if(is_valid_ent(id_bullet)){
		remove_entity(id_bullet)
	}


}
public plugin_precache()
{

precache_model("models/grenade.mdl")
engfunc(EngFunc_PrecacheSound, LENA_L96_SHOTSOUND)
engfunc(EngFunc_PrecacheSound, LENA_L96_WALLHIT_SOUND)

}
public fm_PlaybackEventPre() return FMRES_SUPERCEDE