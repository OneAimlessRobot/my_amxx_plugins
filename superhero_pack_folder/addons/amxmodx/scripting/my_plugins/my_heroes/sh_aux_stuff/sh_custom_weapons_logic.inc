#if defined sh_custom_weapons_logic_inc
  #endinput
#endif
#define sh_custom_weapons_logic_inc

/*in my current configuration,
The entity variable that I use to store custom weapon id is:

pev_iuser1

EXCLUSIVELY IN WEAPON ENTITIES!

use this stock to confirm whether or not the entity is an actual CS weapon!
*/


const default_starting_secret_code =1000



stock bool:entity_is_weapon(ent, bit_mask_to_check=(GUNS_BIT_SUM|CSW_KNIFE)){

  if(pev_valid(ent)!=PDATA_SAFE){
    return false
  }

  static iId; iId = get_pdata_int(ent, m_iId, XO_WEAPON)

  if(!cs_is_valid_itemid(iId, true)){

    return false
  }

  if(!Get_BitVar(bit_mask_to_check,iId)){
    return false
  }

  return true



}
stock remove_weapon_secret_code(ent,weapon_code_to_check_for=-1){

  if(!entity_is_weapon(ent)){

    return
  }
  static curr_weapon_secret_code = -1
  curr_weapon_secret_code = entity_get_int(ent, EV_INT_iuser1)
  
  if(curr_weapon_secret_code<0){
  
    return
  
  }
  
  if((weapon_code_to_check_for>=0)&&(curr_weapon_secret_code==weapon_code_to_check_for)){

    entity_set_int(ent, EV_INT_iuser1, -1)
    return
  }

  entity_set_int(ent, EV_INT_iuser1, -1)

}
stock set_weapon_secret_code(ent, weapon_secret_code_to_set){

  if(!entity_is_weapon(ent)){

    return
  }

  entity_set_int(ent, EV_INT_iuser1, weapon_secret_code_to_set)

}
stock get_weapon_secret_code(ent){

  if(!entity_is_weapon(ent)){

    return -1
  }

  return entity_get_int(ent, EV_INT_iuser1)

}
native allocate_weapon_secret_code();
