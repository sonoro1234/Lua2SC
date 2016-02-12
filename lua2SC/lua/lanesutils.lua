do
local linda = lanes.linda()
function wait(secs)
	lanes.timer(linda,"wait",secs,0)
	linda:receive("wait")
end
end

function lanegen(func_body,globals,thread_name)
	thread_name = thread_name or "unamed thread"
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
		print(thread_name.." finalizer:")
		if err and type(err)~="userdata" then 
			print( thread_name.." after error: "..tostring(err) )
			print(thread_name.." finalizer stack table")
			prstak(stk)
		elseif type(err)=="userdata" then
			print( thread_name.." after cancel " )
		else
			print( thread_name.." after normal return" )
		end
	end
	local function outer_func(block,...)
		
		lanes = require "lanes" --.configure()
		--lanes.require"lanes"
		set_finalizer( finalizer_func ) 
		set_error_reporting("extended")
		set_debug_threadname(thread_name)
		local ret = {func_body(...)}
		
		if block then
			local block_linda = lanes.linda()
			block_linda:receive("unblock")
		end
		return unpack(ret)
	end
	return lanes.gen("*",{globals=globals},outer_func)
end