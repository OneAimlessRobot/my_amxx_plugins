#include <amxmodx>
#include <amxmisc>
#include <engine>
/* 
Plugin releases
===============

v 1.1
-----
- Bug Fixes

v 1.0
-----
- Original Plugin Release
*/

new camera[33]
new Float:origin[33][3]
new bool:in_camera[33]
new fire
new health
new delround
new camera_speed

public plugin_init()
{
	register_plugin("Portable Cameras","1.1","Johnjg75")
	register_clcmd("amx_addcamera","addcm")
	register_clcmd("amx_viewcamera","viewcm")
	register_clcmd("amx_deletecamera","deletecm")
	register_clcmd("amx_cameramenu","cmmenu")
	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3
	register_menucmd(register_menuid("Camera Menu"), keys, "menuProc")
	register_event("HLTV","nRound","a","1=0","2=0")
	register_cvars()
}

public nRound()
{
	for(new i=0;i<33;i++)
	{
		return_view(i)
		if(get_pcvar_num(delround))
			delete_camera(i)
	}
	
	return PLUGIN_HANDLED
}

public menuProc(id,key)
{
	if (key == 0)
	{
		addcm( id )
		cmmenu( id )
	} else if (key == 1) {
		viewcm( id )
		cmmenu( id )
	} else if (key == 2) {
		deletecm( id )
		cmmenu( id )
	}
	return PLUGIN_CONTINUE
}

public cmmenu(id)
{
	new menu[192]
	new keys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3
	format(menu, 191, "Camera Menu^n^n1. Create Camera^n2. View Camera^n3. Delete Camera^n^n0. Exit")
	show_menu(id,keys,menu)
	return PLUGIN_HANDLED
}

public addcm( id )
{
	create_camera( id )
	return PLUGIN_CONTINUE
}

public viewcm( id )
{
	if(view_camera( id ))
	{
		set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 4.0)
		show_hudmessage(id, "Press your USE key to exit camera view.")
	}
	return PLUGIN_CONTINUE
}

public deletecm( id )
{
	delete_camera( id )
	return PLUGIN_HANDLED
}

public client_disconnect( id )
{
	delete_camera( id )
	return PLUGIN_CONTINUE
}

public client_connect( id )
{
	delete_camera( id )
	return PLUGIN_CONTINUE
}

public plugin_precache()
{
	fire = precache_model("sprites/explode1.spr")
	precache_model("models/camera.mdl")
}

public client_PreThink(id)
{

	if(camera[id] && !is_valid_ent(camera[id]))
	{
		camera[id]=0
		in_camera[id]=false
		create_explosion(floatround(origin[id][0]),floatround(origin[id][1]),floatround(origin[id][2]),5,0)
		client_print(id,print_chat,"[AMXX] BOOM! Someone blew up your camera.")
	}
	else if(in_camera[id])
	{
		new Float:velocity[3]
		set_user_velocity(id,velocity)

		new buttons = get_user_button(id)

		if(buttons & IN_USE)
		{
			return_view(id)
		}

		else
		{
			new Float:v_angle[3], Float:angles[3]
			entity_get_vector(camera[id],EV_VEC_angles,angles)
			entity_get_vector(camera[id],EV_VEC_v_angle,v_angle)
			if(buttons & IN_FORWARD)
			{
				v_angle[0] -= get_pcvar_float(camera_speed)
				angles[0] -= get_pcvar_float(camera_speed)
				if(v_angle[0]<-89.0) v_angle[1] = 89.0
				if(angles[0]<-89.0) angles[1] = 89.0
			}
			if(buttons & IN_BACK)
			{
				v_angle[0] += get_pcvar_float(camera_speed)
				angles[0] += get_pcvar_float(camera_speed)
				if(v_angle[0]>89.0) v_angle[1] = -89.0
				if(angles[0]>89.0) angles[1] = -89.0
			}
			if(buttons & IN_MOVELEFT || buttons & IN_LEFT)
			{
				v_angle[1] += get_pcvar_float(camera_speed)
				angles[1] += get_pcvar_float(camera_speed)
				if(v_angle[1]>179.0) v_angle[1] = -179.0
				if(angles[1]>179.0) angles[1] = -179.0
			}
			if(buttons & IN_MOVERIGHT || buttons & IN_RIGHT)
			{
				v_angle[1] -= get_pcvar_float(camera_speed)
				angles[1] -= get_pcvar_float(camera_speed)
				if(v_angle[1]<-179.0) v_angle[1] = 179.0
				if(angles[1]<-179.0) angles[1] = 179.0
			}
			entity_set_vector(camera[id],EV_VEC_angles,angles)
			entity_set_vector(camera[id],EV_VEC_v_angle,v_angle)

		}
	}
	return PLUGIN_CONTINUE
}


stock register_cvars()
{
	health = register_cvar("camera_health","1")
	camera_speed = register_cvar("camera_speed","3")
	delround = register_cvar("camera_deleteround","0")
}

stock create_camera(id)
{
	if(!is_user_alive(id))
	{
		client_print(id,print_chat,"[CAM] You can't create a camera while you are dead.")
		return 0;
	}
	
	if(delete_camera(id))
		client_print(id,print_chat,"[CAM] Your old camera was deleted and new camera spawned.")
	new Float:v_angle[3], Float:angles[3]
	entity_get_vector(id,EV_VEC_origin,origin[id])
	entity_get_vector(id,EV_VEC_v_angle,v_angle)
	entity_get_vector(id,EV_VEC_angles,angles)

	new ent = create_entity("info_target")

	entity_set_string(ent,EV_SZ_classname,"JJG75_Camera")

	entity_set_int(ent,EV_INT_solid,SOLID_BBOX)
	entity_set_int(ent,EV_INT_movetype,MOVETYPE_FLY)
	entity_set_edict(ent,EV_ENT_owner,id)
	entity_set_model(ent,"models/camera.mdl")
	entity_set_float(ent,EV_FL_health,get_pcvar_float(health))
	if(get_pcvar_num(health) == 1)
		entity_set_float(ent,EV_FL_takedamage,0.0)
	else
		entity_set_float(ent,EV_FL_takedamage,1.0)

	new Float:mins[3]
	mins[0] = -5.0
	mins[1] = -10.0
	mins[2] = -5.0

	new Float:maxs[3]
	maxs[0] = 5.0
	maxs[1] = 10.0
	maxs[2] = 5.0

	entity_set_size(ent,mins,maxs)

	entity_set_origin(ent,origin[id])
	entity_set_vector(ent,EV_VEC_v_angle,v_angle)
	entity_set_vector(ent,EV_VEC_angles,angles)

	camera[id] = ent

	return 1;
}


stock view_camera(id)
{
	if(!is_user_alive(id))
	{
		client_print(id,print_chat,"[CAM] You can't view your camera while you're dead.")
		return 0;
	}
	
	if(is_valid_ent(camera[id]))
	{
		attach_view(id,camera[id])
		in_camera[id]=true
		return 1;
	}
	return 0;
}

stock return_view(id)
{
	if(!in_camera[id])
	{
		return 0;
	}
	in_camera[id]=false
	attach_view(id,id)
	return 1;
}

stock delete_camera(id)
{
	if(is_valid_ent(camera[id]))
	{
		if(in_camera[id])
		{
			return_view(id)
			in_camera[id]=false
		}
		create_explosion(floatround(origin[id][0]),floatround(origin[id][1]),floatround(origin[id][2]),5,0)
		remove_entity(camera[id])
		return 1;
	}
	camera[id] = 0
	return 0;
}

stock create_explosion(origin0,origin1,origin2,size,flags)
{
	new origina[3]
	origina[0]=origin0
	origina[1]=origin1
	origina[2]=origin2
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY,origina) 
	write_byte( 3 ) 
	write_coord(origina[0])	// start position
	write_coord(origina[1])
	write_coord(origina[2])
	write_short( fire )
	write_byte( size ) // byte (scale in 0.1's) 188
	write_byte( 10 ) // byte (framerate)
	write_byte( flags ) // byte flags (4 = no explode sound)
	message_end()
}
