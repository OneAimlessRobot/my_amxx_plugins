#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt3.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_gatling_funcs.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"

#define PLUGIN "Superhero yakui pt2 pt1"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

stock const fx_remove_strings[_:NUM_FX][]={
			"We have removed nothing!",
			"We have removed nothing! You should be dead...",
			"Removed ur glow bro!",
			"Removed ur poisan!",
			"Removed ur stun bro!",
			"Removed ur chernobyl!",
			"Removed ur heals!",
			"Removed ur weed!",
			"Removed ur 80s!",
			"Removed ur blindess!",
			"Removed ur college pills!",
			"Removed ur spicy college pills!"
	
}

stock const fx_names[_:NUM_FX][]={
			"no drug",
			"cyanide",
			"glowstick juice",
			"poison",
			"stunner",
			"uranium",
			"morphine",
			"weed",
			"cocaine",
			"blindness",
			"metylphenidate",
			"bath salts",
}

stock const Float:fx_rarity_weights[_:NUM_FX]={
				0.0,
				1.0,
				20.0,
				30.0,
				40.0,
				50.0,
				60.0,
				71.0,
				79.0,
				85.0,
				90.0,
				100.0
}


enum fx_task_parameter_id{
	Float:fx_task_period,
	Float:fx_task_time,
	fx_task_repeats,
	fx_task_apply_id,
	fx_task_remove_id,
	fx_task_apply_func_name[128],
	fx_task_remove_func_name[128],
	fx_task_will_glow_user_screen,
	fx_task_status_icon
}

stock fx_task_parameters[_:NUM_FX][fx_task_parameter_id]={	
					{-1.0,5.0,-1,-1,-1,"","",0,-1},
					{-1.0,5.0,-1,-1,-1,"","",0,-1},
					{1.0,5.0,-1,-1,-1,"glow_task","uneffect_task_generic",-1,-1},
					{1.0,5.0,-1,-1,-1,"poison_task","uneffect_task_generic",-1,DMG_ICON_POISON},
					{0.1,5.0,1,-1,-1,"","uneffect_task_generic",-1,DMG_ICON_SHOCK},
					{1.0,5.0,1,-1,-1,"radioactive_task","",-1,-1},
					{1.0,5.0,-1,-1,-1,"morphine_task","uneffect_task_generic",DMG_ICON_HEALTH},
					{1.0,5.0,-1,-1,-1,"weed_task","unweed_task",0,DMG_ICON_LONGJUMP},
					{1.0,5.0,-1,-1,-1,"cocaine_task","uncocaine_task",1,DMG_ICON_POISON},
					{0.5,5.0,-1,-1,-1,"blind_task","uneffect_task_generic",1,-1},
					{1.0,5.0,-1,-1,-1,"","uneffect_task_generic",0,DMG_ICON_SHOCK},
					{1.0,5.0,-1,-1,-1,"bath_task","uneffect_task_generic",0,DMG_ICON_ARMOR}

}

new gLastWeapon[SH_MAXSLOTS+1]
new g_last_weapon[SH_MAXSLOTS+1]
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
for ( new wpnId = CSW_P228; wpnId <= CSW_P90; wpnId++ )
{
	if ( !(FAST_RELOAD_BITSUM & (1<<wpnId)) && get_weaponname(wpnId, wpnName, charsmax(wpnName)) )
	{
			RegisterHam(Ham_Item_PostFrame, wpnName, "Item_PostFrame_Post", 1,true)
	}
}

for(new i=_:GLOW;i<_:NUM_FX;i++){
	
	if(strlen(fx_task_parameters[i][fx_task_apply_func_name])){
		fx_task_parameters[i][fx_task_apply_id]=allocate_typed_task_id(player_task)
	}
	if(strlen(fx_task_parameters[i][fx_task_remove_func_name])){
		fx_task_parameters[i][fx_task_remove_id]=allocate_typed_task_id(player_task)
	}
	if(fx_task_parameters[i][fx_task_repeats]<0){
		static Float:the_period;
		the_period=fx_task_parameters[i][fx_task_period]
		static Float:the_time;
		the_time=fx_task_parameters[i][fx_task_time]
		fx_task_parameters[i][fx_task_repeats]=floatround(floatdiv(the_time,the_period))
	}
}
RegisterHam(Ham_TakeDamage, "player", "Player_TakeDamage", 1,true) 
register_event("Damage", "fx_damage", "b", "2!0")
register_event("CurWeapon", "fire_weapon", "be", "1=1", "3>0")
register_event("CurWeapon", "weaponChange", "be", "1=1")
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

public Item_PostFrame_Post(iEnt)
{    
	if(pev_valid(iEnt) != 2){
		return HAM_IGNORED
	}
	new id = entity_get_edict(iEnt, EV_ENT_owner);
	
	if(!client_hittable(id)){
		
		return HAM_IGNORED
	}
	if (!sh_is_active()||(gatling_get_fx_num(id)!=_:COCAINE))return HAM_IGNORED
	
	do_fast_reload(id,iEnt,COCAINE_RELOAD_RATE_MULT)
	return HAM_IGNORED
} 

public fx_damage(id)
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
				sh_extra_damage(id, attacker, floatround(extraDamage), "Radiation vuln", headshot)
			}	
		}
		case POISON:{
			new Float:extraDamage = damage * POISON_DMG_MULT - damage
			extraDamage*=(sh_get_user_is_bleeding(id)?2.0:1.0)
			if (floatround(extraDamage)>0){
				sh_extra_damage(id, attacker, floatround(extraDamage), "Poison vuln", headshot)
					
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
	
	if (!is_user_connected(id)||!is_user_alive(id)||!((gatling_get_fx_num(id)==_:POISON)||(gatling_get_fx_num(id)==_:COCAINE))) return PLUGIN_CONTINUE 
	new wpnid = read_data(2)		// id of the weapon 
	new ammo = read_data(3)		// ammo left in clip 
	
	if (gLastWeapon[id] == 0) gLastWeapon[id] = wpnid
	
	if ((gLastClipCount[id] > ammo)&&(gLastWeapon[id] == wpnid)) 
	{
		
		draw_aim_vector(id,(gatling_get_fx_num(id)==_:POISON)?{GREEN,GREEN,GREEN}:{PINK,PINK,PINK})
		if((gatling_get_fx_num(id)==_:COCAINE)){
		
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
	new owner = get_pdata_cbase(weapon_ent, m_pPlayer, XO_WEAPON)
	if(!client_hittable(owner)){
		return HAM_IGNORED
	}
	if (gatling_get_fx_num(owner)==_:METYLPHENIDATE) {
		set_pev(owner, pev_punchangle, {0.0, 0.0, 0.0})
	}

	return HAM_IGNORED
}
public Player_TakeDamage(id)
{
 if ( !sh_is_active() || !is_user_alive(id) || !(gatling_get_fx_num(id)==_:BATH)) return
 
 set_pdata_float(id, fPainShock, 1.0, 5)
} 
public _sh_get_user_effect(iPlugins,iParams){
	
	new id=get_param(1)
	if(!client_hittable(id)||!sh_is_active()){
		
		return NONE;
	}
	
	return gatling_get_fx_num(id)

}

public _sh_get_fx_color_name(iPlugins,iParams){
	
	new fx_num=get_param(1)
	set_array(2,LineColors[FX_COLOR_OFFSET+fx_num],3)
	set_array(3,fx_names[fx_num],128)
	


}
fx_task_user(id,attacker,fx_num){
	if ( !shModActive() ||!client_hittable(id)) return
	new array[2]
	array[0] = fx_num
	array[1] = attacker
	if((fx_task_parameters[fx_num][fx_task_status_icon])>=0){

		set_damage_icon(id,1,fx_task_parameters[fx_num][fx_task_status_icon],LineColors[FX_COLOR_OFFSET+fx_num])
	}
	
	if(strlen(fx_task_parameters[fx_num][fx_task_apply_func_name])){
		
		set_task(fx_task_parameters[fx_num][fx_task_period],
						fx_task_parameters[fx_num][fx_task_apply_func_name],
						id+fx_task_parameters[fx_num][fx_task_apply_id],
						array,
						2,
						"a",
						fx_task_parameters[fx_num][fx_task_repeats])
	}

	if(strlen(fx_task_parameters[fx_num][fx_task_remove_func_name])){
			
		set_task(floatsub(fx_task_parameters[fx_num][fx_task_time],0.1),
						fx_task_parameters[fx_num][fx_task_remove_func_name],
						id+fx_task_parameters[fx_num][fx_task_remove_id],
						array,
						1,
						"a",
						1)
	}


}
public _get_fx_num(iPlugin,iParams){


	new Float:chance=generate_float(0.0,(fx_rarity_weights[sizeof(fx_rarity_weights)-1])*0.02)

	for(new fx_id:i=KILL;i<NUM_FX;i++){
		new Float:compared=fx_rarity_weights[i]*0.01;
		if(chance<compared){

			return i;
		}

	}
	return NONE

}
public _sh_effect_user_direct(iPlugin,iParams){

	new user=get_param(1)
	new attacker=get_param(2)
	new gHeroID=get_param(3)
	new fx_num=get_param(4)
	if(fx_num==_:KILL){

		if(user==attacker){
			new attacker_name[128]
			get_user_name(attacker,attacker_name,127)
			sh_chat_message(0,gHeroID,"%s: Dont worry guys! Momma Yakui has everything under control... what doesnt kill me can only... *thud*",attacker_name)
		
		}
		kill_user(user,attacker)

	}
	else if(fx_num){
		gatling_set_fx_num(user,fx_num)
		fx_task_user(user,attacker,fx_num)
		if(fx_num==_:STUN){


			stun_user(user)
			remove_glow_user(user,fx_task_parameters[_:STUN][fx_task_time])
		}
		else{
			if(fx_num==_:COCAINE){

				sh_bleed_user(user,attacker,BLEED_MINI,gHeroID,0)

			}
		}
	}

	return fx_num;




}
public _sh_effect_user(iPlugin,iParams){

	new fx_num=sh_gen_effect()
	new user=get_param(1)
	new attacker=get_param(2)
	new gHeroID=get_param(3)
	sh_effect_user_direct(user,attacker,gHeroID,fx_num)
	return fx_num;




}



public _sh_uneffect_user(iPlugin,iParams){

	new user=get_param(1)
	new fx_num=get_param(2)
	
	if((gatling_get_fx_num(user)>_:KILL)&&(gatling_get_fx_num(user)<=_:BATH)){
		uneffect_user_primitive(user,true)
	}
	return fx_num;




}
kill_user(id,attacker){
	
	
	if ( !shModActive() ||!client_hittable(id)) return
	sh_screen_fade(id, 0.1, 0.9,
						LineColors[FX_COLOR_OFFSET+_:KILL][0],
						LineColors[FX_COLOR_OFFSET+_:KILL][1],
						LineColors[FX_COLOR_OFFSET+_:KILL][2], 50)
	sh_extra_damage(id,attacker,1,"Cyanide Pill",0,SH_DMG_KILL)
	gatling_set_fx_num(id, NONE)


}


public glow_task(array[],id){
	id-=fx_task_parameters[array[0]][fx_task_apply_id]
	if ( !shModActive() ||!client_hittable(id)) return
	set_render_with_color_const(id,FX_COLOR_OFFSET+array[0],_,_,_,fx_task_parameters[array[0]][fx_task_will_glow_user_screen])
	


}
stun_user(id){

	
	if ( !shModActive() ||!client_hittable(id)) return
	set_render_with_color_const(id, FX_COLOR_OFFSET+_:STUN,_,_,_,fx_task_parameters[STUN][fx_task_will_glow_user_screen])
	sh_set_stun(id, fx_task_parameters[STUN][fx_task_time], STUN_SPEED)
	sh_screen_shake(id, 16.0, fx_task_parameters[STUN][fx_task_time], 2.0)



}
public blind_task(array[],id){
	id-=fx_task_parameters[array[0]][fx_task_apply_id]
	if ( !shModActive() ||!client_hittable(id)) return
	set_render_with_color_const(id,FX_COLOR_OFFSET+array[0],0,_,255,1)

}

public poison_task(array[],id){
	id-=fx_task_parameters[array[0]][fx_task_apply_id]

	if ( !shModActive() ||!client_hittable(id)||!client_hittable(array[1])) return
	set_render_with_color_const(id,FX_COLOR_OFFSET+array[0],_,_,_,fx_task_parameters[array[0]][fx_task_will_glow_user_screen])
	sh_extra_damage(id,array[1],POISON_DAMAGE*((sh_get_user_is_bleeding(id)?2:1)),
							new_dmg_type_names[_:SH_NEW_DMG_DRUG_POISON],
							_,_,_,_,_,_,
							SH_NEW_DMG_DRUG_POISON,
							get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_DRUG_POISON))
	
	


}

public radioactive_task(array[],id){
	id-=fx_task_parameters[array[0]][fx_task_apply_id]
	new attacker=array[1]
	track_user(id,attacker,
						1,
						RADIOACTIVE_DAMAGE,
						fx_task_parameters[array[0]][fx_task_period],
						fx_task_parameters[array[0]][fx_task_time],
						FX_COLOR_OFFSET+array[0])
}
public morphine_task(array[],id){
	id-=fx_task_parameters[array[0]][fx_task_apply_id]
	if ( !shModActive() ||!client_hittable(id)) return
	
	set_render_with_color_const(id,FX_COLOR_OFFSET+array[0],_,_,_,fx_task_parameters[array[0]][fx_task_will_glow_user_screen])
	sh_add_hp(id,MORPHINE_HP_ADD,sh_get_max_hp(id))

}
public weed_task(array[],id){
	id-=fx_task_parameters[array[0]][fx_task_apply_id]
	set_render_with_color_const(id,FX_COLOR_OFFSET+array[0],_,_,_,fx_task_parameters[array[0]][fx_task_will_glow_user_screen])
	set_user_gravity(id,WEED_GRAVITY)

}
public cocaine_task(array[],id){
	id-=fx_task_parameters[array[0]][fx_task_apply_id]
	if ( !shModActive() ||!client_hittable(id)) return
	set_render_with_color_const(id,FX_COLOR_OFFSET+array[0],_,_,_,fx_task_parameters[array[0]][fx_task_will_glow_user_screen])
	set_user_maxspeed(id,COCAINE_SPEED)

}
public bath_task(array[],id){
	id-=fx_task_parameters[array[0]][fx_task_apply_id]
	if ( !shModActive() ||!client_hittable(id)) return
	set_render_with_color_const(id,FX_COLOR_OFFSET+array[0],_,_,_,fx_task_parameters[array[0]][fx_task_will_glow_user_screen])
	

}

public uneffect_task_generic(array[],id){

	id-=fx_task_parameters[array[0]][fx_task_remove_id]
	uneffect_user_primitive(id,false)
}



public unweed_task(array[],id){
	uneffect_task_generic(array,id)
	id-=fx_task_parameters[array[0]][fx_task_remove_id]
	sh_reset_min_gravity(id)

}
public uncocaine_task(array[],id){
	uneffect_task_generic(array,id)
	id-=fx_task_parameters[array[0]][fx_task_remove_id]
	sh_reset_max_speed(id)

}




uneffect_user_primitive(id,bool:terminate_cleaner_task=false){
	if ( !shModActive() ||!is_user_connected(id)) return
	new the_fx_id=gatling_get_fx_num(id)
	if(terminate_cleaner_task){
			remove_task(id+fx_task_parameters[the_fx_id][fx_task_remove_id])
	}
	remove_task(id+fx_task_parameters[the_fx_id][fx_task_apply_id])
	set_user_rendering(id)
	if((fx_task_parameters[the_fx_id][fx_task_status_icon])>=0){

		set_damage_icon(id,0,fx_task_parameters[the_fx_id][fx_task_status_icon])
	}
	
	if(the_fx_id==_:RADIOACTIVE){
		unradioactive_user(id)
	}
	gatling_set_fx_num(id, 0)

}

public on_death_status()
{	
	new id = read_data(2)
	
	if(is_user_connected(id)&&sh_is_active()){
			sh_uneffect_user(id,gatling_get_fx_num(id))
	}
	
}
//----------------------------------------------------------------------------------------------

public weaponChange(id)
{
	if ( !client_hittable(id)||(gatling_get_fx_num(id)!=_:COCAINE)||!shModActive()) return

	new wpnid = get_user_weapon(id)

	if ( g_last_weapon[id] != wpnid ) {
		if ((get_user_maxspeed(id) < COCAINE_SPEED)&&!sh_get_stun(id)){
			set_user_maxspeed(id, COCAINE_SPEED)
		}
	}
	g_last_weapon[id]=wpnid;
}