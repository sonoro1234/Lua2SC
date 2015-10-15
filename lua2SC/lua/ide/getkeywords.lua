

local function loadfilefrompath(cad)
	--print("loadfilefrompath",cad)
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
			--print("loadfilefrompath",file,errorst)
			if chunk then
				return chunk
			end
		end
	end
	print("could not loadfilefrompath "..cad) 
end
local function newrequire(cad)
	--print("newrequire",cad)
	local env = getfenv(2)
	if env.package.loaded[cad] then 
		--print("xxxxxxxxxxxxxxxxxxxxxloaded",cad)
		return env.package.loaded[cad] 
	end
	local chunk = loadfilefrompath(cad)
	if chunk then
		setfenv(chunk, env)
		env.package.loaded[cad] = chunk() or true
		return env.package.loaded[cad]
	else
		env.package.loaded[cad] = "cant load"
	end
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
	--print("loadinEnv",file,env,env and env.package,package)
	local function newindex(t,key,val)
		if type(val) == "table" then
			local info=debug.getinfo(2)
			sckeywordsSource[key] = {currentline = info.currentline,source = info.source}
		end
		rawset(t,key,val)
	end
	if not env then
		env = setmetatable({}, {__index = _G,__newindex = newindex}) 
		env.require = newrequire
		env.package = {} --setmetatable({}, {__index = _G.package})
		env.package.loaded = {}
	end
	--for k,v in pairs(env.package.loaded) do print("env.package.loaded",k,v) end
	local f = loadfilefrompath(file)
	setfenv(f, env)
	env.package.loaded[file] = f() or true
	return env
end

local function body()
end

function GetSCKeyWords()
			require"random" -- dont want to require dll in env TODO:solve it other way
			require"socket" -- dont want to require dll in env TODO:solve it other way
			sckeywordsSource = {}
			local env = loadinEnv"sc.callback_wrappers"
			loadinEnv("sc.gui",env)
			loadinEnv("sc.sc_comm",env)
			loadinEnv("sc.synthdefsc",env)
            --print("env.ReplaceOut",env.ReplaceOut)
			loadinEnv("sc.playerssc",env)
			loadinEnv("sc.stream",env)
			loadinEnv("sc.utils",env)
			loadinEnv("sc.miditoosc",env)
			loadinEnv("sc.playersscgui",env)
			loadinEnv("sc.scbuffer",env)
			loadinEnv("sc.routines",env)
			loadinEnv("sc.ctrl_bus",env)
			loadinEnv("oscfunc",env)
            loadinEnv("sc.named_events",env)
			loadinEnv("sc.MetronomLanes",env)
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
						else
							table.insert(keyword_table,index.."."..i2.." ")
						end
					end
				end
            end
			--LogFile(ToStr(sckeywordsSource),"keyword.txt")
            table.sort(keyword_table)
			return table.concat(keyword_table)
end