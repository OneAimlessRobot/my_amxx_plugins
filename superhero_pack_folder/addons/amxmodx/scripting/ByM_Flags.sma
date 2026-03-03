#include < amxmodx >

new g_szPlayerFlags[ 33 ][ 64 ];

enum _:StructFlags {
	FLAG_NONE,
	
	FLAG_A = 1,
	FLAG_B,
	FLAG_C,
	FLAG_D,
	FLAG_E,
	FLAG_F,
	FLAG_G,
	FLAG_H,
	FLAG_I,
	FLAG_J,
	FLAG_K,
	FLAG_L,
	FLAG_M,
	FLAG_N,
	FLAG_O,
	FLAG_P,
	FLAG_Q,
	FLAG_R,
	FLAG_S,
	FLAG_T,
	FLAG_U,
	FLAG_V,
	FLAG_W,
	FLAG_X,
	FLAG_Y,
	FLAG_Z,
	FLAG_1,
	FLAG_2,
	FLAG_3,
	FLAG_4,
	FLAG_5,
	FLAG_6,
	FLAG_7,
	FLAG_8,
	FLAG_9,
	FLAG_0,
	FLAG_EQUAL,
	FLAG_PARENTHESIS1,
	FLAG_PARENTHESIS2,
	FLAG_PARENTHESIS_SQUARE1,
	FLAG_PARENTHESIS_SQUARE2,
	FLAG_AND
}

new const g_szFlags[ StructFlags ][ ] = {
	" ",
	
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"0",
	"=",
	"(",
	")",
	"[",
	"]",
	"&"
}

public plugin_init( ) {
	register_plugin( "ByM: Flags", "1.0", "Milutinke (ByM)" );
}

public plugin_natives( ) {
	register_native( "bym_set_flag", "NativeSetFlag", 1 );
	register_native( "bym_get_flag", "NativeGetFlag", 1 );
	register_native( "bym_delete_flags", "NativeDelFlags", 1 );
	register_native( "bym_get_flag_char", "NativeGetFlagChar" );
	register_native( "bym_get_flag_int", "NativeGetFlagInt" );
}

public NativeSetFlag( iPlayer, iFlag ) {
	if( HasFlag( iPlayer, iFlag ) )
		return;
		
	add( g_szPlayerFlags[ iPlayer ], charsmax( g_szPlayerFlags[ ] ), g_szFlags[ iFlag ] );
}

public NativeGetFlag( iPlayer, iFlag )
	return HasFlag( iPlayer, iFlag );
	
public NativeDelFlags( iPlayer )
	g_szPlayerFlags[ iPlayer ][ 0 ] = '^0';
	
public NativeGetFlagChar( iPlugin, iParams )
	set_string( 2, g_szFlags[ get_param( 1 ) ], get_param( 3 ) );
	
public NativeGetFlagInt( iPlugin, iParams ) {
	new szFlag[ 6 ];
	get_string( 1, szFlag, charsmax( szFlag ) );
	
	for( new i = FLAG_A; i <= FLAG_AND; i++ ) {
		if( equal( g_szFlags[ i ], szFlag ) )
			return i;
	}
	
	return  0;
}

stock bool: HasFlag( iPlayer, iFlag ) {
	if( containi( g_szPlayerFlags[ iPlayer ], g_szFlags[ iFlag ] ) != -1 ) 
		return true;
		
	return false;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang10266\\ f0\\ fs16 \n\\ par }
*/
