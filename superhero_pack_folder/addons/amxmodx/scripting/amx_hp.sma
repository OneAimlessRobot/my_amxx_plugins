#include <amxmodx>
#include <amxmisc>
#include <fun>
 
#define PLUGIN "Change Health"
#define VERSION "1.0"
#define AUTHOR "BAILOPAN"
 
public plugin_init()
{
     register_plugin(PLUGIN, VERSION, AUTHOR)
     register_concmd("amx_hp", "cmd_hp", ADMIN_SLAY, "<target> <hp>")
}
 
public cmd_hp(id, level, cid)
{
     if (!cmd_access(id, level, cid, 3))
        return PLUGIN_HANDLED
 
     new Arg1[24]
     new Arg2[4]
 
     //Get the command arguments from the console
     read_argv(1, Arg1, charsmax(Arg1))
     read_argv(2, Arg2, charsmax(Arg2))
 
     //Convert the health from a string to a number
     new Health = str_to_num(Arg2)
 
     //Is the first character the @ symbol?
     if (Arg1[0] == '@')
     {
          new Team
          if (equali(Arg1[1], "CT"))
          {
               Team = 2
          } else if (equali(Arg1[1], "T")) {
               Team = 1
          }
          new players[32], num
          get_players(players, num)
          new i
          for (i=0; i<num; i++)
          {
               if (!Team)
               {
                    set_user_health(players[i], Health)
               } else {
                    if (get_user_team(players[i]) == Team)
                    {
                         set_user_health(players[i], Health)
                    }
               }
          }
     } else {
          new player = cmd_target(id, Arg1, 1)
          if (!player)
          {
               console_print(id, "Sorry, player %s could not be found or targetted!", Arg1)
               return PLUGIN_HANDLED
          } else {
               set_user_health(player, Health)
          }
     }
 
     return PLUGIN_HANDLED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
