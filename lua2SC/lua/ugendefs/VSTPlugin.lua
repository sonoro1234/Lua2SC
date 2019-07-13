VSTPlugin = MultiOutUGen:new({name="VSTPlugin"})
local Serverdefault = require"sclua.Server".Server()
function VSTPlugin.ar(input, numOut, bypass, params, id)
	id = id or "nullid"
	numOut = numOut or 1
	bypass = bypass or 0
	local numIn = 0
	if input then
		numIn = #input or 1
	else
		input = {}
	end
	return VSTPlugin:MultiNew(concatTables({2,id, numOut, bypass, numIn},input,params))
end
local pluginDict = {}
function VSTPlugin:init( theID, numOut ,... )
		if theID~="nullid" then self.id = theID end
		self.inputs = {...}
		return self:initOutputs(numOut)
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
local function searchLocal(server, searchPaths, useDefault, verbose, action)
	--local filePath =   lua2scpath.."tmpvst"
	local filePath = os.tmpname()
	useDefault = useDefault and 1 or 0
	verbose = verbose and 1 or 0

	-- flags: local, use default, verbose
	local flags = bit.bor(1 , bit.lshift(useDefault , 1) , bit.lshift(verbose, 2))
	local tmp = concatTables(searchPaths,filePath)
	server:sendMsg('/cmd', '/vst_search', flags,unpack(tmp));
	server:sync()
	local file,err = io.open(filePath,"rb")
	assert(file,err)
	local str = file:read"*a"
	print("filePath",filePath)
	print(str)
	file:close()

	local dict = pluginDict[server]
	local infos = stsplit(str,"\n")
	for i,line in ipairs(infos) do
		if not (line=="") then
		local info = parseInfo(line)
		dict[info.key] = info
		end
	end
end
function VSTPlugin.search(server, dir, useDefault, verbose, wait, action)
	server = server or require"sclua.Server".Server()
	useDefault = useDefault or true
	if not verbose then verbose = false end
	wait = wait or -1
	if dir then
		if type(dir)=="string" then dir = {dir} end
	else
		dir = {}
	end
	for i,v in ipairs(dir) do
		dir[i] = resolvePath(v)
	end
	pluginDict[server] = pluginDict[server] or {}
	searchLocal(server, dir, useDefault, verbose, action)
end
function VSTPlugin.getDict(server)
	server = require"sclua.Server".Server()
	return pluginDict[server]
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
	self:sendMsg("/program_set",i)
	self.synth.server:sync()
	self:prQueryParams();
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

end
