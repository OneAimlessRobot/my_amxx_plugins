#if defined auxiliar_stuff_macros_inc
  #endinput
#endif
#define auxiliar_stuff_macros_inc


#define enum_minus_one (any:-1)
#define enum_zero (any:0)
#define enum_one (any:1)


#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) (%1 |= (1 << (%2 & 31)))
#define UnSet_BitVar(%1,%2) (%1 &= ~(1 << (%2 & 31)))


#define Assign_BitVar(%1,%2,%3) ((%3) ? Set_BitVar(%1,%2) : UnSet_BitVar(%1,%2))

stock bool:true_for_macro=true,
	bool:false_for_macro=false


#define cvar_val(%1,%2) get_pcvar_%1(%2)

#define ANTI_LAGG		7

#define SIZE_OF_BYTE 8

#define SIZE_OF_SHORT 16

#define SIZE_OF_INT 32


#define nth_power_of_two(%1) (1<<%1)

#define exhausted_bitsum (((nth_power_of_two(SIZE_OF_INT-1)-1))+nth_power_of_two(SIZE_OF_INT-1))

#define max_integer_limit (power(2,31)-1);


#define MUL_TWO(%0,%1)                                                          \
    (                                                                           \
        (%0)                                                                    \
        *                                                                       \
        (%1)                                                                    \
    )


/**

amx errors to help me debug

out of bounds is 4


its all from 0
in err none

to whatever the last one is

1 by 1

err exit is 1

err assert is 2, etc.


enum {
  AMX_ERR_NONE,
  // reserve the first 15 error codes for exit codes of the abstract machine //
  AMX_ERR_EXIT,         // forced exit //
  AMX_ERR_ASSERT,       // assertion failed //
  AMX_ERR_STACKERR,     // stack/heap collision //
  AMX_ERR_BOUNDS,       // index out of bounds //
  AMX_ERR_MEMACCESS,    // invalid memory access //
  AMX_ERR_INVINSTR,     // invalid instruction //
  AMX_ERR_STACKLOW,     // stack underflow //
  AMX_ERR_HEAPLOW,      // heap underflow //
  AMX_ERR_CALLBACK,     // no callback, or invalid callback //
  AMX_ERR_NATIVE,       // native function failed //
  AMX_ERR_DIVIDE,       // divide by zero //
  AMX_ERR_SLEEP,        // go into sleepmode - code can be restarted //
  AMX_ERR_INVSTATE,     // invalid state for this access //
  AMX_ERR_INVNATIVE,    // invalid native was used //

  AMX_ERR_MEMORY = 16,  // out of memory //
  AMX_ERR_FORMAT,       // invalid file format //
  AMX_ERR_VERSION,      // file is for a newer version of the AMX //
  AMX_ERR_NOTFOUND,     // function not found //
  AMX_ERR_INDEX,        // invalid index parameter (bad entry point) //
  AMX_ERR_DEBUG,        // debugger cannot run //
  AMX_ERR_INIT,         // AMX not initialized (or doubly initialized) //
  AMX_ERR_USERDATA,     // unable to set user data field (table full) //
  AMX_ERR_INIT_JIT,     // cannot initialize the JIT //
  AMX_ERR_PARAMS,       // parameter error //
  AMX_ERR_DOMAIN,       // domain error, expression result does not fit in range //
  AMX_ERR_GENERAL,      // general error (unknown or unspecific error) 
};



 */
stock list_activated_bits_in_bitsum(generic_bitsum,bool:exclude_mode=false){
	
	new count=0
	new bit_sum_to_actually_do = exclude_mode ? (~(generic_bitsum)): (generic_bitsum)
	for ( new i=0;i<32;i++)
	{	
		new bool:do_eht= bool:((bit_sum_to_actually_do & (1<<i)))
		if ( do_eht )
		{	
			count++
			server_print("The bit %d (on %d position) in this bitsum is the number: %d",count,i,(1<<i));	
		}
	}
}

//entity constants

#define PDATA_SAFE  2

#define client_is_within_range(%1) ((%1>0 && %1<=(SH_MAXSLOTS)))

#define ent_check(%1,%2) if(pev_valid(%1)!=PDATA_SAFE) return %2

#define my_attack_view(%1,%2) engfunc(EngFunc_SetView, %1, %2)

#define my_create_entity(%1) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, %1))

#define my_find_ent_by_class(%1,%2) engfunc(EngFunc_FindEntityByString, %1, "classname", %2)

#define my_remove_entity(%1) engfunc(EngFunc_RemoveEntity, %1)

#define my_get_gametime() get_gametime()

#define my_entity_set_model(%1,%2) engfunc(EngFunc_SetModel, %1, %2)

#define my_entity_set_origin(%1,%2) engfunc(EngFunc_SetOrigin, %1,%2)

/**

-> entity_set_"..."(ent, ..., ...)

entity_set_(.*)\((.*), EV_(.*)_(.*), (.*)\)
->
set_pev($2, pev_$4, $5)


//USE THESE ONES FIRST!
-> entity_get_int(ent, ..., ...)

(.*)=(.*)entity_get_int\((.*), EV_INT_(.*)\)
->
$1 = pev($3, pev_$4)


-> entity_get_float(ent, ..., ...)

(.*)=(.*)entity_get_float\((.*),(.*)EV_FL_(.*)\)
->
pev($3, pev_$5, $1)

//And then use this one


-> entity_get_...(ent, ..., ...)

entity_get_(.*)\((.*), EV_(.*)_(.*),(.*)(.*)\)
->
pev($2, pev_$4, $5)

 */