
local function GetUserLocalDataDir()
	tmplinda = lanes.linda()
	idlelinda:send("wxeval",{function()
		local wxsp = wx.wxStandardPaths.Get()
		local wxver = string.match(wx.wxVERSION_STRING, "[%d%.]+")
		if wxver > "2.9.0" then
		wxsp:UseAppInfo(0)--wx.AppInfo_None)
		end
		return wxsp:GetUserLocalDataDir()  end,tmplinda})
	local key,val=tmplinda:receive(1,"wxevalResp")
	if not key then error("timeout") end
	return val[2]
end
local function GetConfigDir()
	tmplinda = lanes.linda()
	idlelinda:send("wxeval",{function() 
		local wxsp = wx.wxStandardPaths.Get()
		local wxver = string.match(wx.wxVERSION_STRING, "[%d%.]+")
		if wxver > "2.9.0" then
		wxsp:UseAppInfo(0)--wx.AppInfo_None)
		end
		return wxsp:GetConfigDir()  end,tmplinda})
	local key,val=tmplinda:receive(1,"wxevalResp")
	if not val[1] then error(val[2]) end
	return val[2]
end

local Platform = {}
Platform.userAppSupportDir = GetUserLocalDataDir()
Platform.systemAppSupportDir = GetConfigDir()
local lfs = require"lfs"
local Atk = {}
Atk.userSupportDir = Platform.userAppSupportDir .. "/ATK";
Atk.userSoundsDir = Atk.userSupportDir .. "/sounds";
Atk.userKernelDir = Atk.userSupportDir .. "/kernels";
Atk.systemSupportDir = Platform.systemAppSupportDir .. "/ATK";		
Atk.systemSoundsDir = Atk.systemSupportDir .. "/sounds";
Atk.systemKernelDir = Atk.systemSupportDir .. "/kernels";
Atk.portabSupportDir = lua2scpath .. "../ATK";
Atk.portabSoundsDir = Atk.portabSupportDir .. "/sounds";
Atk.portabKernelDir = Atk.portabSupportDir .. "/kernels";
FoaDecoderKernel = {}
function FoaDecoderKernel:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end
function FoaDecoderKernel:initPath()
	local kernelLibPath;
	--find user
--[[
	local file,err = io.open(Atk.userKernelDir)
	if not file then 
		print(err)
	else
		print"found"
		file:close()
	end
--]]
	if lfs.attributes(Atk.portabKernelDir) and lfs.attributes(Atk.portabKernelDir).mode == "directory" then
		kernelLibPath = Atk.portabKernelDir
	elseif lfs.attributes(Atk.userKernelDir) and lfs.attributes(Atk.userKernelDir).mode == "directory" then
		kernelLibPath = Atk.userKernelDir
	elseif lfs.attributes(Atk.systemKernelDir) and lfs.attributes(Atk.systemKernelDir).mode == "directory" then
		kernelLibPath = Atk.systemKernelDir
	else
		prtable(Platform)
		error("is Atk instaled in above directories?")
	end
	return kernelLibPath .. "/FOA/decoders/" .. self.kind
end

function FoaDecoderKernel:initKernel()
	self.chans = 2
	if self.kind == "uhj" then
		self.dirChannels ={ math.pi/6, -math.pi/6 };
		self.sampleRate = "None";
	else
		self.dirChannels ={ 5/9 *math.pi, -math.pi*5/9 };
		self.sampleRate = 44100;
	end
	local databasePath = self:initPath()
	self.subjectPath = databasePath .. "/" .. self.sampleRate .. "/" .. self.kernelSize .. "/" .. string.format("%04d",self.subjectID)

	self.kernel = {}
	if not lfs.attributes(self.subjectPath) then
		error("cant load from ".. self.subjectPath)
	else
		print(self.subjectPath)
		for file in lfs.dir(self.subjectPath) do
			if file ~= "." and file ~= ".." then
				self.kernel[#self.kernel + 1] = {}
				table.insert(self.kernel[#self.kernel],FileBuffer(self.subjectPath .. "/" .. file,0))
				table.insert(self.kernel[#self.kernel],FileBuffer(self.subjectPath .. "/" .. file,1))
			end
		end
	end
	return self
end

function FoaDecoderKernel.newUHJ(t)
	t = t or {}
	local o = FoaDecoderKernel:new{kind="uhj",kernelSize = t.kernelSize or 512,subjectID=0}
	return o:initKernel()
end
function FoaDecoderKernel.newListen(t)
	t = t or {}
	local o = FoaDecoderKernel:new{kind="listen",kernelSize = t.kernelSize or 512,subjectID=1002}
	return o:initKernel()
end
function FoaDecoderKernel.newCIPIC(t)
	t = t or {}
	local o = FoaDecoderKernel:new{kind="cipic",kernelSize = t.kernelSize or 512,subjectID=21}
	return o:initKernel()
end


AtkKernelConv = {}

function AtkKernelConv.ar(inp,kernel,mul,add)
	if not isSimpleTable(inp) then
	end
	local convs = {}
	for i=1,#kernel do
		convs[#convs + 1] = {}
		for j=1,#kernel[1] do
			table.insert(convs[#convs],Convolution2.ar(inp[i],kernel[i][j].buffnum,0,kernel[i][j].frames))
		end
	end
	return Mix(convs):madd(mul or 1,add or 0)
end 

AtkKernelPartConvT = {}

function AtkKernelPartConvT.ar(inp,kernel,mul,add)
	if not isSimpleTable(inp) then
	end
	local convs = {}
	for i=1,#kernel do
		convs[#convs + 1] = {}
		for j=1,#kernel[1] do
			table.insert(convs[#convs],PartConvT.ar(inp[i],1024,kernel[i][j].buffnum,1))
		end
	end
	return Mix(convs):madd(mul or 1,add or 0)
end 

FoaPanB=MultiOutUGen:new{name='FoaPanB'}
function FoaPanB.ar(...)
	local   inp, azimuth, elevation, mul, add   = assign({ 'inp', 'azimuth', 'elevation', 'mul', 'add' },{ nil, 0, 0, 1, 0 },...)
	return FoaPanB:MultiNew{2,4,inp,azimuth,elevation}:madd(mul,add)
end

--[[
dec = FoaDecoderKernel.newCIPIC()
--dec = FoaDecoderKernel.newUHJ()
--prtable(dec)

SynthDef("test",{},function() 
	local sig =  EnvGen.ar(Env.adsr(), Impulse.ar(3)) * PinkNoise.ar(0.8)*10;
	sig = FoaPanB.ar(sig,MouseX.kr(math.pi,-math.pi),MouseY.kr(math.pi,-math.pi))
	prtable(sig)
	sig = AtkKernelConv.ar(sig,dec.kernel)
	Out.ar(0,sig)
end):play()
--]]