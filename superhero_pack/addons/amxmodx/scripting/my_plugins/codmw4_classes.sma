#include "../include/nvault.inc"
#include "../include/amxmod.inc"
#include "../include/amxmodx.inc"
#include "../include/amxmisc.inc"
#include "../include/hamsandwich.inc"
#include "../include/fakemeta.inc"
#include "../include/fakemeta_util.inc"
#include "../include/colorchat.inc"
#include "../include/engine.inc"
#include "../include/fun.inc"
#include "../include/csx.inc"
#include "../include/cstrike.inc"
#include "../include/Vexd_Utilities.inc"
#include "my_include/codmw4_classes.inc"
#include "my_include/codmw4_classenum.inc"

#define PLUGIN "Call of Duty: MW4 Mod classes"
#define VERSION "1.0.0"
#define AUTHOR "Me"
#define Struct				enum


new const energija_klasa[] = 
{  	// HP Klase
0,	// Nema
120,	// Snajperista
140,	// Marinac
75,      // UltraMarinac
130,	// Pro-Strelac
120,	// Mitraljezac
110,	// Doktor
100,	// Vatrena Podrska
100,	// Miner
110,	// Demolitions
100,	// Rusher
130,	// Rambo
120,	// Revolveras
110,	// Bombarder
120,	// Strelac
70,	// Informator
110,	// Pukovnik
150,	// Pobunjenik
110,	// Serijski ubica
120,	// Desetar
110,	// Vodnik
120,	// Kamikaza
100,	// Assassin
170,     // Gazija
150,     // ProSWAT
100,	// Major
100,	// Kapetan
100,	// Potpukovnik
120,	// Marsal
120,	// Nemacki strelac
130,	// Ruski pukovnik
100,	// Poljska pesadija
110,	// Mornar
150,	// Napadac
100,	// Legija
160,	// Armageddon
100,	// Samuraj
150,	// Ratko Mladic
150,	// SWAT
100,	// Partizan
125,	// Gunner
100,	// Cleric
130,	// General
140,	// Terminator
80,	// Slayer
110,	// Zastavnik
125,	// Admiral
150,	// Fighter
120,	// Policajac
110,	// Specijalac
100,	// Predator
105,	// NemackiOficir
124,	// Cetnik
130,	// ProfVojnik
80,	// Crysis
105,	// ProfStrelac
150,      // Komandos
50,
100,
120,
100,
150,
120,
150,
100,       //Zmaj
150,
200,
200,       //ProAssasssin
100,        //Soap
100,         //Google
100,        //Hulk
150,
450,
700,

};
new const Float:brzina_klase[] = 
{	//Brzina Klase
0.0,	// None
1.3,	// Snajperista
1.35,	// Marinac
2.5,    // UltraMarinac
1.0,	// Pro-Strelac
0.8,	// Mitraljezac
1.5,	// Doktor
1.2,	// Vatrena Podrska
1.1,	// Miner
1.1,	// Demolitions
1.3,	// Rusher
1.2,	// Rambo
1.1,	// Revolveras
1.1,	// Bombarder
1.0,	// Strelac
1.6,	// Informator
1.1,	// Pukovnik
1.4,	// Pobunjenik
1.0,	// Serijski ubica
1.0,	// Desetar
1.1,	// Vodnik
1.0,	// Kamikaza
1.4,	// Assassin
1.6,     // Gazija
0.8,     // ProSWAT
1.2,	// Major
1.0,	// Kapetan
1.6,	// Potpukovnik
1.1,	// Marsal
1.0,	// Nemacki strelac
1.0,	// Ruski pukovnik
1.2,	// Poljska pesadija
0.7,	// Mornar
1.2,	// Napadac
1.0,	// Legija
1.0,	// Armageddon
1.4,	// Samuraj
1.4,	// Ratko Mladic
1.3,	// SWAT
1.3,	// Partizan
1.0,	// Gunner
1.2,	// Cleric
1.2,	// General
1.4,	// Terminator
1.6,	// Slayer
1.4,	// Zastavnik
1.1,	// Admiral
1.4,	// Fighter
1.2,	// Policajac
1.8,	// Specijalac
1.3,	// Predator
1.0,	// NemackiOficir
1.2,	// Cetnik
1.6,	// ProfVojnik
1.8,	// Crysis
1.0,	// ProfStrelac
1.2,      // Komandos
1.0,
1.0,
1.2,
1.0,
0.7,
1.4,
1.0,
1.0,         //Zmaj
1.0,
2.6,
1.5,             //ProAssassin
1.0,          //soap
1.0,           //google
1.0,            //Hulk
3.0,
5.0,
3.0,
};
new const oklop_klase[] = 
{    	// Pancir Klasa
0,       //None
100,     //Snajperista
100,     //Marinac
200,     //UltraMarinac
100,     //Pro-Strelac
40,      //Mitraljezac
0,       //Doktor
0,       //Vatrena Podrska
0,       //Miner
100,     //Demolitions
40,      //Rusher
0,       //Rambo
0,       //Revolveras
100,     //Bombarder
40,      //Strelac
0,       //Informator
0,       //Pukovnik
150,     //Pobunjenik
90,      //Serijski ubica
0,       //Desetar
200,     //Vodnik
0,       //Kamikaza
100,     //Assassin
0,       //Gazija
200,     //ProSWAT
0,       //Major
0,       //Kapetan
200,     //Potpukovnik
0,       //Marsal
100,     //Nemacki strelac
0,       //Ruski pukovnik
0,       //Poljska pesadija
100,     //Mornar
0,       //Napadac
0,       //Legija
120,     //Armageddon
0,       //Samuraj
150,     //Ratko Mladic
110,     //SWAT
100,     //Partizan
100,     //Gunner
150,     //Cleric
120,     //General
50,      //Terminator
120,     //Slayer
300,     //Zastavnik
70,      //Admiral
100,     //Fighter
50,      //Policajac
0,       //Specijalac
25,      //Predator
80,      //NemackiOficir
100,     //Cetnik
90,      //ProfVojnik
10,      //Crysis
45,      //ProfStrelac
100,      // Komandos
0,
105,
125,
100,
150,
100,
150,
100,         //Zmaj
500,
200,
150,        //Proassassin
100,         //soap
100,         //google
100,           //Hulk
300,
240,
15,
};		
new const naziv_klase[][] = 
{
"None",					//  0
"Snipers",		// 1
"Marine",		// 2
"UltraMarine",           // 3
"Pro-Shooter",		// 4
"Gunner",		// 5
"Doctor",		// 6
"Fire support",	// 7
"Miner",		// 8
"Demolitions",		// 9
"Rusher",		// 10
"Rambo",		// 11
"Gunman",		// 12
"Bomber",		// 13
"Sagittarius",		// 14
"Informer",		// 15
"Colonel",		// 16
"Rebal",		// 17
"Serial killer",	// 18
"Corporal",		// 19
"Sergeant",		// 20
"Kamikaze",		// 21
"Assassin",		// 22
"Gazija",
"ProSWAT",
"Major",		// 23
"Captain",		// 24
"Lieutenant Colonel",		// 25
"Marshal",		// 26
"German Shooter",	// 27
"Russian colonel",	// 28
"Poland infantry",	// 29
"Sailor",		// 30
"Attacker ",		// 31
"Legion",		// 32
"Armageddon",		// 33
"Samurai",		// 34
"Ratko Mladic",		// 35
"SWAT",			// 36
"Partisan",		// 37
"Gunner",		// 38
"Cleric",		// 39
"General",		// 40
"Terminator",		// 41
"Slayer",		// 42
"Sergeant major",		// 43
"Admiral",		// 44
"Fighter",		// 45
"Policeman",		// 46
"Sapper",		// 47
"Predator",		// 48
"German Officer",	// 49
"Chetnik",		// 50
"Professional Soldie",	// 51
"Crysis",		// 52
"Professional Sagittarius",// 53
"Commando",               // 54
"Ghost",
"JSO",                     // 55
"Pro Miner",              // 56
"Mercenary",               // 57
"Bazooka Soldier",       // 58
"Price",
"Camper",
"Dragon",
"Tokelian",
"Ninja",
"ProAssassin",
"Soap",
"Google",
"Hulk",
"Shredder",
"Graciete",
"ThrashThrush",
};
enum { NONE = 0,  o,  p, s, pr, sk}


new const pripada[] = 
{
NONE, 		// Nema		        //  0
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
p,
p,
p,
p,
o,
o,
o,
o,
o,
o,
o,
o,
o,
p,
o,
p,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
o,
s,
s,
o,
o,
o,
o,
s,
s,
s,
s,
s,
pr,
pr,
sk,
sk,
s,
pr,
o,
};


new const novi_opis[][] = 
{
"\rWeapon : \d Nema ^n\rEnergija : \d 0 HP^n\rPancir:\d 0 AP^nBrzina:\d 0 %",					
"\rWeapon:\y AWP, Deagle i Scout                     ^n\rHitPoints:\y 120HP   ^n\rArmor:\y 100AP             \r^nSpeed:\y 110%      \r^nSpecial powers:\y 60% chance of instant killing knife",                     // 1
"\rWeapon:\y Deagle                                  ^n\rHitPoints:\y 140HP   ^n\rArmor:\y 100AP             \r^nSpeed:\y 135%      \r^nSpecial powers:\y Instant kill with a knife, Double jump",                                     // 2
"\rWeapon:\y USP                                     ^n\rHitPoints:\y 75HP   ^n\rArmor:\y 200AP             \r^nSpeed:\y 250%      \r^nSpecial powers:\y Instant kill with a knife, Double jump, Slighty Transparent",                                     // 2
"\rWeapon:\y AK47, M4A1                              ^n\rHitPoints:\y 110HP   ^n\rArmor:\y 100AP             \r^nSpeed:\y 80%       \r^nSpecial powers:\y Reduced recoil guns",                                 // 3
"\rWeapon:\y Dobija M249                             ^n\rHitPoints:\y 120HP   ^n\rArmor:\y 150AP             \r^nSpeed:\y 80%       \r^nSpecial powers:\y Resistant to mine, has all the bombs",                         // 4
"\rWeapon:\y UMP45                                   ^n\rHitPoints:\y 110HP   ^n\rArmor:\y 100AP             \r^nSpeed:\y 150%      \r^nSpecial powers:\y First aid kit",                                  // 5
"\rWeapon:\y MP5, HE grenade                         ^n\rHitPoints:\y 100HP   ^n\rArmor:\y 100AP             \r^nSpeed:\y 120%      \r^nSpecial powers:\y 2 rockets",                                               // 6
"\rWeapon:\y P90                                     ^n\rHitPoints:\y 100HP   ^n\rArmor:\y 100AP             \r^nSpeed:\y 110%      \r^nSpecial powers:\y 10 mine",                                                        // 7
"\rWeapon:\y Aug, sve bombe                          ^n\rHitPoints:\y 110HP   ^n\rArmor:\y 100AP             \r^nSpeed:\y 110%      \r^nSpecial powers:\y Dynamite that kills everything within 1m",                   // 8
"\rWeapon:\y M3                                      ^n\rHitPoints:\y 100HP   ^n\rArmor:\y 100AP             \r^nSpeed:\y 130%      \r^nSpecial powers:\y None",                                                   // 9
"\rWeapon:\y Famas                                  ^n\rHitPoints:\y 130HP   ^n\rArmor:\y 150AP             \r^nSpeed:\y 120%      \r^nSpecial powers:\y For every murder + 20hp and full barrel, magazine, double jump",       // 10
"\rWeapon:\y Elites                                    ^n\rHitPoints:\y 120HP   ^n\rArmor:\y 0AP               \r^nSpeed:\y 110%      \r^nSpecial powers:\y 1 rocket",                                               // 11
"\\rWeapon:\y M4A1, Deagle                            ^n\rHitPoints:\y 140HP   ^n\rArmor:\y 100AP             \r^nSpeed:\y 90%%      \r^nSpecial powers:\y None",                                                   // 12
"\rWeapon:\y XM1014, Elites                            ^n\rHitPoints:\y 120HP   ^n\rArmor:\y 40AP              \r^nSpeed:\y 100%      \r^nSpecial powers:\y None",                                                   // 13
"\rWeapon:\y MP5                                       ^n\rHitPoints:\y 70HP    ^n\rArmor:\y 0AP               \r^nSpeed:\y 160%      \r^nSpecial powers:\y None",                                                   // 14
"\rWeapon:\y Famas, Deagle                             ^n\rHitPoints:\y 110HP   ^n\rArmor:\y 0AP               \r^nSpeed:\y 110%      \r^nSpecial powers:\y 2 mine",                                                 // 15
"\\rWeapon:\y SG552, HE ,Smoke grenade                ^n\rHitPoints:\y 100HP   ^n\rArmor:\y 150AP             \r^nSpeed:\y 140%      \r^nSpecial powers:\y 1 minu",                                                 // 16
"\rWeapon:\y M4A1                                      ^n\rHitPoints:\y 110HP   ^n\rArmor:\y 100AP             \r^nSpeed:\y 100%      \r^nSpecial powers:\y None",                                                   // 17
"\rWeapon:\y Scout(zadaje 10% vise stete), Deagle      ^n\rHitPoints:\y 120HP   ^n\rArmor:\y 40AP              \r^nSpeed:\y 100%      \r^nSpecial powers:\y None",                                                   // 18
"\rWeapon:\y M3                                        ^n\rHitPoints:\y 110HP   ^n\rArmor:\y 0AP               \r^nSpeed:\y 110%      \r^nSpecial powers:\y None",                                                   // 19
"\rWeapon:\y M4A1                                      ^n\rHitPoints:\y 120HP   ^n\rArmor:\y 0AP               \r^nSpeed:\y 100%      \r^nSpecial powers:\y 2 rockets",                                           // 20
"\rWeapon:\y Deagle                                 ^n\rHitPoints:\y 100HP    ^n\rArmor:\y 0AP               \r^nSpeed:\y 200%      \r^nSpecial powers:\y It's invisible, and instant kill knife",                                           // 21
"\rWeapon:\y Deagle                                 ^n\rHitPoints:\y 120 HP^n\rArmor:\y 100 AP^n\rSpeed:\y 140%^n\rSpecial powers: Invisibile with DEAGLE, 1/3 with DEAGLE",
"\rWeapon:\y M4A1,USP                                 ^n\rHitPoints:\y 150 HP^n\rArmor:\y 200 AP^n\rSpeed:\y 80%^n\rSpecial powers:Immune to insta with knife, 1/7 with M4,2 rockets",
"\rWeapon:\y Svi pistolji                           ^n\rHitPoints:\y 90HP    ^n\rArmor:\y 0AP               \r^nSpeed:\y 110%      \r^nSpecial powers:\y 10 mines",                                            // 22
"\rWeapon:\y Aug                                       ^n\rHitPoints:\y 100HP   ^n\rArmor:\y 0AP               \r^nSpeed:\y 100%      \r^nSpecial powers:\y None",                                                   // 23
"\rWeapon:\y AWP, Deagle                               ^n\rHitPoints:\y 100HP   ^n\rArmor:\y 200AP             \r^nSpeed:\y 100%      \r^nSpecial powers:\y Less visible",                                       // 24
"\rWeapon:\y Deagle                                    ^n\rHitPoints:\y 120HP   ^n\rArmor:\y 0AP               \r^nSpeed:\y 120%      \r^nSpecial powers:\y None",                                                   // 25
"\rWeapon:\y Ak47                                      ^n\rHitPoints:\y 90HP    ^n\rArmor:\y 100AP             \r^nSpeed:\y 120%      \r^nSpecial powers:\y 2 rockets",                                               // 26
"\rWeapon:\y M4A1                                      ^n\rHitPoints:\y 130HP   ^n\rArmor:\y 0AP               \r^nSpeed:\y 70%       \r^nSpecial powers:\y 1 minu",                                                 // 27
"\rWeapon:\y MP5                                       ^n\rHitPoints:\y 100HP   ^n\rArmor:\y 0AP               \r^nSpeed:\y 100%      \r^nSpecial powers:\y 2 dynamite",                                             // 28
"\rWeapon:\y Mac10                                     ^n\rHitPoints:\y 110HP   ^n\rArmor:\y 100AP             \r^nSpeed:\y 100%      \r^nSpecial powers:\y 50% gravity and 2 mines",                           // 29
"\rWeapon:\y Famas, P90                                ^n\rHitPoints:\y 150HP   ^n\rArmor:\y 0AP               \r^nSpeed:\y 250%      \r^nSpecial powers:\y Reduced Gravity",                                   // 30
"\rWeapon:\y M4A1, Deagle                              ^n\rHitPoints:\y 100HP   ^n\rArmor:\y 0AP               \r^nSpeed:\y 100%      \r^nSpecial powers:\y None",                                                   // 31
"\rWeapon:\y AK47, AUG, HE                          ^n\rHitPoints:\y 160HP   ^n\rArmor:\y 120AP             \r^nSpeed:\y 140%      \r^nSpecial powers:\y Less visible and two dynamite",                          // 32
"\rWeapon:\y Usp                                       ^n\rHitPoints:\y 100HP   ^n\rArmor:\y 0AP               \r^nSpeed:\y 120%      \r^nSpecial powers:\y None",                                                   // 33
"\rWeapon:\y M4A1, AK47           ^n\rHitPoints:\y 140HP   ^n\rArmor:\y 150AP             \r^nSpeed:\y 130%      \r^nSpecial powers:\y Double jump and 5 rocket",                                  // 34
"\rWeapon:\y M4A1, USP                               ^n\rHitPoints:\y 150HP   ^n\rArmor:\y 110AP             \r^nSpeed:\y 130%      \r^nSpecial powers:\y None",                                                   // 35
"\rWeapon:\y P90, Flash grenade                      ^n\rHitPoints:\y 100HP   ^n\rArmor:\y 100AP             \r^nSpeed:\y 100%      \r^nSpecial powers:\y Less visible",                                       // 36
"\rWeapon:\y G3SG1, Deagle, HE grenade              ^n\rHitPoints:\y 125HP   ^n\rArmor:\y 100AP             \r^nSpeed:\y 120%      \r^nSpecial powers:\y 1 rocket",                                               // 37
"\rWeapon:\y AK47, Elites                            ^n\rHitPoints:\y 100HP   ^n\rArmor:\y 50AP              \r^nSpeed:\y 120%      \r^nSpecial powers:\y 3 mine",                                                 // 38
"\rWeapon:\y M4A1,P90                               ^n\rHitPoints:\y 130HP   ^n\rArmor:\y 120AP             \r^nSpeed:\y 140%      \r^nSpecial powers:\y Camouflage, 10% chance for instant murder DGL-TV",         // 39
"\rWeapon:\y AK47+Deagle                            ^n\rHitPoints:\y 140HP   ^n\rArmor:\y 50AP              \r^nSpeed:\y 120%      \r^nSpecial powers:\y None",                                                   // 40
"\rWeapon:\y Famas, P90                             ^n\rHitPoints:\y 110HP   ^n\rArmor:\y 120AP             \r^nSpeed:\y 140%      \r^nSpecial powers:\y 3 rockets",                                               // 41
"\rWeapon:\y M4A1, P90, Deagle                         ^n\rHitPoints:\y 90HP    ^n\rArmor:\y 300AP             \r^nSpeed:\y 140%      \r^nSpecial powers:\y 2 rockets",                                               // 42
"\rWeapon:\y AK47, Famas                               ^n\rHitPoints:\y 125HP   ^n\rArmor:\y 70AP              \r^nSpeed:\y 110%      \r^nSpecial powers:\y None",                                                   // 43
"\rWeapon:\y M4A1, Scout, USP                       ^n\rHitPoints:\y 150HP   ^n\rArmor:\y 100AP             \r^nSpeed:\y 140%      \r^nSpecial powers:\y 2 dynamite, double jump, third in the instant kill knife",      // 44
"\rWeapon:\y XM1014, TMP, fiveseven                    ^n\rHitPoints:\y 150HP   ^n\rArmor:\y 50AP              \r^nSpeed:\y 120%      \r^nSpecial powers:\y None",                                                   // 45
"\rWeapon:\y FAMAS, P228                               ^n\rHitPoints:\y 110HP   ^n\rArmor:\y 0AP               \r^nSpeed:\y 150%      \r^nSpecial powers:\y None",                                                   // 46
"\rWeapon:\y sg552, glock18, smokegrenade              ^n\rHitPoints:\y 100HP   ^n\rArmor:\y 25AP              \r^nSpeed:\y 130%      \r^nSpecial powers:\y None",                                                   // 47
"\rWeapon:\y P90, glock18, smokegrenade                ^n\rHitPoints:\y 105HP   ^n\rArmor:\y 80AP              \r^nSpeed:\y 100%      \r^nSpecial powers:\y None",                                                   // 48
"\rWeapon:\y AK47, 2 HE                                ^n\rHitPoints:\y 124HP   ^n\rArmor:\y 100AP             \r^nSpeed:\y 120%      \r^nSpecial powers:\y 2 dynamites",                                             // 49
"\rWeapon:\y FAMAS,USP                                 ^n\rHitPoints:\y 130HP   ^n\rArmor:\y 90AP              \r^nSpeed:\y 160%      \r^nSpecial powers:\y 1 rocket",                                               // 50
"\rWeapon:\y SG552,m4a1                                ^n\rHitPoints:\y 80HP    ^n\rArmor:\y 10AP              \r^nSpeed:\y 180%      \r^nSpecial powers:\y 2 rockets, super speed, invisible",                       // 51
"\rWeapon:\y AWP, m4a1                                 ^n\rHitPoints:\y 105HP   ^n\rArmor:\y 45AP              \r^nSpeed:\y 100%      \r^nSpecial powers:\y Reduced recoil guns",                                 // 52
"\rWeapon:\y M4a1\r^nHitPoints:\y 150 HP^n\rArmor:\y 100 AP^n\rSpeed:\y 120%^n\rSpecial powers: There are three missiles, dynamite, mines and instant kill knife (left click)",
"\rWeapon:\y MAC10\r^nHitPoints:\y 50 HP^n\rArmor:\y 0 AP^n\rSpeed:\y 100%^n\rSpecial powers: Completly Invisible, silently walking,1/10 MAC10 Insta with knife",
"\rWeapon:\y MP5, M4A1\r^nHitPoints:\y 100 HP^n\rArmor:\y 100 AP^n\rSpeed:\y 120%^n\rSpecial powers: 2 rockets and silently walking",
"\rWeapon:\y MP5\r^nHitPoints:\y 105 HP^n\rArmor:\y 100 AP^n\rSpeed:\y 130%^n\rSpecial powers: 5 Mines",
"\rWeapon:\y MP5, M3\r^nHitPoints:\y 105 HP^n\rArmor:\y 100 AP^n\rSpeed:\y 130%^n\rSpecial powers: +2000 U.S. dollars to kill",
"\rWeapon:\y Bazooka\r^nHitPoints:\y 120 HP^n\rArmor:\y 120 AP^n\rSpeed:\y 90%^n\rSpecial powers: Bazooka",
"\rWeapon:\y G3SG1, USP\r^nHitPoints:\y 120 HP^n\rArmor:\y 100 AP^n\rSpeed:\y 140%^n\rSpecial powers: 1/3 with a USP, 1/2 with a knife",
"\rWeapon:\y AWP, Deagle\r^nHitPoints:\y 150 HP^n\rArmor:\y 100 AP^n\rSpeed:\y 120%^n\rSpecial powers: 1/1 with AWP, 1/5 with Deagle and invisible with knife",
"\rWeapon:\y M4A1,MP5\r^nHitPoints:\y 100 HP^n\rArmor:\y 100 AP^n\rSpeed:\y 100%^n\rSpecial powers: Get three rockets and 1/8 chance of instant kill with MP5",
"\rWeapon:\y M4A4,AWP+HE\r^nHitPoints:\y 150 HP^n\rArmor:\y 500 AP^n\rSpeed:\y 100%^n\rSpecial powers: Get two rockets and 1/1 chance of instant kill with AWP and 1/7 chance with M4A1 and Insta with knife and HE. Triple jump",
"\rWeapon:\y Katana,USP\r^nHitPoints:\y 200 HP^n\rArmor:\y 200 AP^n\rSpeed:\y 260%^n\rSpecial powers: Get Katana,Jetpack, Silent Boots, and invisible with katana",
"\rWeapon:\y DEAGLE,MP5\r^nHitPoints:\y 100 HP^n\rArmor:\y 100 AP^n\rSpeed:\y 150%^n\rSpecial powers: 2 Rockets  and 1/5 chance of instant kill with MP5 and 1/3 with Deagle,1/1 with knife and Invisiblity",
"\rWeapon:\y DEAGLE,G3SG1\r^nHitPoints:\y 100 HP^n\rArmor:\y 100 AP^n\rSpeed:\y 100%^n\rSpecial powers: Receives 10 dynamite",
"\rWeapon:\y AK47,FAMAS,P90,ELITES\r^nHitPoints:\y 100 HP^n\rArmor:\y 100 AP^n\rSpeed:\y 100%^n\rSpecial powers: 1/5 chance of instant kill with Elite",
"\rWeapon:\y P90,DEAGLE\r^nHitPoints:\y 100 HP^n\rArmor:\y 100 AP^n\rSpeed:\y 100%^n\rSpecial powers: Get 5 dynamite",
"\rWeapon:\y Katana, AK47\r^nHitPoints:\y 150 HP^n\rArmor:\y 300 AP^n\rSpeed:\y 300%^n\rSpecial powers: 1/5 AK47, Gets Katana,5 dinamite, Silent Boots, and very hard to see",
"\rWeapon:\y Super shotgun,\r^nHitPoints:\y 450 HP^n\rArmor:\y 240 AP^n\rSpeed:\y 500%^n\rSpecial powers: Very Strong shotgun (damage ++ with intelligence),15 dinamite,^n exceptional damage with dynamite^nGlows bright red (BRING IT ON!) (very sturdy baseball cap)",
"\rWeapon:\y Super AK+ super deagle+ super shotgun\r^nHitPoints:\y 700 HP^n\rArmor:\y 15 AP^n\rSpeed:\y 300%^n\rSpecial powers: Very Strong AK (damage 10x default)+ deagle (20x default)^n (plus super shotgun cuz why not)^n,30 dinamite,^n exceptional damage with dynamite^nGlows bright white (BRING IT ON!). Go kick their asses"
};
new const sufix_za_klasu[][] = 
{
"Nema",			// 0
"",		// 1
"",		// 2
"",		// 3
"",		// 4
"",		// 5
"",	// 6
"",		// 7
"",		// 8
"",		// 9
"\y(\dOrdinary class\y)",		// 10
"",		// 11
"",		// 12
"",		// 13
"",		// 14
"",		// 15
"",		// 16
"",	// 17
"",		// 18
"",		// 19
"",		// 20
"\y(\dPremium class\y)",		// 21
"\y(\dPremium class\y)",
"\y(\dPremium class\y)",
"\y(\dPremium class\y)",                   // 22
"",		// 23
"",		// 24
"",		// 25
"",	// 26
"",	// 27
"",	// 28
"",		// 29
"",		// 30
"",		// 31
"\y(\dPremium class\y)",		// 32
"",		// 33
"\y(\dPremium Klasa\y)",		// 34
"",			// 35
"",		// 36
"",		// 37
"",		// 38
"\y(\dOrdinary class\y)",		// 39
"",		// 40
"\y(\dOrdinary class\y)",		// 41
"",		// 42
"",		// 43
"\y(\dOrdinary class\y)",		// 44
"",		// 45
"",		// 46
"",		// 47
"",	// 48
"",		// 49
"",	// 50
"",		// 51
"",// 52
"\y(\dSuper class\y)",               // 53
"\y(\dOrdinary class\y)",                     // 54
"\y(\dSuper class\y)",
"\y(\dOrdinary class\y)",              // 55
"",               // 56
"\y(\dOrdinary class\y)",       // 57
"\y(\dSuper class\y)",
"\y(\dSuper class\y)",
"\y(\dSuper class\y)",
"\y(\dSuper class\y)",
"\y(\dSuper class\y)",
"\y(\dSuper class\y)",
"\y(\dPro class\y)",
"\y(\dPro class\y)",
"\y(\dSkill class\y)",
"\y(\dSkill class\y)",
"\y(\dSuper class\y)",
"\y(\dPro class\y)",
"\y(\dOrdinary class\y)",
};
new const naziv_klase_novi[][] = 
{
"None",					//  0
"\ySnipers",		// 1
"\yMarine",		// 2
"\yUltraMarine",
"\yPro-Shooter",		// 3
"\yGunner",		// 4
"\yDoctor",		// 5
"\yFire support",	// 6
"\yMiner",		// 7
"\yDemolitions",		// 8
"\yRusher",		// 9
"\yRambo",		// 10
"\yGunman",		// 11
"\yBomber",		// 12
"\ySagittarius",		// 13
"\yInformer",		// 14
"\yColonel",		// 15
"\yRebal",		// 16
"\ySerial killer",	// 17
"\yCorporal",		// 18
"\ySergeant",		// 19
"\yKamikaze",		// 20
"\yAssassin",		// 21
"\yGazija",
"\yProSWAT",
"\yMajor",		// 22
"\yCaptain",		// 23
"\yLieutenant Colonel",		// 24
"\yMarshal",		// 25
"\yGerman Shooter",	// 26
"\yRussian colonel",	// 27
"\yPoland infantry",	// 28
"\ySailor",		// 29
"\yAttacker ",		// 30
"\yLegion",		// 31
"\yArmageddon",		// 32
"\ySamurai",		// 33
"\yRatko Mladic",		// 34
"\ySWAT",			// 35
"\yPartisan",		// 36
"\yGunner",		// 37
"\yCleric",		// 38
"\yGeneral",		// 39
"\yTerminator",		// 40
"\ySlayer",		// 41
"\ySergeant major",		// 42
"\yAdmiral",		// 43
"\yFighter",		// 44
"\yPoliceman",		// 45
"\ySapper",		// 46
"\yPredator",		// 47
"\yGerman Officer",	// 48
"\yChetnik",		// 49
"\yProfessional Soldie",	// 50
"\yCrysis",		// 51
"\yProfessional Sagittarius",// 52
"\yCommando",               // 53
"\yGhost",
"\yJSO",                     // 54
"\yPro Miner",              // 55
"\yMercenary",               // 56
"\yBazooka Soldier",       // 57
"\yPrice",
"\yCamper",
"\yDragon",
"Tokelian",
"Ninja",
"\yProAssassin",
"\ySoap",
"\yGoogle",
"\yHulk",
"Shredder",
"Graciete",
"ThrasherThrusher",
};

public plugin_init(){
register_plugin(PLUGIN, VERSION, AUTHOR);

register_concmd("cod_num_classes","printNClasses") 

}

public printNClasses(id, level, cid){

	console_print(id,"Number of classes registered: %i. size of array: %i",sizeof naziv_klase, (613-543)+1);

}

public plugin_natives(){

	register_native("isClassInvisible","_isClassInvisible",0);
	register_native("classHasKatana","_classHasKatana",0);
	register_native("classHasSuperShotgun","_classHasSuperShotgun",0);
	register_native("classHasMegaJetpack","_classHasMegaJetpack",0);
	register_native("classHasClimbing","_classHasClimbing",0);
	register_native("classHasSuperDynamite","_classHasSuperDynamite",0);


}

public bool:_isClassInvisible(iPlugin,iParams){

	new classid=get_param(1)
	
	return classid==Assassin||classid==ProAssassin||classid==Shredder||classid==Ninja||classid==UltraMarinac||classid==Ninja||classid==Armageddon||classid==Ghost||classid==Camper||classid==Gazija;
	


}
public bool:_classHasKatana(iPlugin,iParams){

	new classid=get_param(1)
	
	return classid== Ninja || classid== Shredder;


}
public bool:_classHasSuperShotgun(iPlugin,iParams){

	new classid=get_param(1)
	
	return classid== Graciete||classid==ThrashThrush;


}
public bool:_classHasMegaJetpack(iPlugin,iParams){

	new classid=get_param(1)
	
	return classid== ThrashThrush||classid==Ninja;


}
public bool:_classHasClimbing(iPlugin,iParams){

	new classid=get_param(1)
	
	return classid== Ninja;


}
public bool:_classHasSuperDynamite(iPlugin,iParams){

	new classid=get_param(1)
	
	return classid== Graciete||classid==ThrashThrush;


}
public Float:get_ClassSpeed(classid){

	
	
	return brzina_klase[classid];

}
public get_ClassEnergy(classid){

	
	 //
	return energija_klasa[classid];

}
public get_NumClasses(){

	return sizeof naziv_klase;

}
public get_ClassArmor(classid){

	
	
	return oklop_klase[classid];

}
public get_ClassAccess(classid){

	
	//new value= 
	return pripada[classid];
}
public get_ClassName(classid,buff[]){

	copy( buff, 127, naziv_klase[classid] );
	return PLUGIN_CONTINUE
	

}

public get_ClassNameSrb(classid,buff[]){

	copy(buff, 127, naziv_klase[classid] );
	return PLUGIN_CONTINUE
	
	

}
public get_ClassDesc(classid,buff[]){

	copy(buff , 511, novi_opis[classid] );
	return PLUGIN_CONTINUE
}
public get_ClassSuffix(classid,buff[]){

	copy(buff , 127,sufix_za_klasu[classid] );
	return PLUGIN_CONTINUE
}



