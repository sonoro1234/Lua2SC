----------------------------------------
-- OscPianoEP example
----------------------------------------

SynthDef("help_oteypiano", { out=0, freq=440, amp=0.5, t_gate=0,gate=1, release=0.1, rmin = 0.35,rmax =  2,rampl =  4,rampr = 8, rcore=1, lmin =  0.07,lmax =  1.4;lampl =  -4;lampr =  4, rho=1, e=1, zb=2, zh=0, mh=1.6, k=0.1, alpha=1, p=1.2, pos=0.142, loss = 1,detunes = 6,pan=0},function()
	local env = EnvGen.kr{Env.adsr(0,0,1,0.1),gate,doneAction=2}
	local son = OteyPianoStrings.ar(freq, amp,t_gate, rmin,rmax,rampl,rampr, rcore, lmin,lmax,lampl,lampr, rho, e, zb, zh, mh, k, alpha, p, pos, loss,detunes*0.0001,2)*env
	Out.ar(out, Pan2.ar(son *0.5,LinLin.kr(freq,midi2freq(21),midi2freq(80),-0.75,0.75)));
end):store();

SynthDef("soundboard", { busin=0, busout=0},function()
	local input=In.ar(busin,2); 
	local son = OteySoundBoard.ar(input,20,20,0.9)
	ReplaceOut.ar(busout,son)
end):store();

SynthDef("dwgreverb", { busin=0, busout=0,predelay=0.1,c1=4,c3=4,len=1200,mix = 1},function()
	local source=Mix(In.ar(busin,2)); 
	source = DelayC.ar(source,0.5,predelay)
	source = DWGReverbC1C3_16.ar(source,len,c1,c3,mix)	
	ReplaceOut.ar(busout,source)
end):store();

-- cheap early reflections simulation
SynthDef("early",{busout=0,fac=5,mix=1,lat=0,ff=6000,bypass=0},function()
	local sin = In.ar(busout,2)
	local sm = Mix(sin)*0.5 
	local z = {2,3,5,7,11,13,17}*fac*(1-lat)
	z = z:Do(function(v) return DelayC.ar(sm, 0.2,v/1000)*z[1]/v end) 
	z = Mix(z)
	local z2 = {2,3,5,7,11,13,17}*fac*(1+lat)
	z2 = z2:Do(function(v) return DelayC.ar(sm, 0.2,v/1000)*z2[1]/v end) 
	z2 = Mix(z2)
	local effect = LPF.ar({z,z2},ff)*mix + sin
	ReplaceOut.ar(busout,Select.ar(bypass,{effect,sin}) )
end):store()

Sync()

Effects={FX("dwgreverb",db2amp(-3),nil,{c1=2.5,c3=10,predelay=0.1})}

local scale = modes.dorian + 1 -- C# dorian mode

local melody = LOOP{
PS{
	dur = 1/3,
	escale = scale,
	degree = LS{5-7, 2, 5, 5, 2, 5-7, 3, 7+1, 7+5, 7+5, 7+1, 3} + 7*5,
	amp = LOOP{1,0.8,0.7, 0.9,0.7,0.6}*1,
	t_gate = 1,
},PS{
	dur = LS{8,2,5+1/3,1/3,1/3,2,6},
	escale = scale,
	degree = LS{REST,8,6,8,8,8,6} + 7*4,
	amp = noisefStream{0.2,0.4},
	t_gate = 1,
}}

local ostinato = LOOP{PS{
	dur = 4,
	note = LS{REST},
	t_gate = 1,
	pianopedal = true
},
PS{
	dur = LS{1/3}:rep(3*24),
	escale = scale,
	amp = noisefStream{0.05,0.1},
	degree = LOOP{5,8,10} + 7*4,
	t_gate = 1,
	pianopedal = true
}}

sinte = OscPianoEP{inst="help_oteypiano",sends={db2amp(-9)},channel={level=db2amp(-7)}}
sinte:Bind(ParS{ostinato, melody})
sinte.inserts = {{"soundboard"},{"early",{mix=0.6,lat=0.1,ff=15000,fac=8.87}}} 

theMetro:tempo(140)
theMetro:start()
