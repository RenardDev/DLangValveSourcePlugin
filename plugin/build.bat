@echo off

if exist VSP_32.dll del VSP_32.dll
if exist VSP_32.exp del VSP_32.exp
if exist VSP_32.lib del VSP_32.lib
if exist VSP_32.obj del VSP_32.obj

if exist VSP_64.dll del VSP_64.dll
if exist VSP_64.exp del VSP_64.exp
if exist VSP_64.lib del VSP_64.lib
if exist VSP_64.obj del VSP_64.obj

dmd -v -w -g -gf -gx -shared -m32 -release -lowmem -check=on -checkaction=halt -boundscheck=safeonly -O -inline -mcpu=baseline -L="/DYNAMICBASE" -L="/SUBSYSTEM:WINDOWS" -L="/NXCOMPAT" -L="/CETCOMPAT" -L="/OPT:REF" -L="/RELEASE" -allinst -of=VSP_32.dll VSP.d
dmd -v -w -g -gf -gx -shared -m64 -release -lowmem -check=on -checkaction=halt -boundscheck=safeonly -O -inline -mcpu=baseline -L="/DYNAMICBASE" -L="/SUBSYSTEM:WINDOWS" -L="/NXCOMPAT" -L="/CETCOMPAT" -L="/OPT:REF" -L="/RELEASE" -allinst -of=VSP_64.dll VSP.d

if exist VSP_32.exp del VSP_32.exp
if exist VSP_32.lib del VSP_32.lib
if exist VSP_32.obj del VSP_32.obj

if exist VSP_64.exp del VSP_64.exp
if exist VSP_64.lib del VSP_64.lib
if exist VSP_64.obj del VSP_64.obj

dir VSP_*.*

pause
