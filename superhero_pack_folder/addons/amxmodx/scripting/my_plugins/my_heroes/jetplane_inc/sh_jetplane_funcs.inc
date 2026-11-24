#if defined sh_grief_drive_jet_funcs
  #endinput
#endif
#define sh_grief_drive_jet_funcs


#define JETPLANE_FUSELAGE_CLASSNAME "grief_drive_jet"

stock Float:jetplane_min_dims[3]={-33.0,-33.0,-10.0}
stock Float:jetplane_max_dims[3]={33.0,33.0,10.0}


native jet_loaded(id)
native jet_destroy(id,kill_pilot=false,inflictor=-1)
native jet_deployed(id)
native grief_drive_jet_uncharge_user(id)
native grief_drive_jet_charge_user(id)
native jet_get_user_jet(id)
native jet_hurt_user_jet(id,attacker,damage_entity,Float:damage_to_do)
