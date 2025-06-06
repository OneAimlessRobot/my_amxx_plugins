

#include "../my_include/superheromod.inc"
#include "colt_inc/sh_ethereal.inc"
#include "colt_inc/sh_colt.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"

#define ADRIANO_STATS_TASKID 22226
#define ADRIANO_HUD_TASKID 21121


// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Adriano"
new bool:gHasAdriano[SH_MAXSLOTS+1]
//new g_base_points[SH_MAXSLOTS+1]
new g_adriano_points[SH_MAXSLOTS+1]
new Float:g_base_speed[SH_MAXSLOTS+1]
new Float:g_normal_speed[SH_MAXSLOTS+1]
new Float:g_base_radius[SH_MAXSLOTS+1]
new Float:g_normal_radius[SH_MAXSLOTS+1]

new const hud_color[4]={255,255,1,0}

new const adriano_sentences[1][]={
	
	"HELL YEA LETS GOOOO!!!!"
}
new m_spriteTexture

new base_points
new max_points
new Float:speed_points_heal
new Float:speed_points_heal_coeff
new Float:speed_speed_points_pct
new Float:speed_points_radius_pct
new Float:dmg_speed_points_pct
new Float:base_speed
new Float:max_speed
new Float:max_radius
new Float:base_radius

//new pCvarSpeed
new hud_sync
new hud_sync_health
new gHeroLevel


//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Adriano Valente!", "1.0", "Adriano Valente")
	
	
	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("adriano_level", "8")
	register_cvar("adriano_speed_points_radius_pct", "0.1")
	register_cvar("adriano_base_radius", "500")
	register_cvar("adriano_max_radius", "1000")
	register_cvar("adriano_base_points", "1000")
	register_cvar("adriano_max_points", "1000")
	register_cvar("adriano_base_speed", "500")
	register_cvar("adriano_max_speed", "1000")
	register_cvar("adriano_speed_speed_points_pct", "0.1")
	register_cvar("adriano_dmg_speed_points_pct", "0.1")
	register_cvar("adriano_speed_points_heal", "100")
	register_cvar("adriano_speed_points_heal_coeff", "4")
	
	
	hud_sync=CreateHudSyncObj()
	hud_sync_health=CreateHudSyncObj()
	register_event("ResetHUD","newRound","b")
	gHeroID=shCreateHero(gHeroName, "Hyped by suffering!", "Get faster from those around you and pat mates on the back for motivation!", false, "adriano_level" )
	
	register_forward(FM_TraceLine,"fw_traceline");
	register_event("Damage", "adriano_damage", "b", "2!0")
	RegisterHam(Ham_TraceAttack,"player","trace_adriano")
	register_event("DeathMsg","death","a")
	
	register_srvcmd("adriano_init", "adriano_init")
	shRegHeroInit(gHeroName, "adriano_init")
	/*register_srvcmd("adriano_kd", "adriano_kd")
	shRegKeyDown(gHeroName, "adriano_kd")*/
	//sh_set_hero_speed(gHeroID, pCvarSpeed)
	//register_event("CurWeapon", "fire_weapon", "be", "1=1", "3>0")
}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	
	gHeroLevel=get_cvar_num("adriano_level")
	dmg_speed_points_pct=get_cvar_float("adriano_dmg_speed_points_pct")
	base_radius=get_cvar_float("adriano_base_radius")
	max_radius=get_cvar_float("adriano_max_radius")
	max_points=get_cvar_num("adriano_max_points")
	base_speed=get_cvar_float("adriano_base_speed")
	max_speed=get_cvar_float("adriano_max_speed")
	speed_speed_points_pct=get_cvar_float("adriano_speed_speed_points_pct")
	speed_points_radius_pct=get_cvar_float("adriano_speed_points_radius_pct")
	speed_points_heal=get_cvar_float("adriano_speed_points_heal")
	speed_points_heal_coeff=get_cvar_float("adriano_speed_points_heal_coeff")
	base_points=get_cvar_num("adriano_base_points")
}
public Ham_respawn(id){
	if ( shModActive() && gHasAdriano[id] && is_user_alive(id) ) {
		adriano_weapons(id)

	}


}
//----------------------------------------------------------------------------------------------
public adriano_weapons(id)
{
	if ( shModActive() && client_hittable(id)&& gHasAdriano[id] ) {
		colt_set_colt(id)
		ethereal_set_ethereal(id)
	}
}
public adriano_init()
{
	
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)
	gHasAdriano[id]=(hasPowers!=0)
	if(gHasAdriano[id]){
		
		adriano_weapons(id)
		g_adriano_points[id]=base_points;
		g_base_speed[id]=base_speed
		g_base_radius[id]=base_radius
		set_task(0.1, "adriano_hud", id+ADRIANO_HUD_TASKID, "", 0, "b")
		set_task(0.1, "adriano_loop", id+ADRIANO_STATS_TASKID, "", 0, "b")
	}
	else{
		ethereal_unset_ethereal(id)
		colt_unset_colt(id)
		g_adriano_points[id]=0;
		g_base_speed[id]=0.0
		g_base_radius[id]=0.0
		remove_task(id+ADRIANO_HUD_TASKID)
		remove_task(id+ADRIANO_STATS_TASKID)
	}
	
	
}
add_speed_points(id,Float:damage,is_up){
	
	g_adriano_points[id]=is_up?min(max_points,g_adriano_points[id]+(floatround(damage*dmg_speed_points_pct))):max(0,g_adriano_points[id]-(floatround(damage*speed_points_heal_coeff)))
	
	
}
public get_speed_dmg_in_radius(id,Float:damage){
	
	new client_origin[3],teamate_origin[3],distance
	get_user_origin(id,client_origin);
	new CsTeams:user_team= cs_get_user_team(id)
	for(new i=1;i<=SH_MAXSLOTS;i++){
		
		//if(!is_user_connected(i)||!gHasAdriano[i]||!is_user_alive(i)){
		if((i==id)||!is_user_connected(i)||!gHasAdriano[i]||!is_user_alive(i)){
			
			
		}
		else{
			new CsTeams:other_user_team=cs_get_user_team(i)
			if((user_team==other_user_team)){
				get_user_origin(i,teamate_origin)
				distance=get_distance(client_origin,teamate_origin)
				if(distance<g_normal_radius[i]){
					heal_stream(i, id)
					heal_aura(i)
					add_speed_points(i,damage,true)
				}
			}
		}
		
		
	}
	
	
}
public heal_aura(id){
	
	new origin[3]
	
	get_user_origin(id, origin, 1)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(27)
	write_coord(origin[0])	//pos
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(15)
	write_byte( hud_color[0] )				// r, g, b
	write_byte( hud_color[1] )				// r, g, b
	write_byte( hud_color[2] )				// r, g, b
	write_byte(3)			// life
	write_byte(1)			// decay
	message_end()
	
}
public heal_stream(id, x)
{
	
	new origin[3]
	
	get_user_origin(id, origin, 1)
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( 8 )
	write_short(id)				// start entity
	write_short(x)				// entity
	write_short(m_spriteTexture)		// model
	write_byte( 0 ) 				// starting frame
	write_byte( 30 )  			// frame rate
	write_byte( 1)  			// life
	write_byte( 45)  		// line width
	write_byte( 0 )  			// noise amplitude
	write_byte( hud_color[0] )				// r, g, b
	write_byte( hud_color[1] )				// r, g, b
	write_byte( hud_color[2] )				// r, g, b
	write_byte( 255 )				// brightness
	write_byte( 8 )				// scroll speed
	message_end()
	
}
public adriano_hud(id){
	id-=ADRIANO_HUD_TASKID
	new hud_msg[1000];
	
	if(!is_user_alive(id)||!is_user_connected(id)||!gHasAdriano[id]) return
	format(hud_msg,499,"[SH] %s:^nBase speed: %0.2f^nCurr speed: %0.2f^nMax speed: %0.2f^nBase Points: %d^nPoints: %d^nMax Points: %d^n",
					gHeroName,
					g_base_speed[id],
					g_normal_speed[id],
					max_speed,
					base_points,
					g_adriano_points[id],
					max_points
					);
	
	set_hudmessage(hud_color[0], hud_color[1], hud_color[2], 1.0, 0.5, hud_color[3], 0.0, 0.5,0.0,0.0,1)
	ShowSyncHudMsg(id, hud_sync, "%s", hud_msg)
	
	
	
}
public heal_teamate(id,teamate){
	
	new client_name[128]
	get_user_name(teamate,client_name,127)
	new CsTeams:att_team=cs_get_user_team(id)
	
	new attacker_name[128]
	get_user_name(id,attacker_name,127)
	
	
	if((cs_get_user_team(teamate)==att_team)) {
		new Float:mate_health=float(get_user_health(teamate))
		new Float:added_hp=speed_points_heal*speed_points_heal_coeff;
		new Float: new_health=floatadd(mate_health,added_hp)
		if((sh_get_max_hp(teamate)>floatround(mate_health))){
			
			
			set_user_health(teamate,min(sh_get_max_hp(teamate),floatround(new_health)))
			add_speed_points(id,speed_points_heal,false)
			sh_chat_message(id,gHeroID,"%s: Come on, %s! %s",attacker_name,client_name,adriano_sentences[random_num(0,sizeof(adriano_sentences)-1)])
			sh_chat_message(teamate,gHeroID,"%s: Come on, %s! %s",attacker_name,client_name,adriano_sentences[random_num(0,sizeof(adriano_sentences)-1)])
			sh_chat_message(id,gHeroID,"%d Points deducted from %d",floatround(speed_points_heal),g_adriano_points[id]+floatround(speed_points_heal))
			
		}
		
		
	}
	
}
public trace_adriano(id, attacker, Float:damage, Float:direction[3], traceresult, damagebits)
{
	if( !sh_is_active() || !is_user_alive(id) || !is_user_connected(id)) return HAM_IGNORED;
	if ( (attacker <= 0 || attacker > SH_MAXSLOTS )|| (attacker==id)||!is_user_connected(attacker)||!gHasAdriano[attacker]) return HAM_IGNORED
	
	new clip,ammo, weapon = get_user_weapon(attacker, clip,ammo)
	
	
	// get ent looking at
	static  body;
	get_user_aiming(attacker, id, body);
	if( pev_valid(id))
	{
		set_tr(TR_flFraction, 0.1); // 1.0 == no hit, < 1.0 == hit
		set_tr(TR_pHit, id); // entity hit
		set_tr(TR_iHitgroup, body); // bodypart hit
		if((pev(id,pev_solid)==SOLID_SLIDEBOX)&& (weapon==CSW_KNIFE)){
			heal_teamate(attacker,id)
		}
	}
	
	return HAM_IGNORED;
}
public adriano_damage(id)
{
	if ( !shModActive() || !is_user_alive(id)||!is_user_connected(id) ) return
	
	
	new  Float:damage= float(read_data(2))
	
	get_speed_dmg_in_radius(id,damage)
	
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	new headshot = bodypart == 1 ? 1 : 0
	
	if(!client_hittable(attacker)||!gHasAdriano[attacker]) return

	if(weapon==CSW_ETHEREAL){
	
		sh_extra_damage(id,attacker,floatround(damage),"Adriano Ethereal Rifle",headshot)
	
	}
}
public fw_traceline(Float:v1[3],Float:v2[3],noMonsters,id)
{
	if( !sh_is_active() || !is_user_alive(id) ||!gHasAdriano[id] )
		return FMRES_IGNORED;
	
	
	
	// get crosshair aim
	static iMyAim[3], Float:flMyAim[3];
	get_user_origin(id, iMyAim, 3);
	IVecFVec(iMyAim, flMyAim);
	
	// set crosshair aim
	set_tr(TR_vecEndPos, flMyAim);
	
	// get ent looking at
	static ent, body;
	get_user_aiming(id, ent, body);
	
	// if looking at something
	if( pev_valid(ent))
	{
		if((pev(ent,pev_solid)==SOLID_SLIDEBOX)&&(get_user_team(id)==get_user_team(ent))){
			new hud_msg[128]
			new client_name[127]
			get_user_name(ent,client_name,127)
			new client_health=get_user_health(ent)
			format(hud_msg,127,"[SH] %s: HP of %s: %d/%d",gHeroName,client_name,client_health,sh_get_max_hp(ent))
			set_hudmessage(hud_color[0], hud_color[1], hud_color[2], -1.0, -1.0, hud_color[3], 0.0, 0.1,0.0,0.0,1)
			ShowSyncHudMsg(id, hud_sync_health, "%s", hud_msg)
			
		}	
		
	}	
	return FMRES_IGNORED;
}
public adriano_loop(id){
	
	id-=ADRIANO_STATS_TASKID;
	
	if(gHasAdriano[id]){
		
		update_stats(id)
		
		
	}
	
	
}
update_stats(id){
	
	if(gHasAdriano[id]){
		////g_normal_speed[id]=900.0-float(g_adriano_points[id])
		if(!sh_get_stun(id)){
			new Float:maxspeed=get_user_maxspeed(id)
			g_normal_speed[id]=floatmax(floatmin(floatadd(g_base_speed[id],floatmul(speed_speed_points_pct,float(g_adriano_points[id]))),max_speed),maxspeed),
			set_user_maxspeed(id,g_normal_speed[id])
		}
		g_normal_radius[id]=floatmin(floatadd(g_base_radius[id],floatmul(float(g_adriano_points[id]),speed_points_radius_pct)),max_radius);
		
	}
	
	
}

public adriano_kd()
{
	new temp[6]
	
	// First Argument is an id with colussus Powers!
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( !is_user_alive(id)||!gHasAdriano[id]) return PLUGIN_HANDLED
	
	heal_teamate(id,id)
	
	return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
public newRound(id)
{	
	if(is_user_alive(id) && shModActive()){
		if ( gHasAdriano[id]) {
			adriano_weapons(id)
			g_adriano_points[id]=base_points;
			g_base_speed[id]=base_speed
		}
	}
	return PLUGIN_HANDLED
	
}
public plugin_precache()
{
	m_spriteTexture = precache_model("sprites/laserbeam.spr")
	for(new i=0;i<sizeof(colt_sounds);i++){
	
		engfunc(EngFunc_PrecacheSound,colt_sounds[i] );
	
	}
	precache_model(WORLDMODEL )
	precache_model(VIEWMODEL )
	precache_model(WEAPONMODEL )
	precache_explosion_fx()
}
public sh_round_end(){
	
	
	
}

public death(){
	
	
}
