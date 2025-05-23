#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <xs>

//Uncomment this if server is running zp50 and above
#define USE_ZP50

#if defined USE_ZP50
	#include <zp50_core>
	#include <zp50_items>
	#include <zp50_ammopacks>
	#include <zp50_class_nemesis>
	#include <zp50_class_survivor>
#else
	#include <zombieplague>
#endif

#define PLUGIN_VERSION "0.1.2"

#define SoundFire "weapons/rocketfire1.wav"
#define SoundTravel "weapons/rocket1.wav"
#define SoundFly "zs/fly2.wav"
#define SoundBlow "zs/blow.wav"
#define SoundPickup "events/task_complete.wav"
#define ModelRocket "models/rpgrocket.mdl"
#define ModelJetpack_P "models/p_egon.mdl"
#define ModelJetpack_W "models/w_egon.mdl"
#define ModelJetpack_V "models/v_egon.mdl"
#define ClassJetpack "gg_jetpack"
#define ClassJetpack_P "gg_jetpack_p"
#define ClassRocket "gg_bazooka"
#define ItemName "Jetpack+Bazooka"
#define ItemCost 30
#define RocketSpeed 1500
#define RocketRadius 300.0
#define RocketDamage 800.0
#define JpFwdSpeed 400
#define JpUpVelocity 200.0
#define MaxGas 300
#define DamageDealtForAmmo 500.0
#define IconGreenGas 299
#define IconYellowGas 200
#define IconRedGas 100
#define FlameAndSoundRate 6

//Uncomment this to fully disable knockback on nemesis & zombie
//#define DISABLE_ALL_KNOCKBACK

//Uncomment this to block knockback on nemesis only
//#define NEMESIS_NO_KNOCKBACK

//Uncomment this to make dropped jetpack bouncing
//#define MAKE_JETPACK_BOUNCING

//Uncomment this to allow player to drop their jetpack
#define ALLOW_DROP_JETPACK

//Uncomment this to enable death effect (gibs and blood) killed by rocket
#define MAKE_DEATH_EFFECT

//Uncomment this to enable status icon
//#define MAKE_STATUS_ICON

//Uncomment this to show damage done by rocket to attacker
#define SHOW_DAMAGE_CHAT

new iGas[33], Float:fLastShot[33], Float:fDamageDealt[33], bool:bHasJetpack[33], iItem, SprTrail, SprExplode, SprRing, SprFlame, iMsgScreenShake, iMsgSayText, bool:bHamBot, CvarBotQuota

#if defined MAKE_DEATH_EFFECT
new bool:bKilledByRocket[33]
#endif

#if defined MAKE_STATUS_ICON
new iMsgStatusIcon
new const szIconLJ[] = "item_longjump"
#endif

const OFFSET_WEAPONOWNER = 41
const OFFSET_LINUX_WEAPONS = 4
const UNIT_SECOND = (1<<12)

public plugin_precache()
{
	SprTrail = precache_model("sprites/smoke.spr")
	SprExplode = precache_model("sprites/zerogxplode.spr")
	SprRing = precache_model("sprites/shockwave.spr")
	SprFlame = precache_model("sprites/xfireball3.spr")
	
	precache_model(ModelRocket)
	precache_model(ModelJetpack_P)
	precache_model(ModelJetpack_W)
	precache_model(ModelJetpack_V)
	
	precache_sound(SoundFire)
	precache_sound(SoundTravel)
	precache_sound(SoundFly)
	precache_sound(SoundBlow)
	precache_sound(SoundPickup)
}

public plugin_init()
{
	register_plugin(ItemName, PLUGIN_VERSION, "wbyokomo") //5.April.2015 02:57AM
	
	register_event("HLTV", "OnNewRound", "a", "1=0", "2=0")
	
	RegisterHam(Ham_Killed, "player", "OnKilled")
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "OnDeployKnifePost", 1)
	
	register_touch(ClassJetpack, "player", "OnTouchJetPack")
	register_touch(ClassRocket, "*", "OnTouchRocket")
	
	register_forward(FM_CmdStart, "OnCmdStart")
	
	#if defined USE_ZP50
	iItem = zp_items_register(ItemName, ItemCost)
	#else
	iItem = zp_register_extra_item(ItemName, ItemCost, ZP_TEAM_HUMAN)
	#endif
	
	iMsgScreenShake = get_user_msgid("ScreenShake")
	iMsgSayText = get_user_msgid("SayText")
	CvarBotQuota = get_cvar_pointer("bot_quota")
	
	#if defined MAKE_STATUS_ICON
	iMsgStatusIcon = get_user_msgid("StatusIcon")
	#endif
	
	#if defined ALLOW_DROP_JETPACK
	register_clcmd("drop_jp", "CmdDropJetPack")
	#endif
	
	register_cvar("n4d_jp_version", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	set_cvar_string("n4d_jp_version", PLUGIN_VERSION)
	
	#if defined USE_ZP50
	server_print("ZP: Jetpack+Bazooka plugin has been compiled for ZP50 version.")
	#else
	server_print("ZP: Jetpack+Bazooka plugin has been compiled for ZP43 version.")
	#endif
}

#if defined ALLOW_DROP_JETPACK
public CmdDropJetPack(id)
{
	if(!is_user_alive(id) || !bHasJetpack[id]) return PLUGIN_HANDLED;
	
	CreateWorldJetPack(id)
	RemovePlayerJetPack(id)
	bHasJetpack[id] = false
	#if defined MAKE_STATUS_ICON
	DrawColoredIcon(id)
	#endif
	
	return PLUGIN_HANDLED;
}
#endif

public OnNewRound()
{
	remove_entity_name(ClassJetpack)
}

public client_putinserver(id)
{
	fDamageDealt[id] = 0.0
	ResetPlayerData(id)
	
	if(is_user_bot(id))
	{
		if(!bHamBot && CvarBotQuota) set_task(0.1, "CSBotInit", id);
	}
}

public CSBotInit(id)
{
	if(bHamBot || !is_user_connected(id) || !get_pcvar_num(CvarBotQuota)) return;
	
	RegisterHamFromEntity(Ham_Killed, id, "OnKilled")
	bHamBot = true
}

public client_disconnect(id)
{
	if(bHasJetpack[id])
	{
		ResetPlayerData(id)
		RemovePlayerJetPack(id)
	}
}

public OnKilled(id, atk, gibs)
{
	if(bHasJetpack[id])
	{
		ResetPlayerData(id)
		CreateWorldJetPack(id)
		RemovePlayerJetPack(id)
		#if defined MAKE_STATUS_ICON
		DrawColoredIcon(id)
		#endif
	}
	
	#if defined MAKE_DEATH_EFFECT
	if(bKilledByRocket[id])
	{
		SetHamParamInteger(3, 2)
		new Float:fOrigin[3]; entity_get_vector(id, EV_VEC_origin, fOrigin);
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fOrigin, 0)
		write_byte(TE_LAVASPLASH)
		engfunc(EngFunc_WriteCoord, fOrigin[0])
		engfunc(EngFunc_WriteCoord, fOrigin[1])
		engfunc(EngFunc_WriteCoord, fOrigin[2])
		message_end()
		bKilledByRocket[id] = false
	}
	#endif
}

#if defined USE_ZP50
public zp_fw_core_infect_post(id)
{
	if(bHasJetpack[id])
	{
		ResetPlayerData(id)
		CreateWorldJetPack(id)
		RemovePlayerJetPack(id)
		#if defined MAKE_STATUS_ICON
		DrawColoredIcon(id)
		#endif
	}
}

public zp_fw_items_select_pre(id, itemid, ignorecost)
{
	if(itemid != iItem) return ZP_ITEM_AVAILABLE;
	if(zp_core_is_zombie(id)) return ZP_ITEM_DONT_SHOW;
	if(bHasJetpack[id]) return ZP_ITEM_NOT_AVAILABLE;
	
	return ZP_ITEM_AVAILABLE;
}

public zp_fw_items_select_post(id, itemid, ignorecost)
{
	if(itemid != iItem) return;
	
	CreateJetPack(id, 1)
	UTIL_ColorChat(id, "^x04[ZP]^x01 You got a Jetpack, fly like a BOSS. Hold^x04 JUMP+DUCK^x01 to fly.")
	UTIL_ColorChat(id, "^x04[ZP]^x01 Press mouse ^x04RIGHT-CLICK^x01 to shoot rocket.")
	emit_sound(id, CHAN_STATIC, SoundPickup, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}
#else
public zp_user_infected_post(id)
{
	if(bHasJetpack[id])
	{
		ResetPlayerData(id)
		CreateWorldJetPack(id)
		RemovePlayerJetPack(id)
		#if defined MAKE_STATUS_ICON
		DrawColoredIcon(id)
		#endif
	}
}

public zp_extra_item_selected(id, item)
{
	if(item == iItem)
	{
		if(bHasJetpack[id])
		{
			UTIL_ColorChat(id, "^x04[ZP]^x01 You already have this item.")
			return ZP_PLUGIN_HANDLED;
		}
		
		CreateJetPack(id, 1)
		UTIL_ColorChat(id, "^x04[ZP]^x01 You got a Jetpack, fly like a BOSS. Hold^x04 JUMP+DUCK^x01 to fly.")
		UTIL_ColorChat(id, "^x04[ZP]^x01 Press mouse ^x04RIGHT-CLICK^x01 to shoot rocket.")
		emit_sound(id, CHAN_STATIC, SoundPickup, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	
	return PLUGIN_CONTINUE;
}
#endif

public OnCmdStart(id)
{
	if(!bHasJetpack[id]) return;
	#if defined USE_ZP50
	if(zp_class_survivor_get(id)) return;
	#else
	if(zp_get_user_survivor(id)) return;
	#endif
	
	static button; button = entity_get_int(id, EV_INT_button);
	if((iGas[id] > 0) && (button & IN_DUCK) && (button & IN_JUMP))
	{
		static Float:Velocity[3]
		velocity_by_aim(id, JpFwdSpeed, Velocity)
		Velocity[2] = JpUpVelocity
		entity_set_vector(id, EV_VEC_velocity, Velocity)
		iGas[id] --
		
		if(random(FlameAndSoundRate) == 2) //make random chance to draw flame & play sound to reduce lag, send MSG_PVS instead of MSG_BROADCAST
		{
			if(iGas[id] > 160) emit_sound(id, CHAN_WEAPON, SoundFly, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			else emit_sound(id, CHAN_WEAPON, SoundBlow, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			
			static Float:Origin[3]
			entity_get_vector(id, EV_VEC_origin, Origin)
			engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0)
			write_byte(TE_SPRITE)
			engfunc(EngFunc_WriteCoord, Origin[0])
			engfunc(EngFunc_WriteCoord, Origin[1])
			engfunc(EngFunc_WriteCoord, Origin[2])
			write_short(SprFlame)
			write_byte(4)
			write_byte(192)
			message_end()
		}
	}
	else if(button & IN_ATTACK2)
	{
		static Float:ctime; ctime = get_gametime();
		if(fLastShot[id] < ctime)
		{
			fLastShot[id] = ctime+10.0
			CmdRocket(id)
		}
	}
	else if(button & IN_USE)
	{
		static Float:fVelocity[3]; entity_get_vector(id, EV_VEC_velocity, fVelocity);
		if(fVelocity[2] < 0.0)
		{
			fVelocity[2] = -60.0
			entity_set_vector(id, EV_VEC_velocity, fVelocity)
		}
	}
	else if((iGas[id] < MaxGas) && (entity_get_int(id, EV_INT_flags) & FL_ONGROUND)) //bugfix: only refill gas when on the ground
	{
		iGas[id] ++
	}
	
	//draw colored icon based on gas amount
	#if defined MAKE_STATUS_ICON
	if(iGas[id] == IconGreenGas) DrawColoredIcon(id, 1, 0, 255, 0);
	else if(iGas[id] == IconYellowGas) DrawColoredIcon(id, 1, 255, 255, 0);
	else if(iGas[id] == IconRedGas) DrawColoredIcon(id, 1, 255, 0, 0);
	#endif
}

#if defined MAKE_STATUS_ICON
DrawColoredIcon(id, mode=0, r=0, g=0, b=0)
{
	if(!mode)
	{
		message_begin(MSG_ONE, iMsgStatusIcon, _, id)
		write_byte(0)
		write_string(szIconLJ)
		message_end()
	}
	else
	{
		message_begin(MSG_ONE, iMsgStatusIcon, _, id)
		write_byte(1) //mode
		write_string(szIconLJ)
		write_byte(r) //r
		write_byte(g) //g
		write_byte(b) //b
		message_end()
	}
}
#endif

public OnDeployKnifePost(ent)
{
	new id = get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
	if(pev_valid(id) && bHasJetpack[id]) set_pev(id, pev_viewmodel2, ModelJetpack_V);
}

public OnTouchJetPack(ent, id)
{
	if(is_valid_ent(ent) && is_user_connected(id))
	{
		if(!is_user_alive(id)) return PLUGIN_HANDLED;
		#if defined USE_ZP50
		if(bHasJetpack[id] || zp_core_is_zombie(id) || zp_class_survivor_get(id)) return PLUGIN_HANDLED;
		#else
		if(bHasJetpack[id] || zp_get_user_zombie(id) || zp_get_user_survivor(id)) return PLUGIN_HANDLED;
		#endif
		
		entity_set_int(ent, EV_INT_solid, SOLID_NOT)
		remove_entity(ent)
		CreateJetPack(id, 0)
		UTIL_ColorChat(id, "^x04[ZP]^x01 You got a Jetpack, fly like a BOSS. Hold^x04 JUMP+DUCK^x01 to fly.")
		UTIL_ColorChat(id, "^x04[ZP]^x01 Press mouse^x04 RIGHT-CLICK^x01 to shoot rocket.")
		emit_sound(id, CHAN_STATIC, SoundPickup, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	
	return PLUGIN_CONTINUE;
}

public OnTouchRocket(ent, id)
{
	if(!is_valid_ent(ent)) return;
	
	entity_set_int(ent, EV_INT_solid, SOLID_NOT)
	emit_sound(ent, CHAN_VOICE, SoundTravel, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM) //stop rocket loop sound
	new Float:atkOrigin[3]
	entity_get_vector(ent, EV_VEC_origin, atkOrigin)
	
	//explosion
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, atkOrigin, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, atkOrigin[0])
	engfunc(EngFunc_WriteCoord, atkOrigin[1])
	engfunc(EngFunc_WriteCoord, atkOrigin[2])
	write_short(SprExplode)
	write_byte(30)
	write_byte(30)
	write_byte(10)
	message_end()
	
	//ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, atkOrigin, 0)
	write_byte(TE_BEAMCYLINDER)
	engfunc(EngFunc_WriteCoord, atkOrigin[0])
	engfunc(EngFunc_WriteCoord, atkOrigin[1])
	engfunc(EngFunc_WriteCoord, atkOrigin[2])
	engfunc(EngFunc_WriteCoord, atkOrigin[0])
	engfunc(EngFunc_WriteCoord, atkOrigin[1])
	engfunc(EngFunc_WriteCoord, atkOrigin[2]+500.0)
	write_short(SprRing)
	write_byte(0)
	write_byte(0)
	write_byte(5)
	write_byte(30)
	write_byte(0)
	write_byte(224)
	write_byte(224)
	write_byte(224)
	write_byte(255)
	write_byte(0)
	message_end()
	
	//get attacker
	new attacker = entity_get_edict(ent, EV_ENT_owner)
	if(!is_user_connected(attacker))
	{
		remove_entity(ent)
		return;
	}
	
	//get victim
	new victim = -1
	while((victim = engfunc(EngFunc_FindEntityInSphere, victim, atkOrigin, RocketRadius)) != 0)
	{
		#if defined USE_ZP50
		if(!is_user_alive(victim) || !zp_core_is_zombie(victim)) continue;
		#else
		if(!is_user_alive(victim) || !zp_get_user_zombie(victim)) continue;
		#endif
		
		//damage calculation
		new Float:fOrigin[3], Float:fDistance, Float:fDamage
		entity_get_vector(victim, EV_VEC_origin, fOrigin)
		fDistance = get_distance_f(fOrigin, atkOrigin)
		fDamage = RocketDamage - floatmul(RocketDamage, floatdiv(fDistance, RocketRadius))
		fDamage *= 1.0
		if(fDamage < 1.0) continue;
		
		//screen shake
		message_begin(MSG_ONE_UNRELIABLE, iMsgScreenShake, _, victim)
		write_short(UNIT_SECOND*8)
		write_short(UNIT_SECOND*3)
		write_short(UNIT_SECOND*18)
		message_end()
		
		//do damage & knockback
#if !defined DISABLE_ALL_KNOCKBACK
		#if defined NEMESIS_NO_KNOCKBACK
			#if defined USE_ZP50
			if(!zp_class_nemesis_get(victim))
			#else
			if(!zp_get_user_nemesis(victim))
			#endif
			{
				xs_vec_sub(fOrigin, atkOrigin, fOrigin)
				xs_vec_mul_scalar(fOrigin, fDamage * 0.7, fOrigin)
				xs_vec_mul_scalar(fOrigin, RocketDamage / xs_vec_len(fOrigin), fOrigin)
				entity_set_vector(victim, EV_VEC_velocity, fOrigin)
			}
		#else
		xs_vec_sub(fOrigin, atkOrigin, fOrigin)
		xs_vec_mul_scalar(fOrigin, fDamage * 0.7, fOrigin)
		xs_vec_mul_scalar(fOrigin, RocketDamage / xs_vec_len(fOrigin), fOrigin)
		entity_set_vector(victim, EV_VEC_velocity, fOrigin)
		#endif
#endif
		
		#if defined MAKE_DEATH_EFFECT
		new Float:fHealth = entity_get_float(victim, EV_FL_health);
		fHealth = fHealth - fDamage
		if(fHealth <= 0.0)
		{
			bKilledByRocket[victim] = true
		}
		#endif
		
		ExecuteHam(Ham_TakeDamage, victim, ent, attacker, fDamage, DMG_BULLET)
		
		//calculate ammopack here
		fDamageDealt[attacker] += fDamage
		while(fDamageDealt[attacker] > DamageDealtForAmmo)
		{
			#if defined USE_ZP50
			new ap = zp_ammopacks_get(attacker)
			zp_ammopacks_set(attacker, ap+1)
			#else
			new ap = zp_get_user_ammo_packs(attacker)
			zp_set_user_ammo_packs(attacker, ap+1)
			#endif
			fDamageDealt[attacker] -= DamageDealtForAmmo
		}
		
		#if defined SHOW_DAMAGE_CHAT
		new szName[32]; get_user_name(victim, szName, 31);
		UTIL_ColorChat(attacker, "^x04[ZP]^x01 Damage to^x04 %s^x01 ::^x04 %.0f^x01 damage", szName, fDamage)
		#endif
	}
	
	remove_entity(ent)
}

CreateJetPack(id, fullgas)
{
	new ent = create_entity("info_target")
	if(!is_valid_ent(ent)) return;
	
	bHasJetpack[id] = true
	if(fullgas) iGas[id] = MaxGas;
	new Float:Origin[3]
	entity_get_vector(id, EV_VEC_origin, Origin)
	entity_set_string(ent, EV_SZ_classname, ClassJetpack_P)
	entity_set_model(ent, ModelJetpack_P)
	entity_set_origin(ent, Origin)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_FOLLOW)
	entity_set_edict(ent, EV_ENT_aiment, id)
	entity_set_int(ent, EV_INT_solid, SOLID_NOT)
	entity_set_size(ent, Float:{0.0, 0.0, 0.0}, Float:{0.0, 0.0, 0.0})
	entity_set_edict(ent, EV_ENT_owner, id)
}

CreateWorldJetPack(id)
{
	new ent = create_entity("info_target")
	if(!is_valid_ent(ent)) return;
	
	new Float:Aim[3], Float:Origin[3], iColor[3]
	velocity_by_aim(id, 32, Aim)
	entity_get_vector(id, EV_VEC_origin, Origin)
	Origin[0] += 2*Aim[0]
	Origin[1] += 2*Aim[1]
	entity_set_string(ent, EV_SZ_classname, ClassJetpack)
	entity_set_model(ent, ModelJetpack_W)
	#if defined MAKE_JETPACK_BOUNCING
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_BOUNCE)
	#else
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS)
	#endif
	entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER)
	entity_set_size(ent, Float:{-8.0, -8.0, -8.0}, Float:{8.0, 8.0, 8.0})
	entity_set_float(ent, EV_FL_gravity, 1.25)
	entity_set_vector(ent, EV_VEC_origin, Origin)
	velocity_by_aim(id, 400, Aim)
	entity_set_vector(ent, EV_VEC_velocity, Aim)
	iColor[0] = random_num(16,255)
	iColor[1] = random(255)
	iColor[2] = random(255)
	set_rendering(ent, kRenderFxGlowShell, iColor[0], iColor[1], iColor[2], kRenderNormal, 0)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(ent)
	write_short(SprTrail)
	write_byte(10)
	write_byte(5)
	write_byte(iColor[0])
	write_byte(iColor[1])
	write_byte(iColor[2])
	write_byte(192)
	message_end()
}

CmdRocket(id)
{
	new ent = create_entity("info_target")
	if(!is_valid_ent(ent)) return;
	
	new Float:origin[3], Float:velocity[3]
	entity_get_vector(id, EV_VEC_origin, origin)
	origin[2] += 16.0
	entity_set_string(ent, EV_SZ_classname, ClassRocket)
	entity_set_model(ent, ModelRocket)
	entity_set_origin(ent, origin)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_FLY)
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX)
	entity_set_size(ent, Float:{0.0, 0.0, 0.0}, Float:{0.0, 0.0, 0.0})
	entity_set_edict(ent, EV_ENT_owner, id)
	velocity_by_aim(id, 1500, velocity)
	entity_set_vector(ent, EV_VEC_velocity,	velocity)
	vector_to_angle(velocity, origin)
	entity_set_vector(ent, EV_VEC_angles, origin)
	entity_set_int(ent, EV_INT_effects, EF_LIGHT)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(ent)
	write_short(SprTrail)
	write_byte(30)
	write_byte(5)
	write_byte(224)
	write_byte(224)
	write_byte(224)
	write_byte(192)
	message_end()
	
	emit_sound(id, CHAN_STATIC, SoundFire, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(ent, CHAN_VOICE, SoundTravel, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

RemovePlayerJetPack(id)
{
	new ent = -1
	while((ent = find_ent_by_class(ent, ClassJetpack_P)))
	{
		if(!is_valid_ent(ent)) continue;
		if(entity_get_edict(ent, EV_ENT_owner) != id) continue;
		
		remove_entity(ent)
	}
}

ResetPlayerData(id)
{
	bHasJetpack[id] = false
	fLastShot[id] = 0.0
	iGas[id] = MaxGas
}

UTIL_ColorChat(id, const szText[], any:...)
{
	new szBuffer[512]
	
	if(!id)
	{
		new iPlayers[32], iNum, y, id2
		get_players(iPlayers, iNum, "ch")
		for(y=0;y<iNum;y++)
		{
			id2 = iPlayers[y]
			if(!is_user_connected(id2)) continue;
			
			vformat(szBuffer, charsmax(szBuffer), szText, 3)
			message_begin(MSG_ONE_UNRELIABLE, iMsgSayText, _, id2)
			write_byte(id2)
			write_string(szBuffer)
			message_end()
		}
	}
	else
	{
		vformat(szBuffer, charsmax(szBuffer), szText, 3)
		message_begin(MSG_ONE, iMsgSayText, _, id)
		write_byte(id)
		write_string(szBuffer)
		message_end()
	}
}
