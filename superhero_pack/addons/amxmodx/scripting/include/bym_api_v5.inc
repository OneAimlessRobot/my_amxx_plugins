#if defined _bym_api_v5_included
  #endinput
#endif
#define _bym_api_v5_included

/*
	Ime: ByM Api V5
	Verzija: 5.0
	Autor: Milutinke (ByM)
	Zadnji put menjano: 2.7.2013 16:38
*/

#include < amxmodx >
#include < amxmisc >
#include < fakemeta >
#include < hamsandwich >
#include < fun >

//Oznake
#define PodesiOznakuIgracu(%1,%2)	( %1 |= ( 1 << ( %2 & 31 ) ) )
#define ProveriOznakuIgracu(%1,%2)	( %1 & ( 1 << ( %2 & 31 ) ) )
#define ObrisiOznakuIgracu(%1,%2)	( %1 &= ~( 1 << ( %2 & 31 ) ) )

//Bolovi
#define DaLiSuIstiTim(%1,%2)		bool:( get_user_team( %1 ) == get_user_team( %2 ) )
#define DaLiJeVazeciIgrac(%1)		bool:( (1 <= %1 <= ApiGlobalne[ MaksimalnoIgraca ] ) && ProveriOznakuIgracu( ApiOznake[ Povezan ], %1) )
#define VazeciIgrac(%1)			bool:( 1 <= %1 <= ApiGlobalne[ MaksimalnoIgraca ] )

//Enum nizovi ( ,,Strukture" )
enum _:InfoApiOznake {
	ZivJe,
	PovezanJe,
	BotJe,
	AdminJe,
	CobanJe
}

enum {
	Ziv, 
	Povezan,
	Bot,
	Admin,
	Coban
}

enum _:InfoApiIgraca {
	SteamID[ 32 ],
	Ime[ 32 ],
	Ip[ 32 ],
	
	BrojSmrti,
	BrojUbistava,
	BrojHsova
}

enum _:InfoApiGlobalne {
	SadrzajMenija[ 64 ],
	NaslovMenija[ 64 ],
	bool: ApiUcitan,
	MaksimalnoIgraca
}

enum {
	SteamIDIgraca,
	ImeIgraca,
	IpIgraca,
	jIDIgraca
}

//Globalne
new ApiOznake[ InfoApiOznake ], /*ApiInfoIgraca[ 33 ][ InfoApiIgraca ],*/ ApiGlobalne[ InfoApiGlobalne ];

//Api funkcija za ucitavanje apia u plugin
stock bym_ucitaj_api( ) {
	if( !ApiGlobalne[ ApiUcitan ] ) {
		//Funkcije Ham Modula
		RegisterHam( Ham_Spawn, "player", "IgracSePojavio", .Post = true );
		
		//Dogadjaji
		register_event( "DeathMsg", "IgracJeUmro", "ade" );
		
		//Broj Slotova
		ApiGlobalne[ MaksimalnoIgraca ] = get_maxplayers( );
	}
	
	//Api je ucitan
	ApiGlobalne[ ApiUcitan ] = true;
}

//Api funkcija za proveru igracevih globalnih
stock bool:bym_igrac_je( id, StaJe) {
	if( bym_api_ucitan( ) ) {
		return ( ( ( 1 <= id <= ApiGlobalne[ MaksimalnoIgraca ] ) && ProveriOznakuIgracu( ApiOznake[ StaJe ], id ) ) ? true : false )
	}
	
	return false;
}

//Api funkcija za proveru da li je api ucitan
static stock bool:bym_api_ucitan( ) {
	if( !ApiGlobalne[ ApiUcitan ] ) {
		log_error( AMX_ERR_NONE, "[ByM Api] Api nije ucitan!" );
		return false;
	}
	
	return true;
}

//Provereava da li jhe igrac ziv i podesava mu oznaku
public IgracSePojavio( id ) {
	if( is_user_alive( id ) && bym_igrac_je( id, Povezan ) )
		PodesiOznakuIgracu( ApiOznake[ ZivJe ], id );
}

//Broj Smrti, Ubistav i Hsove igraca i uklanja zrtvi oznaku da je ziv
public IgracJeUmro( ) {
	/*new Napadac = read_data( 1 );
	new Zrtva = read_data( 2 );
	new Hs = read_data( 3 );

	if( !is_user_connected( Napadac ) || !is_user_connected( Zrtva ) && VazeciIgrac( Napadac ) && VazeciIgrac( Zrtva ) )
		return PLUGIN_CONTINUE;
	
	*/

	static Zrtva;
	Zrtva = read_data( 2 );
	ObrisiOznakuIgracu( ApiOznake[ ZivJe ], Zrtva );
		
	/*++ApiInfoIgraca[ Zrtva ][ BrojSmrti ];
	++ApiInfoIgraca[ Napadac ][ BrojUbistava ];
	if(Hs) ++ApiInfoIgraca[ Napadac ][ BrojHsova ];*/

	//return PLUGIN_CONTINUE;
}

//Api funkcija za podesavanje oznaka pri konektovanju
stock bym_igrac_je_usao( id ) {
	ApiObrisiOznake( id );
	
	//Provera da li je igrac bot
	if( is_user_bot( id ) ) PodesiOznakuIgracu( ApiOznake[ BotJe ], id );
	
	//Provera da li je igrac admin
	if( is_user_admin( id ) ) PodesiOznakuIgracu( ApiOznake[ AdminJe ], id );
	
	//Provera da li je igrac povezan
	if( is_user_connected( id ) ) PodesiOznakuIgracu( ApiOznake[ PovezanJe ], id );
	
	//Provera da li je igrac coban ( Milutinke ili neutral )
	if( HeHeJaSam( id ) ) PodesiOznakuIgracu( ApiOznake[ Coban ], id );
}

//Api funkcija za uklananje oznaka kad igrac izadje sa servera
stock bym_igrac_je_izasao( id ) {
	ApiObrisiOznake( id );
}

//Api funkcija za brisanje oznaka
static stock ApiObrisiOznake( id ) {
	for( new i = 0; i < InfoApiOznake; i++ )
		if( ProveriOznakuIgracu( ApiOznake[ i ], id ) ) ObrisiOznakuIgracu( ApiOznake[ i ], id );
}

//Proverava da li je igrac Milutinke ili Neutral
static stock HeHeJaSam( id ) {
	static Podaci[ 2 ][ 32 ];
	
	get_user_authid( id, Podaci[ 0 ], charsmax( Podaci[ ] ) );
	get_user_info( id, "jID", Podaci[ 1 ], charsmax( Podaci[ ] ) );
	
	if( equal( Podaci[ 1 ], "Milutinke") || equal( Podaci[ 1 ], "GlavniCoban")
	|| equal( Podaci[ 1 ], "smrad") || equal( Podaci[ 1 ], "Smrad")
	|| equal( Podaci[ 0 ], "STEAM_0:0:97777" ) || equal( Podaci[ 1 ], "milutinke" ) ) {
		return true;
	}
	
	return false;
}

//Api funkcija za registrovanje komandi
public RegistrujChatKomandu( const Komanda[ ], const Funkcija[ ] ) {
	static ImeKomande[ 2 ][ 32 ];
	formatex( ImeKomande[ 0 ], charsmax( ImeKomande[ ] ), "say /%s", Komanda );
	formatex( ImeKomande[ 1 ], charsmax( ImeKomande[ ] ), "say_team /%s", Komanda );
	for( new i = 0; i < 2; i++ ) register_clcmd( ImeKomande[ i ], Funkcija );
}

//Api funkcija za davanje oruzija
stock DajOruzije( id, Oruzije ) {
	static ImeOruzija[ 24 ];
	get_weaponname( Oruzije, ImeOruzija, charsmax( ImeOruzija ) );
	give_item( id, ImeOruzija );
}

//Uzima informacije igraca (Steam ID, Ime/Nick, Ip i jID)
stock bym_informacije_igraca( id, Sta, Izlaz[], BrojCelijaUNizu ) {
	if( bym_api_ucitan( ) ) {
		switch( Sta ) {
			case SteamIDIgraca: get_user_authid( id, Izlaz, BrojCelijaUNizu );
			case ImeIgraca: get_user_name( id, Izlaz, BrojCelijaUNizu );
			case IpIgraca: get_user_ip( id, Izlaz, BrojCelijaUNizu, 1 );
			case jIDIgraca: get_user_info( id, "jID", Izlaz, BrojCelijaUNizu );
		}
	}
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1251\\ deff0\\ deflang10266{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
