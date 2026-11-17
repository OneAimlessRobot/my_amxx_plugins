#if defined sh_aux_math_funcs_pt2
  #endinput
#endif
#define sh_aux_math_funcs_pt2



/*


	it only returns:
	-1.0 if true
	1.0 if false

	use it to change the sign of things based on a bool
*/
#define sign_chng_mult(%1) ((%1)?-1.0:1.0)
