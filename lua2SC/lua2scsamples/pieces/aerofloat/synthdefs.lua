local bands = 100
sinte=SynthDef("alambres", {out = 0,gate=1,t_gate=1,fdecay=1 ,freq = 400,pan = 0,amp=0.1,
sys_dec=0.2,sound_dec=0.1,objects=32,GAIN=1}, function()

	local objectsm = objects:max(2)
	local pulses = Dust.ar(objectsm*43, 1):sign()
	
	local G = GAIN * objectsm:log()/objectsm
	local energy = Decay.ar(Impulse.ar(0),sys_dec)*amp*G
	local sysdriver = pulses*energy
	local driver = WhiteNoise.ar(amp)*Decay.ar(sysdriver,sound_dec)
	
	local freqs  = TA():Fill(bands,function() return exprandrng(300, 20000) end)
	local decays = TA():Fill(bands,fdecay)
	local amps = TA():Fill(bands,1/bands)
	local signal = Klank.ar(Ref{freqs,amps,decays},driver,freq/82)
	
	signal = SOS.ar(signal,1,0,-1,0,0)
	DetectSilence.ar(signal,0.001,0.1,2);
	CheckBadValues.ar(signal,21)
	Out.ar(out, Pan2.ar(signal*10, pan));
	-----------
end):store()


sinte=SynthDef("KarplusMiniArp",{freq=440,amp = 1,decay = 10,pan=0,coef=0.9 ,coef2=Ref{-0.6},out=0,gate=1,excit=0.1,L1=1,L2=4,L3=1,freqR1=1800,wideF1=0.73,freqR2=826,wideF2=0.8,freqR3=1750,wideF3=0.3,delayComp=-0},function ()

	local signal = Decay.ar(Impulse.ar(0), excit, PinkNoise.ar(amp));
	local freqreciprocal=freq:reciprocal()+delayComp/44100
	local coefi=LinExp.kr(amp,0,1,0.9,LinExp.kr(freq,50,1000,coef,0.2*coef))
	signal = Karplus.ar(signal, 1, freqreciprocal, freqreciprocal, 9, 0,{-coefi},{1-coefi})
	CheckBadValues.ar(signal,22)

	signal = Mix{RLPF.ar(signal,freqR1,wideF1)*L1,Resonz.ar(signal,freqR2,wideF2)*L2,RHPF.ar(signal,freqR3,wideF3)*L3}
	signal=signal*EnvGen.kr(Env.perc(0.0,decay,amp),gate,nil,nil,nil,2);
	signal=LeakDC.ar(signal)
	DetectSilence.ar(signal,0.001,0.1,2);
	CheckBadValues.ar(signal,23)
	signal = Pan2.ar(signal,pan);
	return Out.ar(out, signal*2); 
end):store()

SynthDef("sinpad", {out =0, amp = 0.125, gate = 1, envgendiv = 32, freq = 384, freqgap = 0.25, gdamp = 0.01,ffreq = 1000},function()
	local gd1			= Gendy1.kr{minfreq=0.1, maxfreq=10,mul= gdamp,add=1};
	local gd2			= Gendy1.kr{minfreq=0.1, maxfreq=10,mul= gdamp,add=1};
	local gd3			= Gendy1.kr{minfreq=0.1, maxfreq=10,mul= gdamp,add=1};
	local gd4			= Gendy1.kr{minfreq=0.1, maxfreq=10,mul= gdamp,add=1};
	local gd5			= Gendy1.kr{minfreq=0.1, maxfreq=10,mul= gdamp,add=1};
	local env			=		Env.asr(5, amp, 5);
	local envgen		=		EnvGen.kr{env,gate,doneAction = 2}
	local sin1		=		SinOsc.ar(freq  * gd1,nil,envgen / envgendiv);
	local sin2		= 		SinOsc.ar((freq + freqgap)  * gd2,nil, envgen / envgendiv);
	local sin3		=		SinOsc.ar((freq - freqgap)  * gd3,nil, envgen / envgendiv);
	local sin4		=		SinOsc.ar((freq + (freqgap * 2))  * gd4, nil,envgen / envgendiv);
	local sin5		=		SinOsc.ar((freq - (freqgap * 2))  * gd5, nil, envgen / envgendiv);
	local sinmix1		=		Mix(sin1 + sin2 + sin3)--sin1 + sin2 + sin3;
	local sinmix2		=		Mix(sin1 + sin4 + sin5)
	Out.ar(out, {sinmix1, sinmix2}) 
end):store();

SynthDef("sinpadF", {out =0, amp = 0.125, gate = 1, freq = 384, freqgap = 0.25, gdamp = 0.01,ffreq1 = 500,ffreq2 = 4000,fftime=2,rq=0.2,pw=0.5},function()
	local gd1			= Gendy1.kr{minfreq=0.1, maxfreq=10,mul= gdamp,add=1};
	local gd2			= Gendy1.kr{minfreq=0.1, maxfreq=10,mul= gdamp,add=1};
	local gd3			= Gendy1.kr{minfreq=0.1, maxfreq=10,mul= gdamp,add=1};
	local gd4			= Gendy1.kr{minfreq=0.1, maxfreq=10,mul= gdamp,add=1};
	local gd5			= Gendy1.kr{minfreq=0.1, maxfreq=10,mul= gdamp,add=1};
	local env			=		Env.asr(5, amp, 5);
	local envgen		=		EnvGen.kr{env,gate,doneAction = 2}/32
	local gen = Pulse
	local sinL = gen.ar({freq * gd1,(freq + freqgap)*gd2,(freq - freqgap)*gd3},pw,envgen);
	local sinR = gen.ar({freq * gd1,(freq + freqgap*2)*gd4,(freq - freqgap*2)*gd5},pw,envgen);
	local sinmix1		=		Mix(sinL)--sin1 + sin2 + sin3;
	local sinmix2		=		Mix(sinR)
	local filtered = RLPF.ar({sinmix1, sinmix2},XLine.kr(ffreq1,ffreq2,fftime),rq)
	Out.ar(out,Balance2.ar(filtered[1],filtered[2],SinOsc.kr(0.1,Rand(-math.pi,math.pi))));
end):store();

KLF = {1,2.7,5.2,8.4,12.2}
KLA ={0.1,0.3,0.3,0.2,0.1}
KLR ={4,0.5,0.5,0.3,0.3}
sinte=SynthDef("metalophon", {out = 0,fattack=6000,attack=0.0,decay=25, freq = 144, pan1 = 0,pan2=0,amp=1.0,klf = Ref(KLF),kla=Ref(KLA),klr=Ref(KLR)}, function()
	local e2 = EnvGen.kr(Env.perc(attack, decay, amp, -4),nil,nil,nil,nil,2);
	local signal = Decay.ar(Impulse.ar(0), 0.01, WhiteNoise.ar(1))
	local coef = (0.1/(math.exp(1)-1))*(amp:exp() - 1)
	coef = coef:min(0.1)
	signal = FOS.ar(signal,0.01+coef,0,0.999-coef)
	signal = Klank.ar(Ref{klf, kla, klr},	signal*e2, {freq,freq*1.005},0,freq:linlin(100,5000,1.5,0.03))
	DetectSilence.ar(signal,0.0005,0.1,2);
	CheckBadValues.ar(signal,24)
	signal = signal*0.5
	Out.ar(out, Mix{Pan2.ar(signal[1], pan1),Pan2.ar(signal[2], pan2)});
end):store()

KLF = TA{517,525,1441,2636,2651,4090,4103,2062,2065,2314,3130,3124,4534,4456,3954,4011,2582,3559,4110,4192,5189,4949,5698,5713,6421,6567}/517
KLF = KLF:sort()
KLA = TA():Fill(#KLF,1/#KLF)
KLR = TA():gseries(#KLF,15,0.9)

SynthDef("korean_bell", {out = 0,fattack=6000,attack=0.0,decay=25, freq = 144, pan = 0,amp=1.0,klf = Ref(KLF),kla=Ref(KLA),klr=Ref(KLR)}, function()
	local e2 = EnvGen.kr(Env.perc(attack, decay, amp, -4),nil,nil,nil,nil,2);
	local signal = Decay.ar(Impulse.ar(0), 0.01, WhiteNoise.ar(1))
	local coef = (0.1/(math.exp(1)-1))*(amp:exp() - 1)
	coef = coef:min(0.1)
	signal = FOS.ar(signal,0.01+coef,0,0.999-coef)
	signal = Klank.ar(Ref{klf, kla, klr},	signal*e2, freq,0)
	DetectSilence.ar(signal,0.0005,0.1,2);
	CheckBadValues.ar(signal,25)
	Out.ar(out, Pan2.ar(Mix(signal), pan));
end):store()

SynthDef("PPongF", {gate=1,busin=0, busout=0,ffreq=1500,rq=0.4, fdback=0.25,delaytime=0.5,volumen=2,bypass=0},function()
	local input, effect;
	input=In.ar(busin,2); 
	input= input + fdback*LocalIn.ar(2);
	input=Resonz.ar(input,ffreq,rq)
	effect= DelayN.ar(input,delaytime,delaytime-ControlDur.ir());
	effect = {effect[2],effect[1]}
	LocalOut.ar(effect)
	CheckBadValues.ar(effect,26)
	Out.ar(busout,Select.ar(bypass,{effect *volumen,Silent.ar(2)}))
end):store()

SynthDef("PPongMF", {gate=1,busin=0, busout=0,ffreq=1500,rq=0.4, fdback=0.25,delaytime=0.5,volumen=1,bypass=0},function()
	local input, effect;
	input=Mix(In.ar(busin,2)); 
	--input= input + (fdback*LocalIn.ar(2));
	local farr = fdback*LocalIn.ar(2)
	input = {input + farr[1],farr[2]}
	input=Resonz.ar(input,ffreq,rq)
	effect= DelayN.ar(input,delaytime,delaytime-ControlDur.ir());
	effect = {effect[2],effect[1]}
	LocalOut.ar(effect)
	CheckBadValues.ar(effect,27)
	Out.ar(busout,Select.ar(bypass,{effect *volumen,Silent.ar(2)}))
end):store()
