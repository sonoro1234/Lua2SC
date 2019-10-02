--- first some synthdefs
local phISEM = require"sc.PhISEMSynth"
phISEM:MakeSynth("cascabeles","cascabeles")

SynthDef("btabla",{out=0,freq=100,noisef=0.2,t_gate=1,gate=1,ancho=100,fnoise=1200,amp=1,att=0.125,rel=0.125,tension=0.1,loss=1,ewidth=1/6,epos=0.25,a1=0.5,facF=1,size=1},function()

	local env = Env.asr(0,1,0.1):kr(2,gate)
	tension = 0.000125*facF*freq --*1.1 for Circle
	loss = (-loss/1000):dbamp()
	local noise = 1-noisef + LFDClipNoise.ar(fnoise)*noisef
	amp = Latch.ar(amp*100/ancho, t_gate)
	ancho = ancho / SampleRate.ir()
	att = ancho*att
	rel = ancho*rel
	ancho = (ancho-att-rel):max(0)
	local excitation = EnvGen.ar(Env.new({0,0,1,1,0},{0,att,ancho,rel},"lin"),t_gate)*noise
	local sig = MembraneCircleV.ar(excitation*amp, tension*1.12, loss,ewidth,epos,size,a1)*env;
	Out.ar(out,Pan2.ar(sig*db2amp(-30),0))
end):store(true)

SynthDef("tabla", {out = 0, freq = 265, pan = 0,amp=1,decay=0.2,dectimes=1,att=0.0,dec=0.04,t_trig=0},function()
	local env = Decay2.ar(T2A.ar(t_trig), att, dec);
	local noise = LFNoise2.ar(3000, env);
	local e2 = EnvGen.ar{Env.perc(0.000, decay, amp),t_trig, doneAction=0}*amp;

	local z = DynKlank.ar(
		Ref{{ 1, 2.01, 2.99, 4.03, 5.21, 6.04,7.05,7.95 }, TAU({-14,-12,-7,-10,-10,-20,-20,-20}):dbamp(), {0.5, 0.7, 0.8, 0.8,0.7,0.3,0.3,0.3}},
		noise*e2*0.08, freq, 0,dectimes);
	Out.ar(out, Pan2.ar(z, pan));
end):store(true)

SynthDef("dwgreverb", { busin=0, busout=0,predelay=0.1,c1=4,c3=4,len=1200,mix = 1},function()
	local source=Mix(In.ar(busin,2)); 
	source = DelayC.ar(source,0.5,predelay)
	source = DWGReverbC1C3_16.ar(source,len,c1,c3,mix)	
	ReplaceOut.ar(busout,source)
end):store(true);

SynthDef("dwgreverb3band",{busout=0,busin=0,predelay=0.1,xover = 400;rtlow = 3,rtmid = 2,fdamp = 6000,len=3500,doprime=0},function()
	local source=Mix(In.ar(busin,2));
	source = DelayC.ar(source,0.5,predelay)
	local sig = DWGReverb3Band_16.ar(source,len,xover,rtlow,rtmid,fdamp,nil,nil,doprime)
	ReplaceOut.ar(busout,sig)
end):store(true)

SynthDef("drone",{out=0,freq=200,amp=0.1,gate=1,freqsweep=0.1}, function()
	local e2 = EnvGen.kr{Env.asr(0.0005, amp, 1, -4),gate, doneAction=2};
	Out.ar(out,e2*RLPF.ar(LFPulse.ar({freq,freq*1.5}, 0.15),SinOsc.kr(freqsweep, 0, 
25, 82):midicps(), 0.1,amp));
end):store();

-- get sure all is received
Sync()
--------------------------- scale and ER
escale = newScale({0,1.82,3.86,5.9,7,9.96,10.88}) +2
escale = {escale}

local ER = require"sc.ER"(0.75,1,1,{direct=true,compensation=true,N=2})

--------------------- some players and patterns ---------------------------------------

---------- 2 backvoices pl and plb

local frase = "EUMv-_vO-OIUMv-_vO"
--TT = require"num.ParametricTract"(30,17.5)
TT = require"num.vocaltractB"(30,true,true)
pl = OscEP{inst=TT.sinteRdO2.name,mono=true,sends={db2amp(-8)},channel={level=db2amp(-24)}}

-- common to all backvoices patterns
fixedpars = {
	namp = 0.0,
	thlev = 0.5,
	fA = 1.2,
	fPreoral = 1.2,
	vibdepth = 0.001,
	allvocals = true,
	fade = true}

plpat = PS({
	escale = escale,
	dur = LOOP{7.75+8,0.25},
	degree = LOOP{1,1} + 7*4,
	Rd=0.7
},fixedpars,LOOP(PS(TT:Talk(frase,true,true))))

plpat1 = PS({
	escale = escale,
	dur = LS{12},
	degree = LS{1} + 7*4,
	Rd=0.7
},fixedpars,LOOP(PS(TT:Talk(frase,true,true))))


plpatini = PS({
	escale = escale,
	dur = LOOP{16},
	degree = LOOP{1,1} + 7*4,
	Rd=1.2,
},fixedpars,LOOP(PS(TT:Talk("OIUMv",true,true))))

-- second backvoice a fifth above
plb = copyplayer(pl)
plb.Filters.degree = function(v) return v.degree+4 end
ER:setER(pl,0.3,2)
ER:setER(plb,-0.3,2)

--------- woman
m1 = ENVdeg({-1,-1,0,0},{0.3,0.1,0.6})
m2 = ENVdeg({0,0,1,0},{0.5,0.25,0.25})
m1b = ENVdeg({0,0,-5},{0.9,0.1})
m4 = m1b
m0 = getdegree

local frase2 = "KO-RI-NI-LA_-ME-SU-NE-Mv-KO-RI-NI-LA-_v"
--TT2 = require"num.ParametricTract"(26,14.3)
TT2 = require"num.vocaltractB"(26,false,true)
ella = OscEP{inst=TT2.sinteRdO2.name,mono=true,sends={db2amp(-8)},channel={level=db2amp(-5)}}

ellapat = function(RD) return PS({
	dur = LOOP{LS{2}:rep(11),4+2,4},
	escale = escale,
	degree = LS{5,6,8,8,5,4,3,4,5,4,2,1,1,
				  5,6,8,8,8,6,5,4,5,4,6,5,1,
				LS{2,2,3,2,1,0,1,2,3,2,1,1,1}:rep(2)} + 7*5,
	freq = LOOP{LS{m1,m0}:rep(5),m1,LSS{m1b,m4},m0},
	Rd= LOOP{ENVr({0.5,0.5,0.7},{0,1}),0.5,0.5,ENVr({0.5,0.4},{1}),LS{0.4}:rep(7),ENVr({0.4,0.4,1.9},{0.9,0.1}),0.8}*RD,
	namp = 0.2,
	amp = 0.6,
	thlev = 0.5,
	fA = 0.95,
	fPreoral =  1,
	fAc = 1,
	vibdelay = beats2Time(1),
	vibdepth = LOOP{0,0.005,0.015,0.005,0.01,0.01,0.015,0.005,0.00,0.005,0.015,0.01,0},
},LOOP(PS(TT2:Talk(frase2,true,false))))
end

local fraseini2 = "AMv-EMv-_vA-AMv-EMv-_vA-AMv-E-IMv-_v"
mup = ENVdeg({-1,-1,0},{0,0.1})
mup1 = ENVdeg({-0.5,-0.5,0},{0,0.1})
rdout = ENVr({0.4,0.4,1.9},{0.9,0.1})
rdin = ENVr({0.9,0.9,0.7},{0,1})
ellapatini2 = PS({
	dur = LOOP{4,4+3.9,0.1,4,3.9,0.1,4,4,8+4,8},
	escale = escale,
	degree = LS{4,5,5,3,4,4,2,3,3,3} + 7*5,
	freq = LS{mup1,mup,m0,m0,mup,m0,m0,mup,m0,m0},
	Rd= LOOP{rdin,rdout,1.9,rdin,rdout,1.9,rdin,0.7,rdout,1.9}*2,
	namp = 0.3,
	thlev = 0.5,
	fA = 0.95,
	fPreoral =  1,
	fAc = 1,
	vibdelay = beats2Time(2),
	vibdepth = LOOP{0,0.005,0.015,0.005,0.01,0.01,0.015,0.005,0.00,0.005,0.015,0.01,0},
	allvocals = true,
	fade = true,
},LOOP(PS(TT2:Talk(fraseini2,true,true))))


local fraseini = "DAMv-ME-LA-DEIMv-_v"
mup = ENVdeg({-1,-1,-1,0},{0,0.2,0.1})
mdwn = ENVdeg({1,1,1,0,0,-3},{0,0.2,0.05,0.65,0.1})
mup2 = ENVdeg({-1.5,-1.5,-1.5,0},{0,0.2,0.1})
mup1 = ENVdeg({-1,-1,-1,0},{0,0.2,0.1})
mup3 = ENVdeg({-3,-3,-3,0},{0,0.2,0.1})
rdout = ENVr({0.4,0.4,1.9},{0.9,0.1})
rdin = ENVr({0.9,0.9,0.7},{0,1})
ellapatini = PS({
	dur = LOOP{4,4,4,12,2},
	escale = escale,
	degree = LS{1,0,5-7,1,1} + 7*5,
	freq = LS{mup3,mdwn,mup2,mup1,m0, m0,mup,m0,m0,mup,m0,m0},
	Rd= LOOP{rdin,0.7,0.7,rdout,1.9, rdin,rdout,1.9,rdin,0.7,rdout,1.9}*2,
	namp = 0.3,
	amp = 0.9,
	thlev = 0.25,
	fA = 0.95,
	fPreoral =  1,
	fAc = 1,
	vibdelay = beats2Time(2),
	vibdepth = LOOP{0,0.005,0.015,0.005,0.005,0.01,0.01,0.015,0.005,0.00,0.005,0.015,0.01,0},
	allvocals = true,
	fade = true,
},LOOP(PS(TT2:Talk(fraseini,true,true))))

ER:setER(ella,0.3,1.5)

--- drone
drone = OscEP{inst="drone",mono=true,sends={db2amp(-15)},channel={level=db2amp(-10),pan=0.1}}
dronepat = PS({
	escale = escale,
	dur = LOOP{8},
	degree = 1 + 7*3,
	freqsweep = LOOP{BeatFreq(8*4)},
	amp = 0.4
})

--- tabla hight
tabla=OscEP{inst="tabla",dontfree=true,mono=true,sends={0.2},channel={level=db2amp(-3)}}
tablapat=PS{
	escale = escale,
	degree=1+7*5,
	amp=1,
	t_trig = 1,
	dur=LOOP{1,0.5,1,0.5,0.5,0.25,0.25,   1,0.5,1,0.5,0.5,0.5},
	dectimes = LOOP{1.5,0.01,0.5,0.01,1,1,1, 1,0.01,0.75,0.01,0.2,1,
					1.5,0.01,0.5,0.01,0.75,0.01,0.01, 1,0.01,0.75,0.01,1,1}
}
tabla.inserts = {{"FourBandEq"}}
ER:setER(tabla,-0.2,2)

--- tabla low
up8 = ENVdeg({0,8},{1})
up4 = ENVdeg({0,4},{1})
btabla = OscEP{inst="btabla",mono=true,dontfree=false,channel={level=db2amp(-3)}}
btablapat = PS{
	dur = LOOP{1.5,0.5,1,1},
	escale = escale,
	degree = 1 +7*3,
	freq = LOOP{m0,m0,up8,m0,  m0,m0,up8,up4,  m0,m0,up8,up8, m0,m0,up8,m0},
	loss = LOOP{1,1,1,10, 1,1,1,1,  1,1,1,1, 1,1,1,10}*1.2,
	ewidth = 0.5,
	ancho = 160,
	att = 0,rel=0,
	size = 1,
	facF = 0.966,
	epos=0,
	amp = 1,
	t_gate = 1
}
ER:setER(btabla,0.2,1.3)

--- tambourine
tambourine = OscEP{inst="cascabeles",dontfree=true,sends={db2amp(-16)},channel={level=db2amp(-3)}}
tambourinepat = PS{
	dur = LOOP{1,2,1},
	note = LOOP{REST,30,30},
	amp = LOOP{1,1,0.5}*0.1
}
ER:setER(tambourine,0.1,3)

-------------tamboura
local path = require"sc.path"
path.require_here()

local TambouraGen = require"tamboura"
tamboura = TambouraGen(escale[1])
tamboura.sends = {db2amp(-13)}
tamboura.channel = {level=db2amp(-2)}

tambourapat=PS{
	dur = LOOP{2,1,1, 2,2}:rep(2)*2,
	escale = escale,
	degree = LOOP{5,8,8.01, 1,8}+7*3,
	voice = LOOP{1,2,3, 4,2},
	t_gate = 1,
	amp = LOOP{1,1,1, 1,0.5}
}
tambourapatend=PS{
	dur = LS{16},
	escale = escale,
	degree = 1+7*3,
	voice = 4,
	t_gate = 1,
	amp = 1
}
ER:setER(tamboura,0.1,2)

----------------------sitar

local SitarGen = require"sitar"
sitar = SitarGen.SitarPlayer(escale[1])
sitar.sends = {db2amp(-5)}
sitar.channel = {level=db2amp(-7)}
sitarpat = PS{
	dur = LOOP{REP(2,LS{LS{2}:rep(11),4+2+4})}*0.5,
	escale = escale,
	degree = LS{REP(2,LS{5,6,8,8,5,4,3,4,5,4,2,1,
				  5,6,8,8,8,6,5,4,5,4,6,5,
				LS{2,2,3,2,1,0,1,2,3,2,1,1}:rep(2)})} + 7*5,
	freq = LOOP{LS{m1,m0}:rep(5),m1,m1b,m0},
	t_gate = 1,
	amp = LOOP{1,0}*1,
	freqBase = midi2freq(getNote(1+7*3,escale[1])),
	jora = LOOP{0.5,0}*0.25,
	chikari = LOOP{0,0.75}
}

ER:setER(sitar,-0.4,2)

--sympathetic sitar strings
synpa = SitarGen.SympSitarPlayer(escale[1])
synpa.sends = {db2amp(-15)}
synpa.channel = {level=db2amp(-6)}
function synpapat(deltrig)
	deltrig = deltrig or 0.18
	return PS{
	dur = LS{8},
	amp = 0.5,
	deltrig = deltrig,
	jw = 150,
	t_trig = 1
}
end

ER:setER(synpa,-0.4,2)

------------------ theme structure ---------------

pl:Bind(LS{UNTILEv("frase",plpatini),plpat1,plpat})
plpatc = deepcopy(plpat)
plb:Bind(LS{WAITEv"synpa",plpatc})
ella:Bind(LS{DONOP(8),
	ellapatini2,ellapatini,SETEv"synpa",DONOP(12),SETEv"frase",ellapat(1.6),ellapat(1.3),SETCHANS({sitar},{level=db2amp(-5)}),DONOP(64*2),
	DONOP(1),
	DOACTION(function() 
		StopPlayer(theMetro.ppqPos,drone,tabla,btabla,tambourine)
	end),
	DONOP(4),ellapatini,
	DOACTION(function(self)
		local ppq = self.ppqPos
		fadeout(ppq,ppq+12,pl,plb)
	end),
})

drone:Bind(LS{WAITEv"frase",DONOP(64*2),dronepat})
tabla:Bind(LS{WAITEv"frase",DONOP(64*2),tablapat})
tambourine:Bind(LS{WAITEv"frase",DONOP(64*2),tambourinepat})
btabla:Bind(LS{WAITEv"frase",DONOP(64*2-8),btablapat})
sitar:Bind(LS{WAITEv"frase",DONOP(64*2),sitarpat,sitarpat})
tamboura:Bind(LS{WAITEv"frase",DONOP(64+32),tambourapat,LS{tambourapat}:rep(8),tambourapatend})
synpa:Bind(LS{synpapat(0.18),WAITEv"synpa",synpapat(0.22),WAITEv"frase",DONOP(4),DONOP(64*2-8),synpapat(),DONOP(64*2-8),synpapat(),DONOP(64*2-8),synpapat()})

----------------------------------------------------
MASTER{level=db2amp(-8)}
Effects={FX("dwgreverb",db2amp(0),nil,{c1=1.5,c3=16,len=5000,predelay=0.1})}
--DiskOutBuffer("morning_in_india.wav")
theMetro:tempo(105)
theMetro:start()