#if defined sh_salome_general_include
  #endinput
#endif
#define sh_salome_general_include

//these kind of work as poem titles. neat!
enum poem_idx{

	emptyness_of_the_soul_with_no_ground=0,
	melancholy_of_the_confused_one,
	cynnic_conscience,
	autumn_beach,
	milkchan_mausoleum,
	attic_of_lament

}


enum poem_header_struct{

	start,
	end,
	title[50]

}
stock the_headers[_:poem_idx][poem_header_struct];

//always add:
// title followed by empty line and then--
// poem contents followed by an empty line
// where each verse of the poem is a part of the array of strings
// followed by a title
// rinse and repeat
// make sure the max poems variable matches.
// tip: use spacing to make it easier

stock salome_wordy_mass[][]={
	//poem 0
	
	"The emptyness of a soul with no ground",
	"",
	
	
	
	
	
	"Sabem quem e que sou quando vou internada p'hospital?",
	"Sou a princesa mansa",
	"De bata suja",
	"Vestido braquelio,",
	"Fantasmagorico",
	"Residence do palacio ",
	"De luz fluorescente branca",


	//poem 1


	"",
	"The melancholy of the confused one",
	"",
	
	
	
	
	
	"Antes a minha alma so continha mijo e merda.",
	"agora nao contem nada.",
	"sinceramente nao sei qual deles e pior",
	"Adoro o cheiro a produtos de limpeza",
	"e a lixivia pela manha",
	"Ajuda a purificar a alma, nao concordas?",
	
	
	//poem 2
	
	
	"",
	"Cynnic conscience",
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

	//poem 3
	"",
	"Praia de Outono",
	"",
	"Tenho saudades dos tempos em que viver não me desse a sensação",
	"de um delírio interminável.",
	"Os meus olhos fecham.",
	"Mas a luz ainda penetra.",
	"A pedra que encontrei no quintal não deixa a semente crescer",
	"E a chuva que vem é pouca.",
	"Deixa-me sentir de novo.",
	"Deixa-me rir.",
	"Que as cores vibrem com a luz que lhes irradia.",
	"Não cheiro nem o fumo de quando a casa arde",
	"e os meus ouvidos estão entupidos",
	"com espíritos de inquietação",
	"e deavínculo.",
	"Jogo às escondidas nas sombras do purgatório.",
	"Este precipício onde me situo",
	"descendo lentamente enquanto as estações passam. Ressequida da falta de toque. Da falta de tacto. Os faróis da estrada apagam-se por onde passo. A noite dura setenta e duas horas",
	"Durante as quais nem um minuto de sono arranjo para salvar a minha vida.",
	"Jesus salva-me",
	"Porque mesmo nua não sinto o frio.",
	"Debaixo de fogo não queimo. Só sinto esta dormência asfixiante que rouba o sabor daquilo que  me é oferecido por ti, senhor.",
	"Salva-me porque preciso de inspiração.",
	"Preciso do vigor que me permita completar mais da tua obra",
	"e obedecer mais da tua palavra.",
	"Agradeço por esta mente",
	"Estes dedos",
	"e esta alma de discernimento.",
	"Mas caí nas trevas faz tempo",
	"e deixei de entender o que tudo isto significa.",
	"Jesus. Dá-me a mão.",
	"Puxarei com o que tenho",
	"E continuarei o resto da minha caminhada contigo",
	"hoje e para sempre, amen",
	"",
	"Milkchan's Mausoleum",
	"",
	"Neste sítio vazio não sinto frio nem calor.",
	"Não sinto bem nem mal",
	"Aflige ou excita",
	"o vento bate do mesmo ângulo.",
	"Preencherei com pensamentos a abarrotar.",
	"^n",
	"Este lugar é onde moro.",
	"O lugar em que não existe luz nem escuridão",
	"só o nada que existe por debaixo da alma",
	"",
	"An attic full of Lament",
	"",
	"In this place we find the middle ground.",
	"The border between what is real",
	"and what has become too plausible to ignore.",
	"my synnapses burn in the morning sun.",
	"The night is soothing and quiet.",
	"But shadows hide under the objects in my kitchen",
	"I miss it when home was clad with white and marble.",
	"Other people to talk to",
	"No one around to judge me.",
	""

}

stock num_detected_poems = 0;

stock init_poem_delims(){
	new curr_line_num = 0;
	for(new i = 0; i< _:poem_idx ; i++){
		
		strcat(the_headers[i][title],salome_wordy_mass[curr_line_num],49)
		curr_line_num+=2;
		the_headers[poem_idx:i][start] = (curr_line_num)
		while(strlen(salome_wordy_mass[curr_line_num])>0){
			curr_line_num++
	
		}
		the_headers[poem_idx:i][end] = (curr_line_num-1)
		num_detected_poems++
		curr_line_num++

	}
}

stock send_poem_function( target, poem_idx:idx){
	new i=0;
	
	console_print(target,"^n^n%s^n",the_headers[_:idx][title]);

	for(i = the_headers[idx][start]; i<= the_headers[idx][end]; i++){


		
		console_print(target,"%s",salome_wordy_mass[i]);
	}
	
	
}
stock print_all_poems_debug(){

	console_print(0,"We detected %d poems!^n",num_detected_poems)

	for(new i = 0; i< num_detected_poems; i++){
		
		send_poem_function(0,poem_idx:i)
	}
}
