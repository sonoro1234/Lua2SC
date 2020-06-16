require"sc.Compilesynth" -- has some common synthdefs

SynthDef("formantVoice2", {out=0, gate=1, freq=60, amp=0.3,pan=0, voiceGain=1.0, noiseGain=0.0,sweepRate=0.01},function ()
	local f = Control.names({'f'}).kr(Ref{ 400, 750, 2400, 2600, 2900 });
	local q = Control.names({'q'}).kr(Ref{ 0.1, 0.10666666666667, 0.041666666666667,0.046153846153846, 0.041379310344828 });
	local a = Control.names({'a'}).kr(Ref{ 1, 0.28183829312645, 0.089125093813375, 0.1, 0.01 });
	local env=EnvGen.ar(Env.asr(0.1, 1.0, 0.1), gate, nil,nil,nil,2);
	local filters,filter,freqlag;
	local vibrato = SinOsc.kr(4,Rand(0,2*math.pi));
	freqlag=Lag.kr(freq,sweepRate*0.1);
	filters = Formant.ar(freqlag+vibrato, Lag.kr(f, sweepRate), Lag.kr(f*q, sweepRate), Lag.kr(a, sweepRate));
	filter=HPF.ar(Mix(filters),200)*env*4;
	return Out.ar(out, Pan2.ar(amp*filter,pan,amp ));
end):store()

local path = require"sc.path"
local this_file_path = path.file_path()
ccc=FileBuffer(this_file_path..[[\dbexcite.wav]])

SynthDef("cbass", { fnoise=3500,out=0, freq=440, amp=0.5, gate=1,pos=1-1/7,c1=0.3,c3=200,mistune = 4,mp=0.55,gc=10,wfreq=20000,release=0.2,pan=0},function()
	local wide2 = 0.006 --LinExp.kr(amp,0,1,0.006,0.0001) 
	local pre = 1 --LinExp.kr(amp,0,1,1,0.0001) - 0.5
	local env = Env.new({0,pre, 1, 0}, TA{0.001,wide2, 0.0005}*1,{5,-5, -8});
	fnoise = LinExp.kr(amp,0,1,1600,16000)
	local inp = PlayBuf.ar(1, ccc.buffnum, BufRateScale.kr(ccc.buffnum),gate,0 ,0)*amp
	wfreq = LinExp.kr(amp,40/127,1,1000,20000)
	inp = LPF.ar(inp,wfreq)
	local son = DWGPlucked.ar(freq, amp, gate,pos,c1,c3,inp,release)
	son = son * EnvGen.ar(Env.perc(0,0.6),gate)
	DetectSilence.ar(son, 0.001,nil,2);
	Out.ar(out, Pan2.ar(Mix(son*0.3) ,pan));
end):store();

SynthDef("plukVm",{freq=440,amp = 1,decay = 10,pan=0,coef=0.6 ,out=0,gate=1,excit=0.1},
	function ()
		local signal = Decay.ar(Impulse.ar(0), excit, PinkNoise.ar(amp));
		CheckBadValues.ar(signal,15)
		local freqreciprocal=freq:reciprocal()
		signal = Pluck.ar(signal, 1, freqreciprocal, freqreciprocal, 9, LinExp.kr(amp,0,1,0.9,LinExp.kr(freq,50,1000,coef,0.2*coef)))
		CheckBadValues.ar(signal,16)
		signal=signal*EnvGen.kr(Env.perc(0.01,decay,amp),gate,nil,nil,nil,2);
		--DetectSilence.ar(signal)
		signal=LeakDC.ar(signal)
		DetectSilence.ar(signal,0.001,0.1,2);
		CheckBadValues.ar(signal,13)

		return Out.ar(out, signal); 
end):store()

SynthDef("early",{busout=0,fac=5,mix=1,lat=0,ff=6000,bypass=0},function()
	local sin = In.ar(busout,2)
	local s = Mix(sin)*0.5 --Resonz.ar(Impulse.ar(1), 2000 , 0.3)*3
	local z = {2,3,5,7,11,13,17}*fac*(1-lat)
	z = z:Do(function(v) return DelayC.ar(s, 0.2,v/1000)*z[1]/v end) --*z[1]/v
	z = Mix(z)
	local z2 = {2,3,5,7,11,13,17}*fac*(1+lat)
	z2 = z2:Do(function(v) return DelayC.ar(s, 0.2,v/1000)*z2[1]/v end) --*z2[1]/v
	z2 = Mix(z2)
	local effect = LPF.ar({z,z2},ff)*mix + sin
	ReplaceOut.ar(busout,Select.ar(bypass,{effect,sin}) )
end):store()




