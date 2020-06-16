
body_resons={{118, 18, -33},
{274, 22, -34.5},
{449, 10, -16},
{547, 16, -15.5},
{840, 50, -31},
{997, 30, -20.4},
{1100, 30, -34},
{1290, 25, -29},
{1500, 50, -28},
{1675, 60, -22},
{1900, 60, -20}}

SynthDef("bowsoundboard", { busin=0, busout=0,mix=0.9,fLPF=4300,size=1,T1=1,gainS=1,gainL=120,gainH=1},function()
	local str=In.ar(busin,2); 
	
	local coefs = TA{199, 211, 223, 227, 229, 233, 239, 241 } *size
	local fdn = DWGSoundBoard.ar(str,nil,nil,mix,unpack(coefs:asSimpleTable()));
	local bodyf = 0
	for i,v in ipairs(body_resons) do
		bodyf = bodyf + BPF.ar(str,v[1]*T1,1/(v[2]*T1))*db2amp(v[3])
	end
	local son = str*gainS + bodyf*gainL + fdn*gainH
	son = LPF.ar(son,fLPF)
	ReplaceOut.ar(busout,son)
end):store();

SynthDef("bowed", {out=0, freq=440, amp=0.5,force=1, gate=1,pos=0.07,c1=0.5,c3=40,mistune = 4200,release=0.1,Z = 0.5,B=2,Ztor=1.8,c1tor=1,c3tor=3000,pan=0;
},function()

	local vibfreq = Vibrato.ar{freq, rate= 4, depth= 0.005, delay= 0.5, onset= 2.5, rateVariation= 1, depthVariation= 0.1, iphase =  0}

	local son = DWGBowedTor.ar(vibfreq, amp,force, gate,pos,release,c1,c3,Z,B,1 + mistune/1000,c1tor,c3tor,Ztor)*amp
	Out.ar(out, Pan2.ar(Mix(son*0.015) ,0))
end):store();

SynthDef("formantVoice2", {out=0, gate=1, freq=60, amp=0.3,pan=0, voiceGain=1.0, noiseGain=0.0,sweepRate=0.01},function ()
	local f = Control.names({'f'}).kr(Ref{ 400, 750, 2400, 2600, 2900 });
	local q = Control.names({'q'}).kr(Ref{ 0.1, 0.10666666666667, 0.041666666666667,0.046153846153846, 0.041379310344828 });
	local a = Control.names({'a'}).kr(Ref{ 1, 0.28183829312645, 0.089125093813375, 0.1, 0.01 });
	local env=EnvGen.ar(Env.asr(0.1, 1.0, 0.1), gate, nil,nil,nil,2);
	local filters,filter,freqlag;
	local vibrato = SinOsc.kr(4,Rand(0,2*math.pi));
	freqlag=Lag.kr(freq,sweepRate*0.1);
	filters = Formant.ar(freqlag+vibrato, Lag.kr(f, sweepRate), Lag.kr(f*q, sweepRate), Lag.kr(a, sweepRate));
	filter=HPF.ar(Mix(filters),200)*env;
	return Out.ar(out, Pan2.ar(amp*filter,pan,amp ));
end):store()

SynthDef("framedrum", {out = 0,fattack=6000,attack=0.03,decay=5, freq = 144, pan = 0,amp=1.0,klf = Ref{1,1.594,2.136,2.296,2.653,2.918,3.156,3.501,3.6,3.652,4.06,4.152},kla=Ref(TA():series(12,1,-0.00)),klr=Ref(TA():gseries(12,5,0.91)),decayf=3,gate=1}, function()

	local e2 = EnvGen.ar(Env.adsr(attack, decay,0.5, 0.05),gate,nil,nil,nil,2);
	local i = Decay.ar(Impulse.ar(0), 0.01, LPF.ar(ClipNoise.ar(amp),fattack));
	local signal = Klank.ar(
		-- specs (partials, amplitudes, ringtimes)
		Ref{klf, kla, klr},	
		i*e2,
		freq,			
		0,	
		decayf 
	)
	signal=LeakDC.ar(signal)
	DetectSilence.ar(signal,0.001,0.1,2);
	Out.ar(out, Pan2.ar(signal, pan));
end):store()

local path = require"sc.path"
file_path = path.file_path()
bbb=FileBuffer(file_path..[[\tambourexcite2.wav]])


SynthDef("tambour", { fnoise=3500,out=0, freq=440, amp=0.5, gate=1,pos=1-1/7,c1=0.3,c3=200,mistune = 4,mp=0.55,gc=10,wfreq=20000,release=0.2,pan=0},function()
	local wide2 = 0.006 --LinExp.kr(amp,0,1,0.006,0.0001) 
	local pre = 1 --LinExp.kr(amp,0,1,1,0.0001) - 0.5
	local env = Env.new({0,pre, 1, 0}, TA{0.001,wide2, 0.0005}*1,{5,-5, -8});

	fnoise = LinExp.kr(amp,0,1,1600,16000)

	local inp = PlayBuf.ar(1, bbb.buffnum, BufRateScale.kr(bbb.buffnum),gate,0 ,0)*amp
	wfreq = LinExp.kr(amp,40/127,1,1000,20000)
	inp = LPF.ar(inp,wfreq)

	local son = DWGPlucked2.ar(freq, amp, gate,pos,c1,c3,inp,release,1 + mistune/1000,mp,gc/1000)
	DetectSilence.ar(son, 0.001,nil,2);
	Out.ar(out, Pan2.ar(Mix(son*0.3) ,pan));
end):store()

SynthDef("tambour2", { fnoise=3500,out=0, freq=440, amp=0.5, gate=1,pos=1-1/7,c1=0.3,c3=200,mistune = 4,mp=0.55,gc=10,wfreq=20000,release=0.2,pan=0},function()
	local wide2 = 0.006 --LinExp.kr(amp,0,1,0.006,0.0001) 
	local pre = 1 --LinExp.kr(amp,0,1,1,0.0001) - 0.5
	local env = Env.new({0,pre, 1, 0}, TA{0.001,wide2, 0.0005}*1,{5,-5, -8});

	fnoise = LinExp.kr(amp,0,1,1600,16000)
	local inp = PlayBuf.ar(1, bbb.buffnum, BufRateScale.kr(bbb.buffnum),gate,0 ,0)*amp
	wfreq = LinExp.kr(amp,40/127,1,1000,20000)
	inp = LPF.ar(inp,wfreq)

	local son = DWGPlucked.ar(freq, amp, gate,pos,c1,c3,inp,release)
	DetectSilence.ar(son, 0.001,nil,2);
	Out.ar(out, Pan2.ar(Mix(son*0.3) ,pan));
end):store()

ccc=FileBuffer(file_path..[[\dbexcite.wav]])

SynthDef("cbass", { fnoise=3500,out=0, freq=440, amp=0.5, gate=1,pos=1-1/7,c1=0.3,c3=200,mistune = 4,mp=0.55,gc=10,wfreq=20000,release=0.2,pan=0},function()
	local wide2 = 0.006 
	local pre = 1 
	local env = Env.new({0,pre, 1, 0}, TA{0.001,wide2, 0.0005}*1,{5,-5, -8});

	fnoise = LinExp.kr(amp,0,1,1600,16000)
	local inp = PlayBuf.ar(1, ccc.buffnum, BufRateScale.kr(ccc.buffnum),gate,0 ,0)*amp
	wfreq = LinExp.kr(amp,40/127,1,1000,20000)
	inp = LPF.ar(inp,wfreq)

	local son = DWGPlucked.ar(freq, amp, gate,pos,c1,c3,inp,release)
	DetectSilence.ar(son, 0.001,nil,2);
	Out.ar(out, Pan2.ar(Mix(son*0.3) ,pan));
end):store();


SynthDef("clarinet",{out=0,freq=400,att=0.01,amp=0.5,ampn=1,pc= 1, m= 1.2, gate= 1, release= 0.01, c1= 0.2, c3= 7,time=2,amppc=0.2,pan=0,ampvibu=0.01 },function()

	m = Line.kr(0.8,1.2,time)
	amp = LinLin.kr(amp,0,1,0.76,1)
	local env = EnvGen.ar(Env.asr(att,1,0.2,1),gate)*amp +
	EnvGen.ar(Env.perc(0.01,2,0.01,1),gate)*WhiteNoise.ar() --*GendyI.ar{}

	local ambvib = EnvGen.ar(Env.asr(time*2,ampvibu,0.1,1),gate)
	local vib = SinOsc.kr(4,0,ambvib,1)
	local signal = DWGClarinet3.ar(Lag.kr(freq,0.09)*vib, env,pc,m, gate,release,c1,c3)
	signal = HPF.ar(signal,200)
	Out.ar(out,Pan2.ar(signal,pan))
end):store()
