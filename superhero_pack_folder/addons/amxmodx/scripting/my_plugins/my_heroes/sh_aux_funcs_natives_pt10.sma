#define I_WANT_CONSTANTS
#include <amxmisc>
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"


#define PLUGIN "Superhero aux natives pt10: superhero pickability checks: individual incompatibility"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"
#include "maria_riveter_inc/maria_general_funcs.inc"
#include "flora_inc/flora_global.inc"
#include "sablina_inc/sablina.inc"
#include "goku_inc/goku_inc.inc"
#include "ester_inc/ester_global.inc"
#include "chikoi_inc/chikoi_inc.inc"
#include "vegetto_inc/vegetto_inc.inc"
#include "ksun_inc/ksun_global.inc"
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
	gHeroID_Yakui = -1,
	gHeroID_ksun = -1,
	gHeroID_Chikoi = -1,
	gHeroID_Sablina = -1

#define COMPLAIN_SENTENCE_SIZE 128

#define MAX_INCOMPATIBILITY_PAIRS 32


new filled_pair_count = 0
enum superhero_incompatibility_pair{

	pair_hero_a,
	pair_hero_b,
	custom_complain_sentence[COMPLAIN_SENTENCE_SIZE+1]

}

new sh_incompatibility_pairs[MAX_INCOMPATIBILITY_PAIRS][superhero_incompatibility_pair]


public plugin_init(){


	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_concmd(hero_incompatible_pairs_print,hero_incompatible_pairs_print,ADMIN_ALL)

	
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

	gHeroID_ksun = spores_ksun_hero_id()

	gHeroID_Chikoi = chikoi_get_hero_id()

	gHeroID_Sablina = sablina_get_hero_id()

	//these two really dont get along
	
	push_incompatibility_pair(gHeroID_Goku,gHeroID_Shinobu, "Goku: ^"I dont fw parasites^"")

	push_incompatibility_pair(gHeroID_Ester,gHeroID_Shinobu, "Ester: ^"I dont fw parasites^"")

	push_incompatibility_pair(gHeroID_Flora,gHeroID_Shinobu, "Flora: ^"I dont fw parasites^"")

	push_incompatibility_pair(gHeroID_Shinobu,gHeroID_Yakui, "Yakui: ^"I dont fw parasites^"")

	push_incompatibility_pair(gHeroID_Flora,gHeroID_Yakui, "Flora: ^"(She creeps me out!)^"")

	push_incompatibility_pair(gHeroID_Flora,gHeroID_SuperNoodle, "Flora: ^"Too loud... too many explosions^"")

	push_incompatibility_pair(gHeroID_Shinobu,gHeroID_SuperNoodle, "Sliphantom: ^"I dont fw parasites^"")

	push_incompatibility_pair(gHeroID_Maria,gHeroID_Shinobu, "Maria: ^"I DONT FUCK WITH PARASITES!^"")

	push_incompatibility_pair(gHeroID_Vegetto,gHeroID_Shinobu, "Vegetto: ^"No...^"")

	push_incompatibility_pair(gHeroID_Vegetto,gHeroID_Goku, "Both: ^"A warrior FIGHTS ALONE!^"")

	push_incompatibility_pair(gHeroID_ksun, gHeroID_Maria, "Maria: ^"I dont fw parasites^" ksun: ^"So stuck up...^"")

	push_incompatibility_pair(gHeroID_Chikoi, gHeroID_Maria, "Maria: ^"She is strange...^"")

	push_incompatibility_pair(gHeroID_Chikoi, gHeroID_ksun, "ksun: ^"She is strange...^"")

	push_incompatibility_pair(gHeroID_Ester, gHeroID_ksun, "Both: ^"NO! FUCK THAT BITCH...^"")

	push_incompatibility_pair(gHeroID_Sablina, gHeroID_Maria, "Maria: ^"She is waaaay too lax. I dont trust her...^"")

	


	server_print("%s innited!^n",LIBRARY_NAME)
	

}

stock hero_incompatible_pairs_print_aux(id){

	static name_a[MAX_HERO_NAME_LENGTH],
			name_b[MAX_HERO_NAME_LENGTH]

	console_print(id,"The Incompatibility pairs registered in this server are:^n")
	if(!filled_pair_count){


		console_print(id,"None are registered!^n")
		return
	}
	for(new i=0;i<filled_pair_count;i++){

		sh_get_hero_name_from_id(sh_incompatibility_pairs[i][pair_hero_b],name_b)
		sh_get_hero_name_from_id(sh_incompatibility_pairs[i][pair_hero_a],name_a)
		

		console_print(id,"Pair number %d^n",i)
		console_print(id,"- ^"%s^" is NOT compatible with %s!^nReason: ^"",name_a, name_b)
		if(strlen(sh_incompatibility_pairs[i][custom_complain_sentence])>0){

			console_print(id,"%s^"^n",sh_incompatibility_pairs[i][custom_complain_sentence])

		}
		else{


			console_print(id,"No reason specified^"^n")
		}
		
	}

}
public sh_hero_incompatible_pairs_print(id,level,cid){

	if (!cmd_access(id,level,cid,0))
		return PLUGIN_HANDLED

	
	hero_incompatible_pairs_print_aux(id)

	return PLUGIN_HANDLED
}

push_incompatibility_pair(hero_a,hero_b,const complain_sentence[COMPLAIN_SENTENCE_SIZE+1] = "Incompatible pair of heroes"){


	if((hero_a<0)||(hero_a>=SH_MAXHEROS)||(hero_b<0)||(hero_b>=SH_MAXHEROS)||(hero_a==hero_b)){
		return
	}
	if(filled_pair_count>=MAX_INCOMPATIBILITY_PAIRS){

		return
	}
	sh_incompatibility_pairs[filled_pair_count][pair_hero_a]= hero_a
	sh_incompatibility_pairs[filled_pair_count][pair_hero_b]= hero_b

	copy(sh_incompatibility_pairs[filled_pair_count][custom_complain_sentence],
			COMPLAIN_SENTENCE_SIZE,
			complain_sentence)
	
	filled_pair_count++
}
init_fwd_ret_id:safeguard_pair_process(id,heroID,heroID_a,heroID_b, sh_init_mode:mode, pair_id){


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
	
	sh_chat_message(id,-1,"[SH hero incompatibility pairs manager] ^"%s^"",
			sh_incompatibility_pairs[pair_id][custom_complain_sentence])


	sh_chat_message(id,-1,"[SH hero incompatibility pairs manager] You cannot use the heroes %s and %s at once!",
			name_a,name_b)
	
	sh_chat_message(id,-1,"[SH hero incompatibility pairs manager] type ^"%s^" in the console",hero_incompatible_pairs_print)
	
	sh_chat_message(id,-1,"To check the incompatibility pairs registered in the server")


	return INIT_FWD_BLOCK

	
}
public init_fwd_ret_id:sh_hero_init_pre(id,heroID, sh_init_mode:mode){
	new init_fwd_ret_id:true_return_result = INIT_FWD_PASS
	
	if((heroID<0)||(heroID>=SH_MAXHEROS)){
		return INIT_FWD_PASS
	}

	if(!client_is_within_range(id)){

		return INIT_FWD_PASS
	}
	if(is_user_bot(id)){

		if(sh_get_hero_bit(heroID, SH_BOT_RESTRICTED)){

			return INIT_FWD_BLOCK
		}
	}

	for(new i=0;i<filled_pair_count;i++){


		true_return_result = init_fwd_ret_id:max(
			safeguard_pair_process(id,
					heroID,
					sh_incompatibility_pairs[i][pair_hero_a],
					sh_incompatibility_pairs[i][pair_hero_b],
					mode,
					i),
					true_return_result)
		
		if(true_return_result == INIT_FWD_BLOCK){
			break
		}
	}

	return true_return_result
}