
--------------------------------synths
SynthDef("KarplusMiniArp",{freq=440,amp = 1,decay = 10,pan=0,coef=0.9 ,coef2=Ref{-0.6},out=0,gate=1,excit=0.1,L1=1,L2=4,L3=1,freqR1=1800,wideF1=0.73,freqR2=826,wideF2=0.8,freqR3=1750,wideF3=0.3,delayComp=-0},function ()

	local signal = Decay2.ar(Impulse.ar(0),0.01, excit, PinkNoise.ar(amp));
	local freqreciprocal=freq:reciprocal()+delayComp/44100
	local coefi=LinExp.kr(amp:clip(0,1),0,1,0.9,LinExp.kr(freq,50,1000,coef,0.2*coef))--:clip(0.3,0.999)
	CheckBadValues.ar(signal,9)
	--signal = Karplus.ar(signal, 1, freqreciprocal, freqreciprocal, 9, 0,{-coefi},{1-coefi})
	--signal = Pluck.ar(signal, 1, freqreciprocal, freqreciprocal, 9, coefi)
	signal = DWGPluckedStiff.ar(freq, amp, 1, nil,nil,300, signal)*0.2
	CheckBadValues.ar(signal,10)
	signal = Sanitize.ar(signal,0) -- cant repair Karplus so...
	signal=LeakDC.ar(signal)
	signal = Mix{
				RLPF.ar(signal,freqR1,wideF1)*L1,
				Resonz.ar(signal,freqR2,wideF2)*L2,
				RHPF.ar(signal,freqR3,wideF3)*L3
			}

	CheckBadValues.ar(signal,11)
	signal=signal*EnvGen.kr(Env.perc(0.01,decay,amp),gate,nil,nil,nil,2);
	
	DetectSilence.ar(signal,0.001,0.1,2);
	signal = Pan2.ar(signal,pan);
	CheckBadValues.ar(signal,12)
	return Out.ar(out, signal); 
end):store()

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

KLF = TA{517,525,1441,2636,2651,4090,4103,2062,2065,2314,3130,3124,4534,4456,3954,4011,2582,3559,4110,4192,5189,4949,5698,5713,6421,6567}/517
KLF = KLF:sort()
KLA = TA():Fill(#KLF,1/#KLF)
KLR = TA():gseries(#KLF,15,0.9)


SynthDef("korean_bell", {out = 0,fattack=6000,attack=0.0,decay=25, freq = 144, pan = 0,amp=1.0,klf = Ref(KLF),kla=Ref(KLA),klr=Ref(KLR)}, function()
	local e2 = EnvGen.kr(Env.perc(attack, decay, amp, -4),nil,nil,nil,nil,2);
	local signal = Decay.ar(Impulse.ar(0), 0.01, WhiteNoise.ar(1))--LPF.ar(WhiteNoise.ar(1),fattack));
	local coef = (0.1/(math.exp(1)-1))*(amp:exp() - 1)
	coef = coef:min(0.1)
	signal = FOS.ar(signal,0.01+coef,0,0.999-coef)
	signal = Klank.ar(Ref{klf, kla, klr},	signal*e2, freq,0)--,freq:linlin(100,5000,1.5,0.03))
	DetectSilence.ar(signal,0.0005,0.1,2);
	CheckBadValues.ar(signal,25)
	Out.ar(out, Pan2.ar(Mix(signal), pan));
end):store()

SynthDef("dwgreverb", { busin=0, busout=0,predelay=0.1,c1=4,c3=4,len=1200,mix = 1},function()
	local source=Mix(In.ar(busin,2)); 
	source = DelayC.ar(source,0.5,predelay)
	source = DWGReverbC1C3_16.ar(source,len,c1,c3,mix)	
	ReplaceOut.ar(busout,source)
end):store();

SynthDef("gverb",{gate = 1.0,busout=0,roomsize=50,revtime=3,damping=0.4,
		inputbw=0.4,spread= 15,drylevel=0,earlylevel= 0.35,taillevel= 0.25,maxroomsize=300},
		function()
			local inp = Mix(In.ar(busout, 2))
			local sig = GVerb.ar(inp, roomsize, revtime, damping, inputbw, spread, drylevel, earlylevel, taillevel, maxroomsize)
			ReplaceOut.ar(busout,sig)
end):store()
