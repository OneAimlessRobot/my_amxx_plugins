#include "../my_include/superheromod.inc"
#include "../task_allocator_inc/task_allocator_aux_stuff.inc"
#include <fakemeta_util>
#include "sh_aux_stuff/sh_aux_consts.inc"
#include "sh_aux_stuff/sh_aux_fx_natives_const_pt1.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt1.inc"
#include "sh_aux_stuff/sh_aux_funcs_misc.inc"
#include "sh_aux_stuff/sh_aux_quick_checks.inc"
#include "sh_aux_stuff/sh_aux_math_funcs_pt1.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include <fakemeta_util>



#define PLUGIN "Superhero fx natives pt1"
#define VERSION "1.0.0"
#include "../my_include/my_author_header.inc"

new const damage_icon_strings_arr[_:DMG_ICON_MAX][]={
	"dmg_poison",
	"dmg_rad",
	"dmg_shock",
	"dmg_gas",
	"dmg_heat",
	"item_healthkit",
	"suit_full",
	"item_longjump"
}

stock REMOVE_DAMAGE_ICON_TASKID

public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	g_msgFade = get_user_msgid("ScreenFade");
	gmsgIcon = get_user_msgid("StatusIcon")
	prepare_shero_aux_lib_pt1()
	REMOVE_DAMAGE_ICON_TASKID=allocate_typed_task_id(player_task)

}
public plugin_precache(){

	precache_native_fx_pt1()

}
public plugin_natives(){


	register_native("trail_custom","_trail_custom",0);
	register_native("trail","_trail",0);
	register_native("make_sparks","_make_sparks",0)
	register_native("random_fire","_random_fire",0);
	register_native("make_fire","_make_fire",0);
	register_native("make_shockwave","_make_shockwave",0);
	register_native("heal_stream","_heal_stream",0);
	register_native("unfade_screen_user","_unfade_screen_user",0);
	register_native("fade_screen_user","_fade_screen_user",0);
	register_native("laser_line","_laser_line",0);
	register_native("draw_bbox","_draw_bbox",0);
	register_native("gun_shot_decal","_gun_shot_decal",0);
	register_native("explode_fx","_explode_fx",0);
	register_native("directed_spark","_directed_spark",0);
	register_native("blood_spray","_blood_spray",0);
	register_native("glow","_glow",0);
	register_native("suck_in_sound","_suck_in_sound",0);
	register_native("aura","_aura",0);
	register_native("detect_user","_detect_user",0);
	register_native("create_fired_shot_disk","_create_fired_shot_disk",0);
	register_native("draw_aim_vector","_draw_aim_vector",0);
	register_native("precache_native_fx_pt1","_precache_native_fx_pt1",0)
	register_native("prepare_shero_aux_lib_pt1","_prepare_shero_aux_lib_pt1",0);
	register_native("set_render_with_color_const","_set_render_with_color_const",0)
	register_native("tank_impact_shot_fx","_tank_impact_shot_fx",0)
	register_native("set_damage_icon","_set_damage_icon",0)
	register_native("unset_damage_icon","_unset_damage_icon",0)

}

public _prepare_shero_aux_lib_pt1(iPlugins, iParams){
	
	xs_seed(get_systime(0));
	server_print("Shero lib pt1 innited!^n")
}
public _precache_native_fx_pt1(iPlugin,iParams){


	m_trail = precache_model("sprites/smoke.spr")
	white = precache_model("sprites/shockwave.spr")
	blood1 = precache_model("sprites/blood.spr");
	blood2 = precache_model("sprites/bloodspray.spr");
	gSpriteSmoke = precache_model("sprites/steam1.spr")
	gSpriteBurning = precache_model("sprites/xfire.spr")
	g_iSmokeSprite[0] = precache_model("sprites/black_smoke3.spr");
	g_iSmokeSprite[1] = precache_model("sprites/steam1.spr");
	smoke = precache_model("sprites/steam1.spr")
	g_iFireSprite = precache_model("sprites/flame.spr");
	gSpriteLaser = precache_model("sprites/laserbeam.spr")
	precached_explosion_sprite = precache_model("sprites/shmod/zerogxplode2.spr")

	engfunc(EngFunc_PrecacheSound, LASER_LINE_DEFAULT_SOUND)
	engfunc(EngFunc_PrecacheSound, crush_stunned)
	engfunc(EngFunc_PrecacheSound, SUCK_IN_SOUND_FILE_NAME)
	engfunc(EngFunc_PrecacheSound, EXPLOSION_TANK_SHOT_SOUND)

}
public _trail_custom(iPlugins, iParams){

		new ent_id=get_param(1)

		if(!is_valid_ent(ent_id)) return 
		new color[3]

		get_array(2,color,3)

		new life = get_param(3)
		new width = get_param(4)
		new alpha= get_param(5)

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
		write_byte(alpha) // brightness
		message_end()
}
public _trail(iPlugins, iParams){

		new ent_id=get_param(1)

		if(!is_valid_ent(ent_id)) return 
		new color_const= get_param(2)

		new life = get_param(3)
		new width = get_param(4)
		new alpha = get_param(5)

		message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
		write_byte( TE_BEAMFOLLOW )
		write_short(ent_id) // entity
		write_short(m_trail)  // model
		write_byte( life )       // life
		write_byte( width )        // width
		write_byte(LineColors[color_const][0])			// r, g, b
		write_byte(LineColors[color_const][1])		// r, g, b
		write_byte(LineColors[color_const][2])			// r, g, b
		write_byte(alpha) // brightness
		message_end()
}
public _make_sparks(iPlugins, iParams){

	new Float:the_pos[3]

	get_array_f(1,the_pos,3)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_SPARKS);
	engfunc(EngFunc_WriteCoord, the_pos[0])
	engfunc(EngFunc_WriteCoord, the_pos[1])
	engfunc(EngFunc_WriteCoord, the_pos[2])
	message_end();	
	
}

//(Origin[3], ent, Float:radius)
public _random_fire(iPlugins, iParams){
	
	new Origin[3]
	
	get_array(1,Origin,3)
	
	new ent = get_param(2)

	if(!is_valid_ent(ent)) return 
	new Float:radius = get_param_f(3)

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
public _make_fire(iPlugins, iParams){

	new id= get_param(1)
	new Float:rad= get_param_f(2)

	new radius=floatround(rad)
	new rx, ry, rz, Float:forigin[3]
	rx = random_num(-radius, radius)
	ry = random_num(-radius, radius)
	rz = random_num(-radius, radius)

	if(!is_valid_ent(id)) return 
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
public _make_shockwave(iPlugins, iParams){

	new point[3],
	Float:radius=get_param_f(2),
	color[3],
	shockwave_frame_rate=get_param(4),
	shockwave_life=get_param(5),
	shockwave_line_width=get_param(6),
	shockwave_amplitude=get_param(7),
	alpha=get_param(8)

	get_array(1,point,3)
	get_array(3,color,3)


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
	write_byte(alpha )
	write_byte(0)
	message_end()

}

public _heal_stream(iPlugins, iParams){

	new id=get_param(1)

	new x=get_param(2)
	new color_index=get_param(3)

	new alpha= get_param(4)
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
	write_byte(alpha)				// brightness
	write_byte( 8 )				// scroll speed
	message_end()
	
}

public _fade_screen_user(iPlugins, iParams){

	new id=get_param(1)

	message_begin(MSG_ONE, g_msgFade, {0,0,0}, id); // use the magic #1 for "one client" 
	write_short(0); // fade lasts this long duration 
	write_short(0); // fade lasts this long hold time 
	write_short(FADE_HOLD); // fade type 
	write_byte(0); // fade red 
	write_byte(0); // fade green 
	write_byte(0); // fade blue  
	write_byte(255); // fade alpha  
	message_end(); 

}
public _unfade_screen_user(iPlugins, iParams){

	new id=get_param(1)

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
//(ent_id,Float:Pos[3], Float:vEnd[3],killbeam,color_constants[3]={RED,BLUE,CUSTOM},bool:for_one=false);

//----------------------------------------------------------------------------------------------
public _laser_line(iPlugins, iParams){

	new ent_id=get_param(1),
		Float:Pos[3],
		Float:vEnd[3],
		killbeam=get_param(4),
		color_constants[3],
		for_one=get_param(6),
		make_sound=get_param(7),
		sound_sample[128]
		
	if(!is_valid_ent(ent_id)) return
	
	get_array_f(2,Pos,3)
	get_array_f(3,vEnd,3)
	get_array(5,color_constants,3)
	get_string(8,sound_sample,127)

	static  colors[3]
	if(client_hittable(pev(ent_id, pev_owner))){
	
		switch ( cs_get_user_team(pev(ent_id, pev_owner)) )
		{
			case CS_TEAM_T: colors = LineColors[color_constants[0]]
				case CS_TEAM_CT: colors = LineColors[color_constants[1]]
					default: colors = LineColors[color_constants[2]]
		}
	}
	else if(client_hittable(ent_id)){
		switch ( cs_get_user_team(ent_id) )
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
		//Kill the Beams
		message_begin(for_one?MSG_ONE_UNRELIABLE:MSG_BROADCAST, SVC_TEMPENTITY,_,for_one?ent_id:0) //message begin
		write_byte(TE_KILLBEAM)
		write_short(ent_id) // entity
		message_end()
	}
	if(make_sound){
		emit_sound(ent_id,CHAN_ITEM, sound_sample, 1.0, ATTN_NORM, 0, PITCH_NORM)
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
//(ent_id,killbeam)
public _draw_bbox(iPlugins, iParams){

	new ent_id=get_param(1),
		killbeam=get_param(2)
	if(!is_valid_ent(ent_id)) return
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


public _gun_shot_decal(iPlugins, iParams){

	new Float:vec[3]

	get_array_f(1,vec,3)

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
public _explode_fx(iPlugins, iParams){

	new vec1[3],
		radius=get_param(2)
	
	get_array(1,vec1,3)

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
//(init_id, end_id,girth=10,veins=10,glowing=255,ramming_pace=8,color_constant=GREEN)
public _directed_spark(iPlugins, iParams){

	new init_id=get_param(1),
		end_id=get_param(2),
		girth=get_param(3),
		veins=get_param(4),
		glowing=get_param(5),
		ramming_pace=get_param(6),
		color_constant=get_param(7)

	if(!is_valid_ent(init_id)||!is_valid_ent(end_id)) return 
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
public _tank_impact_shot_fx(iPlugin,iParms){

		new ent=get_param(1)
		if(!is_valid_ent(ent)) return 
		
		new Float:origin[3]

		get_array_f(2,origin,3)
		new radius=get_param(3)
		


		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_SPRITE)
		write_coord_f(origin[0])
		write_coord_f(origin[1])
		write_coord_f(origin[2] + min(1,radius))
		write_short(precached_explosion_sprite)
		write_byte(radius)
		write_byte(200)
		message_end()
		
		emit_sound(ent, CHAN_WEAPON, EXPLOSION_TANK_SHOT_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

		new decal_id
		if ( radius <= 18 ) {
			//radius ~< 216
			decal_id = g_burnDecal[random_num(0,2)]
		}
		else {
			decal_id = g_burnDecalBig[random_num(0,2)]
		}

		// Create the burn decal
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_GUNSHOTDECAL)		//TE_GUNSHOTDECAL
		write_coord_f(origin[0])
		write_coord_f(origin[1])
		write_coord_f(origin[2])
		write_short(0)			//?
		write_byte(decal_id)	//decal
		message_end()

}
public _create_fired_shot_disk(iPlugin,iParms){
	new Float:Pos[3]

	get_array_f(1,Pos,3)
	new ent=get_param(2)
	if(!is_valid_ent(ent)) return 
	new torus_or_disk=get_param(3)

	torus_or_disk=clamp(torus_or_disk,0,1)

	new Float:vOrigin[3]
	pev(ent, pev_origin, vOrigin)
	
	new Float:vTraceDirection[3], Float:vTraceEnd[3],Float:vNormal[3]
	
	velocity_by_aim(ent, 64, vTraceDirection)
	vTraceEnd[0] = vTraceDirection[0] + vOrigin[0]
	vTraceEnd[1] = vTraceDirection[1] + vOrigin[1]
	vTraceEnd[2] = vTraceDirection[2] + vOrigin[2]
	
	new tr = 0
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, 0, ent, tr)
	get_tr2(tr, TR_vecPlaneNormal, vNormal)
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(torus_or_disk?TE_BEAMTORUS:TE_BEAMDISK)
	write_coord_f(vOrigin[0])
	write_coord_f(vOrigin[1])
	write_coord_f(vOrigin[2])
	switch(torus_or_disk){
		case 0:{
			write_coord_f(vNormal[0])
			write_coord_f(vNormal[1])
			write_coord_f(vNormal[2])
		}
		case 1:{

			write_coord_f(vTraceDirection[0])
			write_coord_f(vTraceDirection[1])
			write_coord_f(vTraceDirection[2])

		}
	}
	write_short(white)
	write_byte(1)
	write_byte(5)
	write_byte(5)
	write_byte(14)
	write_byte(1)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(1)
	message_end()

}

//----------------------------------------------------------------------------------------------
public _blood_spray(iPlugins, iParams){


	new Float:vicOrigin[3]

	get_array_f(1,vicOrigin,3)

	new scale=get_param(2)

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

public _glow(iPlugins, iParams){

	new id=get_param(1),
		r=get_param(2),
		g=get_param(3),
		b=get_param(4),
		a=get_param(5),
		on=get_param(6)

	if(on) {
		set_rendering(id, kRenderFxGlowShell, r, g, b, kRenderTransAlpha, a)
	}
	else{
		set_rendering(id, kRenderFxNone, r, g, b,  kRenderTransAlpha, a)
	}
}

public _suck_in_sound(iPlugins, iParams){
	new ent_id=get_param(1),
		make_sound=get_param(2)

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

public _aura(iPlugins, iParams){
	new id= get_param(1);

	if ( !is_user_connected(id) ) return
	new color[3]
	get_array(2,color,3)
	new life=get_param(3)
	new decay= get_param(4)

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

public _set_damage_icon(iPlugins, iParams){

	new id= get_param(1)
	if ( !is_user_connected(id) ) return
	new hide_show_or_flash=get_param(2)

	new the_icon_type_to_show=get_param(3)
	new color[3]

	get_array(4,color,3)


// Poison HUD Icon

	message_begin(MSG_ONE, gmsgIcon, {0,0,0}, id)
	write_byte(hide_show_or_flash)				// status (0=hide, 1=show, 2=flash)
	write_string(damage_icon_strings_arr[the_icon_type_to_show])	// sprite name
	write_byte(color[0])		// red
	write_byte(color[1])	// green
	write_byte(color[2])		// blue
	message_end()
}

/*

native detect_user(id,enemy,Float:origin[3]={0.0,0.0,0.0})

 */
public _detect_user(iPlugins, iParams){

	new id= get_param(1)
	new enemy= get_param(2)


	if(!is_valid_ent(id)||!is_valid_ent(enemy)) return 

	new Float:origin[3]
	get_array_f(3,origin,3)

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
public _draw_aim_vector(iPlugin,iParams){
	new id=get_param(1)

	if(!is_valid_ent(id)) return 
	
	new color_vector_indices[3]
	get_array(2,color_vector_indices,3)

	new Float:fvec1[3], Float:fvec2[3],vec1[3],vec2[3]
	get_user_origin(id, vec1, 1) // origin; your camera point.
	get_user_origin(id, vec2, 3) // termina; where your bullet goes (4 is cs-only)
	IVecFVec(vec1,fvec1)
	IVecFVec(vec2,fvec2)
	laser_line(id,fvec1, fvec2,true,color_vector_indices,false)

}
public _set_render_with_color_const(iPlugins,iParams){
	new id=get_param(1)

	if(!is_valid_ent(id)) return 


	new the_color_const=get_param(2)
	new glow_on_user=get_param(3)
	new alpha=get_param(4)
	new the_hud_alpha=get_param(5)
	new glow_user_hud=get_param(6)
	new is_sleep=get_param(7)
	if(is_sleep||(glow_user_hud&&!sh_get_user_is_asleep(id))){
			sh_screen_fade(id, 0.1, 0.9,
					LineColors[the_color_const][0],
					LineColors[the_color_const][1],
					LineColors[the_color_const][2],
					(the_hud_alpha<0)?50:the_hud_alpha)
	}
	if(glow_on_user){
		sh_set_rendering(id,
						LineColors[the_color_const][0],
						LineColors[the_color_const][1],
						LineColors[the_color_const][2],
						(alpha<0)?255:alpha,
						kRenderFxGlowShell,
						kRenderTransAlpha)
		
		aura(id,LineColors[the_color_const])
	}
}
public _unset_damage_icon(iPlugins,iParams){

	new id=get_param(1)
	if(!is_user_connected(id)) return
	new the_icon_to_remove=get_param(2)

	new Float:delay=get_param_f(3)
	new parm[1]
	parm[0]=the_icon_to_remove
	set_task(delay,"remove_damage_icon_task",id+REMOVE_DAMAGE_ICON_TASKID,parm,1)

}
public remove_damage_icon_task(array[],id){

	id-=REMOVE_DAMAGE_ICON_TASKID
	if(!is_user_connected(id)) return
	set_damage_icon(id,_,array[0])


}