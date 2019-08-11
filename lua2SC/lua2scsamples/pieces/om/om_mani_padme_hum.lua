-- This piece is a prolation canon based on mantra Om_mani_padme_hum
-- https://en.wikipedia.org/wiki/Om_mani_padme_hum
-- https://en.wikipedia.org/wiki/Prolation_canon

-------------------synthdefs ----------------
-- two throats for male and female
Tract = require"num.tract"(22)
Tract18 = require"num.tract"(18) 

-- using pcall in case you dont have atk kernels
ok,ret = pcall(require,"sc.atk")
if not ok then prerror"cant use atk" end

SynthDef("atkpan",{busout=0,busin=0,bypass=0,azim=0,elev=0},function() 
	local input = In.ar(busin,2)
	local monoin = Mix(input)
	local effect 
	if AtkKernelConv then -- if atk present
		local dec = FoaDecoderKernel.newListen()
		effect = FoaPanB.ar(monoin,-azim*math.pi,elev*math.pi)
		effect = AtkKernelConv.ar(effect,dec.kernel)
	else  -- if not atk
		effect = Pan2.ar(monoin,azim*2)
	end
	ReplaceOut.ar(busout,Select.ar(bypass,{effect,input}))
end):store()

SynthDef("dwgreverb", { busin=0, busout=0,c1=1,c3=1,len=12000,mix = 1},function()
	local source=Mix(In.ar(busin,2)); 
	source = DWGReverb.ar(source,len,c1,c3,mix)
	source = AllpassC.ar(source, 0.050, {Rand(0, 0.05), Rand(0, 0.05)}, 1)
	ReplaceOut.ar(busout,source)
end):store();

-- korean bell
KLF = TA{517,525,1441,2636,2651,4090,4103,2062,2065,2314,3130,3124,4534,4456,3954,4011,2582,3559,4110,4192,5189,4949,5698,5713,6421,6567}/517
KLF = KLF:sort()
KLA = TA():Fill(#KLF,1/#KLF)
KLR = TA():gseries(#KLF,25,0.95)

SynthDef("korean_bell", {out = 0,fattack=6000,attack=0.0,decay=50, freq =144, pan = 0,amp=1.0,klf = Ref(KLF),kla=Ref(KLA),klr=Ref(KLR),t_gate=1}, function()
	local e2=1
	local signal = Decay.ar(T2A.ar(t_gate), 0.01, WhiteNoise.ar(1))
	local coef = (0.1/(math.exp(1)-1))*(amp:exp() - 1)
	coef = coef:min(0.1)
	signal = FOS.ar(signal,0.01 + coef,0,0.999 - coef)
	signal = Klank.ar(Ref{klf, kla, klr}, signal*e2, freq,0)--,freq:linlin(100,5000,1.5,0.03))
	Out.ar(out, Pan2.ar(Mix(signal), pan));
end):store()


------------------------------- music ----------------------------------
-- korean bell playing until event grfinish
korean=OscEP{inst="korean_bell",mono=true,dontfree=true,sends={db2amp(0)},channel={inst="channel",level=db2amp(-8)}}
korean:Bind(UNTILEv("grfinish",PS{
	t_gate = 1,
	degree = LS{REST,LOOP{1}}+7*6,
	amp = 0.8,
	pan = 0,
	dur = LS{12,RSinf{16,8,0.25}},
}))
korean.inserts = {{"atkpan",{azim=SINE(0.05,0,0.15)}}}

------------------------------ Mantra singers
scala = {0,2,3,5,7,8.5,10}

om_melody = {
	fA = 1.15,
	fAc = 1,
	fexci = 5500,
	fout = 5000,
	Rd = 0.4,
	namp = 0.02,
	nwidth = 0.5,
	alpha = 3.2,
	vibrate = 5,
	thlev = 0.00,
	escale = {scala},
	pan = 0 ,
	freq = LOOP{ENVdeg({-5,0},{0.25}),ENVdeg({-1,0},{0.5}),LS{getdegree}:rep(3),ENVdeg({0,0,-5},{0.9,0.1}),getdegree},
	degree = LS{1,1,1,1,1,1,REST} + 7*4,
	dur = LS{4,1,1,1,1,6,2}
}

frase = "OM-MA-NI-PAD-ME-HUMv- "

-- player not playing (not OscEP in OSCPlayers) to be copied by players
player = OscEventPlayer:new{inst=Tract.sinteRd.name,mono=true,dontfree=false,sends={db2amp(0)},channel={level=0.2,pan=0}}

-- first mantra player singing until grfinish
om1 = copyplayer(player)
om_melodysolo = deepcopy(om_melody)
om1.sends = {db2amp(-3)}
om1.channel.level = 0.15
om1talk = {[Tract.paramskey_speak] = LOOP{LS{Tract:doTalk(frase,true,true,false)}:rep(3),Tract:doTalk(frase,true,true,true)}}
om1seq = UNTILEv("grfinish",LOOP{PS(om_melodysolo,om1talk),MARK()})
om1:Bind(om1seq)
om1.inserts = {{"atkpan",{azim=SINE(0.05,math.pi,0.15)}}}

-- several mantra singers answering om1
om1coral = copyplayer(player)
om1coral.inst = Tract.coral.name
om1coral.sends = {db2amp(3)}
om1coral.channel.level = om1.channel.level * db2amp(-3) 
om_melodycoral = deepcopy(om_melody)
om_melodycoral.pan = 0
om_melodycoral.fout = 3500
om_melodycoral.Rd = 0.8
coraltalk = {[Tract.paramskey_speak] = LOOP{Tract:doTalk(frase,true,true,false)}}
om1seqcoral = UNTILEv("grfinish",LOOP{PS(om_melodycoral,coraltalk),MARK()},true)
om1coral:Bind(LS{DOREST(32-8),om1seqcoral})

---- 0m2 and om3 singers slowly changing vocal
frasevoc = "OMv-A-I-A-O-UMv- "
speakseqvoc = {[Tract.paramskey_speak] = LOOP{Tract:doTalk(frasevoc,true,true,true)}}

-- om2 a fifth above om1 and four times slower
om2 = copyplayer(player)
o2m = deepcopy_values(om_melody)
o2m.dur = o2m.dur *4
o2m.pan = 0 
o2m.degree = o2m.degree + 4
om2:Bind(LS{DONOP(16*3),LS{PS(o2m,speakseqvoc),COUNT"turn1"}:rep(8)})
om2.channel.level = db2amp(-18)
om2.inserts = {{"atkpan",{azim=-0.25}}}

-- om3 an octave lower and eigth times slower
om3 = copyplayer(player)
o3m = deepcopy_values(om_melody)
o3m.dur = o3m.dur *8
o3m.pan = 0 --SINE(0.01,0,0.25)
o3m.degree = o3m.degree -7
om3:Bind(LS{DONOP(16*7),LS{PS(o3m,deepcopy(speakseqvoc))}:rep(3),SKIP(2,7,PS(o3m,deepcopy(speakseqvoc))),SETEv"grfinish"})
om3.channel.level = db2amp(-18)
om3.inserts = {{"atkpan",{azim=0.25}}}

-- om4 one octave higher and four times quicker
speakseq4 = {[Tract.paramskey_speak] = LOOP{Tract:doTalk(frase,true,true,true)}}
om4 = copyplayer(player)
om4.channel.level = db2amp(-18)
om4.sends = {db2amp(3)}
o4m = deepcopy_values(om_melody)
o4m.dur = o4m.dur *0.25
o4m.pan = 0 --SINE(0.1,0)
o4m.degree = o4m.degree +7
om4:Bind(LS{DONOP(16*8),UNTILEv("girlbegin",LOOP{LS{PS(o4m,speakseq4)}:rep(RSinf{5,4,3}),DONOP(3)}),DOREST(1)})
om4.inserts = {{"atkpan",{azim=SINE(0.05,0,1)}}}

---------------------female singers -------------
-- degree envelopes
m51 = ENVdeg({-5,0},{0.5},true)
m1 = ENVdeg({-1,0},{0.5})
m1b = ENVdeg({2,0},{0.5})
m3 = ENVdeg({2,0},{0.5},true)
m0 = getdegree
gfrase = "OM-MA-NI-E-SO-LI-MA-HA-KU-NI-O-DE-LAM"

-- first phrase part
gs1 = deepcopy_values(om_melodysolo)
gs1.freq = LOOP{m51,m1,m1b,m0,m1b,m1,m3,m0,m1b,m0,m1,m0,m51}
gs1.fA = 0.95
gs1.fAc = 1
gs1.Rd = LOOP{LS{0.5}:rep(12),ENVr({0.5,0.5,0.3,0.5,1.2},{0,0.25,0.5,0.25},"exp")}
gs1.fexci = 5000
gs1.fout = 6000
gs1.namp = 0
gs1.degree = LOOP{5,7,7,7,6,7,5,5,3,3,3,4,5} +7*5
gs1.dur = LS{LS{1}:rep(12),4}
gs1.pan = 0

-- answering phrase part
gs2 = deepcopy_values(gs1)
gs2.freq = LOOP{m51,m1,m1b,m0,m1b,m1,m3,m0,m1b,m0,m1,m51,m0}
gs2.degree = LS{4,4,4,5,3,2,1,-1,-1,-1,0,1,REST}+7*5
gs2.dur = LS{LS{1}:rep(6),2,LS{1}:rep(4),6,6}
gs2.Rd = LOOP{LS{0.5}:rep(7),LS{0.7}:rep(4),ENVr({0.7,0.7,0.5,1.2},{0,0.25,0.75},"exp")}

-- whole female phrase
girlseq = PS(LS{PS(gs1),PS(gs1),PS(gs2)},{[Tract18.paramskey_speak] = LOOP{Tract18:doTalk(gfrase,true)}})

-- first female singer
girl = OscEP{inst=Tract18.sinteRd.name,mono=true,dontfree=false,sends={1},channel={level=db2amp(-16)}}:Bind(LS{DONOP(16*12),SETEv"girlbegin",LS{girlseq}:rep(3),DOREST(16*4),LS{girlseq}:rep(2)})
girl.inserts = {{"atkpan",{azim=-0.15}}} 

-- second female stuff
-- plays two times slower and a fourth below
gs1b = deepcopy_values(gs1)
gs1b.dur = gs1b.dur * 2
gs1b.degree = gs1b.degree -7 +4
gs1b.pan = 0
gs2b = deepcopy_values(gs2)
gs2b.dur = gs2b.dur * 2
gs2b.degree = gs2b.degree -7 +4
gs2b.pan = 0

girlseqb = PS(LS{PS(gs1b),PS(gs1b),PS(gs2b)},{[Tract18.paramskey_speak] = LOOP{Tract18:doTalk(gfrase,true)}})

-- the second female player
girl2 = copyplayer(girl)
girl2.channel.level = db2amp(-18)
girl2:Bind(LS{DONOP(16*12 + 16*2 +24),LS{girlseqb}:rep(1),DOREST(16*4),girlseqb})
girl2.inserts = {{"atkpan",{azim=0.15}}}

---------------------- Master --------------------------------------------
Effects={FX("dwgreverb",db2amp(1),nil,{c1=4,len=6000})}
MASTER{level=db2amp(-2)}
--DiskOutBuffer"Om.wav"
theMetro:tempo(100)
theMetro:start()