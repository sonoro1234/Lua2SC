--this has to be executed at least once
--for compiling essential SynthDefs
require("sc.Compilesynth")

----------------- one extra synthdef
SynthDef("PPongF", {gate=1,busin=0, busout=0,ffreq=1500,rq=0.4, fdback=0.25,delaytime=0.5,volumen=2,bypass=0},function()
	local input, effect;
	input=In.ar(busin,2); 
	input= input + fdback*LocalIn.ar(2);
	input=Resonz.ar(input,ffreq,rq)
	effect= DelayN.ar(input,delaytime,delaytime-ControlDur.ir());
	effect = {effect[2],effect[1]}
	LocalOut.ar(effect)
	Out.ar(busout,Select.ar(bypass,{effect *volumen,Silent.ar(2)}))
end):store()

------------- define some players, master effects 
-- a bass
bass = OscEP{inst="plukV",sends={db2amp(-24)},channel={level=db2amp(-3)}}

-- solo instrument with one insert
solo = OscEP{inst="plukV",sends={db2amp(-10)}}
solo.inserts = {{"PPongF",{bypass=0,volumen=0.95,ffreq=1000,rq=1, fdback=0.5,delaytime=BeatTime(4)}}}

-- a shaker
shaker = OscEP({inst="shaker",sends={db2amp(-20)},channel={level=db2amp(-30)}})

--master effects used with sends in players
Effects={FX("gverb",db2amp(0),nil,{revtime=5,roomsize=100})}

--master section with two inserts
MASTER{level=db2amp(3)}
Master.inserts={
				{"Compander",{slopeAbove=1/3,bypass=0}},
				{"Limiter",{thresh=3,bypass=1}},
			}


---------------------- some patterns
basspat = PS{
	escale = {modes.aeolian},
	degree = LOOP{1,3,RS{5,6},1,3,5-7} + 7*3,
	dur = LOOP{1.5,1.5,1},
	coef = 0.9,
	pan = -0.25
}

solopat = PS{
	escale = {modes.aeolian},
	degree = LOOP{3,2,1,2,1,0,1,0,-1,-2} + 7*6,
	dur = LOOP{1.5,1.5,1}* LS{LS{0.5}:rep(21),LS{0.25}:rep(6)},
	amp = noisefStream{0.6,0.9},
	pan = RSinf{0.5,-0.5}
}

shakerpat = PS{
	note=70,
	velo=LOOP{1,0.2,0.2,0.2,0.5,0.2,0.2,0.2},
	density=LOOP{4000,2000,2000,2000},
	attack=LOOP{0,0.2,0.05,0.2,0.05,0.2,0.05,0.2},
	decay=0.2,
	pan=0,
	dur=0.5
}
---------------------- theme -----------------
solo:Bind(LS{
	solopat,  
	DONOP(12), --wait for 12 beats
	solopat,
	SETEv"bass_start", -- start bass setting "bass_start"
	solopat,
	SETEv"shaker", -- start shaker
	DONOP(16),
	LS{solopat}:rep(3), --repeat pattern 3 times
	DONOP(16),
	solopat
})

bass:Bind(LS{WAITEv"bass_start",basspat})		

shaker:Bind(LS{WAITEv"shaker",shakerpat})

---- some midi input			
instgui = InstrumentsGUI("plukV")
MidiToOsc.AddChannel(0,instgui,{0.2})

-- a FreqScope
FScope()

-- uncoment to record to file (will be in SuperCollider folder)
-- DiskOutBuffer("simple_theme.wav")

-- set tempo and start playing
theMetro:tempo(130)
theMetro:start()
