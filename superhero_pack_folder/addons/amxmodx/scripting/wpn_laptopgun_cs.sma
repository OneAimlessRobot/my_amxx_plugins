#include <amxmodx>
#include <fakemeta>
#include <xs>
#include <weaponmod>
//#include <weaponmod_stocks>

// Plugin information
new const PLUGIN[]	= "WPN Laptop Gun ( PD )";
new const VERSION[]	= "0.5";
new const AUTHOR[]	= "SandStriker";

// Weapon information
new
	g_WPN_NAME[]	= "Laptop Gun",
	g_WPN_SHORT[]	= "laptopgun",
	g_WPN_CLASS[]	= "laptop_sentry";

// Models
new
	g_P_MODEL[]	= "models/p_9mmar.mdl",
	g_V_MODEL[]	= "models/v_laptop_cs.mdl",
	g_W_MODEL[]	= "models/w_9mmar.mdl",
	g_BOOMSPR[]	= "sprites/dexplo.spr",
	g_SENTRY[]	= "models/LaptopSentry.mdl";
	
// Sounds
new g_SOUND[][] = 
{
	"weapons/laptopgun_fire.wav",
	"weapons/laptopgun_reload.wav",
	"weapons/laptopgun_draw.wav",
	"weapons/laptopgun_drop.wav",
	"weapons/laptopgun_altfire.wav"	
};

new g_BREAKABLESOUND[][] =
{
	"debris/bustglass1.wav",
	"debris/bustglass2.wav",
	"debris/bustglass3.wav",
	"debris/glass1.wav",
	"debris/glass2.wav",
	"debris/glass3.wav",
	"debris/glass4.wav"
};

new g_BREAKABLE[] = "func_breakable";

enum lg_seq
{
	lg_idle,
	lg_shoot,
	lg_reload,
	lg_draw,
	lg_down
};

enum sentry_seq
{
	sentry_idle_off,
	sentry_fire,
	sentry_spin,
	sentry_deploy,
	sentry_refire,
	sentry_die
};

enum sentry_seq2
{
	SENTRY_DEPLOYING,
	SENTRY_SEARCHING,
	SENTRY_FIRING,
	SENTRY_DEAD
};

//laptopgun settings
#define LAPTOPGUN_SHAKEFORCE	-1.2
#define LAPTOPGUN_REFIRERATE	0.1
#define LAPTOPGUN_RUNSPEED	200.0
#define LAPTOPGUN_CLIPAMMO	30
#define LAPTOPGUN_MAXMAMMO	240
#define LAPTOPGUN_COST		1400
#define LAPTOPGUN_DMGMAX	20
#define LAPTOPGUN_DMGMIN	5

//sentrygun settings
#define LAPTOPSENTRY_HEALTH	100.0
#define LAPTOPSENTRY_SEARCHAREA	1200.0
#define LAPTOPSENTRY_SHOTDMGMAX	8
#define LAPTOPSENTRY_SHOTDMGMIN	2
#define LAPTOPSENTRY_REFIRERATE 0.1
#define LAPTOPSENTRY_DELAY	1.2

//--------------------------------------
//don't change under.
#define PI			3.141592654
#define TASK_ATTACK2		1025245
#define TASK_DISPLAY		235
#define LAPTOPGUN_RELOADTIME	2.09
#define LAPTOPGUN_BULLETPERSHOT	1
#define LAPTOPGUN_REFIRERATE2	0.8

#define LAPTOPSENTRY_TILTRADIUS	237.0
#define LAPTOPSENTRY_COUNT	pev_fuser1
#define LAPTOPSENTRY_ANGLE	pev_fuser2
#define LAPTOPSENTRY_OWNER	pev_owner
#define LAPTOPSENTRY_TEAM	pev_team
#define LAPTOPSENTRY_SEQUENCE	pev_iuser1
//index, origin, radius
#define find_ent_in_sphere(%1,%2,%3) engfunc(EngFunc_FindEntityInSphere, %1, %2, %3)
#define RemoveEntity(%1)	engfunc(EngFunc_RemoveEntity,%1)

new
	g_wpnid,// g_MaxPlayers,
	g_SentryClass,
	g_msgDamage,
	g_MaxPL,g_FF,g_boom,
	Float:g_OneEightyThroughPI;
new	bool:g_second[33];


public plugin_precache()
{
	g_boom = precache_model(g_BOOMSPR);
	precache_model(g_P_MODEL);
	precache_model(g_V_MODEL);
	precache_model(g_W_MODEL);
	precache_model(g_SENTRY);
	precache_sound(g_SOUND[0]);
	precache_sound(g_SOUND[1]);
	precache_sound(g_SOUND[2]);
	precache_sound(g_SOUND[3]);
	precache_sound(g_SOUND[4]);
	precache_sound(g_BREAKABLESOUND[0]);
	precache_sound(g_BREAKABLESOUND[1]);
	precache_sound(g_BREAKABLESOUND[2]);
	precache_sound(g_BREAKABLESOUND[3]);
	precache_sound(g_BREAKABLESOUND[4]);
	precache_sound(g_BREAKABLESOUND[5]);
	precache_sound(g_BREAKABLESOUND[6]);
	//precache_generic(g_EVENT);
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_forward(FM_Think, "LaptopSentry_Think");
	register_event("ResetHUD","RemoveAllSentry","b");
	g_msgDamage = get_user_msgid("Damage");
	g_FF = get_cvar_pointer("wpn_friendlyfire");
	return PLUGIN_CONTINUE;
}

public plugin_cfg()
{
	g_MaxPL = get_maxplayers();
	g_SentryClass = engfunc(EngFunc_AllocString,g_BREAKABLE);
	g_OneEightyThroughPI = 180.0 / PI;
	arrayset(g_second,false,sizeof(g_second));
	create_weapon();
	return PLUGIN_CONTINUE;
}

create_weapon()
{
	new wpnid = wpn_register_weapon(g_WPN_NAME, g_WPN_SHORT);
	if(wpnid == -1) return PLUGIN_CONTINUE;
	
	// Strings
	wpn_set_string(wpnid,wpn_viewmodel,	g_V_MODEL);
	wpn_set_string(wpnid,wpn_weaponmodel,	g_P_MODEL);
	wpn_set_string(wpnid,wpn_worldmodel,	g_W_MODEL);
	
	// Event handlers
	wpn_register_event(wpnid,event_attack1,		"ev_attack1");
	wpn_register_event(wpnid,event_attack2,		"ev_attack2");
	wpn_register_event(wpnid,event_draw,		"ev_draw");
	wpn_register_event(wpnid,event_reload,		"ev_reload");
	wpn_register_event(wpnid,event_hide,		"ev_holsdrop");
	wpn_register_event(wpnid,event_weapondrop_pre,	"ev_holsdrop");

	// Floats
	wpn_set_float(wpnid,wpn_refire_rate1,		LAPTOPGUN_REFIRERATE);
	wpn_set_float(wpnid,wpn_refire_rate2,		LAPTOPGUN_REFIRERATE2);
	wpn_set_float(wpnid,wpn_run_speed,		LAPTOPGUN_RUNSPEED);
	wpn_set_float(wpnid,wpn_reload_time,		LAPTOPGUN_RELOADTIME);
	
	// Integers
	wpn_set_integer(wpnid,wpn_ammo1,		LAPTOPGUN_CLIPAMMO);
	wpn_set_integer(wpnid,wpn_ammo2,		LAPTOPGUN_MAXMAMMO);
	wpn_set_integer(wpnid,wpn_bullets_per_shot1,	LAPTOPGUN_BULLETPERSHOT);
	wpn_set_integer(wpnid,wpn_cost,			LAPTOPGUN_COST);
	g_wpnid = wpnid;
	return PLUGIN_CONTINUE;
}

public ev_attack1(id)
{
	wpn_playanim(id, lg_shoot);
	emit_sound(id, CHAN_WEAPON, g_SOUND[0], 1.0, ATTN_NORM, 0, PITCH_NORM);
	RecoilControl(id);
	wpn_bullet_shot(g_wpnid,id,0,random_num(LAPTOPGUN_DMGMIN,LAPTOPGUN_DMGMAX));
	
	return PLUGIN_CONTINUE;
}

public ev_attack2(id)
{
	if(!g_second[id])
	{
		wpn_playanim(id,lg_down);
		emit_sound(id, CHAN_ITEM,g_SOUND[4],1.0,ATTN_NORM,0,PITCH_NORM);	
		set_task(1.3,"CreateSentry",TASK_ATTACK2+id);
		//wpn_drop_weapon_real(id,g_wpnid);
		g_second[id] = true;
	}else
	{
		client_print(id,print_chat,"[Laptop Gun] You already deployed sentry gun.");
	}
	return PLUGIN_CONTINUE;
}

RecoilControl(id)
{
	static Float:RecoilShake[3];

	RecoilShake[0] = random_float(LAPTOPGUN_SHAKEFORCE, 0.0);
	RecoilShake[1] = random_float(LAPTOPGUN_SHAKEFORCE, 0.0);
	RecoilShake[2] = 0.0
	set_pev(id, pev_punchangle, RecoilShake);
	return PLUGIN_CONTINUE;
}

public ev_reload (id)
{
	wpn_playanim (id ,lg_reload)
	emit_sound(id, CHAN_ITEM,g_SOUND[1],1.0,ATTN_NORM,0,PITCH_NORM);
	return PLUGIN_CONTINUE;
}

public ev_holsdrop(id)
{
	wpn_playanim(id,lg_down);
	emit_sound(id, CHAN_ITEM,g_SOUND[3],1.0,ATTN_NORM,0,PITCH_NORM);	
	return PLUGIN_CONTINUE;
}

public ev_draw(id)
{
	wpn_playanim(id,lg_draw);
	emit_sound(id, CHAN_ITEM,g_SOUND[2],1.0,ATTN_NORM,0,PITCH_NORM);	
	return PLUGIN_CONTINUE;
}

public CreateSentry(id)
{
	//input id
	if(id > 32) id -= TASK_ATTACK2;
	
	//create func_breakable
	new i_Ent = engfunc(EngFunc_CreateNamedEntity,g_SentryClass);
	if(!i_Ent)
	{
		//failed....
		client_print(id,print_chat,"[WeaponMod Debug] Can't Create Entity");
		return PLUGIN_HANDLED_MAIN;
	}
	
	//set class name
	set_pev(i_Ent,pev_classname,g_WPN_CLASS);

	//set model
	engfunc(EngFunc_SetModel,i_Ent,g_SENTRY);

	//set solid and movetype
	set_pev(i_Ent,pev_solid,SOLID_NOT);
	set_pev(i_Ent,pev_movetype,MOVETYPE_BOUNCE);
	
	//set model sequence.
	set_pev(i_Ent,pev_frame,0);
	set_pev(i_Ent,pev_body,0);
	set_pev(i_Ent,pev_sequence,sentry_deploy);
	set_pev(i_Ent,pev_framerate,1.0);

	//take a damage?
	set_pev(i_Ent,pev_takedamage,DAMAGE_YES);
	
	//set ent health.
	set_pev(i_Ent,pev_health, LAPTOPSENTRY_HEALTH);
	
	
	new Float:vOrigin[3];	//start origin.
	new Float:vVelocity[3];	//velocity.

	//get player origin
	pev( id, pev_origin, vOrigin );
	
	//set velocity for throw.
	velocity_by_aim( id, 600, vVelocity);
	set_pev(i_Ent,pev_velocity,vVelocity);

	//fix angle.
	//set_pev(i_Ent,pev_fixangle,1);

	new const Float:minsize[3] = {-8.0, -8.0, -0.0};
	new const Float:maxsize[3] = {8.0, 8.0, 8.0};

	//set hitbox and origin.
	engfunc(EngFunc_SetSize,i_Ent,minsize,maxsize);
	engfunc(EngFunc_SetOrigin, i_Ent, vOrigin );

	//set owner and team.
	set_pev(i_Ent,LAPTOPSENTRY_OWNER, id );
	set_pev(i_Ent,LAPTOPSENTRY_TEAM,get_user_team(id));

	new Float:fCurrTime = get_gametime();

	//set sequance.
	set_pev(i_Ent,LAPTOPSENTRY_SEQUENCE,SENTRY_DEPLOYING);
	
	set_pev(i_Ent,pev_nextthink, fCurrTime + 0.3);
	return i_Ent;
}

stock SentrySearching(ent)
{
	new Float:Origin[3],Float:pOrigin[3];		//sentry origin, player origin.
	new Float:mindist = LAPTOPSENTRY_SEARCHAREA;	//shortest distance.
	new Float:distance;				//distance.
	new bool:result[4];
	new owner = pev(ent,LAPTOPSENTRY_OWNER);		//get owner.
	new entid = 0,target = -1;			//ents and target id.
	pev(ent,pev_origin,Origin);			//get sentry origin.
	SentryAnimation(ent,sentry_spin);		//play animation.

	//get entity id in sphere.
	entid = find_ent_in_sphere(entid,Origin,LAPTOPSENTRY_SEARCHAREA);
	
	//can get?
	if(entid == 0) return -1;

	while(entid != 0)
	{
		if(!pev_valid(entid))
		{
			entid = find_ent_in_sphere(entid,Origin,LAPTOPSENTRY_SEARCHAREA);
			continue;
		}
		//players or monsters?
		if((pev(entid, pev_flags) & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER)))
		{
			result[0] = (entid == owner)?true:false;
			result[1] = (get_pcvar_num(g_FF)==0 && get_user_team(entid) == pev(ent,LAPTOPSENTRY_TEAM)) ? true : false;
			result[2] = get_entity_godmode(entid);
			result[3] = (!get_entity_alive(entid))? true:false;
			//Through owner, friendly and godmode ents. (wpn_friendlyfire == 0)
			if(result[0] || result[1] || result[2] || result[3])
			{
				entid = find_ent_in_sphere(entid,Origin,LAPTOPSENTRY_SEARCHAREA);
				continue;
			}
			//get player origin.
			pev(entid,pev_origin,pOrigin);
			
			//find sentry and distance of a player.
			distance = get_distance_f(pOrigin,Origin);

			//Is there it to the shortest distance?
			//Is there an obstacle on the way?
			if(distance < mindist && TraceLine(ent,entid,Origin,pOrigin))
			{
				mindist = distance;
				target = entid;
			}
		}

		//next player in spehre.
		entid = find_ent_in_sphere(entid,Origin,LAPTOPSENTRY_SEARCHAREA);
	}
	//return target id.
	return target;
}

bool:get_entity_alive(ent)
{
	new deadflag = pev(ent,pev_deadflag);
	if(deadflag != DEAD_NO)
		return false;
	return true;
}

bool:get_entity_godmode(ent)
{
	new flags = pev(ent, pev_flags);
	new Float:takeDamage;
	pev(ent, pev_takedamage, takeDamage);
	if(flags & FL_GODMODE || takeDamage == 0.0){ 
		return true;
	}
	return false;
}

bool:TraceLine(ent,tid,Float:sentry[3],Float:target[3])
{
	new flags;
	static iHit,Float:fFraction;
	engfunc(EngFunc_TraceLine, sentry, target, DONT_IGNORE_MONSTERS, ent, 0);

	get_tr2(0, TR_flFraction, fFraction);
	iHit = get_tr2(0, TR_pHit);
	
	if (fFraction < 1.0)
	{
		if(!pev_valid(iHit)) return false;
		flags = pev(iHit, pev_flags);
		if(!(flags & (FL_CLIENT | FL_FAKECLIENT | FL_MONSTER)))
			return false;
		if(tid != iHit) return false;
		//if(iHit == pev(ent,LAPTOPSENTRY_OWNER)) return false;
	}
	return true;
}

SentryAttacking(ent,target)
{
	new Float:Origin[3],Float:tOrigin[3];
	pev(ent,pev_origin,Origin);
	pev(target,pev_origin,tOrigin);
	SentryTurnToTarget(ent,Origin,target,tOrigin);
	SentryTracer(Origin,tOrigin);
	SentryDamageToPlayer(ent,Origin,target);
	emit_sound(ent, CHAN_ITEM,g_SOUND[0],1.0,ATTN_NORM,0,PITCH_NORM);
	SentryAnimation(ent,sentry_fire);
}

SentryTracer(Float:start[3], Float:end[3]) 
{
	engfunc(EngFunc_MessageBegin,MSG_PAS, SVC_TEMPENTITY, start, 0);
	write_byte(TE_TRACER);
	engfunc(EngFunc_WriteCoord, start[0]);
	engfunc(EngFunc_WriteCoord, start[1]);
	engfunc(EngFunc_WriteCoord, start[2]+8.0);
	engfunc(EngFunc_WriteCoord, end[0]);
	engfunc(EngFunc_WriteCoord, end[1]);
	engfunc(EngFunc_WriteCoord, end[2]);
	message_end();
}

stock SentryDamageToPlayer(sentry,Float:sOrigin[3], target)
{
	if(!get_entity_alive(target)) return;
	new damage = random_num(LAPTOPSENTRY_SHOTDMGMIN,LAPTOPSENTRY_SHOTDMGMAX);
	new newHealth = get_entity_health(target) - damage;

	if (newHealth <= 0)
	{
		new owner = pev(sentry, LAPTOPSENTRY_OWNER);
		wpn_kill_user(g_wpnid,target,owner);		
	}

	set_entity_health(target, newHealth);

	engfunc(EngFunc_MessageBegin,MSG_ONE_UNRELIABLE, g_msgDamage, {0,0,0}, target);
	write_byte(damage);
	write_byte(damage);
	write_long(DMG_BULLET);
	engfunc(EngFunc_WriteCoord,sOrigin[0]);
	engfunc(EngFunc_WriteCoord,sOrigin[1]);
	engfunc(EngFunc_WriteCoord,sOrigin[2]);
	message_end();
	return;
}

stock set_entity_health(index, health)
{
	health > 0 ? set_pev(index, pev_health, float(health)) : 0;
	return 1;
}

stock get_entity_health(index)
{
	new Float:health;
	pev(index, pev_health, health);
	return floatround(health);
}

public LaptopSentry_Think(ent)
{
	if(!pev_valid(ent))return FMRES_IGNORED;
	static entname[32],target;
	static const size = sizeof(entname)-1;
	pev(ent, pev_classname, entname, size);
	if ( !equal( entname, g_WPN_CLASS ) ) return FMRES_IGNORED;
	static Float:fCurrTime;
	fCurrTime = get_gametime();
	if(fCurrTime <= pev(ent,pev_nextthink)) return FMRES_IGNORED;
	switch(pev(ent,LAPTOPSENTRY_SEQUENCE))
	{
		case SENTRY_DEPLOYING:
		{
			static Float:vl[3];
			pev(ent,pev_velocity,vl);
			xs_vec_mul_scalar(vl,0.8,vl);
			set_pev(ent,pev_velocity,vl);
			if(xs_vec_len(vl) < 0.1)
			{
				set_pev(ent,pev_solid,SOLID_BBOX);
				set_pev(ent,LAPTOPSENTRY_SEQUENCE,SENTRY_SEARCHING);
			}
		}
		case SENTRY_SEARCHING:
		{
			if((target = SentrySearching(ent)) != -1)
			{
				set_pev(ent,LAPTOPSENTRY_SEQUENCE,SENTRY_FIRING);
				set_pev(ent,LAPTOPSENTRY_COUNT,fCurrTime + LAPTOPSENTRY_DELAY);
				set_pev(ent,pev_enemy,target);
			}
		}
		case SENTRY_FIRING:
		{
			if(fCurrTime > pev(ent,LAPTOPSENTRY_COUNT))
			{
				if((target = SentrySearching(ent)) != -1)
				{
					set_pev(ent,pev_enemy,target);
				}else{
					set_pev(ent,LAPTOPSENTRY_SEQUENCE,SENTRY_SEARCHING);
				}
				SentryAttacking(ent,pev(ent,pev_enemy));
				set_pev(ent,LAPTOPSENTRY_COUNT,fCurrTime + LAPTOPSENTRY_REFIRERATE);
			}
		}
		case SENTRY_DEAD:
		{
			wpn_radius_damage(g_wpnid,pev(ent,LAPTOPSENTRY_OWNER),ent,200.0,80.0,DMG_BLAST);
			CreateExplosion(ent);
			g_second[pev(ent,LAPTOPSENTRY_OWNER)] = false;
			set_pev(ent,pev_nextthink,0.0);
			RemoveEntity(ent);
		}
		
	}
	if ( pev_valid(ent) )
	{
		static Float:fHealth;
		pev(ent,pev_health,fHealth);
		if(fHealth < 0)
		{
			set_pev(ent,LAPTOPSENTRY_SEQUENCE,SENTRY_DEAD);
		}
		set_pev(ent,pev_nextthink,fCurrTime + 0.1);
	}


	return FMRES_IGNORED;
}

SentryAnimation(ent,sequence)
{
	set_pev(ent,pev_sequence,sequence);
	set_pev(ent,pev_frame,float((pev(ent,pev_frame) + 1) % 8));
}

public RemoveAllSentry(id)
{
	new ent = g_MaxPL + 1;
	new clsname[32];
	static const clslen = sizeof(clsname) - 1;
	while( ( ent = engfunc( EngFunc_FindEntityByString, ent, "classname", g_WPN_CLASS ) ) )
	{
		if (id)
		{
			if(pev( ent, LAPTOPSENTRY_OWNER ) != id)
				continue;
			clsname[0] = '^0'
			pev( ent, pev_classname, clsname, clslen);
                
			if ( equali( clsname, g_WPN_CLASS ) )
			{
				RemoveEntity(ent);
			}
		}
		else
			set_pev(ent, pev_flags, FL_KILLME );
	}
	g_second[id] = false;
}

SentryTurnToTarget(ent,Float:sOrigin[3], target, Float:tOrigin[3])
{
	if (target)
	{
		new Float:newAngle[3]
		pev(ent, pev_angles, newAngle);
		new Float:x = tOrigin[0] - sOrigin[0];
		new Float:z = tOrigin[1] - sOrigin[1];

		new Float:radians = floatatan(z/x, radian);
		newAngle[1] = radians * g_OneEightyThroughPI;
		if (tOrigin[0] < sOrigin[0])
			newAngle[1] -= 180.0;

		set_pev(ent, LAPTOPSENTRY_ANGLE, newAngle[1]);

		new Float:h = tOrigin[2] - sOrigin[2];
		new Float:b = vector_distance(sOrigin, tOrigin);
		radians = floatatan(h/b, radian);
		new Float:degs = radians * g_OneEightyThroughPI;

		new Float:RADIUS = LAPTOPSENTRY_TILTRADIUS;
		new Float:degreeByte = RADIUS/256.0;
		new Float:tilt = 127.0 - degreeByte * degs;

		set_pev(ent, pev_controller_0, floatround(tilt));
		set_pev(ent, pev_angles, newAngle);
	}
}

CreateExplosion(ent)
{
	
	new Float:vOrigin[3];
	pev(ent,pev_origin,vOrigin);

	engfunc(EngFunc_MessageBegin,MSG_BROADCAST, SVC_TEMPENTITY, vOrigin, 0);
	write_byte(TE_EXPLOSION);
	engfunc(EngFunc_WriteCoord,vOrigin[0]);
	engfunc(EngFunc_WriteCoord,vOrigin[1]);
	engfunc(EngFunc_WriteCoord,vOrigin[2]);
	write_short(g_boom);
	write_byte(50);
	write_byte(15);
	write_byte(0);
	message_end();
}
