#if defined sh_aux_fx_funcs_natives_pt2
  #endinput
#endif
#define sh_aux_fx_funcs_natives_pt2


native precache_native_fx_pt2()
native prepare_shero_aux_lib_pt2()

native fx_invisible(id)

native fx_blood(origin[3],origin2[3],HitPlace,bool:alien=false)


native strip_weapon_for_my_grenade_heroes(id,const message[]="You ran out",classid=CSW_DEAGLE,bool:optional_bool=true)


native fx_bleed(origin[3],bool:alien=false)


native fx_blood_small(origin[3],num)


native fx_blood_large(origin[3],num)

native fx_gib_explode(origin[3],origin2[3])

native fx_extra_blood(origin[3])

native fx_headshot(origin[3])

native anime_kill_fx(origin[3])


native precache_gibs()


native draw_view_cone(player_id, Float:fov_to_contain, Float:distance_limit)
