#if defined sh_aux_funcs_misc_pt2
  #endinput
#endif
#define sh_aux_funcs_misc_pt2



stock hud_msg_sync_vic, hud_msg_sync_att

stock superhero_hud_msg_sync

stock init_hud_syncs(){

	hud_msg_sync_att=CreateHudSyncObj()
	hud_msg_sync_vic=CreateHudSyncObj()
	superhero_hud_msg_sync=CreateHudSyncObj()


}

stock sh_damage_display_stock(victim, attacker,bool:att_bool=true,bool:vic_bool=true,damage){

	if(!is_user_connected(victim)||!is_user_connected(attacker)) return

	if((hud_msg_sync_vic<=0)||(hud_msg_sync_att<=0)) return
	if ( !is_user_connected(victim) || !is_user_connected(attacker) ) return
	if(sh_clients_are_same_team(victim,attacker)) return

	if(!is_user_bot(attacker)){
		if ( att_bool&&(attacker!=victim)) {
			set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 2.0, 0.02, 0.02, -1)
			ShowSyncHudMsg(attacker,hud_msg_sync_att, "%d", damage)
		}
	}

	
	if(!is_user_bot(victim)){
		if ( vic_bool) {
			set_hudmessage(200, 0, 0, -1.0, 0.48, 2, 0.1, 2.0, 0.02, 0.02, -1)
			ShowSyncHudMsg(victim, hud_msg_sync_vic, "%d", damage)
		}
	}
}
stock superhero_protected_hud_message(hud_msg_sync=-1,
				id,
				const message_text[SH_HUD_MSG_BUFF_SIZE],
				string[SH_HUD_MSG_BUFF_SIZE]="",
				r=50,
				g=205,
				b=50,
				Float:param1=-1.0,
				Float:param2=0.40,
				param3=2,
				Float:param4=0.02,
				Float:param5=4.0,
				Float:param6=0.01,
				Float:param7=0.1){

	
	if(hud_msg_sync<=0){

		return
	}
	if(is_user_connected(id)&&!is_user_bot(id)){
		
		set_hudmessage(r,g,b,param1,param2,param3,param4,param5,param6,param7)
		if(strlen(string)){
			ShowSyncHudMsg(id,hud_msg_sync,message_text,string)
		}
		else{

			ShowSyncHudMsg(id,hud_msg_sync,message_text)
		}
	}

}
			