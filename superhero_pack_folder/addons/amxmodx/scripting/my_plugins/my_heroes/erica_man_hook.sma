#define I_WANT_CONSTANTS
#define I_WANT_QUICK_CHECKS
#define I_WANT_MISC_FUNCS
#include <float>
#include <xs>
#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "tranq_gun_inc/sh_erica_get_set.inc"
#include "tranq_gun_inc/sh_man_hook_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"


#define PLUGIN "Superhero erica hook"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

stock hook_on[SH_MAXSLOTS+1] = { 0 , ...}
stock g_dragging_who[SH_MAXSLOTS+1][2]
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
new Float:hook_distance
new Float:gutting_dmg_mult
new Float:hook_drag_time
new max_hook_kills_per_life
new Float:hook_drag_speed


new dmg_source_name_short_gutting[SAFE_BUFFER_SIZE+1]="gutting"
new dmg_source_name_long_gutting[SAFE_BUFFER_SIZE+1]="gutting"
new custom_dmg_id_gutting

stock HOOK_TASKID

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar("hook_distance", "2.0")
	register_cvar("max_hooks_per_life", "2.0")
	register_cvar("hook_drag_speed", "2.0")
	register_cvar("hook_level_difference", "10")
	register_cvar("hook_drag_time", "3")
	register_cvar("hook_gutting_dmg_mult", "3")
	register_event("ResetHUD","hook_new_round","b")
	RegisterHam(Ham_TakeDamage,"player","Erica2_ham_damage",_,true)
	register_forward(FM_CmdStart, "CmdStart1")
	register_event("DeathMsg","death","a")
	custom_dmg_id_gutting=sh_log_custom_damage_source(tranq_get_hero_id(),
					dmg_source_name_short_gutting,
					dmg_source_name_long_gutting,
					1)
	
	HOOK_TASKID=allocate_typed_task_id(player_task)
}

//----------------------------------------------------------------------------------------------
public hook_new_round(id)
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
}

erica_new_spawn_hooks(id){

if (  sh_is_active() && client_hittable(id)&& sh_user_has_hero(id,tranq_get_hero_id())) {
	g_hook_kills[id]=max_hook_kills_per_life;
}
stop_dragging(id)

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
	hook_drag_time=get_cvar_float("hook_drag_time")
	hook_drag_speed=get_cvar_float("hook_drag_speed")
	max_hook_kills_per_life=get_cvar_num("max_hooks_per_life")
	gutting_dmg_mult=get_cvar_float("hook_gutting_dmg_mult")
}
public plugin_natives(){
	
	
	register_native( "hook_set_hook","_hook_set_hook",0)
	
}
stop_dragging(id,bool:deduct=false){

		new client_is_here=is_user_alive( g_dragging_who[id][0])
		new attacker_is_here=is_user_alive( id )
		if(client_is_here){
			entity_set_int( g_dragging_who[id][0], EV_INT_fixangle, 0 );
		}
		if(client_is_here&&attacker_is_here){

			set_user_maxspeed(id,g_prev_max_speed[id])
		}
		if(deduct&&attacker_is_here){
			
			if(g_hook_kills[id]>0){
				g_hook_kills[id]-=deduct?1:0
				if(g_hook_kills[id]>=0){							
					
					if(!is_user_bot(id)){
						sh_chat_message(id,tranq_get_hero_id(),"You've got %d hook strikes left",g_hook_kills[id]);
					}	
				}
			}
			
		}
		g_dragging_who[id][0]=-1
		g_dragging_who[id][1]=0		
}
//----------------------------------------------------------------------------------------------
public hook_think(id)
{
	
	id-=HOOK_TASKID
	if (!client_hittable(id)){
		stop_dragging(id)
		return
	
	}
	if (!sh_user_has_hero(id,tranq_get_hero_id())){

		stop_dragging(id)
		return
	
	}
	if(!client_hittable( g_dragging_who[id][0])){
		

		stop_dragging(id,true)
		return
	}
	if((g_dragging_who[id][1])<=0){
		
		stop_dragging(id,true)
		return
	
	
	}
	new vic=g_dragging_who[id][0]
	new ammo, clip, wpnid=get_user_weapon(id,ammo,clip)
	if(wpnid!=CSW_KNIFE){
		shSwitchWeaponID(id,CSW_KNIFE)
	}
	static Float:aimvec[3],Float:eOrigin[3],Float:vOrigin[3],Float:dst_origin[3]
	pev(vic,pev_origin,vOrigin)
	pev(id,pev_origin,eOrigin)
	new Float:fl_Velocity[3]
	velocity_by_aim(vic,9999,aimvec)
	
	xs_vec_normalize(aimvec,aimvec)

	xs_vec_add_scaled(vOrigin,aimvec,-30.0,dst_origin)
	new Float:curr_dist=get_distance_f(eOrigin,dst_origin)


	new Float:speed_to_use= (curr_dist<30.0)?40.0:hook_drag_speed


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

	if(!(g_dragging_who[id][1]%SENTENCE_TICKS)){
		new random_number=generate_int(0,NUM_SENTENCES-1);
		sh_chat_message(id,tranq_get_hero_id(),"%s",erica_sentences[random_number]);
		sh_chat_message(vic,tranq_get_hero_id(),"%s",erica_sentences[random_number]);
	}
	g_dragging_who[id][1]--;
	set_task((HOOK_DRAG_THINK_PERIOD),"hook_think",id+HOOK_TASKID)
	return
}

//----------------------------------------------------------------------------------------------
public CmdStart1(attacker, uc_handle)
{

	if(!sh_is_active()||sh_is_freezetime()) return FMRES_IGNORED;

	if ( !is_user_connected(attacker)){
		
		return FMRES_IGNORED;
	}
	if(!is_user_alive(attacker)||!sh_is_inround()){

		
		stop_dragging(attacker)
		return FMRES_IGNORED;
		
	}
	if ( !sh_user_has_hero(attacker,tranq_get_hero_id())||!hook_on[attacker]||(g_hook_kills[attacker]<=0)) return FMRES_IGNORED;
	
	if(sh_get_stun(attacker)) return FMRES_IGNORED
	
	new button;
	button= get_uc(uc_handle, UC_Buttons);
	new clip, ammo, weapon = get_user_weapon(attacker, clip, ammo);
	
	if((weapon==CSW_KNIFE)){
		if((button & IN_DUCK)){
			button &= ~IN_DUCK;
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
				
				new Float:vTrace[3], id, tr
				new Float:vOrigin[3],Float:vEnd[3]
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
				if (!is_user_alive(get_tr2(tr, TR_pHit))) {
					free_tr2(tr)
					return FMRES_IGNORED
				}
				
				if (!is_user_alive(id) ){
					free_tr2(tr)
					return FMRES_IGNORED
				
				}
				if(sh_clients_are_same_team(id,attacker)){
					free_tr2(tr)
					return FMRES_IGNORED
				}
				velocity_by_aim(id, floatround(hook_distance), vecForward ); 
				
				xs_vec_make2d( vecForward, vecForward2D );
				static att_name[128],vic_name[128];
				
				if( (xs_vec_dot( vec2LOS, vecForward2D ) > hook_distance*0.5) )
				{
					if(g_hook_kills[attacker]<=0){

						if(!is_user_bot(attacker)){
							sh_chat_message(attacker,tranq_get_hero_id(),"Already hit %d hooks this life!",max_hook_kills_per_life);
						}
						free_tr2(tr)
						return FMRES_IGNORED
					}
					sh_bleed_user(id,attacker,BLEED_MINI,tranq_get_hero_id())
					g_dragging_who[attacker][0]=id
					g_dragging_who[attacker][1]=floatround(HOOK_DRAG_THINK_TIMES)
					entity_set_vector(attacker, EV_VEC_velocity, Float:{0.01,0.01,0.01})
					g_prev_max_speed[attacker]=get_user_maxspeed(attacker)
					set_user_maxspeed(attacker,0.1)
					set_task((HOOK_DRAG_THINK_PERIOD),"hook_think",attacker+HOOK_TASKID)
					get_user_name(attacker,att_name,127)
					get_user_name(id,vic_name,127)
					if(!is_user_bot(attacker)){
						sh_chat_message(attacker,tranq_get_hero_id(),"HOOKED TO %s!",vic_name);
					}
					if(!is_user_bot(id)){
						sh_chat_message(id,tranq_get_hero_id(),"%s HOOKED TO YOU! SHAKE EM OFF!",att_name);
					}
				}
				free_tr2(tr)
			}
		}
		else if(is_user_connected(g_dragging_who[attacker][0])){
	
			stop_dragging(attacker)
		
		}
		
	}
	
	return FMRES_IGNORED;
}
public Erica2_ham_damage(id, idinflictor, attacker, Float:damage, damagebits)
{
if ( !sh_is_active() || !client_hittable(id)||!client_hittable(attacker)) return HAM_IGNORED

new clip,ammo,weapon=get_user_weapon(attacker,clip,ammo)

new CsTeams:att_team=cs_get_user_team(attacker)
if(sh_user_has_hero(attacker,tranq_get_hero_id())&&!(cs_get_user_team(id)==att_team)){
	
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
		static att_name[128],vic_name[128];
		
		
		if(stabbing){
			
			if( (xs_vec_dot( vec2LOS, vecForward2D ) > 0.2) )
			{

				if(g_dragging_who[attacker][0]==id){
					get_user_name(attacker,att_name,127)
					get_user_name(id,vic_name,127)
						
					sh_extra_damage(id,attacker,floatround(damage*gutting_dmg_mult),
								dmg_source_name_long_gutting,1
								,_,_,_,_,_,
								SH_NEW_DMG_BLEED,
								custom_dmg_id_gutting)
					
					new random_number=generate_int(0,NUM_SENTENCES-1);
					
					if(!is_user_bot(id)){
						sh_chat_message(id,tranq_get_hero_id(),"%s",erica_sentences[random_number]);
					}
					if(!is_user_bot(attacker)){
						sh_chat_message(attacker,tranq_get_hero_id(),"%s",erica_sentences[random_number]);
					}
					sh_bleed_user(id,attacker,BLEED_ULTRA,tranq_get_hero_id())
					
					if(!is_user_alive(id)){
						process_manhook_manslaughter( attacker, id)
					}
				}
				stop_dragging(attacker,true)
			}	
		}
	}
}

return HAM_IGNORED

}
public _hook_set_hook(iPlugin,iParams){
new id=get_param(1)
new value_to_set=get_param(2)
new prev_value=hook_on[id]
if(!prev_value&&value_to_set){
	g_hook_kills[id]=max_hook_kills_per_life
}
hook_on[id]=value_to_set

}
public plugin_precache()
{
	for(new i=0;i<sizeof(man_hook_sounds);i++){
	
		engfunc(EngFunc_PrecacheSound,man_hook_sounds[i] );
	
	}
	

}

public death()
{	
	new id = read_data(2)
	
	if(sh_user_has_hero(id,tranq_get_hero_id())){
				
		stop_dragging(id);
	
	}
	
}
process_manhook_manslaughter(iAgressor, iVictim)
{
	new Float:Origin[3], Float:Origin2[3]
	//Check to make sure its a valid entity
	if (!pev_valid(iAgressor)) {
		iAgressor = iVictim
	}

	if (!is_user_connected(iVictim)) return

	entity_get_vector(iVictim,EV_VEC_origin,Origin)
	entity_get_vector(iAgressor,EV_VEC_origin,Origin2)

	gross_kill_gibs_fx(iVictim,Origin,Origin2)
}
