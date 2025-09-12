#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "lena_inc/sh_lena_l96_include.inc"
#include "lena_inc/sh_lena_general_include.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include <fakemeta_util>
#include <reapi>
#include "../my_include/weapons_const.inc"

#define PLUGIN_AUTHOR "MilkChanTheGOAasdasdasdasdasdasdasdasdsdasdT"
#define PLUGIN_VER "1.0"
#define PLUGIN_NAME "SUPERHERO Lena de Verias: L96 weapon_thingie"


new bool:bullet_loaded[SH_MAXSLOTS+1]
new Float:g_Recoil[SH_MAXSLOTS+1][3]
new Float:bullet_launch_pos[MAX_ENTITIES][3];
new g_L96_clip[SH_MAXSLOTS+1]
//new HamHook:TakeDamage
public plugin_init(){
	
	
	register_plugin(PLUGIN_NAME, PLUGIN_VER, PLUGIN_AUTHOR);
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
	
}

public plugin_natives(){
	
	register_native( "lena_l96_clear_bullets","_lena_l96_clear_bullets",0)
	
	
}
public bool:client_isnt_hitter(id){
	
	if ( !client_hittable(id)){
		
		return true
	}
	if(!lena_get_has_lena(id)){
		
		
		return true;
	}
	return false
	
}
public CmdStart(id, uc_handle)
{
	if(client_isnt_hitter(id)){
		
		return FMRES_IGNORED
	}
	
	new button = get_uc(uc_handle, UC_Buttons);
	
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	if((weapon==LENA_WEAPON_CLASSID)){
		if(button & IN_ATTACK)
		{
			if(!bullet_loaded[id]){
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
	if(get_user_weapon(idattacker) != LENA_WEAPON_CLASSID|| !lena_get_has_lena(idattacker)){
		return HAM_IGNORED
	}
		
		
	
	damage=0.0;
	return HAM_SUPERCEDE
	
}

public fw_Item_PostFrame(ent)
{
	if(!is_valid_ent(ent)) return HAM_IGNORED
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
	if(lena_l96_get_num_bullets(pPlayer) == 0)
	{
		client_print(pPlayer, print_center, "You are out of bullets")
		sh_drop_weapon(pPlayer, LENA_WEAPON_CLASSID, true)
		return HAM_SUPERCEDE
	}
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
	
	emit_sound(pPlayer, CHAN_WEAPON, LENA_L96_SHOTSOUND, 1.0, 0.0, 0, PITCH_NORM)
	
	pev(pPlayer, pev_punchangle, g_Recoil[pPlayer])
	set_entvar(pPlayer, var_weaponanim,  SEQ_SHOOT1)
	
	unregister_forward(FM_PlaybackEvent, iPlaybackEvent)
	//DisableHamForward(TakeDamage)
	
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
		
	return PLUGIN_CONTINUE
}
entity_set_int(id, EV_INT_weaponanim, 3)

new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

entity_get_vector(id, EV_VEC_origin , Origin)
entity_get_vector(id, EV_VEC_v_angle, vAngle)


Ent = create_entity("info_target")

if (!Ent){
	return PLUGIN_HANDLED
}
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
entity_set_float(Ent,EV_FL_gravity, LENA_PROJECTILE_GRAVITY_MULT)
entity_set_edict(Ent, EV_ENT_owner, id)

VelocityByAim(id, floatround(LENA_PROJECTILE_SPEED) , Velocity)
new Float:coeff_to_multiply_with
//new zoom=get_member(id,m_iLastZoom);
new resume_zoom=get_member(id,m_bResumeZoom);
if(!(resume_zoom)){
	coeff_to_multiply_with=LENA_PROJECTILE_SHOOT_RANDOMNESS;
	//console_print(id,"coeff to multiply with: %0.2f^nZOOM= %d^n",coeff_to_multiply_with,zoom)
}
else{
	
	new Float:user_movement_velocity[3]
	entity_get_vector(id,EV_VEC_velocity,user_movement_velocity)
	new Float:user_maxspeed=get_user_maxspeed(id);
	new Float:user_current_speed=VecLength(user_movement_velocity)
	new Float:coeff_to_multiply_with_extra=(user_current_speed/user_maxspeed)
	coeff_to_multiply_with=coeff_to_multiply_with_extra*LENA_PROJECTILE_SHOOT_RANDOMNESS
	//console_print(id,"coeff to multiply with: %0.2f^nZOOM= %d^n",coeff_to_multiply_with,zoom)
	
}
randomize_vector_with_coeff(coeff_to_multiply_with,Velocity)

entity_set_vector(Ent, EV_VEC_velocity ,Velocity)
lena_l96_dec_num_bullets(id)

bullet_launch_pos[Ent][0]=Origin[0]
bullet_launch_pos[Ent][1]=Origin[1]
bullet_launch_pos[Ent][2]=Origin[2]
new parm[2]
new parm2[1]

parm2[0]= id
parm[0] = Ent
parm[1] = id
emit_sound(id, CHAN_WEAPON, LENA_L96_SHOTSOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

set_task(LENA_PROJECTILE_SHOOT_PERIOD, "bullet_reload",id,parm2,1,"a",1)
set_task(0.01, "bullettrail",Ent+LENA_PROJECTILE_TRAIL_TASKID,parm,2)

set_task(LENA_PROJECTILE_PHYS_UPDATE_TIME, "bulletspeed",Ent+LENA_PROJECTILE_SPEED_TASKID,parm,2,"b")

return PLUGIN_CONTINUE
}

public bullet_reload(parm[])
{

bullet_loaded[parm[0]] = true
}
public bullettrail(parm[])
{
	new pid = parm[0]
	if (!is_valid_ent(pid))
	{
		return
	}
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
	if(client_hittable(parm[1])){
		//client_print(parm[1],print_console,"Trail update!!!");
	}
}
public bulletspeed(parm[])
{
	new pid = parm[0]
	if (!is_valid_ent(pid))
	{
		return
	}
	new Float:speedz,Float:speedx,Float:speedy;
	new Float:velocity[3]
	new Float:velocity_copy[3]
				

	entity_get_vector(pid,EV_VEC_velocity,velocity);
	multiply_3d_vector_by_scalar(velocity,1.0,velocity_copy);
	speedx=velocity[0]
	speedy=velocity[1]
	speedz=velocity[2]
	
	new Float:gravity_const=get_cvar_float("sv_gravity")*LENA_PROJECTILE_GRAVITY_MULT
	new Float:delta_z=((LENA_PROJECTILE_DRAG_CONST*speedz)/gravity_const)*LENA_PROJECTILE_PHYS_UPDATE_TIME;
	new Float:delta_x=((LENA_PROJECTILE_DRAG_CONST*speedx)/gravity_const)*LENA_PROJECTILE_PHYS_UPDATE_TIME;
	new Float:delta_y=((LENA_PROJECTILE_DRAG_CONST*speedy)/gravity_const)*LENA_PROJECTILE_PHYS_UPDATE_TIME;
	/*console_print(parm[1],"Total speed: %0.2f^nspeedx: %0.2f^nspeedy: %0.2f^nspeedz: %0.2f^nThe angle between the velocity and gravity is: %0.2f^n",
																							speed,
																							speedx,
																							speedy,
																							speedz,
																							the_angle_degrees);
	console_print(parm[1],"The cosine: %0.2f^ngravity const: %0.2f^nDelta x is: %0.2f^nDelta y is: %0.2f^nDelta z is: %0.2f^nDrag constant: %0.2f",
																					floatcos(the_angle_radians,anglemode:radian),
																					gravity_const,
																					delta_x,
																					delta_y,
																					delta_z,
																					LENA_PROJECTILE_DRAG_CONST);*/
																							
	
	speedx-=delta_x
	speedy-=delta_y
	speedz-=delta_z
	velocity_copy[0]=speedx
	velocity_copy[1]=speedy
	velocity_copy[2]=speedz
	entity_set_vector(pid,EV_VEC_velocity,velocity_copy);
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
				sh_chat_message(oid,lena_get_hero_id(),"You hit him! They were %0.2f hammer units away! It was%sa headshot!",distance,headshot?" ":" not ");
				
				new CsArmorType:armor_type;
				cs_get_user_armor(pTouched,armor_type);
				send_poem_function(pTouched, lena_poems[random_num(0,(sizeof lena_poems)-1)]);
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
		remove_bullet(pToucher)	

		arrayset(bullet_launch_pos[pToucher],0.0,3);
	}
}
public remove_bullet(id_bullet){
	remove_task(id_bullet+LENA_PROJECTILE_TRAIL_TASKID);
	remove_task(id_bullet+LENA_PROJECTILE_SPEED_TASKID);
	if(is_valid_ent(id_bullet)){
		remove_entity(id_bullet)
	}


}
public plugin_precache()
{
precache_explosion_fx()
precache_model("models/shell.mdl")
engfunc(EngFunc_PrecacheSound, LENA_L96_SHOTSOUND)
engfunc(EngFunc_PrecacheSound, LENA_L96_WALLHIT_SOUND)
engfunc(EngFunc_PrecacheSound, NULL_SOUND_FILENAME)

}
public fm_PlaybackEventPre() return FMRES_SUPERCEDE