#include <amxmodx>
#include <amxmisc>
#include <ffac_sys>

#define PLUGIN "FFAC location"
#define VERSION "0.2"
#define AUTHOR "hackziner"



public plugin_init() 
{
 
	register_plugin(PLUGIN, VERSION, AUTHOR)
	ffac_register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("ffac_location",VERSION,FCVAR_SERVER)
}

new Float:latitude[33]
new Float:longitude[33]

public ffac_client_auth(id){
	new city[16]
	new country[16]
	new pname[32]
	new temp[8]
	new idi
	ffac_get_player_latitude(id,temp)
	latitude[id] = str_to_float(temp)
	ffac_get_player_longitude(id,temp)
	longitude[id] = str_to_float(temp)
	get_user_name(id,pname,32)
	ffac_get_player_city(id,city)
	ffac_get_player_country(id,country)
	client_print(0,print_chat,"FFAC : %s from %s, %s is in the game",pname,city,country)
	
	
	new maxplayers
	maxplayers = get_maxplayers()
	for(idi = 1 ; idi <= maxplayers ; idi++){
		if(is_user_connected(idi) && is_user_connected(id))
		{
			if (longitude[id]!=0.0 && latitude[id]!=0.0 && longitude[idi]!=0.0 && latitude[idi]!=0.0)
				client_print(idi,print_chat,"FFAC : %s is %d km far away from you",pname,floatround(distance_between(latitude[id],latitude[idi],longitude[id],longitude[idi])))
		}
	}		
}

public Float:distance_between(Float:lat1,Float:lat2,Float:lon1,Float:lon2){
return (6371.0 * floatacos(floatsin(lat1/57.3) * floatsin(lat2/57.3) + floatcos(lat1/57.3) * floatcos(lat2/57.3) *  floatcos(lon2/57.3 -lon1/57.3),0))
}