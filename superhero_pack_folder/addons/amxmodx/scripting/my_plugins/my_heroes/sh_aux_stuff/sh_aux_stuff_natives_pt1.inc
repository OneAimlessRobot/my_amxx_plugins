#if defined sh_aux_fx_funcs_natives_pt1
  #endinput
#endif
#define sh_aux_fx_funcs_natives_pt1



native precache_native_fx_pt1()
native prepare_shero_aux_lib_pt1()

native trail_custom(ent_id,color[3]={255,255,255},life=3,width=10,alpha=255)

native trail(ent_id,color_const=PINK,life=3,width=10,alpha=120)

native make_sparks(Float:the_pos[3])

native random_fire(Origin[3], ent, Float:radius)

native make_fire(id, Float:rad)

native make_shockwave(point[3],Float:radius,const color[3],shockwave_frame_rate=1,shockwave_life=10,shockwave_line_width=8,shockwave_amplitude=1,alpha=255)


native heal_stream(id, x,color_index=LTGREEN,alpha=255)

native unfade_screen_user(id)

native fade_screen_user(id)
//----------------------------------------------------------------------------------------------
native laser_line(ent_id,Float:Pos[3], Float:vEnd[3],killbeam,color_constants[3]={RED,BLUE,CUSTOM},bool:for_one=false,bool:make_sound=false,const default_sound_sample[]=LASER_LINE_DEFAULT_SOUND);

native draw_bbox(ent_id,killbeam)

native gun_shot_decal(Float:vec[3])

//-----------------------------------------------------------------------------------------------
native explode_fx( vec1[3] ,radius)

native directed_spark(init_id, end_id,girth=10,veins=10,glowing=255,ramming_pace=8,color_constant=GREEN)


//----------------------------------------------------------------------------------------------
native blood_spray(Float:vicOrigin[3], scale)


native glow(id, r, g, b,a, on)

native suck_in_sound(ent_id,make_sound)


native aura(id,const color[3]={255,255,255},life=3,decay=1)

native detect_user(id,enemy,Float:origin[3]={0.0,0.0,0.0})


native draw_aim_vector(id,color_vector_indices[3]={CUSTOM,CUSTOM,CUSTOM});


native shoteffects(Float:Pos[3],ent)

native set_render_with_color_const(id,the_color_num,glow_on_user=1,alpha=-1,the_hud_alpha=-1,glow_user_hud=1,is_sleep=0)