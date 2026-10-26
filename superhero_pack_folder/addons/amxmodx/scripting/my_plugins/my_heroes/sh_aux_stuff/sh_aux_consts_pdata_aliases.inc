#if defined sh_aux_consts_pdata_aliases
  #endinput
#endif
#define sh_aux_consts_pdata_aliases




//player flags

#define TOUCHING_GROUND (1<<9)
#define FL_INGROUND2 TOUCHING_GROUND

#if !defined reapi_included 
	//player offsets

	#define XO_PLAYER	5 // linux offset to be used on pdatas with player entities

										//add these offsets in the correct parameter


	#define fPainShock 108					//player pain shock offset
	#define m_iHideHUD 361
	#define m_rgAmmo_player_Slot0  376			//how much ammo does player have in slot 0?
	/**
	Example in how to use this:

	if(iWeaponEntity > 0)
	{
		iAmmoType = m_rgAmmo_player_Slot0 + 
				get_pdata_int(iWeaponEntity, m_iPrimaryAmmoType, XO_WEAPON)
		
		iAmmo = get_pdata_int(iWeaponEntity, m_iClip, XO_WEAPON)
		
		iMagazine = get_pdata_int(iBotIdentity, iAmmoType, XO_PLAYER)
		
		give_item(iPlayer, szWeaponName)
		
		set_pdata_int(iPlayer, iAmmoType, iMagazine, XO_PLAYER)
		
		set_pdata_int(iWeaponEntity, m_iClip, iAmmo, XO_WEAPON)
	}

	*/

	#define m_flNextAttack 83					//when is next user attack allowed with any weapon?

	#define m_rgpPlayerItems_Slot0 367		//what item id does player have in slot 0?
	#define m_pActiveItem 373				//what item is user holding?

	#define m_bResumeZoom 440				//the linux offset should be multiplied by 4 
													//as well as this constant.
													//as it refers to a place in memory which is a single byte in size

	#define m_szAnimExtention 492             //its animation related, definitely
													//this is also multiplied by 4
													//as it is byte sized. (its a string)

	// weapons offsets

	#define XO_WEAPON  4 						//linux offset to be used on pdatas with weapon/item entities


	#define m_flNextPrimaryAttack    46		//when is the next weapon primary attack?

	#define m_fKnown 44 						//idk what this is
	#define m_iPrimaryAmmoType	49			//ammo type in current weapon.
													// 5.56 nato box in Colt m4a1 for example
	#define m_fSilent 74						//is weapon silenced?

	#define m_flNextSecondaryAttack    47		//when is the next weapon secondary attack?
	#define m_fInReload            54 		//is magazine weapon reloading? 
	#define m_iClip 51 						//number of ammo in clip
	#define m_fInSpecialReload 55 			//is shotgun reloading? (1 by 1)
	#define m_pNext 42
	#define m_flTimeWeaponIdle        48
	#define m_iId                43 			// pdata offset for item id (CSW_AWP, CSW_KNIFE, etc.)
	#define m_pPlayer            41 			// pdata offset for item owner
	#define m_iShellId			57 				// shell id for this weapon
	#define m_flEjectBrass     111              // eject brass delay for this weapon

#endif
