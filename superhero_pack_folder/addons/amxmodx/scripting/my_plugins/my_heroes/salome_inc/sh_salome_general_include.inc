#if defined sh_salome_general_include
  #endinput
#endif
#define sh_salome_general_include

#define SALOME_NUM_POEMS 3
#define SALOME_MAX_VERSES 20
#define SALOME_MAX_VERSE_LENGTH 100


//these kind of work as poem titles. neat!
enum poem_idx{

	emptyness_of_the_soul_with_no_ground=0,
	melancholy_of_the_confused_one,
	cynnic_conscience

}

stock the_starts[poem_idx]={
	0,
	8,
	15

}

stock poem_titles[poem_idx][]={

	"The emptyness of a soul with no ground",
	"The melancholy of the confused one",
	"Cynnic conscience"



}

stock salome_wordy_mass[][]={
	"Sabem quem e que sou quando vou internada p'hospital?",
	"Sou a princesa mansa",
	"De bata suja",
	"Vestido braquelio,",
	"Fantasmagorico",
	"Residence do palacio ",
	"De luz fluorescente branca",
	"",
	"Antes a minha alma so continha mijo e merda.",
	"agora nao contem nada.",
	"sinceramente nao sei qual deles e pior",
	"Adoro o cheiro a produtos de limpeza",
	"e a lixivia pela manha",
	"Ajuda a purificar a alma, nao concordas?",
	"",
	"Sabes?",
	"Um erro categorico",
	"que a malta aqui comete?",
	"E assumir que sou normal",
	"Que regulo bem,",
	"Que funciono como deve ser",
	"Que ainda tenho",
	"os fusiveis todos",
	"de desde que nasci",
	""
}


stock send_poem_function( target, poem_idx:idx){
	new i=0;
	
	console_print(target,"%s^n^n^n",poem_titles[idx]);

	while(strlen(salome_wordy_mass[i+the_starts[idx]])>0){


		
		console_print(target,"%s",salome_wordy_mass[i+the_starts[idx]]);
		i++;
	}
	
	
}
