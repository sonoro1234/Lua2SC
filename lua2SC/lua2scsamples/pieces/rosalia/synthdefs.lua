local path = require"sc.path"
--path.file_path()

local ccc=FileBuffer(path.chain(path.file_path(),"dbexcite2.wav"))

SynthDef("cbass", { fnoise=3500,out=0, freq=440, amp=0.5, gate=1,pos=1-1/7,c1=0.3,c3=200,mistune = 4,mp=0.55,gc=10,wfreq=20000,release=0.2,pan=0,decay=2.6},function()
	local wide2 = 0.006  
	local pre = 1
	local env = Env.new({0,pre, 1, 0}, TA{0.001,wide2, 0.0005}*1,{5,-5, -8});
	fnoise = LinExp.kr(amp,0,1,1600,16000)
	local inp = PlayBuf.ar(1, ccc.buffnum, BufRateScale.kr(ccc.buffnum),gate,0 ,0)*amp
	wfreq = LinExp.kr(amp,40/127,1,1000,5000)
	inp = LPF.ar(inp,wfreq)
	local son = DWGPlucked.ar(freq*0.5, amp, gate,pos,c1,c3,inp,release)--,1 + mistune/1000,mp,gc/1000)
	son = son * EnvGen.ar(Env.perc(0,decay),gate)
	DetectSilence.ar(son, 0.001,nil,2);
	Out.ar(out, Pan2.ar(Mix(son*2) ,pan));
end):store(true);

function MakeRoncoSynth(Tract,name,resamp)
	Tract:MakeSynth(name,{Rd=0.3,namp=0.04,nwidth=0.4,vibrate=5,vibdepth=0.01,rv=0.05,jitter=0.015,vibampfac=20,f2=1*3/2,f2amp=0.2},
	function()
	
	freq = freq + freq * LFDNoise3.kr(30,jitter)
	local vibratoF =  Vibrato.kr{freq, rate= vibrate, depth= vibdepth, delay= 0.0, onset= 0, 	rateVariation= rv, depthVariation= 0.1, iphase =  0}
	local Tp,Te,Ta,alpha,Ee = Tract.Rd2Times(Rd)
	vibratoF = vibratoF*{1,f2}
	local exci = LFglottal.ar(vibratoF,Tp,Te,Ta,alpha,namp,nwidth)*glot*3*Ee
	exci[2] = exci[2]*f2amp
	local excinoise =  WhiteNoise.ar()*plosive*Ee 
	exci = Mix(exci)
	return exci +excinoise
	end,resamp)
end

SynthDef("testMembrane",{out=0,pos=0.2,t_gate=1,gate=1,ancho=200,fnoise=10000,amp=0.5,wsamp=100,tension=0.1,loss=1},function()
	loss = (-loss/1000):dbamp()
	local freeenv = EnvGen.kr{Env.asr(0,1,0),gate,doneAction=2}
	local bb = wsamp/44100
	amp = Latch.ar(amp, t_gate)
	local excitation = EnvGen.ar(Env.new({0,1,1,0},{bb,ancho/44100,0}),t_gate)*amp*LFDNoise3.ar(fnoise)
	local sig = MembraneCircle.ar(excitation, tension, loss);
	Out.ar(out,Pan2.ar(sig,0))
end):store(true)

SynthDef("clap2", {out=0,amp = 0.5,pan=0,dura=1,gate=1,q=1,fq=1,rnd1=0,rnd2=0,rnd3=0},function()
	local env1, env2, sig, noise1, noise2;

	env1 = EnvGen.ar{Env.new({0, 1, 0, 1, 0}, {0.001, 0.013 + rnd1, 0, 0.01 +rnd2},{0, -3, 0, -3}),timeScale=dura};
	fq = fq*Rand(0.75,1/0.75)
	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 400);
	noise1 = BPF.ar(noise1, 2000*fq, 3*q);
	-- noise 2 - 1 longer single
	env2 = EnvGen.ar{Env.new({0, 1, 0}, {0.02, 0.3}, {0, -4}),gate,doneAction=2, timeScale=dura};
	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = BPF.ar(noise2, 1200*fq, 0.7*q, 0.1);
	sig = noise1 + noise2;
	sig = sig * 2;
	sig = sig:softclip() * amp;
	sig = LPF.ar(sig,5000)
	sig=Pan2.ar(sig,pan);
	OffsetOut.ar(out,sig*8);
end):store(true)

SynthDef("clap1", {out=0,amp = 0.5,pan=0,dura=1,gate=1,q=1,fq=1,rnd1=0,rnd2=0,rnd3=0},function()
	local env1, env2, sig, noise1, noise2;

	env1 = EnvGen.ar{Env.new({0, 1, 0}, {0.001, 0.013 + rnd1, 0},{0, -3}),timeScale=dura};
	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 400);
	noise1 = BPF.ar(noise1, 2000*fq, 3*q);
	-- noise 2 - 1 longer single
	env2 = EnvGen.ar{Env.new({0, 1, 0}, {0.02, 0.3}, {0, -4}),gate,doneAction=2, timeScale=dura};
	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = BPF.ar(noise2, 1200*fq, 0.7*q, 0.1);
	sig = noise1 --+ noise2;
	sig = sig * 2;
	sig = sig:softclip() * amp;
	sig = LPF.ar(sig,3000)
	sig=Pan2.ar(sig,pan);
	OffsetOut.ar(out,sig*8);
end):store(true)

SynthDef("dwgreverb", { busin=0, busout=0,predelay=0.1,c1=4,c3=4,len=1200,mix = 1},function()
	local source=Mix(In.ar(busin,2)); 
	source = DelayC.ar(source,0.5,predelay)
	source = DWGReverbC1C3_16.ar(source,len,c1,c3,mix)	
	ReplaceOut.ar(busout,source)
end):store(true);

SynthDef("dwgreverb3band",{busout=0,busin=0,predelay=0.1,xover = 400;rtlow = 3,rtmid = 2,fdamp = 6000,len=3500,doprime=0},function()
	local source=Mix(In.ar(busin,2));
	source = DelayC.ar(source,0.5,predelay)
	local sig = DWGReverb3Band_16.ar(source,len,xover,rtlow,rtmid,fdamp,nil,nil,doprime)
	ReplaceOut.ar(busout,sig)
end):store(true)

SynthDef("guitar", { out=0, freq=200, amp=0.5, t_gate=1,pan=0,pos=1-1/7,c1=1,c3=35,
release=0.1,facrel=4,facM=3,facK=1500,facR=5,facF0=50,FEatt=6,FEc1=-8,FEc2=-8,facatt=6,L=0.65,r=0.001,rho=7850,PL=1,gate=1},function()

	facrel = LinExp.kr(amp,0,1,2,0.005)
	facrel = facrel:max(0.005)

	local rel = facrel*0.001 
	local att = facatt *0.001
	local attF = FEatt * 0.001
	local envF = Env.new({0,0, 1, 0}, TA{0,attF, rel},{FEc1,FEc2});
	local env2 = Env.new({0,PL,PL,0},{0,att,rel},1)
	local envR = Env.new({0,1,1,0},{0,att,rel},1)
	local F0 = EnvGen.ar(envF,t_gate)*amp*facF0
	local M = 0.001 * facM * EnvGen.ar(env2,t_gate)
	local K = facK * EnvGen.ar(env2,t_gate) 
	local R = facR * EnvGen.ar(envR,t_gate) 
	
	local son = 8000*PluckSynth.ar(freq, amp, gate,pos,c1,c3,release,F0,M,K,R,L,r,rho)
	Out.ar(out, Pan2.ar(son ,pan));
end):store(true);

SynthDef("plucksoundboard", { busin=0, busout=0,size=2.8,mix=0.8,bypass=0},function()
	local inp=Mix(In.ar(busin,2)); 
	local defdels = TA{199, 211, 223, 227, 229, 233, 239, 241}*size
	son = DWGSoundBoard.ar(inp,20,20,mix,unpack(defdels))
	ReplaceOut.ar(busout,Select.ar(bypass,{son:dup(),inp}))
end):store(true);

SynthDef("PPongF", {gate=1,busin=0, busout=0,ffreq=1500,rq=0.4, fdback=0.25,delaytime=0.5,volumen=2,bypass=0},function()
	local input, effect;
	input=In.ar(busin,2); 
	input= input + fdback*LocalIn.ar(2);
	input=Resonz.ar(input,ffreq,rq)
	effect= DelayN.ar(input,delaytime,delaytime-ControlDur.ir());
	effect = {effect[2],effect[1]}
	LocalOut.ar(effect)
	Out.ar(busout,Select.ar(bypass,{effect *volumen,Silent.ar(2)}))
end):store(true)