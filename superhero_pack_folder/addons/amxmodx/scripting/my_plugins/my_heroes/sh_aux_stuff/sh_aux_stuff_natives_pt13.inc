#if defined sh_aux_natives_pt13
  #endinput
#endif
#define sh_aux_natives_pt13


//returns true if registration was successful. false otherwise
//heroID to make into a ethereal hero
//the healthcap to give
//if < 1.0 (the default) no healthcap will be given to this hero
//ethereal heroes cannot:
//- be healed (except from electrostatic damage sources)
//- be hit with most conventional damage
//they have:
//- less gravity (cvar ptr is passed (-1 for default ethereal gravity pcvar)
//the name of it is "sh_ethereal_heroes_gravity"
//how much should they heal from dealing electrostatic damage?
//default is adding 10% to total healing


native bool:sh_register_elemental_probe_hero(heroID, Float:health_cap = -1.0, cvar_ptr = -1, Float:heal_pct_add = -1.0)

//returns true if registration was successful. false otherwise
//heroID to make into a demonic hero
//give pcvars to hp, ap and speed if you dont want the default ones
//these heroes will get no knockback
//and a configurable passive resistance to all conventional damage
//and kinetic superheromod damage


/*



lena_summary_journal2



```

Author: "Lena de Verías (Imagery) + Flora de Vaght (English translation)"
Title: "Get out, you beastly thing. You're driving the Ladies away"


  I have been away from church for a while. And for that, I dont think I deserve to pray to Our Father.
  So what I will do, Is pray to the devil instead. And tell him from the bottom of my heart
  What he means to me and how I have been using his influence in my life.

  Our devil in the trenches of hell
  Damned be your nome
  Stay away from us you gross thing
  May your whims be shamed
  Both in heaven where you fell from
  And in the gutters of hell
  Where you live at like the skunk you are.
  And may you eat from a bit of the crap
  That you give us every time
  And may it give you terminal colon gangrene.
  Amen.


  Forgive us, My Devil
  For we are sick of your pestering presence
  Ressurecting the dead to talk in our dreams
  We know you fell from the sky
  But being hurt does not make it any less weird
  The fact that you follow us around
  Trying to lower us to your level.

  May the Lord recommend you 
  At a job as a professional skittle painter
  Amen.

```

```
  [
  Author notes:
  "
  For those that want to say whatever
  Im lashing out only at those that ceased to be celestial
  [I say Lifting my hands]
  But at those that use to have
  And dont, anymore.

  ...
  I think its hillarious
  "
  ]


```


I genuinely think that the US government
Is the kind of institution to make a 4 minute
PSA AI video
With loads of unecessary special effects
And torrents upon torrents of river water being used to fuel
The loudest water coolers known to man. of course
About how the star of david is the most beautiful thing
Since the invention of cocaine

*/

native bool:sh_register_hero_with_demonic_prepackage(heroID, ap_cvar_ptr = -1, hp_cvar_ptr = -1, speed_cvar_ptr = -1)