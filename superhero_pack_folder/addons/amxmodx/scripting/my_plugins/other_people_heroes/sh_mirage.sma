
#define I_WANT_CONSTANTS


#include "../my_include/superheromod.inc"
#define I_WANT_CUSTOM_COLORS
#define I_WANT_BASIC_MACROS
#include "../my_include/superheromod.inc"
#include "../my_heroes/sh_aux_stuff/sh_aux_inc.inc"
#include "../my_heroes/sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"

// Mirage - made by Mydas

// CVARS
// mirage_level 3
// mirage_fadetime 0.5 - time it takes for him to become invisible
// mirage_invistime 3  - how long will he stay invis
// mirage_cooldown 5   - how long till he will invis again

// GLOBAL VARIABLES
#define gHeroName "Mirage"
#define MIRAGE_TICK_PERIOD 0.163

#define FADE_THINGIE floatround(1.0/MIRAGE_TICK_PERIOD)
#define INVIS_CALC_THINGIE (255.0*MIRAGE_TICK_PERIOD)
//floats
new pcvar_fadetime = -1,
	pcvar_invistime = -1


//nums
new pcvar_cooldown = -1

public plugin_init() {
  // Plugin Info
  register_plugin("SUPERHERO Mirage","1.0","Mydas")

  create_cvar("mirage_level", "3")
  pcvar_cooldown = create_cvar("mirage_cooldown", "5" )
  pcvar_fadetime = create_cvar("mirage_fadetime", "0.5")
  pcvar_invistime = create_cvar("mirage_invistime", "3")

  // FIRE THE EVENT TO CREATE THIS SUPERHERO!
  gHeroID=shCreateHero(gHeroName, "Delusion", "Turn invisible for a short time when someone aims at you", false, "mirage_level" )

  sh_assign_hero_bit(gHeroID,SH_PASSIVE_INVISIBILITY_HERO, true)

  // CHECK SOME BUTTONS
  set_task(MIRAGE_TICK_PERIOD, "mirage_loop", _, _, _, "b")
  

}


public mirage_loop(taskid)
{
	if ( !sh_is_active() || sh_is_freezetime() ) return

	static players[SH_MAXSLOTS], playerCount, id
	get_players(players, playerCount, "ah")

	for( new j = 0; j < playerCount; j++ ) {
		id = players[j]


		if(!is_user_alive(id)){
		
			continue
		}

		if(!sh_get_user_has_hero(id,gHeroID)){

			continue
		}
		
		static parm[4],i
		if (sh_get_user_has_hero(id,gHeroID)&&is_user_alive(id)&&is_user_connected(id)) 
		{
			for (new enemy=1;enemy< sh_maxplayers()+1;enemy++) 
			{
				if (is_user_alive(enemy) && (get_user_team(enemy)!=get_user_team(id)) && !sh_get_cooldown_flag(id)) 
				{
					new aid,abody
					get_user_aiming(enemy,aid,abody)
					if (aid==id) {
						parm[0]=id
						sh_set_cooldown(id, cvar_val(num, pcvar_cooldown) * 1.0)
						for(i=1; i<=floatround(cvar_val(float, pcvar_fadetime)*FADE_THINGIE); i++) {
							parm[1]=i
							parm[2]=255-floatround(i*(INVIS_CALC_THINGIE/cvar_val(float, pcvar_fadetime)))
							parm[3]=-(parm[2]-255)

							set_task(i*MIRAGE_TICK_PERIOD,"turn_invis",i*100+id,parm,sizeof(parm))
						}
						continue
					}
				}
			}
			continue
		}
	}
}
public turn_invis(parm[4])
{
	new id=parm[0], step=parm[1], stored_alpha = parm[2]
	if(!is_user_connected(id)) return
	
	set_render_with_color_const(id,INVISIBLE_MAN_GREY,1,stored_alpha,
						_,0,_,
						0.0,0,_,kRenderTransAlpha,PRIO_RENDER_INVISIBILITY,gHeroID)

	set_task(cvar_val(float, pcvar_invistime),"remove_invis",step*100+50+id,parm,sizeof(parm))
	if (step==floatround(cvar_val(float, pcvar_fadetime)*FADE_THINGIE)){
		client_print(id,print_chat,"-Turned invisible-")
	}
}

public remove_invis(parm[])
{
	new id=parm[0], step=parm[1], stored_alpha = parm[2], removed_alpha = parm[3]
	if(!is_user_connected(id)) return
	
	remove_glow_user(id,PRIO_RENDER_INVISIBILITY,stored_alpha,kRenderTransAlpha,_,gHeroID)
	if (step==floatround(cvar_val(float, pcvar_fadetime)*FADE_THINGIE)){
		client_print(id,print_chat,"-Visible again-")
		return
	}

	set_render_with_color_const(id,FX_NONE,1,removed_alpha,
						_,0,_,
						0.0,0,_,kRenderTransAlpha,PRIO_RENDER_INVISIBILITY,gHeroID)
}

