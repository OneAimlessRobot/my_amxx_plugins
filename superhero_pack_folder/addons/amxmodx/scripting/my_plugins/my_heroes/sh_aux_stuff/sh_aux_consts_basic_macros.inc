#if defined sh_aux_basic_macros
  #endinput
#endif
#define sh_aux_basic_macros


#define MAX_MAP_DIST_POSSIBLE (8192.0*floatsqroot(3.0))

/*
 first param is cube side length

*/
#define CENTER_CUBE_VEX_DISTANCE(%1) (%1*floatsqroot(3.0))

#define SH_HUD_MSG_BUFF_SIZE 128

#define STRLEN_FOR_FILES 128
#define STRLEN_FOR_NAMES 24


#define MINI_STRING_SIZE 32
#define STRING_SIZE 128
#define BIG_STRING_SIZE (STRING_SIZE*4)
/**

	Useful macro to shorten code!
	the first parameter is the user.
	We will first check if they are alive
	And then the next parameter is the hero id.
	We will they check if they have that hero!
	It can be a hero that obtains a hero id
	Or an actual hero id
	It does not matter as long as the result is anything
	previously returned by either
	shCreateHero
	Or sh_create_hero
 */
#define client_is_hero_user(%1,%2) (is_user_alive(%1)&&sh_get_user_has_hero(%1,%2))
