#include "../my_include/superheromod.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_gatling_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
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
#define jp_fly "wpnmod/minigun/hw_spin.wav"
new bool:pill_loaded[SH_MAXSLOTS+1][NUM_BARRELS]
new bool:atk2[SH_MAXSLOTS+1]
new bool:atk1[SH_MAXSLOTS+1]
new bool:haswhpnnmg[SH_MAXSLOTS+1]
new bool:delayhud[SH_MAXSLOTS+1]
new bool:frstCLIP[SH_MAXSLOTS+1]
new bool:g_fix_punchangle[SH_MAXSLOTS+1]
new bool:delay[SH_MAXSLOTS+1]
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
	register_forward(FM_UpdateClientData, "fm_UpdateClientDataPost", 1)
	register_forward(FM_StartFrame, "fwd_StartFrame")
	register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
	register_forward(FM_PlayerPostThink, "fwPlayerPostThink", 1)
	
	RegisterHam(Ham_TraceAttack, "player", "Ham_TraceAttackYakuiMinigun",_,true)
	console_print(0,"Ham error value: %d^n",IsHamValid(Ham_TakeDamage))
	
	register_forward(FM_CmdStart, "CmdStart");
	register_cvar("yakui_windup_time", "2.0")
	register_event("ResetHUD","newRound","b")
	register_event("DeathMsg","death","a")
	register_forward(FM_Think, "pill_think")
	unregister_forward(FM_PrecacheEvent, g_fwid, 1)
}
public native_playanim(player,anim)
{
	set_pev(player, pev_weaponanim, anim)
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, player)
	write_byte(anim)
	write_byte(pev(player, pev_body))
	message_end()
}
public event_curweapon(id){
	if(!client_hittable(id,gatling_get_pillgatling(id))) return;	
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo)
	if(weapon == YAKUI_WEAPON_CLASSID){
		if(g_plAction[id] != act_run && frstCLIP[id]){
			new ent = get_weapon_ent(id,weapon)
			if(g_Pillgatling_clip[id] < CLIP_SIZE){
				g_Pillgatling_clip[id] = CLIP_SIZE
			}
			cs_set_weapon_ammo(ent, CLIP_SIZE)
			frstCLIP[id] = false
		}
		if(g_Pillgatling_clip[id] == 0){
			new ent = get_weapon_ent(id,weapon)
			cs_set_weapon_ammo(ent, g_Pillgatling_clip[id])
		}
		if(g_plAction[id] == act_run){
			g_Pillgatling_clip[id] = clip
		}
		message_begin(MSG_ONE, get_user_msgid("CurWeapon"), {0,0,0}, id) 
		write_byte(1) 
		write_byte(CSW_KNIFE) 
		write_byte(0) 
		message_end()
		new	Ent = get_weapon_ent(id,weapon)
		if(Ent)
		{
			set_member(Ent, m_Weapon_flTimeWeaponIdle, PILL_SHOOT_PERIOD)
		}
		ammo_hud(id)
		if(atk1[id]){
			fire_mode(id,Ent, 0)
		}
		if(atk2[id]){
			fire_mode(id,Ent, 1)
		}
		haswhpnnmg[id] = true
	}
	
	if(weapon != YAKUI_WEAPON_CLASSID){
		haswhpnnmg[id] = false
	}
	if((!haswhpnnmg[id])){
		g_plAction[id] = act_none
	}
	return;
 }	
//sound and anim
public fwd_StartFrame() {
	static Float:gtime, id
	
	gtime = get_gametime()
	
	for(id = 1; id <= SH_MAXSLOTS; id++) {
		if(g_plAction[id] != act_none) {
			
			if(!(pev(id, pev_button) & IN_ATTACK) && !(pev(id, pev_button) & IN_USE) && g_lastShot[id] + PILL_SHOOT_PERIOD < gtime) {
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
	if ( !is_user_alive(id)||!client_hittable(id,gatling_get_has_yakui(id)&&gatling_get_pillgatling(id))) return FMRES_IGNORED;
	
	if(sh_get_user_is_asleep(id)) return FMRES_IGNORED
	if(sh_get_user_is_chaffed(id)) return FMRES_IGNORED


	new ent = find_ent_by_owner(-1, YAKUI_WEAPON_NAME, id);
	if(haswhpnnmg[id]){
		static buttons;
		buttons= get_uc(uc_handle, UC_Buttons);
		if(buttons & IN_ATTACK)
		{
			atk2[id] = true
			atk1[id] = false
			
		}
		else if(buttons & IN_USE){

			atk2[id] = true
			atk1[id] = false

		}
		if(atk1[id] && !atk2[id] && (g_plAction[id] == act_none || g_plAction[id] == act_load_up) && g_Pillgatling_clip[id]>0){
			buttons &= ~IN_ATTACK
			buttons &= ~IN_USE
			
			sh_chat_message(id,gatling_get_hero_id(),"You have %d pills in your clip!!",g_Pillgatling_clip[id])
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
	delay[id] = false
}
public _clear_pills(iPlugin,iParams){

	arrayset(pill_fx,0,sh_max_entities())
	new grenada = find_ent_by_class(-1, PILL_CLASSNAME)
	while(grenada) {
		remove_entity(grenada)
		grenada = find_ent_by_class(grenada, PILL_CLASSNAME)
	}
}
shooting_aura(id){

	new origin[3]

	get_user_origin(id, origin, 1)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(27)
	write_coord(origin[0])	//pos
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(15)
	write_byte(random_num(0,255))			// r, g, b
	write_byte(random_num(0,255))		// r, g, b
	write_byte(random_num(0,255))			// r, g, b
	write_byte(3)			// life
	write_byte(1)			// decay
	message_end()

}

//----------------------------------------------------------------------------------------------
public newRound(id)
{
	if(!client_hittable(id,gatling_get_has_yakui(id))){
		return PLUGIN_CONTINUE;
	}

	g_plAction[id] = false
	frstCLIP[id] = true	
	return PLUGIN_CONTINUE
		
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
	if(!client_hittable(player,gatling_get_has_yakui(player)&&gatling_get_pillgatling(player))){
		
		return FMRES_IGNORED
	}
	if((get_user_weapon(player) != YAKUI_WEAPON_CLASSID)){
		return FMRES_IGNORED
	}
	new pEntity = get_member(player, m_pActiveItem)
	if(haswhpnnmg[player]&&is_valid_ent(pEntity)){
		set_cd(cd, CD_flNextAttack,  halflife_time() + 0.001)

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

		g_Pillgatling_clip[id]=get_pdata_int(entity, 51, 4)
		if(type == 0 && g_Pillgatling_clip[id]>0){
			launch_pill(id)
			emit_sound(id, CHAN_WEAPON, m_SOUND[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
			sh_chat_message(id,gatling_get_hero_id(),"You have %d pills remaining!",gatling_get_num_pills(id))
			native_playanim(id, anim_spinfire)
			ammo_hud(id)
		} 
		else { 
			if(!delay[id]) {
				ammo_hud(id)
				emit_sound(id, CHAN_WEAPON, m_SOUND[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
				native_playanim(id, anim_spinidle)
				set_task(GAT_WINDUP_PERIOD,"delayanim",id)
				
				delay[id] = true
			}
		}
	}
	atk1[id] = false
	atk2[id] = false
}
launch_pill(id)
{
	shooting_aura(id)
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
	parm[2]=color[0]
	parm[3]=color[1]
	parm[4]=color[2]
	parm[5]=color[3]
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
	/////////////////////
	//Thantik's he-conc functions
stock get_velocity_from_origin( ent, Float:fOrigin[3], Float:fSpeed, Float:fVelocity[3] )
{
	new Float:fEntOrigin[3];
	entity_get_vector( ent, EV_VEC_origin, fEntOrigin );

		// Velocity = Distance / Time

	new Float:fDistance[3];
	fDistance[0] = fEntOrigin[0] - fOrigin[0];
	fDistance[1] = fEntOrigin[1] - fOrigin[1];
	fDistance[2] = fEntOrigin[2] - fOrigin[2];

	new Float:fTime = ( vector_distance( fEntOrigin,fOrigin ) / fSpeed );

	fVelocity[0] = fDistance[0] / fTime;
	fVelocity[1] = fDistance[1] / fTime;
	fVelocity[2] = fDistance[2] / fTime;

	return ( fVelocity[0] && fVelocity[1] && fVelocity[2] );
}


	// Sets velocity of an entity (ent) away from origin with speed (speed)

stock set_velocity_from_origin( ent, Float:fOrigin[3], Float:fSpeed )
{
	new Float:fVelocity[3];
	get_velocity_from_origin( ent, fOrigin, fSpeed, fVelocity )

	entity_set_vector( ent, EV_VEC_velocity, fVelocity );

	return ( 1 );
}
// show ammo clip
public ammo_hud(id) {
	if(!delayhud[id]) {
		delayhud[id] = true
		new AmmoHud[65]
		new clip = g_Pillgatling_clip[id]
		format(AmmoHud, 64, "Ammo: %i", clip)
		set_hudmessage(200, 100, 0, 1.0 , 1.0, 0, 0.1, 0.1,0.1)
		show_hudmessage(id,"%s",AmmoHud)
		set_task(0.2,"delayhutmsg",id)
	}
}
public pilltrail(parm[])
{
	new pid = parm[0]
	if (pid)
	{
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
		write_byte( TE_BEAMFOLLOW )
		write_short(pid) // entity
		write_short(m_trail)  // model
		write_byte( 10 )       // life
		write_byte( 5 )        // width
		write_byte(parm[2])			// r, g, b
		write_byte(parm[3])		// r, g, b
		write_byte(parm[4])			// r, g, b
		write_byte(parm[5]) // brightness

		message_end() // move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)
	}
}


public vexd_pfntouch(pToucher, pTouched)
{

	if (pToucher <= 0) return
	if (!is_valid_ent(pToucher)) return

	new szClassName[32]
	entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)
	if(equal(szClassName, PILL_CLASSNAME))
	{
		new oid = entity_get_edict(pToucher, EV_ENT_owner)
			//new Float:origin[3],dist

		if((pev(pTouched,pev_solid)==SOLID_SLIDEBOX)){
			if(client_hittable(pTouched))
			{

				if((sh_get_user_effect(pTouched)<KILL)||(sh_get_user_effect(pTouched)>BATH)){
					make_effect_direct(pTouched,oid,pill_fx[pToucher],gatling_get_hero_id())
				}
				remove_entity(pToucher)
			}
		}
			//entity_get_vector(pTouched, EV_VEC_ORIGIN, origin)
		if(pev(pTouched,pev_solid)==SOLID_BSP){

			emit_sound(pToucher, CHAN_WEAPON, EFFECT_SHOT_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			remove_entity(pToucher)
		}

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
	precache_sound(jp_fly)
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
public fwPlaybackEvent(flags, invoker, eventid) {
	if (!(g_guns_eventids_bitsum & (1<<eventid))||!haswhpnnmg[invoker]  || !client_hittable(invoker,gatling_get_has_yakui(invoker)&&gatling_get_pillgatling(invoker))){
		return FMRES_IGNORED
	}

	g_fix_punchangle[invoker] = true

	return FMRES_HANDLED
}

public fwPlayerPostThink(id) {
	if (g_fix_punchangle[id]) {
		g_fix_punchangle[id] = false
		set_pev(id, pev_punchangle, Float:{0.0, 0.0, 0.0})
		return FMRES_HANDLED
	}

	return FMRES_IGNORED
}

//get weapon id
stock get_weapon_ent(id,wpnid=0,wpnName[]="")
{
	// who knows what wpnName will be
	static newName[24];

	// need to find the name
	if(wpnid) get_weaponname(wpnid,newName,23);

	// go with what we were told
	else formatex(newName,23,"%s",wpnName);

	// prefix it if we need to
	if(!equal(newName,"weapon_",7))
		format(newName,23,"weapon_%s",newName);

	return fm_find_ent_by_owner(get_maxplayers(),newName,id);
} 

public delayhutmsg(id){
	delayhud[id]= false
}
