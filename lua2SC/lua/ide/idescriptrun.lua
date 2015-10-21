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
	local ID_RUN_SELECTED             = NewID()
	local ID_CANCELRUN       = NewID()
	local ID_KILLRUN       = NewID()
	local ID_CLEAROUTPUT      = NewID()
	local ID_SETTINGS              = NewID()
	local ID_SHOWLANES              = NewID()
	local ID_PREMETRO              = NewID()
-- Create the Debug menu and attach the callback functions
function InitRunMenu()
	local debugMenu = wx.wxMenu{
        { ID_RUN,	"&Run Lua2SC\tF6",	"Execute the current file" },
		{ ID_RUN2,              "&Run plain lua\tF7",               "Execute current file" },
		{ ID_RUN3,              "&Run custom",               "Execute current file" },
		{ ID_RUN_SELECTED,              "&Run selected text\tF8",               "Run selected text" },
		{ ID_DEBUG,              "&Debug",               "Debug mode", wx.wxITEM_CHECK},
		{ ID_PREMETRO,              "&SCHMETRO",               "SCHMETRO mode", wx.wxITEM_CHECK},
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
	--[[
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
	--]]
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
	frame:Connect(ID_RUN_SELECTED, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				event:Enable((editor ~= nil) and (script_lane))
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
				ClearScriptGUI()
				scriptlinda:send("script_exit",1)
				debuggerlinda:send("debug_exit",1)
				ClearAllCurrentLineMarkers()
			end)
	frame:Connect(ID_KILLRUN,  wx.wxEVT_COMMAND_MENU_SELECTED,
			function(event)
				if script_lane then
					--local cancelled,reason=script_lane:cancel(0.1)
					local cancelled,reason = ideCancelScript(0.1)
					print("cancelled1",cancelled,reason);
					if cancelled then
						idlelinda:set("prout",{"softCANCEL!"})
						--script_lane=nil
						return
					elseif canceled == false then
						print("trying to kill",reason)
						-- cancelled,reason=script_lane:cancel(0.1,true)
						-- print("cancelled2",cancelled,reason);
						-- print("script_lane.status",script_lane.status)
						-- if cancelled then --or reason=="killed" then
							-- idlelinda:set("prout",{"ABORT!"})
							-- script_lane=nil
						-- end
                    elseif canceled == nil then
                        print("linda timeout in CANCEL")
					end
					prtable(lanes.threads())
				end
			end)
	frame:Connect(ID_SHOWLANES,  wx.wxEVT_COMMAND_MENU_SELECTED,function() 
			prtable(lanes.threads())
			--lindas = {idlelinda,scriptlinda,scriptguilinda,midilinda,udpsclinda,debuggerlinda}
			for i,linda in ipairs(lindas) do
				print("linda",linda)
				prtable(linda:count())--,linda:dump())
			end
		end)
	frame:Connect(ID_RUN, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) EnableDebugCommands(false,menuBar:IsChecked(ID_DEBUG)); ideScriptRun(1) end)
	frame:Connect(ID_CONTINUE, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) debuggerlinda:send("continue",1); EnableDebugCommands(false);ClearAllCurrentLineMarkers() end)
	frame:Connect(ID_STEPINTO, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) debuggerlinda:send("step_into",1); EnableDebugCommands(false);ClearAllCurrentLineMarkers() end)
	frame:Connect(ID_STEPOVER, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) debuggerlinda:send("step_over",1); EnableDebugCommands(false);ClearAllCurrentLineMarkers() end)
	frame:Connect(ID_STEPOUT, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) debuggerlinda:send("step_out",1); EnableDebugCommands(false);ClearAllCurrentLineMarkers() end)
	frame:Connect(ID_BREAK, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) debuggerlinda:send("break",1) end)
	frame:Connect(ID_RUN2, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) EnableDebugCommands(false,menuBar:IsChecked(ID_DEBUG)); ideScriptRun(2) end)
	frame:Connect(ID_RUN3, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) EnableDebugCommands(false,menuBar:IsChecked(ID_DEBUG)); ideScriptRun(3) end)
	frame:Connect(ID_RUN_SELECTED, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) 
				local editor = GetEditor()
				local strcode = editor:GetSelectedText()
				if strcode then
					scriptlinda:send("execstr",strcode)
				end
			end)
	frame:Connect(ID_SETTINGS, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) Settings:Create(frame).window:Show() end)
	frame:Connect(wx.wxEVT_IDLE,AppIDLE)
end
function ideScriptRun(typerun)

	ClearAllCurrentLineMarkers()
	CallStack:Clear()
    idlelinda:set("prout")
	if menuBar:IsChecked(ID_CLEAROUTPUT) then
        ClearLog(errorLog)
    end
	local debugging = menuBar:IsChecked(ID_DEBUG)
	local typeshedpremetro = menuBar:IsChecked(ID_PREMETRO)
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
	
	ClearScriptGUI()
		
	mainlinda:send("ScriptRun",{typerun=typerun,Debuggerbp=Debuggerbp,debugging=debugging,script=openDocuments[id].filePath,typeshed=typeshedpremetro})
	----------------------------------------
	--if typerun == 1 then
		---timer:Start(300,wx.wxTIMER_ONE_SHOT)
		--lanes.timer(scriptlinda, "beatRequest",0.3,0)
	--end
	script_lane = true 
end

function ideCancelScript(time,forced,forced_timeout)
		local tmplinda=lanes.linda()
		mainlinda:send("CancelScript",{timeout=time,forced=forced,forced_timeout=forced_timeout,tmplinda=tmplinda})
		local key,val=tmplinda:receive(3,"CancelScriptResp")
		if key then
			return unpack(val)
		else --timeout
			return nil
		end
end