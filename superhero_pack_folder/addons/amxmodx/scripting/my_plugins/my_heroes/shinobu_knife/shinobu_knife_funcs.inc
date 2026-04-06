#if defined sh_shinobu_knife_funcs
  #endinput
#endif
#define sh_shinobu_knife_funcs


#define SHINOBU_DEFAULT_TELE_DIST 50.0

enum shinobu_happy_sentence_id{

    ARA_ARA=0,
    MI_MI_MI,
    I_COULDNT_CATCH_THAT,
    DID_IT_HELP,
    OOPS,
    MAX_SHINOBU_HAPPY_SENTENCES
}


stock const happy_sentences[MAX_SHINOBU_HAPPY_SENTENCES][]={

    "Ara ara~ Enjoy the nap ^^-^^",
    "Hmm? What was that? ^"Mi Mi Mi^"?",
    "Ops, Im sorry! Can you repeat from earlier?",
    "Oooh... You were feeling sick earlier. Are you feeling better?",
    "I SHANKED EM DEMON GUTS NOW I SMELL BAD ^^-^^"

}

enum shinobu_fwend_sentence_id{

    AI_AI_AI=0,
    HEEEEEY,
    AM_I_INTERRUPTING,
    MAX_SHINOBU_FWEND_SENTENCES
}


stock const fwend_sentences[MAX_SHINOBU_FWEND_SENTENCES][]={

    "Ai, Ai, Ai~",
    "heeeeeey~",
    "Am I interrupting something?~"

}

enum shinobu_shinobu_shinobu_shinobu_dickery_sentences_id{

    TUMMY_HURT=0,
    I_TAKE_IT_AS_A_SUPPLEMENT,
    FONKY_MEDICINE,
    PARSING_TOMFOOLERY_FILES,
    MAX_DICKERY


}

stock const shinobu_shinobu_shinobu_shinobu_dickery_sentences[MAX_DICKERY][]={

    "Awww, does tummy hurt?",
    "I drink this stuff daily~ Is it really that bad?",
    "Its not hurting... Its a cure~",
    "Parsing tomfoolery files~"

}

enum shinobu_visiting_sentences_id{

    MAKE_THEM_FEEL_AT_HOME=0,
    THEY_LOOK_LONELY,
    MAX_SHINOBU_VISITING_SENTENCES


}


stock const shinobu_visiting_sentences[MAX_SHINOBU_VISITING_SENTENCES][]={

    "Lets go make them feel at home",
    "I wonder if they feel lonely..."

}



native nani_behind_player(tele_player,tg_player,Float: distance_tele_tg=SHINOBU_DEFAULT_TELE_DIST)
native manual_cloak_check(id)
native uncloak_shinobu(id)