# makefile for macosx

# note: configuration for ODE build
#./configure CFLAGS="-march=core2 -mfpmath=sse -sse3 -O3" CXXFLAGS="-march=core2 -mfpmath=sse -sse3 -O3" --with-trimesh=none --with-drawstuff=none

all: demo

#optflags     := -DDEBUG

optflags     := -DNDEBUG -march=core2 -mfpmath=sse -sse3 -O3 -g -ffast-math -fno-math-errno -funsafe-math-optimizations -ffinite-math-only -fno-trapping-math -fsingle-precision-constant

makefile     := Makefile
compiler     := llvm-g++
linker       := ld
flags        := -I. -Inetwork -Inetwork/generated -DSANDBOX -Iode -Wall
libs         := -lode -lm -lnetwork
frameworks   := -framework Carbon -framework OpenGL -framework AGL -framework Cocoa -framework CoreVideo
pch          := PreCompiled.h.gch
test_objs    := $(patsubst tests/%.cpp,tests/%.o,$(wildcard tests/*.cpp))
client_objs  := $(patsubst client/%.cpp,client/%.o,$(wildcard client/*.cpp))
server_objs  := $(patsubst server/%.cpp,server/%.o,$(wildcard server/*.cpp))
shared_objs  := $(patsubst shared/%.cpp,shared/%.o,$(wildcard shared/*.cpp))
source_files := $(wildcard *.cpp) $(wildcard network/*.cpp) $(wildcard client/*.cpp) $(wildcard server/*.cpp) $(wildcard shared/*.cpp) $(wildcard tests/*.cpp)

network/output/libnetwork.a:
	make -C network lib

PreCompiled.d : PreCompiled.h network/output/libnetwork.a
	@makedepend -f- PreCompiled.h $(flags) > PreCompiled.d 2>/dev/null

$(pch): PreCompiled.h PreCompiled.d $(makefile) network/output/libnetwork.a
	$(compiler) PreCompiled.h $(flags)

-include PreCompiled.d

%.o: %.cpp $(pch) $(makefile) network/output/libnetwork.a
	$(compiler) -c $< -o $@ $(flags) $(optflags)

UnitTest: UnitTest.o network/output/libnetwork.a $(test_objs) $(shared_objs) $(server_objs)
	$(compiler) -o $@ $(flags) $(optflags) -Lnetwork/output -Ltests/UnitTest++ -lUnitTest++ UnitTest.o $(net_objs) $(ndl_objs) $(test_objs) $(shared_objs) $(server_objs) $(frameworks) $(libs)

Demo: Demo.o network/output/libnetwork.a $(client_objs) $(server_objs) $(shared_objs)
	$(compiler) Demo.o -o $@ $(flags) $(optflags) -Lnetwork/output $(ndl_objs) $(client_objs) $(server_objs) $(shared_objs) $(frameworks) $(libs)

demo: Demo
	@mkdir -pv output
	@rm -f output/*.tga
	./Demo

playback: Demo
	./Demo playback

video: Demo
	./Demo playback video

loc: 
	wc -l *.cpp *.h network/*.h network/*.cpp tests/*.h tests/*.cpp client/*.h client/*.cpp server/*.h server/*.cpp shared/*.h shared/*.cpp 

test: #UnitTest
	make -C network test
#	./UnitTest

clean:
	make -C network clean
	rm -rf *.a *.d *.o *.h.gch *.app \
	$(client_objs) $(server_objs) $(shared_objs) $(test_objs) \
	*.bak *.zip *.bin *.dSYM UnitTest Demo output

files_to_zip := $(wildcard *.rb) $(wildcard *.cpp) $(wildcard *.h) $(wildcard tests/*.cpp) $(wildcard tests/*.h) $(wildcard demos/*.h) Makefile

Cubes.zip: $(files_to_zip)
	zip -9 Cubes.zip $(files_to_zip)

zip: Cubes.zip

commit: clean
	git add *
	git commit -a -m "$(m)"

deps: Dependencies.d
depend: Dependencies.d

Dependencies.d:
	makedepend -f- -- $(flags) -- $(source_files) > Dependencies.d 2>/dev/null

-include Dependencies.d

.PHONY: Dependencies.d
.PHONY: loc
.PHONY: test
.PHONY: demo
