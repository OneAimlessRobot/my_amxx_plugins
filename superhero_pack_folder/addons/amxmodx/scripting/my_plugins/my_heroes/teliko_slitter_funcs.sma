#define I_WANT_CONSTANTS
#define I_WANT_QUICK_CHECKS
#define I_WANT_MISC_FUNCS
#include <float>
#include <xs>
#include "../my_include/superheromod.inc"
#include "teliko_stuff_inc/sh_teliko_get_set.inc"
#include "tranq_gun_inc/sh_erica_get_set.inc"
#include "teliko_stuff_inc/sh_slitter_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero teliko slitter"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


#define TELIKO_SLITTER_DUMMY_ENTITY_CLASSNAME "teliko_slitter"
new gHeroID = -1
new gHeroID_erica = -1
new slitter_on_mask = 0
new g_player_slitter[SH_MAXSLOTS + 1]
new g_slit_kills[SH_MAXSLOTS + 1]

new Float:g_prev_max_speed[SH_MAXSLOTS+1] = { 0.0, ...}


//floats
new pcvar_slitter_distance
new pcvar_slitter_drag_time
new pcvar_slitter_drag_speed

//nums
new pcvar_max_slitter_kills_per_life

new dmg_source_name_short_sneak[SAFE_BUFFER_SIZE+1]="sneak"
new dmg_source_name_log_sneak[SAFE_BUFFER_SIZE+1]="sneak_attack"
new custom_dmg_id_sneak


//stock HOOK_TASKID
spawn_teliko_slitter(id,target){

	if(!sh_is_active()) return

	if(!is_user_alive(id) || !is_user_alive(id)) return
	
	if(!sh_get_user_has_hero(id,gHeroID)) return

	if(is_valid_ent(g_player_slitter[id])){
		return
	}
	new teliko_hook_to_be_spawned= my_create_entity("info_target")
	if(!teliko_hook_to_be_spawned){

		return
	}
	g_player_slitter[id]=teliko_hook_to_be_spawned
	entity_set_string(teliko_hook_to_be_spawned, EV_SZ_classname, TELIKO_SLITTER_DUMMY_ENTITY_CLASSNAME)

	entity_set_edict(teliko_hook_to_be_spawned, EV_ENT_owner, id)

	//the target
	entity_set_edict(teliko_hook_to_be_spawned,EV_ENT_euser1,target)

	//the times
	entity_set_int(teliko_hook_to_be_spawned, EV_INT_iuser1,floatround(SLITTER_DRAG_THINK_TIMES))

	entity_set_float(teliko_hook_to_be_spawned, EV_FL_nextthink,
				get_gametime()+SLITTER_DRAG_THINK_PERIOD)
}
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	pcvar_slitter_distance = create_cvar("slitter_distance", "2.0")
	pcvar_slitter_drag_time = create_cvar("slitter_drag_time", "3")
	pcvar_slitter_drag_speed = create_cvar("slitter_drag_speed", "2.0")
	pcvar_max_slitter_kills_per_life = create_cvar("max_slits_per_life", "2.0")
	RegisterHam(Ham_TraceAttack,"player","Teliko_ham_trace_damage",_,true)
	register_think(TELIKO_SLITTER_DUMMY_ENTITY_CLASSNAME,"slitter_think")
	register_forward(FM_CmdStart, "CmdStart")
	register_event("CurWeapon", "weaponChange", "be", "1=1")
	

	init_explosion_defaults()
}

stop_dragging(id,target=-1,bool:deduct=false){

		new client_is_here=is_user_alive( target)
		new attacker_is_here=is_user_alive( id )
		if(client_is_here){
			entity_set_int( target, EV_INT_fixangle, 0 );
		}
		if(client_is_here&&attacker_is_here){

			set_user_maxspeed(id,g_prev_max_speed[id])
		}
		if(deduct&&attacker_is_here){
			
			if(g_slit_kills[id]>0){
				g_slit_kills[id]-=deduct?1:0
				if(g_slit_kills[id]>=0){							
					
					if(!is_user_bot(id)){
						sh_chat_message(id,gHeroID,"You've got %d slit kills left",g_slit_kills[id]);
					}	
				}
			}
			
		}
		if(is_valid_ent(g_player_slitter[id])){

			my_remove_entity(g_player_slitter[id])
			g_player_slitter[id]=-1
		}
}
teliko_new_spawn_slits(id){

if (  sh_is_active() && is_user_alive(id)&& sh_get_user_has_hero(id,gHeroID)) {
	g_slit_kills[id]=cvar_val(num,pcvar_max_slitter_kills_per_life);
}
stop_dragging(id,-1)

}
public weaponChange(id)
{
	if ( !sh_get_user_has_hero(id,gHeroID) ||!sh_is_active()) return PLUGIN_CONTINUE
	
	new wpnid = read_data(2)
	if ((wpnid == CSW_KNIFE)&&g_slit_kills[id]) {
		entity_set_string(id, EV_SZ_viewmodel, SLITTER_V_MODEL)
	}
	return PLUGIN_CONTINUE
	
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{	
	if(sh_is_active()&&is_user_alive(id)){
		g_prev_max_speed[id] = get_user_maxspeed(id)
	}
	
}
//----------------------------------------------------------------------------------------------
public sh_round_end()
{
	if(!sh_is_active() ){

		return
	}
	for(new i=1;i< sh_maxplayers()+1;i++){

		teliko_new_spawn_slits(i)
	}

	remove_entity_name(TELIKO_SLITTER_DUMMY_ENTITY_CLASSNAME)
}

//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS();
	
}
//----------------------------------------------------------------------------------------------
public loadCVARS()
{	

	gHeroID = teliko_get_hero_id()
	gHeroID_erica = tranq_get_hero_id()
	
	custom_dmg_id_sneak=sh_log_custom_damage_source(gHeroID,
					dmg_source_name_short_sneak,
					dmg_source_name_log_sneak,
					1)
}
public plugin_natives(){
	
	
	register_native( "slitter_set_slitter","_slitter_set_slitter")
	
}


//----------------------------------------------------------------------------------------------
public slitter_think(ent)
{
	if(!is_valid_ent(ent)){

		return
	}
	new id=entity_get_edict(ent,EV_ENT_owner),
		vic=entity_get_edict(ent,EV_ENT_euser1),
		times_left=entity_get_int(ent,EV_INT_iuser1)
	if (!is_user_alive(id)){
		stop_dragging(id,vic)
		return
	
	}
	if (!sh_get_user_has_hero(id,gHeroID)){

		stop_dragging(id,vic)
		return
	
	}
	if(!is_user_alive( vic)){
		

		stop_dragging(id,vic,true)
		return
	}
	if(times_left<=0){
		
		stop_dragging(id,vic,true)
		return
	
	
	}
	new wpnid=get_user_weapon(id)
	if(wpnid!=CSW_KNIFE){
		sh_switch_weapon(id,CSW_KNIFE)
	}
	static Float:aimvec[3],Float:vAngle[3],Float:vAngles[3],Float:eOrigin[3],Float:vOrigin[3]
	pev(id,pev_origin,vOrigin)
	pev(vic,pev_origin,eOrigin)
	entity_get_vector(id, EV_VEC_v_angle, vAngle)
	entity_get_vector(id, EV_VEC_angles, vAngles)
	new Float:direction[3],Float:fl_Velocity[3], Float:length
	velocity_by_aim(id,9999,aimvec)
	
	static Float:vTrace[3], tr
	static Float:vEnd[3],Float:newVec[3]
	for(new i=0;i<3;i++){
		vEnd[i]=vOrigin[i]+aimvec[i]
	}
	tr = 0
	engfunc(EngFunc_TraceLine, vOrigin, vEnd, 0, id, tr)
	get_tr2(tr, TR_vecEndPos, vTrace)
	
	direction[0] = vTrace[0]-vOrigin[0]
	direction[1] = vTrace[1]-vOrigin[1]
	direction[2] = vTrace[2]-vOrigin[2]

	length = vector_distance(aimvec, vOrigin)
	if (length==0.0) length = 1.0        // avoid division by 0

	newVec[0] = vOrigin[0]+direction[0]*cvar_val(float, pcvar_slitter_distance)/length
	newVec[1] = vOrigin[1]+direction[1]*cvar_val(float, pcvar_slitter_distance)/length

	fl_Velocity[0] = (newVec[0]-eOrigin[0])*DRAG_FORCE
	fl_Velocity[1] = (newVec[1]-eOrigin[1])*DRAG_FORCE
	fl_Velocity[2] = -DRAG_FORCE

	entity_set_vector(vic, EV_VEC_velocity, fl_Velocity)
	
	orient_user(vic,vAngles,vAngle)
	sh_set_stun(vic,2.0,default_stun_speed)
	set_user_maxspeed(id,cvar_val(float, pcvar_slitter_drag_speed))

	times_left--;
	entity_set_int(ent,EV_INT_iuser1,times_left)
	entity_set_float(ent,EV_FL_nextthink,get_gametime()+SLITTER_DRAG_THINK_PERIOD)
}

//----------------------------------------------------------------------------------------------
public CmdStart(attacker, uc_handle)
{	

	if(!sh_is_active()||sh_is_freezetime()){
		return FMRES_IGNORED
	}

	if(!is_user_alive(attacker)||!sh_is_inround()){

		
		stop_dragging(attacker)
		return FMRES_IGNORED
	}
	if ( !sh_get_user_has_hero(attacker,gHeroID) ||sh_get_user_has_hero(attacker,gHeroID_erica) ||!Get_BitVar(slitter_on_mask,attacker)||(g_slit_kills[attacker]<=0)){
		return FMRES_IGNORED
	}

	static button
	button= get_uc(uc_handle, UC_Buttons);
	new weapon = get_user_weapon(attacker);
	
	if((weapon==CSW_KNIFE)){
		if((button & IN_DUCK)){
			button &= ~IN_DUCK;
			set_pev(attacker, pev_flTimeStepSound, 999)
		
		}
		if((button & IN_RELOAD))
		{
			if(!is_valid_ent(g_player_slitter[attacker])){
				button &= ~IN_RELOAD;
				set_uc(uc_handle, UC_Buttons, button);
				
				new Float:vec2LOS[2],
						Float:vecForward[3],
						Float:vecForward2D[2],
						Float:vOrigin[3],
						Float:vEnd[3],
						Float:vTrace[3]
				
				new id,
					tr,
					Float:slitter_distance= cvar_val(float,pcvar_slitter_distance)
				
				velocity_by_aim( attacker, floatround(slitter_distance), vecForward );
				
				xs_vec_make2d( vecForward, vec2LOS );
				xs_vec_normalize( vec2LOS, vec2LOS );

				pev(attacker, pev_origin, vOrigin)
				
				vEnd[0]=vOrigin[0]+vecForward[0]
				vEnd[1]=vOrigin[1]+vecForward[1]
				vEnd[2]=vOrigin[2]+vecForward[2]
				tr = create_tr2()
				if(tr<=0){
					return FMRES_IGNORED
				}
				engfunc(EngFunc_TraceLine, vOrigin, vEnd, 0, attacker, tr)
				get_tr2(tr, TR_vecEndPos, vTrace)
				id = get_tr2(tr, TR_pHit)
				if (!is_user_alive(id) ){
					free_tr2(tr)
					return FMRES_IGNORED
				
				}
				if(sh_clients_are_same_team(id,attacker)){
					return FMRES_IGNORED
				}
				velocity_by_aim(id, 1, vecForward ); 
				
				xs_vec_make2d( vecForward, vecForward2D );
				xs_vec_normalize( vecForward2D, vecForward2D );
				static att_name[128],vic_name[128];

				if( (xs_vec_dot( vec2LOS, vecForward2D ) > 0.5) )
				{	
					if(g_slit_kills[attacker]<=0){

						if(!is_user_bot(attacker)){
							sh_chat_message(attacker,gHeroID,"Already hit %d slit attacks this life!",cvar_val(num,pcvar_max_slitter_kills_per_life));
						}
						free_tr2(tr)
						return FMRES_IGNORED
					}
					entity_set_vector(id, EV_VEC_velocity, Float:{0.01,0.01,0.01})
					g_prev_max_speed[attacker]=get_user_maxspeed(attacker)
					spawn_teliko_slitter(attacker,id)
					get_user_name(attacker,att_name,127)
					get_user_name(id,vic_name,127)
					if(!is_user_bot(attacker)){
						sh_chat_message(attacker,gHeroID,"Snuck up on %s!",vic_name);
					}
					if(!is_user_bot(id)){
						sh_chat_message(id,gHeroID,"You got snuck up on by %s!",att_name);
					}
				}
				free_tr2(tr)
			}
		}
		else if(is_valid_ent(g_player_slitter[attacker])){
			new target=entity_get_edict(g_player_slitter[attacker],EV_ENT_euser1)
			if(is_user_alive(target)){
				stop_dragging(attacker,target)
			}
		
		}
		
	}
	return FMRES_IGNORED;
}
public Teliko_ham_trace_damage(id, attacker, Float:damage, Float:Direction[3], Ptr, DamageBits)
{
if ( !sh_is_active() || !is_user_alive(id) || !is_user_connected(id)||!is_user_alive(attacker) ||!is_user_connected(attacker)) return HAM_IGNORED

new weapon=get_user_weapon(attacker)

new CsTeams:att_team=cs_get_user_team(attacker)
if(sh_get_user_has_hero(attacker,gHeroID) &&!(cs_get_user_team(id)==att_team)&&is_valid_ent(g_player_slitter[attacker])){
	
	new target=entity_get_edict(g_player_slitter[attacker],EV_ENT_euser1)
	if((weapon==CSW_KNIFE)){
		if((id!=target)||!(is_user_alive(target))){

			stop_dragging(attacker,target,true)
			return HAM_IGNORED
		}
		new button = pev(attacker, pev_button);
		new bool:slashing;
		if((button & IN_ATTACK)&&(button & IN_DUCK)){
			
			button &= ~IN_ATTACK;
			button &= ~IN_DUCK;
			slashing=true;
		}
		static Float: vec2LOS[2],
				Float: vecForward[3],
				Float: vecForward2D[2];
		
		velocity_by_aim( attacker, 1, vecForward );
		
		xs_vec_make2d( vecForward, vec2LOS );
		xs_vec_normalize( vec2LOS, vec2LOS );
		
		velocity_by_aim(id, 1, vecForward ); 
		
		xs_vec_make2d( vecForward, vecForward2D );
		static att_name[128],vic_name[128];
		
		
		if(slashing){
			
			if( (xs_vec_dot( vec2LOS, vecForward2D ) > 0.2) )
			{
				if(g_slit_kills[attacker]>0){
					get_user_name(attacker,att_name,127)
					get_user_name(target,vic_name,127)
					if(get_user_godmode(target)){
					
						
						if(!is_user_bot(attacker)){
							sh_chat_message(attacker,gHeroID,"You removed %s's godmode!!",vic_name);
						}
						set_user_godmode(target,0)
					}
					else{
						sh_extra_damage(target,attacker,floatround(damage),
							MY_HIT_HEAD,
							SH_DMG_KILL,_,_,_,
							SH_NEW_DMG_IVE_STUDIED_THE_BLADE,
							custom_dmg_id_sneak)
						
						if(!is_user_bot(attacker)){
							sh_chat_message(attacker,gHeroID,"You slit %s's throat!",vic_name);
						}
						return HAM_SUPERCEDE
					}
				}
				else{
					
					if(!is_user_bot(attacker)){
						sh_chat_message(attacker,gHeroID,"Already hit %d slit kills this life!",
								cvar_val(num, pcvar_max_slitter_kills_per_life));
					}
				}
				stop_dragging(attacker,target,true)
			}	
		}
	}
}

return HAM_IGNORED

}
public _slitter_set_slitter(iPlugin,iParams){
new id=get_param(1)
new value_to_set=get_param(2)
new prev_value=Get_BitVar(slitter_on_mask, id)
if(!prev_value&&value_to_set){
	g_slit_kills[id]=cvar_val(num,pcvar_max_slitter_kills_per_life);
}
Assign_BitVar(slitter_on_mask, id,value_to_set)
}



public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel,SLITTER_V_MODEL)
	for(new i=0;i<sizeof(teliko_slitter_sounds);i++){
	
		engfunc(EngFunc_PrecacheSound,teliko_slitter_sounds[i] );
	
	}

}

public sh_client_death(id){
	
	if(sh_get_user_has_hero(id,gHeroID) ){
		
		stop_dragging(id)
	
	}
	
}
