RANDOM:seed(17) --for getting the same piece always we seed it with fixed number
-------------------------first the SynthDefs------------------------------
-- we will getting requiring a lua file with synthdefs in this script folder
-- and call sync for waiting to async complete
path = require"sc.path"
path.require_here()
require"synthdefs"
Sync()
------------------------------------ the sequences and players  --------------------
scale = {modes.mixolydian + 7} -- mixolydian mode shifted a fifth (7 semitones)

---- ostinato piano player with 4 kind of sounds ------------------
-- not OscPianoEP because rho and others are init time parameters so that a new node must be created
-- poly = 4 sets a maximum polyphony of 4

tipe1={amp = 0.8,rho = 0.2,mh = 0.3}
tipe2={amp = 0.2,rho = 1 ,mh = 1}
tipe3={amp = 0.5,rho = 0.2,mh = 1}
tipe4={amp = 0.5,rho = 0.6,mh = 1.5} 

ostinato = OscEP{inst="oteypiano",sends={db2amp(-15),0},dontfree=true,poly=4,channel={level=db2amp(-9)}}:Bind(PS(
	{
		delta=LOOP{LS{1.5,1,1,0.5}:rep(3),LS{1,0.5,1,0.5,1}}*0.5,
		dur = 1,
		escale = scale,
		degree=7*5+1 + LS{LS{0}:rep(17*15),LOOP{-7}},
		pan=noisefStream({-1,1}),
	},
	LOOP{tipe1,tipe2,tipe3,tipe4}
))
ostinato.inserts = {{"soundboard"}}

------------ piano melody player -------------------------------
-- piano melody with fixed notes and variable dur. rho, rcore and mh change the sound of piano
-- poly = 10 means maximum polyphony of 10 notes
seqdegree = {1,5,10,4,8,5,9,3,7} -- 9 notes

piano=OscEP{inst="oteypiano",sends={db2amp(-15),0},poly=10,dontfree=true,channel={level=db2amp(3)}}
piano.inserts = {{"soundboard"}}

-- infinite long playing sequence
pianoseq={
	-- 4 noteseq hight octave, the rest low octave
	degree = LOOP(seqdegree) + LS{LS{7*5}:rep(9*4),LOOP{7*4}},
	escale = scale,
	dur = LS{LS{2}:rep(9*2), --9*2=18 ; 2 noteseqs
			WRS({LS{2/3}:rep(3),AGLS(scramble,{0.5,1,0.5})},{3,2},12)*2, --12*3=36=9*4 --4 noteseqs
			WRS({LS{2/3}:rep(3),AGLS(scramble,{0.5,1,0.5})},{3,2},9*4), --9*4*3 -- 12 noteseqs
			WRS({LS{2/3}:rep(3),AGLS(scramble,{0.5,1,0.5})},{3,2},-1)*0.5*3/2}, --...
	amp = noisefStream{0.4,0.7},
	pan = noisefStream{-1,1},
	rho = WRS({0.2,1},{12,1},-1),
	rcore = WRS({1,2},{12,1},-1),
	mh = RSinf{0.3,1,1.5}
}

-- end of piano part
pianoendseq = {
	degree = LOOP(seqdegree) + LS{LS{7*5}:rep(9*4),LOOP{7*4}},
	escale = scale,
	dur = LS{WRS({LS{2/3}:rep(3),AGLS(scramble,{0.5,1,0.5})},{3,2},3*3),
		WRS({LS{2/3}:rep(3),AGLS(scramble,{0.5,1,0.5})},{3,2},3*2)*2,
		LS{2}:rep(9)},
	amp = noisefStream{0.4,0.7},
	pan = noisefStream{-1,1},
	rho = WRS({0.2,1},{12,1},-1),
	rcore = WRS({1,2},{12,1},-1),
	mh = RSinf{0.3,1,1.5}
}


-------------------- Jet sound effect -------------------------
Jet = OscEP{dontfree=false,sends={db2amp(-30)},channel={level=db2amp(-11)}}:Bind{
	inst={"Jetsound","Jetsound2"},
	note = LS{60},
	dur =30,
	time = 20
}

----------------------- drone player -------------------------
drone = OscEP{inst="bowdrone",sends={db2amp(-15),0},channel={level=db2amp(-7)},poly=3}:Bind{
	degree = 7*2 + 1,
	escale = scale,
	dur = 12*3,
	amp = 0.2
}
----------------------- violin player -------------------------
violin = OscEP{inst="bowed",sends={db2amp(-15)},channel={level=db2amp(-9)}}
violin.inserts = {{"bowsoundboard"}}

-- first sequence
violinseq = {
	degree = LOOP{1,5,LSS{4,3,2,1,0,-1,-2,1}+7} + 7*5,
	escale = scale,
	dur = LS{LS{4}:rep(12),LS{1/3}:rep(12*4)},
	legato = LOOP{1,1,0.8},
	c3=200,
	force =2.5,
	amp =LOOP{0.9,0.7,1}
}

-- second sequence
violinseq2 = {
	degree = LOOP{1,5,LSS{4,3,2,1,0,-1,-2,1}+7}+7*5,
	escale = scale,
	dur = LS{LS{2}:rep(12*2),LS{0.5}:rep(12*2),LS{1/3}:rep(12*2),LS{0.25}:rep(12*6)},
	legato = LOOP{1,1,0.8},
	c3=200,
	force =2.5,
	amp =LOOP{0.9,0.7,1},
}

--------------------- cello player --------------------------------
cello = OscEP{inst="bowed",sends={db2amp(-15)},channel={level=db2amp(-6)}}:Bind{
	degree = LS({{1,5},{0,2},{-1,4},{-2,1}},2)+7*4,
	escale = scale,
	dur = 4*2,
	pan = {-0.5,0.5},
	amp =0.5,
}
cello.inserts = {{"bowsoundboard"}}

--------------- Actions structure --------------------------------------

actioncue=ActionEP()
actioncue:Bind{
	actions=LS{
			STOP(-4,unpack(OSCPlayers)),
			START(0,Jet),
			START(4,ostinato),
			--GOTO(6,200),
			BINDSTART(20,piano,pianoseq),
			START(200,drone),
			BINDSTART(220,violin, violinseq),
			START(276,cello),
			BINDSTART(276 + 24*2,violin, violinseq2),
			START(360,cello),
			STOP(420,drone),
			BINDSTART(424,piano,pianoendseq),
			ACTION(488,function() ostinato.playing=false end),
	}
}

------------ Master section ----------------------------------------
Master.inserts={
				{"Compander",{thresh=-10,slopeAbove=.66,bypass=0}},
				{"Limiter",{thresh=0,bypass=0}},
			}
--DiskOutBuffer([[mixolidian_mantra4.wav]])
Effects={FX("dwgreverb",db2amp(0.77),nil,{c1=1.3,c3=10,len=1500})}
theMetro:tempo(100)
theMetro:start()
