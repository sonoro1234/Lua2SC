local funcs = require("sclua.funcs")

local Synth_metatable = {}
Synth_metatable.__index = Synth_metatable


function Synth_metatable:__newindex(key, value)
	self.server:sendMsg('/n_set', self.nodeID, key, value)
end

function Synth_metatable:set(args)
	self.server:sendMsg('/n_set', self.nodeID, unpack(parseArgsX(args)) )
end

function Synth_metatable:setn(args)
	self.server:sendMsg('/n_setn', self.nodeID, unpack(args))
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

function Synth_metatable:map(args)
	self.server:sendMsg('/n_map', self.nodeID, unpack(parseArgsX(args,true)) )
end

function Synth_metatable:mapn(args) -- mapping from control bus
	self.server:sendMsg('/n_mapn', self.nodeID, unpack(args) )
end

function Synth_metatable:mapa(args) -- mapping from audio bus
	local msg = {}
	for k,v in pairs(args) do
		msg[#msg+1] = k
		msg[#msg+1] = {"int32",v}
	end
	self.server:sendMsg('/n_mapa', self.nodeID, unpack(msg) )
end

-- support garbage collection:
function Synth_metatable:__gc() 
	self:free() 
end

return Synth_metatable
