/*
(c) Copyright 2026, ThrashBrat

check pawn include for interface
  */

#ifndef __SH_HERO_ARRAY_H__
#define __SH_HERO_ARRAY_H__


typedef uint32_t state_cell_type_t;

#define BITS_PER_BYTE 8

#define bucket_size (sizeof(state_cell_type_t)*BITS_PER_BYTE)

#define NUM_WEAPONS (bucket_size-1) //Bucket size is equal to 32

//We currently support 640 properties

#define SH_MAX_HEROES_FINAL 1000
#define SH_MAX_HERO_PROPERTIES_FINAL 12800


//We currently support 640 client states

#define SH_MAXSLOTS 32 //FIXED!
#define SH_MAX_CLIENT_STATES_FINAL 960

//We currently support 640 types of damage

#define SH_MAX_HERO_DAMAGES_FINAL 12800

#define min(a,b) ((a < b)? a: b)
#define max(a,b) ((a > b)? a: b)

#define Get_BitVar(a,b) (a & ((state_cell_type_t)1 << (b & (bucket_size-1))))

#define Set_BitVar(a,b) (a |= ((state_cell_type_t)1 << (b & (bucket_size-1))))

#define UnSet_BitVar(a,b) (a &= ~((state_cell_type_t)1 << (b & (bucket_size-1))))


#define Assign_BitVar(a,b,c) ((c) ? Set_BitVar(a,b) : UnSet_BitVar(a,b))


class HeroArrays
{
protected:
	state_cell_type_t 
					
					//bounds
					SH_MAXHEROS,
					SH_MAX_HERO_PROPERTIES,
					SH_MAX_CLIENT_STATES,
					SH_MAX_HERO_DAMAGES,
					
					//arrays
					ownership_memory[SH_MAX_HEROES_FINAL],
					cooldown_memory[SH_MAX_HEROES_FINAL],
					the_player_masks[SH_MAX_CLIENT_STATES_FINAL],
					the_hero_projectile_weapons[SH_MAX_HEROES_FINAL];
	
	bool the_hero_flags[SH_MAX_HEROES_FINAL][SH_MAX_HERO_PROPERTIES_FINAL];
	
	bool the_hero_damage_flags[SH_MAX_HEROES_FINAL][SH_MAX_HERO_DAMAGES_FINAL];
	
	float the_hero_damage_mults[SH_MAX_HEROES_FINAL][SH_MAX_HERO_DAMAGES_FINAL];
	

public:
	HeroArrays(void);
	
	void zero_it_out( void );  
	void zero_out_hero_props(void);
	void zero_out_hero_ownership(void);
	void zero_out_player_masks(void);
	void zero_out_hero_projectile_weapon_masks(void);
	void zero_out_id_hero_cooldown_masks(void);
	void zero_out_hero_damage_flags(void);
	
	void init_hero_array_sizes(state_cell_type_t num_of_heroes_for_init,
							state_cell_type_t num_of_hero_props_to_init,
							state_cell_type_t num_of_client_states_to_init,
							state_cell_type_t num_of_hero_damages_to_init
							);
	void init_hero_array_sizes(void);
	bool get_id_has_hero( const state_cell_type_t& player_id, const state_cell_type_t& the_hero_id);  
	void set_id_has_hero( const state_cell_type_t& player_id, const state_cell_type_t& the_hero_id, const state_cell_type_t& the_value_to_set );
	
	
	bool get_id_hero_cooldown_bit( const state_cell_type_t& hero_id, const state_cell_type_t& the_player_id);  
	void set_id_hero_cooldown_bit( const state_cell_type_t& hero_id, const state_cell_type_t& the_player_id, const state_cell_type_t& the_value_to_set );
	void set_one_hero_cooldown_bits( const state_cell_type_t& hero_id, const state_cell_type_t& the_value_to_set);
	
	void set_one_client_cooldown_bit_for_all_heroes( const state_cell_type_t& the_player_id, const state_cell_type_t& the_value_to_set);
	
	
	state_cell_type_t get_max_hero_props(void);
	bool get_hero_bit( const state_cell_type_t& the_hero_id,  const state_cell_type_t& the_flag_id);
	void assign_hero_bit( const state_cell_type_t& the_hero_id, const state_cell_type_t& the_flag_id, const bool& the_polarity_to_set );
	
	state_cell_type_t get_max_hero_damage_flags(void);
	bool get_hero_damage_bit( const state_cell_type_t& the_hero_id,  const state_cell_type_t& the_damage_id);
	void assign_hero_damage_bit( const state_cell_type_t& the_hero_id, const state_cell_type_t& the_damage_id, const bool& the_polarity_to_set );
	
	float get_hero_damage_heal_mult( const state_cell_type_t& the_hero_id,  const state_cell_type_t& the_damage_id);
	void assign_hero_damage_heal_mult( const state_cell_type_t& the_hero_id, const state_cell_type_t& the_damage_id, const float& the_mult_to_set );
	
	
	
	bool get_hero_projectile_weapon_bit( const state_cell_type_t& the_hero_id,  const state_cell_type_t& the_weapon_id);
	void assign_hero_projectile_weapon_bit( const state_cell_type_t& the_hero_id, const state_cell_type_t& the_weapon_id, const state_cell_type_t& the_value_to_set );
	
	
	state_cell_type_t get_max_client_states(void);
	bool get_id_bit( const state_cell_type_t& player_id,  const state_cell_type_t& the_effect_flag_id);
	void assign_id_bit( const state_cell_type_t& player_id, const state_cell_type_t& the_effect_flag_id, const state_cell_type_t& the_polarity_to_set );


	state_cell_type_t get_max_heroes(void);
};
inline HeroArrays::HeroArrays(void){
	printf("The hero module has been initted!\n");
	this->zero_it_out();
	
}
inline void HeroArrays::init_hero_array_sizes(state_cell_type_t num_of_heroes_for_init,
											state_cell_type_t num_of_hero_props_to_init,
											state_cell_type_t num_of_client_states_to_init,
											state_cell_type_t num_of_hero_damages_to_init){
	this->SH_MAXHEROS=max(1,min(num_of_heroes_for_init,SH_MAX_HEROES_FINAL));
	if(this->SH_MAXHEROS==1){
		
		this->SH_MAXHEROS=SH_MAX_HEROES_FINAL;
	}
	if(this->SH_MAXHEROS==SH_MAX_HEROES_FINAL){
		printf("The number of heroes cannot exceed %d or be less than 0!\n"
				"The arrays have been clamped to accomodate the max ammount (%d)\n",
				SH_MAX_HEROES_FINAL,
				this->SH_MAXHEROS);
				
	}
	this->SH_MAX_HERO_PROPERTIES=max(1,min(num_of_hero_props_to_init,SH_MAX_HERO_PROPERTIES_FINAL));
	if(this->SH_MAX_HERO_PROPERTIES==1){
		
		this->SH_MAX_HERO_PROPERTIES=SH_MAX_HERO_PROPERTIES_FINAL;
	}
	if(this->SH_MAX_HERO_PROPERTIES==SH_MAX_HERO_PROPERTIES_FINAL){
		printf("The number of hero properties cannot exceed %d or be less than 0!\n"
				"The arrays have been clamped to accomodate the max ammount (%d)\n",
				SH_MAX_HERO_PROPERTIES_FINAL,
				this->SH_MAX_HERO_PROPERTIES);
				
	}
	this->SH_MAX_CLIENT_STATES=max(1,min(num_of_client_states_to_init,SH_MAX_CLIENT_STATES_FINAL));
	if(this->SH_MAX_CLIENT_STATES==1){
		
		this->SH_MAX_CLIENT_STATES=SH_MAX_CLIENT_STATES_FINAL;
	}
	if(this->SH_MAX_CLIENT_STATES==SH_MAX_CLIENT_STATES_FINAL){
		printf("The number of client states cannot exceed %d or be less than 0!\n"
				"The arrays have been clamped to accomodate the max ammount (%d)\n",
				SH_MAX_CLIENT_STATES_FINAL,
				this->SH_MAX_CLIENT_STATES);
				
	}
	this->SH_MAX_HERO_DAMAGES=max(1,min(num_of_hero_damages_to_init,SH_MAX_HERO_DAMAGES_FINAL));
	if(this->SH_MAX_HERO_DAMAGES==1){
		
		this->SH_MAX_HERO_DAMAGES=SH_MAX_HERO_DAMAGES_FINAL;
	}
	if(this->SH_MAX_HERO_DAMAGES==SH_MAX_HERO_DAMAGES_FINAL){
		printf("The number of hero damages cannot exceed %d or be less than 0!\n"
				"The arrays have been clamped to accomodate the max ammount (%d)\n",
				SH_MAX_HERO_DAMAGES_FINAL,
				this->SH_MAX_HERO_DAMAGES);
				
	}
}
inline void HeroArrays::zero_it_out(void){
		
		this->zero_out_hero_ownership();
		this->zero_out_hero_props();
		this->zero_out_player_masks();
		this->zero_out_hero_projectile_weapon_masks();
		this->zero_out_id_hero_cooldown_masks();
		this->zero_out_hero_damage_flags();
		
}

inline void HeroArrays::zero_out_hero_props(void){
	
	printf("Hero flags array have been zeroed out!\n");
	memset(this->the_hero_flags,0, sizeof(this->the_hero_flags));

}
inline void HeroArrays::zero_out_hero_damage_flags(void){
	
	printf("Hero damage flags array has been zeroed out!\n");
	memset(this->the_hero_damage_flags,0, sizeof(this->the_hero_damage_flags));
	memset(this->the_hero_damage_mults,1.0f, sizeof(this->the_hero_damage_mults));

}
inline void HeroArrays::zero_out_id_hero_cooldown_masks(void){
	
	printf("Id hero cooldown flags array has been zeroed out!\n");
	memset(this->cooldown_memory,0, sizeof(this->cooldown_memory));

}

inline void HeroArrays::zero_out_hero_projectile_weapon_masks(void){
	
	
	printf("Hero projectile weapon flags have been zeroed out!\n");
	memset(this->the_hero_projectile_weapons,0, sizeof(this->the_hero_projectile_weapons));
	
}

inline void HeroArrays::zero_out_player_masks(void){
	
	printf("The player masks have been zeroed out!\n");
	memset(this->the_player_masks,0, sizeof(this->the_player_masks));
		
}

inline void HeroArrays::zero_out_hero_ownership(void){
	
	printf("Hero array has been zeroed out!\n");
	memset(this->ownership_memory,0, sizeof(ownership_memory));
		
}

inline state_cell_type_t HeroArrays::get_max_hero_props(void){
	
	return this->SH_MAX_HERO_PROPERTIES;
}

inline state_cell_type_t HeroArrays::get_max_hero_damage_flags(void){
	
	return this->SH_MAX_HERO_DAMAGES;
}

inline state_cell_type_t HeroArrays::get_max_heroes(void){
	
	return this->SH_MAXHEROS;
}

inline bool HeroArrays::get_hero_bit( const state_cell_type_t& the_hero_id,  const state_cell_type_t& the_flag_id)
{
	if((the_hero_id >= this->SH_MAXHEROS) || (the_flag_id >= this->SH_MAX_HERO_PROPERTIES)){
		return false;
	}
	
	return this->the_hero_flags[the_hero_id][the_flag_id];
}

inline void HeroArrays::assign_hero_bit( const state_cell_type_t& the_hero_id, const state_cell_type_t& the_flag_id, const bool& the_polarity_to_set )
{
	if((the_hero_id >= this->SH_MAXHEROS) || (the_flag_id >= this->SH_MAX_HERO_PROPERTIES)){
		return;
	}
	
	this->the_hero_flags[the_hero_id][the_flag_id]=the_polarity_to_set;
}

inline bool HeroArrays::get_hero_damage_bit( const state_cell_type_t& the_hero_id,  const state_cell_type_t& the_damage_id)
{
	if((the_hero_id >= this->SH_MAXHEROS) || (the_damage_id >= this->SH_MAX_HERO_DAMAGES)){
		return false;
	}
	
	return this->the_hero_damage_flags[the_hero_id][the_damage_id];
}

inline void HeroArrays::assign_hero_damage_bit( const state_cell_type_t& the_hero_id, const state_cell_type_t& the_damage_id, const bool& the_polarity_to_set )
{
	if((the_hero_id >= this->SH_MAXHEROS) || (the_damage_id >= this->SH_MAX_HERO_DAMAGES)){
		return;
	}
	
	this->the_hero_damage_flags[the_hero_id][the_damage_id]=the_polarity_to_set;
}

inline float HeroArrays::get_hero_damage_heal_mult( const state_cell_type_t& the_hero_id,  const state_cell_type_t& the_damage_id)
{
	if((the_hero_id >= this->SH_MAXHEROS) || (the_damage_id >= this->SH_MAX_HERO_DAMAGES)){
		return false;
	}
	
	return this->the_hero_damage_mults[the_hero_id][the_damage_id];
}

inline void HeroArrays::assign_hero_damage_heal_mult( const state_cell_type_t& the_hero_id, const state_cell_type_t& the_damage_id, const float& the_mult_to_set )
{
	if((the_hero_id >= this->SH_MAXHEROS) || (the_damage_id >= this->SH_MAX_HERO_DAMAGES)){
		return;
	}
	
	this->the_hero_damage_mults[the_hero_id][the_damage_id]=the_mult_to_set;
}



//Hero ownership
inline bool HeroArrays::get_id_has_hero( const state_cell_type_t& player_id, const state_cell_type_t& the_hero_id)
{
	if((the_hero_id >= this->SH_MAXHEROS)){
		return false;
	} 
	
	if( !player_id || (player_id > SH_MAXSLOTS)){
		return false;
	
	}
	return Get_BitVar(this->ownership_memory[the_hero_id], player_id);
}

inline void HeroArrays::set_id_has_hero( const state_cell_type_t& player_id, const state_cell_type_t& the_hero_id, const state_cell_type_t& the_value_to_set )
{
	if( (the_hero_id >= this->SH_MAXHEROS)){
		return;
	}
	
	if( !player_id || (player_id > SH_MAXSLOTS)){
		return;
	
	}
	Assign_BitVar(this->ownership_memory[the_hero_id], player_id, the_value_to_set);
}

//Hero cooldown bits
inline bool HeroArrays::get_id_hero_cooldown_bit( const state_cell_type_t& hero_id, const state_cell_type_t& the_player_id)
{
	if((hero_id >= this->SH_MAXHEROS)){
		return false;
	} 
	
	if( !the_player_id || (the_player_id > SH_MAXSLOTS)){
		return false;
	
	}
	return Get_BitVar(this->cooldown_memory[hero_id], the_player_id);
}

inline void HeroArrays::set_id_hero_cooldown_bit( const state_cell_type_t& hero_id, const state_cell_type_t& the_player_id, const state_cell_type_t& the_value_to_set )
{
	if( (hero_id >= this->SH_MAXHEROS)){
		return;
	}
	
	if( !the_player_id || (the_player_id > SH_MAXSLOTS)){
		return;
	
	}
	Assign_BitVar(this->cooldown_memory[hero_id], the_player_id, the_value_to_set);
}
inline void HeroArrays::set_one_hero_cooldown_bits( const state_cell_type_t& hero_id, const state_cell_type_t& the_value_to_set)
{
	if( (hero_id >= this->SH_MAXHEROS)){
		return;
	}
	this->cooldown_memory[hero_id] = the_value_to_set?0xFFFF:0;
}

inline void HeroArrays::set_one_client_cooldown_bit_for_all_heroes( const state_cell_type_t& the_player_id, const state_cell_type_t& the_value_to_set)
{
	if( !the_player_id || (the_player_id > SH_MAXSLOTS)){
		return;
	
	}
	for ( state_cell_type_t i = 0; i < this->SH_MAXHEROS;i++){
	
		Assign_BitVar(this->cooldown_memory[i], the_player_id, the_value_to_set);
	
	}

}

	
//Hero projectile weapon state
inline bool HeroArrays::get_hero_projectile_weapon_bit( const state_cell_type_t& the_hero_id, const state_cell_type_t& the_weapon_id)
{
	if((the_hero_id >= this->SH_MAXHEROS)){
		return false;
	} 
	
	if( !the_weapon_id || (the_weapon_id > NUM_WEAPONS)){
		return false;
	
	}
	return Get_BitVar(this->the_hero_projectile_weapons[the_hero_id], the_weapon_id);
}

inline void HeroArrays::assign_hero_projectile_weapon_bit( const state_cell_type_t& the_hero_id, const state_cell_type_t& the_weapon_id, const state_cell_type_t& the_value_to_set )
{
	if( (the_hero_id >= this->SH_MAXHEROS)){
		return;
	}
	
	if( !the_weapon_id || (the_weapon_id > NUM_WEAPONS)){
		return;
	
	}
	Assign_BitVar(this->the_hero_projectile_weapons[the_hero_id], the_weapon_id, the_value_to_set);
}

//Player effect state
inline state_cell_type_t HeroArrays::get_max_client_states(void){
	
	return this->SH_MAX_CLIENT_STATES;
}

inline bool HeroArrays::get_id_bit( const state_cell_type_t& the_player_id,  const state_cell_type_t& the_effect_flag_id)
{
	
	if( !(the_player_id) || (the_player_id > SH_MAXSLOTS)|| (the_effect_flag_id >= SH_MAX_CLIENT_STATES)){
		return false;
	}
	
	
	return Get_BitVar(this->the_player_masks[the_effect_flag_id], the_player_id);
}

inline void HeroArrays::assign_id_bit( const state_cell_type_t& the_player_id, const state_cell_type_t& the_effect_flag_id, const state_cell_type_t& the_polarity_to_set )
{
	
	if( !(the_player_id) || (the_player_id > SH_MAXSLOTS)|| (the_effect_flag_id >= this->SH_MAX_CLIENT_STATES)){
		return;
	}

	Assign_BitVar(this->the_player_masks[the_effect_flag_id], the_player_id, the_polarity_to_set);
	
}

#endif
