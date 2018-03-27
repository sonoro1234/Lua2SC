local osc = require("osc")
local funcs = require("sclua.funcs")
local Synth_metatable = require("sclua.Synth")
local Buffer_metatable = require("sclua.Buffer")
local Group_metatable = require('sclua.Group')
local Bus_metatable = require('sclua.Bus')

local Server_metatable = {}
Server_metatable.__index = Server_metatable

local BASE_NODE = 0
function Server(IP, port)
	assert(_run_options,"no _run_options")
	assert(not IP and not port,"conecting server not implemented")
	local s = setmetatable({
		IP = IP or '127.0.0.1',
		port = port or _run_options.SC_UDP_PORT,
		options = _run_options,
		defaultGroup = { nodeID = 1 } -- assimilate the behaviour of SC-lang
	}, Server_metatable)
	s.oscout = osc.Send(s.IP, s.port)
	-- s.oscin  = osc.Recv(57180) -- I need a two directional OSC port

	s.Synth = {}

	local smet = {}
	smet.__call = function(t ,name, args, target,addAction)
		local synthTab = setmetatable({
			type = "synth",
			server = s,
			nodeID = nextNodeID(),
			name = name,
			args = parseArgsX(args),
		}, Synth_metatable)
		--[[
		local targ = 0
		if type(target)=="table" then 
			targ = target.nodeID
		elseif type(target)=="number" then 
			targ = target
		else targ = BASE_NODE end
		--]]
		s:sendMsg('/s_new', synthTab.name, synthTab.nodeID, addAction or 0, target and target.nodeID or BASE_NODE, unpack(synthTab.args))
		return synthTab
	end 
	smet.tail = function(aGroup, defName, args)
		return smet.__call(nil, defName, args, aGroup, 1)
	end
	smet.head = function(aGroup, defName, args)
		return smet.__call(nil, defName, args, aGroup, 0)
	end
	smet.after = function(aNode, defName, args)
		return smet.__call(nil, defName, args, aNode, 3)
	end
	smet.before = function(aNode, defName, args)
		return smet.__call(nil, defName, args, aNode, 2)
	end
	smet.replace = function(aNode, defName, args)
		return smet.__call(nil, defName, args, aNode, 4)
	end
	smet.wrapnode = function(node)
		return  setmetatable({
			type = "synth",
			server = s,
			nodeID = node,
			--name = name,
			--args = parseArgsX(args),
		}, Synth_metatable)
	end
	smet.__index = smet
	setmetatable(s.Synth,smet)
	

	s.Buffer = function(path)
   		local bufferTab = setmetatable({
			type = "buffer",
   			bufnum = nextBufNum(),
   			server = s
   		}, Buffer_metatable)
   		if path ~= nil then -- if user provides a filepath (else s/he might want to allocate an empty buf)
		   s:sendMsg('/b_allocRead', bufferTab.bufnum, path)
   		end
   		return bufferTab
	end

	s.Bus = function()
		local busTab = setmetatable({
			type = "bus",
			value = nil,
			busIndex = nextBusIndex(),
			server = s
		}, Bus_metatable)
		return busTab
	end
	
	s.Group = function(aGroup,action,paralel)
		action = action or 0 -- add to head by default
		local target 
		if aGroup == nil then
			target = BASE_NODE --1 -- default SC server group 
		else
			target = aGroup.nodeID
		end
		local groupTab = setmetatable({
			type = "group",
			nodeID = nextGroupID(),
			server = s
		}, Group_metatable)
        if paralel then
            s:sendMsg('/p_new', groupTab.nodeID, action, target) 
        else
            s:sendMsg('/g_new', groupTab.nodeID, action, target)
        end
		return groupTab
	end
	
   return s
end

function Server_metatable:dumpOSC(mode)
-- 	I think this is buggy on the SC Server side (maybe not in 3.5)
--	0 - turn dumping OFF.
--	1 - print the parsed contents of the message.
--	2 - print the contents in hexadecimal.
--	3 - print both the parsed and hexadecimal representations of the contents.	
	print("sending dumposc")
	self.oscout:send('/dumpOSC', mode)
end

function Server_metatable:boot()
	-- since there is no cmd line arg for loading synth defs for scsynth, there has to be a delay
	-- between the two lines below. (it works however if you have your synthdefs in a default folder)
	os.execute("cd /Applications/LuaAV.12.12.11/ && ./scsynth -u 57110 -R 0 &") -- works
	self.oscout:send('/d_loadDir', "/Applications/LuaAV.12.12.11/synthdefs")
end

--os.execute("cd /Applications/SuperCollider/ && ./scsynth -u 57117 -R 0 &")


function Server_metatable:freeAll()
	self.oscout:send('/g_freeAll', 0)
	self.oscout:send('/clearSched')
	self.oscout:send("/g_new", 1, 0, 0)
end

function Server_metatable:sendMsg(...)
	self.oscout:send(...)
end

function Server_metatable:notify(arg)
	self.oscout:send('/notify', arg)
end

function Server_metatable:status()
	self.oscout:send('/status', arg)
end

--function get_osc()
--	for msg in oscin:recv() do	
--		print(msg.addr, msg.types, unpack(msg))
--		-- add message handling here
--	end
--end
--
--go(function()
--	while(true) do
--		get_osc()
--		wait(1/40)
--	end
--end)

--return Server


-- support garbage collection:
function Server_metatable:__gc() 
	self:free() 
end

-- module:
return {
	Server = Server,
	actions = {head=0,tail=1,before=2,after=3,replace=4}
}

