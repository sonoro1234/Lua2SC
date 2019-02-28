Lua2SC
======

Lua client for supercollider scsynth and supernova.
Pure lua implementation based on standard portable modules: lualanes, wxlua, luasocket, 
plus some custom modules: osclua, pmidi, random.


------Building-----------

from build directory:
* set LUAJIT_BIN to the desired installation location in init_cmake.bat
* run init_cmake.bat (or copy to init_cmake.sh)
* make install

you will get Lua2SCinstalled directory inside build.

Only will need wxLua (You can get it from ZeroBraneStudio until I manage to bundle it)

this directory can be copied anywhere.


--------------To first try---------------------

run: lua lua2sc.lua

1. set Debug/settings
2. Supercollider/BootSC (wait until booted)
3. open simple_theme in lua2SC\lua2scsamples\ 
4. Debug/run  (F6)
5. Debug/Cancel run (F5)

![Alt text](lua2sc_.jpg )
