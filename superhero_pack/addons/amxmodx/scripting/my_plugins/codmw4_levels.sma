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
#include "my_include/codmw4_levels.inc"

#tryinclude "my_include/codmw4_lvl.cfg"

#define PLUGIN "Call of Duty: MW4 levels"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum


new level_igraca[33] = 1;
new iskustvo_igraca[33];

new poeni_igraca[33];
new SyncHudObj3;

new g_vault;
public plugin_init(){
register_plugin(PLUGIN, VERSION, AUTHOR);

g_vault = nvault_open("CodMod");
register_concmd("cod_num_levels","print_MaxLvl") 

SyncHudObj3 = CreateHudSyncObj();
}

public plugin_natives(){

	register_native("ProveriNivo","lvlPlayerUp",0);
	register_native("set_PlayerLvl","setPlayerLvl",0);
	register_native("set_PlayerXp","setPlayerXp",0);
	register_native("get_PlayerLvl","getPlayerLvl",0);
	register_native("get_PlayerXp","getPlayerXp",0);
	register_native("SacuvajPodatke","_SacuvajPodatke",0);
	register_native("inc_PlayerXp","incPlayerXp",0);
	register_native("get_PlayerPoints","getPlayerPoints",0);
	register_native("inc_PlayerPoints","incPlayerPoints",0);
	register_native("set_PlayerPoints","setPlayerPoints",0);


}


public getMaxLevel(){



	return sizeof iskustvo_levelu;


}

public print_MaxLvl(id, level, cid){

	console_print(id,"Max levels: %i",getMaxLevel());

}public getXpFromLevel(level){
	
	return iskustvo_levelu[level]
}

public setPlayerLvl(iPlugin,iParams){


	new id=get_param(1);
	new lvl=get_param(2);
	
	level_igraca[id]=lvl;



}
public setPlayerXp(iPlugin,iParams){

	new id=get_param(1);
	new xp=get_param(2);
	
	iskustvo_igraca[id]=xp;

}
public getPlayerLvl(iPlugin,iParams){
	
	new id=get_param(1);
	
	return level_igraca[id];


}
public getPlayerXp(iPlugin,iParams){


	new id=get_param(1);
	
	return iskustvo_igraca[id];
}

public incPlayerXp(iPlugin,iParams){

	new id=get_param(1);
	new inc=get_param(2);
	
	iskustvo_igraca[id]+=inc;

}

public _SacuvajPodatke(iPlugin,iParams)
{
	
	new id=get_param(1)
	new class=get_param(2)
	new intel=get_param(3)
	new energy=get_param(4)
	new resistance=get_param(5)
	new condition=get_param(6)
	
	
	
	if(!class)
		return PLUGIN_CONTINUE;
	
	new vaultkey[128],vaultdata[256], ID_igraca[64];
	format(vaultdata, charsmax(vaultdata),"#%i#%i#%i#%i#%i#%i", get_PlayerXp(id), get_PlayerLvl(id), intel,energy,resistance,condition);
	
	get_user_authid(id, ID_igraca, charsmax(ID_igraca))
	
	format(vaultkey, charsmax(vaultkey),"%s-%i-cod", ID_igraca, class);
	nvault_set(g_vault,vaultkey,vaultdata);
	
	return PLUGIN_CONTINUE;
}

public lvlPlayerUp(iPlugin,iParams){

	
	new id=get_param(1)
	new class=get_param(2)
	new intel=get_param(3)
	new energy=get_param(4)
	new resistance=get_param(5)
	new condition=get_param(6)
	
	if(level_igraca[id] <getMaxLevel())
	{
		new leveled_up=0;
		new level_xp=getXpFromLevel(level_igraca[id])
		
		while(iskustvo_igraca[id] >= level_xp)
		{
			level_igraca[id]++;
			leveled_up=1;
			level_xp=getXpFromLevel(level_igraca[id])
		}
		if(leveled_up){
		
			set_hudmessage(245, 200, 25, -1.0, 0.25, 0, 1.0, 2.0, 0.1, 0.2, 2);
			ShowSyncHudMsg(id, SyncHudObj3, "Dobrodosao na %i level !", level_igraca[id]);
			client_cmd(id, "spk QTM_CodMod/levelup");
		}
		poeni_igraca[id]=(level_igraca[id]-1)*2-intel-energy-resistance-condition;
	}
	SacuvajPodatke(id,class,intel,energy,resistance,condition);
}


public setPlayerPoints(iPlugin,iParams){

	new id=get_param(1)
	new ammount=get_param(2)
	poeni_igraca[id]=ammount;

}
public getPlayerPoints(iPlugin,iParams){


	new id=get_param(1)
	return poeni_igraca[id];

}
public incPlayerPoints(iPlugin,iParams){

	new id=get_param(1)
	new ammount=get_param(2)
	poeni_igraca[id]+=ammount;



}
