
function ERmaker(B,Dist,Size)
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
local busBypass = sc.Bus()
Toggle("Bypas",function(val) print(val);busBypass:set(val) end)
local Nbuf = 2048*8
SynthDef("earlypan",{busout=0,cbusB=busB.busIndex,bypass=0,dist=1.5,angle=0},function()
	print("busB.busIndex",busB.busIndex)
	local L=TA{20,10,16}*In.kr(busSize.busIndex,1)
	local Ps = Ref{9,1,1.2} --{9,5,1.2}
	local Pr = Ps --Ref{3,3,1.2}
	local B = In.kr(cbusB,1) --0.92 --0.72
	dist = In.kr(busDist.busIndex,1)*dist
	local HW=0.2
	local N = 5
	local input = In.ar(busout,2)
	local monoin = Mix(input)*0.5
	local omangle = angle*math.pi*0.5
	local Psmod = {Ps[1] + omangle:sin()*dist,Ps[2] + omangle:cos()*dist,Ps[3]}

	local bL = LocalBuf(Nbuf)
	local bR = LocalBuf(Nbuf)

	local trig = EarlyRefGen.kr(bL,bR,Psmod,Pr,L,HW,-B,N)
 	local sigL = PartConvT.ar(monoin,1024,bL,trig)
 	local sigR = PartConvT.ar(monoin,1024,bR,trig)
--	local sigL = Convolution2L.ar(monoin,bL,trig,Nbuf)
--	local sigR = Convolution2L.ar(monoin,bR,trig,Nbuf)
	local early = {sigL,sigR} --*dist
--	local early = StereoConvolution2L.ar(monoin, bL, bR, trig, Nbuf)
	

	local sig = Select.ar(bypass,{early,input})
	--local sig = Select.ar(In.kr(busBypass.busIndex),{early,Pan2.ar(monoin,angle)})
	--local sig = early
	ReplaceOut.ar(busout,sig);
end):store()
	local M = {}
	function M:setER(pl,val,dist)
		pl.inserts = pl.inserts or {}
		table.insert(pl.inserts,{"earlypan",{angle = val,dist=dist}})
	end
	return M
end


return ERmaker