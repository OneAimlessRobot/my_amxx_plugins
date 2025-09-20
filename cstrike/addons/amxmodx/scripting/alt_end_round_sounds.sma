
    
    /* - - - - - - - - - - -

        AMX Mod X script.
        Copyright (C) 2007 - Arkshine

        Plugin  : 'Alternative End Round Sounds'
        Version :  v2.3b

        Original idea and plugin by PaintLancer.
        Orignal thread : http://forums.alliedmods.net/showthread.php?t=6784
        
        This program is free software; you can redistribute it and/or modify it
        under the terms of the GNU General Public License as published by the
        Free Software Foundation; either version 2 of the License, or (at
        your option) any later version.

        This program is distributed in the hope that it will be useful, but
        WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
        General Public License for more details.

        You should have received a copy of the GNU General Public License
        along with this program; if not, write to the Free Software Foundation,
        Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

        In addition, as a special exception, the author gives permission to
        link the code of this program with the Half-Life Game Engine ("HL
        Engine") and Modified Game Libraries ("MODs") developed by Valve,
        L.L.C ("Valve"). You must obey the GNU General Public License in all
        respects for all of the code used other than the HL Engine and MODs
        from Valve. If you modify this file, you may extend this exception
        to your version of the file, but you are not obligated to do so. If
        you do not wish to do so, delete this exception statement from your
        version.

        ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
        
        Description :
        - - - - - - -
            Plays random music at the end of a round according to who wins,
            instead of just "Terrorists Win" or "Counter-Terrorists Win".

            
        Features :
        - - - - - -
            * Support for mp3 and wav files
            * Using a file for the sounds
            * Per-map config files supported
            * Per-map prefix config files supported
            * Sounds can be toggle on/off by players
            * Ability to choice x sounds to be precache per map
            * Multilingual support

            
        Requirements :
        - - - - - - - -
            * CS 1.6 / CZ
            * AMX/X 1.7x or higher

            
        Cvars :
        - - - -
            * ers_enabled <iNum
            
                <0|1> Disable/Enable this plugin. 
                (default: 1)
            
            
            * ers_player_toggle <iNum>
            
                <0|1> Disable/Enable the client command /roundsound 
                (default: 1)
                
                
            * erc_time_ads <iTime>
            
                Times in seconds between each ads messages. 0 disable ads. 
                (default: 120)

                
            * erc_random_precache <iMaxTeam or iMax_T-iMax_CT>

                Specify how many sounds by team you want to precache randomly among all sounds.
                This means that x sounds will be choosen randomly among all sounds of each team so to be precache at each map. ( 0 = disable feature )
                
                e.g : erc_random_precache "2"   : 2 sounds will be choosen among all CTs sounds and all Ts sounds
                      erc_random_precache "2-3" : 2 Ts sounds will be choosen randomly among all Ts sounds.
                                                  3 CT sound will be choosen randomly among all CTs sounds.
                                                  /!\ Don't forget to insert '-' .
                                                  
                /!\ Map change on cvar change required !

                
        Client command :
        - - - - - - - - 
            * say /roundsound : Give to players the ability to turn on/off the end round sounds

            
        Changelog :
        - - - - - -

            -> Arksine :

             v3.0  - [ 2007-xx-xx ] ( Major update )

                      - Soon. A lot of changes/new features. Huge update. ;)

             v2.3b - [ 2007-11-22 ]
                
                      (!) Fixed a compatibility bug from 2.3a version.
                        
             v2.3a - [ 2007-11-19 ]

                      (+) Added compatibility for Amxx 1.7x.
                      (!) Now 'erc_random_precache' cvar is set to 0 by default.
                      (!) Fixed. At the first start of server, value from 'erc_random_precache' cvar from a config file was not read.
                      (!) Some others minors changes.

             v2.3  - [ 2007-10-29 ]

                      (+) Added 'erc_random_precache' cvar : Specify how many sounds per team you want to precache randomly among all sounds.
                          This means that x sounds will be choosen randomly among all sounds of each team so to be precache at each map. ( request by Arion )
                      (!) Debug mode is enabled by default now.
                      (-) Removed 3 keys languages. No more need.( ERS_LOG_TOTAL_SOUND_LOADED, ERS_LOG_DEBUG_T, ERS_LOG_DEBUG_CT )

             v2.2b - [ 2007-10-28 ]

                      (!) Removed a check. Since trim() is used :
                          Now no need to check space, new line, tabs, carriage returns, etc..

             v2.2a - [ 2007-10-28 ]

                      (!) Changed the method of checking empty file. Now it's more efficient.
                      (!) Added another check to ignore texts which are no comments.
                      (!) Fixed a typo ( key language ).

             v2.2  - [ 2007-10-27 ]

                      (+) Added a check to prevent to get a warning when a team has no sound.
                      (+) Added a check to prevent to not load empty file.
                      (+) Added support for coding-style '//' comments.
                      (!) No longer has a predefined max sounds limit. ( using dynamic array from amxx 1.8.0 )
                      (!) Minors optimizations.
                      (-) Removed useless code.

             v2.1a - [ 2007-07-13 ]

                      (!) Fixed a bug with ML system.
                      (!) Fixed a stupid glitch with formatex().

             v2.1  - [ 2007-07-06 ]

                      (!) Optimize a little.
                      (!) Rewritted loading_file() function.
                      (+) Added ML system & some texts.
                      (+) Added Color in text. ( !g = green ; !t = team color; !n = yellow (normal) )
                      (+) Added #_DEBUG.
                      (+) Added chat command : toggle on/off end round sounds.
                      (+) Added "ers_enabled" cvar : enable/disable plugin
                      (+) Added "ers_player_toggle" cvar : enable/disabled command chat for players
                      (+) Added ads message for chat command
                      (+) Added "erc_time_ads" cvar : control amount of times between 2 messages.

             v2.0b - [ 2007-07-04 ]

                      (!) No features added. Sma reorganized a little and more.

             v2.0a - [ 2007-06-26 ]

                      (!) Fixed. Bug under linux. Some blank lines weren't ignored. (thanks Deejay & NiLuje)

             v2.0  - [ 2007-06-26 ]

                      (!) Totaly rewritted
                      (+) Added support for mp3 files.
                      (+) Added support per file. No more to edit .sma file to add sounds.
                      (+) Added support per-map file.
                      (+) Added support per-map prefix file.

            -> Paintlancer :

             v1.0  :  [ 2004-10-14 ]
                      First release by Paintlancer.
                      Orignal thread : http://forums.alliedmods.net/showthread.php?t=6784

        Credits:
        - - - - - - -
            * PaintLancer : Original idea and plugin.
            * Avalanche   : Inspired color chat function from gungame plugin.
            * Arion       : Random precache idea.
            
            * Languages translation :
                - [fr] : Arkshine
                - [de] : Mordekay
                - [es] : Darkless
        

    - - - - - - - - - - - */

    #include <amxmodx>
    #include <amxmisc>


        new const
    // _________________________________________________

            PLUGIN [] = "Alternative End Round Sounds",
            VERSION[] = "2.3b",
            AUTHOR [] = "Arkshine";
    // _________________________________________________


    #if AMXX_VERSION_NUM < 180
        #define old_amxx
    #endif


    /* ========================= [ "START" AERA FOR CHANGES ] ========================= */


        #define _DEBUG                 // Active debug
        #define MAX_FILE_LENGTH  196   // Max length for files + path.

        #if defined old_amxx
            #define MAX_SOUNDS    25   // Max sounds per team
        #endif

        new const

            g_FileName[]    = "roundsound",     // Name of the main file if no files is found in 'g_FileFolder'.
            g_FileFolder[]  = "round_sound",    // Name of the directory in amxmodx/configs/ for per-map files.
            g_FilePrefix[]  = "ini",            // File extension used for the files.
            g_CmdChat[]     = "/roundsound";    // Chat command for player.


    /* ========================= [ "END" AERA FOR CHANGES ] ========================= */



    // - - - - - - - - - - - - - - - - - - - - - - -

    #define MAX_PLAYERS  32
    #define TASKID_ADS   1333
    #define SIZE_FILE    0
    #define NULL        -1

    new
        bool:g_pHeardSound[ MAX_PLAYERS + 1 ],

        #if !defined old_amxx
            Array:g_lstSoundCT,
            Array:g_lstSoundT,
        #endif

        p_enabled,
        p_player_toggle,
        p_time_ads,
        p_random_precache,

        g_sRp_value[12],
        g_msgSayText;


    enum _:e_Team
    {
        T = 0,
        CT,
    };

    new g_nSnd[ e_Team ];

    #if defined old_amxx
        new g_sTeam_sounds[ MAX_SOUNDS ][ e_Team ][ MAX_FILE_LENGTH ];
        #define charsmax(%1)  sizeof( %1 ) - 1
    #endif

    #define _is_wav(%1)  equali( %1[strlen( %1 ) - 4 ], ".wav" )

    // - - - - - - - - - - - - - - - - - - - - - - -


    public plugin_precache()
    {
        register_dictionary( "end_roundsound.txt" );
              
        if( ( p_random_precache = get_cvar_pointer( "erc_random_precache" ) ) )
            get_pcvar_string( p_random_precache, g_sRp_value, charsmax( g_sRp_value ) );

        if( !p_random_precache )
            return;
            
        #if !defined old_amxx
            g_lstSoundCT = ArrayCreate( MAX_FILE_LENGTH );
            g_lstSoundT  = ArrayCreate( MAX_FILE_LENGTH );
        #endif

        loading_file();
    }


    public plugin_init()
    {
        register_plugin( PLUGIN, VERSION, AUTHOR );
        register_cvar( "ers_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY );

        register_event( "SendAudio", "eT_win" , "a", "2&%!MRAD_terwin" );
        register_event( "SendAudio", "eCT_win", "a", "2&%!MRAD_ctwin"  );

        p_enabled         = register_cvar( "ers_enabled"        , "1"   );
        p_player_toggle   = register_cvar( "ers_player_toggle"  , "1"   );
        p_time_ads        = register_cvar( "erc_time_ads"       , "120" );

        if( !p_random_precache )
        {
            register_cvar( "erc_random_precache", g_sRp_value );
            server_cmd( "restart" );
        }

        register_clcmd( "say"       , "cmd_Say" );
        register_clcmd( "say_team"  , "cmd_Say" );

        g_msgSayText = get_user_msgid( "SayText" );
    }

 
    public client_authorized( id )
        g_pHeardSound[id] = true;


    public client_disconnected( id )
    {
        g_pHeardSound[id] = true;
        remove_task( id + TASKID_ADS );
    }


    public client_putinserver( id )
    {
        new Float:time = get_pcvar_float( p_time_ads );

        if( !time )
            return;

        remove_task( id + TASKID_ADS );
        set_task( time, "show_ads", id + TASKID_ADS, _, _, "b" );
    }


    public show_ads( taskid )
    {
        new id = taskid - TASKID_ADS;
        ShowPrint( id, "%L", id, "ERS_DISPLAY_ADS", g_CmdChat );
    }


    public cmd_Say( id )
    {
        if( !get_pcvar_num( p_enabled ) )
            return PLUGIN_CONTINUE;

        static sMsg[64];
        read_argv( 1, sMsg, charsmax( sMsg ) );

        if( equali( sMsg, g_CmdChat ) )
        {
            if( !get_pcvar_num( p_player_toggle ) )
            {
                ShowPrint( id, "%L", id, "ERS_CMD_DISABLED" );
                return PLUGIN_HANDLED;
            }

            g_pHeardSound[id] = g_pHeardSound[id] ? false : true;
            ShowPrint( id, "%L", id, g_pHeardSound[id] ? "ERS_SOUND_ENABLED" : "ERS_SOUND_DISABLED" );

            return PLUGIN_HANDLED;
        }

        return PLUGIN_CONTINUE;
    }


    public eT_win()
    {
        if( !g_nSnd[ e_Team:T ] )
            return;

        play_sound( e_Team:T );
    }


    public eCT_win()
    {
        if( !g_nSnd[ e_Team:CT ] )
            return;

        play_sound( e_Team:CT );
    }


    play_sound( iTeam )
    {
        static
    //  - - - - - - - - - - - - - - - -
            sCurSnd[ MAX_FILE_LENGTH ];
    //  - - - - - - - - - - - - - - - -

        new iRand;

        if( g_nSnd[ iTeam ] > 1 )
            iRand = random( g_nSnd[ iTeam ] );

        #if defined old_amxx
            copy( sCurSnd, MAX_FILE_LENGTH - 1, g_sTeam_sounds[ iRand ][ iTeam ] );
        #else
            ArrayGetString( iTeam == CT ? g_lstSoundCT : g_lstSoundT, iRand, sCurSnd, MAX_FILE_LENGTH - 1 );
        #endif

        _is_wav( sCurSnd ) ?

             format( sCurSnd, MAX_FILE_LENGTH - 1, "spk %s", sCurSnd[6] ) :
             format( sCurSnd, MAX_FILE_LENGTH - 1, "mp3 play %s", sCurSnd );

        if( get_pcvar_num( p_player_toggle ) )
        {
            static
        //  - - - - - - - - - - -
                iPlayers[32],
                iNum, pid;
        //  - - - - - - - - - - -

            get_players( iPlayers, iNum, "c" );

            for( new i; i < iNum; i++ )
            {
                pid = iPlayers[i];

                if( !g_pHeardSound[pid] || is_user_bot( pid ) )
                    continue;

                client_cmd( pid, "%s", sCurSnd );
            }
        }
        else
            client_cmd( 0, "%s", sCurSnd );
    }


    get_prefix( sMap[], iLen_map, sMapType[], iLen_type )
    {
        new
    //  - - - - - - - - -
            sRest[32];
    //  - - - - - - - - -

        get_mapname( sMap, iLen_map );
        strtok( sMap, sMapType, iLen_type, sRest, charsmax( sRest ), '_', 1 );
    }


    loading_file()
    {
        static
    //  - - - - - - - - - - - - - - - - -
            sPath[ MAX_FILE_LENGTH ],
    //      |
            sConfigsDir[64],
            sPrefix[6],
            sMap[32];
    //  - - - - - - - - - - - - - - - - -

        get_prefix( sMap, charsmax( sMap ), sPrefix, charsmax( sPrefix ) );
        get_configsdir( sConfigsDir, charsmax( sConfigsDir ) );


        new bool:bFound;

        for( new i = 1; i <= 3; i++ )
        {
            switch( i )
            {
                case 1 : formatex( sPath, charsmax( sPath ), "%s/%s/prefix-%s.%s", sConfigsDir, g_FileFolder, sPrefix, g_FilePrefix );
                case 2 : formatex( sPath, charsmax( sPath ), "%s/%s/%s.%s", sConfigsDir, g_FileFolder, sMap, g_FilePrefix );
                case 3 : formatex( sPath, charsmax( sPath ), "%s/%s.%s", sConfigsDir, g_FileName, g_FilePrefix );

                default : break;
            }

            if( !CheckFile( sPath ) )
                continue;

            bFound = true;
            break;
        }

        log_amx( "---" );

        bFound ?
            log_amx( "%L", LANG_SERVER, "ERS_LOG_LOADING", sPath ) :
            log_amx( "%L", LANG_SERVER, "ERS_LOG_NO_FILES_FOUND" );

        load_sound( sPath );
    }

    
    load_sound( const file[] )
    {
        new
    //  - - - - - - - - - - - - - - -
            sBuffer[256],
    //      |
            sLeft[ MAX_FILE_LENGTH ],
            sRight[4],
            sExt[6],
    //      |
            eTeam;
    //  - - - - - - - - - - - - - - -

        new fp = fopen( file, "rt" );

        while( !feof( fp ) )
        {
            fgets( fp, sBuffer, charsmax( sBuffer ) );

            trim( sBuffer );

            if( !sBuffer[0] || sBuffer[0] == ';' || ( sBuffer[0] == '/' && sBuffer[1] == '/' ) )
                continue;

            if( sBuffer[0] != '"' || strlen( sBuffer  ) < 11 )
                continue;

            parse( sBuffer, sLeft, charsmax( sLeft ), sRight, charsmax( sRight ) );
            formatex( sExt, charsmax( sExt ), sLeft[ strlen( sLeft ) - 4 ] );

            if( equali( sExt, ".mp3" ) == -1 || equali( sExt, ".wav" ) == -1 )
            {
                log_amx( "%L", LANG_SERVER, "ERS_LOG_UNKNOW_EXTENSION", sExt );
                continue;
            }

            if( !file_exists( sLeft ) )
            {
                log_amx( "%L", LANG_SERVER, "ERS_LOG_INEXISTENT_FILE", sLeft );
                continue;
            }

            eTeam = NULL;

            if( equali( sRight, "CT" ) )
                eTeam = CT;

            else if( equali( sRight, "T" ) )
                eTeam = T;

            if( eTeam == NULL )
            {
                log_amx( "%L", LANG_SERVER, "ERS_LOG_NO_TEAM_SOUND", sLeft );
                continue;
            }

            #if defined old_amxx
                copy( g_sTeam_sounds[ g_nSnd[ eTeam ] ][ eTeam ], MAX_FILE_LENGTH - 1, sLeft );
            #else
                ArrayPushString( eTeam == CT ? g_lstSoundCT : g_lstSoundT, sLeft );
            #endif

            ++g_nSnd[ eTeam ];
        }
        fclose( fp );

        if( g_nSnd[ e_Team:T ] > 1 || g_nSnd[ e_Team:CT ] > 1 )
        {
                new iMax_t, iMax_ct;
                GetPrecacheValue( iMax_t, iMax_ct );

                #if defined old_amxx
                    UpdateArray( iMax_t, e_Team:T );
                    UpdateArray( iMax_ct, e_Team:CT );
                #else
                    p_DeleteRandomItem( iMax_t , e_Team:T , g_lstSoundT  );
                    p_DeleteRandomItem( iMax_ct, e_Team:CT, g_lstSoundCT );
                #endif
        }

        log_amx( "---" );

        #if defined _DEBUG
            log_amx( "[ Loading %d CTs Sounds ]", g_nSnd[ e_team:CT ] );
        #endif
        #if defined old_amxx
            PrecacheSounds( e_Team:CT );
        #else
            PrecacheSounds_n( g_lstSoundCT );
        #endif

        #if defined _DEBUG
             log_amx( "[ Loading %d Ts Sounds ]", g_nSnd[ e_team:T ] );
        #endif
        #if defined old_amxx
            PrecacheSounds( e_Team:T );
        #else
            PrecacheSounds_n( g_lstSoundT );
        #endif
    }


    GetPrecacheValue( &iMax_t, &iMax_ct )
    {
        trim( g_sRp_value );
        new pos = contain( g_sRp_value, "-" );

        if( pos > 0 )
        {
            iMax_ct = str_to_num( g_sRp_value[ pos + 1 ] )
            g_sRp_value[ pos ] = '^0';
            iMax_t = str_to_num( g_sRp_value );
        }
        else
        {
            iMax_t  = str_to_num( g_sRp_value );
            iMax_ct = iMax_t;
        }
    }

    
    stock UpdateArray( iMax, iTeam )
    {
        new const iCnt_sound = g_nSnd[ iTeam ];
            
        if( !iMax || iMax == iCnt_sound )
            return;

        if( iMax >= iCnt_sound )
            iMax = iCnt_sound - 1;

        new sTmp_sounds[ MAX_SOUNDS ][  ][  ],
            iLast_number[ MAX_SOUNDS ];

        new i, iRand;
        for( i = 0; i < iCnt_sound; i++ )
        {
            copy( sTmp_sounds[i][ iTeam ], MAX_FILE_LENGTH - 1, g_sTeam_sounds[i][ iTeam ] );
            g_sTeam_sounds[i][ iTeam ][0] = '^0';
        }

        arrayset( iLast_number, 0, charsmax( iLast_number ) );

        i = 0;
        while( i != iMax )
        {
            check:
            iRand = random( iCnt_sound );

            if( iLast_number[ iRand ] )
                goto check;

            copy( g_sTeam_sounds[i][ iTeam ], MAX_FILE_LENGTH - 1, sTmp_sounds[ iRand ][ iTeam ] );
            ++i;
                
            iLast_number[ iRand ] = 1;
        }

        g_nSnd[ iTeam ] = iMax;
    }
    

    stock p_DeleteRandomItem( iMax, iTeam, Array:sSound_a )
    {
        new const iCnt_sound = g_nSnd[ iTeam ];
            
        if( !iMax || iMax == iCnt_sound )
            return;

        if( iMax >= iCnt_sound )
            iMax = iCnt_sound - 1;

        DeleteRandomItem( iCnt_sound - iMax, sSound_a );
        g_nSnd[ iTeam ] = iMax;
    }


    stock DeleteRandomItem( iRandom_n, Array:sSound_a )
        {
            new i;

            while( i++ != iRandom_n )
                ArrayDeleteItem( sSound_a, random( ArraySize( sSound_a ) ) );
        }

        
    stock PrecacheSounds( iTeam )
    {
        for( new i; i < g_nSnd[ iTeam ]; i++ )
        {
            PrecacheFile( g_sTeam_sounds[i][ iTeam ] );

            #if defined _DEBUG
                log_amx( "   - %s", g_sTeam_sounds[i][ iTeam ] );
            #endif
        }

        log_amx( "---" );
    }


    stock PrecacheSounds_n( Array:sSound_a )
    {
        static
    //  - - - - - - - - - - - - - - - - - - -
            sFile[ MAX_FILE_LENGTH ],
            iFileLen = charsmax( sFile );
    //  - - - - - - - - - - - - - - - - - - -

        for( new i; i < ArraySize( sSound_a ); i++ )
        {
            ArrayGetString( sSound_a, i, sFile, iFileLen );
            PrecacheFile( sFile );

            #if defined _DEBUG
                log_amx( "   - %s", sFile );
            #endif
        }

         log_amx( "---" );
    }


    PrecacheFile( const sound[] )
    {
        _is_wav( sound ) ?

            precache_sound( sound[6] ) :
            precache_generic( sound );
    }


    ShowPrint( id, const sMsg[], { Float, Sql, Result, _ }:... )
    {
        static
    //  - - - - - - - - -
            newMsg[191],
            message[191],
    //      |
            tNewMsg;
    //  - - - - - - - - -

        tNewMsg = charsmax( newMsg );
        vformat( newMsg, tNewMsg, sMsg, 3 );

        replace_all( newMsg, tNewMsg, "!t", "^3" );
        replace_all( newMsg, tNewMsg, "!g", "^4" );
        replace_all( newMsg, tNewMsg, "!n", "^1" );

        formatex( message, charsmax( message ), "^4[ERS]^1 %s", newMsg );

        emessage_begin( MSG_ONE, g_msgSayText, _, id );
        ewrite_byte( id );
        ewrite_string( message );
        emessage_end();
    }
    
    
    bool:CheckFile( const file[] )
    {
        new
    //  - - - - - - - - - - - - - - - - -
            sBuffer[256],
            fp = fopen( file, "rt" );
    //  - - - - - - - - - - - - - - - - -

        if( !fp )
            return false;

        while( !feof( fp ) )
        {
            fgets( fp, sBuffer, charsmax( sBuffer ) );

            trim( sBuffer );

            if( !sBuffer[0] || sBuffer[0] == ';' || ( sBuffer[0] == '/' && sBuffer[1] == '/' ) || sBuffer[0] != '"' )
                continue;

            if( ( contain( sBuffer, ".mp3^"" ) != -1 || contain( sBuffer, ".wav^"" ) != -1 ) && ( contain( sBuffer, "^"T^"" ) != -1 || contain( sBuffer, "^"CT^"" ) != -1 ) )
                return true;
        }
        fclose( fp );

        return false;
    }
