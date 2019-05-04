require"lanesutils"


local SCUDP = require"sc_comm_loop.scudp"
local SCTCP = require"sc_comm_loop.sctcp"
local SCFFI = require"sc_comm_loop.scinternal"
local  SCCOMMLOOP = {}

function SCCOMMLOOP:init(types,options,linda)
    print"SCCOMMLOOP init"
	assert(not self.inited)
	if types == "udp" then
		self.type = types
		self.sc = SCUDP
		self.sc:init(options,linda)
		self.inited = true
	elseif types == "internal" then
		if not jit then prerror("must run luajit for internal server"); return end
		self.type = types
		self.sc = SCFFI
		local res = self.sc:init(options,linda)
		self.inited = res
        if not res then self.sc = nil end
    elseif types == "tcp" then
		self.type = types
		self.sc = SCTCP
		local res = self.sc:init(options,linda)
		self.inited = res
        if not res then self.sc = nil end
	else
		error("server type "..types.." not implemented")
	end
end

function SCCOMMLOOP:close()
	if self.sc then self.sc:close() end
	self.sc = nil
	self.inited = nil
end

function SCCOMMLOOP:send(msg)
	if self.sc then self.sc:send(msg) end
end
function SCCOMMLOOP:status()
	self:send(toOSC({"/status",{1}}))
end
function SCCOMMLOOP:sync(id)
	self:send(toOSC({"/sync",{id or 1}}))
end

function SCCOMMLOOP:dumpOSC(doit)
	local val= doit and 1 or 0
	self:send(toOSC({"/dumpOSC",{val}}))
end

function SCCOMMLOOP:dumpTree(withvalues)
	withvalues=withvalues or true
	local p= withvalues and 1 or 0
	self:send(toOSC({"/g_dumpTree",{0,p}}))
end

function SCCOMMLOOP:quit()
	idlelinda:set("statusSC") --delete
	self:send(toOSC({"/quit",{}}))
end

return SCCOMMLOOP