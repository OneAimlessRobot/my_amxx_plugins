#if defined sh_aux_fx_funcs_pt1
  #endinput
#endif
#define sh_aux_fx_funcs_pt1



stock trail_custom(ent_id,color[4]={255,255,255,255},life=3,width=10){

		if(pev_valid(ent_id)!=2){
		
			return
		}
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
		write_byte( TE_BEAMFOLLOW )
		write_short(ent_id) // entity
		write_short(m_trail)  // model
		write_byte( life )       // life
		write_byte( width )        // width
		write_byte(color[0])			// r, g, b
		write_byte(color[1])		// r, g, b
		write_byte(color[2])			// r, g, b
		write_byte(color[3]) // brightness
		message_end()
}
stock trail(ent_id,color_const=PINK,life=3,width=10){

		if(pev_valid(ent_id)!=2){
		
			return
		}
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
		write_byte( TE_BEAMFOLLOW )
		write_short(ent_id) // entity
		write_short(m_trail)  // model
		write_byte( life )       // life
		write_byte( width )        // width
		write_byte(LineColors[color_const][0])			// r, g, b
		write_byte(LineColors[color_const][1])		// r, g, b
		write_byte(LineColors[color_const][2])			// r, g, b
		write_byte(LineColors[color_const][3]) // brightness
		message_end()
}
stock make_sparks(Float:the_pos[3]){
	

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SPARKS);
	engfunc(EngFunc_WriteCoord, the_pos[0])
	engfunc(EngFunc_WriteCoord, the_pos[1])
	engfunc(EngFunc_WriteCoord, the_pos[2])
	message_end();	
	
}

stock random_fire(Origin[3], ent, Float:radius) {

	static iRange, iOrigin[3], g_g, i;

	iRange = floatround(radius);

	for (i = 1; i <= 5; i++) {

		g_g = 1;

		iOrigin[0] = Origin[0] + random_num(-iRange, iRange);
		iOrigin[1] = Origin[1] + random_num(-iRange, iRange);
		iOrigin[2] = Origin[2];
		iOrigin[2] = ground_z(iOrigin, ent);

		while (get_distance(iOrigin, Origin) > iRange) {		// If iOrigin is too far away, recalculate its position

			iOrigin[0] = Origin[0] + random_num(-iRange, iRange);
			iOrigin[1] = Origin[1] + random_num(-iRange, iRange);
			iOrigin[2] = Origin[2];

			if (++g_g >= ANTI_LAGG) {
				iOrigin[2] = ground_z(iOrigin, ent, 1);
			} else {
				iOrigin[2] = ground_z(iOrigin, ent);
			}
		}

		new rand = random_num(5, 15);

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_SPRITE);
		write_coord(iOrigin[0]);	// Position
		write_coord(iOrigin[1]);
		write_coord(iOrigin[2] + rand * 5);
		write_short(g_iFireSprite);	// Sprite index
		write_byte(rand);		// Scale
		write_byte(100);		// Brightness
		message_end();
	}

	// One smoke puff for each call to random_fire, regardless of number of flames
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SMOKE);
	write_coord(iOrigin[0]);			// Position
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2] + 120);
	write_short(g_iSmokeSprite[random_num(0, 1)]);	// Sprite index
	write_byte(random_num(10, 30));			// Scale
	write_byte(random_num(10, 20));			// Framerate
	message_end();

}
stock make_fire(id, Float:rad){

	new radius=floatround(rad)
	new rx, ry, rz, Float:forigin[3]
	rx = random_num(-radius, radius)
	ry = random_num(-radius, radius)
	rz = random_num(-radius, radius)

	pev(id, pev_origin, forigin)

	// Additive sprite, plays 1 cycle
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITE)		// 17
	engfunc(EngFunc_WriteCoord, forigin[0] + rx)	// coord, coord, coord (position)
	engfunc(EngFunc_WriteCoord, forigin[1] + ry)
	engfunc(EngFunc_WriteCoord, forigin[2] + 10 + rz)
	write_short(gSpriteBurning)	// short (sprite index)
	write_byte(30)		// byte (scale in 0.1's)
	write_byte(200)		// byte (brightness)
	message_end()

	// Smoke
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_SMOKE)		// 5
	engfunc(EngFunc_WriteCoord, forigin[0] + (rx*2))	// coord, coord, coord (position)
	engfunc(EngFunc_WriteCoord, forigin[1] + (ry*2))
	engfunc(EngFunc_WriteCoord, forigin[2] + 100 + (rz*2))
	write_short(gSpriteSmoke)	// short (sprite index)
	write_byte(60)		// byte (scale in 0.1's)
	write_byte(15)		// byte (framerate)
	message_end()


}
stock make_shockwave(point[3],Float:radius,const color[4],shockwave_frame_rate=1,shockwave_life=10,shockwave_line_width=8,shockwave_amplitude=1){



	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( TE_BEAMCYLINDER)
	write_coord(point[0])
	write_coord(point[1])
	write_coord(point[2] + 16)
	write_coord(point[0])
	write_coord(point[1])
	write_coord(point[2] + floatround(radius))
	write_short( white )
	write_byte( 0 )
	write_byte(shockwave_frame_rate)		// frame rate in 0.1's
	write_byte(shockwave_life)		// life in 0.1's
	write_byte(shockwave_line_width)		// line width
	write_byte(shockwave_amplitude)		// noise amplitude in 0.01's
	write_byte( color[0])
	write_byte( color[1] )
	write_byte( color[2] )
	write_byte( color[3] )
	write_byte(0)
	message_end()

}

stock heal_stream(id, x,color_index=LTGREEN)
{
	
	new origin[3]
	
	get_user_origin(id, origin, 1)
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( 8 )
	write_short(id)				// start entity
	write_short(x)				// entity
	write_short(white)		// model
	write_byte( 0 ) 				// starting frame
	write_byte( 30 )  			// frame rate
	write_byte( 1)  			// life
	write_byte( 45)  		// line width
	write_byte( 0 )  			// noise amplitude
	write_byte( LineColors[color_index][0] )				// r, g, b
	write_byte( LineColors[color_index][1] )				// r, g, b
	write_byte( LineColors[color_index][2] )				// r, g, b
	write_byte( LineColors[color_index][3] )				// brightness
	write_byte( 8 )				// scroll speed
	message_end()
	
}
stock unfade_screen_user(id){
	message_begin(MSG_ONE, g_msgFade, {0,0,0}, id); // use the magic #1 for "one client"  
	write_short(1<<12); // fade lasts this long duration  
	write_short(1<<8); // fade lasts this long hold time  
	write_short(FADE_OUT); // fade type
	write_byte(0); // fade red  
	write_byte(0); // fade green  
	write_byte(0); // fade blue	 
	write_byte(255); // fade alpha	 
	message_end();	
	
}
//----------------------------------------------------------------------------------------------
stock laser_line(ent_id,Float:Pos[3], Float:vEnd[3],killbeam,color_constants[3]={RED,BLUE,CUSTOM},bool:for_one=false)
{
	if ( !pev_valid(ent_id) ) return
	static  colors[3]
	if(client_hittable(pev(ent_id, pev_owner))){
	
		switch ( cs_get_user_team(pev(ent_id, pev_owner)) )
		{
			case CS_TEAM_T: colors = LineColors[color_constants[0]]
				case CS_TEAM_CT: colors = LineColors[color_constants[1]]
					default: colors = LineColors[color_constants[2]]
		}
	}
	else{

		colors=LineColors[color_constants[2]]
	}
	//This is a little cleaner but not much
	if ( killbeam ) {
		//Kill the Beam
		message_begin(for_one?MSG_ONE_UNRELIABLE:MSG_BROADCAST, SVC_TEMPENTITY,_,for_one?ent_id:0) //message begin
		write_byte(TE_KILLBEAM)
		write_short(ent_id) // entity
		message_end()
	}
	
	message_begin(for_one?MSG_ONE_UNRELIABLE:MSG_BROADCAST, SVC_TEMPENTITY,_,for_one?ent_id:0) //message begin
	write_byte (0)     //TE_BEAMENTPOINTS 0
	write_coord_f(Pos[0])
	write_coord_f(Pos[1])
	write_coord_f(Pos[2])		// start entity
	write_coord_f(vEnd[0])	// end position
	write_coord_f( vEnd[1])
	write_coord_f(vEnd[2])
	write_short(gSpriteLaser)// sprite index
	write_byte(0)		// starting frame
	write_byte(0)		// frame rate in 0.1's
	write_byte(1)		// life in 0.1's
	write_byte(5)		// line width in 0.1's
	write_byte(0)		// noise amplitude in 0.01's
	write_byte(colors[0])	// Red
	write_byte(colors[1])	// Green
	write_byte(colors[2])	// Blue
	write_byte(255)	// brightness
	write_byte(0)		// scroll speed in 0.1's
	message_end()
}
stock draw_bbox(ent_id,killbeam){
	new Float:bbox_mins[3],Float:bbox_maxs[3],Float:ent_orig[3]
		
	//Example: vex_rld = vex rear left down (z, y, x)
	//left= min
	//right= max

	Entvars_Get_Vector(ent_id, EV_VEC_mins,bbox_mins)
	Entvars_Get_Vector(ent_id, EV_VEC_maxs,bbox_maxs)
	pev(ent_id,pev_origin,ent_orig)
	new Float:vex_rld[3],Float:vex_rlu[3],Float:vex_rrd[3],Float:vex_rru[3];
	new Float:vex_fld[3],Float:vex_flu[3],Float:vex_frd[3],Float:vex_fru[3];
	
	// Rear left down
	vex_rld[0] = ent_orig[0] + bbox_mins[0];
	vex_rld[1] = ent_orig[1] + bbox_mins[1];
	vex_rld[2] = ent_orig[2] + bbox_mins[2];
	
	// Rear left up
	vex_rlu[0] = ent_orig[0] + bbox_mins[0];
	vex_rlu[1] = ent_orig[1] + bbox_mins[1];
	vex_rlu[2] = ent_orig[2] + bbox_maxs[2];
	
	// Rear right down
	vex_rrd[0] = ent_orig[0] + bbox_maxs[0];
	vex_rrd[1] = ent_orig[1] + bbox_mins[1];
	vex_rrd[2] = ent_orig[2] + bbox_mins[2];
	
	// Rear right up
	vex_rru[0] = ent_orig[0] + bbox_maxs[0];
	vex_rru[1] = ent_orig[1] + bbox_mins[1];
	vex_rru[2] = ent_orig[2] + bbox_maxs[2];
	
	// Front left down
	vex_fld[0] = ent_orig[0] + bbox_mins[0];
	vex_fld[1] = ent_orig[1] + bbox_maxs[1];
	vex_fld[2] = ent_orig[2] + bbox_mins[2];
	
	// Front left up
	vex_flu[0] = ent_orig[0] + bbox_mins[0];
	vex_flu[1] = ent_orig[1] + bbox_maxs[1];
	vex_flu[2] = ent_orig[2] + bbox_maxs[2];
	
	// Front right down
	vex_frd[0] = ent_orig[0] + bbox_maxs[0];
	vex_frd[1] = ent_orig[1] + bbox_maxs[1];
	vex_frd[2] = ent_orig[2] + bbox_mins[2];
	
	// Front right up
	vex_fru[0] = ent_orig[0] + bbox_maxs[0];
	vex_fru[1] = ent_orig[1] + bbox_maxs[1];
	vex_fru[2] = ent_orig[2] + bbox_maxs[2];
	
	//draw lines
	
	laser_line(ent_id, vex_rld, vex_rrd, killbeam);
	laser_line(ent_id, vex_rld, vex_rlu, killbeam);
	laser_line(ent_id, vex_rrd, vex_rru, killbeam);
	laser_line(ent_id, vex_rlu, vex_rru, killbeam);
	
	// Front face
	laser_line(ent_id, vex_fld, vex_frd, killbeam);
	laser_line(ent_id, vex_fld, vex_flu, killbeam);
	laser_line(ent_id, vex_frd, vex_fru, killbeam);
	laser_line(ent_id, vex_flu, vex_fru, killbeam);
	
	// Connecting lines
	laser_line(ent_id, vex_rld, vex_fld, killbeam);
	laser_line(ent_id, vex_rlu, vex_flu, killbeam);
	laser_line(ent_id, vex_rrd, vex_frd, killbeam);
	laser_line(ent_id, vex_rru, vex_fru, killbeam);
	
	


}
stock gun_shot_decal(Float:vec[3]){
	
	new decal_id = burn_decal[random_num(0,4)]
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 109 ) // decal and ricochet sound
	write_coord_f( vec[0] ) //pos
	write_coord_f( vec[1] )
	write_coord_f( vec[2] )
	write_short (0) // I have no idea what thats supposed to be
	write_byte (decal_id) //decal
	message_end()	
}
//-----------------------------------------------------------------------------------------------
stock explode_fx( vec1[3] ,radius)
{
	// blast circles
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1)
	write_byte( 21 )
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2] + 16)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2] + radius*3)
	write_short( white )
	write_byte( 0 ) // startframe
	write_byte( 0 ) // framerate
	write_byte( 2 ) // life 2
	write_byte( 60 ) // width 16
	write_byte( 0 ) // noise
	write_byte( 255 ) // r
	write_byte( 0 ) // g
	write_byte( 0 ) // b
	write_byte( 255 ) //brightness
	write_byte( 0 ) // speed
	message_end()
	//Explosion2
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 12 )
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_byte( radius ) // byte (scale in 0.1's) 188
	write_byte( 10 ) // byte (framerate)
	message_end()
	
	//TE_Explosion
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1)
	write_byte( 3 )
	write_coord(vec1[0] + random_num( -100, 100 ))
	write_coord(vec1[1] + random_num( -100, 100 ))
	write_coord(vec1[2]+ random_num( -50, 50 ))
	write_short( fire )
	write_byte(  radius/9  ) // byte (scale in 0.1's) 188
	write_byte( 12 ) // byte (framerate)
	write_byte( 0 ) // byte flags
	message_end()
	
	//Smoke
	message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1)
	write_byte( 5 ) // 5
	write_coord(vec1[0] + random_num( -100, 100 ))
	write_coord(vec1[1] + random_num( -100, 100 ))
	write_coord(vec1[2] + random_num( -50, 50 ))
	write_short( smoke )
	write_byte( radius/14 )  // 2
	write_byte( 10 )  // 10
	message_end()
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(109)		// decal and ricochet sound
	write_coord(vec1[0])	// pos
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_short(0)			// I have no idea what thats supposed to be
	write_byte(28)			// decal
	message_end()
}
stock directed_spark(init_id, end_id,girth=10,veins=10,glowing=255,ramming_pace=8,color_constant=GREEN)
{
	emit_sound(init_id, CHAN_ITEM, "weapons/electro5.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte( 8 )
	write_short(init_id)				// start entity
	write_short(end_id)				// entity
	write_short(gSpriteLaser)		// model
	write_byte( 0 ) 				// starting frame
	write_byte( 30 )  			// frame rate
	write_byte( 1)  			// life
	write_byte(girth)  		// line width
	write_byte(veins)  			// noise amplitude
	write_byte(LineColors[color_constant][0])				// r, g, b
	write_byte(LineColors[color_constant][1])				// r, g, b
	write_byte(LineColors[color_constant][2])				// r, g, b
	write_byte( glowing)				// brightness
	write_byte( ramming_pace )				// scroll speed
	message_end()

}


//----------------------------------------------------------------------------------------------
stock blood_spray(Float:vicOrigin[3], scale)
{
	new Float:x
	new Float:y
	for(new i = 0; i < 2; i++) {
		x = float(random_num(-10, 10))
		y = float(random_num(-10, 10))
		for(new Float:j = 0.0; j < 2.0; j+=1.0) {
			// Blood spray
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(115)				// TE_BLOODSPRITE
			write_coord_f(vicOrigin[0]+(x*j))	// position
			write_coord_f(vicOrigin[1]+(y*j))
			write_coord_f(vicOrigin[2]+21.0)
			write_short(blood2)	// sprite1 index
			write_short(blood1)	// sprite2 index
			write_byte(248) 			// color RED = 248 YELLOW = 196
			write_byte(scale) 			// scale
			message_end()
		}
	}
}

stock glow(id, r, g, b,a, on) {
	if(on) {
		set_rendering(id, kRenderFxGlowShell, r, g, b, kRenderTransAlpha, a)
	}
	else{
		set_rendering(id, kRenderFxNone, r, g, b,  kRenderTransAlpha, a)
	}
}

stock suck_in_sound(ent_id,make_sound){

	if(!is_valid_ent(ent_id)) return PLUGIN_CONTINUE
	
	new Float:fl_origin[3]
	Entvars_Get_Vector(ent_id, EV_VEC_origin, fl_origin)

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(14)
	write_coord(floatround(fl_origin[0]))
	write_coord(floatround(fl_origin[1]))
	write_coord(floatround(fl_origin[2]))
	write_byte (200)
	write_byte (40)
	write_byte (45)
	message_end()
	if(make_sound){
		emit_sound(ent_id, CHAN_WEAPON, SUCK_IN_SOUND_FILE_NAME, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(ent_id, CHAN_VOICE, SUCK_IN_SOUND_FILE_NAME, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	
	return PLUGIN_CONTINUE
}
stock aura(id,const color[4]={255,255,255,255},life=3,decay=1){

	new origin[3]

	get_user_origin(id, origin, 1)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(27)
	write_coord(origin[0])	//pos
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(15)
	write_byte(color[0])			// r, g, b
	write_byte(color[1])		// r, g, b
	write_byte(color[2])			// r, g, b
	write_byte(life)			// life
	write_byte(decay)			// decay
	message_end()

}

stock detect_user(id,enemy,Float:origin[3]={0.0,0.0,0.0}){


	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostagePos"), {0,0,0}, id)
	write_byte(1)
	write_byte(enemy)
	write_coord_f(origin[0])
	write_coord_f(origin[1])
	write_coord_f(origin[2])
	message_end()

	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostageK"), {0,0,0}, id)
	write_byte(enemy)
	message_end()


}