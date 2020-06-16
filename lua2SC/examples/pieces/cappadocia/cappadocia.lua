RANDOM:seed(17) --for getting the same piece always we seed it with fixed number
-------------------------first the SynthDefs------------------------------
-- we will getting requiring a lua file with synthdefs in this script folder
-- and call sync for waiting to async complete
path = require"sc.path"
path.require_here()
require"synthdefs"
Sync()
------------------------- now some players--------------------------------
-------- tambour player
-- live recorded with MIDIRecord

tambour = OscEP{inst = "tambour" ,dontfree=true,sends={0.1},channel={level=db2amp(-9)}}:Bind(LOOP{PS{

	note = LS{REST,52,59,59,40,59,59, 52,59,59,40,59,59,52,59, 52,59,59,40,59,59, 52,59,59,40,59,59,52,59, 45,57,57,52,57,57,45,57,57,52,57,57,45,57,52,57,57,45,57,57,52,57,57,45,57,57,52,57,} + {0,12},
	detune = {1,1.003},
	amp = LS{0,0.60629921259843,0.60629921259843,0.73228346456693,0.48818897637795,0.73228346456693,0.4251968503937,0.85826771653543,0.47244094488189,0.60629921259843,0.60629921259843,0.47244094488189,0.55905511811024,0.91338582677165,0.62992125984252,0.50393700787402,0.50393700787402,0.55905511811024,0.50393700787402,0.50393700787402,0.41732283464567,0.62992125984252,0.53543307086614,0.50393700787402,0.53543307086614,0.53543307086614,0.55905511811024,0.81102362204724,0.62992125984252,0.76377952755906,0.58267716535433,0.85826771653543,0.66141732283465,0.55905511811024,0.48818897637795,0.73228346456693,0.47244094488189,0.62992125984252,0.47244094488189,0.58267716535433,0.60629921259843,0.40157480314961,0.73228346456693,0.60629921259843,0.47244094488189,0.58267716535433,0.62992125984252,0.50393700787402,0.51968503937008,0.53543307086614,0.58267716535433,0.62992125984252,0.73228346456693,0.60629921259843,0.69291338582677,0.76377952755906,0.69291338582677,} * {1,0.7},
	delta = Quant(0.5,LS{0.066666364669802,0.50000031789144,0.48333326975504,0.51666657129923,0.43333331743876,1.0833334922791,0.54999987284342,0.9333332379659,0.44999996821086,0.51666696866353,0.48333326975504,0.48333326975504,0.51666657129923,0.46666661898295,0.46666661898295,0.58333357175192,0.46666661898295,0.51666657129924,0.46666661898295,1.0333335399628,0.53333322207133,0.98333319028219,0.43333331743876,0.53333361943563,0.46666661898295,0.49999992052714,0.46666661898295,0.49999992052714,0.55000027020773,0.44999996821086,0.53333322207133,0.51666657129924,0.48333326975505,1.0000002384186,0.53333322207133,0.99999984105428,0.43333371480306,0.46666661898295,0.51666657129924,0.48333326975505,0.49999992052714,0.48333326975505,0.53333361943563,0.51666657129923,0.54999987284342,0.44999996821085,0.51666696866353,0.99999984105428,0.54999987284342,0.95000028610229,0.49999992052714,0.48333326975504,0.49999992052714,0.49999992052714,0.48333326975504,0.55000027020772,0.53333338101706,}),
	dur = LS{0,0.36666671435038,0.24999976158142,0.46666661898295,0.35000006357829,0.33333341280619,0.54999987284342,0.3166667620341,0.18333355585734,0.48333326975504,0.40000001589457,0.21666646003723,0.49999992052714,0.300000111262,0.40000001589457,0.38333336512248,0.21666646003723,0.49999992052714,0.28333346048991,0.33333341280619,0.49999992052714,0.28333346048991,0.20000020662944,0.53333361943563,0.46666661898295,0.21666646003723,0.51666657129924,0.38333336512248,0.6166668732961,0.36666671435038,0.24999976158142,0.51666657129924,0.43333331743876,0.28333346048991,0.56666652361552,0.33333341280619,0.20000020662944,0.49999992052714,0.34999966621399,0.21666646003723,0.53333322207133,0.38333336512248,0.56666692097982,0.28333306312561,0.23333311080933,0.46666661898295,0.28333346048991,0.3166663646698,0.58333317438761,0.26666680971781,0.21666646003723,0.43333331743876,0.28333346048991,0.20000020662943,0.51666696866353,0.33333341280619,0.18333315849304,},
	c1 = 2,
	c3 = 6,
	pos = noisefStream{0.05,0.15},
	mistune = 2,
	gc = 30,
	pan = brownSt(-0.5,0.5,0.1),
}	})
tambour.inserts = {{"BPeakEQ",{db=-16,freqEQ=700,rq=0.24}}}

-- three more tambours making rythmic pattern
tam2 = OscEP{inst = "tambour2" ,dontfree=true,sends={0.1},channel={level=db2amp(-3)}}:Bind{
	note = 64 + RSinf{12,0},
	dur = LOOP{2,1}*2/3,
	amp = noisefStream{0.3,0.7}*0.5,
	pos = noisefStream{0.05,0.15},
	pan = -1, --LOOP{-1,0,1}
}
tam2.inserts = {{"BPeakEQ",{db=-22,freqEQ=700,rq=0.24}}}

tam3 = OscEP{inst = "tambour2" ,dontfree=true,sends={0.1},channel={level=db2amp(-3)}}:Bind{
	note = 59 + 12 + LOOP{12,0,0,12},
	dur = LOOP{2+3+3,1}/3,
	amp = 0.5,
	pos = noisefStream{0.05,0.15},
	pan = 1, --LOOP{1,0,-1}
}
tam3.inserts = {{"BPeakEQ",{db=-22,freqEQ=700,rq=0.24}}}

tam4 = OscEP{inst = "tambour2" ,dontfree=true,sends={0.1},channel={level=db2amp(-3)}}:Bind{
	note = 59 + 15 + LOOP{12,0,0,12},
	dur = 1.5,
	amp = 0.5,
	pos = noisefStream{0.05,0.15},
	pan = 0, --LOOP{0,1,-1}
}
tam4.inserts = {{"BPeakEQ",{db=-22,freqEQ=700,rq=0.24}}}

------------ framedrum player with two seqs
framedrum = OscEP{inst = "framedrum" ,dontfree=true,sends={0.1},channel={level=db2amp(-12)}}:Bind{
	note = 45,
	dur = RSinf{9+10,0.5},
	amp = 0.5,
	pan = 0
}
framedrum2 = {
	amp = 0.5,
	note = LOOP{45,45,45}+7,
	dur = LOOP{0.5,1+0.5,1+1},
	decayf = 0.25
}
-------------------- clarinet ---------------------------
-- three phrases and player
-- first phrase 
frase1 = {
	note = LOOP{64,67,69,71,69,67,64,67,REST}+RSinf{LS{12}:rep(9),LS{-12}:rep(9),LS{0}:rep(9)},
	dur = LS{LS{0.5}:rep(8+9),25}, 
	amp = noisefStream{0.6,0.9},
	pan = brownSt(-1,1,0.1),
	ampvibu = 0.005
	
}
-- the same as phrase 1 with more vibrato
frase1b = deepcopy(frase1)
frase1b.ampvibu = 0.05
-- phrase 2
frase2 = {
	note = LS{71,74,72.5,74,71,69,71,71,REST}+RSinf{LS{-12}:rep(9),LS{0}:rep(9)},
	dur = LOOP{RS(TA():series(3,3.5,0.5),8),80}*0.5,
	amp = noisefStream{0.6,0.9},
	pan = brownSt(-1,1,0.1),
	ampvibu = 0.005
}

-- third phrase is markov learned from this sequence
clariseq = TA{64,67,69,71,69,67,64,67,71,74,72.5,74,71,69,71,71,72.5,74,76,72.5,74,72.5,71,69,71,76,78,76,74,72.5,71}-12
-- 64 66 67 69 71 72.5 74 76
-- 0  2   3  5  7  8.5 10 12
-- learn as a third order markov sequence
mark2=MarkovLearnO(clariseq,3)

frase3=LOOP{PS{
	note = LS{MarkSO(mark2)},
	dur = RS({LS{0.25}:rep(4),2,LS{0.5}:rep(2),LS{1/3}:rep(6)}):rep(LOOP{7,7,14})*1,
	amp = noisefStream{0.6,0.9} ,
	legato = WRS({1,0.8},{6,1},-1),
	pan = brownSt(-1,1,0.1),---0.5,
	ampvibu = 0.005
},PS{
		note = LS{REST},
		dur = 16
	}}

-- clarinet player
clarinet = OscEP{inst = "clarinet" ,mono=true,sends={db2amp(-7)},channel={level=db2amp(-9)}}:Bind(LOOP{PS(frase1),PS(frase2)})

clarinet.inserts = {{"BLowShelf",{freqEQ=300,db=-21}},{"PPongF",{volumen=0.97,ffreq=1000,rq=1, fdback=0.85,delaytime=BeatTime(4)}}}

------------- soprano ---------------------------------------
require("sc.Phonemes")
voz = "soprano"
-- phrase notes came from already learnt clarinet markov sequence and rest for 16 beats
sfrase3 = LOOP{PS{
	note = LS{MarkSO(mark2)},
	dur = RS({LS{0.25}:rep(4),2,LS{0.5}:rep(2),LS{1/3}:rep(6)}):rep(LOOP{7,7,14})*1,
	amp = noisefStream{0.6,0.9} ,
	legato = WRS({1,0.8},{6,1},-1),
	pan = brownSt(-0.5,0.5,0.1),---0.5,
	[{"f","a","q"}]=LS(Formants:paramsPalabra({voz.."A",voz.."E",voz.."I",voz.."O",voz.."A",voz.."E",voz.."I",voz.."O",voz.."U"}),-1),
	
},PS{
		note = LS{REST},
		dur = 16
	}}

-- soprano player
soprano = OscEP{inst = "formantVoice2",sends={db2amp(-7)},channel={level=db2amp(-13)}}:Bind(LOOP{PS(sfrase3)})

soprano.inserts = {{"BLowShelf",{freqEQ=300,db=-12}},{"BHiShelf",{bypass=0,db=10,freqEQ=5000,rs=2}},{"PPongF",{bypass=0,volumen=0.95,ffreq=1000,rq=1, fdback=0.9,delaytime=BeatTime(6)}}}

------------------------------bowed chords ----------------------
bowed = OscEP{inst = "bowed" ,sends={0.3},channel={level=db2amp(-7)}}:Bind{
	note = LOOP{{40,52,59},{45,52,57}}-12,
	dur = 16,
	amp = 1,
	pan = {-1,0,1}
}
bowed.inserts = {{"bowsoundboard"}}

------------------------ cbass player --------------------------------
bass = OscEP{inst = "cbass" ,sends={0},channel={level=db2amp(-0)}}:Bind{
	note = LOOP{52,REST,52,REST,59,52,LSS({40,45},-1),52,REST, 52,REST,52,REST,59,52,LSS({40,45},-1),52,REST,50,52},
	dur = LOOP{0.25,1.25,0.5,1,0.5,0.5,1.5,0.5,2, 0.25,1.25,0.5,1,0.5,0.5,1.5,0.5,1,0.5,0.5}
}
--------------------------- Shaker -----------------
shaker=OscEP({inst="shaker",sends={db2amp(-20)},channel={level=db2amp(-30)}})
shaker:Bind{
	note=70,
	velo=LOOP{0.2,0.2,0.2,1,0.5,0.2,1,0.5},
	density=LOOP{4000,2000,2000,2000},
	attack=LOOP{0.05,0.2,0.05,0,0.05,0.2,0.0,0.2},
	decay=0.2,
	pan=0,
	dur=0.5,
	}
------------ actions to control structure
actioncue=ActionEP()
actioncue:Bind{
	actions=LS{
		STOP(-4,unpack(OSCPlayers)),
		START(0,tambour),
		START(40,clarinet),
		STOP(64,tambour),
		START(64,tam2,tam3,tam4),
		START(96,tambour),
		START(32*5,framedrum),
		START(32*7,bowed),
		BINDSTART(32*7,clarinet,frase3),
		STOP(32*8,tambour,bowed),
		START(32*10,tambour,bowed,bass,shaker),
		BINDSTART(32*10,framedrum,framedrum2),
		START(32*10 +4,soprano),
		SENDINSERT(32*10 +4,soprano,3,"bypass",1),
		BINDSTART(32*12,clarinet,LOOP{PS(frase1b)}),
		START(32*12+16,clarinet),
		START(32*13,clarinet),
		START(32*13+16,clarinet),
		STOP(32*14,unpack(OSCPlayers)),
		START(32*14,tambour,soprano),
		SENDINSERT(32*14,soprano,3,"bypass",0),
		START(32*18,tam2,tam3,tam4),
		START(32*19,bass,shaker,framedrum,clarinet),
		START(32*20,bowed),
		--linear on db
		ACTION(770,fadeout,770,770+80,unpack(OSCPlayers)),
		--linear on amplitude
		--FADEOUT(770,770+30,unpack(OSCPlayers))
	}
}

--------------- master section
Master.inserts={
				{"Compander",{slopeAbove=.67,thresh=-25,bypass=0}},
				{"Limiter",{thresh=-3,bypass=0}},
			}
Effects={FX("gverb",db2amp(-0),nil,{revtime=5,roomsize=100})}
--DiskOutBuffer([[cappadocia.wav]])
--FreqScope()
theMetro:tempo(120)
theMetro:start()
