/*
(c) Copyright 2026, ThrashBrat

check pawn include for interface
  */

#ifndef __SH_HERO_ARRAY_H__
#define __SH_HERO_ARRAY_H__

#define SH_MAXHEROS 200
#define SH_MAXSLOTS 32


#define Get_BitVar(a,b) (a & (1 << (b & 31)))
#define Set_BitVar(a,b) (a |= (1 << (b & 31)))
#define UnSet_BitVar(a,b) (a &= ~(1 << (b & 31)))


#define Assign_BitVar(a,b,c) ((c) ? Set_BitVar(a,b) : UnSet_BitVar(a,b))

class HeroArrays
{
protected:
	int32_t the_memory[SH_MAXHEROS],
			the_hero_flags[SH_MAXHEROS],
			the_player_masks[SH_MAXSLOTS+1];

public:
	HeroArrays(void);
	
	void zero_it_out( void );  
	void zero_out_hero_props(void);
	void zero_out_hero_ownership(void);
	void zero_out_player_masks(void);
	
	bool get_id_has_hero( const int32_t& id, const int32_t& the_hero_id);  
	void set_id_has_hero( const int32_t& id, const int32_t& the_hero_id, const bool& the_value_to_set );
	
	
	int32_t get_hero_flags(const int32_t& the_hero_id);
	void set_hero_flags(const int32_t& the_hero_id, const int32_t& the_flags_to_set );
	
	
	bool get_hero_bit( const int32_t& the_hero_id,  const int32_t& the_flag_id);
	void assign_hero_bit( const int32_t& the_hero_id, const int32_t& the_flag_id, const bool& the_polarity_to_set );
	
	
	bool get_id_bit( const int32_t& player_id,  const int32_t& the_effect_flag_id);
	void assign_id_bit( const int32_t& player_id, const int32_t& the_effect_flag_id, const bool& the_polarity_to_set );
	
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
	memset(this->the_hero_flags,0, sizeof(the_hero_flags));
		
}


inline void HeroArrays::zero_out_hero_ownership(void){
	
	printf("Hero array has been zeroed out!\n");
	memset(this->the_memory,0, sizeof(the_memory));
		
}

inline void HeroArrays::zero_out_player_masks(void){
	
	printf("The player masks have been zeroed out!\n");
	memset(this->the_player_masks,0, sizeof(the_player_masks));
		
}

inline int32_t HeroArrays::get_hero_flags(const int32_t& the_hero_id)
{
	if( (the_hero_id < 0) || (the_hero_id >= SH_MAXHEROS)){
		return 0;
	} 
	
	return this->the_hero_flags[the_hero_id];
}

inline void HeroArrays::set_hero_flags(const int32_t& the_hero_id, const int32_t& the_flags_to_set )
{
	if( (the_hero_id < 0) || (the_hero_id >= SH_MAXHEROS)){
		return;
	} 
	this->the_hero_flags[the_hero_id] = the_flags_to_set;
}


inline bool HeroArrays::get_hero_bit( const int32_t& the_hero_id,  const int32_t& the_flag_id)
{
	if( (the_hero_id < 0) || (the_hero_id >= SH_MAXHEROS)){
		return false;
	} 
	
	return Get_BitVar(this->the_hero_flags[the_hero_id], the_flag_id);
}

inline void HeroArrays::assign_hero_bit( const int32_t& the_hero_id, const int32_t& the_flag_id, const bool& the_polarity_to_set )
{
	if( (the_hero_id < 0) || (the_hero_id >= SH_MAXHEROS)){
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
							
	Assign_BitVar(this->the_hero_flags[the_hero_id], the_flag_id, the_polarity_to_set);
}




//Hero ownership
inline bool HeroArrays::get_id_has_hero( const int32_t& id, const int32_t& the_hero_id)
{
	if( (the_hero_id < 0) || (the_hero_id >= SH_MAXHEROS)){
		return false;
	} 
	
	return Get_BitVar(this->the_memory[the_hero_id], id);
}

inline void HeroArrays::set_id_has_hero( const int32_t& id, const int32_t& the_hero_id, const bool& the_value_to_set )
{
	if( (the_hero_id < 0) || (the_hero_id >= SH_MAXHEROS)){
		return;
	} 
	Assign_BitVar(this->the_memory[the_hero_id], id, the_value_to_set);
}


//Player effect state
inline bool HeroArrays::get_id_bit( const int32_t& the_player_id,  const int32_t& the_effect_flag_id)
{
	if( (the_player_id <= 0) || (the_player_id > SH_MAXSLOTS)){
		return false;
	} 
	
	return Get_BitVar(this->the_player_masks[the_player_id], the_effect_flag_id);
}

inline void HeroArrays::assign_id_bit( const int32_t& the_player_id, const int32_t& the_effect_flag_id, const bool& the_polarity_to_set )
{
	if( (the_player_id <= 0) || (the_player_id > SH_MAXSLOTS)){
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
							
	Assign_BitVar(this->the_player_masks[the_player_id], the_effect_flag_id, the_polarity_to_set);
}

#endif