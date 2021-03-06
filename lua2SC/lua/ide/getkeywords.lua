

local CachedFiles = {files = {}}
function CachedFiles:open(name)
	if self.files[name] then return end
	self.files[name] = {}
	if name:sub(1,1) ~= '@' then print("getkeywords dont open:",name," is not a file"); return end
	local file = io.open(name:sub(2))
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
local function getSourceLine(source,line)
	--print("getSourceLine",source)
	return CachedFiles:read(source,line)
end

----------------------------------------------------------- 

local function bodyKeyWords()
	local sckeywordsSource = {}
	local keyword_table = {}
	
	local function getmetas(index, value)
		local mtt = getmetatable(value)
		if mtt then
			for i2,v2 in pairs(mtt) do
				--print(index,i2,v2)
				if type(v2)=="function" then
					table.insert(keyword_table, index.."."..i2.." ")
					local info = debug.getinfo(v2)
					local src = getSourceLine(info.source,info.linedefined)
					local args 
					if src then args = src:match(".-function.-(%(.+%))") end
					sckeywordsSource[index.."."..i2] = {currentline = info.linedefined,source = info.source,def=src,args=args}
					if i2=="__call" then
						--delete first arg table 
						args = args:gsub("%([^,%)]+,","")
						sckeywordsSource[index] = {currentline = info.linedefined,source = info.source,def=src,args=args}
					end
				else
					table.insert(keyword_table,index.."."..i2.." ")
				end
			end
		end
	
	end

	_run_options = {SC_UDP_PORT=57000} --needed by sclua

	local function newindex(t,key,val)
		if type(val) == "table" then
			local info=debug.getinfo(2)
			sckeywordsSource[key] = {currentline = info.currentline,source = info.source}
		end
		rawset(t,key,val)
	end
	setmetatable(_G, {__newindex = newindex})
	require"sc.callback_wrappers"
	require("sc.utils")
	require("sc.gui")
	require("sc.sc_comm")
	require("sc.synthdefsc")
	require("sc.playerssc")
	require("sc.stream")
	require("sc.miditoosc")
	require("sc.playersscgui")
	require("sc.scbuffer")
	require("sc.routines")
	require("sc.ctrl_bus")
	require("sc.oscfunc")
    require("sc.named_events")
	require("sc.MetronomLanes")
	require("sc.queue_action")
	--keywords for sclua
	sclua = require("sclua.Server")
	s = sclua.Server()
	Synth = s.Synth
	Buffer = s.Buffer()
	Bus = s.Bus()


    for index, value in pairs(_G) do
		if index~="_G" then
		if type(value)=="function" then
			table.insert(keyword_table, index.." ")
			local info = debug.getinfo(value)
			local src = getSourceLine(info.source,info.linedefined)
			local args 
			if src then args = src:match(".-function.-(%(.+%))") end
			sckeywordsSource[index] = {currentline = info.linedefined,source = info.source,def=src,args=args}
		elseif type(value)=="table" then
			table.insert(keyword_table, index.." ")
			for i2,v2 in pairs(value) do
				if type(v2)=="function" then
					table.insert(keyword_table, index.."."..i2.." ")
					local info = debug.getinfo(v2)
					local src = getSourceLine(info.source,info.linedefined)
					local args 
					if src then args = src:match(".-function.-(%(.+%))") end
					sckeywordsSource[index.."."..i2] = {currentline = info.linedefined,source = info.source,def=src,args=args}
				else
					table.insert(keyword_table,index.."."..i2.." ")
					getmetas(index.."."..i2, v2)
				end
			end
			getmetas(index, value)
		end
		end
    end
	--LogFile(ToStr(sckeywordsSource),"keyword.txt")
    table.sort(keyword_table)
	--prtable(keyword_table)
	return table.concat(keyword_table),sckeywordsSource
end

function GetSCKeyWords()
	local kw = lanegen(bodyKeyWords,{lua2scpath=lua2scpath},"keywords_lane")()
	sckeywordsSource = kw[2]
	--LogFile(ToStr(sckeywordsSource),"keyword.txt")
	return kw[1]
end