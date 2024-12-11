#if defined sh_graciete_rocket_funcs
  #endinput
#endif
#define sh_graciete_rocket_funcs


#define FADE_OUT	(1<<1)
#define FADE_HOLD (1<<2)



#define JP_CLASSNAME "jp_class"
#define GROUND_THRESHOLD 20.0
#define TOUCHING_GROUND (1<<9)
// GLOBAL VARIABLES
#define GRACIETE_TRAIL_TASKID 19272
#define GRACIETE_COOLDOWN_TASKID 22232
#define GRACIETE_LOAD_TASKID 12822

#define GRACIETE_CHARGE_TASKID 28762
#define GRACIETE_CHARGE_PERIOD 0.1
#define GRACIETE_CHARGE_TIMES floatround(floatdiv(power_land_charge_time,GRACIETE_CHARGE_PERIOD))

#define GRACIETE_MAX_DAMAGE jet_max_power

#define GRACIETE_CHARGE_RATE 100.0

#define jp_jump "shmod/graciete/jp/rocketfire1.wav"
#define jp_fly "shmod/graciete/jp/rocket1.wav"
#define crush_stunned "shmod/Teliko/chaff/chaff_blow.wav"
#define jp_mdl "models/shmod/graciete/jp/rpgrocket.mdl"
/*
public Float:distance_to_ground( const id )
{
    static Float:flOrigin[ 3 ], Float:flEnd[ 3 ], tr;
    pev( id, pev_origin, flOrigin );
    
    xs_vec_sub( flOrigin, Float:{ 0.0, 0.0, 9999.0 }, flEnd );
    
    engfunc( EngFunc_TraceLine, flOrigin, flEnd, IGNORE_MONSTERS, 0, tr );
    
    get_tr2( tr, TR_vecEndPos, flEnd );
    
    if( pev( id, pev_button ) & IN_DUCK )
        flEnd[ 2 ] += 36.0;
    else
        flEnd[ 2 ] += 36.0;
    
    new Float:result=vector_distance( flOrigin, flEnd );
    client_print(id,print_center,"Tua distancia ao chao e: %0.2f",result);
    return result
}*/

native clear_jps()

native reset_graciete_user(id)
native jet_get_user_jet_cooldown(id)
native jet_get_user_power_landing(id)
native jet_uncharge_user(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
