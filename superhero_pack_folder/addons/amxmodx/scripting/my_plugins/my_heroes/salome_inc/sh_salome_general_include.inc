#if defined sh_salome_general_include
  #endinput
#endif
#define sh_salome_general_include

//these kind of work as poem titles. neat!
enum poem_idx{

	emptyness_of_the_soul_with_no_ground=0,
	melancholy_of_the_confused_one,
	cynnic_conscience

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
