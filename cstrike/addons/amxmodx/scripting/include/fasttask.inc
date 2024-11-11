/* Interface functions for FastTask
 *
 * by Darkns.xf
 */

#if defined _fasttask_included
  #endinput
#endif
#define _fasttask_included

//WARNING: you can only pass up to 14 variables into this function. If you need more, go die. :P
native FastTask(Float:fDelay, sFunc[32], {Float,Sql,Result,_}:...);