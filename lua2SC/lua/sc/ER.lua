
function ERmaker(B,Dist,Size,op)
op = op or {}
B = B or 0.85
Dist = Dist or 2.5
Size = Size or 1
local sc = require"sclua.Server".Server()
local busB = sc.Bus()
curr_panel = addPanel{type="hbox"}
Slider("B",0,1,B,function(val) busB:set(val) end)
local busDist = sc.Bus()
Slider("Dist",0,8,Dist,function(val) busDist:set(val) end)
local busSize = sc.Bus()
Slider("Size",0,8,Size,function(val) busSize:set(val) end)
--[[
local busBypass = sc.Bus()
Toggle("Bypas",function(val) print(val);busBypass:set(val) end)
--]]
local busEq
if op.direct then
	busEq = sc.Bus()
	Slider("Eq",0,1,op.Eq or 0,function(val) busEq:set(val) end)
end
local dec
if op.atk then
	require"sc.atk"
	dec = FoaDecoderKernel.newCIPIC()
end
local Nbuf = op.Nbuf or 2048*8
local synname = op.direct and "earlypandir" or "earlypan"
synname = synname .. (op.name or "")
SynthDef(synname,{busout=0,cbusB=busB.busIndex,bypass=0,dist=1.5,angle=0},function()
	print("busB.busIndex",busB.busIndex)
	--local L=TA(op.L or {20,10,16})*In.kr(busSize.busIndex,1)
	--local Ps = Ref(op.Pr or {9,3,1.2})
	local L=TA(op.L or {10,20,16})*In.kr(busSize.busIndex,1)
	local Ps = Ref(op.Pr or {4.5,5,1.2})
	local Pr = Ps --Ref{3,3,1.2}
	local B = In.kr(cbusB,1) --0.92 --0.72
	dist = In.kr(busDist.busIndex,1)*dist
	local HW=0.2
	local N = op.N or 5
	local input = In.ar(busout,2)
	local monoin = Mix(input)*0.5
	local omangle = angle*math.pi*0.5
	local Psmod = {Ps[1] + omangle:sin()*dist,Ps[2] + omangle:cos()*dist,Ps[3]}

	local early
if not op.direct then
	if op.atk then
		local bw = LocalBuf(Nbuf)
		local bx = LocalBuf(Nbuf)
		local by = LocalBuf(Nbuf)
		local bz = LocalBuf(Nbuf)
		local trig = EarlyRefAtkGen.kr(bw,bx,by,bz,Psmod,Pr,L,HW,-B,N)
		local sigw,sigx,sigy,sigz
		if op.part then
			sigw = PartConvT.ar(monoin,1024,bw,trig)
			sigx = PartConvT.ar(monoin,1024,bx,trig)
			sigy = PartConvT.ar(monoin,1024,by,trig)
			sigz = PartConvT.ar(monoin,1024,bz,trig)
		else
			sigw = Convolution2L.ar(monoin,bw,trig,Nbuf)
			sigx = Convolution2L.ar(monoin,bx,trig,Nbuf)
			sigy = Convolution2L.ar(monoin,by,trig,Nbuf)
			sigz = Convolution2L.ar(monoin,bz,trig,Nbuf)
		end
		local ambis = {sigw,sigx,sigy,sigz}
		early = AtkKernelPartConvT.ar(ambis,dec.kernel)*db2amp(4)
	else
		local bL = LocalBuf(Nbuf)
		local bR = LocalBuf(Nbuf)
		local trig = EarlyRefGen.kr(bL,bR,Psmod,Pr,L,HW,-B,N)
		local sigL,sigR
		if op.part then
			sigL = PartConvT.ar(monoin,1024,bL,trig)
			sigR = PartConvT.ar(monoin,1024,bR,trig)
		else
			sigL = Convolution2L.ar(monoin,bL,trig,Nbuf)
			sigR = Convolution2L.ar(monoin,bR,trig,Nbuf)
		end
		early = {sigL,sigR} --*dist
	end
else	
	early = EarlyRef.ar(monoin,Psmod,Pr,L,HW,-B,N,In.kr(busEq.busIndex,1),nil,op.allpass)
end
	if op.compensation then early = early*dist end

	local sig = Select.ar(bypass,{early,input})
	--local sig = Select.ar(In.kr(busBypass.busIndex),{early,Pan2.ar(monoin,angle)})
	--local sig = early
	ReplaceOut.ar(busout,sig);
end):store()
	local M = {}
	M.synname = synname
	function M:setER(pl,val,dist)
		pl.inserts = pl.inserts or {}
		table.insert(pl.inserts,{synname,{angle = val,dist=dist}})
	end
	return M
end


return ERmaker