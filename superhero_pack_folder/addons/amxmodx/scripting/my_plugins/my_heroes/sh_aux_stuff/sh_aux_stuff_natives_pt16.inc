#if defined sh_aux_natives_pt16
  #endinput
#endif
#define sh_aux_natives_pt16


enum rendering_priority_consts{

  PRIO_RENDER_NONE = 0,
  PRIO_RENDER_PASSIVE = 1,
  PRIO_RENDER_INFORMATIVE = 2,
  PRIO_RENDER_EFFECT_ACTIVE = 3,
  PRIO_RENDER_POWERUP = 4,
  PRIO_RENDER_GODMODE= 5,
  PRIO_RENDER_INVISIBILITY = 6,
  PRIO_RENDER_DELETE_INVISIBILITY = 7,
  PRIO_RENDER_DELETE_ASLEEP = 8,
  PRIO_RENDER_MAX_PRIORITY = 9


}

#define PRIO_RENDER_DEFAULT  PRIO_RENDER_PASSIVE


native set_render_with_color_const(id,sh_custom_color:the_color_num,glow_on_user=1,alpha=-1,the_hud_alpha=-1,glow_user_hud=1,is_sleep=0,
    Float:unglow_timer=0.0, set_aura_glow = 1,
    rendering_fx_default = kRenderFxGlowShell,
    rendering_mode_default = kRenderTransColor,
    rendering_priority_consts = PRIO_RENDER_DEFAULT,
    gHeroID = -1)

//if the priority passed is NOT superior or equal to the previously assigned priority on the client,
//the glow will NOT get removed!

//this parameter is used to decide invisibility clashes. set it to the invisibility you put in when you made players invisible!

//(if the invisibility calculation
// from the alpha and render mode values obtained
// is lower or equal than the current player invisibility,
//and their previous priority is equal to PRIO_RENDER_INVISIBILITY as well as the passed in priority
//it wont be removed!
//(The invisibility calculation parameters are only relevant for when you set an invisible glow)
//otherwise just priority constant is considered

//any value below 0.1 removes glow instantly! (No delay task initiated)

native remove_glow_user(id,
                  rendering_priority_consts:priority_threshold = PRIO_RENDER_NONE,
                  removed_alpha = 255,
                  the_default_mode = kRenderTransColor,
                  Float:delay = 0.0,
                  heroID = -1)





native aura(id,const color[3]={255,255,255},life=3,decay=1)