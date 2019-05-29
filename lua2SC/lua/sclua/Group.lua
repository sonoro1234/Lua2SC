local funcs = require("sclua.funcs")

local Group_metatable = {}
Group_metatable.__index = Group_metatable


function Group_metatable:moveToHead(aNode)
	self.server:sendMsg('/g_head', aNode.nodeID, self.nodeID)
end

function Group_metatable:moveToTail(aNode)
	self.server:sendMsg('/g_tail', aNode.nodeID, self.nodeID)
end

function Group_metatable:above(aGroup)
	self.server:sendMsg('/n_before', self.nodeID, aGroup.nodeID )
end

function Group_metatable:below(aGroup)
	self.server:sendMsg('/n_after', self.nodeID, aGroup.nodeID )
end

function Group_metatable:freeAll()
	self.server:sendMsg('/g_freeAll', self.nodeID )
end

function Group_metatable:deepFree()
	self.server:sendMsg('/g_deepFree', self.nodeID )
end

function Group_metatable:free()
	self.server:sendMsg('/n_free', self.nodeID )
end

function Group_metatable:dumpTree(flag)
	flag = flag or 0
	self.server:sendMsg('/g_dumpTree', self.nodeID, flag )
end

function Group_metatable:queryTree(action,include_ctrl_vals)
	action = action or function(msg) end
	include_ctrl_vals = include_ctrl_vals or 0
	-- Replies to the sender with a /g_queryTree.reply message
	OSCFunc.newfilter("/g_queryTree.reply",self.bufnum,action,true)
	ThreadServerSend(self.server:Msg('/g_queryTree', self.nodeID, include_ctrl_vals ))
end

-- support garbage collection:
function Group_metatable:__gc() 
	self:free() 
end

return Group_metatable
