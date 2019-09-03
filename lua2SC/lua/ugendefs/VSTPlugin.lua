VSTPlugin = MultiOutUGen:new({name="VSTPlugin"})
local Serverdefault = require"sclua.Server".Server()
-- function takes a string that behaves like a file to be read
local function StrStream(strg)
    local strptr = 1
    local str = strg
    local strfile = {}
    function strfile:read(len)
        local oldstrptr = strptr
        strptr = strptr + len
		if oldstrptr > #strg then return nil end
        return str:sub(oldstrptr,strptr-1)
    end
	function strfile:next()
		return self:read(1)
	end
	function strfile:readUpTo(del)
		local strin = ""
		local char = self:next()
		if not char then return nil end
		while char and char~=del do
			strin = strin .. char
			char = self:next()
		end
		return strin
	end
	function strfile:prGetLine(skipempty)
		while true do
			local line = self:readUpTo"\n"
			if not line then return nil end
			if (not skipempty or #line>0) and line:sub(1)~="#" and line:sub(1)~=";" then return line end
		end
	end
    return strfile
end
local function asArray(o)
	if type(o)=="table" then
		return o
	elseif type(o)=="nil" then
		return {}
	else
		error"asArray not valid"
	end
end
function VSTPlugin.ar(input, numOut, bypass, params, id, info, auxInput, numAuxOut)
	local flags = 0
	input = asArray(input)
	auxInput = asArray(auxInput)
	params = asArray(params)
	assert(#params%2==0,"'params': expecting pairs of param index/name + value")

	id = id or "nullid"
	numOut = numOut or 1
	bypass = bypass or 0
	numAuxOut = numAuxOut or 0
	info = info or 0
	return VSTPlugin:MultiNew(concatTables({2, id, info, numOut, numAuxOut, flags, bypass, #input},
	input,#params/2, params, #auxInput,  auxInput ))
end
local pluginDict = {}
function VSTPlugin:init( theID, theInfo, numOut, numAuxOut, flags, bypass, numInputs ,... )
		if theID~="nullid" then self.id = theID end
		if theInfo~= 0 then self.info = theInfo end
		self.numInputs = numInputs
		local inputArray = {}
		if numInputs > 0 then
			for i=1,numInputs do
				local inp = select(i,...)
				assert(inp.calcrate == 2, "input not audio rate!!")
				inputArray[#inputArray + 1] = inp
			end
		end
		local offset = numInputs + 1
		local paramArray = {}
		local numParams = select(offset, ...)
		if numParams > 0 then
			for i=offset + 1, offset + numParams*2 do
				paramArray[#paramArray + 1] = select(i,...)
			end
		end
		offset = offset + 1 + (numParams*2)
		local auxInputArray = {}
		local numAuxInputs = select(offset, ...)
		if numAuxInputs > 0 then
			for i= offset + 1, offset + numAuxInputs do
				local inp = select(i,...)
				assert(inp.calcrate == 2, "input not audio rate!!")
				auxInputArray[#auxInputArray + 1] = inp
			end
		end
		for i=1, #paramArray, 2 do
			local param, value = paramArray[i], paramArray[i+1]
			if type(param)~="number" then
				if not self.info then
					error("cant get param without info!!")
				else
					local param1 = info:findParamIndex(param)
					if not param1 then error("bad parameter "..param.." for plugin "..info.name) end
					paramArray[i] = param1
				end
			end
		end
		self.inputs = concatTables({numOut, flags, bypass, numInputs}, inputArray, numAuxInputs, auxInputArray, numParams, paramArray)
		return self:initOutputs(numOut)
end

function VSTPlugin.clearMsg(remove)
	remove = remove==nil
	local remint = remove and 1 or 0
	return {'/cmd', '/vst_clear', remint};
end

function VSTPlugin.clear(server, remove)
	server = server or require"sclua.Server".Server()
	-- clear local plugin dictionary
	pluginDict[server] = {}
	-- clear server plugin dictionary
	--remove=true -> also delete temp file
	server:listSendMsg(VSTPlugin.clearMsg(remove));
end
local lpath = require"sc.path"

local function resolvePath(path)
		local root, temp;
		if lpath.is_windows then
		--(thisProcess.platform.name == \windows).if {
		--	// replace / with \ because of a bug in PathName
		--	path = path.tr($/, $\\);
		--};
		end
		--path = path.standardizePath; // expand ~/
		--// other methods don't work for folders...
		--[[
		PathName(path).isAbsolutePath.not.if {
			// resolve relative paths to the currently executing file
			root = thisProcess.nowExecutingPath;
			root.notNil.if {
				temp = root.dirname +/+ path;
				// no extension: append VST2 platform extension
				(path.find(".vst3").isNil && path.find(platformExtension).isNil).if {
					temp = temp ++ platformExtension;
				};
				File.exists(temp).if { ^temp };
			}
			// otherwise the path is passed to the UGen which tries
			// to resolve it to the standard VST search paths.
		};
		--]]
		--assert(lpath.is_abs(path),"relative path not implemented")
		return path;
end
local function makeInfo(key, info)
		local f = tonumber(info[11]);
		local flags = TA():Fill(8,function(i) return bit.band(1,bit.rshift(f,i-1))> 0 end)-- {arg i; ((f >> i) & 1).asBoolean });
		return {
			parent= parentInfo,
			key= key,
			path= info[1],--.asString,
			name= info[2],--.asString,
			vendor= info[3],--.asString,
			category= info[4],--.asString,
			version= info[5],--.asString,
			id= info[6],--.asInteger,
			numInputs= info[7],--.asInteger,
			numOutputs= info[8],--.asInteger,
			numParameters= info[9],--.asInteger,
			numPrograms= tonumber(info[10]),--.asInteger,
			hasEditor= flags[1],
			isSynth= flags[2],
			singlePrecision= flags[3],
			doublePrecision= flags[4],
			midiInput= flags[5],
			midiOutput= flags[6],
			sysexInput= flags[7],
			sysexOutput= flags[8]
		}
end
local function trim(cad)
    return cad:gsub("^%s*(.-)%s*$","%1") --remove initial and final spaces
end
local function prParseKeyValuePair(line)
	local larr = stsplit(line,"=")
	for i,v in ipairs(larr) do larr[i] = trim(v) end
	return larr
end
local function hex2int(str)
	str = str:upper():reverse()
	str = {str:byte(1,#str)}
	local sum = 0
	for i,v in ipairs(str) do
		if v >= 65 then
			sum = sum + bit.lshift(v - 55, (i-1)*4)
		else
			sum = sum + bit.lshift(v - 48, (i-1)*4)
		end
	end
	return sum
end
local function prParseCount(line)
	local onset = line:find"="
	if not onset then error"plugin info: bad data (expecting 'n=<number>'" end
	return tonumber(line:sub(onset+1))
end
local function prParseInfo(stream)
	local info = {}
	-- default values:
	info.numAuxInputs = 0
	info.numAuxOutputs = 0
	local line,plugin, n, parameters, indexMap, programs, keys
	while true do
		line = stream:prGetLine(true);
		if not line then error"EOF reached" end
		if line == "[plugin]" then plugin = true 
		elseif line == "[parameters]" then
			local name, label
			line = stream:prGetLine();
			n = prParseCount(line)
			parameters = {}
			indexMap = {}
			for i=1,n do
				line = stream:prGetLine();
				name, label = unpack(stsplit(line,","))
				parameters[i] = {name = trim(name), label = trim(label)}
			end
			info.parameters = parameters
			for i,param in ipairs(parameters) do
				indexMap[param.name] = i
			end
			info.prParamIndexMap = indexMap;
		elseif line == "[programs]" then
			line = stream:prGetLine();
			n = prParseCount(line)
			programs = {}
			for i=1,n do
				local name = stream:prGetLine()
				programs[i] = {name = name}
			end
			info.programs = programs
		elseif line == "[keys]" then
			line = stream:prGetLine();
			n = prParseCount(line)
			keys = {}
			for i=1,n do keys[i] = stream:prGetLine() end
			info.key = keys[1]
			return info
		else
			if not plugin then error"plugin info: bad data (%)" end
			local key, value = unpack(prParseKeyValuePair(line));
			if key == "path" then info[key]=value
			elseif key == "name" then info[key]=value
			elseif key == "vendor" then info[key]=value
			elseif key == "category" then info[key]=value
			elseif key == "version" then info[key]=value
			elseif key == "sdkVersion" then info[key]=value
			elseif key == "sdkversion" then info[key]=value
			elseif key == "id" then info[key]=value
			elseif key == "inputs" then info.numInputs=tonumber(value)
			elseif key == "outputs" then info.numOutputs=tonumber(value)
			elseif key == "auxinputs" then info.numAuxInputs=tonumber(value)
			elseif key == "auxoutputs" then info.numAuxOutputs=tonumber(value)
			elseif key == "flags" then
				local f = hex2int(value)
				local flags = {}
				for i=0,7 do flags[i] = bit.band(1,bit.rshift(f,i)) end
				info.hasEditor = flags[0]>0 
				info.isSynth = flags[1]>0
				info.singlePrecision = flags[2]>0
				info.doublePrecision = flags[3]>0
				info.midiInput = flags[4]>0
				info.midiOutput = flags[5]>0
				info.sysexInput = flags[6]>0
				info.sysexOutput = flags[7]>0
			else
				prerror("Bad key",key)
			end
		end
	end
end
local function parseInfo(str)
	local data = stsplit(str,"\t")
	local key = data[1]
	local info = makeInfo(key,TA(data)(2,12))
	local nparam = info.numParameters
	info.parameterNames = {}
	info.parameterLabels = {}
	for i=1,info.numParameters do
		local onset = 12 + (i-1)*2
		table.insert(info.parameterNames,data[onset])
		table.insert(info.parameterLabels,data[onset+1])
	end
	info.programNames = {}
	for i=1,info.numPrograms do
		local onset = 12 + (nparam * 2) + i - 1;
		table.insert(info.programNames, data[onset])
	end
	return info
end

local function prParseIni(stream)
	local line = stream:prGetLine(true)
	if line~="[plugins]" then error"missisng [plugins] header" end
	line = stream:prGetLine(true)
	local n = prParseCount(line)
	local results = {}
	for i=1,n do
		results[i] = prParseInfo(stream)
	end
	return results
end

local function prMakeDest(dest)
	if not dest then return -1 end
	if type(dest)=="string" then return dest end
	if type(dest)=="number" then return dest end
	error"Bad dest in prMakeDest"
end

local function searchMsg(dir, useDefault, verbose, save, parallel, dest)
	--defaults
	useDefault = type(useDefault)==nil and true or useDefault
	if verbose==nil then verbose = false end
	if save==nil then save = true end
	if parallel==nil then parallel = true end
	-- bool to int
	useDefault = useDefault and 1 or 0
	verbose = verbose and 1 or 0
	save = save and 1 or 0
	parallel = parallel and 1 or 0

	local flags = 0
	for i,v in ipairs{useDefault, verbose, save, parallel} do
		flags = bit.bor(flags, bit.lshift(v,i-1))
	end
	
	dir = type(dir)=="string" and {dir} or dir
	assert(type(dir)=="table" or type(dir)=="nil", "Bad dir type")
	if dir == nil then dir = {} end
	for i,v in ipairs(dir) do dir[i] = resolvePath(v) end

	dest = prMakeDest(dest)
	
	return concatTables({'/cmd', '/vst_search', flags, dest}, dir)

end
local function searchLocal(server, searchPaths, useDefault, verbose, save, parallel, action)

	local tmpPath = os.tmpname()
	server:listSendMsg(searchMsg(dir, useDefault, verbose, save, parallel, tmpPath))
	server:sync()
	local file,err = io.open(tmpPath,"rb")
	assert(file,err)
	local str = file:read"*a"
	file:close()
	local strf = StrStream(str)
--	print"----------"
--	print(str)
--	print"-----------"
	local res = prParseIni(strf)
	local dict = pluginDict[server]
	for k,info in pairs(res) do
		dict[info.key]=info
	end
--[[
	while true do
		local line = strf:prGetLine(true)
		if not line then break end
		print(line)
	end
	local dict = pluginDict[server]
	local infos = stsplit(str,"\n")
	for i,line in ipairs(infos) do
		if not (line=="") then
		local info = parseInfo(line)
		dict[info.key] = info
		end
	end
--]]
end
function VSTPlugin.search(server, dir, useDefault, verbose, wait, action, save, parallel)
	server = server or require"sclua.Server".Server()
	if useDefault==nil then useDefault = true end
	if verbose==nil then verbose = true end
	if save==nil then save = true end
	if parallel==nil then parallel = true end
	wait = wait or -1
	
	pluginDict[server] = pluginDict[server] or {}
	searchLocal(server, dir, useDefault, verbose, save, parallel, action)
end
function VSTPlugin.getDict(server)
	server = require"sclua.Server".Server()
	return pluginDict[server]
end
function VSTPlugin.plugins(server)
	server = require"sclua.Server".Server()
	return pluginDict[server]
end
function VSTPlugin.pluginList(server, sorted)
	local dict = VSTPlugin.plugins(server)
	local array = {}
	for k,v in pairs(dict) do table.insert(array,v) end
	if sorted then
		table.sort(array,function(a,b) return a.name < b.name end)
	end
	return array
end
function VSTPlugin.print(server)
	local dict = VSTPlugin.pluginList(server, true)
	--prtable(dict)
	for k,v in ipairs(dict) do
		print(v.key,v.vendor,v.path)
	end
end
function VSTPlugin.prGetInfo(server, key, wait, action)
		local info
		local dict = pluginDict[server];
		-- if the key already exists, return the info.
		-- otherwise probe the plugin and store it under the given key
		--dict !? { info = dict[key] } !? { action.value(info) }
		--?? { this.probe(server, key, key, wait, action) };
		if dict then
			info = dict[key]
			action(info)
		else
			return VSTPlugin.probe(server, key, key, wait, action)
		end
end
local function prProbeLocal(server, path, key, action)

	local info
	local dict = pluginDict[server];
	local filePath = os.tmpname()
	--local filePath = PathName.tmp ++ this.prUniqueID.asString;
	-- ask server to write plugin info to tmp file
	server:sendMsg('/cmd', '/vst_query', path, filePath);
	-- wait for cmd to finish
	server:sync();
	-- read file (only written if the plugin could be probed)
	if lpath.exists(filePath) then
		local file,err = io.open(filePath,"rb")
		assert(file,err)
		local str = file:read"*a"
		file:close()
		info = parseInfo(str)
		dict[info.key] = info
		dict[path] = info
		if key then dict[key] = info end
	else
		error("not existing "..filePath)
	end
	action(info)
end
function VSTPlugin.probe(server, path, key, wait, action)
	wait = wait or -1
	server = server or Serverdefault;
		-- resolve the path
	path = resolvePath(path);
		-- add dictionary if it doesn't exist yet
		--pluginDict[server].isNil.if { pluginDict[server] = IdentityDictionary.new };
		--server.isLocal.if { this.prProbeLocal(server, path, key, action); }
		--{ this.prProbeRemote(server, path, key, wait, action); };
	pluginDict[server] = pluginDict[server] or {}
	prProbeLocal(server, path, key, action)
end


-------------------------------------
VSTPluginController = {}
function VSTPluginController:new(synth, id, synthdef, wait)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	for i,ugen in ipairs(synthdef.Allugens) do
		if ugen.name == "VSTPlugin" then
			if ugen.id==id or id==nil then
				o:init(synth, i-1, wait)
			end
		end
	end
	return o
end
function VSTPluginController:init(synth,theIndex,wait)
	self.synth = synth
	self.synthIndex = theIndex
	self.wait = wait
	self.loaded = false
	--midi = VSTPluginMIDIProxy(this);
	self.oscFuncs = {}
	local ofc = self:prMakeOscFunc(function( msg)
			local index, value, display;
			index = msg[3] --.asInteger;
			value = msg[4] --.asFloat;
			--(msg.size > 5).if {display = this.class.msg2string(msg, 5);};
			if #msg>5 then display = msg[5] end
			-- cache parameter value
			self.paramCache[index] = {value, display};
			-- notify dependants
			--this.changed('/param', index, value, display);
		end, '/vst_param')
	table.insert(self.oscFuncs,ofc)
	ofc = self:prMakeOscFunc(function(msg)
			self.program = msg[3] --.asInteger;
			-- notify dependants
			--this.changed('/program_index', program);
		end, '/vst_program_index')
	table.insert(self.oscFuncs,ofc)
	ofc = self:prMakeOscFunc(function(msg)
			local index, name;
			index = msg[3] --.asInteger;
			name = msg[4] --this.class.msg2string(msg, 4);
			self.programNames[index] = name;
			-- notify dependants
			--this.changed('/program', index, name);
		end, '/vst_program')
	table.insert(self.oscFuncs,ofc)
	ofc = self:prMakeOscFunc(function(msg)
			local index, value;
			index = msg[3] --.asInteger;
			value = msg[4] --.asFloat;
			if self.parameterAutomated then
				self.parameterAutomated(index, value);
			end
		end, '/vst_auto')
	table.insert(self.oscFuncs,ofc)
	ofc = self:prMakeOscFunc(function(msg)
			-- convert to integers and pass as args to action
			--midiReceived.value(*Int32Array.newFrom(msg[3..]));
			assert(false)
		end, '/vst_midi')
	table.insert(self.oscFuncs,ofc)
	ofc = self:prMakeOscFunc(function(msg)
			--convert to Int8Array and pass to action
			--sysexReceived.value(Int8Array.newFrom(msg[3..]));
			assert(false)
		end, '/vst_sysex')
	table.insert(self.oscFuncs,ofc)
	OSCFunc.newfilter("/n_end",self.synth.nodeID,function(msg)
		prtable(msg)
		self:prFree()
	end,true)
end
function VSTPluginController:prFree()
		-- "VSTPluginController: synth freed!".postln;
		for i,v in ipairs(self.oscFuncs) do
			OSCFunc.clearfilters(v.path,v.template,v.handleOSCFuncLinda)
		end
		self:prClear();
		--this.changed('/free');
end
function VSTPluginController:sendMsg(cmd, ...)
	self.synth.server:sendMsg('/u_cmd', self.synth.nodeID, self.synthIndex, cmd, ...);
end
function VSTPluginController:Msg(cmd, ...)
	return self.synth.server:Msg('/u_cmd', self.synth.nodeID, self.synthIndex, cmd, ...);
end
function VSTPluginController:sendMidi(event)
	local type = event.type or 0
	local channel = event.channel or 0
	local data1 = bit.bor(bit.lshift(bit.band(type , 0xf) , 4) , bit.band(channel , 0xf));
	local data2 = event.byte2 or 0
	local data3 = event.byte3 or 0
	local blob = string.char(data1,data2,data3)
	self.synth.server:sendBundle(theMetro:ppq2time(event.delta),self:Msg('/midi_msg', {"blob",blob}))
end
function VSTPluginController:set(...)
	self:sendMsg("/set",...)
end
function VSTPluginController:program_(i)
	assert(i>=0 and i< self:numPrograms(),"program out of range")
	forkIfNeeded(function()
		self:sendMsg("/program_set",i)
		self.synth.server:sync()
		self:prQueryParams();
	end)
end
function VSTPluginController:prMakeOscFunc(func, path,runonce)
	return OSCFunc.newfilter(path,{self.synth.nodeID,self.synthIndex},function(msg)
		print(prOSC(msg))
		func(msg[2])
	end,runonce)
end
function VSTPluginController:prClear()
	self.loaded = false; self.window = false; self.info = nil;	self.paramCache = nil; self.programNames = nil; self.program = nil;
end

function VSTPluginController:editor(show) --{ arg show=true;
	if show == nil then show=true end
	if not self.window then prerror("no editor!")
	else
		self:sendMsg('/vis', show and 1 or 0)
	end
end
function VSTPluginController:open(path, editor, info, action)
	if not path then return self end
	VSTPlugin.prGetInfo(self.synth.server, path, wait,function(theInfo)
		if not theInfo then
			error("could not open "..path)
		end
		
		self:prClear()
		self:prMakeOscFunc(function(msg)
			self.loaded = msg[3] --.asBoolean;
			self.window = msg[4] --.asBoolean;
			if not self.loaded then error("could not open "..path) end
			if not theInfo then error("could not open "..path) end

			--this.slotPut('info', theInfo); // hack because of name clash with 'info'
			self.info = theInfo
			self.paramCache = TA():Fill(theInfo.numParameters, {0, nil});
			self.program = 0;
			-- copy default program names (might change later when loading banks)
			self.programNames = deepcopy(theInfo.programNames);
			self:prQueryParams();
			-- post info if wanted
			if info then prtable(theInfo) end
			if action then	action(self, self.loaded); end
			--this.changed('/open', path, loaded);
			end, '/vst_open',true) --.oneShot;
			-- don't set 'info' property yet
			self:sendMsg('/open', theInfo.key, editor and 1 or 0);

		end)
end
function VSTPluginController:numPrograms()
	return self.info and self.info.numPrograms or 0
end
function VSTPluginController:numParameters()
	return self.info and self.info.numParameters or 0
end
function VSTPluginController:prQueryParams(wait)
	local inittim = lanes.now_secs()
	self:prQuery(wait, self:numParameters(), '/param_query');
	print("prQueryParams",lanes.now_secs()-inittim)
end
function VSTPluginController:prQueryPrograms(wait)
	self:prQuery(wait, self:numPrograms(), '/program_query');
end
function VSTPluginController:prQuery(wait, num, cmd)
	forkIfNeeded(function()
	local bsiz = 64 --16
	local div, mod;
	div = math.floor(num/bsiz);
	mod = num%bsiz
	wait = wait or self.wait;
	-- request bsiz parameters/programs at once
	for i=1,div do
		self:sendMsg(cmd,(i-1)*bsiz, bsiz)
		if wait then
			error"dont do that"
			wait(wait)
		else
			self.synth.server:sync(nil,true)
		end
	end

	-- request remaining parameters/programs
	if mod > 0 then self:sendMsg(cmd, num - mod, mod) end
	end)
end

--ddd = "key="
--require"sc.utils"
--eee = stsplit(ddd,"=")
--prtable(eee)