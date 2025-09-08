#include "../my_include/superheromod.inc"
#include "ksun_inc/sh_sleep_grenade_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "ksun_inc/ksun_global.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include <fakemeta_util>


#define PLUGIN "Superhero ksun sleep grenades"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new bool:sleep_nade_loaded[SH_MAXSLOTS+1]

new bool:sleep_nade_armed[SH_MAXSLOTS+1]
new Float:curr_charge[SH_MAXSLOTS+1]

new Float:min_charge_time,Float:max_charge_time
new hud_sync_charge
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//handle when player presses attack2
	
	arrayset(sleep_nade_loaded,true,SH_MAXSLOTS+1)
	arrayset(sleep_nade_armed,false,SH_MAXSLOTS+1)
	arrayset(curr_charge,0.0,SH_MAXSLOTS+1)
	register_forward(FM_CmdStart, "CmdStart");
	register_cvar("ksun_sleep_nade_max_charge_time", "5.0")
	register_cvar("ksun_sleep_nade_min_charge_time", "1.0")
	hud_sync_charge=CreateHudSyncObj()
}

public plugin_natives(){
	
	
	register_native( "clear_sleep_nades","_clear_sleep_nades",0)
	register_native( "sleep_nade_get_sleep_nade_loaded","_sleep_nade_get_sleep_nade_loaded",0)
	register_native( "sleep_nade_uncharge_sleep_nade","_sleep_nade_uncharge_sleep_nade",0)
	
	
}
//----------------------------------------------------------------------------------------------
public CmdStart(id, uc_handle)
{
	if ( !is_user_alive(id)||!spores_has_ksun(id)||!hasRoundStarted()||client_isnt_hitter(id)) return FMRES_IGNORED;
	
	
	new button = get_uc(uc_handle, UC_Buttons);
	new ent = find_ent_by_owner(-1, "weapon_flashbang", id);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if(weapon==CSW_FLASHBANG){
		if(button & IN_ATTACK)
		{
			button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, button);
			if( !(is_user_alive(id))||!sleep_nade_loaded[id]) return FMRES_IGNORED
			if(ksun_get_num_sleep_nades(id) == 0)
			{
				client_print(id, print_center, "Sorry, dear... No more sleep grenades, I am afraid.")
				sh_drop_weapon(id,CSW_HEGRENADE,true)
				uncharge_user(id)
				return FMRES_IGNORED
			}
			if(!sleep_nade_armed[id]){
				sleep_nade_armed[id]=true
				curr_charge[id]=0.0
				charge_user(id)
				
			}
			
		}
		else if(sleep_nade_armed[id]){
			if(curr_charge[id]>=min_charge_time){
				launch_sleep_nade(id)
				client_print(id,print_center,"You have %d gas grenades left, darling. I repeat, %d",
				ksun_get_num_sleep_nades(id),ksun_get_num_sleep_nades(id)
				);
			}
			else if(curr_charge[id]>0.0){
				sh_chat_message(id,spores_ksun_hero_id(),"You have to charge them, darling...");
				
			}
			uncharge_user(id)
			
		}
	}
	else
	{
		uncharge_user(id)
	}
	if(ent){
		cs_set_user_bpammo(id, CSW_FLASHBANG,ksun_get_num_sleep_nades(id));
		
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
	
	max_charge_time=get_cvar_float("ksun_sleep_nade_max_charge_time")
	min_charge_time=get_cvar_float("ksun_sleep_nade_min_charge_time")
}


public charge_task(id){
	id-=SLEEP_NADE_CHARGE_TASKID
	new hud_msg[300];
	new encouragement[128]
	curr_charge[id]=floatadd(curr_charge[id],SLEEP_NADE_CHARGE_PERIOD)
	new Float:curr_charge_pct=100.0*(curr_charge[id]/max_charge_time);
	if(curr_charge_pct>20.0 && curr_charge_pct<40.0){
		
		format(encouragement,127,"yes, thats it. Keep going, sweetie.^n")
		
	}
	else if(curr_charge_pct<60.0){
		
		format(encouragement,127,"Yes! thats it. Just like that, darling.^n")
		
	}
	else if(curr_charge_pct<80.0){
		
		format(encouragement,127,"Yes! come on dear! Just a bit more!^n")
		
	}
	else if(curr_charge_pct<100.0){
		format(encouragement,127,"OH MY GOD, YES! MORE! MORE! YES!!!^n")
		
		
	}
	format(hud_msg,299,"[SH]: Curr charge: %0.2f^n%s",
	curr_charge_pct,encouragement
	);
	set_hudmessage(LineColors[PURPLE][0], LineColors[PURPLE][1],LineColors[PURPLE][2], -1.0, -1.0,125, 0.0, 0.5,0.0,0.0,1)
	ShowSyncHudMsg(id, hud_sync_charge, "%s", hud_msg)
	
	
	
	
	
	
}
charge_user(id){
	set_task(SLEEP_NADE_CHARGE_PERIOD,"charge_task",id+SLEEP_NADE_CHARGE_TASKID,"", 0,  "a",SLEEP_NADE_CHARGE_TIMES)
	set_task(floatmul(SLEEP_NADE_CHARGE_PERIOD,float(SLEEP_NADE_CHARGE_TIMES))+1.0,"uncharge_task",id+UNSLEEP_NADE_CHARGE_TASKID,"", 0,  "a",1)
	return 0
	
	
	
}
public _sleep_nade_uncharge_sleep_nade(iPlugin,iParams){
	new id=get_param(1)
	uncharge_user(id)
	
	
}
public uncharge_task(id){
	id-=UNSLEEP_NADE_CHARGE_TASKID
	remove_task(id+SLEEP_NADE_CHARGE_TASKID)
	sleep_nade_armed[id]=false
	return 0
	
	
	
}

uncharge_user(id){
	remove_task(id+UNSLEEP_NADE_CHARGE_TASKID)
	remove_task(id+SLEEP_NADE_CHARGE_TASKID)
	sleep_nade_armed[id]=false
	return 0
	
	
	
}
/*client_hittable(gatling_user,vic_userid,CsTeams:gatling_team){

return ((gatling_user==vic_userid))||(is_user_connected(vic_userid)&&is_user_alive(vic_userid)&&vic_userid&&(gatling_team!=cs_get_user_team(vic_userid)))

}*/
client_isnt_hitter(gatling_user){


return (!spores_has_ksun(gatling_user)||!is_user_connected(gatling_user)||!is_user_alive(gatling_user)||gatling_user <= 0 || gatling_user > SH_MAXSLOTS)

}

public _clear_sleep_nades(iPlugin,iParams){

new grenada = find_ent_by_class(-1, SLEEP_NADE_CLASSNAME)
while(grenada) {
	remove_entity(grenada)
	grenada = find_ent_by_class(grenada, SLEEP_NADE_CLASSNAME)
}
}
public _sleep_nade_get_sleep_nade_loaded(iPlugin,iParams){

new id=get_param(1)
return sleep_nade_loaded[id]

}
launch_sleep_nade(id)
{
entity_set_int(id, EV_INT_weaponanim, 3)

new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

entity_get_vector(id, EV_VEC_origin , Origin)
entity_get_vector(id, EV_VEC_v_angle, vAngle)


Ent = create_entity("info_target")

if (!Ent) return PLUGIN_HANDLED

entity_set_string(Ent, EV_SZ_classname, SLEEP_NADE_CLASSNAME)
entity_set_model(Ent,SLEEP_NADE_W_MODEL)

new Float:MinBox[3] = {-1.0, -1.0, -1.0}
new Float:MaxBox[3] = {1.0, 1.0, 1.0}
entity_set_vector(Ent, EV_VEC_mins, MinBox)
entity_set_vector(Ent, EV_VEC_maxs, MaxBox)


Origin[2]+=50.0
entity_set_origin(Ent, Origin)
entity_set_vector(Ent, EV_VEC_angles, vAngle)

entity_set_int(Ent, EV_INT_effects, 2)
entity_set_int(Ent, EV_INT_solid, 1)
entity_set_int(Ent, EV_INT_movetype, 10)
entity_set_edict(Ent, EV_ENT_owner, id)

VelocityByAim(id, floatround(SLEEP_NADE_SPEED*(curr_charge[id]/max_charge_time)) , Velocity)
entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

sleep_nade_loaded[id] = false

ksun_dec_num_sleep_nades(id)

new parm[1]
parm[0] = Ent
emit_sound(id, CHAN_WEAPON, SLEEP_NADE_THROW_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

sh_chat_message(id, spores_ksun_hero_id(),"Ohh! My god, darling! You are amazing... Thank you so much for this [forehead kiss]")
set_task(0.01, "sleep_nade_trail",id,parm,1)

return PLUGIN_CONTINUE
}

public sleep_nade_reload(parm[])
{
if(!is_user_alive(parm[0])||!spores_has_ksun(parm[0])||!is_user_connected(parm[0])) return
sleep_nade_loaded[parm[0]] = true
new clip,ammo,wid=get_user_weapon(parm[0],clip,ammo)
if((wid==CSW_FLASHBANG)&&ksun_get_num_sleep_nades(parm[0])){
entity_set_string(parm[0], EV_SZ_viewmodel, SLEEP_NADE_V_MODEL)
}
}
public sleep_nade_trail(parm[])
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
write_byte(180)			// r, g, b
write_byte(180)		// r, g, b
write_byte(180)			// r, g, b
write_byte(120) // brightness

message_end() // move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)
}
}


public blow_sleep_nade_up(id_sleep_nade){
id_sleep_nade-=SLEEP_NADE_BLAST_TASKID

if ( !is_valid_ent(id_sleep_nade) ) return

new szClassName[32]
Entvars_Get_String(id_sleep_nade, EV_SZ_classname, szClassName, 31)

if(equal(szClassName, SLEEP_NADE_CLASSNAME)) {

new Float:fl_vExplodeAt[3]
Entvars_Get_Vector(id_sleep_nade, EV_VEC_origin, fl_vExplodeAt)
new vExplodeAt[3]
vExplodeAt[0] = floatround(fl_vExplodeAt[0])
vExplodeAt[1] = floatround(fl_vExplodeAt[1])
vExplodeAt[2] = floatround(fl_vExplodeAt[2])
new id = Entvars_Get_Edict(id_sleep_nade, EV_ENT_owner)
new origin[3],dist,i
make_shockwave(vExplodeAt, SLEEP_NADE_RADIUS, {180,180,180,120})
emit_sound(id_sleep_nade, CHAN_WEAPON, SLEEP_NADE_BURST_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

for ( i = 1; i <= SH_MAXSLOTS; i++) {
	
	if( !client_hittable(i) ) continue
	get_user_origin(i,origin)
	dist = get_distance(origin,vExplodeAt)
	if (dist <= SLEEP_NADE_RADIUS) {
		
		sh_sleep_user(i,id,spores_ksun_hero_id())
		
	}
}

new parm[1]
parm[0]=id
remove_sleep_nade(parm,id_sleep_nade+SLEEP_NADE_REM_TASKID)
}

}

public vexd_pfntouch(pToucher, pTouched)
{

if (pToucher <= 0) return
if (!is_valid_ent(pToucher)) return

new szClassName[32]
entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)
if(equal(szClassName,SLEEP_NADE_CLASSNAME))
{
	if(pev(pTouched,pev_solid)==SOLID_BSP){
		emit_sound(pToucher, CHAN_WEAPON, SLEEP_NADE_BURST_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		blow_sleep_nade_up(pToucher+SLEEP_NADE_BLAST_TASKID)
	}

}
}


public remove_sleep_nade(parm[],id_sleep_nade){
id_sleep_nade-=SLEEP_NADE_REM_TASKID
if(!is_valid_ent(id_sleep_nade)) return
sleep_nade_loaded[parm[0]]=true
remove_entity(id_sleep_nade)


}
public plugin_precache()
{
	precache_explosion_fx()

	precache_model(SLEEP_NADE_V_MODEL);
	precache_model(SLEEP_NADE_W_MODEL);
	precache_model(SLEEP_NADE_P_MODEL);

	engfunc(EngFunc_PrecacheSound, SLEEP_NADE_BURST_SFX)
	engfunc(EngFunc_PrecacheSound, SLEEP_NADE_THROW_SFX)



}
