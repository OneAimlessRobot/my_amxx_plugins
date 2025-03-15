#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN "Cod Weapons Zooms"
#define VERSION "1.5"
#define AUTHOR "CeLeS & Cypis"

#define weapon(%1) get_user_weapon(%1, clip, ammo)
#define BUTTON(%1) (pev(id, pev_button) & IN_%1 && !(pev(id, pev_oldbuttons) & IN_%1))
#define id2 get_pdata_cbase(ent, m_pPlayer, 4)
#define MAX 40

#define GLOCK18_SEMIAUTOMATIC		0
#define GLOCK18_BURST			2

#define FAMAS_AUTOMATIC			0
#define FAMAS_BURST			16

#define M4A1_SILENCED			(1<<2)
#define USP_SILENCED			(1<<0)

new const NO_RELOAD = (1<<2)|(1<<CSW_KNIFE)|(1<<CSW_C4)|(1<<CSW_M3)|(1<<CSW_XM1014)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE);

const m_pPlayer = 41;
const m_fInReload = 54;
const m_bSilencerOn = 74;

new V_MODEL[MAX][64];
new SIGHT[MAX][64];
new cvar_recoil_name[MAX][64];

new c_wpnchange[MAX];
new cvar_recoil[MAX];
 
new Float:cl_pushangle[33][3];
new Zoom[33], Reloading[33], WeaponName[24];
new ma_tumik[33], ma_brust[33], ma_tumik_usp[33], ma_brust_glock[33];
new clip, ammo, idwpn;
 
public plugin_init(){
	register_plugin(PLUGIN, VERSION, AUTHOR);
      
	register_forward(FM_CmdStart, "CmdStart");
 	register_forward(FM_PlayerPreThink,"PreThink");

	register_event("CurWeapon","CurWeapon","be","1=1");
      
	for(new i = CSW_P228; i <= CSW_P90; i++){
		if(NO_RELOAD & (1<<i))
			continue;
   
		get_weaponname(i, WeaponName, 23);

		RegisterHam(Ham_Weapon_Reload, WeaponName, "ReloadWeapon", 1);
		RegisterHam(Ham_Weapon_PrimaryAttack, WeaponName, "primary_attack");
		RegisterHam(Ham_Weapon_PrimaryAttack, WeaponName, "primary_attack_post", 1);
		RegisterHam(Ham_Item_Holster, WeaponName, "Item_Holster");
	}
}
 
public plugin_precache(){
	new configfile[200];
	get_configsdir(configfile,199);
	format(configfile,199,"%s/cwz_weapon.ini",configfile);
	if(file_exists(configfile)){
		new row[200], left[64], trash, right[64];
		new size=file_size(configfile,1);
		for(new i=0;i<size;i++){
                  
			new model[64], wchange, recoil[32], sight_model[64];
			read_file(configfile,i,row,200,trash);
			if((contain(row,";")!=0) && strlen(row) && idwpn<MAX){
				replace(row, 199, " ", "_");
				replace(row, 199, "[model]", " ");
				replace(row, 199, "[wchange]", " ");
				replace(row, 199, "[recoil]", " ");
				replace(row, 199, "[sight_model]", " ");
				
				strbreak(row,left,63,right,63);
				format(row, 199, "%s", right);
				format(model, 63, "%s", left);
	 
				strbreak(row,left,63,right,63);
				format(row, 199, "%s", right);
				wchange = str_to_num(left);
	 
				strbreak(row,left,63,right,63);
				format(row, 199, "%s", right);
				format(recoil, 31, "%s", left);
	 
				strbreak(row,left,63,right,63);
				format(row, 199, "%s", right);
				format(sight_model, 63, "%s", left);
				
				c_wpnchange[idwpn] = wchange;
				      
				format(cvar_recoil_name[idwpn], 63, "cwz_%s_recoil", model);
				cvar_recoil[idwpn] = register_cvar(cvar_recoil_name[idwpn], recoil);
	 
				format(V_MODEL[idwpn], 63, "models/%s.mdl", model);
				format(SIGHT[idwpn], 63, "models/%s.mdl", sight_model);
				precache_model(V_MODEL[idwpn]);
				precache_model(SIGHT[idwpn]);
				idwpn++;
			}
		}
	}
}
 
public client_putinserver(id){
	Zoom[id] = false;
	ma_tumik[id] = false;
	ma_brust[id] = false;
	ma_tumik_usp[id] = false;
	ma_brust_glock[id] = false;
}
 
public CurWeapon(id){
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;
            
	for(new i=0;i<idwpn;i++){
		if(weapon(id) == c_wpnchange[i]){
			get_weaponname(read_data(2), WeaponName, 23);
			new ent = fm_find_ent_by_owner(-1, WeaponName, id);
			
			set_pdata_float(ent, 47, 9999.0, 4);
			if(!Zoom[id])
				set_pev(id, pev_viewmodel2, V_MODEL[i]);
			else
				set_pev(id, pev_viewmodel2, SIGHT[i]);
		}
	}
	return PLUGIN_CONTINUE;
}
 
public CmdStart(id){
	if(!is_user_alive(id))
		return FMRES_IGNORED;
      	
	for(new i=0;i<idwpn;i++){
		if(weapon(id) == c_wpnchange[i]){
			if(BUTTON(ATTACK2)){
				if(!Zoom[id] && !Reloading[id]){
					set_pdata_int(id, 363, 55, 5);
					client_cmd(id,"spk weapons/zoom");
					client_cmd(id, "+speed");
					Zoom[id] = true;
				}
				else
					ZoomFalse(id);
			}
		}
	}
	return FMRES_IGNORED;
}
      
public Item_Holster(ent){
	if(ExecuteHamB(Ham_Item_CanHolster, ent)){
		ZoomFalse(id2);
		remove_task(id2);
		Reloading[id2] = false;
	}
}

public ReloadWeapon(ent){
	if(get_pdata_int(ent, m_fInReload, 4)){
		new Float:NextAttack = get_pdata_float(id2, 83, 5);
            
		if(Zoom[id2]){
			if(weapon(id2) == 15){
				if(ma_brust[id2])
					cs_set_weapon_burst(ent, 1);
				else
					cs_set_weapon_burst(ent, 0);
			}
		}
		ZoomFalse(id2);
		Reloading[id2] = true;
		set_task(NextAttack, "taskWeaponReloaded", id2);
	}
}
 
public taskWeaponReloaded(id)
	Reloading[id] = false;      
 
public ZoomFalse(id){
	set_pdata_int(id, 363, 90, 5);
	client_cmd(id, "-speed");
	Zoom[id] = false;
}

public PreThink(id){
	if(!is_user_alive(id))
		return FMRES_IGNORED
	
	new ent = fm_find_ent_by_owner(-1, "weapon_m4a1", id);
	new ent1 = fm_find_ent_by_owner(-1, "weapon_famas", id);
	new ent2 = fm_find_ent_by_owner(-1, "weapon_usp", id);
	new ent3 = fm_find_ent_by_owner(-1, "weapon_glock18", id);
	
	for(new i=0;i<idwpn;i++){
		if(weapon(id) == c_wpnchange[i]){
			if(weapon(id) == 22){
				if(BUTTON(USE)){
					if(ma_tumik[id]){
						cs_set_weapon_silen(ent, 0);
						ma_tumik[id] = false;
					}
					else{
						cs_set_weapon_silen(ent, 1);
						ma_tumik[id] = true;
					}
				}
			}
			if(weapon(id) == 16){
				if(BUTTON(USE)){
					if(ma_tumik_usp[id]){
						cs_set_weapon_silen(ent2, 0);
						ma_tumik_usp[id] = false;
					}
					else{
						cs_set_weapon_silen(ent2, 1);
						ma_tumik_usp[id] = true;
					}
				}
			}
			if(weapon(id) == 15){
				if(BUTTON(USE)){
					if(ma_brust[id]){
						cs_set_weapon_burst(ent1, 0);
						ma_brust[id] = false;
					}
					else{
						cs_set_weapon_burst(ent1, 1);
						ma_brust[id] = true;
					}
				}
			}
			if(weapon(id) == 17){
				if(BUTTON(USE)){
					if(ma_brust_glock[id]){
						cs_set_weapon_burst(ent3, 0);
						ma_brust_glock[id] = false;
					}
					else{
						cs_set_weapon_burst(ent3, 1);
						ma_brust_glock[id] = true;
					}
				}
			}
		}
	}
	return FMRES_IGNORED;
}
 
public primary_attack(ent){
	pev(id2,pev_punchangle,cl_pushangle[id2]);
	return HAM_IGNORED;
}
 
public primary_attack_post(ent){
	for(new i=0;i<idwpn;i++){
		if(weapon(id2) == c_wpnchange[i] && Zoom[id2]){
			new Float:push[3];
			pev(id2,pev_punchangle,push);
			xs_vec_sub(push,cl_pushangle[id2],push);
                  
			xs_vec_mul_scalar(push, get_pcvar_float(cvar_recoil[i]),push);
			xs_vec_add(push,cl_pushangle[id2],push);
			set_pev(id2,pev_punchangle,push);
		}
	}
	return HAM_IGNORED;
} 

stock cs_set_weapon_burst(entity, burstmode){
	new weapon = get_pdata_int(entity, 43, 4);
	if(weapon != CSW_GLOCK18 && weapon != CSW_FAMAS) 
		return;
	
	static TextMsg;
	static const messages[3][] = {"#Switch_To_BurstFire", "#Switch_To_SemiAuto", "#Switch_To_FullAuto"};
	
	static type;
	new firemode = get_pdata_int(entity, m_bSilencerOn, 4);
	
	switch(weapon){
		case CSW_GLOCK18:{
			if(burstmode && firemode == GLOCK18_SEMIAUTOMATIC){
				type = 0;
				firemode = GLOCK18_BURST;
			}
			else if(!burstmode && firemode == GLOCK18_BURST){
				type = 1;
				firemode = GLOCK18_SEMIAUTOMATIC;
			}
			else return;
		}
		case CSW_FAMAS:{
			if(burstmode && firemode == FAMAS_AUTOMATIC){
				type = 0;
				firemode = FAMAS_BURST;
			}
			else if(!burstmode && firemode == FAMAS_BURST){
				type = 2;
				firemode = FAMAS_AUTOMATIC;
			}
			else return;
		}
	}
	set_pdata_int(entity, m_bSilencerOn, firemode, 4);
	
	new client = pev(entity, pev_owner);
	if(is_user_alive(client)){
		if(TextMsg || (TextMsg = get_user_msgid("TextMsg"))){
			emessage_begin(MSG_ONE_UNRELIABLE, TextMsg, _, client);
			ewrite_byte(4);
			ewrite_string(messages[type]);
			emessage_end();
		}
	}
}

stock cs_set_weapon_silen(entity, silence){
	new weapon = get_pdata_int(entity, 43, 4);
	if(weapon != CSW_M4A1 && weapon != CSW_USP) 
		return;
	
	new silencemode = get_pdata_int(entity, m_bSilencerOn, 4);
	
	switch(weapon){
		case CSW_M4A1:{
			if(silence && !(silencemode & M4A1_SILENCED)){
				silencemode |= M4A1_SILENCED;
			}
			else if(!silence && (silencemode & M4A1_SILENCED)){
				silencemode &= ~M4A1_SILENCED;
			}
			else return;
		}
		case CSW_USP:{
			if(silence && !(silencemode & USP_SILENCED)){
				silencemode |= USP_SILENCED;
			}
			else if(!silence && (silencemode & USP_SILENCED)){
				silencemode &= ~USP_SILENCED;
			}
			else return;
		}
	}
	set_pdata_int(entity, m_bSilencerOn, silencemode, 4);
}
