#define I_WANT_CONSTANTS
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt10: superhero pickability checks"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "maria_riveter_inc/maria_general_funcs.inc"
#include "flora_inc/flora_global.inc"
#include "goku_inc/goku_inc.inc"
#include "ester_inc/ester_global.inc"
#include "vegetto_inc/vegetto_inc.inc"
#include "sliphantom_inc/sliphantom_inc.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "shinobu_knife/shinobu_general.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt10.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt10.inc"
#include "../my_include/auxiliar_stuff.inc"

new gHeroID_Maria = -1,
	gHeroID_Shinobu = -1,
	gHeroID_Flora = -1,
	gHeroID_Vegetto = -1,
	gHeroID_Goku = -1,
	gHeroID_Ester = -1,
	gHeroID_SuperNoodle = -1,
	gHeroID_Yakui = -1


#define MAX_INCOMPATIBILITY_PAIRS 32

new filled_pair_count = 0
enum superhero_incompatibility_pair{

	pair_hero_a,
	pair_hero_b

}

new sh_incompatibility_pairs[MAX_INCOMPATIBILITY_PAIRS][superhero_incompatibility_pair]

new bool:is_hero_bot_pickable[SH_MAXHEROS] = {true, ...}

public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);

	
}
public plugin_cfg(){

	gHeroID_Maria = maria_get_hero_id()
	
	gHeroID_Flora = flora_get_hero_id()
	
	gHeroID_Vegetto = vegetto_get_hero_id()

	gHeroID_Goku = goku_get_hero_id()

	gHeroID_Shinobu = shinobu_get_hero_id()

	gHeroID_Ester = ester_get_hero_id()

	gHeroID_SuperNoodle = supernoodle_get_hero_id()

	gHeroID_Yakui = gatling_get_hero_id()

	//these two really dont get along
	
	push_incompatibility_pair(gHeroID_Goku,gHeroID_Shinobu)

	push_incompatibility_pair(gHeroID_Ester,gHeroID_Shinobu)

	push_incompatibility_pair(gHeroID_Flora,gHeroID_Shinobu)

	push_incompatibility_pair(gHeroID_Shinobu,gHeroID_Yakui)

	push_incompatibility_pair(gHeroID_Flora,gHeroID_Yakui)

	push_incompatibility_pair(gHeroID_Flora,gHeroID_SuperNoodle)

	push_incompatibility_pair(gHeroID_Shinobu,gHeroID_SuperNoodle)

	push_incompatibility_pair(gHeroID_Maria,gHeroID_Shinobu)

	push_incompatibility_pair(gHeroID_Vegetto,gHeroID_Shinobu)

	push_incompatibility_pair(gHeroID_Vegetto,gHeroID_Goku)

	

	is_hero_bot_pickable[gHeroID_Shinobu] = false


}
public push_incompatibility_pair(hero_a,hero_b){

	if((hero_a<0)||(hero_a>=SH_MAXHEROS)||(hero_b<0)||(hero_b>=SH_MAXHEROS)||(hero_a==hero_b)){
		return
	}
	if(filled_pair_count>=MAX_INCOMPATIBILITY_PAIRS){

		return
	}
	sh_incompatibility_pairs[filled_pair_count][pair_hero_a]= hero_a
	sh_incompatibility_pairs[filled_pair_count][pair_hero_b]= hero_b
	
	filled_pair_count++
}
safeguard_pair_process(id,heroID,heroID_a,heroID_b, sh_init_mode:mode){


	if(mode==SH_HERO_DROP){
		return INIT_FWD_PASS
	}
		
	new bool:is_a = (heroID==heroID_a),
			bool:is_b = (heroID==heroID_b)

	if(!is_a && !is_b){

		return INIT_FWD_PASS
	
	}
	new other_hero = is_a ? heroID_b : heroID_a
	if(!sh_get_user_has_hero(id,other_hero)){

		return INIT_FWD_PASS

	}

	static name_a[MAX_HERO_NAME_LENGTH],
			name_b[MAX_HERO_NAME_LENGTH]

	sh_get_hero_name_from_id(heroID_b,name_b)
	sh_get_hero_name_from_id(heroID_a,name_a)
	
	sh_chat_message(id,-1,"You cannot use the heroes %s and %s at once!",name_a,name_b)
	
	return INIT_FWD_BLOCK

	
}
public sh_hero_init_pre(id,heroID, sh_init_mode:mode){
	new true_return_result = INIT_FWD_PASS
	
	if((heroID<0)||(heroID>=SH_MAXHEROS)){
		return INIT_FWD_PASS
	}

	if(!is_user_connected(id)){

		return INIT_FWD_PASS
	}
	if(is_user_bot(id)){

		if(!is_hero_bot_pickable[heroID]){

			return INIT_FWD_BLOCK
		}
	}

	for(new i=0;i<filled_pair_count;i++){


		true_return_result = max(
			safeguard_pair_process(id,
					heroID,
					sh_incompatibility_pairs[i][pair_hero_a],
					sh_incompatibility_pairs[i][pair_hero_b],
					mode),
					true_return_result)
		
		if(true_return_result == INIT_FWD_BLOCK){
			break
		}
	}

	return true_return_result
}