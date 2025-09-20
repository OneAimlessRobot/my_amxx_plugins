#if defined codmw4_classes_included
  #endinput
#endif
#define codmw4_classes_included

forward Float:get_ClassSpeed(classid)

forward get_ClassEnergy(classid)
forward get_ClassArmor(classid)
forward get_ClassAccess(classid)
forward get_ClassName(classid,buff[])
forward get_ClassDesc(classid,buff[])
forward get_ClassNameSrb(classid,buff[])
forward get_ClassSuffix(classid,buff[])
forward get_NumClasses()
native bool:isClassInvisible(classid)
native bool:classHasKatana(classid)
native bool:classHasSuperShotgun(classid)
native bool:classHasMegaJetpack(classid)
native bool:classHasClimbing(classid)
native bool:classHasSuperDynamite(classid)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2070\\ f0\\ fs16 \n\\ par }
*/
