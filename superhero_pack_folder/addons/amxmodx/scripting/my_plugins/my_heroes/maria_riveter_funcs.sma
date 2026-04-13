#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include <reapi>
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "maria_riveter_inc/maria_riveter_funcs.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "../my_include/my_author_header.inc"
#include "../my_include/weapons_const.inc"

#define PLUGIN_VER "1.0"
#define PLUGIN_NAME "SUPERHERO Maria's riveter"


new bool:rivet_loaded[SH_MAXSLOTS+1]
new Float:g_Recoil[SH_MAXSLOTS+1][3]
new g_Riveter_clip[SH_MAXSLOTS+1]


public plugin_init(){
	

	register_plugin(PLUGIN_NAME, PLUGIN_VER, AUTHOR);

	arrayset(rivet_loaded,true,SH_MAXSLOTS+1)
	register_forward(FM_CmdStart, "CmdStart");
	RegisterHam(Ham_Item_Deploy, MARIA_WEAPON, "fw_ItemDeployPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, MARIA_WEAPON, "fw_WeaponPrimaryAttackPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, MARIA_WEAPON, "fw_Weapon_PrimaryAttack_Post", 1,true)	
	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)
	RegisterHam(Ham_Item_PostFrame, MARIA_WEAPON, "fw_Item_PostFrame",_,true)	
	
	
	RegisterHam(Ham_TraceAttack, "player", "Ham_TraceAttackMariaRiveter",_,true)
	
	RegisterHam(Ham_Weapon_Reload,MARIA_WEAPON, "fw_WeaponReloadPre",_,true)
	RegisterHam(Ham_Weapon_Reload, MARIA_WEAPON, "fw_Weapon_Reload_Post", 1,true)

	register_think(MARIA_PROJECTILE_CLASSNAME, "rivette_thinque")
	init_gravity_pcvar()


}

public rivette_thinque(ent){


	if ( pev_valid(ent)!=2 ) return FMRES_IGNORED
	
	new owner=entity_get_edict(ent, EV_ENT_owner)

	if(!client_hittable(owner)){

		remove_entity(ent)	
		return FMRES_IGNORED
	}

	new parm[2]
	parm[0] = ent
	parm[1] = owner

	projectile_air_drag_update_speed(parm,MARIA_PROJECTILE_DRAG_CONST,MARIA_PROJECTILE_GRAVITY_MULT,MARIA_PROJECTILE_PHYS_UPDATE_TIME)
	

	entity_set_float( ent, EV_FL_nextthink, floatadd(get_gametime( ) ,MARIA_PROJECTILE_PHYS_UPDATE_TIME));

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


}//----------------------------------------------------------------------------------------------
public plugin_natives(){
	
	register_native( "maria_riveter_clear_rivets","_maria_riveter_clear_rivets",0)
	
	
}
public bool:client_isnt_hitter(id){
	
	return !client_hittable(id,sh_user_has_hero(id,maria_get_hero_id()))
	
}
public CmdStart(id, uc_handle)
{
	if(client_isnt_hitter(id)){
		
		return FMRES_IGNORED
	}
	new button = get_uc(uc_handle, UC_Buttons);
	
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	if((weapon==MARIA_WEAPON_CLASSID)){
		
		if(button & IN_ATTACK)
		{
			if(sh_user_has_hero(id,gatling_get_hero_id())||
						!rivet_loaded[id]||
						(maria_riveter_get_num_rivets(id)<=0)){
				button &= ~IN_ATTACK;
				set_uc(uc_handle, UC_Buttons, button);
				return FMRES_SUPERCEDE
			}
			
		}
	}
	return FMRES_IGNORED;
}

public Ham_TraceAttackMariaRiveter(id, idattacker, Float:damage, Float:direction[3], ptr, damagebits)
{
	
	if(!is_user_connected(idattacker)){
		return HAM_IGNORED	
	}
	if(get_user_weapon(idattacker) != MARIA_WEAPON_CLASSID|| !sh_user_has_hero(idattacker,maria_get_hero_id())){
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
	static bpammo; bpammo = cs_get_user_bpammo(id, MARIA_WEAPON_CLASSID)
	
	static iClip; iClip = get_pdata_int(ent, 51, 4)
	static fInReload; fInReload = get_pdata_int(ent, 54, 4)
	
	if(fInReload && flNextAttack <= 0.0)
	{
		static temp1
		temp1 = min(CLIP_SIZE - iClip, bpammo)

		set_pdata_int(ent, 51, iClip + temp1, 4)
		cs_set_user_bpammo(id, MARIA_WEAPON_CLASSID, bpammo - temp1)		
		
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
	g_Riveter_clip[pPlayer] = -1
	static BPAmmo; BPAmmo = cs_get_user_bpammo(pPlayer, MARIA_WEAPON_CLASSID)
	static iClip; iClip = get_pdata_int(entity, 51, 4)
	
	if(BPAmmo <= 0){
		return HAM_SUPERCEDE
	}
	if(iClip >= CLIP_SIZE){
		return HAM_SUPERCEDE		
	}
	g_Riveter_clip[pPlayer] = iClip		
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
	
		if(g_Riveter_clip[id] == -1)
			return HAM_IGNORED
		
		set_pdata_int(ent, 51, g_Riveter_clip[id], 4)
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
	set_member(pPlayer, m_flNextAttack, MARIA_PROJECTILE_DEPLOY_TIME)
	set_member(entity, m_Weapon_flTimeWeaponIdle, MARIA_PROJECTILE_DEPLOY_TIME)
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
	launch_rivet(pPlayer);
	g_Riveter_clip[pPlayer]=get_pdata_int(entity, 51, 4)
	set_member(entity, m_Weapon_flTimeWeaponIdle, MARIA_PROJECTILE_SHOOT_PERIOD)
	set_member(entity, m_Weapon_flNextPrimaryAttack, MARIA_PROJECTILE_SHOOT_PERIOD)


	pev(pPlayer, pev_punchangle, g_Recoil[pPlayer])
	set_entvar(pPlayer, var_weaponanim,  random_num(anim_shoot1,anim_shoot2))
	unregister_forward(FM_PlaybackEvent, iPlaybackEvent)
	return HAM_SUPERCEDE
}

public fw_Weapon_PrimaryAttack_Post(Ent)
{
	
	if(pev_valid(Ent)!=2)
		return
		
	new id; id = pev(Ent, pev_owner)
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
launch_rivet(id)
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
entity_set_string(Ent, EV_SZ_classname, MARIA_PROJECTILE_CLASSNAME)
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
entity_set_float(Ent,EV_FL_gravity, MARIA_PROJECTILE_GRAVITY_MULT)
entity_set_edict(Ent, EV_ENT_owner, id)

VelocityByAim(id, floatround(MARIA_PROJECTILE_SPEED) , Velocity)
new Float:coeff_to_multiply_with
new resume_zoom=get_member(id,m_bResumeZoom);
if(!(resume_zoom)){
	coeff_to_multiply_with=MARIA_PROJECTILE_SHOOT_RANDOMNESS;
}
else{
	
	new Float:user_movement_velocity[3]
	entity_get_vector(id,EV_VEC_velocity,user_movement_velocity)
	new Float:user_maxspeed=get_user_maxspeed(id);
	new Float:user_current_speed=VecLength(user_movement_velocity)
	new Float:coeff_to_multiply_with_extra=(user_current_speed/user_maxspeed)
	coeff_to_multiply_with=coeff_to_multiply_with_extra*MARIA_PROJECTILE_SHOOT_RANDOMNESS
	
}
randomize_vector_with_coeff(coeff_to_multiply_with,Velocity)

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


public _maria_riveter_clear_rivets(iPlugin,iParams){

new grenada = find_ent_by_class(-1, MARIA_PROJECTILE_CLASSNAME)
while(grenada) {
	remove_entity(grenada)
	grenada = find_ent_by_class(grenada, MARIA_PROJECTILE_CLASSNAME)
}
}

public fm_UpdateClientDataPost(player, sendWeapons, cd)
{
	if(client_isnt_hitter(player)){
		
		return FMRES_IGNORED
	}
	if((get_user_weapon(player) != MARIA_WEAPON_CLASSID)){
		return FMRES_IGNORED
	}
	new pEntity = get_member(player, m_pActiveItem)
	if(is_valid_ent(pEntity)){
		set_cd(cd, CD_flNextAttack, get_gametime()+0.001)
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}


public vexd_pfntouch(pToucher, pTouched)
{

	if (pev_valid(pToucher)!=2){
		
		return
	}

	new szClassName[32]
	entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)
	if(equal(szClassName, MARIA_PROJECTILE_CLASSNAME))
	{
		new Float:origin[3]
		entity_get_vector(pToucher,EV_VEC_origin,origin);
		
		new bool:is_direct_hit = client_hittable(pTouched);
		new Float:rivet_launch_pos[3]
		entity_get_vector(pToucher,EV_VEC_vuser1,rivet_launch_pos)
		new Float:distance=vector_distance(origin,rivet_launch_pos);
		new Float:falloff_coeff= (is_direct_hit?0.0:floatmin(1.0,distance/MARIA_PROJECTILE_DAMAGE_FALLOFF_DIST));
		new Float:damage=MARIA_PROJECTILE_DAMAGE-(35.0*falloff_coeff)+(is_direct_hit?MARIA_PROJECTILE_DAMAGE_DIRECT_BONUS:0.0);
		explosion(maria_get_hero_id(),pToucher,
										MARIA_PROJECTILE_EXPLODE_RADIUS,damage,
										MARIA_PROJECTILE_EXPLODE_FORCE-(is_direct_hit?MARIA_PROJECTILE_KNOCKBACK_DIRECT_REDUCED:0.0),
										is_direct_hit,
										is_direct_hit)
		remove_entity(pToucher)
	}
}
public plugin_precache()
{

engfunc(EngFunc_PrecacheModel,"models/shell.mdl")
engfunc(EngFunc_PrecacheSound, MARIA_RIVETER_SHOTSOUND)
engfunc(EngFunc_PrecacheSound, MARIA_RIVETER_WALLHIT_SOUND)

}
public fm_PlaybackEventPre() return FMRES_SUPERCEDE
