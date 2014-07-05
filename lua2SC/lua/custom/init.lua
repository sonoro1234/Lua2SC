require"sc.callback_wrappers"
require"sc.udpSC"
InitUDP()
require"sc.gui"
require"sc.synthdefsc"

--require"sc.playerssc"
--require"sc.miditoosc"
--require"sc.playersscgui"
--require"sc.scbuffer"

require"sc.MetronomLanes"

--MASTER_INIT1()

function preload()
	theMetro.playNotifyCb[#theMetro.playNotifyCb+1] = function(met) 
				idlelinda:send("Metro",met) 
			end
end
function lanesloop(wait)
			local key,val= scriptlinda:receive(wait or 0,"script_exit","tempo","play","/metronom","metronomLanes","beat","beatRequest","_valueChangedCb","_midiEventCb","OSCReceive")
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
	--while lanesloop() do end
	while true do
		if iup then iup.LoopStep() end
		for i=1,10 do
			local res = lanesloop(0.01)
			if not res then return end
			if res == "timeout" then break end
		end
	end
	print("postload1 exit")
end

function postload2()
	if _resetCb then
		print("SCRIPT: to reset\n")
		_resetCb()
	end
	print("SCRIPT: closing iup\n")
	iup.Close()
end
