function lanegen(func_body,globals,thread_name)
	thread_name = thread_name or "unamed thread"
	local function prstak(stk)
		local str=""
		for i,lev in ipairs(stk) do
			str= str..i..": \n"
			for k,v in pairs(lev) do
				str=str.."\t["..k.."]:"..v.."\n"
			end
		end
		print(str)
	end
	
	local function finalizer_func(err,stk)
		print(thread_name.." finalizer:")
		if err and type(err)~="userdata" then 
			print( thread_name.." after error: "..tostring(err) )
			print(thread_name.." finalizer stack table")
			prstak(stk)
		elseif type(err)=="userdata" then
			print( thread_name.." after cancel " )
		else
			print( thread_name.." after normal return" )
		end
	end
	local function outer_func(block,...)
		
		lanes = require "lanes" --.configure()
		--lanes.require"lanes"
		set_finalizer( finalizer_func ) 
		set_error_reporting("extended")
		set_debug_threadname(thread_name)
		func_body(...)
		
		if block then
			local block_linda = lanes.linda()
			block_linda:receive("unblock")
		end
	end
	return lanes.gen("*",{globals=globals},outer_func)
end
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


//const struct WorldOptions kDefaultWorldOptions ={0,1024,64,1024,1024,64,128,8,8,4096,64,8192, 0,0, 1, 0,0,0,0,0,0,44100,64, 0, 1,0, 0, 0,2,1,0,0,0,0};

struct World* World_New(struct WorldOptions *inOptions);
void World_WaitForQuit(struct World *inWorld);
void World_Cleanup(struct World *inWorld);
//struct ReplyAddress;
typedef void (*ReplyFunc)(struct ReplyAddress *inReplyAddr, char* inBuf, int inSize);
typedef int (*PrintFunc)(const char *format, va_list ap);
void SetPrintFunc(PrintFunc func);
bool World_SendPacket(struct World *inWorld, int inSize, char *inData, ReplyFunc inFunc);
]]

SCFFI = {}
function lanebody(linda)
	local ffi = require("ffi")
	require"osclua"
	ffi.cdef[[typedef void (*ReplyFunc)(struct ReplyAddress *inReplyAddr, char* inBuf, int inSize);]]
	--ffi.cdef[[unsigned long GetCurrentThreadId(void);unsigned long __stdcall GetCurrentThread(void);]]
	--local kernel32 = ffi.load("kernel32");
	local Filters = {}
	local function ReplyFunS(addr,inbuf,size) 
		if size == 0 then return end --sometimes sc sends 0 size
		local oscm = ffi.string(inbuf,size)
		local msg = osclua.fromOSC(oscm)

		local key,val = linda:receive(0,"clearFilter","addFilter")
		while val do 
			if key == "addFilter" then -- /path, linda, block
				--print("SCFFI: addFilter",val[1],val[2])
				Filters[val[1]] = Filters[val[1]] or {}
				Filters[val[1]][val[2]] = true
				if val[3] then val[3]:send("addFilterResponse",1) end --for block
			elseif key == "clearFilter" then
				--print("SCFFI: clearFilter",val)
				if Filters[val[1]]  then
					Filters[val[1]][val[2]] = nil
					if #Filters[val[1]] == 0 then
						Filters[val[1]] = nil
					end
				end
			end
			key,val = linda:receive(0,"addFilter","clearFilter")
		end

		--print("UDPSC: "..prOSC(msg))
		--print("SCUDP receives",msg[1])
		if msg[1]=="/metronom" then
			--prtable(msg)
			--setMetronom(msg[2][2],msg[2][3])
			scriptlinda:send("/metronom",msg[2])
		elseif msg[1]=="/vumeter" then
			--setVumeter(msg[2])
			scriptguilinda:send("/vumeter",msg[2])
		--elseif msg[1]=="/b_setn" then
			--setVumeter(msg[2])
			--scriptguilinda:send("/b_setn",msg[2])
		elseif msg[1]=="/status.reply" then
			idlelinda:send("/status.reply",msg[2])
			--print("UDPSC: "..prOSC(msg))
		--elseif msg[1]=="/n_go" or msg[1]=="/n_end" or msg[1]=="/n_on" or msg[1]=="/n_off" or msg[1]=="/n_move" or msg[1]=="/n_info" then
			--printN_Go(msg)
		elseif msg[1] == "/fail" then
			idlelinda:send("OSCReceive",msg)
		elseif Filters[msg[1]] then
			for onelinda,_ in pairs(Filters[msg[1]]) do
				--print("SCFFIsending",msg[1],onelinda)
				onelinda:send("OSCReceive",msg)
			end
		--else
			--print("UDPSC: NOT sended:"..prOSC(msg))
		end

	end

	cbbb = ffi.cast("ReplyFunc",ReplyFunS)
	--print("cbbb "..tostring(cbbb)..tostring(ffi.cast("int",ffi.cast("void *",cbbb))))
	linda:send("func",tonumber(ffi.cast("int", cbbb)))
end
function laneprint(linda,printlinda)--,libpath,libsc)
	local ffi = require("ffi")
	--ffi.cdef[[typedef int (*PrinterFFI)(char* str,int n);void SetPrintFunc(PrinterFFI func);]]
	ffi.cdef[[typedef int (*PrintFunc)(const char *format, va_list ap);]]
	ffi.cdef[[int snprintf(char *buffer, size_t n, const char *fmt,...);
	int sprintf(char *buffer, const char *fmt,...);
	int printf(const char *fmt, ...);
	int vsprintf(char *target, const char *format, va_list arg_ptr);
	int vsnprintf(char *target, size_t n, const char *format, va_list arg_ptr);]]
	--ffi.cdef[[unsigned long GetCurrentThreadId(void);unsigned long __stdcall GetCurrentThread(void);]]
	--local lib = ffi.load(libpath);
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
	--cbbb = ffi.cast("PrinterFFI",PrintFunc)
	--lib.SetPrintFunc(cbbb)
	cbbb = ffi.cast("PrintFunc",PrintFunc)
	linda:send("func_print",tonumber(ffi.cast("int", cbbb)))
end

function SCFFI:init(options,linda)
	
	--local path = wx.wxFileName.SplitPath(options.SCpath)
	local path = splitpath(options.SCpath)
	if not self.libsc then
		print("load from",path..[[/liblibscsynth]])
		require"lfs"
		lfs.chdir(path)
		self.libsc = ffi.load(path..[[/liblibscsynth]])
	end
	print("self.libsc",self.libsc)
		local globals={print=thread_print,
				prerror=thread_error_print,
				prOSC=prOSC,
				idlelinda = idlelinda,
				scriptguilinda = scriptguilinda
				}
	------------------------------------
	---[[
	self.print_lane = lanegen(laneprint,globals,"laneprint")(true,linda)
	local key,print_func = linda:receive("func_print")
	self.print_func = ffi.cast("PrintFunc",print_func)
	self.libsc.SetPrintFunc(self.print_func)
	--]]
	--------------------------------------
	local plugpath = path..[[/plugins]]
	for i,v in ipairs(options.SC_PLUGIN_PATH) do
		if(v=="default") then
		else	
			plugpath = plugpath..[[;]]..v --..[["]]
		end
	end
	
	local mUGensPluginPath = plugpath
	local kDefaultWorldOptions = ffi.new("WorldOptions_t",nil,1024,64,1024,1024,64,128,8,8,4096,64,8192, 0,nil, 1, 0,nil,nil,nil,nil,nil,44100,64, 0, 1,nil, nil, nil,2,1,mUGensPluginPath,nil,nil,0)
	kDefaultWorldOptions.mInDeviceName =  options.SC_AUDIO_DEVICE
	kDefaultWorldOptions.mOutDeviceName =  options.SC_AUDIO_DEVICE
	self.theworld = self.libsc.World_New(kDefaultWorldOptions)
	print("self.theworld",self.theworld)

	self.resp_lane = lanegen(lanebody,globals,"oscresponder")(true,linda)
	--SCProcess = self.resp_lane
	local key,respfunc = linda:receive("func")
	self.respfunc = ffi.cast("ReplyFunc",respfunc)
	self:send(toOSC({"/notify",{1}}))

	--self.router_lane = lanegen(router_lane,"router_lane")(linda)
end
function SCFFI:close()
	--self.quit_lane = lanegen(lanebodyquit,{},"lanebodyquit")(true)
	print("World_WaitForQuit going",self.theworld)
	self.libsc.World_WaitForQuit(self.theworld)
	--self.libsc.World_Cleanup(self.theworld)
	print"World_WaitForQuit done"
	---[[
	if self.resp_lane then
		local cancelled,reason = self.resp_lane:cancel(1)
		if cancelled then
			self.resp_lane = nil
			--SCProcess = nil
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
	self.libsc.World_SendPacket(self.theworld, #msg, string2char(msg), self.respfunc)
end
end -- if jit

local SCUDP = require"scudp"

local SCSERVER = {}

function SCSERVER:init(types,options,linda)
	assert(not self.inited)
	if types == "udp" then
		self.type = types
		self.sc = SCUDP
		self.sc:init(options,linda)
		self.inited = true
	elseif types == "internal" then
		if not jit then prerror("must run luajit for internal server"); return end
		self.type = types
		self.sc = SCFFI
		self.sc:init(options,linda)
		self.inited = true
	else
		error("server type "..types.." not implemented")
	end
end

function SCSERVER:close()
	if self.sc then self.sc:close() end
	self.sc = nil
	self.inited = nil
end

function SCSERVER:send(msg)
	if self.sc then self.sc:send(msg) end
end
function SCSERVER:status()
	self:send(toOSC({"/status",{1}}))
end
function SCSERVER:sync(id)
	self:send(toOSC({"/sync",{id or 1}}))
end

function SCSERVER:dumpOSC(doit)
	local val= doit and 1 or 0
	self:send(toOSC({"/dumpOSC",{val}}))
end

function SCSERVER:dumpTree(withvalues)
	withvalues=withvalues or true
	local p= withvalues and 1 or 0
	self:send(toOSC({"/g_dumpTree",{0,p}}))
end

function SCSERVER:quit()
	--while idlelinda:receive(0,"statusSC") do end
	--lanes.timer(idlelinda,"statusSC",0)
	--idlelinda:receive(0,"statusSC")
	idlelinda:set("statusSC") --delete
	--if self.type == "udp" then
		self:send(toOSC({"/quit",{}}))
	--end
end

return SCSERVER