#include "../my_include/superheromod.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_gatling_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_inc_pt2.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "chaff_grenade_inc/sh_chaff_fx.inc"


#include <engine>

#include <fakemeta_util>
#include <reapi>
#include "../my_include/weapons_const.inc"

#define PLUGIN "Superhero yakui mk2 pt2"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

const m_pppPlayer            = 41
const m_fflTimeWeaponIdle        = 48
const m_ffInReload            = 54
const m_fflNextAttack = 83

new bool:pill_loaded[SH_MAXSLOTS+1][NUM_BARRELS]
new atk2[SH_MAXSLOTS+1]
new atk1[SH_MAXSLOTS+1]
new delay[SH_MAXSLOTS+1]
new g_fix_punchangle[SH_MAXSLOTS+1]
new curr_barrel[SH_MAXSLOTS+1]
new g_plAction[SH_MAXSLOTS+1]
new Float:g_nextSound[SH_MAXSLOTS+1]
new Float:g_lastShot[SH_MAXSLOTS+1]
new gPillGatlingEngaged[SH_MAXSLOTS+1]
new g_Pillgatling_clip[SH_MAXSLOTS+1]
new g_fwid
new g_guns_eventids_bitsum
// Sounds
new m_SOUND[][] = {"shmod/yakui/hw_shoot1.wav", "shmod/yakui/hw_spin.wav", "shmod/yakui/hw_spinup.wav", "shmod/yakui/hw_spindown.wav"}
new pill_fx[MAX_ENTITIES]
new Float:windup_time
new const g_guns_events[][] = {"events/m249.sc"}
public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);
	console_print(0, "maximo de entidades: %d^n", sh_max_entities())
	arrayset(pill_fx,0,sh_max_entities())
	for(new i=1;i<=SH_MAXSLOTS;i++){
		arrayset(pill_loaded[i],true,NUM_BARRELS)
	}
	arrayset(curr_barrel,0,SH_MAXSLOTS+1);
	register_event("CurWeapon","event_curweapon","be", "1=1")
	RegisterHam(Ham_Weapon_PrimaryAttack, YAKUI_WEAPON_NAME, "Ham_Weapon_PillGatling",_,true)
	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)
	RegisterHam(Ham_Item_Deploy, YAKUI_WEAPON_NAME, "fw_ItemDeployPre",_,true)
	register_forward(FM_StartFrame, "fwd_StartFrame")
	register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
	register_forward(FM_PlayerPostThink, "fwPlayerPostThink", 1)
	register_event("ResetHUD","newRound","b")
	RegisterHam(Ham_Item_PostFrame, YAKUI_WEAPON_NAME, "Item_PostFrame_Post", 1,true)
		
	RegisterHam(Ham_Weapon_Reload,YAKUI_WEAPON_NAME, "fw_WeaponReloadPre",_,true)
	RegisterHam(Ham_Weapon_Reload, YAKUI_WEAPON_NAME, "fw_Weapon_Reload_Post", 1,true)
	
	RegisterHam(Ham_TraceAttack, "player", "Ham_TraceAttackYakuiMinigun",_,true)
	console_print(0,"Ham error value: %d^n",IsHamValid(Ham_TakeDamage))
	
	register_forward(FM_CmdStart, "CmdStart");
	register_logevent("event_start", 2, "1=Round_Start")
	register_cvar("yakui_windup_time", "2.0")
	register_event("DeathMsg","death","a")
	register_forward(FM_Think, "pill_think")
	unregister_forward(FM_PrecacheEvent, g_fwid, 1)
}


public Item_PostFrame_Post(iEnt)
{    
	if (!sh_is_active()){
		return HAM_IGNORED
	}
	if(pev_valid(iEnt) != 2){
		return HAM_IGNORED
	}
	new id = entity_get_edict(iEnt, EV_ENT_owner);
	
	if(!client_hittable(id,gatling_get_has_yakui(id)&&gatling_get_pillgatling(id))){
		
		return HAM_IGNORED
	}
	static Float:flNextAttack; flNextAttack = get_pdata_float(id, m_fflNextAttack, 5)
	static bpammo; bpammo = cs_get_user_bpammo(id, YAKUI_WEAPON_CLASSID)
	
	static iClip; iClip = get_pdata_int(iEnt, 51, 4)
	static fInReload; fInReload = get_pdata_int(iEnt, m_ffInReload , 4)
	
	if(fInReload && flNextAttack <= 0.0)
	{
		static temp1
		temp1 = min(CLIP_SIZE - iClip, bpammo)

		set_pdata_int(iEnt, 51, iClip + temp1, 4)
		cs_set_user_bpammo(id, YAKUI_WEAPON_CLASSID, bpammo - temp1)		
		
		set_pdata_int(iEnt, m_ffInReload , 0, 4)
		
		fInReload = 0
		new Float:fDelay = floatdiv(g_fReloadDelay[YAKUI_WEAPON_CLASSID], windup_time)
		set_pdata_float(get_pdata_cbase(iEnt, m_pppPlayer, 4), m_fflNextAttack, fDelay, 5)
		set_pdata_float(iEnt, m_fflTimeWeaponIdle, fDelay + 0.5, 4)
	}
	return HAM_IGNORED
} 
public native_playanim(player,anim)
{
	set_pev(player, pev_weaponanim, anim)
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, player)
	write_byte(anim)
	write_byte(pev(player, pev_body))
	message_end()
}

public Ham_Weapon_PillGatling(weapon_ent)
{
	if ( !sh_is_active() ) return HAM_IGNORED

	new owner = get_pdata_cbase(weapon_ent, m_ppPlayer, XO_WEAPON)
	if(!client_hittable(owner,gatling_get_has_yakui(owner))) return HAM_IGNORED
	if(!gatling_get_pillgatling(owner)||(g_plAction[owner]!=act_run)){
		return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}
public fwPlaybackEvent(flags, invoker, eventid) {
	if (!(g_guns_eventids_bitsum & (1<<eventid)) || !client_hittable(invoker,gatling_get_has_yakui(invoker)&&gatling_get_pillgatling(invoker))){
		return FMRES_IGNORED
	}

	g_fix_punchangle[invoker] = 1

	return FMRES_HANDLED
}
public fwPlayerPostThink(id) {
	if (g_fix_punchangle[id]) {
		g_fix_punchangle[id] = 0
		set_pev(id, pev_punchangle, Float:{0.0, 0.0, 0.0})
		return FMRES_HANDLED
	}

	return FMRES_IGNORED
}
public event_curweapon(id){
	if(!client_hittable(id,gatling_get_has_yakui(id))) return PLUGIN_CONTINUE;	
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo)
	if(weapon == YAKUI_WEAPON_CLASSID){
		if(!gatling_get_pillgatling(id)){
			atk2[id]=atk1[id]=0
			return PLUGIN_HANDLED
		}
		if(g_plAction[id] == act_run){
			g_Pillgatling_clip[id] = clip
		}
		new	Ent = find_ent_by_owner(-1, YAKUI_WEAPON_NAME, id);
		if(Ent)
		{
			do_fast_shot(id,weapon,float(NUM_BARRELS))
		}
		if(atk1[id]){
			fire_mode(id,Ent, 0)
		}
		if(atk2[id]){
			fire_mode(id,Ent, 1)
		}
	}
	else{
		g_plAction[id] = act_none
	}
	return PLUGIN_CONTINUE
 }
//sound and anim
public fwd_StartFrame() {
	static Float:gtime, id
	
	gtime = get_gametime()
	
	for(id = 1; id <= SH_MAXSLOTS; id++) {
		if(g_plAction[id] != act_none) {
			
			if(!(pev(id, pev_button) & IN_ATTACK) && !(pev(id, pev_button) & IN_USE) && g_lastShot[id] + PILL_SHOOT_PERIOD< gtime) {
				native_playanim(id, anim_spinidledown)
				emit_sound(id, CHAN_WEAPON, m_SOUND[3], 1.0, ATTN_NORM, 0, PITCH_NORM)
				g_nextSound[id] = gtime + windup_time
				g_plAction[id] = act_none
			}
		}
	}
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
public Ham_TraceAttackYakuiMinigun(id, idattacker, Float:damage, Float:direction[3], ptr, damagebits)
{
	
	if(!is_user_connected(idattacker)){
		return HAM_IGNORED	
	}
	if(get_user_weapon(idattacker) != YAKUI_WEAPON_CLASSID|| !gatling_get_has_yakui(idattacker)){
		return HAM_IGNORED
	}
	
	damage=0.0;
	return HAM_SUPERCEDE
	
}
public plugin_natives(){


	register_native("gatling_set_pill_fx_num","_gatling_set_pill_fx_num",0);
	register_native("gatling_get_pill_fx_num","_gatling_get_pill_fx_num",0);
	register_native("gatling_set_pillgatling","_gatling_set_pillgatling",0);
	register_native("gatling_get_pillgatling","_gatling_get_pillgatling",0);
	register_native( "clear_pills","_clear_pills",0)


}
public _gatling_get_pill_fx_num(iPlugin,iParams){


	new pillid= get_param(1)
	return pill_fx[pillid]

}

public _gatling_set_pill_fx_num(iPlugin,iParams){


	new pillid= get_param(1)
	new value_to_set= get_param(2)
	pill_fx[pillid]=value_to_set

}
public _gatling_get_pillgatling(iPlugin,iParams){
	new id=get_param(1)
	return gPillGatlingEngaged[id]

}
public _gatling_set_pillgatling(iPlugin,iParams){

	new id= get_param(1)
	new value_to_set= get_param(2)
	gPillGatlingEngaged[id]=value_to_set;
}


//----------------------------------------------------------------------------------------------
public CmdStart(id, uc_handle)
{
	if ( !is_user_alive(id)||!client_hittable(id,gatling_get_has_yakui(id))) return FMRES_IGNORED;
	
	if(sh_get_user_is_asleep(id)) return FMRES_IGNORED
	if(sh_get_user_is_chaffed(id)) return FMRES_IGNORED


	new ent = find_ent_by_owner(-1, YAKUI_WEAPON_NAME, id);
	new clip,ammo,weapon=get_user_weapon(id,clip,ammo)
	if((weapon==YAKUI_WEAPON_CLASSID)){
		static buttons;
		buttons= get_uc(uc_handle, UC_Buttons);
		if(buttons & IN_ATTACK)
		{
			atk1[id] = gatling_get_pillgatling(id)
			atk2[id] = 0
			
		}
		else if(buttons & IN_USE){

			atk2[id] = gatling_get_pillgatling(id)
			atk1[id] = 0

		}
		if(atk1[id] && !atk2[id] && (g_plAction[id] == act_none || g_plAction[id] == act_load_up) && g_Pillgatling_clip[id]>0){
			buttons &= ~IN_ATTACK
			buttons &= ~IN_USE
			
			set_uc(uc_handle, UC_Buttons, buttons)
			fire_mode(id,ent,0)
		} else if(atk2[id] || atk1[id] && g_Pillgatling_clip[id]==0){
			fire_mode(id,ent,1)
		}
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

	windup_time=get_cvar_float("yakui_windup_time")
}
public delayanim(id){
	delay[id] = 0
}
public _clear_pills(iPlugin,iParams){

	arrayset(pill_fx,0,sh_max_entities())
	new grenada = find_ent_by_class(-1, PILL_CLASSNAME)
	while(grenada) {
		remove_entity(grenada)
		grenada = find_ent_by_class(grenada, PILL_CLASSNAME)
	}
}
public fw_WeaponReloadPre(entity)
{
	if(pev_valid(entity)!=2)
		return HAM_IGNORED
	new pPlayer = get_member(entity, m_pPlayer)
	
	if(!client_hittable(pPlayer,gatling_get_has_yakui(pPlayer)&&gatling_get_pillgatling(pPlayer))){
		
		return HAM_IGNORED
	}
	g_Pillgatling_clip[pPlayer] = -1
	static BPAmmo; BPAmmo = cs_get_user_bpammo(pPlayer, YAKUI_WEAPON_CLASSID)
	static iClip; iClip = get_pdata_int(entity, 51, 4)
	
	if(BPAmmo < 0){
		return HAM_SUPERCEDE
	}
	if(iClip >= CLIP_SIZE){
		return HAM_SUPERCEDE		
	}
	g_Pillgatling_clip[pPlayer] = iClip
	return HAM_HANDLED
}
public fw_Weapon_Reload_Post(ent)
{
	if(pev_valid(ent)!=2)
		return HAM_IGNORED
		
	static id; id = pev(ent, pev_owner)
	if(!client_hittable(id,gatling_get_has_yakui(id)&&gatling_get_pillgatling(id))){
		
		return HAM_IGNORED
	}
	if((get_pdata_int(ent, 54, 4) == 1))
	{ 
	
		if(g_Pillgatling_clip[id] == -1)
			return HAM_IGNORED
		
		set_pdata_int(ent, 51, g_Pillgatling_clip[id], 4)
	}
	
	
	return HAM_HANDLED
}


public fm_UpdateClientDataPost(player, sendWeapons, cd)
{
	if(!client_hittable(player,gatling_get_has_yakui(player))){
		
		return FMRES_IGNORED
	}
	if((get_user_weapon(player) != YAKUI_WEAPON_CLASSID)){
		return FMRES_IGNORED
	}
	new pEntity = get_member(player, m_pActiveItem)
	if(gatling_get_pillgatling(player)&&is_valid_ent(pEntity)){
		set_cd(cd, CD_flNextAttack,  halflife_time() + 999999.0)

	}
	return FMRES_HANDLED
}

// in fire
fire_mode(id,entity, type) {
	
	static Float:gtime
	gtime = get_gametime()
	g_lastShot[id] = gtime

	if(g_nextSound[id] <= gtime){
		switch(g_plAction[id]) {
			case act_none: {
				
				native_playanim(id, anim_spinup)
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

		if(type == 0 && g_Pillgatling_clip[id]>0){
			g_Pillgatling_clip[id]=get_pdata_int(entity, 51, 4)
			launch_pill(id)
			emit_sound(id, CHAN_WEAPON, m_SOUND[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
			native_playanim(id, anim_spinfire)
		} 
		else { 
			if(!delay[id]) {
				emit_sound(id, CHAN_WEAPON, m_SOUND[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
				native_playanim(id, anim_spinidle)
				set_task(GAT_WINDUP_PERIOD,"delayanim",id)
				
				delay[id] = 1
			}
		}
	}
	atk1[id] = 0
	atk2[id] = 0
}
launch_pill(id)
{
	
	entity_set_int(id, EV_INT_weaponanim, 3)

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

	VelocityByAim(id, floatround(PILL_SPEED) , Velocity)
	entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

	set_pev(Ent, pev_vuser1, Velocity)
	pill_loaded[id][curr_barrel[id]] = false

	gatling_dec_num_pills(id)
	new parm[6]
	new fx_num=sh_gen_effect()
	pill_fx[Ent]=fx_num
	new color[4]
	sh_get_pill_color(fx_num,id,color)
	parm[0] = Ent
	parm[1] =id
	for(new i=0;i<sizeof color;i++){
		parm[i+2]=color[i]
	}
	aura(id,color,3,1)
	emit_sound(id, CHAN_WEAPON, m_SOUND[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_task(0.01, "pilltrail",id,parm,6)

	entity_set_float( Ent, EV_FL_nextthink, get_gametime( ) + 0.05 );
	parm[0] = id
	parm[1] = curr_barrel[id]
	curr_barrel[id]=(((curr_barrel[id]+1)<NUM_BARRELS)?curr_barrel[id]+1:0)
	set_task(PILL_SHOOT_PERIOD, "pill_reload",id+PILL_RELOAD_TASKID,parm,2)

	return PLUGIN_CONTINUE
}

	//----------------------------------------------------------------------------------------------
public pill_think(ent)
{

	if(!pev_valid(ent)){

		return

	}
	new szClassName[32]
	entity_get_string(ent, EV_SZ_classname, szClassName, 31)
	if(!equal(szClassName, PILL_CLASSNAME))
	{
		return;
	}
	new id=pev(ent,pev_owner)
	if (!client_hittable(id,gatling_get_has_yakui(id))) {
		remove_entity(ent)
		return
	}
	new Float:newVelocity[3],Float:velocityVec[ 3 ]
	entity_get_vector( ent, EV_VEC_velocity, velocityVec );
	entity_get_vector( ent, EV_VEC_velocity, newVelocity );



	velocityVec[0] = velocityVec[0]+(random_float(-1.0,1.0)*PILL_MASS)
	velocityVec[1] = velocityVec[1]+(random_float(-1.0,1.0)*PILL_MASS)

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
public pill_reload(parm[])
{
	if(!client_hittable(parm[0],gatling_get_has_yakui(parm[0]))) return
	pill_loaded[parm[0]][parm[1]]=true
	
}


public pilltrail(parm[])
{
	new pid = parm[0]
	new the_fucking_argument[4];
	for(new i=0;i<sizeof the_fucking_argument;i++){
		the_fucking_argument[i]=parm[2+i]
	}
	trail_custom(pid,the_fucking_argument,10,5)
}

public fw_ItemDeployPre(entity)
{
	if(pev_valid(entity)!=2)
		return HAM_IGNORED
		
	new pPlayer = get_member(entity, m_pPlayer)
	
	if(!client_hittable(pPlayer,gatling_get_has_yakui(pPlayer)&&gatling_get_pillgatling(pPlayer))){
		
		return HAM_IGNORED
	}

	native_playanim(pPlayer, anim_draw)
	ExecuteHam(Ham_Item_Deploy, entity)
	set_member(pPlayer, m_flNextAttack, PILL_DEPLOY_TIME)
	set_member(entity, m_Weapon_flTimeWeaponIdle, PILL_DEPLOY_TIME)
	set_pdata_int(entity, 51,min(CLIP_SIZE,get_pdata_int(entity, 51, 4)), 4)
	return HAM_SUPERCEDE
}

//----------------------------------------------------------------------------------------------
public newRound(id)
{	
	if(sh_is_active()&&client_hittable(id,gatling_get_has_yakui(id))){
		atk1[id]=0;
		atk2[id]=0;
		g_plAction[id]=act_none;
	}
	return PLUGIN_HANDLED
	
}

public event_start(){
	static iPlayers[32], iPlayersNum, i 
	get_players(iPlayers, iPlayersNum, "a") 
	for (i = 0; i <= iPlayersNum; ++i){
		newRound(i)
	}
}
public vexd_pfntouch(pToucher, pTouched)
{

	if (pev_valid(pToucher)!=2){
		
		return
	}

	new szClassName[32]
	entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)
	if(equal(szClassName, PILL_CLASSNAME))
	{
		
		new oid = entity_get_edict(pToucher, EV_ENT_owner)
		new Float:hit_orig[3]

		if (pev_valid(pTouched)!=2){
			emit_sound(pToucher, CHAN_WEAPON, EFFECT_SHOT_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			make_sparks(hit_orig);
			gun_shot_decal(hit_orig);
			remove_entity(pToucher)
			return
		}
		entity_get_vector(pToucher,EV_VEC_origin,hit_orig);
		if((pev(pTouched,pev_solid)==SOLID_SLIDEBOX)){
			if(client_hittable(pTouched))
			{

				if((sh_get_user_effect(pTouched)<KILL)||(sh_get_user_effect(pTouched)>BATH)){
					make_effect_direct(pTouched,oid,pill_fx[pToucher],gatling_get_hero_id())
				}
			}
		}
		else if(pev(pTouched,pev_solid)==SOLID_BSP){

			emit_sound(pToucher, CHAN_WEAPON, EFFECT_SHOT_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			make_sparks(hit_orig);
			gun_shot_decal(hit_orig);
		}
		remove_entity(pToucher)
	}
}
public remove_pill(id_pill){
	id_pill-=PILL_REM_TASKID

	remove_entity(id_pill)


}
public plugin_precache()
{
	precache_model("models/shell.mdl")
	precache_explosion_fx()
	precache_model(GATLING_P_MODEL)
	precache_model(GATLING_V_MODEL)
	g_fwid = register_forward(FM_PrecacheEvent, "fwPrecacheEvent", 1)
	engfunc(EngFunc_PrecacheSound, EFFECT_SHOT_SFX)
	precache_sound(m_SOUND[0])
	precache_sound(m_SOUND[1])
	precache_sound(m_SOUND[2])
	precache_sound(m_SOUND[3])

}

public death()
{
	new id = read_data(2)
		//new killer= read_data(1)

	if(!is_user_connected(id)||!sh_is_active()||!gatling_get_has_yakui(id)) return


}