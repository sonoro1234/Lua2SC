	local ID_DUMPTREE       = NewID()
	local ID_DUMPOSC       = NewID()
	local ID_BOOTSC       = NewID()
    local ID_BOOTSC_tcp       = NewID()
	local ID_BOOTSC_internal       = NewID()
	local ID_QUITSC       = NewID()
	local ID_AUTODETECTSC       = NewID()
	
local SCProcess
function InitSCMenu()

	local SCMenu = wx.wxMenu{
		{ ID_DUMPTREE,              "Dump SC Tree",               "Dumps SC Tree in SC console" },
		{ ID_DUMPOSC,              "Dump OSC",               "Dumps OSC" , wx.wxITEM_CHECK },
		{ ID_BOOTSC,              "Boot SC",               "Boots SC" },
		{ ID_BOOTSC_tcp,              "Boot SC TCP",               "Boots SC TCP" },
		{ ID_BOOTSC_internal,              "Boot SC internal",               "Boots SC internal" },
		{ ID_QUITSC,              "Quit SC",               "Quits SC" },
		{ ID_AUTODETECTSC,              "Autodetect SC",               "Autodetect SC", wx.wxITEM_CHECK  },
        }
	menuBar:Append(SCMenu, "&Supercollider")
	frame:Connect(ID_DUMPTREE,  wx.wxEVT_COMMAND_MENU_SELECTED,
		function(event) 
			--linda:send("dumpTree",1)
			IDESCSERVER:dumpTree(true)	
		end)
	frame:Connect(ID_DUMPOSC,  wx.wxEVT_COMMAND_MENU_SELECTED,
		function(event) 
			--linda:send("dumpTree",1)
			IDESCSERVER:dumpOSC(event:IsChecked())	
		end)
	frame:Connect(ID_AUTODETECTSC,  wx.wxEVT_COMMAND_MENU_SELECTED,
		function(event) 
			if event:IsChecked() then
                if not IDESCSERVER.inited then
                    IDESCSERVER:init("tcp",file_settings:load_table("settings"),mainlinda)
                end
                udpsclinda:send("Detect",1)
				--IDESCSERVER:sync()
				lanes.timer(idlelinda,"statusSC",1,0)
			else
				--while idlelinda:receive(0,"statusSC") do end
                idlelinda:set("statusSC")
				lanes.timer(idlelinda,"statusSC")
				--idlelinda:receive(0,"statusSC")
			end
		end)
	frame:Connect(ID_BOOTSC,  wx.wxEVT_COMMAND_MENU_SELECTED,function() return BootSC(false) end)
    frame:Connect(ID_BOOTSC_tcp,  wx.wxEVT_COMMAND_MENU_SELECTED,function() return BootSC(true) end)
	frame:Connect(ID_BOOTSC_internal,  wx.wxEVT_COMMAND_MENU_SELECTED,function() 
		local this_file_settings = file_settings:load_table("settings")
		if this_file_settings.SC_SYNTHDEF_PATH~="default" then
			wx.wxSetEnv("SC_SYNTHDEF_PATH",this_file_settings.SC_SYNTHDEF_PATH)
		end
		IDESCSERVER:init("internal",this_file_settings,mainlinda)
		ClearLog(ScLog)
		lanes.timer(idlelinda,"statusSC",1,0)
	end)
	
	frame:Connect(ID_QUITSC,  wx.wxEVT_COMMAND_MENU_SELECTED,function(event)
				IDESCSERVER:quit()
				IDESCSERVER:close()
				if SCProcess then
					io.write("trying to join SCProcess\n")
					local res,err = SCProcess:join(4)
					if res == nil then
						print("Error on SCProcess join:",err or "timeout")
						SCProcess = nil
					else
						print("SCProcess.status",SCProcess.status)
						SCProcess = nil
					end
				end
				--[[
				if SCProcess then
					local c,er = SCProcess:cancel(0.3)
					print("SCProcess",c,er)
					print("SCProcess",SCProcess.status)
					if c then
						SCProcess=nil
					end
				end
				--]]
				prtable(lanes.threads())
			end)
	frame:Connect(ID_DUMPTREE, wx.wxEVT_UPDATE_UI,
			function (event)
				event:Enable(IDESCSERVER.inited~=nil)
			end)
	frame:Connect(ID_DUMPOSC, wx.wxEVT_UPDATE_UI,
			function (event)
				event:Enable(IDESCSERVER.inited~=nil)
			end)
	frame:Connect(ID_BOOTSC, wx.wxEVT_UPDATE_UI,
			function (event)
				event:Enable(IDESCSERVER.inited==nil)
			end)
    frame:Connect(ID_BOOTSC_tcp, wx.wxEVT_UPDATE_UI,
			function (event)
				event:Enable(IDESCSERVER.inited==nil)
			end)
	frame:Connect(ID_BOOTSC_internal, wx.wxEVT_UPDATE_UI,
			function (event)
				event:Enable(jit and IDESCSERVER.inited==nil)
			end)

end
function SCProcess_Loop(cmd,bootedlinda)
    local exe,err
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
	print("begin sc loop ....")
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
    bootedlinda:send("booted",1)
	repeat
		--print(stdout:read("*all") or stderr:read("*all") or "nil")
		exe:flush()
		--io.write("reading line bootsc\n")
		local line=exe:read("*l")
		if line then
			--io.write(line .."\n")
			print(line)
		else
			--io.write("server finished\n")
			print("server finished")
			return true
		end
		--exe:flush()
	until false
	return true
end		
require"lanesutils"
function BootSC(use_tcp) 
	
	local this_file_settings = file_settings:load_table("settings")
	local path = wx.wxFileName.SplitPath(this_file_settings.SCpath)
	wx.wxSetWorkingDirectory(path)
	wx.wxSetEnv("SC_SYSAPPSUP_PATH",path) 
	if this_file_settings.SC_SYNTHDEF_PATH~="default" then
		wx.wxSetEnv("SC_SYNTHDEF_PATH",this_file_settings.SC_SYNTHDEF_PATH)
	end
	local plugpath=[[ -U ]]..[["]]..path..[[/plugins"]]
	local plugpathsep = jit.os=="Windows" and ";" or ":"
	for i,v in ipairs(this_file_settings.SC_PLUGIN_PATH) do
		if(v=="default") then
		else	
			plugpath=plugpath..plugpathsep..[["]]..v..[["]]
		end
	end
	if #this_file_settings.SC_PLUGIN_PATH==0 then
		plugpath = ""
	end
	local numcores_option = ""
    if string.match(this_file_settings.SCpath,".*supernova[^"..path_sep.."]") then
		numcores_option = " -T 4 "
	end
    local systemclock_option = " -C "..this_file_settings.SC_SYSTEM_CLOCK.." "
	local audio_dev_option = " "
	if this_file_settings.SC_AUDIO_DEVICE ~= "" then
		audio_dev_option = [[ -H "]]..this_file_settings.SC_AUDIO_DEVICE..[[" ]]
	end
	
	local cmd=[[""]]..this_file_settings.SCpath..[["]]..systemclock_option..(use_tcp and [[ -t ]] or [[ -u ]])..this_file_settings.SC_UDP_PORT..[[ -o ]]..this_file_settings.SC_NOUTS..[[ -i ]]..this_file_settings.SC_NINS..[[ -Z ]]..this_file_settings.SC_BUFFER_SIZE..audio_dev_option..plugpath..numcores_option..
	[[ -m 65536]]
	--[[ -m 4096]]
	..[[ 2>&1"]]
	--local cmd=[["]]..this_file_settings.options.SCpath..[["]]	
	print(cmd)
	local function sc_print(...)
		--local str=""
		--for i=1, select('#', ...) do
		--	str = str .. tostring(select(i, ...))
		--end
		--str = str .. "\n"
		--io.write(table.concat({...}).."\n")
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
        --function(cmd) os.execute(cmd) end)
		SCProcess_Loop)
        
    local bootedlinda = lanes.linda()
	SCProcess= process_gen(cmd,bootedlinda)

	if not SCProcess then
		wx.wxMessageBox("Could not boot scsynth.")
		SCProcess=nil
	else
        local key,val = bootedlinda:receive(3,"booted")
        if not key then print"sc not booted in 3 seconds" end
        --wait(1)
        local typeserver = use_tcp and "tcp" or "udp"
        IDESCSERVER:init(typeserver,file_settings:load_table("settings"),mainlinda)
		ClearLog(ScLog)
		udpsclinda:send("Detect",1)
		--lanes.timer(idlelinda,"statusSC",1,0)
	end
	menuBar:Check(ID_DUMPOSC, false)
	
end
		
--[[
function QuitSC()
	if SCProcess then
		DisplayLog(string.format("Trying to kill process scproces \n"),ScLog)
		while idlelinda:receive(0,"statusSC") do end
		lanes.timer(idlelinda,"statusSC",0)
		idlelinda:receive(0,"statusSC")
		SCProcess:cancel(1)
	end
end
--]]