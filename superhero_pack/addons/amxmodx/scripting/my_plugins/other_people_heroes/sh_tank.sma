#include <amxmod>
#include <xtrafun>
#include <Vexd_Utilities>
#include "../my_include/superheromod.inc"


// Tank!  
// CVARS
// tank_gravity      - he cant jump high......mostly cause he is a frigin tank
// tank_level        - what level must they be for throwing nades?

new const HEGRENADE_MODEL[] = "models/w_hegrenade.mdl"

// VARIABLES
new gHeroName[]="Tank"
new gHasTankPower[SH_MAXSLOTS+1]
//----------------------------------------------------------------------------------------------
public plugin_init()
{
  // Plugin Info
  register_plugin("SUPERHERO Tank","1.2","sharky/(AssKicR)")
 
  // FIRE THE EVENT TO CREATE THIS SUPERHERO!
  register_cvar("tank_level", "7")
  register_cvar("tank_gravity", "0.5" )
  register_cvar("tank_grenademult", "0.0")
  register_cvar("tank_grenadetimer", "1")  

  shCreateHero(gHeroName, "Nade Cannon!", "Nade Cannon!!", false, "tank_level" )
  
  // REGISTER EVENTS THIS HERO WILL RESPOND TO! (AND SERVER COMMANDS)
  // INIT
  register_srvcmd("tank_init", "tank_init")
  shRegHeroInit(gHeroName, "tank_init")

  register_event("ResetHUD","newRound","b")
  register_event("WeapPickup","models","b","1=19")
  register_event("CurWeapon","check_grenades","be","1=1")
  register_event("TextMsg","aTextMsg","bc","2&#Game_radio", "4&#Fire_in_the_hole")
  register_event("Damage", "tank_damage", "b", "2!0")

  shSetMinGravity(gHeroName, "tank_gravity" )
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
  //Playerview of laucher
  precache_model("models/tank/v_hegrenade.mdl") 
  
  //World View Of FLying Nade
  precache_model("models/tank/w_hegrenade.mdl") 
}
//----------------------------------------------------------------------------------------------
public tank_init()
{
  new temp[6]
  // First Argument is an id
  read_argv(1,temp,5)
  new id=str_to_num(temp)
  
  // 2nd Argument is 0 or 1 depending on whether the id has flash
  read_argv(2,temp,5)
  new hasPowers=str_to_num(temp)

  if ( hasPowers ) {
   gHasTankPower[id]=true
   tank_weapons(id)
   }
  else {
   gHasTankPower[id]=false  
   }
}
//----------------------------------------------------------------------------------------------
public newRound(id) {
  if ( gHasTankPower[id] && is_user_alive(id) ) {
    tank_weapons(id)
  }
  return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public tank_weapons(id) {
  if ( is_user_alive(id) && gHasTankPower[id] && shModActive() )
  {
     shGiveWeapon(id,"weapon_hegrenade")
  }
  return PLUGIN_HANDLED
} 
//----------------------------------------------------------------------------------------------
public refill(parm[])
{
  new id=parm[0]

  if ( is_user_alive(id) && gHasTankPower[id] && shModActive() )
  {
     shGiveWeapon(id,"weapon_hegrenade")
  }
}
//----------------------------------------------------------------------------------------------
public models(id) {
  model_he(id)
}
//----------------------------------------------------------------------------------------------
public model_he(id) { 
  if ( !is_user_alive(id) ) return PLUGIN_CONTINUE 
  // Weapon Model change thanks to [CCC]Taz-Devil
  Entvars_Set_String(id, EV_SZ_viewmodel, "models/tank/v_hegrenade.mdl")  
  new hCurrent 
  hCurrent = FindEntity(-1,"weapon_hegrenade") 
  while(hCurrent != -1) { 
    hCurrent = FindEntity(hCurrent,"weapon_hegrenade") 
   } 
  return PLUGIN_HANDLED
} 
//----------------------------------------------------------------------------------------------
public check_grenades(id)
{ 
if ( !gHasTankPower[id] || !shModActive() ) return PLUGIN_CONTINUE
new clip, ammo 
new wpn_id=get_user_weapon(id, clip, ammo)

if ( wpn_id == CSW_HEGRENADE ) model_he(id)

return PLUGIN_CONTINUE 
} 
//----------------------------------------------------------------------------------------------
public aTextMsg() { 
   //if (!heArena) 
      //return PLUGIN_HANDLED 
   new name[32] 
   read_data(3,name,31) 
   new parm[1] 
   parm[0] = get_user_index(name) 
   if (gHasTankPower[parm[0]]) {
      set_task(0.01,"ahethrown",0,parm,1)
      set_task( get_cvar_float("tank_grenadetimer"), "refill", 0, parm, 1  )
   }
   //set_task(0.1,"grenid",0,parm,1) 

   return PLUGIN_CONTINUE 
} 
//----------------------------------------------------------------------------------------------
public ahethrown(parm[]) { 

   new string[32], grenadeid = 0 
   do 
   { 
      grenadeid = get_grenade_id(parm[0], string, 31, grenadeid) 
   } 
   while (grenadeid &&!equali(HEGRENADE_MODEL,string)) 

   if (grenadeid) 
   { 
      if (gHasTankPower[parm[0]]) {
         ENT_SetModel(grenadeid, "models/tank/w_hegrenade.mdl")
      }
   } 
}
//----------------------------------------------------------------------------------------------
public tank_damage(id)
{
    if (!shModActive()) return PLUGIN_CONTINUE

    new damage = read_data(2)
    new weapon, bodypart, attacker = get_user_attacker(id,weapon,bodypart)
    
    if ( attacker <=0 || attacker>SH_MAXSLOTS ||attacker == id ) return PLUGIN_CONTINUE
    
    if ( gHasTankPower[attacker] && weapon == CSW_HEGRENADE && is_user_alive(id) )
    {
       // do extra damage
       new extraDamage = floatround(damage * get_cvar_float("tank_grenademult") - damage)
       if (extraDamage>0) shExtraDamage( id, attacker, extraDamage, "grenade" )
    }
    return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
