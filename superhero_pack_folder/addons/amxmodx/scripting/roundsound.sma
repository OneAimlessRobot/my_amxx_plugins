#include <amxmodx>

public plugin_init() 
{ 
  register_plugin("RoundSound","1.0","PaintLancer")
  register_event("SendAudio", "t_win", "a", "2&%!MRAD_terwin")
  register_event("SendAudio", "ct_win", "a", "2&%!MRAD_ctwin")  
}

public t_win()
{
  new rand = random_num(1,16)

  client_cmd(0,"stopsound")

  switch(rand)
  {
    case 1: client_cmd(0,"spk misc/roundsounds/'Akui The Maid - my cats like rock - 02 sunflower'")
  }

  return PLUGIN_HANDLED
}

public ct_win()
{
  new rand = random_num(1,16)

  client_cmd(0,"stopsound")

  switch(rand)
  {
    case 1: client_cmd(0,"spk misc/roundsounds/'Akui The Maid - my cats like rock - 02 sunflower'")
  }

  return PLUGIN_HANDLED
}

public plugin_precache() 
{
  precache_sound("misc/roundsounds/'Akui The Maid - my cats like rock - 02 sunflower'.wav")

  return PLUGIN_CONTINUE
}
