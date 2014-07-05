-- simplified config for saving an loading lua tables
local file_settings = {filename=nil,defaults=nil,table=nil}

function file_settings:init(filename,defaults)
	self.filename = filename
	self.defaults = defaults
end
function file_settings:_write()
	local file = io.open(self.filename,"w")
	if file then
		file:write(serializeTableF(self.table))
		file:close()
	else
		print"not file in file_settings _write"
	end
end
function file_settings:_read()
	local file = io.open(self.filename,"r")
	if file then
		local str = file:read("*a")
		local t = assert(loadstring(str))()
		self.table = t or self.defaults
		file:close()
	else
		print"not file in file_settings _read"
		self.table = self.defaults
	end
end
function file_settings:save_table(key,t)
	self.table[key] = t
	self:_write()
end
function file_settings:load_table(key)
	self:_read()
	return self.table[key]
end
--------------------------------------

return file_settings