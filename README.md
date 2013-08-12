Lua2SC
======

Lua client for supercollider scsynth and supernova

------Linux and Mac OS
First you should build lua 5.1 or 5.2
build wxlua as a module (most difficult part)
build luasocket
build bitOp (in case you are in 5.1)

Then build this repo:
with CMake you need to provide:

PORTMIDI_DIR with path to portmidi
OSCPACK_DIR with path to oscpack (1_1_0 or greater)
LUA_INCLUDE_DIR with the lua source include directory
LUA_LIBRARY with the path to lua.dll

run lua lua2sc.lua


------Windows--------
windows users can try the already build binary folder Lua2SC-bin
