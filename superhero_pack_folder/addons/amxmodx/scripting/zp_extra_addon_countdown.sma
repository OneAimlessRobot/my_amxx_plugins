/*================================================================================
           -----------------------------------
           -*- [ZP] Extra Addon: Countdown -*-
           -----------------------------------

           ~~~~~~~~~~~~~~~
           - Description -
           ~~~~~~~~~~~~~~~

           This will countdown until someone will turn into zombie. 

           ~~~~~~~~~~~~~~~
           - To do list! -
           ~~~~~~~~~~~~~~~

           Go to zombieplague.cfg and find zp_delay 10 change to zp_delay 15.
           ( cstrike / addons / amxmodx / configs / zombieplague.cfg )

           ~~~~~~~~~~~~~~~
           -  Changelog  -
           ~~~~~~~~~~~~~~~

           - Version: 1.0 (April 1 2012)
           * Public release.

================================================================================*/           
           
#include <amxmodx>
#include <amxmisc>

/*================================================================================
 [Defines]
=================================================================================*/

#define PLUGIN "[ZP] Extra Addon: Countdown"
#define VERSION "1.0"
#define AUTHOR "MercedeS"

/*================================================================================
 [Plugin init]
=================================================================================*/

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0") 
}

/*================================================================================
 [Precaches]
=================================================================================*/

public plugin_precache()
{
	precache_sound("zombie_plague/10.wav")
	precache_sound("zombie_plague/9.wav")
	precache_sound("zombie_plague/8.wav")
	precache_sound("zombie_plague/7.wav")
	precache_sound("zombie_plague/6.wav")
	precache_sound("zombie_plague/5.wav")
	precache_sound("zombie_plague/4.wav")
	precache_sound("zombie_plague/3.wav")
	precache_sound("zombie_plague/2.wav")
	precache_sound("zombie_plague/1.wav")
}

/*================================================================================
 [Round start event]
=================================================================================*/

public event_round_start()
{
	set_task(5.0, "countdown")
}

/*================================================================================
 [Countdown]
=================================================================================*/

public countdown()
{
	set_task(1.0, "ten")
	set_task(2.0, "nine")
	set_task(3.0, "eight")
	set_task(4.0, "seven")
	set_task(5.0, "six")
	set_task(6.0, "five")
	set_task(7.0, "four")
	set_task(8.0, "three")
	set_task(9.0, "two")
	set_task(10.0, "one")
}

public ten()
{
	set_dhudmessage(0, 180, 255, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
	show_dhudmessage(0, "-= 10 =-^n[**********]")
	client_cmd(0, "spk zombie_plague/10")
}

public nine()
{
	set_dhudmessage(0, 180, 255, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
	show_dhudmessage(0, "-= 9 =-^n[*********]")
	client_cmd(0, "spk zombie_plague/9")
}

public eight()
{
	set_dhudmessage(0, 180, 255, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
	show_dhudmessage(0, "-= 8 =-^n[********]")
	client_cmd(0, "spk zombie_plague/8")
}

public seven()
{
	set_dhudmessage(0, 180, 255, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
	show_dhudmessage(0, "-= 7 =-^n[*******]")
	client_cmd(0, "spk zombie_plague/7")
}

public six()
{
	set_dhudmessage(0, 180, 255, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
	show_dhudmessage(0, "-= 6 =-^n[******]")
	client_cmd(0, "spk zombie_plague/6")
}

public five()
{
	set_dhudmessage(0, 180, 255, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
	show_dhudmessage(0, "-= 5 =-^n[*****]")
	client_cmd(0, "spk zombie_plague/5")
}

public four()
{
	set_dhudmessage(0, 180, 255, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
	show_dhudmessage(0, "-= 4 =-^n[****]")
	client_cmd(0, "spk zombie_plague/4")
}

public three()
{
	set_dhudmessage(0, 180, 255, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
	show_dhudmessage(0, "-= 3 =-^n[***]")
	client_cmd(0, "spk zombie_plague/3")
}

public two()
{
	set_dhudmessage(0, 180, 255, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
	show_dhudmessage(0, "-= 2 =-^n[**]")
	client_cmd(0, "spk zombie_plague/2")
}

public one()
{
	set_dhudmessage(255, 0, 0, -1.0, 0.28, 2, 0.02, 1.0, 0.01, 0.1)
	show_dhudmessage(0, "-= 1 =-^n[*]")
	client_cmd(0, "spk zombie_plague/1")
}

/*================================================================================
                                      END
=================================================================================*/


