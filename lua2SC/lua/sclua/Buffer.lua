local funcs = require("sclua.funcs")

local Buffer_metatable = {}
Buffer_metatable.__index = Buffer_metatable


function Buffer_metatable:alloc(numframes, numchannels,cmplMsg)
	numchannels = numchannels or 1
	OSCFunc.newfilter("/b_info",self.bufnum,self:queryresponse(),true)
	ThreadServerSendT{{'/b_alloc', {self.bufnum, numframes, numchannels}},{"/b_query",{self.bufnum}}}
	return self
end

function Buffer_metatable:allocRead(path,start,numframes)
	start = start or 0
	numframes = numframes or -1
	OSCFunc.newfilter("/b_info",self.bufnum,self:queryresponse(),true)
	--ThreadServerSendT{{'/b_allocRead', {self.bufnum, path, start, numframes}},{"/b_query",{self.bufnum}}}
	ThreadServerSend{'/b_allocRead', {self.bufnum, path, start, numframes,{"blob",toOSC({"/b_query",{self.bufnum}})}}}
end

function Buffer_metatable:allocReadChannel(path,start,numframes,channels)
	start = start or 0
	numframes = numframes or -1
	channels = channels or {0}
	--channels[#channels+1] = {"blob",""} --supernova needs that no more
	OSCFunc.newfilter("/b_info",self.bufnum,self:queryresponse(),true)
	local msg = {'/b_allocReadChannel', {self.bufnum, path, start, numframes,unpack(channels)}}
	table.insert(msg[2],{"blob",toOSC({"/b_query",{self.bufnum}})})
	ThreadServerSend(msg)
end

function Buffer_metatable:read(path,start,numframes,bufstart,leaveopen)
	start = start or 0
	numframes = numframes or -1
	bufstart = bufstart or 0
	leaveopen = leaveopen or 0
	OSCFunc.newfilter("/done",{"/b_read",self.bufnum},function(msg) prtable(msg) end,true)
	ThreadServerSend(self.server:Msg('/b_read', self.bufnum, path, start, numframes,bufstart,leaveopen))
end

--Header format is one of:
--"aiff", "next", "wav", "ircam"", "raw"
--Sample format is one of:
--"int8", "int16", "int24", "int32", "float", "double", "mulaw", "alaw"
function Buffer_metatable:write(path,headerf,samplef, numframes, bufstart, leaveopen, cmplMsg)
	headerf = headerf or "wav"
	samplef = samplef or "float"
	numframes = numframes or -1
	bufstart = bufstart or 0
	leaveopen = leaveopen or 0
	OSCFunc.newfilter("/done",{"/b_write",self.bufnum},function(msg)  end,true)
	ThreadServerSend(self.server:Msg('/b_write', self.bufnum, path, headerf, samplef, numframes, bufstart, leaveopen,cmplMsg))
end

function Buffer_metatable:free()
	self.server:sendMsg('/b_free', self.bufnum)
	self.server.allbuffers[self] = nil
end

function Buffer_metatable:zero()
	self.server:sendMsg('/b_zero', self.bufnum)
end

function Buffer_metatable:set(index, value)
	self.server:sendMsg('/b_set', self.bufnum, index, value)
end

function Buffer_metatable:setn(index, numsamples, value) -- not ready perphas ... instead of value or use unpack
	self.server:sendMsg('/b_setn', self.bufnum, index, numsamples, unpack(value))
end

function Buffer_metatable:fill(index, numsamples, value)
	self.server:sendMsg('/b_fill', self.bufnum, index, numsamples, value)
end

function Buffer_metatable:close()
	self.server:sendMsg('/b_close', self.bufnum)
end

function Buffer_metatable:queryresponse()
	return function(msg)
			print("buffer:",msg[2][1]," frames:",msg[2][2]," channels:",msg[2][3]," samprate:",msg[2][4])
			self.frames = msg[2][2]
			self.channels = msg[2][3]
			end
end
function Buffer_metatable:query(block)
	if block then
		print("blockin on b_query",self.bufnum)
		local tmplinda = lanes.linda()
		OSCFunc.newfilter("/b_info",self.bufnum,self:queryresponse(),true,true,tmplinda)
		ThreadServerSend(self.server:Msg('/b_query', self.bufnum))
		local key,val = tmplinda:receive("OSCReceive") -- wait
		OSCFunc.handleOSCReceive(val) -- clean responder and print
	else
	OSCFunc.newfilter("/b_info",self.bufnum,self:queryresponse(),true)
	ThreadServerSend(self.server:Msg('/b_query', self.bufnum))
	end
end

function Buffer_metatable:get(index)
	self.server:sendMsg('/b_get', self.bufnum, index)
end

function Buffer_metatable:getn(index, numsamples,action)
	assert(numsamples)
	if action then
		OSCFunc.newfilter("/b_setn",self.bufnum,function(msg2)
			--prtable(msg2)
			local t = {}
			for i=4,#msg2[2] do
				t[#t+1] = msg2[2][i]
			end
			action(t)
		end,true)
	end
	ThreadServerSend(self.server:Msg('/b_getn', self.bufnum, index, numsamples))
end

function Buffer_metatable:loadToFloatArray(index, count, action)
	--forkIfNeeded(function()
	index = index or 0
	count = count or -1
	local tmpPath = os.tmpname()
	self:write(tmpPath, "wav", "float", count, index)
	self.server:sync()
	local sndfile = require"sndfile_ffi"
	local ffi = require"ffi"
	local sf = sndfile.Sndfile(tmpPath)
	--print("sf load",tmpPath,sf:channels(),sf:frames(),sf:samplerate(),sf:format())
	local samples = tonumber(sf:channels()*sf:frames())
	--print("samples",samples,type(samples))
	local rbuff = ffi.new("float[?]",samples)
	local readen = sf:readf_float(rbuff, sf:frames())
	--assert(200==readen)
	if sf:frames()~=readen then
		prerror("sf error:",sndfile.C.sf_error(sf.sf))
	end
	local ret = {}
	for i=0,samples-1 do
		ret[i+1] = rbuff[i]
	end

	sf:close()
	local ok,err = os.remove(tmpPath)
	if not ok then prerror("could not delete tmp file ",err) end
	--print"calling action"
	if action then action(ret) end
	--print"called action"
	return ret
	--end)
end

function Buffer_metatable:__gc() 
	self:free() 
end

-- support garbage collection:
function Buffer_metatable:__gc() 
	self:free() 
end


return Buffer_metatable

