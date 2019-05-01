
local function prstak(stk)
	local str=""
	for i,lev in ipairs(stk) do
		str= str..i..": \n"
		for k,v in pairs(lev) do
			str=str.."\t["..k.."]:"..v.."\n"
		end
	end
	io.write(str)
end

local function finalizer_func(err,stk)
	print("ide_lane finalizer:")
	if err and type(err)~="userdata" then 
		print( "after error: "..tostring(err) )
		print("finalizer stack table")
		prstak(stk)
	elseif type(err)=="userdata" then
		print( "after cancel " )
	else
		print( "after normal return" )
	end
	mainlinda:send("ide_exit",1)
	print( "finalizer ok" )
end


local function ide_main()
	--local 
	lanes = require "lanes" --.configure()
	set_finalizer( finalizer_func ) 
	set_error_reporting("extended")
	set_debug_threadname("ide_lane")

	require"sc.utils"
	--dofile(lua2scpath .."lua"..path_sep .. "ide" ..path_sep .. "ide.lua")
	
	IDESCSERVER = require"ide.ide_server"
	require"sc.oscfunc"
	
	require"pmidi"
	require("osclua")
	toOSC=osclua.toOSC
	fromOSC=osclua.fromOSC


	dofile(lua2scpath .. "lua" .. path_sep .. "ide" .. path_sep .. "ide.lua")
	--require"ide.ide"
	
end
local function ide_lane()
	local function MidiOpen(opt) return mainlinda:send("MidiOpen",opt) end
	local function MidiClose() 
		local tmplinda = lanes.linda()
		mainlinda:send("MidiClose",tmplinda)
		tmplinda:receive("MidiClose_done")
	end
	local process_gen=lanes.gen("*",--"base,math,os,package,string,table",
		{
		--cancelstep=10000,
		required={},
		globals={
				path_sep = path_sep,
				lua2scpath = lua2scpath,
				_presetsDir = _presetsDir,
				idlelinda = idlelinda,
				scriptlinda= scriptlinda,
				scriptguilinda= scriptguilinda,
				midilinda= midilinda,
				udpsclinda=udpsclinda,
				debuggerlinda=debuggerlinda,
				mainlinda = mainlinda,
				lindas = lindas,
				file_settings = file_config,
				MidiOpen = MidiOpen,
				MidiClose = MidiClose,
                --print=thread_print
				},
		priority=0},
		ide_main)
		return process_gen()
end
return ide_lane

