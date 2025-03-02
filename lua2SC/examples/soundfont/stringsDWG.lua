--This is to compare with soundfont version
-- more CPU
--ER = require"sc.ER"(0.85,2.5,1.8,{direct=true,N=2,Eq=0.8,bypass=true})
-- less CPU
ER = require"sc.ER"(0.85,2.5,1.8,{part=true,N=3,bypass=true})

-- synthdef for reverb
SynthDef("dwgreverb", { busin=0, busout=0,predelay=0.1,c1=1.2,c3=4,len=1200,mix = 1},function()
	local source=Mix(In.ar(busin,2)); 
	source = DelayC.ar(source,0.5,predelay)
	source = DWGReverbC1C3_16.ar(source,len,c1,c3,mix)	
	ReplaceOut.ar(busout,source)
end):store(true);

body_resons={{118, 18, -33},
{274, 22, -34.5},
{449, 10, -16},
{547, 16, -15.5},
{840, 50, -31},
{997, 30, -20.4},
{1100, 30, -34},
{1290, 25, -29},
{1500, 50, -28},
{1675, 60, -22},
{1900, 60, -20}}
sc = require"sclua.Server".Server()
gainLB = sc.Bus()
Slider("gainL",0,120,92,function(val) gainLB:set(val) end)
gainSB = sc.Bus()
Slider("gainS",0,2,1.8,function(val) gainSB:set(val) end)
gainHB = sc.Bus()
Slider("gainH",0,2,1,function(val) gainHB:set(val) end)

SynthDef("bowsoundboard", { busin=0, busout=0,mix=0.9,fLPF=6300,size=1,T1=1,gainS=0,gainL=60,gainH=2,Qw=1},function()
	local str=In.ar(busin,2); 
	
	local coefs = TA{199, 211, 223, 227, 229, 233, 239, 241 } *size
	local fdn = DWGSoundBoard.ar(str,nil,nil,mix,unpack(coefs:asSimpleTable()));
	local bodyf = 0
	T1 = T1:max(0.001)
	for i,v in ipairs(body_resons) do
		bodyf = bodyf + BPF.ar(str,v[1]*T1,Qw/(v[2]*T1))*db2amp(v[3])
	end
	gainL =  In.kr(gainLB.busIndex,1)
	gainS =  In.kr(gainSB.busIndex,1)
	gainH =  In.kr(gainHB.busIndex,1)
	local son = str*gainS + bodyf*gainL + fdn*gainH
	son = LPF.ar(son,fLPF)
	ReplaceOut.ar(busout,son)
end):store(true);
bowed = SynthDef("bowed", {out=0, freq=440, amp=0.5,force=1, gate=1,pos=0.14,c1=2,c3=40,mistune = 5200,release=0.1,Z = 1,Zfac=1,B=2,Ztor=3,c1tor=2,c3tor=6000,pan=0,vibdeph=7,vibrate=5,vibonset=0.5,t_gate=1,rID=1;
},function()
	RandID.ir(rID)
	N = 30 -- number of players
	local midiamp = 0.15
	local fratio = midi2ratio(midiamp)
	local freqs = TA():Fill(N,Rand(-midiamp,midiamp):midiratio())
	freq = freqs*freq

	local vibfreq = Vibrato.kr{freq, rate= vibrate, depth= vibdeph/1000, delay= 0, onset= vibonset, rateVariation= 0.5, depthVariation= 0.2, iphase =  TRand.kr(0,1,t_gate),trig=t_gate}
	local pos = TA():Fill(N,Rand(0.1,0.2))

	Z = Z*Zfac
	local son = DWGBowedTor.ar(vibfreq, amp,force, gate,pos,release,c1,c3,Z,B,1 + mistune/1000,c1tor,c3tor,Ztor)*0.5
	son = son:Doi(function(v,i) return DelayC.ar(v,0.4,NRand(0,1,4)*0.1) end)

	Out.ar(out, Pan2.ar(Mix(son*0.1) ,0))
end):store(true);
Sync()
-------------------------------------------------------------------

local scale = {modes.aeolian}
maxa = 2
--PlotEnv(Env({0.2,0.2,maxa,maxa},{0.01,0.4,0.7}),2,1.5)
local amp = LOOP{ENV({0,0,maxa,maxa},{0.2,2,0.7}),ENV({-0,-0,-maxa,-maxa},{0.2,2,0.7})}*1
local amp = LOOP{ENVr({0,0,maxa,maxa},{0.01,0.5,0.5}),ENVr({-0,-0,-maxa,-maxa},{0.01,0.5,0.5})}
force = SliderControl("for",0,4,2.5)
fT1 = SliderControl("fT1",0,4,1.1)
Qw = SliderControl("Qw",0,4,1)

v1 = OscEP{inst="bowed", mono=true, sends={0.5},channel={level=db2amp(-20)}}
v1:Bind(PS({
	dur = 2,
	escale = scale,
	degree = LOOP{1,2,3,4,5,6,7,8} + 7*6,
	amp = amp,
	force = force,
	t_gate = 1,
}
))
ff = 1
local fLPF = math.max(3000,linearmap(0,5,16000,2200,ff))
v1.inserts = {{"bowsoundboard",{T1=fT1/ff,Qw=Qw,size=ff,fLPF=fLPF,dur=2}}}
ER:setER(v1,-1,1)

v2 = OscEP{inst="bowed", mono=true,sends={0.5},channel={level=db2amp(-20)}}
v2:Bind(PS({
	dur = 2,
	escale = scale,
	degree = LOOP{1,0,-1,-2,4,3,2,1} + 7*6,
	amp = deepcopy(amp),
	force = force,
	t_gate = 1
}))
ff = 1
local fLPF = math.max(3000,linearmap(0,5,16000,2200,ff))
v2.inserts = {{"bowsoundboard",{T1=fT1/ff,Qw=Qw,size=ff,fLPF=fLPF,dur=2}}}
ER:setER(v2,-0.5,1)

vl = OscEP{inst="bowed", mono=true,sends={0.5},channel={level=db2amp(-20)}}
vl:Bind(PS({
	dur = 4,
	escale = scale,
	degree = LOOP{3,2,1,0,-1,-2,-3,-4} + 7*5,
	amp = deepcopy(amp),
	force = force,
	t_gate = 1
}))

ff = 2
local fLPF = math.max(3000,linearmap(0,5,16000,2200,ff))
vl.inserts = {{"bowsoundboard",{T1=fT1/ff,Qw=Qw,size=ff,fLPF=fLPF,dur=2}}}
ER:setER(vl,-0.02,1)


ce = OscEP{inst="bowed", mono=true,sends={0.5},channel={level=db2amp(-20)}}
ce:Bind(PS({
	dur = 4,
	escale = scale,
	degree = LOOP{1,1,1,1,1,1,1,1} + 7*4,
	amp = deepcopy(amp),
	force = force,
	t_gate = 1
}))

ff = 4
local fLPF = math.max(3000,linearmap(0,5,16000,2200,ff))
ce.inserts = {{"bowsoundboard",{T1=fT1/ff,Qw=Qw,size=ff,fLPF=fLPF,dur=2}}}
ER:setER(ce,0.5,1)

cb = OscEP{inst="bowed", mono=true,sends={0.5},channel={level=db2amp(-16)}}
cb:Bind(PS({
	dur = 4*2,
	escale = scale,
	degree = LOOP{1,0,-1,-2,-3,-4,-5,-6} + REP(8,LOOP{7*4,7*3}),
	amp = deepcopy(amp),
	force = force*1.5,
	t_gate = 1
}))

ff = 5
local fLPF = math.max(3000,linearmap(0,5,16000,2200,ff))
cb.inserts = {{"bowsoundboard",{T1=fT1/ff,Qw=Qw,size=ff,fLPF=fLPF,dur=2}}}
ER:setER(cb,1,1)

FScope()
MASTER{level=db2amp(-15)}
Effects ={FX("dwgreverb",db2amp(-6),0,{c1=1.2})}
theMetro:tempo(100)
theMetro:start()