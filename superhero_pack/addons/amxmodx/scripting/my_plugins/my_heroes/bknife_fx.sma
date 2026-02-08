#include "../my_include/superheromod.inc"
#include "bleed_knife_inc/sh_bknife_fx.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero bleed fx"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new bool:gIsBleeding[SH_MAXSLOTS+1]
public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);
arrayset(gIsBleeding,false,SH_MAXSLOTS+1)
}

public plugin_natives(){


	register_native("sh_bleed_user","_sh_bleed_user",0);
	register_native("sh_ultrableed_user","_sh_ultrableed_user",0);
	register_native("sh_minibleed_user","_sh_minibleed_user",0);
	register_native("sh_unbleed_user","_sh_unbleed_user",0);
	register_native("make_bleed_fx","_make_bleed_fx",0);
}


public _sh_bleed_user(iPlugin,iParams){

	new user=get_param(1)
	new attacker=get_param(2)
	new gHeroID=get_param(3)
	if ( !shModActive() || !client_hittable(user)||!client_hittable(attacker)) return

	new attacker_name[128]
	get_user_name(attacker,attacker_name,127)
	new user_name[128]
	get_user_name(user,user_name,127)
	if(!gIsBleeding[user]||STABS_STACK){
		
		
		if(!is_user_bot(user)){
			sh_chat_message(user,gHeroID,"%s has bled you!!!",attacker_name)
		}
		if(!is_user_bot(attacker)){
			sh_chat_message(attacker,gHeroID,"You just bled %s!!!",user_name)
		
		}
		emit_sound(user, CHAN_STATIC, BLEED_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		bleed_user(user,attacker)
	}



}
public _sh_ultrableed_user(iPlugin,iParams){

	new user=get_param(1)
	new attacker=get_param(2)
	new gHeroID=get_param(3)
	
	if ( !shModActive() ||!client_hittable(user)||!client_hittable(attacker)) return

	new attacker_name[128]
	get_user_name(attacker,attacker_name,127)
	new user_name[128]
	get_user_name(user,user_name,127)
	if(!gIsBleeding[user]||STABS_STACK){
		
		
		if(!is_user_bot(user)){
			sh_chat_message(user,gHeroID,"%s has back stabbed you!!!!!!",attacker_name)
		}
		if(!is_user_bot(attacker)){
			sh_chat_message(attacker,gHeroID,"You just back stabbed %s!!!!!!!",user_name)
		}
		emit_sound(user, CHAN_STATIC, BLEED_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		ultrableed_user(user,attacker)
	}



}
public _sh_minibleed_user(iPlugin,iParams){

	
	new user=get_param(1)
	new attacker=get_param(2)
	new gHeroID=get_param(3)
	if ( !shModActive() ||!client_hittable(user)||!client_hittable(attacker)) return

	new attacker_name[128]
	get_user_name(attacker,attacker_name,127)
	new user_name[128]
	get_user_name(user,user_name,127)
	if(!gIsBleeding[user]||SLASHES_STACK){
		
		
		if(!is_user_bot(user)){
			sh_chat_message(user,gHeroID,"%s has slashed you!!!!!!",attacker_name)
		}
		if(!is_user_bot(attacker)){
			sh_chat_message(attacker,gHeroID,"You just slashed %s!!!!!!!",user_name)
		}
		emit_sound(user, CHAN_STATIC, BLEED_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		minibleed_user(user,attacker)
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
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BLOODSTREAM);
	write_coord(origin[0]);
	write_coord(origin[1]);
	write_coord(origin[2]+10);
	write_coord(random_num(-360,360));
	write_coord(random_num(-360,360));
	write_coord(-10);
	write_byte(70);
	write_byte(random_num(50,100));
	message_end();
}

public minibleed_task(array[],id){
	id-=MINIBLEED_TASKID
	if ( !shModActive() ||!client_hittable(id)||!client_hittable(array[0])) return

	sh_screen_fade(id, 0.1, 0.9, bleed_color[0], bleed_color[1], bleed_color[2], 25)
	sh_set_rendering(id, bleed_color[0], bleed_color[1], bleed_color[2], bleed_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(array[0], 0.1, 0.9, bleed_color[0], bleed_color[1], bleed_color[2], 25)
	sh_add_hp(array[0],MINIBLEED_DAMAGE,sh_get_max_hp(array[0]))
	make_bleed_fx(id)
	sh_set_stun(id,0.25,0.5)
	sh_extra_damage(id,array[0],MINIBLEED_DAMAGE,"Minibleeding",0,SH_DMG_NORM)
	
	


}
minibleed_user(id,attacker){
	
	if ( !shModActive() ||!client_hittable(id)||!client_hittable(attacker)) return
	new array[1]
	array[0] = attacker
	gIsBleeding[id]=true
	set_task(MINIBLEED_PERIOD,"minibleed_task",id+MINIBLEED_TASKID,array, sizeof(array),  "a",MINIBLEED_TIMES)
	set_task(floatsub(floatmul(MINIBLEED_PERIOD,float(MINIBLEED_TIMES)),0.1),"unminibleed_task",id+UNMINIBLEED_TASKID,"", 0,  "a",1)


}
public unminibleed_task(id){
	id-=UNMINIBLEED_TASKID
	
	if ( !shModActive() || !is_user_connected(id)) return
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+MINIBLEED_TASKID)
	gIsBleeding[id]=false



}

public ultrableed_task(array[],id){
	id-=ULTRABLEED_TASKID

	if ( !shModActive() ||!client_hittable(id)||!client_hittable(array[0])) return
	sh_screen_fade(id, 0.1, 0.9, bleed_color[0], bleed_color[1], bleed_color[2], 150)
	sh_set_rendering(id, bleed_color[0], bleed_color[1], bleed_color[2], bleed_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(array[0], 0.1, 0.9, bleed_color[0], bleed_color[1], bleed_color[2], 150)
	sh_add_hp(array[0],ULTRABLEED_DAMAGE,sh_get_max_hp(array[0]))
	make_bleed_fx(id)
	sh_set_stun(id,0.25,0.5)
	sh_extra_damage(id,array[0],ULTRABLEED_DAMAGE,"Ultrableeding",0,SH_DMG_NORM)
	
	


}
ultrableed_user(id,attacker){
	if ( !shModActive()  || !client_hittable(id)||!client_hittable(attacker)) return
	new array[1]
	array[0] = attacker
	gIsBleeding[id]=true
	set_task(ULTRABLEED_PERIOD,"ultrableed_task",id+ULTRABLEED_TASKID,array, sizeof(array),  "a",ULTRABLEED_TIMES)
	set_task(floatsub(floatmul(ULTRABLEED_PERIOD,float(ULTRABLEED_TIMES)),0.1),"unultrableed_task",id+UNULTRABLEED_TASKID,"", 0,  "a",1)



}
public unultrableed_task(id){
	id-=UNULTRABLEED_TASKID
	if ( !shModActive() || !is_user_connected(id)) return
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+ULTRABLEED_TASKID)
	gIsBleeding[id]=false



}

public bleed_task(array[],id){
	id-=BLEED_TASKID

	if ( !shModActive() ||!client_hittable(id)||!client_hittable(array[0])) return
	sh_screen_fade(id, 0.1, 0.9, bleed_color[0], bleed_color[1], bleed_color[2], 50)
	sh_set_rendering(id, bleed_color[0], bleed_color[1], bleed_color[2], bleed_color[3],kRenderFxGlowShell, kRenderTransAlpha)
	sh_screen_fade(array[0], 0.1, 0.9, bleed_color[0], bleed_color[1], bleed_color[2], 50)
	sh_add_hp(array[0],BLEED_DAMAGE,sh_get_max_hp(array[0]))
	make_bleed_fx(id)
	sh_extra_damage(id,array[0],BLEED_DAMAGE,"Bleeding",0,SH_DMG_NORM)
	
	


}
bleed_user(id,attacker){
	if ( !shModActive()  || !client_hittable(id)||!client_hittable(attacker)) return
	new array[1]
	array[0] = attacker
	gIsBleeding[id]=true
	set_task(BLEED_PERIOD,"bleed_task",id+BLEED_TASKID,array, sizeof(array),  "a",BLEED_TIMES)
	set_task(floatsub(floatmul(BLEED_PERIOD,float(BLEED_TIMES)),0.1),"unbleed_task",id+UNBLEED_TASKID,"", 0,  "a",1)



}
public unbleed_task(id){
	id-=UNBLEED_TASKID
	if ( !shModActive() || !is_user_connected(id)) return
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+BLEED_TASKID)
	gIsBleeding[id]=false



}

unbleed_user(id){
	if ( !shModActive() || !is_user_connected(id)) return
	set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	remove_task(id+BLEED_TASKID)
	remove_task(id+UNBLEED_TASKID)
	gIsBleeding[id]=false



}
