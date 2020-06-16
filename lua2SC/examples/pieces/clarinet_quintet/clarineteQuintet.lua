-------------------------first the SynthDefs------------------------------
-- we will getting requiring a lua file with synthdefs in this script folder
-- and call sync for waiting to async complete
path = require"sc.path"
path.require_here()
require"synthdefs"
Sync()

---------------- music -------------------------------
-- clarinet 
cl_notes = {1,3,5,8,7,8,5,3,4,5,1,3,5,5,5,5-7}

cl_phrase = PS{
	escale = "aeolian",
	degree = LS(cl_notes)+7*5,
	amp = LS{LS{0.6}:rep(#cl_notes),LOOP{0.6}}, 
	m = LOOP{RAMP(0.2,1.6)},
	legato = LOOP{0.9,1},
	dur = LOOP{4,2}
}

cl_phrase = LS{DONOP(46),SKIPdur(46,LS(cl_phrase):rep(6)),DOREST(46),SKIPdur(46,LS(cl_phrase):rep(2))}

clarinet = OscEP{inst="clarinet",mono=true,sends={0.5},channel={level=db2amp(-2.5),pan=-0.5}}:Bind(cl_phrase)

------------ three bowed instruments

bw1 = PS{
	escale = "aeolian",
	degree = LS{1,2,3, 2,3,1, 2,3,1, 2}+7*6,
	amp = 0.5,
	legato = LOOP{LS{1,1,0.9}:rep(3),0.9},
	dur = LOOP{LS{4,2,6}:rep(3),12}
}

bw2 = PS{
	escale = "aeolian",
	degree = LS{5,5,6,5,6,5,5,5}+7*5,
	amp = 0.5,
	dur = 6 
}

bw3 = PS{
	escale = "aeolian",
	degree = LOOP{8,7,6,7,8 ,6,7,8,7,7.5}+7*4,
	amp = 1,
	dur = LS{6,6,4,2,6,4,2,6,6,6} 
}

bwdown = PS{
	escale = "aeolian",
	dur  = LOOP{4,2},
	degree = LS(TA():series(8*2+1,3+7*6,-1)),
	legato = LOOP{LS{1}:rep(3),0.8},
	amp = LS{LS{0.5}:rep(16),0.3}*2,
	force = 0.934
}
bwdown2 = PS{
	escale = "aeolian",
	dur  = LOOP{4,2}*0.5,
	degree = LS(TA():series(8*2,3+7*7,-1)..TA():series(8*2,6+7*6,-1)),
	legato = LOOP{LS{1}:rep(7),0.8},
	force = 0.934
}
bwdown3 = PS{
	escale = "aeolian",
	dur  = 1,
	degree = LS(TA():series(6,3+7*8,-1)..TA():series(6,1+7*8,-1)..TA():series(6,6+7*7,-1)
	..TA():series(6,5+7*7,-1)..TA():series(6,4+7*7,-1)..TA():series(6,3+7*7,-1)..TA():series(12,2+7*7,-1)),
	legato = LOOP{LS{1}:rep(5),0.8},
	amp = 0.4,
	force = 0.934
}

bowed = OscEP{inst="bowed",mono=true,sends={0.5},channel={level=db2amp(-11),pan=-0.6}}
:Bind(LS{bwdown,DOREST(48-4),DONOP(48*2),bw1,DOREST(48),LS{FinDur(48,bwdown)}:rep(3)})
bowed.inserts = {{"bowsoundboard"}}

bowed2 = OscEP{inst="bowed",mono=true,sends={0.5},channel={level=db2amp(-11),pan=0.6}}
:Bind(LS{DONOP(48*2),bwdown2,DONOP(48),bw2,DOREST(48),LS{bwdown2}:rep(3)})
bowed2.inserts = {{"bowsoundboard"}}

bowed3 = OscEP{inst="bowed",mono=true,sends={0.5},channel={level=db2amp(-11),pan=-0.6}}
:Bind(LS{DONOP(48*3),bwdown3,bw3,DOREST(48),LS{bwdown3}:rep(3)})
bowed3.inserts = {{"bowsoundboard"}}


------------------------------ piano

pianochords = {
{"C-3","G-3","C-5","D#4","G-4"},--I
{"D#3","A#3","A#4","D#4","G-4"},--III
{"G#2","G#3","C-5","D#4","G#4"},--VI
{"G-2","G-3","C-5","D#4","G-4"},--I
{"F-2","F-3","G#4","F-4","C-4"},--IV
{"C-3","G-3","C-4","D#4","G-4"},--I
{"G-2","G-3","G-4","A#3","D-4"},--V
{"G-2","G-3","G-4","B-3","D-4"}}--Vmay

-- this function will make arpegio from chord
function Arpeg(tran,ampf)
	ampf = ampf or 1
	return function(cc)
		print(cc)
		local ccn = TA(cc):Do(noteToNumber) + tran
		local v1,v2 = {},{}
		v1.note = LS(ccn(1,3))
		v1.dur = LS{6,5,4}
		v1.delta = LS{1,1,4}
		v1.amp = 0.05*ampf*3

		v2.note = LS({NOP}..ccn(4,5)..ccn(4,5)..ccn(4))
		v2.dur = 1
		v2.amp = LS(TA():gseries(6,1,0.85))*0.05*ampf*3
		return ParS{PS(v1),PS(v2)}
	end
end

-- sequence of chords playing
chordseq = {
	note = SF(LS(pianochords),function(t) return TA(t):Do(noteToNumber)end),
	dur = 6,
	amp = LOOP{0.15,0.1}*0.5*3,
	strum = LOOP{0.2,0.1} ,--0.25,
	zb =2
}

-- whole piano sequence
pianophr = LS{PS(chordseq),
	LS{SF(LS(pianochords),Arpeg(0))}:rep(2),
	LS{SF(LS(pianochords),Arpeg(12))}:rep(1),
	LS{SF(LS(pianochords),Arpeg(0,1))}:rep(3),
	LS{SF(LS(pianochords),Arpeg(12))}:rep(1),
	PS(chordseq)}

piano = OscEP{inst="help_oteypiano",sends={0.0,0.7},channel={level=db2amp(-6)}}:Bind(pianophr)
piano.inserts = {{"soundboard"},{"early27piano"}}

-------------------------------------------------------------------------
--DiskOutBuffer("clarinetQuintetxxx.wav")
Effects={FX("gverb",db2amp(-5)),FX("resonDWG",db2amp(0.77),nil)}

theMetro:play(120)
theMetro:start()