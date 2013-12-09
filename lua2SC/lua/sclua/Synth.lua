local funcs = require("sclua.funcs")

local Synth_metatable = {}
Synth_metatable.__index = Synth_metatable


function Synth_metatable:__newindex(key, value)
	self.server:sendMsg('/n_set', self.nodeID, key, value)
end

function Synth_metatable:set(args)
	self.server:sendMsg('/n_set', self.nodeID, unpack(parseArgsX(args)) )
end

function Synth_metatable:setn(controlNameNum, args)
	local nn = funcs.parseArgsX(controlNameNum)
	local args = funcs.parseArgsX(controlNameNum)
	for arg, val in pairs(args) do 
		table.insert(nn, arg)
		table.insert(nn, val)
	end
	self.server:sendMsg('/n_setn', self.nodeID, unpack(nn))
end

function Synth_metatable:above(aSynth)
	self.server:sendMsg('/n_before', self.nodeID, aSynth.nodeID )
end

function Synth_metatable:below(aSynth)
	self.server:sendMsg('/n_after', self.nodeID, aSynth.nodeID )
end

function Synth_metatable:moveToHead(aNode)
	self.server:sendMsg('/g_head', aNode.nodeID, self.nodeID )
end

function Synth_metatable:moveToTail(aNode)
	self.server:sendMsg('/g_tail', aNode.nodeID, self.nodeID )
end

function Synth_metatable:free()
	self.server:sendMsg('/n_free', self.nodeID )
end

function Synth_metatable:run(arg)
	self.server:sendMsg('/n_run', self.nodeID, arg)
end

function Synth_metatable:getNodeID()
	return self.nodeID
end

function Synth_metatable:map(name, aBus)
	self.server:sendMsg('/n_map', self.nodeID, name, aBus.busIndex )
end

function Synth_metatable:mapn(args) -- mapping from control bus
	self.server:sendMsg('/n_mapn', self.nodeID, unpack(args) )
end

function Synth_metatable:mapa(args) -- mapping from control bus
	self.server:sendMsg('/n_mapa', self.nodeID, unpack(args) )
end

-- support garbage collection:
function Synth_metatable:__gc() 
	self:free() 
end

return Synth_metatable
