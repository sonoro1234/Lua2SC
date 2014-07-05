	local ID_DUMPTREE       = NewID()
	local ID_DUMPOSC       = NewID()
	local ID_BOOTSC       = NewID()
	local ID_BOOTSC_internal       = NewID()
	local ID_QUITSC       = NewID()
	local ID_AUTODETECTSC       = NewID()

function InitSCMenu()

	local SCMenu = wx.wxMenu{
		{ ID_DUMPTREE,              "Dump SC Tree",               "Dumps SC Tree in SC console" },
		{ ID_DUMPOSC,              "Dump OSC",               "Dumps OSC" , wx.wxITEM_CHECK },
		{ ID_BOOTSC,              "Boot SC",               "Boots SC" },
		{ ID_BOOTSC_internal,              "Boot SC internal",               "Boots SC internal" },
		{ ID_QUITSC,              "Quit SC",               "Quits SC" },
		{ ID_AUTODETECTSC,              "Autodetect SC",               "Autodetect SC", wx.wxITEM_CHECK  },
        }
	menuBar:Append(SCMenu, "&Supercollider")
	frame:Connect(ID_DUMPTREE,  wx.wxEVT_COMMAND_MENU_SELECTED,
		function(event) 
			--linda:send("dumpTree",1)
			SCSERVER:dumpTree(true)	
		end)
	frame:Connect(ID_DUMPOSC,  wx.wxEVT_COMMAND_MENU_SELECTED,
		function(event) 
			--linda:send("dumpTree",1)
			SCSERVER:dumpOSC(event:IsChecked())	
		end)
	frame:Connect(ID_AUTODETECTSC,  wx.wxEVT_COMMAND_MENU_SELECTED,
		function(event) 
			if event:IsChecked() then
				SCSERVER:sync()
				lanes.timer(idlelinda,"statusSC",1,0)
			else
				while idlelinda:receive(0,"statusSC") do end
				lanes.timer(idlelinda,"statusSC",0)
				idlelinda:receive(0,"statusSC")
			end
		end)
	frame:Connect(ID_BOOTSC,  wx.wxEVT_COMMAND_MENU_SELECTED,BootSC)
	frame:Connect(ID_BOOTSC_internal,  wx.wxEVT_COMMAND_MENU_SELECTED,function() 
		SCSERVER:init("internal",file_settings:load_table("settings"),mainlinda)
		ClearLog(ScLog)
		lanes.timer(idlelinda,"statusSC",1,0)
	end)
	frame:Connect(ID_QUITSC,  wx.wxEVT_COMMAND_MENU_SELECTED,function(event)
				SCSERVER:quit()
				SCSERVER:close()
				if SCProcess then
					local c,er = SCProcess:cancel(0.3)
					print("SCProcess",c,er)
					print("SCProcess",SCProcess.status)
					if c then
						SCProcess=nil
					end
				end
				prtable(lanes.threads())
			end)
	frame:Connect(ID_DUMPTREE, wx.wxEVT_UPDATE_UI,
			function (event)
				event:Enable(SCSERVER.inited~=nil)
			end)
	frame:Connect(ID_DUMPOSC, wx.wxEVT_UPDATE_UI,
			function (event)
				event:Enable(SCSERVER.inited~=nil)
			end)
	frame:Connect(ID_BOOTSC, wx.wxEVT_UPDATE_UI,
			function (event)
				event:Enable(SCProcess==nil)
			end)
	frame:Connect(ID_BOOTSC_internal, wx.wxEVT_UPDATE_UI,
			function (event)
				event:Enable(jit and SCProcess==nil)
			end)
	-- frame:Connect(ID_QUITSC, wx.wxEVT_UPDATE_UI,
			-- function (event)
				-- event:Enable(SCProcess~=nil)
			-- end)
end
function SCProcess_Loop(cmd)
	local lanes = require "lanes" --.configure()
	local function prstak(stk)
		local str=""
		for i,lev in ipairs(stk) do
			str= str..i..": \n"
			for k,v in pairs(lev) do
				str=str.."\t["..k.."]:"..v.."\n"
			end
		end
		print(str)
	end
	
	local function finalizer_func(err,stk)
		print("SCProcess_Loop finalizer:")
		if err and type(err)~="userdata" then 
			print( "after error: "..tostring(err) )
			print("finalizer stack table")
			prstak(stk)
		elseif type(err)=="userdata" then
			print( "after cancel " )
		else
			print( "after normal return" )
		end
		if exe then exe:close() end
		print( "finalizer ok" )
	end
	print("soy sc loop ....")
	set_finalizer( finalizer_func ) 
	set_error_reporting("extended")
	set_debug_threadname("SCProcess_Loop")
	
	exe,err=io.popen(cmd)
	if not exe then
		print("Could not popen. Error: ",err)
		return false
	else
		--print("Command run successfully... ready!")
		exe:setvbuf("no")
	end
	repeat
		--print(stdout:read("*all") or stderr:read("*all") or "nil")
		exe:flush()
		--io.write("reading line bootsc\n")
		local line=exe:read("*l")
		if line then
			print(line)
		else
			return false
		end
		--exe:flush()
	until false
end		

function BootSC() 
	SCSERVER:init("udp",file_settings:load_table("settings"),mainlinda)
	
	local this_file_settings = file_settings:load_table("settings")
	local path = wx.wxFileName.SplitPath(this_file_settings.SCpath)
	wx.wxSetWorkingDirectory(path)
	wx.wxSetEnv("SC_SYSAPPSUP_PATH",path) 
	if this_file_settings.SC_SYNTHDEF_PATH~="default" then
		wx.wxSetEnv("SC_SYNTHDEF_PATH",this_file_settings.SC_SYNTHDEF_PATH)
	end
	local plugpath=[["]]..path..[[/plugins"]]
	for i,v in ipairs(this_file_settings.SC_PLUGIN_PATH) do
		if(v=="default") then
		else	
			plugpath=plugpath..[[;"]]..v..[["]]
		end
	end
	--local cmd="\"\""..this_file_settings.options.SCpath.."\"".." -u "..this_file_settings.options.SC_UDP_PORT.." -H ASIO ".."-U \""..path.."\\plugins\"\""
	local cmd=[[""]]..this_file_settings.SCpath..[["]]..[[ -v 2 ]]..[[ -u ]]..this_file_settings.SC_UDP_PORT..[[ -o 2 -i 2 ]]..[[ -H "]]..this_file_settings.SC_AUDIO_DEVICE..[[" -U ]]..plugpath..[[ -m 65536]]..[[ 2>&1"]]
	--local cmd=[["]]..this_file_settings.options.SCpath..[["]]	
	print(cmd)
	local function sc_print(...)
		--local str=""
		--for i=1, select('#', ...) do
		--	str = str .. tostring(select(i, ...))
		--end
		--str = str .. "\n"
		idlelinda:send("proutSC",table.concat({...}).."\n")
	end
	local process_gen=lanes.gen("*",--"base,math,os,package,string,table",
		{
		cancelstep=10000,
		required={},
		globals={
				print=sc_print,
				idlelinda=idlelinda,
				--lanes=lanes,
				--linda=linda
				},
		priority=0},
		SCProcess_Loop)

	SCProcess=process_gen(cmd)
	
	if not SCProcess then
		wx.wxMessageBox("Could not boot scsynth.")
		SCProcess=nil
	else
		ClearLog(ScLog)
		udpsclinda:send("Detect",1)
		lanes.timer(idlelinda,"statusSC",1,0)
	end
	menuBar:Check(ID_DUMPOSC, false)
	
end
		
function QuitSC()
	if SCProcess then
		DisplayLog(string.format("Trying to kill process scproces \n"),ScLog)
		while idlelinda:receive(0,"statusSC") do end
		lanes.timer(idlelinda,"statusSC",0)
		idlelinda:receive(0,"statusSC")
		SCProcess:cancel(1)
	end
end