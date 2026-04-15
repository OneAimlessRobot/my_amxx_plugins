#include "../include/amxmodx.inc"
#include "../include/fun.inc"
#include "../include/reapi.inc"
#include "../include/fakemeta.inc"
#include "../include/cstrike.inc"
#include "my_include/my_author_header.inc"

#define PLUGIN "amx scoreboard"
#define VERSION "1.0.0"
#define HEADER_FMT "| [%-4.3s]| %-32.31s | %-11.10s | %-13.12s | %-6.5s | %-9.9s | %-9.9s |^n"
#define PLAYER_LINE_FMT "| [%-4d]| %-32.31s | %-5.4s/%-5.4s | %-6d/%-6d | %-6d | %-4d/%-4d | %-4d/%-4d |"
#define PLAYER_LINE_FMT_OFF_GAME "| [%-4d]| %-32.31s |"
#define TEAM_HEADER_FMT "Team: %-32.31sn_players: %-3dScore: %-4d^n"
#define ROW_LENGTH 128

/**
 * Counter-Strike team id constants.
enum CsTeams
{
	CS_TEAM_UNASSIGNED = 0,
	CS_TEAM_T          = 1,
	CS_TEAM_CT         = 2,
	CS_TEAM_SPECTATOR  = 3,
}
 */

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

enum col_order{

    EDICT_ID_COL_ID=0,
    USER_NAME_COL_ID,
    ALIVE_GOD_COL_ID,
    HP_AP_COL_ID,
    MONEY_COL_ID,
    FRAGS_DEATHS_COL_ID,
    PING_COL_ID,
    MAX_COL_ORDER
}
new header_buff[ROW_LENGTH]

//called ONLY ONCE


build_header(){

    arrayset(header_buff,0,sizeof header_buff)

    format(header_buff, charsmax(header_buff),HEADER_FMT,
                "pid",
                "user_name",
                "alive/god",
                "hp/ap",
                "money",
                "frag/death",
                "ping/loss")
}

print_team_header(CsTeams:team){

    server_print(TEAM_HEADER_FMT,
                        team_names[_:team],
                        (team_quotas_consts[_:team]==CSGameRules_Members:-1)?-1:
                       get_member_game(team_quotas_consts[_:team]),
                       (team_scores_consts[_:team]==CSGameRules_Members:-1)?-1:
                       get_member_game(team_scores_consts[_:team]))
}
build_player_line(id,buff[ROW_LENGTH]){

    arrayset(buff,0,sizeof buff)

    static user_name[64]
    get_user_name(id,user_name,(sizeof user_name)-1)
    new ping=0,loss=0,result=get_user_ping(id,ping,loss)

    if(!result) return //get rid of annoying warning. this should never return early here
    
    formatex(buff,(sizeof buff)-1,PLAYER_LINE_FMT,
                                id,
                                user_name,
    is_user_alive(id)?"Yes!":"Nuh.",get_user_godmode(id)?"Yes!":"Nuh.",
                                get_user_health(id),get_user_armor(id),
                                cs_get_user_money(id),
                                get_user_frags(id),get_user_deaths(id),
                                is_user_bot(id)?-1:ping,is_user_bot(id)?-1:loss)
}
build_player_line_spec_unassigned(id,buff[ROW_LENGTH]){

    arrayset(buff,0,sizeof buff)

    static user_name[64]
    get_user_name(id,user_name,(sizeof user_name)-1)

    formatex(buff,(sizeof buff)-1,PLAYER_LINE_FMT_OFF_GAME,
                                id,
                                user_name)
}
public plugin_init(){

    register_plugin(PLUGIN, VERSION, AUTHOR);
    build_header()
    register_srvcmd("amx_scoreboard", "amx_scoreboard")
}


public amx_scoreboard(){

    server_print("Scoreboard print requested!^nHere is the scoreboard:^n")

    static player_line[ROW_LENGTH]

    for(new i=0;i<sizeof team_print_ordering;i++){
        static CsTeams:team;
        team=team_print_ordering[i]

        print_team_header(team)
        if(i<=1){
            server_print("%s",header_buff)
        }
        for(new i=0;i<33;i++){ 
            
            if(!is_user_connected(i)) continue

            if(cs_get_user_team(i) != team) continue
            switch(team){
                case CS_TEAM_T:{
                    
                    build_player_line(i,player_line)
                }
                case CS_TEAM_CT:{
                    
                    build_player_line(i,player_line)
                }
                default:{

                    build_player_line_spec_unassigned(i,player_line)
                }
            }
            server_print("%s",player_line)

        }
        server_print("^n")
    }


    return PLUGIN_HANDLED
}