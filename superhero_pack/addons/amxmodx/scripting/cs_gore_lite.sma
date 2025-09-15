/*
*  amx_gore flags
*    a - Headshot kill blood spray
*    b - Gib on C4 kill
*    c - Gib on grenade kill
*
*/

#include <amxmodx>
#include <hamsandwich>
#include <engine>
#include <fakemeta>

#define GORE_HEADSHOT       (1<<0) // "a"
#define GORE_GIB_C4         (1<<1) // "b"
#define GORE_GIB_NADE       (1<<2) // "c"

new bool:g_regbots;
new pcvar_gore, pcvar_botquota;
new g_GibDmgType;
new g_LastDmgBits[33];

public plugin_init()
{
  register_plugin("CS Gore Lite", "0.2", "kebabstorm");
  pcvar_gore = register_cvar("amx_gore", "ab");
}

public plugin_cfg()
{
  new iFlags = get_gore_flags();

  g_GibDmgType = 0;

  if (iFlags & GORE_GIB_C4)
    g_GibDmgType = DMG_BLAST;

  if (iFlags & GORE_GIB_NADE)
    g_GibDmgType |= DMG_GRENADE;

  if (g_GibDmgType) {
    RegisterHam(Ham_Killed, "player", "Ham_Player_Killed");
    RegisterHam(Ham_TakeDamage, "player", "Ham_Player_TakeDamage");
    pcvar_botquota = get_cvar_pointer("bot_quota");
  }

  if (iFlags & GORE_HEADSHOT)
    register_event("DeathMsg", "Event_DeathMsg", "a", "3=1");

}

public client_putinserver(id)
{
  if(!g_regbots && g_GibDmgType && pcvar_botquota && is_user_bot(id))
    set_task(0.1, "register_bots", id);
}

public register_bots(id)
{
  if(g_regbots || !is_user_connected(id) || !is_user_bot(id))
    return;

  RegisterHamFromEntity(Ham_TakeDamage, id, "Ham_Player_TakeDamage");
  RegisterHamFromEntity(Ham_Killed, id, "Ham_Player_Killed");
  g_regbots = true;
}

public Ham_Player_TakeDamage(victim, inflictor, attacker, Float:damage, damagebits)
{
  if (1 <= victim <= 32)
    g_LastDmgBits[victim] = damagebits;

  return HAM_IGNORED;
}

public Ham_Player_Killed(victim, killer, shouldgib)
{
  if (1 <= victim <= 32 && g_LastDmgBits[victim] & g_GibDmgType) {
    SetHamParamInteger(3,2);
    return HAM_HANDLED;
  }
  return HAM_IGNORED;
}

public Event_DeathMsg()
{
  new victim = read_data(2);
  new Float:vecOrigin[3];

  GetHeadPosition(victim, vecOrigin);
  if (pev(victim, pev_flags) & FL_DUCKING)
    vecOrigin[2] += 10.0;
  else
    vecOrigin[2] += 35.0;

  fx_headshot(vecOrigin);
}

fx_headshot(Float:vecOrigin[3])
{
  message_begin_f(MSG_PVS, SVC_TEMPENTITY, vecOrigin);
  write_byte(TE_BLOODSTREAM);
  write_coord_f(vecOrigin[0]);
  write_coord_f(vecOrigin[1]);
  write_coord_f(vecOrigin[2]);
  write_coord(random_num(-30,30)); // x
  write_coord(random_num(-30,30)); // y
  write_coord(1000); // z
  write_byte(70); // color
  write_byte(random_num(100,200)); // speed
  message_end();
}

GetHeadPosition(const pPlayer, Float:vecOutput[3])
{
  new Float:vecOrigin[3], Float:vecViewOfs[3];
  entity_get_vector(pPlayer, EV_VEC_origin, vecOrigin);
  entity_get_vector(pPlayer, EV_VEC_view_ofs, vecViewOfs);

  vecViewOfs[0] += 7.0;

  for (new i = 0; i < 3; i++)
    vecOutput[i] = vecOrigin[i] + vecViewOfs[i];
}

public get_gore_flags()
{
  new sFlags[24];
  get_pcvar_string(pcvar_gore,sFlags,23);
  return read_flags(sFlags);
}
