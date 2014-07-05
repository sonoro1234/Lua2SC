--to comunicate via linda with server
local M = {}

function M:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end
function M:init(types,options,linda)
	self.linda = linda
	self.type = types
	self.linda:send("initsc",{types,options,linda})
	self.inited = true
end

function M:send(msg)
	self.linda:send("sendsc",msg)
end
function M:close()
	if self.inited then
		self.linda:send("closesc",1)
	end
	self.inited = nil
end

function M:status()
	self:send(toOSC({"/status",{1}}))
end
function M:sync(id)
	self:send(toOSC({"/sync",{id or 1}}))
end

function M:dumpOSC(doit)
	local val= doit and 1 or 0
	self:send(toOSC({"/dumpOSC",{val}}))
end

function M:dumpTree(withvalues)
	withvalues=withvalues or true
	local p= withvalues and 1 or 0
	self:send(toOSC({"/g_dumpTree",{0,p}}))
end

function M:quit()
	if self.type == "udp" then
		self:send(toOSC({"/quit",{}}))
	end
end

return M