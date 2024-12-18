#include "../my_include/superheromod.inc"

#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"



#define PLUGIN "Superhero yakui mk2 pt3"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new gHasYakui[SH_MAXSLOTS+1]
new gNumPills[SH_MAXSLOTS+1]
new gNumRockets[SH_MAXSLOTS+1]
new gCurrFX[SH_MAXSLOTS+1]


public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);

arrayset(gCurrFX,0,SH_MAXSLOTS+1)
}

public plugin_natives(){


	register_native("gatling_set_num_pills","_gatling_set_num_pills",0);
	register_native("gatling_get_num_pills","_gatling_get_num_pills",0);
	register_native("gatling_dec_num_pills","_gatling_dec_num_pills",0);
	
	register_native("gatling_set_num_rockets","_gatling_set_num_rockets",0);
	register_native("gatling_get_num_rockets","_gatling_get_num_rockets",0);
	register_native("gatling_dec_num_rockets","_gatling_dec_num_rockets",0);
	
	register_native("gatling_set_fx_num","_gatling_set_fx_num",0);
	register_native("gatling_get_fx_num","_gatling_get_fx_num",0);
	
	
	register_native("gatling_set_hero_id","_gatling_set_hero_id",0);
	register_native("gatling_get_hero_id","_gatling_get_hero_id",0);
	
	register_native("gatling_set_has_yakui","_gatling_set_has_yakui",0);
	register_native("gatling_get_has_yakui","_gatling_get_has_yakui",0);
	
	
	register_native( "uneffect_user_handler","_uneffect_user_handler",0)
	register_native( "make_effect","_make_effect",0)
	register_native( "make_effect_direct","_make_effect_direct",0)
	register_native( "sh_get_pill_color","_sh_get_pill_color",0)

}

public _make_effect(iPlugin,iParams){

	new vic= get_param(1)
	new attacker= get_param(2)
	new hero_id=get_param(3)

	sh_uneffect_user(vic,gCurrFX[vic],hero_id)
	new fx_num=sh_effect_user(vic,attacker,hero_id)
	gCurrFX[vic]=fx_num;

}
public _make_effect_direct(iPlugin,iParams){

	new vic= get_param(1)
	new attacker= get_param(2)
	new fx_num= get_param(3)
	new hero_id=get_param(4)
	sh_uneffect_user(vic,gCurrFX[vic],hero_id)
	sh_effect_user_direct(vic,attacker,fx_num,hero_id)
	gCurrFX[vic]=fx_num;

}
public _uneffect_user_handler(iPlugin,iParams){

	new user=get_param(1)
	new hero_id=get_param(2)
	sh_uneffect_user(user,gatling_get_fx_num(user),hero_id)
	gCurrFX[user]=0;

}
public _gatling_set_has_yakui(iPlugin,iParams){
	new id= get_param(1)
	new value_to_set= get_param(2)
	gHasYakui[id]=value_to_set;
}
public _gatling_get_has_yakui(iPlugin,iParams){
	new id= get_param(1)
	return gHasYakui[id]
}

public _gatling_get_hero_id(iPlugin,iParams){
	return gHeroID
}
public _gatling_set_hero_id(iPlugin,iParams){
	gHeroID=get_param(1)
}

public _gatling_set_num_pills(iPlugin,iParams){
	new id= get_param(1)
	new value_to_set=get_param(2)
	gNumPills[id]=value_to_set;
}
public _gatling_get_num_pills(iPlugin,iParams){


	new id= get_param(1)
	return gNumPills[id]

}

public _gatling_dec_num_pills(iPlugin,iParams){


	new id= get_param(1)
	gNumPills[id]-= (gNumPills[id]>0)? 1:0

}

public _gatling_set_num_rockets(iPlugin,iParams){

	new id= get_param(1)
	new value_to_set=get_param(2)
	gNumRockets[id]=value_to_set;

}

public _gatling_get_num_rockets(iPlugin,iParams){


	new id= get_param(1)
	return gNumRockets[id]

}

public _gatling_dec_num_rockets(iPlugin,iParams){


	new id= get_param(1)
	gNumRockets[id]-= (gNumRockets[id]>0)? 1:0

}
public _gatling_get_fx_num(iPlugin,iParams){


	new id= get_param(1)
	return gCurrFX[id]

}

public _gatling_set_fx_num(iPlugin,iParams){


	new id= get_param(1)
	new value_to_set= get_param(2)
	gCurrFX[id]=value_to_set

}

public _sh_get_pill_color(iPlugin,iParams){
	new fx_num=get_param(1)
	new attacker=get_param(2)
	new color[4]
	get_array(3,color,4)

	switch(fx_num){
		case KILL:{
			sh_chat_message(attacker,gatling_get_hero_id(),"Here is your kill bro!")
			copy(color,4,kill_color)
			
		
		}
		case GLOW:{
			sh_chat_message(attacker,gatling_get_hero_id(),"Here is your glow bro!")
			copy(color,4,glow_color)
			
		
		}
		case STUN:{
			sh_chat_message(attacker,gatling_get_hero_id(),"Here is your stun bro!")
			copy(color,4,stun_color)
		
		
		}
		case POISON:{
			sh_chat_message(attacker,gatling_get_hero_id(),"Here is your crack bro!")
			copy(color,4,poison_color)
		
		
		
		}
		case RADIOACTIVE:{
			sh_chat_message(attacker,gatling_get_hero_id(),"Here is your radioactive bro!")
			copy(color,4,radioactive_color)
		
		
		
		}
		case MORPHINE:{
			sh_chat_message(attacker,gatling_get_hero_id(),"Here is your morphine bro!")
			copy(color,4,morphine_color)
		
		
		
		}
		case WEED:{
		
			sh_chat_message(attacker,gatling_get_hero_id(),"Here is your weed bro!")
			copy(color,4,weed_color)
		
		}
		case COCAINE:{
			sh_chat_message(attacker,gatling_get_hero_id(),"Here is your cocaine bro!")
			copy(color,4,cocaine_color)
		
		
		
		}
		case BLIND:{
			sh_chat_message(attacker,gatling_get_hero_id(),"Here is your blindness bro!")
			copy(color,4,blind_color)
		
		
		}
		case METYLPHENIDATE:{
			sh_chat_message(attacker,gatling_get_hero_id(),"Here is your college pills bro!")
			copy(color,4,focus_color)
		
		
		}
		case BATH:{
			sh_chat_message(attacker,gatling_get_hero_id(),"Here is your spicy college pills bro!")
			copy(color,4,bath_color)
		
		
		}
		default:{
			sh_chat_message(attacker,gatling_get_hero_id(),"No fx will be applied bro sorry")
			color[3]=0
		
		}
	

	
	}
	set_array(3,color,4)




}

public plugin_precache()
{
	
}
