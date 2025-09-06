#include "../my_include/superheromod.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "lena_inc/sh_lena_l96_include.inc"
#include "lena_inc/sh_lena_general_include.inc"

#define PLUGIN_AUTHOR "MilkChanTheGOAT"
#define PLUGIN_VER "1.0"
#define PLUGIN_NAME "SUPERHERO Lena de Verias: L96 weapon_thingie"


new bool:gIsReloadingLenaL96[SH_MAXSLOTS+1]
new bool:bullet_loaded[SH_MAXSLOTS+1]
new Float:bullet_launch_pos[MAX_ENTITIES][3];
new bool:bullet_hurts[MAX_ENTITIES];
new m_trail
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//handle when player presses attack2
	for(new i=0;i<MAX_ENTITIES;i++){
		
		arrayset(bullet_launch_pos[i],0.0,3);
		
	}
	arrayset(bullet_loaded,true,SH_MAXSLOTS+1)
	arrayset(bullet_hurts,false,SH_MAXSLOTS+1)
	register_forward(FM_CmdStart, "CmdStart");
	RegisterHam(Ham_Item_Deploy, STRN_ELITE, "fw_ItemDeployPre")
	RegisterHam(Ham_Weapon_PrimaryAttack, STRN_ELITE, "fw_WeaponPrimaryAttackPre")
	RegisterHam(Ham_Weapon_Reload,STRN_ELITE, "fw_WeaponReloadPre")
	
}

public plugin_natives(){
	
	register_native( "lena_l96_clear_bullets","_lena_l96_clear_bullets",0)
	
	
}
public CmdStart(id, uc_handle)
{
	if ( !is_user_alive(id)||!tranq_get_has_erica(id)||!hasRoundStarted()||client_isnt_hitter(id)) return FMRES_IGNORED;
	
	
	new button = get_uc(uc_handle, UC_Buttons);
	new ent = find_ent_by_owner(-1, "weapon_elite", id);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if(weapon==CSW_ELITE){
		if(button & IN_ATTACK)
		{
			button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, button);
			if(!(is_user_alive(id))||!bullet_loaded[id]) return FMRES_IGNORED
			if(tranq_get_num_bullets(id) == 0)
			{
				client_print(id, print_center, "You are out of bullets")
				return FMRES_IGNORED
			}
			launch_bullet(id)
			bullet_loaded[id]=false
			
		}
		else
		{
			button &= ~IN_ATTACK;
			set_uc(uc_handle, UC_Buttons, button);
			
			set_pev(id, pev_weaponanim, 0);
			set_pdata_float(id, 83, 0.5, 4);
			if(ent){
				set_pdata_float(ent, 48, 0.5+DART_SHOOT_PERIOD, 4);
			}
			bullet_loaded[id]=true
		}
	}
	if(ent)
	{
		cs_set_weapon_ammo(ent, -1);
		cs_set_user_bpammo(id, CSW_ELITE,tranq_get_num_bullets(id));
	}
	
	return FMRES_IGNORED;
}

launch_bullet(id)
{

entity_set_int(id, EV_INT_weaponanim, 3)

new Float: Origin[3], Float: Velocity[3], Float: vAngle[3], Ent

entity_get_vector(id, EV_VEC_origin , Origin)
entity_get_vector(id, EV_VEC_v_angle, vAngle)


Ent = create_entity("info_target")

if (!Ent) return PLUGIN_HANDLED

entity_set_string(Ent, EV_SZ_classname, DART_CLASSNAME)
entity_set_model(Ent, "models/shell.mdl")

new Float:MinBox[3] = {-1.0, -1.0, -1.0}
new Float:MaxBox[3] = {1.0, 1.0, 1.0}
entity_set_vector(Ent, EV_VEC_mins, MinBox)
entity_set_vector(Ent, EV_VEC_maxs, MaxBox)

entity_set_origin(Ent, Origin)
entity_set_vector(Ent, EV_VEC_angles, vAngle)

entity_set_int(Ent, EV_INT_effects, 2)
entity_set_int(Ent, EV_INT_solid, 2)
entity_set_int(Ent, EV_INT_movetype, 5)
entity_set_edict(Ent, EV_ENT_owner, id)

VelocityByAim(id, floatround(DART_SPEED) , Velocity)
entity_set_vector(Ent, EV_VEC_velocity ,Velocity)

tranq_dec_num_bullets(id)

if(tranq_get_is_max_points(id)){

	bullet_hurts[Ent]=true;
	bullet_launch_pos[Ent][0]=Origin[0]
	bullet_launch_pos[Ent][1]=Origin[1]
	bullet_launch_pos[Ent][2]=Origin[2]

}
new parm[1]

parm[0] = Ent
emit_sound(id, CHAN_WEAPON, SILENT_TRANQS_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

set_task(0.01, "bullettrail",id,parm,1)

return PLUGIN_CONTINUE
}

public bullet_reload(parm[])
{

bullet_loaded[parm[0]] = true
}
public bullettrail(parm[])
{
new pid = parm[0]
if (pid)
{
message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
write_byte( TE_BEAMFOLLOW )
write_short(pid) // entity
write_short(m_trail)  // model
write_byte( 10 )       // life
write_byte( 5 )
write_byte(LineColorsWithAlpha[WHITE][0])			// r, g, b
write_byte(LineColorsWithAlpha[WHITE][1])		// r, g, b
write_byte(LineColorsWithAlpha[WHITE][2])			// r, g, b
write_byte(LineColorsWithAlpha[WHITE][3]) // brightness
message_end() // move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)
}
}

public _clear_bullets(iPlugin,iParams){

new grenada = find_ent_by_class(-1, LENA_BULLET_CLASSNAME)
new grenada = find_ent_by_class(-1, LENA_BULLET:CLASSNAME)
while(grenada) {
	remove_entity(grenada)
	arrayset(bullet_launch_pos[grenada],0.0,3);
	bullet_hurts[grenada]=false;
	grenada = find_ent_by_class(grenada, LENA_BULLET_CLASSNAME)
}
}


public vexd_pfntouch(pToucher, pTouched)
{

if (pToucher <= 0) return
if (!is_valid_ent(pToucher)) return

new szClassName[32]
entity_get_string(pToucher, EV_SZ_classname, szClassName, 31)
if(equal(szClassName, DART_CLASSNAME))
{
new oid = entity_get_edict(pToucher, EV_ENT_owner)
//new Float:origin[3],dist

if((pev(pTouched,pev_solid)==SOLID_SLIDEBOX)){
	if(client_hittable(pTouched))
	{
		if(bullet_hurts[pToucher]){
			new Float:vic_origin[3];
			entity_get_vector(pTouched,EV_VEC_origin,vic_origin);
			new Float:distance=vector_distance(vic_origin,bullet_launch_pos[pToucher]);
			new Float:falloff_coeff= floatmin(1.0,distance/DART_DAMAGE_FALLOFF_DIST);
			sh_extra_damage(pTouched,oid,floatround(DART_DAMAGE-35.0*falloff_coeff),"Rage tranq");
			
		
		}
		sh_sleep_user(pTouched,oid,tranq_get_hero_id())
		
	}
	remove_entity(pToucher)
	arrayset(bullet_launch_pos[pToucher],0.0,3);
	bullet_hurts[pToucher]=false;
}
//entity_get_vector(pTouched, EV_VEC_ORIGIN, origin)
if(pev(pTouched,pev_solid)==SOLID_BSP){
	
		emit_sound(pToucher, CHAN_WEAPON, EFFECT_SHOT_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		remove_entity(pToucher)	
		arrayset(bullet_launch_pos[pToucher],0.0,3);
		bullet_hurts[pToucher]=false;

		}

	}
}
public remove_bullet(id_bullet){
	id_bullet-=DART_REM_TASKID

	remove_entity(id_bullet)


}