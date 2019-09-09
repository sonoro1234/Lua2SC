-------------------------first the SynthDefs------------------------------
-- we will getting requiring a lua file with synthdefs in this script folder
-- and call sync for waiting to async complete
path = require"sc.path"
path.require_here()
require"synthdefs"

Tract = require"num.tract"(18)
Tract20 = require"num.tract"(20)
Tract22 = require"num.tract"(22)

ER = require"sc.ER"(0.75,1,1,{N=5,L={12,16,4},Pr = {5,3,1.2},Nbuf = 2048*2,bypass=true, compensation=true,anglefac=2, part=false})

Sync()


-------------------------------------- score ---------------------------
-- zurdo
zurdoseq={
	note = LOOP{1,1,NOP,1},
	dur = LOOP{12,9,2,1}/3, 
	amp = LOOP{1,0.2,1,1},
	wsamp = LOOP{0.3,0.3,1,1}*100,
	tension = ERAMP(1,0.97,1)*0.008,--LOOP{1,ERAMP(1,1.1,0.5),4,4,RS{1,4},4,4,4,4,4}*0.01,
	loss = 0.9,
	t_gate = 1
}
zurdo = OscEP{inst="testMembrane",mono=true,dontfree=true,sends={0.5},channel={level=db2amp(-20)}}
zurdo:Bind(LS{WAITEv"zurdo",SKIPdur(7,PS(zurdoseq)),PS(zurdoseq)})
ER:set(zurdo,{angle=-0.1,bypass=0,dist=0.5})

--- singer
escala = TA{0,2,3.5,5,7,8.75,10} - 3

m51 = ENVdeg({-5,0},{0.5},true)
m51i = ENVdeg({-7*2,-7*2,-5,0},{0.75,0,0.25})
m1u = ENVdeg({-1,0},{0.5},true)
m1 = ENVdeg({-1,0,0,-5},{0.5,0.25,0.25})
m1b = ENVdeg({2,0},{0.5})
m3 = ENVdeg({2,0},{0.5},true)
m3b = ENVdeg({0,1},{0.5},true)
m0 = getdegree

rd= 2 --2.5
rdmin = 2.7 --3.5
melody = {
	dur = 2/3,
	vibdeph = 0.01,
	Rd = LOOP{RAMP(0.8,rd),LS{rd}:rep(2),RAMP(rd,rdmin),LS{rdmin}:rep(2),RAMP(rdmin,rd),LS{rd}:rep(4),RAMP(rd,rdmin)},
	fA = 0.9,
	escale = {escala},
	degree = LS{1,1,1, 1,1,3, 4,4,4, 4,3,1} + 7*5,
	fexci = 16000,
	fout = 16000,
	namp = LS{0.1,LS{0.1}:rep(10),0.1}*0.2,
	nwidth = 0.4,
	thlev = 0.0,
	freq = LOOP{m51,m0,m0 , m0,m1b,m0, m3,m0,m0, m0,m0,m1}
}
meloini = deepcopy(melody)
meloini.freq = LOOP{m51i,m0,m0 , m0,m1b,m0, m3,m0,m0, m0,m0,m1}
melody_press = {
	dur = 2/3,
	Rd = LOOP{RAMP(0.8,rd),LS{rd}:rep(2),RAMP(rd,rdmin),LS{rdmin}:rep(2),RAMP(rdmin,rd),LS{rd}:rep(4),RAMP(rd,rdmin)}/2.7,
	fA = 0.9,
	escale = {escala},
	degree = LS{1,1,1, 1,1,3, 4,4,4, 4,3,1} + 7*5,
	fexci = 16000,
	fout = 16000,
	namp = 0,
	nwidth = 0.4,
    amp = 0.2,
	alpha = 7.2,
	freq = LOOP{m51,m0,m0 , m0,m1b,m0, m3,m0,m0, m0,m0,m1}
}

frase = "HA-LE-KI-MO-SU-NI-LA-KA-ME-DI-NA-RE"
talk = {[Tract.paramskey_speak] = LOOP{Tract:doTalk(frase,true,true,false)}}
singer = OscEP{inst=Tract.sinteRd.name,mono=true,sends={db2amp(-13)},channel={level=db2amp(-0)}}
singer.inserts = {{ER.synname,{angle=-0.1,bypass=0}},{"BLowShelf",{db=-4,freqEQ=450,rs=0.7,bypass=0}},{"PPongF",{bypass=1,volumen=0.95,ffreq=1000,rq=1, fdback=0.6,delaytime=BeatTime(4/3)}}}

singer:Bind(LS{DONOP(1+64),
PS(meloini,talk),DOREST(8*4),
LS{PS(meloini,talk)}:rep(2),DOREST(8*4),
LS{PS(melody,talk)}:rep(2),DOREST(8*4),
LS{PS(melody_press,talk)}:rep(2),SETEv"osti",DOREST(8*2),
LS{PS(melody_press,talk)}:rep(2),DOREST(8*2),
LS{PS(melody_press,talk)}:rep(2),SETEv"singer3",DOREST(8*2),
SETINS(3,{bypass=0}),LS{PS(melody_press,talk)}:rep(2),DOREST(8*2),
LS{PS(melody_press,talk)}:rep(2),SETEv"singer2",DOREST(8*2),
SETINS(3,{bypass=1}),LS{PS(melody_press,talk)}:rep(2),DOREST(8-1),SETEv"zurdo",DOREST(8+1),
LS{PS(melody_press,talk)}:rep(2),DOREST(8*2-1),SETEv"coros",DOREST(1),
LS{LS{PS(melody_press,talk)}:rep(2),SETEv"solo_s",DOREST(8*2)},
LS{LS{PS(melody_press,talk)}:rep(2),SETCHANS({pluk,pluk2,plukosti,shaker,bow,claper,zurdo},{unmute=0}),DOREST(8*2)},
LS{LS{PS(melody_press,talk)}:rep(2),SETCHANS({pluk,pluk2,plukosti,shaker,bow,claper,zurdo},{unmute=1}),DOREST(8*2)},
LS{LS{PS(melody_press,talk)}:rep(2),SETPLAYERS({Master},{level=ERAMP(1,db2amp(-120),Time2beats(100))}),DOREST(8*2)},
LOOP{LS{PS(melody_press,talk)}:rep(2),DOREST(8*2)}
})
-- singer2
melodyos = {
	dur = LOOP{LS{2,1}:rep(7),1,1,1}/3,
	Rd = 0.7,
	fA = 0.9,
	escale = {escala},
	degree = LOOP{1,5, 5,5, 4,5, 5,5, 2,4, 5,6, 4,6, 5,4,2} + 7*5,
	namp = 0.02, 
}


fraseos = "KI-U-_v-Eq-KI-E-_v-Eq-KI-U-_v-Eq-KI-E-A-I-O"
talkos = {[Tract.paramskey_speak] = LOOP{LS{Tract:doTalk(fraseos,true,true,false)}}}
singer2 = copyplayer(singer)
singer2.channel.level = db2amp(-16)
singer2:Bind(LS{WAITEv"singer2",ADV(LOOP{PS(melodyos,talkos)})})
singer2.inserts = {{ER.synname,{angle=SINE(0.1,0,0.5),dist=0.6,bypass=0}}} 

-- singer3
mel_s3 = {
	dur = LS{5,2,2,3,12}/3,
	Rd = 1,
	fA = 0.9,
	escale = {escala},
	degree = LOOP{REST,1,REST,1,1-7} + 7*6,
	namp = 0.02, 
	freq = LOOP{m0,m1u,m0 ,m1u,m51}
}
frase3 = "_v-HE-_v-_qE-MUMv"
talk3 = {[Tract.paramskey_speak] = LOOP{LS{Tract:doTalk(frase3,true,false,false)}}}
singer3 = copyplayer(singer2)
singer3.channel.level = db2amp(-12)
singer3:Bind(LS{WAITEv"singer3",DOREST(4),LOOP{PS(mel_s3,talk3)}})
singer3.inserts = {{ER.synname,{angle=0.05,dist=2,bypass=0}}}

-- solo
solo = {
	dur = LS{2,2,4,2,2,3,3*3,LS{2}:rep(12)}/3,
	Rd = 0.3,
	fA = 1.1,
	escale = {escala},
	degree = LOOP{1,1,1,2,4,5,5,5,4,2,1,1,1,2,4,1,0,1,2} + 7*5,
	namp = 0.02, 
}
frase_solo = "KO-LE-RO-DO-MI-HA-LE"
talk_solo = {[Tract20.paramskey_speak] = LOOP{LS{Tract20:doTalk(frase_solo,true,false,false)}}}
solo_s = copyplayer(singer2)
solo_s.inst = Tract20.sinteRd.name
solo_s.channel.level = db2amp(-16)
solo_s:Bind(LS{WAITEv"solo_s",DONOP(1),LOOP{PS(solo,talk_solo)}})
solo_s.inserts = {{ER.synname,{angle=SINE(0.05,0,0.3),dist=0.5,bypass=0}}}

---- several choir voices with 3 singers each voice
-- choir1
local fratio = midi2ratio(0.1)
local freqs = TA():gseries(3,1 * fratio^(-1),fratio)
Tract22:MakeCoralSynth("coralafri",freqs)
hm3b = ENVdeg({0,0,1},{0.75,0.25})
hmelo = {
	dur = LOOP{9,1,2}/3,
	Rd = 1,
	amp = LOOP{ENV({1,1,1,0.5},{0,0.25,0.75},nil,true),1,0.5},
	fA = 1.4,
	escale = {escala},
	degree = LOOP{1,REST,0} + 7*4,
}
hfrase = "Mv-_v-HAU"
htalk = {[Tract22.paramskey_speak] = LOOP{LS{Tract:doTalk(hfrase,true,true,false)}}}
choir = OscEP{inst=Tract22.coralafri.name,mono=true,sends={db2amp(-5)},channel={level=db2amp(-16)}}
choir:Bind(LS{WAITEv"coros",FinDur(1,SKIPdur(3,PS(hmelo,htalk))),LOOP{ADV(LS{PS(hmelo,htalk)}:rep(2))}})
ER:set(choir, {angle=0.1,dist=1.6,bypass=0} )

--choir2 (second voice)
choir2 = copyplayer(choir)
choir2.channel.level = db2amp(-16)
hmeloq = deepcopy_values(hmelo)
htalkq = deepcopy(htalk)
hmeloq.degree = hmeloq.degree+LOOP{4,4,4,3,3,3}
choir2:Bind(LS{WAITEv"coros",FinDur(1,SKIPdur(3,PS(hmeloq,htalkq))),LOOP{ADV(LS{PS(hmeloq,htalkq)}:rep(2))}})
choir2.inserts = {{ER.synname,{angle=-0.1,dist=1.6,bypass=0}}}


-- choir3 (choir answering)
hmelo2 = {
	dur = LOOP{5,4,3+12}/3,
	Rd = 1,
	amp = LOOP{1,ENV({1,1,1,0.3},{0,0.25,0.75},nil,true),1},
	fA = 1.3,
	escale = {escala},
	degree = LS{NOP,8,REST} + 7*4,
	freq = LOOP{m0,m51,m0}
}
hfrase2 = "_v-HE-_v"
htalk2 = {[Tract22.paramskey_speak] = LOOP{LS{Tract:doTalk(hfrase2,true,true,false)}}}
choir3 = OscEP{inst=Tract22.coralafri.name,mono=true,sends={db2amp(-5)},channel={level=db2amp(-18)}}
choir3:Bind(LS{WAITEv"coros",DONOP(1),LOOP{ADV(LS{PS(hmelo2,htalk2)}:rep(2))}})
ER:set(choir3, {angle=0.0,dist=1.6,bypass=0})

-- pluk
plukseq = {
	escale = {escala},
	degree = LOOP{1,3,REST,1,3,RS{LS{REST}:rep(2),LS{6-7,7-7}},LSS{6-7,5-7}} + 7*5,
	delta = LOOP{2,1, 3, 2,1,1,1,1}/3,
	dur = LOOP{ 2,1,3,2,1,1,1,RS{1,4}}/3,
	amp = LOOP{1,1,1,0.75,0.75,1,1,1}*noisefStream{0.4,0.7},
	pos = noisefStream{0.06,0.2},
	c3 = noisefStream{50,800},c1 = 0.04,
}
plukiniseq = {
	escale = {escala},
	degree = LS{6-7,7-7,5-7} + 7*5,
	delta = LOOP{1,1,1}/3,
	dur = LOOP{1,1,4}/3,
	amp = LOOP{0.3,0.5,1}*0.7,
	pos = noisefStream{0.06,0.2},
	c3 = noisefStream{50,800},c1 = 0.04,
}
pluk = OscEP{inst = "afripluck",sends={0.1},channel={level=db2amp(0)}}
pluk:Bind(LS{PS(plukiniseq),PS(plukseq)})
pluk.inserts = {{"plucksoundboard",{db=0,mix=0.8}},{ER.synname,{angle=0.14,bypass=0}},{"BPeakEQ",{freqEQ=1000,rq=3.5}},{"Compander",{postGain=0.6,thresh=-36,bypass=1}},{"PPongF",{bypass=1,volumen=0.95,ffreq=1000,rq=1, fdback=0.9,delaytime=BeatTime(2)}}}

-- pluk2
pluk2 = OscEP{inst = "afripluck",dontfree=true,sends={0.1},channel={level=db2amp(0)}}:Bind(LS{DONOP(1),PS{
	escale = {escala},
	degree = LOOP{1,8} + 7*6,
	dur = RSinf{1,1/3},
	delta = 1,--LOOP{2,4}/3, --RSinf{LS{1,1},LS{2/3,4/3}},
	amp = noisefStream{0.3,0.6},
	pos = noisefStream{0.06,0.2},
	c3 = 2000,c1 = 200 --0.04
}})
pluk2.inserts = {{"plucksoundboard",{db=0}},{ER.synname,{angle=-0.1,dist=0.4}}}

--plukosti
plukosti_seq = {
	dur = LS{2,1,3}/3,
	escale = {escala},
	degree = LOOP{1,1,REST} + 7*6,
	amp = noisefStream{0.5,0.6},
	pos = noisefStream{0.06,0.2},
	c3 = RSinf{10,20}
}
plukosti_seq2 = {
	dur = LS{2,1,1,1,1}/3,
	escale = {escala},
	degree = LOOP{1,1,RS{LS{5,3,4},LS{1,5-7,0}}} + 7*6,
	amp = noisefStream{0.5,0.6},
	pos = noisefStream{0.06,0.2},
	c3 = RSinf{10,20}
}
plukosti = OscEP{inst = "afripluck",sends={db2amp(-13)},channel={level=db2amp(-15)}}
plukosti.inserts = {{"plucksoundboard",{db=0,mix=0.8}},{ER.synname,{angle=0.9,bypass=0}},{"BPeakEQ",{freqEQ=1600,rq=1,db=5}}}

plukosti:Bind(LS{WAITEv"osti",DONOP(1),LS{PS(plukosti_seq)}:rep(8),WRS({PS(plukosti_seq),PS(plukosti_seq2)},{4,1},-1)})


-- shaker
shpat = {
	note=70,
	amp = LOOP{0.2,0.2,0.2,1,0.5,0.2,1,0.5},
	density=LOOP{4000,2000,2000,2000},
	attack=LOOP{0.05,0.2,0.05,0,0.05,0.2,0.0,0.2},
	decay=0.2,
	dur=LOOP{2,1}/3,
	}
shaker=OscEP({inst="shaker",sends={db2amp(-26),db2amp(-6)},channel={level=db2amp(-24)}})
shaker:Bind(LS{DONOP(16),PS(shpat)})
ER:set(shaker,{angle=0.2,dist=0.55,bypass=0} )

-- violin
mm1 = ENVdeg({-1,0},{0.5})
bowseq = {
	dur = LS{LS{1}:rep(9*2-1),2/3,4/3,2,LS{1}:rep(9-1),2/3,4/3,1},
	velo = LOOP{ENV({0,0,1,1,0},{0,0.5,0.4,0.1},"lin",true)}*LOOP{-1,1}*0.4,
	escale = {escala},
	freq = LOOP{mm1,LS{m0}:rep(19),mm1,LS{m0}:rep(10)},
	force =  1,
	degree = LOOP{LS{1,3,4,5,4,3,1,0,-2}:rep(2),1,REST,LS{1,3,4,5,4,3,1,0,-2}:rep(1),1,REST} + 7*6,
}
bowseq2 = deepcopy(bowseq)
bowseq2.degree = LOOP{LS{1,3,4,5,7,3,1,0,-2}:rep(2),1,REST,LS{1,3,4,5,4,3,1,0,-2}:rep(1),1,REST} + 7*6
bow = OscEP({inst="bowed",mono=true,sends={db2amp(-13),db2amp(-6)},channel={level=db2amp(0)}})
bow.inserts = {{"bowsoundboard"}}
ER:set(bow, {angle=-0.85,dist=0.5,bypass=0})
bow:Bind(LS{DONOP(32+1),PS(bowseq),DONOP(8),PS(bowseq),DONOP(8*2),PS(bowseq),DONOP(8*2),PS(bowseq2),DONOP(8),LOOP{PS(bowseq),PS(bowseq2)}})

-- claps
clapseq = {
	dur = LOOP{5,4,3,3,3,6}/3,
	note = LS{60,60,60,REST,60,60}:rep(4),
	amp = LOOP{0.6,0.6,0.5,1,RS{0.4,0.2},0.4}*0.7,
	dura = LOOP{1,1,LS{0.7}:rep(3),1},
	fq =noisefStream{0.4,0.6},
	q =LOOP{noisefStream({0.3,0.5},4),0.2,noisefStream({0.4,0.5},1)},
}
claper = OscEP{inst="clap2",dontfree=true,sends={db2amp(-8)},channel={level=db2amp(-5)}}
claper:Bind(LS{DONOP(1+120),LS{PS(clapseq),DONOP(16)}:rep(2),LOOP{PS(clapseq)}})
ER:set(claper, {angle=-0.2,bypass=0,dist=2})

------------------- master -------------
Effects={FX("dwgreverb",db2amp(1),nil,{c1=4.5,c3=20,len=5000})}

theMetro:tempo(160)
theMetro:start()
