Lua2SC
======

Lua client for supercollider scsynth and supernova.
Pure lua implementation based on standard portable modules: lualanes, wxlua, luasocket, 
plus some custom modules: osclua, pmidi, random.

------Lua learning resources--------

* https://www.lua.org/manual/5.1/   (Lua specification)
* https://www.lua.org/pil/contents.html  (Online book for Lua 5.0, but great Lua introduction)
* http://luajit.org/  (LuaJIT additions to Lua 5.1 as ffi.)

* http://tylerneylon.com/a/learn-lua/ If you dont have more than 15 minutes

------Lua2SC learning resources---------

* The pieces and other examples I will be uploading.
* Ctrl+I will find the source of most keywords (those in pale blue color in the IDE)
* I am open to any questions posted as issues in Lua2SC repository.

------Ubuntu Studio building requirements ---------
All of them can be installed with `sudo apt install`

* cmake (should be >= 3.13)
* libasound2-dev

and for wx module

* libgtk2.0-dev
* libgl1-mesa-dev
* freeglut3-dev

------Building-----------

from build directory:
* set LUAJIT_BIN to the desired installation absolute location in init_cmake.bat (.sh)
* add -DBUILD_WXLUA=ON in init_cmake.bat if you wish to also build wx module.
* run init_cmake.bat (or copy to init_cmake.sh)
* make
* make install

you will get Lua2SC installed directory where you pointed LUAJIT_BIN to.

this directory can be copied anywhere.


--------------To first try---------------------

run: Lua2SC.bat or Lua2SC.sh

1. set Debug/settings
2. Supercollider/BootSC (wait until booted)
3. open simple_theme in lua2SC\lua2scsamples\ 
4. Debug/run  (F6)
5. Debug/Cancel run (F5)

![Alt text](lua2sc_.jpg )

------------Using lillypond--------------------

1. Find location of lilypond executable in Debug->Settings
2. Set as first line in script: LILY = require"sc.lilypond"
3. Set as last line in script: LILY:Gen(initial beat,last beat)
4. Run as plain lua script with F7

------------Using Non real time---------------

1. Set as first line in script: NRT = require"sc.nrt":Gen(number of beats to render)
2. Run script with Run Lua2SC (F6)