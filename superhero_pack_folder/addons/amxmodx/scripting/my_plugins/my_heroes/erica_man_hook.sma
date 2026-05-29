#define I_WANT_CONSTANTS
#define I_WANT_MISC_FUNCS
#define I_WANT_QUICK_CHECKS
#include <float>
#include <xs>
#include "../my_include/superheromod.inc"
#include "tranq_gun_inc/sh_erica_get_set.inc"
#include "tranq_gun_inc/sh_man_hook_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"


#define PLUGIN "Superhero erica hook"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

#define ERICA_HOOK_DUMMY_ENTITY_CLASSNAME "erica_hook"

new gHeroID = -1
stock hook_on_mask = 0
stock g_player_hook[SH_MAXSLOTS+1]
stock Float:g_prev_max_speed[SH_MAXSLOTS+1] = { 0.0, ...}
stock g_hook_kills[SH_MAXSLOTS+1] = { 0 , ...}
#define NUM_SENTENCES 5
stock const erica_sentences[NUM_SENTENCES][]={
	
	"TAKE THIS! Wow... this think really went deep... Ok gotta get it off... HMMFFPPH!",
	"Ahhh its too stuck! its between the guys ribs...",
	"Hmmph! hmmph! Man their loosing blood but I still cant get if off!",
	"Man those are guts... those are... his lower vertebrae, I think... ",
	"I think... AHH got it!"
}
#define SENTENCE_TICKS 30
new hook_distance_pcvar
new gutting_dmg_mult_pcvar
new hook_drag_time_pcvar
new max_hook_kills_per_life_pcvar
new hook_drag_speed_pcvar


new dmg_source_name_short_gutting[SAFE_BUFFER_SIZE+1]="gutting"
new dmg_source_name_log_gutting[SAFE_BUFFER_SIZE+1]="gutting"
new custom_dmg_id_gutting

//stock HOOK_TASKID
spawn_erica_hook(id,target){

	if(!sh_is_active()) return

	if(!is_user_alive(id) || !is_user_alive(id)) return
	
	if(!sh_get_user_has_hero(id,gHeroID)) return

	if(is_valid_ent(g_player_hook[id])){
		return
	}
	new erica_hook_to_be_spawned= create_entity("info_target")
	if(!erica_hook_to_be_spawned){

		return
	}
	g_player_hook[id]=erica_hook_to_be_spawned
	entity_set_string(erica_hook_to_be_spawned, EV_SZ_classname, ERICA_HOOK_DUMMY_ENTITY_CLASSNAME)

	entity_set_edict(erica_hook_to_be_spawned, EV_ENT_owner, id)

	//the target
	entity_set_edict(erica_hook_to_be_spawned,EV_ENT_euser1,target)

	//the times
	entity_set_int(erica_hook_to_be_spawned, EV_INT_iuser1,floatround(HOOK_DRAG_THINK_TIMES))

	entity_set_float(erica_hook_to_be_spawned, EV_FL_nextthink,
				get_gametime()+HOOK_DRAG_THINK_PERIOD)
}


public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	hook_distance_pcvar=create_cvar("hook_distance", "2.0")
	max_hook_kills_per_life_pcvar=create_cvar("max_hooks_per_life", "2.0")
	hook_drag_speed_pcvar=create_cvar("hook_drag_speed", "2.0")
	hook_drag_time_pcvar=create_cvar("hook_drag_time", "3")
	gutting_dmg_mult_pcvar=create_cvar("hook_gutting_dmg_mult", "3")
	RegisterHam(Ham_TraceAttack,"player","Erica2_ham_trace_damage",_,true)
	register_think(ERICA_HOOK_DUMMY_ENTITY_CLASSNAME,"hook_think")
	register_forward(FM_CmdStart, "CmdStart")
}
public plugin_cfg(){


	gHeroID=tranq_get_hero_id()

	custom_dmg_id_gutting=sh_log_custom_damage_source(gHeroID,
					dmg_source_name_short_gutting,
					dmg_source_name_log_gutting,
					1)
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

		erica_new_spawn_hooks(i)
	}

	remove_entity_name(ERICA_HOOK_DUMMY_ENTITY_CLASSNAME)
}

erica_new_spawn_hooks(id){

if (  sh_is_active() && is_user_alive(id)&& sh_get_user_has_hero(id,gHeroID)) {
	g_hook_kills[id]=cvar_val(num,max_hook_kills_per_life_pcvar);
}
stop_dragging(id,-1)

}
public plugin_natives(){
	
	
	register_native( "hook_set_hook","_hook_set_hook",0)
	
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
			
			if(g_hook_kills[id]>0){
				g_hook_kills[id]-=deduct?1:0
				if(g_hook_kills[id]>=0){							
					
					if(!is_user_bot(id)){
						sh_chat_message(id,gHeroID,"You've got %d hook strikes left",g_hook_kills[id]);
					}	
				}
			}
			
		}
		if(is_valid_ent(g_player_hook[id])){

			remove_entity(g_player_hook[id])
			g_player_hook[id]=-1
		}
}
//----------------------------------------------------------------------------------------------
public hook_think(ent)
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
	static Float:aimvec[3],Float:eOrigin[3],Float:vOrigin[3],Float:dst_origin[3]
	pev(vic,pev_origin,vOrigin)
	pev(id,pev_origin,eOrigin)
	new Float:fl_Velocity[3]
	velocity_by_aim(vic,9999,aimvec)
	
	xs_vec_normalize(aimvec,aimvec)

	xs_vec_add_scaled(vOrigin,aimvec,-30.0,dst_origin)
	new Float:curr_dist=get_distance_f(eOrigin,dst_origin)


	new Float:speed_to_use= (curr_dist<30.0)?40.0:cvar_val(float,hook_drag_speed_pcvar)


	fl_Velocity[0] = (dst_origin[0]-eOrigin[0])*(speed_to_use/curr_dist)
	fl_Velocity[1] = (dst_origin[1]-eOrigin[1])*(speed_to_use/curr_dist)
	fl_Velocity[2] = (dst_origin[2]-eOrigin[2])*(speed_to_use/curr_dist)

	entity_set_vector(id,EV_VEC_velocity,fl_Velocity)

	dst_origin[2]+=4.0
	new Float: dst_angles[3],Float:dst_v_angles[3]
	new Float: slight_vel[3]
	xs_vec_sub(vOrigin, eOrigin,slight_vel)
	xs_vec_normalize(slight_vel,slight_vel)
	xs_vec_mul_scalar(slight_vel,100.0,slight_vel)
	vector_to_angle(slight_vel,dst_v_angles)
	vector_to_angle(slight_vel,dst_angles)
	orient_user(id,dst_angles,dst_v_angles)
	set_user_maxspeed(id,1.0)

	if(!(times_left%SENTENCE_TICKS)){
		new random_number=generate_int(0,NUM_SENTENCES-1);
		sh_chat_message(id,gHeroID,"%s",erica_sentences[random_number]);
		sh_chat_message(vic,gHeroID,"%s",erica_sentences[random_number]);
	}
	times_left--;
	entity_set_int(ent,EV_INT_iuser1,times_left)
	entity_set_float(ent,EV_FL_nextthink,get_gametime()+HOOK_DRAG_THINK_PERIOD)
	return
}

//----------------------------------------------------------------------------------------------
public CmdStart(attacker, uc_handle)
{

	if(!sh_is_active()||sh_is_freezetime()) return FMRES_IGNORED;

	if ( !is_user_connected(attacker)){
		
		return FMRES_IGNORED;
	}
	if(!is_user_alive(attacker)||!sh_is_inround()){

		
		stop_dragging(attacker)
		return FMRES_IGNORED;
		
	}
	if ( !sh_get_user_has_hero(attacker,gHeroID)||!Get_BitVar(hook_on_mask, attacker)||(g_hook_kills[attacker]<=0)) return FMRES_IGNORED;

	
	new button;
	button= get_uc(uc_handle, UC_Buttons);
	new weapon = get_user_weapon(attacker);
	
	if((weapon==CSW_KNIFE)){
		if((button & IN_DUCK)){
			button &= ~IN_DUCK;
			set_pev(attacker, pev_flTimeStepSound, 999)
		
		}
		if((button & IN_RELOAD))
		{
			if((!is_valid_ent(g_player_hook[attacker]))){
				button &= ~IN_RELOAD;
				set_uc(uc_handle, UC_Buttons, button);
				
				
				new Float:vec2LOS[2],
						Float:vecForward[3],
						Float:vecForward2D[2],
						Float:vOrigin[3],
						Float:vEnd[3],
						Float:vTrace[3]
				
				new id, tr

				velocity_by_aim( attacker, floatround(cvar_val(float,hook_distance_pcvar)), vecForward );
				
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
					free_tr2(tr)
					return FMRES_IGNORED
				}
				velocity_by_aim(id, 1, vecForward ); 
				
				xs_vec_make2d( vecForward, vecForward2D );
				xs_vec_normalize( vecForward2D, vecForward2D );
				static att_name[128],vic_name[128];
				
				if( (xs_vec_dot( vec2LOS, vecForward2D ) > 0.5) )
				{
					if(g_hook_kills[attacker]<=0){

						if(!is_user_bot(attacker)){
							sh_chat_message(attacker,gHeroID,"Already hit %d hooks this life!",cvar_val(num,max_hook_kills_per_life_pcvar));
						}
						free_tr2(tr)
						return FMRES_IGNORED
					}
					sh_bleed_user(id,attacker,BLEED_MINI,gHeroID)

					entity_set_vector(attacker, EV_VEC_velocity, Float:{0.01,0.01,0.01})
					g_prev_max_speed[attacker]=get_user_maxspeed(attacker)
					set_user_maxspeed(attacker,0.1)
					spawn_erica_hook(attacker,id)
					get_user_name(attacker,att_name,127)
					get_user_name(id,vic_name,127)
					if(!is_user_bot(attacker)){
						sh_chat_message(attacker,gHeroID,"HOOKED TO %s!",vic_name);
					}
					if(!is_user_bot(id)){
						sh_chat_message(id,gHeroID,"%s HOOKED TO YOU! SHAKE EM OFF!",att_name);
					}
				}
				free_tr2(tr)
			}
		}
		else if(is_valid_ent(g_player_hook[attacker])){
			new target=entity_get_edict(g_player_hook[attacker],EV_ENT_euser1)
			if(is_user_alive(target)){
				stop_dragging(attacker,target)
			}
		
		}
		
	}
	
	return FMRES_IGNORED;
}
public Erica2_ham_trace_damage(id, attacker, Float:damage, Float:Direction[3], Ptr, DamageBits)
{
if ( !sh_is_active() || !is_user_alive(id)||!is_user_alive(attacker)) return HAM_IGNORED

new weapon=get_user_weapon(attacker)

new CsTeams:att_team=cs_get_user_team(attacker)
if(sh_get_user_has_hero(attacker,gHeroID)&&!(cs_get_user_team(id)==att_team)&&is_valid_ent(g_player_hook[attacker])){
	
	new target=entity_get_edict(g_player_hook[attacker],EV_ENT_euser1)
	if((weapon==CSW_KNIFE)){
		if((id!=target)||!(is_user_alive(target))){

			stop_dragging(attacker,target,true)
			return HAM_IGNORED
		}
		new button = pev(attacker, pev_button);
		new bool:stabbing;
		if((button & IN_ATTACK2)){
			
			button &= ~IN_ATTACK2;
			stabbing=true;
		}
		static Float: vec2LOS[2],
				Float: vecForward[3],
				Float: vecForward2D[2];
		
		velocity_by_aim( attacker, 1, vecForward );
		
		xs_vec_make2d( vecForward, vec2LOS );
		xs_vec_normalize( vec2LOS, vec2LOS );
		
		velocity_by_aim(target, 1, vecForward ); 
		
		xs_vec_make2d( vecForward, vecForward2D );
		static att_name[128],vic_name[128];
		
		
		if(stabbing){
			
			if( (xs_vec_dot( vec2LOS, vecForward2D ) > 0.2) )
			{
				
				if(is_user_alive(target)){

					get_user_name(attacker,att_name,127)
					get_user_name(id,vic_name,127)
						
					sh_extra_damage(target,attacker,floatround(damage*cvar_val(float,gutting_dmg_mult_pcvar)),
								MY_HIT_HEAD
								,_,_,_,_,
								SH_NEW_DMG_BLEED,
								custom_dmg_id_gutting)
					
					new random_number=generate_int(0,NUM_SENTENCES-1);
					
					if(!is_user_bot(target)){
						sh_chat_message(target,gHeroID,"%s",erica_sentences[random_number]);
					}
					if(!is_user_bot(attacker)){
						sh_chat_message(attacker,gHeroID,"%s",erica_sentences[random_number]);
					}
					sh_bleed_user(target,attacker,BLEED_ULTRA,gHeroID)
					
					if(!is_user_alive(target)){
						process_manhook_manslaughter( attacker, target)
					}
				}
				stop_dragging(attacker,target,true)
			}	
		}
	}
}

return HAM_IGNORED

}
public _hook_set_hook(iPlugin,iParams){
new id=get_param(1)
new value_to_set=get_param(2)
new prev_value=Get_BitVar(hook_on_mask, id)

if(!prev_value&&value_to_set){
	g_hook_kills[id]=cvar_val(num,max_hook_kills_per_life_pcvar)
}
Assign_BitVar(hook_on_mask, id,value_to_set)

}
public plugin_precache()
{
	for(new i=0;i<sizeof(man_hook_sounds);i++){
	
		engfunc(EngFunc_PrecacheSound,man_hook_sounds[i] );
	
	}
	

}

public sh_client_death(id)
{
	if(sh_get_user_has_hero(id,gHeroID)){
				
		stop_dragging(id);
	
	}
	
}
process_manhook_manslaughter(iAgressor, iVictim)
{
	new Float:Origin[3], Float:Origin2[3]
	//Check to make sure its a valid entity
	if (!is_valid_ent(iAgressor)) {
		iAgressor = iVictim
	}

	if (!is_user_connected(iVictim)) return

	entity_get_vector(iVictim,EV_VEC_origin,Origin)
	entity_get_vector(iAgressor,EV_VEC_origin,Origin2)

	gross_kill_gibs_fx(iVictim,Origin,Origin2)
}