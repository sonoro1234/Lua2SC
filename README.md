Lua2SC
======

Lua client for supercollider scsynth and supernova.
Pure lua implementation based on standard portable modules: lualanes, wxlua, luasocket, 
plus some custom modules: osclua, pmidi, random.


------Building-----------

1 - Need to have lua 5.1 or 5.2 or luajit with lualanes wxlua luasocket or
build lua 5.1 or 5.2
build lualanes 
build wxlua as a module (most difficult part)
build luasocket

2 - Then build this repo:

you need to provide in build/toolchain.cmake:
LUA_INCLUDE_DIR with the lua source include directory
LUA_LIBRARY with the path to luaXX.dll (luaXX.so)

from build directory run:
init_cmake.bat (or copy to init_cmake.sh)
make install

you will get Lua2SC directory inside build.
this directory can be copied anywhere.


--------------To first try---------------------

run: lua lua2sc.lua

1- set Debug/settings
2- Supercollider/BootSC (wait until booted)
3- open simple_theme in lua2SC\lua2scsamples\ 
4- Debug/run  (F6)
5- Debug/Cancel run (F5)

![Alt text](lua2sc_.jpg )
