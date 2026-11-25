#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_MATH_FUNCS
#define I_WANT_CUSTOM_COLORS
#define I_WANT_ENTITY_VECTORS
#define I_WANT_PDATA_ALIASES
#define I_WANT_RESOURCE_ALIASES
#define I_WANT_BASIC_MACROS

#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_rpsyringe_funcs.inc"
#include "special_fx_inc/sh_gatling_funcs.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"

#define PLUGIN "Superhero yakui mk2 pt2"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


#define PILL_CLASSNAME "pill_gatling_pill"

#define NUM_BARRELS 6
#define PILLGATLING_CLIP_SIZE 250
#define PILL_SPEED 1350.0

//this should be roughly 450 rpm
#define PILL_SHOOT_PERIOD_BASE 0.13333333333
#define PILL_SHOOT_PERIOD (PILL_SHOOT_PERIOD_BASE/float(NUM_BARRELS))

#define PILL_DEPLOY_TIME 1.0

#define SHUTDOWN_TIME 1.7
#define PILL_MASS 100.0

#define PILLGATLING_RECOIL 0.1

enum yakui_pillgatling_anims{
	yakui_pillgatling_anim_idle = 0,
	yakui_pillgatling_anim_idle2,
	yakui_pillgatling_anim_gentleidle,
	yakui_pillgatling_anim_stillidle,
	yakui_pillgatling_anim_draw,
	yakui_pillgatling_anim_holster,
	yakui_pillgatling_anim_spinup,
	yakui_pillgatling_anim_spindown,
	yakui_pillgatling_anim_spinidle,
	yakui_pillgatling_anim_spinfire,
	yakui_pillgatling_anim_spinidledown
}

enum gatling_action{
	act_none = 0,
	act_load_up,
	act_run
}
enum fire_mode_enum{
	spin_shoot=0,
	spin_only

}

#define GAT_WINDUP_PERIOD 0.2


new gNumPills[SH_MAXSLOTS+1]
new gatling_action:g_plAction[SH_MAXSLOTS+1]
new Float:g_nextSound[SH_MAXSLOTS+1]

new Float:user_last_maxspeed[SH_MAXSLOTS+1]

new mode_change_button_pressed_mask = 0

new Float:g_recoil_pillgatling[SH_MAXSLOTS+1][3]

new Float:g_lastShot[SH_MAXSLOTS+1]
new g_Pillgatling_clip[SH_MAXSLOTS+1]
new wpn_name_for_future_lookup[50]

new can_fire_mask = 0
new delay_mask = 0
new gPillGatlingEngaged_mask = 0
new g_fwid = 0
new g_guns_eventids_bitsum = 0
// Sounds
new m_SOUND[][] = {"shmod/yakui/hw_shoot1.wav", "shmod/yakui/hw_spin.wav", "shmod/yakui/hw_spinup.wav", "shmod/yakui/hw_spindown.wav"}

new YAKUI_CHARGING_SPEED_TASKID

#define YAKUI_CHARGING_SPEED_TASK_PERIOD 0.3

new Float:windup_time
new const g_guns_events[][] = {"events/m249.sc"}
public plugin_init(){

	register_plugin(PLUGIN, VERSION, AUTHOR);

	create_cvar("yakui_windup_time", "2.0")

	register_forward(FM_StartFrame, "fwd_StartFrame")
	register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
	register_forward(FM_CmdStart, "CmdStart");

	wlt_get_def_name(my_weapon_ids:YAKUI_WEAPON_CLASSID,wpn_name_for_future_lookup,charsmax(wpn_name_for_future_lookup))
	RegisterHam(Ham_Weapon_PrimaryAttack, wpn_name_for_future_lookup, "fw_WeaponPrimaryAttackPre",_,true)
	RegisterHam(Ham_Weapon_PrimaryAttack, wpn_name_for_future_lookup, "fw_Weapon_PrimaryAttack_Post",1,true)
	RegisterHam(Ham_Item_Deploy, wpn_name_for_future_lookup, "fw_ItemDeployPre",_,true)
	
	RegisterHam(Ham_Item_PostFrame, wpn_name_for_future_lookup, "Item_PostFrame_Pre", _,true)
		
	RegisterHam(Ham_Weapon_Reload, wpn_name_for_future_lookup, "fw_WeaponReloadPre",_,true)
	RegisterHam(Ham_Weapon_Reload, wpn_name_for_future_lookup, "fw_Weapon_Reload_Post", 1,true)
	
	register_entity_as_wall_touchable(PILL_CLASSNAME,"FwdTouchWorld")
	register_custom_touchable(PILL_CLASSNAME,"pilula_sexual_penetra_player",player_vector,1)

	register_think(PILL_CLASSNAME, "pill_think")

	YAKUI_CHARGING_SPEED_TASKID=allocate_typed_task_id(generic_task)
	set_task(YAKUI_CHARGING_SPEED_TASK_PERIOD,"yakui_speed_task",YAKUI_CHARGING_SPEED_TASKID,_,_,"b")
    
	register_forward(FM_CmdStart, "player_prethink_yakui_weapon");

	unregister_forward(FM_PrecacheEvent, g_fwid, 1)
	
	register_event("CurWeapon", "weaponChange","be","1=1")


}

//----------------------------------------------------------------------------------------------
public switchmodel(id)
{
	if ( !is_user_alive(id) || !client_is_weapon_user(id, SH_PILLGATLING) ) return
	new clip, ammo, wpnid = get_user_weapon(id,clip,ammo)
	if (wpnid == YAKUI_WEAPON_CLASSID) {
		// Weapon Model change thanks to [CCC]Taz-Devil
		entity_set_string(id, EV_SZ_viewmodel, GATLING_V_MODEL)
		entity_set_string(id, EV_SZ_weaponmodel, GATLING_P_MODEL)
	}
}

//----------------------------------------------------------------------------------------------
public weaponChange(id)
{
	if ( !client_is_weapon_user(id, SH_PILLGATLING) || !sh_is_active() ) return

	new wpnid = read_data(2)

	if ( wpnid != YAKUI_WEAPON_CLASSID && client_is_weapon_user(id, SH_PILLGATLING)) return

	switchmodel(id)
}
//----------------------------------------------------------------------------------------------
public player_prethink_yakui_weapon(id, uc_handle)
{


	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	if ( !is_user_alive(id) ||!client_is_weapon_user(id, SH_PILLGATLING) ) return FMRES_IGNORED;

	if(sh_get_id_bit(id, SH_CONTROLLING_VEHICLE)) return FMRES_IGNORED

	static button;
	button= get_uc(uc_handle, UC_Buttons);
	static prev_button; prev_button = entity_get_int(id, EV_INT_oldbuttons)
	if((button & IN_ALT1)&&!(prev_button & IN_ALT1)){

		if(!Get_BitVar(mode_change_button_pressed_mask, id)){
			new wpnid=get_user_weapon(id)
			if(wpnid==YAKUI_WEAPON_CLASSID){
				Set_BitVar(mode_change_button_pressed_mask, id);
				new has_rockets=gatling_get_rockets(id)
				new has_pgatling=gatling_get_pillgatling(id)
				gatling_set_pillgatling(id,!has_pgatling)
				gatling_set_rockets(id,!has_rockets)
				sh_chat_message(id,gHeroID,"Engaged %s mode! %s",!has_rockets?"Rocket propelled syringe":"Pill shooting gatling",!has_rockets?"MOUSE1 attacks are disabled!":"")
			}
		}
	}
	else{

		UnSet_BitVar(mode_change_button_pressed_mask, id);
	}
	return FMRES_IGNORED;
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
		
	if (sh_is_freezetime()) return HAM_IGNORED;

	static pPlayer; pPlayer = get_pdata_cbase(entity, m_pPlayer, XO_WEAPON)
	
	if(!client_is_weapon_user(pPlayer, SH_PILLGATLING)){
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
	if(!client_is_weapon_user(id, SH_PILLGATLING)){
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
public Item_PostFrame_Pre(iEnt)
{    
	if (!sh_is_active()){
		return
	}
	if(pev_valid(iEnt) != 2){
		return
	}
	static id; id = get_pdata_cbase(iEnt, m_pPlayer,XO_WEAPON)
	
	if(!client_is_weapon_user(id, SH_PILLGATLING)||!Get_BitVar(gPillGatlingEngaged_mask,id)){
		
		return
	}
	static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_flNextAttack, XO_PLAYER)
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
	static Float:gtime, id, button
	
	gtime = get_gametime()
	
	for(id = 1; id < sh_maxplayers()+1; id++) {

		button = pev(id,pev_button)
		if(g_plAction[id] != act_none) {
			
			if(
				
				(get_user_weapon(id)!=YAKUI_WEAPON_CLASSID)
			
							||

				(!(button & IN_ATTACK) && !(button& IN_USE)&& (( g_lastShot[id] + GAT_WINDUP_PERIOD) < gtime))) {
				
					native_playanim(id, yakui_pillgatling_anim_spinidledown)
					emit_sound(id, CHAN_WEAPON, m_SOUND[3], 1.0, ATTN_NORM, 0, PITCH_NORM)
					g_nextSound[id] = gtime + SHUTDOWN_TIME
					g_plAction[id] = act_none
					set_user_maxspeed_controlled(id, user_last_maxspeed[id],true, true)
					sh_assign_id_bit(id, SH_IS_CHARGING_HEAVY_ATTACK, false)
					continue
			}
		}
	}
}
public plugin_natives(){

	
	register_native("gatling_set_num_pills","_gatling_set_num_pills");
	register_native("gatling_dec_num_pills","_gatling_dec_num_pills");
	register_native("gatling_set_user_pillgatling","_gatling_set_user_pillgatling")
	register_native("gatling_set_pillgatling","_gatling_set_pillgatling");
	register_native("gatling_get_pillgatling","_gatling_get_pillgatling");


}
public _gatling_set_user_pillgatling(iPlugin,iParams){
	
	new id = get_param(1),
		bool:value = bool:get_param(2),
		start_ammo = get_param(3)
	
	gNumPills[id] = 0
	sh_assign_id_custom_weapon_bit(id, SH_PILLGATLING, value);
	if(value){
		gNumPills[id] = max_macro(1,start_ammo)
		sh_give_weapon(id, YAKUI_WEAPON_CLASSID,true)
		new weapon_id=get_weapon_ent_of_player(id,YAKUI_WEAPON_CLASSID)
		if(is_valid_ent(weapon_id)){
			set_pdata_int(weapon_id, m_iClip, PILLGATLING_CLIP_SIZE, XO_WEAPON);
			cs_set_user_bpammo(id, YAKUI_WEAPON_CLASSID,gNumPills[id]-PILLGATLING_CLIP_SIZE);
			
		}
	}
	else{
		if ( is_user_alive(id) ) {
			sh_drop_weapon(id,YAKUI_WEAPON_CLASSID,true);
		}
	}

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
public sh_round_end(){

	remove_entity_name(PILL_CLASSNAME)
}

public _gatling_dec_num_pills(iPlugin,iParams){


	new id= get_param(1)
	if(!is_user_connected(id)){
		
		return
	}
	gNumPills[id]-= (gNumPills[id]>0)? 1:0

}

public yakui_speed_task(task_id){

	

	if (!sh_is_active()||sh_is_freezetime()||!sh_is_inround()){

		return
	
	}

	static the_players[SH_MAXSLOTS], pnum, id		
	get_players(the_players, pnum, "ah")
	for (new i = 0; i < pnum; i++) {
		
		id = the_players[i]

		if ( !client_is_weapon_user(id, SH_PILLGATLING)){
			
			continue;
		}

		if(!Get_BitVar(gPillGatlingEngaged_mask,id)){
			
			continue

		}
		if(g_plAction[id]==act_run){

			set_user_maxspeed_controlled(id, 100.0,true, false)

		}



	}


}
//----------------------------------------------------------------------------------------------
public CmdStart(id, uc_handle)
{	

	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}
	
	if ( !client_is_weapon_user(id, SH_PILLGATLING)){
		
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

	new ent = get_pdata_cbase(id, m_pActiveItem, XO_PLAYER)

	static buttons;
	buttons= get_uc(uc_handle, UC_Buttons);
	
	if(buttons & IN_USE){
		
		buttons &= ~IN_USE;
		if(!Get_BitVar(can_fire_mask,id)){
			
			user_last_maxspeed[id] = get_user_maxspeed(id)

			sh_assign_id_bit(id, SH_IS_CHARGING_HEAVY_ATTACK, true)
		
		}
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

	gHeroID = yakui_get_hero_id()
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
	
	if(!client_is_weapon_user(pPlayer, SH_PILLGATLING)||!Get_BitVar(gPillGatlingEngaged_mask,pPlayer)){
		
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
	if(!client_is_weapon_user(id, SH_PILLGATLING)||!Get_BitVar(gPillGatlingEngaged_mask,id)){
		
		return HAM_IGNORED
	}
	if(g_Pillgatling_clip[id] == -1)
		return HAM_IGNORED

	
	set_pdata_int(ent, m_iClip, g_Pillgatling_clip[id], XO_WEAPON)
	set_pdata_int(ent, m_fInReload, 1, XO_WEAPON);
	
	
	return HAM_IGNORED
}
public fwPlaybackEvent(flags, invoker, eventid) {
	if (!(g_guns_eventids_bitsum & (1<<eventid)) || !client_is_weapon_user(invoker, SH_PILLGATLING)||!Get_BitVar(gPillGatlingEngaged_mask, invoker)){
		return FMRES_IGNORED
	}
	return FMRES_HANDLED
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

	static Float:Origin[3], Float:Velocity[3], Float:vAngle[3], Ent

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
	static color[3]
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

	if(!is_valid_ent(ent)){

		return

	}
	
	new id=entity_get_edict(ent,EV_ENT_owner)
	if (!client_is_weapon_user(id, SH_PILLGATLING)) {
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
	
	if(!client_is_weapon_user(pPlayer, SH_PILLGATLING)||!Get_BitVar(gPillGatlingEngaged_mask, pPlayer)){
		
		return HAM_IGNORED
	}
	Assign_BitVar(can_fire_mask, pPlayer, false_for_macro);

	ExecuteHam(Ham_Item_Deploy, entity)
	set_pdata_float(pPlayer, m_flNextAttack, PILL_DEPLOY_TIME ,XO_PLAYER)
	set_pdata_float(entity, m_flTimeWeaponIdle, PILL_DEPLOY_TIME ,XO_WEAPON)
	set_pdata_int(entity, m_iClip,min(PILLGATLING_CLIP_SIZE,get_pdata_int(entity, m_iClip, XO_WEAPON)), XO_WEAPON)
	return HAM_SUPERCEDE
}

//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
	if(!sh_is_active()){
		
		return
		
	}
	if(!client_is_within_range(id)){
		
		return
	}
	
	Assign_BitVar(can_fire_mask,id,false_for_macro);
	UnSet_BitVar(mode_change_button_pressed_mask, id);
	g_plAction[id]=act_none;
}
//----------------------------------------------------------------------------------------------
public sh_client_death(id)
{	
	if(!sh_is_active()){
		
		return
		
	}
	if(!client_is_within_range(id)){
		
		return
	}
	
	Assign_BitVar(can_fire_mask,id,false_for_macro);
	g_plAction[id]=act_none;
}

public pilula_sexual_penetra_player(pToucher, pTouched)
{
	if(!is_valid_ent(pToucher)) return

	if(is_user_alive(pTouched))
	{	
		new id = entity_get_edict(pToucher, EV_ENT_owner);
		//retrieve current pill fx num

		new fx_id:fx_num=fx_id:entity_get_int(pToucher,EV_INT_iuser3)
		make_effect(pTouched,id,5.0,gHeroID,fx_num,false)
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
