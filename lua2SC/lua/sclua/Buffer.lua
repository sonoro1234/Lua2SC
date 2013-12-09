local funcs = require("sclua.funcs")

local Buffer_metatable = {}
Buffer_metatable.__index = Buffer_metatable


function Buffer_metatable:alloc(numframes, numchannels)
   self.server:sendMsg('/b_alloc', self.bufnum, numframes, numchannels)
end

function Buffer_metatable:read(path)
   self.server:sendMsg('/b_allocRead', self.bufnum, path)
end

function Buffer_metatable:write(path)
	self.server:sendMsg('/b_write', self.bufnum, path, "aiff", "int16")
end

function Buffer_metatable:free()
	self.server:sendMsg('/b_free', self.bufnum)
end

function Buffer_metatable:zero()
	self.server:sendMsg('/b_zero', self.bufnum)
end

function Buffer_metatable:set(index, value)
	self.server:sendMsg('/b_set', self.bufnum, index, value)
end

function Buffer_metatable:setn(index, numsamples, value) -- not ready perphas ... instead of value or use unpack
	self.server:sendMsg('/b_setn', self.bufnum, index, numsamples, value)
end

function Buffer_metatable:fill(index, numsamples, value)
	self.server:sendMsg('/b_fill', self.bufnum, index, numsamples, value)
end

function Buffer_metatable:close()
	self.server:sendMsg('/b_close', self.bufnum)
end

function Buffer_metatable:query()
	self.server:sendMsg('/b_query', self.bufnum)
end

function Buffer_metatable:get(index)
	self.server:sendMsg('/b_get', self.bufnum, index)
end

function Buffer_metatable:getn(index, numsamples)
	self.server:sendMsg('/b_get', self.bufnum, index, numsamples)
end

function Buffer_metatable:__gc() 
	self:free() 
end

-- support garbage collection:
function Buffer_metatable:__gc() 
	self:free() 
end

return Buffer_metatable

