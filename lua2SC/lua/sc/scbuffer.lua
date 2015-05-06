

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
function FileBuffer(filename,samples,inisample)
	samples=samples or 0
	inisample=inisample or 0
	local buf=SCBuffer:new({filename = filename,samples=samples,inisample=inisample,isFileBuffer=true})
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
	buf:Init(true)
	return buf
end
function SCBuffer:setn(data,ini)
	ini = ini or 0
	self.data = data or self.data
	assert(#self.data <= self.samples)
	local dd = {{"int32",self.buffnum},{"int32",ini},{"int32",#self.data}}
	--dd = concatTables(dd,self.data)
	for i,v in ipairs(self.data) do
		dd[#dd + 1] = {"float",v}
	end
	udp:send(toOSC{"/b_setn",dd})
end
function SCBuffer:alloc(block)
	--print("calling b_alloc")
	--prtable(self)
	local dgram=toOSC({"/b_alloc",{{"int32",self.buffnum},{"int32",self.samples},{"int32",self.channels}}})
	if block==nil then block=false end
	if block then
		udpB:send(dgram)
		local dgram2 = assert(udpB:receive(),"Not receiving from SCSYNTH\n")
		printDone(fromOSC(dgram2))
	else
		udp:send(dgram)
    end
end
function SCBuffer:read()

	udpB:send(toOSC({"/b_read",{{"int32",self.buffnum},self.filename,
	{"int32",0}, --start file
	{"int32",self.samples}--,
	--{"int32",0}, --start buffer
	--{"int32",0} --leave open 0 1 for DiskIn
	}})) 
	dgram = assert(udpB:receive())
	if dgram then
		msg=fromOSC(dgram)
		printDone(msg)
	else
        print("no datagram")
	end
end
--"aiff", "next", "wav", "ircam", "raw"
--"int8", "int16", "int24", "int32", "float", "double", "mulaw", "alaw"
function SCBuffer:write()

	udpB:send(toOSC({"/b_write",{{"int32",self.buffnum},self.filename,self.header_format,self.samples_format,
	{"int32",-1}, --frames to write
	{"int32",0}, --start buffer
	{"int32",self.leaveopen} --leave open 0 1 for DiskIn
	}})) 
	dgram = assert(udpB:receive())
	if dgram then
		msg=fromOSC(dgram)
		printDone(msg)
	else
        print("no datagram")
	end
end
function SCBuffer:allocRead(block)
	assert(self.filename)
	local dgram=toOSC{"/b_allocRead",{{"int32",self.buffnum},{"string",self.filename},{"int32",self.inisample},{"int32",self.samples}}}
	if block==nil then block=false end
	if block then
		udpB:send(dgram)
		local dgram2 = assert(udpB:receive(),"Not receiving from SCSYNTH\n")
		printDone(fromOSC(dgram2),"allocRead response:")
		print("allocRead",self.filename)
	else
		udp:send(dgram)
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
	print("inicio queryinfo")
	local dgram=toOSC({"/b_query",{{"int32",self.buffnum}}})
	if block==nil then block=false end
	if block then
		udpB:send(dgram,"/b_info")
		local dgram2 = assert(udpB:receive(),"Not receiving from SCSYNTH\n")
		printB_info(fromOSC(dgram2))
	else
		udp:send(dgram)
    end
	print("fin queryinfo")
end
function SCBuffer:free(block)
	local dgram=toOSC({"/b_free",{{"int32",self.buffnum}}})
	if block==nil then block=false end
	if block then
		udpB:send(dgram)
		local dgram2 = assert(udpB:receive(),"Not receiving from SCSYNTH\n")
		printDone(fromOSC(dgram2))
	else
		udp:send(dgram)
    end
end
function SCBuffer:close(block)
	local dgram=toOSC{"/b_close",{self.buffnum}}
	if block==nil then block=true end
	if block then
		udpB:send(dgram)
		local dgram2 = assert(udpB:receive(),"Not receiving from SCSYNTH\n")
		printDone(fromOSC(dgram2))
	else
		udp:send(dgram)
    end
end
function SCBuffer:Init(block)
	if self.isFileBuffer then
		self:allocRead(true)
		self:queryinfo(true)
	elseif self.isDiskOutBuffer then
		self:alloc(true)
		self:write(true)
		self.DiskOutNode = GetNode()
		assert(Master.node)
		udp:send(toOSC{"/s_new",{ "DiskoutSt", self.DiskOutNode,3, Master.node, "bufnum", self.buffnum,"busin",self.recording_bus}});
		print("init disk out")
		prtable(self)
		self:queryinfo(true)
	elseif self.isDataBuffer then
		self:alloc(true)
		self:setn()
		self:queryinfo(true)
	else
		self:alloc(true)
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
			udp:send(toOSC{"/n_free",{v.DiskOutNode}});
			print("going to close isDiskOutBuffer")
			v:close(true)
			print("end free disk")
		end
		v:free(true)
	end
 end)