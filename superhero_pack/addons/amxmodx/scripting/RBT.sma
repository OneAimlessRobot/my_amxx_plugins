#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fakemeta_util>
#include <cstrike>
#include <fun>
#include <engine>
#include <string>
#pragma reqlib "dcapi"
native damagecar(id, damage)

#define PLUGIN_NAME "Realistic Bullet Tracer"
#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_AUTHOR "Knekter , man_s_our"

new bullspeed[32], bullweight[32]

new bool:g_bullet_time = true;

#define MAX_PLAYERS 32
#define MAX_SPEED 15000

new bool:g_restart_attempt[MAX_PLAYERS + 1];

new g_last_weapon[MAX_PLAYERS + 1];
new g_last_clip[MAX_PLAYERS + 1];
new smoke_sprite;
new g_sprite_bullet;
new gravity
public plugin_precache()
{
	precache_model("models/null.mdl");
	precache_sound("weapons/bulwiz.wav");
	g_sprite_bullet = precache_model("sprites/s.spr");
	smoke_sprite = precache_model("sprites/wall_puff1.spr");
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_concmd("bt_toggle", "clcmd_bullettime", ADMIN_KICK, "<1/on | 0/off>");
	register_clcmd("fullupdate", "clcmd_fullupdate");
	gravity = register_cvar("grav", "1",FCVAR_SERVER)
	register_event("ResetHUD", "event_reset_hud", "be");
	register_event("TextMsg", "event_restart_attempt", "a", "2=#Game_will_restart_in");
	register_event("CurWeapon", "event_weaponfire", "be", "1=1", "2!4", "2!6", "2!9", "2!25", "2!29");

	register_forward(FM_Touch, "forward_touch");
	server_cmd("sv_maxvelocity %d",MAX_SPEED)
	bullspeed[CSW_P228] = 1400
	bullweight[CSW_P228] = 8
	bullspeed[CSW_SCOUT] = 2800
	bullweight[CSW_SCOUT] = 8
	bullspeed[CSW_XM1014] = 1250
	bullweight[CSW_XM1014] = 4
	bullspeed[CSW_MAC10] = 919
	bullweight[CSW_MAC10] = 15
	bullspeed[CSW_AUG] = 2900
	bullweight[CSW_AUG] = 4
	bullspeed[CSW_ELITE] = 1280
	bullweight[CSW_ELITE] = 8
	bullspeed[CSW_FIVESEVEN] = 2345
	bullweight[CSW_FIVESEVEN] = 2
	bullspeed[CSW_UMP45] = 1005
	bullweight[CSW_UMP45] = 15
	bullspeed[CSW_SG550] = 3100
	bullweight[CSW_SG550] = 4
	bullspeed[CSW_GALI] = 2013
	bullweight[CSW_GALI] = 4
	bullspeed[CSW_FAMAS] = 2212
	bullweight[CSW_FAMAS] = 4
	bullspeed[CSW_USP] = 886
	bullweight[CSW_USP] = 15
	bullspeed[CSW_GLOCK18] = 1132
	bullweight[CSW_GLOCK18] = 8
	bullspeed[CSW_AWP] = 3000
	bullweight[CSW_AWP] = 16
	bullspeed[CSW_MP5NAVY] = 1132
	bullweight[CSW_MP5NAVY] = 8
	bullspeed[CSW_M249] = 3000
	bullweight[CSW_M249] = 4
	bullspeed[CSW_M3] = 1250
	bullweight[CSW_M3] = 4
	bullspeed[CSW_M4A1] = 1570
	bullweight[CSW_M4A1] = 4
	bullspeed[CSW_TMP] = 1280
	bullweight[CSW_TMP] = 8
	bullspeed[CSW_G3SG1] = 2800
	bullweight[CSW_G3SG1] = 8
	bullspeed[CSW_DEAGLE] = 1380
	bullweight[CSW_DEAGLE] = 19
	bullspeed[CSW_SG552] = 2900
	bullweight[CSW_SG552] = 4
	bullspeed[CSW_AK47] = 1992
	bullweight[CSW_AK47] = 8
	bullspeed[CSW_P90] = 2345
	bullweight[CSW_P90] = 2
}

public clcmd_bullettime(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;

	static arg[3];
	read_argv(1, arg, sizeof(arg));

	if ((equali(arg, "on") || equali(arg, "1")) && g_bullet_time != true)
	{
		util_hitzones(0);
		client_print(0, print_chat, "[AMXX] Bullet time has currently been enabled!");

		g_bullet_time = true;
	}
	else if ((equali(arg, "off") || equali(arg, "0")) && g_bullet_time != false)
	{
		util_hitzones(255);
		client_print(0, print_chat, "[AMXX] Bullet time has currently been disabled!");

		g_bullet_time = false;
	}

	return PLUGIN_HANDLED;
}

public clcmd_fullupdate()
{
	// Block those bastards
	return PLUGIN_HANDLED;
}

public event_reset_hud(id)
{
	if (g_restart_attempt[id])
	{
		g_restart_attempt[id] = false;
		return;
	}

	event_player_spawn(id);
}

public event_restart_attempt()
{
	new num, p;
	static players[32];
	get_players(players, num, "a");

	for (p = 0; p < num; ++p)
		g_restart_attempt[players[p]] = true;
}

public event_player_spawn(id)
{
	if (g_bullet_time == false)
		return;

	set_user_hitzones(id, 0, 0);
	set_user_hitzones(0, id, 0);

	return;
}

public event_weaponfire(id)
{
	if (g_bullet_time == false)
		return;
	new clip;
	new weapon = get_user_weapon(id, clip);

	if (g_last_weapon[id] == 0)
		g_last_weapon[id] = weapon;

	if ((g_last_clip[id] > clip) && (g_last_weapon[id] == weapon))
	{
		new entity = fm_create_entity("info_target");
		if (entity > 0)
		{
			new Float:angle[3], Float:origin[3],Float:org, Float:aimvec[3]
			new Float:minbox[3] = {-1.0, -1.0, -1.0};
			new Float:maxbox[3] = {1.0, 1.0, 1.0};
			engfunc(EngFunc_GetBonePosition, id, 14, origin, angle);
			org = origin[2] + 3;
			pev(id, pev_origin, origin);
			origin[2] = org;
			set_pev(entity, pev_classname, "bullet_x");
			fm_entity_set_model(entity, "models/null.mdl");
			set_pev(entity, pev_dmg, float(weapon));

			pev(id, pev_v_angle, angle);

			fm_entity_set_size(entity, minbox, maxbox);
			fm_entity_set_origin(entity, origin);

			set_pev(entity, pev_angles, angle);
			set_pev(entity, pev_v_angle, angle);

			set_pev(entity, pev_effects, 2);
			set_pev(entity, pev_solid, SOLID_BBOX);
			if(get_pcvar_num(gravity))
			{
				set_pev(entity, pev_movetype, MOVETYPE_TOSS);
				set_pev(entity, pev_gravity, float(MAX_SPEED) / 15000.0);
			}
			else
				set_pev(entity, pev_movetype, MOVETYPE_FLY);
			set_pev(entity, pev_owner, id);
			new spd = floatround(float(MAX_SPEED) * float(bullspeed[weapon]) / 3100.0)
			VelocityByAim(id, spd, aimvec);
			set_pev(entity, pev_velocity, aimvec);

			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_BEAMFOLLOW);
			write_short(entity);			// Entity to follow
			write_short(g_sprite_bullet);		// Sprite index
			write_byte(1);				// Life
			write_byte(1);				// Line width
			write_byte(255);			// Red
			write_byte(255);			// Green
			write_byte(0);				// Blue
			write_byte(255);			// Brightness
			message_end();
			emit(id);
		}
	}

	g_last_weapon[id] = weapon;
	g_last_clip[id] = clip;
}

public forward_touch(toucher, touched)
{
	if (toucher > 0 && touched >= 0)
	{
		static classname[32];
		static classname2[32];
		pev(toucher, pev_classname, classname, sizeof(classname));
		pev(touched, pev_classname, classname2, sizeof(classname2));
		
		if(equal(classname, "bullet_x"))
		{
			new Float:torigin[3];
			new attacker = pev(toucher, pev_owner);
			pev(toucher, pev_origin, torigin);
			
			if (is_user_connected(touched) && equal(classname2, "player"))
			{
				new Float:velocity[3];
				pev(toucher, pev_velocity, velocity)
				new multiply = get_bone_hit(gunshot_bone(touched, torigin));
				new Float:wep;
				pev(toucher, pev_dmg, wep);
				new weapon = floatround(wep);
				new vel = floatround(xs_vec_len(velocity) / float(MAX_SPEED))
				util_damage(attacker, touched, weapon, multiply, vel);
			}
			else
			{
				message_begin(MSG_ALL ,SVC_TEMPENTITY)
				write_byte(TE_EXPLOSION);
				write_coord(floatround(torigin[0]));
				write_coord(floatround(torigin[1]));
				write_coord(floatround(torigin[2]));
				write_short(smoke_sprite);
				write_byte(5);
				write_byte(50);
				write_byte(14);//no light or sound or particles
				message_end();
			}
			emit_sound(toucher, CHAN_STATIC, "weapons/bulwiz.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			fm_remove_entity(toucher);
			if (equal(classname2, "func_breakable"))
				fm_force_use(attacker, touched);
			if(equal(classname2, "func_vehicle") || equal(classname2, "func_tracktrain"))
				damagecar(touched, 10);
		}
	}

	return PLUGIN_HANDLED;
}

stock get_bone_hit(number)
{
	if(number == 40)
	{
		return 200;
	}
	else if (1 <= number <= 4){
		return 30;}
 
	else if (4 < number <= 6){
		return 100;}
 
	else if (6 < number <= 8){
		return 200;}

	return 10;
}

stock gunshot_bone(victim, Float:endtrace[3])
{
    new Float:angles[3], Float:origin[3], Float:dist = 9999999.99, Float:curorigin[3], bone_nr
    for (new i=1;i<=54;i++)
    {
        // Get the bone position
        engfunc(EngFunc_GetBonePosition, victim, i, curorigin, angles)
        // Calculate the distance vector
        xs_vec_sub(curorigin, endtrace, angles)
 
        // If this is smaller than the last small distance remember the value!
        if (xs_vec_len(angles) <= dist)
        {
            origin = curorigin
            dist = xs_vec_len(angles)
            bone_nr = i
        }
    }
 
    // Return the bone
    return bone_nr
}
util_damage(attacker, victim, weapon, multiply, vel)
{
	new head = (multiply == 200)
	new damage = multiply * (bullweight[weapon] * power(vel, 2) + 1);
	static weaponname[32]
	get_weaponname(weapon, weaponname, sizeof(weaponname));
	replace(weaponname, 32, "weapon_", "");
	if (get_user_health(victim) - damage <= 0)
		util_kill(attacker, victim, weaponname, head);
	else if (get_user_team(attacker) != get_user_team(victim) || (get_user_team(attacker) == get_user_team(victim) && get_cvar_num("mp_friendlyfire") == 1))
	{
		fm_fakedamage(victim, weaponname, float(damage), DMG_BULLET);

		static origin[3];
		get_user_origin(victim, origin, 0);

		message_begin(MSG_ONE, get_user_msgid("Damage"), {0, 0, 0}, victim);
		write_byte(0);		 // Damage save
		write_byte(damage);	 // Damage take
		write_long(DMG_BULLET);	 // Damage type
		write_coord(origin[0]);	 // X
		write_coord(origin[1]);	 // Y
		write_coord(origin[2]);	 // Z
		message_end();

		if (get_user_team(attacker) == get_user_team(victim))
		{
			static name[32];
			get_user_name(attacker, name, sizeof(name));

			client_print(0, print_chat, "%s attacked a teammate", name);
		}
	}
}

util_kill(killer, victim, weapon[], head)
{
	if (get_user_team(killer) != get_user_team(victim))
	{
		user_silentkill(victim);
		make_deathmsg(killer, victim, head, weapon);

		set_user_frags(killer, get_user_frags(killer) + 1);

		new money = cs_get_user_money(killer) + 300;
		if (money >= 16000)
			cs_set_user_money(killer, 16000);
		else
			cs_set_user_money(killer, money, 1);
	}
	else
	{
		if (get_cvar_num("mp_friendlyfire") == 1)
		{
			user_silentkill(victim);
			make_deathmsg(killer, victim, 0, weapon);

			set_user_frags(killer, get_user_frags(killer) - 1);

			new money = cs_get_user_money(killer) - 3300;
			if (money <= 0)
				cs_set_user_money(killer, 0);
			else
				cs_set_user_money(killer, money, 1);
		}
	}

	message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"));
	write_byte(killer);			 // Destination
	write_short(get_user_frags(killer));	 // Frags
	write_short(cs_get_user_deaths(killer)); // Deaths
	write_short(0);				 // Player class
	write_short(get_user_team(killer));	 // Team
	message_end();

	message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"));
	write_byte(victim);			 // Destination
	write_short(get_user_frags(victim));	 // Frags
	write_short(cs_get_user_deaths(victim)); // Deaths
	write_short(0);				 // Player class
	write_short(get_user_team(victim));	 // Team
	message_end();

	static kname[32];
	static vname[32];
	static kteam[10];
	static vteam[10];
	static kauthid[32];
	static vauthid[32];

	get_user_name(killer, kname, sizeof(kname));
	get_user_team(killer, kteam, sizeof(kteam));
	get_user_authid(killer, kauthid, sizeof(kauthid));

	get_user_name(victim, vname, sizeof(vname));
	get_user_team(victim, vteam, sizeof(vteam));
	get_user_authid(victim, vauthid, sizeof(vauthid));

	log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"%s^"", 
	kname, get_user_userid(killer), kauthid, kteam, 
 	vname, get_user_userid(victim), vauthid, vteam, weapon);
}

util_hitzones(value)
{
	new num, p;
	static players[32];
	get_players(players, num, "a");

	for (p = 0; p < num; ++p)
	{
		set_user_hitzones(players[p], 0, value);
		set_user_hitzones(0, players[p], value);
	}
}
public emit(id)
{
	if(is_valid_ent(id))
	{
		emit_sound(id, CHAN_STATIC, "weapons/bulwiz.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
		new parm[1]
		parm[0] = id
		set_task(0.1, "emit", id * 10, parm, 1)
	}
}

