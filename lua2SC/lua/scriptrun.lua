-- ---------------------------------------------------------------------------
local USE_PROFILE = false

local function MsgLoop()
	while true do
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
				OSCFunc.handleOSCReceive(val)
			elseif key=="execstr" then 
				local chunk,err = loadstring(val)
				if chunk then
					local t = {pcall(chunk)}
					if t[1] then 
						print(unpack(t)) 
					else
						prerror(unpack(t))
					end
				else
					print("error in exestr:",err)
				end
			end
		end
	end
end

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
			prtable(stk)
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
			if (typev=="number") or (typev=="string") or (typev=="boolean") then
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

		require("sc.init")

		local fs,err = loadfile(script)
		if fs then 
			fs() 
		else 
			for i=2,math.huge do
				local debuginfo = debug.getinfo(i,"Snlf")
				if not debuginfo then break end
				io.stderr:write("aaa"..ToStr(debuginfo).."\n")
			end
			--error("loadfile error:"..tostring(err),2)
			error("loadfile error:"..script..(err:match("(:%d*:)") or ":-1:")..err:match(":%d*:(.+)"),2) 
		end
		
		_initCb()
		
		local profile,pr
		if USE_PROFILE then
			ProFi = require 'ProFi'
			ProFi:start()
			
			-- profile = require("jit.profile")
			-- pr = {}
			-- profile.start("f", function(th, samples, vmmode)
				-- local d = profile.dumpstack(th, "f", 1)
				-- pr[d] = (pr[d] or 0) + samples
			-- end)
			
			--require("jit.p").start("3vfsi4m1")--,lua2scpath..'profReport.txt')
		end

		MsgLoop()
		
		if USE_PROFILE then
			ProFi:stop()
			ProFi:writeReport( lua2scpath..'MyProfilingReport.txt' )
			
			-- profile.stop()
			-- print"luaJIT profiler:-----------------------"
			-- for d,v in pairs(pr) do print(v, d) end
			-- print"luaJIT profiler end:-----------------------"
			
			--require("jit.p").stop()
		end

		if _resetCb then
			print("SCRIPT: to reset\n")
			_resetCb()
		end
		return true
	end
	
	local function main_lanes_custom(script)

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
	
	local function main_lanes_plain(script)
		dofile(script)
		return true
	end
	
	local runmain = nil
	if typerun ==1 then
		runmain = main_lanes --pmain --main_lanes
	elseif typerun == 2 then
		runmain = main_lanes_plain
	elseif typerun == 3 then
		runmain = main_lanes_custom
	end
	
	local function xpcallerror(err) 
			io.stderr:write("xpcallerror: "..tostring(err).."\n")
			io.stderr:write(debug.traceback())
			--detect recursive error
			io.stderr:write("\ndebug.getinfo:\n")
			for i=2,math.huge do
				local debuginfo = debug.getinfo(i,"Snlf")
				if not debuginfo then break end
				io.stderr:write(ToStr(debuginfo).."\n")
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
			local function compile_error(err,iscompileerr)
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
				if not err2 and iscompileerr then err2 = err end
				if err2 then
					info.source = "@"..err2:match(":-(.-):%d*:")
					info.currentline = err2:match(":(%d*):") or -1
					return info
				end
			end
			local debuginfo = debug.getinfo(2,"Slf")
			local stack,vars = Debugger:get_call_stack(3)
			print("is require?",debuginfo.func == require)
			print("is dofile?",debuginfo.func == dofile)
			print("is loadfile?",debuginfo.func == loadfile)
			local is_comp_err = debuginfo.func == require or debuginfo.func == dofile or debuginfo.func == loadfile
			-- if there is a compile error add it to stack and vars
			local info = compile_error(err,is_comp_err)
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
		
	local function pmain(scr,numberrun)

		lanes = require "lanes" --.configure()
		set_finalizer( finalizer_func ) 
		set_error_reporting("extended")
		set_debug_threadname("script_thread"..numberrun)

		Debugger = require"sc.debugger"
		--clear linda-------------
		local usedkeys = scriptlinda:count()
		if usedkeys then
			for k,v in pairs(usedkeys) do scriptlinda:set(k) end
		end
		if debugging then
			Debugger:init(Debuggerbp) --,3)
		end
				
		return xpcall(function() 
			return runmain(scr) 
		end,xpcallerror)
	end
	
	--DisplayOutput(ToStr(package))
	local script_lane_gen=lanes.gen("*",--"base,math,os,package,string,table",
		{
		cancelstep=100,
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
				--OSCFunc = OSCFunc,
				OSCFuncLinda = scriptlinda,
				Debuggerbp = Debuggerbp,
				debugging = debugging,
				scriptname = script,
				typerun = typerun,
				typeshed = typeshed,
				sc_comm_type = SCSERVER.type,
				MsgLoop = MsgLoop,
                lua2scpath = lua2scpath
				},
		priority=0},
		pmain)
	n_scriptrun = n_scriptrun + 1
	script_lane = script_lane_gen(script,tostring(n_scriptrun))
	print("script_lane",script_lane)
end

function CancelScript(timeout,forced,forced_timeout)
	local cancelled,reason=script_lane:cancel(timeout,forced,forced_timeout)
	io.write("CancelScript "..tostring(cancelled).." "..tostring(reason).."\n")
	
	local t0,st= os.time()
	while os.time()-t0 < timeout do
		st= script_lane.status
		io.stderr:write( '.' )
		if st~="running" then 
			io.stderr:write( st..'\n' )
			cancelled= true
			break 
		end
	end
	return {cancelled,reason}
end
function send_debuginfo(source,line,stack,vars,activate)
	idlelinda:send("debugger",{source,line,stack,vars,activate})
	--idlelinda:send("debugger",{source,line,stack,nil,activate})
end