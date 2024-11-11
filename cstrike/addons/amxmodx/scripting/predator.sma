//////////////////////////////////////////
//Predator Mode                         //
//Created By Haimmaik                   //
//Released on December 26, 2005          //
//////////////////////////////////////////
//										//
//--------------------------------------//
//Modules required:						//
//fun									//
//engine								//
//cstrike								//
//--------------------------------------//
//Doesn't work well with:				//
//Superhero mode						//
//Warcraft3 mode						//
//Amx_gore								//
//										//
//If any of them is on plz turn it off.	//
//										//
//--------------------------------------//
//Works well with:						//
//Surf_tools							//
//										//
//==========================================================================================//
//Features:																					//
//---------																					//
//This plugin allow a player to become a predator, but he needs to pay the price of			//
//frags and money (the admin decide the price). A predator have 200HP and 500AP, he is		//
//invisable and his speed and jump are better than normal. A predator also got a plasma		//
//attack.(the admin chooses how many plasma shot the predator will get every round)			//
//The predator has a special vision so he can see better. When a predator dies he becomes	//
//A normal human again. The admin can set the score the predator will get for each kill	and	//
//how much money he will get for each kill.													//
//headshot will add the predator an extra point (more than the admin decided). A predator	//
//can't use any weapon but claws and his plasma gun BUT he can kill in 1 knife strike so be	//
//aware :).																					//
//*NOTE* A predator can change his view mode (normal, 3d person, strategy)					//
//																							//
//====================================================================================================================================
//Commands(ADMIN):																													//
//---------																															//
//admin_enable_predator 1/0					Turns on and off the predator mode (default 1) *NOTE, ADMIN COMMANDS ARE STILL ACTIVE*	//
//admin_everyone_predator 1/0				Gives all the players the predator menu. if u choose not to be a predator.. u die.		//
//admin_frags_predator [number]				Decide how many frags you need to pay to become a predator (default 20)					//
//admin_money_predator [number]				Decides how much money you need to pay to become a predator (default 16,000)			//
//admin_plasma_predator[number]				Decides how many plasma shots a predator will get (default 3)							//
//admin_frags_plasma [number]				Decides how many frags a predator gets for plasma kill (default 1)						//
//admin_frags_knife [number]				Decides how many frags a predator gets for knife kill (default 2)						//
//admin_kill_money [number]					Decides how much money a predator gets for each kill (default 300)						//
//admin_predator [name][type][plasma]		Change a player into a predator, choose type of predator and amount of plasma			//
//admin_predatorteam [team][type][plasma]	Same as admin_predaotr just to a full team (T,CT,ALL or 1,2,3)							//
//admin_unpredator [name]					Change a predator into a human															//
//admin_unpredatorteam [team]				Same as admin_unpredator just to a full team (T,CT,ALL or 1,2,3)						//
//admin_addplasma [name][number]			Adds Plasma shoots to a predator (player have to be a predator)							//
//admin_predator_custom [name][type]		Changes a player's MODEL into a predator model *NOTE, HE IS NOT A PREDATOR*				//
//admin_view_predator [number]				Changes the speed of the bodyheat (default 0.2) [change map to take effect]				//
//admin_hp_predator [number]				sets amount of HP the predator gets (default 200)										//
//																																	//
//																																	//
//Commands(CLIENT):																													//
//--------																															//
//ppfire									Shoot a plasma ball (i suggest u bind it to mouse3)										//
//pcview									Change the view mode of the predator (i suggest u bind it to P)							//
//dbinds									Auto bind the client functions into the default keys									//
//say /predatorhelp							Open the help window explains about other /say commands of the mode						//
//																																	//
//====================================================================================================================================
//Server Installation:											//
//Copy the file "predator.amxx" into: addons\amxmodx\plugins\	//
//Copy the file "predhelp.txt" into: addons\amxmodx\plugins\	//
//Open the file addons\amxmodx\config\plugins.ini				//
//Add there the line "predator.amxx"							//
//																//
//Copey Those Files 	  into those places:					//
//"predator1.mdl"		cstrike\models\player\predator1\		//
//"predator2.mdl"		cstrike\models\player\predator2\		//
//"predator3.mdl"		cstrike\models\player\predator3\		//
//"predator4.mdl"		cstrike\models\player\predator4\		//
//"claws.mdl"			cstrike\models\							//
//"v_knife.mdl"			cstrike\models\							//
//"crpredator.wav"		cstrike\sound\predator\					//
//"scpredator.wav"		cstrike\sound\predator\					//
//"depredator.wav"		cstrike\sound\predator\					//
//"plasma_shoot.wav"	cstrike\sound\predator\					//
//"explosion.wav"		cstrike\sound\predator\					//
//"plasma.spr"			cstrike\sprites\						//
//"laserbeam.spr"		cstrike\sprites\						//
//"plasma_explode.spr"	cstrike\sprites\						//
//"blood.spr"			cstrike\sprites\						//
//"bloodspray.spr"		cstrike\sprites\						//
//"Fleshgibs.mdl"		cstrike\models\							//
//"GIB_Skull.mdl"		cstrike\models\							//
//"GIB_Legbone.mdl"		cstrike\models\							//
//"GIB_Lung.mdl"		cstrike\models\							//
//"GIB_B_Gib.mdl"		cstrike\models\							//
//"GIB_B_Bone.mdl"		cstrike\models\							//
//"rpgrocket.mdl"		cstrike\models\							//
//"bc_spithit2.wav"		cstrike\sound\predator\					//
//"suitchargeno1.wav"	cstrike\sound\predator\					//
//"smallmedkit2.wav"	cstrike\sound\predator\					//
//"button3.wav"			cstrike\sound\predator\					//
//																//
//================================================================
//Code taken from other plugins:	//
//amx_gore.sma						//
//GHW_speed_hack.sma				//
//amx_knivesonly.sma				//
//nvx_3rdperson.sma					//
//									//
// I HOPE I DIDNT FORGET ANY		//
//									//
//====================================
//Credits:							//
//Haimmaik							//
//zenith77							//
//Batman/Gorlag						//
//v3x								//
//XxAvalanchexX						//
//Hawk552							//
//Charr								//
//									//
// SORRY IF I FORGOT SOMEONE :(		//
//									//
//====================================
//
//	AND HERE IS THE FULL CODE!! :)
//
//---------------[INCLUDES]---------------
 #include <amxmodx>
 #include <amxmisc>
 #include <fun>
 #include <cstrike>
 #include <engine>

 //---------------[PLASMA STUFF]---------------
 new gExplosionModel
 new gTrailModel
 new msgtext
 
 //---------------[BLOOD STUFF]---------------
 new blood_drop
 new blood_spray
 
 //---------------[BODYPARTS STUFF]---------------
new mdl_gib_flesh
new mdl_gib_head
new mdl_gib_legbone
new mdl_gib_lung
new mdl_gib_meat
new mdl_gib_spine

//---------------[MSG STUFF]---------------
new MsgSayText

 //---------------[PRECATCH SOUNDS]---------------
 public plugin_precache()
 {
	precache_model("models/player/predator1/predator1.mdl")
	precache_model("models/player/predator2/predator2.mdl")
	precache_model("models/player/predator3/predator3.mdl")
	precache_model("models/player/predator4/predator4.mdl")
	precache_model("models/claws.mdl")
	precache_model("models/rpgrocket.mdl")
	precache_model("models/v_knife.mdl")
	precache_sound("predator/crpredator.wav")
	precache_sound("predator/scpredator.wav")
	precache_sound("predator/depredator.wav")
	precache_sound("predator/plasma_shoot.wav")
	precache_sound("predator/explosion.wav")
	precache_sound("predator/bc_spithit2.wav")
	precache_sound("predator/suitchargeno1.wav")
	precache_sound("predator/smallmedkit2.wav")
	precache_sound("predator/button3.wav")
	precache_model("sprites/plasma.spr")
	gTrailModel = precache_model("sprites/laserbeam.spr")
	gExplosionModel = precache_model("sprites/plasma_explode.spr")
	blood_drop = precache_model("sprites/blood.spr")
	blood_spray = precache_model("sprites/bloodspray.spr")
	mdl_gib_flesh = precache_model("models/Fleshgibs.mdl")
	mdl_gib_head = precache_model("models/GIB_Skull.mdl")
	mdl_gib_legbone = precache_model("models/GIB_Legbone.mdl")
	mdl_gib_lung = precache_model("models/GIB_Lung.mdl")
	mdl_gib_meat = precache_model("models/GIB_B_Gib.mdl")
	mdl_gib_spine = precache_model("models/GIB_B_Bone.mdl")
 }

 //---------------[PLUGIN INIT]---------------
 public plugin_init()
 {

	register_plugin("Predator_Mode","1.96","Haim")
	new keys = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5
	register_menucmd(register_menuid("Choose Your Predator:"),keys,"func_menu")
	register_event("ResetHUD","func_menuspawndelay","be")
	register_event("ResetHUD","startround","be")
	register_event("DeathMsg","unpredator","a")
	register_event("DeathMsg","death_blood","a")
	register_event("CurWeapon", "toggleclaws", "be", "1=1")
	register_event("Damage", "func_predatorpower", "b", "2!0")
	register_event("Damage","dmg_blood","b","2!0","3=0","4!0")
	register_cvar("admin_enable_predator","1")
	register_cvar("admin_frags_predator","20")
	register_cvar("admin_money_predator","16000")
	register_cvar("admin_plasma_predator","3")
	register_cvar("admin_frags_plasma","1")
	register_cvar("admin_frags_knife","2")
	register_cvar("admin_kill_money","300")
	register_cvar("admin_everyone_predator","0")
	register_cvar("admin_view_predator","0.4")
	register_cvar("admin_hp_predator","200")
	register_concmd("admin_predator","func_adminpredator",ADMIN_LEVEL_A,"[target] [kind] [plasma]")
	register_concmd("admin_predatorteam","func_adminpredatorteam",ADMIN_LEVEL_A,"[team] [kind] [plasma]")
	register_concmd("admin_addplasma","func_addplasma",ADMIN_LEVEL_A,"[target] [plasma]")
	register_concmd("admin_unpredator","func_adminunpredator",ADMIN_LEVEL_A,"[target]")
	register_concmd("admin_unpredatorteam","func_adminunpredatorteam",ADMIN_LEVEL_A,"[team]")
	register_concmd("admin_predator_custom","custom",ADMIN_LEVEL_A,"[target]")
	register_clcmd("ppfire","cmdShoot")
	register_clcmd("pcview","func_view")
	register_clcmd("dbinds","func_autobind")
	register_clcmd("say /predatorhelp","func_predhelp")
	register_clcmd("say /predcost","func_predcost")
	register_clcmd("say /predfrags","func_predfrags")
	register_clcmd("say /predmoney","func_predmoney")
	register_clcmd("say /predon","func_predon")
	register_clcmd("say /predeveryone","func_predeveryone")
	register_touch("PlasmaBall","*","plasma_hit")
	msgtext = get_user_msgid("StatusText")
	MsgSayText = get_user_msgid("SayText")
	set_task(0.85,"lowhp_blood",0,"",0,"b")
	set_task(get_cvar_float("admin_view_predator"), "func_bodyheat", 0, "", 0, "b")
 }

 //---------------[THE PREDATOR GLOBAL VALUE]---------------

 new ispredator[33]
 new delay[33]
 new plasma[33]
 new view[33]
 new onoroff[33]

 //---------------[SPAWN DELAY FOR MENU]---------------
 public func_menuspawndelay(id)
 {
	if(ispredator[id]!=0)
	{
		set_task(1.0,"func_screen",id)
	}
	if (get_cvar_num("admin_enable_predator")!=1)
	{
		set_hudmessage(0,30,200,-1.0,0.4,0,3.0,10.0,0.15,0.5,1)
		show_hudmessage(id,"Predator Mode Is Off")
		return PLUGIN_HANDLED
	}
	new msg[51]
	format(msg,50,"^x01Say ^x04 /predatorhelp ^x01 for more info.")
	message_begin(MSG_ONE,MsgSayText,{0,0,0},id)
	write_byte(id)
	write_string(msg)
	message_end()
	if(get_cvar_num("admin_everyone_predator")==0)
	{
		if((ispredator[id]==0 || ispredator[id]==5) && delay[id]<1 && get_user_frags(id)>=get_cvar_num("admin_frags_predator") && cs_get_user_money(id)>=get_cvar_num("admin_money_predator"))
		{
			set_task(1.5,"showMenu",id)
			server_cmd("sv_maxspeed 100000")
			server_cmd("sv_airaccelerate 500")
		}
	}
	if(get_cvar_num("admin_everyone_predator")==1)
	{
		if(ispredator[id]==0 || ispredator[id]==5)
		{
			set_task(1.5,"showMenu",id)
			server_cmd("sv_maxspeed 100000")
			server_cmd("sv_airaccelerate 500")
		}
	}
	return PLUGIN_HANDLED
 }


 //---------------[PRADATOR GOT KILLED]---------------
 public unpredator()
 {
	new id=read_data(2)
	if(ispredator[id]!=0)
	{
		ispredator[id]=5
		plasma[id]=0
		onoroff[id]=0
		if(get_user_health(id)>100)
		{
			set_user_health(id,get_user_health(id)-(get_cvar_num("admin_hp_predetor")-100))
		}
		cs_set_user_armor(id,0,CS_ARMOR_NONE)
		set_user_gravity(id,1.0)
		set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,255)
		set_user_footsteps(id,0)
		set_user_maxspeed(id,350.0)
		client_cmd(id,"cl_forwardspeed 400")
		client_cmd(id,"cl_backspeed 400")
		client_cmd(id,"cl_sidespeed 400")
		client_cmd(id,"spk predator/depredator")
		message_begin(MSG_ONE, 98, {0,0,0}, id)
		write_short(1<<0) 	// fade lasts this long duration
		write_short(1<<0) 	// fade lasts this long hold time
		write_short(1<<2) 	// fade type HOLD
		write_byte(100)	// fade red
		write_byte(0) 	// fade green
		write_byte(0) 	// fade blue
		write_byte(0) 	// fade alpha
		message_end()
		set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
		show_hudmessage(id,"You are no longer a predator")
		if(view[id]!=0)
		{
			func_view(id)
		}
		new HUD[51]
		format(HUD,50,"")
		message_begin(MSG_ONE, msgtext, {0,0,0}, id)
		write_byte(0)
		write_string(HUD)
		message_end()
	}
 }

 //---------------[SHOW PREDATOR MENU]---------------
 public showMenu(id)
 {
	new menu[192]
	new keys = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5

	format(menu,191,"\yChoose Your Predator:^n^n\w1. Forest Predator^n2. Mountain Predator^n3. Desert Predator^n4. Snow Predator^n5. None")
	show_menu(id,keys,menu)
	return PLUGIN_HANDLED
 }

 //---------------[PREDATOR CHOOSE]---------------
 public func_menu(id,key)
 {
	if(key==0)
	{
		if(get_cvar_num("admin_everyone_predator")==0)
		{
			set_user_frags(id,get_user_frags(id)-get_cvar_num("admin_frags_predator"))
			cs_set_user_money(id,cs_get_user_money(id)-get_cvar_num("admin_money_predator"))
		}
		ispredator[id]=1
		plasma[id]=get_cvar_num("admin_plasma_predator")
		set_user_health(id,get_cvar_num("admin_hp_predator"))
		cs_set_user_armor(id,500,CS_ARMOR_VESTHELM)
		set_user_gravity(id,0.5)
		set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
		set_user_footsteps(id,1)
		cs_set_user_model(id,"predator1")
		client_cmd(id,"spk predator/crpredator")
		set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
		show_hudmessage(id,"You are now a forest predator")
		cs_set_user_nvg(id,1)
		new HUD[51]
		format(HUD,50,"You got %i Plasma shots left.",plasma[id])
		message_begin(MSG_ONE, msgtext, {0,0,0}, id)
		write_byte(0)
		write_string(HUD)
		message_end()
	}
	if(key==1)
	{
		if(get_cvar_num("admin_everyone_predator")==0)
		{
			set_user_frags(id,get_user_frags(id)-get_cvar_num("admin_frags_predator"))
			cs_set_user_money(id,cs_get_user_money(id)-get_cvar_num("admin_money_predator"))
		}
		ispredator[id]=2
		plasma[id]=get_cvar_num("admin_plasma_predator")
		set_user_health(id,get_cvar_num("admin_hp_predator"))
		cs_set_user_armor(id,500,CS_ARMOR_VESTHELM)
		set_user_gravity(id,0.5)
		set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
		set_user_footsteps(id,1)
		cs_set_user_model(id,"predator2")
		client_cmd(id,"spk predator/crpredator")
		set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
		show_hudmessage(id,"You are now a mountain predator")
		cs_set_user_nvg(id,1)
		new HUD[51]
		format(HUD,50,"You got %i Plasma shots left.",plasma[id])
		message_begin(MSG_ONE, msgtext, {0,0,0}, id)
		write_byte(0)
		write_string(HUD)
		message_end()
	}
	if(key==2)
	{
		if(get_cvar_num("admin_everyone_predator")==0)
		{
			set_user_frags(id,get_user_frags(id)-get_cvar_num("admin_frags_predator"))
			cs_set_user_money(id,cs_get_user_money(id)-get_cvar_num("admin_money_predator"))
		}
		ispredator[id]=3
		plasma[id]=get_cvar_num("admin_plasma_predator")
		set_user_health(id,get_cvar_num("admin_hp_predator"))
		cs_set_user_armor(id,500,CS_ARMOR_VESTHELM)
		set_user_gravity(id,0.5)
		set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
		set_user_footsteps(id,1)
		cs_set_user_model(id,"predator3")
		client_cmd(id,"spk predator/crpredator")
		set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
		show_hudmessage(id,"You are now a desert predator")
		cs_set_user_nvg(id,1)
		new HUD[51]
		format(HUD,50,"You got %i Plasma shots left.",plasma[id])
		message_begin(MSG_ONE, msgtext, {0,0,0}, id)
		write_byte(0)
		write_string(HUD)
		message_end()
	}
	if(key==3)
	{
		if(get_cvar_num("admin_everyone_predator")==0)
		{
			set_user_frags(id,get_user_frags(id)-get_cvar_num("admin_frags_predator"))
			cs_set_user_money(id,cs_get_user_money(id)-get_cvar_num("admin_money_predator"))
		}
		ispredator[id]=4
		plasma[id]=get_cvar_num("admin_plasma_predator")
		set_user_health(id,get_cvar_num("admin_hp_predator"))
		cs_set_user_armor(id,500,CS_ARMOR_VESTHELM)
		set_user_gravity(id,0.5)
		set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
		set_user_footsteps(id,1)
		cs_set_user_model(id,"predator4")
		client_cmd(id,"spk predator/crpredator")
		set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
		show_hudmessage(id,"You are now a snow predator")
		cs_set_user_nvg(id,1)
		new HUD[51]
		format(HUD,50,"You got %i Plasma shots left.",plasma[id])
		message_begin(MSG_ONE, msgtext, {0,0,0}, id)
		write_byte(0)
		write_string(HUD)
		message_end()
	}
	if(key==4)
	{
		if(get_cvar_num("admin_everyone_predator")==0)
		{
			delay[id]=3
			set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
			show_hudmessage(id,"You are NOT a predator. U will have to wait 3 rounds to be predator.")
		}
		if(get_cvar_num("admin_everyone_predator")!=0)
		{
			client_cmd(id,"kill")
			set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
			show_hudmessage(id,"You have to be a predator so dont fool around.")
		}
	}
 }

 //---------------[ADMIN SET PREDATOR]---------------
 public func_adminpredator(id,level,cid)
 {
	if (!cmd_access(id,level,cid,4))
	{
		console_print(id, "sorry, ur admin level is too low to use that command")
		return PLUGIN_HANDLED
	}

	new arg[32]
	new kin[2]
	new pla[10]
	read_argv(1,arg,31)
	read_argv(2,kin,1)
	read_argv(3,pla,9)
	new kinf=str_to_num(kin)
	new plaf=str_to_num(pla)
	new player=cmd_target(id,arg,2)
	if(ispredator[player]==0)
	{
		if(kinf==1)
		{
			ispredator[player]=1
			plasma[player]=plaf
			set_user_health(player,get_cvar_num("admin_hp_predator"))
			cs_set_user_armor(player,500,CS_ARMOR_VESTHELM)
			set_user_gravity(player,0.5)
			set_user_rendering(player,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
			set_user_footsteps(player,1)
			client_cmd(player,"spk predator/crpredator")
			cs_set_user_model(player,"predator1")
			set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
			show_hudmessage(player,"You are now a predator")
			cs_set_user_nvg(player,1)
			console_print(id,"Success")
			new HUD[51]
			format(HUD,50,"You got %i Plasma shots left.",plasma[player])
			message_begin(MSG_ONE, msgtext, {0,0,0}, player)
			write_byte(0)
			write_string(HUD)
			message_end()
			return PLUGIN_HANDLED
		}
		if(kinf==2)
		{
			ispredator[player]=2
			plasma[player]=plaf
			set_user_health(player,get_cvar_num("admin_hp_predator"))
			cs_set_user_armor(player,500,CS_ARMOR_VESTHELM)
			set_user_gravity(player,0.5)
			set_user_rendering(player,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
			set_user_footsteps(player,1)
			client_cmd(player,"spk predator/crpredator")
			cs_set_user_model(player,"predator2")
			set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
			show_hudmessage(player,"You are now a predator")
			cs_set_user_nvg(player,1)
			console_print(id,"Success")
			new HUD[51]
			format(HUD,50,"You got %i Plasma shots left.",plasma[player])
			message_begin(MSG_ONE, msgtext, {0,0,0}, player)
			write_byte(0)
			write_string(HUD)
			message_end()
			return PLUGIN_HANDLED
		}
		if(kinf==3)
		{
			ispredator[player]=3
			plasma[player]=plaf
			set_user_health(player,get_cvar_num("admin_hp_predator"))
			cs_set_user_armor(player,500,CS_ARMOR_VESTHELM)
			set_user_gravity(player,0.5)
			set_user_rendering(player,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
			set_user_footsteps(player,1)
			client_cmd(player,"spk predator/crpredator")
			cs_set_user_model(player,"predator3")
			set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
			show_hudmessage(player,"You are now a predator")
			cs_set_user_nvg(player,1)
			console_print(id,"Success")
			new HUD[51]
			format(HUD,50,"You got %i Plasma shots left.",plasma[player])
			message_begin(MSG_ONE, msgtext, {0,0,0}, player)
			write_byte(0)
			write_string(HUD)
			message_end()
			return PLUGIN_HANDLED
		}
		if(kinf==4)
		{
			ispredator[player]=4
			plasma[player]=plaf
			set_user_health(player,get_cvar_num("admin_hp_predator"))
			cs_set_user_armor(player,500,CS_ARMOR_VESTHELM)
			set_user_gravity(player,0.5)
			set_user_rendering(player,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
			set_user_footsteps(player,1)
			client_cmd(player,"spk predator/crpredator")
			cs_set_user_model(player,"predator4")
			set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
			show_hudmessage(player,"You are now a predator")
			cs_set_user_nvg(player,1)
			console_print(id,"Success")
			new HUD[51]
			format(HUD,50,"You got %i Plasma shots left.",plasma[player])
			message_begin(MSG_ONE, msgtext, {0,0,0}, player)
			write_byte(0)
			write_string(HUD)
			message_end()
			return PLUGIN_HANDLED
		}
		} else {
		console_print(id,"That player is already a predator")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
 }
 
 //---------------[ADMIN SET PREDATOR FOR TEAM]---------------
 public func_adminpredatorteam(id,level,cid)
 {
	if (!cmd_access(id,level,cid,4))
	{
		console_print(id, "sorry, ur admin level is too low to use that command")
		return PLUGIN_HANDLED
	}
	new arg[32]
	new kin[2]
	new pla[10]
	read_argv(1,arg,31)
	read_argv(2,kin,1)
	read_argv(3,pla,9)
	new kinf=str_to_num(kin)
	new plaf=str_to_num(pla)
	if(equali(arg[0],"T") || equali(arg[0],"1"))
	{
		new team_players[32],nb,i
		get_players(team_players,nb,"a")
		for(i=0;i<nb;i++)
		{
			new pid = team_players[i]
			if(get_user_team(pid)==1)
			{
				if(ispredator[pid]==0)
				{
					if(kinf==1)
					{
						ispredator[pid]=1
						plasma[pid]=plaf
						set_user_health(pid,get_cvar_num("admin_hp_predator"))
						cs_set_user_armor(pid,500,CS_ARMOR_VESTHELM)
						set_user_gravity(pid,0.5)
						set_user_rendering(pid,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
						set_user_footsteps(pid,1)
						client_cmd(pid,"spk predator/crpredator")
						cs_set_user_model(pid,"predator1")
						set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
						show_hudmessage(pid,"You are now a predator")
						cs_set_user_nvg(pid,1)
						console_print(id,"Success")
						new HUD[51]
						format(HUD,50,"You got %i Plasma shots left.",plasma[pid])
						message_begin(MSG_ONE, msgtext, {0,0,0}, pid)
						write_byte(0)
						write_string(HUD)
						message_end()
					}
					if(kinf==2)
					{
						ispredator[pid]=2
						plasma[pid]=plaf
						set_user_health(pid,get_cvar_num("admin_hp_predator"))
						cs_set_user_armor(pid,500,CS_ARMOR_VESTHELM)
						set_user_gravity(pid,0.5)
						set_user_rendering(pid,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
						set_user_footsteps(pid,1)
						client_cmd(pid,"spk predator/crpredator")
						cs_set_user_model(pid,"predator2")
						set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
						show_hudmessage(pid,"You are now a predator")
						cs_set_user_nvg(pid,1)
						console_print(id,"Success")
						new HUD[51]
						format(HUD,50,"You got %i Plasma shots left.",plasma[pid])
						message_begin(MSG_ONE, msgtext, {0,0,0}, pid)
						write_byte(0)
						write_string(HUD)
						message_end()
					}
					if(kinf==3)
					{
						ispredator[pid]=3
						plasma[pid]=plaf
						set_user_health(pid,get_cvar_num("admin_hp_predator"))
						cs_set_user_armor(pid,500,CS_ARMOR_VESTHELM)
						set_user_gravity(pid,0.5)
						set_user_rendering(pid,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
						set_user_footsteps(pid,1)
						client_cmd(pid,"spk predator/crpredator")
						cs_set_user_model(pid,"predator3")
						set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
						show_hudmessage(pid,"You are now a predator")
						cs_set_user_nvg(pid,1)
						console_print(id,"Success")
						new HUD[51]
						format(HUD,50,"You got %i Plasma shots left.",plasma[pid])
						message_begin(MSG_ONE, msgtext, {0,0,0}, pid)
						write_byte(0)
						write_string(HUD)
						message_end()
					}
					if(kinf==4)
					{
						ispredator[pid]=4
						plasma[pid]=plaf
						set_user_health(pid,get_cvar_num("admin_hp_predator"))
						cs_set_user_armor(pid,500,CS_ARMOR_VESTHELM)
						set_user_gravity(pid,0.5)
						set_user_rendering(pid,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
						set_user_footsteps(pid,1)
						client_cmd(pid,"spk predator/crpredator")
						cs_set_user_model(pid,"predator4")
						set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
						show_hudmessage(pid,"You are now a predator")
						cs_set_user_nvg(pid,1)
						console_print(id,"Success")
						new HUD[51]
						format(HUD,50,"You got %i Plasma shots left.",plasma[pid])
						message_begin(MSG_ONE, msgtext, {0,0,0}, pid)
						write_byte(0)
						write_string(HUD)
						message_end()
					}
				}
			}
		}		
	}
	if(equali(arg[0],"CT") || equali(arg[0],"2"))
	{
		new team_players[32],nb,i
		get_players(team_players,nb,"a")
		for(i=0;i<nb;i++)
		{
			new pid = team_players[i]
			if(get_user_team(pid)==2)
			{
				if(ispredator[pid]==0)
				{
					if(kinf==1)
					{
						ispredator[pid]=1
						plasma[pid]=plaf
						set_user_health(pid,get_cvar_num("admin_hp_predator"))
						cs_set_user_armor(pid,500,CS_ARMOR_VESTHELM)
						set_user_gravity(pid,0.5)
						set_user_rendering(pid,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
						set_user_footsteps(pid,1)
						client_cmd(pid,"spk predator/crpredator")
						cs_set_user_model(pid,"predator1")
						set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
						show_hudmessage(pid,"You are now a predator")
						cs_set_user_nvg(pid,1)
						console_print(id,"Success")
						new HUD[51]
						format(HUD,50,"You got %i Plasma shots left.",plasma[pid])
						message_begin(MSG_ONE, msgtext, {0,0,0}, pid)
						write_byte(0)
						write_string(HUD)
						message_end()
					}
					if(kinf==2)
					{
						ispredator[pid]=2
						plasma[pid]=plaf
						set_user_health(pid,get_cvar_num("admin_hp_predator"))
						cs_set_user_armor(pid,500,CS_ARMOR_VESTHELM)
						set_user_gravity(pid,0.5)
						set_user_rendering(pid,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
						set_user_footsteps(pid,1)
						client_cmd(pid,"spk predator/crpredator")
						cs_set_user_model(pid,"predator2")
						set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
						show_hudmessage(pid,"You are now a predator")
						cs_set_user_nvg(pid,1)
						console_print(id,"Success")
						new HUD[51]
						format(HUD,50,"You got %i Plasma shots left.",plasma[pid])
						message_begin(MSG_ONE, msgtext, {0,0,0}, pid)
						write_byte(0)
						write_string(HUD)
						message_end()
					}
					if(kinf==3)
					{
						ispredator[pid]=3
						plasma[pid]=plaf
						set_user_health(pid,get_cvar_num("admin_hp_predator"))
						cs_set_user_armor(pid,500,CS_ARMOR_VESTHELM)
						set_user_gravity(pid,0.5)
						set_user_rendering(pid,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
						set_user_footsteps(pid,1)
						client_cmd(pid,"spk predator/crpredator")
						cs_set_user_model(pid,"predator3")
						set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
						show_hudmessage(pid,"You are now a predator")
						cs_set_user_nvg(pid,1)
						console_print(id,"Success")
						new HUD[51]
						format(HUD,50,"You got %i Plasma shots left.",plasma[pid])
						message_begin(MSG_ONE, msgtext, {0,0,0}, pid)
						write_byte(0)
						write_string(HUD)
						message_end()
					}
					if(kinf==4)
					{
						ispredator[pid]=4
						plasma[pid]=plaf
						set_user_health(pid,get_cvar_num("admin_hp_predator"))
						cs_set_user_armor(pid,500,CS_ARMOR_VESTHELM)
						set_user_gravity(pid,0.5)
						set_user_rendering(pid,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
						set_user_footsteps(pid,1)
						client_cmd(pid,"spk predator/crpredator")
						cs_set_user_model(pid,"predator4")
						set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
						show_hudmessage(pid,"You are now a predator")
						cs_set_user_nvg(pid,1)
						console_print(id,"Success")
						new HUD[51]
						format(HUD,50,"You got %i Plasma shots left.",plasma[pid])
						message_begin(MSG_ONE, msgtext, {0,0,0}, pid)
						write_byte(0)
						write_string(HUD)
						message_end()
					}
				}
			}
		}		
	}
	if(equali(arg[0],"ALL") || equali(arg[0],"3"))
	{
		new team_players[32],nb,i
		get_players(team_players,nb,"a")
		for(i=0;i<nb;i++)
		{
			new pid = team_players[i]
			if(ispredator[pid]==0)
			{
				if(kinf==1)
				{
					ispredator[pid]=1
					plasma[pid]=plaf
					set_user_health(pid,get_cvar_num("admin_hp_predator"))
					cs_set_user_armor(pid,500,CS_ARMOR_VESTHELM)
					set_user_gravity(pid,0.5)
					set_user_rendering(pid,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
					set_user_footsteps(pid,1)
					client_cmd(pid,"spk predator/crpredator")
					cs_set_user_model(pid,"predator1")
					set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
					show_hudmessage(pid,"You are now a predator")
					cs_set_user_nvg(pid,1)
					console_print(id,"Success")
					new HUD[51]
					format(HUD,50,"You got %i Plasma shots left.",plasma[pid])
					message_begin(MSG_ONE, msgtext, {0,0,0}, pid)
					write_byte(0)
					write_string(HUD)
					message_end()
				}
				if(kinf==2)
				{
					ispredator[pid]=2
					plasma[pid]=plaf
					set_user_health(pid,get_cvar_num("admin_hp_predator"))
					cs_set_user_armor(pid,500,CS_ARMOR_VESTHELM)
					set_user_gravity(pid,0.5)
					set_user_rendering(pid,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
					set_user_footsteps(pid,1)
					client_cmd(pid,"spk predator/crpredator")
					cs_set_user_model(pid,"predator2")
					set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
					show_hudmessage(pid,"You are now a predator")
					cs_set_user_nvg(pid,1)
					console_print(id,"Success")
					new HUD[51]
					format(HUD,50,"You got %i Plasma shots left.",plasma[pid])
					message_begin(MSG_ONE, msgtext, {0,0,0}, pid)
					write_byte(0)
					write_string(HUD)
					message_end()
				}
				if(kinf==3)
				{
					ispredator[pid]=3
					plasma[pid]=plaf
					set_user_health(pid,get_cvar_num("admin_hp_predator"))
					cs_set_user_armor(pid,500,CS_ARMOR_VESTHELM)
					set_user_gravity(pid,0.5)
					set_user_rendering(pid,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
					set_user_footsteps(pid,1)
					client_cmd(pid,"spk predator/crpredator")
					cs_set_user_model(pid,"predator3")
					set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
					show_hudmessage(pid,"You are now a predator")
					cs_set_user_nvg(pid,1)
					console_print(id,"Success")
					new HUD[51]
					format(HUD,50,"You got %i Plasma shots left.",plasma[pid])
					message_begin(MSG_ONE, msgtext, {0,0,0}, pid)
					write_byte(0)
					write_string(HUD)
					message_end()
				}
				if(kinf==4)
				{
					ispredator[pid]=4
					plasma[pid]=plaf
					set_user_health(pid,get_cvar_num("admin_hp_predator"))
					cs_set_user_armor(pid,500,CS_ARMOR_VESTHELM)
					set_user_gravity(pid,0.5)
					set_user_rendering(pid,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
					set_user_footsteps(pid,1)
					client_cmd(pid,"spk predator/crpredator")
					cs_set_user_model(pid,"predator4")
					set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
					show_hudmessage(pid,"You are now a predator")
					cs_set_user_nvg(pid,1)
					console_print(id,"Success")
					new HUD[51]
					format(HUD,50,"You got %i Plasma shots left.",plasma[pid])
					message_begin(MSG_ONE, msgtext, {0,0,0}, pid)
					write_byte(0)
					write_string(HUD)
					message_end()
				}
			}
		}		
	}
	return PLUGIN_HANDLED
}
 
 //---------------[ADMIN REMOVE PREDATOR]---------------
 public func_adminunpredator(id,level,cid)
 {
	if (!cmd_access(id,level,cid,2))
	{
		console_print(id, "sorry, ur admin level is too low to use that command")
		return PLUGIN_HANDLED
	}

	new arg[32]
	read_argv(1,arg,31)
	new player=cmd_target(id,arg,2)
	if(ispredator[player]!=0)
	{
		ispredator[player]=0
		plasma[player]=0
		if(get_user_health(player)>100)
		{
			set_user_health(player,get_user_health(player)-100)
		}
		cs_set_user_armor(id,0,CS_ARMOR_NONE)
		set_user_gravity(player,1.0)
		set_user_rendering(player,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,255)
		set_user_footsteps(player,0)
		set_user_maxspeed(player,250.0)
		client_cmd(player,"cl_forwardspeed 400")
		client_cmd(player,"cl_backspeed 400")
		client_cmd(player,"cl_sidespeed 400")
		client_cmd(player,"spk predator/depredator")
		cs_reset_user_model(player)
		set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
		show_hudmessage(player,"You are no longer a predator")
		message_begin(MSG_ONE, 98, {0,0,0}, player)
		write_short(1<<0) 	// fade lasts this long duration
		write_short(1<<0) 	// fade lasts this long hold time
		write_short(1<<2) 	// fade type HOLD
		write_byte(100)	// fade red
		write_byte(0) 	// fade green
		write_byte(0) 	// fade blue
		write_byte(0) 	// fade alpha
		message_end()
		console_print(id,"Success")
		if(view[player]!=0)
		{
			func_view(player)
		}
		onoroff[player]=0
		cs_set_user_nvg(player,0)
		client_cmd(player,"spk predator/smallmedkit2")
		new HUD[51]
		format(HUD,50,"")
		message_begin(MSG_ONE, msgtext, {0,0,0}, player)
		write_byte(0)
		write_string(HUD)
		message_end()

		} else {
		console_print(id,"That player is not a predator")
	}
	return PLUGIN_HANDLED
 }
 
 //---------------[ADMIN REMOVE PREDATOR FROM TEAM]---------------
public func_adminunpredatorteam(id,level,cid)
{
	if (!cmd_access(id,level,cid,2))
	{
		console_print(id, "sorry, ur admin level is too low to use that command")
		return PLUGIN_HANDLED
	}
	new arg[32]
	read_argv(1,arg,31)
	if(equali(arg[0],"T") || equali(arg[0],"1"))
	{
		new team_players[32],nb,i
		get_players(team_players,nb,"a")
		for(i=0;i<nb;i++)
		{
			new pid = team_players[i]
			if(get_user_team(pid)==1)
			{
				if(ispredator[pid]!=0)
				{
					ispredator[pid]=0
					plasma[pid]=0
					if(get_user_health(pid)>100)
					{
						set_user_health(pid,get_user_health(pid)-100)
					}
					cs_set_user_armor(id,0,CS_ARMOR_NONE)
					set_user_gravity(pid,1.0)
					set_user_rendering(pid,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,255)
					set_user_footsteps(pid,0)
					set_user_maxspeed(pid,250.0)
					client_cmd(pid,"cl_forwardspeed 400")
					client_cmd(pid,"cl_backspeed 400")
					client_cmd(pid,"cl_sidespeed 400")
					client_cmd(pid,"spk predator/depredator")
					cs_reset_user_model(pid)
					set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
					show_hudmessage(pid,"You are no longer a predator")
					message_begin(MSG_ONE, 98, {0,0,0}, pid)
					write_short(1<<0) 	// fade lasts this long duration
					write_short(1<<0) 	// fade lasts this long hold time
					write_short(1<<2) 	// fade type HOLD
					write_byte(100)	// fade red
					write_byte(0) 	// fade green
					write_byte(0) 	// fade blue
					write_byte(0) 	// fade alpha
					message_end()
					console_print(id,"Success")
					if(view[pid]!=0)
					{
						func_view(pid)
					}
					onoroff[pid]=0
					cs_set_user_nvg(pid,0)
					client_cmd(pid,"spk predator/smallmedkit2")
					new HUD[51]
					format(HUD,50,"")
					message_begin(MSG_ONE, msgtext, {0,0,0}, pid)
					write_byte(0)
					write_string(HUD)
					message_end()
				}
			}
		}
	}
	if(equali(arg[0],"CT") || equali(arg[0],"2"))
	{
		new team_players[32],nb,i
		get_players(team_players,nb,"a")
		for(i=0;i<nb;i++)
		{
			new pid = team_players[i]
			if(get_user_team(pid)==2)
			{
				if(ispredator[pid]!=0)
				{
					ispredator[pid]=0
					plasma[pid]=0
					if(get_user_health(pid)>100)
					{
						set_user_health(pid,get_user_health(pid)-100)
					}
					cs_set_user_armor(id,0,CS_ARMOR_NONE)
					set_user_gravity(pid,1.0)
					set_user_rendering(pid,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,255)
					set_user_footsteps(pid,0)
					set_user_maxspeed(pid,250.0)
					client_cmd(pid,"cl_forwardspeed 400")
					client_cmd(pid,"cl_backspeed 400")
					client_cmd(pid,"cl_sidespeed 400")
					client_cmd(pid,"spk predator/depredator")
					cs_reset_user_model(pid)
					set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
					show_hudmessage(pid,"You are no longer a predator")
					message_begin(MSG_ONE, 98, {0,0,0}, pid)
					write_short(1<<0) 	// fade lasts this long duration
					write_short(1<<0) 	// fade lasts this long hold time
					write_short(1<<2) 	// fade type HOLD
					write_byte(100)	// fade red
					write_byte(0) 	// fade green
					write_byte(0) 	// fade blue
					write_byte(0) 	// fade alpha
					message_end()
					console_print(id,"Success")
					if(view[pid]!=0)
					{
						func_view(pid)
					}
					onoroff[pid]=0
					cs_set_user_nvg(pid,0)
					client_cmd(pid,"spk predator/smallmedkit2")
					new HUD[51]
					format(HUD,50,"")
					message_begin(MSG_ONE, msgtext, {0,0,0}, pid)
					write_byte(0)
					write_string(HUD)
					message_end()
				}
			}
		}
	}
	if(equali(arg[0],"ALL") || equali(arg[0],"3"))
	{
		new team_players[32],nb,i
		get_players(team_players,nb,"a")
		for(i=0;i<nb;i++)
		{
			new pid = team_players[i]
			if(ispredator[pid]!=0)
			{
				ispredator[pid]=0
				plasma[pid]=0
				if(get_user_health(pid)>100)
				{
					set_user_health(pid,get_user_health(pid)-100)
				}
				cs_set_user_armor(id,0,CS_ARMOR_NONE)
				set_user_gravity(pid,1.0)
				set_user_rendering(pid,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,255)
				set_user_footsteps(pid,0)
				set_user_maxspeed(pid,250.0)
				client_cmd(pid,"cl_forwardspeed 400")
				client_cmd(pid,"cl_backspeed 400")
				client_cmd(pid,"cl_sidespeed 400")
				client_cmd(pid,"spk predator/depredator")
				cs_reset_user_model(pid)
				set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
				show_hudmessage(pid,"You are no longer a predator")
				message_begin(MSG_ONE, 98, {0,0,0}, pid)
				write_short(1<<0) 	// fade lasts this long duration
				write_short(1<<0) 	// fade lasts this long hold time
				write_short(1<<2) 	// fade type HOLD
				write_byte(100)	// fade red
				write_byte(0) 	// fade green
				write_byte(0) 	// fade blue
				write_byte(0) 	// fade alpha
				message_end()
				console_print(id,"Success")
				if(view[pid]!=0)
				{
					func_view(pid)
				}
				onoroff[pid]=0
				cs_set_user_nvg(pid,0)
				client_cmd(pid,"spk predator/smallmedkit2")
				new HUD[51]
				format(HUD,50,"")
				message_begin(MSG_ONE, msgtext, {0,0,0}, pid)
				write_byte(0)
				write_string(HUD)
				message_end()
			}
		}
	}
	return PLUGIN_HANDLED
}
 
 //---------------[START ROUND]---------------
 public startround(id)
 {
	if(ispredator[id]==0)
	{
		set_user_health(id,100)
		set_user_gravity(id,1.0)
		set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,255)
		set_user_footsteps(id,0)
		onoroff[id]=0
	}
	if(ispredator[id]==1)
	{
		plasma[id]=get_cvar_num("admin_plasma_predator")
		set_user_health(id,get_cvar_num("admin_hp_predator"))
		cs_set_user_armor(id,500,CS_ARMOR_VESTHELM)
		set_user_gravity(id,0.5)
		set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
		set_user_footsteps(id,1)
		cs_set_user_model(id,"predator1")
		cs_set_user_nvg(id,1)
		new HUD[51]
		format(HUD,50,"You got %i Plasma shots left.",plasma[id])
		message_begin(MSG_ONE, msgtext, {0,0,0}, id)
		write_byte(0)
		write_string(HUD)
		message_end()
		onoroff[id]=0
	}
	if(ispredator[id]==2)
	{
		plasma[id]=get_cvar_num("admin_plasma_predator")
		set_user_health(id,get_cvar_num("admin_hp_predator"))
		cs_set_user_armor(id,500,CS_ARMOR_VESTHELM)
		set_user_gravity(id,0.5)
		set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
		set_user_footsteps(id,1)
		cs_set_user_model(id,"predator2")
		cs_set_user_nvg(id,1)
		new HUD[51]
		format(HUD,50,"You got %i Plasma shots left.",plasma[id])
		message_begin(MSG_ONE, msgtext, {0,0,0}, id)
		write_byte(0)
		write_string(HUD)
		message_end()
		onoroff[id]=0
	}
	if(ispredator[id]==3)
	{
		plasma[id]=get_cvar_num("admin_plasma_predator")
		set_user_health(id,get_cvar_num("admin_hp_predator"))
		cs_set_user_armor(id,500,CS_ARMOR_VESTHELM)
		set_user_gravity(id,0.5)
		set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
		set_user_footsteps(id,1)
		cs_set_user_model(id,"predator3")
		cs_set_user_nvg(id,1)
		new HUD[51]
		format(HUD,50,"You got %i Plasma shots left.",plasma[id])
		message_begin(MSG_ONE, msgtext, {0,0,0}, id)
		write_byte(0)
		write_string(HUD)
		message_end()
		onoroff[id]=0
	}
	if(ispredator[id]==4)
	{
		plasma[id]=get_cvar_num("admin_plasma_predator")
		set_user_health(id,get_cvar_num("admin_hp_predator"))
		cs_set_user_armor(id,500,CS_ARMOR_VESTHELM)
		set_user_gravity(id,0.5)
		set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,20)
		set_user_footsteps(id,1)
		cs_set_user_model(id,"predator4")
		cs_set_user_nvg(id,1)
		new HUD[51]
		format(HUD,50,"You got %i Plasma shots left.",plasma[id])
		message_begin(MSG_ONE, msgtext, {0,0,0}, id)
		write_byte(0)
		write_string(HUD)
		message_end()
		onoroff[id]=0
	}
	if(ispredator[id]==5)
	{
		ispredator[id]=0
		onoroff[id]=0
		set_user_health(id,100)
		cs_set_user_armor(id,0,CS_ARMOR_VESTHELM)
		set_user_gravity(id,1.0)
		set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,255)
		set_user_footsteps(id,0)
		cs_reset_user_model(id)
		func_view(id)
	}
	if(delay[id]>0)
	{
		delay[id]= delay[id]-1
	}
 }


 //---------------[PREDATOR SPEED & KNIFE & PLASMACOUNT]---------------
 public client_PreThink(id)
 {
	new clip,ammo
	if(ispredator[id]!=0)
	{
		entity_set_float(id,EV_FL_fuser2,0.0)
		set_user_maxspeed(id,475.0)
		client_cmd(id,"cl_forwardspeed 475;cl_backspeed 475;cl_sidespeed 475")
		if(get_user_weapon(id,clip,ammo)!=CSW_KNIFE && get_user_weapon(id,clip,ammo)!=CSW_C4)
		{
			client_cmd(id,"weapon_knife")
		}
		if(get_user_health(id)<101)
		{
			set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,225-(get_user_health(id)*2))
		}
	}
 }

 //---------------[PREDATOR POWER]---------------
 public func_predatorpower(id)
 {
	func_screen(id)
	new weapon, bodypart, attacker = get_user_attacker(id,weapon,bodypart)
	if(ispredator[attacker]!=0 && attacker!=id)
	{
		new iOrigin[3]
		new wpn[32]
		get_weaponname(attacker,wpn,31)
		new damage
		new victimhealth = get_user_health(id)
		damage = read_data(2)
		if(weapon==CSW_KNIFE)
		{
			damage = damage*2
		}
		if (victimhealth - damage<1)
		{
			user_silentkill(id)
			if(ispredator[id]==0)
			{
				get_user_origin(id,iOrigin)
				// Effects
				fx_blood_red(iOrigin)
				fx_blood_red(iOrigin)
				fx_blood_red(iOrigin)
				fx_bleed_red(iOrigin)
				fx_bleed_red(iOrigin)
				fx_headshot_red(iOrigin)
				fx_blood_large_red(iOrigin,5)
				fx_blood_small_red(iOrigin,15)
				fx_trans(id,0)
				fx_gib_explode(iOrigin)
				// Hide body
				iOrigin[2] = iOrigin[2]-20
				set_user_origin(id,iOrigin)
			}
			if(ispredator[id]!=0)
			{
				get_user_origin(id,iOrigin)
				// Effects
				fx_blood_green(iOrigin)
				fx_blood_green(iOrigin)
				fx_blood_green(iOrigin)
				fx_bleed_green(iOrigin)
				fx_bleed_green(iOrigin)
				fx_headshot_green(iOrigin)
				fx_blood_large_green(iOrigin,5)
				fx_blood_small_green(iOrigin,15)
				fx_trans(id,0)
				fx_gib_explode(iOrigin)
				// Hide body
				iOrigin[2] = iOrigin[2]-20
				set_user_origin(id,iOrigin)
			}
			make_deathmsg(attacker,id,bodypart,wpn)
			set_user_frags(attacker,get_user_frags(attacker)+get_cvar_num("admin_frags_knife"))
			cs_set_user_money(attacker,cs_get_user_money(attacker)+get_cvar_num("admin_kill_money"))
			client_cmd(attacker,"spk predator/bc_spithit2")
			client_cmd(id,"spk predator/bc_spithit2")
			client_cmd(attacker,"spk predator/scpredator")
			client_cmd(id,"spk predator/scpredator")
			} else {
			set_user_health(id, victimhealth-damage)
		}
	}

	return PLUGIN_CONTINUE
 }

 //---------------[PREDATOR MODEL]---------------
 public custom(id,level,cid)
 {
	new arg[32]
	new swi[2]
	read_argv(1,arg,31)
	read_argv(2,swi,1)
	new swit=str_to_num(swi)
	new player = cmd_target(id,arg,2)
	if(swit==1)
	{
		cs_set_user_model(player,"predator1")
	}
	if(swit==2)
	{
		cs_set_user_model(player,"predator2")
	}
	if(swit==3)
	{
		cs_set_user_model(player,"predator3")
	}
	if(swit==4)
	{
		cs_set_user_model(player,"predator4")
	}
	if(swit==0)
	{
		cs_reset_user_model(player)
	}
	return PLUGIN_HANDLED
 }

 //---------------[PLASMA SHOOT]---------------

 public cmdShoot(id)
 {
	if(plasma[id]>0 && ispredator[id]!=0 && ispredator[id]!=5)
	{
		plasma[id]=plasma[id]-1

		new HUD[51]
		format(HUD,50,"You got %i Plasma shots left.",plasma[id])
		message_begin(MSG_ONE, msgtext, {0,0,0}, id)
		write_byte(0)
		write_string(HUD)
		message_end()

		new origin[3], Float:fOrigin[3]//player origin... and float origin
		new Float:velocity[3] // speed of the entity to move

		get_user_origin(id,origin,1)//get user origin - int
		IVecFVec(origin, fOrigin)// convert the int into float

		new ePlasmaBall = create_entity("info_target") // create the plasma ball
		entity_set_string(ePlasmaBall, EV_SZ_classname, "PlasmaBall") //set name of the entity "PlasmaBall"

		new Float:posAdjust[3] //Used for adjusting the starting position
		velocity_by_aim(id, 70, posAdjust)  //You can replace 50 with whatever , get origin of the AIM
		fOrigin[0] += posAdjust[0]
		fOrigin[1] += posAdjust[1]
		fOrigin[2] += posAdjust[2]
		entity_set_vector(ePlasmaBall, EV_VEC_origin,fOrigin)//set the shot's direction

		new Float:maxs[3] = {0.2,0.2,0.5}
		new Float:mins[3] = {-0.2,-0.2,-0.5}
		entity_set_size(ePlasmaBall,mins,maxs)//set size
		entity_set_int(ePlasmaBall,EV_INT_solid, SOLID_BBOX)//make solid
		entity_set_int(ePlasmaBall,EV_INT_movetype,MOVETYPE_FLYMISSILE)//set movetype
		entity_set_float(ePlasmaBall,EV_FL_framerate,1.0)//framerate
		entity_set_int(ePlasmaBall, EV_INT_rendermode, 5)//randermode
		entity_set_float(ePlasmaBall, EV_FL_renderamt, 255.0)//visable
		entity_set_float(ePlasmaBall, EV_FL_scale, 1.20)//dunno
		entity_set_model(ePlasmaBall, "sprites/plasma.spr")//model
		emit_sound(ePlasmaBall, CHAN_AUTO, "predator/plasma_shoot.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)//sound
		VelocityByAim(id,1150,velocity)//speed
		entity_set_vector(ePlasmaBall,EV_VEC_velocity,velocity)//set the shot's speed
		entity_set_edict(ePlasmaBall, EV_ENT_owner, id)

		// Create a trail...
		/* Broadcast to all players*/
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)     // TE_BEAMFOLLOW ( msg #22) create a line of decaying beam segments until entity stops moving
		write_byte(22)                // msg id
		write_short(ePlasmaBall)                // short (entity:attachment to follow)
		write_short(gTrailModel)         // short (sprite index)
		write_byte(25)                // byte (life in 0.1's)
		write_byte(7)                // byte (line width in 0.1's)
		write_byte(42)                // byte (color)
		write_byte(170)                // byte (color)
		write_byte(255)                // byte (color)
		write_byte(255)                // byte (brightness)
		message_end()
		return PLUGIN_HANDLED
		} else {
		set_hudmessage(0,30,200,-1.0,0.75,0,3.0,10.0,0.15,0.5,1)
		show_hudmessage(id,"You are out of ammo")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
 }

 //---------------[PLASMA HIT]---------------

 public plasma_hit(ePlasmaBall,other) {

	if(other == 0) {


		new Float:fOrigin[3]
		new iOrigin[3]
		// get origin....
		entity_get_vector(ePlasmaBall, EV_VEC_origin, fOrigin)


		// changes a Float vector to an interger
		FVecIVec(fOrigin, iOrigin)


		// this sends out a server message ( from const.h )
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(23)			//TE_GLOWSPRITE
		write_coord(iOrigin[0])
		write_coord(iOrigin[1])
		write_coord(iOrigin[2])
		write_short(gExplosionModel)	// model
		write_byte(3)			// life 0.x sec
		write_byte(12)	// size
		write_byte(210)		// brightness
		message_end()

		// our explosion sound...
		emit_sound(ePlasmaBall, CHAN_AUTO, "predator/explosion.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

		remove_entity(ePlasmaBall) // remove the entity
	}
	else if(is_user_connected(other)) {

		new attacker = entity_get_edict(ePlasmaBall,EV_ENT_owner)
		if(get_user_team(other)!=get_user_team(attacker))
		{
			new bodypart,weapon[32]
			new iOriginp[3]
			user_silentkill(other)
			if(ispredator[other]==0)
			{
				get_user_origin(other,iOriginp)
				// Effects
				fx_blood_red(iOriginp)
				fx_blood_red(iOriginp)
				fx_blood_red(iOriginp)
				fx_bleed_red(iOriginp)
				fx_bleed_red(iOriginp)
				fx_headshot_red(iOriginp)
				fx_blood_large_red(iOriginp,10)
				fx_blood_small_red(iOriginp,20)
				fx_trans(other,0)
				fx_gib_explode(iOriginp)
				// Hide body
				iOriginp[2] = iOriginp[2]-20
				set_user_origin(other,iOriginp)
			}
			if(ispredator[other]!=0)
			{
				get_user_origin(other,iOriginp)
				// Effects
				fx_blood_green(iOriginp)
				fx_blood_green(iOriginp)
				fx_blood_green(iOriginp)
				fx_bleed_green(iOriginp)
				fx_bleed_green(iOriginp)
				fx_headshot_green(iOriginp)
				fx_blood_large_green(iOriginp,10)
				fx_blood_small_green(iOriginp,20)
				fx_trans(other,0)
				fx_gib_explode(iOriginp)
				// Hide body
				iOriginp[2] = iOriginp[2]-20
				set_user_origin(other,iOriginp)
			}
			make_deathmsg(attacker,other,bodypart,weapon)
			set_user_frags (attacker,get_user_frags(attacker)+get_cvar_num("admin_frags_plasma"))
			cs_set_user_money(attacker,cs_get_user_money(attacker)+get_cvar_num("admin_kill_money"))

			new Float:fOrigin[3]
			new iOrigin[3]
			// get origin....
			entity_get_vector(ePlasmaBall, EV_VEC_origin, fOrigin)


			// changes a Float vector to an interger
			FVecIVec(fOrigin, iOrigin)


			// this sends out a server message ( from const.h )
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(23)			//TE_GLOWSPRITE
			write_coord(iOrigin[0])
			write_coord(iOrigin[1])
			write_coord(iOrigin[2])
			write_short(gExplosionModel)	// model
			write_byte(3)			// life 0.x sec
			write_byte(12)	// size
			write_byte(210)		// brightness
			message_end()

			// our explosion sound...
			emit_sound(ePlasmaBall, CHAN_AUTO, "predator/explosion.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			client_cmd(other,"spk predator/bc_spithit2")
			client_cmd(attacker,"spk predator/bc_spithit2")

			remove_entity(ePlasmaBall)
			} else {
			new Float:fOrigin[3]
			new iOrigin[3]
			// get origin....
			entity_get_vector(ePlasmaBall, EV_VEC_origin, fOrigin)


			// changes a Float vector to an interger
			FVecIVec(fOrigin, iOrigin)


			// this sends out a server message ( from const.h )
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(23)			//TE_GLOWSPRITE
			write_coord(iOrigin[0])
			write_coord(iOrigin[1])
			write_coord(iOrigin[2])
			write_short(gExplosionModel)	// model
			write_byte(3)			// life 0.x sec
			write_byte(12)	// size
			write_byte(210)		// brightness
			message_end()

			// our explosion sound...
			emit_sound(ePlasmaBall, CHAN_AUTO, "predator/explosion.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			remove_entity(ePlasmaBall)
		}
			} else {
				new Float:fOrigin[3]
				new iOrigin[3]
				// get origin....
				entity_get_vector(ePlasmaBall, EV_VEC_origin, fOrigin)


				// changes a Float vector to an interger
				FVecIVec(fOrigin, iOrigin)


				// this sends out a server message ( from const.h )
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
				write_byte(23)			//TE_GLOWSPRITE
				write_coord(iOrigin[0])
				write_coord(iOrigin[1])
				write_coord(iOrigin[2])
				write_short(gExplosionModel)	// model
				write_byte(3)			// life 0.x sec
				write_byte(12)	// size
				write_byte(210)		// brightness
				message_end()

				// our explosion sound...
				emit_sound(ePlasmaBall, CHAN_AUTO, "predator/explosion.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

				remove_entity(ePlasmaBall) // remove the entity
		}
 }

 public func_addplasma(id,level,cid)
 {
	if (!cmd_access(id,level,cid,3))
	{
		console_print(id, "sorry, ur admin level is too low to use that command")
		return PLUGIN_HANDLED
	}

	new arg[32]
	new am[10]
	read_argv(1,arg,31)
	read_argv(2,am,9)
	new amf=str_to_num(am)
	new player = cmd_target(id,arg,2)
	if(ispredator[player]!=0 && ispredator[player]!=5)
	{
		plasma[player]=plasma[player]+amf
		new HUD[51]
		format(HUD,50,"You got %i Plasma shots left.",plasma[player])
		message_begin(MSG_ONE, msgtext, {0,0,0}, player)
		write_byte(0)
		write_string(HUD)
		message_end()
	}
	return PLUGIN_HANDLED
 }

 //---------------[PUBLIC ON CONNECT FUNCTION]---------------
 public client_disconnect(id)
 {
	ispredator[id]=0
	plasma[id]=0
	onoroff[id]=0
 }

 //---------------[PREDATOR BLUE SCREEN EVERY NEW ROUND]---------------
 public func_screen(id)
 {
	if(is_user_alive(id))
	{
		if(view[id]==1 && ispredator[id]!=0)
		{
			onoroff[id]=1
			client_cmd(id,"spk predator/suitchargeno1")
			message_begin(MSG_ONE, 98, {0,0,0}, id)
			write_short(1<<0) 	// fade lasts this long duration
			write_short(1<<0) 	// fade lasts this long hold time
			write_short(1<<2) 	// fade type HOLD
			write_byte(0)	// fade red
			write_byte(0) 	// fade green
			write_byte(255) 	// fade blue
			write_byte(130) 	// fade alpha
			message_end()
		}
		if(view[id]==2 && ispredator[id]!=0)
		{
			onoroff[id]=2
			client_cmd(id,"spk predator/suitchargeno1")
			message_begin(MSG_ONE, 98, {0,0,0}, id)
			write_short(1<<0) 	// fade lasts this long duration
			write_short(1<<0) 	// fade lasts this long hold time
			write_short(1<<2) 	// fade type HOLD
			write_byte(25)	// fade red
			write_byte(25) 	// fade green
			write_byte(25) 	// fade blue
			write_byte(210) 	// fade alpha
			message_end()
		}
	}
 }

 //---------------[PREDATOR CLAWS]---------------

 public toggleclaws(id)
 {
	new clip, ammo, wpnid = get_user_weapon(id,clip,ammo)
	new model[32]
	entity_get_string(id,EV_SZ_viewmodel,model,31)
	if(ispredator[id]!=0 && !equali(model,"models/claws.mdl") && !equali(model,"models/v_c4.mdl"))
	{
		entity_set_string(id, EV_SZ_viewmodel,"models/claws.mdl")
	}
	if(ispredator[id]==0 && wpnid == CSW_KNIFE && !equali(model,"models/v_knife.mdl"))
	{
		entity_set_string(id, EV_SZ_viewmodel,"models/v_knife.mdl")
	}
 }
 
 //---------------[PREDATOR VIEW]---------------
 public func_view(id)
 {
	 if(ispredator[id]!=0 && ispredator[id]!=5)
	 {
		 if(view[id]==0)
		 {
			 view[id]=1
			 onoroff[id]=1
			 client_cmd(id,"spk predator/suitchargeno1")
			 console_print(id,"view is normal with mask")
			 message_begin(MSG_ONE, 98, {0,0,0},id)
			 write_short(1<<0) 	// fade lasts this long duration
			 write_short(1<<0) 	// fade lasts this long hold time
		 	 write_short(1<<2) 	// fade type HOLD
			 write_byte(0)	// fade red
			 write_byte(0) 	// fade green
			 write_byte(255) 	// fade blue
			 write_byte(120) 	// fade alpha
			 message_end()
			 return PLUGIN_HANDLED
		 }
		 if(view[id]==1)
		 {
			 view[id]=2
			 onoroff[id]=2
			 client_cmd(id,"spk predator/suitchargeno1")
			 console_print(id,"predator view mode")
			 message_begin(MSG_ONE, 98, {0,0,0},id)
			 write_short(1<<0) 	// fade lasts this long duration
			 write_short(1<<0) 	// fade lasts this long hold time
		 	 write_short(1<<2) 	// fade type HOLD
			 write_byte(25)	// fade red
			 write_byte(25) 	// fade green
			 write_byte(25) 	// fade blue
			 write_byte(210) 	// fade alpha
			 message_end()
			 return PLUGIN_HANDLED
		 }
		 if(view[id]==2)
		 {
			 view[id]=3
			 client_cmd(id,"spk predator/smallmedkit2")
			 console_print(id,"view is 3d person mode")
			 set_view(id,CAMERA_3RDPERSON)
			 onoroff[id]=0
			 message_begin(MSG_ONE, 98, {0,0,0},id)
			 write_short(1<<0) 	// fade lasts this long duration
			 write_short(1<<0) 	// fade lasts this long hold time
		 	 write_short(1<<2) 	// fade type HOLD
			 write_byte(0)	// fade red
			 write_byte(0) 	// fade green
			 write_byte(0) 	// fade blue
			 write_byte(0) 	// fade alpha
			 message_end()
			 return PLUGIN_HANDLED
		 }
		 if(view[id]==3)
		 {
			 view[id]=4
			 client_cmd(id,"spk predator/button3")
			 console_print(id,"view is strategy")
			 set_view(id,CAMERA_TOPDOWN)
			 return PLUGIN_HANDLED
		 }
		 if(view[id]==4)
		 {
			 view[id]=0
			 client_cmd(id,"spk predator/button3")
			 console_print(id,"view is normal")
			 set_view(id,CAMERA_NONE)
			 return PLUGIN_HANDLED
		 }
		 
	 }
	 if(ispredator[id]==0 && view[id]!=0)
	 {
		 set_view(id,CAMERA_NONE)
		 view[id]=0
		 onoroff[id]=0
		 set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderTransAlpha,255)
		 return PLUGIN_HANDLED
	 }
	 return PLUGIN_HANDLED
 }
 
  //=======================================================================================
  //=====================================[BLOOD STUFF]=====================================
  //=======================================================================================

  //---------------[MAKE MODEL INVISABLE IN EXPLOTION]---------------
static fx_trans(player,amount)
{
	set_user_rendering(player,kRenderFxNone,0,0,0,kRenderTransAlpha,amount)
	return PLUGIN_CONTINUE
}
  
 //---------------[BLOOD EVERY HIT (HUAMN)]---------------
   public fx_blood_red(origin[3]) //hit blood human
 {
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(115) //TE_BLOODSPRITE in const.h
	write_coord(origin[0]+random_num(-20,20))
	write_coord(origin[1]+random_num(-20,20))
	write_coord(origin[2]+random_num(-20,20))
	write_short(blood_spray)
	write_short(blood_drop)
	write_byte(248) // color index
	write_byte(15) // size
	message_end()
 }
 
  //---------------[BLOOD EVERY HIT (PREDATOR)]---------------
 public fx_blood_green(origin[3]) //hit blood predator
 {
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(115) //TE_BLOODSPRITE in const.h
	write_coord(origin[0]+random_num(-20,20))
	write_coord(origin[1]+random_num(-20,20))
	write_coord(origin[2]+random_num(-20,20))
	write_short(blood_spray)
	write_short(blood_drop)
	write_byte(192) // color index
	write_byte(15) // size
	message_end()
 }
 
  //---------------[DIEING BLEEDING HUMAN]---------------
public fx_bleed_red(origin[3]) //blood sprays on low hp
{
	// Blood spray
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(101)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+10)
	write_coord(random_num(-100,100)) // x
	write_coord(random_num(-100,100)) // y
	write_coord(random_num(-10,10)) // z
	write_byte(70) // color
	write_byte(random_num(50,100)) // speed
	message_end()
}

 //---------------[DIEING BLEEDING PREDATOR]---------------
public fx_bleed_green(origin[3]) //blood sprays on low hp green
{
	// Blood spray
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(101)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+10)
	write_coord(random_num(-100,100)) // x
	write_coord(random_num(-100,100)) // y
	write_coord(random_num(-10,10)) // z
	write_byte(192) // color
	write_byte(random_num(50,100)) // speed
	message_end()
}

 //---------------[HEADSHOT BLOOD HUMAN]---------------
public fx_headshot_red(origin[3])
{
	// Blood spray, 5 times
	for (new i = 0; i < 5; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(101)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2]+30)
		write_coord(random_num(-20,20)) // x
		write_coord(random_num(-20,20)) // y
		write_coord(random_num(50,300)) // z
		write_byte(70) // color
		write_byte(random_num(100,200)) // speed
		message_end()
	}
}

 //---------------[HEADSHOT BLOOD PREDATOR]---------------
public fx_headshot_green(origin[3])
{
	// Blood spray, 8 times
	for (new i = 0; i < 8; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(101)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2]+30)
		write_coord(random_num(-20,20)) // x
		write_coord(random_num(-20,20)) // y
		write_coord(random_num(50,300)) // z
		write_byte(192) // color
		write_byte(random_num(100,200)) // speed
		message_end()
	}
}

 //---------------[BLOOD DECALS SMALL RED]---------------
static fx_blood_small_red(origin[3],num) //red blood decals [small]
{
	// Blood decals
	static const blood_small[7] = {190,191,192,193,194,195,197}
	// Small splash
	for (new j = 0; j < num; j++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(116) //TE_WORLDDECAL from const.h
		write_coord(origin[0]+random_num(-100,100))
		write_coord(origin[1]+random_num(-100,100))
		write_coord(origin[2]-36)
		write_byte(blood_small[random_num(0,6)]) // index
		message_end()
	}
}

 //---------------[BLOOD DECALS BIG RED]---------------
static fx_blood_large_red(origin[3],num) //red blood decals [ big]
{
	// Blood decals
	static const blood_large[2] = {204,205}

	// Large splash
	for (new i = 0; i < num; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(116) //TE_WORLDDECAL from const.h
		write_coord(origin[0]+random_num(-50,50))
		write_coord(origin[1]+random_num(-50,50))
		write_coord(origin[2]-36)
		write_byte(blood_large[random_num(0,1)]) // index
		message_end()
	}
}

 //---------------[BLOOD DECALS SMALL GREEN]---------------
static fx_blood_small_green(origin[3],num) //green blood decals [small]
{
	// Blood decals
	static const blood_small[6] = {3,4,5,6,7,8}
	// Small splash
	for (new j = 0; j < num; j++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(116) //TE_WORLDDECAL from const.h
		write_coord(origin[0]+random_num(-65,65))
		write_coord(origin[1]+random_num(-65,65))
		write_coord(origin[2]-36)
		write_byte(blood_small[random_num(0,5)]) // index
		message_end()
	}
}

 //---------------[BLOOD DECALS BIG GREEN]---------------
static fx_blood_large_green(origin[3],num) //green blood decals [ big]
{
	// Blood decals
	static const blood_large[2] = {26,27}

	// Large splash
	for (new i = 0; i < num; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(116) //TE_WORLDDECAL from const.h
		write_coord(origin[0]+random_num(-45,45))
		write_coord(origin[1]+random_num(-45,45))
		write_coord(origin[2]-36)
		write_byte(blood_large[random_num(0,1)]) // index
		message_end()
	}
}

 //---------------[GRANADE EXPLOTION BODYPARTS MODELS]---------------
static fx_gib_explode(origin[3])
{
	new flesh[3]
	flesh[0] = mdl_gib_flesh
	flesh[1] = mdl_gib_meat
	flesh[2] = mdl_gib_legbone

	// Gib explosion
	// Head
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(106) //TR_MODEL
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(random_num(-100,100))
	write_coord(random_num(-100,100))
	write_coord(random_num(100,200))
	write_angle(random_num(0,360))
	write_short(mdl_gib_head)
	write_byte(0) // bounce
	write_byte(500) // life
	message_end()
	
	// Spine
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(106)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_coord(random_num(-100,100))
	write_coord(random_num(-100,100))
	write_coord(random_num(100,200))
	write_angle(random_num(0,360))
	write_short(mdl_gib_spine)
	write_byte(0) // bounce
	write_byte(500) // life
	message_end()
	
	// Lung
	for(new i = 0; i < random_num(1,2); i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(106)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(random_num(-100,100))
		write_coord(random_num(-100,100))
		write_coord(random_num(100,200))
		write_angle(random_num(0,360))
		write_short(mdl_gib_lung)
		write_byte(0) // bounce
		write_byte(500) // life
		message_end()
	}
	
	// Parts, 5 times
	for(new i = 0; i < 5; i++) {
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(106)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2])
		write_coord(random_num(-100,100))
		write_coord(random_num(-100,100))
		write_coord(random_num(100,200))
		write_angle(random_num(0,360))
		write_short(flesh[random_num(0,2)])
		write_byte(0) // bounce
		write_byte(500) // life
		message_end()
	}
}

//===========================================[FUNCTIONS]===========================================

 //---------------[PLAYER HIT BLOOD]---------------
public dmg_blood()
{
	new id=read_data(0)
	if(is_user_alive(id))
	{
		new origin[3]
		get_user_origin(id,origin)
		if(ispredator[id]==0)
		{
			fx_blood_red(origin)
			fx_blood_small_red(origin,3)
		}
		if(ispredator[id]!=0)
		{
			fx_blood_green(origin)
			fx_blood_small_green(origin,3)
		}
	}
}

 //---------------[PLAYER BLEED ON LOW HP]---------------
public lowhp_blood()
{
	new iPlayer, iPlayers[32], iNumPlayers, iOrigin[3]
	get_players(iPlayers,iNumPlayers,"a")
	for (new i = 0; i < iNumPlayers; i++) 
	{
		iPlayer = iPlayers[i]
		if(get_user_health(iPlayer)< 20)
		{
			if (ispredator[iPlayer]==0)
			{
				get_user_origin(iPlayer,iOrigin)
				fx_bleed_red(iOrigin)
				fx_blood_small_red(iOrigin,5)
			}
			if (ispredator[iPlayer]!=0)
			{
				get_user_origin(iPlayer,iOrigin)
				fx_bleed_green(iOrigin)
				fx_blood_small_green(iOrigin,5)
			}
		}
	}
}

 //---------------[DEATH BLOOD EFFECTS (HEADSHOT/GRANADE EXPLOTION)]---------------
public death_blood()
{
	new iOrigin[3]
	new sWeapon[32]
	new id = read_data(2)
	new iHeadshot = read_data(3)
	
	read_data(4,sWeapon,31)
	
	if (iHeadshot)
	{
		if(ispredator[id]==0)
		{
			get_user_origin(id,iOrigin)
			fx_headshot_red(iOrigin)
			fx_blood_large_red(iOrigin,2)
			fx_blood_small_red(iOrigin,5)
		}
		if(ispredator[id]!=0)
		{
			get_user_origin(id,iOrigin)
			fx_headshot_green(iOrigin)
			fx_blood_large_green(iOrigin,2)
			fx_blood_small_green(iOrigin,5)
		}
	}
	else if (equal(sWeapon,"grenade"))
	{
		if(ispredator[id]==0)
		{
			get_user_origin(id,iOrigin)
			// Effects
			fx_blood_red(iOrigin)
			fx_blood_red(iOrigin)
			fx_blood_red(iOrigin)
			fx_bleed_red(iOrigin)
			fx_bleed_red(iOrigin)
			fx_headshot_red(iOrigin)
			fx_trans(id,0)
			fx_gib_explode(iOrigin)
			fx_blood_large_red(iOrigin,10)
			fx_blood_small_red(iOrigin,25)
			// Hide body
			iOrigin[2] = iOrigin[2]-20
			set_user_origin(id,iOrigin)
		}
		if(ispredator[id]!=0)
		{
			get_user_origin(id,iOrigin)
			// Effects
			fx_blood_green(iOrigin)
			fx_blood_green(iOrigin)
			fx_blood_green(iOrigin)
			fx_bleed_green(iOrigin)
			fx_bleed_green(iOrigin)
			fx_headshot_green(iOrigin)
			fx_trans(id,0)
			fx_gib_explode(iOrigin)
			fx_blood_large_green(iOrigin,10)
			fx_blood_small_green(iOrigin,25)
			// Hide body
			iOrigin[2] = iOrigin[2]-20
			set_user_origin(id,iOrigin)
		}
	} 
	if(ispredator[id]==0)
	{
		fx_blood_small_red(iOrigin,12)
		fx_blood_large_red(iOrigin,5)
	}
	if(ispredator[id]!=0)
	{
		fx_blood_small_green(iOrigin,12)
		fx_blood_large_green(iOrigin,5)
	}
}

//---------------[AUTO BIND SYSTEM]---------------

public func_autobind(id)
{
	client_cmd(id,"bind p pcview")
	client_cmd(id,"bind mouse3 ppfire")
	console_print(id,"Key Defaults are bound. ENJOY!")
	return PLUGIN_HANDLED
}

//---------------[BODY HEAT SYSTEM CONNECT]---------------
public client_connect(id)
{
	onoroff[id] = 0
	ispredator[id]=0
	plasma[id]=0
}

//---------------[BODY HEAT AND LIGHTSIGHT SYSTEM]---------------
public func_bodyheat()
{
	new players[32]
	new pnum,origin[3]
	new idheat,id
	get_players(players,pnum,"a")
	for (new i = 0; i < pnum; i++)
	{
		id = players[i]
		if(ispredator[id]!=0 && ispredator[id]!=5)
		{
			if (onoroff[id]==1 && is_user_alive(id))
			{
				for (new j = 0; j < pnum; j++)
				{
					idheat = players[j]
					if (idheat != id && ispredator[idheat]==0 && is_user_alive(idheat))
					{
						get_user_origin(idheat,origin,0)
						message_begin(MSG_ONE,SVC_TEMPENTITY,origin,id)
						write_byte(21)
						write_coord(origin[0])
						write_coord(origin[1])
						write_coord(origin[2])
						write_coord(origin[0])
						write_coord(origin[1])
						write_coord(origin[2]+30)
						write_short(gTrailModel)
						write_byte(0)
						write_byte(1)
						write_byte(6)
						write_byte(60)
						write_byte(1)
						write_byte(250) // red
						write_byte(60) // green
						write_byte(0) // blue
						write_byte(255) //brightness
						write_byte(0)
						message_end()
					}
				}
			}
			if (onoroff[id]==2 && is_user_alive(id))
			{
				for (new j = 0; j < pnum; j++)
				{
					idheat = players[j]
					if (idheat != id && ispredator[idheat]!=0 && is_user_alive(idheat))
					{
						get_user_origin(idheat,origin,0)
						message_begin(MSG_ONE,SVC_TEMPENTITY,origin,id)
						write_byte(21)
						write_coord(origin[0])
						write_coord(origin[1])
						write_coord(origin[2])
						write_coord(origin[0])
						write_coord(origin[1])
						write_coord(origin[2]+30)
						write_short(gTrailModel)
						write_byte(0)
						write_byte(1)
						write_byte(6)
						write_byte(60)
						write_byte(1)
						write_byte(255) // red
						write_byte(255) // green
						write_byte(255) // blue
						write_byte(255) //brightness
						write_byte(0)
						message_end()
					}
				}
			}
		}
	}
}

  //=======================================================================================
  //======================================[Info Area]======================================
  //=======================================================================================

//---------------[Predator Help]---------------
public func_predhelp(id)
{
	show_motd(id,"/addons/amxmodx/plugins/predhelp.txt","Predator Help")
}

//---------------[Predator Cost Check]---------------
public func_predcost(id)
{
	new msg[101]
	format(msg,100,"^x01You need ^x04%d frags ^x01 and ^x04%d money ^x01 to be a predator.",get_cvar_num("admin_frags_predator"),get_cvar_num("admin_money_predator"))
	message_begin(MSG_ONE,MsgSayText,{0,0,0},id)
	write_byte(id)
	write_string(msg)
	message_end()
}

//---------------[Predator Frags Check]---------------
public func_predfrags(id)
{
	new msg[101]
	format(msg,100,"^x01You get ^x04%d ^x01 frags for ^x03 Knife ^x01 and ^x04%d ^x01 frags for ^x03 Plasma.",get_cvar_num("admin_frags_knife"),get_cvar_num("admin_frags_plasma"))
	message_begin(MSG_ONE,MsgSayText,{0,0,0},id)
	write_byte(id)
	write_string(msg)
	message_end()
}

//---------------[Predator Money Check]---------------
public func_predmoney(id)
{
	new msg[101]
	format(msg,100,"^x01You get ^x04%d ^x01 money for each kill.",get_cvar_num("admin_kill_money"))
	message_begin(MSG_ONE,MsgSayText,{0,0,0},id)
	write_byte(id)
	write_string(msg)
	message_end()
}

//---------------[Predator On or Off check]---------------
public func_predon(id)
{
	new msg[101]
	if(get_cvar_num("admin_enable_predator")==1)
	{
		format(msg,100,"^x01Predator Mode is ^x03 On.")
	}
	if(get_cvar_num("admin_enable_predator")==0)
	{
		format(msg,100,"^x01Predator Mode is ^x03 Off.")
	}
	message_begin(MSG_ONE,MsgSayText,{0,0,0},id)
	write_byte(id)
	write_string(msg)
	message_end()
}

//---------------[Predator Everyone mode on or off check]---------------
public func_predeveryone(id)
{
	new msg[101]
	if(get_cvar_num("admin_everyone_predator")==1)
	{
		format(msg,100,"^x01Predator Everyone Mode is ^x03 On.")
	}
	if(get_cvar_num("admin_everyone_predator")==0)
	{
		format(msg,100,"^x01Predator Everyone Mode is ^x03 Off.")
	}
	message_begin(MSG_ONE,MsgSayText,{0,0,0},id)
	write_byte(id)
	write_string(msg)
	message_end()
}
