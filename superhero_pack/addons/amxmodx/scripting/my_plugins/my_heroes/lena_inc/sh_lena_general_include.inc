#if defined sh_lena_general_include
  #endinput
#endif
#define sh_lena_general_include

#define LENA_HUD_TASKID 15932224


stock const Model_V_Awp[] = "models/shmod/madassassin_v_awp.mdl"
stock const Model_P_Awp[] = "models/shmod/madassassin_p_awp.mdl"


#define MAX_POEM_LENGTH 4000
#define CHUNK_SIZE 129
#define LENA_NUM_POEMS 3
stock const lena_poems[LENA_NUM_POEMS][MAX_POEM_LENGTH]={
	"Bros sabem quem e que sou quando vou internada p'hospital?^nSou a princesa mansa^nDe bata suja^nVestido braquelio,^nFantasmagorico^nResidence do palacio ^nDe luz fluorescente branca^n",
	"Antes a minha alma so continha mijo e merda.^nagora nao contem nada.^nsinceramente nao sei qual deles e pior^nAdoro o cheiro a produtos de limpeza^ne a lixivia pela manha^nAjuda a purificar a alma,^nnao concordas?^n",
	"Sabes?^nUm erro categorico ^nque a malta aqui comete?^nE assumir que sou normal^nQue regulo bem,^nQue funciono como deve ser^nQue ainda tenho^nos fusiveis todos^nde desde que nasci^n",
};


native lena_get_has_lena(id)


stock send_poem_function(id, target, poem[MAX_POEM_LENGTH]){
	
	new total=1;
	new curr_char=0;
	new printed=0;
	new num_sends=0;
	new buff[2*CHUNK_SIZE+1];
	for(;total<MAX_POEM_LENGTH;total+=printed,curr_char+=printed){
		arrayset(buff,0,sizeof buff)
		strcat(buff,poem[curr_char],min(MAX_POEM_LENGTH-total,(sizeof buff)-1))
		printed=console_print(target,"%s",buff);
		if(!strlen(buff)){
			
			return
		}
	}
	
	
}