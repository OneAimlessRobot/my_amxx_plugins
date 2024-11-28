#include "../../include/nvault.inc"
#include "../../include/amxmod.inc"
#include "../../include/amxmodx.inc"
#include "../../include/amxmisc.inc"
#include "../../include/hamsandwich.inc"
#include "../../include/fakemeta.inc"
#include "../../include/fakemeta_util.inc"
#include "../../include/colorchat.inc"
#include "../../include/engine.inc"
#include "../../include/fun.inc"
#include "../../include/csx.inc"
#include "../../include/cstrike.inc"
#include "../../include/Vexd_Utilities.inc"
#include "my_include/codmw4_cmds.inc"

new Ubrania_CT[4][]={"sas","gsg9","urban","gign"};
new Ubrania_Terro[4][]={"arctic","leet","guerilla","terror"};


#define PLUGIN "Call of Duty: MW4 Modcmds"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

public plugin_init() 
{ 
register_plugin(PLUGIN, VERSION, AUTHOR);
register_clcmd("say /def","_KupiDefuse");

}

public PromeniModel(id,reset)
{
if (id<1 || id>32 || !is_user_connected(id)) 
return PLUGIN_CONTINUE;

if (reset)
cs_reset_user_model(id);
else
{
new num = random_num(0,3);
switch(get_user_team(id))
{
case 1: cs_set_user_model(id, Ubrania_CT[num]);
case 2:cs_set_user_model(id, Ubrania_Terro[num]);
}
}
return PLUGIN_CONTINUE;
}


public _KupiDefuse(id)
{
	new pare_igraca = cs_get_user_money(id);
	
	if(get_user_team(id) != 2)
	{
		ColorChat(id, NORMAL, "^3[COD:MW4]^4 Only the CT team can buy a defuse kit");
		return PLUGIN_CONTINUE;
	}
	else if(pare_igraca < 200)
	{
		ColorChat(id, NORMAL, "^3[COD:MW4]^4 You do not have enough money");
		ColorChat(id, NORMAL, "^3[COD:MW4]^4 You have ^3 %i/ 200", pare_igraca);
		return PLUGIN_CONTINUE;
	}
	else if(cs_get_user_defuse(id) == 1)
	{
		ColorChat(id, NORMAL, "^3[COD:MW4]^4 Already have a defuse kit");
		return PLUGIN_CONTINUE;
	}
	cs_set_user_money(id, pare_igraca-200);
	cs_set_user_defuse(id, 1);
	
	return PLUGIN_CONTINUE;
}
