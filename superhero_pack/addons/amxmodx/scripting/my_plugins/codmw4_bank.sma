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
#include "my_include/codmw4_bank.inc"

#define PLUGIN "Call of Duty: MW4 bank"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new shop_poeni_igraca[33];



new g_vault;


new shop_kill


public plugin_init() 
{ 
register_plugin(PLUGIN, VERSION, AUTHOR);

g_vault = nvault_open("CodMod");

register_concmd("withdraw","podigni") 
register_concmd("deposit","ubaci")
register_concmd("bank","_Banka")
register_clcmd("say /bank","_Banka")
shop_kill = register_cvar("cod_killgb", "3")

}
public getPlayerGB(player){


	return shop_poeni_igraca[player]

}
public addPlayerGB(player,ammount){


	shop_poeni_igraca[player]+=ammount;
	return PLUGIN_CONTINUE;

}
public setPlayerGB(player,ammount){

	
	shop_poeni_igraca[player]=ammount;
	return PLUGIN_CONTINUE;


}
public getKillGB(){


	return shop_kill;

}

public _Banka(id)
{
new naslove[60]
format(naslove, 59, "\dGB Banka(\r%i\y):", shop_poeni_igraca[id]);
new menu = menu_create(naslove, "BankaHandler")
menu_additem(menu,"\yPut GB points in the bank")
menu_additem(menu,"\yWithdraw GB points from bank")
menu_additem(menu,"\yView account balance")
menu_setprop(menu, MPROP_EXITNAME, "\rExit");
menu_display(id, menu);
}
public BankaHandler(id, menu, item)
{
if(item == MENU_EXIT)
{
menu_destroy(menu);
return PLUGIN_CONTINUE;
}
switch(item)
{
case MENU_EXIT:
{
	menu_destroy(menu)
}
case 0:
{
	client_cmd(id,"messagemode deposit")
	ColorChat(id,GREEN,"^3[COD:MW4]^4 Type in the number of GB Points which do you want to put in the bank")
}
case 1:
{
	client_cmd(id,"messagemode withdraw")
	ColorChat(id,GREEN,"^3[COD:MW4]^4 Type in the number of GB Points which do you want to withdraw from banks")
}
case 2:
{
	new broj_poena[32],pid[32]
	get_user_authid(id,pid,31)
	nvault_get(g_vault,pid,broj_poena,31)
	ColorChat(id,GREEN,"^3[COD:MW4]^4 Got %s GB Points in your account",broj_poena)
}
}
return PLUGIN_CONTINUE
}
public ubaci(id)
{
new suma[32],suma2, broj_poena
read_argv(1,suma,31)
suma2 = str_to_num(suma)
broj_poena = shop_poeni_igraca[id]
if(suma2<0) return
if(suma2>broj_poena)
suma2=broj_poena

new pid[32], bpoeni[32],bpoeni2, xxx[32]
get_user_authid(id,pid,31)
nvault_get(g_vault,pid,bpoeni,31)
bpoeni2 = str_to_num(bpoeni)
num_to_str(suma2+bpoeni2,xxx,31)
nvault_set(g_vault,pid,xxx)
shop_poeni_igraca[id] = broj_poena - suma2
ColorChat(id,GREEN,"^3[COD:MW4]^4 You successfully put %i GB points in the bank!",suma2)    
}
public podigni(id)
{
new suma[32],suma2, broj_poena,broj_bpoena[32],broj_bpoena2,pid[32],xxx[32]
read_argv(1,suma,31)
suma2 = str_to_num(suma)
broj_poena = shop_poeni_igraca[id]
get_user_authid(id,pid,31)
nvault_get(g_vault,pid,broj_bpoena,31)
broj_bpoena2 = str_to_num(broj_bpoena)
if(suma2<0)
	return
if(suma2>broj_bpoena2)
	suma2 = broj_bpoena2
	
shop_poeni_igraca[id] = broj_poena + suma2
num_to_str(broj_bpoena2-suma2,xxx,31)
nvault_set(g_vault,pid,xxx)
ColorChat(id,GREEN,"^3[COD:MW4]^4 You have Withdrawen %i GB Points!",suma2)
}
