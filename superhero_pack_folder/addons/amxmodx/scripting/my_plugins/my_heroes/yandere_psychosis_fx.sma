#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "chaff_grenade_inc/sh_chaff_fx.inc"
#include "jetplane_inc/sh_yandere_get_set.inc"
#include "yandere_inc/sh_yandere_inc.inc"
#include "yandere_inc/sh_yandere_psychosis.inc"


#define PLUGIN "Superhero psychosis fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	arrayset(g_yandere_leaped,true,SH_MAXSLOTS+1)
	register_event("DeathMsg","on_death_psychosis","a")
	register_cvar("yandere_psychosis_time", "5")
	register_cvar("yandere_psychosis_zoom", "5")
	register_cvar("yandere_psychosis_add_ap", "5")
	register_cvar("yandere_psychosis_dmg_cushion", "5")
	register_cvar("yandere_psychosis_cooldown", "30")
	register_cvar("yandere_psychosis_cooldown", "30")
	register_cvar("yandere_psychosis_degen_mult", "30")
	register_cvar("yandere_psychosis_degen_health_threshold", "50.0")
	RegisterHam(Ham_TakeDamage,"player","psychosis_ham_damage",_,true)
	MsgSetFOV = get_user_msgid("SetFOV")
	register_forward(FM_CmdStart, "psychosis_leap")
	init_hud_syncs()
	
}

public psychosis_ham_damage(id, idinflictor, attacker, Float:damage, damagebits)
{
if ( !sh_is_active() || !client_hittable(id)||!client_hittable(attacker) ||(id==attacker)) return HAM_IGNORED
new CsTeams:att_team,CsTeams:vic_team;
new bool:clients_here_are_same_team=sh_clients_are_same_team(id,attacker,vic_team,att_team)
if(yandere_get_has_yandere(id)&&!(clients_here_are_same_team)&&yandere_get_is_super(id)&&yandere_get_user_is_psychosis(id)){
	
	damage=1.0+damage- (damage*psychosis_dmg_cushion)
	SetHamParamFloat(4, damage);
}
return HAM_IGNORED
	
}
public plugin_natives(){


	
	register_native("yandere_get_user_is_psychosis","_yandere_get_user_is_psychosis",0);
	register_native("yandere_psychosis_user","_yandere_psychosis_user",0);
	register_native("yandere_unpsychosis_user","_yandere_unpsychosis_user",0);
	register_native("yandere_get_psychosis_degen_pct","_yandere_get_psychosis_degen_pct",0);
	register_native("yandere_get_psychosis_degen_health_threshold","_yandere_get_psychosis_degen_health_threshold",0);


}
public plugin_cfg(){


	loadCVARS()
}
loadCVARS(){


zoom=get_cvar_num("yandere_psychosis_zoom")
psychosis_time=get_cvar_float("yandere_psychosis_time")
psychosis_cooldown=get_cvar_num("yandere_psychosis_cooldown")
psychosis_dmg_cushion=get_cvar_float("yandere_psychosis_dmg_cushion")
psychosis_degen_pct=get_cvar_float("yandere_psychosis_degen_pct");
psychosis_degen_health_threshold=get_cvar_float("yandere_psychosis_degen_health_threshold")
psychosis_add_ap=get_cvar_num("yandere_psychosis_add_ap")

}
public Float:_yandere_get_psychosis_degen_pct(iPlugin,iParams){

	return psychosis_degen_pct
}
public Float:_yandere_get_psychosis_degen_health_threshold(iPlugin,iParams){

	return psychosis_degen_health_threshold
}


public bool:_yandere_get_user_is_psychosis(iPlugin,iParams){
	new id= get_param(1)
	
	return gIsPsychosis[id]


}
public _yandere_psychosis_user(iPlugin,iParams){
	new id= get_param(1)
	
	psychosis_user(id)


}

public _yandere_unpsychosis_user(iPlugin,iParams){
	new id= get_param(1)
	
	unpsychosis_user(id)


}

public client_PostThink(id) {
	
	if(!client_hittable(id,yandere_get_has_yandere(id))) { 
		return
	}
	if(g_yandere_leaped[id]){
		new flags = pev(id, pev_flags)
		if((flags  & FL_INGROUND2)){
			g_yandere_leaped[id]=false
		}
	}
}
public Player_TakeDamage(id)
{
	if ( !shModActive() || !is_user_alive(id) || !gSuperAngry[id]||!(yandere_get_user_is_psychosis(id))||!client_hittable(id)) return HAM_IGNORED
	
	set_pdata_float(id, fPainShock, 1.0, 5)

	return HAM_IGNORED
}

//----------------------------------------------------------------------------------------------
public psychosis_leap(id, uc_handle)
{
	if ( !is_user_alive(id)||!yandere_get_has_yandere(id)||!yandere_get_user_is_psychosis(id)||!hasRoundStarted()||!client_hittable(id,yandere_get_has_yandere(id))) return FMRES_IGNORED;
	
	if(sh_get_user_is_asleep(id)) return FMRES_IGNORED
	if(sh_get_user_is_chaffed(id)) return FMRES_IGNORED
	
	new button = get_uc(uc_handle, UC_Buttons);
	
	if(!g_yandere_leaped[id]){
		if(button & IN_JUMP)
		{
			button &= ~IN_JUMP;
			new Float:velocity[3]
			pev(id,pev_velocity,velocity)
			velocity[2]+=600.0
			set_pev(id,pev_velocity,velocity)
			g_yandere_leaped[id]=true
			
			
		}
	}
	return FMRES_IGNORED;
}

public psychosis_task(id){
	id-=YANDERE_PSYCHOSIS_TASKID

	gPsychosisTime[id]-=1.0
	sh_set_rendering(id, LineColors[PINK][0],LineColors[PINK][1],LineColors[PINK][2],255,kRenderFxGlowShell, kRenderTransAlpha)
	aura(id,LineColors[PINK])

	if(!is_user_bot(id)){
		static hud_msg[SH_HUD_MSG_BUFF_SIZE];
		static hero_name_arr[MAX_HERO_NAME_LENGTH]
		sh_get_hero_name_from_id(yandere_get_hero_id(),hero_name_arr)
		formatex(hud_msg,99,"[SH] %s:^nPsychosis mode for %0.1f more seconds!",
		hero_name_arr,
		gPsychosisTime[id]
		);
		superhero_protected_hud_message(superhero_hud_msg_sync,id,"%s", hud_msg,LineColors[PINK][0],LineColors[PINK][1],LineColors[PINK][2], -0.7, -1.0, 1, 0.0, 1.0,0.0,0.0)
		sh_screen_fade(id,0.1,1.0,LineColors[PINK][0],LineColors[PINK][1],LineColors[PINK][2],50)
	}
	
	
	
}
psychosis_user(id){
	
	psychosis_on(id)
	sh_screen_fade(id,0.1,1.0,LineColors[PINK][0],LineColors[PINK][1],LineColors[PINK][2],50)
	set_task(PSYCHOSIS_PERIOD,"psychosis_task",id+YANDERE_PSYCHOSIS_TASKID,"",0,  "a",PSYCHOSIS_TIMES)
	set_task(floatsub(psychosis_time,0.1),"unpsychosis_task",id+UNPSYCHOSIS_TASKID,"", 0,  "a",1)
	
	
	
}
public unpsychosis_task(id){
	id-=UNPSYCHOSIS_TASKID
	set_user_rendering(id)
	remove_task(id+YANDERE_PSYCHOSIS_TASKID)
	psychosis_off(id)
	
	
	
}

public unpsychosis_user(id){
	remove_task(id+UNPSYCHOSIS_TASKID)
	set_user_rendering(id)
	remove_task(id+YANDERE_PSYCHOSIS_TASKID)
	psychosis_off(id)
	
	
	
}
//----------------------------------------------------------------------------------------------
psychosis_off(id)
{


// Reset Zoom
gIsPsychosis[id]=false
g_yandere_leaped[id]=true
yandere_unmorph(id)
yandere_model(id)
for(new i=0;i<sizeof yandere_pain_sounds;i++){
	emit_sound(id, CHAN_AUTO, yandere_pain_sounds[i], 1.0, 0.0, SND_STOP, PITCH_NORM)
}
emit_sound(id, CHAN_AUTO, NULL_SOUND, 1.0, 0.0, 0, PITCH_NORM)
cs_set_user_armor(id,0,CS_ARMOR_NONE)
message_begin(MSG_ONE, MsgSetFOV, {0,0,0}, id)
write_byte(90)	//Normal, not Zooming
message_end()

}
psychosis_on(id){

gPsychosisTime[id]=psychosis_time
ultimateTimer(id, psychosis_cooldown * 1.0)
g_yandere_leaped[id]=false
gIsPsychosis[id]=true
yandere_unmorph(id)
yandere_model(id)
cs_set_user_armor(id,cs_get_user_armor(id)+psychosis_add_ap,CS_ARMOR_VESTHELM)
message_begin(MSG_ONE, MsgSetFOV, {0,0,0}, id)
write_byte(zoom)
message_end()

}


public on_death_psychosis()
{	
	new id = read_data(2)
	
	if(is_user_connected(id)||sh_is_active()){
		unpsychosis_user(id)
	}
	
}