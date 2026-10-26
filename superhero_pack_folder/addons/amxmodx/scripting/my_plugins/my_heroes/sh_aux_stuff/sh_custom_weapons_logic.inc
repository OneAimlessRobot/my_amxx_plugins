#if defined sh_custom_weapons_logic_inc
  #endinput
#endif
#define sh_custom_weapons_logic_inc

#define my_create_entity(%1) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, %1))

stock my_give_item(index, const item[]) {
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
		return 0;

	new ent = my_create_entity(item);
	if (!pev_valid(ent))
		return 0;

	new Float:origin[3];
	pev(index, pev_origin, origin);
	set_pev(ent, pev_origin, origin);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);

	new save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, index);
	if (pev(ent, pev_solid) != save)
		return ent;

	engfunc(EngFunc_RemoveEntity, ent);

	return -1;
}

stock my_get_user_weapon_entity(id, wid = 0) {
	new weap = wid, clip, ammo;
	if (!weap && !(weap = get_user_weapon(id, clip, ammo)))
		return 0;
	
	new class[32];
	get_weaponname(weap, class, sizeof class - 1);

	return my_find_ent_by_owner(-1, class, id);
}

native bool:entity_is_weapon(ent, bit_mask_to_check=(GUNS_BIT_SUM|CSW_KNIFE), &weapon_id_to_extract=CSW_NONE);

native remove_weapon_secret_code(ent,weapon_code_to_check_for=-1);

native get_weapon_secret_code(ent);

native set_weapon_secret_code(ent, weapon_secret_code_to_set);

native allocate_weapon_secret_code();
