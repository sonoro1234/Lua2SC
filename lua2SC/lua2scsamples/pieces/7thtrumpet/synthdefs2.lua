require"sc.Compilesynth"

SynthDef("dwgreverb", { busin=0, busout=0,c1=4,c3=4,len=1200,mix = 1},function()
	local source=Mix(In.ar(busin,2)); 
	--source = DWGReverb.ar(source,len,c1,c3,mix)*0.5	
	source = DWGReverbC1C3_16.ar(source,len,c1,c3,mix)	
	ReplaceOut.ar(busout,source)
end):store();

SynthDef("AdachiAyers",{out=0,flip=530,presion= 10000,radio=0.0085,reflec=0,reflec2=0,reflec3=0,kernel=0,trig=0,open=0.0014,gate=1,sweep=0.3,delay=100,gdamp=0.003,pan=0},function()

	--local vibrato = SinOsc.kr(4,Rand(0,2*math.pi),10);
	local env = EnvGen.kr{Env.asr(0,1,0.1),gate,doneAction=2}
	local gd2= Gendy1.kr(nil,nil,nil,nil,0.1, 10,nil,nil,nil,nil, gdamp,1)
	local delay = delay:max(1):min(1400)
	local signal = AdachiAyers.ar(Lag.kr(flip*gd2,sweep),presion,radio,reflec,reflec2,reflec3,open,1,delay)*80;

	signal = Convolution2.ar(signal,kernel,trig,2048, 0.5)*env
	--signal = BHiShelf.ar(signal,500,2,24)
	signal = LeakDC.ar(signal)
	--DetectSilence.ar(signal,0.0001,0.1,2)
	--Out.ar(out,Pan2.ar(signal,0));
	Out.ar(out,Pan2.ar(signal,SinOsc.kr(Rand(0.02,0.1),math.pi*pan)));
end):store()

KLF = TA{517,525,1441,2636,2651,4090,4103,2062,2065,2314,3130,3124,4534,4456,3954,4011,2582,3559,4110,4192,5189,4949,5698,5713,6421,6567}/517
KLF = KLF:sort()
KLA = TA():Fill(#KLF,1/#KLF)
KLR = TA():gseries(#KLF,15,0.9)

sinte=SynthDef("korean_bell", {t_trig=1,out = 0,fattack=6000,attack=0.0,decay=25, freq = 144, pan = 0,amp=1.0,klf = Ref(KLF),kla=Ref(KLA),klr=Ref(KLR)}, function()
	local e2 = 1

	local signal = Decay.ar(T2A.ar(t_trig), 0.01, WhiteNoise.ar(1))

	local coef = (0.1/(math.exp(1)-1))*(amp:exp() - 1)
	coef = coef:min(0.1)
	signal = FOS.ar(signal,0.01+coef,0,0.999-coef)
	signal = Klank.ar(Ref{klf, kla, klr},	signal*e2, freq,0)
	Out.ar(out, Pan2.ar(Mix(signal), pan));
end):store(true)

KLR = TA():gseries(#KLF,10,0.97)

sinte=SynthDef("Voicebell", {out=0, t_gate=1,gate=1,attack=0.0,decay=25, freq=60, amp=0.3,pan=0, voiceGain=2.0, noiseGain=0.0,sweepRate=2,width=0.17,klf = Ref(KLF),kla=Ref(KLA),klr=Ref(KLR)},function ()
	local f = Control.names({'f'}).kr(Ref{800, 1150, 2900, 3900, 4950});
	local q = Control.names({'q'}).kr(Ref{0.1, 0.078260869565217, 0.041379310344828, 0.033333333333333, 0.028282828282828 });
	local a = Control.names({'a'}).kr(Ref{ 1, 1, 1, 1, 1 });
	local signal2 = Decay.ar(T2A.ar(t_gate), 0.01, {WhiteNoise.ar(1),WhiteNoise.ar(1)})
	--local signal2 = Decay.ar(T2A.ar(t_gate), 0.01, {BrownNoise.ar(1),BrownNoise.ar(1)})
	local signal = Klank.ar(Ref{klf, kla, klr},	signal2, freq,0)--,freq:linlin(100,5000,1.5,0.03))
	local exci = signal
	exci = OnePole.ar(exci, 0.97 - (amp*0.2));
	
	local filters1 = Resonz.ar(exci[1], Lag.kr(f, sweepRate), Lag.kr(q, sweepRate), Lag.kr(1, sweepRate));
	local filters2 = Resonz.ar(exci[2], Lag.kr(f, sweepRate), Lag.kr(q, sweepRate), Lag.kr(1, sweepRate));
	
	local filter1=HPF.ar(Mix(filters1),200)*0.75 --*env;
	local filter2=HPF.ar(Mix(filters2),200)*0.75 --*env;
	return Out.ar(out, {filter1,filter2})
end):store(true)
