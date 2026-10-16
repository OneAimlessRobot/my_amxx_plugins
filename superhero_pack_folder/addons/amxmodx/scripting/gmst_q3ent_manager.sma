#include <amxmodx>
#include <amxmisc>
#include <engine>

#define MAXPATH 128

#define MAX_ENTTYPES 128
#define MAX_ENTTYPELEN 64
new g_enttypes[MAX_ENTTYPES][MAX_ENTTYPELEN];
new g_enttypes_c = 0;

#define MAX_MAPENTS 1024
new Float:g_mapent_pos[MAX_MAPENTS][3];
new g_mapent_type[MAX_MAPENTS];
new g_mapent_c = 0;

new g_mapent_file[MAXPATH];

new g_beamsprite;

public plugin_init(){
	register_plugin("add info_targets", "0.1", "Sneaky@GlobalModders.net");
	register_clcmd("ent_menu", "menu_main");
	
	new buffer[MAXPATH];
	get_datadir(buffer, charsmax(buffer));
	strcat(buffer, "/info_target.ents", charsmax(buffer));
	
	new fenttypes = fopen(buffer, "r");
	while(fgets(fenttypes, g_enttypes[g_enttypes_c], MAX_ENTTYPELEN-1)){
		trim(g_enttypes[g_enttypes_c]);
		g_enttypes_c++;
	}
	fclose(fenttypes);
	
	get_datadir(g_mapent_file, charsmax(g_mapent_file));
	strcat(g_mapent_file, "/info_target", charsmax(g_mapent_file));
	if(!dir_exists(g_mapent_file))
		mkdir(g_mapent_file);	
	
	new mapname[MAXPATH];
	get_mapname(mapname, charsmax(mapname));
	strcat(g_mapent_file, "/", charsmax(g_mapent_file));
	strcat(g_mapent_file, mapname, charsmax(g_mapent_file));
	
	load_mapents();
}

public plugin_precache(){
	g_beamsprite = precache_model("sprites/laserbeam.spr")
}

load_mapents(){
	new buffer[MAX_ENTTYPELEN + 128];
	new fmapent = fopen(g_mapent_file, "r");
	while(fgets(fmapent, buffer, charsmax(buffer))){
		new offset = 0;
		for(new i = 0; i < 3; i++){
			while(buffer[offset] && buffer[offset] == ' ')
			offset++;
			g_mapent_pos[g_mapent_c][i] = str_to_float(buffer[offset]);
			while(buffer[offset] && buffer[offset] != ' ')
			offset++;
		}
		trim(buffer[offset]);
		for(new i = 0; i < g_enttypes_c; i++){
			if(!strcmp(buffer[offset], g_enttypes[i], true)){
				g_mapent_type[g_mapent_c] = i;
				g_mapent_c++;
				break;
			}
		}
	}
	fclose(fmapent);
	
	spawn_mapents();
}

spawn_mapents(){
	for(new i = 0; i < g_mapent_c; i++){
		new ent = create_entity("info_target");
		entity_set_origin(ent, g_mapent_pos[i]);
		entity_set_string(ent, EV_SZ_targetname, g_enttypes[g_mapent_type[i]]);
	}
}

save_mapents(){
	new fmapent = fopen(g_mapent_file, "w");
	for(new i = 0; i < g_mapent_c; i++){
		fprintf(fmapent, "%f %f %f %s^n", g_mapent_pos[i][0], g_mapent_pos[i][1], g_mapent_pos[i][2], g_enttypes[g_mapent_type[i]]);
	}
	fclose(fmapent);
}

public menu_main(id){
	new menu = menu_create("Main menu", "handler_main");
	menu_additem(menu, "Add entity", "menu_addent");
	menu_additem(menu, "Trace entities", "menu_trent");
	menu_additem(menu, "Remove nearest entity", "menu_rement");
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public handler_main(id, menu, item){
	if(item >= 0){
		new ac, info[16];
		menu_item_getinfo(menu, item, ac, info, charsmax(info),"",0,ac);
		callfunc_begin(info);
		callfunc_push_int(id);
		callfunc_end();
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}

public menu_trent(id){
	if(task_exists(id)){
		remove_task(id);
	}else{
		set_task(0.1, "task_trace", id);
	}
	
	menu_main(id);
	return PLUGIN_HANDLED;
}

getfuncolor(multiplier){
	return 128+floatround((floatsin(get_gametime()*multiplier, degrees)+1)*127*0.5);
}

public task_trace(id){
	for(new i = 0; i < g_mapent_c; i++){
		message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id);
		write_byte(TE_BEAMENTPOINT);
		write_short(id);
		write_coord(floatround(g_mapent_pos[i][0]));
		write_coord(floatround(g_mapent_pos[i][1]));
		write_coord(floatround(g_mapent_pos[i][2]));
		write_short(g_beamsprite);
		write_byte(0);
		write_byte(0);
		write_byte(11);
		write_byte(4);
		write_byte(0);
		write_byte(getfuncolor(3));
		write_byte(getfuncolor(-1));
		write_byte(getfuncolor(7));
		write_byte(255);
		
		write_byte(0);
		message_end();
	}
	set_task(1.0, "task_trace", id);
}

public menu_addent(id){
	new menu = menu_create("Add entity menu", "handler_addent");
	for(new i = 0; i < g_enttypes_c; i++){
		menu_additem(menu, g_enttypes[i]);
	}
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public handler_addent(id, menu, item){
	if(item < 0){
		menu_destroy(menu);
		menu_main(id);
		return PLUGIN_HANDLED;
	}
	
	entity_get_vector(id, EV_VEC_origin, g_mapent_pos[g_mapent_c]);
	g_mapent_type[g_mapent_c] = item;
	client_print(id, print_chat, "Added %s @ [%.0f;%.0f;%.0f]", g_enttypes[g_mapent_type[g_mapent_c]], g_mapent_pos[g_mapent_c][0], g_mapent_pos[g_mapent_c][1], g_mapent_pos[g_mapent_c][2]);
	g_mapent_c++;
	save_mapents();
	
	menu_destroy(menu);
	menu_addent(id);
	return PLUGIN_HANDLED;
}

public menu_rement(id){
	new Float:min_dist = 64.0, Float:origin[3];
	new ent = -1;
	entity_get_vector(id, EV_VEC_origin, origin);
	for(new i = 0; i < g_mapent_c; i++){
		new Float:dist = vector_distance(origin, g_mapent_pos[i]);
		if(dist < min_dist){
			min_dist = dist;
			ent = i;
		}
	}
	if(ent >= 0){
		client_print(id, print_chat, "Removed %s @ [%.0f;%.0f;%.0f]", g_enttypes[g_mapent_type[ent]], g_mapent_pos[ent][0], g_mapent_pos[ent][1], g_mapent_pos[ent][2]);
		g_mapent_c--;
		if(g_mapent_c > 0){
			g_mapent_pos[ent] = g_mapent_pos[g_mapent_c];
			g_mapent_type[ent] = g_mapent_type[g_mapent_c];
		}
		save_mapents();
	}else{
		client_print(id, print_chat, "No entities nearby (radius of %.0f units).", min_dist);
	}
	menu_main(id);
	return PLUGIN_HANDLED;
}