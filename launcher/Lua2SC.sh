#!/bin/sh
# luajit wrapper that looks for libraries only relative to the current directory
# and relative to the executable's directory, making the distribution portable.

# get full path of $0 without spawning a new process (this wrapper process is bad enough)
bindir="${0%Lua2SC.sh}"
curdir="$PWD"
cd "$bindir"
bindir="$PWD"
cd "$curdir"

luadir="$bindir/lua"

export LUA_CPATH="./?.so;$bindir/?.so"
export LUA_PATH="./?.lua;$luadir/?.lua;$luadir/?/init.lua"
export LD_LIBRARY_PATH=$bindir
exec "$bindir/luajit" ./lua2SC/lua2sc.lua
