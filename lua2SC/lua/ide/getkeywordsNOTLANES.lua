

local function loadfilefrompath(cad)
	-- TODO win32,linux,mac?
	cad = string.gsub(cad, "%.",path_sep) --"/")
	------------------------------------
	local paths = stsplit(package.path,";")
	for i, path in ipairs(paths) do
		local file=string.gsub(path,"?",cad)
		local exist = io.open(file)

		if exist then
			exist:close()
			local chunk,errorst = loadfile(file)
			print("loadfilefrompath",file,errorst)
			if chunk then
				return chunk
			end
		end
	end
	error("could not loadfilefrompath "..cad) 
end
local function newrequire(cad)
	local env = getfenv(2)
	if package.loaded[cad] then return package.loaded[cad] end
	local chunk = loadfilefrompath(cad)
	setfenv(chunk, env)
	package.loaded[cad] = chunk()
	return package.loaded[cad]
end
local CachedFiles = {files = {}}
function CachedFiles:open(name)
	if self.files[name] then return end
	self.files[name] = {}
	local file = io.open(name)
	if not file then print("CachedFiles:Error opening "..tostring(name).."\n"); return  end
	for i=1,math.huge do
		local str = file:read()
		if not str then break end
		self.files[name][i] = str
	end
	file:close()
end
function CachedFiles:read(name,line)
	if not self.files[name] then self:open(name) end
	return self.files[name][line]
end
function getSourceLine(source,line)
	return CachedFiles:read(source,line)
end
 
function loadinEnv(file,env)
	local function newindex(t,key,val)
		--[[ the functions are done in other place
		local info=debug.getinfo(2)
		--print ("setting "..key.." from line "..info.currentline.." in file "..info.short_src)
		local src
		if type(val)=="function" then
			src = getSourceLine(info.source:sub(2),info.currentline)
		end
		local args 
		if src then args = src:match(".-function.-(%(.+%))") end
		sckeywordsSource[key] = {currentline = info.currentline,source = info.source,def=src,args=args}
		--]]
		if type(val) == "table" then
			local info=debug.getinfo(2)
			sckeywordsSource[key] = {currentline = info.currentline,source = info.source}
		end
		rawset(t,key,val)
	end
	if not env then
		env = setmetatable({}, {__index = _G,__newindex = newindex}) 
		env.require = newrequire
		env.package = setmetatable({}, {__index = _G.package})
		env.package.loaded = {}
	end
	local f = loadfilefrompath(file)
	setfenv(f, env)
	f()
	return env
end

function GetSCKeyWords()
			require"random" -- dont want to require dll in env TODO:solve it other way
			socket = require"socket" -- dont want to require dll in env TODO:solve it other way
			sckeywordsSource = {}
			local env = loadinEnv"sc.callback_wrappers"
			loadinEnv("sc.synthdefsc",env)
			loadinEnv("sc.playerssc",env)
			loadinEnv("sc.stream",env)
			loadinEnv("sc.utils",env)
			loadinEnv("sc.miditoosc",env)
			loadinEnv("sc.scbuffer",env)
			loadinEnv("sc.routines",env)
			--loadinEnv("sc.ctrl_bus",env)
			loadinEnv("sc.oscfunc",env)
			local keyword_table = {}
            for index, value in pairs(env) do
				if type(value)=="function" then
					table.insert(keyword_table, index.." ")
					local info = debug.getinfo(value)
					local src = getSourceLine(info.source:sub(2),info.linedefined)
					local args 
					if src then args = src:match(".-function.-(%(.+%))") end
					sckeywordsSource[index] = {currentline = info.linedefined,source = info.source,def=src,args=args}
				elseif type(value)=="table" then
					table.insert(keyword_table, index.." ")
					for i2,v2 in pairs(value) do
						if type(v2)=="function" then
							table.insert(keyword_table, index.."."..i2.." ")
							local info = debug.getinfo(v2)
							local src = getSourceLine(info.source:sub(2),info.linedefined)
							local args 
							if src then args = src:match(".-function.-(%(.+%))") end
							sckeywordsSource[index.."."..i2] = {currentline = info.linedefined,source = info.source,def=src,args=args}
						end
					end
				end
            end
			--LogFile(ToStr(sckeywordsSource))
            table.sort(keyword_table)
			return table.concat(keyword_table)
end