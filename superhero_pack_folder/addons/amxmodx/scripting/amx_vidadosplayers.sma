#include <amxmodx>
#include <hamsandwich>
#include <cstrike>

#define IsPlayer(%1) (1 <= %1 <= g_players)

new const PLUGIN_VERSION[]  = "1.0";
new gRed, gBlue;
new g_players;

public plugin_init() 
{
 register_plugin("Aim Health", PLUGIN_VERSION,  "MaNiax");
 RegisterHam(Ham_Player_PreThink, "player", "Player_PreThink");
 g_players = get_maxplayers();
}

public Player_PreThink(id)
{
 new iPlr, iBody;
 get_user_aiming(id, iPlr, iBody);
 
 if( IsPlayer(iPlr) && is_user_alive(iPlr) )
 {
  switch( cs_get_user_team(iPlr) )
  {
   case CS_TEAM_T:
   {
    gRed = 255;
    gBlue = 0;
   }
   case CS_TEAM_CT:
   {
    gRed = 0;
    gBlue = 255;
   }
  }
  
  new EnemyHealth = get_user_health(iPlr);
  new EnemyName[33];
  get_user_name(iPlr, EnemyName, charsmax(EnemyName));
  set_hudmessage(gRed, gBlue, 0, -1.0, -1.0, 0, 6.0, 1.6, 0.1, 0.2, -1); 
  show_hudmessage(id, "Name: %s | Health: %i", EnemyName, EnemyHealth);
 }  
}  
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
