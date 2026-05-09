


#define NUM_YANDERE_PAIN_SOUNDS 3
stock const yandere_pain_sounds[NUM_YANDERE_PAIN_SOUNDS][128]={
	"shmod/yandere/Yakui_the_maid-bodies_everywhere.wav",
	"shmod/yandere/Yakui_the_maid-46.wav",
	"shmod/yandere/Yakui_the_maid-Chloramine.wav"
	
	
}
#define PSYCHOSIS_PERIOD 1.0
#define PSYCHOSIS_TIMES floatround(floatdiv(psychosis_time,PSYCHOSIS_PERIOD))

stock gIsPsychosisMask
stock g_yandere_leaped_mask

stock Float:gPsychosisTime[SH_MAXSLOTS+1]

stock MsgSetFOV



native bool:yandere_get_user_is_psychosis(id);
native yandere_psychosis_user(id);
native yandere_unpsychosis_user(id);

