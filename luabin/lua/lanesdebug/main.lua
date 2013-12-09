--1) lua main.lua
--2) type break
--3) type step_over
--4) type quit to exit

lanes = require"lanes".configure()
local outlinda = lanes.linda()
debuggerlinda = lanes.linda()

local function prstack(stk)
		local str=""
		for i,lev in ipairs(stk) do
			str= str..i..": \n"
			for k,v in pairs(lev) do
				str=str.."\t["..k.."]:"..v.."\n"
			end
		end
		print(str)
end

local function send_debuginfo(source,line,stack,vars)
	outlinda:send("debugger",{source,line,stack,vars})
end

function debugscript()
	lanes = require"lanes"
	set_finalizer(function (err,stk)
			if err  and type(err)~="userdata" then 
				print( "script_thread error: "..tostring(err) )
				prstack(stk)
			elseif type(err)=="userdata" then 
				print( "script_thread after cancel" )
			else
				print("script_thread finalized")
			end	
		end)
	set_error_reporting("extended")
	require"lanesdebug.debugger"
	require"lanesdebug.script"
end

function output_lane()
	lanes = require"lanes"
	set_finalizer(function (err,stk)
			if err  and type(err)~="userdata" then 
				print( "output_lane error: "..tostring(err) )
				print(prstack)
				prstack(stk)
			elseif type(err)=="userdata" then 
				print( "output_lane after cancel" )
			else
				print("output_lane finalized")
			end	
		end)
	set_error_reporting("extended")
	while true do
		local key,val = outlinda:receive("debugger")
		if key == "debugger" then
			print("deb:",val[1],val[2])
		end
	end
end

function thread_shell()
    local line = ''
    while true do
        io.write('--> ')
        line = io.read()
        if line == 'continue' or line == "step_into" or line == "step_over" or line == "step_out" or line == "break" then 
			debuggerlinda:send(line,1)
		elseif line == "quit" then
			script_thread:cancel(1)
			return
		end
        print("Echo:'"..line.."'")
    end
end

Debugger = {}
--Debugger.breakpoints{linenumber = {file1,file2},linenumber2 = {file}}
script_thread = lanes.gen("*",{globals = {Debugger = Debugger,debuggerlinda = debuggerlinda,send_debuginfo=send_debuginfo}},debugscript)()
lanes.gen("*",output_lane)()

thread_shell()