#if defined sh_soccer_funcs
  #endinput
#endif
#define sh_soccer_funcs

new const BALL_BOUNCE_GROUND[ ] = "kickball/bounce.wav";
new const g_szBallModel[ ]     = "models/kickball/ball.mdl";

new kicked[] = "shmod/roberto_carlos/kickball/kicked.wav"
new gotball[] = "shmod/roberto_carlos/kickball/gotball.wav"

new beamspr
new ballcolor[3] = { 255,200,100 }
new ballbeam[3] = { 20,50,255 }

#define BALL_RETRIEVE true
#define BALL_CLASSNAME "soccer_ball"

#define BALL_SPEED 1600.0

#define BALL_DMG 100

#define BALL_REM_TASKID 11123

#define BALL_CURVE_TASKID 19923

#define AVG_FACTOR 3

#define BALL_REM_TIME 5.0

#define MAX_ENTITIES 2048

#define BALL_MASS 1.8

#define CURVE_APEX_DIST 1.0

native clear_balls()

native kick_the_ball(id)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
