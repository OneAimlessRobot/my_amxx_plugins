#include <amxmodx>
#include <engine>

#define PLUGIN    "3Rd view"
#define AUTHOR    "Ferrari & Sylvanor"
#define VERSION    "1.0"

#define MAX_PLAYERS 32

new g_pCamera

// pas besoin de taguer bool, fais comme tu veux cependant.
new g_bCamera[ MAX_PLAYERS + 1 ]

public plugin_precache() 
{      
	precache_model( "models/rpgrocket.mdl" ); 
}
public plugin_init()
{
    // register_plugin �a peut pas faire de mal non plus

    g_pCamera = register_cvar("amx_3rdview", "1")
    register_clcmd("say /3pers", "cmdCamera")
    register_clcmd("say_team /3pers", "cmdCamera")

}

public client_putinserver( id )
{
    g_bCamera[ id ] = false
}

public cmdCamera( id )
{
    if( get_pcvar_num( g_pCamera ) )
    {
        if( (g_bCamera[ id ] = !g_bCamera[ id ]) )
        {
            set_view( id, CAMERA_3RDPERSON )
        }
        else
        {
            set_view( id, CAMERA_NONE );
        }
    }
    return PLUGIN_HANDLED // PLUGIN_CONTINUE ou m�me rien du tout si tu veux pouvoir voir la commande dans le tchat.
}  