-------------------------first the SynthDefs------------------------------
-- we will getting requiring a lua file with synthdefs in this script folder
-- and call sync for waiting to async complete
local path = require"sc.path"
path.require_here()
require"synthdefs"
Sync()

-----------------------------------
escale = newScale({0,1,3.86,5,7.02,8,10}) 
escale = {escale}
------------- early reflection synths ------------------

local ER = require"sc.ER"(0.85,1,1,{direct=false,compensation=true,part=true,N=5})
local ERdir = require"sc.ER"(0.85,1,1,{direct=true,compensation=true,part=true,N=2,allpass=0.7})

--------------------- players and patterns ---------------------------
---- choir with three voices

local frase = "Mv-UMv-OMv-Mv-OIUMv-EUMv"
local frase2 = "Mv-EUMv-OIUMv"
--TT = require"num.ParametricTract"(25,17.5)
TT = require"num.vocaltractB"(30,true,true)
drone = {
	escale = escale,
	dur = LS{LS{12}:rep(4),6,6},
	degree = LS{LS{1}:rep(4),1,REST} + 7*4,
	Rd=0.3,
	namp = 0.0,
	thlev = 0.5,
	fA = 1.2,
	fPreoral = 1.2,
	vibdepth = 0.003,
	allvocals = true,
	fade = true
}

choir = deepcopy(drone)
choir.dur = LS{12,6,6,6,6,6,6,12}
choir.degree = LS{1,0,2,-1,-2,-1,0,1} + 7*4

c1 = OscEP{inst=TT.sinteRdO2.name,mono=true,sends={db2amp(-15),db2amp(-15)},channel={level=db2amp(-22),pan=0}}

c2 = copyplayer(c1)
drone2 = deepcopy(drone)
drone2.degree = LS{LS{5}:rep(4),5,REST} + 7*4
choir2 = deepcopy(choir)
choir2.degree = LS{5,4,4,4,5,4,6,5} + 7*4

c3 = copyplayer(c1)
c3.channel.level = db2amp(-19)
drone3 = deepcopy(drone)
drone3.degree = LS{LS{REST}:rep(4),REST,REST} + 7*3
choir3 = deepcopy(choir)
choir3.degree = LS{1,0,2,-1,-2,-1,0,1} + 7*3

ERdir:set(c1, {dist=2,angle=SINEr(0.05,math.pi/2,-1,1)})
ERdir:set(c2, {dist=2,angle=SINEr(0.05,-math.pi/2,-1,1)})

----------------- spanish guitar
guit_pat = {
	escale = escale,
	dur = LS{9,3,6,6,6,6,6,4,2,12},
	degree = LS{{1,5,8,10,12},{1,5,9,11,12},
				{0,4,9,11,12},  
				{2,4,9,11,12},
				{-1,4,9,11,12},
				{-2,5,8,10,12},
				{2,4,9,11,12},
				{0,4,9,11,12},
				{0.5,4,9,11,12},
				{1,5,8,10,12}} +7*4,
	voice =LOOP{{5,4,3,2,1}} ,
	amp = LOOP{TA():series(5,0.5,0.5/4)},
	t_gate= 1,
	strum = 0.75
}
guit_patB = deepcopy(guit_pat)
guit_patB.dur = LS{6,6,6,6,6,6,6,4,2,12}

guit_pat2R = {
	escale = escale,
	dur = LS{2, 0.5,0.5,0.5, 0.5,1,1,2, 2, 6,1,1,1,1,4}*0.5, --12
	degree = LOOP{{1,5,8,10,12},LS{{1,5,8,10,12}}:rep(3),LS{{1,5,8,10,12},{12,10,8,5,1}}:rep(2),REST,{0,2,4,9,11,12},{3,4},2,1,5,8} +7*4,
	voice = LOOP{{5,4,3,2,1},LS{{5,4,3,2,1}}:rep(3),LS{{5,4,3,2,1},{1,2,3,4,5}}:rep(2),{6,5,4,3,2,1},{6,5,4,3,2,1},{5,4},5,5,4,3},
	amp = LOOP{LS{TA():series(5,0.5,0.3/4)},LS{0.6,0.5,0.7},LS{TA():series(5,0.5,0.3/4)}:rep(6),0.7,0.7,LS{0.7}:rep(3)},
	t_gate = LOOP{1,LS{1}:rep(3),LS{1}:rep(7),0,1,1,1},
	strum = LOOP{0.15,LS{0.25}:rep(4),LS{0.15}:rep(4),0.75,0,0,0,0,0}
}


guit_pat2b = {
	escale = escale,
	dur = LS{2, 0.5,0.5,0.5, 0.5,1,1,2, 2, 6,1,1,1,1,4}*0.5, 
	degree = LOOP{{2,4,9,11,12},LS{{2,4,9,11,12}}:rep(3),LS{{2,4,9,11,12},{12,11,9,4,2}}:rep(2),REST,{2.7,5,9,11,12},{2.7,4},2,1,5,8} +7*4,
	voice = LOOP{{5,4,3,2,1},LS{{5,4,3,2,1}}:rep(3),LS{{5,4,3,2,1},{1,2,3,4,5}}:rep(2),{6,5,4,3,2,1},{6,5,4,3,2,1},{5,4},5,5,4,3},
	amp = LOOP{LS{TA():series(5,0.5,0.3/4)},LS{0.6,0.5,0.7},LS{TA():series(5,0.5,0.3/4)}:rep(6),0.7,0.7,LS{0.7}:rep(3)},
	t_gate = LOOP{1,LS{1}:rep(3),LS{1}:rep(7),0,1,1,1},
	strum = LOOP{0.15,LS{0.25}:rep(4),LS{0.15}:rep(4),0.75,0,0,0,0,0}
}

guit_pat2c = {
	escale = escale,
	dur = LS{2, 0.5,0.5,0.5, 0.5,1,1,2, 2, 6,1,1,1,1,4}*0.5, --12
	degree = LOOP{{2,4,9,11,12},LS{{2,4,9,11,12}}:rep(3),LS{{2,4,9,11,12},{12,11,9,4,2}}:rep(2),REST,{2.7,5,9,11,12},{2.7,4},2,2.7,5,9} +7*4,
	voice = LOOP{{5,4,3,2,1},LS{{5,4,3,2,1}}:rep(3),LS{{5,4,3,2,1},{1,2,3,4,5}}:rep(2),{6,5,4,3,2,1},{6,5,4,3,2,1},{5,4},5,5,4,3},
	amp = LOOP{LS{TA():series(5,0.5,0.3/4)},LS{0.6,0.5,0.7},LS{TA():series(5,0.5,0.3/4)}:rep(6),0.7,0.7,LS{0.7}:rep(3)},
	t_gate = LOOP{1,LS{1}:rep(3),LS{1}:rep(7),0,1,1,1},
	strum = LOOP{0.15,LS{0.25}:rep(4),LS{0.15}:rep(4),0.75,0,0,0,0,0}
}

guit_pat3 = {
	escale = escale,
	dur = LOOP{LS{2/3}:rep(10),4/3+4, LS{0.5}:rep(8), LS{2/3}:rep(3),LS{0.5}:rep(6),3}*0.5, --12
	degree = LS{6,{9,11},6,5,{9,11},5,4.5,{9,11},4.5,4,{9,11},
		{4,9,11},5, 4,2.7, 2,2.7, 4,5, {4,9,11},5,4, 2.7,2, 1,1,3,{1,5},8} +7*4,
	voice = LOOP{LS{4,{3,2},4}:rep(3),4,{3,2},{4,3,2},4,4,5,5,5,4,4, {4,3,2},4,4,5,5, 5,5,5,{5,4},3},
	--strum = LOOP{LS{0,0.05,0}:rep(3),0,0.05},
	amp = LS{LS{1,0.75,0.5}:rep(3),0.75,0.5,LS{1}:rep(18)}*1.2,--1, --0.95,
	t_gate = LOOP{LS{1}:rep(11),1,0,1,1,1,0,1,0,1,0,0,1,0, 0,1,0,{0,1},1},
}

guit_pat3b = {
	escale = escale,
	dur = LOOP{LS{2/3}:rep(10),4/3+4, LS{0.5}:rep(8), LS{2/3}:rep(3),LS{0.5}:rep(6),3}*0.5, --12
	degree = LS{6,{9,11},6,5,{9,11},5,4.5,{9,11},4.5,4,{9,11},
		{4,9,11},5, 4,2.7, 2,2.7, 4,5, {4,9,11},5,4, 2.7,2, 2.7,2.7,5,{2.7,9},12} +7*4,
	voice = LOOP{LS{4,{3,2},4}:rep(3),4,{3,2},{4,3,2},4,4,5,5,5,4,4, {4,3,2},4,4,5,5, 5,5,5,{5,3},2},
	--strum = LOOP{LS{0,0.05,0}:rep(3),0,0.05},
	amp = LS{LS{1,0.75,0.5}:rep(3),0.75,0.5,LS{1}:rep(18)}*1.5,--1, --0.95,
	t_gate = LOOP{LS{1}:rep(11),1,0,1,1,1,0,1,0,1,0,0,1,0, 0,1,0,{0,1},1},
}

guit = OscVoicerEP{inst="guitar",sends={db2amp(-9),db2amp(-19)},channel={level=db2amp(-3)}}
guit.inserts = {{"plucksoundboard"}}
ERdir:setER(guit,-0.1,1)

--------- woman -------------
m1 = ENVdeg({-1,-1,0,0},{0.3,0.1,0.6})
m1l = ENVdeg({-1,-1,0,0},{0.5,0.1,0.4})
m5 = ENVdeg({-4,-4,0,0},{0.4,0.1,0.6})
md = ENVdeg({0,0,0,-1,-1,0,0},{0,0.2,0.1,0.1,0.1,0.5})
m2 = ENVdeg({0,0,1,0},{0.5,0.25,0.25})
m1b = ENVdeg({0,0,-5},{0.9,0.1})
m1c = ENVdeg({0,0,-1},{0.9,0.1})
m4 = ENVdeg({1,1,1,0,0,-1,-1,0},{0,0.12,0.05,0.12,0.05,0.12,0.05})
m0 = getdegree

local fraseella = "A-_A-A-_A-_v-A-HA-A-_A-_v-A-_A-A-HA-_v"
--TT2 = require"num.ParametricTract"(26,13.3)
TT2 = require"num.vocaltractB"(28,false,true)

ella = OscEP{inst=TT2.sinteRdO2.name,mono=true,sends={0.35,0.35},channel={level=1}}
intro_ella = {
	dur = LOOP{LS{2}:rep(4),4}, --LOOP{LS{2}:rep(11),4,4},
	escale = escale,
	degree = LS{4,5,5,5,REST,3,4,4,4,REST,2,3,3,3,REST,1,2,2,2,REST,1,2,1,1,REST}:rep(1) + 7*5,
	freq = LOOP{LS{m0,m1,m4,m1b,m0}:rep(4),m0,m1,m4,m0,m0},
	Rd= LOOP{0.5,0.4,0.3,0.3,0.5},
	namp = 0.25,
	thlev = 0.5,
	fA = LOOP{LS(TA():series(25,1.2,(0.85-1.2)/25)),LS{0.9}:rep(25)},
	fPreoral =  0.95,
	fAc = 1,
	vibdelay = 0,
	vibdepth = LOOP{0,0,0,0.01,0},
}

melo_ella1 = deepcopy(intro_ella)
melo_ella1.fA = 0.9

fraseella3 = "RA-RA-HA-RA-RA-HA-_v-RA-RA-HA-RA-_v"
moru = ENVdeg({0,0,1,1},{0.4,0.1,0.5})
mord = ENVdeg({0,0,-1,-1},{0.4,0.1,0.5})
melo_ella3 = {
	dur = LOOP{2,2,2,3,1,1,1, 2,2,2,4,2}*0.5,
	escale = escale,
	degree = LS{5,5,3,4,4,3,REST, 5,5,3,4,REST ,4,4,2,3,3,2,REST ,4,4,2,3,REST} +7*5,
	freq = LOOP{moru,mord,moru,moru,m0,m0,m0, moru,mord,moru,moru,m0},
	thlev = 0.5,
	fA=0.9,
	namp = 0.25,
	fPreoral =0.95,
	Rd = 0.6,
	vibdepth = 0
}

ER:setER(ella,-0.1,1)

table.insert(ella.inserts,{"PPongF",{bypass=1,volumen=0.4,fdback=0.8,delaytime=BeatTime(4)}})
table.insert(ella.inserts,{"FourBandEq",{bypass=0,db={{0,0,0,0}}},false})

-------- man -----------------

hombre = require"num.vocaltractB"(36,true,true)
MakeRoncoSynth(hombre,"Ronco",true)
ini_frase_h = "A-HAOUMv-IAOUMv-EAOUMv-_v"
frase_h1 = "EI-TOU-NEI-HO-EIOMv-_v-EI-TOU-NEI-HOUMv-EIOMv-_v"
frase_h2="AI-IA-DE-HO-RAOUMv-_v-AI-IA-DE-HO-RAOUMv-_v-AI-IA-DE-HO-RAOUMv-_v-AI-IA-DE-HO-RAOUMv-AI-IA-DE-_v-HAUMv-REIOMv-_v-KO-RIEN-DOUMv-_v"
el = OscEP{inst=hombre.Ronco.name,mono=true,sends={0.25,db2amp(-15)},channel={level=db2amp(3)}}

ER:setER(el,0.1,1)
ini_el = {

    dur = LS{4,10,2,15,9}*0.5, --20
	escale = escale,
	degree = LS{0,1,1,1,REST} +7*5,
	freq = LS{m0,m0,m4,m0,m0},
	amp = 0.5, 
	Rd= 0.3,
	namp = 0.35,
	thlev = 0.5,
	fA = 1.1,
	fPreoral = 1.1,
	fAc = 1,
	vibdelay = 0,
	vibdepth = LOOP{0,0,0,0.01,0}*1,
	allvocals = true,
	fade = true,
}

local caeRd = ENVr({0.3,0.3,0.3,0.4,1.9},{0,0.3,0.3,0.4})
local caeRd2 = ENVr({0.3,0.3,0.3,0.4,0.7},{0,0.3,0.5,0.2})
melo_el1 = {

    dur = LS{2,1,2,1,4,6,1,1,6,6,12,6}*0.5, --24
	escale = escale,
	degree = LS{2,2.7,4,3,4,REST,2.8,2,2.8,2,1,REST} +7*5,
	freq = m0,
	amp = LOOP{2,1.5,2,1.5,2,1}*0.3, 
	Rd= LS{LS{0.3}:rep(4),caeRd,LS{0.25}:rep(5),caeRd,1},
	namp = 0.35,
	thlev = 0.5,
	fA = 1.1,
	fPreoral = 1.1,
	fAc = 1,
	vibdelay = 0,
	vibdepth = LOOP{0,0,0.01,0,0.01}*1,
	allvocals = true,
	fade = LS{LS{false}:rep(4),true,true,false,false,LS{true}:rep(4)}
}
melo_el1b = deepcopy(melo_el1)
melo_el1b.degree = LS{2,2.7,4,5,4,REST,2.8,2,2.8,2,1,REST} +7*5
melo_el1b.fPreoral = 1.2

melo_el2 = {

    dur = LS{2,1,2,1,3,3 ,2,1,2,1,3,3 ,2,1,2,1,3,3, 2,2,2,2,2,2, 2,1,1, 9,4,3,1,1,12+6}*0.5, 
	escale = escale,
	degree = LS{4,4,4,2.7,2,REST ,5,5,5,4,3,REST ,6,6,6,5,4,REST, 7,7,7,6,5,4,3,4,REST ,2.8 ,2,REST,1,1,1} +7*5,
	freq = LS{LS{m1l,m0,m0,m0,m1b,m0}:rep(3) , m1l,m0,m0,m0,m0,m0,m0,m1b,  m0, m0 ,md,LOOP{m0}},
	amp = ENV({1,1,1,0.8,0.6},{0,0.3,0.5,0.2})*0.6, 
	Rd= 0.3,
	namp = 0.3,
	nwidth = 0.9,
	thlev = 0.5,
	fA = 1.1,
	fPreoral = 1.3,
	fAc = 1,
	vibdelay = 0,
	vibdepth = LOOP{LS{LS{0.0}:rep(4),0.01,0}:rep(3) ,LS{0.01}:rep(8),LS{0.01}:rep(-1),0 ,LS{0.01}:rep(4),0.02,0,0.01,0,0,0,0.01,0}*1,
	allvocals = LS{LS{false}:rep(32),LOOP{true}},
	fade = LS{LS{false}:rep(32),LOOP{true}},
}

----------- clap -----------------
local fqh = 0.6
local flw = 0.1

pat={
	dur = LOOP{1.5,1.5, 1.5,1.5, 1+1,1+1,1+1,
				1.5,1.5, 1.5,1.5, 1+1,1+1,1+1}*0.5,
	fq =  LOOP{flw,fqh,flw,fqh,flw,flw,flw}*0.3,
	rnd1 = noisefStream{-0.003,0.003},
	rnd2 = noisefStream{-0.003,0.003},
	amp = LOOP{4.5,0.5,3,0.5,4.5,3,3}*0.5,
}
pat2={
	dur = LOOP{1,1,1+1,1,1+1,0.5,0.5,1,0.5,0.5,1,1}*0.5,
	fq =  LOOP{fqh}*0.4*noisefStream{0.8,1.15},
	rnd1 = noisefStream{-0.003,0.003},
	rnd2 = noisefStream{-0.003,0.003},
	amp = LOOP{0,1,1,1,1,1,1,1.5,1,1,1.5,1}*0.15,
}

clap=OscEP{inst="clap1",dontfree=true,sends={db2amp(-10,0),0},channel={level=db2amp(0)}}

clap2 = copyplayer(clap)
clap2.inst = "clap2"
clap2.channel.level = 1

ERdir:setER(clap,-0.5,1.75)
ERdir:setER(clap2,0.5,1.75)

----- handdrum ----------

tambpat = {
	dur = LOOP{1.5,1.5,1,1,0.5,0.5},
	tension = LOOP{0.0175,0.0175,0.026,0.026,0.026,0.0175},
	loss = LOOP{0.3,0.3,1,2,2,0.3},
	amp = LOOP{1,1,1,0.5,0.5,1}*0.5,
	t_gate = 1
}
tamb = OscEP{inst="testMembrane",mono=true,dontfree=true,sends={db2amp(-15)},channel={level=db2amp(-9)}}

ER:setER(tamb,-0.2,1)

----------------------bass
basspat2 = {
	dur = LOOP{1.5,1.5,1,1,0.5,0.5},
	escale = escale,
	degree = LOOP{1,1,8,1,LSS{7,9},1}+7*4,
	decay = LOOP{2.6, 2.6 ,2.6, 0.6, 0.6, 0.6}
}
bass = OscEP{inst="cbass",mono=false,sends={db2amp(-25)},channel={level=db2amp(-8)}}

ER:setER(bass,0.2,1)

------------------ song structure -----------------------------------
ActionEP():Bind{actions = LS{STOP(504,c1,c2,c3),ACTION(505,function() theMetro:stop() end)}}

c1:Bind(LS{
	DONOP(2),
	PS(drone,LOOP(PS(TT:Talk(frase,true,true)))),
	PS(choir,LOOP(PS(TT:Talk(frase,true,true)))),
	DOREST(0), --to stop mono player

	WAITEv"jondo2",
	UNTILEv("melo1",LS{
		PS(choir,LOOP(PS(TT:Talk(frase,true,true)))),
	}),
	DOREST(0),
	WAITEv"melo1",
	DOREST(2),
	PS(choir,LOOP(PS(TT:Talk(frase,true,true)))),
	DOREST(0),
	WAITEv"hombre2",
	DOREST(2),
	LOOP(PS(drone,LOOP(PS(TT:Talk(frase,true,true)))))
})

c2:Bind(LS{
	DONOP(2),
	PS(drone2,LOOP(PS(TT:Talk(frase2,true,true)))),
	PS(choir2,LOOP(PS(TT:Talk(frase2,true,true)))),
	DOREST(0),
	WAITEv"jondo2",
	UNTILEv("melo1",LS{
		PS(choir2,LOOP(PS(TT:Talk(frase2,true,true)))),
	}),
	DOREST(0),
	WAITEv"melo1",
	DOREST(2),
	PS(choir2,LOOP(PS(TT:Talk(frase2,true,true)))),
	DOREST(0),
	WAITEv"hombre2",
	DOREST(2),
	LOOP(PS(drone2,LOOP(PS(TT:Talk(frase2,true,true)))))
})

c3:Bind(LS{
	DONOP(62),
	PS(choir3,LOOP(PS(TT:Talk(frase,true,true)))),
	DOREST(0),
	WAITEv"melo1",
	DOREST(2),
	PS(choir3,LOOP(PS(TT:Talk(frase,true,true))))
})

guit:Bind(LS{
	DONOP(62),
	SETCHAN{level=db2amp(-3)},
	PS(guit_pat),
	WAITEv"guit_jondo",
	SETCHAN{level=db2amp(2)},
	PS(guit_pat2R),
	PS(guit_pat3),
	SETEv"jondo",
	SETCHAN{level=db2amp(-3)},
	PS(guit_pat2R),
	PS(guit_pat2R),
	PS(guit_pat2c),
	PS(guit_pat2b),
	PS(guit_pat3b),
	PS(guit_pat2b),
	SETEv"jondo2",
	SETCHAN{level=db2amp(-3)},
	PS(guit_patB),
	WAITEv"melo1",
	DOREST(2),
})

ella:Bind(LS{
	SETSENDS(2,0.35),
	PS(intro_ella,LOOP(PS(TT2:Talk(fraseella,true,false)))),
	PS(melo_ella1,LOOP(PS(TT2:Talk(fraseella,true,false)))),
	DOREST(3),
	SETSENDS(2,db2amp(-15)),
	DOREST(2),
	SETEv("guit_jondo"),
	WAITEv"melo1",
	SETSENDS(2,0.35),
	SETINS(2,{bypass=0}),
	PS(melo_ella1,LOOP(PS(TT2:Talk(fraseella,true,false)))),
	DOREST(2+6),
	SETSENDS(2,db2amp(-15)),
	SETEv"hombre2",
	SETINS(2,{volumen=0.2}),
	LS{PS(melo_ella3,LOOP(PS(TT2:Talk(fraseella3,true,false))))}:rep(3),
	DOREST(12),
	LS{PS(melo_ella3,LOOP(PS(TT2:Talk(fraseella3,true,false))))}:rep(2),
	WAITEv"fin",
	DOREST(2),
	SETINS(2,{volumen=0}),
})

el:Bind(LS{
	WAITEv"jondo",
	SETCHAN{level=db2amp(4)},
	PS(ini_el,hombre:Talk(ini_frase_h,false,false)),
	DOREST(4),
	PS(melo_el1,hombre:Talk(frase_h1,true,true)),
	PS(melo_el1b,hombre:Talk(frase_h1,true,true)),
	WAITEv"jondo2",
	DOREST(6),
	PS(melo_el2,hombre:Talk(frase_h2,true,true)),
	DOREST(4),
	SETEv"melo1",
	WAITEv"hombre2",
	DOREST(24),
	SETCHAN{level=db2amp(0)},
	PS(ini_el,hombre:Talk(ini_frase_h,true,true)),
	DOREST(2),
	PS(ini_el,hombre:Talk(ini_frase_h,true,true)),
	PS(melo_el1,hombre:Talk(frase_h1,true,true)),
	PS(melo_el1b,hombre:Talk(frase_h1,true,true)),
	PS(melo_el2,hombre:Talk(frase_h2,true,true)),
	SETEv"fin"
})

clap:Bind(LS{
	DONOP(2),
	DONOP(60),
	FinDur(60.25,PS(pat)),
	WAITEv"guit_jondo",
	PS(pat)
})

clap2:Bind(LS{
	DONOP(2),
	DONOP(60),
	FinDur(60.25,PS(pat2)),
	WAITEv"guit_jondo",
	PS(pat2)
})

tamb:Bind(LS{
	WAITEv"melo1",
	DONOP(2),
	PS(tambpat)
})

bass:Bind(LS{
	WAITEv"melo1",
	DONOP(2),
	DONOP(60),
	PS(basspat2),
})

-------------------------------- master
MASTER{level=db2amp(-15)}
Master.inserts = {{"to_mono",{bypass=1}}}
Effects={FX("dwgreverb3band",db2amp(0),nil,{rtlow=1.5,rtmid=1.2,predelay=0.14}),FX("dwgreverb",db2amp(0),nil,{c1=1,c3=10,len=5000,predelay=0.14})}
theMetro:tempo(110)
theMetro:start()