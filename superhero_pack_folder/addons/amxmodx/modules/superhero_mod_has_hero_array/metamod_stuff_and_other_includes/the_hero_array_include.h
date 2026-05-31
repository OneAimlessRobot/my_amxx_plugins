/*
(c) Copyright 2026, ThrashBrat

check pawn include for interface
  */

#ifndef __SH_HERO_ARRAY_H__
#define __SH_HERO_ARRAY_H__


typedef uint32_t state_cell_type_t;


#define size_of_state_cell_bits (sizeof(state_cell_type_t)*8)

//We currently support 640 properties

#define SH_MAXHEROS 200
#define SH_MAX_HERO_PROPERTIES 1280
#define SH_HERO_PROPERTY_BUCKET_SIZE size_of_state_cell_bits
#define SH_NUM_HERO_BIT_BUCKETS (SH_MAX_HERO_PROPERTIES/SH_HERO_PROPERTY_BUCKET_SIZE)


//We currently support 640 client states

#define SH_MAXSLOTS 32
#define SH_MAX_CLIENT_STATES 960
#define SH_CLIENT_STATE_BUCKET_SIZE size_of_state_cell_bits
#define SH_NUM_CLIENT_STATE_BUCKETS (SH_MAX_CLIENT_STATES/SH_CLIENT_STATE_BUCKET_SIZE)

#define Get_BitVar(a,b) (a & (1 << (b & (size_of_state_cell_bits-1))))

#define Set_BitVar(a,b) (a |= (1 << (b & (size_of_state_cell_bits-1))))

#define UnSet_BitVar(a,b) (a &= ~(1 << (b & (size_of_state_cell_bits-1))))


#define Assign_BitVar(a,b,c) ((c) ? Set_BitVar(a,b) : UnSet_BitVar(a,b))


class HeroArrays
{
protected:
	int32_t the_memory[SH_MAXHEROS],
			the_hero_flags[SH_MAXHEROS][SH_NUM_HERO_BIT_BUCKETS],
			the_player_masks[SH_MAXSLOTS+1][SH_NUM_CLIENT_STATE_BUCKETS];

public:
	HeroArrays(void);
	
	void zero_it_out( void );  
	void zero_out_hero_props(void);
	void zero_out_hero_ownership(void);
	void zero_out_player_masks(void);
	
	bool get_id_has_hero( const state_cell_type_t& id, const state_cell_type_t& the_hero_id);  
	void set_id_has_hero( const state_cell_type_t& id, const state_cell_type_t& the_hero_id, const bool& the_value_to_set );
	
	
	uint32_t get_max_hero_props(void);
	bool get_hero_bit( const state_cell_type_t& the_hero_id,  const state_cell_type_t& the_flag_id);
	void assign_hero_bit( const state_cell_type_t& the_hero_id, const state_cell_type_t& the_flag_id, const bool& the_polarity_to_set );
	
	
	uint32_t get_max_client_states(void);
	bool get_id_bit( const state_cell_type_t& player_id,  const state_cell_type_t& the_effect_flag_id);
	void assign_id_bit( const state_cell_type_t& player_id, const state_cell_type_t& the_effect_flag_id, const bool& the_polarity_to_set );
	
	
};
inline HeroArrays::HeroArrays(void){
	printf("The hero module has been initted!\n");
	this->zero_it_out();
}

inline void HeroArrays::zero_it_out(void){
		
		this->zero_out_hero_ownership();
		this->zero_out_hero_props();
		this->zero_out_player_masks();
		
}

inline void HeroArrays::zero_out_hero_props(void){
	
	printf("Hero flags array have been zeroed out!\n");
	for(int i=0;i< SH_MAXHEROS;i++){
		memset(&this->the_hero_flags[i],0, sizeof(this->the_hero_flags[i]));
	}
}


inline void HeroArrays::zero_out_player_masks(void){
	
	printf("The player masks have been zeroed out!\n");
	for(int i=0;i< SH_MAXSLOTS+1;i++){
		memset(&this->the_player_masks[i],0, sizeof(this->the_player_masks[i]));
	}
		
}


inline void HeroArrays::zero_out_hero_ownership(void){
	
	printf("Hero array has been zeroed out!\n");
	memset(this->the_memory,0, sizeof(the_memory));
		
}


/**
	//We currently support 1280 hero properties
	
	and 200 heroes in total!
	
	#define SH_MAXHEROS 200
	#define SH_MAX_HERO_PROPERTIES 1280
	#define SH_HERO_PROPERTY_BUCKET_SIZE size_of_state_cell_bits
	#define SH_NUM_HERO_BIT_BUCKETS (SH_MAX_HERO_PROPERTIES/SH_HERO_PROPERTY_BUCKET_SIZE)
	
*/
inline uint32_t HeroArrays::get_max_hero_props(void){
	
	return SH_MAX_HERO_PROPERTIES;
}

inline bool HeroArrays::get_hero_bit( const state_cell_type_t& the_hero_id,  const state_cell_type_t& the_flag_id)
{
	if( (the_hero_id < 0) || (the_hero_id >= SH_MAXHEROS) ||
			(the_flag_id < 0) || (the_flag_id >= SH_MAX_HERO_PROPERTIES)){
		return false;
	}
	int word = (the_flag_id / SH_HERO_PROPERTY_BUCKET_SIZE),
		bit = (the_flag_id & (SH_HERO_PROPERTY_BUCKET_SIZE-1));
	
	return Get_BitVar(this->the_hero_flags[the_hero_id][word], bit);
}

inline void HeroArrays::assign_hero_bit( const state_cell_type_t& the_hero_id, const state_cell_type_t& the_flag_id, const bool& the_polarity_to_set )
{
	if( (the_hero_id < 0) || (the_hero_id >= SH_MAXHEROS) ||
			(the_flag_id < 0) || (the_flag_id >= SH_MAX_HERO_PROPERTIES)){
		return;
	}
	/*
	printf("Someone is trying to assign\n"
				"%s polarity\n"
				"to property %d\n"
				"in hero %d!\n",
				the_polarity_to_set?"Positive":"Negative",
				the_flag_id,
				the_hero_id);*/
	
	int word = (the_flag_id / SH_HERO_PROPERTY_BUCKET_SIZE),
		bit = (the_flag_id & (SH_HERO_PROPERTY_BUCKET_SIZE-1));
	
	Assign_BitVar(this->the_hero_flags[the_hero_id][word], bit, the_polarity_to_set);
}




//Hero ownership
inline bool HeroArrays::get_id_has_hero( const state_cell_type_t& id, const state_cell_type_t& the_hero_id)
{
	if( (the_hero_id < 0) || (the_hero_id >= SH_MAXHEROS)){
		return false;
	} 
	
	if( (id <= 0) || (id > SH_MAXSLOTS)){
		return false;
	
	}
	return Get_BitVar(this->the_memory[the_hero_id], id);
}

inline void HeroArrays::set_id_has_hero( const state_cell_type_t& id, const state_cell_type_t& the_hero_id, const bool& the_value_to_set )
{
	if( (the_hero_id < 0) || (the_hero_id >= SH_MAXHEROS)){
		return;
	}
	
	if( (id <= 0) || (id > SH_MAXSLOTS)){
		return;
	
	}
	Assign_BitVar(this->the_memory[the_hero_id], id, the_value_to_set);
}


//Player effect state
/**
	//We currently support 640 client states
	
	and 32 players in total!
	
	#define SH_MAXSLOTS 32
	#define SH_MAX_CLIENT_STATES 960
	#define SH_CLIENT_STATE_BUCKET_SIZE size_of_state_cell_bits
	#define SH_NUM_CLIENT_STATE_BUCKETS (SH_MAX_CLIENT_STATES/SH_CLIENT_STATE_BUCKET_SIZE)

*/

inline uint32_t HeroArrays::get_max_client_states(void){
	
	return SH_MAX_CLIENT_STATES;
}

inline bool HeroArrays::get_id_bit( const state_cell_type_t& the_player_id,  const state_cell_type_t& the_effect_flag_id)
{
	
	if( (the_player_id <= 0) || (the_player_id > SH_MAXSLOTS)||
			(the_effect_flag_id < 0) || (the_effect_flag_id >= SH_MAX_CLIENT_STATES)){
		return false;
	}
	
	int word = (the_effect_flag_id / SH_CLIENT_STATE_BUCKET_SIZE),
		bit = (the_effect_flag_id & (SH_CLIENT_STATE_BUCKET_SIZE-1));
	
	return Get_BitVar(this->the_player_masks[the_player_id][word], bit);
}

inline void HeroArrays::assign_id_bit( const state_cell_type_t& the_player_id, const state_cell_type_t& the_effect_flag_id, const bool& the_polarity_to_set )
{
	
	if( (the_player_id <= 0) || (the_player_id > SH_MAXSLOTS)||
			(the_effect_flag_id < 0) || (the_effect_flag_id >= SH_MAX_CLIENT_STATES)){
		return;
	}
	
	int word = (the_effect_flag_id / SH_CLIENT_STATE_BUCKET_SIZE),
		bit = (the_effect_flag_id & (SH_CLIENT_STATE_BUCKET_SIZE-1));
	
	Assign_BitVar(this->the_player_masks[the_player_id][word], bit, the_polarity_to_set);
	
}

#endif