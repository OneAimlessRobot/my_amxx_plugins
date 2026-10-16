/*
*
*	Prop Manager by RedSMURF
*
*
*	Description:
*
*	Cvars:
*		None
*
*	Commands:
*       say /pm                         "Opens the Prop Manager menu."
*       say_team /pm                    "Opens the Prop Manager menu."
*       say /prop                       "Opens the Prop Manager menu."
*       say_team /prop                  "Opens the Prop Manager menu."
*       pm_reload                       "Reloads the configuration file."
*       prop_reload                     "Reloads the configuration file."
*
*	Changelog:
*       v1.0: Initial release.
*
*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <xs>

#if !defined MAX_PLAYERS
    #define MAX_PLAYERS 32
#endif

#if !defined MAX_VALUE_LENGTH
    #define MAX_VALUE_LENGTH 64
#endif

#if !defined MAX_RESOURCE_PATH_LENGTH
    #define MAX_RESOURCE_PATH_LENGTH 128
#endif

#if !defined MAX_FILE_CELL_SIZE
    #define MAX_FILE_CELL_SIZE 192
#endif

#if !defined MAX_PLATFORM_PATH_LENGTH
    #define MAX_PLATFORM_PATH_LENGTH 256
#endif

#define MAX_ENT             32
#define PROP_KEY            667788
#define PROP_ARRAY_ITEM     pev_iuser1

new const PLUGIN_VERSION[]          = "1.0"
new const Float:DELAY_ON_CONNECT    = 1.0
new const ERROR_FILE[]              = "PropManager_ERRORS.log"

enum
{
    SECTION_NONE,
    SECTION_MAIN_SETTINGS,
    SECTION_PROP
}

enum
{
    DTYPE_FLOAT,
    DTYPE_FLOAT_RANGE,
    DTYPE_INT,
    DTYPE_INT_RANGE,
    DTYPE_BOOL,
    DTYPE_FLAGS,
    DTYPE_VECTOR,
    DTYPE_VECTOR_FLOAT,
    DTYPE_ARRAY,
    DTYPE_ARRAY_SOUND,
    DTYPE_STRING_MODEL,
    DTYPE_STRING_SOUND,
    DTYPE_STRING_SPRITE
}

enum
{
    FLAG_SOLID              = (1 << 0),
    FLAG_ANIM               = (1 << 1),

    FLAG_SHOW               = (1 << 2),
    FLAG_GHOST              = (1 << 3),
    FLAG_GROUND             = (1 << 4),
    FLAG_SELECT             = (1 << 5)
}

enum
{
    SHOW_DEFAULT,
    SHOW_FORCE_SHOW,
    SHOW_FORCE_HIDE
}

enum _:MAIN_SETTINGS
{
    SETTING_DEFAULT_MODEL[MAX_RESOURCE_PATH_LENGTH],
    SETTING_DEFAULT_FLAGS,
    SETTING_DEFAULT_SEQUENCE,
    Float:SETTING_DEFAULT_FRAMERATE,
    Float:SETTING_DEFAULT_SPAWN_CHANCE,

    bool:SETTING_PROP_LOAD,
    Float:SETTING_PROP_RANGE,
    Float:SETTING_PROP_CHECK,
    Float:SETTING_OFFSET_BASE,
    Float:SETTING_OFFSET[2],
    Float:SETTING_OFFSET_STEP,
    SETTING_GHOST_ALPHA,

    SETTING_SOUND_MENU_NAV[MAX_RESOURCE_PATH_LENGTH],
    SETTING_SOUND_MENU_REMOVE[MAX_RESOURCE_PATH_LENGTH],
    SETTING_SOUND_MENU_ALERT[MAX_RESOURCE_PATH_LENGTH],

    SETTING_COLOR_SELECT[3]
}

enum _:PROP
{
    PROP_ID,
    PROP_ITEM,
    PROP_SHOW,
    PROP_FLAGS,
    PROP_NAME[MAX_VALUE_LENGTH],
    PROP_MODEL[MAX_RESOURCE_PATH_LENGTH],

    Float:PROP_ORIGIN[3],
    Float:PROP_ANGLES[3],
    Float:PROP_MINS[3],
    Float:PROP_MAXS[3],

    PROP_SEQUENCE,
    Float:PROP_FRAMERATE,
    Float:PROP_SPAWN_CHANCE,
}

enum _:PLAYER_DATA
{
    PDATA_PROP_GHOST,
    PDATA_PROP_MENU,
    bool:PDATA_PROP_ACTION,
    Float:PDATA_OFFSET,
    Float:PDATA_NEXT_OFFSET
}

enum
{
    SOUND_MENU_NAV,
    SOUND_MENU_REMOVE,
    SOUND_MENU_ALERT
}

enum
{
    MENU_ROOT,
    MENU_CREATE,
    MENU_SHOW,
    MENU_REMOVE,
    MENU_ROTATE
}

enum
{
    ROOT_CREATE,
    ROOT_SHOW,
    ROOT_REMOVE,
    ROOT_SAVE,

    ROOT_NOCLIP = 5,
    ROOT_GODMODE
}

enum
{
    SHOW_NEXT,
    SHOW_BACK,

    SHOW_CURRENT = 3,
    SHOW_ALL_SHOW,
    SHOW_ALL_HIDE,
    SHOW_ALL_DEFAULT
}

enum
{
    REMOVE_NEXT,
    REMOVE_BACK,

    REMOVE_CURRENT = 3,
    REMOVE_ALL
}

enum
{
    ROTATE_RIGHT,
    ROTATE_LEFT,
    ROTATE_UP,
    ROTATE_DOWN,

    ROTATE_GROUND = 5,
    ROTATE_PLACE
}

new Float:g_fDirections[][] =
{
    {-1.0, 0.0, 0.0},
    {1.0, 0.0, 0.0},
    {0.0, -1.0, 0.0},
    {0.0, 1.0, 0.0},
    {0.0, 0.0, -1.0},
    {0.0, 0.0, 1.0}
}

new g_szMenuHandler[][MAX_VALUE_LENGTH] =
{
    "menuHandlerRoot",
    "menuHandlerCreate",
    "menuHandlerShow",
    "menuHandlerRemove",
    "menuHandlerRotate"
}

new g_szCN[] = "propmanager"

new Array:g_aProp,
    Array:g_aPropConfig,
    g_eSettings[MAIN_SETTINGS],
    g_ePlayerData[MAX_PLAYERS + 1][PLAYER_DATA],
    bool:g_bFileWasRead = false,
    g_iProp, g_iPropConfig,
    g_iMaxPlayers

new g_szShow[][] = {"PROP_DEFAULT", "PROP_SHOWN", "PROP_HIDDEN"}
new g_szShowChat[][] = {"PROP_CHAT_DEFAULT", "PROP_CHAT_SHOWN", "PROP_CHAT_HIDDEN"}
new g_szShowColor[][] = {"\d", "\y", "\r"}

public plugin_init()
{
    register_plugin("Prop Manager", PLUGIN_VERSION, "RedSMURF")

    register_clcmd("say /pm",           "cmdMenu", ADMIN_RCON)
    register_clcmd("say_team /pm",      "cmdMenu", ADMIN_RCON)
    register_clcmd("say /prop",         "cmdMenu", ADMIN_RCON)
    register_clcmd("say_team /prop",    "cmdMenu", ADMIN_RCON)
    register_concmd("pm_reload",        "cmdReload", ADMIN_RCON, "-- Reloads the configuration file")
    register_concmd("prop_reload",      "cmdReload", ADMIN_RCON, "-- Reloads the configuration file")

    register_dictionary("PropManager.txt")

    register_forward(FM_UpdateClientData, "fwdUpdateClientData", 1)
    register_forward(FM_AddToFullPack, "fwdAddToFullPack", 1)
    RegisterHam(Ham_Spawn, "info_target", "fwdSpawn", 1)
    RegisterHam(Ham_Player_PreThink, "player", "fwdPreThink")
    RegisterHam(Ham_Killed, "player", "fwdKilled", 1)

    register_logevent("eventRoundStart", 2, "1=Round_Start")
    set_task(0.1, "propTask", .flags = "b")

    propInit()
    g_iMaxPlayers = get_maxplayers()
}

public plugin_precache()
{
    g_aProp = ArrayCreate(PROP)
    g_aPropConfig = ArrayCreate(PROP)

    ReadFile()
}

public plugin_end()
{
    ArrayDestroy(g_aProp)
    ArrayDestroy(g_aPropConfig)
}

public cmdMenu(id, iLevel, iCmd)
{
    if ( !cmd_access(id, iLevel, iCmd, 1) )
        return PLUGIN_HANDLED

    propSound(id, SOUND_MENU_NAV)
    propMenu(id, MENU_ROOT)

    return PLUGIN_HANDLED
}

public cmdReload(id, iLevel, iCmd)
{
    if ( !cmd_access(id, iLevel, iCmd, 1) )
        return PLUGIN_HANDLED

    ReadFile()
    console_print(id, "The configuration file has been reloaded successfully !")

    return PLUGIN_HANDLED
}

public client_command(id)
{
    if ( !g_ePlayerData[id][PDATA_PROP_GHOST] )
        return PLUGIN_CONTINUE

    new szCmd[16]
    read_argv(0, szCmd, charsmax(szCmd))

    if ( contain(szCmd, "weapon_") != -1
    || equal(szCmd, "invnext")
    || equal(szCmd, "invprev")
    || equal(szCmd, "lastinv") )
        return PLUGIN_HANDLED

    return PLUGIN_CONTINUE
}

public eventRoundStart()
{
    if ( !g_iProp )
        return PLUGIN_HANDLED

    new eProp[PROP]

    for ( new i = 0; i < g_iProp; i ++ )
    {
        ArrayGetArray(g_aProp, i, eProp)

        if ( eProp[PROP_SHOW] != SHOW_DEFAULT )
            continue

        if ( eProp[PROP_SPAWN_CHANCE] >= random_float(0.0, 1.0) )
        {
            eProp[PROP_FLAGS] |= FLAG_SHOW
            if ( eProp[PROP_FLAGS] & FLAG_SOLID )
                set_pev(eProp[PROP_ID], pev_solid, SOLID_BBOX)
        }
        else
        {
            eProp[PROP_FLAGS] &= ~FLAG_SHOW
            if ( eProp[PROP_FLAGS] & FLAG_SOLID )
                set_pev(eProp[PROP_ID], pev_solid, SOLID_NOT)
        }

        ArraySetArray(g_aProp, i, eProp)
    }

    return PLUGIN_HANDLED
}

ReadFile()
{
    if ( g_bFileWasRead )
    {
        for ( new id = 1; id <= g_iMaxPlayers; id ++ )
            if ( is_user_connected(id))
                UpdateData(id)
        ArrayClear(g_aPropConfig)
        g_iPropConfig = 0
    }

    new g_szFileName[MAX_RESOURCE_PATH_LENGTH]
    get_configsdir(g_szFileName, charsmax(g_szFileName))
    add(g_szFileName, charsmax(g_szFileName), "/PropManager.ini")

    new iFile
    iFile = fopen(g_szFileName, "rt")

    if ( !iFile )
    {
        set_fail_state("An error occured during the opening of the configuration file !")
    }

    new szData[MAX_RESOURCE_PATH_LENGTH], szKey[MAX_VALUE_LENGTH], szValue[MAX_VALUE_LENGTH],
        eProp[PROP], iSection = SECTION_NONE, iLine, iPos

    while( !feof(iFile) )
    {
        iLine ++
        fgets(iFile, szData, charsmax(szData))
        trim(szData)

        switch( szData[0] )
        {
            case EOS, ';', '#':
            {
                continue
            }
            case '[':
            {
                if ( szData[strlen(szData) - 1] == ']' )
                {
                    replace(szData, charsmax(szData), "[", "")
                    replace(szData, charsmax(szData), "]", "")
                    trim(szData)

                    if ( equali(szData, "Main Settings") )
                    {
                        iSection = SECTION_MAIN_SETTINGS
                    }
                    else
                    {
                        if ( g_iPropConfig )
                            ArrayPushArray(g_aPropConfig, eProp)

                        copy(eProp[PROP_NAME], charsmax(eProp[PROP_NAME]), szData)
                        copy(eProp[PROP_MODEL], charsmax(eProp[PROP_MODEL]), g_eSettings[SETTING_DEFAULT_MODEL])
                        xs_vec_copy(Float:{0.0, 0.0, 0.0}, eProp[PROP_MINS])
                        xs_vec_copy(Float:{0.0, 0.0, 0.0}, eProp[PROP_MAXS])
                        eProp[PROP_FLAGS]               = g_eSettings[SETTING_DEFAULT_FLAGS]
                        eProp[PROP_SEQUENCE]            = g_eSettings[SETTING_DEFAULT_SEQUENCE]
                        eProp[PROP_FRAMERATE]           = g_eSettings[SETTING_DEFAULT_FRAMERATE]
                        eProp[PROP_SPAWN_CHANCE]        = g_eSettings[SETTING_DEFAULT_SPAWN_CHANCE]

                        iSection = SECTION_PROP
                        g_iPropConfig ++
                    }
                }
                else
                {
                    LogConfigError(iLine, "Unclosed section name: %s", szData)
                    iSection = SECTION_NONE
                }
            }
            default:
            {
                strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
                iPos = contain(szValue, "#")
                if ( iPos != -1 )
                    szValue[iPos] = EOS

                trim(szKey)
                trim(szValue)

                switch( iSection )
                {
                    case SECTION_NONE:
                    {
                        LogConfigError(iLine, "Data is not in any defined section: %s", szData)
                    }
                    case SECTION_MAIN_SETTINGS:
                    {
                        if ( equali(szKey, "SETTING_DEFAULT_MODEL") )
                            parseSetting(DTYPE_STRING_MODEL, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_MODEL], charsmax(g_eSettings[SETTING_DEFAULT_MODEL]))
                        else if ( equali(szKey, "SETTING_DEFAULT_FLAGS") )
                            parseSetting(DTYPE_FLAGS, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_FLAGS], charsmax(g_eSettings[SETTING_DEFAULT_FLAGS]))
                        else if ( equali(szKey, "SETTING_DEFAULT_FRAMERATE") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_FRAMERATE], charsmax(g_eSettings[SETTING_DEFAULT_FRAMERATE]))
                        else if ( equali(szKey, "SETTING_DEFAULT_SEQUENCE") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_SEQUENCE], charsmax(g_eSettings[SETTING_DEFAULT_SEQUENCE]))
                        else if ( equali(szKey, "SETTING_DEFAULT_SPAWN_CHANCE") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_SPAWN_CHANCE], charsmax(g_eSettings[SETTING_DEFAULT_SPAWN_CHANCE]))
                        else if ( equali(szKey, "SETTING_PROP_LOAD") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_PROP_LOAD], charsmax(g_eSettings[SETTING_PROP_LOAD]))
                        else if ( equali(szKey, "SETTING_PROP_CHECK") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_PROP_CHECK], charsmax(g_eSettings[SETTING_PROP_CHECK]))
                        else if ( equali(szKey, "SETTING_OFFSET_BASE") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_OFFSET_BASE], charsmax(g_eSettings[SETTING_OFFSET_BASE]))
                        else if ( equali(szKey, "SETTING_OFFSET") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_OFFSET], charsmax(g_eSettings[SETTING_OFFSET]))
                        else if ( equali(szKey, "SETTING_OFFSET_STEP") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_OFFSET_STEP], charsmax(g_eSettings[SETTING_OFFSET_STEP]))
                        else if ( equali(szKey, "SETTING_GHOST_ALPHA") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_GHOST_ALPHA], charsmax(g_eSettings[SETTING_GHOST_ALPHA]))
                        else if ( equali(szKey, "SETTING_SOUND_MENU_NAV") )
                            parseSetting(DTYPE_STRING_SOUND, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_SOUND_MENU_NAV], charsmax(g_eSettings[SETTING_SOUND_MENU_NAV]))
                        else if ( equali(szKey, "SETTING_SOUND_MENU_REMOVE") )
                            parseSetting(DTYPE_STRING_SOUND, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_SOUND_MENU_REMOVE], charsmax(g_eSettings[SETTING_SOUND_MENU_REMOVE]))
                        else if ( equali(szKey, "SETTING_SOUND_MENU_ALERT") )
                            parseSetting(DTYPE_STRING_SOUND, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_SOUND_MENU_ALERT], charsmax(g_eSettings[SETTING_SOUND_MENU_ALERT]))
                        else if ( equali(szKey, "SETTING_COLOR_SELECT") )
                            parseSetting(DTYPE_VECTOR, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_COLOR_SELECT], charsmax(g_eSettings[SETTING_COLOR_SELECT]))
                    }
                    case SECTION_PROP:
                    {
                        if ( equali(szKey, "PROP_MODEL") )
                            parseSetting(DTYPE_STRING_MODEL, szKey, charsmax(szKey), szValue, charsmax(szValue), eProp[PROP_MODEL], charsmax(eProp[PROP_MODEL]), g_eSettings[SETTING_DEFAULT_MODEL])
                        else if ( equali(szKey, "PROP_FLAGS") )
                            parseSetting(DTYPE_FLAGS, szKey, charsmax(szKey), szValue, charsmax(szValue), eProp[PROP_FLAGS], charsmax(eProp[PROP_FLAGS]), g_eSettings[SETTING_DEFAULT_FLAGS])
                        else if ( equali(szKey, "PROP_SEQUENCE") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), eProp[PROP_SEQUENCE], charsmax(eProp[PROP_SEQUENCE]), g_eSettings[SETTING_DEFAULT_SEQUENCE])
                        else if ( equali(szKey, "PROP_FRAMERATE") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), eProp[PROP_FRAMERATE], charsmax(eProp[PROP_FRAMERATE]), g_eSettings[SETTING_DEFAULT_FRAMERATE])
                        else if ( equali(szKey, "PROP_SPAWN_CHANCE") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), eProp[PROP_SPAWN_CHANCE], charsmax(eProp[PROP_SPAWN_CHANCE]), g_eSettings[SETTING_DEFAULT_SPAWN_CHANCE])
                        else if ( equali(szKey, "PROP_MINS") )
                            parseSetting(DTYPE_VECTOR_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), eProp[PROP_MINS], charsmax(eProp[PROP_MINS]))
                        else if ( equali(szKey, "PROP_MAXS") )
                            parseSetting(DTYPE_VECTOR_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), eProp[PROP_MAXS], charsmax(eProp[PROP_MAXS]))
                    }
                }
            }
        }
    }

    if ( g_iPropConfig )
        ArrayPushArray(g_aPropConfig, eProp)
    else
        set_fail_state("No Props were found in the configuration file.")

    g_bFileWasRead = true
    fclose(iFile)
}

public client_authorized(id)
{
    set_task(DELAY_ON_CONNECT, "UpdateData", id)
}

public client_disconnected(id)
{
    new iItem
    if ( g_ePlayerData[id][PDATA_PROP_GHOST]
    && (iItem = pev(g_ePlayerData[id][PDATA_PROP_GHOST], PROP_ARRAY_ITEM)) != -1 )
    {
        propKill(g_ePlayerData[id][PDATA_PROP_GHOST])
        propRemove(iItem)
    }

    g_ePlayerData[id][PDATA_PROP_GHOST]  = 0
    g_ePlayerData[id][PDATA_PROP_ACTION] = false
    g_ePlayerData[id][PDATA_PROP_MENU]   = 0
}

public UpdateData(id)
{
    g_ePlayerData[id][PDATA_OFFSET] = g_eSettings[SETTING_OFFSET_BASE]
}

public propInit()
{
    if ( g_eSettings[SETTING_PROP_LOAD] )
        loadData()
}

public propMenu(id, iType)
{
    new szData[64], iMenu
    formatex(szData, charsmax(szData), "%L", id, "PROP_MENU_TITLE", PLUGIN_VERSION)
    iMenu = menu_create(szData, g_szMenuHandler[iType])

    switch( iType )
    {
        case MENU_ROOT:   { menuRoot(id, iMenu); }
        case MENU_CREATE: { menuCreate(iMenu);      format(szData, charsmax(szData), "%s^n%L", szData, id, "PROP_ROOT_CREATE"); }
        case MENU_SHOW:   { menuShow(id, iMenu);    format(szData, charsmax(szData), "%s^n%L", szData, id, "PROP_ROOT_SHOW"); }
        case MENU_REMOVE: { menuRemove(id, iMenu);  format(szData, charsmax(szData), "%s^n%L", szData, id, "PROP_ROOT_REMOVE"); }
        case MENU_ROTATE: { menuRotate(id, iMenu);  format(szData, charsmax(szData), "%s^n%L", szData, id, "PROP_ROOT_ROTATE"); }
    }

    if ( menu_pages(iMenu) > 1 )
        format(szData, charsmax(szData), "%s^n%L", szData, id, "PROP_MENU_TITLE_PAGE")

    menu_setprop(iMenu, MPROP_TITLE, szData)
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)
    menu_setprop(iMenu, MPROP_NUMBER_COLOR, "\r")

    menu_display(id, iMenu)
    return PLUGIN_HANDLED
}

stock menuNav(id, iMenu)
{
    new szItem[64]

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_NAV_NEXT")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_NAV_BACK")
    menu_additem(iMenu, szItem)

    menu_addblank2(iMenu)
}

public menuRoot(id, iMenu)
{
    new szItem[64]

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_ROOT_CREATE")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_ROOT_SHOW")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_ROOT_REMOVE")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_ROOT_SAVE")
    menu_additem(iMenu, szItem)

    menu_addblank2(iMenu)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_ROOT_NOCLIP", id, get_user_noclip(id) ? "PROP_ON" : "PROP_OFF")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_ROOT_GODMODE", id, get_user_godmode(id) ? "PROP_ON" : "PROP_OFF")
    menu_additem(iMenu, szItem)
}

public menuHandlerRoot(id, menu, item)
{
    if ( item == MENU_EXIT )
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    switch( item )
    {
        case ROOT_CREATE:
        {
            if ( g_iProp >= MAX_ENT )
            {
                client_print_color(id, id, "%L %L", id, "PROP_CHAT_TAG", id, "PROP_CHAT_LIMIT", MAX_ENT)
                propSound(id, SOUND_MENU_REMOVE)
            }
            else
            {
                propSound(id, SOUND_MENU_NAV)
                propMenu(id, MENU_CREATE)
            }
        }
        case ROOT_SHOW:
        {
            if ( !g_iProp )
            {
                client_print_color(id, id, "%L %L", id, "PROP_CHAT_TAG", id, "PROP_CHAT_NO_PROP")
                propSound(id, SOUND_MENU_REMOVE)
            }
            else
            {
                propSound(id, SOUND_MENU_NAV)
                propMenu(id, MENU_SHOW)
            }
        }
        case ROOT_REMOVE:
        {
            if ( !g_iProp )
            {
                client_print_color(id, id, "%L %L", id, "PROP_CHAT_TAG", id, "PROP_CHAT_NO_PROP")
                propSound(id, SOUND_MENU_REMOVE)
            }
            else
            {
                propSound(id, SOUND_MENU_REMOVE)
                propMenu(id, MENU_REMOVE)
            }
        }
        case ROOT_SAVE:
        {
            saveData(id)
        }
        case ROOT_NOCLIP:
        {
            propNoClip(id)
        }
        case ROOT_GODMODE:
        {
            propGodMode(id)
        }
    }

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public menuCreate(iMenu)
{
    new eProp[PROP], szItem[64]

    for ( new i = 0; i < g_iPropConfig; i ++ )
    {
        ArrayGetArray(g_aPropConfig, i, eProp)

        copy(szItem, charsmax(szItem), eProp[PROP_NAME])
        menu_additem(iMenu, szItem)
    }
}

public menuHandlerCreate(id, menu, item)
{
    if ( item == MENU_EXIT
    || !is_user_alive(id) )
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    propCreate(id, item)
    propSound(id, SOUND_MENU_NAV)
    propMenu(id, MENU_ROTATE)

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public menuShow(id, iMenu)
{
    new szItem[64], eProp[PROP]

    menuNav(id, iMenu)
    ArrayGetArray(g_aProp, g_ePlayerData[id][PDATA_PROP_MENU], eProp)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_SHOW_CURRENT",
    g_szShowColor[eProp[PROP_SHOW]], eProp[PROP_NAME], id, g_szShow[eProp[PROP_SHOW]])
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_SHOW_ALL_SHOW")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_SHOW_ALL_HIDE")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_SHOW_ALL_DEFAULT")
    menu_additem(iMenu, szItem)

    g_ePlayerData[id][PDATA_PROP_ACTION] = true
    eProp[PROP_FLAGS] |= FLAG_SELECT
    ArraySetArray(g_aProp, g_ePlayerData[id][PDATA_PROP_MENU], eProp)
}

public menuHandlerShow(id, menu, item)
{
    new eProp[PROP]
    ArrayGetArray(g_aProp, g_ePlayerData[id][PDATA_PROP_MENU], eProp)
    eProp[PROP_FLAGS] &= ~FLAG_SELECT
    ArraySetArray(g_aProp, g_ePlayerData[id][PDATA_PROP_MENU], eProp)

    switch( item )
    {
        case SHOW_NEXT:
        {
            if ( g_ePlayerData[id][PDATA_PROP_MENU] >= g_iProp - 1 )
                g_ePlayerData[id][PDATA_PROP_MENU] = 0
            else
                g_ePlayerData[id][PDATA_PROP_MENU] ++

            propSound(id, SOUND_MENU_NAV)
            propMenu(id, MENU_SHOW)
        }
        case SHOW_BACK:
        {
            if ( g_ePlayerData[id][PDATA_PROP_MENU] <= 0 )
                g_ePlayerData[id][PDATA_PROP_MENU] = g_iProp - 1
            else
                g_ePlayerData[id][PDATA_PROP_MENU] --

            propSound(id, SOUND_MENU_NAV)
            propMenu(id, MENU_SHOW)
        }
        case SHOW_CURRENT:
        {
            if ( ++ eProp[PROP_SHOW] > SHOW_FORCE_HIDE )
                eProp[PROP_SHOW] = SHOW_DEFAULT

            if ( eProp[PROP_SHOW] == SHOW_FORCE_SHOW
            || eProp[PROP_SHOW] == SHOW_DEFAULT )
            {
                set_pev(eProp[PROP_ID], pev_solid, SOLID_BBOX)
                eProp[PROP_FLAGS] |= FLAG_SHOW
            }
            else if ( eProp[PROP_SHOW] == SHOW_FORCE_HIDE )
            {
                set_pev(eProp[PROP_ID], pev_solid, SOLID_NOT)
                eProp[PROP_FLAGS] &= ~FLAG_SHOW
            }

            client_print_color(id, id, "%L %L", id, "PROP_CHAT_TAG", id, "PROP_CHAT_SHOW_CURRENT",
            eProp[PROP_NAME], id, g_szShowChat[eProp[PROP_SHOW]])
            ArraySetArray(g_aProp, g_ePlayerData[id][PDATA_PROP_MENU], eProp)

            propSound(id, SOUND_MENU_NAV)
            propMenu(id, MENU_SHOW)
        }
        case SHOW_ALL_SHOW:
        {
            for ( new i = 0; i < g_iProp; i ++ )
            {
                ArrayGetArray(g_aProp, i, eProp)
                eProp[PROP_FLAGS] |= FLAG_SHOW
                eProp[PROP_SHOW] = SHOW_FORCE_SHOW
                set_pev(eProp[PROP_ID], pev_solid, SOLID_BBOX)

                ArraySetArray(g_aProp, i, eProp)
            }

            client_print_color(id, id, "%L %L", id, "PROP_CHAT_TAG", id, "PROP_CHAT_SHOW_ALL_SHOWN")
            propSound(id, SOUND_MENU_ALERT)
            propMenu(id, MENU_SHOW)
        }
        case SHOW_ALL_HIDE:
        {
            for ( new i = 0; i < g_iProp; i ++ )
            {
                ArrayGetArray(g_aProp, i, eProp)
                eProp[PROP_FLAGS] &= ~FLAG_SHOW
                eProp[PROP_SHOW] = SHOW_FORCE_HIDE
                set_pev(eProp[PROP_ID], pev_solid, SOLID_NOT)

                ArraySetArray(g_aProp, i, eProp)
            }

            client_print_color(id, id, "%L %L", id, "PROP_CHAT_TAG", id, "PROP_CHAT_SHOW_ALL_HIDDEN")
            propSound(id, SOUND_MENU_ALERT)
            propMenu(id, MENU_SHOW)
        }
        case SHOW_ALL_DEFAULT:
        {
            for ( new i = 0; i < g_iProp; i ++ )
            {
                ArrayGetArray(g_aProp, i, eProp)
                eProp[PROP_FLAGS] |= FLAG_SHOW
                eProp[PROP_SHOW] = SHOW_DEFAULT
                set_pev(eProp[PROP_ID], pev_solid, SOLID_BBOX)
                ArraySetArray(g_aProp, i, eProp)
            }

            client_print_color(id, id, "%L %L", id, "PROP_CHAT_TAG", id, "PROP_CHAT_SHOW_ALL_DEFAULT")
            propSound(id, SOUND_MENU_ALERT)
            propMenu(id, MENU_SHOW)
        }
        default:
        {
            g_ePlayerData[id][PDATA_PROP_ACTION] = false
            g_ePlayerData[id][PDATA_PROP_MENU] = 0
        }
    }

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public menuRemove(id, iMenu)
{
    new szItem[64], eProp[PROP]

    menuNav(id, iMenu)
    ArrayGetArray(g_aProp, g_ePlayerData[id][PDATA_PROP_MENU], eProp)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_REMOVE_CURRENT", eProp[PROP_NAME])
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_REMOVE_ALL")
    menu_additem(iMenu, szItem)

    g_ePlayerData[id][PDATA_PROP_ACTION] = true
    eProp[PROP_FLAGS] |= FLAG_SELECT
    ArraySetArray(g_aProp, g_ePlayerData[id][PDATA_PROP_MENU], eProp)
}

public menuHandlerRemove(id, menu, item)
{
    new eProp[PROP]

    ArrayGetArray(g_aProp, g_ePlayerData[id][PDATA_PROP_MENU], eProp)
    eProp[PROP_FLAGS] &= ~FLAG_SELECT
    ArraySetArray(g_aProp, g_ePlayerData[id][PDATA_PROP_MENU], eProp)

    switch( item )
    {
        case REMOVE_NEXT:
        {
            if ( g_ePlayerData[id][PDATA_PROP_MENU] >= g_iProp - 1 )
                g_ePlayerData[id][PDATA_PROP_MENU] = 0
            else
                g_ePlayerData[id][PDATA_PROP_MENU] ++

            propSound(id, SOUND_MENU_NAV)
            propMenu(id, MENU_REMOVE)
        }
        case REMOVE_BACK:
        {
            if ( g_ePlayerData[id][PDATA_PROP_MENU] <= 0 )
                g_ePlayerData[id][PDATA_PROP_MENU] = g_iProp - 1
            else
                g_ePlayerData[id][PDATA_PROP_MENU] --

            propSound(id, SOUND_MENU_NAV)
            propMenu(id, MENU_REMOVE)
        }
        case REMOVE_CURRENT:
        {
            propKill(eProp[PROP_ID])
            propRemove(g_ePlayerData[id][PDATA_PROP_MENU])

            client_print_color(id, id, "%L %L", id, "PROP_CHAT_TAG", id, "PROP_CHAT_REMOVE_CURRENT", eProp[PROP_NAME])
            g_ePlayerData[id][PDATA_PROP_MENU] = 0

            propSound(id, g_iProp > 0 ? SOUND_MENU_REMOVE : SOUND_MENU_NAV)
            propMenu(id, g_iProp > 0 ? MENU_REMOVE : MENU_ROOT)
        }
        case REMOVE_ALL:
        {
            while( g_iProp )
            {
                ArrayGetArray(g_aProp, 0, eProp)

                propKill(eProp[PROP_ID])
                propRemove(0)
            }

            client_print_color(id, id, "%L %L", id, "PROP_CHAT_TAG", id, "PROP_CHAT_REMOVE_ALL")
            g_ePlayerData[id][PDATA_PROP_MENU] = 0

            propSound(id, SOUND_MENU_ALERT)
            propMenu(id, MENU_ROOT)
        }
        default:
        {
            g_ePlayerData[id][PDATA_PROP_MENU] = 0
            g_ePlayerData[id][PDATA_PROP_ACTION] = false
        }
    }

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public menuRotate(id, iMenu)
{
    new szItem[64], eProp[PROP]
    if ( propGet(eProp, g_ePlayerData[id][PDATA_PROP_GHOST]) == -1 )
    {
        menu_destroy(iMenu)
        return
    }

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_ROTATE_RIGHT")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_ROTATE_LEFT")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_ROTATE_UP")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_ROTATE_DOWN")
    menu_additem(iMenu, szItem)

    menu_addblank2(iMenu)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_ROTATE_GROUND",
    id, eProp[PROP_FLAGS] & FLAG_GROUND ? "PROP_ON" : "PROP_OFF")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "PROP_ROTATE_PLACE")
    menu_additem(iMenu, szItem)
}

public menuHandlerRotate(id, menu, item)
{
    new eProp[PROP], iItem
    if ( (iItem = propGet(eProp, g_ePlayerData[id][PDATA_PROP_GHOST])) == -1 )
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    switch( item )
    {
        case ROTATE_RIGHT:
        {
            pev(eProp[PROP_ID], pev_angles, eProp[PROP_ANGLES])
            eProp[PROP_ANGLES][1] -= 22.5
            if ( eProp[PROP_ANGLES][1] < -180.0 ) eProp[PROP_ANGLES][1] += 360.0

            set_pev(eProp[PROP_ID], pev_angles, eProp[PROP_ANGLES])
            ArraySetArray(g_aProp, iItem, eProp)

            propSound(id, SOUND_MENU_NAV)
            propMenu(id, MENU_ROTATE)
        }
        case ROTATE_LEFT:
        {
            pev(eProp[PROP_ID], pev_angles, eProp[PROP_ANGLES])
            eProp[PROP_ANGLES][1] += 22.5
            if ( eProp[PROP_ANGLES][1] > 180.0 ) eProp[PROP_ANGLES][1] -= 360.0

            set_pev(eProp[PROP_ID], pev_angles, eProp[PROP_ANGLES])
            ArraySetArray(g_aProp, iItem, eProp)

            propSound(id, SOUND_MENU_NAV)
            propMenu(id, MENU_ROTATE)
        }
        case ROTATE_UP:
        {
            pev(eProp[PROP_ID], pev_angles, eProp[PROP_ANGLES])
            eProp[PROP_ANGLES][0] -= 22.5
            if ( eProp[PROP_ANGLES][0] < -180.0 ) eProp[PROP_ANGLES][0] += 360.0

            set_pev(eProp[PROP_ID], pev_angles, eProp[PROP_ANGLES])
            ArraySetArray(g_aProp, iItem, eProp)

            propSound(id, SOUND_MENU_NAV)
            propMenu(id, MENU_ROTATE)
        }
        case ROTATE_DOWN:
        {
            pev(eProp[PROP_ID], pev_angles, eProp[PROP_ANGLES])
            eProp[PROP_ANGLES][0] += 22.5
            if ( eProp[PROP_ANGLES][0] > 180.0 ) eProp[PROP_ANGLES][0] -= 360.0

            set_pev(eProp[PROP_ID], pev_angles, eProp[PROP_ANGLES])
            ArraySetArray(g_aProp, iItem, eProp)

            propSound(id, SOUND_MENU_NAV)
            propMenu(id, MENU_ROTATE)
        }
        case ROTATE_GROUND:
        {
            eProp[PROP_FLAGS] ^= FLAG_GROUND
            ArraySetArray(g_aProp, iItem, eProp)

            propSound(id, SOUND_MENU_NAV)
            propMenu(id, MENU_ROTATE)
        }
        case ROTATE_PLACE:
        {
            propTrace(eProp, id)
            g_ePlayerData[id][PDATA_PROP_GHOST] = 0
            g_ePlayerData[id][PDATA_PROP_ACTION] = false

            eProp[PROP_FLAGS] |= FLAG_SHOW
            eProp[PROP_FLAGS] &= ~FLAG_GHOST

            if ( eProp[PROP_FLAGS] & FLAG_ANIM )
                propSetAnim(eProp)
            if ( eProp[PROP_FLAGS] & FLAG_SOLID )
                propSetSolid(eProp)
            ArraySetArray(g_aProp, iItem, eProp)

            client_print_color(id, id, "%L %L", id, "PROP_CHAT_TAG", id, "PROP_CHAT_CREATE_NEW", eProp[PROP_NAME])
            propSound(id, SOUND_MENU_NAV)
            propMenu(id, MENU_ROOT)
        }
        default:
        {
            propKill(eProp[PROP_ID])
            propRemove(iItem)
            g_ePlayerData[id][PDATA_PROP_GHOST] = 0
            g_ePlayerData[id][PDATA_PROP_ACTION] = false
        }
    }

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public propTask()
{
    new eProp[PROP]
    for ( new id = 1; id <= g_iMaxPlayers; id ++ )
    {
        if ( !is_user_alive(id) )
            continue

        if ( !g_ePlayerData[id][PDATA_PROP_GHOST] )
        {
            if ( g_ePlayerData[id][PDATA_PROP_ACTION] )
                propCheck(id)
        }
        else if ( propGet(eProp, g_ePlayerData[id][PDATA_PROP_GHOST]) != -1 )
        {
            propTrace(eProp, id)
        }
    }
}

stock propCreate(id, iItem)
{
    new iEnt
    iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))

    if ( !pev_valid(iEnt) )
        return

    new eProp[PROP]
    ArrayGetArray(g_aPropConfig, iItem, eProp)
    eProp[PROP_ID] = iEnt
    eProp[PROP_ITEM] = iItem
    if ( id )
    {
        g_ePlayerData[id][PDATA_PROP_GHOST] = eProp[PROP_ID]
        g_ePlayerData[id][PDATA_PROP_ACTION] = true
        g_ePlayerData[id][PDATA_OFFSET] = g_eSettings[SETTING_OFFSET_BASE]

        eProp[PROP_FLAGS] |= FLAG_GHOST
    }

    set_pev(iEnt, PROP_ARRAY_ITEM, g_iProp)
    set_pev(iEnt, pev_impulse, PROP_KEY)
    set_pev(iEnt, pev_classname, g_szCN)
    set_pev(iEnt, pev_sequence, eProp[PROP_SEQUENCE])
    engfunc(EngFunc_SetModel, iEnt, eProp[PROP_MODEL])

    ArrayPushArray(g_aProp, eProp)
    g_iProp ++

    dllfunc(DLLFunc_Spawn, iEnt)
}

public propRemove(iItem)
{
    new eProp[PROP]
    ArrayDeleteItem(g_aProp, iItem)
    g_iProp --

    for ( new i = iItem; i < g_iProp; i ++ )
    {
        ArrayGetArray(g_aProp, i, eProp)
        set_pev(eProp[PROP_ID], PROP_ARRAY_ITEM, i)
    }
}

public saveData(id)
{
    new eProp[PROP],
        szFile[128], iFile,
        szData[64]

    get_mapname(szFile, charsmax(szFile))
    format(szFile, charsmax(szFile), "maps/%s_PropManager.ini", szFile)

    iFile = fopen(szFile, "wt")
    if ( !iFile )
        return PLUGIN_HANDLED

    for ( new i = 0; i < g_iProp; i ++ )
    {
        ArrayGetArray(g_aProp, i, eProp)

        formatex(szData, charsmax(szData), "[%d]^n", i)
        fputs(iFile, szData)

        formatex(szData, charsmax(szData), "item = %d^n", eProp[PROP_ITEM])
        fputs(iFile, szData)

        formatex(szData, charsmax(szData), "origin = %.2f %.2f %.2f^n",
        eProp[PROP_ORIGIN][0], eProp[PROP_ORIGIN][1], eProp[PROP_ORIGIN][2])
        fputs(iFile, szData)

        formatex(szData, charsmax(szData), "angles = %.2f %.2f %.2f^n",
        eProp[PROP_ANGLES][0], eProp[PROP_ANGLES][1], eProp[PROP_ANGLES][2])
        fputs(iFile, szData)

        formatex(szData, charsmax(szData), "mins = %.2f %.2f %.2f^n",
        eProp[PROP_MINS][0], eProp[PROP_MINS][1], eProp[PROP_MINS][2])
        fputs(iFile, szData)

        formatex(szData, charsmax(szData), "maxs = %.2f %.2f %.2f^n",
        eProp[PROP_MAXS][0], eProp[PROP_MAXS][1], eProp[PROP_MAXS][2])
        fputs(iFile, szData)

        formatex(szData, charsmax(szData), "angles = %.2f %.2f %.2f^n",
        eProp[PROP_ANGLES][0], eProp[PROP_ANGLES][1], eProp[PROP_ANGLES][2])
        fputs(iFile, szData)

        formatex(szData, charsmax(szData), "show = %d^n", eProp[PROP_SHOW])
        fputs(iFile, szData)

        eProp[PROP_FLAGS] &= ~(FLAG_GHOST | FLAG_SELECT)
        formatex(szData, charsmax(szData), "flags = %d^n", eProp[PROP_FLAGS])
        fputs(iFile, szData)
    }

    client_print_color(id, id, "%L %L", id, "PROP_CHAT_TAG", id, "PROP_CHAT_SAVE", szFile)
    fclose(iFile)

    propSound(id, SOUND_MENU_NAV)
    propMenu(id, MENU_ROOT)
    return PLUGIN_HANDLED
}

public loadData()
{
    new szFile[128], iFile,
        szData[64], szKey[32], szValue[32],
        Float:fOrigin[3], Float:fAngles[3], Float:fMins[3], Float:fMaxs[3], iItem,
        iShow, iFlags, iCount = -1

    get_mapname(szFile, charsmax(szFile))
    format(szFile, charsmax(szFile), "maps/%s_PropManager.ini", szFile)

    iFile = fopen(szFile, "rt")
    if ( !iFile )
    {
        console_print(0, "%L %L", 0, "PROP_CHAT_TAG", 0, "PROP_CHAT_NO_DATA")
        return PLUGIN_HANDLED
    }

    while( !feof(iFile) )
    {
        fgets(iFile, szData, charsmax(szData))

        if ( szData[0] == '[' )
        {
            if ( iCount != -1 )
                loadDataProp(fOrigin, fAngles, fMins, fMaxs, iShow, iFlags, iItem, iCount)

            iCount ++
        }
        else
        {
            strtok(szData, szKey, charsmax( szKey ), szValue, charsmax( szValue ), '=')
            trim(szKey)
            trim(szValue)

            if ( equal(szKey, "item") )
            {
                iItem = str_to_num(szValue)
            }
            else if ( equal(szKey, "origin") )
            {
                strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ' ')
                fOrigin[0] = str_to_float(szKey)

                strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ' ')
                fOrigin[1] = str_to_float(szKey)
                fOrigin[2] = str_to_float(szValue)
            }
            else if ( equal(szKey, "angles") )
            {
                strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ' ')
                fAngles[0] = str_to_float(szKey)

                strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ' ')
                fAngles[1] = str_to_float(szKey)
                fAngles[2] = str_to_float(szValue)
            }
            else if ( equal(szKey, "mins") )
            {
                strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ' ')
                fMins[0] = str_to_float(szKey)

                strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ' ')
                fMins[1] = str_to_float(szKey)
                fMins[2] = str_to_float(szValue)
            }
            else if ( equal(szKey, "maxs") )
            {
                strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ' ')
                fMaxs[0] = str_to_float(szKey)

                strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ' ')
                fMaxs[1] = str_to_float(szKey)
                fMaxs[2] = str_to_float(szValue)
            }
            else if ( equal(szKey, "angles") )
            {
                strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ' ')
                fAngles[0] = str_to_float(szKey)

                strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ' ')
                fAngles[1] = str_to_float(szKey)
                fAngles[2] = str_to_float(szValue)
            }
            else if ( equal(szKey, "show") )
            {
                iShow = str_to_num(szValue)
            }
            else if ( equal(szKey, "flags") )
            {
                iFlags = str_to_num(szValue)
            }
        }
    }

    if ( iCount != -1 )
        loadDataProp(fOrigin, fAngles, fMins, fMaxs, iShow, iFlags, iItem, iCount)

    fclose(iFile)
    return PLUGIN_HANDLED
}

stock loadDataProp(Float:fOrigin[3], Float:fAngles[3], Float:fMins[3], Float:fMaxs[3], iShow, iFlags, iItem, iCount)
{
    new eProp[PROP]
    propCreate(0, iItem)
    ArrayGetArray(g_aProp, iCount, eProp)

    xs_vec_copy(fOrigin, eProp[PROP_ORIGIN])
    xs_vec_copy(fAngles, eProp[PROP_ANGLES])
    set_pev(eProp[PROP_ID], pev_origin, fOrigin)
    set_pev(eProp[PROP_ID], pev_angles, fAngles)
    xs_vec_copy(fMins, eProp[PROP_MINS])
    xs_vec_copy(fMaxs, eProp[PROP_MAXS])

    eProp[PROP_SHOW] = iShow
    eProp[PROP_FLAGS] = iFlags

    if ( eProp[PROP_FLAGS] & FLAG_ANIM )
        propSetAnim(eProp)
    if ( eProp[PROP_FLAGS] & (FLAG_SHOW | FLAG_SOLID) )
        propSetSolid(eProp)

    ArraySetArray(g_aProp, iCount, eProp)
}

public propNoClip(id)
{
    set_user_noclip(id, !get_user_noclip(id))

    propSound(id, SOUND_MENU_NAV)
    propMenu(id, MENU_ROOT)
}

public propGodMode(id)
{
    set_user_godmode(id, !get_user_godmode(id))

    propSound(id, SOUND_MENU_NAV)
    propMenu(id, MENU_ROOT)
}

public fwdUpdateClientData(id, iSendWeapons, iHandle)
{
    if ( g_ePlayerData[id][PDATA_PROP_GHOST] )
    {
        set_cd(iHandle, CD_WeaponAnim, 0)
        set_cd(iHandle, CD_flNextAttack, get_gametime() + 0.1)
    }

    return FMRES_IGNORED
}

public fwdAddToFullPack(es, e, iEnt, iHost, iHostFlags, iPlayer, pSet)
{
    if ( !pev_valid(iEnt)
    || !isProp(iEnt)
    || !get_orig_retval() )
        return FMRES_IGNORED

    new eProp[PROP]
    if ( propGet(eProp, iEnt) == -1 )
        return FMRES_IGNORED

    new bool:bHidden
    bHidden = !(eProp[PROP_FLAGS] & FLAG_SHOW)

    if ( !g_ePlayerData[iHost][PDATA_PROP_ACTION] )
    {
        if ( bHidden )
            set_es(es, ES_Effects, EF_NODRAW)
    }
    else if ( eProp[PROP_FLAGS] & FLAG_SELECT )
    {
        set_es(es, ES_RenderColor, g_eSettings[SETTING_COLOR_SELECT])
        set_es(es, ES_RenderAmt, 32)
        set_es(es, ES_RenderFx, kRenderFxGlowShell)

        if ( bHidden )
            set_es(es, ES_RenderMode, kRenderTransAlpha)
    }
    else if ( eProp[PROP_FLAGS] & FLAG_GHOST )
    {
        set_es(es, ES_RenderMode, kRenderTransAlpha)
        set_es(es, ES_RenderAmt, g_eSettings[SETTING_GHOST_ALPHA])
    }

    return FMRES_IGNORED
}

public fwdSpawn(iEnt)
{
    if ( !isProp(iEnt) )
        return HAM_IGNORED

    set_pev(iEnt, pev_solid, SOLID_NOT)
    set_pev(iEnt, pev_movetype, MOVETYPE_FLY)

    return HAM_IGNORED
}

public fwdPreThink(id)
{
    if ( !is_user_alive(id) )
        return HAM_IGNORED

    static iButton, Float:fCurrentTime
    iButton = pev(id, pev_button)
    fCurrentTime = get_gametime()

    if ( g_ePlayerData[id][PDATA_PROP_GHOST] )
    {
        if ( fCurrentTime > g_ePlayerData[id][PDATA_NEXT_OFFSET] )
        {
            if ( iButton & IN_ATTACK )
            {
                g_ePlayerData[id][PDATA_OFFSET]      += g_eSettings[SETTING_OFFSET_STEP]
                g_ePlayerData[id][PDATA_OFFSET]      = floatclamp(g_ePlayerData[id][PDATA_OFFSET], g_eSettings[SETTING_OFFSET][0], g_eSettings[SETTING_OFFSET][1])
                g_ePlayerData[id][PDATA_NEXT_OFFSET] = fCurrentTime + 0.1
            }
            else if ( iButton & IN_ATTACK2 )
            {
                g_ePlayerData[id][PDATA_OFFSET]      -= g_eSettings[SETTING_OFFSET_STEP]
                g_ePlayerData[id][PDATA_OFFSET]      = floatclamp(g_ePlayerData[id][PDATA_OFFSET], g_eSettings[SETTING_OFFSET][0], g_eSettings[SETTING_OFFSET][1])
                g_ePlayerData[id][PDATA_NEXT_OFFSET] = fCurrentTime + 0.1
            }
        }

        iButton &= ~(IN_ATTACK | IN_ATTACK2)
        set_pev(id, pev_button, iButton)
    }

    return HAM_IGNORED
}

public fwdKilled(id, iAttacker, bGib)
{
    g_ePlayerData[id][PDATA_PROP_ACTION] = false
    g_ePlayerData[id][PDATA_PROP_MENU]   = 0

    if ( g_ePlayerData[id][PDATA_PROP_GHOST] )
    {
        new eProp[PROP], iItem

        if ( (iItem = propGet(eProp, g_ePlayerData[id][PDATA_PROP_GHOST])) != -1 )
        {
            propKill(g_ePlayerData[id][PDATA_PROP_GHOST])
            propRemove(iItem)
        }

        g_ePlayerData[id][PDATA_PROP_GHOST] = 0
    }
}

stock propTrace(eProp[PROP], id)
{
    new Float:fVec1[3]
    pev(id, pev_origin, eProp[PROP_ORIGIN])
    pev(id, pev_v_angle, fVec1)
    engfunc(EngFunc_MakeVectors, fVec1)
    global_get(glb_v_forward, fVec1)

    xs_vec_mul_scalar(fVec1, g_ePlayerData[id][PDATA_OFFSET], fVec1)
    xs_vec_add(fVec1, eProp[PROP_ORIGIN], fVec1)

    engfunc(EngFunc_TraceLine, eProp[PROP_ORIGIN], fVec1, DONT_IGNORE_MONSTERS, id, 0)
    get_tr2(0, TR_vecEndPos, eProp[PROP_ORIGIN])

    propSetBox(eProp)
    propSetOffset(eProp)
    set_pev(eProp[PROP_ID], pev_origin, eProp[PROP_ORIGIN])
}

stock propCheck(id)
{
    new eProp[PROP], Float:fVec1[3], Float:fVec2[3], Float:fVec3[3], Float:fMins[3], Float:fMaxs[3], Float:fNearest[3]
    new iBest, Float:fBestDist, Float:fDot, Float:fDist

    pev(id, pev_origin, fVec1)
    pev(id, pev_view_ofs, fVec2)
    xs_vec_add(fVec1, fVec2, fVec1)

    pev(id, pev_v_angle, fVec2)
    engfunc(EngFunc_MakeVectors, fVec2)
    global_get(glb_v_forward, fVec2)

    iBest = -1
    fBestDist = g_eSettings[SETTING_PROP_CHECK]
    for ( new i = 0; i < g_iProp; i ++ )
    {
        ArrayGetArray(g_aProp, i, eProp)
        xs_vec_sub(eProp[PROP_ORIGIN], fVec1, fVec3)
        fDot = xs_vec_dot(fVec2, fVec3)

        if ( fDot < 0.0 )
            continue

        pev(eProp[PROP_ID], pev_absmin, fMins)
        pev(eProp[PROP_ID], pev_absmax, fMaxs)
        xs_vec_mul_scalar(fVec2, fDot, fVec3)
        xs_vec_add(fVec3, fVec1, fVec3)

        fNearest[0] = floatclamp(fVec3[0], fMins[0], fMaxs[0])
        fNearest[1] = floatclamp(fVec3[1], fMins[1], fMaxs[1])
        fNearest[2] = floatclamp(fVec3[2], fMins[2], fMaxs[2])
        fDist = get_distance_f(fVec3, fNearest)
        if ( fDist < fBestDist )
        {
            fBestDist = fDist
            iBest = i
        }
    }

    if ( iBest != -1
    && g_ePlayerData[id][PDATA_PROP_MENU] != iBest )
    {
        ArrayGetArray(g_aProp, g_ePlayerData[id][PDATA_PROP_MENU], eProp)
        eProp[PROP_FLAGS] &= ~FLAG_SELECT
        ArraySetArray(g_aProp, g_ePlayerData[id][PDATA_PROP_MENU], eProp)

        ArrayGetArray(g_aProp, iBest, eProp)
        eProp[PROP_FLAGS] |= FLAG_SELECT
        ArraySetArray(g_aProp, iBest, eProp)
        g_ePlayerData[id][PDATA_PROP_MENU] = iBest
    }
}

stock propSetBox(eProp[PROP])
{
    new Float:fMins[3], Float:fMaxs[3],
        Float:fForward[3], Float:fRight[3], Float:fUp[3],
        Float:fCorners[8][3]

    engfunc(EngFunc_AngleVectors, eProp[PROP_ANGLES], fForward, fRight, fUp)
    xs_vec_copy(eProp[PROP_MINS], fMins)
    xs_vec_copy(eProp[PROP_MAXS], fMaxs)

    for ( new i = 0; i < 8; i ++ )
    {
        fCorners[i][0] = (i & 1) ? fMaxs[0] : fMins[0]
        fCorners[i][1] = (i & 2) ? fMaxs[1] : fMins[1]
        fCorners[i][2] = (i & 4) ? fMaxs[2] : fMins[2]

        boxRotate(fCorners[i], fForward, fRight, fUp)
    }

    xs_vec_copy(fCorners[0], fMins)
    xs_vec_copy(fCorners[0], fMaxs)
    for ( new i = 1; i < 8; i ++ )
    {
        fMins[0] = floatmin(fMins[0], fCorners[i][0])
        fMins[1] = floatmin(fMins[1], fCorners[i][1])
        fMins[2] = floatmin(fMins[2], fCorners[i][2])

        fMaxs[0] = floatmax(fMaxs[0], fCorners[i][0])
        fMaxs[1] = floatmax(fMaxs[1], fCorners[i][1])
        fMaxs[2] = floatmax(fMaxs[2], fCorners[i][2])
    }

    xs_vec_copy(fMins, eProp[PROP_MINS])
    xs_vec_copy(fMaxs, eProp[PROP_MAXS])
}

stock boxRotate(Float:fLocal[3], Float:fForward[3], Float:fRight[3], Float:fUp[3])
{
    new Float:fOut[3]
    fOut[0] = fLocal[0] * fForward[0] + fLocal[1] * fRight[0] + fLocal[2] * fUp[0]
    fOut[1] = fLocal[0] * fForward[1] + fLocal[1] * fRight[1] + fLocal[2] * fUp[1]
    fOut[2] = fLocal[0] * fForward[2] + fLocal[1] * fRight[2] + fLocal[2] * fUp[2]

    xs_vec_copy(fOut, fLocal)
}

stock propSetOffset(eProp[PROP])
{
    new Float:fGaps[6], Float:fVec1[3],
        Float:fCurrentGap

    fGaps[0] = -eProp[PROP_MINS][0]
    fGaps[1] = eProp[PROP_MAXS][0]
    fGaps[2] = -eProp[PROP_MINS][1]
    fGaps[3] = eProp[PROP_MAXS][1]
    fGaps[4] = -eProp[PROP_MINS][2]
    fGaps[5] = eProp[PROP_MAXS][2]

    if ( eProp[PROP_FLAGS] & FLAG_GROUND )
    {
        xs_vec_sub(eProp[PROP_ORIGIN], Float:{0.0, 0.0, 9999.9}, fVec1)
        engfunc(EngFunc_TraceLine, eProp[PROP_ORIGIN], fVec1, DONT_IGNORE_MONSTERS, eProp[PROP_ID], 0)
        get_tr2(0, TR_vecEndPos, eProp[PROP_ORIGIN])
    }

    for ( new i = 0; i < 6; i ++ )
    {
        xs_vec_mul_scalar(g_fDirections[i], 9999.9, fVec1)
        xs_vec_add(fVec1, eProp[PROP_ORIGIN], fVec1)
        engfunc(EngFunc_TraceLine, eProp[PROP_ORIGIN], fVec1, DONT_IGNORE_MONSTERS, eProp[PROP_ID], 0)
        get_tr2(0, TR_vecEndPos, fVec1)
        fCurrentGap = xs_vec_distance(eProp[PROP_ORIGIN], fVec1)

        if ( fCurrentGap < fGaps[i] )
        {
            get_tr2(0, TR_vecPlaneNormal, fVec1)
            xs_vec_mul_scalar(fVec1, fGaps[i] - fCurrentGap, fVec1)
            xs_vec_add(eProp[PROP_ORIGIN], fVec1, eProp[PROP_ORIGIN])
        }
    }
}

stock propSetSolid(eProp[PROP])
{
    new Float:fMins[3], Float:fMaxs[3]
    set_pev(eProp[PROP_ID], pev_solid, SOLID_BBOX)
    set_pev(eProp[PROP_ID], pev_movetype, MOVETYPE_NONE)

    xs_vec_copy(eProp[PROP_MINS], fMins)
    xs_vec_copy(eProp[PROP_MAXS], fMaxs)
    engfunc(EngFunc_SetSize, eProp[PROP_ID], fMins, fMaxs)
    set_rendering(eProp[PROP_ID], kRenderFxNone, 255, 255, 255, kRenderNormal, 255)
}

stock propSetAnim(eProp[PROP])
{
    set_pev(eProp[PROP_ID], pev_frame, 0)
    set_pev(eProp[PROP_ID], pev_framerate, eProp[PROP_FRAMERATE])
    set_pev(eProp[PROP_ID], pev_animtime, get_gametime())
}

stock propSound(iEnt, iSound, bool:bPlayer = true)
{
    new szSample[64]

    switch( iSound )
    {
        case SOUND_MENU_NAV:    copy(szSample, charsmax(szSample), g_eSettings[SETTING_SOUND_MENU_NAV])
        case SOUND_MENU_REMOVE: copy(szSample, charsmax(szSample), g_eSettings[SETTING_SOUND_MENU_REMOVE])
        case SOUND_MENU_ALERT:  copy(szSample, charsmax(szSample), g_eSettings[SETTING_SOUND_MENU_ALERT])
    }

    if ( bPlayer )
        client_cmd(iEnt, "spk %s", szSample)
    else
        engfunc(EngFunc_EmitSound, iEnt, CHAN_ITEM, szSample, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

stock propGet(eProp[PROP], iEnt)
{
    new iItem
    iItem = pev(iEnt, PROP_ARRAY_ITEM)
    if ( iItem < 0 || iItem >= g_iProp )
        return -1

    ArrayGetArray(g_aProp, iItem, eProp)
    return iItem
}

stock bool:isProp(iEnt)
{
    return pev(iEnt, pev_impulse) == PROP_KEY
}

stock propKill(iEnt)
{
    if (pev_valid(iEnt))
        set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_KILLME)
}

stock parseSetting(iType, szKey[], iKeyLen, szValue[], iValueLen, any:output[], iOutputLen, const any:fallback[] = {0.0, 0.0})
{
    switch ( iType )
    {
        case DTYPE_FLOAT_RANGE:
        {
            strtok(szValue, szKey, iKeyLen, szValue, iValueLen, ' ')
            output[0] = str_to_float(szKey)
            output[1] = str_to_float(szValue)

            if ( output[0] < 0.0 ) output[0] = fallback[0]
            if ( output[1] < 0.0 ) output[1] = fallback[1]
        }
        case DTYPE_FLOAT:
        {
            output[0] = str_to_float(szValue)
            if ( output[0] < 0.0 ) output[0] = fallback[0]
        }
        case DTYPE_INT_RANGE:
        {
            strtok(szValue, szKey, iKeyLen, szValue, iValueLen, ' ')
            output[0] = str_to_num(szKey)
            output[1] = str_to_num(szValue)

            if ( output[0] < 0 ) output[0] = fallback[0]
            if ( output[1] < 0 ) output[1] = fallback[1]
        }
        case DTYPE_INT:
        {
            output[0] = str_to_num(szValue)
            if ( output[0] < 0 ) output[0] = fallback[0]
        }
        case DTYPE_BOOL:
        {
            output[0] = bool:str_to_num(szValue)
        }
        case DTYPE_FLAGS:
        {
            output[0] = read_flags(szValue)
        }
        case DTYPE_VECTOR:
        {
            strtok(szValue, szKey, iKeyLen, szValue, iValueLen, ' ')
            output[0] = str_to_num(szKey)

            strtok(szValue, szKey, iKeyLen, szValue, iValueLen, ' ')
            output[1] = str_to_num(szKey)
            output[2] = str_to_num(szValue)
        }
        case DTYPE_VECTOR_FLOAT:
        {
            strtok(szValue, szKey, iKeyLen, szValue, iValueLen, ' ')
            output[0] = str_to_float(szKey)

            strtok(szValue, szKey, iKeyLen, szValue, iValueLen, ' ')
            output[1] = str_to_float(szKey)
            output[2] = str_to_float(szValue)
        }
        case DTYPE_ARRAY:
        {
            replace_all(szValue, iValueLen, "^"", " ")
            replace_all(szValue, iValueLen, "^^n", "^n")
            ArrayPushString(output[0], szValue)
        }
        case DTYPE_ARRAY_SOUND:
        {
            ArrayPushString(output[0], szValue)
            if ( !g_bFileWasRead ) precache_sound(szValue)
        }
        case DTYPE_STRING_MODEL:
        {
            copy(output, iOutputLen, szValue)
            if ( !g_bFileWasRead ) precache_model(szValue)
        }
        case DTYPE_STRING_SOUND:
        {
            copy(output, iOutputLen, szValue)
            if ( !g_bFileWasRead ) precache_sound(szValue)
        }
        case DTYPE_STRING_SPRITE:
        {
            if ( !g_bFileWasRead )
                output[0] = precache_model(szValue)
        }
    }
}

stock LogConfigError(const iLine, const szText[], any:...)
{
    new szError[MAX_PLATFORM_PATH_LENGTH]
    vformat(szError, charsmax(szError), szText, 3)

    log_to_file(ERROR_FILE, "^nLine %d: %s", iLine, szError)
}


