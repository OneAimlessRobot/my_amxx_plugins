#include "../include/amxmodx.inc"
#include "../include/fun.inc"
#include "../include/reapi.inc"
#include "../include/fakemeta.inc"
#include "../include/cstrike.inc"
#include "my_include/my_author_header.inc"

#define PLUGIN "amx scoreboard"
#define VERSION "1.0.0"
#define HEADER_FMT "| [%-5.4s]| %-32.31s | %-11.10s | %-13.12s | %-6.5s | %-9.9s | %-10.9s | %-32.31s | %-9.9s |^n"
#define PLAYER_LINE_FMT "| [%-5d]| %-32.31s | %-5.4s/%-5.4s | %-6d/%-6d | %-6d | %-4d/%-4d | %-10.9s | %-32.31s | %-4d/%-4d |"
#define TEAM_HEADER_FMT "Team: %-32.31sn_players: %-3dScore: %-4d^n"

#define HEADER_FMT_OFF_GAME "| [%-5.4s]| %-32.31s | %-10.9s | %-32.31s | %-9.9s |^n"
#define PLAYER_LINE_FMT_OFF_GAME "| [%-5d]| %-32.31s | %-10.9s | %-32.31s | %-4d/%-4d |^n"
#define TEAM_HEADER_FMT_OFF_GAME "Team: %-32.31s^n"

#define ROW_LENGTH 2561

#define TEAM_IS_OFF_GAME(%1)  ((%1)>1)

new const CsTeams:team_print_ordering[_:CS_TEAM_SPECTATOR+1]={

    CS_TEAM_T,
    CS_TEAM_CT,
    CS_TEAM_SPECTATOR,
    CS_TEAM_UNASSIGNED

}
new const team_names[_:CS_TEAM_SPECTATOR+1][]={

    "Unassigned",
    "Terrorist",
    "Counter-Terrorist",
    "Spectator"
}

new const CSGameRules_Members:team_quotas_consts[_:CS_TEAM_SPECTATOR+1]={
            
            CSGameRules_Members: -1,
            m_iNumTerrorist,
            m_iNumCT,
            CSGameRules_Members:-1

}
new const CSGameRules_Members:team_scores_consts[_:CS_TEAM_SPECTATOR+1]={
    CSGameRules_Members:-1,
	m_iNumTerroristWins,
	m_iNumCTWins,
    CSGameRules_Members:-1

}

new header_buff[ROW_LENGTH],
    off_game_header_buff[ROW_LENGTH]

//called ONLY ONCE


build_header(){
    arrayset(header_buff,0,sizeof header_buff)
    
    format(header_buff, charsmax(header_buff),HEADER_FMT,
                "pgid",
                "user_name",
                "alive/god",
                "hp/ap",
                "money",
                "frag/death",
                "human/bot",
                "authid",
                "ping/loss")
}
build_off_game_header(){

    arrayset(off_game_header_buff,0,sizeof off_game_header_buff)

    format(off_game_header_buff, charsmax(off_game_header_buff),HEADER_FMT_OFF_GAME,
                "pgid",
                "user_name",
                "human/bot",
                "authid",
                "ping/loss")
}

print_team_header(team_ordinal,&CsTeams:stored_team=CsTeams:0){

    stored_team=team_print_ordering[team_ordinal]

    if(TEAM_IS_OFF_GAME(team_ordinal)){


        server_print(TEAM_HEADER_FMT_OFF_GAME,
                            team_names[_:stored_team])
        
    }
    else{
        server_print(TEAM_HEADER_FMT,
                            team_names[_:stored_team],
                            (team_quotas_consts[_:stored_team]==CSGameRules_Members:-1)?-1:
                        get_member_game(team_quotas_consts[_:stored_team]),
                        (team_scores_consts[_:stored_team]==CSGameRules_Members:-1)?-1:
                        get_member_game(team_scores_consts[_:stored_team]))
    }
}
build_player_line(id,team_ordinal,buff[ROW_LENGTH]){

    arrayset(buff,0,sizeof buff)

    static user_name[64],user_authid[64]

    get_user_name(id,user_name,(sizeof user_name)-1)
    
    get_user_authid(id,user_authid,(sizeof user_authid)-1)

    new ping=0,loss=0,result=get_user_ping(id,ping,loss)

    if(!result) return //get rid of annoying warning. this should never return early here
    
          
    if(TEAM_IS_OFF_GAME(team_ordinal)){

        formatex(buff,(sizeof buff)-1,PLAYER_LINE_FMT_OFF_GAME,
                                id,
                                user_name,
                                is_user_bot(id)?"[ BOT ]":"[ HUMAN ]",
                                user_authid,
                                is_user_bot(id)?-1:ping,is_user_bot(id)?-1:loss)
    }
    else{

        formatex(buff,(sizeof buff)-1,PLAYER_LINE_FMT,
                                    id,
                                    user_name,
        is_user_alive(id)?"Yes!":"Nuh.",get_user_godmode(id)?"Yes!":"Nuh.",
                                    get_user_health(id),get_user_armor(id),
                                    cs_get_user_money(id),
                                    get_user_frags(id),get_user_deaths(id),
                                    is_user_bot(id)?"[ BOT ]":"[ HUMAN ]",
                                    user_authid,
                                    is_user_bot(id)?-1:ping,is_user_bot(id)?-1:loss)           
    }
}
public plugin_init(){

    register_plugin(PLUGIN, VERSION, AUTHOR);
    build_header()
    build_off_game_header()
    register_srvcmd("amx_score", "amx_score")
}


public amx_score(){

    server_print("Scoreboard print requested!^nHere is the scoreboard:^n")

    static player_line[ROW_LENGTH]

    for(new j=0;j<sizeof team_print_ordering;j++){
        
        static CsTeams:team=CsTeams:0;

        print_team_header(j,team)
        
        server_print("%s",TEAM_IS_OFF_GAME(j)?off_game_header_buff:header_buff)
        for(new i=0;i<33;i++){ 
            
            if(!is_user_connected(i)) continue

            if(cs_get_user_team(i) != team) continue
            
            build_player_line(i,j,player_line)
            server_print("%s",player_line)

        }
        server_print("^n")
    }


    return PLUGIN_HANDLED
}