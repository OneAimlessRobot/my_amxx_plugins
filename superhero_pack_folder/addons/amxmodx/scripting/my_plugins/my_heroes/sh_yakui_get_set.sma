#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"



#define PLUGIN "Superhero yakui mk2 pt3"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new gHasYakui[SH_MAXSLOTS+1]
new gNumPills[SH_MAXSLOTS+1]
new gNumRockets[SH_MAXSLOTS+1]
new gCurrFX[SH_MAXSLOTS+1]


new gHeroID


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
	register_native( "sh_get_pill_color","_sh_get_pill_color",0)

}

public _make_effect(iPlugin,iParams){

	new vic= get_param(1)
	new attacker= get_param(2)
	new hero_id=get_param(3)
	new fx_num= get_param(4)
	new override=get_param(5)

	new true_fx_num= (fx_num<=0)?sh_gen_effect():fx_num
	
	if(!is_user_connected(vic)||!is_user_connected(attacker)){
		
		return
	}
	if((sh_get_user_effect(vic)>=_:GLOW)&&(sh_get_user_effect(vic)<=_:BATH)&&!override){

		return
	}
	sh_uneffect_user(vic,gCurrFX[vic])
	sh_effect_user_direct(vic,attacker,hero_id,true_fx_num)

}

public _uneffect_user_handler(iPlugin,iParams){

	new user=get_param(1)
	if(!is_user_connected(user)){
		
		return
	}
	if((gatling_get_fx_num(user)>_:KILL)&&(gatling_get_fx_num(user)<_:NUM_FX)){
		sh_uneffect_user(user,gatling_get_fx_num(user))
		gCurrFX[user]=0;
	}
}
public _gatling_set_has_yakui(iPlugin,iParams){
	new id= get_param(1)
	new value_to_set= get_param(2)
	if(!is_user_connected(id)){
		
		return
	}
	gHasYakui[id]=value_to_set;
}
public _gatling_get_has_yakui(iPlugin,iParams){
	new id= get_param(1)
	if(!is_user_connected(id)){
		
		return 0
	}
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
	if(!is_user_connected(id)){
		
		return
	}
	gNumPills[id]=value_to_set;
}
public _gatling_get_num_pills(iPlugin,iParams){


	new id= get_param(1)
	if(!is_user_connected(id)){
		
		return -1
	}
	return gNumPills[id]

}

public _gatling_dec_num_pills(iPlugin,iParams){


	new id= get_param(1)
	if(!is_user_connected(id)){
		
		return
	}
	gNumPills[id]-= (gNumPills[id]>0)? 1:0

}

public _gatling_set_num_rockets(iPlugin,iParams){

	new id= get_param(1)
	new value_to_set=get_param(2)
	if(!is_user_connected(id)){
		
		return
	}
	gNumRockets[id]=value_to_set;

}

public _gatling_get_num_rockets(iPlugin,iParams){


	new id= get_param(1)
	if(!is_user_connected(id)){
		
		return -1
	}
	return gNumRockets[id]

}

public _gatling_dec_num_rockets(iPlugin,iParams){


	new id= get_param(1)
	if(!is_user_connected(id)){
		
		return
	}
	gNumRockets[id]-= (gNumRockets[id]>0)? 1:0

}
public _gatling_get_fx_num(iPlugin,iParams){


	new id= get_param(1)
	if(!is_user_connected(id)){
		
		return NONE
	}
	return gCurrFX[id]

}

public _gatling_set_fx_num(iPlugin,iParams){


	new id= get_param(1)
	new value_to_set= get_param(2)
	if(!is_user_connected(id)){
		
		return
	}
	gCurrFX[id]=value_to_set

}

public _sh_get_pill_color(iPlugin,iParams){
	new fx_num=get_param(1)
	new attacker=get_param(2)
	if(!is_user_connected(attacker)){
		
		return
	}	
	set_array(3,LineColors[_:NUM_FX+fx_num-1],3)




}