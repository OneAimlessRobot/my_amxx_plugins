#include <amxmodx.inc>
#include <engine.inc>
#include <superheromod.inc>
#include <Vexd_Utilities.inc>
#include <xtrafun.inc>

// VARIABLES
new gHeroName[]="Antman"
new bool:g_HasAntmanPowers[SH_MAXSLOTS+1]
new bool:g_morphed[SH_MAXSLOTS+1]
//----------------------------------------------------------------------------------------------
public plugin_init()
{
  // Plugin Info
  register_plugin("SUPERHERO Antman","1.0","SRGrty")
 
  // FIRE THE EVENT TO CREATE THIS SUPERHERO!
  if ( isDebugOn() ) server_print("Attempting to create Antman Hero")
  register_cvar("Antman_level", "7" )
  shCreateHero(gHeroName, "Small", "Makes you hard to see", true, "Antman_level" )
  
  // REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
  // INIT
  register_srvcmd("Antman_init", "Antman_init")
  shRegHeroInit(gHeroName, "Antman_init")
  register_event("ResetHUD","newRound","b")
  register_event("DeathMsg", "Antman_death", "a")
  register_srvcmd("Antman_kd", "Antman_kd")
  shRegKeyDown(gHeroName, "Antman_kd")
    // KEY UP
  register_srvcmd("Antman_ku",   "Antman_ku")
  shRegKeyUp(gHeroName, "Antman_ku")

  // DEFAULT THE CVARS
  register_cvar("Antman_cooldown", "45" )
  register_cvar("Antman_maxtime",  "30" )
  register_cvar("Antman_toggle",  "1" )
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
  precache_model("models/player/Antman/Antman.mdl")
  return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public newRound(id)
{
  gPlayerUltimateUsed[id]=false
  return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
public Antman_init()
{
  new temp[128]
  // First Argument is an id
  read_argv(1,temp,5)
  new id=str_to_num(temp)
  
  // 2nd Argument is 0 or 1 depending on whether the id has wolverine skills
  read_argv(2,temp,5)
  new hasPowers=str_to_num(temp)

  if ( hasPowers )
   g_HasAntmanPowers[id]=true
  else
   g_HasAntmanPowers[id]=false  
}
//----------------------------------------------------------------------------------------------
// RESPOND TO KEYDOWN
public Antman_kd() 
{ 
  new temp[6]
  
  // First Argument is an id with Antman Powers!
  read_argv(1,temp,5)
  new id=str_to_num(temp) 
 
    // If in toggle mode change this to a keyup event
  if ( get_cvar_num("Antman_toggle") && g_morphed[id] )
  {
    Antman_unmorph(id)
    return PLUGIN_HANDLED
  }
  
  // Let them know they already used their ultimate if they have
  if ( gPlayerUltimateUsed[id] )
  {
    playSoundDenySelect(id)
    return PLUGIN_HANDLED 
  } 
  
  new AntmanCooldown=get_cvar_num("Antman_cooldown")
  if ( AntmanCooldown>0 )ultimateTimer(id, AntmanCooldown * 1.0 )
  
  Antman_morph(id)
  
  new AntmanMaxTime=get_cvar_num("Antman_maxtime")
  if (AntmanMaxTime>0)
  
  {
     new parm[1]
     parm[0]=id
     set_task(AntmanMaxTime*1.0,"forceUnmorph",0, parm, 1)
  }
  return PLUGIN_HANDLED 
} 
//----------------------------------------------------------------------------------------------
public Antman_morph(id)
{

  cs_set_user_model(id,"Antman") 
  g_morphed[id]=true
  // Message
  set_hudmessage(200, 200, 0, 0.35, 0.45, 2, 0.02, 2.0, 0.01, 0.1, 2) 
  show_hudmessage(id,  "You are now as small as an ant") 
}
//----------------------------------------------------------------------------------------------
public Antman_unmorph(id)
{
  if ( g_morphed[id] )
  {
    cs_reset_user_model(id) 
    set_hudmessage(200, 200, 0, 0.35, 0.45, 2, 0.02, 2.0, 0.01, 0.1, 2) 
    show_hudmessage(id,"            Antman mode of") 
    g_morphed[id]=false
  }
}
//----------------------------------------------------------------------------------------------
public Antman_death()
{
  new id=read_data(2)
  
  Antman_unmorph(id)
  return PLUGIN_HANDLED 
}
//----------------------------------------------------------------------------------------------
public forceUnmorph(parm[])
{
  new id= parm[0]
  Antman_unmorph(id)  
}
//----------------------------------------------------------------------------------------------
// RESPOND TO KEYUP
public Antman_ku() 
{ 
  new temp[6]
  
  // toggle mode - keyup doesn't do anything!
  if ( get_cvar_num("Antman_toggle") ) return PLUGIN_HANDLED
  
  // First Argument is an id with Antman powers!
  read_argv(1,temp,5)
  new id=str_to_num(temp)

  Antman_unmorph(id)
  return PLUGIN_HANDLED 
} 
//----------------------------------------------------------------------------------------------