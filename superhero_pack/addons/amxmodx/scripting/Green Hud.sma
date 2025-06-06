/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <amxmodx>
#include <amxmisc>
#include <superheromod>

#define PLUGIN "New Plug-In"
#define VERSION "1.0"
#define AUTHOR "author"

new gPlayerLevel[SH_MAXSLOTS+1]


public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	new message[64], temp[64]
new heroIndex, MaxBinds, count, playerLevel, playerpowercount
new menuid, mkeys

count = 0
playerLevel = gPlayerLevel[id]

if ( playerLevel < gNumLevels ) {
formatex(message, charsmax(message), "LVL:%d/%d XP%d/%d)", playerLevel, gNumLevels, gPlayerXP[id], gXPLevel[playerLevel+1])
}
else {
formatex(message, charsmax(message), "LVL:%d/%d XP%d/%d)", playerLevel, gNumLevels, gPlayerXP[id])
}

//Resets All Bind assignments
MaxBinds = min(get_pcvar_num(sh_maxbinds), SH_MAXBINDPOWERS)
for ( new x = 1; x <= MaxBinds; x++ ) {
gPlayerBinds[id][x] = -1
}

playerpowercount = getPowerCount(id)

for ( new x = 1; x <= gNumLevels && x <= playerpowercount; x++ ) {
heroIndex = gPlayerPowers[id][x]
if ( -1 < heroIndex < gSuperHeroCount ) {
// 2 types of heroes - auto heroes and bound heroes...
// Bound Heroes require special work...
if ( gSuperHeros[heroIndex][requiresKeys] ) {
count++
if (count <= 3) {
if ( message[0] != '^4') add(message, charsmax(message), " ")
formatex(temp, charsmax(temp), "%d=%s", count, gSuperHeros[heroIndex])
add(message, charsmax(message), temp)
}
// Make sure this players keys are bound correctly
if ( count <= get_pcvar_num(sh_maxbinds) && count <= SH_MAXBINDPOWERS ) {
gPlayerBinds[id][count] = heroIndex
gPlayerBinds[id][0] = count
}
else {
clearPower(id, x)
}
}
}
}

if ( is_user_alive(id) ) {
writeStatusMessage(id, message)
if ( setThePowers ) set_task(0.6, "setPowers", id)
}

// Update menu incase already in menu and levels changed
// or user is no longer in menu
get_user_menu(id, menuid, mkeys)
if ( menuid != gMenuID ) {
gInMenu[id] = false
}
else {
menuSuperPowers(id, gPlayerMenuOffset[id])
}
}
