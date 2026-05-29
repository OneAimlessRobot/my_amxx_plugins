#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#define I_WANT_CUSTOM_WEAPONS

#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "maria_riveter_inc/maria_riveter_funcs.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_gatling_funcs.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"

#define PLUGIN "Superhero yakui mk2 pt2"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


new gHeroID = -1
new gNumPills[SH_MAXSLOTS+1]
new gatling_action:g_plAction[SH_MAXSLOTS+1]
new Float:g_nextSound[SH_MAXSLOTS+1]

new Float:g_recoil_pillgatling[SH_MAXSLOTS+1][3]

new Float:g_lastShot[SH_MAXSLOTS+1]
new g_Pillgatling_clip[SH_MAXSLOTS+1]


new can_fire_mask = 0
new delay_mask = 0
new gPillGatlingEngaged_mask = 0
new g_fwid = 0
new g_guns_eventids_bitsum = 0
// Sounds
new m_SOUND[][] = {"shmod/yakui/hw_shoot1.wav", "shmod/yakui/hw_spin.wav", "shmod/yakui/hw_spinup.wav", "shmod/yakui/hw_spindown.wav"}


new weapon_secret_code = -1

new Float:windup_time
new const g_guns_events[][] = {"events/m249.sc"}
public plugin_init(){

	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_names_stock_arr[YAKUI_WEAPON_CLASSID], "fw_WeaponPrimaryAttackPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_names_stock_arr[YAKUI_WEAPON_CLASSID], "fw_Weapon_PrimaryAttack_Post",1,true)
	RegisterHam(Ham_Item_Deploy, weapon_names_stock_arr[YAKUI_WEAPON_CLASSID], "fw_ItemDeployPre",_,true)
	register_forward(FM_StartFrame, "fwd_StartFrame")
	register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
	RegisterHam(Ham_Item_PostFrame, weapon_names_stock_arr[YAKUI_WEAPON_CLASSID], "Item_PostFrame_Post", 1,true)
		
	RegisterHam(Ham_Weapon_Reload, weapon_names_stock_arr[YAKUI_WEAPON_CLASSID], "fw_WeaponReloadPre",_,true)
	RegisterHam(Ham_Weapon_Reload, weapon_names_stock_arr[YAKUI_WEAPON_CLASSID], "fw_Weapon_Reload_Post", 1,true)
	
	RegisterHam(Ham_TraceAttack, "player", "Ham_TraceAttackYakuiMinigun",_,true)
	
	register_entity_as_wall_touchable(PILL_CLASSNAME,"FwdTouchWorld")
	register_custom_touchable(PILL_CLASSNAME,"pilula_sexual_penetra_player",player_vector,1)

	register_forward(FM_CmdStart, "CmdStart");
	create_cvar("yakui_windup_time", "2.0")
	register_think(PILL_CLASSNAME, "pill_think")
	unregister_forward(FM_PrecacheEvent, g_fwid, 1)
	
	weapon_secret_code = allocate_weapon_secret_code()

}

public FwdTouchWorld( pilula_sexualllllee, World ) {

	if(!is_valid_ent(pilula_sexualllllee)) return
	
	new Float:origin[3]
	entity_get_vector(pilula_sexualllllee,EV_VEC_origin,origin);


	emit_sound(pilula_sexualllllee, CHAN_WEAPON, GLASS_BREAK_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	make_sparks(origin);
	gun_shot_decal(origin);
	
	remove_entity(pilula_sexualllllee)
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

	if(!Get_BitVar(can_fire_mask,pPlayer)){
		return HAM_SUPERCEDE
	}

	if(g_plAction[pPlayer]!=act_run){
		return HAM_SUPERCEDE
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
	fire_mode(pPlayer, entity,spin_shoot);
	g_Pillgatling_clip[pPlayer]=get_pdata_int(entity, m_iClip, XO_WEAPON)
	set_pdata_float(entity, m_flNextPrimaryAttack, PILL_SHOOT_PERIOD,XO_WEAPON)
	set_pdata_float(entity, m_flTimeWeaponIdle, PILL_SHOOT_PERIOD,XO_WEAPON)


	entity_get_vector(pPlayer, EV_VEC_punchangle, g_recoil_pillgatling[pPlayer])
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

	if(!Get_BitVar(can_fire_mask,id)){
		return
	}
	if(g_plAction[id]!=act_run){
		return
	}
	static Float:Push[3]
	entity_get_vector(id, EV_VEC_punchangle, Push)

	sub_3d_vectors(Push, g_recoil_pillgatling[id], Push)
	
	multiply_3d_vector_by_scalar(Push, PILLGATLING_RECOIL, Push)
	add_3d_vectors(Push, g_recoil_pillgatling[id], Push)
	entity_set_vector(id, EV_VEC_punchangle, Push)
}
public Item_PostFrame_Post(iEnt)
{    
	if (!sh_is_active()){
		return
	}
	if(pev_valid(iEnt) != 2){
		return
	}
	static id; id = get_pdata_cbase(iEnt, m_pPlayer,XO_WEAPON)
	
	if(!client_is_hero_user(id, gHeroID)||!Get_BitVar(gPillGatlingEngaged_mask,id)){
		
		return
	}
	static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, OFFSET_LINUX_PLAYER)
	static bpammo; bpammo = cs_get_user_bpammo(id, YAKUI_WEAPON_CLASSID)
	
	static iClip; iClip = get_pdata_int(iEnt, m_iClip, XO_WEAPON)
	static fInReload; fInReload = get_pdata_int(iEnt, m_fInReload , XO_WEAPON)
	
	if(fInReload && flNextAttack <= 0.0)
	{
		static temp1
		temp1 = min(PILLGATLING_CLIP_SIZE - iClip, bpammo)

		set_pdata_int(iEnt, m_iClip, iClip + temp1, XO_WEAPON)
		cs_set_user_bpammo(id, YAKUI_WEAPON_CLASSID, bpammo - temp1)		
		
		set_pdata_int(iEnt, m_fInReload , 0, XO_WEAPON)
		
		fInReload = 0
	}
}
//sound and anim
public fwd_StartFrame() {
	static Float:gtime, id
	
	gtime = get_gametime()
	
	for(id = 1; id < sh_maxplayers()+1; id++) {
		if(g_plAction[id] != act_none) {
			
			if(!(pev(id,pev_button) & IN_ATTACK) && !(pev(id,pev_button) & IN_USE)&& (( g_lastShot[id] + GAT_WINDUP_PERIOD) < gtime)) {
				native_playanim(id, yakui_pillgatling_anim_spinidledown)
				emit_sound(id, CHAN_WEAPON, m_SOUND[3], 1.0, ATTN_NORM, 0, PITCH_NORM)
				g_nextSound[id] = gtime + SHUTDOWN_TIME
				g_plAction[id] = act_none
			}
		}
	}
}
public Ham_TraceAttackYakuiMinigun(id, idattacker, Float:damage, Float:direction[3], ptr, damagebits)
{
	if(damage<=0.0){
		return HAM_IGNORED
	}

	if(!is_user_connected(idattacker)){
		return HAM_IGNORED	
	}
	if(get_user_weapon(idattacker) != YAKUI_WEAPON_CLASSID||
					!sh_get_user_has_hero(idattacker,gHeroID)||
					!Get_BitVar(gPillGatlingEngaged_mask,idattacker)){
		return HAM_IGNORED
	}
	damage= 0.0
	SetHamParamFloat(3,damage)
	
	return HAM_SUPERCEDE
	
}
public plugin_natives(){

	
	register_native("gatling_set_num_pills","_gatling_set_num_pills");
	register_native("gatling_get_num_pills","_gatling_get_num_pills");
	register_native("gatling_dec_num_pills","_gatling_dec_num_pills");

	register_native("gatling_set_pillgatling","_gatling_set_pillgatling");
	register_native("gatling_get_pillgatling","_gatling_get_pillgatling");


}
public _gatling_get_pillgatling(iPlugin,iParams){
	new id=get_param(1)
	return Get_BitVar(gPillGatlingEngaged_mask,id)

}
public _gatling_set_pillgatling(iPlugin,iParams){

	new id= get_param(1)
	new value_to_set= get_param(2);
	Assign_BitVar(gPillGatlingEngaged_mask,id, value_to_set);
}


public _gatling_set_num_pills(iPlugin,iParams){
	new id= get_param(1)
	new value_to_set=get_param(2)
	if(!is_user_connected(id)){
		
		return
	}
	gNumPills[id]=value_to_set;
}
public _gatling_get_num_pills(iPlugin,iParams){


	new id= get_param(1)
	if(!is_user_connected(id)){
		
		return -1
	}
	return gNumPills[id]

}

public _gatling_dec_num_pills(iPlugin,iParams){


	new id= get_param(1)
	if(!is_user_connected(id)){
		
		return
	}
	gNumPills[id]-= (gNumPills[id]>0)? 1:0

}

//----------------------------------------------------------------------------------------------
public CmdStart(id, uc_handle)
{	

	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	
	if ( !client_is_hero_user(id, gHeroID)){
		
		return FMRES_IGNORED;
	}

	if(!Get_BitVar(gPillGatlingEngaged_mask,id)){

		Assign_BitVar(can_fire_mask, id, false_for_macro);
		return FMRES_IGNORED

	}

	new weapon=get_user_weapon(id)
	if(weapon!=YAKUI_WEAPON_CLASSID){
		return FMRES_IGNORED

	}

	new ent = get_pdata_cbase(id, m_pActiveItem, XTRA_OFS_PLAYER)

	static buttons;
	buttons= get_uc(uc_handle, UC_Buttons);
	
	if(buttons & IN_USE){
		
		buttons &= ~IN_USE;
		Assign_BitVar(can_fire_mask, id, true_for_macro);
	}
	else{

		Assign_BitVar(can_fire_mask, id, false_for_macro);
	}

	if(Get_BitVar(can_fire_mask,id) ){

		set_uc(uc_handle, UC_Buttons, buttons)
	}
	if(Get_BitVar(can_fire_mask,id) ){
		fire_mode(id,ent,spin_only)
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

	gHeroID = gatling_get_hero_id()
	windup_time=get_cvar_float("yakui_windup_time")
}
public delayanim(id){
	Assign_BitVar(delay_mask,id, false_for_macro)
}
public fw_WeaponReloadPre(entity)
{
	if(pev_valid(entity)!=2)
		return HAM_IGNORED
	
	static pPlayer; pPlayer = get_pdata_cbase(entity, m_pPlayer,XO_WEAPON)
	
	if(!client_is_hero_user(pPlayer, gHeroID)||!Get_BitVar(gPillGatlingEngaged_mask,pPlayer)){
		
		return HAM_IGNORED
	}
	g_Pillgatling_clip[pPlayer] = -1
	static BPAmmo; BPAmmo = cs_get_user_bpammo(pPlayer, YAKUI_WEAPON_CLASSID)
	static iClip; iClip = get_pdata_int(entity, m_iClip, XO_WEAPON)
	
	if(BPAmmo <= 0){
		return HAM_SUPERCEDE
	}
	if(iClip >= PILLGATLING_CLIP_SIZE){
		return HAM_SUPERCEDE		
	}
	g_Pillgatling_clip[pPlayer] = iClip
	return HAM_IGNORED
}
public fw_Weapon_Reload_Post(ent)
{
	if(pev_valid(ent)!=2)
		return HAM_IGNORED
		
	static id; id = get_pdata_cbase(ent, m_pPlayer,XO_WEAPON)
	if(!client_is_hero_user(id, gHeroID)||!Get_BitVar(gPillGatlingEngaged_mask,id)){
		
		return HAM_IGNORED
	}
	if(g_Pillgatling_clip[id] == -1)
		return HAM_IGNORED

	
	set_pdata_int(ent, m_iClip, g_Pillgatling_clip[id], XO_WEAPON)
	set_pdata_int(ent, m_fInReload, 1, XO_WEAPON);
	
	
	return HAM_IGNORED
}


public fwPlaybackEvent(flags, invoker, eventid) {
	if (!(g_guns_eventids_bitsum & (1<<eventid)) || !client_is_hero_user(invoker, gHeroID)||!Get_BitVar(gPillGatlingEngaged_mask, invoker)){
		return FMRES_IGNORED
	}
	return FMRES_HANDLED
}

public fm_UpdateClientDataPost(player, sendWeapons, cd)
{
	if(!client_is_hero_user(player, gHeroID)){
		
		return FMRES_IGNORED
	}
	if((get_user_weapon(player) != YAKUI_WEAPON_CLASSID)){
		return FMRES_IGNORED
	}
	new pEntity = get_pdata_cbase(player, m_pActiveItem,OFFSET_LINUX_PLAYER)
	if(is_valid_ent(pEntity)){
		set_cd(cd, CD_flNextAttack, get_gametime()+9999.0)
		return FMRES_HANDLED
	}
	return FMRES_IGNORED
}

// in fire
fire_mode(id,entity, fire_mode_enum:type) {
	
	static Float:gtime
	gtime = get_gametime()
	g_lastShot[id] = gtime

	if(g_nextSound[id] <= gtime){
		switch(g_plAction[id]) {
			case act_none: {
				
				native_playanim(id, yakui_pillgatling_anim_spinup)
				emit_sound(id, CHAN_WEAPON, m_SOUND[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
				g_nextSound[id] = gtime + windup_time
				g_plAction[id] = act_load_up
			}
			case act_load_up: {
				g_nextSound[id] = gtime
				g_plAction[id] = act_run
			}
		}

	}

	if(g_plAction[id] == act_run) {

		if(type == spin_shoot && g_Pillgatling_clip[id]>0){
			g_Pillgatling_clip[id]=get_pdata_int(entity, m_iClip, XO_WEAPON)
			emit_sound(id, CHAN_WEAPON, m_SOUND[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
			launch_pill(id)
			if(!Get_BitVar(delay_mask,id)) {
				native_playanim(id, yakui_pillgatling_anim_spinfire)
				set_task(GAT_WINDUP_PERIOD,"delayanim",id)
				Assign_BitVar(delay_mask,id, true_for_macro)
			}
		} 
		else { 
			if(!Get_BitVar(delay_mask,id)) {
				emit_sound(id, CHAN_WEAPON, m_SOUND[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
				native_playanim(id, yakui_pillgatling_anim_spinidle)
				set_task(GAT_WINDUP_PERIOD,"delayanim",id)
				
				Assign_BitVar(delay_mask,id, true_for_macro)
			}
		}
	}
}
launch_pill(id)
{

	new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

	entity_get_vector(id, EV_VEC_origin , Origin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)


	Ent = create_entity("info_target")

	if (!Ent) return PLUGIN_HANDLED

	entity_set_string(Ent, EV_SZ_classname, PILL_CLASSNAME)
	entity_set_model(Ent, "models/shell.mdl")

	new Float:MinBox[3] = {-1.0, -1.0, -1.0}
	new Float:MaxBox[3] = {1.0, 1.0, 1.0}
	entity_set_vector(Ent, EV_VEC_mins, MinBox)
	entity_set_vector(Ent, EV_VEC_maxs, MaxBox)

	entity_set_origin(Ent, Origin)
	entity_set_vector(Ent, EV_VEC_angles, vAngle)

	entity_set_int(Ent, EV_INT_effects, 2)
	entity_set_int(Ent, EV_INT_solid, 2)

	entity_set_int(Ent, EV_INT_movetype, 10)
	entity_set_edict(Ent, EV_ENT_owner, id)

	velocity_by_aim(id, floatround(PILL_SPEED) , Velocity)
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

	set_pev(Ent, pev_vuser1, Velocity)
	

	gNumPills[id]-= (gNumPills[id]>0)? 1:0

	new fx_id:fx_num=sh_gen_effect()
	
	//this will store the fx num in the pill ent
	entity_set_int(Ent,EV_INT_iuser3,fx_num)
	new color[3]
	sh_get_pill_color(fx_num,id,color)

	aura(id,color,3,1)
	emit_sound(id, CHAN_WEAPON, m_SOUND[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	trail_custom(Ent,color,10,5)
	

	entity_set_float( Ent, EV_FL_nextthink, get_gametime( ) + 0.05 );

	return PLUGIN_CONTINUE
}

	//----------------------------------------------------------------------------------------------
public pill_think(ent)
{

	if(pev_valid(ent)!=2){

		return

	}
	
	new id=entity_get_edict(ent,EV_ENT_owner)
	if (!client_is_hero_user(id, gHeroID)) {
		remove_entity(ent)
		return
	}
	new Float:newVelocity[3],Float:velocityVec[ 3 ]
	entity_get_vector( ent, EV_VEC_velocity, velocityVec );
	entity_get_vector( ent, EV_VEC_velocity, newVelocity );


	new Float:rnd_floatx=generate_float(-PILL_MASS,PILL_MASS)*float(generate_bool()?-1:1),
		Float:rnd_floaty=generate_float(-PILL_MASS,PILL_MASS)*float(generate_bool()?-1:1)

	velocityVec[0] = velocityVec[0]+(rnd_floatx)
	velocityVec[1] = velocityVec[1]+(rnd_floaty)

	new Float:length = vector_length(velocityVec)
		// Stupid Check but lets make sure you don't devide by 0
	if ( !length ) length = 1.0

	newVelocity[0]= velocityVec[0]*PILL_SPEED/length
	newVelocity[1] = velocityVec[1]*PILL_SPEED/length
	newVelocity[2]= velocityVec[2]


	entity_set_vector(ent, EV_VEC_velocity ,newVelocity)
	set_pev(ent, pev_vuser1, newVelocity)
	entity_set_float( ent, EV_FL_nextthink, get_gametime( ) + 0.05 );
}

public fw_ItemDeployPre(entity)
{
	if(pev_valid(entity)!=2)
		return HAM_IGNORED
		
	static pPlayer; pPlayer = get_pdata_cbase(entity, m_pPlayer,XO_WEAPON)
	
	if(!client_is_hero_user(pPlayer, gHeroID)||!Get_BitVar(gPillGatlingEngaged_mask, pPlayer)){
		
		remove_weapon_secret_code(entity,weapon_secret_code)
		return HAM_IGNORED
	}

	ExecuteHam(Ham_Item_Deploy, entity)
	set_pdata_float(pPlayer, m_flNextAttack, PILL_DEPLOY_TIME ,OFFSET_LINUX_PLAYER)
	set_pdata_float(entity, m_flTimeWeaponIdle, PILL_DEPLOY_TIME ,XO_WEAPON)
	set_pdata_int(entity, m_iClip,min(PILLGATLING_CLIP_SIZE,get_pdata_int(entity, m_iClip, XO_WEAPON)), XO_WEAPON)
	set_weapon_secret_code(entity,weapon_secret_code)
	return HAM_SUPERCEDE
}

//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
	if(sh_is_active()&&!client_is_hero_user(id, gHeroID)){
		
		Assign_BitVar(can_fire_mask,id,false_for_macro);
		g_plAction[id]=act_none;
	}
	
}
public pilula_sexual_penetra_player(pToucher, pTouched)
{
	if(!is_valid_ent(pToucher)) return

	if(is_user_alive(pTouched))
	{	
		new id = entity_get_edict(pToucher, EV_ENT_owner);
		//retrieve current pill fx num

		new fx_id:fx_num=fx_id:entity_get_int(pToucher,EV_INT_iuser3)
		make_effect(pTouched,id,gHeroID,fx_num,false)
	}
	remove_entity(pToucher)
}
public fwPrecacheEvent(type, const name[]) {
	for (new i = 0; i < sizeof g_guns_events; ++i) {
		if (equal(g_guns_events[i], name)) {
			g_guns_eventids_bitsum |= (1<<get_orig_retval())
			return FMRES_HANDLED
		}
	}

	return FMRES_IGNORED
}
public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel,"models/shell.mdl")
	
	engfunc(EngFunc_PrecacheModel,GATLING_P_MODEL)
	engfunc(EngFunc_PrecacheModel,GATLING_V_MODEL)
	g_fwid = register_forward(FM_PrecacheEvent, "fwPrecacheEvent", 1)
	engfunc(EngFunc_PrecacheSound, GLASS_BREAK_SFX)
	engfunc(EngFunc_PrecacheSound,m_SOUND[0])
	engfunc(EngFunc_PrecacheSound,m_SOUND[1])
	engfunc(EngFunc_PrecacheSound,m_SOUND[2])
	engfunc(EngFunc_PrecacheSound,m_SOUND[3])

}
