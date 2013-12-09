local function get_call_stack(inilevel)
	local stack = {}
	local vars = {}
	for level = inilevel or 1,math.huge do
		local stlevel = level - inilevel + 1
		local stinfo = debug.getinfo(level,"Snlf")
		if not stinfo then return stack,vars end
		stack[stlevel] = stinfo
		--locals
		vars[stlevel] = {locals= {},upvalues= {}}
		local i = 1
		while true do
			local name,value = debug.getlocal(level,i)
			if not name then break end
			if string.sub(name, 1, 1) ~= '(' then
				vars[stlevel].locals[name] = value
			end
			i = i + 1
		end
		local func = stinfo.func
		local i = 1
		while true do
			local name,value = debug.getupvalue(func,i)
			if not name then break end
			vars[stlevel].upvalues[name] = value
			i = i + 1
		end
	end
end
local function getstacklevel()
	for i = 1,math.huge do
		if not debug.getinfo(i,"l") then return i end
	end
end
local function is_stacklevel_lower(level)
	return not debug.getinfo(level,"l")
end
function Debugger.debug_hook (event, line)
	--print(event, line)
	local thread = coroutine.running() or 0
	if debuggerlinda:receive(0,"break") then
		Debugger.step_into = true
		Debugger.step_over = false
	end
	if Debugger.breakpoints[line] or Debugger.step_into or Debugger.step_over then
		
		local debuginfo = debug.getinfo(2,"S")
		local s = debuginfo.source
		--debug_print("trace",event, line,s,Debugger.step_over,Debugger.step_into)
		if (Debugger.step_over and Debugger.laststacklevel[thread] and is_stacklevel_lower(Debugger.laststacklevel[thread])
		or Debugger.step_into 
		or (Debugger.breakpoints[line] and Debugger.breakpoints[line][s])) then

			--debug_print(s , ":" , line,Debugger.step_into,Debugger.step_over , getstacklevel())
			--debug_print(ToStr(debuginfo))
			--debug_print(debug.traceback("traceback",2))
			Debugger.step_into = false
			Debugger.step_over = false
			
			local stack,vars = get_call_stack(3)
			send_debuginfo(s,line,stack,vars)
			
			while true do
				local key,val = debuggerlinda:receive("continue","debug_exit","step_into","step_over","step_out","brpoints")
				--debug_print("debuggerlinda",key,val)
				if key == "debug_exit" then
					debug.sethook()
					break
				elseif key == "continue" then
					break
				elseif key == "step_into" then
					Debugger.step_into = true
					break
				elseif key == "step_over" then
					Debugger.laststacklevel[thread] = getstacklevel()
					Debugger.step_over = true
					break
				elseif key == "step_out" then
					Debugger.laststacklevel[thread] = getstacklevel()-1
					Debugger.step_over = true
					break
				elseif key == "brpoints" then
					if val[1] == "add" then
						Debugger.breakpoints[val[3]] = Debugger.breakpoints[val[3]] or {}
						Debugger.breakpoints[val[3]][val[2]] = true
					else --delete
						if Debugger.breakpoints[val[3]] then
							Debugger.breakpoints[val[3]][val[2]] = nil
						end
					end
				end
			end
		end
	end
end

function Debugger:init()
	self.step_over = false
	self.step_into = false
	self.laststacklevel = {} 
	self.breakpoints = self.breakpoints or {}
	repeat
		local key,val= debuggerlinda:receive(0,"continue","debug_exit","step_into","step_over","step_out","brpoints","break")
	until val==nil
	
end

--for debugging coroutines
local oldcocreate = coroutine.create
coroutine.create = function(f)
			local thread = oldcocreate(f) 
			print("coroutine.running() is",thread,Debugger.debug_hook)
			debug.sethook(thread,Debugger.debug_hook,"l")
			return thread
			end
Debugger:init()
debug.sethook(Debugger.debug_hook, "l")

