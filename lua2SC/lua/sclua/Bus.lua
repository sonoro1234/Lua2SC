local funcs = require("sclua.funcs")

local Bus_metatable = {}
Bus_metatable.__index = Bus_metatable


function Bus_metatable:set(value)
	self.value = value
	self.server:sendMsg('/c_set', self.busIndex, value)
end

-- Untested
function Bus_metatable:setn(nrofbusses, values)
	self.server:sendMsg('/c_setn', self.busIndex, nrofbusses, values)
end

function Bus_metatable:fill(nrofbusses, value)
	self.server:sendMsg('/c_fill', self.busIndex, nrofbusses, value)
end

function Bus_metatable:get()
	self.server:sendMsg('/c_get', self.busIndex)
end

function Bus_metatable:getn(index, nrofbusses)
	self.server:sendMsg('/c_getn', self.busIndex, nrofbusses)
end

function Bus_metatable:index()
	return self.busIndex
end

-- support garbage collection:
function Bus_metatable:__gc() 
	self:free() 
end

return Bus_metatable