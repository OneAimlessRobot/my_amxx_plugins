

#include "../my_include/superheromod.inc"
#define MAX_MONEY 16000
#define MONEY_TIER 15999
// GLOBAL VARIABLES
new gHeroID
new const gHeroName[] = "Leyla"
new bool:gHasLeyla[SH_MAXSLOTS+1]
new gLeylaUserMoney[SH_MAXSLOTS+1]
new gLeylaGiveMoney[SH_MAXSLOTS+1]

new const money_color[4]={1,255,1,1}

enum{
	GIVE,
	CHANGE
}
new hud_sync
new hud_sync_money
new gHeroLevel
new starting_money
new default_money
new Float:give_radius
new Float:headshot_mult
#define SENDAUDIO_MESSAGE_PITCH_ARG 3

//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO Leyla", "1.0", "TastyMedula")
	
	
	// DO NOT EDIT THIS FILE TO CHANGE CVARS, USE THE SHCONFIG.CFG
	register_cvar("leyla_level", "8")
	register_cvar("leyla_staring_money", "10000")
	register_cvar("leyla_default_give_money", "1000")
	register_cvar("leyla_default_give_radius", "300.0")
	register_cvar("leyla_headshot_mult", "1.5")
	register_concmd("leyla_stats","print_leyla_stats")
	register_event("ResetHUD","newRound","b")
	gHeroID=shCreateHero(gHeroName, "Rich walking bank girl!", "Infinite max money! Donate it to teammates, by going next to them! Set the money with the cmd 'set_leyla_money'! Damage also rewards you!", true, "leyla_level" )
	hud_sync=CreateHudSyncObj()
	hud_sync_money=CreateHudSyncObj()
	register_event("DeathMsg","death","a")
	register_srvcmd("leyla_init", "leyla_init")
	shRegHeroInit(gHeroName, "leyla_init")
	register_srvcmd("leyla_kd", "leyla_kd")
	register_forward(FM_TraceLine,"fw_traceline");
	shRegKeyDown(gHeroName, "leyla_kd")
	arrayset(gLeylaUserMoney,0,SH_MAXSLOTS+1)
	
}


public leyla_init()
{
	
	// First Argument is an id
	new temp[6]
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	read_argv(2,temp,5)
	new hasPowers = str_to_num(temp)
	gHasLeyla[id]=(hasPowers!=0)
	if(gHasLeyla[id]){
		gLeylaUserMoney[id]=starting_money
		gLeylaGiveMoney[id]=default_money
		
	}
	else{
		gLeylaUserMoney[id]=0
		gLeylaGiveMoney[id]=0
	}
	
	
}
public print_leyla_stats(id)
{
	if (  is_user_alive(id) &&gHasLeyla[id]&&is_user_connected(id))
	{
		sh_chat_message(id,gHeroID,"You currently have %d backup money", gLeylaUserMoney[id] )
		sh_chat_message(id,gHeroID,"And you can give %d money per key down", gLeylaGiveMoney[id])
		
	}
	return PLUGIN_HANDLED
}
public leyla_damage(id){
	if ( !shModActive() || !is_user_alive(id) ||!gHasLeyla[id]) return
	
	/*
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	new headshot = bodypart == 1 ? 1 : 0
	if ( attacker <= 0 || attacker > SH_MAXSLOTS || attacker==id ) return
	new attacker_name[128];
	new client_name[128];
	get_user_name(attacker,attacker_name,127);
	get_user_name(id,client_name,127);
	
	*/
}

public unpoor_teamate(id,teamate,ammount,type_of_trade){
	
	new real_ammount;
	if (ammount<0){
		
		real_ammount=gLeylaGiveMoney[id];
	}
	else{
		real_ammount=ammount;
		
	}
	new client_name[128]
	get_user_name(teamate,client_name,127)
	new CsTeams:att_team=cs_get_user_team(id)
	
	new attacker_name[128]
	get_user_name(id,attacker_name,127)
	
	
	if((cs_get_user_team(teamate)==att_team)) {
		new mate_money=cs_get_user_money(teamate)
		new normal_leyla_money=cs_get_user_money(id)
		
		if(!gHasLeyla[teamate]){
			new new_money=min(MAX_MONEY,mate_money+real_ammount)
			cs_set_user_money(teamate,new_money,1)
		}
		else{
			new distance_to_max=MAX_MONEY-mate_money;
			if(distance_to_max<real_ammount){
				
				cs_set_user_money(teamate,MAX_MONEY,1)
				gLeylaUserMoney[teamate]+=real_ammount-distance_to_max
				
			}
			else{
				
				new new_money=mate_money+real_ammount
				cs_set_user_money(teamate,new_money,1)
				
			}
			
			
			
		}
		if(type_of_trade==GIVE){
			new new_leyla_money;
			if(gLeylaUserMoney[id]>0){
				if(gLeylaUserMoney[id]>=real_ammount){
					gLeylaUserMoney[id]-=real_ammount
					
				}
				else{
					new_leyla_money=MAX_MONEY-(real_ammount-gLeylaUserMoney[id])
					gLeylaUserMoney[id]=0
					cs_set_user_money(id,new_leyla_money,1)
				}
				
			}
			else{
				if(normal_leyla_money>real_ammount){
					cs_set_user_money(id,normal_leyla_money-real_ammount,1)
				}
				else{
					playSoundDenySelect(id)
					
				}
			}
		}
	}
	
}
public get_first_mate_in_radius(id){
	
	new client_origin[3],teamate_origin[3],distance
	get_user_origin(id,client_origin);
	new CsTeams:user_team= cs_get_user_team(id)
	for(new i=1;i<=SH_MAXSLOTS;i++){
		
		if((i==id)||!is_user_connected(i)||!is_user_alive(i)){
			
			
		}
		else{
			new CsTeams:other_user_team=cs_get_user_team(i)
			if((user_team==other_user_team)){
				get_user_origin(i,teamate_origin)
				distance=get_distance(client_origin,teamate_origin)
				if(distance<give_radius){
					return i
				}
			}
		}
		
		
	}
	return -1
	
	
}
public fw_traceline(Float:v1[3],Float:v2[3],noMonsters,id)
{
	if( !sh_is_active() || !is_user_alive(id) ||!gHasLeyla[id] )
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
			new client_money=cs_get_user_money(ent)
			format(hud_msg,127,"[SH] %s: Money of %s: %d+%d",gHeroName,client_name,client_money,gLeylaUserMoney[ent])
			set_hudmessage(money_color[0], money_color[1], money_color[2], -1.0, -1.0, money_color[3], 0.0, 0.5,0.0,0.0,1)
			ShowSyncHudMsg(id, hud_sync_money, "%s", hud_msg)
			
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
	
	gHeroLevel=get_cvar_num("leyla_level")
	starting_money=get_cvar_num("leyla_staring_money")
	default_money=get_cvar_num("leyla_default_give_money")
	give_radius=get_cvar_float("leyla_default_give_radius")
	headshot_mult=get_cvar_float("leyla_headshot_mult")
}
public reset_leyla(id){
	
	if ( gHasLeyla[id]) {
		
	}
	
}
public leyla_kd()
{
	new temp[6]
	
	// First Argument is an id with colussus Powers!
	read_argv(1,temp,5)
	new id=str_to_num(temp)
	
	if ( !is_user_alive(id)||!gHasLeyla[id]) return PLUGIN_HANDLED
	new i
	if((i=get_first_mate_in_radius(id))>0){
		
		unpoor_teamate(id,i,-1,GIVE)
		
	}
	
	
	return PLUGIN_HANDLED
}


//----------------------------------------------------------------------------------------------
public newRound(id)
{	
	if(is_user_alive(id) && shModActive()&&gHasLeyla[id]){ 
		reset_leyla(id)	
	}
	return PLUGIN_HANDLED	
}
public plugin_precache()
{
	
}
public sh_round_end(){
	
	
}

public death()
{	
	//new id = read_data(2)
	new killer= read_data(1)
	if(gHasLeyla[killer]){
		
		unpoor_teamate(killer,killer,-1,CHANGE)
		
	}
}