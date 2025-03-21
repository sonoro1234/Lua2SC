require"lanesutils"

if jit then
	ffi = require("ffi")
	ffi.cdef[[
typedef unsigned int uint32;
typedef struct WorldOptions
{
	const char* mPassword;
	uint32 mNumBuffers;
	uint32 mMaxLogins;
	uint32 mMaxNodes;
	uint32 mMaxGraphDefs;
	uint32 mMaxWireBufs;
	uint32 mNumAudioBusChannels;
	uint32 mNumInputBusChannels;
	uint32 mNumOutputBusChannels;
	uint32 mNumControlBusChannels;
	uint32 mBufLength;
	uint32 mRealTimeMemorySize;
	
	int mNumSharedControls;
	float *mSharedControls;
	
	bool mRealTime;
	bool mMemoryLocking;
	float mSafetyClipThreshold;// = 1.26;
	
	const char *mNonRealTimeCmdFilename;
	const char *mNonRealTimeInputFilename;
	const char *mNonRealTimeOutputFilename;
	const char *mNonRealTimeOutputHeaderFormat;
	const char *mNonRealTimeOutputSampleFormat;
	
	uint32 mPreferredSampleRate;
	
	uint32 mNumRGens;
	
	uint32 mPreferredHardwareBufferFrameSize;
	
	uint32 mLoadGraphDefs;
	
	const char *mInputStreamsEnabled;
	const char *mOutputStreamsEnabled;
	const char *mInDeviceName;
	
	int mVerbosity;
	
	bool mRendezvous;
	
	const char *mUGensPluginPath;
	
	const char *mOutDeviceName;
	
	const char *mRestrictedPath;
	
	int mSharedMemoryID;
} WorldOptions_t;


/////////////////////////////
//SC_Reply.h
struct ReplyAddress;
typedef void (*ReplyFunc)(struct ReplyAddress* inReplyAddr, char* inBuf, int inSize);

typedef int (*PrintFunc)(const char* format, va_list ap);

struct SndBuf;

void SetPrintFunc(PrintFunc func);
struct World* World_New(struct WorldOptions* inOptions);
void World_Cleanup(struct World* inWorld, bool unload_plugins);// = false);
void World_NonRealTimeSynthesis(struct World* inWorld, struct WorldOptions* inOptions);
int World_OpenUDP(struct World* inWorld, const char* bindTo, int inPort);
int World_OpenTCP(struct World* inWorld, const char* bindTo, int inPort, int inMaxConnections,
                  int inBacklog);
void World_WaitForQuit(struct World* inWorld, bool unload_plugins); // = false);
bool World_SendPacket(struct World* inWorld, int inSize, char* inData, ReplyFunc inFunc);
bool World_SendPacketWithContext(struct World* inWorld, int inSize, char* inData, ReplyFunc inFunc,
                                 void* inContext);
int World_CopySndBuf(struct World* world, uint32 index, struct SndBuf* outBuf, bool onlyIfChanged,
                     bool* didChange);
int scprintf(const char* fmt, ...);

]]

SCFFI = {}
function lanebody(linda)
	--print"---------enter lanebody"
	local ffi = require("ffi")
	require"osclua"
	ffi.cdef[[typedef void (*ReplyFunc)(struct ReplyAddress *inReplyAddr, char* inBuf, int inSize);]]
	local trace = false
	local tracestatus = false
	local Filters = {}
	local function ReplyFunS(addr,inbuf,size) 
		--print("ReplyFunS",addr,inbuf,size)
		if size == 0 then return end --sometimes sc sends 0 size
		local oscm = ffi.string(inbuf,size)
		local msg = osclua.fromOSC(oscm)

		local key,val = linda:receive(0,"sendsc","clearFilter","addFilter","trace","exit")
		while val do 
			if key == "addFilter" then -- /path, linda, block
				Filters[val[1]] = Filters[val[1]] or {}
				Filters[val[1]][val[2]] = true
				if val[3] then val[3]:send("addFilterResponse",1) end --for block
			elseif key == "clearFilter" then
				if Filters[val[1]]  then
					Filters[val[1]][val[2]] = nil
					if #Filters[val[1]] == 0 then
						Filters[val[1]] = nil
					end
				end
            elseif key == "sendsc" then
                --not needed --see SCFFI:send
			elseif key == "trace" then
                trace = val[1]
				tracestatus = val[2]
				prtable(Filters)
            elseif key == "exit" then
                --not needed : see SCFFI:close
				--return true
			end
			key,val = linda:receive(0,"sendsc","clearFilter","addFilter","trace","exit")
		end
		if trace then
			if msg[1]~="/status.reply" or tracestatus then
				print("SCFFI: "..prOSC(msg))
			end
		end
		if msg[1]=="/metronom" then
			scriptlinda:send("/metronom",msg[2])
		elseif msg[1]=="/vumeter" then
			scriptguilinda:send("/vumeter",msg[2])
		elseif msg[1]=="/status.reply" then
			idlelinda:send("/status.reply",msg[2])
		elseif msg[1] == "/fail" then
			scriptlinda:send("OSCReceive",msg)
		elseif Filters[msg[1]] then
			for onelinda,_ in pairs(Filters[msg[1]]) do
				onelinda:send("OSCReceive",msg)
			end
		elseif Filters.ALL then
			msg[1] = "ALL"
			for onelinda,_ in pairs(Filters.ALL) do
				onelinda:send("OSCReceive",msg)
			end
		--else --use OSCFunc.trace
			--print("SCFFI: "..prOSC(msg))
		end
	end
	 --local ptr = tonumber(ffi.cast('uintptr_t', ffi.cast('void *', cb)))
	local cb = ffi.cast("ReplyFunc",ReplyFunS)
	local ptr = ffi.cast('uintptr_t', ffi.cast('void *', cb))
	--print("cbbb "..tostring(cb).." "..tostring(ptr).." "..tostring(tonumber(ptr)))
	linda:send("func",tonumber(ptr))
end
function laneprint(linda)
	local ffi = require("ffi")
	ffi.cdef[[typedef int (*PrintFunc)(const char *format, va_list ap);]]
	
	ffi.cdef[[int snprintf(char *buffer, size_t n, const char *fmt,...);
	int sprintf(char *buffer, const char *fmt,...);
	int printf(const char *fmt, ...);
	int vsprintf(char *target, const char *format, va_list arg_ptr);
	int vsnprintf(char *target, size_t n, const char *format, va_list arg_ptr);]]

	local function PrintFuncFFI(str,n) 
		print(ffi.string(str))
		return 1
	end
	local function sc_print(...)
		--local str=""
		--for i=1, select('#', ...) do
		--	str = str .. tostring(select(i, ...))
		--end
		--str = str .. "\n"
		idlelinda:send("proutSC",table.concat({...}))
	end
	local buf = ffi.new("char[1024]")
	local function PrintFunc(fmt,...) 
		--ffi.C.snprintf(buf,1024,fmt,...)
		--ffi.C.vsprintf(buf,fmt,...)
		local ret = ffi.C.vsnprintf(buf,1024,fmt,...)
		--ffi.C.printf(fmt,...)
		if ret > 0 then
			sc_print(ffi.string(buf))
		else
			sc_print"failure in vsnprintf"
		end
		--print(string.format(ffi.string(fmt),...))
		return 0
	end

	local cb = ffi.cast("PrintFunc",PrintFunc)
	local ptr = ffi.cast('uintptr_t', ffi.cast('void *', cb))
	linda:send("func_print",tonumber(ptr))
end

function SCFFI:init(options,linda)
	
	--local path = wx.wxFileName.SplitPath(options.SCpath)
	local path = splitpath(options.SCpath)
	if not self.libsc then
		print("load from",path..[[liblibscsynth.dll]])
		local lfs = require"lfs"
		local succes,msg = lfs.chdir(path)
        if not succes then
            print("cant chdir "..path,msg)
        end
		local succes,msg = lfs.attributes(path..[[liblibscsynth.dll]])
        if not succes then
            print("cant find "..path,msg)
		else
			print("found:",path..[[liblibscsynth.dll]])
        end
		--self.libsc = ffi.load(path..[[liblibscsynth]])
        local succes,res = pcall(ffi.load,path..[[liblibscsynth.dll]])
        if succes then 
            self.libsc = res
        else
            print(res)
            return false
        end
	end
	print("self.libsc",self.libsc)
		local globals={
				print=thread_print, --comment to dont loose info
				prerror=thread_error_print,
				prOSC=prOSC,
				idlelinda = idlelinda,
				scriptguilinda = scriptguilinda,
				scriptlinda = scriptlinda
				}
	------------------------------------
	---[[ comment to see in console
	self.print_lane = lanegen(laneprint,globals,"laneprint")(true,linda)
	local key, print_func = linda:receive("func_print")
	self.print_func = ffi.cast("PrintFunc",print_func)
	self.libsc.SetPrintFunc(self.print_func)
	--]]
	--------------------------------------
	local plugpath = path..[[/plugins]]
	for i,v in ipairs(options.SC_PLUGIN_PATH) do
		if(v=="default") then
		else
			--TODO linux uses ":"
			plugpath = plugpath..[[;]]..v --..[["]]
		end
	end
	
	local mUGensPluginPath = plugpath
	local kDefaultWorldOptions = ffi.new("WorldOptions_t",nil,1024,64,1024,1024,64,1024,8,8,16384,64,8192, 0,nil, true, false,1.26, nil,nil,nil,nil,nil,44100,64, 0, 1,nil, nil, nil,2,true,mUGensPluginPath,nil,nil,0)
	kDefaultWorldOptions.mInDeviceName =  options.SC_AUDIO_DEVICE
	kDefaultWorldOptions.mOutDeviceName =  options.SC_AUDIO_DEVICE
	self.theworld = self.libsc.World_New(kDefaultWorldOptions)
	--print("self.theworld",self.theworld)

	self.resp_lane = lanegen(lanebody,globals,"oscresponder")(true,linda)
	--print("waiting for func")
	local key,respfunc = linda:receive("func")
	--print("respfunc", key, respfunc)
	self.respfunc = ffi.cast("ReplyFunc",respfunc)
	--print("self.respfunc", self.respfunc)
	self:send(toOSC({"/notify",{1}}))
    return true
end
function SCFFI:close()
	print("World_WaitForQuit going",self.theworld)
	self.libsc.World_WaitForQuit(self.theworld, true)
	--self.libsc.World_Cleanup(self.theworld) -- called by World_WaitForQuit
	print"World_WaitForQuit done"
	---[[
	if self.resp_lane then
		local cancelled,reason = self.resp_lane:cancel(1)
		if cancelled then
			self.resp_lane = nil
		else
			print("Unable to cancel SCFFI.resp_lane",cancelled,reason)
		end
	end
	if self.print_lane then
		local cancelled,reason = self.print_lane:cancel(1)
		if cancelled then
			self.print_lane = nil
		else
			print("Unable to cancel SCFFI.print_lane",cancelled,reason)
		end
	end
	--]]
end
--function SCFFI:quit()
	--do nothing in internal
--end
function SCFFI:send(msg)
	local function string2char(txt)
		local cmddata = ffi.new("char[?]",#txt + 1)
		ffi.copy(cmddata,txt)
		return cmddata
	end
	--prtable(osclua.fromOSC(msg))
	local ret = self.libsc.World_SendPacket(self.theworld, #msg, string2char(msg), self.respfunc)
	if not ret then print("World_SendPacket error") end
end
end -- if jit

return SCFFI