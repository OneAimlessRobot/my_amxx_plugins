/*
(c) Copyright 2026, ThrashBrat
  */

#ifndef __SH_HERO_ARRAY_H__
#define __SH_HERO_ARRAY_H__

#define SH_MAXHEROS 200


#define Get_BitVar(a,b) (a & (1 << (b & 31)))
#define Set_BitVar(a,b) (a |= (1 << (b & 31)))
#define UnSet_BitVar(a,b) (a &= ~(1 << (b & 31)))


#define Assign_BitVar(a,b,c) ((c) ? Set_BitVar(a,b) : UnSet_BitVar(a,b))

class HeroArray
{
protected:
	int32_t the_memory[SH_MAXHEROS];

public:
	HeroArray(void);
	void zero_it_out( void );  
	bool get_id_has_hero( const int32_t& id, const int32_t& the_hero_id);  
	void set_id_has_hero( const int32_t& id, const int32_t& the_hero_id, const bool& the_value_to_set );
};
inline HeroArray::HeroArray(void){
	printf("Hero array has been initiated!\n");
	this->zero_it_out();
}
inline void HeroArray::zero_it_out(void){
	
	printf("Hero array has been zeroed out!\n");
	memset(this->the_memory,0, sizeof(the_memory));
		
}
inline bool HeroArray::get_id_has_hero( const int32_t& id, const int32_t& the_hero_id)
{
	if( (the_hero_id < 0) || (the_hero_id >= SH_MAXHEROS)){
		return false;
	} 
	
	return Get_BitVar(this->the_memory[the_hero_id], id);
}

inline void HeroArray::set_id_has_hero( const int32_t& id, const int32_t& the_hero_id, const bool& the_value_to_set )
{
	if( (the_hero_id < 0) || (the_hero_id >= SH_MAXHEROS)){
		return;
	} 
	Assign_BitVar(this->the_memory[the_hero_id], id, the_value_to_set);
}

#endif