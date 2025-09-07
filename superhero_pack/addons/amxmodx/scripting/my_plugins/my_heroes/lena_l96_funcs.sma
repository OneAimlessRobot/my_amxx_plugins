#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "lena_inc/sh_lena_l96_include.inc"
#include "lena_inc/sh_lena_general_include.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include <fakemeta_util>
#include <reapi>
#include "../my_include/weapons_const.inc"

#define PLUGIN_AUTHOR "MilkChanTheGOAT"
#define PLUGIN_VER "1.0"
#define PLUGIN_NAME "SUPERHERO Lena de Verias: L96 weapon_thingie"


new bool:bullet_loaded[SH_MAXSLOTS+1]
new Float:g_Recoil[SH_MAXSLOTS+1][3]
new Float:bullet_launch_pos[MAX_ENTITIES][3];
new g_L96_clip[SH_MAXSLOTS+1]
new g_L96_zoom[SH_MAXSLOTS+1]
public plugin_init(){
	
	
	register_plugin(PLUGIN_NAME, PLUGIN_VER, PLUGIN_AUTHOR);
	for(new i=0;i<MAX_ENTITIES;i++){
		
		arrayset(bullet_launch_pos[i],0.0,3);
		
	}
	arrayset(bullet_loaded,true,SH_MAXSLOTS+1)
	register_forward(FM_CmdStart, "CmdStart");
	RegisterHam(Ham_Item_Deploy, LENA_WEAPON, "fw_ItemDeployPre")
	RegisterHam(Ham_Weapon_PrimaryAttack, LENA_WEAPON, "fw_WeaponPrimaryAttackPre")
	RegisterHam(Ham_Weapon_PrimaryAttack, LENA_WEAPON, "fw_Weapon_PrimaryAttack_Post", 1)	
	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack_Player")	
	RegisterHam(Ham_Item_PostFrame, LENA_WEAPON, "fw_Item_PostFrame")	
	
	RegisterHam(Ham_Weapon_Reload,LENA_WEAPON, "fw_WeaponReloadPre")
	RegisterHam(Ham_Weapon_Reload, LENA_WEAPON, "fw_Weapon_Reload_Post", 1)	
	
}

public plugin_natives(){
	
	register_native( "lena_l96_clear_bullets","_lena_l96_clear_bullets",0)
	register_native( "lena_l96_get_user_zoom","_lena_l96_get_user_zoom",0)
	register_native( "lena_l96_remove_user_zoom","_lena_l96_remove_user_zoom",0)
	register_native( "lena_l96_reset_user_zoom","_lena_l96_reset_user_zoom",0)
	register_native( "lena_l96_set_user_zoom","_lena_l96_set_user_zoom",0)
	register_native( "lena_l96_get_user_zoom","_lena_l96_get_user_zoom",0)
	
	
}

public CmdStart(id, uc_handle)
{
	if ( !is_user_alive(id)||client_isnt_hitter(id)) return FMRES_IGNORED;
	
	
	new button = get_uc(uc_handle, UC_Buttons);
	new old_buttons= pev( id, pev_oldbuttons )
	
	//new flags= entity_get_int( id, EV_INT_flags ) 
	//& FL_ONGROUND 
	
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	if((weapon==LENA_WEAPON_CLASSID)){
		
		if((button & IN_ATTACK2)&&!(old_buttons&IN_ATTACK2))
		{
			new zoom=g_L96_zoom[id]
			switch(zoom){
				
				
				case LENA_NO_ZOOM:{
					g_L96_zoom[id]=LENA_FIRST_ZOOM
					
				}
				case LENA_FIRST_ZOOM:{
					g_L96_zoom[id]=LENA_SECOND_ZOOM
					
					
				}
				case LENA_SECOND_ZOOM:{
					
					g_L96_zoom[id]=LENA_MAX_ZOOM
					
				}
				case LENA_MAX_ZOOM:{
					
					g_L96_zoom[id]=LENA_NO_ZOOM
					
				}
				
			}
		}
		if(button & IN_ATTACK)
		{
			if(!bullet_loaded[id]||!(g_L96_zoom[id])){
				button &= ~IN_ATTACK;
				set_uc(uc_handle, UC_Buttons, button);
				emit_sound(id, CHAN_WEAPON, LENA_L96_SHOTSOUND, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
				emit_sound(id, CHAN_WEAPON, NULL_SOUND_FILENAME, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				return FMRES_SUPERCEDE
			}
			
		}
	}
	return FMRES_IGNORED;
}

client_isnt_hitter(gatling_user){


return (!lena_get_has_lena(gatling_user)||!is_user_connected(gatling_user)||!is_user_alive(gatling_user)||gatling_user <= 0 || gatling_user > SH_MAXSLOTS)

}
public fw_TraceAttack_Player(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{
	if(!is_user_connected(Attacker))
		return HAM_IGNORED	
	if(get_user_weapon(Attacker) != LENA_WEAPON_CLASSID || !lena_get_has_lena(Attacker))
		return HAM_IGNORED
		
	Damage=0.0;
	
	return HAM_SUPERCEDE
}

public fw_Item_PostFrame(ent)
{
	static id; id = pev(ent, pev_owner)
	if(client_isnt_hitter(id)){
		
		return HAM_IGNORED;
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
	new pPlayer = get_member(entity, m_pPlayer)
	
	if(client_isnt_hitter(pPlayer)){
		
		return HAM_IGNORED
	}
	g_L96_clip[pPlayer] = -1
	g_L96_zoom[pPlayer] = LENA_NO_ZOOM
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
	new pPlayer = get_member(entity, m_pPlayer)
	
	if(client_isnt_hitter(pPlayer)){
		
		return HAM_IGNORED
	}
	ExecuteHam(Ham_Item_Deploy, entity)
	set_member(pPlayer, m_flNextAttack, LENA_PROJECTILE_SHOOT_PERIOD*2)
	set_member(entity, m_Weapon_flTimeWeaponIdle, LENA_PROJECTILE_SHOOT_PERIOD*2)
	set_pdata_int(entity, 51,min(CLIP_SIZE,get_pdata_int(entity, 51, 4)), 4)
	cs_set_user_zoom(pPlayer,CS_RESET_ZOOM,0);
	g_L96_zoom[pPlayer]=LENA_NO_ZOOM;
	return HAM_SUPERCEDE
}


public fw_WeaponPrimaryAttackPre(entity)
{
	new pPlayer = get_member(entity, m_pPlayer)
	
	if ( client_isnt_hitter(pPlayer)||!hasRoundStarted()) return HAM_IGNORED;
	
	if(lena_l96_get_num_bullets(pPlayer) == 0)
	{
		client_print(pPlayer, print_center, "You are out of bullets")
		sh_drop_weapon(pPlayer, LENA_WEAPON_CLASSID, true)
		return HAM_SUPERCEDE
	}
	launch_bullet(pPlayer)
	bullet_loaded[pPlayer]=false;
	g_L96_clip[pPlayer]=get_pdata_int(entity, 51, 4)
	set_member(entity, m_Weapon_flTimeWeaponIdle, LENA_PROJECTILE_SHOOT_PERIOD)
	set_member(entity, m_Weapon_flNextPrimaryAttack, LENA_PROJECTILE_SHOOT_PERIOD)
	
	pev(pPlayer, pev_punchangle, g_Recoil[pPlayer])
	return HAM_IGNORED
}

public fw_Weapon_PrimaryAttack_Post(Ent)
{
	static id; id = pev(Ent, pev_owner)
	if(client_isnt_hitter(id)){
			return;
	}
	static Float:Push[3]
	pev(id, pev_punchangle, Push)
	xs_vec_sub(Push, g_Recoil[id], Push)
	
	xs_vec_mul_scalar(Push, RECOIL, Push)
	xs_vec_add(Push, g_Recoil[id], Push)
	set_pev(id, pev_punchangle, Push)
}

launch_bullet(id)
{

entity_set_int(id, EV_INT_weaponanim, 3)

new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

entity_get_vector(id, EV_VEC_origin , Origin)
entity_get_vector(id, EV_VEC_v_angle, vAngle)


Ent = create_entity("info_target")

if (!Ent) return PLUGIN_HANDLED

entity_set_string(Ent, EV_SZ_classname, LENA_PROJECTILE_CLASSNAME)
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
entity_set_float(Ent,EV_FL_gravity, 1.25)
entity_set_edict(Ent, EV_ENT_owner, id)

VelocityByAim(id, floatround(LENA_PROJECTILE_SPEED) , Velocity)
entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

lena_l96_dec_num_bullets(id)

new parm[1]
new parm2[1]

parm2[0]= id
parm[0] = Ent
emit_sound(id, CHAN_WEAPON, LENA_L96_SHOTSOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

set_task(LENA_PROJECTILE_SHOOT_PERIOD, "bullet_reload",id,parm2,1,"a",1)
set_task(0.01, "bullettrail",id,parm,1)

return PLUGIN_CONTINUE
}

public bullet_reload(parm[])
{

bullet_loaded[parm[0]] = true
}
public bullettrail(parm[])
{
new pid = parm[0]
if (pid)
{
message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
write_byte( TE_BEAMFOLLOW )
write_short(pid) // entity
write_short(m_trail)  // model
write_byte( 10 )       // life
write_byte( 5 )
write_byte(LineColorsWithAlpha[WHITE][0])			// r, g, b
write_byte(LineColorsWithAlpha[WHITE][1])		// r, g, b
write_byte(LineColorsWithAlpha[WHITE][2])			// r, g, b
write_byte(LineColorsWithAlpha[WHITE][3]) // brightness
message_end() // move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)
}
}


public lena_zoom_task(id){
	
	id-=LENA_ZOOM_TASKID;
	if(!lena_get_has_lena(id)||!is_user_connected(id)){
		lena_l96_remove_user_zoom(id);
	}
	//sh_chat_message(id,lena_get_hero_id(),"Zoom loop running!");
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	if((weapon==LENA_WEAPON_CLASSID)){
		new zoom=g_L96_zoom[id]
		switch(zoom){
			
			
			case LENA_NO_ZOOM:{
				cs_set_user_zoom(id,CS_RESET_ZOOM,0);
				
			}
			case LENA_FIRST_ZOOM:{
				cs_set_user_zoom(id,CS_SET_AUGSG552_ZOOM,0);
				
				
			}
			case LENA_SECOND_ZOOM:{
				
				cs_set_user_zoom(id,CS_SET_FIRST_ZOOM,0);
				
			}
			case LENA_MAX_ZOOM:{
				
				cs_set_user_zoom(id,CS_SET_SECOND_ZOOM,0);
				
			}
			
		}
	}
	
	
	
	
}
public _lena_l96_reset_user_zoom(iPlugin,iParams){

	new id=get_param(1)
	g_L96_zoom[id]=LENA_NO_ZOOM;

}
public _lena_l96_remove_user_zoom(iPlugin,iParams){

	new id=get_param(1)
	remove_task(id+LENA_ZOOM_TASKID)

}

public _lena_l96_set_user_zoom(iPlugin,iParams){

	new id=get_param(1)
	set_task(0.1,"lena_zoom_task",id+LENA_ZOOM_TASKID,"",0,"b")

}
public _lena_l96_get_user_zoom(iPlugin,iParams){

	new id=get_param(1)
	return g_L96_zoom[id]

}

public _lena_l96_clear_bullets(iPlugin,iParams){

new grenada = find_ent_by_class(-1, LENA_PROJECTILE_CLASSNAME)
while(grenada) {
	remove_entity(grenada)
	arrayset(bullet_launch_pos[grenada],0.0,3);
	grenada = find_ent_by_class(grenada, LENA_PROJECTILE_CLASSNAME)
}
}


public vexd_pfntouch(pToucher, pTouched)
{

	if (pToucher <= 0) return
	if (!is_valid_ent(pToucher)) return

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
				new Float:speed
				new Float:velocity[3]
				
				
				entity_get_vector(pToucher,EV_VEC_velocity,velocity);
				speed=VecLength(velocity);
				new Float:speed_coeff=(speed/LENA_PROJECTILE_SPEED)
				new Float:vic_origin[3];
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
					damage*=4;
				}
				
				sh_extra_damage(pTouched,oid,floatround(damage),"Lena bullet",headshot);
				sh_chat_message(oid,lena_get_hero_id(),"You hit him! It was%sa headshot!",headshot?" ":" not ");
				emit_sound(pToucher, CHAN_WEAPON, LENA_L96_BODYHIT_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				make_bleed_fx(pTouched);
				
			}
		}
		if(pev(pTouched,pev_solid)==SOLID_BSP){
		
			emit_sound(pToucher, CHAN_WEAPON, LENA_L96_WALLHIT_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			make_sparks(origin);
			gun_shot_decal(origin);
			remove_entity(pToucher)	

		}

		arrayset(bullet_launch_pos[pToucher],0.0,3);
	}
}
public remove_bullet(id_bullet){
	id_bullet-=LENA_PROJECTILE_REM_TASKID

	remove_entity(id_bullet)


}
public plugin_precache()
{
precache_explosion_fx()
precache_model("models/shell.mdl")
engfunc(EngFunc_PrecacheSound, LENA_L96_SHOTSOUND)
engfunc(EngFunc_PrecacheSound, LENA_L96_WALLHIT_SOUND)
engfunc(EngFunc_PrecacheSound, LENA_L96_BODYHIT_SOUND)
engfunc(EngFunc_PrecacheSound, NULL_SOUND_FILENAME)

}