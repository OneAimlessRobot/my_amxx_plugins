#if defined sh_aux_fx_funcs_natives_pt1
  #endinput
#endif
#define sh_aux_fx_funcs_natives_pt1

native ammo_hud(id,number,sw)

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


native directed_spark(init_id, end_id,girth=10,veins=10,glowing=255,ramming_pace=8,color_constant=GREEN, life=1, make_sound=1)

native glow(id, r, g, b,a, on)

native suck_in_fx(ent_id,make_sound)


native draw_aim_vector(id,sh_custom_color:color_vector_indices[3]={CUSTOM,CUSTOM,CUSTOM});

/**
true for torus
false for disk

*/
native create_fired_shot_disk(Float:Pos[3],ent,bool:torus_or_disk=true)
