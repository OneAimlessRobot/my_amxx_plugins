#if defined sh_aux_quick_checks
  #endinput
#endif
#define sh_aux_quick_checks


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


//use any <=0 to not discriminate by team. Use 1 to only get id's teamates. use 2 to only look at their enemies
stock sh_get_player_counts(id,discriminate_team=1, &alive, &dead)
{
	alive = 0
	dead = 0

	new team = get_user_team(id)
	for (new i = 1; i < sh_maxplayers()+1; i++) {
		if ((i == id || !is_user_connected(i))&&(discriminate_team<=0)) continue
		if ((get_user_team(i) != team)&&(discriminate_team==1)) continue
		if ((get_user_team(i) == team)&&(discriminate_team==2)) continue

		if (is_user_alive(i)) alive++
		else dead++
	}
}
