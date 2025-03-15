@echo OFF

SET amxxpc=amxxpc.exe
SET outdir=weaponmod_compiled
SET weapondir=weapons
SET addondir=addons
SET gameinfodir=gameinfo

echo **********************
echo * WeaponMod Compiler *
echo **********************
echo.

if not exist "%outdir%" mkdir "%outdir%"
"%amxxpc%" weaponmod.sma -o"%outdir%/weaponmod.amxx"
for %%i in ("%weapondir%/*.sma") do "%amxxpc%" "%weapondir%/%%i" -o"%outdir%/%%i"
for %%i in ("%addondir%/*.sma") do "%amxxpc%" "%addondir%/%%i" -o"%outdir%/%%i"
for %%i in ("%gameinfodir%/*.sma") do "%amxxpc%" "%gameinfodir%/%%i" -o"%outdir%/%%i"
pause