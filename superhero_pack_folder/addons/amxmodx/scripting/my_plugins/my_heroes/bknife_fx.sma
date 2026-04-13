#include "../my_include/superheromod.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt2.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"


#define PLUGIN "Superhero bleed fx"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

enum bleed_task_parameter_id{
	Float:bleed_task_period,
	Float:bleed_task_time,
	bleed_task_repeats,
	bleed_task_apply_id,
	bleed_task_remove_id,
	bleed_task_apply_func_name[128],
	bleed_task_remove_func_name[128]
}
enum bleed_alpha_type{
  hud_alpha,
  render_alpha
}
stock const bleed_type_names[_:NUM_BLEED_TYPES][]={
			"no bleeding",
      "mini bleeding",
      "bleeding",
      "ultrableeding"
}
stock const bleed_type_damages[_:NUM_BLEED_TYPES]={
			0,
      10,
      40,
      40
}
stock const bleed_type_alphas[_:NUM_BLEED_TYPES][bleed_alpha_type]={
			{0,0},
      {50,255},
      {75,255},
      {120,255}
}
stock bleed_task_parameters[_:NUM_BLEED_TYPES][bleed_task_parameter_id]={	
					{-1.0,5.0,0,-1,-1,"",""},
					{1.0,5.0,0,-1,-1,"bleed_task","unbleed_task"},
					{1.0,5.0,0,-1,-1,"bleed_task","unbleed_task"},
					{0.25,5.0,0,-1,-1,"bleed_task","unbleed_task"}

}

new gIsBleeding[SH_MAXSLOTS+1]
public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);
arrayset(gIsBleeding,NONE,SH_MAXSLOTS+1)

for(new i=_:BLEED_MINI;i<_:NUM_BLEED_TYPES;i++){
	
	bleed_task_parameters[i][bleed_task_apply_id]=allocate_typed_task_id(player_task)
	bleed_task_parameters[i][bleed_task_remove_id]=allocate_typed_task_id(player_task)
	static Float:the_period;
	the_period=bleed_task_parameters[i][bleed_task_period]
	static Float:the_time;
	the_time=bleed_task_parameters[i][bleed_task_time]
	bleed_task_parameters[i][bleed_task_repeats]=floatround(floatdiv(the_time,the_period))
}
register_event("DeathMsg","on_death_bleeding","a")
register_event("ResetHUD","bleed_newRound","b")
init_hud_syncs()

}

//----------------------------------------------------------------------------------------------
public bleed_newRound(id)
{	
	if(shModActive()&&client_hittable(id)){
		if(gIsBleeding[id]){
			sh_unbleed_user(id)
		}
	}
	
}
public plugin_natives(){


	register_native("sh_bleed_user","_sh_bleed_user",0);
	register_native("sh_unbleed_user","_sh_unbleed_user",0);
	register_native("make_bleed_fx","_make_bleed_fx",0);
	register_native("do_bleed_knife_attack","_do_bleed_knife_attack",0)
	register_native("sh_get_user_is_bleeding","_sh_get_user_is_bleeding",0)

}
public _sh_get_user_is_bleeding(iPlugin,iParam){

	new id= get_param(1)
	return gIsBleeding[id]
}
public _do_bleed_knife_attack(iPlugin,iParam){

new id= get_param(1)
new attacker= get_param(2)
new hero_id= get_param(3)
new slash_damage=get_param(4)
new stab_damage=get_param(5)
new optional_bool=get_param(6)
new attack_name_string[128]
get_string(7,attack_name_string,127)
new blood_sound_sample[128]
get_string(8,blood_sound_sample,127)
new heal_attacker=get_param(9)

new clip,ammo,weapon=get_user_weapon(attacker,clip,ammo)

if(optional_bool&&!(sh_clients_are_same_team(id,attacker))&&(attacker!=id)){

	if(weapon==CSW_KNIFE){
		emit_sound(attacker, CHAN_WEAPON, blood_sound_sample, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		new button = pev(attacker, pev_button);
		new bool:slashing;
		new bool:stabbing;
		if(button & IN_ATTACK2){
			
			button &= ~IN_ATTACK2;
			stabbing=true;
			slashing=false
		}
		if(button & IN_ATTACK){
			
			button &= ~IN_ATTACK;
			stabbing=false;
			slashing=true
		}
		new Float: vec2LOS[2];
		new Float: vecForward[3];
		new Float: vecForward2D[2];
	
		velocity_by_aim( attacker, 1, vecForward );
      
		xs_vec_make2d( vecForward, vec2LOS );
		xs_vec_normalize( vec2LOS, vec2LOS );
    
		velocity_by_aim(id, 1, vecForward ); 
        
		xs_vec_make2d( vecForward, vecForward2D );
		new damage=(stabbing?stab_damage:slash_damage)
		if(stabbing){
			
			if( (xs_vec_dot( vec2LOS, vecForward2D ) > 0.8) )
			{
				sh_bleed_user(id,attacker,BLEED_ULTRA,hero_id,heal_attacker)
				damage=damage*4;
			}
			else{
				sh_bleed_user(id,attacker,BLEED_NORMAL,hero_id,heal_attacker)
			}
		}
		else if(slashing){
			
			sh_bleed_user(id,attacker,BLEED_MINI,hero_id,heal_attacker)
		}
		sh_extra_damage(id,attacker,damage,attack_name_string,0,SH_DMG_NORM)
		
	}
}
return HAM_IGNORED
}

bleed_task_user(id,attacker,heal_user){
	if ( !shModActive()  || !client_hittable(id)||!client_hittable(attacker)) return
	new array[3]
	array[0] = gIsBleeding[id]
	array[1] = attacker
	array[2] = heal_user
	set_task(bleed_task_parameters[gIsBleeding[id]][bleed_task_period],
					bleed_task_parameters[gIsBleeding[id]][bleed_task_apply_func_name],
					id+bleed_task_parameters[gIsBleeding[id]][bleed_task_apply_id],
					array,
					3,
					"a",
					bleed_task_parameters[gIsBleeding[id]][bleed_task_repeats])

	set_task(floatsub(bleed_task_parameters[gIsBleeding[id]][bleed_task_time],0.1),
					bleed_task_parameters[gIsBleeding[id]][bleed_task_remove_func_name],
					id+bleed_task_parameters[gIsBleeding[id]][bleed_task_remove_id],
					array,
					1,
					"a",
					1)



}

public _sh_bleed_user(iPlugin,iParams){

	new user=get_param(1)
	new attacker=get_param(2)
	new bleed_type=get_param(3)
	new gHeroID=get_param(4)
	new heal_user=get_param(5)
	if ( !shModActive() || !client_hittable(user)||!client_hittable(attacker)) return

	new attacker_name[128]
	get_user_name(attacker,attacker_name,127)
	new user_name[128]
	get_user_name(user,user_name,127)
	if(!gIsBleeding[user]){
		
		
		if(!is_user_bot(user)){
			sh_chat_message(user,gHeroID,"%s has bled you!!!",attacker_name)
		}
		if(!is_user_bot(attacker)){
			sh_chat_message(attacker,gHeroID,"You just bled %s!!!",user_name)
		
		}
		emit_sound(user, CHAN_STATIC, BLEED_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		gIsBleeding[user]=bleed_type
		bleed_task_user(user,attacker,heal_user)
	}



}
public plugin_precache(){
	
	engfunc(EngFunc_PrecacheSound, BLEED_SFX)

}

public _sh_unbleed_user(iPlugin,iParams){

	new user=get_param(1)
	unbleed_user(user)




}
public _make_bleed_fx(iPlugin,iParams){

	new id=get_param(1)
	new origin[3]
	get_user_origin(id,origin)
	fx_blood(origin,origin,HIT_STOMACH,false)
}

public bleed_task(array[],id){
	id-=bleed_task_parameters[array[0]][bleed_task_apply_id]
	if ( !shModActive() ||!client_hittable(id)||!client_hittable(array[1])) return

	set_render_with_color_const(id,RED,1,bleed_type_alphas[array[0]][render_alpha],bleed_type_alphas[array[0]][hud_alpha])
	if(array[2]){
		generic_heal(heal_hp_hud_msg_sync,
					array[1],
					float(bleed_type_damages[array[0]]),
					_,
					RED,
					_,
					_,
					bleed_type_alphas[array[0]][hud_alpha],1,0)
	}
	else{
		set_render_with_color_const(array[1],RED,0,_,bleed_type_alphas[array[0]][hud_alpha],1)
	}
	make_bleed_fx(id)
	sh_extra_damage(id,array[1],bleed_type_damages[array[0]],new_dmg_type_names[_:SH_NEW_DMG_BLEED],0,_,_,_,_,_,
			SH_NEW_DMG_BLEED,
			get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_BLEED))
	


}
public unbleed_task(array[],id){
	id-=bleed_task_parameters[array[0]][bleed_task_remove_id]
	
	if ( !shModActive() || !is_user_connected(id)) return
	remove_task(id+bleed_task_parameters[array[0]][bleed_task_apply_id])
	set_user_rendering(id)
	gIsBleeding[id]=NONE



}

unbleed_user(id){
	remove_task(id+bleed_task_parameters[gIsBleeding[id]][bleed_task_remove_id])
	remove_task(id+bleed_task_parameters[gIsBleeding[id]][bleed_task_apply_id])
	if ( !shModActive() || !is_user_connected(id)) return
	
	set_user_rendering(id)
	gIsBleeding[id]=NONE



}

public on_death_bleeding()
{	
	new id = read_data(2)
	
	if(is_user_connected(id)&&sh_is_active()){
		sh_unbleed_user(id)
	
	}
	
}