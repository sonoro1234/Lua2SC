--this has to be executed at least once
--for compiling essential SynthDefs
require("sc.Compilesynth")


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

bass = OscEP{inst="plukV",sends={db2amp(-24)}}:Bind{
	escale = {modes.aeolian},
	degree = LOOP{1,3,RS{5,6}} + 7*3,
	dur = LOOP{1.5,1.5,1},
	coef = 0.9,
	pan = -0.25
}

solo = OscEP{inst="plukV",sends={db2amp(-10)}}:Bind{
	escale = {modes.aeolian},
	degree = LOOP{3,2,1,2,1,0,1,0,-1,-2} + 7*6,
	dur = LOOP{1.5,1.5,1}* LOOP{LS{0.5}:rep(16),LS{0.25}:rep(4)},
	amp = noisefStream{0.6,0.9},
	pan = RSinf{0.5,-0.5}
}
solo.inserts = {{"PPongF",{bypass=0,volumen=0.95,ffreq=1000,rq=1, fdback=0.9,delaytime=BeatTime(4)}}}

Effects={FX("gverb",db2amp(0),nil,{revtime=5,roomsize=100})}
Master.inserts={
				{"Compander",{slopeAbove=1/3,bypass=0}},
				{"Limiter",{thresh=3,bypass=1}},
			}
FreqScope()

theMetro:start()