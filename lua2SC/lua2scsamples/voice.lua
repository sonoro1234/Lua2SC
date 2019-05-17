

SynthDef("dwgreverb", { busin=0, busout=0,predelay=0.1,c1=4,c3=4,len=1200,mix = 1},function()
	local source=Mix(In.ar(busin,2)); 
	source = DelayC.ar(source,0.5,predelay)
	source = DWGReverbC1C3_16.ar(source,len,c1,c3,mix)	
	ReplaceOut.ar(busout,source)
end):store(true);

------------------------------------------------------------------
-- scale with non tempered tunning
escale = newScale({0,1.82,3.86,5.9,7,9.96,10.88}) +2

-- some control bus envelopes to move the pitch
m1 = ENVdeg({-1,-1,0,0},{0.3,0.1,0.6})
m2 = ENVdeg({0,0,1,0},{0.5,0.25,0.25})
m1b = ENVdeg({0,0,-5},{0.9,0.1})
m0 = getdegree

-- what we are going to speak
local phrase = "KO-RI-NI-LA_-ME-SU-NE-Mv-KO-RI-NI-LA-_v"

-- two different modules for speaking
--TT2 = require"num.ParametricTract"(26,14.3)
TT2 = require"num.vocaltractB"(26,false,true) --26 tubes, female, oversampled

-- the player
she = OscEP{inst=TT2.sinteRdO2.name,mono=true,sends={db2amp(-8)},channel={level=db2amp(-5)}}

-- talking part of pattern, must go in second table of main PS to get acces to dur parameter
talkpat = LOOP(PS(TT2:Talk(phrase)))

-- the whole pattern
shepat = PS({
	dur = LOOP{LS{2}:rep(11),6,4},
	escale = {escale},
	degree = LS{5,6,8,8,5,4,3,4,5,4,2,1,1,
				5,6,8,8,8,6,5,4,5,4,6,5,1,
				LS{2,2,3,2,1,0,1,2,3,2,1,1,1}:rep(2)} + 7*5,
	freq = LOOP{LS{m1,m0}:rep(5),m1,LSS{m1b,m1b},m0}, -- comment and glissando disapear
	Rd= LOOP{ENVr({0.5,0.5,0.7},{0,1}), 0.5, 0.5, ENVr({0.5,0.4},{1}), LS{0.4}:rep(7), ENVr({0.4,0.4,1.9},{0.9,0.1}),0.8} * 1.5, -- this modulates the strenght of glottal impulse
	namp = 0.2, -- noise amplitude
	amp = 0.6,
	thlev = 0.5, -- throat component amplitude
	fA = 0.95, -- lenght factor
	vibdelay = beats2Time(1), -- delay vibrato 1 beat
	vibdepth = LOOP{0,0.005,0.015,0.005,0.01,0.01,0.015,0.005,0.00,0.005,0.015,0.01,0},
},talkpat)

-- bind the pattern
she:Bind(shepat)

--- set master section
MASTER{level=db2amp(-8)}
Effects={FX("dwgreverb",db2amp(0),nil,{c1=1.5,c3=16,len=5000,predelay=0.1})}

--set tempo and start playing
theMetro:tempo(105)
theMetro:start()