//TESS-One by Xel0z - Current Version 1.2 - Released at 03-10-2009

/*
Credits:
- To {HOJ} Batman for the Nightcrawler
(currently shadowcat) loop.
*/

/*
Changelog:
v1.0 - 03-10-2009:
- Initial Release.

v1.1 - 03-11-2009:
- Slight (very slight) code changes.

v1.2 - 08-14-2009:
- Slight change in tess_TakeDamage.
*/

/*
//TESS-One
tessone_level 5
tessone_absorbtime 8
tessone_cooldown 45
*/

#include "../my_include/superheromod.inc"

new g_HeroID
new const g_HeroName[] = "TESS-One"
new bool:g_HasTessOne[SH_MAXSLOTS+1]
new bool:g_IsImmune[SH_MAXSLOTS+1]
new g_TessTimer[SH_MAXSLOTS+1]
new g_TessCooldown, g_TessAbsorbTime

public plugin_init()
{
	register_plugin("SUPERHERO TESS-One", "1.2", "Xel0z")

	new tessLevel = register_cvar("tessone_level", "5")
	g_TessAbsorbTime = register_cvar("tessone_absorbtime", "8")
	g_TessCooldown = register_cvar("tessone_cooldown", "45")

	g_HeroID = sh_create_hero(g_HeroName, tessLevel)
	sh_set_hero_info(g_HeroID, "Absorbs Metal", "Become immune to bullets for X seconds")
	sh_set_hero_bind(g_HeroID)
	
	RegisterHam(Ham_TakeDamage, "player", "tess_TakeDamage")

	set_task(1.0, "tess_loop", _, _, _, "b")
}

public sh_hero_init(id, heroID, mode)
{
	if ( g_HeroID != heroID ) return

	switch(mode) {
		case SH_HERO_ADD: {
			g_HasTessOne[id] = true
			g_TessTimer[id] = -1
		}

		case SH_HERO_DROP: {
			g_HasTessOne[id] = false

			if ( g_TessTimer[id] >= 0 ) tess_endimmunity(id)
		}
	}
}

public sh_client_spawn(id)
{
	gPlayerInCooldown[id] = false
	g_TessTimer[id] = -1

	if ( g_HasTessOne[id] ) tess_endimmunity(id)
}

public sh_hero_key(id, heroID, key)
{
	if ( g_HeroID != heroID || sh_is_freezetime() || !is_user_alive(id) ) return

	if ( key == SH_KEYDOWN ) {
		if ( gPlayerInCooldown[id] || g_TessTimer[id] >= 0 ) {
			sh_sound_deny(id)
			return
		}

		g_TessTimer[id] = get_pcvar_num(g_TessAbsorbTime)
		g_IsImmune[id] = true

		sh_chat_message(id, g_HeroID, "Absorbing bullets for %d seconds", g_TessTimer[id])
	}
}

public tess_TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if ( damagebits & DMG_BULLET && g_HasTessOne[this] && g_IsImmune[this] && get_user_weapon(idattacker) != CSW_KNIFE ) {
		SetHamParamFloat(4, 0.0)
		return HAM_SUPERCEDE
	}
	
	return HAM_IGNORED
}

public tess_loop()
{
	static players[SH_MAXSLOTS], playerCount, player, i
	static Float:cooldown, immuneTime
	cooldown = get_pcvar_float(g_TessCooldown)
	get_players(players, playerCount, "ah")

	for ( i = 0; i < playerCount; i++ ) {
		player = players[i]

		if ( g_HasTessOne[player] ) {
			immuneTime = g_TessTimer[player]
			if ( immuneTime > 0 ) {
				g_TessTimer[player]--
			}else if ( immuneTime == 0 ) {
				if ( cooldown > 0.0 ) sh_set_cooldown(player, cooldown)

				g_TessTimer[player]--
				tess_endimmunity(player)
			}
		}
	}
}

tess_endimmunity(id)
{
	if ( !is_user_connected(id) ) return

	g_IsImmune[id] = false
	g_TessTimer[id] = -1
}

public sh_client_death(victim)
{
	gPlayerInCooldown[victim] = false

	g_TessTimer[victim]= -1

	if ( g_HasTessOne[victim] ) tess_endimmunity(victim)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1043\\ f0\\ fs16 \n\\ par }
*/
