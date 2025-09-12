/*
-----888888----------88888------888888----
----888----88-------888-888-----88---88---
----888----88------888---888----88----88--
----888------------888---888----88---88---
----888------------888888888----888888----
----888------------888---888----88---88---
----888----88------888---888----88----88--
-----8888888-------888---888----88-----88-
------------------------------------------
------------------------------------------
---888------888-----8888888-----8888888---
---8888----8888----88-----88----88----88--
---88-88--88-88----88-----88----88-----88-
---88--8888--88----88-----88----88------8-
---88---88---88----88-----88----88------8-
---88--------88----88-----88----88-----88-
---88--------88----88-----88----88----88--
---88--------88-----8888888-----8888888---
------------------------------------------

******************************************
By 

Stephen|AF| - Base carmod (one speed, foot steps, no engine sound, honk, siren, crashes, car model effect, car spawning command, temporary locks)
Fred Dawes  - Added more models, sounds, different speed classes, permanent locks, item_keys for car spawning
Wonsae      - Added passenger mod (Not working)
******************************************




*/









#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#define MAX_SPAWNS 20
new carout[33]
new incar[33]
//new carpool[33]
//new carpooled[33]
//new torigin[33][3]
new Float:oldspeed[33]
new Float:oldfric[33]
new oldmodel[33][33]
new carmodel[33][33]
new allow[33]
new usedcar[33]
new sirenon[33]

public loadSettings() {
   new szFilename[64]
   get_cvar_string("rp_carsfile",szFilename,63)

   if (!file_exists(szFilename)) {
      write_file(szFilename,"; CAR SPAWNS HERE",-1)
      server_print("[AMXX] No ^"%s^" was found, so it has been created.", szFilename)
      return PLUGIN_HANDLED
   }

   new szText[256]
   new a, g_aNum, pos = 0

   while ( g_aNum < MAX_SPAWNS && read_file(szFilename,pos++,szText,255,a) )
   {         
      if ( szText[0] == ';' ) continue
      server_cmd(szText)
      ++g_aNum
   }
   server_print("[AMXX] Loaded %i spawns", g_aNum )
   return PLUGIN_HANDLED
}

public overhear(a,distance,Speech[])
{
   new OriginA[3], OriginB[3]
   get_user_origin(a,OriginA)
   new players[32], num
   get_players(players,num,"ac")
   for(new b = 0; b < num;b++)
   {
      if(a!=players[b])
      {
         get_user_origin(players[b],OriginB)
         if(distance == -1) {
            client_print(players[b],print_chat,Speech)
         }
         else
         {
            if(get_distance(OriginA,OriginB) <= distance) {
               client_print(players[b],print_chat,Speech)
            }
         }
      }
   }
   return PLUGIN_HANDLED
}
public makecar(id) {
   new item[32], orig1[6], orig2[6], orig3[6], angles1[6], authid[31], Float:origin[3]
   read_argv(1, item, 31)
   read_argv(2, orig1, 5)
   read_argv(3, orig2, 5)
   read_argv(4, orig3, 5)
   read_argv(5, angles1, 5)
   read_argv(6, authid, 31)

   origin[0] = float(str_to_num(orig1))
   origin[1] = float(str_to_num(orig2))
   origin[2] = float(str_to_num(orig3))
   new Float:angles2 = float(str_to_num(angles1))

   new car = create_entity("info_target")

   if(!car) {
      client_print(id,print_chat,"CAR WAS not created. Error.^n")
      return PLUGIN_HANDLED
   }

   new Float:minbox[3] = { -2.5, -2.5, -2.5 }
   new Float:maxbox[3] = { 2.5, 2.5, -2.5 }
   new Float:angles[3] = { 0.0, 0.0, 0.0 }
   angles[1] = angles2

   entity_set_vector(car,EV_VEC_mins,minbox)
   entity_set_vector(car,EV_VEC_maxs,maxbox)
   entity_set_vector(car,EV_VEC_angles,angles)

   entity_set_float(car,EV_FL_dmg,0.0)
   entity_set_float(car,EV_FL_dmg_take,0.0)
   entity_set_float(car,EV_FL_max_health,99999.0)
   entity_set_float(car,EV_FL_health,99999.0)
   entity_set_int(car,EV_INT_solid,SOLID_TRIGGER)
   entity_set_int(car,EV_INT_movetype,MOVETYPE_NONE)

   entity_set_string(car,EV_SZ_targetname,item)
   entity_set_string(car,EV_SZ_classname,"item_car")
   new damodel[64]
   format(damodel,63,"models/player/%s/%s.mdl", item, item)

   entity_set_model(car,damodel)
   entity_set_origin(car,origin)

   carout[id] = car
   entity_set_string(carout[id],EV_SZ_target,authid)
   return PLUGIN_HANDLED
}

/*
public getin(id){
	new blah2
	if(get_user_aiming(id,carpool[id],blah2,200)) {
		if(carpooled[id] == 1)
			{
			getout(id)
			return PLUGIN_HANDLED;
		}
		if(incar[id] == 1){
			if(carpooled[carpool[id]] == 1){
				client_print(carpool[id],print_chat,"[CarMod] You got kicked out of the car!")
				getout(carpool[id])
			}else{
				client_print(id,print_chat,"[CarMod] Get out of your car first!")
			}
		}
		if(!is_user_connected(carpool[id]))
			{
			client_print(id,print_chat,"[CarMod] Invalid target.")
			return PLUGIN_HANDLED;
		}
		if(incar[carpool[id]] == 0)
			{
			client_print(id,print_chat,"[CarMod] Player not in car.")
			return PLUGIN_HANDLED;
		}
		client_print(id,print_chat,"[CarMod] You are now riding with the player!")
		set_user_rendering(id,kRenderFxNone,0,0,0,kRenderTransAlpha,0)
		set_user_noclip(id, 1)
		get_user_origin(carpool[id], torigin[id])
		torigin[id][2] += 80
		carpooled[id] = 1
		set_user_origin(id,torigin[id])
		set_task(0.1, "originchange", id+45, "", 0, "b")
		return PLUGIN_HANDLED
	} else {
		client_print(id,print_chat,"[CarMod] Too far away to ride the player's car.")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED;
}
public originchange(id){
	id -= 45

	get_user_origin(carpool[id], torigin[id])
	torigin[id][2] += 80

	
	set_user_origin(id,torigin[id])
	return PLUGIN_HANDLED;
}

public client_PostThink(id) {
	if(carpooled[id] == 1){
		set_user_rendering(id,kRenderFxNone,0,0,0,kRenderTransAlpha,0);
	}else{
		set_user_rendering(id,kRenderFxNone,0,0,0,kRenderTransAlpha,255);
	}
	return PLUGIN_HANDLED
} 

public getout(id)
{
	carpool[id] = 0
	client_print(id,print_chat,"[CarMod] You are no longer incar with the player!")
	set_user_noclip(id,0)
	set_user_rendering(id,kRenderFxNone,0,0,0,kRenderTransAlpha,255)
	get_user_origin(carpool[id], torigin[id])
	torigin[id][2] += 80
	set_user_origin(id,torigin[id])
	remove_task(id+45)
	set_task(3.0,"leavecar",id)
	return PLUGIN_HANDLED;
} 

public leavecar(id)
{
	carpooled[id] = 0;
	return PLUGIN_HANDLED
}
*/

public plugin_init()
{
   register_touch("item_car","player","setcar")
   register_touch("player","player","crash")

// register_clcmd("passenger","getin")
   register_clcmd("getout","uncar")
   register_clcmd("honk","honk")
   register_clcmd("siren","siren")   
   register_srvcmd("amx_makecar","makecar")
   register_srvcmd("item_keys","item_keys")
   register_cvar("rp_carsfile", "carsfile.ini")
   register_concmd("amx_createcar","purposedrop")
   register_event("DeathMsg","death_msg","a")
// set_task(10.0,"loadSettings")
}

/*
---------------------
!!!!PRECACHE HERE!!!!
---------------------
If you want to add a car, add the line
precache_model("<path to player model from TS>")

It will be classified as a class C car
*/


public plugin_precache()
{
   precache_model("models/player/car_corolla/car_corolla.mdl")
   precache_model("models/player/car_viper/car_viper.mdl")
   precache_model("models/player/car_astra/car_astra.mdl")
   precache_model("models/player/car_police/car_police.mdl")
   precache_model("models/player/car_evo/car_evo.mdl")
   precache_model("models/player/car_gto/car_gto.mdl")
   precache_sound("carmod/car_horn.wav")
   precache_sound("carmod/siren2.wav")
   precache_sound("carmod/start.wav")
   precache_sound("carmod/engine2.wav")
   precache_sound("ambience/rd_warehouse.wav")
   register_plugin("Carmod","2.0","Steven|AF| - Dawes")
}



public crash(entid, id) {
   if(allow[entid] == 1 || allow[id] == 1) return PLUGIN_HANDLED
   if(incar[id] && incar[entid]) {
      new hp = get_user_health(entid)
      new hp2 = get_user_health(id)
      set_user_health(entid,(hp - 75))
      set_user_health(id,(hp2 - 75))
//    set_user_maxspeed(id,oldspeed[id])
//    entity_set_float(id,EV_FL_friction,oldfric[id])
//    car_drop(id)
      set_user_info(id,"model",oldmodel[id])
      incar[id] = 0
      emit_sound(id, CHAN_ITEM, "ambience/rd_warehouse.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
      //drop_car(id)
      //drop_car(entid)
      return PLUGIN_HANDLED
   }
   if(incar[id]) {
      new hp = get_user_health(id)
      set_user_health(id,(hp - 10))
      emit_sound(id, CHAN_ITEM, "ambience/rd_warehouse.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
      //if(get_user_health(id) <= 0) drop_car(id)
      return PLUGIN_HANDLED
   }
   if(incar[entid]) {
      set_user_health(id,0)
      emit_sound(entid, CHAN_ITEM, "ambience/rd_warehouse.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
      //if(get_user_health(entid) <= 0) drop_car(entid)
      return PLUGIN_HANDLED
   }
   return PLUGIN_HANDLED
}
public honk(id) {
   if(incar[id] != 1) return PLUGIN_HANDLED
   emit_sound(id, CHAN_ITEM, "carmod/car_horn.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
   return PLUGIN_HANDLED
}
public siren(id) {
   if(incar[id] != 1) return PLUGIN_HANDLED
   if(sirenon[id] == 1) {
      sirenon[id] = 0
      return PLUGIN_HANDLED
   }
   new popo[33]
   popo = "car_police"
   if(equal(carmodel[id],popo)){
      sirenon[id] = 1
      return PLUGIN_HANDLED
   }
   client_print(id,print_chat,"[CarMod] You must be driving a police car!")
   return PLUGIN_HANDLED
}
public client_PreThink(id)
{
   if(incar[id] != 0)
   {
      new bufferstop = entity_get_int(id,EV_INT_button)

      if(bufferstop != 0) {
         entity_set_int(id,EV_INT_button,bufferstop & ~IN_ATTACK & ~IN_ATTACK2 & ~IN_ALT1 & ~IN_USE)
      }

      if((bufferstop & IN_JUMP) && (entity_get_int(id,EV_INT_flags) & ~FL_ONGROUND & ~FL_DUCKING)) {
         entity_set_int(id,EV_INT_button,entity_get_int(id,EV_INT_button) & ~IN_JUMP)
      }
      return PLUGIN_CONTINUE
   }
   return PLUGIN_CONTINUE
}

public setcar(entid,id) {
   if(allow[id] != 0) return PLUGIN_HANDLED
   if(incar[id] != 0) return PLUGIN_HANDLED

   new locked[33], authid[33]
   entity_get_string(entid,EV_SZ_target,locked,32)
   get_user_authid(id,authid,32)
   if(equal(locked,authid)) {}
   else{ 
      client_print(id,print_chat,"This car is reserved for %s, you are %s",locked,authid)
      allow[id] = 1
      set_task(5.0,"allowhim",id)
      return PLUGIN_HANDLED
   }
   new name[64]
   get_user_name(id,name,63)
   new message[300]
   format(message,299,"[CarMod] %s has gotten into his car and started the engine.",name)
   overhear(id,300,message)
   client_print(id,print_chat,"[CarMod] You have gotten into your car and started the engine.")
   get_user_info(id,"model",oldmodel[id], 32)

   new itemstr[33]
   entity_get_string(entid,EV_SZ_targetname,itemstr,31)

   carmodel[id] = itemstr
   set_user_info(id,"model",itemstr)
   oldspeed[id] = get_user_maxspeed(id)
   oldfric[id] = entity_get_float(id,EV_FL_friction)
   if(equal(carmodel[id],"car_gto") || equal(carmodel[id],"car_viper")) {
      set_user_maxspeed(id, 1750.0)
      client_cmd(id,"cl_forwardspeed 1750.0")
      client_cmd(id,"cl_sidespeed 1750.0")
      client_cmd(id,"cl_backspeed 1750.0")
   }else{
      if(equal(carmodel[id],"car_evo")){
         set_user_maxspeed(id, 1000.0)
         client_cmd(id,"cl_forwardspeed 1000.0")
         client_cmd(id,"cl_sidespeed 1000.0")
         client_cmd(id,"cl_backspeed 1000.0")
      }else{
         if(equal(carmodel[id],"car_police") || equal(carmodel[id],"car_corolla")){
            set_user_maxspeed(id, 750.0)
            client_cmd(id,"cl_forwardspeed 750.0")
            client_cmd(id,"cl_sidespeed 750.0")
            client_cmd(id,"cl_backspeed 750.0")
         }else{
            set_user_maxspeed(id, 500.0)
            client_cmd(id,"cl_forwardspeed 500.0")
            client_cmd(id,"cl_sidespeed 500.0")
            client_cmd(id,"cl_backspeed 500.0")
         }
      }
   }
   entity_set_float(id,EV_FL_friction,0.3)
   incar[id] = 1
   carout[id] = 0
   emit_sound(id, CHAN_ITEM, "carmod/start.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
   ///Replace footsteps with engine sound
   set_user_footsteps(id, 1)
   set_task(3.0,"engine",id)
   remove_entity(entid)
   return PLUGIN_HANDLED
}

public engine(id) {
   if(incar[id] != 1) return PLUGIN_HANDLED
   if(sirenon[id] == 1){
      emit_sound(id, CHAN_ITEM, "carmod/siren2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
      set_task(11.0,"engine",id)
   }else{
      emit_sound(id, CHAN_ITEM, "carmod/engine2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
      set_task(1.0,"engine",id)
   }
   return PLUGIN_HANDLED
}
public uncar(id) {
   if(incar[id] != 1) return PLUGIN_HANDLED
   new name[64]
   get_user_name(id,name,63)
   new message[300]
   set_user_footsteps(id, 0)
   format(message,299,"[CarMod] %s has turned off his engine and got out of the car.",name)
   overhear(id,300,message)
   client_print(id,print_chat,"[CarMod] You have turned off your engine and got out of the car.")
   set_user_maxspeed(id,oldspeed[id])
   entity_set_float(id,EV_FL_friction,oldfric[id])
   car_drop(id)
   set_user_info(id,"model",oldmodel[id])
   incar[id] = 0
   return PLUGIN_HANDLED
}

public item_keys()
{

   new authid[32], itemname[64], arg[32], id
   read_argv(1,arg,31)
   read_argv(2,itemname,31)
   id = str_to_num(arg)
   get_user_authid(id,authid,31)
   new origin[3], Float:originF[3]
   get_user_origin(id,origin)
   if( usedcar[id] == 1 ){
	client_print(id,print_chat,"[CarMod] You already have a car!!")
	return PLUGIN_HANDLED
   }
   originF[0] = float(origin[0])
   originF[1] = float(origin[1])
   originF[2] = float(origin[2])

   new car = create_entity("info_target")

   if(!car) {
      client_print(id,print_chat,"CAR WAS not created. Error.^n")
      return PLUGIN_HANDLED
   }

   new Float:minbox[3] = { -2.5, -2.5, -2.5 }
   new Float:maxbox[3] = { 2.5, 2.5, -2.5 }
   new Float:angles[3] = { 0.0, 0.0, 0.0 }

   new Float:pangles[3]
   entity_get_vector(id,EV_VEC_angles,pangles)
   angles[1] = pangles[1]
   entity_set_vector(car,EV_VEC_mins,minbox)
   entity_set_vector(car,EV_VEC_maxs,maxbox)
   entity_set_vector(car,EV_VEC_angles,angles)

   entity_set_float(car,EV_FL_dmg,0.0)
   entity_set_float(car,EV_FL_dmg_take,0.0)
   entity_set_float(car,EV_FL_max_health,99999.0)
   entity_set_float(car,EV_FL_health,99999.0)

   entity_set_int(car,EV_INT_solid,SOLID_TRIGGER)
   entity_set_int(car,EV_INT_movetype,MOVETYPE_NONE)

   entity_set_string(car,EV_SZ_targetname,itemname)
   entity_set_string(car,EV_SZ_classname,"item_car")

   new damodel[64]
   format(damodel,63,"models/player/%s/%s.mdl", itemname, itemname)
   entity_set_model(car,damodel)
   entity_set_origin(car,originF)
   allow[id] = 1
   set_task(2.0,"allowhim",id)
   carout[id] = car
   usedcar[id] = 1
   entity_set_string(carout[id],EV_SZ_target,authid)
   return PLUGIN_HANDLED
}

public purposedrop(id)
{
   if(!is_user_alive(id)) return PLUGIN_HANDLED
   new itemname[64], save1[6], authid[31], szFilename[64]
   read_argv(1, itemname, 31)
   read_argv(2, save1, 5)
   read_argv(3, authid, 31)
   if(!(get_user_flags(id) & ADMIN_LEVEL_A)){
      client_print(id,print_console,"You do not have access to this command.")
      return PLUGIN_HANDLED
   }
   if(equal(itemname, "") || equal(save1, "")) {
      client_print(id,print_console,"Usage: amx_createcar <model> <save 1/0> <Steamid>")
      return PLUGIN_HANDLED
   }

   new save = str_to_num(save1)
   new origin[3], Float:originF[3]
   get_user_origin(id,origin)

   originF[0] = float(origin[0])
   originF[1] = float(origin[1])
   originF[2] = float(origin[2])

   new car = create_entity("info_target")

   if(!car) {
      client_print(id,print_chat,"CAR WAS not created. Error.^n")
      return PLUGIN_HANDLED
   }

   new Float:minbox[3] = { -2.5, -2.5, -2.5 }
   new Float:maxbox[3] = { 2.5, 2.5, -2.5 }
   new Float:angles[3] = { 0.0, 0.0, 0.0 }

   new Float:pangles[3]
   entity_get_vector(id,EV_VEC_angles,pangles)
   angles[1] = pangles[1]
   entity_set_vector(car,EV_VEC_mins,minbox)
   entity_set_vector(car,EV_VEC_maxs,maxbox)
   entity_set_vector(car,EV_VEC_angles,angles)

   entity_set_float(car,EV_FL_dmg,0.0)
   entity_set_float(car,EV_FL_dmg_take,0.0)
   entity_set_float(car,EV_FL_max_health,99999.0)
   entity_set_float(car,EV_FL_health,99999.0)

   entity_set_int(car,EV_INT_solid,SOLID_TRIGGER)
   entity_set_int(car,EV_INT_movetype,MOVETYPE_NONE)

   entity_set_string(car,EV_SZ_targetname,itemname)
   entity_set_string(car,EV_SZ_classname,"item_car")

   new damodel[64]
   format(damodel,63,"models/player/%s/%s.mdl", itemname, itemname)

   entity_set_model(car,damodel)
   entity_set_origin(car,originF)
   if(save == 1 || equal(save1, "1")) {
      get_cvar_string("rp_carsfile",szFilename,63)
      if (!file_exists(szFilename)) return PLUGIN_HANDLED

      new message[64]
      format(message, 63, "amx_makecar %s %i %i %i 0 ^"%s^"", itemname, origin[0], origin[1], origin[2], authid)
      write_file(szFilename,message,-1)
   }
   allow[id] = 1
   set_task(10.0,"allowhim",id)
   carout[id] = car
   entity_set_string(carout[id],EV_SZ_target,authid)
   return PLUGIN_HANDLED
}
public car_drop(id)
{
   //if(!is_user_alive(id)) return PLUGIN_HANDLED
   if(incar[id] != 1) return PLUGIN_HANDLED

   new origin[3],Float:pangles[3],Float:originF[3]
   get_user_origin(id,origin)

   originF[0] = float(origin[0])
   originF[1] = float(origin[1])
   originF[2] = float(origin[2])
   set_user_footsteps(id,0)   
   client_cmd(id,"cl_forwardspeed 350")
   client_cmd(id,"cl_sidespeed 350")
   client_cmd(id,"cl_backspeed 350")
   new car = create_entity("info_target")

   if(!car) {
      client_print(id,print_chat,"CAR WAS not created. Error.^n")
      return PLUGIN_HANDLED
   }

   new Float:minbox[3] = { -2.5, -2.5, -2.5 }
   new Float:maxbox[3] = { 2.5, 2.5, -2.5 }
   new Float:angles[3] = { 0.0, 0.0, 0.0 }
   entity_get_vector(id,EV_VEC_angles,pangles)
   angles[1] = pangles[1]

   entity_set_vector(car,EV_VEC_mins,minbox)
   entity_set_vector(car,EV_VEC_maxs,maxbox)
   entity_set_vector(car,EV_VEC_angles,angles)

   entity_set_float(car,EV_FL_dmg,0.0)
   entity_set_float(car,EV_FL_dmg_take,0.0)
   entity_set_float(car,EV_FL_max_health,99999.0)
   entity_set_float(car,EV_FL_health,99999.0)

   entity_set_int(car,EV_INT_solid,SOLID_TRIGGER)
   entity_set_int(car,EV_INT_movetype,MOVETYPE_NONE)

   entity_set_string(car,EV_SZ_targetname,carmodel[id])
   entity_set_string(car,EV_SZ_classname,"item_car")

   new damodel[64]
   format(damodel,63,"models/player/%s/%s.mdl", carmodel[id], carmodel[id])

   entity_set_model(car,damodel)
   entity_set_origin(car,originF)

   carout[id] = car
   allow[id] = 1
   new authid[32]
   get_user_authid(id,authid,32)
   entity_set_string(carout[id],EV_SZ_target,authid)
   set_task(10.0,"allowhim",id)
   return PLUGIN_HANDLED
}
public allowhim(id) {
   allow[id] = 0
}
public client_infochanged(id)
{
   if(incar[id] == 1) {
      set_user_info(id,"model",carmodel[id])
      return PLUGIN_HANDLED
   }
   return PLUGIN_HANDLED
}
public client_disconnected(id) {

   if(incar[id] == 1) {
      car_drop(id)
      incar[id] = 0
   }
   if(carout[id]) {
      carout[id] = 0
   }
//   if(task_exists(id+45)) remove_task(id+45) 
   return PLUGIN_CONTINUE
}
public death_msg() {
   new id = read_data(2)
   if(incar[id] == 1) {
      set_user_maxspeed(id,oldspeed[id])
      entity_set_float(id,EV_FL_friction,oldfric[id])
      set_user_info(id,"model",oldmodel[id])
      car_drop(id)
      incar[id] = 0
   }
/*
   if(carpooled[id] == 1){
      getout(id)
      return PLUGIN_HANDLED;
   }
*/	

   return PLUGIN_CONTINUE
} 
