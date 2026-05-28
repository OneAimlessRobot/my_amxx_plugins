#include "../my_include/superheromod.inc"

// MEGAMAN! = The Ultimate Hero

// VARIABLES
new smoke 
new laser 
new laser_shots[33] 

// Damage Variables
#define h1_dam 100 //HEAD
#define h2_dam 50  //CHEST
#define h3_dam 55  //STOMACH
#define h4_dam 25  //ARM
#define h6_dam 45  //LEG

// CVARS
// megaman_level               // - Level to make Megaman Available - //Default-   10 //
// megaman_laser_ammo          // - Ammo that the Photon Cannon has - //Default-  150 //
// megaman_laser_burndecals    // - The ammount of PhotonGun Decals - //Default-    1 //
// megaman_cooldown            // - The Cooldown time of the Photon - //Default- 0.02 //
// megaman_gravity             // - The JumpingPower Megaman's suit - //Default-  650 //
// megaman_armor               // - The Megasuit's Power of defense - //Default-  600 //
// megaman_health              // - The Power Megaman has to resist - //Default-  300 //
// megaman_speed               // - The Speed/Agility of a Megasuit - //Default-  700 //

// Megaman is an awesome superhero that has a megasuit of ultimate powers!

new gHeroName[]="Megaman"
new gHeroID
//----------------------------------------------------------------------------------------------------------
public plugin_init()
{
  // Plugin Info
  register_plugin("SUPERHERO Megaman","1.14.4","NOOBology Madskillz")
 
  // FIRE THE EVENT TO CREATE THIS SUPERHERO!
  if (!cvar_exists("Megaman_level")) create_cvar("megaman_level", "10" )
  gHeroID=shCreateHero(gHeroName, "Photon Cannon", "Blazing Cannon and Megasuit", true, "megaman_level" )
  
  
  
  
  // THE DEFAULT OF THE CVARS
  create_cvar("megaman_laser_ammo", "100")      // - Ammo that the Photon Cannon has - //Default-  150 //
  create_cvar("megaman_laser_burndecals", "1")  // - The ammount of PhotonGun Decals - //Default-    1 //
  create_cvar("megaman_cooldown", "0.02" )      // - The Cooldown time of the Photon - //Default- 0.02 //  
  create_cvar("megaman_level", "10" )           // - Level to make Megaman Available - //Default-   10 //
  create_cvar("megaman_gravity", "650" )        // - The JumpingPower Megaman's suit - //Default-  650 //
  create_cvar("megaman_armor", "600" )          // - The Megasuit's Power of defense - //Default-  600 //
  create_cvar("megaman_health", "300" )         // - The Power Megaman has to resist - //Default-  300 //
  create_cvar("megaman_speed", "700" )          // - The Speed/Agility of a Megasuit - //Default-  700 //
}
//----------------------------------------------------------------------------------------------------------
public plugin_precache()
{
   smoke = engfunc(EngFunc_PrecacheModel,"sprites/steam1.spr") 
   laser = engfunc(EngFunc_PrecacheModel,"sprites/laserbeam.spr") 
   engfunc(EngFunc_PrecacheSound,"weapons/electro5.wav") 
   engfunc(EngFunc_PrecacheSound,"weapons/xbow_hitbod2.wav") 
}
//----------------------------------------------------------------------------------------------------------
public sh_client_death(id) 
{

  if ( id<0 || id>SH_MAXSLOTS ) return PLUGIN_CONTINUE
  remove_task(id)
  return PLUGIN_CONTINUE
  
}

//----------------------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
  if ( !hasRoundStarted() )
  {
    laser_shots[id] = get_cvar_num("megaman_laser_ammo") 
    sh_unset_cooldown_flag(id)
  }
  return PLUGIN_HANDLED
}


//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, sh_key_mode:key)
{
if ( gHeroID != heroID ||!sh_get_user_has_hero(id,gHeroID) ) return

switch(key)
{
	case SH_KEYDOWN: {
		megaman_kd(id)
	}
	
	case SH_KEYUP: {
		
		megaman_ku(id)
	}
}
}

public megaman_kd(id) 
{
  if ( !hasRoundStarted() ) return PLUGIN_HANDLED 

  if ( !is_user_alive(id) ) return PLUGIN_HANDLED   
  
  // Let them know they already used their ultimate if they have 
  new parm[1]
  parm[0]=id
  megamanFire(parm)  // 1 immediate shot
  set_task( get_cvar_float("megaman_cooldown"), "megamanFire", id, parm, 1, "b")  //delayed shots

  return PLUGIN_HANDLED
}

//----------------------------------------------------------------------------------------------------------
public megamanFire(parm[])
{
  fire_laser(parm[0])
}

//----------------------------------------------------------------------------------------------------------
public megaman_ku(id)
{
  remove_task(id)
} 

//----------------------------------------------------------------------------------------------------------
public laserEffects(id, aimvec[3] )
{
  new choose_decal,decal_id 

  emit_sound(id,CHAN_ITEM, "weapons/electro5.wav", 1.0, ATTN_NORM, 0, PITCH_NORM) 

  choose_decal = generate_int(0,0)
  switch(choose_decal)
  { 
      case 0: decal_id = 28 
      case 1: decal_id = 103 
      case 2: decal_id = 198 
      case 3: decal_id = 199    
  } 

  new origin[3]
  get_user_origin(id, origin, 1)
  
  // DELIGHT
  message_begin( MSG_BROADCAST,SVC_TEMPENTITY) 
  write_byte( 27 ) 
  write_coord( origin[0] ) //POSITION
  write_coord( origin[1] ) 
  write_coord( origin[2] )
  write_byte( 10 )
  write_byte( 30 ) // RED
  write_byte( 190 ) // GREEN 
  write_byte( 255 ) // BLUE 
  write_byte( 2 ) // LIFE
  write_byte( 1 ) // DECAY
  message_end() 
    
  //BEAMENTPOINTS
  message_begin( MSG_BROADCAST,SVC_TEMPENTITY) 
  write_byte ( 0 )     //TE_BEAMENTPOINTS 0  
  write_coord(origin[0]) 
  write_coord(origin[1]) 
  write_coord(origin[2]) 
  write_coord(aimvec[0]) 
  write_coord(aimvec[1]) 
  write_coord(aimvec[2]) 
  write_short( laser ) 
  write_byte( 1 ) // FRAMESTART 
  write_byte( 5 ) // FRAMERATE 
  write_byte( 2 ) // LIFE 
  write_byte( 80 ) // WIDTH 
  write_byte( 0 ) // NOISE 
  write_byte( 30 ) // RED
  write_byte( 190 ) // BLUE
  write_byte( 255 ) // GREEN
  write_byte( 200 ) // BRIGHTNESS 
  write_byte( 175 ) // SPEED
  message_end() 
  
  //Sparks 
  message_begin( MSG_PVS, SVC_TEMPENTITY) 
  write_byte( 9 ) 
  write_coord( aimvec[0] ) 
  write_coord( aimvec[1] ) 
  write_coord( aimvec[2] ) 
  message_end()
  
  //Smoke    
  message_begin( MSG_BROADCAST,SVC_TEMPENTITY) 
  write_byte( 5 ) // 5 
  write_coord(aimvec[0]) 
  write_coord(aimvec[1]) 
  write_coord(aimvec[2]) 
  write_short( smoke ) 
  write_byte( 22 )  // 10 
  write_byte( 10 )  // 10 
  message_end() 
  
  if(get_cvar_num("megaman_laser_burndecals") == 1)
  {
    //TE_GUNSHOTDECAL 
    message_begin( MSG_BROADCAST,SVC_TEMPENTITY) 
    write_byte( 109 ) // DECAL AND RICOCHET SOUNDS
    write_coord( aimvec[0] ) //POSITION
    write_coord( aimvec[1] ) 
    write_coord( aimvec[2] ) 
    write_short (0) // NO CLUE [RECOMMEND YOU LEAVE IT ALONE]
    write_byte (decal_id) //DECAL
    message_end()
  }
  
}

//----------------------------------------------------------------------------------------------------------
public fire_laser(id)
{ 
  new aimvec[3] 
  new tid,tbody 
  new FFOn= get_cvar_num("mp_friendlyfire")

  if( !is_user_alive(id) ) return
  
  if ( laser_shots[id]<=0 ) 
  {  
    playSoundDenySelect(id)
    return
  }
  
  // Use the Ultimate
  // ultimateTimer(id, get_cvar_float("megaman_cooldown")
  
  // Photon Ammo Left
  laser_shots[id]--  
  if(laser_shots[id] < 6) client_print(id,print_chat,"%d Energy Remaining", laser_shots[id] )

  get_user_origin(id,aimvec,3) 
  laserEffects(id, aimvec)

  get_user_aiming(id,tid,tbody,9999) 
  
  if( tid > 0 && tid < 33 && ( FFOn || get_user_team(id)!=get_user_team(tid) ) )
  { 
    emit_sound(tid,CHAN_BODY, "weapons/xbow_hitbod2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM) 
    
    // Determine the damage of each body part
    new damage;
    switch(tbody)
    {
      case 1: damage=h1_dam
      case 2: damage=h2_dam
      case 3: damage=h3_dam
      case 4: damage=h4_dam
      case 5: damage=h4_dam
      case 6: damage=h6_dam
      case 7: damage=h6_dam
    }

    // Deal the Damage
    sh_extra_damage(tid, id, damage)
  }  
}  

//----------------------------------------------------------------------------------------------------------
public client_disconnected(id)
{
  // stupid check but lets see
  if ( id <=0 || id>32 ) return PLUGIN_CONTINUE

  // Yeah don't want any left over residuals
  remove_task(id)
  
  return PLUGIN_CONTINUE  
}

//----------------------------------------------------------------------------------------------------------
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
