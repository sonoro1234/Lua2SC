

---------------------------------
local presets = {
---[[
----------TAMB
tambourine = {
GAIN =5,
SOUND_DECAY = 0.95;
SYSTEM_DECAY = 0.9985;
objects = 32,
freqs = {2300,5600,8100},
freq_rand = TA{0,0.05,0.05},
amps = TA{0.1,0.8,1} ,
RESON = {0.96,0.99,0.99},
Zeros = {1.0,0.0,-1.0}
},
--]]
--------------------------------------------
---[[
-- Sleighbells
cascabeles = {
SOUND_DECAY = 0.97;
SYSTEM_DECAY = 0.9994;
GAIN = 1.0;
objects = 33;
freqs = {2500,5300,6500,8300,9800},
freq_rand = TA():Fill(5,0.03),
amps = TA{1,1,1,0.5,0.3} ,
RESON = TA():Fill(5,0.99);
Zeros = {1.0,0.0,-1.0}
},
--]]
---[[cascabeles
cascabeles2={
GAIN = 0.1,
SOUND_DECAY = 0.99;
SYSTEM_DECAY = 0.9999;
objects = 10;
freqs = TA{2.7,5.2,8.4,12.2}*1500,
freq_rand = TA():Fill(4,0.01),
amps =TA{0.3,0.3,0.2,0.1};
RESON = TA():Fill(4,0.9995);
Zeros = {1.0,0.0,-1.0}
},
--]]
Maraca = {
SOUND_DECAY = 0.95;
SYSTEM_DECAY = 0.999;
GAIN = 20.0;
objects = 25;
freqs = {3200.0};
RESON = {0.96};
Zeros ={1.0, -1.0, 0.0}
},
Sekere = {
SOUND_DECAY = 0.96;
SYSTEM_DECAY = 0.999;
GAIN = 20.0;
objects = 64;
freqs = {5500.0},
RESON = {0.6};
Zeros ={1.0, 0.0, -1.0}},

Sandpaper ={
SOUND_DECAY = 0.999;
SYSTEM_DECAY = 0.999;
GAIN = 0.5;
objects = 128;
freqs = {4500.0};
RESON = {0.6};
Zeros = {1.0,0.0,-1.0}},

Cabasa = {
SOUND_DECAY = 0.96;
SYSTEM_DECAY = 0.997;
GAIN = 40.0;
objects = 512;
freqs = {3000.0};
RESON = {0.7};
Zeros = {1.0,-1.0,0.0}},

Bamboo ={
SOUND_DECAY = 0.95;
SYSTEM_DECAY = 0.9999;
GAIN = 2.0;
objects = 1.25;
freqs = TA{1,0.8,1.2}*2800;
freq_rand = TA():Fill(3,0.2),
RESON	= TA():Fill(3,0.995);},

Stix1 = {
SOUND_DECAY = 0.96;
SYSTEM_DECAY = 0.998;
GAIN = 30.0;
objects = 2;
freqs = {5500.0};
RESON = {0.6};
Zeros = {1.0,0.0,-1.0}},

Crunch1 = {
SOUND_DECAY = 0.95;
SYSTEM_DECAY = 0.99806;
GAIN = 20.0;
objects = 7;
freqs = {800.0};
RESON = {0.95};
Zeros = {1.0,-1.0,0.0}},

Claps = {
SOUND_DECAY = 0.95;
SYSTEM_DECAY = 0.99806;
GAIN = 20.0;
objects = 7;
freqs = {800.0,1000,1200};
RESON = {0.95,0.95,0.95};
Zeros = {1.0,-1.0,0.0}},
}

---------------------------------------------
local function coef2t60(coef,fs)
	local fs = fs or 44100
	return math.log(0.001)/math.log(coef)/fs
end
local function radio2t60(radio,fs)
	local fs = fs or 44100
	return math.log(1000)/fs/(1-radio)
end
local function makeShynthFromPreset(t)
	local res = {}
	res.GAIN = t.GAIN
	res.objects = t.objects
	res.freqs = t.freqs
	res.amps = t.amps or TA():Fill(#t.freqs,1)
	res.sys_dec = coef2t60(t.SYSTEM_DECAY)
	res.sound_dec = coef2t60(t.SOUND_DECAY)
	res.decays = TA(t.RESON):Do(radio2t60)
	res.freq_rand = t.freq_rand and TA(t.freq_rand) or TA():Fill(#t.freqs,0)
	res.Zeros = t.Zeros or {1,0,0}
	return res
end

local PhISEM = {}
PhISEM.presets = presets 
function PhISEM:list_presets()
	for k,v in pairs(self.presets) do
		print(k)
	end
end
function PhISEM:MakeSynth(name,preset)
	preset = preset or name
	local t = makeShynthFromPreset(self.presets[preset])
--------------------------------------
---[[
	SynthDef(name, {out = 0,gate=1,ffac = 1,pan = 0,amp=0.1,
freqs=Ref(t.freqs),sys_dec=t.sys_dec,sound_dec=t.sound_dec,amps=Ref(t.amps),decays=Ref(t.decays),f_rand=Ref(t.freq_rand),objects=t.objects,GAIN=t.GAIN,Zeros=Ref(t.Zeros)}, function()
	local objectsm = objects:max(2)
	--local pulses = Dust.ar(objects*43, 1)
	local pulses = Dust.ar(objectsm*43, 1):sign()
	--local pulses =	Changed.ar(LFClipNoise.ar(22000))
	--local pulses = Impulse.ar(1)
	
	local G = GAIN * objectsm:log()/objectsm
	local energy = Decay.ar(Impulse.ar(0),sys_dec)*amp*G
	local sysdriver = pulses*energy
	--local driver = WhiteNoise.ar(1)*Integrator.ar(sysdriver,sound_dec)
	local driver = WhiteNoise.ar(1)*Decay.ar(sysdriver,sound_dec)
	--local freqs2 = freqs * (1.0 + Gate.ar((freq_rand * TA{WhiteNoise.ar()}),pulses))
	local freqs2 = ffac*freqs *  (1 + TRand.ar( -f_rand, f_rand, pulses))
	local signal = Mix(Ringz.ar(driver,freqs2,decays,amps))
	--local e2 = EnvGen.kr(Env.asr(attack, 0.5, 0.1),gate,nil,nil,nil,2);
	--signal = sysdriver
	signal = SOS.ar(signal,Zeros[1],Zeros[2],Zeros[3],0,0)
	DetectSilence.ar(signal,0.001,0.1,2);
	Out.ar(out, Pan2.ar(signal, pan));
	-----------
end):store(true)
end

--]]
--[[
bands = 100
sinte=SynthDef("alambres", {out = 0,gate=1,t_gate=1,fdecay=1 ,freq = 400,pan = 0,amp=0.1,
sys_dec=0.2,sound_dec=0.1,objects=32,GAIN=1}, function()

	local objectsm = objects:max(2)
	--local pulses = Dust.ar(objects*43, 1)
	local pulses = Dust.ar(objectsm*43, 1):sign()
	--local pulses =	Changed.ar(LFClipNoise.ar(22000))
	--local pulses = Impulse.ar(1)
	
	local G = GAIN * objectsm:log()/objectsm
	local energy = Decay.ar(Impulse.ar(0),sys_dec)*amp*G
	local sysdriver = pulses*energy
	--local driver = WhiteNoise.ar(1)*Integrator.ar(sysdriver,sound_dec)
	local driver = WhiteNoise.ar(amp)*Decay.ar(sysdriver,sound_dec)

	--local driver = EnvGen.ar(Env.perc(0,0,amp+0.5),t_gate)*WhiteNoise.ar()
	
	local freqs  = TA():Fill(bands,function() return exprandrng(300, 20000) end)
	local decays = TA():Fill(bands,fdecay)
	local amps = TA():Fill(bands,1/bands)
	local signal = Klank.ar(Ref{freqs,amps,decays},driver,freq/82)
	
	signal = SOS.ar(signal,1,0,-1,0,0)
	--local e2 = EnvGen.kr(Env.asr(attack, 1, 0.1),gate,nil,nil,nil,2);
	DetectSilence.ar(signal,0.001,0.1,2);
	Out.ar(out, Pan2.ar(signal, pan));
	-----------
end):store()
--]]

--[[
PhISEM:MakeSynth("cascabeles","cascabeles")
duras = TA{0.5,0.25,0.25,1,0.5,1,1,0.5,1,0.5,0.5,1.5,1}*4
player=OscEP{inst="cascabeles",mono=false,dontfree=true,sends={db2amp(-18)},channel={inst="channel",level=db2amp(-6)}}
player:Bind{
	--note=LOOP{LS{40}:rep(#duras-1),REST}, 
	--dur=LOOP(duras),
	dur = 1,
	velo=noisefStream{0.1,0.6},
	pan = 0,
	--objects = 7 --LOOP{LS{60}:rep(4),LS{7}:rep(4)}
}
--]]
-------------------------------------------------------------

--print("building synth: ",sinte.name)
--sinte:build()
--print("writing synth: ",sinte.name)
--sinte:writeDefFile()
--loadSynthDef(SynthDefs_path..sinte.name..".scsyndef",true)
--tt=readSCSynthFile(SynthDefs_path..sinte.name..".scsyndef")
--[[
sinte:dumpInputs()
sinte:makeDefStr()
tt=readSCSynthString(sinte.compiledStr)
prtable(tt)
--]]
--sinte:load()
--[[
Effects={FX("gverb")}
--EPinstGUI(player)
theMetro:play(120,-4,1)	
preset = "Claps"
PhISEM:MakeSynth(preset)	
local instGui = InstrumentsGUI(preset,false)
MidiToOsc.AddChannel(0,instGui,{0.0})

FreqScope()

--]]
return PhISEM	








