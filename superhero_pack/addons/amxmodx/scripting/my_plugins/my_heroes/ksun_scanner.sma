
#include "../my_include/superheromod.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "ksun_inc/ksun_global.inc"
#include "ksun_inc/ksun_particle.inc"
#include "ksun_inc/ksun_spore_launcher.inc"
#include "ksun_inc/ksun_scanner.inc"



new Float:ksun_track_max_radius,
	Float:ksun_track_min_radius,
	Float:ksun_track_traverse_time;
new ksun_max_victims

new num_launched_spores[SH_MAXSLOTS+1]
new num_deployed_spores[SH_MAXSLOTS+1]
new g_player_num_victims[SH_MAXSLOTS+1]

new g_player_spores[SH_MAXSLOTS+1][SH_MAXSLOTS+2]
new g_player_targets[SH_MAXSLOTS+1][SH_MAXSLOTS+2]

new g_player_tracks_player[SH_MAXSLOTS+1][SH_MAXSLOTS+1]

new g_player_scanner[SH_MAXSLOTS+1]


public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO ksun scanner","1.1","MilkChanThaGOAT")
	
	register_cvar("ksun_track_max_radius", "2000.0")
	register_cvar("ksun_track_min_radius", "500.0")
	register_cvar("ksun_track_traverse_time", "2.0")
	register_cvar("ksun_max_victims", "4" )
	register_event("SendAudio","ev_SendAudio","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw");
	
	
	register_forward(FM_Think, "scanner_think")
}

public plugin_natives(){
	
	
	
	
	register_native("scanner_max_victims","_scanner_max_victims",0)
	register_native("get_player_scanner","_get_player_scanner",0)
	register_native("set_player_scanner","_set_player_scanner",0)
	
	register_native("spawn_scanner","_spawn_scanner",0)
	
	register_native("reset_player_targets","_reset_player_targets",0)
	
	register_native("get_player_num_victims","_get_player_num_victims",0)
	register_native("set_player_num_victims","_set_player_num_victims",0)
	register_native("dec_player_num_victims","_dec_player_num_victims",0)
	
	register_native("get_player_num_deployed_spores","_get_player_num_deployed_spores",0)
	register_native("set_player_num_deployed_spores","_set_player_num_deployed_spores",0)
	register_native("dec_player_num_deployed_spores","_dec_player_num_deployed_spores",0)
	
	register_native("get_player_num_launched_spores","_get_player_num_launched_spores",0)
	register_native("set_player_num_launched_spores","_set_player_num_launched_spores",0)
	register_native("dec_player_num_launched_spores","_dec_player_num_launched_spores",0)
	
	register_native("get_scanner_min_radius","_get_scanner_min_radius",0)
	register_native("get_scanner_max_radius","_get_scanner_max_radius",0)
	register_native("get_scanner_traverse_time","_get_scanner_traverse_time",0)
	
	register_native("get_spore_from_player_spores","_get_spore_from_player_spores",0)
	register_native("get_target_from_player_targets","_get_target_from_player_targets",0)
	
	register_native("set_spore_at_player_spores","_set_spore_at_player_spores",0)
	register_native("set_target_at_player_targets","_set_target_at_player_targets",0)
	
	register_native("get_scanner_player_tracks_player","_get_scanner_player_tracks_player",0)
	register_native("set_scanner_player_tracks_player","_set_scanner_player_tracks_player",0)
	register_native("scanners_clear","_scanners_clear",0)
	register_native("destroy_player_scanner","_destroy_player_scanner",0)
	
	
	
}

public ev_SendAudio(){
	
	if(!sh_is_active()) return PLUGIN_CONTINUE
	scanners_clear()
}
public _get_spore_from_player_spores(iPlugin,iParams){
	new id=get_param(1)
	new index=get_param(2)
	
	return g_player_spores[id][index]
}
public _get_target_from_player_targets(iPlugin,iParams){
	new id=get_param(1)
	new index=get_param(2)
	
	return g_player_targets[id][index]
}
public _set_spore_at_player_spores(iPlugin,iParams){
	new id=get_param(1)
	new index=get_param(2)
	new value= get_param(3)
	
	g_player_spores[id][index]=value
}
public _set_target_at_player_targets(iPlugin,iParams){
	new id=get_param(1)
	new index=get_param(2)
	new value= get_param(3)
	
	g_player_targets[id][index]=value
}

public _get_player_num_victims(iPlugin,iParams){
	new id=get_param(1)
	
	return g_player_num_victims[id]
}
public _set_player_num_victims(iPlugin,iParams){
	new id=get_param(1)
	new value=get_param(2)
	
	g_player_num_victims[id]=value

}
public _dec_player_num_victims(iPlugin,iParams){
	new id=get_param(1)

	g_player_num_victims[id]= (g_player_num_victims[id]>0)? (g_player_num_victims[id]-1):0

}

public _get_player_num_deployed_spores(iPlugin,iParams){
	new id=get_param(1)
	
	return num_deployed_spores[id]
}
public _set_player_num_deployed_spores(iPlugin,iParams){
	new id=get_param(1)
	new value=get_param(2)
	
	num_deployed_spores[id]=value

}
public _dec_player_num_deployed_spores(iPlugin,iParams){
	new id=get_param(1)

	num_deployed_spores[id]= (num_deployed_spores[id]>0)? (num_deployed_spores[id]-1):0

}


public _get_player_num_launched_spores(iPlugin,iParams){
	new id=get_param(1)
	
	return num_launched_spores[id]
}
public _set_player_num_launched_spores(iPlugin,iParams){
	new id=get_param(1)
	new value=get_param(2)
	
	num_launched_spores[id]=value

}
public _dec_player_num_launched_spores(iPlugin,iParams){
	new id=get_param(1)

	num_launched_spores[id]= (num_launched_spores[id]>0)? (num_launched_spores[id]-1):0

}
public Float:_get_scanner_traverse_time(iPlugin,iParms){
	
	
	return ksun_track_traverse_time
	
	
}
public _reset_player_targets(iPlugin,iParams){
		
		new id=get_param(1)

		arrayset(g_player_tracks_player[id],false,SH_MAXSLOTS+1)	
		arrayset(g_player_targets[id],0,SH_MAXSLOTS+1)
		arrayset(g_player_spores[id],0,SH_MAXSLOTS+1)
}
public Float:_get_scanner_max_radius(iPlugin,iParms){
	
	
	return ksun_track_max_radius
	
	
}
public Float:_get_scanner_min_radius(iPlugin,iParms){
	
	
	return ksun_track_min_radius
	
	
}
public _destroy_player_scanner(iPlugin,iParams){
	
	new id=get_param(1)
	
	if(!is_user_connected(id)||! sh_is_active() ) return PLUGIN_HANDLED
	

	if ( spores_has_ksun(id)) {
		if(is_valid_ent(g_player_scanner[id]) && (g_player_scanner[id]>0)){
			
			
			emit_sound(get_player_launcher(id), CHAN_STATIC, LAUNCHER_SCAN_SFX, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
			entity_set_float(g_player_scanner[id], EV_FL_fuser1, 0.0);
			entity_set_float(g_player_scanner[id], EV_FL_fuser2, 0.0);
			remove_entity(g_player_scanner[id])
			g_player_scanner[id]=0
	
	
		}
	}
	return PLUGIN_HANDLED
}
public _spawn_scanner(iPlugins,iParams){
	new id= get_param(1)
	if(!spores_has_ksun(id)||!client_hittable(id)){
		
		return
	}
	new originplayer[3]
	new Float: b_orig[3]
	get_user_origin(id, originplayer)
	
	b_orig[0] = float(originplayer[0]);
	b_orig[1] = float(originplayer[1]);
	b_orig[2] = float(originplayer[2]+UNITS_ABOVE);
	new scanner = create_entity( "info_target" );
	if ( (scanner == 0) || !pev_valid(scanner )||!is_valid_ent(scanner )) {
		client_print(id, print_chat, "[SH](ksun) Scanner Creation Failure")
		return
	}
	entity_set_string(scanner, EV_SZ_classname, SCANNER_CLASSNAME)
	entity_set_float(scanner, EV_FL_fuser1, 0.0);
	entity_set_float(scanner, EV_FL_fuser2, get_scanner_min_radius());
	entity_set_edict(scanner, EV_ENT_owner, id)
	entity_set_origin(scanner, b_orig)
	g_player_scanner[id]=scanner
	entity_set_float(scanner, EV_FL_nextthink, get_gametime()+SCAN_LOOP_PERIOD);
	emit_sound(id, CHAN_STATIC, LAUNCHER_SCAN_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
	
}
public _set_scanner_player_tracks_player(iPlugins,iParams){
	
	new id1=get_param(1)
	new id2=get_param(2)
	new value=get_param(3)
	g_player_tracks_player[id1][id2]=value
	
	
}
public _get_scanner_player_tracks_player(iPlugins,iParams){
	
	new id1=get_param(1)
	new id2=get_param(2)
	
	return g_player_tracks_player[id1][id2]
	
	
}
public _get_player_scanner(iPlugins, iParms){
	new id=get_param(1)
	return g_player_scanner[id]

}
public _set_player_scanner(iPlugins, iParms){
	new id=get_param(1)
	new scanner_ent_id=get_param(2)
	g_player_scanner[id]=scanner_ent_id

}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{
	
	ksun_track_min_radius= get_cvar_float("ksun_track_min_radius")
	ksun_track_max_radius= get_cvar_float("ksun_track_max_radius")
	ksun_track_traverse_time= get_cvar_float("ksun_track_traverse_time")
	ksun_max_victims= get_cvar_num("ksun_max_victims")
}
public _scanner_max_victims(iPlugins, iParms){
	
	return ksun_max_victims
	
}

public _scanners_clear(iPlugins, iParms){
	
	
	new scanner = find_ent_by_class(-1, SCANNER_CLASSNAME)
	while( scanner) {
		remove_entity( scanner)
		scanner = find_ent_by_class(scanner, SCANNER_CLASSNAME)
	}
	
	
}


public scanner_think(scanner){
	
	if ( !pev_valid(scanner) || (scanner<=0) ||!is_valid_ent(scanner)) return FMRES_IGNORED
	static classname[32]
	classname[0] = '^0'
	pev(scanner, pev_classname, classname, charsmax(classname))
	
	if ( !equal(classname, SCANNER_CLASSNAME) ) return FMRES_IGNORED
	
	new id= entity_get_edict(scanner,EV_ENT_owner)
	if ( !client_hittable(id) ||!spores_has_ksun(id)) return FMRES_IGNORED

	new Float:fOrigin[3];
	entity_get_vector( id, EV_VEC_origin, fOrigin);
	if(entity_get_float(scanner, EV_FL_fuser2)>=ksun_track_max_radius){
		
		
		show_targets(id)
		if(g_player_num_victims[id]>0){
			
			launcher_deploy(id)
		}
		destroy_player_scanner(id)
		return FMRES_IGNORED
		
	}
	
	new iOrigin[3];
	for(new i=0;i<3;i++){
		iOrigin[i] = floatround(fOrigin[i]);
	}
	
	arrayset(g_player_tracks_player[id],false,SH_MAXSLOTS+1)
	num_deployed_spores[id]=0
	num_launched_spores[id]=0
	arrayset(g_player_targets[id],0,SH_MAXSLOTS+1)
	g_player_num_victims[id]=0
	
	make_shockwave(iOrigin,entity_get_float(scanner, EV_FL_fuser2),{255, 0, 255,50})
	new entlist[33];
	new numfound = find_sphere_class(id,"player", entity_get_float(scanner, EV_FL_fuser2) ,entlist, 32);
	new CsTeams:idTeam = cs_get_user_team(id)
	for( new i= 0;(g_player_num_victims[id]<=(ksun_max_victims))&&(i< numfound);i++){
		
			new pid = entlist[i];
			if(!client_hittable(pid)){
				continue
			
			}
			
			if((cs_get_user_team(pid)==idTeam)){
					continue
			}
			if(!g_player_tracks_player[id][pid]){
				g_player_tracks_player[id][pid]=true
				num_deployed_spores[id]++
				num_launched_spores[id]++
				g_player_targets[id][num_launched_spores[id]]=pid;
				g_player_num_victims[id]++
			}
		
	}
	
	entity_set_float( scanner, EV_FL_fuser2, floatadd(entity_get_float(scanner, EV_FL_fuser2) ,SCAN_DIST_INC));
	entity_set_float( scanner, EV_FL_fuser1, floatadd(entity_get_float(scanner, EV_FL_fuser1) ,SCAN_LOOP_PERIOD));
	entity_set_float( scanner, EV_FL_nextthink, floatadd(get_gametime( ) ,SCAN_LOOP_PERIOD));
	
	return FMRES_IGNORED
}


show_targets(id){

	if(!client_hittable(id)||!spores_has_ksun(id)){
		
		return
	}
	new hud_msg[500];
	new client_name[128];
	get_user_name(id,client_name,127)
	if(g_player_num_victims[id]<=0){
		
		client_print(id,print_center,"[SH] ksun:^nNo victims were gathered...")
	}
	else{
		format(hud_msg,500,"[SH] (ksun):Targets are:^n")
		for(new i=1;i<=SH_MAXSLOTS;i++){
			if(g_player_tracks_player[id][i]&&client_hittable(i)){
				get_user_name(i,client_name,127)
				format(hud_msg,500,"%s%s.^n",hud_msg,client_name);
			}
		} 
		client_print(id,print_chat, "%s", hud_msg)
	}
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	precache_model(KSUN_SPORE_MDL)
	engfunc(EngFunc_PrecacheSound, SPORE_PREPARE_SFX)
	engfunc(EngFunc_PrecacheSound, LAUNCHER_SCAN_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_SEND_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_HEAL_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_READY_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_WOUND_SFX)
	engfunc(EngFunc_PrecacheSound, SPORE_TRAVEL_SFX)
	precache_model( "models/metalgibs.mdl" );
	engfunc(EngFunc_PrecacheSound,"debris/metal2.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal1.wav" );
	engfunc(EngFunc_PrecacheSound,"debris/metal3.wav" );
	precache_explosion_fx()
}