#if defined sh_aux_quick_checks
  #endinput
#endif
#define sh_aux_quick_checks

stock bool:client_hittable(vic_userid,optional_bool=1){
	if(vic_userid<=0){
		
		return false;
	}
	if(pev_valid(vic_userid)!=2){
		
		return false;
	}
	if(!is_user_connected(vic_userid)){
		
		return false;
	}
	return (((is_user_alive(vic_userid))?true:false)&&optional_bool);

}


stock bool:sh_clients_are_same_team(id,attacker,&CsTeams:stored_id_team=CS_TEAM_UNASSIGNED,&CsTeams:stored_attacker_team=CS_TEAM_UNASSIGNED){

	if(!is_user_connected(id)||!is_user_connected(attacker)){
		return false
	}
	new CsTeams:the_stored_id_team=cs_get_user_team(attacker),
			CsTeams:the_stored_attacker_team=cs_get_user_team(id)
	
	stored_id_team=the_stored_id_team;
	stored_attacker_team=the_stored_attacker_team;

	return (the_stored_id_team==the_stored_attacker_team)&&( id != attacker )


}