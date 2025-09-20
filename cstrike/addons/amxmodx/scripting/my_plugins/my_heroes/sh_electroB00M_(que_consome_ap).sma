
#include "../my_include/superheromod.inc"

/* CVARS - copy and paste to shconfig.cfg

//ElectroB00M
ElectroB00M_level 20
ElectroB00M_armor 400		//How much armor does ElectroB00M start with
ElectroB00M_period 0.1		//How often (seconds) to run the loop
ElectroB00M_stunspeed 100        //How fast can a target move when hit by a spark
ElectroB00M_teslacoildamage 30		//Damage per spark
ElectroB00M_radius 200		//Danger radius around a switched on player
ElectroB00M_powercost 5		//How much armor does it cost per spark, set 0 for free energy device
ElectroB00M_stuntime 10 //For how long will a hit player stay stunned

*/

// VARIABLES
new gHeroID
new gHeroName[]="ElectroB00M"
new gSpriteLightning
new const gTeslaCoilRevvingSound[] = "ambience/voltage.wav"
new const gTeslaCoilOff[] = "weapons/egon_off1.wav"
new bool:g_hasElectroBoomPowers[SH_MAXSLOTS+1]
new bool:g_teslacoilRunning[SH_MAXSLOTS+1]
new bool:gRechargeAllowed[SH_MAXSLOTS+1]
new pcvarArmor, pCvarPeriod, pCvarPowerCost, pcvarTimeToStun, pcvarElectroB00MStunSpeed, pCvarElectroB00MRadius,pCvarElectroB00MDamage
new gPowerCost 
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO ElectroB00M","2.0","TastyMedula")
	
	// DEFAULT THE CVARS
	new pcvarLevel = register_cvar("ElectroB00M_level", "20" )
	pCvarPeriod = register_cvar("ElectroB00M_period", "0.1")
	pcvarArmor = register_cvar("ElectroB00M_armor", "100")
	pcvarTimeToStun = register_cvar("ElectroB00M_stuntime", "10")
	pcvarElectroB00MStunSpeed = register_cvar("ElectroB00M_stunspeed", "100")
	pCvarPowerCost = register_cvar("ElectroB00M_powercost", "5")
	pCvarElectroB00MRadius = register_cvar("ElectroB00M_radius", "200" )
	pCvarElectroB00MDamage = register_cvar("ElectroB00M_teslacoildamage", "30" )
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_bind(gHeroID)
	sh_set_hero_info(gHeroID, "Humble engineer", "Silly Electrician! Unleash your MANLY arcs on EVERYONE!")
	sh_set_hero_hpap(gHeroID, _, pcvarArmor)
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	gSpriteLightning = precache_model("sprites/lgtning.spr")
	precache_sound("weapons/electro5.wav")
	precache_sound("weapons/xbow_hitbod2.wav")
	precache_sound(gTeslaCoilRevvingSound)
	precache_sound(gTeslaCoilOff)
}
//----------------------------------------------------------------------------------------------
public sh_hero_init(id, heroID, mode)
{
	if ( gHeroID != heroID ) return
	
	remove_task(id)
	
	if ( mode == SH_HERO_ADD ) {
		set_task(get_pcvar_float(pCvarPeriod), "ElectroB00M_loop", id, _, _, "b")
		g_hasElectroBoomPowers[id]=true
	}
	else{
		g_hasElectroBoomPowers[id]=false
	
	}
	sh_debug_message(id, 1, "%s %s", gHeroName, mode ? "ADDED" : "DROPPED")
}
//----------------------------------------------------------------------------------------------
public plugin_cfg()
{
	loadCVARS()
}
//----------------------------------------------------------------------------------------------
loadCVARS()
{
gPowerCost = get_pcvar_num(pCvarPowerCost)
}
//----------------------------------------------------------------------------------------------   
public ElectroB00M_loop(id)
{

if ( !sh_is_active() || !is_user_alive(id) || !gRechargeAllowed[id] ||!g_hasElectroBoomPowers[id]) return
static CsArmorType:armorType
static userArmor
userArmor = cs_get_user_armor(id, armorType)
if ( userArmor == 0 ) armorType = CS_ARMOR_VESTHELM

switch(g_teslacoilRunning[id]) {
	case false: {
		// Recharge armor even if armor is not used for JP fuel
		if ( userArmor < sh_get_max_ap(id) ) {
			cs_set_user_armor(id, userArmor + 1, armorType)
		}
	}
	
	case true: {
		if ( gPowerCost > 0 )
		{
			if ( userArmor < gPowerCost ) {
				sh_sound_deny(id)
				g_teslacoilRunning[id] = false
				
				set_user_info(id, "TC", "0")
				
				emit_sound(id, CHAN_WEAPON,gTeslaCoilOff, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				client_print(id, print_center, "[SH]ElectroB00M :You ran out of Power")
				return
			}
			cs_set_user_armor(id, userArmor - gPowerCost, armorType)
		}
		new uOrigin[3]
		new vOrigin[3]
		new dBetween
		new Float:TimeToStun = get_pcvar_float(pcvarTimeToStun)
		new Float:ElectroB00MStunSpeed = get_pcvar_float(pcvarElectroB00MStunSpeed)
		new ElectroB00MRadius = get_pcvar_num(pCvarElectroB00MRadius)
		
		get_user_origin(id,uOrigin)
		for ( new x=1; x<=SH_MAXSLOTS; x++) 
		{
			if ( (is_user_alive(x) && get_user_team(id)!=get_user_team(x)) && x!=id )
			{
				get_user_origin(x,vOrigin)
				dBetween = get_distance(uOrigin, vOrigin )
				if ( dBetween < ElectroB00MRadius )
				{
					ElectroB00M_instant(x, id)
					sh_set_stun(x, TimeToStun, ElectroB00MStunSpeed)
				}
			}
		}
		emit_sound(id, CHAN_WEAPON, gTeslaCoilRevvingSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
}
}
//----------------------------------------------------------------------------------------------
public sh_hero_key(id, gHeroID, key)
{
if ( gHeroID != gHeroID ||!g_hasElectroBoomPowers[id]) return

switch(key)
{
	case SH_KEYDOWN: {
		if ( sh_is_freezetime() || !is_user_alive(id) ) return
		
		g_teslacoilRunning[id] = true
		
		// This needs to change to a forward check
		set_user_info(id, "TC", "1")
		client_print(id, print_center, "[SH]ElectroB00M :Tesla coil on")
		set_user_rendering(id,kRenderFxGlowShell, 184, 105, 255, kRenderTransAlpha,255)
	}
	
	case SH_KEYUP: {
		
		if ( !g_teslacoilRunning[id] ) return
		
		g_teslacoilRunning[id] = false
		
		// This needs to change to a forward check
		set_user_info(id, "TC", "0")
		emit_sound(id, CHAN_WEAPON,gTeslaCoilOff, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		client_print(id, print_center, "[SH]ElectroB00M :Tesla coil off")
		
		set_user_rendering(id,kRenderFxGlowShell, 0, 0, 0, _,_)
	}
}
}
//----------------------------------------------------------------------------------------------
public sh_client_death(victim)
{
g_teslacoilRunning[victim] = false

// This needs to change to a forward check
set_user_info(victim, "TC", "0")

gRechargeAllowed[victim] = false
}
//----------------------------------------------------------------------------------------------
public lightning_effect(id, x)
{
new origin[3]

emit_sound(id, CHAN_ITEM, "weapons/electro5.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

get_user_origin(id, origin, 1)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(27)
write_coord(origin[0])	//pos
write_coord(origin[1])
write_coord(origin[2])
write_byte(15)
write_byte(100)			// r, g, b
write_byte(100)		// r, g, b
write_byte(255)			// r, g, b
write_byte(3)			// life
write_byte(1)			// decay
message_end()

message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
write_byte( 8 )
write_short(id)				// start entity
write_short(x)				// entity
write_short(gSpriteLightning)		// model
write_byte( 0 ) 				// starting frame
write_byte( 30 )  			// frame rate
write_byte( 1)  			// life
write_byte( 23 )  		// line width
write_byte( 45 )  			// noise amplitude
write_byte( 128 )				// r, g, b
write_byte( 128 )				// r, g, b
write_byte( 255 )				// r, g, b
write_byte( 255 )				// brightness
write_byte( 8 )				// scroll speed
message_end()
}
//
public ElectroB00M_instant(x, id)
{
new ElectroB00MDamage=get_pcvar_num(pCvarElectroB00MDamage)
lightning_effect(id, x)
emit_sound(x, CHAN_ITEM, "weapons/xbow_hitbod2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
shExtraDamage( x, id, ElectroB00MDamage, "ElectroB00M 's Mad Tesla Coil" )
return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
public sh_client_spawn(id)
{
gRechargeAllowed[id] = false

set_task(1.0, "spawn_delay", id)
}
//----------------------------------------------------------------------------------------------
public spawn_delay(id)
{
//Delay is to allow time for sh armor power to set.
if ( !is_user_alive(id) ) return

gRechargeAllowed[id] = true
}
//----------------------------------------------------------------------------------------------
public client_disconnected(id)
{
// stupid check but lets see
if ( id < 1 || id > sh_maxplayers() ) return

g_teslacoilRunning[id] = false

// This needs to change to a forward check
set_user_info(id, "TC", "0")

gRechargeAllowed[id] = false

// Yeah don't want any left over residuals
remove_task(id)
}
//----------------------------------------------------------------------------------------------
public client_connected(id)
{
// stupid check but lets see
if ( id < 1 || id > sh_maxplayers() ) return

g_teslacoilRunning[id] = false

// This needs to change to a forward check
set_user_info(id, "TC", "0")

g_hasElectroBoomPowers[id]=false
gRechargeAllowed[id] = false

// Yeah don't want any left over residuals
remove_task(id)
}
//
