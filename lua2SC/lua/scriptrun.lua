-- ---------------------------------------------------------------------------
local USE_PROFILE = false
function ScriptRun(pars)

	local typerun = pars.typerun
	local Debuggerbp = pars.Debuggerbp
	local script = pars.script
	local debugging = pars.debugging
	local typeshed = pars.typeshed
	
	local function prstak(stk)
		local str=""
		for i,lev in ipairs(stk) do
			str= str..i..": \n"
			for k,v in pairs(lev) do
				str=str.."\t["..k.."]:"..v.."\n"
			end
		end
		prerror(str)
	end
	
	local function finalizer_func(err,stk)
		if err and type(err)~="userdata" then 
			prerror( "SCRIPT: finalizer after error: ")
			local onlyerrorst=err:match(":%d+:(.+)")
			prerror(tostring(err).."\n"..tostring(onlyerrorst) )
			--prerror("SCRIPT: finalizer stack table")
			--prstak(stk)
			prtable(stk)
			--debuglocals()
			--print("end debug print")
		elseif type(err)=="userdata" then
			print( "SCRIPT: finalizer after cancel " )
		else
			print( "SCRIPT: finalizer after normal return" )
		end
		print("SCRIPT: finalizer ok")
	end
	
	local function ScriptExit()
		scriptlinda:send("script_exit",1)
	end
	local function TextToClipBoard(text)
		idlelinda:send("TextToClipBoard",text)
	end
	local function CopyControl(con)
		local res = {}
		for k,v in pairs(con) do
			local typev = type(v)
			if (typev=="number") or (typev=="string") then
				res[k]=v
			elseif typev=="table" and (k=="pos" or k=="menu") then
				res[k]=v
			elseif typev=="function" then --and (k=="DrawCb") then
				res[k]=v
			else
				--print("No CopyControl",k,v)
			end
		end
		return res
	end
	local function guiAddWindow(window)
		scriptguilinda:send("guiModify",{"addWindow",CopyControl(window)})
	end
	local function guiAddWindowAV(window)
		scriptguilinda:send("guiModify",{"addWindowAV",CopyControl(window)})
	end
	-- tipex tag label name menu panel
	local function guiAddControl(control)
		scriptguilinda:send("guiModify",{"addControl",CopyControl(control)})
	end
	local function guiAddPanel(panel)
			scriptguilinda:send("guiModify",{"addPanel",panel})
	end
	local function guiDeleteControl(tag)
		scriptguilinda:send("guiModify",{"deleteControl",tag})
	end
	local function guiDeletePanel(tag)
		scriptguilinda:send("guiModify",{"deletePanel",tag})
	end
	local function guiEmptyPanel(tag)
		scriptguilinda:send("guiModify",{"emptyPanel",tag})
	end
	local function guiUpdate()
		print"guiUpdate"
		scriptguilinda:send("guiUpdate",1)
	end
	local function guiSetValue(tag,value)
		scriptguilinda:send("guiSetValue",{tag,value})
	end
	local function guiSetLabel(tag,value)
		scriptguilinda:send("guiSetLabel",{tag,value})
	end
	
	local function dodir(func,path,pattern,recur,level)
		local tmplinda=lanes.linda()
		idlelinda:send("DoDir",{path,pattern,recur,tmplinda})
		local key,val=tmplinda:receive("dodirResp")
		assert(key=="dodirResp")
		for k,v in ipairs(val) do
			func(v.file,v.lev,v.path)
		end
	end
	local function openFileSelector(path,pat,save)
		pat=pat or "*"
		if save==nil then save=false end
		local tmplinda=lanes.linda()
		idlelinda:send("_FileSelector",{path,pat,save,tmplinda})
		local key,val=tmplinda:receive("_FileSelectorResp")
		assert(key=="_FileSelectorResp")
		return val
	end
	local function guiGetValue(tag)
		assert(false)
	end

	--------------------------------------------------------
	local function main_lanes(script)
--[[
		--clear linda-------------
		local usedkeys = scriptlinda:count()
		if usedkeys then
			for k,v in pairs(usedkeys) do scriptlinda:set(k) end
		end

		if debugging then
			Debugger:init(Debuggerbp)
		end
		--]]
		require("sc.init")

		theMetro.playNotifyCb[#theMetro.playNotifyCb+1] = function(met) 
				idlelinda:send("Metro",met:send()) 
			end
		scriptname2 = script
		local fs,err = loadfile(script)
		if fs then 
			fs() 
		else 
			error("loadfile error:"..tostring(err),2) 
		end
		
		_initCb()
		if USE_PROFILE then
		ProFi = require 'ProFi'
		ProFi:start()
		end

		while true do
			--local dgram,status = udp2:receive()
			--from the gui (editor and scriptgui)
			local key,val= scriptlinda:receive("script_exit","metronomLanes","_midiEventCb","tempo","play","/metronom","beat","beatRequest","_valueChangedCb","OSCReceive","execstr")
			if val then
				--print("xxxxxxxxxxxxrequired linda: ",key," : ",val)
				if key=="metronomLanes" then
					setMetronomLanes(val)
				elseif key=="beat" then
					theMetro:play(nil,val)
				elseif key=="tempo" then
					theMetro:play(val)
				elseif key=="/metronom" then
					setMetronom(val[2],val[3])
				elseif key=="script_exit" then
					print("SCRIPT: script_exit arrived")
					break
				elseif key=="beatRequest" then
					idlelinda:send("Metro",theMetro:send())
					----print("beatRequest")
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
					--print("OSCReceive in scriptlinda",tb2st(val))
					OSCFunc.handleOSCReceive(val)
				elseif key=="execstr" then 
					local chunk,err = loadstring(val)
					if chunk then
						--setfenv(chunk, getfenv(fs))
						chunk()
						--prtable(debug.getinfo(fs))
						--debuglocals(true)
					else
						print("error in exestr:",err)
					end
				end
			end
		end
		
		if USE_PROFILE then
		ProFi:stop()
		ProFi:writeReport( 'c:/MyProfilingReport.txt' )
		end

		if _resetCb then
			print("SCRIPT: to reset\n")
			_resetCb()
		end
		return true
	end
	
	local function main_lanes_custom(script)
--[[
		--clear linda-------------
		local usedkeys = scriptlinda:count()
		if usedkeys then
			for k,v in pairs(usedkeys) do scriptlinda:set(k) end
		end

		if debugging then
			Debugger:init(Debuggerbp)
		end
		--]]
		require("custom.init")
		preload()

		local fs,err = loadfile(script)
		if fs then 
			fs() 
		else 
			error("loadfile error:"..tostring(err),2) 
		end
		
		postload1()
		postload2()
		return true
	end
	local function main_lanes_customAV(script)
--[[
		--clear linda-------------
		local usedkeys = scriptlinda:count()
		if usedkeys then
			for k,v in pairs(usedkeys) do scriptlinda:set(k) end
		end

		if debugging then
			Debugger:init(Debuggerbp)
		end
		--]]
		
		arg = {}
		arg[0] = [[C:\LUA\luaAV4repo\LuaAV4\modules\av.lua]]
		arg[1] = script
		local fs,err = loadfile([[C:\LUA\luaAV4repo\LuaAV4\modules\av.lua]])
		if fs then 
			fs() 
		else 
			error("loadfile error:"..tostring(err),2) 
		end
		
		return true
	end
	local function main_lanes_plain(script)
		io.write"this is main_lanes_plain"
		--if debugging then
		--	Debugger:init(Debuggerbp)
		--end
		dofile(script)
		return true
	end
	
	--CloseScriptGUI()

	--CreateScriptGUI()
	
	local runmain = nil
	if typerun ==1 then
		--timer:Start(300,wx.wxTIMER_ONE_SHOT)
		--manager:GetPane(panel):Show()
		runmain = main_lanes --pmain --main_lanes
	elseif typerun == 2 then
		--manager:GetPane(panel):Hide()
		runmain = main_lanes_plain
	elseif typerun == 3 then
		--manager:GetPane(panel):Hide()
		runmain = main_lanes_custom
	end
	
	local function xpcallerror(err) 
			io.stderr:write("from xpcall error required to cancel: "..tostring(err).."\n")
			--detect recursive error
			for i=2,math.huge do
				local debuginfo = debug.getinfo(i,"Snlf")
				if not debuginfo then break end
				--io.stderr:write(ToStr(debuginfo).."\n")
				if debuginfo.func == xpcallerror then
					io.stderr:write("recursive error\n")
					return
				end
			end
			--prerror("xpcallerror:") 
			--local ccc = {string.byte(err,1,#err)}
			--prerror(table.concat(ccc,","))
			--io.stderr:write(string.byte(err,1,#err))
			--prerror(tostring(err)) 
			--prerror(err) 
			prerror("xpcallerror:"..tostring(err)) 
			--io.stderr:write("xpcallerror:"..tostring(err).."\n")
			
			-- function to get compiler errors in required files
			local function compile_error(err)
				local info = {}
				--catch error from require
				local err2 = err:match("from file%s+'.-':.-([%w%p]*:%d+:)")
				--if not err2 then
				--	err2 = err:match("from file%s+'.-':.-([%w%p]*)")
				--end
				--catch error from loadfile
				if not err2 then
					err2 = err:match("loadfile error:([%w%p]*:%d+:)")
				end
				if err2 then
					info.source = "@"..err2:match(":-(.-):%d*:")
					info.currentline = err2:match(":(%d*):") or -1
					return info
				end
			end
			
			local debuginfo = debug.getinfo(2,"Slf")
			local stack,vars = Debugger.get_call_stack(3)
			print("is require?",debuginfo.func == require)
			-- if there is a compile error add it to stack and vars
			local info = compile_error(err)
			if (info) then
				io.stderr:write("comp err source: ",info.source.."\n")
				io.stderr:write("comp err line: ",info.currentline,"\n")
				local stack_tbl2,vars2 = {},{}
				stack_tbl2[1] = info
				vars2[1] = {}
				for i,v in ipairs(stack) do
					stack_tbl2[i+1] = stack[i]
					vars2[i+1] = vars[i]
				end
				stack = stack_tbl2
				vars = vars2
			end
			
			send_debuginfo(debuginfo.source,debuginfo.currentline,stack,vars,false)
		end
		
	local function pmain(scr)

		lanes = require "lanes" --.configure()
		set_finalizer( finalizer_func ) 
		set_error_reporting("extended")
		set_debug_threadname("script_thread")

		

		Debugger = require"sc.debugger"
		--clear linda-------------
		local usedkeys = scriptlinda:count()
		if usedkeys then
			for k,v in pairs(usedkeys) do scriptlinda:set(k) end
		end
		if debugging then
			Debugger:init(Debuggerbp)
		end
				
		return xpcall(function() 
			return runmain(scr) 
		end,xpcallerror)
	end
	
	--DisplayOutput(ToStr(package))
	local script_lane_gen=lanes.gen("*",--"base,math,os,package,string,table",
		{
		cancelstep=10000,
		required={},
		globals={print=thread_print,
				send_debuginfo=send_debuginfo,
				prerror=thread_error_print,
				guiAddWindow=guiAddWindow,
				guiAddControl=guiAddControl,
				guiDeleteControl=guiDeleteControl,
				guiDeletePanel=guiDeletePanel,
				guiEmptyPanel=guiEmptyPanel,
				guiSetValue=guiSetValue,
				guiSetLabel=guiSetLabel,
				guiAddPanel=guiAddPanel,
				guiUpdate=guiUpdate,
				ScriptExit=ScriptExit,
				dodir=dodir,
				openFileSelector=openFileSelector,
				TextToClipBoard=TextToClipBoard,
				--lanes=lanes,
				scriptlinda=scriptlinda,
				mainlinda = mainlinda,
				scriptguilinda=scriptguilinda,
				idlelinda=idlelinda,
				debuggerlinda=debuggerlinda,
				midilinda=midilinda,
				udpsclinda=udpsclinda,
				_sendMidi=pmidi._sendMidi,
				_run_options = file_config:load_table("settings"),--this_file_settings.options,
				_presetsDir=_presetsDir,
				prtable=prtable,
				ToStr=ToStr,
				--addOSCFilter = addOSCFilter,
				--clearOSCFilter = clearOSCFilter
				OSCFunc = OSCFunc,
				OSCFuncLinda = scriptlinda,
				Debuggerbp = Debuggerbp,
				debugging = debugging,
				scriptname = script,
				typerun = typerun,
				typeshed = typeshed,
				sc_comm_type = SCSERVER.type
				},
		priority=0},
		pmain)
		
	script_lane = script_lane_gen(script)
	print("script_lane",script_lane)
end

function CancelScript(timeout)
	local cancelled,reason=script_lane:cancel(timeout)
	return {cancelled,reason}
end
function send_debuginfo(source,line,stack,vars,activate)
	idlelinda:send("debugger",{source,line,stack,vars,activate})
	--idlelinda:send("debugger",{source,line,stack,nil,activate})
end