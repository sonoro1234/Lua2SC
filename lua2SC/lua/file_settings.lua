-- simplified config for saving an loading lua tables
local file_settings = {filename=nil,defaults=nil,table=nil}

function file_settings:init(filename,defaults,basepath)
	self.filename = filename
	self.defaults = defaults
    self.basepath = basepath
    self.basepathmatch = basepath:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])","%%%1") --replace magic characters
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
        --MERGE DEFAULTS
        for k,v in pairs(self.defaults.settings) do
            if not self.table.settings[k] then
                self.table.settings[k] = v
            end
        end
		file:close()
	else
		print"not file in file_settings _read"
		self.table = self.defaults
	end
end
function file_settings:getportable(str) 
    local port_path = str:match(self.basepathmatch.."(.+)")
    --print(str,port_path,self.basepath)
    return port_path and port_path or str
end
function file_settings:abs2portable()
    self.table.settings.SCpath = self:getportable(self.table.settings.SCpath)
    self.table.settings.SC_SYNTHDEF_PATH = self:getportable(self.table.settings.SC_SYNTHDEF_PATH)
    for i,v in ipairs(self.table.settings.SC_PLUGIN_PATH) do
        self.table.settings.SC_PLUGIN_PATH[i] = self:getportable(v)
    end
end
local is_windows = package.config:sub(1,1) == '\\'
local function isabs(P)
	if is_windows then
		return P:sub(1,1) == '/' or P:sub(1,1)=='\\' or P:sub(2,2)==':'
	else
		return P:sub(1,1) == '/'
	end
end
local sep = is_windows and '\\' or '/'
path_sep = sep
local np_gen1,np_gen2 = '[^SEP]+SEP%.%.SEP?','SEP+%.?SEP'
local np_pat1, np_pat2 = np_gen1:gsub('SEP',sep) , np_gen2:gsub('SEP',sep)
local function normpath(P)
    if is_windows then
        if P:match '^\\\\' then -- UNC
            return '\\\\'..normpath(P:sub(3))
        end
        P = P:gsub('/','\\')
    end
    local k
    repeat -- /./ -> /
        P,k = P:gsub(np_pat2,sep)
    until k == 0
    repeat -- A/../ -> (empty)
        P,k = P:gsub(np_pat1,'')
    until k == 0
    if P == '' then P = '.' end
    return P
end
local function abspath(P,pwd)
	--local pwd = lfs.currentdir()
	if not isabs(P) then
		P = pwd..sep..P
	elseif is_windows  and P:sub(2,2) ~= ':' and P:sub(2,2) ~= '\\' then
		P = pwd:sub(1,2)..P -- attach current drive to path like '\\fred.txt'
	end
	return normpath(P)
end
function file_settings:getabs(str) 
    if isabs(str) then 
        return str
    else
        return abspath(str,self.basepath) --self.basepath..str
    end
end
function file_settings:portable2abs()
    self.table.settings.SCpath = self:getabs(self.table.settings.SCpath)
    self.table.settings.SC_SYNTHDEF_PATH = self:getabs(self.table.settings.SC_SYNTHDEF_PATH)
    for i,v in ipairs(self.table.settings.SC_PLUGIN_PATH) do
        self.table.settings.SC_PLUGIN_PATH[i] = self:getabs(v)
    end
end
function file_settings:save_table(key,t)
	self.table[key] = t
    self:abs2portable()
	self:_write()
end
function file_settings:load_table(key)
	self:_read()
    self:portable2abs()
	return self.table[key]
end
--------------------------------------

return file_settings