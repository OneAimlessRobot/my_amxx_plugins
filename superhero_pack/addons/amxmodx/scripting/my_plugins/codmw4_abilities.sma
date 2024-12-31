#include "../include/nvault.inc"
#include "../include/amxmod.inc"
#include "../include/amxmodx.inc"
#include "../include/amxmisc.inc"
#include "../include/hamsandwich.inc"
#include "../include/fakemeta.inc"
#include "../include/fakemeta_util.inc"
#include "../include/colorchat.inc"
#include "../include/engine.inc"
#include "../include/fun.inc"
#include "../include/csx.inc"
#include "../include/cstrike.inc"
#include "../include/Vexd_Utilities.inc"
#include "my_include/codmw4_abilities.inc"
#include "my_include/codmw4_classenum.inc"




#define PLUGIN "Call of Duty: MW4 abilities"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

public plugin_init(){


register_plugin(PLUGIN, VERSION, AUTHOR);


}

public plugin_natives(){

	register_native("Climb","_Climb",0);
	register_native("MultiJumpExec","_MultiJumpExec",0);
	register_native("MagicianApply","_MagicianApply",0);
	register_native("reduceRecoil","_reduceRecoil",0);
	register_native("JetpackJump","_JetpackJump",0);


}

public _Climb(iPlugin,iParams ) {
		
	
	new Float: g_wallorigin[3];
	get_array_f(2,g_wallorigin,3)
	new iPlayer=get_param(1)
	if( !(1<=iPlayer<=32) )
		return FMRES_IGNORED;
	
	if( !is_user_alive( iPlayer ) ){
		return FMRES_IGNORED;
	}
	
	static Float: fOrigin[ 3 ];
	entity_get_vector( iPlayer, EV_VEC_origin, fOrigin );
	
	if( get_distance_f( fOrigin, g_wallorigin ) > 25.0 )
		return FMRES_IGNORED;
	
	if( entity_get_int( iPlayer, EV_INT_flags ) & FL_ONGROUND )
		return FMRES_IGNORED;
	
	static iButton;
	iButton = entity_get_int( iPlayer, EV_INT_button );
	
	if( ( iButton & IN_FORWARD ) || ( iButton & IN_BACK ) ) {
		static Float: fVelocity[ 3 ];
		VelocityByAim( iPlayer, ( ( iButton & IN_FORWARD ) ? 120 : -120 ), fVelocity );
		entity_set_vector( iPlayer, EV_VEC_velocity, fVelocity );
	}
	
	return FMRES_IGNORED;
}
public _MultiJumpExec(iPlugin,iParams ){

		new id=get_param(1);
		new button=get_param(2)
		new flags=get_param(3)
		new numJumps=get_param_byref(4)
		new perk_info[2];
		get_array(5,perk_info,2);
		new player_class=get_param_byref(6)
		
		new oldbutton = pev(id, pev_oldbuttons);
		
		if((button & IN_JUMP) && !(flags & FL_ONGROUND) && !(oldbutton & IN_JUMP) && get_addr_val(numJumps) > 0)
		{
			set_addr_val(numJumps,get_addr_val(numJumps)-1);
			new Float:velocity[3];
			pev(id, pev_velocity,velocity);
			velocity[2] = random_float(265.0,285.0);
			set_pev(id, pev_velocity,velocity);
		}
		else if(flags & FL_ONGROUND)
		{	
			set_addr_val(numJumps,0)
			if(perk_info[0] == 11)
				set_addr_val(numJumps,1)
			else if(player_class == 65||perk_info[0] == 47)
				set_addr_val(numJumps,2)
		}

}
public _MagicianApply(iPlugin,iParams ){

		new id=get_param(1)
		new button= get_param(2)
		if(button & IN_DUCK)
		{ 
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 2); 
		}
		else if (button != IN_DUCK)
		{         
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 255);
		}

}
public _reduceRecoil(iPlugin,iParams ){

		new id=get_param(1)
		new Float:howMuch=get_param_f(2)
		static Float:punchangle[3];
		set_pev(id, pev_punchangle, punchangle);
		for(new i=0; i<3;i++) 
			punchangle[i]*=howMuch;
		set_pev(id, pev_punchangle, punchangle);
		
}
stock setArrayPos(array[2],pos,value){

	array[pos]=value;
}

stock getArrayPos(array[2],pos){

	return array[pos];

}
stock setfArrayPos(Float:array[3],pos,Float:value){

	array[pos]=value;
}

stock Float:getfArrayPos(Float:array[3],pos){
	
	return array[pos];
	

}
public _JetpackJump( iPlugin,iParams ){

		new id=get_param(1)
		new intensity=get_param(2)
		new perk_info[2];
		get_array(3,perk_info,2);
		perk_info[1] = floatround(get_gametime());
		new Float:velocity[3];
		VelocityByAim(id, intensity, velocity);
		velocity[2] = random_float(265.0,285.0);
		set_pev(id, pev_velocity, velocity);
		set_array(3,perk_info,2);
}
