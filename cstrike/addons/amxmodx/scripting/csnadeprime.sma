
 #include <amxmodx>
 #include <csx>
 #include <fakemeta>

 #define GRENADE_FUSE	1.7
 #define ANIM_PULLPIN	1
 #define PRIME_SOUND	"weapons/boltup.wav"

 new cvEnabled, cvExplodeInHand, cvBlockStuff, Float:primed[33], forceExplode[33];

 // plugin initiation
 public plugin_init()
 {
	register_plugin("CSNadePriming","0.10","Avalanche");

	cvEnabled = register_cvar("csnp_enabled","1");
	cvExplodeInHand = register_cvar("csnp_explodeinhand","1");
	cvBlockStuff = register_cvar("csnp_blockstuff","1");

	register_clcmd("fullupdate","cmd_fullupdate");

	register_event("ResetHUD","event_resethud","b");
	register_event("DeathMsg","event_deathmsg","a");
	register_event("CurWeapon","event_curweapon","b","1=0");

	register_forward(FM_PlayerPreThink,"fw_playerprethink");
	register_forward(FM_CmdStart,"fw_cmdstart");

	register_message(get_user_msgid("SendAudio"),"msg_sendaudio");
	register_message(get_user_msgid("TextMsg"),"msg_textmsg");
	register_message(SVC_TEMPENTITY,"msg_tempentity");
 }

 // plugin precache
 public plugin_precache()
 {
	precache_sound(PRIME_SOUND);
 }

 // block fullupdate
 public cmd_fullupdate(id)
 {
	return PLUGIN_HANDLED;
 }

 // player respawns
 public event_resethud(id)
 {
	if(is_user_connected(id))
		client_disconnect(id); // clear
 }

 // player dies
 public event_deathmsg()
 {
	client_disconnect(read_data(2)); // clear
 }

 // player leaves
 public client_disconnect(id)
 {
	primed[id] = 0.0;
	forceExplode[id] = 0;
	remove_task(id);
 }

 // player switches FROM a weapon
 public event_curweapon(id)
 {
	if(!get_pcvar_num(cvEnabled))
		return;

	new oldWeapon = read_data(2);

	if(oldWeapon == CSW_FLASHBANG || oldWeapon == CSW_HEGRENADE)
		client_disconnect(id); // clear values
 }

 // player throws a grenade
 public grenade_throw(index,greindex,wId)
 {
	remove_task(index);

	if(!get_pcvar_num(cvEnabled))
		return;

	if(forceExplode[index])
	{
		// place it right on us
		new iOrigin[3], Float:fOrigin[3];
		get_user_origin(index,iOrigin,1);
		IVecFVec(iOrigin,fOrigin);
		engfunc(EngFunc_SetOrigin,greindex,fOrigin);

		// stop it from moving anywhere
		set_pev(greindex,pev_velocity,Float:{0.0,0.0,0.0});

		// get current time
		new Float:hltime;
		global_get(glb_time,hltime);

		// explode!
		set_pev(greindex,pev_dmgtime,hltime);

		forceExplode[index] = 0;
		primed[index] = 0.0;

		return;
	}
	else if(!primed[index]) return

	new Float:dmgtime, Float:newtime, Float:hltime;

	pev(greindex,pev_dmgtime,dmgtime);
	global_get(glb_time,hltime);

	// fuse has already ran up
	if(hltime - primed[index] > dmgtime - hltime) newtime = hltime

	// we have plenty of time left
	else newtime = dmgtime - (hltime - primed[index]);

	set_pev(greindex,pev_dmgtime,newtime);
	primed[index] = 0.0;
 }

 // fire in the hole sound
 public msg_sendaudio()
 {
	if(!get_pcvar_num(cvEnabled) || !get_pcvar_num(cvBlockStuff) || !forceExplode[get_msg_arg_int(1)])
		return PLUGIN_CONTINUE;

	static sound[18];
	get_msg_arg_string(2,sound,17);

	// stop grenade throwing radio alerts
	if(equal(sound,"%!MRAD_FIREINHOLE"))
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
 }

 // fire in the hole message
 public msg_textmsg()
 {
	if(!get_pcvar_num(cvEnabled) || !get_pcvar_num(cvBlockStuff))
		return PLUGIN_CONTINUE;

	static message[21], name[32], testName[32], players[32];
	get_msg_arg_string(2,message,3);

	// some exception
	if(!str_to_num(message))
		return PLUGIN_CONTINUE;

	get_msg_arg_string(3,message,20);
	get_msg_arg_string(4,name,31);

	// CZ radio message
	if(equal(message,"#Game_radio_location",20))
		get_msg_arg_string(6,message,17);

	// regular radio message
	else if(equal(message,"#Game_radio",11))
		get_msg_arg_string(5,message,17);

	// "Fire in the hole!"
	if(!equal(message,"#Fire_in_the_hole"))
		return PLUGIN_CONTINUE;

	new i, id, num;
	get_players(players,num);

	// match name to player
	for(i=0;i<num;i++)
	{
		get_user_name(players[i],testName,31);
		if(equal(name,testName))
		{
			id = players[i];
			break;
		}
	}

	if(forceExplode[id])
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
 }

 // exclamation mark from grenade throw
 public msg_tempentity()
 {
	// 124 = TE_PLAYERATTACHMENT
	if(!get_pcvar_num(cvEnabled) || !get_pcvar_num(cvBlockStuff)
	|| get_msg_arg_int(1) != 124 || !forceExplode[get_msg_arg_int(2)])
		return PLUGIN_CONTINUE;

	// specifications of the grenade throw "!"
	if(get_msg_arg_float(3) == 35.0 && get_msg_arg_int(5) == 15)
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
 }

 // player is about to think, really hard
 public fw_playerprethink(id)
 {
	if(!get_pcvar_num(cvEnabled) || primed[id])
		return FMRES_IGNORED;

	static dummy, weapon;
	weapon = get_user_weapon(id,dummy,dummy);

	if(weapon != CSW_FLASHBANG && weapon != CSW_HEGRENADE)
		return FMRES_IGNORED;

	if(pev(id,pev_weaponanim) != ANIM_PULLPIN)
		return FMRES_IGNORED;

	// just pressed secondary fire
	if((pev(id,pev_button) & IN_ATTACK2) && !(pev(id,pev_oldbuttons) & IN_ATTACK2))
	{
		global_get(glb_time,primed[id]);
 		emit_sound(id,CHAN_WEAPON,PRIME_SOUND,0.5,ATTN_NORM,0,PITCH_HIGH);

		if(get_pcvar_num(cvExplodeInHand))
			set_task(random_float(GRENADE_FUSE-1.0,GRENADE_FUSE),"explode_in_hand",id);
	}

	return FMRES_IGNORED;
 }

 // sending out commands
 public fw_cmdstart(id,uc_handle,seed)
 {
	if(!get_pcvar_num(cvEnabled) || !forceExplode[id])
		return FMRES_IGNORED;

	// force him to throw grenade, let go of trigger
	set_uc(uc_handle,UC_Buttons,get_uc(uc_handle,UC_Buttons) & ~IN_ATTACK);
	set_uc(uc_handle,UC_Buttons,get_uc(uc_handle,UC_Buttons) & ~IN_ATTACK2);

	return FMRES_HANDLED;
 }

 // BOOM in your face!
 public explode_in_hand(id)
 {
	if(primed[id]) forceExplode[id] = 1;
 }
