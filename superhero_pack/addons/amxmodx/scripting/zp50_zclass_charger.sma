#include <amxmodx>
#include <engine>
#include <hamsandwich>
#include <fun>
#include <fakemeta>
#include <xs>
#include <orpheu>
#include <orpheu_stocks>
#include <zp50_core>
#include <zp50_class_zombie>
#include <zp50_class_nemesis>
#include <zp50_class_survivor>

/*********************************
**		YOU CAN EDIT THIS		**
*********************************/
new const CUSTOM_TAG[] = "[ZP]";

new const g_Charger_ClassName[] = "Charger Zombie"; // Name
new const g_Charger_ClassInfo[] = "Charge"; // Info
new const g_Charger_ClassModel[][] = {"zp_l4d_charger"}; // Zombie Model
new const g_Charger_ClassClawsModel[][] = {"models/zombie_plague/v_knife_charger.mdl"}; // Claw Model
new const g_Charger_ClassHealth = 2200; // Health
new const Float:g_Charger_ClassSpeed = 240.0; // Speed
new const Float:g_Charger_ClassGravity = 1.1; // Gravity
new const Float:g_Charger_ClassKnockback = 0.0; // Knockback
/*********************************
**		STOP HERE AAAAHH		**
*********************************/

new const g_SOUND_Charger_Impact[][] = {"zombie_plague/loud_chargerimpact_01.wav", "zombie_plague/loud_chargerimpact_04.wav"};
new const g_SOUND_Charger_Respawn[][] = {"zombie_plague/charger_alert_01.wav", "zombie_plague/charger_alert_02.wav"};
new const g_SOUND_Charger_Charge[][] = {"zombie_plague/charger_charge_01.wav", "zombie_plague/charger_charge_02.wav"};
new const g_SOUND_Charger_Alert[][] = {"zombie_plague/charger_lurk_15.wav", "zombie_plague/charger_lurk_17.wav"};
new const g_SOUND_Charger_Hits[][] = {"zombie_plague/charger_smash_01.wav", "zombie_plague/charger_smash_02.wav"};

new g_MODEL_Rocks;

new g_SPRITE_Trail;

#define TASK_SOUND				318930
#define TASK_CHARGER_CAMERA	637860

#define ID_SOUND					(taskid - TASK_SOUND)
#define ID_CHARGER_CAMERA		(taskid - TASK_CHARGER_CAMERA)

new OrpheuStruct:g_UserMove;

new g_Charger_ClassId;
new g_TrailColors[3];
new g_MaxUsers;

new g_CVAR_RespawnSound;
new g_CVAR_AlertSound;
new g_CVAR_HitSound;
new g_CVAR_CoolDown;
new g_CVAR_Colors;
new g_CVAR_InfectHumans;
new g_CVAR_DamageToHumans;

new Float:g_Charger_CD[33];
new Float:g_Charger_Angles[33][3];
new Float:g_LastGravity[33];
new Float:g_LastSpeed[33];

new g_Charger_CountFix[33];
new g_Charger_CameraEnt[33];
new g_Charger_InCamera[33];

public plugin_precache() {
	new i;
	
	for(i = 0; i < sizeof(g_SOUND_Charger_Impact); ++i) {
		precache_sound(g_SOUND_Charger_Impact[i]);
	}
	
	for(i = 0; i < sizeof(g_SOUND_Charger_Respawn); ++i) {
		precache_sound(g_SOUND_Charger_Respawn[i]);
	}
	
	for(i = 0; i < sizeof(g_SOUND_Charger_Charge); ++i) {
		precache_sound(g_SOUND_Charger_Charge[i]);
	}
	
	for(i = 0; i < sizeof(g_SOUND_Charger_Alert); ++i) {
		precache_sound(g_SOUND_Charger_Alert[i]);
	}
	
	for(i = 0; i < sizeof(g_SOUND_Charger_Hits); ++i) {
		precache_sound(g_SOUND_Charger_Hits[i]);
	}
	
	g_MODEL_Rocks = precache_model("models/rockgibs.mdl");
	
	g_SPRITE_Trail = precache_model("sprites/laserbeam.spr");
	
	g_Charger_ClassId = zp_class_zombie_register(g_Charger_ClassName, g_Charger_ClassInfo, g_Charger_ClassHealth, g_Charger_ClassSpeed, g_Charger_ClassGravity);
	
	zp_class_zombie_register_kb(g_Charger_ClassId, g_Charger_ClassKnockback);
	
	for(i = 0; i < sizeof(g_Charger_ClassModel); ++i) {
		zp_class_zombie_register_model(g_Charger_ClassId, g_Charger_ClassModel[i]);
	}
	
	for(i = 0; i < sizeof(g_Charger_ClassClawsModel); ++i) {
		zp_class_zombie_register_claw(g_Charger_ClassId, g_Charger_ClassClawsModel[i]);
	}
}

public plugin_init() {
	register_plugin("[ZP] Class: Charger", "v1.0", "KISKE");
	
	g_MaxUsers = get_maxplayers();
	
	OrpheuRegisterHook(OrpheuGetDLLFunction("pfnPM_Move", "PM_Move"), "OnPM_Move");
	OrpheuRegisterHook(OrpheuGetFunction("PM_Jump"), "OnPM_Jump");
	OrpheuRegisterHook(OrpheuGetFunction("PM_Duck"), "OnPM_Duck");
	
	register_event("HLTV", "event__HLTV", "a", "1=0", "2=0");
	
	register_forward(FM_CmdStart, "fw_CmdStart");
	register_forward(FM_EmitSound, "fw_EmitSound");
	
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled");
	RegisterHam(Ham_Think, "trigger_camera", "fw_Think_TriggerCamera");
	
	g_CVAR_RespawnSound = register_cvar("zp_charger_respawn_sound", "1");
	g_CVAR_AlertSound = register_cvar("zp_charger_alert_sound", "1");
	g_CVAR_HitSound = register_cvar("zp_charger_hits_sound", "1");
	g_CVAR_CoolDown = register_cvar("zp_charger_cooldown", "15");
	g_CVAR_Colors = register_cvar("zp_charger_colors", "255 0 0"); // red green blue
	g_CVAR_InfectHumans = register_cvar("zp_charger_charge_infect", "0");
	g_CVAR_DamageToHumans = register_cvar("zp_charger_charge_damage", "100");
	
	register_touch("player", "*", "touch__PlayerAll");
	
	parseColors();
}

public client_putinserver(id) {
	g_Charger_CD[id] = 0.0;
}

public client_disconnected(id) {
	remove_task(id + TASK_SOUND);
	remove_task(id + TASK_CHARGER_CAMERA);
	
	if(g_Charger_InCamera[id]) {
		g_Charger_InCamera[id] = 0;
		
		if(is_valid_ent(g_Charger_CameraEnt[id])) {
			remove_entity(g_Charger_CameraEnt[id]);
			g_Charger_CameraEnt[id] = 0;
		}
	}
}

public event__HLTV() {
	parseColors();
}

parseColors() {
	new sColors[20];
	new sRed[4];
	new sGreen[4];
	new sBlue[4];
	
	get_pcvar_string(g_CVAR_Colors, sColors, charsmax(sColors));
	
	parse(sColors, sRed, charsmax(sRed), sGreen, charsmax(sGreen), sBlue, charsmax(sBlue));
	
	g_TrailColors[0] = clamp(str_to_num(sRed), 0, 255);
	g_TrailColors[1] = clamp(str_to_num(sGreen), 0, 255);
	g_TrailColors[2] = clamp(str_to_num(sBlue), 0, 255);
}

public zp_fw_core_cure(id, survivor) {
	remove_task(id + TASK_SOUND);
	remove_task(id + TASK_CHARGER_CAMERA);
	
	if(g_Charger_InCamera[id]) {
		g_Charger_InCamera[id] = 0;
		
		if(is_valid_ent(g_Charger_CameraEnt[id])) {
			remove_entity(g_Charger_CameraEnt[id]);
			g_Charger_CameraEnt[id] = 0;
		}
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_KILLBEAM);
		write_short(id);
		message_end();
	}
}

public zp_fw_core_infect_post(id, infector) {
	if(!zp_class_nemesis_get(id) && zp_class_zombie_get_current(id) == g_Charger_ClassId) {
		client_print(id, print_chat, "%s Press +attack to charge!", CUSTOM_TAG);
		
		if(get_pcvar_num(g_CVAR_RespawnSound)) {
			emit_sound(id, CHAN_VOICE, g_SOUND_Charger_Respawn[random_num(0, charsmax(g_SOUND_Charger_Respawn))], 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
		
		if(get_pcvar_num(g_CVAR_AlertSound)) {
			remove_task(id + TASK_SOUND);
			set_task(random_float(8.0, 10.0), "task__PlayChargerSound", id + TASK_SOUND);
		}
	}
}

public task__PlayChargerSound(const taskid) {
	if(get_pcvar_num(g_CVAR_AlertSound)) {
		new id;
		id = ID_SOUND;
		
		if(zp_core_is_zombie(id) && !zp_class_nemesis_get(id) && zp_class_zombie_get_current(id) == g_Charger_ClassId) {
			emit_sound(id, CHAN_VOICE, g_SOUND_Charger_Alert[random_num(0, charsmax(g_SOUND_Charger_Alert))], 1.0, ATTN_NORM, 0, PITCH_NORM);
			
			set_task(random_float(8.0, 10.0), "task__PlayChargerSound", id + TASK_SOUND);
		}
	}
}

public fw_CmdStart(const id, const handle) {
	if(is_user_alive(id)) {
		if(zp_core_is_zombie(id) && !zp_class_nemesis_get(id) && zp_class_zombie_get_current(id) == g_Charger_ClassId) {
			static iButton;
			iButton = get_uc(handle, UC_Buttons);
			
			static iOldButton;
			iOldButton = entity_get_int(id, EV_INT_oldbuttons);
			
			static iFlags;
			iFlags = entity_get_int(id, EV_INT_flags);
			
			if(g_Charger_InCamera[id]) {
				if((iButton & IN_ATTACK) || (iButton & IN_ATTACK2)) {
					if((iButton & IN_ATTACK)) {
						iButton &= ~IN_ATTACK;
						set_uc(handle, UC_Buttons, iButton);
					} else {
						iButton &= ~IN_ATTACK2;
						set_uc(handle, UC_Buttons, iButton);
					}
					
					return FMRES_SUPERCEDE;
				}
			}
			
			if(iButton & IN_ATTACK) {
				iButton &= ~IN_ATTACK;
				set_uc(handle, UC_Buttons, iButton);
				
				if(!(iOldButton & IN_ATTACK)) {
					if((iFlags & (FL_ONGROUND | FL_PARTIALGROUND | FL_INWATER | FL_CONVEYOR | FL_FLOAT)) && !(entity_get_int(id, EV_INT_bInDuck)) && !(iFlags & FL_DUCKING)) {
						new Float:flGameTime;
						flGameTime = get_gametime()
						
						if(g_Charger_CD[id] > flGameTime) {
							client_print(id, print_chat, "%s You must to wait %0.2f seconds!", CUSTOM_TAG, (g_Charger_CD[id] - flGameTime));
							return FMRES_SUPERCEDE;
						}
						
						new Float:flValue;
						flValue = get_pcvar_float(g_CVAR_CoolDown);
						
						if(flValue > 0.0) {
							g_Charger_CD[id] = flGameTime + flValue;
						}
						
						remove_task(id + TASK_SOUND);
						
						g_Charger_CountFix[id] = 0;
						
						g_LastSpeed[id] = get_user_maxspeed(id);
						
						g_LastGravity[id] = get_user_gravity(id);
						set_user_gravity(id, 100.0);
						
						entity_get_vector(id, EV_VEC_v_angle, g_Charger_Angles[id]);
						g_Charger_Angles[id][0] = 0.0;
						
						message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
						write_byte(TE_BEAMFOLLOW);
						write_short(id);
						write_short(g_SPRITE_Trail);
						write_byte(25);
						write_byte(4);
						write_byte(g_TrailColors[0]);
						write_byte(g_TrailColors[1]);
						write_byte(g_TrailColors[2]);
						write_byte(255);
						message_end();
						
						g_Charger_CameraEnt[id] = create_entity("trigger_camera");
						
						if(is_valid_ent(g_Charger_CameraEnt[id])) {
							emit_sound(id, CHAN_BODY, g_SOUND_Charger_Charge[random_num(0, charsmax(g_SOUND_Charger_Charge))], 1.0, ATTN_NORM, 0, PITCH_NORM);
							
							set_kvd(0, KV_ClassName, "trigger_camera");
							set_kvd(0, KV_fHandled, 0);
							set_kvd(0, KV_KeyName, "wait");
							set_kvd(0, KV_Value, "999999");
							dllfunc(DLLFunc_KeyValue, g_Charger_CameraEnt[id], 0);
							
							entity_set_int(g_Charger_CameraEnt[id], EV_INT_spawnflags, SF_CAMERA_PLAYER_TARGET|SF_CAMERA_PLAYER_POSITION);
							entity_set_int(g_Charger_CameraEnt[id], EV_INT_flags, entity_get_int(g_Charger_CameraEnt[id], EV_INT_flags) | FL_ALWAYSTHINK);
							
							DispatchSpawn(g_Charger_CameraEnt[id]);
							
							g_Charger_InCamera[id] = 1;
							
							ExecuteHam(Ham_Use, g_Charger_CameraEnt[id], id, id, 3, 1.0);
						}
					} else {
						client_print(id, print_chat, "%s You must to stand on the ground!", CUSTOM_TAG);
					}
				}
				
				return FMRES_SUPERCEDE;
			}
		}
	}
	
	return HAM_IGNORED;
}

public fw_EmitSound(const id, const channel, const sample[], const Float:volume, const Float:attn, const flags, const pitch) {
	if(!is_user_connected(id)) {
		return FMRES_IGNORED;
	}
	
	if(get_pcvar_num(g_CVAR_HitSound)) {
		if(zp_core_is_zombie(id) && !zp_class_nemesis_get(id) && zp_class_zombie_get_current(id) == g_Charger_ClassId) {
			if(sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i') { // KNI(FE)
				if((sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') || (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a')) { // HIT || STA(B)
					emit_sound(id, channel, g_SOUND_Charger_Hits[random_num(0, charsmax(g_SOUND_Charger_Hits))], volume, attn, flags, pitch);
					return FMRES_SUPERCEDE;
				}
			}
		}
	}
	
	return FMRES_IGNORED;
}

public fw_PlayerKilled(const victim, const killer, const shouldgib) {
	remove_task(victim + TASK_SOUND);
	remove_task(victim + TASK_CHARGER_CAMERA);
	
	if(g_Charger_InCamera[victim]) {
		g_Charger_InCamera[victim] = 0;
		
		if(is_valid_ent(g_Charger_CameraEnt[victim])) {
			remove_entity(g_Charger_CameraEnt[victim]);
			g_Charger_CameraEnt[victim] = 0;
		}
		
		// Necessary ?
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_KILLBEAM);
		write_short(victim);
		message_end();
	}
}

public fw_Think_TriggerCamera(const iEnt) {
	static id;
	
	for(id = 1; id <= g_MaxUsers; ++id) {
		if(g_Charger_CameraEnt[id] == iEnt) {
			id += 1337;
			break;
		}
	}
	
	if(id < 1337) {
		return;
	}
	
	id -= 1337;
	
	static Float:vecUserOrigin[3];
	static Float:vecCameraOrigin[3];
	static Float:vecForward[3];
	static Float:vecVelocity[3];
	
	entity_get_vector(id, EV_VEC_origin, vecUserOrigin);
	
	vecUserOrigin[2] += 45.0;
	
	angle_vector(g_Charger_Angles[id], ANGLEVECTOR_FORWARD, vecForward);
	
	vecCameraOrigin[0] = vecUserOrigin[0] + (-vecForward[0] * 150.0);
	vecCameraOrigin[1] = vecUserOrigin[1] + (-vecForward[1] * 150.0);
	vecCameraOrigin[2] = vecUserOrigin[2] + (-vecForward[2] * 150.0);
	
	engfunc(EngFunc_TraceLine, vecUserOrigin, vecCameraOrigin, IGNORE_MONSTERS, id, 0);
	
	static Float:flFraction;
	get_tr2(0, TR_flFraction, flFraction);
	
	if(flFraction != 1.0) {
		flFraction *= 150.0;
		
		vecCameraOrigin[0] = vecUserOrigin[0] + (-vecForward[0] * flFraction);
		vecCameraOrigin[1] = vecUserOrigin[1] + (-vecForward[1] * flFraction);
		vecCameraOrigin[2] = vecUserOrigin[2] + (-vecForward[2] * flFraction);
	}
	
	entity_set_vector(iEnt, EV_VEC_angles, g_Charger_Angles[id]);
	entity_set_vector(iEnt, EV_VEC_origin, vecCameraOrigin);
	
	entity_set_vector(id, EV_VEC_angles, g_Charger_Angles[id]);
	entity_set_vector(id, EV_VEC_v_angle, g_Charger_Angles[id]);
	
	entity_set_int(id, EV_INT_fixangle, 1);
	
	velocity_by_aim(id, 1000, vecVelocity);
	vecVelocity[2] = 0.0;
	entity_set_vector(id, EV_VEC_velocity, vecVelocity);
}

public touch__PlayerAll(const id, const victim) {
	if(is_user_alive(id)) {
		if(g_Charger_InCamera[id]) {
			++g_Charger_CountFix[id];
			
			if(g_Charger_CountFix[id] >= 2) {
				new Float:vecOrigin[3];
				entity_get_vector(id, EV_VEC_origin, vecOrigin);
				
				// A bugfix with func_wall and func_breakeable entities
				if(g_Charger_CountFix[id] < 1337) {
					new sClassName[14];
					if(!is_user_alive(victim)) {
						entity_get_string(victim, EV_SZ_classname, sClassName, charsmax(sClassName));
					
						if(sClassName[4] == '_' && ((sClassName[5] == 'b' && sClassName[9] == 'k' && sClassName[13] == 'e') || (sClassName[5] == 'w' && sClassName[6] == 'a' && sClassName[8] == 'l'))) { // func_breakeable || func_wall
							set_user_gravity(id, 1.0);
							
							vecOrigin[2] += 15.0;
							entity_set_vector(id, EV_VEC_origin, vecOrigin);
							
							g_Charger_CountFix[id] = 1337;
							
							return;
						}
					}
				}
				
				if(is_user_alive(victim)) {
					if(!g_Charger_InCamera[victim]) {
						new Float:vecVictimOrigin[3];
						new Float:vecSub[3];
						new Float:flScalar;
						
						entity_get_vector(victim, EV_VEC_origin, vecVictimOrigin);
						
						if((entity_get_int(victim, EV_INT_bInDuck)) || (entity_get_int(victim, EV_INT_flags) & FL_DUCKING)) {
							vecVictimOrigin[2] += 18.0;
						}
						
						xs_vec_sub(vecVictimOrigin, vecOrigin, vecSub);
						
						flScalar = (600.0 - vector_length(vecSub));
						
						vecSub[2] += 1.5;
						
						xs_vec_mul_scalar(vecSub, flScalar, vecSub);
						
						entity_set_vector(victim, EV_VEC_velocity, vecSub);
						
						if(!zp_core_is_zombie(victim)) {
							if(get_pcvar_num(g_CVAR_InfectHumans) && !zp_class_survivor_get(victim)) {
								zp_core_infect(victim, id);
							} else if(get_pcvar_num(g_CVAR_DamageToHumans)) {
								ExecuteHam(Ham_TakeDamage, victim, id, id, get_pcvar_float(g_CVAR_DamageToHumans), DMG_CRUSH);
							}
						}
						
						return;
					}
				}
				
				if(g_Charger_InCamera[id]) {
					g_Charger_InCamera[id] = 0;
					
					if(is_valid_ent(g_Charger_CameraEnt[id])) {
						remove_entity(g_Charger_CameraEnt[id]);
						g_Charger_CameraEnt[id] = 0;
					}
					
					message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
					write_byte(TE_KILLBEAM);
					write_short(id);
					message_end();
				}
				
				remove_task(id + TASK_CHARGER_CAMERA);
				set_task(0.35, "task__BackUserView", id + TASK_CHARGER_CAMERA);
				
				engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
				write_byte(TE_DLIGHT);
				engfunc(EngFunc_WriteCoord, vecOrigin[0]);
				engfunc(EngFunc_WriteCoord, vecOrigin[1]);
				engfunc(EngFunc_WriteCoord, vecOrigin[2]);
				write_byte(25);
				write_byte(128);
				write_byte(128);
				write_byte(128);
				write_byte(30);
				write_byte(20);
				message_end();
				
				engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin, 0);
				write_byte(TE_BREAKMODEL);
				engfunc(EngFunc_WriteCoord, vecOrigin[0]); 
				engfunc(EngFunc_WriteCoord, vecOrigin[1]);
				engfunc(EngFunc_WriteCoord, vecOrigin[2] + 24);
				write_coord(22);
				write_coord(22);
				write_coord(22);
				write_coord(random_num(-50, 100));
				write_coord(random_num(-50, 100));
				write_coord(30);
				write_byte(10);
				write_short(g_MODEL_Rocks);
				write_byte(15);
				write_byte(40);
				write_byte(0x03);
				message_end();
				
				emit_sound(id, CHAN_BODY, g_SOUND_Charger_Impact[random_num(0, charsmax(g_SOUND_Charger_Impact))], 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
		}
	}
}

public task__BackUserView(const taskid) {
	new id;
	id = ID_CHARGER_CAMERA;
	
	set_user_maxspeed(id, g_LastSpeed[id]);
	set_user_gravity(id, g_LastGravity[id]);
	
	attach_view(id, id);
	
	if(get_pcvar_num(g_CVAR_AlertSound)) {
		remove_task(id + TASK_SOUND);
		set_task(random_float(8.0, 10.0), "task__PlayChargerSound", id + TASK_SOUND);
	}
}

public OrpheuHookReturn:OnPM_Move(const OrpheuStruct:pmove, const server) {
	g_UserMove = pmove;
}

public OrpheuHookReturn:OnPM_Jump() {
	new id;
	id = OrpheuGetStructMember(g_UserMove, "player_index") + 1;
	
	if(is_user_alive(id) && g_Charger_InCamera[id]) {
		OrpheuSetStructMember(g_UserMove, "oldbuttons", OrpheuGetStructMember(g_UserMove, "oldbuttons") | IN_JUMP);
	}
}

public OrpheuHookReturn:OnPM_Duck() {
	new id;
	id = OrpheuGetStructMember(g_UserMove, "player_index") + 1;
	
	if(is_user_alive(id) && g_Charger_InCamera[id]) {
		new OrpheuStruct:cmd = OrpheuStruct:OrpheuGetStructMember(g_UserMove, "cmd");
		OrpheuSetStructMember(cmd, "buttons", OrpheuGetStructMember(cmd, "buttons" ) & ~IN_DUCK);
	}
}