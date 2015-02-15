require"sc.callback_wrappers"
--require"sc.udpSC"
--InitUDP()
--require"sc.gui"
--require"sc.synthdefsc"

--require"sc.playerssc"
--require"sc.miditoosc"
--require"sc.playersscgui"
--require"sc.scbuffer"

require"sc.MetronomLanes"

--MASTER_INIT1()

function preload()
	package.path = [[C:\LUA\luaAV4repo\LuaAV4\modules\?.lua;]] .. package.path
	local ffi = require "ffi"

	local path_sep = ffi.os == "Windows" and "\\" or "/"
	
	-- extend the search paths:
	local path_default = ffi.os == "Windows" and "" or "./"
	local module_extension = ffi.os == "Windows" and "dll" or "so"
	local lib_extension = ffi.os == "Windows" and "dll" or (ffi.os == "OSX" and "dylib" or "so")
	local function add_module_path(path)
		-- lua modules
		package.path = string.format("%s?.lua;%s?%sinit.lua;%s", path, path, path_sep, package.path)
		-- binary modules
		package.cpath = string.format("%s?.%s;%s", path, module_extension, package.cpath)
		-- ffi libraries
		package.ffipath = package.ffipath or ""
		package.ffipath = string.format("%s%s%slib?.%s;%s", path, ffi.os, path_sep, lib_extension, package.ffipath)
	end
	add_module_path([[C:\LUA\luaAV4repo\LuaAV4\modules\]])
	local av = require"av"
	-- pre-load LuaAV globals:
	Window = require "Window"
	--now, go, wait, event = schedule.now, schedule.go, schedule.wait, schedule.event
	av.time = function() return theMetro.timestamp end
	function _onFrameCb()  av.step() end
	--av.run = function
	theMetro.playNotifyCb[#theMetro.playNotifyCb+1] = function(met) 
				idlelinda:send("Metro",met) 
			end
end
function lanesloop(wait)
			local key,val= scriptlinda:receive("script_exit","tempo","play","/metronom","metronomLanes","beat","beatRequest","_valueChangedCb","_midiEventCb","OSCReceive")
			if key then
				--print("xxxxxxxxxxxxrequired linda: ",key," : ",val)
				if key == lanes.cancel_error then
					return false
				elseif key=="beat" then
					theMetro:play(nil,val)
				elseif key=="tempo" then
					theMetro:play(val)
				elseif key=="/metronom" then
					setMetronom(val[2],val[3])
				elseif key=="metronomLanes" then
					--print("metronomLanes")
					setMetronomLanes(val)
				--elseif key=="/vumeter" then
					--setVumeter(val)
				elseif key=="script_exit" then
					print("SCRIPT: script_exit arrived")
					return false
				elseif key=="beatRequest" then
					--linda:send("beatResponse",theMetro.actualbeat)
					idlelinda:send("Metro",theMetro)
					--print("beatRequest")
				elseif key=="_valueChangedCb" then
					--print("_valueChangedCbzzz")
					_valueChangedCb(val[1],val[2],val[3])
				elseif key=="_midiEventCb" then
					_midiEventCb(val)
				elseif key=="play" then
					if val==1 then
						theMetro:start()
					else
						theMetro:stop()
					end
				elseif key=="OSCReceive" then 
					OSCFunc.handleOSCReceive(val)
				end
				return true
			end
			return "timeout"
		end
function postload1()
	_initCb()
	theMetro:play(120,-4,0,30)
	theMetro:start()
	while true do
		--for i=1,10 do
			local res = lanesloop(0.01)
			if not res then return end
			if res == "timeout" then break end
		--end
	end
	print("postload1 exit")
end

function postload2()
	if _resetCb then
		print("SCRIPT: to reset\n")
		_resetCb()
	end
	print("SCRIPT: closing iup\n")
	--iup.Close()
end
