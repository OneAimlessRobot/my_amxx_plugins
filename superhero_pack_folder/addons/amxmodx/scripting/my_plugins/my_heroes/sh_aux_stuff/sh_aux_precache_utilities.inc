#if defined sh_aux_precache_utilities
  #endinput
#endif
#define sh_aux_precache_utilities

/*



	strings should be terminated by a null string always.
	It will output how many of what came before it.

	name of resource is used in printing
	as well as resource categorization.

	Debug tells the function whether or not we should print


*/
stock count_null_terminated_string_array(const strings[][],
														const name_of_resource[],
														const resource_categorization[],
														const debug_val){
	static i = 0,
		result = 0

	i = 0
	result = 0
	while(strings[result][0]!=0){

		result++
	}
	if(debug_val){

		server_print("%d %s were counted! They are:^n^n",result,name_of_resource)
		i=0
		while(strings[i][0]!=0){
			
			server_print("%s number %d (index %d): %s^n",resource_categorization,i+1,i,strings[i])
			i++
		}
	}
	
	return result
}

/*


	enum stuff_to_precache{

		PRECACHE_SOUNDS = EngFunc_PrecacheSound,
		PRECACHE_MODELS = EngFunc_PrecacheModel,
		PRECACHE_GENERIC = EngFunc_PrecacheGeneric



	}

	strings should be terminated by a null string always.
	It will not count anything
	it will just precache


*/
enum stuff_to_precache{

	PRECACHE_SOUNDS = EngFunc_PrecacheSound,
	PRECACHE_MODELS = EngFunc_PrecacheModel,
	PRECACHE_GENERIC = EngFunc_PrecacheGeneric



}
/*


	enum stuff_to_precache{

		PRECACHE_SOUNDS = EngFunc_PrecacheSound,
		PRECACHE_MODELS = EngFunc_PrecacheModel,
		PRECACHE_GENERIC = EngFunc_PrecacheGeneric



	}

	strings should be terminated by a null string always.
	It will not count anything
	it will just precache


*/
stock precache_null_terminated_resource_list(const resources[][],
													stuff_to_precache:precached_stuff_val, const debug_val){

	static i = 0,
			type_of_resource[128],
			full_string[128]

	

	i = 0
	while(resources[i][0]!=0){
		
		engfunc(_:precached_stuff_val, resources[i]);
		i++
		if(debug_val){

			arrayset(type_of_resource,0,charsmax(type_of_resource))
			arrayset(full_string,0,charsmax(full_string))

			switch(precached_stuff_val){
				
				case PRECACHE_SOUNDS:{

					formatex(type_of_resource,charsmax(type_of_resource),"%s","Sound")
					
				}
				case PRECACHE_MODELS:{
					
					formatex(type_of_resource,charsmax(type_of_resource),"%s","Model")

				}
				case PRECACHE_GENERIC:{

					formatex(type_of_resource,charsmax(type_of_resource),"%s","Generic")
				}
			}
			
			formatex(full_string,charsmax(full_string),"We just precached a %s named %s!",type_of_resource, resources[i-1])
			server_print("%s^n",full_string)
		}
	}

}