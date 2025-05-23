#include "../my_include/superheromod.inc"
#include <xs>
#include "tranq_gun_inc/sh_erica_get_set.inc"
#include "tranq_gun_inc/sh_man_hook_funcs.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"


#define PLUGIN "Superhero erica hook"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

stock hook_on[SH_MAXSLOTS+1]
stock gSpriteLaser;
stock g_dragging_who[SH_MAXSLOTS+1][2]
stock g_hook_kills[SH_MAXSLOTS+1]
#define NUM_SENTENCES 5
stock const erica_sentences[NUM_SENTENCES][]={
	
	"TAKE THIS! Wow... this think really went deep... Ok gotta get it off... HMMFFPPH!",
	"Ahhh its too stuck! its between the guys ribs...",
	"Hmmph! hmmph! Man their loosing blood but I still cant get if off!",
	"Man those are guts... those are... his lower vertebrae, I think... ",
	"I think... AHH got it!"
}
new Float:hook_distance
new Float:hook_drag_time
new hook_level_difference
new max_hook_kills_per_life
new Float:hook_drag_speed
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	for(new i=0;i<SH_MAXSLOTS+1;i++){
		if(!client_isnt_hittable(i)){
			g_dragging_who[i][0]=-1;
			g_dragging_who[i][1]=0
		}
	
	}
	arrayset(hook_on,0,SH_MAXSLOTS+1)
	arrayset(g_hook_kills,0,SH_MAXSLOTS+1)
	register_cvar("hook_distance", "2.0")
	register_cvar("max_hooks_per_life", "2.0")
	register_cvar("hook_drag_speed", "2.0")
	register_cvar("hook_level_difference", "10")
	register_cvar("hook_drag_time", "3")
	RegisterHam(Ham_TakeDamage,"player","Erica2_ham_damage")
	register_forward(FM_CmdStart, "CmdStart1")
	register_event("DeathMsg","death","a")
	register_event("ResetHUD","newRound","b")
	register_event("CurWeapon", "weaponChange", "be", "1=1")
}

public weaponChange(id)
{
	if ( !is_user_alive(id)||!tranq_get_has_erica(id) ||!shModActive()) return PLUGIN_CONTINUE
	
	new clip, ammo, wpnid = get_user_weapon(id,clip,ammo)
	if ((wpnid == CSW_KNIFE)&&hook_get_hook_kills(id)) {
	}
	return PLUGIN_CONTINUE
	
}
//----------------------------------------------------------------------------------------------
public newRound(id)
{
if ( tranq_get_has_erica(id)&&is_user_alive(id) && shModActive() &&!hasRoundStarted() ) {
	
	stop_dragging(id)
	g_hook_kills[id]=max_hook_kills_per_life;
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
	hook_distance=get_cvar_float("hook_distance")
	hook_level_difference=get_cvar_num("hook_level_difference")
	hook_drag_time=get_cvar_float("hook_drag_time")
	hook_drag_speed=get_cvar_float("hook_drag_speed")
	max_hook_kills_per_life=get_cvar_num("max_hooks_per_life")
}
public plugin_natives(){
	
	
	register_native( "hook_set_hook","_hook_set_hook",0)
	register_native( "hook_get_hook","_hook_get_hook",0)
	register_native( "hook_get_dragging_who","_hook_get_dragging_who",0)
	register_native( "hook_get_hook_kills","_hook_get_hook_kills",0)
	
}
stop_dragging(id){
	
		remove_task(id+HOOK_TASKID)
		if((g_dragging_who[id][0]>=0)){
			if(!client_isnt_hittable( g_dragging_who[id][0])){
				entity_set_int( g_dragging_who[id][0], EV_INT_fixangle, 0 );
			}
			
		}
		g_dragging_who[id][1]=0
		g_dragging_who[id][0]=-1

}

//----------------------------------------------------------------------------------------------
laser_line(ent_id,Float:Pos[3], Float:vEnd[3],killbeam)
{
	if ( !pev_valid(ent_id) ) return

	//This is a little cleaner but not much
	if ( killbeam ) {
		//Kill the Beam
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY) //message begin
		write_byte(TE_KILLBEAM)
		write_short(ent_id) // entity
		message_end()
	}
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) //message begin
	write_byte (0)     //TE_BEAMENTPOINTS 0
	write_coord_f(Pos[0])
	write_coord_f(Pos[1])
	write_coord_f(Pos[2])		// start entity
	write_coord_f(vEnd[0])	// end position
	write_coord_f( vEnd[1])
	write_coord_f(vEnd[2])
	write_short(gSpriteLaser)// sprite index
	write_byte(0)		// starting frame
	write_byte(0)		// frame rate in 0.1's
	write_byte(1)		// life in 0.1's
	write_byte(5)		// line width in 0.1's
	write_byte(0)		// noise amplitude in 0.01's
	write_byte(bleed_color[0])	// Red
	write_byte(bleed_color[1])	// Green
	write_byte(bleed_color[2])	// Blue
	write_byte(255)	// brightness
	write_byte(0)		// scroll speed in 0.1's
	message_end()
}
//----------------------------------------------------------------------------------------------
public hook_think(id)
{
	id-=HOOK_TASKID
	if (client_isnt_hitter(id)){
	
		remove_task(id+HOOK_TASKID)
		return FMRES_IGNORED
	
	}
	if(g_dragging_who[id][0]<0){
		
		g_hook_kills[id]--;
		if(hook_get_hook_kills(id)){							
				
			sh_chat_message(id,tranq_get_hero_id(),"You got %d hook strikes left",hook_get_hook_kills(id));
			
		}
	
	
		remove_task(id+HOOK_TASKID)
		return FMRES_IGNORED
	}
	if(!(g_dragging_who[id][1])){
		
		g_hook_kills[id]--;
		if(hook_get_hook_kills(id)){							
				
			sh_chat_message(id,tranq_get_hero_id(),"You got %d hook strikes left",hook_get_hook_kills(id));
			
		}
		stop_dragging(id)
	
		return FMRES_IGNORED
	
	
	}
	new vic=g_dragging_who[id][0]
	new ammo, clip, wpnid=get_user_weapon(id,ammo,clip)
	if(wpnid!=CSW_KNIFE){
		shSwitchWeaponID(id,CSW_KNIFE)
	}
	static Float:aimvec[3],Float:vAngle[3],Float:vAngles[3],Float:eOrigin[3],Float:vOrigin[3]
	pev(vic,pev_origin,vOrigin)
	pev(id,pev_origin,eOrigin)
	entity_get_vector(vic, EV_VEC_v_angle, vAngle)
	entity_get_vector(vic, EV_VEC_angles, vAngles)
	new Float:direction[3],Float:fl_Velocity[3], Float:length
	VelocityByAim(vic,9999,aimvec)
	
	static Float:vTrace[3], tr
	static Float:vEnd[3],Float:newVec[3]
	for(new i=0;i<3;i++){
		vEnd[i]=vOrigin[i]-aimvec[i]
	}
	tr = 0
	engfunc(EngFunc_TraceLine, vOrigin, vEnd, 0, vic, tr)
	get_tr2(tr, TR_vecEndPos, vTrace)
	
	direction[0] = vTrace[0]-vOrigin[0]
	direction[1] = vTrace[1]-vOrigin[1]
	direction[2] = vTrace[2]-vOrigin[2]

	length = vector_distance(aimvec, vOrigin)
	if (length==0.0) length = 1.0        // avoid division by 0

	newVec[0] = vOrigin[0]+direction[0]*hook_distance/length
	newVec[1] = vOrigin[1]+direction[1]*hook_distance/length
	newVec[2] = vOrigin[2]+direction[2]*hook_distance/length

	fl_Velocity[0] = (newVec[0]-eOrigin[0])*hook_drag_speed
	fl_Velocity[1] = (newVec[1]-eOrigin[1])*hook_drag_speed
	fl_Velocity[2] = (newVec[2]-eOrigin[2])*hook_drag_speed

	entity_set_vector(id, EV_VEC_velocity, fl_Velocity)
	laser_line(id,eOrigin,vOrigin,false)
	orient_user(id,vAngles,vAngle)
	if(!(g_dragging_who[id][1]%30)){
		sh_chat_message(id,tranq_get_hero_id(),"%s",erica_sentences[random_num(0,NUM_SENTENCES-1)]);
		sh_chat_message(vic,tranq_get_hero_id(),"%s",erica_sentences[random_num(0,NUM_SENTENCES-1)]);
	}
	g_dragging_who[id][1]--;
	return FMRES_IGNORED
}

public orient_user(id,Float:angles[3],Float:v_angle[3])
{
	
	entity_set_int( id, EV_INT_fixangle, 0 );
	entity_set_vector(id, EV_VEC_v_angle,v_angle)
	entity_set_vector(id, EV_VEC_angles,angles)
	entity_set_int( id, EV_INT_fixangle, 1 );
	
	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public CmdStart1(attacker, uc_handle)
{
	if ( !is_user_alive(attacker)||!tranq_get_has_erica(attacker)||!hasRoundStarted()||client_isnt_hittable(attacker)) return FMRES_IGNORED;
	//if ( !is_user_alive(attacker)||!tranq_get_has_erica(attacker)) return FMRES_IGNORED;
	
	
	static button;
	button= get_uc(uc_handle, UC_Buttons);
	new clip, ammo, weapon = get_user_weapon(attacker, clip, ammo);
	
	if((weapon==CSW_KNIFE)){
		if((button & IN_DUCK)){
			button&= ~IN_DUCK
			set_pev(attacker, pev_flTimeStepSound, 999)
		
		}
		if((button & IN_RELOAD))
		{
			if((g_dragging_who[attacker][0]<0)){
				button &= ~IN_RELOAD;
				set_uc(uc_handle, UC_Buttons, button);
				
				new Float: vec2LOS[2];
				new Float: vecForward[3];
				new Float: vecForward2D[2];
				
				velocity_by_aim( attacker, floatround(hook_distance), vecForward );
				
				xs_vec_make2d( vecForward, vec2LOS );
				xs_vec_normalize( vec2LOS, vec2LOS );
				
				static Float:vTrace[3], id, tr
				static Float:vOrigin[3],Float:vEnd[3]
				pev(attacker, pev_origin, vOrigin)
				vEnd[0]=vOrigin[0]+vecForward[0]
				vEnd[1]=vOrigin[1]+vecForward[1]
				vEnd[2]=vOrigin[2]+vecForward[2]
				tr = 0
				engfunc(EngFunc_TraceLine, vOrigin, vEnd, 0, attacker, tr)
				get_tr2(tr, TR_vecEndPos, vTrace)
				id = get_tr2(tr, TR_pHit)
				if (!is_user_alive(id) ){
					return FMRES_IGNORED
				
				}
				if(cs_get_user_team(id)==cs_get_user_team(attacker)){
					return FMRES_IGNORED
				}
				velocity_by_aim(id, floatround(hook_distance), vecForward ); 
				
				xs_vec_make2d( vecForward, vecForward2D );
				new att_name[128],vic_name[128];
				
				if( (xs_vec_dot( vec2LOS, vecForward2D ) > hook_distance*0.8) )
				{
					if(!hook_get_hook_kills(attacker)){
					
						sh_chat_message(attacker,tranq_get_hero_id(),"Already hit %d hooks this life!",max_hook_kills_per_life);
						return FMRES_IGNORED
					}
					sh_minibleed_user(id,attacker,tranq_get_hero_id())
					g_dragging_who[attacker][0]=id
					g_dragging_who[attacker][1]=floatround(HOOK_DRAG_THINK_TIMES)
					set_task((HOOK_DRAG_THINK_PERIOD),"hook_think",attacker+HOOK_TASKID,"",0,"b")
					get_user_name(attacker,att_name,127)
					get_user_name(id,vic_name,127)
					sh_chat_message(attacker,tranq_get_hero_id(),"HOOKED TO %s!",vic_name);
					sh_chat_message(id,tranq_get_hero_id(),"%s HOOKED TO YOU! SHAKE EM OFF!",att_name);
					
				}
			}
		}
		else {
		
		
			g_dragging_who[attacker][0]=-1
		
		}
		
	}
	return FMRES_IGNORED;
}
public Erica2_ham_damage(id, idinflictor, attacker, Float:damage, damagebits)
{
if ( !shModActive() || !is_user_alive(id) || !is_user_connected(id)||!is_user_alive(attacker) ||!is_user_connected(attacker) ||!(attacker>=1 && attacker <=SH_MAXSLOTS)) return HAM_IGNORED

new clip,ammo,weapon=get_user_weapon(attacker,clip,ammo)

new CsTeams:att_team=cs_get_user_team(attacker)
if(tranq_get_has_erica(attacker)&&!(cs_get_user_team(id)==att_team)){
	
	if(weapon==CSW_KNIFE){
		new button = pev(attacker, pev_button);
		new bool:stabbing;
		if((button & IN_ATTACK2)){
			
			button &= ~IN_ATTACK2;
			stabbing=true;
		}
		new Float: vec2LOS[2];
		new Float: vecForward[3];
		new Float: vecForward2D[2];
		
		velocity_by_aim( attacker, 1, vecForward );
		
		xs_vec_make2d( vecForward, vec2LOS );
		xs_vec_normalize( vec2LOS, vec2LOS );
		
		velocity_by_aim(id, 1, vecForward ); 
		
		xs_vec_make2d( vecForward, vecForward2D );
		new att_name[128],vic_name[128];
		
		
		if(stabbing){
			
			if( (xs_vec_dot( vec2LOS, vecForward2D ) > 0.8) )
			{
				if(g_dragging_who[attacker][0]==id){
					get_user_name(attacker,att_name,127)
					get_user_name(id,vic_name,127)
						
					sh_extra_damage(id,attacker,floatround(damage*2),"Gutting")
					sh_chat_message(id,tranq_get_hero_id(),"%s",erica_sentences[random_num(0,NUM_SENTENCES-1)]);
					sh_chat_message(attacker,tranq_get_hero_id(),"%s",erica_sentences[random_num(0,NUM_SENTENCES-1)]);
					
				}
			}	
		}
	}
}

return HAM_IGNORED

}
public _hook_get_hook(iPlugin,iParams){
new id=get_param(1)

return hook_on[id];


}
public _hook_set_hook(iPlugin,iParams){
new id=get_param(1)
new value_to_set=get_param(2)
new prev_value=hook_on[id]
if(!prev_value&&value_to_set){
	g_hook_kills[id]=0;
}
hook_on[id]=value_to_set

}
public _hook_get_dragging_who(iPlugin,iParams){
new id=get_param(1)

return g_dragging_who[id][0]


}

public _hook_get_hook_kills(iPlugin,iParams){
new id=get_param(1)

return g_hook_kills[id]


}


client_isnt_hitter(gatling_user){
new bool:result=(!is_user_connected(gatling_user)||!is_user_alive(gatling_user)||gatling_user <= 0 || gatling_user > SH_MAXSLOTS)
if(result) return true

return !tranq_get_has_erica(gatling_user)

}

client_isnt_hittable(gatling_user){
new bool:result=(!is_user_connected(gatling_user)||!is_user_alive(gatling_user))
return result


}


public plugin_precache()
{
	for(new i=0;i<sizeof(man_hook_sounds);i++){
	
		engfunc(EngFunc_PrecacheSound,man_hook_sounds[i] );
	
	}
	gSpriteLaser = precache_model("sprites/laserbeam.spr")

}

public death()
{	
	new id = read_data(2)
	if(tranq_get_has_erica(id)){
		
		stop_dragging(id)
	
	}
	
}
