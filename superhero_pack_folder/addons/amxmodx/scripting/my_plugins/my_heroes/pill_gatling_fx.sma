#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "special_fx_inc/sh_gatling_funcs.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"


#define PLUGIN "Superhero yakui pt2 pt1"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"


const fPainShock = 108


new gLastWeapon[SH_MAXSLOTS+1]
new gLastClipCount[SH_MAXSLOTS+1]
public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);
new wpnName[32]
for ( new wpnId = CSW_P228; wpnId <= CSW_P90; wpnId++ )
{
	if ( !(NO_RECOIL_WEAPONS_BITSUM & (1<<wpnId)) && get_weaponname(wpnId, wpnName, charsmax(wpnName)) )
	{
			RegisterHam(Ham_Weapon_PrimaryAttack, wpnName, "Ham_Weapon_PrimaryAttack_Post", 1,true) 
	}
}
for(new i=_:GLOW;i<_:NUM_FX;i++){
	
	fx_task_parameters[i][_:fx_task_apply_id]=allocate_typed_task_id(player_task)
	fx_task_parameters[i][_:fx_task_remove_id]=allocate_typed_task_id(player_task)
	static Float:the_period;
	the_period=fx_task_parameters[i][_:fx_task_period]
	static Float:the_time;
	the_time=fx_task_parameters[i][_:fx_task_time]
	fx_task_parameters[i][_:fx_task_repeats]=floatround(floatdiv(the_time,the_period))
}
RegisterHam(Ham_TakeDamage, "player", "Player_TakeDamage", 1,true) 
register_event("Damage", "crack_damage", "b", "2!0")
register_event("CurWeapon", "fire_weapon", "be", "1=1", "3>0")
register_event("DeathMsg","on_death_status","a")
}
public plugin_natives(){


	register_native("sh_effect_user","_sh_effect_user",0);
	register_native("sh_gen_effect","_get_fx_num",0);
	register_native("sh_get_user_effect","_sh_get_user_effect",0);
	register_native("sh_effect_user_direct","_sh_effect_user_direct",0);
	register_native("sh_uneffect_user","_sh_uneffect_user",0);
	register_native("sh_get_fx_color_name","_sh_get_fx_color_name",0);
}


public crack_damage(id)
{
	if ( !sh_is_active() || !client_hittable(id)) return
	
	new  Float:damage= float(read_data(2))
	new weapon, bodypart, attacker = get_user_attacker(id, weapon, bodypart)
	new headshot = bodypart == 1 ? 1 : 0
	if ( !client_hittable(attacker)||attacker==id) return
	
	new fx_num_att=(gatling_get_fx_num(attacker));
	new fx_num_vic=(gatling_get_fx_num(id));
	switch (fx_num_att){
		case POISON:{
			new Float:extraDamage = damage * POISON_DMG_MULT - damage
			if (floatround(extraDamage)>0){
				sh_extra_damage(id, attacker, floatround(extraDamage), "Crackhead rage", headshot)
					
			}	
		}
		case METYLPHENIDATE:{
			new gained_xp= floatround(FOCUS_XPMULT*damage);
			new current_xp= sh_get_user_xp(attacker)
			new new_xp= gained_xp+ current_xp;
			sh_set_user_xp(attacker,new_xp);
		}
		default:{
		
		}
	}
	switch(fx_num_vic){

		case RADIOACTIVE:{
			new Float:extraDamage = damage * RADIOACTIVE_DAMAGE_VULNERABILITY_COEFF + damage
			if (floatround(extraDamage)>0){
				sh_extra_damage(id, attacker, floatround(extraDamage), "Radoactive damage vulnerability", headshot)
				
				if(!is_user_bot(attacker)){
					sh_chat_message(attacker,-1,"You've dealt %0.2f more damage thanks to radioactive damage vulnerability!",damage * RADIOACTIVE_DAMAGE_VULNERABILITY_COEFF)
				}
			}	
		}
		default:{

		}
	}
	
}

public sh_extra_damage_fwd_pre(&victim, &attacker, &damage,wpnDescription[32],  &headshot,&dmgMode, &bool:dmgStun, &bool:dmgFFmsg, const Float:dmgOrigin[3],&dmg_type,&sh_thrash_brat_dmg_type:new_dmg_type,&custom_weapon_id){
	if (!sh_is_active() || !client_hittable(victim) || !client_hittable(attacker)) return DMG_FWD_PASS

	new fx_num_att=(gatling_get_fx_num(attacker));
	new fx_num_vic=(gatling_get_fx_num(victim));
	switch (fx_num_att){
		case POISON:{
			new Float:extraDamage = damage * POISON_DMG_MULT - damage
			if (floatround(extraDamage)>0){
				damage=floatround(extraDamage)
			}	
		}
		case METYLPHENIDATE:{
			new gained_xp= floatround(FOCUS_XPMULT*damage);
			new current_xp= sh_get_user_xp(attacker)
			new new_xp= gained_xp+ current_xp;
			sh_set_user_xp(attacker,new_xp);
		}
		default:{
		
		}
	}
	switch(fx_num_vic){

		case RADIOACTIVE:{
			new Float:extraDamage = damage * RADIOACTIVE_DAMAGE_VULNERABILITY_COEFF + damage
			if (floatround(extraDamage)>0){
				damage=floatround(extraDamage)
				
			}	
		}
		default:{
			
		}
	}
	return DMG_FWD_PASS
}

public fire_weapon(id)
{
	
	if (!is_user_connected(id)||!is_user_alive(id)||!((gatling_get_fx_num(id)==POISON)||(gatling_get_fx_num(id)==COCAINE))) return PLUGIN_CONTINUE 
	new wpnid = read_data(2)		// id of the weapon 
	new ammo = read_data(3)		// ammo left in clip 
	
	if (gLastWeapon[id] == 0) gLastWeapon[id] = wpnid
	
	if ((gLastClipCount[id] > ammo)&&(gLastWeapon[id] == wpnid)) 
	{
		
		draw_aim_vector(id,(gatling_get_fx_num(id)==POISON)?{GREEN,GREEN,GREEN}:{PINK,PINK,PINK})
		if((gatling_get_fx_num(id)==COCAINE)){
		
			do_fast_shot(id,wpnid,COCAINE_FIRE_RATE_MULT)
		}
	}
	gLastClipCount[id] = ammo
	gLastWeapon[id]=wpnid;
	return PLUGIN_CONTINUE 
	
}

//----------------------------------------------------------------------------------------------
public Ham_Weapon_PrimaryAttack_Post(weapon_ent)
{
	if(pev_valid(weapon_ent)!=2){

		return HAM_IGNORED;
	}
	if ( !sh_is_active() ){
		return HAM_IGNORED
	}
	new owner = get_pdata_cbase(weapon_ent, m_ppPlayer, XO_WEAPON)
	if(!client_hittable(owner)){
		return HAM_IGNORED
	}
	if ( gatling_get_fx_num(owner)==METYLPHENIDATE) {
		set_pev(owner, pev_punchangle, {0.0, 0.0, 0.0})
	}

	return HAM_IGNORED
}
public Player_TakeDamage(id)
{
 if ( !sh_is_active() || !is_user_alive(id) || !( gatling_get_fx_num(id)==BATH)) return
 
 set_pdata_float(id, fPainShock, 1.0, 5)
} 
public fx_id:_sh_get_user_effect(iPlugins,iParams){
	
	new id=get_param(1)
	if(!client_hittable(id)||!sh_is_active()){
		
		return NONE;
	}
	
	return gatling_get_fx_num(id)

}

public _sh_get_fx_color_name(iPlugins,iParams){
	
	new fx_num=get_param(1)
	set_array(2,fx_colors[fx_num],4)
	set_array(3,fx_names[fx_num],128)
	


}
screen_fade_with_color_num(id,fx_id:the_color_num){

	sh_screen_fade(id, 0.1, 0.9, fx_colors[the_color_num][0], fx_colors[the_color_num][1], fx_colors[the_color_num][2], 50)

}


fx_task_user(id,fx_id:fx_num){
	if ( !shModActive() ||!client_hittable(id)) return
	set_task(fx_task_parameters[fx_num][fx_task_period],
					fx_task_parameters[fx_num][fx_task_apply_func_name],
					id+fx_task_parameters[fx_num][fx_task_apply_id],
					"",
					0,
					"a",
					fx_task_parameters[fx_num][fx_task_repeats])

	set_task(floatsub(floatmul(fx_task_parameters[fx_num][fx_task_period],
					float(fx_task_parameters[fx_num][fx_task_repeats])),0.1),
					fx_task_parameters[fx_num][fx_task_remove_func_name],
					id+fx_task_parameters[fx_num][fx_task_remove_id],
					"",
					0,
					"a",
					1)



}
public fx_id:_get_fx_num(iPlugin,iParams){


	new Float:chance=random_float(0.0,1.0)


	for(new fx_id:i=KILL;i<NUM_FX;i++){
		new Float:compared=fx_rarity_slice_edges[i];
		if(chance<compared){

			return i;
		}

	}
	return NONE

}
execute_effect_task(fx_id:fx_num,user){






}
public _sh_effect_user_direct(iPlugin,iParams){

	new user=get_param(1)
	new attacker=get_param(2)
	new fx_num=get_param(3)
	new gHeroID=get_param(4)
	if(user==attacker){
	
		
		sh_chat_message(attacker,gHeroID,"Hehe...")
	
	}
	switch(fx_num){
		case KILL:{
			if(user==attacker){
				new attacker_name[128]
				get_user_name(attacker,attacker_name,127)
				sh_chat_message(0,gHeroID,"%s: Dont worry guys! Momma Yakui has everything under control... what doesnt kill me can only... *thud*",attacker_name)
			
			}
			kill_user(user,attacker)
			
		
		
		}
		case GLOW:{
		
			fx_task_user(id,fx_num)
		
		
		}
		case STUN:{
		
		
			fx_task_user(id,fx_num)
		
		}
		case POISON:{
		
		
			poison_user(user,attacker)
		
		}
		case RADIOACTIVE:{
		
		
			fx_task_user(id,fx_num)
		
		}
		case MORPHINE:{
		
		
			fx_task_user(id,fx_num)
		
		}
		case WEED:{
		
		
			fx_task_user(id,fx_num)
		
		}
		case COCAINE:{
		
		
			cocaine_user(user,attacker,gHeroID)
		
		}
		case BLIND:{
		
		
			fx_task_user(id,fx_num)
		
		}
		case METYLPHENIDATE:{
		
		
			fx_task_user(id,fx_num)
		
		}
		case BATH:{
		
		
			fx_task_user(id,fx_num)
		
		}
		default:{
		
			return NONE;
		
		}
	
	
	
	
	}
	return fx_num;




}
public fx_id:_sh_effect_user(iPlugin,iParams){

	new fx_id:fx_num=sh_gen_effect()
	new user=get_param(1)
	new attacker=get_param(2)
	new gHeroID=get_param(3)
	sh_effect_user_direct(user,attacker,fx_num,gHeroID)
	return fx_num;




}



public fx_id:_sh_uneffect_user(iPlugin,iParams){

	new user=get_param(1)
	new fx_num=get_param(2)
	new gHeroID=get_param(3)
	
	uneffect_user_primitive(id,true)
	if(!is_user_bot(user)){
		sh_chat_message(user,gHeroID,fx_remove_strings[fx_num])
	}
	gatling_set_fx_num(user,0)
	return fx_num;




}
kill_user(id,attacker){
	
	
	if ( !shModActive() ||!client_hittable(id)) return
	sh_screen_fade(id, 0.1, 0.9, fx_colors[KILL][0], fx_colors[KILL][1], fx_colors[KILL][2], 50)
	sh_extra_damage(id,attacker,1,"Cyanide Pill",0,SH_DMG_KILL)
	gatling_set_fx_num(id, NONE)


}


public glow_task(id){
	id-=GLOW_TASKID

	if ( !shModActive() ||!client_hittable(id)) return
	sh_set_rendering(id, fx_colors[GLOW][0], fx_colors[GLOW][1], fx_colors[GLOW][2], fx_colors[GLOW][3],kRenderFxGlowShell, kRenderTransAlpha)
	aura(id,fx_colors[GLOW])
	
	


}
stun_user(id){

	
	if ( !shModActive() ||!client_hittable(id)) return
	sh_set_stun(id, STUN_PERIOD, STUN_SPEED)
	sh_screen_shake(id, 16.0, (STUN_PERIOD), 2.0)
	set_task(STUN_PERIOD,"unstun_task",id+UNSTUN_TASKID,"", 0,  "a",1)



}
unstun_user(id){

	if ( !shModActive() ||!client_hittable(id)) return
	sh_screen_fade(id, 0.1, 0.9, fx_colors[STUN][0], stun_color[1], stun_color[2],  50)
	sh_set_stun(id,0.0,1.0)
	gatling_set_fx_num(id, 0)
	sh_screen_shake(id,0.0,0.0,0.0)
	remove_task(id+UNSTUN_TASKID)



}
public poison_task(array[],id){
	id-=POISON_TASKID

	if ( !shModActive() ||!client_hittable(id)||!client_hittable(array[0])) return
	sh_set_rendering(id, poison_color[0], poison_color[1], poison_color[2], poison_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, 0.9, poison_color[0], poison_color[1], poison_color[2], 50)
	sh_extra_damage(id,array[0],POISON_DAMAGE,"Crack pill",0,SH_DMG_NORM)
	
	


}

poison_user(id,attacker){
	new array[1]
	array[0] = attacker
	if ( !shModActive() ||!client_hittable(id)||!client_hittable(array[0])) return
	set_task(POISON_PERIOD,"poison_task",id+POISON_TASKID,array, sizeof(array),  "a",POISON_TIMES)
	set_task(floatsub(floatmul(POISON_PERIOD,float(POISON_TIMES)),0.1),"unpoison_task",id+UNPOISON_TASKID,"", 0,  "a",1)



}
public unpoison_task(id){
	id-=UNPOISON_TASKID
	remove_task(id+POISON_TASKID)
	if ( !shModActive() ||!is_user_connected(id)) return
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	gatling_set_fx_num(id, 0)



}

unpoison_user(id){
	remove_task(id+UNPOISON_TASKID)
	remove_task(id+POISON_TASKID)
	if ( !shModActive() ||!is_user_connected(id)) return
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	gatling_set_fx_num(id, 0)



}

radioactive_user(id,attacker){
	
	if ( !shModActive() ||!client_hittable(id)||!client_hittable(attacker)) return
	track_user(id,attacker,1,RADIOACTIVE_DAMAGE,RADIOACTIVE_PERIOD,RADIOACTIVE_TIME)


}
unradioactive_user(id,attacker){
	
	if ( !shModActive() ||!client_hittable(id)||!client_hittable(attacker)) return
	track_user(id,attacker,1,RADIOACTIVE_DAMAGE,RADIOACTIVE_PERIOD,RADIOACTIVE_TIME)


}
public blind_task(id){
	id-=BLIND_TASKID
	if ( !shModActive() ||!client_hittable(id)) return
	sh_screen_fade(id, 0.1, BLIND_PERIOD, blind_color[0], blind_color[1], blind_color[2], blind_color[3])

}
blind_user(id){
	
	if ( !shModActive() ||!client_hittable(id)) return
	set_task(BLIND_PERIOD,"blind_task",id+BLIND_TASKID,"", 0,  "a",BLIND_TIMES)
	set_task(floatsub(floatmul(BLIND_PERIOD,float(BLIND_TIMES)),0.1),"unblind_task",id+UNBLIND_TASKID,"", 0,  "a",1)

}
public unblind_task(id){
	id-=fx_task_parameters[BLIND][fx_task_apply_id]
	uneffect_user_primitive(id,false)
	id-=UNBLIND_TASKID
	unblind_user(id)



}
unblind_user(id){
	
	if ( !shModActive() ||!client_hittable(id)) return
	remove_task(id+BLIND_TASKID)
	remove_task(id+UNBLIND_TASKID)
	gatling_set_fx_num(id, 0)

}

public morphine_task(id){
	id-=MORPHINE_TASKID
	if ( !shModActive() ||!client_hittable(id)) return
	sh_set_rendering(id,morphine_color[0], morphine_color[1], morphine_color[2], morphine_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, MORPHINE_PERIOD, morphine_color[0], morphine_color[1], morphine_color[2],  50)
	sh_add_hp(id,MORPHINE_HP_ADD,sh_get_max_hp(id))

}
morphine_user(id){
	
	if ( !shModActive() ||!client_hittable(id)) return
	set_task(MORPHINE_PERIOD,"morphine_task",id+MORPHINE_TASKID,"", 0,  "a",MORPHINE_TIMES)
	set_task(floatsub(floatmul(MORPHINE_PERIOD,float(MORPHINE_TIMES)),0.1),"unmorphine_task",id+UNMORPHINE_TASKID,"", 0,  "a",1)

}
public unmorphine_user(id){
	remove_task(id+UNMORPHINE_TASKID)
	remove_task(id+MORPHINE_TASKID)
	if ( !shModActive() ||!is_user_connected(id)) return
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	gatling_set_fx_num(id, 0)

}
public unmorphine_task(id){
	id-=UNMORPHINE_TASKID
	remove_task(id+MORPHINE_TASKID)
	if ( !shModActive() ||!is_user_connected(id)) return
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	gatling_set_fx_num(id, 0)

}
public weed_task(id){
	id-=WEED_TASKID
	sh_set_rendering(id, weed_color[0],  weed_color[1],  weed_color[2],  weed_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, WEED_PERIOD, weed_color[0],  weed_color[1],  weed_color[2], 50)
	set_user_gravity(id,WEED_GRAVITY)

}
weed_user(id){
	
	if ( !shModActive() ||!client_hittable(id)) return
	set_task(WEED_PERIOD,"weed_task",id+WEED_TASKID,"", 0,  "a",WEED_TIMES)
	set_task(floatsub(floatmul(WEED_PERIOD,float(WEED_TIMES)),0.1),"unweed_task",id+UNWEED_TASKID,"", 0,  "a",1)

}
unweed_user(id){
	remove_task(id+UNWEED_TASKID)
	remove_task(id+WEED_TASKID)
	if ( !shModActive() ||!is_user_connected(id)) return
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	gatling_set_fx_num(id, 0)
	sh_reset_min_gravity(id)

}
public unweed_task(id){
	id-=UNWEED_TASKID
	remove_task(id+WEED_TASKID)
	if ( !shModActive() ||!is_user_connected(id)) return
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	gatling_set_fx_num(id, 0)
	sh_reset_min_gravity(id)

}
public cocaine_task(id){
	id-=COCAINE_TASKID
	if ( !shModActive() ||!client_hittable(id)) return
	sh_set_rendering(id, cocaine_color[0], cocaine_color[1], cocaine_color[2], cocaine_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	
	set_user_maxspeed(id,COCAINE_SPEED)

}
cocaine_user(id,attacker,gHeroID){
	
	if ( !shModActive() ||!client_hittable(id)||!client_hittable(attacker)) return
	set_task(COCAINE_PERIOD,"cocaine_task",id+COCAINE_TASKID,"", 0,  "a",COCAINE_TIMES)
	set_task(floatsub(floatmul(COCAINE_PERIOD,float(COCAINE_TIMES)),0.1),"uncocaine_task",id+UNCOCAINE_TASKID,"", 0,  "a",1)
	sh_minibleed_user(id,attacker,gHeroID)
}

focus_user(id){

	if ( !shModActive() ||!client_hittable(id)) return
	set_task(FOCUS_PERIOD,"focus_task",id+FOCUS_TASKID,"", 0,  "a",FOCUS_TIMES)
	set_task(floatsub(floatmul(FOCUS_PERIOD,float(FOCUS_TIMES)),0.1),"unfocus_task",id+UNFOCUS_TASKID,"", 0,  "a",1)

}
bath_user(id){

	if ( !shModActive() ||!client_hittable(id)) return
	set_task(BATH_PERIOD,"bath_task",id+BATH_TASKID,"", 0,  "a",BATH_TIMES)
	set_task(floatsub(floatmul(BATH_PERIOD,float(BATH_TIMES)),0.1),"unbath_task",id+UNBATH_TASKID,"", 0,  "a",1)

}
public bath_task(id){
	id-=BATH_TASKID
	if ( !shModActive() ||!client_hittable(id)) return
	sh_set_rendering(id, bath_color[0],bath_color[1], bath_color[2], bath_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(id, 0.1, BATH_PERIOD, bath_color[0],bath_color[1], bath_color[2], 50)

}

uncocaine_user(id){
	
	uneffect_user_primitive(id,true)
	sh_reset_max_speed(id)

}
public uncocaine_task(id){
	id-=fx_task_parameters[COCAINE][fx_task_apply_id]
	uneffect_user_primitive(id,false)
	sh_reset_max_speed(id)

}

public unbath_task(id){
	id-=fx_task_parameters[BATH][fx_task_apply_id]
	uneffect_user_primitive(id,false)

}

public focus_task(id){
	id-=fx_task_parameters[METYLPHENIDATE][fx_task_apply_id]
	uneffect_user_primitive(id,false)

}

public unfocus_task(id){
	id-=fx_task_parameters[METYLPHENIDATE][fx_task_remove_id]
	uneffect_user_primitive(id,false)

}

unfocus_user(id){
	uneffect_user_primitive(id,true)

}



unbath_user(id){
	uneffect_user_primitive(id,true)

}

public unstun_task(id){
	id-=fx_task_parameters[STUN][fx_task_apply_id]
	unstun_user(id)



}
uneffect_user_primitive(id,bool:terminate_cleaner_task=false){
	new fx_id:the_fx_id=gatling_get_fx_num(id)
	if(terminate_cleaner_task){
			remove_task(id+fx_task_parameters[_:the_fx_id][_:fx_task_remove_id])
	}
	remove_task(id+fx_task_parameters[_:the_fx_id][_:fx_task_apply_id])
	if ( !shModActive() ||!is_user_connected(id)) return
	set_user_rendering(id)
	gatling_set_fx_num(id, 0)

}

public on_death_status()
{	
	new id = read_data(2)
	
	if(is_user_connected(id)||sh_is_active()){
		sh_uneffect_user(id,0,gatling_get_hero_id())
	
	}
	
}