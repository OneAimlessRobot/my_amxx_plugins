#if defined sh_aux_funcs
  #endinput
#endif
#define sh_aux_funcs

#define RADIOACTIVE_TASK_ID 73223627
#define UNRADIOACTIVE_TASK_ID 732231123


#define FADE_OUT	(1<<1)
#define FADE_HOLD (1<<2)

#define crush_stunned "shmod/Teliko/chaff/chaff_blow.wav"

#define COLORS_NUM 8
//Colors To Pick From
#define CUSTOM		0
#define RED		1
#define GREEN		2
#define BLUE		3
#define LTBLUE		4
#define YELLOW		5
#define PURPLE		6
#define ORANGE		7

//Color definitions
new const LineColors[COLORS_NUM][3] = {
	{150, 150, 150},	//Custom
	{255, 0, 0},		//Red
	{0, 255, 0},		//Green
	{0, 0, 255},		//Blue
	{0, 255, 255},		//Light Blue
	{255, 255, 0},		//Yellow
	{255, 0, 255},		//Purple
	{255, 128, 0}		//Orange
}
new const radioactive_color[4]={0,255,255,255}

native explosion_player(hero_id,ent_id,Float:explosion_radius,Float:peak_power)
native explosion(hero_id,ent_id,Float:explosion_radius,Float:peak_power)
native track_user(hero_id,id,attacker,do_damage=0,damage=40,Float:period,Float:time)
native make_shockwave(point[3],Float:radius,const color[4])
native unradioactive_user(id)
native draw_bbox(id,killbeam)

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
