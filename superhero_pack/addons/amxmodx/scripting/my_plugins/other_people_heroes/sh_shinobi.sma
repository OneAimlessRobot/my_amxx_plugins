#include <amxmodx>
#include <engine>
#include "../my_include/superheromod.inc"

new const SOUND_SMOKESCREEN[]	= "weapons/sg_explode.wav"
new const MODEL_SHURIKEN[]	= "models/rshell_big.mdl"

new g_heroID
new bool:g_hasShinobi[SH_MAXSLOTS+1]
new g_ShinobiPowers[SH_MAXSLOTS+1]
new g_JumpButton[SH_MAXSLOTS+1]
new g_TouchingIsGood[SH_MAXSLOTS+1]
new Float:g_fLastOrigin[SH_MAXSLOTS+1][3]
new g_JumpPower[SH_MAXSLOTS+1]
new g_fallProtection[SH_MAXSLOTS+1]
new bool:g_Jumped[SH_MAXSLOTS+1]
new Float:g_fShurikenDelay[SH_MAXSLOTS+1]

new cvar_smoke_delay, cvar_wall_power, cvar_jump_power
new cvar_max_stealth, cvar_level, cvar_shur_speed
new cvar_shur_damage, cvar_shur_num, cvar_shur_delay

new g_blood, g_bloodspray, sprite_beam


#define PLUGIN_NAME 	"SUPERHERO Shinobi"
#define PLUGIN_AUTHOR 	"Cheap_Suit"
#define PLUGIN_VERSION	"1.0"

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	cvar_level		= register_cvar("shinobi_level",	"9")
	cvar_smoke_delay	= register_cvar("shinobi_cooldown", 	"18.0")
	cvar_wall_power		= register_cvar("shinobi_walljump", 	"900")
	cvar_jump_power		= register_cvar("shinobi_longjump", 	"550")
	cvar_max_stealth	= register_cvar("shinobi_stealth", 	"18.8")
	cvar_shur_speed		= register_cvar("shinobi_shur_speed", 	"1200")
	cvar_shur_damage	= register_cvar("shinobi_shur_dmg", 	"7")
	cvar_shur_num		= register_cvar("shinobi_shur_pack", 	"17")
	cvar_shur_delay		= register_cvar("shinobi_shur_delay", 	"10.0")

	g_heroID = sh_create_hero("Shinobi", cvar_level)
	sh_set_hero_info(g_heroID, "Shinobi Powers", "To enter shinobi mode you must use your knife")
	sh_set_hero_bind(g_heroID)

	register_touch("player", 	"worldspawn", 		"touch_World")
	register_touch("player", 	"func_wall", 		"touch_World")
	register_touch("player", 	"func_breakable", 	"touch_World")
	register_touch("shuriken", 	"player", 		"touch_Shuriken")
	register_think("shuriken", 	"think_Shuriken")

	register_event("Damage", "Event_Damage", "be", "2>0")
}

public plugin_precache()
{
	precache_sound(SOUND_SMOKESCREEN)
	precache_model(MODEL_SHURIKEN)

	precache_sound("player/pl_shell1.wav")
	precache_sound("player/pl_shell2.wav")
	precache_sound("player/pl_shell3.wav")

	precache_sound("player/headshot2.wav")
	precache_sound("player/headshot3.wav")

	sprite_beam 	= precache_model("sprites/laserbeam.spr")
	g_blood 	= precache_model("sprites/blood.spr")
	g_bloodspray 	= precache_model("sprites/bloodspray.spr")
}

public sh_hero_init(id, heroID, mode)
{
	if(g_heroID != heroID)
		return

	switch(mode)
	{
		case SH_HERO_ADD: 	g_hasShinobi[id] = true
		case SH_HERO_DROP:
		{
			g_hasShinobi[id] = false
			entity_set_int(id, EV_INT_renderfx, kRenderFxNone)
			entity_set_int(id, EV_INT_rendermode, kRenderNormal)
		}
	}
}

public sh_hero_key(id, heroID, key)
{
	if(g_heroID != heroID || key != SH_KEYDOWN || !is_user_alive(id)
	|| !g_hasShinobi[id] || !g_ShinobiPowers[id])
		return PLUGIN_CONTINUE

	new Float:shinobiCooldown = get_pcvar_float(cvar_smoke_delay)
	if(gPlayerInCooldown[id])
	{
		sh_sound_deny(id)
		sh_chat_message(id, g_heroID, "You must wait %.1f seconds after a Smoke Screen Ninjutsu", shinobiCooldown)
		return PLUGIN_CONTINUE
	}

	new ent = create_entity("info_target")
	if(is_valid_ent(ent))
	{
		if ( shinobiCooldown > 0.0 ) sh_set_cooldown(id, shinobiCooldown)

		new Float:fOrigin[3]
		entity_get_vector(id, EV_VEC_origin, fOrigin)
		fOrigin[2] -= 50
		entity_set_vector(ent, EV_VEC_origin, fOrigin)

		playback_event(0, id, 26, 0.0, fOrigin, Float:{0.0, 0.0, 0.0}, 0.0, 0.0, 0, 1, 0, 0)
		emit_sound(ent, CHAN_STATIC, SOUND_SMOKESCREEN, VOL_NORM, ATTN_NORM, 0, PITCH_HIGH)
		remove_entity(ent)
	}
	return PLUGIN_CONTINUE
}

public sh_client_spawn(id)
{
	g_JumpPower[id] = 0
	g_TouchingIsGood[id] = 0
	entity_set_float(id, EV_FL_gravity, 1.0)
	g_fShurikenDelay[id] -= get_gametime()

	new shurikens = -1
	while((shurikens = find_ent_by_class(shurikens, "shuriken")))
		remove_entity(shurikens)

	gPlayerInCooldown[id] = false
}

public Event_Damage(id)
{
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE

	new attakerWeapon, attacker = get_user_attacker(id, attakerWeapon)
	if(!is_user_alive(attacker) || !g_hasShinobi[attacker])
		return PLUGIN_CONTINUE

	if(attakerWeapon != CSW_KNIFE)
		return PLUGIN_CONTINUE

	new Float:randomFloat[3]
	for(new i = 0; i < 3; i++)
	{
		new damage = read_data(2)
		randomFloat[i] = random_float((float(damage) * -1.0), float(damage))
	}
	entity_set_vector(id, EV_VEC_punchangle, randomFloat)

	return PLUGIN_CONTINUE
}

public client_PreThink(id)
{
	if(!is_user_alive(id) || !g_ShinobiPowers[id])
		return PLUGIN_CONTINUE

	if(entity_get_float(id, EV_FL_flFallVelocity) >= 350.0)
		g_fallProtection[id] = 1

	if((get_entity_flags(id) & FL_ONGROUND))
	{
		g_JumpPower[id] = 0
		g_TouchingIsGood[id] = 0
		entity_set_float(id, EV_FL_gravity, 1.0)
	}

	new Float:fCurOrigin[3]
	entity_get_vector(id, EV_VEC_origin, fCurOrigin)
	if(get_distance_f(fCurOrigin, g_fLastOrigin[id]) > 10.0)
	{
		g_JumpPower[id] = 0
		g_TouchingIsGood[id] = 0
		entity_set_float(id, EV_FL_gravity, 1.0)
	}

	new nButton = get_user_button(id)
	new oButton = get_user_oldbutton(id)

	if(nButton & IN_USE && !(oButton & IN_USE))
	{
		if((g_fShurikenDelay[id] + get_pcvar_float(cvar_shur_delay)) < get_gametime())
		{
			for(new i = 0; i < get_pcvar_num(cvar_shur_num); ++i)
				create_shuriken(id)

			g_fShurikenDelay[id] = get_gametime()
		} else
			sh_chat_message(id, g_heroID, "Please wait %.1f second(s)", (g_fShurikenDelay[id] + get_pcvar_float(cvar_shur_delay)) - get_gametime())
	}

	if(nButton & IN_JUMP && !(nButton & IN_DUCK))
	{
		g_JumpButton[id] = 1

		if(g_TouchingIsGood[id])
		{
			new Float:fVelocity[3]
			velocity_by_aim(id, 0, fVelocity)
			entity_set_vector(id, EV_VEC_velocity, fVelocity)

			new maxJumpVel = get_pcvar_num(cvar_wall_power)
			if(g_JumpPower[id] < maxJumpVel)
				g_JumpPower[id] += 20
			else
				g_JumpPower[id] = maxJumpVel
		}
	}
	else if(nButton & IN_JUMP && nButton & IN_DUCK && nButton & IN_FORWARD)
	{
		if(g_Jumped[id])
			return PLUGIN_CONTINUE

		new Flags = entity_get_int(id, EV_INT_flags)
		if(Flags | FL_WATERJUMP && entity_get_int(id, EV_INT_waterlevel) < 2 && Flags & FL_ONGROUND)
		{
			new Float:fVelocity[3]
			entity_get_vector(id, EV_VEC_velocity, fVelocity)

			if(fVelocity[0] == 0.0 || fVelocity[1] == 0.0)
					return PLUGIN_CONTINUE

			new jumpPower = get_pcvar_num(cvar_jump_power)

			new Float:fAimVelocity[3]
			velocity_by_aim(id, jumpPower, fAimVelocity)

			if(fAimVelocity[2] > 300.0)
			{
				fVelocity[0] = fAimVelocity[0] * 0.5
				fVelocity[1] = fAimVelocity[1] * 0.5
				fVelocity[2] = fAimVelocity[2]
			}
			else
			{
				fVelocity[0] = fAimVelocity[0]
				fVelocity[1] = fAimVelocity[1]
				fVelocity[2] = 310.0
			}
			entity_set_vector(id, EV_VEC_velocity, fVelocity)
			g_Jumped[id] = true
		}
	}
	else if(nButton & IN_JUMP && nButton & IN_DUCK && nButton & IN_BACK)
	{
		if(g_Jumped[id])
			return PLUGIN_CONTINUE

		new Flags = entity_get_int(id, EV_INT_flags)
		if(Flags | FL_WATERJUMP && entity_get_int(id, EV_INT_waterlevel) < 2 && Flags & FL_ONGROUND)
		{
			new Float:fVelocity[3]
			entity_get_vector(id, EV_VEC_velocity, fVelocity)

			if(fVelocity[0] == 0.0 || fVelocity[1] == 0.0)
					return PLUGIN_CONTINUE

			new jumpPower = get_pcvar_num(cvar_jump_power)

			new Float:fAimVelocity[3]
			velocity_by_aim(id, jumpPower, fAimVelocity)

			fVelocity[0] = fAimVelocity[0] * -1.0
			fVelocity[1] = fAimVelocity[1] * -1.0
			fVelocity[2] = 310.0

			entity_set_vector(id, EV_VEC_velocity, fVelocity)
			g_Jumped[id] = true
		}
	}
	else if(oButton & IN_JUMP)
	{
		g_JumpButton[id] = 0
		g_Jumped[id] = false

		if(g_TouchingIsGood[id])
		{
			new Float:fVelocity[3]
			velocity_by_aim(id, g_JumpPower[id], fVelocity)
			entity_set_vector(id, EV_VEC_velocity, fVelocity)

			g_TouchingIsGood[id] = 0
		}
		g_JumpPower[id] = 0
	}
	else if(oButton & IN_DUCK)
		g_Jumped[id] = false

	return PLUGIN_CONTINUE
}

public client_PostThink(id)
{
	if(!is_user_alive(id) || !g_hasShinobi[id])
		return PLUGIN_CONTINUE

	new tmp, weapon = get_user_weapon(id, tmp, tmp)
	switch(weapon)
	{
		case CSW_KNIFE: g_ShinobiPowers[id] = 1
		default:	g_ShinobiPowers[id] = 0
	}

	if(!g_ShinobiPowers[id])
	{
		g_JumpPower[id] = 0
		g_TouchingIsGood[id] = 0
		g_fallProtection[id] = 0

		entity_set_float(id, EV_FL_gravity, 1.0)
		entity_set_int(id, EV_INT_renderfx, kRenderFxNone)
		entity_set_int(id, EV_INT_rendermode, kRenderNormal)
	}
	else
	{
		if(g_fallProtection[id])
			entity_set_int(id, EV_INT_watertype, -3)

		if(get_speed(id) < 280.0)
		{
			new Float:fValue = float(get_speed(id))
			new Float:fMaxValue = get_pcvar_float(cvar_max_stealth)
			if(fValue < fMaxValue) fValue = fMaxValue
			entity_set_int(id, EV_INT_rendermode, kRenderFxNone)
			entity_set_float(id, EV_FL_renderamt, fValue)
			entity_set_int(id, EV_INT_rendermode, kRenderTransTexture)
		}
		else
		{
			entity_set_int(id, EV_INT_renderfx, kRenderFxNone)
			entity_set_int(id, EV_INT_rendermode, kRenderNormal)
		}
	}
	return PLUGIN_CONTINUE
}

public touch_World(id, world)
{
	if(!is_user_alive(id) || !g_ShinobiPowers[id])
		return PLUGIN_CONTINUE

	if(g_JumpButton[id] && !(get_entity_flags(id) & FL_ONGROUND))
	{
		g_TouchingIsGood[id] = 1
		entity_set_float(id, EV_FL_gravity, 0.001)
		entity_get_vector(id, EV_VEC_origin, g_fLastOrigin[id])
	}
	return PLUGIN_CONTINUE
}

public think_Shuriken(ent) if(is_valid_ent(ent))
{
	if((get_entity_flags(ent) & FL_ONGROUND))
		remove_entity(ent)
	else
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.01)
}

public touch_Shuriken(ent, id)
{
	if(!is_valid_ent(ent) || !is_user_alive(id))
		return PLUGIN_CONTINUE

	new iOrigin[3]
	get_user_origin(id, iOrigin)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	write_coord(iOrigin[0])
	write_coord(iOrigin[1])
	write_coord(iOrigin[2])
	write_short(g_bloodspray)
	write_short(g_blood)
	write_byte(70)
	write_byte(2)
	message_end()

	new SOUND_HIT[21]
	format(SOUND_HIT, 20, "player/headshot%d.wav", random_num(2, 3))
	emit_sound(ent, CHAN_BODY, SOUND_HIT, 0.5, ATTN_NORM, 0, PITCH_NORM)

	new attacker = entity_get_edict(ent, EV_ENT_owner)
	if(get_user_team(attacker) != get_user_team(id))
		sh_extra_damage(id, attacker, get_pcvar_num(cvar_shur_damage), "shuriken", 0)
	remove_entity(ent)

	return PLUGIN_CONTINUE
}

public create_shuriken(id)
{
	new ent = create_entity("info_target")
	if(is_valid_ent(ent))
	{
		entity_set_string(ent, EV_SZ_classname, "shuriken")
		entity_set_model(ent, MODEL_SHURIKEN)
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS)
		entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER)
		entity_set_edict(ent, EV_ENT_owner, id)

		new Float:fEntOrigin[3], Float:fEntVelocity[3]
		entity_get_vector(id, EV_VEC_origin, fEntOrigin)
		velocity_by_aim(id, 17, fEntVelocity)

		fEntOrigin[0] += fEntVelocity[0]
		fEntOrigin[1] += fEntVelocity[1]

		entity_set_vector(ent, EV_VEC_origin, fEntOrigin)

		velocity_by_aim(id, get_pcvar_num(cvar_shur_speed), fEntVelocity)

		fEntVelocity[0] += random_num(-150, 150)
		fEntVelocity[1] += random_num(-150, 150)
		fEntVelocity[2] += random_num(-150, 150)

		entity_set_vector(ent, EV_VEC_velocity, fEntVelocity)

		entity_set_float(ent, EV_FL_gravity, 0.1)
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.01)

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW)
		write_short(ent)
		write_short(sprite_beam)
		write_byte(10)
		write_byte(3)
		write_byte(255)
		write_byte(255)
		write_byte(255)
		write_byte(100)
		message_end()

		new SOUND_SHELLS[21]
		format(SOUND_SHELLS, 20, "player/pl_shell%d.wav", random_num(1, 3))
		emit_sound(ent, CHAN_STATIC, SOUND_SHELLS, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
}
