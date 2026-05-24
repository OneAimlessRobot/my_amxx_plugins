#if defined sh_aux_funcs_misc_pt2
  #endinput
#endif
#define sh_aux_funcs_misc_pt2

stock bool:generic_weapon_tracer_logic(Attacker,bool:custom_boolean=true,weapon_id=-1, hero_id=-1,bool:exclude_custom_weapons= false,sh_custom_color:color_vector_indices[3]={CUSTOM,CUSTOM,CUSTOM}){

    if(!is_user_alive(Attacker)){
        return false
    }
    if(hero_id>=0){
        if(!sh_user_has_hero(Attacker, hero_id)){
            return false
        }
    }
    if(!custom_boolean){

        return false
    }
    static item; item = get_pdata_cbase(Attacker, m_pActiveItem, XTRA_OFS_PLAYER)

    if(pev_valid(item)!=2){
        return false
    }

    if(cs_is_valid_itemid(weapon_id,true)&&(weapon_id!=CSW_KNIFE)){
        
        static iId; iId = get_pdata_int(item, m_iId, XO_WEAPON)
        
        if(iId!=weapon_id){
            return false
        }
    }

    static weapon_secret_code = -1
    weapon_secret_code = entity_get_int(item, EV_INT_iuser1)
    if(exclude_custom_weapons && (weapon_secret_code >=0 )){

        return false
    }
    new Float:fvec1[3], Float:fvec2[3],vec1[3],vec2[3]
    get_user_origin(Attacker, vec1, 1) // origin; your camera point.
    get_user_origin(Attacker, vec2, 3) // termina; where your bullet goes (4 is cs-only)
    IVecFVec(vec1,fvec1)
    IVecFVec(vec2,fvec2)
    laser_line(Attacker,fvec1, fvec2,true,color_vector_indices,false)

    return true

}