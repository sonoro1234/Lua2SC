

Buffers={}
SCBuffer={filename=nil,samples=0,channels=1,inisample=0,leaveopen=0}
function SCBuffer:new(o)
	o = o or {}
	o.buffnum=GetBuffNum()
	setmetatable(o, self)
	self.__index = self
	return o
end
GetBuffNum=IDGenerator()

function Buffer(channels,samples)
	local buf=SCBuffer:new({channels = channels,samples=samples})
	table.insert(Buffers,buf)
	buf:Init(true)
	return buf
end
function FileBuffer(filename,chan,samples,inisample)
	chan = chan or -1
	samples=samples or -1
	inisample=inisample or 0
	local buf=SCBuffer:new({filename = filename,channels=-1,samples=samples,inisample=inisample,isFileBuffer=true,chan=chan})
	table.insert(Buffers,buf)
	buf:Init(true)
	return buf
end
function DataBuffer(data)
	samples=#data
	inisample=inisample or 0
	local buf=SCBuffer:new({filename = filename,samples=samples,inisample=inisample,isDataBuffer=true,data = data})
	table.insert(Buffers,buf)
	buf:Init(true)
	return buf
end
function DiskOutBuffer(filename,recording_bus,channels,header_format,samples_format,samples,inisample)
	samples=samples or 131072 
	inisample=inisample or 0
	channels = channels or 2
	recording_bus = recording_bus or 0
	samples_format = samples_format or "float"
	header_format = header_format or "wav"
	local buf=SCBuffer:new({filename = filename,channels = channels,samples=samples,inisample=inisample,
	header_format=header_format,samples_format=samples_format,leaveopen=1,isDiskOutBuffer=true,recording_bus=recording_bus})
	table.insert(Buffers,buf)
	--buf:Init(true)
	table.insert(initCbCallbacks,function() buf:Init(true) end)
	return buf
end
function SCBuffer:setn(data,ini)
	ini = ini or 0
	self.data = data or self.data
	local size = #self.data
	if size < 16000 then
	assert(#self.data <= self.samples)
	local dd = {{"int32",self.buffnum},{"int32",ini},{"int32",#self.data}}
	--dd = concatTables(dd,self.data)
	for i,v in ipairs(self.data) do
		dd[#dd + 1] = {"float",v}
	end
    sendBundle({"/b_setn",dd})
	else
		--send in chunks
		local dataleft = size
		local chunksize = 10000
		local thischunkini = ini
		repeat
		local thischunksize = math.min(dataleft,chunksize)

		local dd = {{"int32",self.buffnum},{"int32",thischunkini},{"int32",thischunksize}}
		for i=1,thischunksize do
			dd[#dd + 1] = {"float",self.data[thischunkini + i]}
		end
		sendBundle({"/b_setn",dd})
		dataleft = dataleft - thischunksize
		thischunkini = thischunkini + thischunksize
		until(dataleft==0)
	end
end
function SCBuffer:alloc(block)

	local msg = {"/b_alloc",{{"int32",self.buffnum},{"int32",self.samples},{"int32",self.channels}}}
	if block==nil then block=false end
	if block then
		local res = sendBlocked(msg)
		printDone(res)
	else
        sendBundle(msg)
    end
end
function SCBuffer:read()

	local msg = {"/b_read",{{"int32",self.buffnum},self.filename,
	{"int32",0}, --start file
	{"int32",self.samples}--,
	--{"int32",0}, --start buffer
	--{"int32",0} --leave open 0 1 for DiskIn
	}}
	local res = sendBlocked(msg)
    printDone(res)
end
--"aiff", "next", "wav", "ircam", "raw"
--"int8", "int16", "int24", "int32", "float", "double", "mulaw", "alaw"
function SCBuffer:write(when)

	local msg = {"/b_write",{{"int32",self.buffnum},self.filename,self.header_format,self.samples_format,
	{"int32",-1}, --frames to write
	{"int32",0}, --start buffer
	{"int32",self.leaveopen} --leave open 0 1 for DiskIn
	}}
	--local res = sendBlocked(msg)
    --printDone(res)
	sendBundle(msg,when)
	-- if dgram then
		-- msg=fromOSC(dgram)
		-- printDone(msg)
	-- else
        -- print("no datagram")
	-- end
end
function SCBuffer:allocRead(block)
	assert(self.filename)
	local msg = {"/b_allocRead",{{"int32",self.buffnum},{"string",self.filename},{"int32",self.inisample},{"int32",self.samples}}}
	if block==nil then block=false end
	if block then
		local res = sendBlocked(msg)
		printDone(res,"allocRead response:")
		print("allocRead",self.filename)
	else
		sendBundle(msg)
    end
end
function SCBuffer:allocReadChannel(block)
	assert(self.filename)
	local channels
	if type(self.chan)=="number" then
		channels = {self.chan}
	else
		channels = deepcopy(self.chan)
	end
	channels[#channels+1] = {"blob",""} --supernova needs that
	local msg = {"/b_allocReadChannel",{{"int32",self.buffnum},{"string",self.filename},{"int32",self.inisample},{"int32",self.samples},unpack(channels)}}
	if block==nil then block=false end
	if block then
		local res = sendBlocked(msg)
		printDone(res,"allocReadChannel response:")
		print("allocReadChannel",self.filename,self.chan)
	else
		sendBundle(msg)
    end
end
function printB_info(msg)
	if(msg[1]=="/b_info") then
		print("buffer:",msg[2][1]," frames:",msg[2][2]," channels:",msg[2][3]," samprate:",msg[2][4])
	else
		print(tb2st)
	end
end
function SCBuffer:queryinfo(block)

	local msg = {"/b_query",{{"int32",self.buffnum}}}
	if block==nil then block=false end
	if block then
		local res = sendBlocked(msg)
		assert(self.buffnum == res[2][1])
		if self.channels==-1 then
			self.channels = res[2][3]
		else
			assert(self.channels == res[2][3])
		end
		self.frames = res[2][2]
		self.samprate = res[2][4]
		printB_info(res)
	else
		sendBundle(msg)
    end

end
function SCBuffer:free(block)
	local msg = {"/b_free",{{"int32",self.buffnum}}}
	if block==nil then block=false end
	if block then
		local res = sendBlocked(msg)
		printDone(res)
	else
		sendBundle(msg)
    end
end
function SCBuffer:close(block)
	local msg = {"/b_close",{self.buffnum}}
	if block==nil then block=true end
	if block then
		local res = sendBlocked(msg)
		printDone(res)
	else
		sendBundle(msg)
    end
end
function SCBuffer:Init(block)
	if self.isFileBuffer then
		if self.chan == -1 then
			self:allocRead(true)
			self:queryinfo(true)
		else
			self:allocReadChannel(true)
			self:queryinfo(true)
		end
	elseif self.isDiskOutBuffer then
		--local when = theMetro:ppq2time(5)
		self:alloc(true)
		self:write(nil)
		self.DiskOutNode = GetNode()
		assert(Master.node)
		sendBundle({"/s_new",{ "DiskoutSt", self.DiskOutNode,3, Master.node, "bufnum", self.buffnum,"busin",self.recording_bus}})--,when);
		print("init disk out")
		prtable(self)
		self:queryinfo(true)
	elseif self.isDataBuffer then
		self:alloc(true)
		self:setn()
		self:queryinfo(true)
	else
		self:alloc(true)
		self:queryinfo(true)
	end
end

-- table.insert(initCbCallbacks,function()
	-- print("init buffers")
	-- for i,v in ipairs(Buffers) do
		-- v:Init(true)
	-- end
 -- end)
 table.insert(resetCbCallbacks,function()
	print("reset buffers")
	for i,v in ipairs(Buffers) do
		if v.isDiskOutBuffer then
			print("reset isDiskOutBuffer")
			prtable(v)
			sendBundle({"/n_free",{v.DiskOutNode}});
			print("going to close isDiskOutBuffer")
			v:close(true)
			print("end free disk")
		end
		v:free(true)
	end
	--liberar los de sclua
	local s = require"sclua.Server".Server()
	for k,v in pairs(s.allbuffers) do
		k:free()
	end
 end)