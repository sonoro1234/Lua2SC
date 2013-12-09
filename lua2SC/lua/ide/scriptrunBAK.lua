function ScriptRun(typerun)

	ClearAllCurrentLineMarkers()
	CallStack:Clear()
	if menuBar:IsChecked(ID_CLEAROUTPUT) then
        ClearLog(errorLog)
    end
	local editor = GetEditor()
	local id = editor:GetId()
	-- test compile it before we run it, if successful then ask to save
	
	if not SaveIfModified(editor) then
		return
	end

	-----------------Debugger stuff
	local Debugger
	if typerun==2 then
		Debugger = {breakpoints={}}
		for id, document in pairs(openDocuments) do
				local filePath = document.filePath
                local editor     = document.editor
                local nextLine = editor:MarkerNext(0, BREAKPOINT_MARKER_VALUE)
                while (nextLine ~= -1) do
                    Debugger.breakpoints[nextLine + 1] = Debugger.breakpoints[nextLine + 1] or {}
					Debugger.breakpoints[nextLine +1]["@"..filePath] = true
                    nextLine = editor:MarkerNext(nextLine + 1, BREAKPOINT_MARKER_VALUE)
                end
		end
	else --not debugging
		Debugger = nil
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
		--local 
		lanes = require "lanes" --.configure()
		set_finalizer( finalizer_func ) 
		set_error_reporting("extended")
		set_debug_threadname("script_thread")
		--clear linda-------------
		repeat
			local key,val= scriptlinda:receive(0,"script_exit","/metronom","metronomLanes","beat","tempo","play","beatRequest","_valueChangedCb","_midiEventCb")
			--print("xxxxxxxxxxxxxxxxxxxxxxMain clear linda",key)
		until val==nil
		--------------
		if typerun == 2 then
			require"sc.debugger"
		end
		require("sc.init")
		--if typerun==1 then
			theMetro.playNotifyCb[#theMetro.playNotifyCb+1] = function(met) 
				idlelinda:send("Metro",met) 
				end
		--end
		--dofile(script)
		local fs,err = loadfile(script)
		if fs then 
			fs() 
		else 
			--print("loadfile error:",err)
			error("loadfile error:"..tostring(err),2) 
		end
		_initCb()
		--idlelindabb:send("Metro",theMetro)
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
				if cancel_test() then
					io.stderr:write("required to cancel\n")
					break
				end
		end
		print("SCRIPT: to reset\n")
		if _resetCb then
			_resetCb()
		end
		return true
	end
	local function main_lanes_plain(script)
		--local 
		lanes = require "lanes" --.configure()
		set_finalizer(function (err,stk)
		if err and type(err)~="userdata" then 
			prerror( "SCRIPT: plain script finalizer after error: ")
			local onlyerrorst=err:match(":%d+:(.+)")
			prerror(tostring(err).."\n"..tostring(onlyerrorst) )
		elseif type(err)=="userdata" then
			print( "SCRIPT: plain script finalizer after cancel " )
		else
			print( "SCRIPT: plain script finalizer after normal return" )
			print("SCRIPT: finalizer ok")
		end
	end ) 
		set_error_reporting("extended")
		set_debug_threadname("script_thread")
		
		dofile(script)
		
		return true
	end
	--CloseScriptGUI()
	ClearScriptGUI()
	--CreateScriptGUI()
	--[[
	local function pmain(scr)
		if not xpcall(function() 
			main_lanes(scr) 
		end) then debuglocals(true);error() end
	end
	--]]
	local function pmain(scr)
		return xpcall(function() 
			main_lanes(scr) 
		end,function(err) print(err) debuglocals(true) end)
	end
	
	
	local runmain=nil
	if typerun==1 or typerun==2 then
		timer:Start(300,wx.wxTIMER_ONE_SHOT)
		--manager:GetPane(panel):Show()
		runmain=pmain --main_lanes
	elseif typerun==3 then
		--manager:GetPane(panel):Hide()
		runmain=main_lanes_plain
	end
	--DisplayOutput(ToStr(package))
	local script_lane_gen=lanes.gen("*",--"base,math,os,package,string,table",
		{
		cancelstep=false,
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
				_sendMidi=pmidi._sendMidi,
				_run_options=Settings.options,
				_presetsDir=_presetsDir,
				prtable=prtable,
				ToStr=ToStr,
				--addOSCFilter = addOSCFilter,
				--clearOSCFilter = clearOSCFilter
				OSCFunc = OSCFunc,
				OSCFuncLinda = scriptlinda,
				Debugger = Debugger
				--pmidi=pmidi
				},
		priority=0},
		runmain)
		
	script_lane=script_lane_gen(openDocuments[id].filePath)
end