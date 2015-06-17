local NRT = {}
function NRT:open(filepath)
	local file,err = io.open(filepath,"wb")
	self.file = file
	if not self.file then error(err) end
	self.filepath = filepath
	
end
function NRT:sendBundle(msg,time)
	assert(self.file)
	assert(time)
	if not self.closed then
		local kSecondsToOSCunits = 4294967296
		local timestamp = time*kSecondsToOSCunits 
		local dgram = toOSC{timestamp,msg}
		prerror(time,#dgram,str2int(int2str(#dgram,4,false)))
		self.file:write(int2str(#dgram,4,false))
		self.file:write(dgram)
	else
		prerror("nrt closed:",prOSC(msg))
	end
end
function NRT:close()
	self.file:close()
	self.closed = true
end
function NRT:Gen(endppq)
	local function pathnoext(P)
		return P:match("([^%.]+)")
	end
	NRT:open(pathnoext(scriptname)..".osc")
	theMetro:play(nil,0,0,25)
	local lastt = 0
    sendBundle = function(msg,ti)
		ti = ti or lastt
		lastt = ti
		prerror(ti,prOSC(msg))
		NRT:sendBundle(msg,ti)
	end
	sendBlocked = function(msg)
		prerror(lastt,prOSC(msg))
		--if msg[1]~="/d_recv" then
		NRT:sendBundle(msg,lastt)
		--end
		return {"/done",{}}
	end
    table.insert(initCbCallbacks,function()
		theMetro:play(nil,0,0,25)
		theMetro.oldtimestamp = -theMetro.period
		while theMetro.ppqPos < endppq do
			theMetro.timestamp = theMetro.oldtimestamp + theMetro.period
			theMetro.oldppqPos = theMetro.ppqPos
			theMetro.ppqPos = theMetro.ppqPos + theMetro.frame
			--print("theMetro",theMetro.oldppqPos,theMetro.ppqPos)
			_onFrameCb()
			theMetro.oldtimestamp = theMetro.timestamp
		end
		sendBundle({"/quit",{}})
		NRT:close()
---[=[
		-- call sc NRT
		local is_windows = package.config:sub(1,1) == '\\'
		local sep = is_windows and '\\' or '/'
		local scpath = (_run_options.SCpath):match("(.+"..sep..")([^"..sep.."]+)")
		local plugpath = [["]]..scpath..[[plugins"]]
		for i,v in ipairs(_run_options.SC_PLUGIN_PATH) do
			if(v=="default") then
			else	
				plugpath = plugpath..[[;"]]..v..[["]]
			end
		end
		local cmd = string.format("\"\"%s\" -N \"%s\" _ \"%s\" 44100 wav float -U %s -o 2 -i 2 -V 2 -m 65536 2>&1\"",_run_options.SCpath, NRT.filepath, pathnoext(scriptname)..".wav",plugpath)
		print(cmd)
		--print(os.execute(cmd))
		local exe,err = io.popen(cmd)
		if not exe then
			print("Could not popen. Error: ",err)
			return false
		else
			exe:setvbuf("no")
		end
		repeat
			--print(stdout:read("*all") or stderr:read("*all") or "nil")
			exe:flush()
			--io.write("reading line bootsc\n")
			local line = exe:read("*l")
			if line then
				--io.write(line .."\n")
				print(line)
			else
				--io.write("server finished\n")
				print("nrt server finished")
				return true
			end
		until false
--]=]
    end)
end
return NRT