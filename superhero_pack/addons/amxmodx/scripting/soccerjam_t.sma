#pragma dynamic 131072 //I used to much memory =(
/*
 *	CVARs:
 *		- These CVARS can be changed at any time during round!
 *		sj_players			(default: 6)	- Players needed per team for a match.
 *		sj_time				(default: 30)	- Minutes of combined both quarters.
 *		sj_ballspawndist	(default: 80)	- Ball distance % between 1-100, for how close it is to center of the field for opposite team who scored.
 *		sj_kick 			(default: 1000)	- Kicking velocity.
 *		sj_reset 			(default: 30.0)	- Ball reset time, to respawn at ball spawn location.
 *		sj_goalsafety 		(default: 300)	- Distance around Comm Chair, that does damage to enemy.
 *		sj_point_multiplier	(default: 10.0)	- Amount of points needed per credit (for Half-Time credits).
 *		sj_afk_time			(default: 3)	- Time before kicked if not ready when X amount of players are ready.
 *		sj_afk_pct			(default: 60) 	- Percent of players needed to be ready for afk kicker to take hold.
 *
 *	Commands:
 *		amx_endgame		- Ends a game and resets back to PRE-GAME setup. (Can be done at any time.)
 *
 *
 *  Version : 	1.3
 *	Requires:	AMXX 1.76f
 *
 *	Author:		OneEyed
 *	Email:		joelruiz2@gmail.com
 *	IRC:		#soccerjam (irc.gamesurge.net) 
 */

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <cstrike>
#include <fun>

#define MAX_TEXT_BUFFER 2047
#define MAX_NAME_LENGTH 33
#define MAX_PLAYER 33
#define MAX_ASSISTERS 3

#define POS_X 		-1.0
#define POS_Y 		0.85

#define TEAMS 4

#define T	1
#define CT	2
#define SPECTATOR 3

#define TYPE_TOURNAMENT 		100
#define TYPE_PUG				200


static const TeamMascots[TEAMS][] = {
	"NULL",
	"models/kingpin.mdl",
	"models/garg.mdl",
	"NULL"	
}

static const TeamNames[TEAMS][] = {
	"Unassigned",
	"Terr",
	"CT",
	"Spectator"
}


#define MODE_NONE 		0
#define MODE_PREGAME 	1
#define MODE_GAME 		2
#define MODE_HALFTIME 	3
#define MODE_SHOOTOUT 	4
#define MODE_OVERTIME 	5

new GAME_MODE

#define SHOTCLOCK_TIME 			12
#define COUNTDOWN_TIME 			10
#define STARTING_CREDITS 		12.0
#define REQUIRED_TEAM_PLAYERS 	6
#define BASE_HP 				100
#define BASE_SPEED 				250.0
#define BASE_DISARM				5

#define GOALY_POINTS_CAMP	3

#define HEALTH_REGEN_AMOUNT 		12
#define MAX_GOALY_DISTANCE			600
#define MAX_GOALY_DELAY				7.0
#define MAX_ENEMY_SHOOTOUT_DIST 	1200
#define MAX_POWERPLAY				5
//Muliply our upgrades by this amount
#define AMOUNT_POWERPLAY 			5

//Curve Ball Defines
#define CURVE_ANGLE		15	//Angle for spin kick multipled by current direction.
#define CURVE_COUNT		6	//Curve this many times.
#define CURVE_TIME		0.2	//Time to curve again.
#define DIRECTIONS		2	//# of angles allowed.
#define	ANGLEDIVIDE		6	//Divide angle this many times for curve.

#define POINTS_GOALY_CAMP 	0.2
#define POINTS_GOAL			0.8
#define POINTS_ASSIST		0.8
#define POINTS_STEAL		0.3
#define POINTS_KILL			0.2
//#define POINTS_POWERPLAY 	0.05
#define POINTS_POSESSION	0.05
#define POINTS_GOALSAVE 	0.1
#define POINTS_DISTANCE 	float(amt)/300.0

#define AMOUNT_STA 		20	//Health
#define AMOUNT_STR 		25	//Stronger kicking
#define AMOUNT_AGI 		13	//Faster Speed 
#define AMOUNT_DEX 		18	//Better Catching
#define AMOUNT_DISARM 	6	//Disarm ball chance (disarm lvl * this) if random num up 1-100 < disarm
#define MAXLEVEL_BONUS 	0

#define RECORDS 7
enum {
	GOAL = 1,
	ASSIST,
	STEAL,
	KILL,
	POSSESSION,
	//POWERPLAY,
	GOALSAVE,
	DISTANCE,
}


#define UPGRADES 5
enum {
	STA = 1,	//stamina
	STR,		//strength
	AGI,		//agility
	DEX,		//dexterity
	DISARM,
}

static 	const 	UpgradeTitles[UPGRADES+1][] = { "NULL", "Stamina", "Strength", "Agility", "Dexterity", "Disarm" }
new 	const 	UpgradeMax[UPGRADES+1] = { 0, 5, 5, 5, 5, 5 }

new PowerPlay, powerplay_list[MAX_POWERPLAY+1]
new Float:fire_delay

new PlayerUpgrades[MAX_PLAYER][UPGRADES+1]
new GoalEnt[TEAMS]

new PressedAction[MAX_PLAYER]
new seconds[MAX_PLAYER]
new g_sprint[MAX_PLAYER]

new SideJump[MAX_PLAYER]
new Float:SideJumpDelay[MAX_PLAYER]
new PlayerDeaths[MAX_PLAYER]
new PlayerKills[MAX_PLAYER]
new Mascots[TEAMS]

new menu_upgrade[MAX_PLAYER]

new g_iTeamBall
new timer
new winner
new OverTime
new ShootOut
new GoalyPoints[MAX_PLAYER]
new Float:GoalyCheckDelay[MAX_PLAYER]
new GoalyCheck[MAX_PLAYER]
new candidates[TEAMS]
new LineUp[7]
new next

new bool:GameOver
new TimeLeft
new bool:Ready[MAX_PLAYER]

#define MAX_BALL_SPAWNS 5

new Float:BallSpawnOrigin[MAX_BALL_SPAWNS][3]
new ballspawncount

new Float:TeamBallOrigins[TEAMS][3]
new Float:TEMP_TeamBallOrigins[3]
//new TEMP_NetModel[32]
new Float:MascotsOrigins[3]
new Float:MascotsAngles[3]

new bool:freeze_player[MAX_PLAYER]

new NumPlayersOfMatch;
//#define RANKS 3
//new TopPlayer[2][RANKS+1][RECORDS+1]
new TopPlayer[2][RECORDS+1]
new MadeRecord[MAX_PLAYER][RECORDS+1]
new TopPlayerName[RECORDS+1][MAX_NAME_LENGTH]
new Float:g_Experience[MAX_PLAYER]

new PlayerDisconnectID[MAX_PLAYER]
new PlayerDisconnectCount;
//------------------------------------------------------------------------------------
//MODELS
//------------------------------------------------------------------------------------
//You may change the ball model. Just give correct path of new model.
new ball[] = "models/kickball/ball.mdl" //"models/kickball/chicken.mdl"


//------------------------------------------------------------------------------------
//GLOW COLORS 
//------------------------------------------------------------------------------------
//Only ball holder, Comm Chairs, and ball will glow!
//Format is (0-255) { Red , Green , Blue }
//Team ONE Color
new TeamColors[TEAMS][3]

//Ball color
new ballcolor[3] = { 255,200,100 } 	// YELLOW
//------------------------------------------------------------------------------------


//------------------DO NOT TOUCH BELOW THIS LINE, unless you know what your doing.---------------------------------

#define HUD_CHANNEL 4
#define MESSAGE_DELAY 4.0

new kicked[] = "kickball/kicked.wav"
new ballhit[] = "kickball/bounce.wav"
new distress[] = "kickball/distress.wav"
new returned[] = "kickball/returned.wav"
new amaze[] = "kickball/amaze.wav"
new laugh[] = "kickball/laugh.wav"
new perfect[] = "kickball/perfect.wav"
new diebitch[] = "kickball/diebitch.wav"
new pussy[] = "kickball/pussy.wav"
new prepare[] = "kickball/prepare.wav"
new gotball[] = "kickball/gotball.wav"
//new tomes[] = "kickball/tomes.wav"
new bday[] = "kickball/bday.wav"
new levelup[] = "kickball/levelup.wav"
new boomchaka[] = "kickball/boomchakalaka.wav"
new whistle[] = "kickball/whistle.wav"
new whistle_endgame[] = "kickball/whistle_endgame.wav";

new maxplayers

//Special FX//
new fire
new smoke
new beamspr
new Burn_Sprite
new g_fxBeamSprite

//Kickball Vars//
new ballholder
new ballowner
new aball
new is_kickball

new Float:testorigin[3], Float:velocity[3]
new ROUND
new score[TEAMS]
new scoreboard[1025]
new temp1[64], temp2[64]
new distorig[2][3] //distance recorder

new g_szGameTitle[32];

new gmsgDeathMsg

new g_msgTextMsg
new Float:g_Points[MAX_PLAYER];
new bool:RunOnce

new AUTHOR[] = "OneEyed"
static const VERSION[] = "1.3";

new curvecount
new direction
new Float:BallSpinDirection[3]
new bool:has_knife[MAX_PLAYER]

new goaldied[MAX_PLAYER]
new bool:is_dead[MAX_PLAYER]

new assist[16]
new iassist[TEAMS]

new P_TOURNY_ON;
new P_BALLSPAWN_DIST;
new P_PLAYERS;
new P_TIME;
new P_POINT_MULTI;
new P_RESET;
new P_GOALSAFETY;
new P_KICK;
new P_AFK_PCT;
new P_AFK_TIME;

/*====================================================================================================
 [Precache]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public plugin_precache() {
	precache_model(ball)
	
	beamspr = precache_model("sprites/laserbeam.spr")
	fire = precache_model("sprites/shockwave.spr")
	smoke = precache_model("sprites/steam1.spr")

	g_fxBeamSprite = precache_model("sprites/lgtning.spr")
	Burn_Sprite = precache_model("sprites/xfireball3.spr")
	
	precache_model( TeamMascots[T] )
	precache_model( TeamMascots[CT] )
	precache_model( "models/chick.mdl" )
	
	precache_sound(amaze)
	precache_sound(laugh)
	precache_sound(perfect)
	precache_sound(diebitch)
	precache_sound(pussy)
	precache_sound(prepare)
	precache_sound(ballhit)
	precache_sound(gotball)
	precache_sound(bday)
	precache_sound(returned)
	precache_sound(distress)
	precache_sound(kicked)
	precache_sound(levelup)

	precache_sound(boomchaka)
	precache_sound(whistle);
	precache_sound(whistle_endgame);
}

/*====================================================================================================
 [Initialize]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public plugin_init() {
	
	new g_MapName[65]
	get_mapname(g_MapName,64)
	
	register_cvar("soccer_jam_online","0",FCVAR_SERVER)
	register_cvar("soccer_jam_version", VERSION, FCVAR_SERVER);
	//register_cvar("soccer_jam_online", "0");
	//Check if entity is hardcoded/ripented in map
	
	if(is_kickball > 0) 
	{
		register_plugin("Soccer Jam Tourny(ON)", VERSION, AUTHOR)
		set_cvar_num("soccer_jam_online",1)
		
		TeamColors[T] = { 250, 10, 10 }
		TeamColors[CT] = { 10, 10, 250 }
		timer = COUNTDOWN_TIME
		
		g_msgTextMsg = get_user_msgid("TextMsg")
		gmsgDeathMsg = get_user_msgid("DeathMsg")
		
		
		maxplayers = get_maxplayers()
		
		if(equali(g_MapName,"soccerjam")) {
			CreateGoalNets(g_MapName)
			create_wall(g_MapName)
		}
		
		register_clcmd("say","handle_say")
		register_clcmd("say_team","handle_say")

		register_event("ResetHUD", "Event_ResetHud", "be")
		register_event("HLTV","Event_StartRound","a","1=0","2=0")
		register_event("Damage", "Event_Damage", "b", "2!0", "3=0", "4!0" );
		
		P_PLAYERS = register_cvar("sj_players", "6")
		P_TIME = register_cvar("sj_time", "30")
		P_POINT_MULTI = register_cvar("sj_point_multiplier","3.5")
		P_RESET = register_cvar("sj_reset","30.0")
		P_GOALSAFETY = register_cvar("sj_goalsafety","650")
		P_KICK = register_cvar("sj_kick","650")
		P_AFK_PCT = register_cvar("sj_afk_pct", "60");
		P_AFK_TIME = register_cvar("sj_afk_time", "3");
		//register_cvar("kickball_respawn","2.0")
		//register_cvar("kickball_random","1")
		//register_cvar("kickball_fov","105")
		register_cvar("SCORE_CT","0")
		register_cvar("SCORE_T","0")
		
		register_cvar("soccerjam_username", "")
		register_cvar("soccerjam_password", "")
		
		P_BALLSPAWN_DIST = register_cvar("sj_ballspawndist", "80" );
		P_TOURNY_ON = register_cvar("sj_tournamentmode", "1" );
	
		register_touch("PwnBall", "player", 			"touchPlayer")
		//register_touch("PwnBall", "GoalNet",			"touchCC")
		register_touch("PwnBall", "soccerjam_goalnet",	"touchCC")
		
		register_touch("PwnBall", "worldspawn",			"touchWorld")
		register_touch("PwnBall", "func_wall",			"touchWorld")
		register_touch("PwnBall", "func_door",			"touchWorld")
		register_touch("PwnBall", "func_door_rotating", "touchWorld")
		register_touch("PwnBall", "func_wall_toggle",	"touchWorld")
		register_touch("PwnBall", "func_breakable",		"touchWorld")
		
		register_touch("PwnBall", "Blocker",			"touchBlocker")
		
		set_task(0.4,"meter",0,"",0,"b")
		set_task(0.5,"statusDisplay",8787,"",0,"b")
		
		register_think("PwnBall","ball_think")
		register_think("Mascot", "mascot_think")
		
		register_clcmd("drop","Turbo")
		register_clcmd("fullupdate","fullupdate")
  	 	register_clcmd("lastinv","BuyUpgrade")
  	 	register_clcmd("radio1", "LeftDirection")
		register_clcmd("radio2", "RightDirection")
		register_concmd("amx_endgame", "cmdEndGame", ADMIN_KICK, "End's a current match");
		
		register_menucmd(register_menuid("Team_Select",1), (1<<0)|(1<<1)|(1<<4)|(1<<5), "team_select") 
		register_clcmd("jointeam 1", "vgui_jointeamone") 
		register_clcmd("jointeam 2", "vgui_jointeamtwo") 

		//register_forward(FM_EmitSound,"forward_emit_sound");
  	 	register_message(g_msgTextMsg, "editTextMsg")
  	 	TimeLeft = (get_pcvar_num(P_TIME) * 60);
  	 	GoalyPoints[0] = -1;
  	 	GAME_MODE = MODE_PREGAME
  	 	new id;
  	 	for(id=1; id<=maxplayers;id++)
  	 		g_Experience[id] = STARTING_CREDITS
  	 		
  	 	g_szGameTitle[0] = 0;
	}
	else {
		register_plugin("Soccer Jam Tourny(OFF)", "1.0", "OneEyed")
		set_cvar_num("soccer_jam_online",0)
	}
	return PLUGIN_HANDLED
}

public cmdEndGame(id,level,cid) {
	if(!cmd_access(id,level,cid,0))
		return PLUGIN_HANDLED
		
	new name[32];
	get_user_name(id, name, 31);
	client_print(0, print_chat, "[SOCCER JAM] - Game Ended by: %s", name)
	remove_task(55555);
	remove_task(9999);
	
	PostGame();
	
	//So we don't get respawned/reset by other events.
	server_cmd("sv_restart 100000000") 
	return PLUGIN_HANDLED
}

public team_select(id, key) { 
	if (key==0 || key==1 || key==4) 
		if(join_team(id, key))
			return PLUGIN_HANDLED
	return PLUGIN_CONTINUE 
} 

public vgui_jointeamone(id)
{
	if(join_team(id, 0))
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE 
}

public vgui_jointeamtwo(id)
{
	if(join_team(id, 1))
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE 
}
/*
public team_select_vgui(id) {
	if(join_team(id))
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE 
}
*/
bool:join_team(id, key=-1) 
{
	if(key == 4)
	{
		client_print(id, print_chat, "Please choose a team manually!") 
		return true;
	}
		
	new num, players[32]
	get_players(players, num, "c");
	if(GAME_MODE == MODE_PREGAME && (key == 0 || key == 1))
	{
		new id, team
		new teamcnt[3]
		new sjplayers = get_pcvar_num(P_PLAYERS);
		
		for(id=1;id<=maxplayers;id++)
			if(is_user_connected(id))
			{
				team = get_user_team(id);
				teamcnt[team]++;
			}
			
		if(teamcnt[key+1] >= sjplayers)
		{
			client_print(id, print_chat, "%s team is full.", key==0?"Terrorist" : "Counter-Terrorists" );
			return true;
		}
		
	}
	if(GAME_MODE == MODE_PREGAME && num < NumPlayersOfMatch) {
		
		if(PlayerDisconnectCount > 0)
		{
			copy_stats(PlayerDisconnectID[PlayerDisconnectCount-1], id);
			PlayerDisconnectID[PlayerDisconnectCount-1] = 0;
			PlayerDisconnectCount -= 1;
		}
		return false;	
	}
	if(get_pcvar_num(P_TOURNY_ON) != 1 && (GAME_MODE != MODE_PREGAME) && NumPlayersOfMatch) {
		if(num > NumPlayersOfMatch) {
			client_print(id, print_chat, "Game is FULL, you may spectate only!") 
			client_cmd(id, "jointeam 6");
			return true;
		}
	}
	return false;
}

/*====================================================================================================
 [Player Ban/Admins]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/

public RightDirection(id) {

	if(id == ballholder) {

		direction--
		if(direction < -(DIRECTIONS))
			direction = -(DIRECTIONS)
		new temp = direction * CURVE_ANGLE
		SendCenterText( id, temp );
	}
	else
		client_print(id, print_chat, "You don't have ball, to curve right." );
	return PLUGIN_HANDLED
}

SendCenterText( id, dir )
{
	new dir_text[12];
	if(dir < 0)
		format(dir_text, 11, "right");
	else if(dir == 0)
		format(dir_text, 11, "");
	else if(dir > 0)
		format(dir_text, 11, "left");
		
	client_print(id, print_center, "%i degrees %s.", (dir<0?-(dir):dir), dir_text);	
}

public LeftDirection(id) {
	if(id == ballholder) {
		direction++
		if(direction > DIRECTIONS)
			direction = DIRECTIONS
		new temp = direction * CURVE_ANGLE
		SendCenterText( id, temp )
	}
	else {
		client_print(id, print_chat, "You don't have ball, to curve left.");
	}
	return PLUGIN_HANDLED
}


public CurveBall(id) {
	if(direction && get_speed(aball) > 5 && curvecount > 0) {

		new Float:dAmt = float((direction * CURVE_ANGLE) / ANGLEDIVIDE);
		new Float:v[3], Float:v_forward[3];
		
		entity_get_vector(aball, EV_VEC_velocity, v);
		vector_to_angle(v, BallSpinDirection);

		BallSpinDirection[1] = normalize( BallSpinDirection[1] + dAmt );
		BallSpinDirection[2] = 0.0;
		
		angle_vector(BallSpinDirection, 1, v_forward);
		
		new Float:speed = vector_length(v);// * 0.95;
		v[0] = v_forward[0] * speed
		v[1] = v_forward[1] * speed
		
		entity_set_vector(aball, EV_VEC_velocity, v);

		curvecount--;
		set_task(CURVE_TIME, "CurveBall", id);
	}
}

public fullupdate(id) {
	return PLUGIN_HANDLED
}
/*====================================================================================================
 [Ball Stuff]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public ball_think() {

	if(is_valid_ent(aball)) {
		
		new Float:gametime = get_gametime()
		if(PowerPlay >= MAX_POWERPLAY && gametime - fire_delay >= 0.3)
			on_fire()
			
		if(ballholder > 0) {
			new team = get_user_team(ballholder)
			entity_get_vector(ballholder, EV_VEC_origin,testorigin)

			if(!is_user_alive(ballholder)) 
			{
				new tname[32]
				get_user_name(ballholder,tname,31)

				remove_task(55555)
				set_task(get_pcvar_float(P_RESET),"clearBall",55555)
				
				format(temp1,63,"%s [%s] dropped the ball!",TeamNames[team],tname)
				
				//remove glow of owner and set ball velocity really really low
				glow(ballholder,0,0,0,0)

				//g_KickDelay[ballholder] = 0.0;
				
				ballowner = ballholder
				ballholder = 0
				
				
				testorigin[2] += 10
				entity_set_origin(aball, testorigin)

				new Float:vel[3], x
				for(x=0;x<3;x++)
					vel[x] = 1.0
				
				entity_set_vector(aball,EV_VEC_velocity,vel)
				entity_set_float(aball,EV_FL_nextthink,halflife_time() + 0.05)
				return PLUGIN_HANDLED
			}
			if(entity_get_int(aball,EV_INT_solid) != SOLID_NOT)
				entity_set_int(aball, EV_INT_solid, SOLID_NOT)

			//Put ball in front of player
			ball_infront(ballholder, 50.0)
			new i
			for(i=0;i<3;i++)	
				velocity[i] = 0.0
			//Add lift to z axis
			new flags = entity_get_int(ballholder, EV_INT_flags)	
			if(flags & FL_DUCKING)
				testorigin[2] -= 20
			else
				testorigin[2] -= 30
				
			entity_set_vector(aball,EV_VEC_velocity,velocity)
	  		entity_set_origin(aball,testorigin)
		}
		else {
			if(entity_get_int(aball,EV_INT_solid) != SOLID_BBOX)
				entity_set_int(aball, EV_INT_solid, SOLID_BBOX)			
		}
	}
	entity_set_float(aball,EV_FL_nextthink,halflife_time() + 0.05)
	return PLUGIN_HANDLED
}

moveBall(where, team=0) {
	
	if(is_valid_ent(aball)) 
	{
		if(ballholder) {
			glow(ballholder,0,0,0,0)
			//g_KickDelay[ballholder] = 0.0;
		}
			
		ballholder = 0
		ballowner = 0		
				
		if(team) {
			new Float:bv[3]
			if(g_iTeamBall == 0)
			{
				bv[2] = 50.0
				entity_set_origin(aball, TeamBallOrigins[team])
				entity_set_vector(aball, EV_VEC_velocity, bv)	
			}
			else
			{
				bv[2] = 50.0
				new Float:borig = get_pcvar_float(P_BALLSPAWN_DIST) / 100.0;
				new Float:vecOrig[3];
				new i;
				for(i=0;i<3;i++)
					vecOrig[i] = BallSpawnOrigin[0][i] + ( (TeamBallOrigins[team][i]-BallSpawnOrigin[0][i]) * borig );
				
				entity_set_origin(aball, vecOrig)
				entity_set_vector(aball, EV_VEC_velocity, bv)	
					
			}
			PowerPlay = 0
		}
		else {
			switch(where) {
				case 0: { //outside map
					
					new Float:orig[3], x
					for(x=0;x<3;x++)
						orig[x] = -9999.9
					entity_set_origin(aball,orig)
				}
				case 1: { //at middle
					
					new Float:v[3], rand
					v[2] = 400.0
					if(ballspawncount > 1)
						rand = random_num(0, ballspawncount-1)
					else
						rand = 0
						
					entity_set_origin(aball, BallSpawnOrigin[rand])
					entity_set_vector(aball, EV_VEC_velocity, v)
		
					PowerPlay = 0
					
				}
			}
		}
	}
}

public ball_infront(id, Float:dist) {
	
	new Float:nOrigin[3]
	new Float:vAngles[3] // plug in the view angles of the entity
	new Float:vReturn[3] // to get out an origin fDistance away

	entity_get_vector(aball,EV_VEC_origin,testorigin)
	entity_get_vector(id,EV_VEC_origin,nOrigin)
	entity_get_vector(id,EV_VEC_v_angle,vAngles)

		
	vReturn[0] = floatcos( vAngles[1], degrees ) * dist
	vReturn[1] = floatsin( vAngles[1], degrees ) * dist
	
	vReturn[0] += nOrigin[0]
	vReturn[1] += nOrigin[1]
	
	testorigin[0] = vReturn[0] 
	testorigin[1] = vReturn[1]
	testorigin[2] = nOrigin[2]
	
	/* 
	new Float:ang[3]
	entity_get_vector(id,EV_VEC_angles,ang)
	ang[0] = 0.0
	ang[1] -= 90.0
	ang[2] = 0.0
	entity_set_vector(aball,EV_VEC_angles,ang)
	*/
}

public on_fire()
{
	new rx, ry, rz, Float:forig[3], forigin[3]
	//new killer = args[1]
	fire_delay = get_gametime()
	
	rx = random_num(-5, 5)
	ry = random_num(-5, 5)
	rz = random_num(-5, 5)
	entity_get_vector(aball, EV_VEC_origin, forig)
	new x
	for(x=0;x<3;x++)
		forigin[x] = floatround(forig[x])
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(17)
	write_coord(forigin[0] + rx)
	write_coord(forigin[1] + ry)
	write_coord(forigin[2] + 10 + rz)
	write_short(Burn_Sprite)
	write_byte(7)
	write_byte(235)
	message_end()
}
/*====================================================================================================
 [Mascot Think]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/

public mascot_think(mascot)
{
	if(GAME_MODE != MODE_PREGAME && GAME_MODE != MODE_HALFTIME) {
		new team = entity_get_int(mascot, EV_INT_team)
		new distance = get_pcvar_num(P_GOALSAFETY)
		new indist[32], inNum
		
		new id, playerteam, dist
		new Float:gametime = get_gametime();
		new distances[33]
		for(id=1 ; id<=maxplayers ; id++) {
			if(!is_user_bot(id) && is_user_alive(id)) 
			{
				playerteam = get_user_team(id)
				dist = get_entity_distance(id, mascot)
				distances[id] = dist;
				if(playerteam != team ) {
					if(dist < distance)
						if(id == ballholder) {
							TerminatePlayer(id, mascot, team, 220.0)
							entity_set_float(mascot,EV_FL_nextthink,halflife_time() + 1.0)
							return PLUGIN_HANDLED
						}
						else
							indist[inNum++] = id
				}
				else {
					if(GAME_MODE == MODE_SHOOTOUT && playerteam != ShootOut && id == candidates[playerteam]) {
						if(dist	>= MAX_ENEMY_SHOOTOUT_DIST) {
							//client_print(0,print_chat,"Stepped outta goal area");
							spawn(id)
							entity_set_float(id, EV_FL_takedamage, 0.0);
						}
					}
					
					if((gametime - GoalyCheckDelay[id] >= MAX_GOALY_DELAY) ) 
					{
						goaly_checker(id, dist, gametime) 
					}
				}
			}
		}
		new rnd = random_num(0, (inNum-1))
		new chosen = indist[rnd]
		if(chosen)
		{
			TerminatePlayer(chosen, mascot, team, random_float(25.0, 35.0))
		}
		
	}
	entity_set_float(mascot,EV_FL_nextthink,halflife_time() + 1.0)
	return PLUGIN_HANDLED
}

// Goaly Points System				
goaly_checker(id, dist, Float:gametime) 
{
	if(dist < MAX_GOALY_DISTANCE ) 
	{
		if(GoalyCheck[id] > 1) {
			
			g_Points[id] += POINTS_GOALY_CAMP;
			GoalyPoints[id] += GOALY_POINTS_CAMP;
			
			new hp = get_user_health(id);
			new maxhp = ( BASE_HP );// + (PlayerUpgrades[id][STA] * AMOUNT_STA) ) - HEALTH_REGEN_AMOUNT;
			new diff = maxhp - hp;			
			if(hp <= maxhp) {//(maxhp - (maxhp/3))) {
				if(diff < HEALTH_REGEN_AMOUNT)
					set_user_health( id, hp + (maxhp - hp) );
				else
					set_user_health( id, hp + HEALTH_REGEN_AMOUNT )
			}
		}
		else
			GoalyCheck[id]++

		GoalyCheckDelay[id] = gametime
	}
	else
		GoalyCheck[id] = 0
}


/*====================================================================================================
 [Status Display]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public statusDisplay()
{
	new id, team
	if(GAME_MODE != MODE_SHOOTOUT) {
		for(id=1; id<=maxplayers; id++) {
			if(is_user_connected(id) && !is_user_bot(id)) {
				if(!is_user_alive(id) && !is_dead[id]) {
					team = get_user_team(id)
					if(team == 1 || team == 2) {
						remove_task(id+1000)
						has_knife[id] = false;
						is_dead[id] = true
						//new Float:respawntime = get_cvar_float("kickball_respawn")
						set_task(2.0,"AutoRespawn",id)
						set_task(2.2, "AutoRespawn2",id)
					}
				}
			}
		}
	}
	switch(GAME_MODE) 
	{
		case MODE_PREGAME: DO_MODE_PREGAME();
		case MODE_HALFTIME: DO_MODE_PREGAME();
		case MODE_GAME: 
		{
			new score_t = score[T], score_ct = score[CT]
		
			if(TimeLeft == 0) 
			{
				if(!ROUND) {
					play_wav(0, whistle_endgame);
					TimeLeft = -1;
					scoreboard[0] = 0;
					format(scoreboard,1024,"HALF-TIME")
					set_task(1.0,"showHud",456321,"",0,"a",3)
					server_cmd("sv_restart 4")
					set_task(4.1,"DoHalfTimeReport",0);
					for(id=1;id<=maxplayers;id++) 
						Ready[id] = false;
					ROUND = 1;
				}
				else {
					if(!GameOver) 
					{
						GameOver = true
						
						if(score_t > score_ct)
							winner = T
						else if(score_ct > score_t)
							winner = CT
						
						play_wav(0, whistle_endgame);
							
						if(winner) {
							//GAME_MODE = MODE_PREGAME
							scoreboard[0] = 0;
							format(scoreboard,1024,"Team %s ^nWINS!",TeamNames[winner])
							set_task(1.0,"showHud",456321,"",0,"a",3)
							server_cmd("sv_restart 5")
						}
						else {
							GAME_MODE = MODE_SHOOTOUT
							ShootOut = 1
							
							server_cmd("sv_restart 6")
							scoreboard[0] = 0;
							format(scoreboard,1024,"Tie Game!!^nMoving into ShootOut mode.^n Team %s up first",TeamNames[ShootOut])
							set_task(1.0,"showHud",456321,"",0,"a",3)
						}
						
					}
				}
				moveBall(0)
			}
			else if(TimeLeft > 0) {
				new bteam = get_user_team(ballholder>0?ballholder:ballowner)
				new timedisplay[32]
				//if(TimeLeft < 60)
				//	format(timedisplay, 31, "%i", TimeLeft)
				//else {
				new minutes = TimeLeft / 60
				new seconds = TimeLeft % 60
				format(timedisplay, 31, "%i:%s%i",minutes,seconds<10?"0":"",seconds)
				//}
				new totPoints//Float:credits, , Float:points
				scoreboard[0] = 0;
				for(id=1;id<=maxplayers;id++) {
					if(!is_user_connected(id) || is_user_bot(id))
						continue
					team = get_user_team(id);
					totPoints = floatround(g_Points[id] * 100);
				
					format(scoreboard,1024,"%s HALF -- %s  ^n%s - %i  |  %s - %i ^nPoints: %i ^n^n%s^n^n%s",ROUND==0?"1ST":"2ND",timedisplay,TeamNames[T],score_t,TeamNames[CT],score_ct,totPoints,temp1,team==bteam?temp2:"")
					
					set_hudmessage(20, 255, 20, 0.90, 0.10, 0, 1.0, 1.5, 0.1, 0.1, HUD_CHANNEL)
					show_hudmessage(id,"%s",scoreboard)
				}
				TimeLeft--
			}
		}
		//case MODE_SHOOTOUT: {
			
		//}
		case MODE_OVERTIME: 
		{
			if(TimeLeft <= 0)
			{
				moveBall(0)
				play_wav(0, whistle_endgame);
				OverTime++
				GAME_MODE = MODE_NONE
				server_cmd("sv_restart 8")
				scoreboard[0] = 0;
				format(scoreboard,1024,"Tie Game!! ^nUp next... ^nOVERTIME Round %i",OverTime)
				set_task(1.0,"showHud",456321,"",0,"a",6)
			}
			else {
				new timedisplay[32]
				new bteam = get_user_team(ballholder>0?ballholder:ballowner)
				if(TimeLeft < 60)
					format(timedisplay, 31, "%i", TimeLeft)
				else {
					new minutes = TimeLeft / 60
					new seconds = TimeLeft % 60
					format(timedisplay, 31, "%i:%s%i",minutes,seconds<10?"0":"",seconds)
				}
				scoreboard[0] = 0;
				for(id=1;id<=maxplayers;id++) {
					if(!is_user_connected(id) || is_user_bot(id))
						continue
					team = get_user_team(id)
					
					format(scoreboard,1024,"Time Left: %s^nOVERTIME %i^n%s - %i  |  %s - %i ^n^n%s^n^n^n%s",timedisplay,OverTime,TeamNames[T],score[T],TeamNames[CT],score[CT],temp1,team==bteam?temp2:"")
					set_hudmessage(20, 255, 20, 0.90, 0.20, 0, 1.0, 1.5, 0.1, 0.1, HUD_CHANNEL)
					show_hudmessage(id,"%s",scoreboard)
				}
				TimeLeft--
			}
		}
	}
	return PLUGIN_HANDLED
}

public DoHalfTimeReport() {
		
	new id, Float:points;
	for(id=1;id<=maxplayers;id++) {
		points = g_Points[id] / get_pcvar_float(P_POINT_MULTI);
		if(points) {
				
			g_Experience[id] = points;
			//g_Points[id] = 0;
			
			//for(x=1;x<=UPGRADES;x++)
			//	Old_PlayerUpgrades[id][x] = PlayerUpgrades[id][x];
			BuyUpgrade(id)
		}
	}
}

DO_MODE_PREGAME() 
{
	new teamready[TEAMS][512], teamLen[TEAMS], id, team
	new player_name[32], teamcount[TEAMS], readycount[TEAMS]
	
	for(id = 1; id<=maxplayers; id++)
		if(is_user_connected(id) && !is_user_bot(id)) {
			team = get_user_team(id)
			get_user_name(id, player_name, 31)
			teamcount[team]++
			if(Ready[id]) {
				readycount[team]++
				teamLen[team] += format(teamready[team][teamLen[team]], 511-teamLen[team], "(READY) %s^n", player_name)	
			}
			else {
				
				teamLen[team] += format(teamready[team][teamLen[team]], 511-teamLen[team], "(WAITING) %s^n", player_name)	
			}
		}
		
	new required = get_pcvar_num(P_PLAYERS)
	new missing[64], x
	
	if(get_pcvar_num(P_TOURNY_ON) != 1)
	{
		new Float:kicktime = float(get_pcvar_num(P_AFK_PCT)) / 100.0;
		new Float:seconds = float(get_pcvar_num(P_AFK_TIME) * 60);	
		new Float:player_total = float(teamcount[1] + teamcount[2]);
		new Float:player_ready = float(readycount[1] + readycount[2]);
		new Float:player_pct = player_ready / player_total;
		
		if(player_pct > kicktime) {
			if(teamcount[1] >= required && teamcount[2] >= required) {
				for(id=1;id<=maxplayers;id++) {
					if(is_user_connected(id) && !is_user_bot(id) && !is_user_hltv(id)) {
						team = get_user_team(id)
						if((team == 1 || team == 2) && !Ready[id] && !task_exists(id+4545)) {
							set_task(seconds,"KickMe",id+4545);
							client_print(id,print_chat, "[SOCCER JAM] - You have %i minutes to get ready, or be kicked!", get_pcvar_num(P_AFK_TIME));	
							client_print(id,print_chat, "[SOCCER JAM] - You have %i minutes to get ready, or be kicked!", get_pcvar_num(P_AFK_TIME));
							play_wav(id, returned);	
						}	
					}	
				}
			}
		}
	}
					
	for(x=1;x<3;x++) {
			
		if(teamcount[x] < required)
			format(missing, 63, "Players Missing: %i", required-teamcount[x])
		else if(teamcount[x] != readycount[x])
			format(missing, 63, "Players Not Ready: %i", teamcount[x]-readycount[x])
		else if(teamcount[x] == readycount[x])
			format(missing, 63, "READY")
			
		set_hudmessage(x==1?255:25, 10, x==1?25:255, 0.60, x==1?0.2:0.55, 0, 1.0, 1.5, 0.1, 0.1, x==1?2:3)
		show_hudmessage(0,"%s(TEAM %s)  %s^n%s",x==1?(GAME_MODE==MODE_PREGAME?"- Pre-Game^n^n":"- Half-Time^n^n"):"",TeamNames[x], missing, teamready[x])
	}
		
	if( (teamcount[1] >= required && teamcount[2] >= required) && 
		(teamcount[1] == readycount[1] && teamcount[2] == readycount[2]) ) 
	{
		if(GAME_MODE == MODE_PREGAME) {
			NumPlayersOfMatch = teamcount[1] + teamcount[2];
			cleanup();
			g_iTeamBall = 0;
		}
		
		BeginCountdown()	
		GAME_MODE = MODE_NONE
	}	
}
public KickMe(id) {
	id -= 4545;
	server_cmd("kick #%d ^"%s^"", get_user_userid(id), "You were kicked for taking to long in getting ready!")
}
/*====================================================================================================
 [Touched]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public touchWorld(ball, world) {

	if(get_speed(ball) > 5) {
		new Float:v[3]
		entity_get_vector(ball, EV_VEC_velocity, v)
		v[0] = (v[0] * 0.85)
		v[1] = (v[1] * 0.85)
		v[2] = (v[2] * 0.85)
		entity_set_vector(ball, EV_VEC_velocity, v)
		emit_sound(ball, CHAN_ITEM, ballhit, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
}

public touchPlayer(ball, player) {
	
	if(is_user_bot(player))
		return PLUGIN_HANDLED
		
	new playerteam = get_user_team(player)
	if((playerteam != 1 && playerteam != 2))
		return PLUGIN_HANDLED

	remove_task(55555)
	
	new aname[64], stolen
	get_user_name(player,aname,63)
	new ballteam = get_user_team(ballowner)
	if(ballowner > 0 && playerteam != ballteam )
	{
		new speed = get_speed(aball)
		new button = entity_get_int(player, EV_INT_button)
		if(speed > 500) 
		{
			//configure catching algorithm
			new rnd = random_num(0,100)
			new dexlevel = PlayerUpgrades[player][DEX];
			new bstr = (PlayerUpgrades[ballowner][STR] * AMOUNT_STR) / 10
			new dex = (dexlevel * AMOUNT_DEX) + dexlevel;
			new pct = ( (button & IN_USE) ? 10 : 0 ) + dex
			
			pct += ( dexlevel * (g_sprint[player] ? 1 : 0) )	//Give Dex Lvl * 2 if turboing.
			pct += ( g_sprint[player] ? 5 : 0 )		//player turboing? give 5% 
			pct -= ( g_sprint[ballowner] ? 10 : 0 ) 	//ballowner turboing? lose 5%
			pct -= bstr						//ballowner has strength? remove bstr
			
			//will player avoid damage?
			if( rnd > pct ) {
				new Float:dodmg = (float(speed) / 13.0) + bstr - (dex - dexlevel);
				if(dodmg < 10.0)
					dodmg = 10.0;
				client_print(0,print_chat,"%s got smacked for %i damage.",aname,floatround(dodmg))

				set_msg_block(gmsgDeathMsg,BLOCK_ONCE)
				fakedamage(player,"AssWhoopin",dodmg,1)
				set_msg_block(gmsgDeathMsg,BLOCK_NOT)

				if(!is_user_alive(player)) {
					message_begin(MSG_ALL, gmsgDeathMsg)
					write_byte(ballowner)
					write_byte(player)
					write_string("AssWhoopin")
					message_end()
					
					new frags = get_user_frags(ballowner)
					entity_set_float(ballowner, EV_FL_frags, float(frags + 1))
					Event_Record(ballowner, KILL, -1)
					
					client_print(player,print_chat,"You were killed by the ball going to fast!")
					client_print(ballowner,print_chat,"You killed %s with the ball!",aname)
				}
				else {
					new Float:pushVel[3]
					pushVel[0] = velocity[0]
					pushVel[1] = velocity[1]
					pushVel[2] = velocity[2] + ((velocity[2] < 0)?random_float(-200.0,-50.0):random_float(50.0,200.0))
					entity_set_vector(player,EV_VEC_velocity,pushVel)
				}
				new x
				for(x=0;x<3;x++)
					velocity[x] = (velocity[x] * random_float(0.1,0.9))
				entity_set_vector(aball,EV_VEC_velocity,velocity)
				direction = 0
				return PLUGIN_HANDLED
			}
		}
		
		if(speed > 950)
			play_wav(0, pussy)
		
		//new goalent = GoalEnt[playerteam]
		new Float:pOrig[3]
		entity_get_vector(player, EV_VEC_origin, pOrig)
		new Float:dist = get_distance_f(pOrig, TeamBallOrigins[playerteam]);
		
		//give more points the closer it is to net
		if(dist < 600.0 && speed > 300) {
			new Float:speeddelim = (float(speed) / 1000.0) - (dist / 2000.0)
			g_Points[player] += speeddelim;
			
			if(speeddelim > 0.0)
			{
				GoalyPoints[player] += floatround(speeddelim * 100.0);
				Event_Record( player, GOALSAVE, -1 );
			}
		}
		
		Event_Record(player, STEAL, -1)
		
		format(temp1,63,"%s [%s] stole the ball!",TeamNames[playerteam],aname)
		client_print(0,print_console,"%s",temp1)
		stolen = 1
		
		client_print(player,print_chat,"You stole the ball!")
		
		if(GAME_MODE == MODE_SHOOTOUT) {
			new oteam = (ShootOut == 1 ? 2:1)
			//new bhteam = get_user_team(
			if(playerteam == oteam) {
				//fakedamage(LineUp[next], "TimeIsUp", 220.0, 1)
				SetAsWatcher(LineUp[next], oteam)
				moveBall(0)
			}
		}
	}
	if(ballholder == 0) {
		emit_sound(aball, CHAN_ITEM, gotball, 1.0, ATTN_NORM, 0, PITCH_NORM)
		
		if(!has_knife[player])
			give_knife(player)
		
		if(stolen)
			PowerPlay = 0
		else
			format(temp1,63,"%s [%s] picked up the ball!",TeamNames[playerteam],aname)
			
		new bool:check
		if(((PowerPlay > 1 && powerplay_list[PowerPlay-2] == player) || (PowerPlay > 0 && powerplay_list[PowerPlay-1] == player)) && PowerPlay != MAX_POWERPLAY)
			check = true
					
		if(PowerPlay <= MAX_POWERPLAY && !check) {
			powerplay_list[PowerPlay] = player
			PowerPlay++
		}
		else
		{
			//new i;
			//for(i=0;i<PowerPlay;i++)
			//	Event_Record( powerplay_list[i], POWERPLAY, -1);
		}
		curvecount = 0
		direction = 0
		//GoalyPoints[player] = 0;
		
		format(temp2, 63, "POWER PLAY! -- Level: %i", PowerPlay>0?PowerPlay-1:0)
			
		ballholder = player
		ballowner = 0
		
		Event_Record( player, POSSESSION, -1);
		
		new msg[64]
		set_hudmessage(255, 20, 20, POS_X, 0.4, 1, 1.0, 1.5, 0.1, 0.1, 2)
		format(msg,63,"YOU HAVE THE BALL!!")
		show_hudmessage(player,"%s",msg)
		//Glow Player who has ball their team color
		beam(10)
		glow(player, TeamColors[playerteam][0], TeamColors[playerteam][1], TeamColors[playerteam][2], 1)
	}
	return PLUGIN_HANDLED
}

public touchCC(ball, goalpost) 
{
	remove_task(55555)
		
	new team = get_user_team(ballowner)
	new goalent = GoalEnt[team]
	if (goalpost != goalent && ballowner > 0) {
		new aname[64]
		new Float:ccorig[3]
		new ccorig2[3]
	
		entity_get_vector(ball, EV_VEC_origin,ccorig)
		new l
		for(l=0;l<3;l++) 
			ccorig2[l] = floatround(ccorig[l])
		flameWave(ccorig2)
		get_user_name(ballowner,aname,63)
		new frags = get_user_frags(ballowner)
		entity_set_float(ballowner, EV_FL_frags, float(frags + 10))
		//set_user_frags(ballowner, get_user_frags(ballowner)+10)
		
		play_wav(0, distress)
		
		/////////////////////ASSIST CODE HERE///////////
		
		new assisters[4] = { 0, 0, 0, 0 }
		new iassisters = 0
		new ilastplayer = iassist[ team ]
		
		// We just need the last player to kick the ball
		// 0 means it has passed 15 at least once
		if ( ilastplayer == 0 )
			ilastplayer = 15
		else
			ilastplayer--
		
		if ( assist[ ilastplayer ] != 0 ) {
			new i, playerid, bool:canadd, x
			for ( i = 0; i < 16; i++ ) {
				// Stop if we've already found 4 assisters
				if ( iassisters == MAX_ASSISTERS )
					break;
				playerid = assist[ i ]
				// Skip if player is invalid
				if ( playerid == 0 )
					continue;
				// Skip if kicker is counted as an assister
				if ( playerid == assist[ ilastplayer ] )
					continue;

				canadd = true
				// Loop through each assister value
				for ( x = 0; x < 3; x++ )
					// make sure we can add them
					if ( playerid == assisters[ x ] ) {
						canadd = false;
						break;
					}
		
				// Skip if they've already been added
				if ( canadd == false )
					continue;
				// They didn't kick the ball last, and they haven't been added, add them
				assisters[ iassisters++ ] = playerid
			}
			new c, pass
			// This gives each person an assist, xp, and prints that out to them
			for ( c = 0; c < iassisters; c++ ) {
				pass = assisters[ c ]
				Event_Record(pass, ASSIST, -1)
				client_print( pass, print_chat, "You made an assist!")
			}
		}
		iassist[ 0 ] = 0
		/////////////////////ASSIST CODE HERE///////////
		for(l=0;l<3;l++)
			distorig[1][l] = floatround(ccorig[l])
		new distshot = (get_distance(distorig[0],distorig[1])/12)
		
		format(temp1,63,"%s [%s] SCORED from %i ft!!",TeamNames[team],aname,distshot)
		client_print(0,print_console,"%s",temp1)
		
		if(distshot > MadeRecord[ballowner][DISTANCE])
			Event_Record(ballowner, DISTANCE, distshot)// record distance, and make that distance exp
			
		Event_Record(ballowner, GOAL, -1)	//zero xp for goal cause distance is what gives it.
		
		
		g_iTeamBall = team;
		//Increase Score, and update cvar score
		score[team]++
		switch(team) {
			case 1: set_cvar_num("SCORE_CT",score[team])
			case 2: set_cvar_num("SCORE_T",score[team])
		}
		client_print(ballowner,print_chat,"You made a %i ft GOAL !",distshot)
	
		moveBall(0);
		
		switch(GAME_MODE) {
			case MODE_GAME: {
				new x, kills, deaths;
				for(x=1;x<=maxplayers;x++) {
					if(is_user_connected(x))
					{	
						kills = get_user_frags(x)
						deaths = cs_get_user_deaths(x)
						
						if( deaths > 0)
							PlayerDeaths[x] = deaths
						if( kills > 0)
							PlayerKills[x] = kills
					}
				}
				if(TimeLeft > 16)
					server_cmd("sv_restart 4")
			}
			case MODE_OVERTIME: {
				if(score[T] > score[CT])
					winner = T
				else if(score[CT] > score[T])
					winner = CT
					
				if(winner) {
					GAME_MODE = MODE_NONE
					scoreboard[0] = 0;
					format(scoreboard,1024,"Team %s ^nWINS!",TeamNames[winner])
					set_task(1.0,"showHud",456321,"",0,"a",3)
					server_cmd("sv_restart 5")
				}
			}
			case MODE_SHOOTOUT: {
					
			}
		}
		
		new r = random_num(1,6)
		switch(r) {
			case 1: play_wav(0, amaze)
			case 2: play_wav(0, laugh)
			case 3: play_wav(0, perfect)
			case 4: play_wav(0, diebitch)
			case 5: play_wav(0, bday)
			case 6: play_wav(0, boomchaka)
		}	

	}
	else if(goalpost == goalent) {
		moveBall(0, team)
		client_print(ballowner,print_chat,"You cannot kick to your goal net!!")
	}
	return PLUGIN_HANDLED	
}
/*====================================================================================================
 [Command Blocks]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public client_kill(id) {
	if(is_kickball)
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}

public client_command(id) {
	if(!is_kickball) return PLUGIN_CONTINUE
	new arg[13]
	read_argv( 0, arg , 12 )
	
	if ( equal("buy",arg) || equal("autobuy",arg) ) 
		return PLUGIN_HANDLED
		
	return PLUGIN_CONTINUE
}
/*====================================================================================================
 [Events]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public Event_Damage()
{
	new victim = read_data(0);
	new attacker = get_user_attacker(victim)
	if(is_user_alive(attacker)) {
		if(is_user_alive(victim) && victim == ballholder) {
			
			new upgrade = PlayerUpgrades[attacker][DISARM]
			if(upgrade) {
				//if() {
					new disarm = upgrade * AMOUNT_DISARM
					//new disarmpct = BASE_DISARM + (victim==ballholder?(disarm+5):0)//10;BASE_DISARM + (BASE_DISARM * (((upgrade*2) * AMOUNT_DISARM_PCT) / 100))
					new disarmpct = BASE_DISARM + disarm;//10;BASE_DISARM + (BASE_DISARM * (((upgrade*2) * AMOUNT_DISARM_PCT) / 100))
					
					new rand = random_num(1,100)
					
					if(disarmpct >= rand)
					{
						new vname[32], aname[32]
						get_user_name(victim,vname,31)
						get_user_name(attacker,aname,31)
						
						//if(victim == ballholder) {
						kickBall(victim, 1)
						client_print(attacker,print_chat,"You made %s drop the ball",vname)
						client_print(victim,print_chat,"Your ball was removed by %s",aname)
						//}
						/*
						else {
							new weapon, clip, ammo
							weapon = get_user_weapon(victim,clip,ammo)
							if(weapon == CSW_KNIFE) 
							{
								strip_user_weapons(victim);
								has_knife[victim] = false;
								set_task(float(disarm), "give_knife", victim+1000)
								client_print(attacker,print_chat,"You disarmed %s",vname)
								client_print(victim,print_chat,"You were disarmed by %s",aname)
							}
						}
						*/
					}
				//}
			}
		}
	}
}

SetAsWatcher(id, team) {
	new Float:orig[3], Float:ang[3]
	orig[0] = BallSpawnOrigin[0][0]
	orig[1] = BallSpawnOrigin[0][1]
	orig[2] = BallSpawnOrigin[0][2] + 650.0;
	freeze_player[id] = true;
	strip_user_weapons(id);
	entity_get_vector(Mascots[team], EV_VEC_v_angle, ang);
	
	entity_set_origin(id, orig)
	entity_set_vector(id, EV_VEC_v_angle, ang);
	
	set_user_health(id, 255)
	//entity_set_float(id, EV_FL_gravity, 0.000001);
	entity_set_int(id, EV_INT_effects, (entity_get_int(id, EV_INT_effects) | 128) )
	entity_set_int(id, EV_INT_solid, 0);
}

public ShootoutSetup(team) {
	new id, t, oteam = (team == 1 ? 2 : 1)
	next = 0
	candidates[oteam] = 0
	new goaly = 0;
	for(id=1; id<=maxplayers; id++) {
		if(is_user_connected(id) && !is_user_bot(id)) {
			t = get_user_team(id)
			
			if(t == oteam) 
			{
				SetAsWatcher(id, oteam);
				if(!goaly) {
					goaly = id;
				}
				else if(GoalyPoints[id] > GoalyPoints[goaly]) {
					goaly = id
				}
			}
			else 
				if(t == team) {
					SetAsWatcher(id, oteam);
					LineUp[next++] = id
				}
		}
	}
	new name[32];
	
	if(!goaly)
		client_print(0,print_chat," ERROR: Unable to aquire a Goaly for Team %s",TeamNames[oteam])
	else {
		candidates[oteam] = goaly
		get_user_name(goaly,name,31);
		client_print(0,print_chat," --- %s will be GOALY.",name);
		freeze_player[goaly] = false;
		entity_set_float(goaly, EV_FL_takedamage, 0.0);
	}
	if(!next)
		client_print(0,print_chat," ERROR: Unable to create a Line Up for Team %s",TeamNames[oteam])
}

public Event_StartRound()
{
	if(!is_kickball) return PLUGIN_CONTINUE
	
	new id, team
	
	//if(GAME_MODE != MODE_SHOOTOUT) {
		
	//	for(id=1;id<=maxplayers;id++)
	//		freeze_player[id] = false;	
	//}
	remove_task(55555)
	
	if(winner) {
		displayWinnerAwards()
		GAME_MODE = MODE_PREGAME
		
		
		set_task(29.9,"PostGame",654123)
		
		//Set Spectators to join the team.
		for(id=1;id<=maxplayers;id++) {
			Ready[id] = false;
			if(is_user_connected(id)){
				team = get_user_team(id)
				
				if(team != 1 && team != 2)
				{
					client_cmd( id, "chooseteam" );
				}	
			}	
		}
	
		//server_cmd("sv_restart 30")
		return PLUGIN_CONTINUE
	}
	
	if(OverTime)
	{
		g_iTeamBall = 0;
		GAME_MODE = MODE_OVERTIME
	}	
	
	switch(GAME_MODE) {
		case MODE_GAME: {
			if(TimeLeft == -1) {
				GAME_MODE = MODE_HALFTIME		
				g_iTeamBall = 0;
			}
			else
				SetupRound()
		}
		case MODE_SHOOTOUT: {
			set_task(1.0,"PostSetupShootoutRound",0)
		}
		case MODE_OVERTIME: {
			TimeLeft = (get_pcvar_num(P_TIME) * 60)
			GameOver = false
			SetupRound()
		}	
	}
	
	for(id=1;id<=maxplayers;id++) 
	{
		if(is_user_connected(id) && !is_user_bot(id)) {
			is_dead[id] = false
			seconds[id] = 0
			g_sprint[id] = 0
			PressedAction[id] = 0
			
			team = get_user_team(id);
			if(GAME_MODE == MODE_HALFTIME && (team == 1 || team == 2))
				BuyUpgrade(id)
		}
	}
	
	return PLUGIN_CONTINUE
}



public PostSetupShootoutRound() {
	ShootoutSetup(ShootOut)
	//new id
	next--
	
	moveBall(1)
	new id = LineUp[next]
	cs_user_spawn(id)
	entity_set_origin(id, BallSpawnOrigin[0])
	freeze_player[id] = true;
	entity_set_float(id, EV_FL_maxspeed, 0.0)
	timer = SHOTCLOCK_TIME
	
	//new id;
	//for(id=1;id<=maxplayers;id++)
		
		
	set_task(5.0, "ShotClock", 0)
}

public SetupRound() {
	iassist[ 0 ] = 0
	
	if(!is_valid_ent(aball))
		createball()
		
	if(g_iTeamBall == 0)
		moveBall(1)
	else
		moveBall(0, g_iTeamBall==1?2:1);
	
	g_iTeamBall = 0;
	
	play_wav(0, prepare)
				
	set_task(1.0, "PostPostSetupRound", 0)
	
	return PLUGIN_HANDLED
}
public PostPostSetupRound() {
	new id, kills, deaths;
	for(id=1;id<=maxplayers;id++) {
		
		if(is_user_connected(id) && !is_user_bot(id)) {
			kills = PlayerKills[id]
			deaths = PlayerDeaths[id]
			if(kills)
				entity_set_float(id, EV_FL_frags, float(kills))
			if(deaths)
				cs_set_user_deaths(id,deaths)
			
			if(is_user_alive(id))
				give_knife(id)	
				
			if(GAME_MODE == MODE_GAME && g_Experience[id] >= 4)
			{
				new i;
				for(i=1;i<UPGRADES;i++)
					PlayerUpgrades[id][i] = 3;
				PlayerUpgrades[id][UPGRADES] = 0;
				
				g_Experience[id] = 0.0;
			}
		}
	}	
	
	new hudmsg[64];//scoreboard[0] = 0;
	new r = 255,g = 255,b = 255;
	switch(g_iTeamBall)
	{
		case 2: 
		{
			format(hudmsg,63,"Terrorist's ball.", g_iTeamBall==1?"Counter-Terrorist":"")
			r = 255; b = 20; g = 20;
		}
		case 1: 
		{
			r = 20; g = 20; b = 255;
			format(hudmsg,63,"Counter-Terrorist's ball.", g_iTeamBall==1?"Counter-Terrorist":"Terrorist")
		}
		
	}
	
	if(g_iTeamBall == 1 || g_iTeamBall == 2)
	{
		set_hudmessage(r, g, b, POS_X, 0.3, 0, 4.0, 4.5, 0.1, 0.1, 2)
		show_hudmessage(0,"%s",hudmsg)
	}
}

public Event_ResetHud(id) {
	if( (GAME_MODE == MODE_PREGAME || GAME_MODE == MODE_HALFTIME) && g_Experience[id] >= 1.0) {
		BuyUpgrade(id)	
	}
	goaldied[id] = 0
	set_task(0.2,"PostResetHud",id)
}

public PostResetHud(id) {
	if(is_user_alive(id))
	{
		new stam = PlayerUpgrades[id][STA]
		
		if(GAME_MODE != MODE_SHOOTOUT) {
			if(!has_knife[id]) {
				give_knife(id)
			}
		}
		
		//compensate for our turbo
		if(!g_sprint[id]) {
			set_speedchange(id)
		}
		if(stam > 0)
			entity_set_float(id, EV_FL_health, float(100 + (stam * AMOUNT_STA)))
	}
}

/*====================================================================================================
 [Client Moves]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public Turbo(id) 
{
	if(is_user_alive(id))
		g_sprint[id] = 1
	return PLUGIN_HANDLED
}

public client_PreThink(id)
{
	if( is_kickball && is_valid_ent(aball) && is_user_connected(id) && !is_user_bot(id))
	{
		
		if(freeze_player[id]) {
				
			entity_set_vector(id,EV_VEC_velocity,Float:{0.0,0.0,0.0});
		}
		else {
			new button = entity_get_int(id, EV_INT_button)	
			new usekey = (button & IN_USE)
			new up = (button & IN_FORWARD)
			new down = (button & IN_BACK)
			new moveright = (button & IN_MOVERIGHT)
			new moveleft = (button & IN_MOVELEFT)
			new jump = (button & IN_JUMP)
			new flags = entity_get_int(id, EV_INT_flags)
			
			new onground = flags & FL_ONGROUND
			
			if( (moveright || moveleft) && !up && !down && jump && onground && !g_sprint[id] && id != ballholder)
				SideJump[id] = 1
			
			if(g_sprint[id])
				entity_set_float(id, EV_FL_fuser2, 0.0)
			
			if( id != ballholder )
				PressedAction[id] = usekey
			else {
				if( usekey && !PressedAction[id]) {
					kickBall(id, 0);
					/*
					if(!g_KickDelay[id])
						g_KickDelay[id] = get_gametime();
					else {
						new flags = entity_get_int(id, EV_INT_flags)
						if((flags & FL_ONGROUND)) 
						{
							DeterminePower(id) 
							client_print(id,print_center,"Power %i%%",g_KickPower[id]);	
						}
						else
							client_print(id,print_center,"Power 100%%",g_KickPower[id]);		
					}
					*/
				}
				else if( !usekey && PressedAction[id])
					PressedAction[id] = 0
				//else if( !usekey && g_KickDelay[id] ) {
					/*
					new flags = entity_get_int(id, EV_INT_flags)
					if(!(flags & FL_ONGROUND)) {
						g_KickPower[id] = 100;
						client_print(id,print_center,"Power 100%%");
					}
					*/		
				//}
				
				new Float:pOrig[3], Float:pVel[3], i;	
				new team = get_user_team(id);
				if(team != 1 || team != 2)
					return PLUGIN_CONTINUE;
					
				team = (team == 1 ? 2 : 1);
				
				entity_get_vector(id, EV_VEC_origin, pOrig)
				
				for(i=0;i<2;i++)
					pOrig[i] = pOrig[i] - TeamBallOrigins[team][i]
						
				new Float:dist = (pOrig[0]*pOrig[0]) + (pOrig[1]*pOrig[1]);
		
				//give more points the closer it is to net
				if(dist < 360000) 
				{
					dist = floatsqroot(dist);
					
					entity_get_vector(id, EV_VEC_velocity, pVel );
					
					for(i=0;i<2;i++)
						pOrig[i] = pOrig[i] / dist;
					
					for(i=0;i<2;i++)
						pVel[i] *= pOrig[i] * 500;
						
					entity_set_vector(id, EV_VEC_velocity, pVel );
				}
		
			}
		}
	}
	return PLUGIN_CONTINUE
}
/*
DeterminePower(id) 
{
	new Float:gametime = get_gametime();
	new Float:del = gametime - g_KickDelay[id];
	
	if(del >= 0.2)
		g_KickPower[id] = 100;
	else {
		new delay = floatround(del*10.0)
		switch(delay) {
			case 0: g_KickPower[id] = 70;
			case 1: g_KickPower[id] = 70;
			case 2: g_KickPower[id] = 100;
		}
	}
}
*/
public client_PostThink(id) {
	if(is_kickball && is_user_connected(id)) {
		if(freeze_player[id]) {
			entity_set_vector(id,EV_VEC_velocity,Float:{0.0,0.0,0.0});
		}	
		else {
			new Float:gametime = get_gametime()
			new button = entity_get_int(id, EV_INT_button)
				
			new up = (button & IN_FORWARD)
			new down = (button & IN_BACK)
			new moveright = (button & IN_MOVERIGHT)
			new moveleft = (button & IN_MOVELEFT)
			new jump = (button & IN_JUMP)
			new Float:vel[3]
	
			entity_get_vector(id,EV_VEC_velocity,vel)
			
			if( (gametime - SideJumpDelay[id] > 5.0) && SideJump[id] && jump && (moveright || moveleft) && !up && !down) {
				
				vel[0] *= 2.0
				vel[1] *= 2.0
				vel[2] = 300.0
	
				entity_set_vector(id,EV_VEC_velocity,vel)
				SideJump[id] = 0
				SideJumpDelay[id] = gametime
			}
			else
				SideJump[id] = 0
		}
	}
}

public kickBall(id, velType) 
{
	remove_task(55555)
	set_task(get_pcvar_float(P_RESET),"clearBall",55555)
	
	new team = get_user_team(id)
	new a,x
	
	//Give it some lift
	ball_infront(id, 55.0)

	testorigin[2] += 10

	new Float:tempO[3], Float:returned1[3]
	new Float:dist2

	entity_get_vector(id, EV_VEC_origin, tempO)
	new tempEnt = trace_line( id, tempO, testorigin, returned1 )

	dist2 = get_distance_f(testorigin, returned1)

	//ball_infront(id, 55.0)

	if( point_contents(testorigin) != CONTENTS_EMPTY || (!is_user_connected(tempEnt) && dist2 ) )//|| tempDist < 65)
		return PLUGIN_HANDLED
	else
	{
		//Check Make sure our ball isnt inside a wall before kicking
		new Float:ballF[3], Float:ballR[3], Float:ballL[3]
		new Float:ballB[3], Float:ballTR[3], Float:ballTL[3]
		new Float:ballBL[3], Float:ballBR[3]

		for(x=0; x<3; x++) {
				ballF[x] = testorigin[x];	ballR[x] = testorigin[x];
				ballL[x] = testorigin[x];	ballB[x] = testorigin[x];
				ballTR[x] = testorigin[x];	ballTL[x] = testorigin[x];
				ballBL[x] = testorigin[x];	ballBR[x] = testorigin[x];
			}

		for(a=1; a<=6; a++) {

			ballF[1] += 3.0;	ballB[1] -= 3.0;
			ballR[0] += 3.0;	ballL[0] -= 3.0;

			ballTL[0] -= 3.0;	ballTL[1] += 3.0;
			ballTR[0] += 3.0;	ballTR[1] += 3.0;
			ballBL[0] -= 3.0;	ballBL[1] -= 3.0;
			ballBR[0] += 3.0;	ballBR[1] -= 3.0;

			if(point_contents(ballF) != CONTENTS_EMPTY || point_contents(ballR) != CONTENTS_EMPTY ||
			point_contents(ballL) != CONTENTS_EMPTY || point_contents(ballB) != CONTENTS_EMPTY ||
			point_contents(ballTR) != CONTENTS_EMPTY || point_contents(ballTL) != CONTENTS_EMPTY ||
			point_contents(ballBL) != CONTENTS_EMPTY || point_contents(ballBR) != CONTENTS_EMPTY)
					return PLUGIN_HANDLED
		}

		new ent = -1
		testorigin[2] += 35.0

		while((ent = find_ent_in_sphere(ent, testorigin, 35.0)) != 0) {
			if(ent > maxplayers)
			{
				new classname[32]
				entity_get_string(ent, EV_SZ_classname, classname, 31)

				if((contain(classname, "goalnet") != -1 || contain(classname, "func_") != -1) &&
					!equal(classname, "func_water") && !equal(classname, "func_illusionary"))
					return PLUGIN_HANDLED
			}
		}
		testorigin[2] -= 35.0

	}
		
	new Float:ballorig[3], kickVel
	entity_get_vector(id,EV_VEC_origin,ballorig)
	
	if(!velType) {
		new str = (PlayerUpgrades[id][STR] * AMOUNT_STR) + (AMOUNT_POWERPLAY*(PowerPlay*5))
		kickVel = get_pcvar_num(P_KICK) + str
		kickVel += g_sprint[id] * 100
		//new Float:percent = g_KickPower[id] * 0.01
		
		//kickVel = floatround(float(kickVel) * percent);
		
		if(direction) {
			entity_get_vector(id, EV_VEC_angles, BallSpinDirection)
			curvecount = CURVE_COUNT
		}
		set_task(CURVE_TIME*2, "CurveBall", id)
		
		
	}
	else {
		curvecount = 0
		direction = 0
		kickVel = random_num(100, 600)
	}
	
	velocity_by_aim(id, kickVel, velocity)
	for(x=0;x<3;x++)
		distorig[0][x] = floatround(ballorig[x])
	
	/////////////////////WRITE ASSIST CODE HERE IF NEEDED///////////
	if ( iassist[ 0 ] == team ) {
		if ( iassist[ team ] == 15 ) {
			iassist[ team ] = 0
		}
	}
	else {
		// clear the assist list
		new ind
		for ( ind = 0; ind < 16; ind++ )
			assist[ ind ] = 0
		// clear the assist index
		iassist[ team ] = 0
		// set which team to track
		iassist[ 0 ] = team
	}
	assist[ iassist[ team ]++ ] = id
	/////////////////////WRITE ASSIST CODE HERE IF NEEDED///////////
	
	ballowner = id
	ballholder = 0
	//g_KickDelay[id] = 0.0;
	
	entity_set_origin(aball,testorigin)
	entity_set_vector(aball,EV_VEC_velocity,velocity)
	
	
	emit_sound(aball, CHAN_ITEM, kicked, 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	glow(id,0,0,0,0)
	
	beam(10)
	
	new aname[64]
	get_user_name(id,aname,63)
	
	format(temp1,63,"%s [%s] kicked the ball!",TeamNames[team],aname)
	client_print(0,print_console,"%s",temp1)

	return PLUGIN_HANDLED
}
/*====================================================================================================
 [Upgrades]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public BuyUpgrade(id) {
	
	new level[65], num[11], mTitle[101]
	if(GAME_MODE == MODE_PREGAME || GAME_MODE == MODE_HALFTIME) {
		
		format(mTitle,100,"%sCharacter Upgrade:^nCredits: %.0f  ",GAME_MODE==MODE_HALFTIME?"-- HALF-TIME^n":"",g_Experience[id])
		
		menu_upgrade[id] = menu_create(mTitle, "Upgrade_Handler");
		new x
		for(x=1; x<=UPGRADES; x++)
		{
			if((PlayerUpgrades[id][x] + 1) > UpgradeMax[x])
				format(level,64,"\r%s (MAXED Lvl: %i)",UpgradeTitles[x],UpgradeMax[x])
			else
				format(level,64,"%s \r(\wLvl: \y%i\r) \y-- \w%i credits",UpgradeTitles[x], PlayerUpgrades[id][x]+1, PlayerUpgrades[id][x]==(UpgradeMax[x]-1) ? 2 : 1)
			
			format(num, 10,"%i",x)
			menu_additem(menu_upgrade[id], level, num, 0)
		}
		menu_addblank(menu_upgrade[id], (UPGRADES+1))
		if(g_Experience[id] < 1.0)
			menu_setprop(menu_upgrade[id], MPROP_EXIT, MEXIT_ALL);
		else
			menu_setprop(menu_upgrade[id], MPROP_EXIT, MEXIT_NEVER);
	}
	else {
		new upgrades[512], len
		new plupgrade, maxupgrade
		len = format(upgrades[len], 511-len, "Character Stats^n")
		new x;
		for(x=1; x<=UPGRADES; x++) 
		{
			plupgrade = PlayerUpgrades[id][x]
			maxupgrade = UpgradeMax[x]
			
			len += format(upgrades[len],511-len, "\y-- \w%s \y-- \wLvl %i^n", UpgradeTitles[x],(plupgrade >= maxupgrade)?maxupgrade:plupgrade)
		}
		menu_upgrade[id] = menu_create(upgrades, "Done_Handler");
		menu_additem(menu_upgrade[id], "Done", "50", 0)
		//menu_addblank(menu_upgrade[id], 1)
		menu_setprop(menu_upgrade[id], MPROP_EXIT, MEXIT_NEVER);
	}
	
	menu_display(id, menu_upgrade[id], 0)
	return PLUGIN_HANDLED
}

public Done_Handler(id, menu, item)
	return PLUGIN_HANDLED	

public Upgrade_Handler(id, menu, item) {
		
	if(item == MENU_EXIT) {
		return PLUGIN_HANDLED	
	}
	if(g_Experience[id] < 1.0) {
		client_print(id, print_chat, "Type .ready to finalize, or .reset to start over!")
		return PLUGIN_HANDLED
	}
	new cmd[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, cmd,5, iName, 63, callback); 
		
	new upgrade = str_to_num(cmd)
	new playerupgrade = PlayerUpgrades[id][upgrade]
	new maxupgrade = UpgradeMax[upgrade]
	
	if(playerupgrade != maxupgrade+MAXLEVEL_BONUS) 
	{
		if(PlayerUpgrades[id][upgrade] == maxupgrade-1 && g_Experience[id] < 2.0) {
			client_print(id, print_chat, "You do not have enough credits to upgrade %s LvL %i",UpgradeTitles[upgrade],maxupgrade)	
		}
		else {
			if(playerupgrade < maxupgrade-1)
				playerupgrade += 1
			else
				playerupgrade += MAXLEVEL_BONUS+1
				
			g_Experience[id] -= 1.0;
			
			if(playerupgrade < maxupgrade)
				client_print(id,print_chat,"Upgraded Lvl %i %s, %.0f credits left.",playerupgrade,UpgradeTitles[upgrade],g_Experience[id])
			else {
				g_Experience[id] -= 1.0;
				client_print(id,print_chat,"Upgraded Lvl %i %s, %.0f credits left.",maxupgrade,UpgradeTitles[upgrade],g_Experience[id])
				client_print(id,print_chat,"You've reached max level (%i)! Received %i extra level bonus!",maxupgrade,MAXLEVEL_BONUS)
				
				play_wav(id, levelup)
			}
			switch(upgrade) {
				case STA: {
					new stam = playerupgrade * AMOUNT_STA
					entity_set_float(id, EV_FL_health, float(BASE_HP + stam))	//set_user_health(id, BASE_HP + stam)
				}
				case AGI: {
					if(!g_sprint[id]) {
						set_speedchange(id)
					}
				}
			}
		}
		PlayerUpgrades[id][upgrade] = playerupgrade
	}
	else {
		client_print(id,print_chat,"%s is maxed at LvL %i!",UpgradeTitles[upgrade],maxupgrade)
	}
	if(g_Experience[id] < 1.0) {
		client_print(id, print_chat, "Type .ready to finalize, or .reset to start over!")
		return PLUGIN_HANDLED
	}
	else
		BuyUpgrade(id)
	return PLUGIN_HANDLED
}

/*====================================================================================================
 [Turbo]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public meter()
{
	if(GAME_MODE != MODE_PREGAME && GAME_MODE != MODE_HALFTIME) {
		new id
		new sprintText[512], sec
		new r, g, b
		new len, x
		new ndir = -(DIRECTIONS)
		
		for(id = 1 ; id <= maxplayers ; id++)
		{
			sec = seconds[id]
			if(!is_user_alive(id) || is_user_bot(id))
				continue
			
			if(get_user_team(id) == 1) {
				r = 200
				g = 10
				b = 25
			}
			else {
				r = 25
				g = 10
				b = 255
			}
			
			if(id == ballholder)
			{
				set_hudmessage(r, g, b, POS_X, 0.75, 0, 0.0, 0.6, 0.0, 0.0, 1)
	
				len = format(sprintText, 127, "  [-CURVE-] ^n[")
	
				for(x=DIRECTIONS; x>=ndir; x--)
					if(x==0)
						len += format(sprintText[len], 127-len, "%s%s",direction==x?"0":"+", x==ndir?"]":"  ")
					else
						len += format(sprintText[len], 127-len, "%s%s",direction==x?"0":"=", x==ndir?"]":"  ")
	
				show_hudmessage(id, "%s", sprintText)
			}
		
			
			set_hudmessage(r, g, b, POS_X, POS_Y, 0, 0.0, 0.6, 0.0, 0.0, 3)
			
			if(sec > 30) {
				sec -= 2
				format(sprintText, 128, "  [-TURBO-] ^n[==============]")
				set_speedchange(id)
				g_sprint[id] = 0
			}
			else if(sec >= 0 && sec < 30 && g_sprint[id]) {
				sec += 2
				set_speedchange(id, 100.0) 
			}
			
			switch(sec)	{
				case 0:		format(sprintText, 128, "  [-TURBO-] ^n[||||||||||||||]")
				case 2:		format(sprintText, 128, "  [-TURBO-] ^n[|||||||||||||=]")
				case 4:		format(sprintText, 128, "  [-TURBO-] ^n[||||||||||||==]")
				case 6:		format(sprintText, 128, "  [-TURBO-] ^n[|||||||||||===]")
				case 8:		format(sprintText, 128, "  [-TURBO-] ^n[||||||||||====]")
				case 10:	format(sprintText, 128, "  [-TURBO-] ^n[|||||||||=====]")
				case 12:	format(sprintText, 128, "  [-TURBO-] ^n[||||||||======]")
				case 14:	format(sprintText, 128, "  [-TURBO-] ^n[|||||||=======]")
				case 16:	format(sprintText, 128, "  [-TURBO-] ^n[||||||========]")
				case 18:	format(sprintText, 128, "  [-TURBO-] ^n[|||||=========]")
				case 20:	format(sprintText, 128, "  [-TURBO-] ^n[||||==========]")
				case 22:	format(sprintText, 128, "  [-TURBO-] ^n[|||===========]")
				case 24:	format(sprintText, 128, "  [-TURBO-] ^n[||============]")
				case 26:	format(sprintText, 128, "  [-TURBO-] ^n[|=============]")
				case 28:	format(sprintText, 128, "  [-TURBO-] ^n[==============]")
				case 30: { 	
					format(sprintText, 128, "  [-TURBO-] ^n[==============]")
					sec = 92
				}
				case 32: sec = 0;
			}
			
			
		 	seconds[id] = sec
			show_hudmessage(id,"%s",sprintText)
		}
	}
}

set_speedchange(id, Float:speed=0.0) 
{
	//if(!freeze_player[id]) {
	new Float:agi = float( (PlayerUpgrades[id][AGI] * AMOUNT_AGI) + (id==ballholder?(AMOUNT_POWERPLAY * (PowerPlay*2)):0) )
	agi += (BASE_SPEED + speed) //250 is normal
	entity_set_float(id,EV_FL_maxspeed, agi)
	//}
}
/*
set_speedchange(id, Float:speed) 
{
	speed += BASE_SPEED //250 is normal
	entity_set_float(id,EV_FL_maxspeed, speed)
}*/

/*====================================================================================================
 [Misc.]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public createball() {

	new entity = create_entity("info_target")
	if (entity) {
		
		entity_set_string(entity,EV_SZ_classname,"PwnBall")
		entity_set_model(entity, ball)
		
		entity_set_int(entity, EV_INT_solid, SOLID_BBOX)
		entity_set_int(entity, EV_INT_movetype, MOVETYPE_BOUNCE)
		
		new Float:MinBox[3]
		new Float:MaxBox[3]
		MinBox[0] = -15.0
		MinBox[1] = -15.0
		MinBox[2] = 0.0
		MaxBox[0] = 15.0
		MaxBox[1] = 15.0
		MaxBox[2] = 12.0
		entity_set_vector(entity, EV_VEC_mins, MinBox)
		entity_set_vector(entity, EV_VEC_maxs, MaxBox)
		
		glow(entity,ballcolor[0],ballcolor[1],ballcolor[2],10)
		
		entity_set_float(entity,EV_FL_framerate,0.0)
		entity_set_int(entity,EV_INT_sequence,0)
	}
	//save our entity ID to aball variable
	aball = entity
	entity_set_float(entity,EV_FL_nextthink,halflife_time() + 0.05)
	return PLUGIN_HANDLED
}

public CreateGoalNets(mapname[]) {
	
	new endzone
	new Float:orig[3]
	new Float:MinBox[3], Float:MaxBox[3], x
	for(x=1;x<3;x++) {
		endzone = create_entity("info_target")
		if (endzone) {
	
			entity_set_string(endzone,EV_SZ_classname,"soccerjam_goalnet")
			entity_set_model(endzone, "models/chick.mdl")
			entity_set_int(endzone, EV_INT_solid, SOLID_BBOX)
			entity_set_int(endzone, EV_INT_movetype, MOVETYPE_NONE)
			
			MinBox[0] = -25.0;	MinBox[1] = -145.0;	MinBox[2] = -36.0
			MaxBox[0] =  25.0;	MaxBox[1] =  145.0;	MaxBox[2] =  70.0
	
			entity_set_vector(endzone, EV_VEC_mins, MinBox)
			entity_set_vector(endzone, EV_VEC_maxs, MaxBox)
			
			switch(x) {
				case 1: {
					orig[0] = 2110.0
					orig[1] = 0.0
					orig[2] = 1604.0
				}
				case 2: {
					orig[0] = -2550.0
					orig[1] = 0.0
					orig[2] = 1604.0
				}	
			}
			
			entity_set_origin(endzone,orig)
			
			entity_set_int(endzone, EV_INT_team, x)
			set_entity_visibility(endzone, 0)
			GoalEnt[x] = endzone
		}
	}
	
}

stock create_wall(mapname[]) {
	if(equali(mapname, "soccerjam")) {
		new wall = create_entity("func_wall")
		if(wall) 
		{
			new Float:orig[3]
			new Float:MinBox[3], Float:MaxBox[3]
			entity_set_string(wall,EV_SZ_classname,"Blocker")
			entity_set_model(wall, "models/chick.mdl")
		
			entity_set_int(wall, EV_INT_solid, SOLID_BBOX)
			entity_set_int(wall, EV_INT_movetype, MOVETYPE_NONE)
	
			MinBox[0] = -72.0;	MinBox[1] = -100.0;	MinBox[2] = -72.0
			MaxBox[0] =  72.0;	MaxBox[1] =  100.0;	MaxBox[2] =  72.0
			
			entity_set_vector(wall, EV_VEC_mins, MinBox)
			entity_set_vector(wall, EV_VEC_maxs, MaxBox)
			
			orig[0] = 2355.0
			orig[1] = 1696.0
			orig[2] = 1604.0
			entity_set_origin(wall,orig)
			set_entity_visibility(wall, 0)
		}
	}
}

stock create_mascot(team)//, Float:orig[3]) 
{
	new Float:MinBox[3], Float:MaxBox[3]
	new mascot = create_entity("info_target")
	if(mascot) 
	{
		entity_set_string(mascot,EV_SZ_classname,"Mascot")
		entity_set_model(mascot, TeamMascots[team])
		Mascots[team] = mascot
		
		entity_set_int(mascot, EV_INT_solid, SOLID_NOT)
		entity_set_int(mascot, EV_INT_movetype, MOVETYPE_NONE)
		entity_set_int(mascot, EV_INT_team, team)
		MinBox[0] = -16.0;	MinBox[1] = -16.0;	MinBox[2] = -72.0
		MaxBox[0] =  16.0;	MaxBox[1] =  16.0;	MaxBox[2] =  72.0
		entity_set_vector(mascot, EV_VEC_mins, MinBox)
		entity_set_vector(mascot, EV_VEC_maxs, MaxBox)
		//orig[2] += 200.0
		
		entity_set_origin(mascot,MascotsOrigins)
		entity_set_float(mascot,EV_FL_animtime,2.0)
		entity_set_float(mascot,EV_FL_framerate,1.0)
		entity_set_int(mascot,EV_INT_sequence,0)
		
		if(team == 2)
			entity_set_byte(mascot, EV_BYTE_controller1, 115)
		
		entity_set_vector(mascot,EV_VEC_angles,MascotsAngles)
		entity_set_float(mascot,EV_FL_nextthink,halflife_time() + 1.0)
	}
}
public pfn_keyvalue(entid) {
	
	if(!RunOnce) {
		RunOnce = true
		
		new entity = create_entity("game_player_equip");
		if(entity) {
			DispatchKeyValue(entity, "weapon_knife", "1");
			//DispatchKeyValue(entity, "weapon_scout", "1");
			DispatchKeyValue(entity, "targetname", "roundstart");
			DispatchSpawn(entity);
		}
	}
	new classname[32], key[32], value[32]
	copy_keyvalue(classname, 31, key, 31, value, 31)

	new temp_origins[3][10], x, team
	new temp_angles[3][10]
	
	if(equal(key, "classname") && equal(value, "soccerjam_goalnet"))
		DispatchKeyValue("classname", "func_wall")
		
	if(equal(classname, "game_player_equip")){
		remove_entity(entid);
	}
	else if(equal(classname, "func_wall"))
	{
		if(equal(key, "team"))
		{
			team = str_to_num(value)
			if(team == 1 || team == 2) {
				GoalEnt[team] = entid
				set_task(1.0, "FinalizeGoalNet", team)
			}
		}	
	}
	else if(equal(classname, "soccerjam_mascot"))
	{
		if(equal(key, "team"))
		{
			team = str_to_num(value)
			create_mascot(team)
		}
		else if(equal(key, "origin"))
		{
			parse(value, temp_origins[0], 9, temp_origins[1], 9, temp_origins[2], 9)
			for(x=0;x<3;x++)
				MascotsOrigins[x] = floatstr(temp_origins[x])
		}
		else if(equal(key, "angles")) 
		{
			parse(value, temp_angles[0], 9, temp_angles[1], 9, temp_angles[2], 9)
			for(x=0;x<3;x++)
				MascotsAngles[x] = floatstr(temp_angles[x])
		}
	}
	else if(equal(classname, "soccerjam_teamball")) 
	{
		if(equal(key, "team")) 
		{
			team = str_to_num(value)
			for(x=0;x<3;x++)
			{
				TeamBallOrigins[team][x] = TEMP_TeamBallOrigins[x]
			}
			
		}
		else if(equal(key, "origin")) 
		{
			parse(value, temp_origins[0], 9, temp_origins[1], 9, temp_origins[2], 9)
			for(x=0;x<3;x++)
				TEMP_TeamBallOrigins[x] = floatstr(temp_origins[x])	
		}
	}
	else if(equal(classname, "soccerjam_ballspawn")) 
	{
		if(equal(key, "origin")) {
			is_kickball = 1
			
			if(ballspawncount < MAX_BALL_SPAWNS) {
				parse(value, temp_origins[0], 9, temp_origins[1], 9, temp_origins[2], 9)
				
				BallSpawnOrigin[ballspawncount][0] = floatstr(temp_origins[0])
				BallSpawnOrigin[ballspawncount][1] = floatstr(temp_origins[1])
				BallSpawnOrigin[ballspawncount][2] = floatstr(temp_origins[2]) + 10.0
				
				ballspawncount++
			}
		}
	}
}

public FinalizeGoalNet(team) {
	new goalnet = GoalEnt[team]
	//entity_get_vector(goalnet, EV_VEC_origin, GoalEntOrig[team])
	entity_set_string(goalnet,EV_SZ_classname,"soccerjam_goalnet")
	entity_set_int(goalnet, EV_INT_team, team)
	set_entity_visibility(goalnet, 0)
}

public touchBlocker(pwnball, blocker) {
	new Float:orig[3] = { 2234.0, 1614.0, 1604.0 }
	entity_set_origin(pwnball, orig)
}
/*====================================================================================================
 [Misc.]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public editTextMsg() 
{
	new string[64], radio[64]
	get_msg_arg_string(2, string, 63)
	
	if( get_msg_args() > 2 ) 
		get_msg_arg_string(3, radio, 63)
	
	if(containi(string, "#Game_will_restart") != -1 || containi(radio, "#Game_radio") != -1)
		return PLUGIN_HANDLED
		
	return PLUGIN_CONTINUE
}

public client_connect(id)
	if(is_kickball)
		set_user_info(id,"_vgui_menus","0")
		
public AutoRespawn(id) {
	if(is_dead[id] && is_user_connected(id)) {
		cs_user_spawn(id)
		strip_user_weapons(id)
	}
}
public AutoRespawn2(id)
	if(is_dead[id] && is_user_connected(id)) {
		is_dead[id] = false
		cs_user_spawn(id)
		if(!has_knife[id])
			give_knife(id)
	}

play_wav(id, wav[])
	client_cmd(id,"spk %s",wav)
	

cmdSpectate(id) {
	cs_set_user_team(id, CS_TEAM_SPECTATOR, CS_DONTCHANGE)
	if(is_user_alive(id))
		user_kill(id)
}

public give_knife(id) {
	if(id > 1000)
		id -= 1000

	remove_task(id+1000)

	give_item(id, "weapon_knife")
	has_knife[id] = true;
}

Float:normalize(Float:nVel)
{
	if(nVel > 180.0) {
		nVel -= 360.0
	}
	else if(nVel < -179.0) {
		nVel += 360.0
	}

	return nVel
}
/*====================================================================================================
 [Cleanup]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public client_disconnect(id) {
	new m;
	for(m = 1; m<=RECORDS; m++)
		MadeRecord[id][m] = 0
	remove_task(id)
	if(ballholder == id ) {
		clearBall()
	}
	if(ballowner == id) {
		ballowner = 0
	}
	PlayerKills[id] = 0
	PlayerDeaths[id] = 0
	is_dead[id] = false
	seconds[id] = 0
	g_sprint[id] = 0
	has_knife[id] = false;
	PressedAction[id] = 0
	//g_KickDelay[id] = 0.0;
	
	remove_task(id+4545);
	//g_Experience[id] = STARTING_CREDITS
	//for(new x=1;x<=UPGRADES;x++)
	//	PlayerUpgrades[id][x] = 0
	
	//CleanUpPlayer(id)
	new num, players[32]
	get_players(players,num, "c")
	
	if(!num) {
		PostGame();
		moveBall(0)
		server_cmd("sv_restart 4")
	}
	
	PlayerDisconnectID[PlayerDisconnectCount] = id;
	PlayerDisconnectCount += 1;
}

copy_stats( id, dest_id )
{
	for(new x=1;x<=UPGRADES;x++)
		PlayerUpgrades[dest_id][x] = PlayerUpgrades[id][x];	
		
	for(new x=1;x<=UPGRADES;x++)
		PlayerUpgrades[id][x] = 0;
		
	g_Points[dest_id] = g_Points[id];
	g_Points[id] = 0.0;	
}

cleanup() {
	new x, id, m
	for(x=1;x<=RECORDS;x++) {
		TopPlayer[0][x] = 0
		TopPlayer[1][x] = 0
		TopPlayerName[x][0] = 0
	}
	
	for(id=1;id<=maxplayers;id++) {
		PlayerDeaths[id] = 0
		PlayerKills[id] = 0
	
		GoalyPoints[id] = 0
		Ready[id] = false
		g_Points[id] = 0.0;
		freeze_player[id] = false;
			
		for(m = 1; m<=RECORDS; m++)
			MadeRecord[id][m] = 0
	}
	candidates[T] = 0
	candidates[CT] = 0
	for(x=0;x<7;x++)
		LineUp[x] = 0
	
	winner = 0
	ROUND = 0
	timer = COUNTDOWN_TIME
	TimeLeft = (get_pcvar_num(P_TIME) * 60)
	score[T] = 0
	score[CT] = 0
	set_cvar_num("SCORE_CT",0)
	set_cvar_num("SCORE_T",0)
	GameOver = false
	OverTime = 0
	ShootOut = 0
	PowerPlay = 0
	
}

/*====================================================================================================
 [Help]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public client_putinserver(id) {
	if(is_kickball)
		set_task(30.0,"soccerjamHelp",id)
	client_cmd(id, "cl_forwardspeed 1000")
	client_cmd(id, "cl_backspeed 1000")
	client_cmd(id, "cl_sidespeed 1000")
	
	//if(!is_user_bot(id))
	//	CheckPlayer(id);
}

public soccerjamHelp(id) {
	new name[32]
	get_user_name(id,name,31)
	client_print(id,print_chat,"=== - Soccer Jam Tournament Version - ===")
	client_print(id,print_chat,".ready - ready up")
	client_print(id,print_chat,".wait - set wait status")
	client_print(id,print_chat,".reset - redo upgrades" )
	client_print(id,print_chat,".stats <name> - Shows stats (Endgame only)." )
	//client_print(id,print_chat,"=========------------------========")
	
	
	if(GAME_MODE == MODE_GAME && g_Experience[id] >= 4)
	{
		new i;
		for(i=1;i<UPGRADES;i++)
			PlayerUpgrades[id][i] = 3;
		PlayerUpgrades[id][UPGRADES] = 0;
		
		g_Experience[id] = 0.0;
	}
	
}

public handle_say(id) 
{
	new said[192]//, help[7]
	read_args(said,192)
	remove_quotes(said)
	//client_print( id, print_chat, "-- SAID SOMETHING");
	new cmdReady[32], info[32], x
	parse(said, cmdReady, 31, info, 31);
	
	if(GAME_MODE == MODE_PREGAME || GAME_MODE == MODE_HALFTIME) {
		
		//strcat(cmdReady, said, 6)
		if(containi(cmdReady, ".ready") != -1) {
			if(g_Experience[id] >= 1.0) {
				client_print(id,print_chat,"You must use all credits before becoming ready!")	
			}
			else {
				remove_task(id+4545);
				Ready[id] = true
			}
		}
		else if(containi(cmdReady, ".wait") != -1) {
			Ready[id] = false	
		}
		else if(containi(cmdReady, ".reset") != -1) {
			Ready[id] = false
			
	
			if(GAME_MODE == MODE_HALFTIME) {
				//g_Experience[id] = g_Points[id] / get_cvar_float("sj_point_multiplier");
				//for(x=1;x<=UPGRADES;x++)
				//	PlayerUpgrades[id][x] = Old_PlayerUpgrades[id][x];
				for(x=1;x<=UPGRADES;x++)
					PlayerUpgrades[id][x] = 0;
				g_Experience[id] = STARTING_CREDITS + (g_Points[id] / get_pcvar_float(P_POINT_MULTI));
			}
			else if(GAME_MODE == MODE_PREGAME) {
				for(x=1;x<=UPGRADES;x++)
					PlayerUpgrades[id][x] = 0;
				g_Experience[id] = STARTING_CREDITS
			}
			BuyUpgrade(id)
		}
	}
		
	//strcat(help,said,6)
	if((containi(cmdReady, "help") != -1) )
		soccerjam_help(id)
	if( (contain(cmdReady, "spec") != -1) )
		cmdSpectate(id)
		
	return PLUGIN_CONTINUE
	
}

public soccerjam_help(id) {
	new help_title[64], msg[2047]
	format(help_title,63,"SoccerJam Help")
	add(msg,2046,"<body bgcolor=#000000><font color=#FFB000><br>")
	add(msg,2046,"<center><h2>Soccer Jam Help</h2><br><table><tr><td><p><b><font color=#FFB000>")
	add(msg,2046,"<h2>MOVES</h2>")
	add(msg,2046,"Kick - ^"Use^" or ^"E^" key (Hold to charge power, or press in air to instant kick.)<br>")
	add(msg,2046,"Turbo - ^"Drop^" or ^"G^" key <br>")
	add(msg,2046,"Upgrades - ^"Lastinv^" or ^"Q^" key<br>")
	add(msg,2046,"Dive - Move left/right + Jump<br>")
	add(msg,2046,"Catch - Run into the ball<br><br>")
	add(msg,2046,"<h2>STATS</h2>")
	add(msg,2046,"Stamina - User gains more health.<br>")
	add(msg,2046,"Strength - Allows stronger kicking and more chance to harm someone with ball.<br>")
	add(msg,2046,"Agility - Increases the players speed.<br>")
	add(msg,2046,"Dexterity - Increases player's chance of catching ball.<br>")
	add(msg,2046,"Disarm - Chance to disarm ball and knife every connected attack.<br><br>")
	add(msg,2046,"<h2>TIPS</h2>")
	add(msg,2046,"- Use your experience when available, it is valuable help needed.<br>")
	add(msg,2046,"- For more control kicking, vary how high or low you aim.<br>")
	add(msg,2046,"- Holding your kick key <b>can</b> improve catching.<br>")
	add(msg,2046,"</b><br></td></tr></table></center>")
	show_motd(id,msg,help_title)
}


Event_Record(id, recordtype, amt) {
	if(GAME_MODE != MODE_PREGAME && GAME_MODE != MODE_HALFTIME) {
		if(amt == -1)
			MadeRecord[id][recordtype]++
		else
			MadeRecord[id][recordtype] = amt
			
		new playerRecord = MadeRecord[id][recordtype]
		if(playerRecord > TopPlayer[1][recordtype]) 
		{
			TopPlayer[0][recordtype] = id
			TopPlayer[1][recordtype] = playerRecord
			new name[MAX_NAME_LENGTH+1]
			get_user_name(id,name,MAX_NAME_LENGTH)
			format(TopPlayerName[recordtype],MAX_NAME_LENGTH,"%s",name)
		}
	
		switch(recordtype) {
			case GOAL: g_Points[id] += POINTS_GOAL
			case ASSIST: g_Points[id] += POINTS_ASSIST
			case STEAL: g_Points[id] += POINTS_STEAL
			case KILL: g_Points[id] += POINTS_KILL
			case POSSESSION: g_Points[id] += POINTS_POSESSION
			//case POWERPLAY: g_Points[id] += POINTS_POWERPLAY
			case GOALSAVE: g_Points[id] += POINTS_GOALSAVE
			case DISTANCE: g_Points[id] += POINTS_DISTANCE
		}
	}
}
/*====================================================================================================
 [Post Game]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
public showHud() {
	set_hudmessage(255, 0, 20, -1.0, 0.35, 1, 1.0, 1.5, 0.1, 0.1, HUD_CHANNEL)
	show_hudmessage(0,"%s",scoreboard)
}
public showHud2(awards[]) {
	set_hudmessage(250, 130, 20, 0.4, 0.35, 0, 1.0, 2.0, 0.1, 0.1, 2)
	show_hudmessage(0, "%s", awards)
}

public displayWinnerAwards()
{
	new x
	for(x=1;x<=RECORDS;x++)
		if(!TopPlayer[0][x])
			format(TopPlayerName[x],MAX_NAME_LENGTH,"Nobody")

	
	//Display our Winning Team, with Awards, and kill Comm Chair of opponent
	new awards[513]
	new len = 0
	len += format(awards[len], 512-len, "%s Team WINS!!^n", (winner == 1 ? "Terrorist" : "CT") )
	len += format(awards[len], 512-len, "%s - %i  |  %s - %i^n^n", TeamNames[T],score[T],TeamNames[CT],score[CT])
	len += format(awards[len], 512-len, "      --Awards--^n")
	len += format(awards[len], 512-len, "%s -- %i Goals ^n", TopPlayerName[GOAL], TopPlayer[1][GOAL])
	len += format(awards[len], 512-len, "%s -- %i Steals^n", TopPlayerName[STEAL], TopPlayer[1][STEAL])
	len += format(awards[len], 512-len, "%s -- %i Assists^n", TopPlayerName[ASSIST], TopPlayer[1][ASSIST])
	len += format(awards[len], 512-len, "%s -- %i Ball Kills^n", TopPlayerName[KILL], TopPlayer[1][KILL])
	len += format(awards[len], 512-len, "%s -- %i ft (Longest Goal)^n", TopPlayerName[DISTANCE], TopPlayer[1][DISTANCE])

	set_task(1.0, "showHud2", 0, awards, 513, "a", 10)
	
}

public PostGame() 
{
	ROUND = 0;
	GAME_MODE = MODE_PREGAME
	
	moveBall(0)
	
	new id, x
	for(id=1;id<=maxplayers;id++)
	{
		Ready[id] = false;
		g_Experience[id] = STARTING_CREDITS
		for(x=1;x<=UPGRADES;x++)
			PlayerUpgrades[id][x] = 0
		BuyUpgrade(id);
	}
}

public ShotClock() {
	new score_t = score[T], score_ct = score[CT]
	if(timer <= 0) {
		timer = SHOTCLOCK_TIME
		if(!freeze_player[LineUp[next]] && is_user_connected(LineUp[next]))
			SetAsWatcher(LineUp[next], ShootOut)
		next--
		
		if(next >= 0) {
			new shooter = LineUp[next]
			
			if(!is_user_connected(shooter))
			{
				timer = 0;
				ShotClock();
			}
			moveBall(1)
			cs_user_spawn(shooter)
			entity_set_origin(shooter, BallSpawnOrigin[0])
			freeze_player[shooter] = true;
			is_dead[shooter] = false
			seconds[shooter] = 0
			g_sprint[shooter] = 0
			PressedAction[shooter] = 0
			entity_set_float(shooter,EV_FL_maxspeed, 0.0)
			set_task(3.0, "ShotClock", 0)
			
		}
		else {
			new id;
			for(id=1;id<=maxplayers;id++)
				freeze_player[id] = false;
		
			moveBall(0)
			entity_set_float(candidates[ShootOut==1?2:1], EV_FL_takedamage, 1.0)
			if(ShootOut == 2) {
				server_cmd("sv_restart 8")
				
				if(score_t > score_ct)
					winner = T
				else if(score_ct > score_t)
					winner = CT
				
				if(winner) {
					GAME_MODE = MODE_NONE
					scoreboard[0] = 0;
					format(scoreboard,1024,"Team %s ^nWINS!",TeamNames[winner])
					set_task(1.0,"showHud",456321,"",0,"a",6)
					//server_cmd("sv_restart 5")
				}
				else {
					ShootOut = 0
					OverTime++
					GAME_MODE = MODE_NONE
					//server_cmd("sv_restart 8")
					scoreboard[0] = 0;
					format(scoreboard,1024,"Tie Game!!^nMoving to OVERTIME Round %i^nFirst to score wins!",OverTime)
					set_task(1.0,"showHud",456321,"",0,"a",6)
				}
			}
			else {
				//candidates[2] = 0
				
				server_cmd("sv_restart 5")
				ShootOut = 2
				scoreboard[0] = 0;
				format(scoreboard,1024,"Team %s is next for SHOOTOUT!",TeamNames[ShootOut])
				set_task(1.0,"showHud",456321,"",0,"a",3)
			}
		}
	}
	else {
		new shotclock[256], name[32]
		if(is_user_connected(LineUp[next]))
		{
			get_user_name(LineUp[next], name, 31)
			if(freeze_player[LineUp[next]]) {
				play_wav(0, whistle);
				set_speedchange(LineUp[next], 0.0);
				freeze_player[LineUp[next]] = false;
				
				new goaly = candidates[ShootOut==1?2:1]
				seconds[goaly] = 0
				g_sprint[goaly] = 0
			}
		}
		else
		{
			format(name, 31, "Nobody");	
		}
		
				
		format(shotclock, 255, "Shooting: %s ^nShot Clock: %i^nTeam %s: %i | Team %s: %i",name,timer,TeamNames[T],score_t,TeamNames[CT],score_ct)
		set_hudmessage(255, 10, 20, -1.0, 0.6, 1, 1.0, 1.0, 1.0, 0.5, HUD_CHANNEL)
		show_hudmessage(0, "%s",shotclock)
		timer--
		set_task(0.9,"ShotClock",0)
	}
}

public BeginCountdown() {
	if(!timer) {
		timer = COUNTDOWN_TIME
		TimeLeft = (get_pcvar_num(P_TIME) * 60)
			
		GAME_MODE = MODE_GAME
	}
	else {
		new output[32]
		num_to_word(timer,output,31)
		client_cmd(0,"spk vox/%s.wav",output)
		
		if(timer > (COUNTDOWN_TIME / 2))
			set_hudmessage(20, 250, 20, -1.0, 0.55, 1, 1.0, 1.0, 1.0, 0.5, 2)
		else
			set_hudmessage(255, 0, 0, -1.0, 0.55, 1, 1.0, 1.0, 1.0, 0.5, 2) 	
			
		if(timer > (COUNTDOWN_TIME - 2))
			show_hudmessage(0, "GAME BEGINS IN...^n%i",timer)
		else
			show_hudmessage(0, "%i",timer)
			
		client_print(0,print_chat,"GAME BEGINS IN... %i", timer)	
				
		if(timer == 1)
			server_cmd("sv_restart 1")
		timer--
		set_task(0.9,"BeginCountdown",9999)
	}
}

public clearBall() {
	play_wav(0, returned);
	format(temp1,63,"Ball RESPAWNED at the middle!")
	moveBall(1)
}

/*====================================================================================================
 [Special FX]

 Purpose:	$$

 Comment:	$$

====================================================================================================*/
TerminatePlayer(id, mascot, team, Float:dmg) {
	new orig[3], Float:morig[3], iMOrig[3], x
	
	get_user_origin(id, orig)
	entity_get_vector(mascot,EV_VEC_origin,morig)
	
	for(x=0;x<3;x++)
		iMOrig[x] = floatround(morig[x])
	
	fakedamage(id,"Terminator",dmg,1)

	new loc = (team == 1 ? 100 : 140)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(0)
	write_coord(iMOrig[0])			//(start positionx) 
	write_coord(iMOrig[1])			//(start positiony)
	write_coord(iMOrig[2] + loc)			//(start positionz)
	write_coord(orig[0])			//(end positionx)
	write_coord(orig[1])		//(end positiony)
	write_coord(orig[2])		//(end positionz) 
	write_short(g_fxBeamSprite) 			//(sprite index) 
	write_byte(0) 			//(starting frame) 
	write_byte(0) 			//(frame rate in 0.1's) 
	write_byte(7) 			//(life in 0.1's) 
	write_byte(120) 			//(line width in 0.1's) 
	write_byte(25) 			//(noise amplitude in 0.01's) 
	write_byte(250)			//r
	write_byte(0)			//g
	write_byte(0)			//b
	write_byte(220)			//brightness
	write_byte(1) 			//(scroll speed in 0.1's)
	message_end()
}

glow(id, r, g, b, on) {
	if(on == 1) {
		set_rendering(id, kRenderFxGlowShell, r, g, b, kRenderNormal, 255)
		entity_set_float(id, EV_FL_renderamt, 1.0)
	}
	else if(!on) {
		set_rendering(id, kRenderFxNone, r, g, b,  kRenderNormal, 255)
		entity_set_float(id, EV_FL_renderamt, 1.0)
	}
	else if(on == 10) {
		set_rendering(id, kRenderFxGlowShell, r, g, b, kRenderNormal, 255)
		entity_set_float(id, EV_FL_renderamt, 1.0)
	}
}


beam(life) {
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(22); // TE_BEAMFOLLOW
	write_short(aball); // ball
	write_short(beamspr); // laserbeam
	write_byte(life); // life
	write_byte(5); // width
	write_byte(250); // R
	write_byte(80); // G
	write_byte(10); // B
	write_byte(175); // brightness
	message_end();	
}


flameWave(myorig[3]) {
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY, myorig) 
    write_byte( 21 ) 
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2] + 16) 
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2] + 500) 
    write_short( fire )
    write_byte( 0 ) // startframe 
    write_byte( 0 ) // framerate 
    write_byte( 15 ) // life 2
    write_byte( 50 ) // width 16 
    write_byte( 10 ) // noise 
    write_byte( 255 ) // r 
    write_byte( 0 ) // g 
    write_byte( 0 ) // b 
    write_byte( 255 ) //brightness 
    write_byte( 1 / 10 ) // speed 
    message_end() 
    
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY,myorig) 
    write_byte( 21 ) 
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2] + 16) 
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2] + 500) 
    write_short( fire )
    write_byte( 0 ) // startframe 
    write_byte( 0 ) // framerate 
    write_byte( 10 ) // life 2
    write_byte( 70 ) // width 16 
    write_byte( 10 ) // noise 
    write_byte( 255 ) // r 
    write_byte( 50 ) // g 
    write_byte( 0 ) // b 
    write_byte( 200 ) //brightness 
    write_byte( 1 / 9 ) // speed 
    message_end() 
    
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY,myorig)
    write_byte( 21 )
    write_coord(myorig[0])
    write_coord(myorig[1])
    write_coord(myorig[2] + 16) 
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2] + 500) 
    write_short( fire )
    write_byte( 0 ) // startframe 
    write_byte( 0 ) // framerate 
    write_byte( 10 ) // life 2
    write_byte( 90 ) // width 16 
    write_byte( 10 ) // noise 
    write_byte( 255 ) // r 
    write_byte( 100 ) // g 
    write_byte( 0 ) // b 
    write_byte( 200 ) //brightness 
    write_byte( 1 / 8 ) // speed 
    message_end() 
    
    //Explosion2 
    message_begin( MSG_BROADCAST, SVC_TEMPENTITY) 
    write_byte( 12 ) 
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2])
    write_byte( 80 ) // byte (scale in 0.1's) 188 
    write_byte( 10 ) // byte (framerate) 
    message_end() 

    //TE_Explosion 
    message_begin( MSG_BROADCAST, SVC_TEMPENTITY ) 
    write_byte( 3 ) 
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2])
    write_short( fire ) 
    write_byte( 65 ) // byte (scale in 0.1's) 188 
    write_byte( 10 ) // byte (framerate) 
    write_byte( 0 ) // byte flags 
    message_end() 

    //Smoke 
    message_begin( MSG_BROADCAST,SVC_TEMPENTITY,myorig) 
    write_byte( 5 ) // 5
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2]) 
    write_short( smoke )
    write_byte( 50 )  // 2
    write_byte( 10 )  // 10
    message_end()
    
    return PLUGIN_HANDLED
}
