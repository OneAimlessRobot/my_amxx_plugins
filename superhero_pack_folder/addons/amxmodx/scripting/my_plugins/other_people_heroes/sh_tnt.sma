/*shconfig.cfg Cvars:

//TNT
tnt_level 1
tnt_damage 30                //damage from explosion
tnt_velocity 200                //how strong explosion pushes you
tnt_mines 1                //how many mines you can drop
tnt_radius 100		//damage radius from mine explosion

*/



#include "../my_include/superheromod.inc"

new gHeroName[] = "TNT";
new gHeroID
new gMinesLeft[SH_MAXSLOTS+1];
new gPlanter[SH_MAXSLOTS+1];

new splode_spr;

public plugin_precache() {
	splode_spr = engfunc(EngFunc_PrecacheModel,"sprites/zerogxplode.spr");
}

public plugin_init() {
	register_plugin("SUPERHERO TNT", "1.0", "[x]Rol Sources");

	register_cvar("tnt_level", "1");
	register_cvar("tnt_damage", "30");
	register_cvar("tnt_velocity", "200");
	register_cvar("tnt_mines", "1");
	register_cvar("tnt_radius", "100");

	gHeroID=shCreateHero(gHeroName, "Sploding Mines", "Drop mines to explode those who walk by!", false, "tnt_level");

	register_forward(FM_Touch, "fw_entTouch");
}

//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, key)
{
if ( gHeroID != heroID ||!sh_user_has_hero(id,gHeroID) ) return

switch(key)
{
	case SH_KEYDOWN: {
		tnt_kd(id)
	}
}
}
public tnt_kd(id) {
	
	if (!is_user_alive(id) || !sh_user_has_hero(id,gHeroID)) return;
	if(gMinesLeft[id] <= 0) { client_print(id, print_chat, "[SH](TNT) No Mines Left!!"); return; }
	
	gMinesLeft[id]--
	gPlanter[id] = id;
	
	spawn_mine(id);
}

public spawn_mine(id) {
	/*FAKEMETA: */
	new mine = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target")); //create mine ent
	
	if(!mine) {
		client_print(id, print_chat, "[SH](TNT) Warning: Mine Creation Failed, try again.");
		return;
	}
	
	new Float:origin[3];
	pev(id, pev_origin, origin); //get player origin
	origin[2] = 0.0; //set on ground not in air
	
	engfunc(EngFunc_SetOrigin, mine, origin); //set origin of mine
	engfunc(EngFunc_SetSize, mine, Float:{0.0,0.0,0.0}, Float:{9.0,9.0,9.0}); //set size of mine
	
	set_pev(mine, pev_classname, "tnt_mine"); //set classname
	engfunc(EngFunc_SetModel, mine, "models/w_c4.mdl"); //set model

	
}

public fw_entTouch(ptr, ptd) {
	/* FAKEMETA */
	
	if(ptr == 0 || ptd == 0) return;

	if(ptr == gPlanter[ptr] || cs_get_user_team(ptr) == cs_get_user_team(gPlanter[ptr])) return;
	
	new class[32]
	pev(ptd, pev_classname, class, 31);
	
	if(!equal(class, "tnt_mine")) return;
	
	splode_effects(ptd);
	new m_origin[3], i_origin[3];
	
	get_user_origin(ptd, m_origin);
	
	for(new i = 1; i < sh_maxplayers()+1; i++) {
		get_user_origin(i, i_origin);
		if(get_distance(m_origin, i_origin) <= get_cvar_num("tnt_radius")) {
			new Float:velocity[3];	
			pev(i, pev_velocity, velocity);
	
			velocity[2] += get_cvar_num("tnt_velocity");
			set_pev(i, pev_velocity, velocity);
	
			new health = pev(i, pev_health);

			set_pev(i, pev_health, health - get_cvar_num("tnt_damage"));
	
			if(pev(i, pev_health) <= 0) {
				user_kill(i);
	
				cs_set_user_deaths(ptr, cs_get_user_deaths(ptr)-1);
	
				message_begin(MSG_ALL, get_user_msgid("DeathMsg"), {0,0,0}, 0);
				write_byte(0);
				write_byte(i);
				write_byte(0);
				write_string("world");
				message_end();
			}
		}
	}
}

public splode_effects(id) {
	new origin[3];
	get_user_origin(id, origin);
	
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(3);       // TE_EXPLOSION
	write_coord(origin[0]);   // end point of beam
	write_coord(origin[1]);
	write_coord(origin[2]);
	write_short(splode_spr);    // blast sprite
	write_byte(10);            // scale in 0.1u
	write_byte(30);            // frame rate
	write_byte(8);           // TE_EXPLFLAG_NOPARTICLES
	message_end();            
	
	return;
}

public sh_client_spawn(id) {
	if(!is_user_alive(id) || !sh_user_has_hero(id,gHeroID)) return;
	
	gMinesLeft[id] = get_cvar_num("tnt_mines");
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1252\\ deff0\\ deflang1033{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
