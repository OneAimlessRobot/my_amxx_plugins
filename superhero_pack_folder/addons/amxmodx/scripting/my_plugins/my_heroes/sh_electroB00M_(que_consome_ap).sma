#define I_WANT_CONSTANTS
#define I_WANT_CUSTOM_COLORS
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt16.inc"
#include "../my_include/my_author_header.inc"
#include "sh_aux_stuff/sh_aux_stuff_natives_pt4.inc"
#include "shock_fx_inc/shock_fx.inc"


// VARIABLES

new generic_dmg_shock
new gHeroName[]="ElectroB00M"
new gSpriteLightning
new const gTeslaCoilRevvingSound[] = "ambience/techamb2.wav"
new const gTeslaCoilOff[] = "weapons/egon_off1.wav"
new bool:g_teslacoilRunning[SH_MAXSLOTS+1]
new bool:gRechargeAllowed[SH_MAXSLOTS+1]
new pcvarArmor, pCvarPeriod, pCvarPowerCost, pcvarTimeToStun, pcvarElectroB00MStunSpeed, pCvarElectroB00MRadius,pCvarElectroB00MDamage
new gPowerCost 
//----------------------------------------------------------------------------------------------
public plugin_init()
{
	// Plugin Info
	register_plugin("SUPERHERO ElectroB00M","2.0",AUTHOR)
	
	// DEFAULT THE CVARS
	new pcvarLevel = create_cvar("ElectroB00M_level", "20" )
	pCvarPeriod = create_cvar("ElectroB00M_period", "0.1")
	pcvarArmor = create_cvar("ElectroB00M_armor", "100")
	pcvarTimeToStun = create_cvar("ElectroB00M_stuntime", "10")
	pcvarElectroB00MStunSpeed = create_cvar("ElectroB00M_stunspeed", "100")
	pCvarPowerCost = create_cvar("ElectroB00M_powercost", "5")
	pCvarElectroB00MRadius = create_cvar("ElectroB00M_radius", "200" )
	pCvarElectroB00MDamage = create_cvar("ElectroB00M_teslacoildamage", "30" )
	
	// FIRE THE EVENT TO CREATE THIS SUPERHERO!
	gHeroID = sh_create_hero(gHeroName, pcvarLevel)
	sh_set_hero_bind(gHeroID)
	sh_set_hero_info(gHeroID, "Humble engineer", "Silly Electrician! Unleash your MANLY arcs on EVERYONE!")
	sh_set_hero_hpap(gHeroID, _, pcvarArmor)
}
//----------------------------------------------------------------------------------------------
public plugin_precache()
{
	gSpriteLightning = engfunc(EngFunc_PrecacheModel,"sprites/lgtning.spr")
	engfunc(EngFunc_PrecacheSound,"weapons/electro5.wav")
	engfunc(EngFunc_PrecacheSound,"weapons/xbow_hitbod2.wav")
	engfunc(EngFunc_PrecacheSound,gTeslaCoilRevvingSound)
	engfunc(EngFunc_PrecacheSound,gTeslaCoilOff)
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
generic_dmg_shock = get_weapon_id_for_generic_dmg_source(SH_NEW_DMG_SHOCK)

set_task(get_pcvar_float(pCvarPeriod), "ElectroB00M_loop", _, _, _, "b")
}
//----------------------------------------------------------------------------------------------   
public ElectroB00M_loop(task_id)
{
	if ( !sh_is_active() || sh_is_freezetime() ) return
	
	static the_players_attacked[SH_MAXSLOTS], pnum_attacked, x_attacked,
			the_players[SH_MAXSLOTS], pnum, id
	get_players(the_players, pnum, "ah")


	for(new i=0;i< pnum;i++){

		id = the_players[i]


		if ( !gRechargeAllowed[id] ||!sh_get_user_has_hero(id,gHeroID) ) continue

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
				emit_sound(id, CHAN_WEAPON,gTeslaCoilRevvingSound, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)

				
			}
			
			case true: {
				if ( gPowerCost > 0 )
				{
					if ( userArmor < gPowerCost ) {
						sh_sound_deny(id)
						g_teslacoilRunning[id] = false
						
						sh_assign_id_bit(id, SH_ELECTROBOOM_TESLA_COIL_RUNNING, false)
						emit_sound(id, CHAN_WEAPON,gTeslaCoilRevvingSound, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
						emit_sound(id, CHAN_WEAPON,gTeslaCoilOff, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
						
						if(!is_user_bot(id)){
							client_print(id, print_center, "[SH]ElectroB00M :You ran out of Power")
						}
						continue
					}
					cs_set_user_armor(id, userArmor - gPowerCost, armorType)
				}

				new Float:TimeToStun = get_pcvar_float(pcvarTimeToStun)
				new Float:ElectroB00MStunSpeed = get_pcvar_float(pcvarElectroB00MStunSpeed)
				new ElectroB00MRadius = get_pcvar_num(pCvarElectroB00MRadius)

				new ElectroB00MDamage=get_pcvar_num(pCvarElectroB00MDamage)
				pnum_attacked=find_sphere_class(id,"player",float(ElectroB00MRadius),the_players_attacked,sizeof(the_players_attacked))
				for ( new j = 0; j < pnum_attacked; j++) {
					
					x_attacked = the_players_attacked[j]

					if ( (is_user_alive(x_attacked) && get_user_team(id)!=get_user_team(x_attacked)) && x_attacked!=id )
					{
						
						ElectroB00M_instant(x_attacked, id, (ElectroB00MDamage/2)+1)
						sh_set_stun(x_attacked, TimeToStun, ElectroB00MStunSpeed)
						sh_shock_user(x_attacked,id,TimeToStun, _, float((ElectroB00MDamage/2)+1),float(ElectroB00MRadius)/2, false)
					}
				}
				
				emit_sound(id, CHAN_WEAPON, gTeslaCoilRevvingSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			}
		}
	}
}
//----------------------------------------------------------------------------------------------
public sh_hero_key(id, heroID, sh_key_mode:key)
{
if ( gHeroID != heroID ||!sh_get_user_has_hero(id,gHeroID) ) return

switch(key)
{
	case SH_KEYDOWN: {
		if ( sh_is_freezetime() || !is_user_alive(id) ) return
		
		g_teslacoilRunning[id] = true
		
		sh_assign_id_bit(id, SH_ELECTROBOOM_TESLA_COIL_RUNNING, true)
		if(!is_user_bot(id)){
			client_print(id, print_center, "[SH]ElectroB00M :Tesla coil on")
		}
		set_render_with_color_const(id,ELELCTROBOOM_VIOLET,1,255,100,1,0,get_pcvar_float(pCvarPeriod),_,_,kRenderNormal,PRIO_RENDER_INFORMATIVE)
	}
	
	case SH_KEYUP: {
		
		if ( !g_teslacoilRunning[id] ) return
		
		g_teslacoilRunning[id] = false
		
		sh_assign_id_bit(id, SH_ELECTROBOOM_TESLA_COIL_RUNNING, false)
		emit_sound(id, CHAN_WEAPON,gTeslaCoilOff, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		if(!is_user_bot(id)){
			client_print(id, print_center, "[SH]ElectroB00M :Tesla coil off")
		}
		remove_glow_user(id,PRIO_RENDER_INFORMATIVE,_,kRenderNormal)
	}
}
}
//----------------------------------------------------------------------------------------------
public sh_client_death(victim)
{
g_teslacoilRunning[victim] = false

sh_assign_id_bit(victim, SH_ELECTROBOOM_TESLA_COIL_RUNNING, false)

emit_sound(victim, CHAN_WEAPON, gTeslaCoilRevvingSound, VOL_NORM, ATTN_NORM, SND_STOP, PITCH_NORM)
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
public ElectroB00M_instant(x, id, damage)
{
lightning_effect(id, x)
emit_sound(x, CHAN_ITEM, "weapons/xbow_hitbod2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
sh_extra_damage( x, id, damage,
						_,_,_,_,_,
						SH_NEW_DMG_SHOCK,
						generic_dmg_shock)
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

sh_assign_id_bit(id, SH_ELECTROBOOM_TESLA_COIL_RUNNING, false)

gRechargeAllowed[id] = false

}
//----------------------------------------------------------------------------------------------
public client_connected(id)
{
// stupid check but lets see
if ( id < 1 || id > sh_maxplayers() ) return

g_teslacoilRunning[id] = false

sh_assign_id_bit(id, SH_ELECTROBOOM_TESLA_COIL_RUNNING, false)

gRechargeAllowed[id] = false

}
//
