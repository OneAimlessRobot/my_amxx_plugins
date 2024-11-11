#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

public plugin_init()
{
    RegisterHam(Ham_TraceAttack, "worldspawn", "fw_HamTraceAttackPost", 1)
}

public fw_HamTraceAttackPost(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType)
{
    if(get_user_weapon(iAttacker) == CSW_KNIFE)
    {
        new Float:vecEnd[3]
        get_tr2(ptr, TR_vecEndPos, vecEnd)
    
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
        write_byte(TE_SPARKS);
        engfunc(EngFunc_WriteCoord, vecEnd[0])
        engfunc(EngFunc_WriteCoord, vecEnd[1])
        engfunc(EngFunc_WriteCoord, vecEnd[2])
        message_end();
    }
    return HAM_IGNORED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
