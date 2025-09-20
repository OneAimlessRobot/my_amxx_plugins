
#include "../include/nvault.inc"
#include "../include/amxmod.inc"
#include "../include/amxmodx.inc"
#include "../include/amxmisc.inc"
#include "../include/hamsandwich.inc"
#include "../include/fakemeta.inc"
#include "../include/fakemeta_util.inc"
#include "../include/colorchat.inc"
#include "../include/engine.inc"
#include "../include/fun.inc"
#include "../include/csx.inc"
#include "../include/cstrike.inc"
#include "../include/Vexd_Utilities.inc"
#include "my_include/codmw4_classenum.inc"
#include "my_include/codmw4_classes.inc"
#include "my_include/codmw4_cmds.inc"
#include "my_include/codmw4_perks.inc"
#include "my_include/codmw4_levels.inc"
#include "my_include/codmw4_bank.inc"
#include "my_include/codmw4_abilities.inc"
#include "my_include/codmw4_fakedmg.inc"


#define BOTY 1
#define ZADATAK_POKAZI_INFORMACIJE 672
#define ZADATAK_POKAZI_ORUZIJA 672
#define ZADATAK_PROVERA 704
#define ZADATAK_POKAZI_REKLAME 768
#define ZADATAK_POSTAVI_BRZINU 832


#define PLUGIN "Call of Duty: MW4 Mod"
#define VERSION "1.3.0"
#define AUTHOR "Me"
#define Struct				enum
new sprite_white;
new sprite_blast;
new sprite_beam;
new sprite_trail;
new sprite_smoke;

new SyncHudObj;
new SyncHudObj2;

new Float:g_wallorigin[32][3]
new g_msg_screenfade;
new cvar_xp_za_ubistvo;
new iskustvo_za_pobedu;

new iskustvo_za_pare;
new iskustvo_za_mnogopara;

Struct _:StructForwards {
	reset_model_fwd,
	get_class_name_fwd,
	get_class_desc_fwd,
	get_class_speed_fwd,
	get_class_armor_fwd,
	get_class_energy_fwd,
	get_class_acess_fwd,
	get_class_suffix_fwd,
	get_perk_name_fwd,
	get_perk_desc_fwd,
	get_num_perks_fwd,
	get_num_classes_fwd,
	get_max_lvl_fwd,
	get_lvl_xp_fwd,
	get_player_gb_fwd,
	add_player_gb_fwd,
	set_player_gb_fwd,
	get_kill_gb_fwd
	
}

new const szForwards[ StructForwards ][ ] = {
	
	"PromeniModel",
	"get_ClassName",
	"get_ClassDesc",
	"get_ClassSpeed",
	"get_ClassArmor",
	"get_ClassEnergy",
	"get_ClassAccess",
	"get_ClassSuffix",
	"get_PerkName",
	"get_PerkDesc",
	"get_NumPerks",
	"get_NumClasses",
	"get_MaxLevel",
	"getXpFromLevel",
	"getPlayerGB",
	"addPlayerGB",
	"setPlayerGB",
	"getKillGB"
}

new g_vault;

new fwForwards[ StructForwards ];
new inteligencija_igraca[33];
new energija_igraca[33];
new snaga_igraca[33];
new kondicija_igraca[33];

new rakete_igraca[33];


new klasa_igraca[33];

new nova_klasa_igraca[33];

new const maxAmmo[31]={0,52,0,90,1,32,1,100,90,1,120,100,100,90,90,90,100,120,30,120,200,32,90,120,90,2,35,90,90,0,100};
new const maxClip[31] = { -1, 13, -1, 10,  1,  7,  1,  30, 30,  1,  30,  20,  25, 30, 35, 25,  12,  20, 10,  30, 100,  8, 30,  30, 20,  2,  7, 30, 30, -1,  50 };


new informacije_predmet_igraca[33][2];

new maximalna_energija_igraca[33];
new Float:smanjene_povrede_igraca[33];
new Float:brzina_igraca[33]

new snaga_predmeta[33];

new const frakcje[][] = 
{
"Nema",						// 0
"\y[\dOrdinary\y]\r Class",// 1
"\y[\dPremium\y]\r Class\y(\dFree from 10:00 PM-09:00 AM\y)",// 2
"\y[\dSuper\y]\r Class",
"\y[\dPro\y]\r Class",
"\y[\dSkill\y]\r Class"  //3

};
new frakcija_igraca[33]


new broj_medkit_igraca[33];
new broj_raketa_igraca[33];
new broj_min_igraca[33];
new broj_dinamita_igraca[33];
new broj_skokova_igraca[33];

new naziv_igraca[33][64]; 
new daj_igracu[33]; 
new fovmsg;

new Float:prethodna_raketa_igraca[33];
new Float:idle[33];

new bool:dobio_predmet[33];
new bool:droga[33];
new bool:freezetime = true;
new bool:ima_bazuku[33];
new bool:reloading[33];
new bool:lansirano[33][33];

public plugin_init() 
{ 
register_plugin(PLUGIN, VERSION, AUTHOR);

g_vault = nvault_open("CodMod");

register_think("MedKit","MedKitThink");

RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
RegisterHam(Ham_Spawn, "player", "Pocetak", 1);
RegisterHam(Ham_Touch, "armoury_entity", "DodirOruzija");
RegisterHam(Ham_Touch, "weapon_shield", "DodirOruzija");
RegisterHam(Ham_Touch, "weaponbox", "DodirOruzija");
RegisterHam(Ham_Weapon_WeaponIdle, "weapon_p228", "Weapon_WeaponIdle");
RegisterHam(Ham_Item_Deploy, "weapon_p228", "Weapon_DeployBazooka", 1);
RegisterHam(Ham_Weapon_WeaponIdle, "weapon_knife", "Weapon_WeaponIdle");
RegisterHam(Ham_Item_Deploy, "weapon_knife", "Weapon_DeployKatana", 1);
RegisterHam(Ham_Weapon_WeaponIdle, "weapon_m3", "Weapon_WeaponIdle");
RegisterHam(Ham_Item_Deploy, "weapon_m3", "Weapon_DeploySuperShotgun", 1);

register_forward(FM_CmdStart, "CmdStart");
register_forward(FM_EmitSound, "EmitSound");
register_forward(FM_SetModel, "SetModel");
register_forward(FM_Touch, "fw_Touch");
register_forward(FM_TraceLine,"fw_traceline");

register_logevent("PocetakRunde", 2, "1=Round_Start"); 
register_event("DeathMsg", "Death", "ade");
register_event("Damage", "Damage", "b", "2!=0");       
register_event("CurWeapon","CurWeapon","be", "1=1");
register_event("HLTV", "novaRunda", "a", "1=0", "2=0");

register_touch("Rocket", "*" , "DodirRakete");
register_touch("Mine", "player",  "DodirMine");

register_clcmd("say /class", "IzaberiKlasu");
register_clcmd("say /klasa", "IzaberiKlasu");
register_clcmd("say /menu", "Menu");
register_clcmd("say /Description", "OpisKlase");
register_clcmd("say /Des", "OpisKlase");
register_clcmd("say /opis", "OpisKlase");
register_clcmd("say /predmet", "OpisPredmeta");
register_clcmd("say /item", "OpisPredmeta");
register_clcmd("say /drop", "IzbaciPredmet");
register_clcmd("say /izbaci", "IzbaciPredmet");
register_clcmd("say /restart", "KomandaResetujPoene");
register_clcmd("say /reset", "KomandaResetujPoene");
register_clcmd("say /shop", "Shope");
register_clcmd("say /prodaj", "Prodaj"); 
register_clcmd("say /sell", "Prodaj");
register_clcmd("say /komande","Komande");
register_clcmd("say /controls","Komande");
register_clcmd("say /daj", "DajNekomPredmet");
register_clcmd("say /help", "Pomoc");
register_clcmd("say /kupi", "KupiPredmet");  
register_clcmd("fullupdate", "BlokirajKomande");
register_clcmd("say", "hook_say")

cvar_xp_za_ubistvo = register_cvar("cod_killxp", "800");
iskustvo_za_pobedu = get_cvar_num("cod_winxp")
register_concmd("cod_lvl", "cmd_setlvl", ADMIN_RCON, "<name: if started by @: @CT= to all cts, @T= to all ts @anything_else= everyone except you> <level> <0= normal,not 0... ignore name and set random>");
register_concmd("cod_class", "cmd_setclass", ADMIN_RCON, "<name: if started by @: @CT= to all cts, @T= to all ts @anything_else= everyone except you> <class> <0= normal,not 0... ignore name and set random>");
register_concmd("cod_dajpredmet", "cmd_setpredmet", ADMIN_RCON, "<nick> <item>");


register_cvar("cod_winxp", "50");

register_message(get_user_msgid("Health"), "message_Health");
g_msg_screenfade = get_user_msgid("ScreenFade");
SyncHudObj = CreateHudSyncObj();
SyncHudObj2 = CreateHudSyncObj();

register_menucmd(register_menuid("Klasa:"), 1023, "OpisKlase");
iskustvo_za_pare = 250;
iskustvo_za_mnogopara = 500;
fovmsg = get_user_msgid("SetFOV");
InitialiseForwards( );

}
InitialiseForwards( ) {
fwForwards[ reset_model_fwd ] = CreateMultiForward( szForwards[ reset_model_fwd ],ET_CONTINUE, FP_CELL,FP_CELL );
fwForwards[ get_class_name_fwd ] = CreateMultiForward( szForwards[ get_class_name_fwd ],ET_CONTINUE, FP_CELL,FP_ARRAY );
fwForwards[ get_class_desc_fwd ] = CreateMultiForward( szForwards[ get_class_desc_fwd ],ET_CONTINUE, FP_CELL,FP_ARRAY );
fwForwards[ get_class_speed_fwd ] = CreateMultiForward( szForwards[ get_class_speed_fwd ],ET_CONTINUE, FP_CELL );
fwForwards[ get_class_armor_fwd ] = CreateMultiForward( szForwards[ get_class_armor_fwd ],ET_CONTINUE, FP_CELL );
fwForwards[ get_class_energy_fwd ] = CreateMultiForward( szForwards[get_class_energy_fwd],ET_CONTINUE, FP_CELL );
fwForwards[ get_class_acess_fwd ] = CreateMultiForward( szForwards[ get_class_acess_fwd ],ET_CONTINUE, FP_CELL );
fwForwards[ get_class_suffix_fwd ] = CreateMultiForward( szForwards[ get_class_suffix_fwd ],ET_CONTINUE, FP_CELL,FP_ARRAY );
fwForwards[ get_perk_name_fwd ] = CreateMultiForward( szForwards[ get_perk_name_fwd ],ET_CONTINUE, FP_CELL,FP_ARRAY );
fwForwards[ get_perk_desc_fwd ] = CreateMultiForward( szForwards[ get_perk_desc_fwd ],ET_CONTINUE, FP_CELL,FP_ARRAY );
fwForwards[ get_num_perks_fwd ] = CreateMultiForward( szForwards[ get_num_perks_fwd ],ET_CONTINUE);
fwForwards[ get_num_classes_fwd ] = CreateMultiForward( szForwards[ get_num_classes_fwd ],ET_CONTINUE);
fwForwards[ get_max_lvl_fwd ] = CreateMultiForward( szForwards[ get_max_lvl_fwd ],ET_CONTINUE);
fwForwards[ get_lvl_xp_fwd ] = CreateMultiForward( szForwards[ get_lvl_xp_fwd ],ET_CONTINUE,FP_CELL);
fwForwards[ get_player_gb_fwd ] = CreateMultiForward( szForwards[ get_player_gb_fwd ],ET_CONTINUE,FP_CELL);
fwForwards[ add_player_gb_fwd ] = CreateMultiForward( szForwards[ add_player_gb_fwd ],ET_CONTINUE,FP_CELL,FP_CELL);
fwForwards[ set_player_gb_fwd ] = CreateMultiForward( szForwards[ set_player_gb_fwd ],ET_CONTINUE,FP_CELL,FP_CELL);
fwForwards[ get_kill_gb_fwd ] = CreateMultiForward( szForwards[ get_kill_gb_fwd ],ET_CONTINUE);



	

}

public plugin_end(){


}
public hook_say(id)  
{  
	new chat[192]  
	read_args(chat, 191)  
	remove_quotes(chat)  
	
	new name[32]  
	get_user_name(id, name, 31)  
	
	if(equal(chat, "")|| chat[ 0 ] == '/')
		return 2; 
	
	new CsTeams:userteam = cs_get_user_team(id)  
	
	new buff[128];
	new result
	PrepareArray(buff,128,1)
	ExecuteForward(fwForwards[get_class_name_fwd],result,klasa_igraca[id],buff);
	if (is_user_alive(id))  
	{  
		ColorChat(0, RED, " ^x04[%s - %i] ^3%s ^x01%s", buff, get_PlayerLvl(id), name, chat);  
		
	}  
	else if (!is_user_alive(id) && userteam != CS_TEAM_SPECTATOR)  
	{  
		ColorChat(0, GREY, "[DEATH]^x04[%s - %i] ^3%s ^x01%s", buff, get_PlayerLvl(id), name, chat);  
	}  
	else  
	{  
		ColorChat(0, GREY, "[SPEC]^x04[%s - %i] ^3%s ^x01%s", buff, get_PlayerLvl(id), name, chat);  
	}  
	return 2;
}


public cmd_setclass(id, level, cid)
{
	if(!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED;
	
	new arg1[33];
	new arg2[128];
	new arg3[2];
	read_argv(1, arg1, 32);
	read_argv(2, arg2, 127);
	read_argv(3, arg3, 1);
	new mode= str_to_num(arg3);
	if (arg1[0] == '@')
	{
		new Team=0;
		if (equali(arg1[1], "CT"))
		{
			Team = 2
			} else if (equali(arg1[1], "T")) {
			Team = 1
		}
		new players[32], num
		get_players(players, num)
		new i
		for (i=1; i<=num; i++)
		{
			if(i!=id){
				if (!Team)
				{
					if(!mode){
						set_player_class(i,arg2)
					}
					else{
						set_random_player_class(i)
					}
					} else {
					if (get_user_team(i) == Team)
					{
						
						if(!mode){
							set_player_class(i,arg2)
						}
						else{
							set_random_player_class(i)
						}
					}
				}
			}
		}
	}
	else {
		new player = cmd_target(id, arg1, 0);
		if (!player)
		{
			console_print(id, "Sorry, player %s could not be found or targetted!", arg1)
			return PLUGIN_HANDLED
			} else {
			
			
			if(!mode){
				console_print(player,"Escolheste a classe %s^n",arg2)
				set_player_class(player,arg2)
			}
			else{
				console_print(player,"Escolheste uma classe aleatoria!!!")
				set_random_player_class(player)
			}
		}
	}
	return PLUGIN_HANDLED;
}

public set_player_class(player, class_name[]){
	new i=0;
	new class_num;
	ExecuteForward(fwForwards[get_num_classes_fwd],class_num);
	for(; i <class_num; i++){
		new buff[128];
		new result
		PrepareArray(buff,128,1)
		ExecuteForward(fwForwards[get_class_name_fwd],result,i,buff);
		console_print(player,"Nome desta classe %s^n^nO nome da tua classe: %s^n",buff,class_name)
		if(equali(class_name,buff,strlen(buff))){
			
			klasa_igraca[player]=i;
			UcitajPodatke(player,klasa_igraca[player]);
			break;
		}
	}
}
public set_random_player_class(player){
	new class_num;
	ExecuteForward(fwForwards[get_num_classes_fwd],class_num);
	new integer= random_num(1,class_num-1);
	
	klasa_igraca[player]=integer;
	UcitajPodatke(player,klasa_igraca[player]);
	
}
public UcitajPodatke(id, klasa)
{
	new vaultkey[128],vaultdata[256], ID_igraca[64];
	
	get_user_authid(id, ID_igraca, charsmax(ID_igraca))
	
	format(vaultkey, charsmax(vaultkey),"%s-%i-cod", ID_igraca, klasa);
	nvault_get(g_vault,vaultkey,vaultdata,255);
	
	replace_all(vaultdata, 255, "#", " ");
	
	new playerdata[6][32];
	
	parse(vaultdata, playerdata[0], 31, playerdata[1], 31, playerdata[2], 31, playerdata[3], 31, playerdata[4], 31, playerdata[5], 31);
	
	set_PlayerXp(id,str_to_num(playerdata[0]));
	set_PlayerLvl(id,str_to_num(playerdata[1])>0?str_to_num(playerdata[1]):1);
	inteligencija_igraca[id] = str_to_num(playerdata[2]);
	energija_igraca[id] = str_to_num(playerdata[3]);
	snaga_igraca[id] = str_to_num(playerdata[4]);
	kondicija_igraca[id] = str_to_num(playerdata[5]);
	set_PlayerPoints(id, (get_PlayerLvl(id)-1)*2-inteligencija_igraca[id]-energija_igraca[id]-snaga_igraca[id]-kondicija_igraca[id]);
	
	return PLUGIN_CONTINUE;
}


public KomandaResetujPoene(id)
{	
	ColorChat(id, NORMAL, "^4[COD:MW4] ^1Points are reseted");
	client_cmd(id, "spk QTM_CodMod/select");
	
	ResetujPoene(id)
}
public ResetujPoene(id)
{	
	set_PlayerPoints(id,  get_PlayerLvl(id)*2-2);
	inteligencija_igraca[id] = 0;
	energija_igraca[id] = 0;
	kondicija_igraca[id] = 0;
	snaga_igraca[id] = 0;
	
	if(get_PlayerPoints(id))
		DodelaPoena(id);
}
public IzbaciPredmet(id)
{
	if(informacije_predmet_igraca[id][0])
	{
		new buff[128];
		new result
		PrepareArray(buff,128,1)
		ExecuteForward(fwForwards[get_perk_name_fwd],result,informacije_predmet_igraca[id][0],buff);
		ColorChat(id, NORMAL, "^4[COD:MW4] ^1Bacio si ^3%s.", buff);
		Obrisipredmet(id);
	}
	else
		ColorChat(id, NORMAL, "^4[COD:MW4] ^1You have no item.");
} 


public cmd_setlvl(id, level, cid)
{
	if(!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED;
	
	
	new maxlevel =0;
	ExecuteForward(fwForwards[get_max_lvl_fwd],maxlevel)
	
	new arg1[33];
	new arg2[6];
	new arg3[2];
	read_argv(1, arg1, 32);
	read_argv(2, arg2, 5);
	read_argv(3, arg3, 1);
	new value = str_to_num(arg2);
	new mode = str_to_num(arg3);
	
	if (arg1[0] == '@')
	{
		new Team=0;
		if (equali(arg1[1], "CT"))
		{
			Team = 2
			} else if (equali(arg1[1], "T")) {
			Team = 1
		}
		new players[32], num
		get_players(players, num)
		new i
		for (i=1; i<=num; i++)
		{
			if(i!=id){
				
				if( mode){
					value= random(maxlevel-1);
				}
				if (!Team)
				{
					
					set_PlayerXp(i,(value*value)*7)
					set_PlayerLvl(i,0);
					
					ProveriNivo(i,klasa_igraca[i],inteligencija_igraca[i],energija_igraca[i],snaga_igraca[i],kondicija_igraca[i]);
	
					} else {
					if (get_user_team(i) == Team)
					{
						
						
						set_PlayerXp(i,(value*value)*7)
						set_PlayerLvl(i,0);
						ProveriNivo(i,klasa_igraca[i],inteligencija_igraca[i],energija_igraca[i],snaga_igraca[i],kondicija_igraca[i]);
	
					}
				}
			}
		}
	}
	else {
		new player = cmd_target(id, arg1, 0);
		if (!player)
		{
			console_print(id, "Sorry, player %s could not be found or targetted!", arg1)
			return PLUGIN_HANDLED
			} else {
			if( mode){
				value= random(maxlevel-1);
			}
			
			set_PlayerXp(id,(value*value)*7)
			set_PlayerLvl(id,0);
			ProveriNivo(id,klasa_igraca[id],inteligencija_igraca[id],energija_igraca[id],snaga_igraca[id],kondicija_igraca[id]);
	
		}
	}
	return PLUGIN_HANDLED;
}


public Obrisipredmet(id)
{
	informacije_predmet_igraca[id][0] = 0;
	informacije_predmet_igraca[id][1] = 0;
	
	if(is_user_alive(id))
	{
		set_user_footsteps(id, 0);
		//set_rendering(id,kRenderFxGlowShell,0,0,0 ,kRenderTransAlpha, 255);
		new result;
		ExecuteForward(fwForwards[reset_model_fwd],result,id, 1);
	}
}
public DajPredmet(id, predmet)
{
	Obrisipredmet(id);
	informacije_predmet_igraca[id][0] = predmet;
	snaga_predmeta[id] = 160;
	new buff[128];
	new result
	PrepareArray(buff,128,1)
	ExecuteForward(fwForwards[get_perk_name_fwd],result,informacije_predmet_igraca[id][0],buff);
	ColorChat(id, NORMAL, "^4[COD:MW4] ^1You've got ^3%s.", buff);	
	
	switch(predmet)
	{
		case 1:
		{
			set_user_footsteps(id, 1);
		}
		case 2:
		{
			informacije_predmet_igraca[id][1] = random_num(3,6);
		}
		case 3:
		{
			informacije_predmet_igraca[id][1] = random_num(6, 11);
		}
		case 5:
		{
			informacije_predmet_igraca[id][1] = random_num(6, 9);
		}
		case 6:
		{
			if(isClassInvisible(klasa_igraca[id]))
			{
				
				ExecuteForward(fwForwards[get_num_perks_fwd],result);
				DajPredmet(id, random_num(1, result-1));
			}
			else
			{
				informacije_predmet_igraca[id][1] = random_num(1, 9999);
				set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, informacije_predmet_igraca[id][1]);
			}
		}
		case 7:
		{
			informacije_predmet_igraca[id][1] = random_num(2, 4);
		}
		case 8:
		{
			if(klasa_igraca[id] == Marinac){
				ExecuteForward(fwForwards[get_num_perks_fwd],result);
				DajPredmet(id, random_num(1, result-1));
			}
		}
		case 9:
		{
			informacije_predmet_igraca[id][1] = random_num(1, 3);
			
			ExecuteForward(fwForwards[reset_model_fwd],result,id, 0);
			give_item(id, "weapon_hegrenade");
		}
		case 10:
		{
			informacije_predmet_igraca[id][1] = random_num(4, 8);
			give_item(id, "weapon_hegrenade");
		}
		case 12:
		{
			informacije_predmet_igraca[id][1] = random_num(1, 4);
		}
		case 13:
		{
			give_item(id, "weapon_awp");
		}
		case 15:
		{
			if(klasa_igraca[id] == Rambo){
				ExecuteForward(fwForwards[get_num_perks_fwd],result);
				DajPredmet(id, random_num(1, result-1));
			}
		}
		case 19:
		{
			informacije_predmet_igraca[id][1] = 1;
		}
		case 26:
		{
			informacije_predmet_igraca[id][1] = random_num(3, 6);
		}
		case 27:
		{
			informacije_predmet_igraca[id][1] = 3;
		}
		case 40:
		{
			if(isClassInvisible(klasa_igraca[id]))
			{
				
				ExecuteForward(fwForwards[get_num_perks_fwd],result);
				DajPredmet(id, random_num(1, result-1));
			}
		}
	}
}
public KupiPredmet(id){
	if(cs_get_user_money(id) < 3000){
		client_print(id,print_center,"You do not have enough money !");
		return PLUGIN_HANDLED;
	}
	if(informacije_predmet_igraca[id][0]){
		client_print(id,print_center,"Vec imate predmet!");
		return PLUGIN_HANDLED;
	}
	new result
	ExecuteForward(fwForwards[get_num_perks_fwd],result);
	DajPredmet(id, random_num(1, result-1));
	cs_set_user_money(id,cs_get_user_money(id)-3000,1);
	return PLUGIN_HANDLED;
}
public PobednjenaRunda(const Team[])
{
	new Players[32], playerCount, id;
	get_players(Players, playerCount, "aeh", Team);
	
	if(get_playersnum() < 3)
		return;
	
	for (new i=0; i<playerCount; i++)
	{
		id = Players[i];
		if(!klasa_igraca[id] && !is_user_connected(id))
			continue;
		
		inc_PlayerXp(id,iskustvo_za_pobedu);
		ColorChat(id, NORMAL, "^3[COD:MW2]^4 You've got %i experience for defeated Round.", iskustvo_za_pobedu);
		ProveriNivo(id,klasa_igraca[id],inteligencija_igraca[id],energija_igraca[id],snaga_igraca[id],kondicija_igraca[id]);
	
	}
}	
public plugin_cfg() 
{	
	server_cmd("sv_maxspeed 1000");
}
public plugin_precache()
{
	new Entity = create_entity( "info_map_parameters" );
	if(pev_valid(Entity)){
		
		DispatchKeyValue( Entity, "buying", "3" );
			
	}
	DispatchSpawn( Entity );
	
	
	sprite_white = precache_model("sprites/white.spr") ;
	sprite_blast = precache_model("sprites/dexplo.spr");
	sprite_trail = precache_model("sprites/smoke.spr");
	sprite_smoke = precache_model("sprites/steam1.spr");
	
	
	precache_sound("QTM_CodMod/select.wav");
	precache_sound("QTM_CodMod/start.wav");
	precache_sound("QTM_CodMod/start2.wav");
	precache_sound("QTM_CodMod/levelup.wav");
	
	precache_model("models/w_medkit.mdl");
	precache_model("models/rpgrocket.mdl");
	precache_model("models/mine.mdl");
	precache_model("models/w_law.mdl");
	precache_model("models/v_law.mdl");
	precache_model("models/ByM_Cod/v_katana.mdl");
	precache_model("models/ByM_Cod/v_katanainv.mdl");
	precache_model("models/ByM_Cod/p_katana.mdl");
	precache_model("models/ByM_Cod/v_supershotgun.mdl");
	precache_model("models/ByM_Cod/p_supershotgun.mdl");
	precache_model("models/p_law.mdl");
	precache_model("models/s_grenade.mdl");
}
public pfn_keyvalue( Entity )  
{ 
	new ClassName[ 20 ], Dummy[ 2 ];
	
	
	copy_keyvalue( ClassName, charsmax( ClassName ), Dummy, charsmax( Dummy ), Dummy, charsmax( Dummy ) );
	
	if( equal( ClassName, "info_map_parameters" ) ) 
	{ 
		//remove_entity( Entity );
		return PLUGIN_HANDLED ;
	}
	return PLUGIN_CONTINUE;
}
public CmdStart(id, uc_handle)
{
	if(!is_user_alive(id))
		return FMRES_IGNORED;
	
	
	set_task(0.1, "setInvis", id);
		
	new button = get_uc(uc_handle, UC_Buttons);
	new flags = pev(id, pev_flags);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if(informacije_predmet_igraca[id][0] == 11 || klasa_igraca[id] == Rambo||klasa_igraca[id] == Toker || informacije_predmet_igraca[id][0] == 47)
	{
		new numJumps=broj_skokova_igraca[id];
		MultiJumpExec(id,button,flags,numJumps,informacije_predmet_igraca[id],klasa_igraca[id])
	}
	if(classHasClimbing(klasa_igraca[id]))
	{
		if( button & IN_USE )
			Climb( id,g_wallorigin[id]);
	}
	if(klasa_igraca[id] == JSO)
	{
		set_user_footsteps(id, 1);
	}
	if(klasa_igraca[id] == Camper)
	{
		MagicianApply(id,button);
	}
	if(button & IN_ATTACK)
	{
		
		if(informacije_predmet_igraca[id][0] == 20){
			 reduceRecoil(id,1.0);
		}
		else if(informacije_predmet_igraca[id][0] == 23)
		{
			 reduceRecoil(id,0.8);
			
		}
	}
	if(button & IN_JUMP && button & IN_DUCK && flags & FL_ONGROUND )
	{
		if(get_gametime() > informacije_predmet_igraca[id][1]+4.0){
		if(!classHasMegaJetpack(klasa_igraca[id])){
		if(informacije_predmet_igraca[id][0] == 28 ){
		
			JetpackJump(id,700,informacije_predmet_igraca[id]);
		}
		else if(informacije_predmet_igraca[id][0] == 50){
		
			JetpackJump(id,1250,informacije_predmet_igraca[id]);
		}
		}
		else{
			JetpackJump(id,1500,informacije_predmet_igraca[id]);
		
		}
		}
	}
	if(weapon == 1 && ima_bazuku[id])
	{ 
		new button = get_uc(uc_handle, UC_Buttons);
		new ent = find_ent_by_owner(-1, "weapon_p228", id);
		if(!pev_valid(ent)){
			
				return FMRES_IGNORED
		}
		if(button & IN_ATTACK)
		{
			button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, button);
			
			if(!rakete_igraca[id] || reloading[id] || !idle[id]) 
				return FMRES_IGNORED;
			if(idle[id] && (get_gametime()-idle[id]<=0.4)) 
				return FMRES_IGNORED;
			
			new Float:Origin[3], Float:Angle[3], Float:Velocity[3];
			pev(id, pev_origin, Origin);
			pev(id, pev_v_angle, Angle);
			velocity_by_aim(id, 1000, Velocity);
			
			Angle[0] *= -1.0
			
			new ent = create_entity("info_target")
			if(!pev_valid(ent)){
				
					return FMRES_IGNORED
			}
			set_pev(ent, pev_classname, "rocket");
			engfunc(EngFunc_SetModel, ent, "models/s_grenade.mdl");
			
			set_pev(ent, pev_solid, SOLID_BBOX);
			set_pev(ent, pev_movetype, MOVETYPE_TOSS);
			set_pev(ent, pev_owner, id);
			set_pev(ent, pev_mins, Float:{-1.0, -1.0, -1.0});
			set_pev(ent, pev_maxs, Float:{1.0, 1.0, 1.0});
			set_pev(ent, pev_gravity, 0.35);
			
			set_pev(ent, pev_origin, Origin);
			set_pev(ent, pev_velocity, Velocity);
			set_pev(ent, pev_angles, Angle);
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMFOLLOW)
			write_short(ent)
			write_short(sprite_trail)
			write_byte(6)
			write_byte(3)
			write_byte(224)	
			write_byte(224)	
			write_byte(255)
			write_byte(100)
			message_end()	
			
			set_pev(id, pev_weaponanim, 7);
			new entwpn = find_ent_by_owner(-1, "weapon_p228", id);
			if(entwpn)
				set_pdata_float(entwpn, 48, 1.5+3.0, 4);
			set_pdata_float(id, 83, 1.5, 4)
			
			reloading[id] = true;
			emit_sound(id, CHAN_WEAPON, "weapons/law_shoot1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			
			if(task_exists(id+3512)) 
				remove_task(id+3512);
			
			set_task(1.5, "task_launcher_reload", id+3512);
			rakete_igraca[id]--;
		}
		else if(button & IN_RELOAD)
		{
			button &= ~IN_RELOAD;
			set_uc(uc_handle, UC_Buttons, button);
			
			set_pev(id, pev_weaponanim, 0);
			set_pdata_float(id, 83, 0.5, 4);
			if(ent)
				set_pdata_float(ent, 48, 0.5+3.0, 4);
		}
		if(ent)
		{
			cs_set_weapon_ammo(ent, -1);
			cs_set_user_bpammo(id, 1, rakete_igraca[id]);
		}
	}
	else if(weapon != 1 && ima_bazuku[id])
		idle[id] = 0.0;
	
	return FMRES_IGNORED;
}

public Shope(id)
{
	new menu = menu_create("Shop:", "AAAbp");
	menu_additem(menu, "\yOrdinary Shop");
	menu_additem(menu, "\yGB Shop");
	menu_display(id, menu);
}
public AAAbp(id, menu, item) 
{
	
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	switch(item) 
	{ 
		case 0:
		{
			Shop(id)
		}
		case 1:
		{
			Predmeti(id)
		}
	}
	return PLUGIN_CONTINUE;
}  
public Shop(id)
{
	new menu = menu_create("\yShop Menu \d:", "Shop_Handle");
	menu_additem(menu, "\ySmall Pharmacy \r[Gives 50 HP] \yPrice: \r3000$");
	menu_additem(menu, "\yUnited Pharmacy \r[Gives 100 HP] \yPrice: \r5000$");
	menu_additem(menu, "\yRed Bull \r[Jump higher + Higher speed] \yPrice: \r7500$");
	menu_additem(menu, "\yLotto \r[Ticket lottery] \yPrice: \r2000$");
	menu_additem(menu, "\ySmall Exp \r[Gives 250 XP] \yPrice: \r5000$");
	menu_additem(menu, "\yGreat Exp \r[Gives 500 XP] \yPrice: \r10000$");
	menu_additem(menu, "\yRandom Item \yPrice: \r3000$");
	menu_display(id, menu);
}
public Shop_Handle(id, menu, item) 
{
	
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	menu_display(id, menu);
	new pare_igraca = cs_get_user_money(id);
	new hp = get_user_health(id);
	switch(item) 
	{ 
		case 0:
		{
			new cena = 3000;
			if (pare_igraca<cena)
			{
				ColorChat(id,GREEN,"[Shop] ^1You do not have enough money.");
				return PLUGIN_CONTINUE;
			}
			if(hp >= maximalna_energija_igraca[id] || klasa_igraca[id] == Assassin)
			{
				ColorChat(id,GREEN,"[Shop] ^1Already have maximal energy.");
				return PLUGIN_CONTINUE;
			}
			new ammount=50;
			new nova_energija = (hp+ammount<maximalna_energija_igraca[id])? hp+ammount: maximalna_energija_igraca[id];
			set_user_health(id, nova_energija);
			ColorChat(id,GREEN,"[Shop] ^1You bought ^3Small pharmacy");
			cs_set_user_money(id, pare_igraca-cena);
		}
		case 1:
		{
			new cena = 5000;
			if (pare_igraca<cena)
			{
				ColorChat(id,GREEN,"[Shop] ^1You do not have enough money.");
				return PLUGIN_CONTINUE;
			}
			if(hp >= maximalna_energija_igraca[id] || klasa_igraca[id] == Assassin)
			{
				ColorChat(id,GREEN,"[Shop] ^1Already have maximal energy.");
				return PLUGIN_CONTINUE;
			}
			new ammount=100;
			new nova_energija = (hp+ammount<maximalna_energija_igraca[id])? hp+ammount: maximalna_energija_igraca[id];
			set_user_health(id, nova_energija);
			ColorChat(id,GREEN,"[Shop] ^1You bought^3 Big Pharmacy");
			cs_set_user_money(id, pare_igraca-cena);
		}
		case 2:
		{
			new cena = 7500;
			if (pare_igraca<cena)
			{
				ColorChat(id,GREEN,"[Shop] ^1You do not have enough money.");
				return PLUGIN_CONTINUE;
			}
			set_user_gravity(id,get_user_gravity(id) - 0.3);
			set_user_maxspeed(id,get_user_maxspeed(id) + 10.0);
			ColorChat(id,GREEN,"[Shop]^1 You bought^3 RedBull.");
			ColorChat(id,GREEN,"[RedBull]^1Now you can get wings to fly as^3 bird.");
			cs_set_user_money(id, pare_igraca-cena)
		}
		case 3:
		{
			new cena = 2000;
			if (pare_igraca<cena)
			{
				ColorChat(id,GREEN,"[Shop] ^1You do not have enough money.");
				return PLUGIN_CONTINUE;
			}
			cs_set_user_money(id, pare_igraca-cena);
			ColorChat(id,GREEN,"[Shop] ^1You have bought a lottery ticket");
			ColorChat(id,GREEN,"[Shop] ^1Wait a couple^3 of seconds^1 to see your^3 award");
			
			new rand = random_num(0,13);
			switch(rand)
			{
				case 0:
				{
					ColorChat(id,GREEN,"[Shop] ^1you've got^3 100 $^1!")
					cs_set_user_money(id, pare_igraca + 100)
				}
				case 1:
				{
					ColorChat(id,GREEN,"[Shop] ^1You've got^3 Redbull^1!");
					ColorChat(id,GREEN,"[RedBull]^1Now you can get wings to fly like a  bird^1.");
					set_user_gravity(id,get_user_gravity(id) - 0.3);
					set_user_maxspeed(id,get_user_maxspeed(id) + 10.0);
				}
				case 2:
				{
					ColorChat(id,GREEN,"[Shop] ^1Unfortunately nothing^3 get^1!")
				}
				case 3:
				{
					ColorChat(id,GREEN,"[Shop] ^1lost^3 150$^1!")
					cs_set_user_money(id, pare_igraca - 150)
				}
				case 4:
				{
					ColorChat(id,GREEN,"[Shop] ^1you've^3 1000$^1!")
					cs_set_user_money(id, pare_igraca + 1000)
				}
				case 5:
				{
					ColorChat(id,GREEN,"[Shop] ^1you've got ^3 item^1!")
					new result
					ExecuteForward(fwForwards[get_num_perks_fwd],result)
					DajPredmet(id, random_num(1, result-1));
				}
				case 6:
				{
					ColorChat(id,GREEN,"[Shop] ^1Unfortunately did not get anything^1!")
				}
				case 7:
				{
					ColorChat(id,GREEN,"[Shop] ^1You have lost ^3 8000$^1!")
					cs_set_user_money(id, pare_igraca - 8000)
				}
				case 8:
				{
					ColorChat(id,GREEN,"[Shop] ^1Unfortunately, you are not getting ^3^1!")
				}
				case 9:
				{
					ColorChat(id,GREEN,"[Shop]^1 you've^3 1000 EXP ^1!")
					inc_PlayerXp(id, iskustvo_za_mnogopara);
				}
				case 10:
				{
					ColorChat(id,GREEN,"[Shop]^1 you've^3 500 EXP^1!")
					inc_PlayerXp(id, 500);
				}
				case 11:
				{
					ColorChat(id,GREEN,"[Shop] ^1 Congratulations you get a premium class ^3:^3 you can use it by the end of the mapr^1!")
					set_user_flags(id, ADMIN_LEVEL_F)
				}
				case 12:
				{
					ColorChat(id,GREEN,"[Shop]^1 you've^3 100 EXP^1 !")
					inc_PlayerXp(id, 100);
				}
				case 13:
				{
					ColorChat(id,GREEN,"[Shop]^1 lost^3 100 HP")
					new ammount=-100;
					new nova_energija = (hp+ammount<maximalna_energija_igraca[id])? hp+ammount: maximalna_energija_igraca[id];
					set_user_health(id, nova_energija);
				}
			}
			ProveriNivo(id,klasa_igraca[id],inteligencija_igraca[id],energija_igraca[id],snaga_igraca[id],kondicija_igraca[id]);
	
			return PLUGIN_CONTINUE;
		}
		case 4:
		{
			new cena = 5000;
			if (pare_igraca<cena)
			{
				ColorChat(id,GREEN,"[Shop]^1 You do not have enough money.");
				return PLUGIN_CONTINUE;
			}
			inc_PlayerXp(id, iskustvo_za_pare);
			ColorChat(id,GREEN,"[Shop] ^1You bought ^3 Small EXP");
			cs_set_user_money(id, pare_igraca-cena)
			
			ProveriNivo(id,klasa_igraca[id],inteligencija_igraca[id],energija_igraca[id],snaga_igraca[id],kondicija_igraca[id]);
	
		}
		case 5:
		{
			new cena = 10000;
			if (pare_igraca<cena)
			{
				ColorChat(id,GREEN,"[Shop]^1 You do not have enough money.");
				return PLUGIN_CONTINUE;
			}
			inc_PlayerXp(id, iskustvo_za_mnogopara);
			ColorChat(id,GREEN,"[Shop]^1You bought ^3Larger EXP");
			cs_set_user_money(id, pare_igraca-cena)
			ProveriNivo(id,klasa_igraca[id],inteligencija_igraca[id],energija_igraca[id],snaga_igraca[id],kondicija_igraca[id]);
	
		}		
		case 6:
		{
			new cena = 3000;						
			if (pare_igraca<cena)
			{
				ColorChat(id,RED,"[Shop]^1 You do not have enough money!");
				return PLUGIN_CONTINUE;
			}
			cs_set_user_money(id, pare_igraca-cena)
			new result
			ExecuteForward(fwForwards[get_num_perks_fwd],result)
			DajPredmet(id, random_num(1, result-1));
		}
	}
	return PLUGIN_CONTINUE;
}
public Predmeti(id)
{
	
	if (!is_user_connected(id)) 
		return
	
	new naslow[60]
	new player_gb
	ExecuteForward(fwForwards[get_player_gb_fwd],player_gb,id);
	format(naslow, 59, "\yGB Shop(\r%i\y):", player_gb);
	new menu = menu_create(naslow, "Predmeti_Handle");
	menu_additem(menu, "\dScout Expert \y[\ritem\y] \dPrice: \y200 GB");  //Hvala Razor za ovo \d
	menu_additem(menu, "\dAWP Master \y[\rItem\y] \dPrice: \y200 GB");  //Hvala Razor za ovo \d
	menu_additem(menu, "\dOnly Headshoot \y[\rItem\y] \dPrice: \y175 GB");   //Hvala Razor za ovo \d
	menu_additem(menu, "\dSet Stunter \y[\rItem\y] \dPRice: \y175 GB");   //Hvala Razor za ovo \d
	menu_additem(menu, "\dHE Expert \y[\rItem\y] \dPRice: \y145 GB");   //Hvala Razor za ovo \d
	menu_additem(menu, "\dM4 Swat \y[\rItem\y] \dPrice: \y145 GB");   //Hvala Razor za ovo \d
	menu_additem(menu, "\dAssassin Cloak \y[\rItem\y] \dPrice: \y120 GB");   //Hvala Razor za ovo \d
	menu_display(id, menu);
}
public Predmeti_Handle(id, menu, item) 
{
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	client_cmd(id, "spk QTM_CodMod/select");
	
	new player_gb
	ExecuteForward(fwForwards[get_player_gb_fwd],player_gb,id);
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	switch(item) 
	{ 
		case 0:
		{
			if(player_gb<200)
			{
				ColorChat(id,RED,"[COD MW4]^1 You do not have enough ^4GB points!");
				return PLUGIN_HANDLED;
			}
			ExecuteForward(fwForwards[add_player_gb_fwd],player_gb,id,-200)
			DajPredmet(id, 34)
		}
		case 1:
		{
			if(player_gb<200)
			{
				ColorChat(id,RED,"[COD MW4]^1 You do not have enough ^4GB points!");
				return PLUGIN_HANDLED;
			}
			ExecuteForward(fwForwards[add_player_gb_fwd],player_gb,id,-200)
			DajPredmet(id, 13)
		}
		case 2:
		{
			if(player_gb<175)
			{
				ColorChat(id,RED,"[COD MW4]^1 You do not have enough ^4GB points!");
				return PLUGIN_HANDLED;
			}
			ExecuteForward(fwForwards[add_player_gb_fwd],player_gb,id,-175)
			DajPredmet(id, 41)
		}
		case 3:
		{
			if(player_gb<175)
			{
				ColorChat(id,RED,"[COD MW4]^1 You do not have enough ^4GB points!");
				return PLUGIN_HANDLED;
			}
			ExecuteForward(fwForwards[add_player_gb_fwd],player_gb,id,-175)
			DajPredmet(id, 31)
		}
		case 4:
		{
			if(player_gb<145)
			{
				ColorChat(id,RED,"[COD MW4]^1 You do not have enough ^4GB points!");
				return PLUGIN_HANDLED;
			}
			ExecuteForward(fwForwards[add_player_gb_fwd],player_gb,id,-145)
			DajPredmet(id, 10)
		}
		case 5:
		{
			if(player_gb<145)
			{
				ColorChat(id,RED,"[COD MW4]^1 You do not have enough ^4GB points!");
				return PLUGIN_HANDLED;
			}
			ExecuteForward(fwForwards[add_player_gb_fwd],player_gb,id,-145)
			DajPredmet(id, 32)
		}
		case 6:
		{
			if(player_gb<120)
			{
				ColorChat(id,RED,"[COD MW4]^1 You do not have enough ^4GB points!");
				return PLUGIN_HANDLED;
			}
			ExecuteForward(fwForwards[add_player_gb_fwd],player_gb,id,-120)
			DajPredmet(id, 40)
		}
	}
	return PLUGIN_CONTINUE;
}
public DodelaPoena(id)
{
	
	if (!is_user_connected(id)) 
		return
	
	new inteligencija[65], inteligencija10[65], inteligencija100[65], inteligencija1000[65];
	new energija[60], energija10[60], energija100[65], energija1000[65];
	new snaga[60], snaga10[60], snaga100[60], snaga1000[60];
	new kondicija[60], kondicija10[60], kondicija100[60], kondicija1000[60];
	new naslov[25];
	format(inteligencija, 64, "\yIntelligence: \r%i \y(Increases attack)", inteligencija_igraca[id]);
	format(energija, 59, "\yEnergy: \r%i \y(Increases HP)", energija_igraca[id]);
	format(snaga, 59, "\yResistance: \r%i \y(Reduces violation)", snaga_igraca[id]);
	format(kondicija, 59, "\yStamina: \r%i \y(Increases the pace of walking)", kondicija_igraca[id]);
	format(inteligencija10, 64, "\yAdd \d10 \ypoints to Intelligence");
	format(energija10, 59, "\yAdd \d10 \ypoints to Energy");
	format(snaga10, 59, "\yAdd \d10 \ypoints to Resistance");
	format(kondicija10, 59, "\yAdd \d10 \ypoints to Stamina");
	format(inteligencija100, 64, "\yAdd \d100 \ypoints to Intelligence");
	format(energija100, 59, "\yAdd \d100 \ypoints to Energy");
	format(snaga100, 59, "\yAdd \d100 \ypoints to Resistance");
	format(kondicija100, 59, "\yAdd \d100 \ypoints to Stamina");
	format(inteligencija1000, 64, "\yAdd \d1000 \ypoints to Intelligence");
	format(energija1000, 59, "\yAdd \d1000 \ypoints to Energy");
	format(snaga1000, 59, "\yAdd \d1000 \ypoints to Resistance");
	format(kondicija1000, 59, "\yAdd \d1000 \ypoints to Stamina");
	format(naslov, 24, "\Award points(%i):", get_PlayerPoints(id));
	new menu = menu_create(naslov, "DodelaPoena_Handler");
	menu_additem(menu, inteligencija);
	menu_additem(menu, energija);
	menu_additem(menu, snaga);
	menu_additem(menu, kondicija);
	menu_additem(menu, inteligencija10);
	menu_additem(menu, energija10);
	menu_additem(menu, snaga10);
	menu_additem(menu, kondicija10);
	menu_additem(menu, inteligencija100);
	menu_additem(menu, energija100);
	menu_additem(menu, snaga100);
	menu_additem(menu, kondicija100);
	menu_additem(menu, inteligencija1000);
	menu_additem(menu, energija1000);
	menu_additem(menu, snaga1000);
	menu_additem(menu, kondicija1000);
	menu_display(id, menu);
	#if defined BOTY
	if(is_user_bot(id)){
		new qtr=get_PlayerPoints(id)/4;
		
		new valueIntel=min(qtr,get_PlayerPoints(id));
		inteligencija_igraca[id]+=valueIntel;
		inc_PlayerPoints(id,-valueIntel)
		
		valueIntel=min(qtr,get_PlayerPoints(id));
		energija_igraca[id]+=valueIntel;
		inc_PlayerPoints(id,-valueIntel)
		
		valueIntel=min(qtr,get_PlayerPoints(id));
		snaga_igraca[id]+=valueIntel;
		inc_PlayerPoints(id,-valueIntel)
		
		valueIntel=min(qtr,get_PlayerPoints(id));
		kondicija_igraca[id]+=valueIntel;
		inc_PlayerPoints(id,-valueIntel)
		
	}
	#endif
}
public DodelaPoena_Handler(id, menu, item)
{
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	if(get_PlayerPoints(id) < 1)
		return PLUGIN_CONTINUE;
	
	switch(item) 
	{ 
		case 0: 
		{	
			if(inteligencija_igraca[id]<3000)
			{
				inteligencija_igraca[id]++;
				inc_PlayerPoints(id,-1)
			}
			else 
				ColorChat(id, NORMAL, "^4[COD:MW4] ^1Dostigli ste maximalni nivo inteligencije");
			
		}
		case 1: 
		{	
			if(energija_igraca[id]<3000)
			{
				energija_igraca[id]++;
				inc_PlayerPoints(id,-1)
			}
			else 
				ColorChat(id, NORMAL, "^4[COD:MW4] ^1Dostigli ste maximalni nivo energije");
		}
		case 2: 
		{	
			if(snaga_igraca[id]<3000)
			{
				snaga_igraca[id]++;
				inc_PlayerPoints(id,-1)
			}
			else 
				ColorChat(id, NORMAL, "^4[COD:MW4] ^1Dostigli ste maximalni nivo snage");
			
		}
		case 3: 
		{	
			if(kondicija_igraca[id]<3000)
			{
				kondicija_igraca[id]++;
				inc_PlayerPoints(id,-1)
			}
			else 
				ColorChat(id, NORMAL, "^4[COD:MW4] ^1Dostigli ste maximalni nivo kondicije");
		}
		case 4:
		{
			if(get_PlayerPoints(id) < 10)
			{
				//ColorChat(id, NORMAL, "^4[COD:MW4] ^1You do not have enough points");
				
				inteligencija_igraca[id]+=get_PlayerPoints(id) ;
				set_PlayerPoints(id,0)
			}
			else if(inteligencija_igraca[id]<3000)
			{
				inteligencija_igraca[id]+=10;
				inc_PlayerPoints(id,-10)
			}
			else
				ColorChat(id, NORMAL, "^4[COD:MW4] ^1Dostigli ste maximalni nivo inteligencije");
		}
		case 5: 
		{
			if(get_PlayerPoints(id) < 10)
			{
				//ColorChat(id, NORMAL, "^4[COD:MW4] ^1You do not have enough points");
				
				energija_igraca[id]+=get_PlayerPoints(id) ;
				set_PlayerPoints(id,0)
			}	
			else if(energija_igraca[id]<3000)
			{
				energija_igraca[id]+=10;
				inc_PlayerPoints(id,-10)
			}
			else 
				ColorChat(id, NORMAL, "^4[COD:MW4] ^1Dostigli ste maximalni nivo energije");
		}
		case 6: 
		{
			if(get_PlayerPoints(id) < 10)
			{
				//ColorChat(id, NORMAL, "^4[COD:MW4] ^1You do not have enough points");
				
				snaga_igraca[id]+=get_PlayerPoints(id) ;
				set_PlayerPoints(id,0)
			}	
			else if(snaga_igraca[id]<3000)
			{
				snaga_igraca[id]+=10;
				inc_PlayerPoints(id,-10)
			}
			else 
				ColorChat(id, NORMAL, "^4[COD:MW4] ^1Dostigli ste maximalni nivo snage");
		}
		case 7: 
		{
			if(get_PlayerPoints(id) < 10)
			{
				//ColorChat(id, NORMAL, "^4[COD:MW4] ^1You do not have enough points");
				kondicija_igraca[id]+=get_PlayerPoints(id) ;
				set_PlayerPoints(id,0)
			}	
			else if(kondicija_igraca[id]<3000)
			{
				kondicija_igraca[id]+=10;
				inc_PlayerPoints(id,-10)
			}
			else 
				ColorChat(id, NORMAL, "^4[COD:MW4] ^1Dostigli ste maximalni nivo kondicije");
		}
		case 8: 
		{
			if(get_PlayerPoints(id) < 100)
			{
				//ColorChat(id, NORMAL, "^4[COD:MW4] ^1You do not have enough points");
				inteligencija_igraca[id]+=get_PlayerPoints(id) ;
				set_PlayerPoints(id,0)
			}	
			else if(inteligencija_igraca[id]<3000)
			{
				inteligencija_igraca[id]+=100;
				inc_PlayerPoints(id,-100)
			}
			else 
				ColorChat(id, NORMAL, "^4[COD:MW4] ^1Dostigli ste maximalni nivo inteligencije");
		}
		case 9: 
		{
			if(get_PlayerPoints(id)< 100)
			{
				//ColorChat(id, NORMAL, "^4[COD:MW4] ^1You do not have enough points");
				energija_igraca[id]+=get_PlayerPoints(id) ;
				set_PlayerPoints(id,0)
			}	
			else if(energija_igraca[id]<3000)
			{
				energija_igraca[id]+=100;
				inc_PlayerPoints(id,-100)
			}
			else 
				ColorChat(id, NORMAL, "^4[COD:MW4] ^1Dostigli ste maximalni nivo energije");
		}
		case 10: 
		{
			if(get_PlayerPoints(id) < 100)
			{
				//ColorChat(id, NORMAL, "^4[COD:MW4] ^1You do not have enough points");
				snaga_igraca[id]+=get_PlayerPoints(id) ;
				set_PlayerPoints(id,0)
			}	
			else if(snaga_igraca[id]<3000)
			{
				snaga_igraca[id]+=100;
				inc_PlayerPoints(id,-100)
			}
			else 
				ColorChat(id, NORMAL, "^4[COD:MW4] ^1Dostigli ste maximalni nivo snage");
		}
		case 11: 
		{
			if(get_PlayerPoints(id)< 100)
			{
				//ColorChat(id, NORMAL, "^4[COD:MW4] ^1You do not have enough points");
				kondicija_igraca[id]+=get_PlayerPoints(id) ;
				set_PlayerPoints(id,0)
			}	
			else if(kondicija_igraca[id]<3000)
			{
				kondicija_igraca[id]+=100;
				inc_PlayerPoints(id,-100)
			}
			else 
				ColorChat(id, NORMAL, "^4[COD:MW4] ^1Dostigli ste maximalni nivo kondicije");
		}
		case 12: 
		{
			if(get_PlayerPoints(id) < 1000)
			{
				//ColorChat(id, NORMAL, "^4[COD:MW4] ^1You do not have enough points");
				
				inteligencija_igraca[id]+=get_PlayerPoints(id) ;
				set_PlayerPoints(id,0)
			}	
			else if(inteligencija_igraca[id]<3000)
			{
				inteligencija_igraca[id]+=1000;
				inc_PlayerPoints(id,-1000)
			}
			else 
				ColorChat(id, NORMAL, "^4[COD:MW4] ^1Dostigli ste maximalni nivo inteligencije");
		}
		case 13: 
		{
			if(get_PlayerPoints(id)< 1000)
			{
				//ColorChat(id, NORMAL, "^4[COD:MW4] ^1You do not have enough points");
				energija_igraca[id]+=get_PlayerPoints(id) ;
				set_PlayerPoints(id,0)
			}	
			else if(energija_igraca[id]<3000)
			{
				energija_igraca[id]+=1000;
				inc_PlayerPoints(id,-1000)
			}
			else 
				ColorChat(id, NORMAL, "^4[COD:MW4] ^1Dostigli ste maximalni nivo energije");
		}
		case 14: 
		{
			if(get_PlayerPoints(id)< 1000)
			{
				//ColorChat(id, NORMAL, "^4[COD:MW4] ^1You do not have enough points");
				snaga_igraca[id]+=get_PlayerPoints(id) ;
				set_PlayerPoints(id,0)
			}	
			else if(snaga_igraca[id]<3000)
			{
				snaga_igraca[id]+=1000;
				inc_PlayerPoints(id,-1000)
			}
			else 
				ColorChat(id, NORMAL, "^4[COD:MW4] ^1Dostigli ste maximalni nivo snage");
		}
		case 15: 
		{
			if(get_PlayerPoints(id)< 1000)
			{
				//ColorChat(id, NORMAL, "^4[COD:MW4] ^1You do not have enough points");
				kondicija_igraca[id]+=get_PlayerPoints(id) ;
				set_PlayerPoints(id,0)
			}	
			else if(kondicija_igraca[id]<3000)
			{
				kondicija_igraca[id]+=1000;
				inc_PlayerPoints(id,-1000)
			}
			else 
				ColorChat(id, NORMAL, "^4[COD:MW4] ^1Dostigli ste maximalni nivo kondicije");
		}
	}
	if(get_PlayerPoints(id)>0)
		DodelaPoena(id);
	
	return PLUGIN_CONTINUE;
}
public Pocetak(id)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return PLUGIN_CONTINUE;
	
	
	if(nova_klasa_igraca[id])
	{
		klasa_igraca[id] = nova_klasa_igraca[id];
		nova_klasa_igraca[id] = 0;
		ima_bazuku[id] = false;
		rakete_igraca[id] = 0;
		strip_user_weapons(id);
		give_item(id, "weapon_knife");
		
		UcitajPodatke(id, klasa_igraca[id]);
	}
	if(!klasa_igraca[id])
	{
		IzaberiKlasu(id);
		return PLUGIN_CONTINUE;
	}
	switch(klasa_igraca[id])
	{
		case Snajperista:
		{
			give_item(id, "weapon_awp");
			give_item(id, "weapon_scout");
			give_item(id, "weapon_deagle");
		}
		case Marinac:
		{
			give_item(id, "weapon_deagle");
		}
		case UltraMarinac:
		{
			give_item(id, "weapon_usp");
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 55);
		}
		case ProStrelac:
		{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_ak47");
		}
		case Mitraljezac:
		{
			give_item(id, "weapon_m249");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");                             
			give_item(id, "weapon_smokegrenade");
		}
		case Doktor:
		{
			give_item(id, "weapon_ump45")
			broj_medkit_igraca[id] = 4
		}      
		case VatrenaPodrska:
		{
			give_item(id, "weapon_mp5navy");
			broj_raketa_igraca[id] = 2;
		}
		case Miner:
		{
			give_item(id, "weapon_p90");
			broj_min_igraca[id] = 3
		}
		case Demolitions:
		{
			give_item(id, "weapon_aug");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_smokegrenade");
			broj_dinamita_igraca[id] = 1;
		}
		case Rusher:
		{
			give_item(id, "weapon_m3");
		}
		case Rambo:
		{
			give_item(id, "weapon_famas");
			broj_skokova_igraca[id]=2;
		}
		case Revolveras:
		{
			give_item(id, "weapon_elite");
			broj_raketa_igraca[id] = 2;
		}
		case Bombarder:
		{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_deagle");
			give_item(id, "weapon_hegrenade");
			cs_set_user_bpammo(id, CSW_HEGRENADE, 15);
		}
		case Strelac:
		{
			give_item(id, "weapon_xm1014");
			give_item(id, "weapon_elite");
		}
		case Informator:
		{
			give_item(id, "weapon_mp5navy");
		}
		case Pukovnik:
		{
			give_item(id, "weapon_famas");
			give_item(id, "weapon_deagle");
			broj_min_igraca[id] = 2
		}
		case Pobunjenik:            
		{
			give_item(id, "weapon_sg552");
			broj_raketa_igraca[id] = 2;
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 65);
		}      
		case SerijskiUbica:
		{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_smokegrenade");
		}
		case Desetar:
		{
			give_item(id, "weapon_scout");
			give_item(id, "weapon_deagle");
		}
		case Vodnik:
		{
			give_item(id, "weapon_m3");
			
		}
		case Kamikaza:
		{
			give_item(id, "weapon_m4a1");
			broj_raketa_igraca[id] = 2;
		}
		case Assassin:
		{      
			give_item(id, "weapon_deagle");
		}
		case Gazija:
		{      
			give_item(id, "weapon_deagle");
		}
		case ProSWAT:
		{      
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_usp");
			broj_raketa_igraca[id] = 2;
		}
		case Major:
		{
			give_item(id, "weapon_glock18");
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_usp");
			give_item(id, "weapon_p228");
			give_item(id, "weapon_deagle");
			give_item(id, "weapon_elite");
			give_item(id, "weapon_fiveseven");
			give_item(id, "weapon_smokegrenade");
			broj_min_igraca[id] = 10
		}
		case Kapetan:
		{
			give_item(id, "weapon_aug");
		}
		case Potpukovnik:
		{
			give_item(id, "weapon_awp");
			give_item(id, "weapon_deagle");
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 55);
		}
		case Marsal:
		{
			give_item(id, "weapon_deagle");
		}
		case NemackiStrelac:
		{
			give_item(id, "weapon_ak47");
			broj_raketa_igraca[id] = 2;
		}
		case RuskiPukovnik:
		{
			give_item(id, "weapon_m4a1");
			broj_min_igraca[id] = 1
		}
		case PoljskaPesadija:
		{
			give_item(id, "weapon_mp5navy");
			broj_dinamita_igraca[id] = 2
		}
		case Mornar:
		{
			give_item(id, "weapon_mac10");
			broj_min_igraca[id] = 2
		}
		case Napadac:
		{
			give_item(id, "weapon_famas");
			give_item(id, "weapon_p90");
			broj_dinamita_igraca[id] = 0
		}
		case Legija:
		{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_sg552");
			give_item(id, "weapon_deagle");
		}
		case Armageddon:
		{
			give_item(id, "weapon_ak47");
			give_item(id, "weapon_aug");
			give_item(id, "weapon_hegrenade");
			broj_dinamita_igraca[id] = 3
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 50);    
		}
		case Samuraj:
		{
			give_item(id, "weapon_usp");
		}
		case RatkoMladic:
		{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_ak47");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_deagle");
			broj_raketa_igraca[id] = 5;
		}
		case SWAT:
		{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_usp");
		}
		case Partizan:
		{
			give_item(id, "weapon_p90");
			give_item(id, "weapon_flashbang");
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 70);
		}
		case Gunner:
		{
			give_item(id, "weapon_g3sg1");
			give_item(id, "weapon_deagle");
			give_item(id, "weapon_hegrenade");
			broj_raketa_igraca[id] = 2;
		}
		case Cleric:
		{
			give_item(id, "weapon_ak47");
			give_item(id, "weapon_elite");
			broj_min_igraca[id] = 3
		}
		case General:
		{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_p90");
			give_item(id, "weapon_deagle");
			
			new result;
			ExecuteForward(fwForwards[reset_model_fwd],result,id, 0);
		}
		case Terminator:
		{
			give_item(id, "weapon_ak47");
			give_item(id, "weapon_usp");
			broj_raketa_igraca[id] = 2;
		}
		case Slayer:
		{
			give_item(id, "weapon_famas");
			give_item(id, "weapon_p90");
			broj_raketa_igraca[id] = 3;
		}
		case Zastavnik:
		{
			give_item(id, "weapon_p90");
			give_item(id, "weapon_deagle");
			broj_raketa_igraca[id] = 2;
		}
		case Admiral:
		{
			give_item(id, "weapon_ak47");
			give_item(id, "weapon_famas");
		}
		case Fighter:
		{
			give_item(id, "weapon_mac10");
			give_item(id, "weapon_scout");
			give_item(id, "weapon_usp");
			broj_dinamita_igraca[id] = 2
		}
		case Policajac:
		{
			give_item(id, "weapon_xm1014");
			give_item(id, "weapon_tmp");
			give_item(id, "weapon_fiveseven");     
			
		}
		case Specijalac:
		{
			give_item(id, "weapon_famas");
			give_item(id, "weapon_p228");
			give_item(id, "weapon_m3");    
			
		}
		case Predator:
		{
			give_item(id, "weapon_sg552");
			give_item(id, "weapon_glock18");
			give_item(id, "weapon_smokegrenade");
			
		}
		case NemackiOficir:
		{
			give_item(id, "weapon_p90");
			give_item(id, "weapon_glock18");
			give_item(id, "weapon_smokegrenade");
		}
		case Cetnik:
		{
			give_item(id, "weapon_ak47");
			give_item(id, "weapon_hegrenade");
			give_item(id, "weapon_hegrenade");
			broj_dinamita_igraca[id] = 2
		}
		case ProfVojnik:
		{
			give_item(id, "weapon_famas");
			give_item(id, "weapon_usp");
			broj_raketa_igraca[id] = 2;
		}
		case Crysis:            
		{
			give_item(id, "weapon_sg552");
			give_item(id, "weapon_m4a1");
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 70);
		}
		case ProfStrelac:
		{
			give_item(id, "weapon_awp");
			give_item(id, "weapon_m4a1");
			broj_raketa_igraca[id] = 2;
		}
		case Komandos:
		{
			give_item(id, "weapon_m4a1");
			broj_dinamita_igraca[id] = 3;
			broj_raketa_igraca[id] = 3;
			broj_min_igraca[id] = 3;
		}
		case Ghost:
		{
			give_item(id, "weapon_mac10");
			set_user_footsteps(id, 1);
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 0);
		}
		case JSO:
		{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_mp5navy");
			broj_raketa_igraca[id] = 2;
			set_user_footsteps(id, 1);
		}
		case ProMiner:
		{
			give_item(id, "weapon_mp5navy");
			broj_min_igraca[id] = 5;
		}
		case Placenik:
		{
			give_item(id, "weapon_mp5navy");
			give_item(id, "weapon_m3");
		}
		case BazookaSoldier:
		{
			give_item(id, "weapon_p228");
			give_item(id, "weapon_deagle");
			//ima_bazuku[id] = true;
			rakete_igraca[id] = 10;
		}
		case Price:
		{
			give_item(id, "weapon_g3sg1");
			give_item(id, "weapon_usp");
		}
		case Camper:
		{
			give_item(id, "weapon_awp");
			give_item(id, "weapon_deagle");
		}
		case Zmaj:
		{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_mp5navy");
			broj_raketa_igraca[id] = 3;
		}
		case Toker:
		{
			give_item(id, "weapon_m4a1");
			give_item(id, "weapon_awp");
			give_item(id, "weapon_hegrenade");
			broj_raketa_igraca[id] = 2;
			broj_skokova_igraca[id]=3;
		}
		case Ninja:
		{
			give_item(id, "weapon_usp");
			set_user_footsteps(id, 1);
			set_user_gravity(id, 0.56);
		}
		case Shredder:
		{
			give_item(id, "weapon_ak47");
			set_user_footsteps(id, 1);
			broj_dinamita_igraca[id] = 5;
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 20);
		}
		case ProAssassin:
		{
			give_item(id, "weapon_mp5navy");
			give_item(id, "weapon_deagle");
			broj_raketa_igraca[id] = 2;
		}
		case Soap:
		{
			give_item(id, "weapon_g3sg1");
			give_item(id, "weapon_deagle");
			broj_dinamita_igraca[id] = 10;
		}
		case Google:
		{
			give_item(id, "weapon_famas");
			give_item(id, "weapon_ak47");
			give_item(id, "weapon_p90");
			give_item(id, "weapon_elite");
		}
		case Hulk:
		{
			give_item(id, "weapon_p90");
			give_item(id, "weapon_deagle");
			broj_dinamita_igraca[id] = 3;
		}
		case Graciete:
		{
			give_item(id, "weapon_elite");
			give_item(id, "weapon_m3");
			set_user_rendering(id, kRenderFxGlowShell,255, 0, 0, kRenderTransColor, 255);
			broj_dinamita_igraca[id] = 15;
		}
		case ThrashThrush:
		{
			give_item(id, "weapon_ak47");
			give_item(id, "weapon_deagle");
			give_item(id, "weapon_m3");
			set_user_rendering(id, kRenderFxGlowShell,255, 255, 255, kRenderTransColor, 255);
			broj_dinamita_igraca[id] = 30;
		}
	}
	if(get_PlayerPoints(id)>0)
		DodelaPoena(id);
	
	if(informacije_predmet_igraca[id][0] == 10 || informacije_predmet_igraca[id][0] == 9)
		give_item(id, "weapon_hegrenade");
	
	if(informacije_predmet_igraca[id][0] == 9)
	{
		new result;
		ExecuteForward(fwForwards[reset_model_fwd],result,id, 0);
	}
	
	if(informacije_predmet_igraca[id][0] == 1)
		set_user_footsteps(id, 1);
	else
		set_user_footsteps(id, 0);
	
	if(informacije_predmet_igraca[id][0] == 13)
		give_item(id, "weapon_awp");
	
	if(informacije_predmet_igraca[id][0] == 31)
		give_item(id, "weapon_mp5navy");	
	
	if(informacije_predmet_igraca[id][0] == 31)
		give_item(id, "weapon_usp");	
	
	if(informacije_predmet_igraca[id][0] == 32)
		give_item(id, "weapon_m4a1");	
	
	if(informacije_predmet_igraca[id][0] == 33)
		give_item(id, "weapon_deagle");	
	
	if(informacije_predmet_igraca[id][0] == 34)
		give_item(id, "weapon_scout");		
	
	if(informacije_predmet_igraca[id][0] == 35)
		give_item(id, "weapon_awp");
	
	if(informacije_predmet_igraca[id][0] == 35)
		give_item(id, "weapon_ak47");	
	
	if(informacije_predmet_igraca[id][0] == 36)
		give_item(id, "weapon_m3");	
	
	if(informacije_predmet_igraca[id][0] == 37)
		give_item(id, "weapon_hegrenade");	
	
	if(informacije_predmet_igraca[id][0] == 38)
		give_item(id, "weapon_galil");	
	
	if(informacije_predmet_igraca[id][0] == 39)
		give_item(id, "weapon_awp");
	
	if(informacije_predmet_igraca[id][0] == 39)
		give_item(id, "weapon_deagle");	
	
	if(informacije_predmet_igraca[id][0] == 42)
		give_item(id, "weapon_m4a1");
	
	if(informacije_predmet_igraca[id][0] == 43)
		give_item(id, "weapon_ak47");
	
	if(informacije_predmet_igraca[id][0] == 40)
		set_user_gravity(id,get_user_gravity(id) - 0.4);
	
	if(informacije_predmet_igraca[id][0] == 16)
		give_item(id, "weapon_deagle");
	
	if(informacije_predmet_igraca[id][0] == 19)
		informacije_predmet_igraca[id][1] = 1;
	
	if(informacije_predmet_igraca[id][0] == 27)
		informacije_predmet_igraca[id][1] = 3;
	
	if(informacije_predmet_igraca[id][0] == 29)
		set_user_gravity(id,get_user_gravity(id) - 0.4);
	
	new weapons[32];
	new weaponsnum;
	get_user_weapons(id, weapons, weaponsnum);
	for(new i=0; i<weaponsnum; i++)
		if(is_user_alive(id))
		if(maxAmmo[weapons[i]] > 0)
		cs_set_user_bpammo(id, weapons[i], maxAmmo[weapons[i]]);
	
	PostaviAtribute(id)
	
	return PLUGIN_CONTINUE;
}
public PostaviAtribute(id)
{
	new armor,energy, speed;
	ExecuteForward(fwForwards[get_class_energy_fwd],energy,klasa_igraca[id]);
	ExecuteForward(fwForwards[get_class_speed_fwd],speed,klasa_igraca[id]);
	ExecuteForward(fwForwards[get_class_armor_fwd],armor,klasa_igraca[id]);
	smanjene_povrede_igraca[id] = (0.7*(1.0-floatpower(1.1, -0.112311341*float(snaga_igraca[id]))));
	maximalna_energija_igraca[id] = energy+energija_igraca[id]*2;
	brzina_igraca[id] = (250.0*(speed+floatround(kondicija_igraca[id]*1.2)));
	
	if(informacije_predmet_igraca[id][0] == 18 && klasa_igraca[id] != Assassin)
	{
		maximalna_energija_igraca[id] += 100;
		brzina_igraca[id] -= 0.4;
	}
	
	if(informacije_predmet_igraca[id][0] == 25 && klasa_igraca[id] != Assassin)
	{
		maximalna_energija_igraca[id] += 50;
		brzina_igraca[id] -= 0.3;
	}
	if(informacije_predmet_igraca[id][0] == 30)
	{
		brzina_igraca[id] += 1.2;
	}
	if(informacije_predmet_igraca[id][0] == 48)
	{
		cs_set_user_money(id, cs_get_user_money(id)+8000);
	}
	if(informacije_predmet_igraca[id][0] == 49)
	{
		Drogiraj(id);
	}
	set_user_armor(id, armor);
	
	if(informacije_predmet_igraca[id][0] == 17)
		set_user_armor(id, 500);
	
	set_user_health(id, maximalna_energija_igraca[id]);
	
}

public Drogiraj(id)
{
	droga[id] = true
	message_begin( MSG_ONE, fovmsg, { 0, 0, 0 }, id )
	write_byte( 180 )
	message_end( )               
}  
public PocetakRunde()	
{
	freezetime = false;
	for(new id=0;id<=32;id++)
	{
		if(!is_user_alive(id))
			continue;
		
		set_task(0.1, "PostaviBrzinu", id+ZADATAK_POSTAVI_BRZINU);
		switch(get_user_team(id))
		{
			case 1: 
			{
				client_cmd(id, "spk QTM_CodMod/start2");
				give_item(id, "weapon_glock18");
			}
			case 2: 
			{
				client_cmd(id, "spk QTM_CodMod/start");
				give_item(id, "weapon_usp");
			}
		}
	}
}
public novaRunda()
{
	freezetime = true;
	new iEnt = find_ent_by_class(-1, "Mine");
	while(iEnt > 0) 
	{
		if (pev_valid(iEnt)){
			remove_entity(iEnt);
		}
		iEnt = find_ent_by_class(iEnt, "Mine");	
	}
}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_alive(this) || !is_user_connected(this) || informacije_predmet_igraca[this][0] == 24 || !is_user_connected(idattacker) || get_user_team(this) == get_user_team(idattacker) || !klasa_igraca[idattacker])
		return HAM_IGNORED;
	
	new health = get_user_health(this);
	new weapon = get_user_weapon(idattacker);
	
	if(health < 2)
		return HAM_IGNORED;
	
	if(informacije_predmet_igraca[this][0] == 27 && informacije_predmet_igraca[this][1]>0)
	{
		informacije_predmet_igraca[this][1]--;
		return HAM_SUPERCEDE;
	}
	
	if(snaga_igraca[this]>0)
		damage -= smanjene_povrede_igraca[this]*damage;
	
	if(informacije_predmet_igraca[this][0] == 2 || informacije_predmet_igraca[this][0] == 3)
		damage-=(float(informacije_predmet_igraca[this][1])<damage)? float(informacije_predmet_igraca[this][1]): damage;
	
	if(informacije_predmet_igraca[idattacker][0] == 5 && !UTIL_In_FOV(this, idattacker) && UTIL_In_FOV(idattacker, this))
		damage*=2.0;
	
	if(informacije_predmet_igraca[idattacker][0] == 10)
		damage+=informacije_predmet_igraca[idattacker][1];
	
	if(informacije_predmet_igraca[this][0] == 12)
		damage-=(5.0<damage)? 5.0: damage;
	
	if(weapon == CSW_AWP && informacije_predmet_igraca[idattacker][0] == 13)
		damage=float(health);
	
	if(weapon == CSW_AWP && informacije_predmet_igraca[idattacker][0] == 35)
		damage=float(health);	
	
	if(informacije_predmet_igraca[idattacker][0] == 21)
		damage+=10;
	
	if(informacije_predmet_igraca[idattacker][0] == 22)
		damage+=20;
	
	if(informacije_predmet_igraca[idattacker][0] == 45)
		damage+=48;
	
	if(idinflictor != idattacker && entity_get_int(idinflictor, EV_INT_movetype) != 5)
	{
		if((informacije_predmet_igraca[idattacker][0] == 9 && random_num(1, informacije_predmet_igraca[idattacker][1]) == 1) || informacije_predmet_igraca[idattacker][0] == 10)
			damage = float(health);	
	}
	if(weapon == CSW_HEGRENADE)
	{
		if(klasa_igraca[idattacker] == Bombarder)
		{
			give_item(idattacker, "weapon_hegrenade")
			cs_set_user_bpammo(idattacker, CSW_HEGRENADE, 5)
		}
	}
	if(weapon == CSW_KNIFE)
	{
		if(klasa_igraca[this] == SWAT || klasa_igraca[this] == ProSWAT)
			return HAM_SUPERCEDE;
		if(informacije_predmet_igraca[idattacker][0] == 4)
			damage=damage*1.4+inteligencija_igraca[idattacker];
		if(informacije_predmet_igraca[idattacker][0] == 8 || (klasa_igraca[idattacker] == Snajperista && random_num(1,2) == 1) || klasa_igraca[idattacker] == Marinac || klasa_igraca[idattacker] == Camper && !(get_user_button(idattacker) & IN_ATTACK) || klasa_igraca[idattacker] == Toker && !(get_user_button(idattacker) & IN_ATTACK) || klasa_igraca[idattacker] == Assassin && !(get_user_button(idattacker) & IN_ATTACK))
			damage = float(health);
	}
	if(informacije_predmet_igraca[idattacker][0] == 31)
	{
		if(weapon == CSW_USP && !random(1))
			damage = float(health);
		
		if(weapon == CSW_MP5NAVY && !random(3))
			damage = float(health);
	}
	if(informacije_predmet_igraca[idattacker][0] == 32)
	{
		if(weapon == CSW_M4A1 && !random(3))
			damage = float(health);
	}
	if(informacije_predmet_igraca[idattacker][0] == 33)
	{
		if(weapon == CSW_DEAGLE && !random(2))
			damage = float(health);
	}
	if(informacije_predmet_igraca[idattacker][0] == 36)
	{
		if(weapon == CSW_M3 && !random(2))
			damage = float(health);
	}
	if(informacije_predmet_igraca[idattacker][0] == 37)
	{
		if(weapon == CSW_HEGRENADE && !random(2))
			damage = float(health);
	}
	if(informacije_predmet_igraca[idattacker][0] == 38)
	{
		if(weapon == CSW_GALIL && !random(3))
			damage = float(health);
	}
	if(informacije_predmet_igraca[idattacker][0] == 35)
	{
		if(weapon == CSW_AWP)
			damage = float(health);
		
		if(weapon == CSW_DEAGLE && !random(1))
			damage = float(health);
	}
	if(informacije_predmet_igraca[idattacker][0] == 34)
	{
		if(weapon == CSW_SCOUT)
			damage = float(health);
	}
	if(klasa_igraca[idattacker] == Zmaj)
	{
		if(weapon == CSW_MP5NAVY && !random(7))
			damage = float(health);
	}
	if(klasa_igraca[idattacker] == ProSWAT)
	{
		if(weapon == CSW_M4A1 && !random(6))
			damage = float(health);
	}
	if(klasa_igraca[idattacker] == Ghost)
	{
		if(weapon == CSW_MAC10 && !random(9))
			damage = float(health);
		if(weapon == CSW_KNIFE)
			damage = float(health);
	}
	if(klasa_igraca[idattacker] == Price)
	{
		if(weapon == CSW_USP && !random(2))
			damage = float(health);
		if(weapon == CSW_KNIFE && !random(1))
			damage = float(health);
	}
	if(klasa_igraca[idattacker] == Ninja)
	{
		if(weapon == CSW_KNIFE){
			new ent=engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
			set_pev(ent,pev_classname,"katana");
			SetHamParamEntity(2, ent);
			damage = float(health);
		}
	}
	if(klasa_igraca[idattacker] == Shredder)
	{
		if(weapon == CSW_KNIFE){
			new ent=engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
			set_pev(ent,pev_classname,"katana");
			SetHamParamEntity(2, ent);
			damage = float(health);
		}
		if(weapon == CSW_AK47&&!random(6))
			damage = float(health);
	}
	if(klasa_igraca[idattacker] == UltraMarinac)
	{
		if(weapon == CSW_KNIFE)
			damage = float(health);
	}
	if(klasa_igraca[idattacker] == Gazija)
	{
		if(weapon == CSW_DEAGLE && !random(2))
			damage = float(health);
	}
	if(klasa_igraca[idattacker] == Camper)
	{
		if(weapon == CSW_DEAGLE && !random(4))
			damage = float(health);
		if(weapon == CSW_AWP)
			damage = float(health);
	}
	if(klasa_igraca[idattacker] == ProAssassin)
	{
		if(weapon == CSW_MP5NAVY && !random(4))
			damage = float(health);
		if(weapon == CSW_KNIFE)
			damage = float(health);
		if(weapon == CSW_DEAGLE && !random(2))
			damage = float(health);
	}
	if(klasa_igraca[idattacker] == Toker)
	{
		if(weapon == CSW_AWP)
			damage = float(health);
		if(weapon == CSW_M4A1 && !random(6))
			damage = float(health);
		if(weapon == CSW_HEGRENADE)
			damage = float(health)
	}
	if(classHasSuperShotgun(klasa_igraca[idattacker]))
	{
		if(weapon == CSW_M3){
		
			new ent=engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
			set_pev(ent,pev_classname,"super shotgun");
			SetHamParamEntity(2, ent);
			damage+=inteligencija_igraca[idattacker]*0.66666;
		
		}
	}
	if(klasa_igraca[idattacker]==ThrashThrush)
	{
		if(weapon == CSW_AK47){
		
			new ent=engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
			set_pev(ent,pev_classname,"thrasher thrusher");
			SetHamParamEntity(2, ent);
			damage+=inteligencija_igraca[idattacker]*0.38;
		
		}
		if(weapon == CSW_DEAGLE){
		
			new ent=engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
			set_pev(ent,pev_classname,"mini thrasher thrusher");
			SetHamParamEntity(2, ent);
			damage+=inteligencija_igraca[idattacker]*0.76;
		
		}
	}
	if(klasa_igraca[idattacker] == Google)
	{
		if(weapon == CSW_ELITE && !random(5))
			damage = float(health);
	}
	if(informacije_predmet_igraca[this][0] == 26 && random_num(1, informacije_predmet_igraca[this][1]) == 1)
	{
		SetHamParamEntity(3, this);
		SetHamParamEntity(1, idattacker);
	}
	SetHamParamFloat(4, damage);
	return HAM_IGNORED;
}
public Damage(id)
{
	new attacker = get_user_attacker(id);
	new damage = read_data(2);
	if(!is_user_alive(attacker) || !is_user_connected(attacker) || id == attacker || !klasa_igraca[attacker])
		return PLUGIN_CONTINUE;
	
	if(informacije_predmet_igraca[attacker][0] == 12 && random_num(1, informacije_predmet_igraca[id][1]) == 1)
		Display_Fade(id,1<<14,1<<14 ,1<<16,255,155,50,230);
	
	if(get_user_team(id) != get_user_team(attacker))
	{
		while(damage>20)
		{
			damage-=20;
			inc_PlayerXp(attacker,1);			
		}
	}
	ProveriNivo(attacker,klasa_igraca[attacker],inteligencija_igraca[attacker],energija_igraca[attacker],snaga_igraca[attacker],kondicija_igraca[attacker]);
	
	return PLUGIN_CONTINUE;
}
public Death()
{
	new id = read_data(2);
	new attacker = read_data(1);
	
	if(!is_user_alive(attacker) || !is_user_connected(attacker))
		return PLUGIN_CONTINUE;
	new kill_gb,result
	ExecuteForward(fwForwards[get_kill_gb_fwd],kill_gb)
	ExecuteForward(fwForwards[add_player_gb_fwd],result,attacker,get_pcvar_num(kill_gb))
	new weapon = get_user_weapon(attacker);
	new energija = get_user_health(attacker);
	if(informacije_predmet_igraca[id][0])
	{
		if(snaga_predmeta[id] > 0) 
			snaga_predmeta[id]-=20;
	}
	if(snaga_predmeta[id] > 0) 
	{
		ColorChat(id, NORMAL, "^3[COD:MW4] ^4 Power Item:^3 %i.", snaga_predmeta[id]);
	}
	else 
	{
		
		new buff[128];
		new result
		PrepareArray(buff,128,1)
		ExecuteForward(fwForwards[get_perk_name_fwd],result,informacije_predmet_igraca[id][0],buff);
		ColorChat(id, RED, "[COD:MW4] ^x01 Item: %s, was completely destroyed.", buff);
		Obrisipredmet(id);
	}
	if(get_user_team(id) != get_user_team(attacker) && klasa_igraca[attacker])
	{
		new iskustvo_za_ubistvo = get_pcvar_num(cvar_xp_za_ubistvo);
		new novo_iskustvo = get_pcvar_num(cvar_xp_za_ubistvo); 
		
		if(klasa_igraca[id] == Rambo && klasa_igraca[attacker] != Rambo)
			novo_iskustvo += iskustvo_za_ubistvo*2;
		
		if(klasa_igraca[attacker] == ProAssassin)
		{
			novo_iskustvo += iskustvo_za_ubistvo;
		}
		if(klasa_igraca[id] == ProAssassin && klasa_igraca[attacker] != ProAssassin)
			novo_iskustvo += iskustvo_za_ubistvo*2;
		
		if(informacije_predmet_igraca[attacker][0] == 46)
		{
			novo_iskustvo += iskustvo_za_ubistvo;
		}
		if(informacije_predmet_igraca[id][0] == 46 && informacije_predmet_igraca[attacker][0] != 46)
			novo_iskustvo += iskustvo_za_ubistvo*2;
		
		if(get_PlayerLvl(id) > get_PlayerLvl(attacker))
			novo_iskustvo += (get_PlayerLvl(id)-get_PlayerLvl(attacker))*(iskustvo_za_ubistvo/10);
		
		if(klasa_igraca[attacker] == Rambo || informacije_predmet_igraca[attacker][0] == 15 && maxClip[weapon] != -1)
		{
			
			new nova_energija = (energija+20<maximalna_energija_igraca[attacker])? energija+20: maximalna_energija_igraca[attacker];
			set_user_clip(attacker, maxClip[weapon]);
			set_user_health(attacker, nova_energija);
		}  
		#if defined BOTY
		if(is_user_bot(attacker) && random(9) == 0)
			IzbaciPredmet(id);
		#endif
		if(!informacije_predmet_igraca[attacker][0]){
			new result
			ExecuteForward(fwForwards[get_num_perks_fwd],result);
			DajPredmet(attacker, random_num(1, result-1));
		}
		
		if(informacije_predmet_igraca[attacker][0] == 14)
		{
			new nova_energija = (energija+50<maximalna_energija_igraca[attacker])? energija+50: maximalna_energija_igraca[attacker];
			set_user_health(attacker, nova_energija);
		}
		set_hudmessage(255, 212, 0, 0.50, 0.33, 1, 6.0, 4.0);
		ShowSyncHudMsg(attacker, SyncHudObj2, "+%i", novo_iskustvo);
		
		inc_PlayerXp(attacker,novo_iskustvo);
	}
	
	ProveriNivo(attacker,klasa_igraca[attacker],inteligencija_igraca[attacker],energija_igraca[attacker],snaga_igraca[attacker],kondicija_igraca[attacker]);
	

	if(informacije_predmet_igraca[id][0] == 7 && random_num(1, informacije_predmet_igraca[id][1]) == 1)
		set_task(0.1, "Provera", id+ZADATAK_PROVERA);
	
	return PLUGIN_CONTINUE;
}
public client_putinserver(id)
{
	DeleteSkills(id);
	ObrisiZadatke(id);
	Obrisipredmet(id);
	
	set_task(3.0, "PokaziInformacije", id+ZADATAK_POKAZI_INFORMACIJE);
	set_task(10.0, "PokaziReklame", id+ZADATAK_POKAZI_REKLAME);
}
public client_disconnected(id)
{
	SacuvajPodatke(id,klasa_igraca[id],inteligencija_igraca[id],energija_igraca[id],snaga_igraca[id],kondicija_igraca[id]);
	DeleteSkills(id);
	ObrisiZadatke(id);	
	Obrisipredmet(id);
	
	remove_task(id+ZADATAK_POSTAVI_BRZINU);	
	
}
public DeleteSkills(id)
{
	if(!is_user_connected(id)){
		
		return;
	
	}
	klasa_igraca[id] = 0;
	set_PlayerLvl(id,0);
	set_PlayerXp(id,0);
	set_PlayerPoints(id,0);
	energija_igraca[id] = 0;
	inteligencija_igraca[id] = 0;
	snaga_igraca[id] = 0;
	kondicija_igraca[id] = 0;
	maximalna_energija_igraca[id] = 0;
	brzina_igraca[id] = 0.00;
	get_user_name(id, naziv_igraca[id], 63);
	
	remove_task(id+ZADATAK_POSTAVI_BRZINU);
}
public ObrisiZadatke(id)
{
	remove_task(id+ZADATAK_POKAZI_INFORMACIJE);
	remove_task(id+ZADATAK_POKAZI_REKLAME);	
	remove_task(id+ZADATAK_POSTAVI_BRZINU);
	remove_task(id+ZADATAK_PROVERA); 
}
public OpisKlase(id)
{
	if (!is_user_connected(id)) 
		return
	
	
	new menu = menu_create("Select Class:", "OpisKlase_Handle");
	new class_num;
	ExecuteForward(fwForwards[get_num_classes_fwd],class_num);
	for(new i=1; i <class_num; i++){
		new name[128];
		new result
		PrepareArray(name,128,1)
		ExecuteForward(fwForwards[get_class_name_fwd],result,i,name);
		menu_additem(menu,name);
	}
	menu_setprop(menu, MPROP_EXITNAME, "Exit");
	menu_setprop(menu, MPROP_BACKNAME, "Previous Page");
	menu_setprop(menu, MPROP_NEXTNAME, "Next page");
	menu_display(id, menu);
	
	client_cmd(id, "spk QTM_CodMod/select");
}
public OpisKlase_Handle(id, menu, item)
{
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item++ == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	new opis[1024];
	new subopis[512];
	new result
	PrepareArray(subopis,512,1)
	ExecuteForward(fwForwards[get_class_desc_fwd],result,item,subopis);
	new name[128];
	PrepareArray(name,128,1)
	ExecuteForward(fwForwards[get_class_name_fwd],result,item,name);
	format(opis, charsmax(opis), "\rClass:\d%s^n%s", name, subopis);
	show_menu(id, 1023, opis);
	
	return PLUGIN_CONTINUE;
}
public IzaberiKlasu(id)
{
	new menu = menu_create("\ySelect Menu:", "IzaberiFrakciju_Handle");
	for(new i = 1;i<sizeof(frakcje);i++)
	{
		menu_additem(menu, frakcje[i]);
	}
	menu_display(id, menu);
	menu_setprop(menu, MPROP_EXITNAME, "\rExit");
}
public IzaberiFrakciju_Handle(id, menu2, item)
{       
	if(item == MENU_EXIT)
	{
		menu_destroy(menu2);
		return PLUGIN_CONTINUE;
	}
	item++;
	frakcija_igraca[id] = item;
	new menu = menu_create("\ySelect Class:", "IzaberiKlasu_Handle");
	new klasa[260];
	new class_num;
	ExecuteForward(fwForwards[get_num_classes_fwd],class_num);
	console_print(id,"Num classes: %i",class_num);
	for(new i=1; i <class_num; i++){
		new result
		ExecuteForward(fwForwards[get_class_acess_fwd],result,i);
		//result=3;
		if(result == item)
		{
			UcitajPodatke(id, i);
			new buff[128],buff2[128];
			new result
			PrepareArray(buff,128,1)
			ExecuteForward(fwForwards[get_class_suffix_fwd],result,i,buff);
			PrepareArray(buff2,128,1)
			ExecuteForward(fwForwards[get_class_name_fwd],result,i,buff2);
			format(klasa, 259, "\r%s %s \rLevel:\y %i", buff2, buff, get_PlayerLvl(id));
			menu_additem(menu, klasa);
		}
	}
	UcitajPodatke(id, klasa_igraca[id]);
	
	menu_setprop(menu, MPROP_EXITNAME, "\rExit");
	menu_setprop(menu, MPROP_BACKNAME, "\yPrevious Page");
	menu_setprop(menu, MPROP_NEXTNAME, "\yNext Page");
	menu_display(id, menu);
	
	client_cmd(id, "spk mw/select");
	
	return PLUGIN_CONTINUE;
}
public IzaberiKlasu_Handle(id, menu, item)
{
	
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	
	client_cmd(id, "spk mw/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}       
	
	item++;
	
	new ile = 0;
	new class_num;
	ExecuteForward(fwForwards[get_num_classes_fwd],class_num);
	for(new i=1; i <class_num; i++){
		new acclevel
		ExecuteForward(fwForwards[get_class_acess_fwd],acclevel,i);
		if(acclevel== frakcija_igraca[id])
		{
			ile++;
		}
		if(ile == item)
		{
			item = i;
			break;
		}
	}
	if(item == klasa_igraca[id])
	{
		ColorChat(id, NORMAL, "^3[COD:MW4]^4 Already using this class.");
		return PLUGIN_CONTINUE;
	}
	new Timee[10];
	
	get_time("%H", Timee, charsmax(Timee));
	
	new DnevnoVreme = (equal(Timee, "09") || equal(Timee, "10") || equal(Timee, "11") || equal(Timee, "12") 
	|| equal(Timee, "13") || equal(Timee, "14") || equal(Timee, "15") || equal(Timee, "16") 
	|| equal(Timee, "17") || equal(Timee, "18") || equal(Timee, "19") || equal(Timee, "20")
	|| equal(Timee, "21"));  
	
	
	if(item == RatkoMladic && !(get_user_flags(id) & ADMIN_LEVEL_A) && DnevnoVreme)  
	{
		ColorChat(id, GREY, "[Cod:Mw4]^3 Need access ^4 Premium Class.");
		IzaberiKlasu(id);
		return PLUGIN_CONTINUE;
	}
	if(item == Assassin && !(get_user_flags(id) & ADMIN_LEVEL_A) && DnevnoVreme)
	{
		ColorChat(id, GREY, "[Cod:Mw4]^3 You do not have access to ^4 Premium Class.");
		IzaberiKlasu(id);
		return PLUGIN_CONTINUE;
	}
	if(item == Major && !(get_user_flags(id) & ADMIN_LEVEL_A) && DnevnoVreme)
	{
		ColorChat(id, GREY, "[Cod:Mw4]^3 You do not have access to ^4 Premium Class.");
		IzaberiKlasu(id);
		return PLUGIN_CONTINUE;
	}
	if(item == Armageddon && !(get_user_flags(id) & ADMIN_LEVEL_A) && DnevnoVreme)
	{
		ColorChat(id, GREY, "[Cod:Mw4]^3 You do not have access to ^4 Premium Class.");
		IzaberiKlasu(id);
		return PLUGIN_CONTINUE;
	}
	if(item == Komandos && !(get_user_flags(id) & ADMIN_LEVEL_B) && DnevnoVreme)
	{
		ColorChat(id, GREY, "[Cod:Mw4]^3 You do not have access to ^4 Super Class.");
		IzaberiKlasu(id);
		return PLUGIN_CONTINUE;
	}
	
	if(item == Price && !(get_user_flags(id) & ADMIN_LEVEL_B) && DnevnoVreme)
	{
		ColorChat(id, GREY, "[Cod:Mw4]^3 You do not have access to ^4 Super Class.");
		IzaberiKlasu(id);
		return PLUGIN_CONTINUE;
	}
	if(item == Camper && !(get_user_flags(id) & ADMIN_LEVEL_B) && DnevnoVreme)
	{
		ColorChat(id, GREY, "[Cod:Mw4]^3 You do not have access to ^4 Super Class.");
		IzaberiKlasu(id);
		return PLUGIN_CONTINUE;
	}
	if(item == Toker && !(get_user_flags(id) & ADMIN_LEVEL_B) && DnevnoVreme)
	{
		ColorChat(id, GREY, "[Cod:Mw4]^3 You do not have access to ^4 Super Class.");
		IzaberiKlasu(id);
		return PLUGIN_CONTINUE;
	}
	if(item == Zmaj && !(get_user_flags(id) & ADMIN_LEVEL_B) && DnevnoVreme)
	{
		ColorChat(id, GREY, "[Cod:Mw4]^3 You do not have access to ^4 Super CLass.");
		IzaberiKlasu(id);
		return PLUGIN_CONTINUE;
	}
	if(item == ProAssassin && !(get_user_flags(id) & ADMIN_LEVEL_C) && DnevnoVreme)
	{
		ColorChat(id, GREY, "[Cod:Mw4]^3 You do not have access to ^4 Pro Class.");
		IzaberiKlasu(id);
		return PLUGIN_CONTINUE;
	}
	if(item == Soap && !(get_user_flags(id) & ADMIN_LEVEL_C) && DnevnoVreme)
	{
		ColorChat(id, GREY, "[Cod:Mw4]^3 You do not have access to ^4 Pro Class.");
		IzaberiKlasu(id);
		return PLUGIN_CONTINUE;
	}
	if(item == Google && !(get_user_flags(id) & ADMIN_LEVEL_D) && DnevnoVreme)
	{
		ColorChat(id, GREY, "[Cod:Mw4]^3 You do not have access to ^4 Skill Class.");
		IzaberiKlasu(id);
		return PLUGIN_CONTINUE;
	}
	if(item == Hulk && !(get_user_flags(id) & ADMIN_LEVEL_D) && DnevnoVreme)
	{
		ColorChat(id, GREY, "[Cod:Mw4]^3 You do not have access to ^4 Skill Class.");
		IzaberiKlasu(id);
		return PLUGIN_CONTINUE;
	}
	
	if(klasa_igraca[id])
	{
		nova_klasa_igraca[id] = item;
		ColorChat(id, GREY, "[Cod:Mw4]^4 Class will be changed out in the following rounds.");
	}
	else
	{
		klasa_igraca[id] = item;
		UcitajPodatke(id, klasa_igraca[id]);
		
		if(is_user_alive(id) && is_user_connected(id))
		{
			Pocetak(id)
		}
	}
	return PLUGIN_CONTINUE;
}
public KreirajMedKit(id)
{
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	if(!broj_medkit_igraca[id])
	{
		set_hudmessage(255, 0, 0, 0.23, 0.10, 0, 6.0, 6.0);
		show_hudmessage(id, "Need more packs for first aid");
		return PLUGIN_CONTINUE;
	}
	
	if(prethodna_raketa_igraca[id] + 5.0 > get_gametime())
	{
		set_hudmessage(255, 0, 0, 0.23, 0.10, 0, 6.0, 6.0);
		show_hudmessage(id, "Mozate da lecite za 5s!");
		return PLUGIN_CONTINUE;
	}
	
	prethodna_raketa_igraca[id] = get_gametime();
	broj_medkit_igraca[id]--;
	
	new Float:origin[3];
	entity_get_vector(id, EV_VEC_origin, origin);
	
	new ent = create_entity("info_target");
	if(!pev_valid(ent)){
				
			return PLUGIN_CONTINUE
	}
	entity_set_string(ent, EV_SZ_classname, "MedKit");
	entity_set_edict(ent, EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_solid, SOLID_NOT);
	entity_set_vector(ent, EV_VEC_origin, origin);
	entity_set_float(ent, EV_FL_ltime, halflife_time() + 7 + 0.1);
	
	
	entity_set_model(ent, "models/w_medkit.mdl");
	set_rendering ( ent, kRenderFxGlowShell, 255,0,0, kRenderFxNone, 255 ) 	;
	drop_to_floor(ent);
	
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1);
	
	return PLUGIN_CONTINUE;
}
public MedKitThink(ent)
{
	new id = entity_get_edict(ent, EV_ENT_owner);
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	new totem_dist = 300;
	new totem_heal = 5+floatround(inteligencija_igraca[id]*0.5);
	if (entity_get_edict(ent, EV_ENT_euser2) == 1)
	{		
		new Float:forigin[3], origin[3];
		entity_get_vector(ent, EV_VEC_origin, forigin);
		FVecIVec(forigin,origin);
		
		new entlist[33];
		new numfound = find_sphere_class(0,"player",totem_dist+0.0,entlist, 32,forigin);
		
		for (new i=0; i < numfound; i++)
		{		
			new pid = entlist[i];
			
			if (get_user_team(pid) != get_user_team(id))
				continue;
			
			new energija = get_user_health(pid);
			new nova_energija = (energija+totem_heal<maximalna_energija_igraca[pid])?energija+totem_heal:maximalna_energija_igraca[pid];
			if (is_user_alive(pid)) set_user_health(pid, nova_energija);		
		}
		entity_set_edict(ent, EV_ENT_euser2, 0);
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 1.5);
		
		return PLUGIN_CONTINUE;
	}
	if (entity_get_float(ent, EV_FL_ltime) < halflife_time() || !is_user_alive(id))
	{
		remove_entity(ent);
		return PLUGIN_CONTINUE;
	}
	if (entity_get_float(ent, EV_FL_ltime)-2.0 < halflife_time())
		set_rendering ( ent, kRenderFxNone, 255,255,255, kRenderTransAlpha, 100 ) ;
	
	new Float:forigin[3], origin[3];
	entity_get_vector(ent, EV_VEC_origin, forigin);
	FVecIVec(forigin,origin);
	
	//Find people near and give them health
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, origin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( origin[0] );
	write_coord( origin[1] );
	write_coord( origin[2] );
	write_coord( origin[0] );
	write_coord( origin[1] + totem_dist );
	write_coord( origin[2] + totem_dist );
	write_short( sprite_white );
	write_byte( 0 ); // startframe
	write_byte( 0 ); // framerate
	write_byte( 10 ); // life
	write_byte( 10 ); // width
	write_byte( 255 ); // noise
	write_byte( 255 ); // r, g, b
	write_byte( 100 );// r, g, b
	write_byte( 100 ); // r, g, b
	write_byte( 128 ); // brightness
	write_byte( 5 ); // speed
	message_end();
	
	entity_set_edict(ent, EV_ENT_euser2 ,1);
	entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.5);
	
	return PLUGIN_CONTINUE;
}
public KreirajRakete(id)
{
	if(!broj_raketa_igraca[id])
	{
		set_hudmessage(255, 0, 0, 0.23, 0.10, 0, 6.0, 6.0);
		show_hudmessage(id, "Iskoristili ste sve rakete");
		return PLUGIN_CONTINUE;
	}
	
	if(prethodna_raketa_igraca[id] + 2.0 > get_gametime())
	{
		set_hudmessage(255, 0, 0, 0.23, 0.10, 0, 6.0, 6.0);
		show_hudmessage(id, "Mozate da koristite raketu za 2 sekunde!");
		return PLUGIN_CONTINUE;
	}
	
	if(is_user_alive(id))
	{	
		
		prethodna_raketa_igraca[id] = get_gametime();
		broj_raketa_igraca[id]--;
		new Float: Origin[3], Float: vAngle[3], Float: Velocity[3];
		
		entity_get_vector(id, EV_VEC_v_angle, vAngle);
		entity_get_vector(id, EV_VEC_origin , Origin);
		
		new Ent = create_entity("info_target");
		if(!pev_valid(Ent)){
				
				return PLUGIN_CONTINUE
		}
		entity_set_string(Ent, EV_SZ_classname, "Rocket");
		entity_set_model(Ent, "models/rpgrocket.mdl");
		
		vAngle[0] *= -1.0;
		
		entity_set_origin(Ent, Origin);
		entity_set_vector(Ent, EV_VEC_angles, vAngle);
		
		entity_set_int(Ent, EV_INT_effects, 2);
		entity_set_int(Ent, EV_INT_solid, SOLID_BBOX);
		entity_set_int(Ent, EV_INT_movetype, MOVETYPE_FLY);
		entity_set_edict(Ent, EV_ENT_owner, id);
		
		VelocityByAim(id, 1000 , Velocity);
		entity_set_vector(Ent, EV_VEC_velocity ,Velocity);
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
		write_byte(22) 
		write_short(Ent) 
		write_short(sprite_beam) 
		write_byte(45) 
		write_byte(4) 
		write_byte(255) 
		write_byte(105) 
		write_byte(180) 
		write_byte(25)
		message_end() 
	}	
	return PLUGIN_CONTINUE;
}
public KreirajDinamit(id)
{
	if(!broj_dinamita_igraca[id])
	{
		set_hudmessage(255, 0, 0, 0.23, 0.10, 0, 6.0, 6.0);
		show_hudmessage(id, "Iskoristili ste sav dinamit");
		return PLUGIN_CONTINUE;
	}
	broj_dinamita_igraca[id]--;
	
	new Float:fOrigin[3];
	entity_get_vector(id, EV_VEC_origin, fOrigin);	
	
	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(fOrigin[i]);
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(TE_EXPLOSION);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(sprite_blast);
	write_byte(32);
	write_byte(20);
	write_byte(0);
	message_end();
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] );
	write_coord( iOrigin[2] );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] + 300 );
	write_coord( iOrigin[2] + 300 );
	write_short( sprite_white );
	write_byte( 0 ); // startframe
	write_byte( 0 ); // framerate
	write_byte( 10 ); // life
	write_byte( 10 ); // width
	write_byte( 255 ); // noise
	write_byte( 255 ); // r, g, b
	write_byte( 100 );// r, g, b
	write_byte( 100 ); // r, g, b
	write_byte( 128 ); // brightness
	write_byte( 8 ); // speed
	message_end();
	
	new entlist[33];
	new numfound = find_sphere_class(id, "player", 300.0 , entlist, 32);
	
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		
		if (!is_user_alive(pid) || get_user_team(id) == get_user_team(pid) || informacije_predmet_igraca[pid][0] == 24)
			continue;
		if(classHasSuperDynamite(klasa_igraca[id])){
			if(klasa_igraca[id]==Graciete){
				ExecuteHam(Ham_TakeDamage, pid, 0, id, 90.0+2*float(inteligencija_igraca[id]) , 1);
			}
			if(klasa_igraca[id]==ThrashThrush){
				ExecuteHam(Ham_TakeDamage, pid, 0, id, 90.0+5*float(inteligencija_igraca[id]) , 1);
			}
		}
		else{
			ExecuteHam(Ham_TakeDamage, pid, 0, id, 90.0+float(inteligencija_igraca[id]) , 1);
		}
	}
	return PLUGIN_CONTINUE;
}
public PostaviMine(id)
{
	if(!broj_min_igraca[id])
	{
		set_hudmessage(255, 0, 0, 0.23, 0.10, 0, 6.0, 6.0);
		show_hudmessage(id, "Iskoristili ste sve mine");
		return PLUGIN_CONTINUE;
	}
	
	new entlist[2];
	if(find_sphere_class(id, "func_buyzone", 750.0, entlist, 1))
	{
		set_hudmessage(255, 0, 0, 0.23, 0.10, 0, 6.0, 6.0);
		show_hudmessage(id, "You can not lay mines near base !");
		return PLUGIN_CONTINUE;
	}
	broj_min_igraca[id]--;
	
	new Float:origin[3];
	entity_get_vector(id, EV_VEC_origin, origin);
	
	new ent = create_entity("info_target");
	if(!pev_valid(ent)){
		
		return PLUGIN_CONTINUE
	}
	entity_set_string(ent ,EV_SZ_classname, "Mine");
	entity_set_edict(ent ,EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
	entity_set_origin(ent, origin);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	
	entity_set_model(ent, "models/mine.mdl");
	entity_set_size(ent,Float:{-16.0,-16.0,0.0},Float:{16.0,16.0,2.0});
	
	drop_to_floor(ent);
	
	entity_set_float(ent,EV_FL_nextthink,halflife_time() + 0.01) ;
	
	
	return PLUGIN_CONTINUE;
}
public DodirMine(ent, id)
{
	if ( !is_valid_ent(ent))
		return;
	
	new attacker = entity_get_edict(ent, EV_ENT_owner);
	if (get_user_team(attacker) != get_user_team(id))
	{
		new Float:fOrigin[3];
		entity_get_vector( ent, EV_VEC_origin, fOrigin);
		
		new iOrigin[3];
		for(new i=0;i<3;i++)
			iOrigin[i] = floatround(fOrigin[i]);
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
		write_byte(TE_EXPLOSION);
		write_coord(iOrigin[0]);
		write_coord(iOrigin[1]);
		write_coord(iOrigin[2]);
		write_short(sprite_blast);
		write_byte(32); // scale
		write_byte(20); // framerate
		write_byte(0);// flags
		message_end();
		new entlist[33];
		new numfound = find_sphere_class(ent,"player", 90.0 ,entlist, 32);
		
		for (new i=0; i < numfound; i++)
		{		
			new pid = entlist[i];
			
			if (!is_user_alive(pid) || get_user_team(attacker) == get_user_team(pid) || informacije_predmet_igraca[pid][0] == 24 || klasa_igraca[id] == Mitraljezac)
				continue;
			
			ExecuteHam(Ham_TakeDamage, pid, ent, attacker, 90.0+float(inteligencija_igraca[attacker]) , 1);
		}
		remove_entity(ent);
	}
}

public DodirRakete(ent)
{
	if ( !is_valid_ent(ent))
		return;
	
	new attacker = entity_get_edict(ent, EV_ENT_owner);
	
	new Float:fOrigin[3];
	entity_get_vector(ent, EV_VEC_origin, fOrigin);	
	
	new iOrigin[3];
	for(new i=0;i<3;i++)
		iOrigin[i] = floatround(fOrigin[i]);
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
	write_byte(TE_EXPLOSION);
	write_coord(iOrigin[0]);
	write_coord(iOrigin[1]);
	write_coord(iOrigin[2]);
	write_short(sprite_blast);
	write_byte(32); // scale
	write_byte(20); // framerate
	write_byte(0);// flags
	message_end();
	
	new entlist[33];
	new numfound = find_sphere_class(ent, "player", 230.0, entlist, 32);
	
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		
		if (!is_user_alive(pid) || get_user_team(attacker) == get_user_team(pid) || informacije_predmet_igraca[pid][0] == 24)
			continue;
		ExecuteHam(Ham_TakeDamage, pid, ent, attacker, 55.0+float(inteligencija_igraca[attacker]) , 1);
	}
	remove_entity(ent);
}
public fw_Touch(ent, id)
{
	
	if (!is_user_connected(id)) 
		return FMRES_IGNORED;
	
	if (!pev_valid(ent)) 
		return FMRES_IGNORED
	
	new ClassName[32]
	pev(ent, pev_classname, ClassName, charsmax(ClassName))
	if(equal(ClassName, "rocket"))
	{
		
		new attacker = pev(ent, pev_owner);
		new Float:entOrigin[3], Float:fDamage, Float:Origin[3];
		pev(ent, pev_origin, entOrigin);
		entOrigin[2] += 1.0;
		
		new Float:g_damage = 90.0+(inteligencija_igraca[attacker]/4);
		new Float:g_radius = 250.0+(inteligencija_igraca[attacker]/4);
		
		new victim = -1
		while((victim = engfunc(EngFunc_FindEntityInSphere, victim, entOrigin, g_radius)) != 0)
		{		
			if(!is_user_alive(victim) || get_user_team(attacker) == get_user_team(victim))
				continue;
			
			pev(victim, pev_origin, Origin);
			fDamage = g_damage - floatmul(g_damage, floatdiv(get_distance_f(Origin, entOrigin), g_radius));
			fDamage *= estimate_take_hurt(entOrigin, victim, 0)
			if(fDamage>0.0)
			{
				UTIL_Kill(attacker, victim, fDamage);
				
				if(get_user_team(attacker)!=get_user_team(victim)) 
					if(pev(victim, pev_health))
					ExecuteHam(Ham_TakeDamage, victim, ent, attacker, fDamage, DMG_BULLET)
				
			}
		} 	
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
		write_byte(TE_EXPLOSION); 
		write_coord(floatround(entOrigin[0])); 
		write_coord(floatround(entOrigin[1])); 
		write_coord(floatround(entOrigin[2])); 
		write_short(sprite_blast); 
		write_byte(40);
		write_byte(30);
		write_byte(TE_EXPLFLAG_NONE); 
		message_end();
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(5)
		write_coord(floatround(entOrigin[0])); 
		write_coord(floatround(entOrigin[1])); 
		write_coord(floatround(entOrigin[2]));
		write_short(sprite_smoke);
		write_byte(35);
		write_byte(5);
		message_end();
		remove_entity(ent);
		return FMRES_IGNORED
		
	}
	
	if(!is_user_alive(ent) || !classHasClimbing(klasa_igraca[ ent ]) || !pev_valid(ent)||!is_valid_ent( ent ) )
		return FMRES_IGNORED
	
	
	entity_get_vector( ent, EV_VEC_origin, g_wallorigin[ ent ] );
	
	return FMRES_IGNORED
}

public setInvis(id){

	new weapon = get_user_weapon(id);
	if(klasa_igraca[id] == Ghost)
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 0);
	if(klasa_igraca[id] == Shredder)
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 20);
	
	if(klasa_igraca[id] == UltraMarinac)
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 55);
		
	if(klasa_igraca[id] == Assassin && weapon == CSW_KNIFE) 
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 1); 
	else if(klasa_igraca[id] == Assassin && weapon != CSW_KNIFE) 
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 255);
	
	if(klasa_igraca[id] == ProAssassin && weapon == CSW_KNIFE) 
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 1); 
	else if(klasa_igraca[id] == ProAssassin && weapon != CSW_KNIFE) 
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 255);
	
	if(klasa_igraca[id] == Ninja && weapon == CSW_KNIFE) 
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 1); 
	else if(klasa_igraca[id] == Ninja && weapon != CSW_KNIFE) 
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 255);
	
	if(klasa_igraca[id] == Gazija && weapon == CSW_DEAGLE) 
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 1); 
	else if(klasa_igraca[id] == Gazija && weapon != CSW_DEAGLE) 
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 255);
	
	if(informacije_predmet_igraca[id][0] == 40 && weapon == CSW_KNIFE) 
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 1); 
	else if(informacije_predmet_igraca[id][0] == 40 && weapon != CSW_KNIFE) 
		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransColor, 255);
		
		
	if(klasa_igraca[id] == Graciete){
		set_user_rendering(id, kRenderFxGlowShell,255, 0, 0, kRenderTransColor, 255);
	
	}	
	if(klasa_igraca[id] == ThrashThrush){
		set_user_rendering(id, kRenderFxGlowShell,255, 255,255, kRenderTransColor, 255);
	
	}


}

public CurWeapon(id)
{
	if(freezetime||!klasa_igraca[id])
		return PLUGIN_CONTINUE;
	
	new weapon = get_user_weapon(id);
	
	if(informacije_predmet_igraca[id][0] == 44 && maxClip[weapon] != -1)
		set_user_clip(id, maxClip[weapon]);
	PostaviBrzinu(id);
	setInvis(id)
	set_task(0.1, "PostaviBrzinu", id+ZADATAK_POSTAVI_BRZINU);
	set_task(0.1, "setInvis", id);
	new weapons[32];
	new weaponsnum;
	get_user_weapons(id, weapons, weaponsnum);
	for(new i=0; i<weaponsnum; i++)
		if(is_user_alive(id))
		if(maxAmmo[weapons[i]] > 0)
		cs_set_user_bpammo(id, weapons[i], maxAmmo[weapons[i]]);
	
	return PLUGIN_CONTINUE;
}
/*public changeWeaponData(id){

	if(!klasa_igraca[id])
		return PLUGIN_CONTINUE;
	
	new weapon,clip,ammo = get_user_weapon(id,clip,ammo);
	
	return PLUGIN_CONTINUE
}*/
public EmitSound(id, iChannel, szSound[], Float:fVol, Float:fAttn, iFlags, iPitch ) 
{
	if(!is_user_alive(id))
		return FMRES_IGNORED;
	
	if(equal(szSound, "common/wpn_denyselect.wav"))
	{
		KoristiPredmet(id);
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}
public KoristiPredmet(id)
{
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	if(informacije_predmet_igraca[id][0] == 19 && informacije_predmet_igraca[id][1]>0) 
	{
		set_user_health(id, maximalna_energija_igraca[id]);
		informacije_predmet_igraca[id][1]--;
	}
	if(broj_medkit_igraca[id]>0)
		KreirajMedKit(id);
	if(broj_raketa_igraca[id]>0)
		KreirajRakete(id);
	if(broj_min_igraca[id]>0)
		PostaviMine(id);
	if(broj_dinamita_igraca[id]>0)
		KreirajDinamit(id);
	
	return PLUGIN_HANDLED;
}

public OpisPredmeta(id, menu, item)
{
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	new slucajne_vrednosti[3];
	
	new buffperk[512];
	new result
	PrepareArray(buffperk,512,1)
	ExecuteForward(fwForwards[get_perk_desc_fwd],result,informacije_predmet_igraca[id][0],buffperk);
	num_to_str(informacije_predmet_igraca[id][1], slucajne_vrednosti, 2);
	format(buffperk, 511, buffperk);
	replace_all(buffperk, 511, "LW", slucajne_vrednosti);
	if(item++ == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	new finalbuff[1024];
	new buffperk2[128];
	PrepareArray(buffperk2,128,1)
	ExecuteForward(fwForwards[get_perk_name_fwd],result,informacije_predmet_igraca[id][0],buffperk2);
	new buffperk3[512];
	PrepareArray(buffperk3,512,1)
	ExecuteForward(fwForwards[get_perk_desc_fwd],result,informacije_predmet_igraca[id][0],buffperk3);
	format(finalbuff, charsmax(finalbuff), "\rPredmet: \y%s^n\rOpis: \d%s", buffperk2, buffperk3);
	show_menu(id, 1023, finalbuff)
	return PLUGIN_CONTINUE;
}   
public Provera(id)
{
	id-=ZADATAK_PROVERA;
	ExecuteHamB(Ham_CS_RoundRespawn, id);
}  
public PokaziInformacije(id) 
{   
	id -= ZADATAK_POKAZI_INFORMACIJE;
	
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	set_task(0.1, "PokaziInformacije", id+ZADATAK_POKAZI_INFORMACIJE);
	new result
	if(is_user_connected(id) && !is_user_alive(id))
	{
		new target = entity_get_int(id, EV_INT_iuser2);
		
		if(!target)
			return PLUGIN_CONTINUE;
		
		set_hudmessage(-122, 255, 0, 0.6, -1.0, 0, 0.0, 0.3, 0.0, 0.0, 2);
		new buff[128];
		PrepareArray(buff,128,1)
		ExecuteForward(fwForwards[get_class_name_fwd],result,klasa_igraca[target],buff);
		new buffperk[128];
		PrepareArray(buffperk,128,1)
		ExecuteForward(fwForwards[get_perk_name_fwd],result,informacije_predmet_igraca[target][0],buffperk);
		
		new player_gb,player_xp_to_next_level,max_level
		ExecuteForward(fwForwards[get_max_lvl_fwd],max_level)
		ExecuteForward(fwForwards[get_lvl_xp_fwd],player_xp_to_next_level,get_PlayerLvl(target)+((get_PlayerLvl(target)>=max_level-1)?0:1));
		ExecuteForward(fwForwards[get_player_gb_fwd],player_gb,target);
		ShowSyncHudMsg(id, SyncHudObj, "Class: %s^nExperience: %i/%i^nLevel: %i^nHP: %d^nItem: %s^nGB : %i^nMod by Me", buff, get_PlayerXp(target),player_xp_to_next_level,get_PlayerLvl(target), get_user_health(target), buffperk,player_gb);
		
		return PLUGIN_CONTINUE;
	}
	set_hudmessage(0, 250, 0, 0.02, 0.17, 0, 0.0, 0.3, 0.0, 0.0);
	
	new buff[128];
	PrepareArray(buff,128,1)
	ExecuteForward(fwForwards[get_class_name_fwd],result,klasa_igraca[id],buff);
	
	new buffperk[128];
	
	PrepareArray(buffperk,128,1)
	ExecuteForward(fwForwards[get_perk_name_fwd],result,informacije_predmet_igraca[id][0],buffperk);
	new player_gb,player_xp_to_next_level,max_level
	ExecuteForward(fwForwards[get_max_lvl_fwd],max_level)
	ExecuteForward(fwForwards[get_lvl_xp_fwd],player_xp_to_next_level,get_PlayerLvl(id)+((get_PlayerLvl(id)>=max_level-1)?0:1));
	ExecuteForward(fwForwards[get_player_gb_fwd],player_gb,id);
	ShowSyncHudMsg(id, SyncHudObj, "[Class: %s]^n[Experience: %i/%i]^n[Level: %i]^n[HP: %d]^n[Item: %s]^n[GB: %i]^n[Mod by Romanov]", buff, get_PlayerXp(id),player_xp_to_next_level,get_PlayerLvl(id), get_user_health(id), buffperk, player_gb);
	if(broj_medkit_igraca[id] != 0)
	{
		set_hudmessage(240, 220, 200, 0.6, -1.0, 0, 0.0, 0.3, 0.0, 0.0, 2);
		ShowSyncHudMsg(id, SyncHudObj2, "[Medkit: %i]", broj_medkit_igraca[id])
	}
	if(broj_raketa_igraca[id] != 0)
	{
		set_hudmessage(240, 220, 200, 0.6, -1.0, 0, 0.0, 0.3, 0.0, 0.0, 2);
		ShowSyncHudMsg(id, SyncHudObj2, "[Rakete: %i]", broj_raketa_igraca[id])
	}
	if(broj_min_igraca[id] != 0)
	{
		set_hudmessage(240, 220, 200, 0.6, -1.0, 0, 0.0, 0.3, 0.0, 0.0, 2);
		ShowSyncHudMsg(id, SyncHudObj2, "[Mine: %i]", broj_min_igraca[id])
	}
	if(broj_dinamita_igraca[id] != 0)
	{
		set_hudmessage(240, 220, 200, 0.6, -1.0, 0, 0.0, 0.3, 0.0, 0.0, 2);
		ShowSyncHudMsg(id, SyncHudObj2, "[Dinamit: %i]", broj_dinamita_igraca[id])
	}	
	return PLUGIN_CONTINUE;
	
}    
public PokaziReklame(id)
{
	id-=ZADATAK_POKAZI_REKLAME;
	if (!is_user_connected(id)) 
		return 
	
	ColorChat(0, GREEN, "[COD:MW4]^1 Welcome to COD:MW4. Mod edit by ^3Romanov");
}

public Pomoc(id){
	if (!is_user_connected(id)) 
		return
	
	show_menu(id, 1023, "\y/reset\w - reset points^n\y/class\w - Change class^n\y/drop\w - Drops item^n\y/item\w - Shows the description of your item^n\y/des\w - Shows the description of the class^n\y+use\w - Use the special power", -1, "Pomoc");
}
public PostaviBrzinu(id)
{
	id -= id > 32 ? ZADATAK_POSTAVI_BRZINU : 0
	
	if (!is_user_connected(id)) 
		return
	
	if(klasa_igraca[id])
	{
		set_user_maxspeed(id, brzina_igraca[id])
	}
}
public fw_traceline(Float:vecStart[3],Float:vecEnd[3],ignoreM,id,trace) 
{
	if(!is_user_connected(id))
		return;
	
	if(!is_user_connected(get_tr2(0,TR_pHit))){
		
		return
	}
	
	new hit = get_tr2(trace, TR_pHit);
	
	if(!is_user_connected(hit))
		return;
	
	new hitzone = get_tr2(trace, TR_iHitgroup);
	if((informacije_predmet_igraca[hit][0] == 41 || klasa_igraca[hit] == ProSWAT || klasa_igraca[hit] == SWAT )&& hitzone != HIT_HEAD)
		set_tr2(trace, TR_iHitgroup, 8);
		
	if(klasa_igraca[hit] == Graciete&& hitzone == HIT_HEAD)
		set_tr2(trace, TR_iHitgroup, 8);
	
	if(informacije_predmet_igraca[id][0] == 42 && !random(3) && get_user_weapon(id) == CSW_M4A1)
		set_tr2(trace, TR_iHitgroup, HIT_HEAD);	
	
	if(informacije_predmet_igraca[id][0] == 43 && !random(3) && get_user_weapon(id) == CSW_AK47)
		set_tr2(trace, TR_iHitgroup, HIT_HEAD);	
}
public DodirOruzija(weapon,id)
{
	if(!is_user_connected(id))
		return HAM_IGNORED;
	
	new model[23];
	pev(weapon, pev_model, model, 22);
	if (pev(weapon, pev_owner) == id || containi(model, "w_backpack") != -1)
		return HAM_IGNORED;
	return HAM_SUPERCEDE;
}
stock bool:UTIL_In_FOV(id,target)
{
	if (!is_user_connected(id)) 
		return false
	
	if (Find_Angle(id,target,9999.9) > 0.0)
		return true;
	
	return false;
}
stock UTIL_Kill(attacker, this, Float:damage)
{
	if(get_user_health(this) <= floatround(damage))
		lansirano[attacker][this] = true;
}
stock Float:Find_Angle(Core,Target,Float:dist)
{
	new Float:vec2LOS[2];
	new Float:flDot;
	new Float:CoreOrigin[3];
	new Float:TargetOrigin[3];
	new Float:CoreAngles[3];
	
	pev(Core,pev_origin,CoreOrigin);
	pev(Target,pev_origin,TargetOrigin);
	
	if (!pev_valid(Core)||!pev_valid(Target)) 
		return 0.0;
	
	if (get_distance_f(CoreOrigin,TargetOrigin) > dist)
		return 0.0;
	
	pev(Core,pev_angles, CoreAngles);
	
	for ( new i = 0; i < 2; i++ )
		vec2LOS[i] = TargetOrigin[i] - CoreOrigin[i];
	
	new Float:veclength = Vec2DLength(vec2LOS);
	
	//Normalize V2LOS
	if (veclength <= 0.0)
	{
		vec2LOS[0] = 0.0;
		vec2LOS[1] = 0.0;
	}
	else
	{
		new Float:flLen = 1.0 / veclength;
		vec2LOS[0] = vec2LOS[0]*flLen;
		vec2LOS[1] = vec2LOS[1]*flLen;
	}
	//Do a makevector to make v_forward right
	engfunc(EngFunc_MakeVectors,CoreAngles);
	
	new Float:v_forward[3];
	new Float:v_forward2D[2];
	get_global_vector(GL_v_forward, v_forward);
	
	v_forward2D[0] = v_forward[0];
	v_forward2D[1] = v_forward[1];
	
	flDot = vec2LOS[0]*v_forward2D[0]+vec2LOS[1]*v_forward2D[1];
	
	if ( flDot > 0.5 )
	{
		return flDot;
	}
	return 0.0;
}
stock Float:Vec2DLength( Float:Vec[2] )  
{ 
	return floatsqroot(Vec[0]*Vec[0] + Vec[1]*Vec[1] );
}
stock Display_Fade(id,duration,holdtime,fadetype,red,green,blue,alpha)
{
	message_begin( MSG_ONE, g_msg_screenfade,{0,0,0},id );
	write_short( duration );	// Duration of fadeout
	write_short( holdtime );	// Hold time of color
	write_short( fadetype );	// Fade type
	write_byte ( red );		// Red
	write_byte ( green );		// Green
	write_byte ( blue );		// Blue
	write_byte ( alpha );	// Alpha
	message_end();
}
public SetModel(ent, model[])
{
	if(!pev_valid(ent))
		return FMRES_IGNORED
	
	if(!equal(model, "models/w_p228.mdl")) 
		return FMRES_IGNORED;
	
	new id = pev(ent, pev_owner);

	if(!is_user_connected(id))
		return FMRES_IGNORED
	
	if(!(ima_bazuku[id]))
		return FMRES_IGNORED;
	
	engfunc(EngFunc_SetModel, ent, "models/w_law.mdl");
	set_pev(ent, pev_iuser4, rakete_igraca[id]);
	ima_bazuku[id] = false;
	return FMRES_SUPERCEDE;
}
public message_DeathMsg()
{
	static killer, victim;
	killer = get_msg_arg_int(1);
	victim = get_msg_arg_int(2);
	
	if(!is_user_connected(killer)||!is_user_connected(victim))
		return PLUGIN_CONTINUE
	
	if(lansirano[killer][victim])
	{
		lansirano[killer][victim] = false;
		set_msg_arg_string(4, "grenade");
		return PLUGIN_CONTINUE;
	}
	
	if(classHasKatana(klasa_igraca[killer]))
	{
		set_msg_arg_string(4, "weapon_knife");
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}
public task_launcher_reload(id)
{
	id -= 3512;
	
	if (!is_user_connected(id)) 
		return
	
	reloading[id] = false;
	set_pev(id, pev_weaponanim, 0);
}
public Weapon_DeployBazooka(ent)
{
	if(!pev_valid(ent)){
		
			return PLUGIN_CONTINUE
	}
	new id = get_pdata_cbase(ent, 41, 4);
	
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	if(ima_bazuku[id])
	{
		set_pev(id, pev_viewmodel2, "models/v_law.mdl");
		set_pev(id, pev_weaponmodel2, "models/p_law.mdl");
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}
public Weapon_DeployKatana(ent)
{
	if(!pev_valid(ent))
		return PLUGIN_CONTINUE;
	
	new id = get_pdata_cbase(ent, 41, 4);
	
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	if(classHasKatana(klasa_igraca[id]))
	{
		set_pev(id, pev_viewmodel2, "models/ByM_Cod/v_katanainv.mdl");
		set_pev(id, pev_weaponmodel2, "models/ByM_Cod/p_katana.mdl");
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}
public Weapon_DeploySuperShotgun(ent){

	if(!pev_valid(ent))
		return PLUGIN_CONTINUE;
	
	new id = get_pdata_cbase(ent, 41, 4);
	
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	if(classHasSuperShotgun(klasa_igraca[id]))
	{
		set_pev(id, pev_viewmodel2, "models/ByM_Cod/v_supershotgun.mdl");
		set_pev(id, pev_weaponmodel2, "models/ByM_Cod/p_supershotgun.mdl");
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;

}
public Weapon_WeaponIdle(ent)
{
	if(!pev_valid(ent))
		return
	
	new id = get_pdata_cbase(ent, 41, 4);
	
	if (!is_user_connected(id)) 
		return
	
	if(get_user_weapon(id) == 1 && ima_bazuku[id])
	{
		if(!idle[id]) 
			idle[id] = get_gametime();
	}
}
stock set_user_clip(id, ammo)
{
	new weaponname[32], weaponid = -1, weapon = get_user_weapon(id, _, _);
	get_weaponname(weapon, weaponname, 31);
	while ((weaponid = find_ent_by_class(weaponid, weaponname)) != 0)
		if(entity_get_edict(weaponid, EV_ENT_owner) == id) 
	{
		set_pdata_int(weaponid, 51, ammo, 4);
		return weaponid;
	}
	return 0;
}
stock Float:estimate_take_hurt(Float:fPoint[3], ent, ignored) 
{
	new Float:fOrigin[3];
	new tr;
	new Float:fFraction;
	pev(ent, pev_origin, fOrigin);
	engfunc(EngFunc_TraceLine, fPoint, fOrigin, DONT_IGNORE_MONSTERS, ignored, tr);
	get_tr2(tr, TR_flFraction, fFraction);
	
	if(fFraction == 1.0 || get_tr2(tr, TR_pHit) == ent)
	{
		return 1.0;
	}
	return 0.6;
}
public message_Health(msgid, dest, id)
{
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE;
	
	static hp;
	hp = get_msg_arg_int(1);
	
	if(hp > 255 && (hp % 256) == 0)
		set_msg_arg_int(1, ARG_BYTE, ++hp);
	
	return PLUGIN_CONTINUE;
}
public BlokirajKomande()
	return PLUGIN_HANDLED;

public cmd_setpredmet(id, level, cid)
{
	if(!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED;
	
	new arg1[33];
	new arg2[6];
	
	read_argv(1, arg1, 32);
	read_argv(2, arg2, 5);
	
	new igrac  = cmd_target(id, arg1, 0)
	new predmet = str_to_num(arg2)
	
	if(!is_user_alive(igrac))
	{
		client_print(id, print_console, "Ne mozete dati predmet mrtvom igracu.");
		return PLUGIN_HANDLED;
	}
	new result
	ExecuteForward(fwForwards[get_num_perks_fwd],result)
	if(predmet < 0 || predmet > result-1)
	{
		client_print(id, print_console, "Uneli ste nevazeci broj predmeta.");
		return PLUGIN_HANDLED;
	}
	DajPredmet(igrac, predmet);
	
	if(get_cvar_num("cod_predmet_log"))
	{
		new vreme[9] ,authid[32], authid2[32], name2[32], name[32];
		get_user_authid(id, authid, 31);
		get_user_authid(igrac, authid2, 31);
		get_user_name(igrac, name2, 31);
		get_user_name(id, name, 31);
		get_time("%H:%M:%S", vreme, 8);
	}
	return PLUGIN_HANDLED;
}
public Komande(id){
	
	if (!is_user_connected(id)) 
		return
	
	show_menu(id, 1023, "\r/reset\y -Ponovo podeli poene^n\r/shop\y - Otvari Shop^n\r/class\y - Choose a class^n\r/drop\y - Remove item^n\r/predmet\y - Opis tvog predmeta^n\r/opis\y -Opis svih klasa^n\rna +use \y- Koristi specijalne moci klase^n\rna (+radio2) \y- Koristi killstreak^n\r/rs\y resetuje skor^n\r/pomoc\y Ukljucuje/Iskljucuje pomoc u chatu^n\r/def\y ", -1, "Komande");
}
public Prodaj(id) 
{ 
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	client_cmd(id, "spk MW4/select");  
	
	
	if(!informacije_predmet_igraca[id][0]) 
	{ 
		ColorChat(id, NORMAL, "^4[COD:MW4]^1 Need Item."); 
		return PLUGIN_CONTINUE; 
	} 
	else 
	{ 
		new pare_igraca; 
		pare_igraca = cs_get_user_money(id); 
		new buff[128];
		new result
		PrepareArray(buff,128,1)
		ExecuteForward(fwForwards[get_perk_name_fwd],result,informacije_predmet_igraca[id][0],buff);
		ColorChat(id, NORMAL, "^4[COD:MW4] ^1You sold ^3%s^1 for ^3$2500", buff); 
		Obrisipredmet(id); 
		cs_set_user_money(id, pare_igraca+2500);
	}
	return PLUGIN_CONTINUE;
}  
public DajNekomPredmet(id) 
{ 
	if (!is_user_connected(id)) 
		return 
	
	new menu = menu_create("Izaberi Igraca", "DajNekomPredmet_Handle"); 
	new cb = menu_makecallback("DajNekomPredmet_Callback"); 
	new broj_predmeta; 
	for(new i=0; i<=32; i++) 
	{ 
		if(!is_user_connected(i)) 
			continue; 
		daj_igracu[broj_predmeta++] = i; 
		menu_additem(menu, naziv_igraca[i], "0", 0, cb); 
	} 
	menu_display(id, menu); 
} 
public DajNekomPredmet_Handle(id, menu, item) 
{ 
	if(item < 1 || item > 32) return PLUGIN_CONTINUE; 
	
	if(!is_user_connected(daj_igracu[item])) 
	{ 
		ColorChat(id, NORMAL, "^4[COD:MW4]^1 Player is disconnected."); 
		return PLUGIN_CONTINUE; 
	} 
	if(dobio_predmet[id]) 
	{ 
		ColorChat(id, NORMAL, "^4[COD:MW4]^1 You must wait until the next round."); 
		return PLUGIN_CONTINUE; 
	} 
	if(!informacije_predmet_igraca[id][0]) 
	{ 
		ColorChat(id, NORMAL, "^4[COD:MW4]^1 You have no item."); 
		return PLUGIN_CONTINUE; 
	} 
	if(informacije_predmet_igraca[daj_igracu[item]][0]) 
	{ 
		ColorChat(id, NORMAL, "^4[COD:MW4]^1 This player has already been the subject of."); 
		return PLUGIN_CONTINUE; 
	} 
	if(!is_user_alive(daj_igracu[item])) 
	{ 
		ColorChat(id, NORMAL, "^4[COD:MW4]^1 You must be alive."); 
		return PLUGIN_CONTINUE; 
	} 
	
	dobio_predmet[daj_igracu[item]] = true; 
	DajPredmet(daj_igracu[item], informacije_predmet_igraca[id][0]); 
	informacije_predmet_igraca[daj_igracu[item]][1] = informacije_predmet_igraca[id][1]; 
	
	new buff[128];
	new result
	PrepareArray(buff,128,1)
	ExecuteForward(fwForwards[get_perk_name_fwd],result,informacije_predmet_igraca[id][0],buff);
	ColorChat(id, NORMAL, "^4[COD:MW4]^1 Awarded ^3%s ^1sa ^3%s.", naziv_igraca[daj_igracu[item]], buff); 
	ColorChat(daj_igracu[item], NORMAL, "^4[COD:MW4]^1 You got a ^3 %s^1 od ^3%s.",buff , naziv_igraca[id]); 
	Obrisipredmet(id); 
	return PLUGIN_CONTINUE; 
}

public DajNekomPredmet_Callback(id, menu, item) 
{ 
	if(daj_igracu[item] == id) 
		return ITEM_DISABLED; 
	return ITEM_ENABLED; 
}  
public Menu(id)
{
	if (!is_user_connected(id)) 
		return
	
	new menu = menu_create("Menu:", "Menu_handle");
	menu_additem(menu, "\rClasses\y(Class Menu)");
	menu_additem(menu, "\rDescription Klase\y(Description of the Class Menu)");
	menu_additem(menu, "\rShop\y(Shop Menu)");
	menu_display(id, menu);
}
public Menu_handle(id, menu, item) 
{
	if (!is_user_connected(id)) 
		return PLUGIN_CONTINUE;
	
	client_cmd(id, "spk QTM_CodMod/select");
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	switch(item) 
	{ 
		case 0:
		{
			IzaberiKlasu(id)
		}
		case 1:
		{
			OpisKlase(id)
		}
		case 2:
		{
			Shop(id)
		}
	}
	return PLUGIN_CONTINUE;
}
