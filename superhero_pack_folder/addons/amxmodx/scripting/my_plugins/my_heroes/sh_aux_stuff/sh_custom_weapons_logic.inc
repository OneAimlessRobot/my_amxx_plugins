#if defined sh_custom_weapons_logic_inc
  #endinput
#endif
#define sh_custom_weapons_logic_inc

native bool:entity_is_weapon(ent, bit_mask_to_check=(GUNS_BIT_SUM|CSW_KNIFE), &weapon_id_to_extract=CSW_NONE);

native remove_weapon_secret_code(ent,weapon_code_to_check_for=-1);

native get_weapon_secret_code(ent);

native set_weapon_secret_code(ent, weapon_secret_code_to_set);

native allocate_weapon_secret_code();
