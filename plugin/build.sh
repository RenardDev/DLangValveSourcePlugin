
rm -f VSP_32.o
rm -f VSP_64.o

dmd -v -w -g -gdwarf=5 -gf -gx -fPIC -shared -m32 -release -lowmem -check=on -checkaction=halt -boundscheck=safeonly -O -inline -mcpu=baseline -allinst -of=VSP_32.so VSP.d
dmd -v -w -g -gdwarf=5 -gf -gx -fPIC -shared -m64 -release -lowmem -check=on -checkaction=halt -boundscheck=safeonly -O -inline -mcpu=baseline -allinst -of=VSP_64.so VSP.d

rm -f VSP_32.o
rm -f VSP_64.o
