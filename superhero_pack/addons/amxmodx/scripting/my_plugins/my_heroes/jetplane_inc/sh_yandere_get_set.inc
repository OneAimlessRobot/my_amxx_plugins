#if defined sh_get_set_yandere
  #endinput
#endif
#define sh_get_set_yandere




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

new const love_color[4]={250, 92, 163,50}
new const red_color[4]={255, 0, 0, 50}
new const heal_color[4]={250,250,210, 100}

new const yandere_shotgun_sounds[3][]={"weapons/yandere_shotgun/balrog11_draw.wav",
"weapons/yandere_shotgun/xm1014-1.wav",
"weapons/yandere_shotgun/xm1014-insert.wav"}
new const yandere_sentences[5][]={
	"Hiss.... Hiss.... Hiss.... Hiss.....",
	"Where are you... where... are you...",
	"Come out to plaaaaayyyy... There is NO WAY IM LETTING ANY OF YOU GO NOW!!!!!",
	"I hear their voices... I hear them... Then want... they want... red and black",
	"I want... all your blood. All of it.... and water the graves of my family with it."
}

native yandere_get_is_super(id)
native yandere_get_has_yandere(id)
native yandere_get_hero_id()
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
