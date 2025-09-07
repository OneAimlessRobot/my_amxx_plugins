#if defined sh_lena_general_include
  #endinput
#endif
#define sh_lena_general_include

#define LENA_HUD_TASKID 15932224


stock const Model_V_Awp[] = "models/shmod/madassassin_v_awp.mdl"
stock const Model_P_Awp[] = "models/shmod/madassassin_p_awp.mdl"


#define MAX_POEM_LENGTH 4000
#define LENA_NUM_POEMS 3
stock const lena_poems[LENA_NUM_POEMS][MAX_POEM_LENGTH]={
	"Bros sabem quem é que sou quando vou internada p'hospital?^nSou a princesa mansa^nDe bata suja^nVestido braquélio,^nFantasmagórico^nResidence do palácio ^nDe luz fluorescente branca",
	"Antes a minha alma só continha mijo e merda.^nagora não contém nada.^nsinceramente não sei qual deles é pior^nAdoro o cheiro a produtos de limpeza^ne a lixivia pela manhã^nAjuda a purificar a alma,^nnão concordas?",
	"Sabes?^nUm erro categórico ^nque a malta aqui comete?^nÉ assumir que sou normal^nQue regulo bem,^nQue funciono como deve ser^nQue ainda tenho^nos fusiveis todos^nde desde que nasci",
};


native lena_get_has_lena(id)

