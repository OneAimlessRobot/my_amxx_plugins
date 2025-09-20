#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta_util>

#define PLUGIN "KillStreak"
#define VERSION "1.12"
#define AUTHOR "cypis"

new const maxAmmo[31]={0,52,0,90,1,32,1,100,90,1,120,100,100,90,90,90,100,120,30,120,200,32,90,120,90,2,35,90,90,0,100};

new sprite_blast, cache_trail;

new licznik_zabic[33], radar[33], nalot[33], predator[33], nuke[33], emp[33], cuav[33], uav[33], pack[33];
new user_controll[33];
new emp_czasowe[33];

new PobraneOrigin[3];

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    register_forward(FM_Touch, "fw_Touch");
    register_forward(FM_PlayerPreThink, "player_predator");
    register_forward(FM_ClientKill, "cmdKill")

    RegisterHam(Ham_Killed, "player", "SmiercGracza", 1);
    
    register_event("CurWeapon","CurWeapon","be", "1=1");

    register_clcmd("say /ks", "uzyj_nagrody");
    register_clcmd("say /killstreak", "uzyj_nagrody");
    register_clcmd("killstreak", "uzyj_nagrody");
    set_task (2.0,"radar_scan",_,_,_,"b");
}

public plugin_precache()
{
    sprite_blast = precache_model("sprites/dexplo.spr")
    cache_trail = precache_model("sprites/smoke.spr")
    precache_model("models/p_hegrenade.mdl");
    precache_model("models/cod_carepackage.mdl")
    precache_model("models/cod_plane.mdl")
    precache_model("models/cod_predator.mdl")
    
    precache_sound("mw/nuke_friend.wav");
    precache_sound("mw/nuke_enemy.wav");
    precache_sound("mw/nuke_give.wav");
    
    precache_sound("mw/jet_fly1.wav");
    //precache_sound("mw/jet_fly2.wav");
    
    precache_sound("mw/emp_effect.wav");
    precache_sound("mw/emp_friend.wav");
    precache_sound("mw/emp_enemy.wav");
    precache_sound("mw/emp_give.wav");
    
    precache_sound("mw/counter_friend.wav");
    precache_sound("mw/counter_enemy.wav");
    precache_sound("mw/counter_give.wav");
    
    precache_sound("mw/air_friend.wav");
    precache_sound("mw/air_enemy.wav");
    precache_sound("mw/air_give.wav");
    
    precache_sound("mw/predator_friend.wav");
    precache_sound("mw/predator_enemy.wav");
    precache_sound("mw/predator_give.wav");
    
    precache_sound("mw/uav_friend.wav");
    precache_sound("mw/uav_enemy.wav");
    precache_sound("mw/uav_give.wav")
}

public uzyj_nagrody(id)
{
    new menu = menu_create("KillStreak:", "Nagrody_Handler");
    new cb = menu_makecallback("Nagrody_Callback");
    menu_additem(menu, "UAV", _, _, cb);
    menu_additem(menu, "Care Package", _, _, cb);
    menu_additem(menu, "Counter-UAV", _, _, cb);
    menu_additem(menu, "Predator Missle", _, _, cb);
    menu_additem(menu, "Airstrike", _, _, cb);
    menu_additem(menu, "EMP", _, _, cb);
    menu_additem(menu, "Nuke", _, _, cb);
    menu_setprop(menu, MPROP_EXITNAME, "Wyjdz^n\yKill Streak v1.12 by \rCypis");
    menu_display(id, menu)
}

public Nagrody_Callback(id, menu, item)
{
    if(!uav[id] && item == 0)
        return ITEM_DISABLED;
        
    if(!pack[id] && item == 1)
        return ITEM_DISABLED;
        
    if(!cuav[id]&& item == 2)
        return ITEM_DISABLED;
        
    if(!predator[id] && item == 3)
        return ITEM_DISABLED;
        
    if(!nalot[id] && item == 4)
        return ITEM_DISABLED;
        
    if(!emp[id] && item == 5)
        return ITEM_DISABLED;
        
    if(!nuke[id] && item == 6)
        return ITEM_DISABLED;
        
    return ITEM_ENABLED;
}
    
public Nagrody_Handler(id, menu, item)
{
    if(!is_user_alive(id))
        return PLUGIN_HANDLED;
    
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    
    switch(item)
    {
        case 0:{
            if(!emp_czasowe[id])
                CreateUVA(id)
        }
        case 1:{
            if(!emp_czasowe[id])
                CreatePack(id)
        } 
        case 2:{
            if(!emp_czasowe[id])
                CreateCUVA(id)
        } 
        case 3:{
            if(!emp_czasowe[id])
                CreatePredator(id)
        } 
        case 4:{
            if(!emp_czasowe[id])
                CreateNalot(id)
        } 
        case 5:{
            if(!emp_czasowe[id])
                CreateEmp(id)
        } 
        case 6: CreateNuke(id)
    }        
    return PLUGIN_HANDLED;
}

public client_putinserver(id){
    licznik_zabic[id] = 0;
    user_controll[id] = 0
    nalot[id] = 0;
    predator[id] = 0
    nuke[id] = false;
    radar[id] = false;
    cuav[id] = false;
    uav[id] = false;
    emp[id] = false;
    pack[id] = false;
}

public SmiercGracza(id, attacker, shouldgib)
{    
    if(is_user_alive(attacker) && is_user_connected(attacker))
    {
        if(get_user_team(attacker) != get_user_team(id))
        {
            new name[32]
            licznik_zabic[attacker]++;
            set_dhudmessage2(42, 42, 255, -1.0, 0.30, 2, 0.0, 3.0, 0.02, 0.02, true)
            get_user_name(attacker,name,31);
            if(licznik_zabic[attacker] > 0)
            {
                switch(licznik_zabic[attacker])
                {
                    case 3:
                    {
                        uav[attacker] = true;
                        show_dhudmessage2(0, "", name, licznik_zabic[attacker]);
                        client_print(attacker, print_chat, "UAV Recon standing by. Press 4 or type /ks");
                        client_cmd(attacker, "spk sound/mw/uav_give.wav")
                    }
                    case 4:
                    {
                        switch(random_num(0,1))
                        {
                            case 0:{
                                pack[attacker] = true;
                                show_dhudmessage2(0, "", name, licznik_zabic[attacker]);
                                client_print(attacker, print_chat, "Care Package ready. Press 4 or type /ks");
                            }
                            case 1:{
                                cuav[attacker] = true;
                                show_dhudmessage2(0, "", name, licznik_zabic[attacker]);
                                client_print(attacker, print_chat, "Counter-UAV waiting for your go. Press 4 or type /ks");
                                client_cmd(attacker, "spk sound/mw/counter_give.wav")
                            }
                        }
                    }
                    case 5:
                    {
                        predator[attacker]++;
                        show_dhudmessage2(0, "", name, licznik_zabic[attacker]);
                        client_print(attacker, print_chat, "Predator Missile ready to strike. Press 4 or type /ks");
                        client_cmd(attacker, "spk sound/mw/predator_give.wav")
                    }
                    case 6:
                    {
                        nalot[attacker]++;
                        show_dhudmessage2(0, "", name, licznik_zabic[attacker]);
                        client_print(attacker, print_chat, "Harrier Aistrike ready. Press 4 or type /ks");
                        client_cmd(attacker, "spk sound/mw/air_give.wav")
                    }
                    case 15:
                    {
                        emp[attacker] = true;
                        show_dhudmessage2(0, "", name, licznik_zabic[attacker]);
                        client_print(attacker, print_chat, "EMP ready. Press 4 or type /ks");
                        client_cmd(attacker, "spk sound/mw/emp_give.wav")
                    }
                    case 20:
                    {
                        nuke[attacker] = true;
                        show_dhudmessage2(0, "", name, licznik_zabic[attacker]);
                        client_print(attacker, print_chat, "Tactical Nuke ready. Press 4 or type /ks");
                        client_cmd(attacker, "spk sound/mw/nuke_give.wav")
                        licznik_zabic[attacker] = false;
                    }
                }
            }
        }
    }
    if(!is_user_alive(id))
    {
        licznik_zabic[id] = 0;
        user_controll[id] = 0
    }
}

//uav
public CreateUVA(id)
{
    uav[id] = false;
    radar[id] = true;
    new num, players[32]
    get_players(players, num, "gh")
    for(new a = 0; a < num; a++)
    {
        new i = players[a]
        if(get_user_team(id) != get_user_team(i))
            client_cmd(i, "spk sound/mw/uav_enemy.wav")
        else
            client_cmd(i, "spk sound/mw/uav_friend.wav")
    }
    radar_scan()
}

public radar_scan()
{
    new PlayerCoords[3];
                
    for (new id=1; id<=32; id++)
    {
        if(!is_user_alive(id) || !radar[id] || emp_czasowe[id])
            continue;
                        
        for (new i=1;i<=32;i++)
        {       
            if(!is_user_alive(i) || get_user_team(i) == get_user_team(id)) 
                continue;
            
            get_user_origin(i, PlayerCoords)

            message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostagePos"), {0,0,0}, id)
            write_byte(id)
            write_byte(i)           
            write_coord(PlayerCoords[0])
            write_coord(PlayerCoords[1])
            write_coord(PlayerCoords[2])
            message_end()
                                
            message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostageK"), {0,0,0}, id)
            write_byte(i)
            message_end()
        }
    }
}    
//dotyk enta
public fw_Touch(ent, id)
{
    if (!pev_valid(ent)) 
        return FMRES_IGNORED
    
    new class[32];
    pev(ent, pev_classname, class, charsmax(class))
    if(equal(class, "Pack") && pev_valid(id))
    {
        if((pev(id, pev_flags) & FL_CLIENT) && (pev(ent, pev_flags) & FL_ONGROUND))
        {
            new weapons[32];
            new weaponsnum;
            get_user_weapons(id, weapons, weaponsnum);
            for(new i=0; i<weaponsnum; i++)
                if(maxAmmo[weapons[i]] > 0)
                    cs_set_user_bpammo(id, weapons[i], maxAmmo[weapons[i]]);
            
            fm_give_item(id, "weapon_hegrenade")
            fm_give_item(id, "weapon_flashbang")
            fm_give_item(id, "weapon_flashbang")            
            fm_give_item(id, "weapon_smokegrenade");
            
            fm_remove_entity(ent)
            return FMRES_IGNORED
        }
    }
    if(equal(class, "Bomb"))
    {
        bombs_explode(ent, 100.0, 150.0)
        fm_remove_entity(ent)
        return FMRES_IGNORED
    }
    if(equal(class, "Predator"))
    {
        new owner = pev(ent, pev_owner)
        bombs_explode(ent, 220.0, 400.0)
        fm_attach_view(owner, owner)
        user_controll[owner] = 0
        fm_remove_entity(ent)
        return FMRES_IGNORED
    }
    return FMRES_IGNORED
} 
//airpack
public CreatePack(id)
{
    CreatePlane(id)
    pack[id] = false
    set_task(1.0, "airpack", id+742)
}

public airpack(taskid)
{
    new id = (taskid - 742)
    
    PobraneOrigin[2] += 150; 
    
    new Float:LocVecs[3]; 
    IVecFVec(PobraneOrigin, LocVecs); 
    
    new g_pack = fm_create_entity("info_target")
    fm_create_ent(id, g_pack, "Pack", "models/cod_carepackage.mdl", 1, 6, LocVecs)
}

//counter-uva
public CreateCUVA(id)
{
    cuav[id] = false
    new num, players[32]
    get_players(players, num, "gh")
    for(new a = 0; a < num; a++)
    {
        new i = players[a]
        if(get_user_team(id) != get_user_team(i))
        {
            client_cmd(i, "spk sound/mw/counter_enemy.wav")
            radar[i] = false;
        }
        else
            client_cmd(i, "spk sound/mw/counter_friend.wav")
    }
}
//emp
public CreateEmp(id)
{
    client_cmd(0, "spk sound/mw/emp_effect.wav")
    emp[id] = false;
    new num, players[32]
    get_players(players, num, "gh")
    for(new a = 0; a < num; a++)
    {
        new i = players[a]
        if(get_user_team(id) != get_user_team(i))
        {
            if(is_user_alive(i))
            {
                Display_Fade(i,1<<12,1<<12,1<<16,255, 255,0,166)
                message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HideWeapon"), _, i) 
                write_byte((1<<0)|(1<<3)|(1<<5)) 
                message_end() 
            }
            client_cmd(i, "spk sound/mw/emp_enemy.wav")
            emp_czasowe[i] = true;
        }
        else
            client_cmd(i, "spk sound/mw/emp_friend.wav")
    }
    set_task(90.0,"usun_emp", id+2315)
}

public usun_emp(taskid)
{
    new id = (taskid - 2315);
    
    new num, players[32]
    get_players(players, num, "gh")
    for(new a = 0; a < num; a++)
    {
        new i = players[a]
        if(get_user_team(id) != get_user_team(i))
        {
            if(is_user_alive(i))
            {
                message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HideWeapon"), _, i) 
                write_byte(0) 
                message_end()
            }
            emp_czasowe[i] = false;
        }
    }
}

public CurWeapon(id)
{
    if(emp_czasowe[id])
    {
        message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HideWeapon"), _, id) 
        write_byte((1<<0)|(1<<3)|(1<<5)) 
        message_end() 
    }
}

//nuke
public CreateNuke(id)
{
    new num, players[32]
    get_players(players, num, "gh")
    for(new a = 0; a < num; a++)
    {
        new i = players[a]
        if(is_user_alive(i))
            Display_Fade(i,10<<12,10<<12,1<<16,255, 42, 42,171)
            
        if(get_user_team(id) != get_user_team(i))
            client_cmd(i, "spk sound/mw/nuke_enemy.wav")
        else
            client_cmd(i, "spk sound/mw/nuke_friend.wav")
    }
    set_task(10.0,"trzesienie")
    set_task(13.5,"usun", id)
    nuke[id] = false;
}

public trzesienie()
{
    new num, players[32]
    get_players(players, num, "gh")
    for(new a = 0; a < num; a++)
    {
        new i = players[a]
        if(is_user_alive(i))
        {
            Display_Fade(i,3<<12,3<<12,1<<16,255, 85, 42,215)
            message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0,0,0}, i)
            write_short(255<<12)
            write_short(4<<12) 
            write_short(255<<12) 
            message_end()
        }
    }
}

public usun(id)
{
    new num, players[32]
    get_players(players, num, "gh")
    for(new a = 0; a < num; a++)
    {
        new i = players[a]
        if(is_user_alive(i))
        {
            if(get_user_team(id) != get_user_team(i))
            {
                fm_set_user_frags(id, get_user_frags(id)+1);
            }
            user_silentkill(i)
        }
    }
}
//nalot
public CreateNalot(id)
{
    new num, players[32]
    get_players(players, num, "gh")
    for(new a = 0; a < num; a++)
    {
        new i = players[a]
        if(get_user_team(id) != get_user_team(i))
            client_cmd(i, "spk sound/mw/air_enemy.wav")
        else
            client_cmd(i, "spk sound/mw/air_friend.wav")
    }
    set_task(1.0, "CreateBombs", id+997, _, _, "a", 3);
    CreatePlane(id)
    nalot[id]--;
}

public usun_ent()
    fm_remove_entity_name("Samolot");

public CreateBombs(taskid)
{    
    new id = (taskid-997)

    new g_bomby[15], radlocation[3], randomx, randomy; 

    PobraneOrigin[2] += 50; 
    
    for(new i=0; i<15; i++) 
    {
        randomx = random_num(-150,150); 
        randomy = random_num(-150,150); 
        
        radlocation[0] = PobraneOrigin[0]+1*randomx; 
        radlocation[1] = PobraneOrigin[1]+1*randomy; 
        radlocation[2] = PobraneOrigin[2]; 

        new Float:LocVec[3]; 
        IVecFVec(radlocation, LocVec); 
        
        g_bomby[i] = fm_create_entity("info_target")
        fm_create_ent(id, g_bomby[i], "Bomb", "models/p_hegrenade.mdl", 2, 10, LocVec)
    }
}  

public CreatePlane(id)
{
    new Float:Origin[3], Float: Angle[3], Float: Velocity[3];

    get_user_origin(id, PobraneOrigin, 3);
    
    velocity_by_aim(id, 1000, Velocity);
    pev(id, pev_origin, Origin);
    pev(id, pev_v_angle, Angle); 
    
    Origin[2] += 250;
    Angle[0] = 0.0;
    Velocity[2] = Origin[2];
    
    new ent = fm_create_entity("info_target");
    fm_create_ent(id, ent, "Samolot", "models/cod_plane.mdl", 2, 8, Origin);
    
    set_pev(ent, pev_velocity, Velocity);
    set_pev(ent, pev_angles, Angle);
    
    emit_sound(ent, CHAN_ITEM, "mw/jet_fly1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
    set_task(4.5, "usun_ent");
}

//predator
public CreatePredator(id){
    new num, players[32]
    get_players(players, num, "gh")
    for(new a = 0; a < num; a++)
    {
        new i = players[a]
        if(get_user_team(id) != get_user_team(i))
            client_cmd(i, "spk sound/mw/predator_enemy.wav")
        else
            client_cmd(i, "spk sound/mw/predator_friend.wav")
    }
    
    new Float:Origin[3], Float:Angle[3], Float:Velocity[3]
    
    velocity_by_aim(id, 700, Velocity)
    pev(id, pev_origin, Origin)
    pev(id, pev_v_angle, Angle)
    
    Angle[0] *= -1.0

    new g_predator = fm_create_entity("info_target")
    fm_create_ent(id, g_predator, "Predator", "models/cod_predator.mdl", 2, 5, Origin)
    
    set_pev(g_predator, pev_velocity, Velocity)
    set_pev(g_predator, pev_angles, Angle)
        
    message_begin( MSG_BROADCAST, SVC_TEMPENTITY)
    write_byte(TE_BEAMFOLLOW)
    write_short(g_predator)
    write_short(cache_trail)
    write_byte(10)
    write_byte(5)
    write_byte(205)
    write_byte(237)
    write_byte(163)
    write_byte(200)
    message_end()
    
    predator[id] = false;
    
    fm_attach_view(id, g_predator)
    user_controll[id] = g_predator
} 

public player_predator(id)
{                        
    if(user_controll[id] > 0)
    {
        new ent = user_controll[id]
        if (pev_valid(ent))
        {
            new Float:Velocity[3], Float:Angle[3]
            velocity_by_aim(id, 500, Velocity)
            pev(id, pev_v_angle, Angle)
            
            set_pev(ent, pev_velocity, Velocity)
            set_pev(ent, pev_angles, Angle)
        }
        else
        {
            fm_attach_view(id, id)
        }
    }  
}

bombs_explode(ent, Float:zadaje, Float:promien)
{
    if (!pev_valid(ent)) 
        return;
    
    new attacker = pev(ent, pev_owner)
    
    new Float:entOrigin[3], Float:fDistance, Float:fDamage, Float:vOrigin[3]
    pev(ent, pev_origin, entOrigin)
    entOrigin[2] += 1.0
    
    new victim = -1
    while((victim = engfunc(EngFunc_FindEntityInSphere, victim, entOrigin, promien)) != 0)
    {
        if (attacker==victim || !pev_valid(victim))
            continue;
        
        pev(victim, pev_origin, vOrigin)
        fDistance = get_distance_f(vOrigin, entOrigin)
        fDamage = zadaje - floatmul(zadaje, floatdiv(fDistance, promien))
        fDamage *= estimate_take_hurt(entOrigin, victim, 0)
        if(fDamage>0.0)
        {
            if(get_user_team(attacker)!=get_user_team(victim)) 
                if(pev(victim, pev_health) > 0.0)
                    ExecuteHam(Ham_TakeDamage, victim, ent, attacker, fDamage, DMG_BULLET)
        }
    }
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
    write_byte(TE_EXPLOSION);
    write_coord(floatround(entOrigin[0]));
    write_coord(floatround(entOrigin[1])); 
    write_coord(floatround(entOrigin[2]));
    write_short(sprite_blast);
    write_byte(32);
    write_byte(20); 
    write_byte(0);
    message_end();
}

public cmdKill()
    return FMRES_IGNORED;

stock fm_create_ent(id, ent, const szName[], const szModel[], iSolid, iMovetype, Float:fOrigin[3])
{
    if(!pev_valid(ent))
            return;
    
    set_pev(ent, pev_classname, szName)
    engfunc(EngFunc_SetModel, ent, szModel)
    set_pev(ent, pev_solid, iSolid)
    set_pev(ent, pev_movetype, iMovetype)
    set_pev(ent, pev_owner, id)
    set_pev(ent, pev_origin, fOrigin)
}

stock Float:estimate_take_hurt(Float:fPoint[3], ent, ignored) 
{
    new Float:fOrigin[3]
    new tr
    new Float:fFraction
    pev(ent, pev_origin, fOrigin)
    engfunc(EngFunc_TraceLine, fPoint, fOrigin, DONT_IGNORE_MONSTERS, ignored, tr)
    get_tr2(tr, TR_flFraction, fFraction)
    if(fFraction == 1.0 || get_tr2(tr, TR_pHit) == ent)
        return 1.0
    return 0.6
}

stock Display_Fade(id,duration,holdtime,fadetype,red,green,blue,alpha)
{
    message_begin(MSG_ONE, get_user_msgid("ScreenFade"),{0,0,0},id);
    write_short(duration);
    write_short(holdtime );
    write_short(fadetype);
    write_byte(red);
    write_byte(green);
    write_byte(blue);
    write_byte(alpha);
    message_end();
}

//dhudmessage
new dhud_color;
new dhud_x;
new dhud_y;
new dhud_effect;
new dhud_fxtime;
new dhud_holdtime;
new dhud_fadeintime;
new dhud_fadeouttime;
new dhud_reliable;

stock set_dhudmessage2(red = 0, green = 160, blue = 0, Float:x = -1.0, Float:y = 0.65, effects = 2, Float:fxtime = 6.0, Float:holdtime = 3.0, Float:fadeintime = 0.1, Float:fadeouttime = 1.5, bool:reliable = false)
{
    #define clamp_byte(%1)       (clamp(%1, 0, 255))
    #define pack_color(%1,%2,%3) (%3 + (%2<<8) + (%1<<16))

    dhud_color     = pack_color(clamp_byte(red), clamp_byte(green), clamp_byte(blue));
    dhud_x        = _:x;
    dhud_y        = _:y;
    dhud_effect    = effects;
    dhud_fxtime    = _:fxtime;
    dhud_holdtime    = _:holdtime;
    dhud_fadeintime    = _:fadeintime;
    dhud_fadeouttime = _:fadeouttime;
    dhud_reliable    = _:reliable;
    return 1;
}

stock show_dhudmessage2(index, const message[], any:...)
{
    new buffer[128];
    new numArguments = numargs();

    if(numArguments == 2)
        send_dhudMessage2(index, message);
    else if(index || numArguments == 3)
    {
        vformat(buffer, charsmax(buffer), message, 3);
        send_dhudMessage2(index, buffer);
    }
    else
    {
        new playersList[32], numPlayers;
        get_players(playersList, numPlayers, "ch");

        if(!numPlayers)
            return 0;

        new Array:handleArrayML = ArrayCreate();

        for(new i = 2, j; i < numArguments; i++)
        {
            if(getarg(i) == LANG_PLAYER)
            {
                while((buffer[j] = getarg(i + 1, j++))) {}
                j = 0;

                if(GetLangTransKey(buffer) != TransKey_Bad)
                    ArrayPushCell(handleArrayML, i++);
            }
        }

        new size = ArraySize(handleArrayML);

        if(!size)
        {
            vformat(buffer, charsmax(buffer), message, 3);
            send_dhudMessage2(index, buffer);
        }
        else
        {
            for(new i = 0, j; i < numPlayers; i++)
            {
                index = playersList[i];

                for(j = 0; j < size; j++)
                    setarg(ArrayGetCell(handleArrayML, j), 0, index);

                vformat(buffer, charsmax(buffer), message, 3);
                send_dhudMessage2(index, buffer);
            }
        }
        ArrayDestroy(handleArrayML);
    }
    return 1;
}

stock send_dhudMessage2(const index, const message[])
{
    message_begin(dhud_reliable? (index? MSG_ONE: MSG_ALL): (index? MSG_ONE_UNRELIABLE: MSG_BROADCAST), SVC_DIRECTOR, _, index);
    {
        write_byte(strlen(message) + 31);
        write_byte(DRC_CMD_MESSAGE);
        write_byte(dhud_effect);
        write_long(dhud_color);
        write_long(dhud_x);
        write_long(dhud_y);
        write_long(dhud_fadeintime);
        write_long(dhud_fadeouttime);
        write_long(dhud_holdtime);
        write_long(dhud_fxtime);
        write_string(message);
    }
    message_end();
} 
