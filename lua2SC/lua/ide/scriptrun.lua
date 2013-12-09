-- ---------------------------------------------------------------------------
	local ID_RUN              = NewID()
	local ID_DEBUG              = NewID()
	--local ID_DEBUGPLAIN              = NewID()
	local ID_CONTINUE              = NewID()
	local ID_STEPINTO              = NewID()
	local ID_STEPOVER              = NewID()
	local ID_STEPOUT              = NewID()
	local ID_BREAK             = NewID()
	local ID_RUN2              = NewID()
	local ID_RUN3              = NewID()
	local ID_CANCELRUN       = NewID()
	local ID_KILLRUN       = NewID()
	local ID_CLEAROUTPUT      = NewID()
	local ID_SETTINGS              = NewID()
	local ID_SHOWLANES              = NewID()
-- Create the Debug menu and attach the callback functions
function InitRunMenu()
	local debugMenu = wx.wxMenu{
        { ID_RUN,	"&Run Lua2SC\tF6",	"Execute the current file" },
		{ ID_RUN2,              "&Run plain lua\tF7",               "Execute current file" },
		{ ID_RUN3,              "&Run custom",               "Execute current file" },
		{ ID_DEBUG,              "&Debug",               "Debug mode", wx.wxITEM_CHECK},
		--{ ID_DEBUGPLAIN,              "&Debug plain lua",               "Debug the current file" },
		{},
		{ ID_CONTINUE,              "&Continue \tF9",               "Continue debugging" },
		{ ID_STEPINTO,              "&Step into \tF10",               "Step into" },
		{ ID_STEPOVER,              "&Step over \tShift-F10",               "Step over" },
		{ ID_STEPOUT,              "&Step out \tCtrl-F10",               "Step out" },
		{ ID_BREAK,              "&Break ",               "Break" },
		{},

		{ ID_CANCELRUN,              "&Cancel Run\tF5",               "Stops execution" },
		{ ID_KILLRUN,              "&Kill script",               "Stops execution" },
		{ ID_SHOWLANES,              "&Dump lanes",               "Dump lanes" },
        { },
        { ID_CLEAROUTPUT,"C&lear Output Window","Clear the output window before compiling or debugging", wx.wxITEM_CHECK },
        { }, { ID_SETTINGS,    "Settings", "Set running options." }
        }
	function EnableDebugCommands(flag,flagbreak)
		if flagbreak == nil then flagbreak = not flag end
		menuBar:Enable(ID_CONTINUE,flag)
		menuBar:Enable(ID_STEPINTO,flag)
		menuBar:Enable(ID_STEPOUT,flag)
		menuBar:Enable(ID_STEPOVER,flag)
		menuBar:Enable(ID_BREAK,flagbreak)
	end
	menuBar:Append(debugMenu, "&Debug")
	menuBar:Check(ID_CLEAROUTPUT, true)
	menuBar:Check(ID_DEBUG, false)
	EnableDebugCommands(false,false)
	local ID_TIMERBEATREQUEST = 2
	timer = wx.wxTimer(frame,ID_TIMERBEATREQUEST)
	frame:Connect(wx.wxEVT_TIMER,
			function (event)
				local id=event:GetId()
				if id==ID_TIMERBEATREQUEST then
					if script_lane then
						scriptlinda:send("beatRequest",1)
						--timer:Start(300,wx.wxTIMER_ONE_SHOT)
					end
				end
			end)
	frame:Connect(ID_RUN, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				event:Enable((editor ~= nil) and (not script_lane))
			end)
	frame:Connect(ID_DEBUG, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				event:Enable((editor ~= nil) and (not script_lane))
			end)
			--[[
	frame:Connect(ID_DEBUGPLAIN, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				event:Enable((editor ~= nil) and (not script_lane))
			end)
			--]]
	frame:Connect(ID_RUN2, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				event:Enable((editor ~= nil) and (not script_lane))
			end)
	frame:Connect(ID_RUN3, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				event:Enable((editor ~= nil) and (not script_lane))
			end)
	frame:Connect(ID_CANCELRUN, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				event:Enable((editor ~= nil) and (script_lane~=nil))
			end)
	frame:Connect(ID_KILLRUN, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				event:Enable((editor ~= nil) and (script_lane~=nil))
			end)
	
	
	frame:Connect(ID_CANCELRUN,  wx.wxEVT_COMMAND_MENU_SELECTED,
			function(event) 
				--local cancelled=script_lane:cancel(0.1)
				--print("cancelled",cancelled);
				--print("script_lane.status",script_lane.status)
				scriptlinda:send("script_exit",1)
				--debuggerlinda:send("debug_exit",1)
				ClearAllCurrentLineMarkers()
			end)
	frame:Connect(ID_KILLRUN,  wx.wxEVT_COMMAND_MENU_SELECTED,
			function(event)
				if script_lane then
					local cancelled,reason=script_lane:cancel(0.1)
					print("cancelled1",cancelled,reason);
					if cancelled then
						idlelinda:set("prout",{"CANCEL!"})
						--script_lane=nil
						return
					-- else
						-- print("trying to kill")
						-- cancelled,reason=script_lane:cancel(0.1,true)
						-- print("cancelled2",cancelled,reason);
						-- print("script_lane.status",script_lane.status)
						-- if cancelled then --or reason=="killed" then
							-- idlelinda:set("prout",{"ABORT!"})
							-- script_lane=nil
						-- end
					end
					prtable(lanes.threads())
				end
			end)
	frame:Connect(ID_SHOWLANES,  wx.wxEVT_COMMAND_MENU_SELECTED,function() 
			prtable(lanes.threads())
			lindas = {idlelinda,scriptlinda,scriptguilinda,midilinda,udpsclinda,debuggerlinda}
			for i,linda in ipairs(lindas) do
				print("linda",i)
				prtable(linda:count())--,linda:dump())
			end
		end)
	frame:Connect(ID_RUN, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) EnableDebugCommands(false,menuBar:IsChecked(ID_DEBUG)); ScriptRun(1) end)
	--frame:Connect(ID_DEBUG, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) EnableDebugCommands(false); ScriptRun(2) end)
	--frame:Connect(ID_DEBUGPLAIN, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) EnableDebugCommands(false); ScriptRun(4) end)
	frame:Connect(ID_CONTINUE, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) debuggerlinda:send("continue",1); EnableDebugCommands(false);ClearAllCurrentLineMarkers() end)
	frame:Connect(ID_STEPINTO, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) debuggerlinda:send("step_into",1); EnableDebugCommands(false);ClearAllCurrentLineMarkers() end)
	frame:Connect(ID_STEPOVER, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) debuggerlinda:send("step_over",1); EnableDebugCommands(false);ClearAllCurrentLineMarkers() end)
	frame:Connect(ID_STEPOUT, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) debuggerlinda:send("step_out",1); EnableDebugCommands(false);ClearAllCurrentLineMarkers() end)
	frame:Connect(ID_BREAK, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) debuggerlinda:send("break",1) end)
	frame:Connect(ID_RUN2, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) EnableDebugCommands(false,menuBar:IsChecked(ID_DEBUG)); ScriptRun(2) end)
	frame:Connect(ID_RUN3, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) EnableDebugCommands(false,menuBar:IsChecked(ID_DEBUG)); ScriptRun(3) end)
	frame:Connect(ID_SETTINGS, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) Settings:Create(frame).window:Show() end)
	frame:Connect(wx.wxEVT_IDLE,AppIDLE)
end
function ScriptRun(typerun)

	ClearAllCurrentLineMarkers()
	CallStack:Clear()
	if menuBar:IsChecked(ID_CLEAROUTPUT) then
        ClearLog(errorLog)
    end
	local debugging = menuBar:IsChecked(ID_DEBUG)
	local editor = GetEditor()
	local id = editor:GetId()
	-- test compile it before we run it, if successful then ask to save
	
	if not SaveIfModified(editor) then
		return
	end

	-----------------Debugger stuff
	local Debuggerbp
	if debugging then
		Debuggerbp = {breakpoints={}}
		for id, document in pairs(openDocuments) do
				local filePath = document.filePath
                local editor     = document.editor
                local nextLine = editor:MarkerNext(0, BREAKPOINT_MARKER_VALUE)
                while (nextLine ~= -1) do
                    Debuggerbp.breakpoints[nextLine + 1] = Debuggerbp.breakpoints[nextLine + 1] or {}
					Debuggerbp.breakpoints[nextLine +1]["@"..filePath] = true
                    nextLine = editor:MarkerNext(nextLine + 1, BREAKPOINT_MARKER_VALUE)
                end
		end
	else --not debugging
		Debuggerbp = {}
	end
	----------------------------------------
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
	--[[
	local function addOSCFilter(path,template,func,runonce)
		OSCFunc.newfilter(path,template,func,runonce)
	end
	local function clearOSCFilter(path,template)
		OSCFunc.clearfilters(path,template)
	end
	--]]
	--------------------------------------------------------
	local function main_lanes(script)

		--clear linda-------------
		repeat
			local key,val= scriptlinda:receive(0,"script_exit","/metronom","metronomLanes","beat","tempo","play","beatRequest","_valueChangedCb","_midiEventCb")
			--print("xxxxxxxxxxxxxxxxxxxxxxMain clear linda",key)
		until val==nil

		if debugging then
			--prtable(Debugger)
			Debugger:init(Debuggerbp)
		end
		
		require("sc.init")

		theMetro.playNotifyCb[#theMetro.playNotifyCb+1] = function(met) 
				idlelinda:send("Metro",met) 
			end

		local fs,err = loadfile(script)
		if fs then 
			fs() 
		else 
			error("loadfile error:"..tostring(err),2) 
		end
		
		_initCb()

		while true do
			--local dgram,status = udp2:receive()
			--from the gui (editor and scriptgui)
			local key,val= scriptlinda:receive("script_exit","tempo","play","/metronom","metronomLanes","beat","beatRequest","_valueChangedCb","_midiEventCb","OSCReceive")
			if val then
				--print("xxxxxxxxxxxxrequired linda: ",key," : ",val)
				if key=="beat" then
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
					break
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
			end
		end
		
		if _resetCb then
			print("SCRIPT: to reset\n")
			_resetCb()
		end
		return true
	end
	
	local function main_lanes_custom(script)
		--clear linda-------------
		repeat
			local key,val= scriptlinda:receive(0,"script_exit","/metronom","metronomLanes","beat","tempo","play","beatRequest","_valueChangedCb","_midiEventCb")
			--print("xxxxxxxxxxxxxxxxxxxxxxMain clear linda",key)
		until val==nil

		if debugging then
			Debugger:init(Debuggerbp)
		end
		
		function lanesloop(wait)
			local key,val= scriptlinda:receive(wait or 0,"script_exit","tempo","play","/metronom","metronomLanes","beat","beatRequest","_valueChangedCb","_midiEventCb","OSCReceive")
			if key then
				--print("xxxxxxxxxxxxrequired linda: ",key," : ",val)
				if key=="beat" then
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
		if debugging then
			Debugger:init(Debuggerbp)
		end
		dofile(script)
		return true
	end
	
	--CloseScriptGUI()
	ClearScriptGUI()
	--CreateScriptGUI()
	
	local runmain=nil
	if typerun ==1 then
		timer:Start(300,wx.wxTIMER_ONE_SHOT)
		--manager:GetPane(panel):Show()
		runmain=main_lanes --pmain --main_lanes
	elseif typerun == 2 then
		--manager:GetPane(panel):Hide()
		runmain=main_lanes_plain
	elseif typerun == 3 then
		--manager:GetPane(panel):Hide()
		runmain=main_lanes_custom
	end
	
	local function xpcallerror(err) 
			io.stderr:write("from xpcall error required to cancel "..tostring(err).."\n")
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
			prerror("xpcallerror:"..tostring(err)) 
			io.stderr:write("xpcallerror:"..tostring(err))
			-- function to get errors in required files
			local function compile_error(err)
				local info = {}
				--catch error from require
				local err2 = err:match("from file%s+'.-':.-([%w%p]*:%d+:)")
				--catch error from loadfile
				if not err2 then
					err2 = err:match("loadfile error:([%w%p]*:%d+:)")
				end
				if err2 then
					info.source = "@"..err2:match(":-(.-):%d*:")
					info.currentline = err2:match(":(%d*):")
					return info
				end
			end
			
			local debuginfo = debug.getinfo(2,"Slf")
			local stack,vars = Debugger.get_call_stack(3)
			
			-- if there is a compile error add it to stack and vars
			local info=compile_error(err)
			if (info) then
				io.stderr:write("comp err source: ",info.source)
				io.stderr:write("comp err line: ",info.currentline)
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
				scriptguilinda=scriptguilinda,
				idlelinda=idlelinda,
				debuggerlinda=debuggerlinda,
				midilinda=midilinda,
				udpsclinda=udpsclinda,
				_sendMidi=pmidi._sendMidi,
				_run_options=Settings.options,
				_presetsDir=_presetsDir,
				prtable=prtable,
				ToStr=ToStr,
				--addOSCFilter = addOSCFilter,
				--clearOSCFilter = clearOSCFilter
				OSCFunc = OSCFunc,
				OSCFuncLinda = scriptlinda,
				Debuggerbp = Debuggerbp,
				debugging = debugging,
				typerun = typerun
				},
		priority=0},
		pmain)
		
	script_lane=script_lane_gen(openDocuments[id].filePath)
end