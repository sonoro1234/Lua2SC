-- simplified config for saving an loading lua tables
local Config = {}

function Config:init(appname,vendorname)
	local config = wx.wxFileConfig(appname, vendorname)
	if config then
		config:SetRecordDefaults()
		self.config = config
	else
		error("Could not create config")
	end
end
function Config:save_table(key,t)
	local oldpath = self.config:GetPath()
	--self.config:DeleteGroup(path)
    self.config:SetPath("/")
	self.config:Write(key,serializeTableF(t))
	self.config:Flush()
	self.config:SetPath(oldpath)
end
function Config:load_table(key)
	local oldpath = self.config:GetPath()
	--self.config:DeleteGroup(path)
    self.config:SetPath("/")
	local goodread,serialized = self.config:Read(key)
	self.config:SetPath(oldpath)
	if goodread then
		return assert(loadstring(serialized))()
	else
		return nil
	end
end
function Config:delete()
	self.config:delete()
end
return Config