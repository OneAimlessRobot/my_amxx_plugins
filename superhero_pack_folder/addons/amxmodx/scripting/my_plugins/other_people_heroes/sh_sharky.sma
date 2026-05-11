#include "../my_include/superheromod.inc"

// sharky! - me!!! :)
// CVARS
// sharky_cooldown # of seconds before sharky can NoClip Again
// sharky_time # confused time
// sharky_level


// VARIABLES
new gHeroName[]="sharky's-confusion"
new gHeroID
new g_sharkyTimer[SH_MAXSLOTS+1]
new gSharkyMode[33]
new g_sharkySound[]="ambience/alien_zonerator.wav"
new smoke
//----------------------------------------------------------------------------------------------
public plugin_init()
{
  // Plugin Info
  register_plugin("SUPERHERO sharky","1.0","sharky")
 
  // FIRE THE EVENT TO CREATE THIS SUPERHERO!
  register_cvar("sharky_level", "9" )
  register_cvar("sharky_cooldown", "0.0" ) //CoolDown
  register_cvar("sharky_time", "0.0" ) // Time In confusedMode
  register_cvar("sharky_speed", "1000" ) //Speed he can run
  register_cvar("sharky_summon", "0" ) //1=yes 0=no
  register_cvar("sharky_smoke", "1" ) //1=yes 0=no
  register_cvar("sharky_ammo", "0" ) //1=always 0=Only in ninjamode

  gHeroID=shCreateHero(gHeroName, "sharky-mode", "make confusing smoke storm,get ALL the gunz", true, "sharky_level")
  register_clcmd("SharkyPower","make_fog",ADMIN_USER)
  
  register_event("CurWeapon","changeWeapon","be","0=0")

  // LOOP
  register_srvcmd("sharky_loop", "sharky_loop")
  //  shRegLoop1P0(gHeroName, "sharky_loop", "ac" ) // Alive sharkyHeros="ac"
  set_task(1.0,"sharky_loop",0,"",0,"b") //forever loop
  // DEATH
  register_event("DeathMsg", "sharky_death", "a")
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
   smoke = engfunc(EngFunc_PrecacheModel,"sprites/steam1.spr") 
   engfunc(EngFunc_PrecacheSound,g_sharkySound)
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode){
  if(heroID!=gHeroID) return

  if ( !sh_user_has_hero(id,gHeroID))
  {
    sharky_endmode(id)
    g_sharkyTimer[id]=0
  }
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
  sh_unset_cooldown_flag(id)
  if ( sh_user_has_hero(id,gHeroID) ) {
  sharky_gunz(id)
    }
  if (g_sharkyTimer[id]>0) {
  sharky_endmode(id)
  }
  return PLUGIN_HANDLED
}

//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, key)
{
if ( gHeroID != heroID ||!sh_user_has_hero(id,gHeroID) ) return

switch(key)
{
	case SH_KEYDOWN: {
		sharky_kd(id)
	}
}
}
//----------------------------------------------------------------------------------------------
// RESPOND TO KEYDOWN
public sharky_kd(id) 
{
  if ( !is_user_alive(id) ) return PLUGIN_HANDLED 
    
  // Let them know they already used their ultimate if they have
  if ( sh_get_cooldown_flag(id) )
  {
    playSoundDenySelect(id)
    return PLUGIN_HANDLED 
  }
  
  // Make sure they're not in the middle of it already
  if ( g_sharkyTimer[id]>0 ) return PLUGIN_HANDLED
  
  g_sharkyTimer[id]=get_cvar_num("sharky_time")+1
  if (get_cvar_num("sharky_smoke")==1){
  make_fog(id)
  }
  set_user_footsteps(id,1)
  shSetMaxSpeed(gHeroName, "sharky_speed", "[0]" )
  ultimateTimer(id, get_cvar_num("sharky_cooldown") * 1.0)
  gSharkyMode[id]=true
 
  // sharky Messsage 
  new message[128]
  formatex(message, 127, "entered confused mode - ur confused" )
  set_hudmessage(255,0,0,-1.0,0.3,0,0.25,1.0,0.0,0.0)
  show_hudmessage(id, message)
  emit_sound(id,CHAN_STATIC, g_sharkySound, 0.1, ATTN_NORM, 0, PITCH_LOW)

  return PLUGIN_HANDLED 
} 
//----------------------------------------------------------------------------------------------
public stopSound(id)
{
    //new SND_STOP=(1<<5)
    emit_sound(id,CHAN_STATIC, g_sharkySound, 0.1, ATTN_NORM, (1<<5), PITCH_LOW)
}
//----------------------------------------------------------------------------------------------   
public sharky_loop()
{
  for ( new id=1; id< sh_maxplayers()+1; id++ )
  {
    if ( sh_user_has_hero(id,gHeroID)&& is_user_alive(id)  ) 
    {
      if ( g_sharkyTimer[id]>0 )
      {
        g_sharkyTimer[id]--
        new message[128]
        formatex(message, 127, "%d seconds left of Sharky Mode", g_sharkyTimer[id] )
        set_hudmessage(255,0,0,-1.0,0.3,0,1.0,1.0,0.0,0.0)
        show_hudmessage( id, message)
        set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,80)
      }
      else
      {
        if ( g_sharkyTimer[id] == 0 )
        {
          g_sharkyTimer[id]--
          sharky_endmode(id)
          stopSound(id)
        }
      }
    }
  }
}
//----------------------------------------------------------------------------------------------
public sharky_endmode(id)
{
  stopSound(id)
  g_sharkyTimer[id]=0
  if ( gSharkyMode[id])
  {
    // Turn it off
	set_user_footsteps(id,0)
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,255)
	gSharkyMode[id]=false
  }
}
//----------------------------------------------------------------------------------------------
public sharky_death()
{
  new id=read_data(2)
  sharky_endmode(id)
  sh_unset_cooldown_flag(id)
}
//----------------------------------------------------------------------------------------------
public changeWeapon(id)
{
	if (get_cvar_num("sharky_ammo")==1){
		if ( !sh_user_has_hero(id,gHeroID) || !sh_is_active() ) return PLUGIN_CONTINUE
	}
	else{
		if ( !sh_user_has_hero(id,gHeroID) || !gSharkyMode[id] || !sh_is_active() ) return PLUGIN_CONTINUE
	}

	new  clip, ammo
	new wpn_id=get_user_weapon(id, clip, ammo);
	new wpn[32]

	if ( wpn_id!=CSW_TMP) {
		engclient_cmd(id,"weapon_tmp")
	}

	if ( wpn_id==CSW_TMP) {

		// Never Run Out of Ammo!
		//server_print("STATUS ID=%d CLIP=%d, AMMO=%d WPN=%d", id, clip, ammo, wpn_id)
		if ( clip == 0 )
		{
			//server_print("INVOKING PUNISHER MODE! ID=%d CLIP=%d, AMMO=%d WPN=%d", id, clip, ammo, wpn_id)
			get_weaponname(wpn_id,wpn,31)
			//highly recommend droppging weapon - buggy without it!
			give_item(id,wpn)
			engclient_cmd(id, wpn )
			engclient_cmd(id, wpn ) // Checking to see if multple sends helps - sometimes this doesn't work... ;-(
			engclient_cmd(id, wpn ) // Checking to see if multple sends helps - sometimes this doesn't work... ;-(
		}
	}

	return PLUGIN_CONTINUE
}
//----------------------------------------------------------------------------------------------
public sharky_gunz(id)
{
  shGiveWeapon(id,"weapon_mp5navy")

  shGiveWeapon(id,"weapon_sg552") 
  shGiveWeapon(id,"weapon_m4a1") 
  shGiveWeapon(id,"weapon_awp") 
  
   
  shGiveWeapon(id,"weapon_usp") 
  shGiveWeapon(id,"weapon_mac10") 
 

  shGiveWeapon(id,"weapon_elite")
  //give_item(id,"weapon_mp5navy") 
  //give_item(id,"weapon_deagle") 
   
  shGiveWeapon(id,"weapon_fiveseven")
  shGiveWeapon(id,"weapon_p90") 
  
   
  shGiveWeapon(id,"weapon_scout") 
  shGiveWeapon(id,"weapon_g3sg1") 
  //give_item(id,"weapon_sg552") 
  //give_item(id,"weapon_m4a1") 
  shGiveWeapon(id,"weapon_aug") 
  shGiveWeapon(id,"weapon_sig550") 
  
  shGiveWeapon(id,"weapon_m249") 
  shGiveWeapon(id,"weapon_hegrenade")
   
  
  // Give CTs a Defuse Kit
  if ( get_user_team(id) == 2 ) shGiveWeapon(id,"item_thighpack")

  return
}
//----------------------------------------------------------------------------------------------
public fog_this_area(origin[3]){ 
   message_begin( MSG_BROADCAST,SVC_TEMPENTITY,origin ) 
   write_byte( 5 ) 
   write_coord( origin[0] + generate_int( -200, 200 )) 
   write_coord( origin[1] + generate_int( -200, 200 )) 
   write_coord( origin[2] + generate_int( -150, 150 )) 
   write_short( smoke ) 
   write_byte( 120 ) 
   write_byte( 5 ) 
   message_end() 
} 
//----------------------------------------------------------------------------------------------

public make_fog(id){ 
   if (!sh_user_has_hero(id,gHeroID)) 
      return PLUGIN_HANDLED 
   if (is_user_alive(id)!=1) 
      return PLUGIN_HANDLED 
   new origin[3] 
   get_user_origin(id,origin) 
   fog_this_area(origin) 
   fog_this_area(origin) 
   fog_this_area(origin) 
   fog_this_area(origin) 
   fog_this_area(origin) 
   fog_this_area(origin) 
   fog_this_area(origin) 
   fog_this_area(origin) 
   fog_this_area(origin) 
   fog_this_area(origin)
   fog_this_area(origin)
   fog_this_area(origin)
   fog_this_area(origin)
   fog_this_area(origin)
   fog_this_area(origin)
   fog_this_area(origin)
   if (get_cvar_num("sharky_summon")==1){
   summon_sharky(id)
   }
   return PLUGIN_HANDLED 
} 
//----------------------------------------------------------------------------------------------
public summon_sharky(id)
{
new cmd[128]
new team[24]
get_user_team(id,team,7)

if (equal(team, "CT", 1)) {
  formatex(cmd, 127, "amx_monster hassassin #%i 1 @T", id)
  server_cmd(cmd)
}else{
  formatex(cmd, 127, "amx_monster hassassin #%i 1 @CT", id)
  server_cmd(cmd)
}
}
//----------------------------------------------------------------------------------------------
