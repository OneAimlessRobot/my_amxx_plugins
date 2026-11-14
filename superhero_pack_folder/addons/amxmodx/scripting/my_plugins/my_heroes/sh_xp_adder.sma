#define I_WANT_QUICK_CHECKS

#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "./sh_xp_adder_inc/sh_xp_adder_inc.inc"

#define PLUGIN "Superhero xp adder funcs"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

#define BASE_XP_DMG_COEFF 4.0
enum xp_bonus_struct{

	xp_extra_earn_string[64],
	
	xp_extra_type_string[32],
	
	Float:xp_extra_type_mult, // these are positive. Enum flag for subtraction takes care of penalties and rewards

	xp_extra_type_bonus, // these are positive. Enum flag for subtraction takes care of penalties and rewards

    bool:notify_before,

    bool:notify_after,

    bool:is_subtracted

}

stock const xp_extra_earn_struct_arr[xp_type_bonus_id][xp_bonus_struct] = {
	{"for killing players" ,"XP_KILL_XP", 9.0, 0, false,true, false},

	{"for the damage you caused to the enemy team", "XP_DAMAGE_XP", 1.0, 0, false,true, false},

	{"for planting the bomb", "XP_BOMB_PLANT_XP",500.0, 50, true,true, false},
	{"along with your team for detonating the bomb", "XP_BOMB_EXPLODE_XP",900.0, 10, true,true, false},
	{"along with your team for saving the bomb target", "XP_BOMB_TARGET_SAVE_XP",500.0, 10, true,true, false},


	{"for being the bomb defuser", "XP_BOMB_DEFUSE_XP",1000.0, 5, true,true, false},

	{"killing a single or multiple hostages", "XP_KILL_HOSTAGE_XP",500.0,25, true,true, true},
	{"for rescuing a single or multiple hostages", "XP_HOSTAGE_RESCUED_XP",500.0,25, true,true, false},
	{"along with your team for rescuing all the hostages", "XP_HOSTAGE_ALL_RESCUED_XP",900.0,15, true,true, false},


	{"for killing the vip", "XP_VIP_ASSASSINATE_XP",3.0,15, true,true, false},
	{"for escaping as the vip", "XP_VIP_ESCAPE_XP",2000.0, 30, true,true, false},
	{"along with your team for protecting the vip", "XP_VIP_PROTECT_XP",2500.0, 10, true,true, false}



}
stock player_built_xp_this_round[SH_MAXSLOTS+1][xp_type_bonus_id]


public plugin_init()
{

register_plugin(PLUGIN, VERSION, AUTHOR)

for(new i=0;i<sizeof player_built_xp_this_round;i++){

    arrayset(player_built_xp_this_round[i],0,sizeof player_built_xp_this_round[])

}

RegisterHam(Ham_TakeDamage, "player", "common_damage", 1,true)

}
//this is biased towards the attacker obs. So this is what you multiply the damage that the attacker puts in by
Float:calculate_dmg_xp_coeff(id, idattacker){
    if(!is_user_connected(id)){

        return BASE_XP_DMG_COEFF //as if we assumed that they were same level
    }
    new Float:vic_level = float(sh_get_user_lvl(id)),
        Float:att_level = float(sh_get_user_lvl(idattacker))

    
    new Float:coeff = max_macro(1.0, vic_level - att_level)

    coeff *= vic_level

    coeff *= BASE_XP_DMG_COEFF

    return coeff

}

public common_damage(id, idinflictor, idattacker, Float:damage, damagebits)
{
    if(damage <= 0.0){

        return
    }
    if ( !sh_is_active() || !is_user_connected(idattacker)){
        return
    }

    if((id==idattacker)||sh_clients_are_same_team(id,idattacker)){


        return
    }


    sh_set_user_xp_fwd_post(idattacker, floatround(calculate_dmg_xp_coeff(id, idattacker) * damage), XP_DAMAGE_XP)

}

public sh_extra_damage_fwd_post(victim, attacker, damage, my_hitpoint_enum:bodypart ,sh_damage_mode:dmgMode, sh_extra_damage_flags:sh_extra_dmg_flags, const Float:dmgOrigin[3],dmg_type,const sh_thrash_brat_dmg_type:new_dmg_type, const custom_weapon_id){

    if ( !sh_is_active() ||  !is_user_connected(attacker)){

        return
    }
    if((victim==attacker)||sh_clients_are_same_team(victim,attacker)){


        return
    }
    if(!is_valid_custom_dmg_source(_:new_dmg_type)){

        return

    }
    if(damage <= 0){

        return
    }

    sh_set_user_xp_fwd_post(attacker,floatround(calculate_dmg_xp_coeff(victim, attacker)) * damage, XP_DAMAGE_XP)
    
}

public sh_set_user_xp_fwd_post(id, xp,xp_type_bonus_id:xp_type){

    if(!sh_is_active()||!is_user_connected(id)){

        return XP_FWD_PASS
    }
    new bool:is_subtracted_here = xp_extra_earn_struct_arr[xp_type][is_subtracted]

    new xp_diff = ( (is_subtracted_here?-1:1)*(xp+xp_extra_earn_struct_arr[xp_type][xp_extra_type_bonus]) )

    player_built_xp_this_round[id][xp_type]+=xp_diff
    
    if((xp_type>enum_zero) && xp_extra_earn_struct_arr[xp_type][notify_before]){

        sh_chat_message(id,-1,"You shall be %s %d xp %s at the end of the round",
                is_subtracted_here?"deducted":"awarded an extra",
                (is_subtracted_here?-1:1)*xp_diff,
                xp_extra_earn_struct_arr[xp_type][xp_extra_earn_string])
    }
    return XP_FWD_PASS

}

public sh_round_start(){

    if(!sh_is_active()){
        return;
    }
    for(new i=1;i< sh_maxplayers()+1;i++){
        if(is_user_connected(i)){
            for(new xp_type_bonus_id:type=enum_zero; type<xp_type_bonus_id; type++){
                new bool:is_subtracted_here = xp_extra_earn_struct_arr[type][is_subtracted]
                new xp_diff=player_built_xp_this_round[i][type]*
                            (floatround( xp_extra_earn_struct_arr[type][xp_extra_type_mult]));

                if(xp_diff!=0){
                    if(xp_extra_earn_struct_arr[type][notify_after]){

                        sh_chat_message(i,-1,"You were %s %d xp %s last round!",
                                    xp_extra_earn_struct_arr[type][is_subtracted]?"deducted":"awarded an extra",
                                    (is_subtracted_here?-1:1)*xp_diff,
                                    xp_extra_earn_struct_arr[type][xp_extra_earn_string])
                    
                    }    
                    
                    sh_set_user_xp(i,xp_diff,true);
                }
            }
            arrayset(player_built_xp_this_round[i], 0, xp_type_bonus_id)
        }
    }

}