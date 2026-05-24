#if defined sh_aux_fx_funcs_natives_pt1
  #endinput
#endif
#define sh_aux_fx_funcs_natives_pt1

enum damage_icon_types{
  DMG_ICON_POISON=0,
  DMG_ICON_RADIATION,
  DMG_ICON_SHOCK,
  DMG_ICON_GAS,
  DMG_ICON_HEAT,
  DMG_ICON_HEALTH,
  DMG_ICON_ARMOR,
  DMG_ICON_LONGJUMP,
  DMG_ICON_BIO,
  DMG_ICON_CHEM,
  DMG_ICON_DROWN,
	DMG_ICON_BATTERY
}
native ammo_hud(id,number,sw)


native remove_glow_user(id,Float:delay)

native precache_native_fx_pt1()
native prepare_shero_aux_lib_pt1()

native trail_custom(ent_id,color[3]={255,255,255},life=3,width=10,alpha=255)

native trail(ent_id,sh_custom_color:color_const=PINK,life=3,width=10,alpha=120)

native make_sparks(Float:the_pos[3])

native random_fire(Origin[3], ent, Float:radius)

native make_fire(id, Float:rad)

native make_shockwave(Float:point[3],Float:radius,const color[3],shockwave_frame_rate=1,shockwave_life=10,shockwave_line_width=8,shockwave_amplitude=1,alpha=255)
/** 
hide=0
show=1
flash=2

enum damage_icon_types{
  DMG_ICON_POISON=0,
  DMG_ICON_RADIATION,
  DMG_ICON_SHOCK,
  DMG_ICON_GAS,
  DMG_ICON_HEAT,
  DMG_ICON_HEALTH,
  DMG_ICON_ARMOR,
  DMG_ICON_LONGJUMP,
  DMG_ICON_BIO,
  DMG_ICON_CHEM,
  DMG_ICON_DROWN,
	DMG_ICON_BATTERY

}


 */
native set_damage_icon(id,hide_show_or_flash=0,
          damage_icon_types:the_type_of_icon=DMG_ICON_POISON,
          const color[3]={0,0,0},
          Float:the_remove_timer=0.0)


/** 
remember:

this is a special fx function.
the purpose of the radius value
is to allow the native to choose
between big decals (Radius>18)
or small decals (otherwise)

*/
native tank_impact_shot_fx(ent_id, Float:origin[3],radius=18)
native heal_stream(id, x,
    sh_custom_color:color_index=LTGREEN,alpha=255)

native unfade_screen_user(id)

native fade_screen_user(id)
//----------------------------------------------------------------------------------------------
native laser_line(ent_id,Float:Pos[3], Float:vEnd[3],killbeam,
      sh_custom_color:color_constants[3]={RED,BLUE,CUSTOM},
      bool:for_one=false,
      bool:make_sound=false,
      const default_sound_sample[]=LASER_LINE_DEFAULT_SOUND);

native draw_bbox(ent_id,killbeam)

native gun_shot_decal(Float:vec[3])

native big_gun_shot_decal(Float:vec[3], radius=18)

//-----------------------------------------------------------------------------------------------

/**
Explosion sfx masks!


enum explosion_sfx_flags (<<= 1){
	sfx_show_nothing = 0,
	sfx_show_shockwave = 1,
	sfx_show_fireball,
	sfx_show_smoke,
	sfx_show_burn_decal,
	sfx_show_custom_sound

}

*/
native explode_fx( vec1[3] ,radius, sh_custom_color:fx_color=WHITE,alpha=255,
            explosion_sfx_flags:sfx_mask=(sfx_show_shockwave|sfx_show_fireball|sfx_show_smoke|sfx_show_burn_decal))

native directed_spark(init_id, end_id,girth=10,veins=10,glowing=255,ramming_pace=8,color_constant=GREEN)

native glow(id, r, g, b,a, on)

native suck_in_sound(ent_id,make_sound)


native aura(id,const color[3]={255,255,255},life=3,decay=1)

native detect_user(id,enemy,Float:origin[3]={0.0,0.0,0.0})


native draw_aim_vector(id,sh_custom_color:color_vector_indices[3]={CUSTOM,CUSTOM,CUSTOM});

/**
true for torus
false for disk

*/
native create_fired_shot_disk(Float:Pos[3],ent,bool:torus_or_disk=true)

native set_render_with_color_const(id,sh_custom_color:the_color_num,glow_on_user=1,alpha=-1,the_hud_alpha=-1,glow_user_hud=1,is_sleep=0,
    Float:unglow_timer=0.0)