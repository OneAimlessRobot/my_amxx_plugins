#include < amxmodx >

native geoip_country_ex( const ip[ ], result[ ], len, id = -1 );

new const g_szSerbianCountries[ ][ ] = {
	"Serbia",
	"Montenegro",
	"Bosnia",
	"Macedonia",
	"Slovenia",
	"Croatia",
	"Kosovo" // Srbija
};

public plugin_init( ) {
	register_plugin( "[ByM] Auto Lang Setter", "1.0", "Milutinke (ByM)" );
}

public client_putinserver( iPlayer ) {
	if( !is_user_connected( iPlayer ) )
		return;
	
	new szIp[ 32 ];
	get_user_ip( iPlayer, szIp, charsmax( szIp ) );
	
	new szCountry[ 96 ], iIterator;
	geoip_country_ex( szIp, szCountry, charsmax( szCountry ), -1 );
	
	set_user_info( iPlayer, "lang", "en" );
	client_cmd( iPlayer, "setinfo lang en" );
	
	if( containi( szCountry, "error" ) != -1 )
		return;
	
	for( iIterator = 0; iIterator < sizeof( g_szSerbianCountries ); iIterator ++ ) {
		if( containi( szCountry, g_szSerbianCountries[ iIterator ] ) != -1 ) {
			set_user_info( iPlayer, "lang", "sr" );
			client_cmd( iPlayer, "setinfo lang sr" );
			
			console_print( iPlayer, "--------------------------^nYour language has been set to Serbian beacause you are from: %s^n--------------------------", szCountry );
			break;
		}
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
