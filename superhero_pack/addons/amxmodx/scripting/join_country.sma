#include <amxmodx>
#include <geoip>
#include <colorchat>
 
public plugin_init() register_plugin("Join Country","1.0","<VeCo>")
 
public client_putinserver(id)
{
static sz_name[32]
get_user_name(id,sz_name,charsmax(sz_name))
 
static sz_ip[16],sz_country[20]
get_user_ip(id,sz_ip,charsmax(sz_ip),1)
geoip_country(sz_ip,sz_country,charsmax(sz_country))
 
ColorChat(0,GREY,"^x01Player^x03 %s^x01 connected from^x04 %s^x01",sz_name,sz_country)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
