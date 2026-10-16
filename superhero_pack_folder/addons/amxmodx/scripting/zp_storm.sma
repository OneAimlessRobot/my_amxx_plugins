#include <amxmodx>
#include <zombieplague>

new g_storm
new light

public plugin_init() 
{	
	register_plugin("[ZP] Extra Item: Infection Storm","1.0","fiendshard")
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0");
	g_storm = zp_register_extra_item("Infection Storm", 15, ZP_TEAM_ZOMBIE)
}

public plugin_precache() 
{ 
	light = precache_model("sprites/lgtning.spr") 
}

public zp_extra_item_selected(id, itemid)
{
	if (itemid == g_storm)
	{
		set_task(0.5,"lightning0",id+1,"",0,"a",60)
		set_task(1.0,"lightning1",id+2,"",0,"a",60)
		set_task(1.5,"lightning2",id+3,"",0,"a",60)
		set_task(2.0,"lightning3",id+4,"",0,"a",60)
		set_task(2.5,"lightning4",id+5,"",0,"a",60)
		set_task(3.0,"lightning5",id+6,"",0,"a",60)
	}
	return PLUGIN_HANDLED
}

public lightning0(id)
{
	new xy[2]
	xy[0] = random_num(-2000,2200)
	xy[1] = random_num(-2000,2200)
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte(0) 
	write_coord(xy[0]) 
	write_coord(xy[1]) 
	write_coord(4000) 
	write_coord(xy[0]) 
	write_coord(xy[1]) 
	write_coord(-2000) 
	write_short(light) 
	write_byte(1) // framestart 
	write_byte(5) // framerate 
	write_byte(2) // life 
	write_byte(200) // width 
	write_byte(100) // noise 
	write_byte(0) // r, g, b 
	write_byte(255) // r, g, b 
	write_byte(0) // r, g, b 
	write_byte(200) // brightness 
	write_byte(200) //  
	message_end() 
	
	new origin[3];
	get_user_origin(id, origin, 0)
	{
		if((origin[0] = xy[0]) && (origin[1] = xy[1]))
		zp_infect_user(id)
	}
}

public lightning1(id)
{
	new xy[2]
	xy[0] = random_num(-2000,2200)
	xy[1] = random_num(-2000,2200)
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte(0) 
	write_coord(xy[0]) 
	write_coord(xy[1]) 
	write_coord(4000) 
	write_coord(xy[0]) 
	write_coord(xy[1]) 
	write_coord(-2000) 
	write_short(light) 
	write_byte(1) // framestart 
	write_byte(5) // framerate 
	write_byte(2) // life 
	write_byte(10) // width 
	write_byte(10) // noise 
	write_byte(0) // r, g, b 
	write_byte(255) // r, g, b 
	write_byte(0) // r, g, b 
	write_byte(200) // brightness 
	write_byte(200) //  
	message_end() 
	
	new origin[3];
	get_user_origin(id, origin)
	{
		if((origin[0] = xy[0]) && (origin[1] = xy[1]))
		zp_infect_user(id)
	}
}

public lightning2(id)
{
	new xy[2]
	xy[0] = random_num(-2000,2200)
	xy[1] = random_num(-2000,2200)
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte(0) 
	write_coord(xy[0]) 
	write_coord(xy[1]) 
	write_coord(4000) 
	write_coord(xy[0]) 
	write_coord(xy[1]) 
	write_coord(-2000) 
	write_short(light) 
	write_byte(1) // framestart 
	write_byte(5) // framerate 
	write_byte(2) // life 
	write_byte(50) // width 
	write_byte(50) // noise 
	write_byte(0) // r, g, b 
	write_byte(255) // r, g, b 
	write_byte(0) // r, g, b 
	write_byte(200) // brightness 
	write_byte(200) //  
	message_end() 
	
	new origin[3];
	get_user_origin(id, origin)
	{
		if((origin[0] = xy[0]) && (origin[1] = xy[1]))
		zp_infect_user(id)
	}
}

public lightning3(id)
{
	new xy[2]
	xy[0] = random_num(-2000,2200)
	xy[1] = random_num(-2000,2200)
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte(0) 
	write_coord(xy[0]) 
	write_coord(xy[1]) 
	write_coord(4000) 
	write_coord(xy[0]) 
	write_coord(xy[1]) 
	write_coord(-2000) 
	write_short(light) 
	write_byte(1) // framestart 
	write_byte(5) // framerate 
	write_byte(2) // life 
	write_byte(200) // width 
	write_byte(150) // noise 
	write_byte(0) // r, g, b 
	write_byte(255) // r, g, b 
	write_byte(0) // r, g, b 
	write_byte(200) // brightness 
	write_byte(200) //  
	message_end() 
	
	new origin[3];
	get_user_origin(id, origin)
	{
		if((origin[0] = xy[0]) && (origin[1] = xy[1]))
		zp_infect_user(id)
	}
}

public lightning4(id)
{
	new xy[2]
	xy[0] = random_num(-2000,2200)
	xy[1] = random_num(-2000,2200)
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte(0) 
	write_coord(xy[0]) 
	write_coord(xy[1]) 
	write_coord(4000) 
	write_coord(xy[0]) 
	write_coord(xy[1]) 
	write_coord(-2000) 
	write_short(light) 
	write_byte(1) // framestart 
	write_byte(5) // framerate 
	write_byte(2) // life 
	write_byte(220) // width 
	write_byte(50) // noise 
	write_byte(0) // r, g, b 
	write_byte(255) // r, g, b 
	write_byte(0) // r, g, b 
	write_byte(200) // brightness 
	write_byte(200) //  
	message_end() 
	
	new origin[3];
	get_user_origin(id, origin)
	{
		if((origin[0] = xy[0]) && (origin[1] = xy[1]))
		zp_infect_user(id)
	}
}

public lightning5(id)
{
	new xy[2]
	xy[0] = random_num(-2000,2200)
	xy[1] = random_num(-2000,2200)
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
	write_byte(0) 
	write_coord(xy[0]) 	// Start X
	write_coord(xy[1]) 	// Start Y
	write_coord(4000) 	// Start Z
	write_coord(xy[0]) 	// End X
	write_coord(xy[1]) 	// End Y
	write_coord(-2000) 	// End Z
	write_short(light) 
	write_byte(1) // framestart 
	write_byte(5) // framerate 
	write_byte(2) // life 
	write_byte(180) // width 
	write_byte(70) // noise 
	write_byte(0) // r, g, b 
	write_byte(255) // r, g, b 
	write_byte(0) // r, g, b 
	write_byte(200) // brightness 
	write_byte(200) //  
	message_end() 
	
	new origin[3];
	get_user_origin(id, origin)
	{
		if((origin[0] = xy[0]) && (origin[1] = xy[1]))
		zp_infect_user(id)
	}	
}

public Event_NewRound(id) 
{ 
	if(task_exists(id+1) || (id+2) || (id+3) || (id+4) || (id+5) || (id+6)) 
	remove_task((id-1) && (id-2) && (id-3) && (id-4) && (id-5) && (id-6))
}
