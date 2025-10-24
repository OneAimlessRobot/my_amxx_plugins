#include "../my_include/superheromod.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_gatling_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include <engine>

#define PLUGIN "Superhero yakui mk2 pt2"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum
#define jp_fly "wpnmod/minigun/hw_spin.wav"
new bool:pill_loaded[SH_MAXSLOTS+1]
new bool:gat_wound_up[SH_MAXSLOTS+1]
new bool:gat_wound_triggered[SH_MAXSLOTS+1]
new Float:gat_wound_time[SH_MAXSLOTS+1]
new gPillGatlingEngaged[SH_MAXSLOTS+1]

new pill_fx[MAX_ENTITIES]
new Float:windup_time
new const gunsound[] = "shmod/yakui/m249-1.wav";
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//handle when player presses attack2
	console_print(0, "maximo de entidades: %d^n", sh_max_entities())
	arrayset(pill_fx,0,sh_max_entities())
	arrayset(pill_loaded,true,SH_MAXSLOTS+1)
	arrayset(gat_wound_up,false,SH_MAXSLOTS+1)
	arrayset(gat_wound_triggered,false,SH_MAXSLOTS+1)
	arrayset(gat_wound_time,0.0,SH_MAXSLOTS+1)
	register_forward(FM_CmdStart, "CmdStart");
	register_cvar("yakui_windup_time", "2.0")
	register_event("DeathMsg","death","a")
	register_event("ResetHUD","newRound","b")
	register_forward(FM_Think, "pill_think")
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
	if(!hasRoundStarted()){
	
		uncharge_user(id)
		return FMRES_IGNORED
	}
	
	
	static button;
	button= get_uc(uc_handle, UC_Buttons);
	new ent = find_ent_by_owner(-1, "weapon_m249", id);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	new bool:firing=false
	if(weapon==CSW_M249){
		if(button & IN_ATTACK)
		{
			firing=true
			button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, button);
			if( !gatling_get_pillgatling(id) || !(is_user_alive(id))||!pill_loaded[id]){
				
			}
			else if(gatling_get_num_pills(id) == 0)
			{
				client_print(id, print_center, "You are out of pills")
			}
			else if(!gat_wound_up[id])
			{
				client_print(id, print_center, "You are not wound up!")
			}
			else {
				launch_pill(id)
			}
			return FMRES_IGNORED
			
		}
		if(button & IN_USE){
			
			
			button &= ~IN_USE;
			set_uc(uc_handle, UC_Buttons, button);
			if(!gat_wound_triggered[id]){
				gat_wound_triggered[id]=true
				gat_wound_time[id]=0.0
				charge_user(id)
				
			}
			
		}
		else if(!firing){
			
			uncharge_user(id)
			gat_wound_time[id]=0.0
			gat_wound_triggered[id]=false
			gat_wound_up[id]=false
		}
	}
	else{
		
		uncharge_user(id)
		gat_wound_triggered[id]=false
		gat_wound_up[id]=false
	}
	if(ent)
	{
		cs_set_weapon_ammo(ent, -1);
		cs_set_user_bpammo(id, CSW_M249, gatling_get_num_pills(id));
	}
	
	return FMRES_IGNORED;
}


	//----------------------------------------------------------------------------------------------
public newRound(id)
{
	
	if ( is_user_connected(id)&&is_user_alive(id) && shModActive() ) {
		
		gat_wound_time[id]=0.0
		gat_wound_triggered[id]=false
		gat_wound_up[id]=false
	}
	return PLUGIN_HANDLED
	
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
public charge_task(id){
	id-=GAT_WINDUP_TASKID
	new hud_msg[128];
	gat_wound_time[id]=floatmin(windup_time,floatadd(gat_wound_time[id],GAT_WINDUP_PERIOD))
	emit_sound(id, CHAN_WEAPON, jp_fly, 1.0, ATTN_NORM, 0, PITCH_NORM)
	if(gat_wound_time[id]<(windup_time*0.75)){
		format(hud_msg,127,"[SH]: Curr windup: %0.2f^n",
			100.0*(gat_wound_time[id]/windup_time)
		);
		client_print(id,print_center,"%s",hud_msg)
	}
	else{
		gat_wound_up[id]=true
		emit_sound(id, CHAN_WEAPON, jp_fly, 1.0, ATTN_NORM, SND_STOP, PITCH_NORM)
	}
}
charge_user(id){
	set_task(GAT_WINDUP_PERIOD,"charge_task",id+GAT_WINDUP_TASKID,"", 0,  "b")
	return 0
	
	
	
}

uncharge_user(id){
	remove_task(id+UNGAT_WINDUP_TASKID)
	remove_task(id+GAT_WINDUP_TASKID)
	emit_sound(id, CHAN_WEAPON, jp_fly, 1.0, ATTN_NORM, SND_STOP, PITCH_NORM)
	gat_wound_triggered[id]=false
	return 0
	
	
	
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
	pill_loaded[id] = false
	
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
	emit_sound(id, CHAN_WEAPON, gunsound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		//if(get_cvar_num("veronika_m203trail"))
	set_task(0.01, "pilltrail",id,parm,6)
	
	entity_set_float( Ent, EV_FL_nextthink, get_gametime( ) + 0.05 );
	parm[0] = id
	set_task(PILL_SHOOT_PERIOD, "pill_reload",id+PILL_RELOAD_TASKID,parm,1)
	
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
	pill_loaded[parm[0]] = true
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
	engfunc(EngFunc_PrecacheSound, EFFECT_SHOT_SFX)
	engfunc(EngFunc_PrecacheSound, gunsound)
	
}

public death()
{
	new id = read_data(2)
		//new killer= read_data(1)
	
	if(!is_user_connected(id)||!sh_is_active()||!gatling_get_has_yakui(id)) return
	
	uncharge_user(id)
	gat_wound_time[id]=0.0
	gat_wound_triggered[id]=false
	gat_wound_up[id]=false
	
}
