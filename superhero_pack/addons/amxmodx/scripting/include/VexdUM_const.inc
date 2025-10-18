/*
 * VexdUM defines/constants
 *
 * (c) 2002-2010 - AMX Mod Team
 * This file is provided as is (no warranties).
 *
 */

#if defined _vexdum_const_included
  #endinput
#endif
#define _vexdum_const_included

/*** Entvars Integer ***/
/*** To use with entity_get_int/entity_set_int. ***/
enum {
  EV_INT_gamestate,
  EV_INT_oldbuttons,
  EV_INT_groupinfo,
  EV_INT_iuser1,
  EV_INT_iuser2,
  EV_INT_iuser3,
  EV_INT_iuser4,
  EV_INT_weaponanim,
  EV_INT_pushmsec,
  EV_INT_bInDuck,
  EV_INT_flTimeStepSound,
  EV_INT_flSwimTime,
  EV_INT_flDuckTime,
  EV_INT_iStepLeft,
  EV_INT_movetype,
  EV_INT_solid,
  EV_INT_skin,
  EV_INT_body,
  EV_INT_effects,
  EV_INT_light_level,
  EV_INT_sequence,
  EV_INT_gaitsequence,
  EV_INT_modelindex,
  EV_INT_playerclass,
  EV_INT_waterlevel,
  EV_INT_watertype,
  EV_INT_spawnflags,
  EV_INT_flags,
  EV_INT_colormap,
  EV_INT_team,
  EV_INT_fixangle,
  EV_INT_weapons,
  EV_INT_rendermode,
  EV_INT_renderfx,
  EV_INT_button,
  EV_INT_impulse,
  EV_INT_deadflag,
};

/*** Entvars Float ***/
/*** To use with entity_get_float/entity_set_float. ***/
enum {
  EV_FL_impacttime,
  EV_FL_starttime,
  EV_FL_idealpitch,
  EV_FL_pitch_speed,
  EV_FL_ideal_yaw,
  EV_FL_yaw_speed,
  EV_FL_ltime,
  EV_FL_nextthink,
  EV_FL_gravity,
  EV_FL_friction,
  EV_FL_frame,
  EV_FL_animtime,
  EV_FL_framerate,
  EV_FL_health,
  EV_FL_frags,
  EV_FL_takedamage,
  EV_FL_max_health,
  EV_FL_teleport_time,
  EV_FL_armortype,
  EV_FL_armorvalue,
  EV_FL_dmg_take,
  EV_FL_dmg_save,
  EV_FL_dmg,
  EV_FL_dmgtime,
  EV_FL_speed,
  EV_FL_air_finished,
  EV_FL_pain_finished,
  EV_FL_radsuit_finished,
  EV_FL_scale,
  EV_FL_renderamt,
  EV_FL_maxspeed,
  EV_FL_fov,
  EV_FL_flFallVelocity,
  EV_FL_fuser1,
  EV_FL_fuser2,
  EV_FL_fuser3,
  EV_FL_fuser4,
};

/*** Entvars Vector ***/
/*** To use with entity_get_vector/entity_set_vector. ***/
enum {
  EV_VEC_origin,
  EV_VEC_oldorigin,
  EV_VEC_velocity,
  EV_VEC_basevelocity,
  EV_VEC_clbasevelocity,
  EV_VEC_movedir,
  EV_VEC_angles,
  EV_VEC_avelocity,
  EV_VEC_punchangle,
  EV_VEC_v_angle,
  EV_VEC_endpos,
  EV_VEC_startpos,
  EV_VEC_absmin,
  EV_VEC_absmax,
  EV_VEC_mins,
  EV_VEC_maxs,
  EV_VEC_size,
  EV_VEC_rendercolor,
  EV_VEC_view_ofs,
  EV_VEC_vuser1,
  EV_VEC_vuser2,
  EV_VEC_vuser3,
  EV_VEC_vuser4,
};

/*** Entvars Edict ***/
/*** To use with entity_get_edict/entity_set_edict. ***/
enum {
  EV_ENT_chain,
  EV_ENT_dmg_inflictor,
  EV_ENT_enemy,
  EV_ENT_aiment,
  EV_ENT_owner,
  EV_ENT_groundentity,
  EV_ENT_pContainingEntity,
  EV_ENT_euser1,
  EV_ENT_euser2,
  EV_ENT_euser3,
  EV_ENT_euser4,
};

/*** Entvars String ***/
/*** To use with entity_get_string/entity_set_string. ***/
enum {
  EV_SZ_classname,
  EV_SZ_globalname,
  EV_SZ_model,
  EV_SZ_target,
  EV_SZ_targetname,
  EV_SZ_netname,
  EV_SZ_message,
  EV_SZ_noise,
  EV_SZ_noise1,
  EV_SZ_noise2,
  EV_SZ_noise3,
  EV_SZ_viewmodel,
  EV_SZ_weaponmodel,
};

/*** Entvars Byte ***/
/*** To use with entity_get_byte/entity_set_byte. ***/
enum {
  EV_BYTE_controller0,
  EV_BYTE_controller1,
  EV_BYTE_controller2,
  EV_BYTE_controller3,
  EV_BYTE_blending0,
  EV_BYTE_blending1,
};

/*** Globalvars Integer ***/
/*** To use with global_get_int(). ***/
enum {
  GV_INT_trace_hitgroup,
  GV_INT_trace_flags,
  GV_INT_msg_entity,
  GV_INT_cdAudioTrack,
  GV_INT_maxClients,
  GV_INT_maxEntities,
};

/*** Globalvars Float ***/
/*** To use with global_get_float(). ***/
enum {
  GV_FL_time,
  GV_FL_frametime,
  GV_FL_force_retouch,
  GV_FL_deathmatch,
  GV_FL_coop,
  GV_FL_teamplay,
  GV_FL_serverflags,
  GV_FL_found_secrets,
  GV_FL_trace_allsolid,
  GV_FL_trace_startsolid,
  GV_FL_trace_fraction,
  GV_FL_trace_plane_dist,
  GV_FL_trace_inopen,
  GV_FL_trace_inwater,
};

/*** Globalvars Vector ***/
/*** To use with global_get_vector(). ***/
enum {
  GV_VEC_v_forward,
  GV_VEC_v_up,
  GV_VEC_v_right,
  GV_VEC_trace_endpos,
  GV_VEC_trace_plane_normal,
  GV_VEC_vecLandmarkOffset,
};

/*** Globalvars Edict ***/
/*** To use with global_get_edict(). ***/
enum {
  GV_ENT_trace_ent,
};

/*** Globalvars String ***/
/*** To use with global_get_string(). ***/
enum {
  GV_SZ_mapname,
  GV_SZ_startspot,
};

/*** TraceLine Integer ***/
/*** To use with traceline_get_int/traceline_set_int. ***/
enum {
  TR_INT_fAllSolid,    /* If true, plane is not valid */
  TR_INT_fStartSolid,  /* If true, the initial point was in a solid area */
  TR_INT_fInOpen,
  TR_INT_fInWater,
  TR_INT_iHitgroup,    /* 0 == Generic, non zero is specific body part */
};

/*** TraceLine Float ***/
/*** To use with traceline_get_float/traceline_set_float. ***/
enum {
  TR_FL_flFraction,  /* Time completed, 1.0 = didn't hit anything */
  TR_FL_flPlaneDist,
};

/*** TraceLine Vector ***/
/*** To use with traceline_get_vector/traceline_set_vector. ***/
enum {
  TR_VEC_vecEndPos,       /* Final position */
  TR_VEC_vecPlaneNormal,  /* Surface normal at impact */
};

/*** TraceLine Edict ***/
/*** To use with traceline_get_edict/traceline_set_edict. ***/
enum {
  TR_ENT_pHit,  /* Entity the surface is on */
};

// All traces types.
enum TraceResult {
  TR_ENT_HitEntityID,   /* Entity ID if found or 0. */

  TR_INT_StartSolid,    /* Initial point in a solid area. */
  TR_INT_AllSolid,      /* If true, plane is not valid. */
  TR_INT_InOpen,        /* Initial point in open (in the world). */
  TR_INT_InWater,       /* Initial point in water. */
  TR_INT_HitGroupID,    /* Hit group ID of body part (see HIT_* from "amxconst.inc"). */

  TR_FL_Fraction,       /* Fraction level (1.0 = didn't hit something) */
  TR_FL_PlaneDistance,  /* Plane distance. */

  TR_VEC_EndPosition,   /* End position. */
  TR_VEC_PlaneNormal    /* Plane surface at impact. */
};

/*** For global_get_int(GV_INT_trace_flags) ***/
#define FTRACE_SIMPLEBOX     (1<<0)  /* Traceline with a simple box */

/*** Speak flags ***/
/*** To use with get_speak/set_speak. ***/
#define SPEAK_NORMAL     0  /* Speak normal */
#define SPEAK_MUTED      1  /* Muted (can't speak) */
#define SPEAK_ALL        2  /* Can speak to all */
#define SPEAK_LISTENALL  4  /* Can listen all */

/*** Entity: button flags ***/
/*** To use with entity_get_int/entity_set_int and EV_INT_button/EV_INT_oldbuttons iVars. ***/
#define IN_ATTACK     (1<<0)   /* Attack key */
#define IN_JUMP       (1<<1)   /* Jump key */
#define IN_DUCK       (1<<2)   /* Duck key */
#define IN_FORWARD    (1<<3)   /* Forward key */
#define IN_BACK       (1<<4)   /* Backward key */
#define IN_USE        (1<<5)   /* Use key */
#define IN_CANCEL     (1<<6)   /* Cancel key (esc) */
#define IN_LEFT       (1<<7)   /* Leftward */
#define IN_RIGHT      (1<<8)   /* Rightward */
#define IN_MOVELEFT   (1<<9)   /* Left dodge */
#define IN_MOVERIGHT  (1<<10)  /* Right dodge */
#define IN_ATTACK2    (1<<11)  /* Attack 2 key */
#define IN_RUN        (1<<12)  /* Run key (walk) */
#define IN_RELOAD     (1<<13)  /* Reload key */
#define IN_ALT1       (1<<14)  /* Alt1 key */
#define IN_SCORE      (1<<15)  /* Scoreboard key */

/*** Entity: flags ***/
/*** To use with entity_get_int/entity_set_int and EV_INT_flags iVar. ***/
#define FL_FLY            (1<<0)   /* Changes the SV_Movestep() behavior to not need to be on ground */
#define FL_SWIM           (1<<1)   /* Changes the SV_Movestep() behavior to not need to be on ground (but stay in water) */
#define FL_CONVEYOR       (1<<2)
#define FL_CLIENT         (1<<3)
#define FL_INWATER        (1<<4)
#define FL_MONSTER        (1<<5)
#define FL_GODMODE        (1<<6)
#define FL_NOTARGET       (1<<7)
#define FL_SKIPLOCALHOST  (1<<8)   /* Don't send entity to local host, it's predicting this entity itself */
#define FL_ONGROUND       (1<<9)   /* At rest/On the ground */
#define FL_PARTIALGROUND  (1<<10)  /* Not all corners are valid */
#define FL_WATERJUMP      (1<<11)  /* Player jumping out of water */
#define FL_FROZEN         (1<<12)  /* Player is frozen for 3rd person camera */
#define FL_FAKECLIENT     (1<<13)  /* JAC: fake client, simulated server side. Don't send network messages to them */
#define FL_DUCKING        (1<<14)  /* Player flag. Player is fully crouched */
#define FL_FLOAT          (1<<15)  /* Apply floating force to this entity when in water */
#define FL_GRAPHED        (1<<16)  /* Worldgraph has this ent listed as something that blocks a connection */
#define FL_IMMUNE_WATER   (1<<17)
#define FL_IMMUNE_SLIME   (1<<18)
#define FL_IMMUNE_LAVA    (1<<19)
#define FL_PROXY          (1<<20)  /* This is a spectator proxy */
#define FL_ALWAYSTHINK    (1<<21)  /* Brush model flag. Call think every frame regardless of nextthink - ltime (for constantly changing velocity/path) */
#define FL_BASEVELOCITY   (1<<22)  /* Base velocity has been applied this frame (used to convert base velocity into momentum) */
#define FL_MONSTERCLIP    (1<<23)  /* Only collide in with monsters who have FL_MONSTERCLIP set */
#define FL_ONTRAIN        (1<<24)  /* Player is _controlling_ a train, so movement commands should be ignored on client during prediction */
#define FL_WORLDBRUSH     (1<<25)  /* Not moveable/removeable brush entity (really part of the world, but represented as an entity for transparency or something) */
#define FL_SPECTATOR      (1<<26)  /* This client is a spectator, don't run touch functions, etc. */
#define FL_CUSTOMENTITY   (1<<29)  /* This is a custom entity */
#define FL_KILLME         (1<<30)  /* This entity is marked for death. This allows the engine to kill ents at the appropriate time */
#define FL_DORMANT        (1<<31)  /* Entity is dormant, no updates to client */

/*** Entity: spawn flags ***/
/*** To use with entity_get_int/entity_set_int and EV_INT_spawnflags iVar. ***/
/* func_train */
#define SF_TRAIN_WAIT_RETRIGGER         1
#define SF_TRAIN_START_ON               4  /* Train is initially moving */
#define SF_TRAIN_PASSABLE               8  /* Train is not solid (used to make water trains) */
/* func_wall_toggle */
#define SF_WALL_START_OFF               0x0001
/* func_converyor */
#define SF_CONVEYOR_VISUAL              0x0001
#define SF_CONVEYOR_NOTSOLID            0x0002
/* func_button */
#define SF_BUTTON_DONTMOVE              1
#define SF_BUTTON_TOGGLE                32   /* Button stays pushed until reactivated */
#define SF_BUTTON_SPARK_IF_OFF          64   /* Button sparks in OFF state */
#define SF_BUTTON_TOUCH_ONLY            256  /* Button only fires as a result of USE key */
/* func_rot_button */
#define SF_ROTBUTTON_NOTSOLID           1
/* env_global */
#define SF_GLOBAL_SET                   1  /* Set global state to initial state on spawn */
/* multisource */
#define SF_MULTI_INIT                   1
/* momentary_rot_button */
#define SF_MOMENTARY_DOOR               0x0001
/* button_target */
#define SF_BTARGET_USE                  0x0001
#define SF_BTARGET_ON                   0x0002
/* func_door, func_water, func_door_rotating, momementary_door */
#define SF_DOOR_ROTATE_Y                0
#define SF_DOOR_START_OPEN              1
#define SF_DOOR_ROTATE_BACKWARDS        2
#define SF_DOOR_PASSABLE                8
#define SF_DOOR_ONEWAY                  16
#define SF_DOOR_NO_AUTO_RETURN          32
#define SF_DOOR_ROTATE_Z                64
#define SF_DOOR_ROTATE_X                128
#define SF_DOOR_USE_ONLY                256  /* Door must be opened by player's use button */
#define SF_DOOR_NOMONSTERS              512  /* Monster can't open */
#define SF_DOOR_SILENT                  0x80000000
/* gibshooter */
#define SF_GIBSHOOTER_REPEATABLE        1  /* Allows a gibshooter to be refired */
/* env_funnel */
#define SF_FUNNEL_REVERSE               1  /* Funnel effect repels particles instead of attracting them */
/* env_bubbles */
#define SF_BUBBLES_STARTOFF             0x0001
/* env_blood */
#define SF_BLOOD_RANDOM                 0x0001
#define SF_BLOOD_STREAM                 0x0002
#define SF_BLOOD_PLAYER                 0x0004
#define SF_BLOOD_DECAL                  0x0008
/* env_shake */
#define SF_SHAKE_EVERYONE               0x0001  /* Don't check radius */
#define SF_SHAKE_DISRUPT                0x0002  /* Disrupt controls */
#define SF_SHAKE_INAIR                  0x0004  /* Shake players in air */
/* env_fade */
#define SF_FADE_IN                      0x0001  /* Fade in, not out */
#define SF_FADE_MODULATE                0x0002  /* Modulate, don't blend */
#define SF_FADE_ONLYONE                 0x0004
/* env_beam, env_lightning */
#define SF_BEAM_STARTON                 0x0001
#define SF_BEAM_TOGGLE                  0x0002
#define SF_BEAM_RANDOM                  0x0004
#define SF_BEAM_RING                    0x0008
#define SF_BEAM_SPARKSTART              0x0010
#define SF_BEAM_SPARKEND                0x0020
#define SF_BEAM_DECALS                  0x0040
#define SF_BEAM_SHADEIN                 0x0080
#define SF_BEAM_SHADEOUT                0x0100
#define SF_BEAM_TEMPORARY               0x8000
/* env_sprite */
#define SF_SPRITE_STARTON               0x0001
#define SF_SPRITE_ONCE                  0x0002
#define SF_SPRITE_TEMPORARY             0x8000
/* env_message */
#define SF_MESSAGE_ONCE                 0x0001  /* Fade in, not out */
#define SF_MESSAGE_ALL                  0x0002  /* Send to all clients */
/* env_explosion */
#define SF_ENVEXPLOSION_NODAMAGE        (1<<0)  /* When set, ENV_EXPLOSION will not actually inflict damage */
#define SF_ENVEXPLOSION_REPEATABLE      (1<<1)  /* Can this entity be refired? */
#define SF_ENVEXPLOSION_NOFIREBALL      (1<<2)  /* Don't draw the fireball */
#define SF_ENVEXPLOSION_NOSMOKE         (1<<3)  /* Don't draw the smoke */
#define SF_ENVEXPLOSION_NODECAL         (1<<4)  /* Don't make a scorch mark */
#define SF_ENVEXPLOSION_NOSPARKS        (1<<5)  /* Don't make a scorch mark */
/* func_tank */
#define SF_TANK_ACTIVE                  0x0001
#define SF_TANK_PLAYER                  0x0002
#define SF_TANK_HUMANS                  0x0004
#define SF_TANK_ALIENS                  0x0008
#define SF_TANK_LINEOFSIGHT             0x0010
#define SF_TANK_CANCONTROL              0x0020
#define SF_TANK_SOUNDON                 0x8000
/* grenade */
#define SF_DETONATE                     0x0001
/* item_suit */
#define SF_SUIT_SHORTLOGON              0x0001
/* game_score */
#define SF_SCORE_NEGATIVE               0x0001
#define SF_SCORE_TEAM                   0x0002
/* game_text */
#define SF_ENVTEXT_ALLPLAYERS           0x0001
/* game_team_master */
#define SF_TEAMMASTER_FIREONCE          0x0001
#define SF_TEAMMASTER_ANYTEAM           0x0002
/* game_team_set */
#define SF_TEAMSET_FIREONCE             0x0001
#define SF_TEAMSET_CLEARTEAM            0x0002
/* game_player_hurt */
#define SF_PKILL_FIREONCE               0x0001
/* game_counter */
#define SF_GAMECOUNT_FIREONCE           0x0001
#define SF_GAMECOUNT_RESET              0x0002
/* game_player_equip */
#define SF_PLAYEREQUIP_USEONLY          0x0001
/* game_player_team */
#define SF_PTEAM_FIREONCE               0x0001
#define SF_PTEAM_KILL                   0x0002
#define SF_PTEAM_GIB                    0x0004
/* func_trackchange */
#define SF_PLAT_TOGGLE                  0x0001
#define SF_TRACK_ACTIVATETRAIN          0x00000001
#define SF_TRACK_RELINK                 0x00000002
#define SF_TRACK_ROTMOVE                0x00000004
#define SF_TRACK_STARTBOTTOM            0x00000008
#define SF_TRACK_DONT_MOVE              0x00000010
/* func_tracktrain */
#define SF_TRACKTRAIN_NOPITCH           0x0001
#define SF_TRACKTRAIN_NOCONTROL         0x0002
#define SF_TRACKTRAIN_FORWARDONLY       0x0004
#define SF_TRACKTRAIN_PASSABLE          0x0008
#define SF_PATH_DISABLED                0x00000001
#define SF_PATH_FIREONCE                0x00000002
#define SF_PATH_ALTREVERSE              0x00000004
#define SF_PATH_DISABLE_TRAIN           0x00000008
#define SF_PATH_ALTERNATE               0x00008000
#define SF_CORNER_WAITFORTRIG           0x001
#define SF_CORNER_TELEPORT              0x002
#define SF_CORNER_FIREONCE              0x004
/* trigger_push */
#define SF_TRIGGER_PUSH_START_OFF       2   /* Spawnflag that makes trigger_push spawn turned OFF */
/* trigger_hurt */
#define SF_TRIGGER_HURT_TARGETONCE      1   /* Only fire hurt target once */
#define SF_TRIGGER_HURT_START_OFF       2   /* Spawnflag that makes trigger_push spawn turned OFF */
#define SF_TRIGGER_HURT_NO_CLIENTS      8   /* Spawnflag that makes trigger_push spawn turned OFF */
#define SF_TRIGGER_HURT_CLIENTONLYFIRE	16  /* Trigger hurt will only fire its target if it is hurting a client */
#define SF_TRIGGER_HURT_CLIENTONLYTOUCH 32  /* Only clients may touch this trigger */
/* trigger_auto */
#define SF_AUTO_FIREONCE                0x0001
/* trigger_relay */
#define SF_RELAY_FIREONCE               0x0001
/* multi_manager */
#define SF_MULTIMAN_CLONE               0x80000000
#define SF_MULTIMAN_THREAD              0x00000001
/* env_render
 * Flags to indicate masking off various render parameters that are normally copied to the targets. */
#define SF_RENDER_MASKFX                (1<<0)
#define SF_RENDER_MASKAMT               (1<<1)
#define SF_RENDER_MASKMODE              (1<<2)
#define SF_RENDER_MASKCOLOR             (1<<3)
/* trigger_changelevel */
#define SF_CHANGELEVEL_USEONLY          0x0002
/* trigger_endsection */
#define SF_ENDSECTION_USEONLY           0x0001
/* trigger_camera */
#define SF_CAMERA_PLAYER_POSITION       1
#define SF_CAMERA_PLAYER_TARGET         2
#define SF_CAMERA_PLAYER_TAKECONTROL    4
/* func_rotating */
#define SF_BRUSH_ROTATE_Y_AXIS          0
#define SF_BRUSH_ROTATE_INSTANT         1
#define SF_BRUSH_ROTATE_BACKWARDS       2
#define SF_BRUSH_ROTATE_Z_AXIS          4
#define SF_BRUSH_ROTATE_X_AXIS          8
#define SF_PENDULUM_AUTO_RETURN         16
#define SF_PENDULUM_PASSABLE            32
#define SF_BRUSH_ROTATE_SMALLRADIUS     128
#define SF_BRUSH_ROTATE_MEDIUMRADIUS    256
#define SF_BRUSH_ROTATE_LARGERADIUS     512
/* triggers */
#define SF_TRIGGER_ALLOWMONSTERS        1    /* Monsters allowed to fire this trigger */
#define SF_TRIGGER_NOCLIENTS            2    /* Players not allowed to fire this trigger */
#define SF_TRIGGER_PUSHABLES            4    /* Only pushables can fire this trigger */
#define SF_TRIG_PUSH_ONCE               1
/* func_breakable */
#define SF_BREAK_TRIGGER_ONLY           1    /* May only be broken by trigger */
#define SF_BREAK_TOUCH                  2    /* Can be "crashed through" by running player (plate glass) */
#define SF_BREAK_PRESSURE               4    /* Can be broken by a player standing on it */
#define SF_BREAK_CROWBAR                256  /* Instant break if hit with crowbar */
/* func_pushable
 * It's also func_breakable, so don't collide with those flags. */
#define SF_PUSH_BREAKABLE               128
/* light_spawn */
#define SF_LIGHT_START_OFF              1
#define SPAWNFLAG_NOMESSAGE             1
#define SPAWNFLAG_NOTOUCH               1
#define SPAWNFLAG_DROIDONLY             4
#define SPAWNFLAG_USEONLY               1    /* Can't be touched, must be used (buttons) */
/* Monster Spawnflags */
#define SF_MONSTER_WAIT_TILL_SEEN       1    /* Spawnflag that makes monsters wait until player can see them before attacking */
#define SF_MONSTER_GAG                  2    /* No idle noises from this monster */
#define SF_MONSTER_HITMONSTERCLIP       4
#define SF_MONSTER_PRISONER             16   /* Monster won't attack anyone, no one will attacke him */
#define SF_MONSTER_WAIT_FOR_SCRIPT      128  /* Spawnflag that makes monsters wait to check for attacking until the script is done or they've been attacked */
#define SF_MONSTER_PREDISASTER          256  /* This is a predisaster scientist or barney; influences how they speak */
#define SF_MONSTER_FADECORPSE           512  /* Fade out corpse after death */
#define SF_MONSTER_FALL_TO_GROUND       0x80000000
#define SF_MONSTER_TURRET_AUTOACTIVATE  32
#define SF_MONSTER_TURRET_STARTINACTIVE 64
#define SF_MONSTER_WAIT_UNTIL_PROVOKED  64   /* Don't attack the player unless provoked */
/* info_decal */
#define SF_DECAL_NOTINDEATHMATCH        2048
/* worldspawn */
#define SF_WORLD_DARK                   0x0001   /* Fade from black at startup */
#define SF_WORLD_TITLE                  0x0002   /* Display game title at startup */
#define SF_WORLD_FORCETEAM              0x0004   /* Force teams */
#define SF_NORESPAWN                    (1<<30)  /* Set this bit on guns and stuff that should never respawn */

/*** Entity: movetype flags ***/
/*** To use with entity_get_int/entity_set_int and EV_INT_movetype iVar. ***/
#define MOVETYPE_NONE            0   /* Never moves */
#define MOVETYPE_ANGLENOCLIP     1   /* Movetype angle value noclip */
#define MOVETYPE_ANGLECLIP       2   /* Movetype angle value clip */
#define MOVETYPE_WALK            3   /* Player only. Moving on the ground */
#define MOVETYPE_STEP            4   /* Gravity, special edge handling. Monsters use this */
#define MOVETYPE_FLY             5   /* No gravity, but still collides with stuff */
#define MOVETYPE_TOSS            6   /* Gravity/Collisions */
#define MOVETYPE_PUSH            7   /* No clip to world, push and crush */
#define MOVETYPE_NOCLIP          8   /* No gravity, no collisions, still do velocity/avelocity */
#define MOVETYPE_FLYMISSILE      9   /* Extra size to monsters */
#define MOVETYPE_BOUNCE          10  /* Just like Toss, but reflect velocity when contacting surfaces */
#define MOVETYPE_BOUNCEMISSILE   11  /* Bounce w/o gravity */
#define MOVETYPE_FOLLOW          12  /* Track movement of aiment */
#define MOVETYPE_PUSHSTEP        13  /* BSP model that needs physics/world collisions (uses nearest hull for world collision) */

/*** Entity: solid flags ***/
/*** To use with entity_get_int/entity_set_int and EV_INT_solid iVar. ***/
#define SOLID_NOT       0  /* No interaction with other objects */
#define SOLID_TRIGGER   1  /* Touch on edge, but not blocking */
#define SOLID_BBOX      2  /* Touch on edge, block */
#define SOLID_SLIDEBOX  3  /* Touch on edge, but not an onground */
#define SOLID_BSP       4  /* BSP clip, touch on edge, block */

/*** Entity: effect flags ***/
/*** To use with entity_get_int/entity_set_int and EV_INT_effects iVar. ***/
#define EF_BRIGHTFIELD  1    /* Swirling cloud of particles */
#define EF_MUZZLEFLASH  2    /* Single frame ELIGHT on entity attachment 0 */
#define EF_BRIGHTLIGHT  4    /* DLIGHT centered at entity origin */
#define EF_DIMLIGHT     8    /* Player flashlight */
#define EF_INVLIGHT     16   /* Gets lighting from ceiling */
#define EF_NOINTERP     32   /* Don't interpolate the next frame */
#define EF_LIGHT        64   /* Rocket flare glow sprite */
#define EF_NODRAW       128  /* Don't draw entity */

/*** Entity: dead flags ***/
/*** To use with entity_get_int/entity_set_int and EV_INT_deadflag iVar. ***/
#define DEAD_NO           0  /* Alive */
#define DEAD_DYING        1  /* Playing death animation or still falling off of a ledge waiting to hit ground */
#define DEAD_DEAD         2  /* Dead. lying still 1 */
#define DEAD_RESPAWNABLE  3  /* Dead. lying still 2 */
#define DEAD_DISCARDBODY  4  /* Dead. lying still 3 */

/*** Damage values ***/
/*** To use with entity_get_float/entity_set_float and EV_FL_takedamage iVar or VexdUM damage functions. ***/
#define DAMAGE_NO   0.0
#define DAMAGE_YES  1.0
#define DAMAGE_AIM  2.0

/*** Damage flags ***/
/*** To use with write_long native... or VexdUM damage functions. ***/
#define DMG_GENERIC           0        /* Generic damage was done */
#define DMG_CRUSH         (1<<0)       /* Crushed by falling or moving object */
#define DMG_BULLET        (1<<1)       /* Shot */
#define DMG_SLASH         (1<<2)       /* Cut, clawed, stabbed */
#define DMG_BURN          (1<<3)       /* Heat burned */
#define DMG_FREEZE        (1<<4)       /* Frozen */
#define DMG_FALL          (1<<5)       /* Fell too far */
#define DMG_BLAST         (1<<6)       /* Explosive blast damage */
#define DMG_CLUB          (1<<7)       /* Crowbar, punch, headbutt */
#define DMG_SHOCK         (1<<8)       /* Electric shock */
#define DMG_SONIC         (1<<9)       /* Sound pulse shockwave */
#define DMG_ENERGYBEAM    (1<<10)      /* Laser or other high energy beam */
#define DMG_NEVERGIB      (1<<12)      /* With this bit OR'd in, no damage type will be able to gib victims upon death */
#define DMG_ALWAYSGIB     (1<<13)      /* With this bit OR'd in, any damage type can be made to gib victims upon death */
#define DMG_DROWN         (1<<14)      /* Drowning */
#define DMG_PARALYZE      (1<<15)      /* Slows affected creature down */
#define DMG_NERVEGAS      (1<<16)      /* Nerve toxins, very bad */
#define DMG_POISON        (1<<17)      /* Blood poisioning */
#define DMG_RADIATION     (1<<18)      /* Radiation exposure */
#define DMG_DROWNRECOVER  (1<<19)      /* Drowning recovery */
#define DMG_ACID          (1<<20)      /* Toxic chemicals or acid burns */
#define DMG_SLOWBURN      (1<<21)      /* In an oven */
#define DMG_SLOWFREEZE    (1<<22)      /* In a subzero freezer */
#define DMG_MORTAR        (1<<23)      /* Hit by air raid (done to distinguish grenade from mortar) */
#define DMG_TIMEBASED     (~(0x3fff))  /* Mask for time-based damage */

/*** For PointContents() ***/
#define CONTENTS_EMPTY            -1
#define CONTENTS_SOLID            -2
#define CONTENTS_WATER            -3
#define CONTENTS_SLIME            -4
#define CONTENTS_LAVA             -5
#define CONTENTS_SKY              -6
#define CONTENTS_ORIGIN           -7  /* Removed at csg time */
#define CONTENTS_CLIP             -8  /* Changed to contents_solid */
#define CONTENTS_CURRENT_0        -9
#define CONTENTS_CURRENT_90       -10
#define CONTENTS_CURRENT_180      -11
#define CONTENTS_CURRENT_270      -12
#define CONTENTS_CURRENT_UP       -13
#define CONTENTS_CURRENT_DOWN     -14
#define CONTENTS_TRANSLUCENT      -15
#define CONTENTS_LADDER           -16
#define CONTENT_FLYFIELD          -17
#define CONTENT_GRAVITY_FLYFIELD  -18
#define CONTENT_FOG               -19

/*** For trace_result() ***/
enum {
  TR_AllSolid,      /* (int) If true, plane is not valid */
  TR_StartSolid,    /* (int) If true, the initial point was in a solid area */
  TR_InOpen,        /* (int) */
  TR_InWater,       /* (int) */
  TR_Fraction,      /* (float) Time completed, 1.0 = didn't hit anything */
  TR_EndPos,        /* (vector) Final position */
  TR_PlaneDist,     /* (float) */
  TR_PlaneNormal,   /* (vector) Surface normal at impact */
  TR_Hit,           /* (entity) Entity the surface is on */
  TR_Hitgroup       /* (int) 0 == Generic, non zero is specific body part */
};

/*** For trace_hull() ***/
#define HULL_POINT  0
#define HULL_HUMAN  1
#define HULL_LARGE  2
#define HULL_HEAD   3

/*** For playback_event() ***/
#define FEV_NOTHOST   (1<<0)  /* Skip local host for event send */
#define FEV_RELIABLE  (1<<1)  /* Send the event reliably */
#define FEV_GLOBAL    (1<<2)  /* Don't restrict to PAS/PVS, send this event to _everybody_ on the server (useful for stopping CHAN_STATIC sounds started by clients) */
#define FEV_UPDATE    (1<<3)  /* If this client already has one of these events in its queue, just update the event instead of sending it as a duplicate */
#define FEV_HOSTONLY  (1<<4)  /* Only send to entity specified as the invoker */
#define FEV_SERVER    (1<<5)  /* Only send if the event was created on the server */
#define FEV_CLIENT    (1<<6)  /* Only issue event client side (from shared code) */

/*** DLLFunc type list ***/
/*** To use with dllfunc(). ***/
enum {
  DLLFunc_GameInit, /* void (void) */
  DLLFunc_Spawn,    /* int (edict_t *pent) */
  DLLFunc_Think,    /* void (edict_t *pent) */
  DLLFunc_Use,      /* void (edict_t *pentUsed, edict_t *pentOther) */
  DLLFunc_Touch,    /* void (edict_t *pentTouched, edict_t *pentOther) */
  DLLFunc_Blocked,  /* void (edict_t *pentBlocked, edict_t *pentOther) */

  /* You can pass in 0 for glb kvd handle or a kvd handle here. */
  DLLFunc_KeyValue,          /* void (edict_t *pentKeyvalue, KeyValueData *pkvd) */
  DLLFunc_SetAbsBox,         /* void (edict_t *pent) */
  DLLFunc_ClientConnect,     /* bool (edict_t *pEntity, const char *pszName, const char *pszAddress, char szRejectReason[128]) */
  DLLFunc_ClientDisconnect,  /* void (edict_t *pEntity) */
  DLLFunc_ClientKill,        /* void (edict_t *pEntity) */
  DLLFunc_ClientPutInServer, /* void (edict_t *pEntity) */
  DLLFunc_ClientCommand,     /* void (edict_t *pEntity) */
  DLLFunc_ServerDeactivate,  /* void (void) */
  DLLFunc_PlayerPreThink,    /* void (edict_t *pEntity) */
  DLLFunc_PlayerPostThink,   /* void (edict_t *pEntity) */
  DLLFunc_StartFrame,        /* void (void) */
  DLLFunc_ParmsNewLevel,     /* void (void) */
  DLLFunc_ParmsChangeLevel,  /* void (void) */

  /* Returns string describing current .dll.  E.g., TeamFotrress 2, Half-Life. */
  /* This also gets called when the server is queried for information (for example, by a server browser tool). */
  DLLFunc_GetGameDescription, /* const char * (void) */

  /* Spectator funcs */
  DLLFunc_SpectatorConnect,    /* void (edict_t *pEntity) */
  DLLFunc_SpectatorDisconnect, /* void (edict_t *pEntity) */
  DLLFunc_SpectatorThink,      /* void (edict_t *pEntity) */

  /* Notify game .dll that engine is going to shut down. Allows mod authors to set a breakpoint. */
  DLLFunc_Sys_Error, /* void (const char *error_string) */

  DLLFunc_PM_FindTextureType, /* char (char *name) */
  DLLFunc_RegisterEncoders,   /* void (void) */

  /* Enumerates player hulls. Returns 0 if the hull number doesn't exist, 1 otherwise. */
  DLLFunc_GetHullBounds, /* int (int hullnumber, float *mins, float *maxs) */

  /* Creates baselines for certain "unplaced" items. */
  DLLFunc_CreateInstBaselines,      /* void (void) */
  DLLFunc_pfnAllowLagCompensation,  /* int (void) */

  /* We know this does not fit with DLLFUNC(), but I don't want another native just for it. */
  MetaFunc_CallGameEntity, /* bool (plid_t plid, const char *entStr,entvars_t *pev) */

  DLLFunc_ClientUserInfoChanged, /* void (edict *pEntity, char *infobuffer) */

  /* You can pass in 0 for global cd handle or another cd handle here. */
  DLLFunc_UpdateClientData, /* void (const struct edict_s *ent, int sendweapons, struct clientdata_s *cd) */

  /* You can pass in 0 for global entity state handle or another entity state handle here. */
  DLLFunc_AddToFullPack,  /* int (struct entity_state_s *state, int e, edict_t *ent, edict_t *host, int hostflags, int player, unsigned char *pSet) */

  /* You can pass in 0 for global usercmd handle or another usercmd handle here. */
  DLLFunc_CmdStart,      /* void (const edict_t *player, const struct usercmd_s *cmd, unsigned int random_seed) */
  DLLFunc_CmdEnd,        /* void (const edict_t *player) */
  DLLFunc_CreateBaseline /* void (int player, int eindex, struct entity_state_s *baseline, struct edict_s *entity, int playermodelindex, vec3_t player_mins, vec3_t player_maxs) */
};

enum EntityState {
  ES_BOOL_Spectator,

  ES_BYTE_Flags,
  ES_BYTE_RenderColor,    // byte array[3], RGB value
  ES_BYTE_Blending,    // byte array[4]
  ES_BYTE_Controller,    // byte array[4]

  ES_SHORT_Skin,
  ES_SHORT_Solid,

  ES_INT_Number,
  ES_INT_MessageNum,
  ES_INT_EntityType,
  ES_INT_MoveType,
  ES_INT_OnGround,
  ES_INT_OldButtons,
  ES_INT_UseHull,
  ES_INT_StepLeft,
  ES_INT_Sequence,
  ES_INT_GaitSequence,
  ES_INT_WeaponModel,
  ES_INT_WeaponAnimation,
  ES_INT_Owner,
  ES_INT_Body,
  ES_INT_AimEntity,
  ES_INT_ModelID,
  ES_INT_Team,
  ES_INT_PlayerClass,
  ES_INT_Health,
  ES_INT_ColorMap,
  ES_INT_Effects,
  ES_INT_RenderMode,
  ES_INT_RenderFX,
  ES_INT_RenderAlpha,
  ES_INT_User1,
  ES_INT_User2,
  ES_INT_User3,
  ES_INT_User4,

  ES_FL_Scale,
  ES_FL_Gravity,
  ES_FL_FallVelocity,
  ES_FL_Friction,
  ES_FL_FOV,
  ES_FL_StartTime,
  ES_FL_MessageTime,
  ES_FL_ImpactTime,
  ES_FL_AnimationTime,
  ES_FL_Frame,
  ES_FL_FrameRate,
  ES_FL_User1,
  ES_FL_User2,
  ES_FL_User3,
  ES_FL_User4,

  ES_VEC_Origin,
  ES_VEC_StartPosition,
  ES_VEC_EndPosition,
  ES_VEC_Mins,
  ES_VEC_Maxs,
  ES_VEC_Angles,
  ES_VEC_Velocity,
  ES_VEC_BaseVelocity,
  ES_VEC_User1,
  ES_VEC_User2,
  ES_VEC_User3,
  ES_VEC_User4
};

/*** For forward_return() ***/
#define FMV_STRING  1
#define FMV_FLOAT   2
#define FMV_CELL    3

/*** For alertmessage forward (atype parameter) ***/
enum {
  at_notice,
  at_console,    /* Same as at_notice, but forces a ConPrintf, not a message box */
  at_aiconsole,  /* Same as at_console, but only shown if developer level is 2! */
  at_warning,
  at_error,
  at_logged      /* Server print to console (only in multiplayer games) */
};

// To use with entity_get_boneposition native.
#define BONEID_HEAD 8
#define BONEID_NECK 40
#define BONEID_CHEST 6
#define BONEID_STOMACH 4
#define BONEID_LEFTARM 24
#define BONEID_RIGHTARM 39
#define BONEID_LEFTBUTTOCK 41
#define BONEID_RIGHTBUTTOCK 42
#define BONEID_LEFTLEG 48
#define BONEID_RIGHTLEG 54

/* Ignored trace flags.
 *
 * Note: To use with some trace functions (forwards/natives). */
#define DONT_IGNORE_MONSTERS      0
#define IGNORE_MONSTERS           1
#define IGNORE_MISSILE            2
#define IGNORE_GLASS          0x100

// Client status flags, to use with some forwards at the client_* format.
const CSF_ALIVE = (1<<0) // client is alive
const CSF_BOT   = (1<<1) // client is a bot

/* Compare types for the strings comparisons (classes names, etc.). Generally used by the modules (VexdUM...).
 *
 * Note: To use with some natives that contain the "CompareType" enumeration as parameter (forwards natives with custom class). */
enum CompareType {
  CT_None = 0,  /* No comparison (ignored). This means there is no "filter" and it's called/true for everything (like using "*").
                 * Note: This is only supported by some specific functions (when specified in their documentation), as the VexdUM's ones (custom forwards) and a few more. */
  CT_EqualCS,   /* Check/Search/Call if the string/class is equal to the specified string/class (case-sensitive). */
  CT_EqualCI,   /* Check/Search/Call if the string/class is equal to the specified string/class (case-insensitive). */
  CT_StartCS,   /* Check/Search/Call if the string/class starts with the specified string/class (case-sensitive). */
  CT_StartCI,   /* Check/Search/Call if the string/class starts with the specified string/class (case-insensitive). */
  CT_ContainCS, /* Check/Search/Call if the string/class contains the specified string/class (case-sensitive). */
  CT_ContainCI  /* Check/Search/Call if the string/class contains the specified string/class (case-insensitive). */
};

/* Hook types for the custom "AddToFullPack" forwards.
 *
 * Note: To use with the "[un]register_atfp_forward[_light]" natives. */
enum ATFPType {
  ATFPT_Pre,    /* Register/Unregister the forward as PRE. */
  ATFPT_Post,   /* Register/Unregister the forward as POST. */
  ATFPT_PostORV /* Register/Unregister the forward as POST but only call it when the original return value is not equal to 0 (useful & efficient performance gain). */
};

// To use with <get|set>_client_data native.
enum eClientData {
  CD_INT_bInDuck,
  CD_INT_ID,
  CD_INT_Flags,
  CD_INT_DeadFlag,
  CD_INT_tfState,
  CD_INT_PushMsec,
  CD_INT_WaterType,
  CD_INT_WaterLevel,
  CD_INT_WaterJumpTime,
  CD_INT_ViewModel,
  CD_INT_Weapons,
  CD_INT_WeaponAnim,
  CD_INT_AmmoShells,
  CD_INT_AmmoNails,
  CD_INT_AmmoCells,
  CD_INT_AmmoRockets,
  CD_INT_flDuckTime,
  CD_INT_flSwimTime,
  CD_INT_flTimeStepSound,
  CD_INT_User1,
  CD_INT_User2,
  CD_INT_User3,
  CD_INT_User4,

  CD_FL_Health,
  CD_FL_MaxSpeed,
  CD_FL_FOV,
  CD_FL_flNextAttack,
  CD_FL_User1,
  CD_FL_User2,
  CD_FL_User3,
  CD_FL_User4,

  CD_VEC_Origin,
  CD_VEC_ViewOfs,
  CD_VEC_PunchAngle,
  CD_VEC_Velocity,
  CD_VEC_User1,
  CD_VEC_User2,
  CD_VEC_User3,
  CD_VEC_User4,

  CD_SZ_PhysInfo
};

// To use with <get|set>_user_command native.
enum eUserCommand {
  UC_INT_LerpMsec,
  UC_INT_Msec,
  UC_INT_LightLevel,
  UC_INT_Buttons,
  UC_INT_Impulse,
  UC_INT_WeaponSelect,
  UC_INT_ImpactIndex,

  UC_FL_ForwardMove,
  UC_FL_SideMove,
  UC_FL_UpMove,

  UC_VEC_ViewAngles,
  UC_VEC_ImpactPosition
};
