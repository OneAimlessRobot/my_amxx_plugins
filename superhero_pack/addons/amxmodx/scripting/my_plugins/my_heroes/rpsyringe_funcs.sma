#include "../my_include/superheromod.inc"
#include "special_fx_inc/sh_yakui_get_set.inc"
#include "special_fx_inc/sh_gatling_special_fx.inc"
#include "special_fx_inc/sh_rpsyringe_funcs.inc"
#include "special_fx_inc/sh_gatling_funcs.inc"
#include "sh_aux_stuff/sh_aux_inc.inc"
#include "tranq_gun_inc/sh_tranq_fx.inc"
#include "chaff_grenade_inc/sh_chaff_fx.inc"


#define PLUGIN "Superhero yakui mk2 pt4"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum

new gRocketsEngaged[SH_MAXSLOTS+1]
new has_rocket[SH_MAXSLOTS+1]
new rocket_fx[MAX_ENTITIES]
public plugin_init(){
	
	
	register_plugin(PLUGIN, VERSION, AUTHOR);
	//handle when player presses attack2
	
	arrayset(rocket_fx,0,MAX_ENTITIES)
	arrayset(has_rocket,0,SH_MAXSLOTS+1)
	register_forward(FM_CmdStart, "CmdStart");
}

public plugin_natives(){
	
	
	register_native("gatling_set_rocket_fx_num","_gatling_set_rocket_fx_num",0);
	register_native("gatling_get_rocket_fx_num","_gatling_get_rocket_fx_num",0);
	register_native("gatling_set_rockets","_gatling_set_rockets",0);
	register_native("gatling_get_rockets","_gatling_get_rockets",0);
	register_native( "clear_missiles","_clear_missiles",0)
	
	
}

public _gatling_get_rocket_fx_num(iPlugin,iParams){
	
	
	new pillid= get_param(1)
	return rocket_fx[pillid]
	
}

public _gatling_set_rocket_fx_num(iPlugin,iParams){
	
	
	new pillid= get_param(1)
	new value_to_set= get_param(2)
	rocket_fx[pillid]=value_to_set
	
}

public _gatling_get_rockets(iPlugin,iParams){
	new id=get_param(1)
	return gRocketsEngaged[id]
	
}
public _gatling_set_rockets(iPlugin,iParams){
	
	new id= get_param(1)
	new value_to_set= get_param(2)
	gRocketsEngaged[id]=value_to_set;
}
public CmdStart(id, uc_handle)
{
	if ( !hasRoundStarted()||client_isnt_hitter(id)) return FMRES_IGNORED;
	
	if(sh_get_user_is_asleep(id)) return FMRES_IGNORED
	if(sh_get_user_is_chaffed(id)) return FMRES_IGNORED
	
	new button = get_uc(uc_handle, UC_Buttons);
	new ent = find_ent_by_owner(-1, YAKUI_WEAPON_NAME, id);
	new clip, ammo, weapon = get_user_weapon(id, clip, ammo);
	
	if(weapon==YAKUI_WEAPON_CLASSID){
		if(button & IN_ATTACK2)
		{
			button &= ~IN_ATTACK2;
			set_uc(uc_handle, UC_Buttons, button);
			if( !gatling_get_rockets(id) || !(is_user_alive(id))||has_rocket[id]) return FMRES_IGNORED
			if(gatling_get_num_rockets(id) == 0)
			{
				if(!is_user_bot(id)){
					client_print(id, print_center, "You are out of rockets")
				}
				return FMRES_IGNORED
			}
			make_rocket(id,floatround(ROCKET_SPEED))
			
		}
		else
		{
			button &= ~IN_ATTACK2;
			set_uc(uc_handle, UC_Buttons, button);
			
			set_pev(id, pev_weaponanim, 0);
			set_pdata_float(id, 83, 0.5, 4);
			if(ent){
				set_pdata_float(ent, 48, 0.5+ROCKET_SHOOT_PERIOD, 4);
			}
			has_rocket[id] = 0
		}
	}
	
	return FMRES_IGNORED;
}
public bool:client_isnt_hitter(id){
	
	if ( !client_hittable(id)){
		
		return true
	}
	if(!gatling_get_has_yakui(id)){
		
		
		return true;
	}
	return false
	
}


public vexd_pfntouch(pToucher, pTouched) {


if (pev_valid(pToucher)!=2 ){
	return
}
new szClassName[32]
Entvars_Get_String(pToucher, EV_SZ_classname, szClassName, 31)

if(equal(szClassName, ROCKET_CLASSNAME)) {
	
	
	new Float:fl_vExplodeAt[3]
	Entvars_Get_Vector(pToucher, EV_VEC_origin, fl_vExplodeAt)
	new vExplodeAt[3]
	vExplodeAt[0] = floatround(fl_vExplodeAt[0])
	vExplodeAt[1] = floatround(fl_vExplodeAt[1])
	vExplodeAt[2] = floatround(fl_vExplodeAt[2])
	new id = Entvars_Get_Edict(pToucher, EV_ENT_owner)
	new origin[3],dist,i
	
	explode_fx(vExplodeAt,floatround(ROCKET_RADIUS))
	for ( i = 1; i <= SH_MAXSLOTS; i++) {
		
		if( !client_hittable(i) ) continue
		get_user_origin(i,origin)
		dist = get_distance(origin,vExplodeAt)
		if (dist <= ROCKET_RADIUS) {
			
			if((sh_get_user_effect(i)<KILL)||(sh_get_user_effect(i)>BATH)){
				make_effect_direct(i,id,rocket_fx[pToucher],gatling_get_hero_id())
			}
			
		}
	}
	
	
	emit_sound(pToucher, CHAN_WEAPON, ROCKET_EXPLODE_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	new color[4]
	sh_get_pill_color(rocket_fx[pToucher],id,color)
	make_shockwave(vExplodeAt,ROCKET_RADIUS,color)
	
	if ( is_valid_ent(pTouched) ) {
		new szClassName2[32]
		Entvars_Get_String(pTouched, EV_SZ_classname, szClassName2, 31)
		
		if(equal(szClassName2, ROCKET_CLASSNAME)) {
			emit_sound(pToucher, CHAN_WEAPON, ROCKET_EXPLODE_SFX, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			remove_missile(pTouched)
		}
	}
	remove_missile(pToucher)	
}
}
//----------------------------------------------------------------------------------------------
//make_rocket(userindex,commandtype,missilespeed,antimissleid)
make_rocket(id,iarg1)
{

new Float:vOrigin[3]
new Float:vAngles[3]
Entvars_Get_Vector(id, EV_VEC_origin, vOrigin)
Entvars_Get_Vector(id, EV_VEC_v_angle, vAngles)
new notFloat_vOrigin[3]
notFloat_vOrigin[0] = floatround(vOrigin[0])
notFloat_vOrigin[1] = floatround(vOrigin[1])
notFloat_vOrigin[2]  =floatround(floatadd( vOrigin[2] , 50.0))


new NewEnt
NewEnt = CreateEntity("info_target")
if(NewEnt == 0) {
if(!is_user_bot(id)){
	client_print(id,print_chat,"[SH](Yakui the Maid Mk2): Rocket fail!")
}
return PLUGIN_HANDLED
}

Entvars_Set_String(NewEnt, EV_SZ_classname, ROCKET_CLASSNAME)
ENT_SetModel(NewEnt, "models/rpgrocket.mdl")

new Float:fl_vecminsx[3] = {-1.0, -1.0, -1.0}
new Float:fl_vecmaxsx[3] = {1.0, 1.0, 1.0}

Entvars_Set_Vector(NewEnt, EV_VEC_mins,fl_vecminsx)
Entvars_Set_Vector(NewEnt, EV_VEC_maxs,fl_vecmaxsx)

ENT_SetOrigin(NewEnt, vOrigin)
Entvars_Set_Vector(NewEnt, EV_VEC_angles, vAngles)
entity_set_int(NewEnt, EV_INT_effects, 64)
Entvars_Set_Int(NewEnt, EV_INT_solid, 2)

Entvars_Set_Int(NewEnt, EV_INT_movetype, 10)


Entvars_Set_Edict(NewEnt, EV_ENT_owner, id)

new Float:fl_iNewVelocity[3]
new iNewVelocity[3]
VelocityByAim(id, iarg1, fl_iNewVelocity)
Entvars_Set_Vector(NewEnt, EV_VEC_velocity, fl_iNewVelocity)
iNewVelocity[0] = floatround(fl_iNewVelocity[0])
iNewVelocity[1] = floatround(fl_iNewVelocity[1])
iNewVelocity[2] = floatround(fl_iNewVelocity[2])

emit_sound(NewEnt, CHAN_WEAPON, "weapons/rocketfire1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
emit_sound(NewEnt, CHAN_VOICE, "weapons/rocket1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
has_rocket[id] = NewEnt

gatling_dec_num_rockets(id)

new fx_num=sh_gen_effect()
rocket_fx[NewEnt]=fx_num
new color[4]
sh_get_pill_color(fx_num,id,color)
trail_custom(NewEnt,color,30,20)
Entvars_Set_Float(NewEnt, EV_FL_gravity, 0.50)
return PLUGIN_HANDLED
}
//----------------------------------------------------------------------------------------------
public client_disconnected(id)
{
has_rocket[id] = 0
}
//----------------------------------------------------------------------------------------------
public rocket_reload(id)
{
id-=ROCKET_RELOAD_TASKID
has_rocket[id] = 0
}
//----------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------
remove_missile(missile){
if(!pev_valid(missile)){
	
	return PLUGIN_CONTINUE
}
new Float:fl_origin[3]
Entvars_Get_Vector(missile, EV_VEC_origin, fl_origin)

message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_IMPLOSION)
write_coord(floatround(fl_origin[0]))
write_coord(floatround(fl_origin[1]))
write_coord(floatround(fl_origin[2]))
write_byte (200)
write_byte (40)
write_byte (45)
message_end()

emit_sound(missile, CHAN_WEAPON, "ambience/particle_suck2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
emit_sound(missile, CHAN_VOICE, "ambience/particle_suck2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

RemoveEntity(missile)
return PLUGIN_CONTINUE
}

public _clear_missiles(){


for (new i=1; i <=SH_MAXSLOTS; i++) {
if(has_rocket[i] > 0){
	if(pev_valid(has_rocket[i])){
		remove_missile(has_rocket[i])
	}
}

}
}
public plugin_precache()
{
precache_sound(ROCKET_EXPLODE_SFX)
precache_sound("ambience/particle_suck2.wav")
precache_explosion_fx()

precache_model(GATLING_P_MODEL)
precache_model(GATLING_V_MODEL)

}
