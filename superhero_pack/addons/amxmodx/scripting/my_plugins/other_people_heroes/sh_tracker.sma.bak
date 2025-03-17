#include <amxmodx>
#include <Vexd_Utilities>
#include <superheromod>

/* CVARS - COPY AND PASTE INTO shconfig.cfg

//Tracker
tracker_level 9 //Level at which you can get tracker (Default: 9)
tracker_scale 8 //Size of the target sprite (Default: 8)
tracker_bright 255 //Brightness of the target sprite (0-255) (Default: 255)
tracker_maxtargets 0 //Max number of targets that can be tracked at one time (0 is unlimited) (Default: 0)
tracker_timetargeted 0.0 //Ammount of time you can track someone before you lose the target on them (in seconds) (float) (0.0 is unlimited) (Default: 0.0)
tracker_refreshrate 1.0 //Ammount of time between showings of the target sprite (in seconds) (float) (Default: 1.0)

*/

/* VERSION HISTORY

1.0 - IT LIVES!
1.1 - Now prevents tracking of teammates and self, changed the sprite, got the sprite out of the wall
1.2 - Added maxtargets, timetargeted, and refreshrate cvars (by request)
1.3 - Changed the sprite again, reduced the distance between wall and sprite, sprite no longer obscures the view of the target

*/

new spriteTarget
new bool:hasTrackerPowers[SH_MAXSLOTS+1]
new bool:isTagged[SH_MAXSLOTS+1][SH_MAXSLOTS+1]
new Float:timeLeft[SH_MAXSLOTS+1][SH_MAXSLOTS+1]
new numTargets[SH_MAXSLOTS+1]
//----------------------------------------------------------------------------------------------
public plugin_init()
{
  //Register the plugin
  register_plugin("SUPERHERO Tracker", "1.3", "Kunlock")
  
  //Create the hero
  register_cvar("tracker_level","9")
  register_cvar("tracker_scale","8")
  register_cvar("tracker_bright","255")
  register_cvar("tracker_maxtargets","0")
  register_cvar("tracker_timetargeted","0.0")
  register_cvar("tracker_refreshrate","1.0")
  //Hero Name- Short Description- Long Description- false=Automatic Powers true=KeyDown powers- Hero level
  shCreateHero("Tracker", "Tracks victims", "Shooting enemies tags them so you can track them down", false, "tracker_level" )
  
  //Initialize the hero
  register_srvcmd("tracker_init", "tracker_init")
  shRegHeroInit("Tracker", "tracker_init")
  
  //Hook the events
  register_event("ResetHUD","newRound","b")
  register_event("Damage", "tracker_damage", "b", "2!0")
  
  //Start the loop
  set_task(get_cvar_float("tracker_refreshrate"), "tracker_loop")
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
    spriteTarget = precache_model("sprites/shmod/tracker_target.spr")
}
//----------------------------------------------------------------------------------------------
public newRound(id)
{
  new players[32], num
  
  get_players(players, num, "a")
  
  numTargets[id] = 0
  
  for(new v=0; v<num; v++)
    isTagged[id][players[v]] = false
  
  for(new a=0; a<num; a++)
    if(isTagged[players[a]][id])
    {
      isTagged[players[a]][id] = false
      numTargets[players[a]] = numTargets[players[a]]--
    }
}
//----------------------------------------------------------------------------------------------
public tracker_init()
{
  new temp[128]
  // First Argument is an id of the player
  read_argv(1, temp, 5)
  new id = str_to_num(temp)
  
  // 2nd Argument is 0 if the player doesnt have Tracker powers, 1 if the player does have Tracker powers
  read_argv(2, temp, 5)
  new hasPowers = str_to_num(temp)
  
  if(hasPowers == 1)
    hasTrackerPowers[id] = true
  else
    hasTrackerPowers[id] = false
}
//----------------------------------------------------------------------------------------------
public tracker_damage(id)
{
  new victim = id
  new attacker = get_user_attacker(victim)
  new maxTargets = get_cvar_num("tracker_maxtargets")
  
  if(maxTargets == 0){
    maxTargets = 32
  }
    
  /*console_print(id,"Vitima: %d^nAttacker: %d^nTamanho do vetor de trackers: %d^nTamanho do numero de alvos do attacker: %d^n",victim,attacker,sizeof hasTrackerPowers,sizeof(numTargets[]))*/
  
  if(attacker<(SH_MAXSLOTS+1) && hasTrackerPowers[attacker] && attacker!=victim && get_user_team(attacker)!=get_user_team(victim) && numTargets[attacker]<maxTargets)
  {
    isTagged[attacker][victim] = true
    numTargets[attacker] = numTargets[attacker]++
    timeLeft[attacker][victim] = get_cvar_float("tracker_timetargeted")
    if(timeLeft[attacker][victim]==0.0)
      timeLeft[attacker][victim] = -1.0
  }
}
//----------------------------------------------------------------------------------------------
public tracker_loop()
{
  new players[32], num
  
  get_players(players, num, "a")
  new bright = get_cvar_num("tracker_bright")
  new scale = get_cvar_num("tracker_scale")
  
  for(new a=0; a<num; a++)
  {
    for(new v=0; v<num; v++)
    {
      if(isTagged[players[a]][players[v]] && (timeLeft[players[a]][players[v]]>0.0 || timeLeft[players[a]][players[v]]==-1.0))
      {
        new Float:source[3], Float:target[3], Float:location[3], view[3], hit[3]
        get_user_origin(players[a],view,1)
        
        source[0] = float(view[0])
        source[1] = float(view[1])
        source[2] = float(view[2])
        
        Entvars_Get_Vector(players[v],EV_VEC_origin,target)
        new hitent=TraceLn(players[a], source, target, location)
        
        if(hitent!=players[v])
        {
	        location[0] = (((((source[0]+location[0])/2.0)+location[0])/2.0)+location[0])/2.0
	        location[1] = (((((source[1]+location[1])/2.0)+location[1])/2.0)+location[1])/2.0
	        location[2] = (((((source[2]+location[2])/2.0)+location[2])/2.0)+location[2])/2.0
        }
        else
        {
	        location[0]=target[0]
	        location[1]=target[1]
	        location[2]=target[2]
        }
        
        hit[0] = floatround(location[0])
        hit[1] = floatround(location[1])
        hit[2] = floatround(location[2])
        
        message_begin(MSG_ONE, SVC_TEMPENTITY, hit, players[a])
        write_byte(17)//additive sprite, plays 1 cycle
        write_coord(hit[0])//x
        write_coord(hit[1])//y
        write_coord(hit[2])//z
        write_short(spriteTarget)//sprite index
        write_byte(scale)//scale in 0.1's
        write_byte(bright)//brightness
        message_end()
        
        if(timeLeft[players[a]][players[v]]!=-1.0)
        {
          timeLeft[players[a]][players[v]] = timeLeft[players[a]][players[v]] - get_cvar_float("tracker_refreshrate")
          if(timeLeft[players[a]][players[v]]<0.0)
            timeLeft[players[a]][players[v]] = 0.0
        }
      }
    }
  }
  
  set_task(get_cvar_float("tracker_refreshrate"), "tracker_loop")
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
