
SynthDef("testMembrane",{out=0,pos=0.2,t_gate=1,gate=1,ancho=200,fnoise=10000,amp=0.5,wsamp=100,tension=0.1,loss=1},function()
	loss = (-loss/1000):dbamp()
	local freqreciprocal = 1/100
	local bb = wsamp/44100
	amp = Latch.ar(amp, t_gate)
	local excitation = EnvGen.ar(Env.new({0,1,1,0},{bb,ancho/44100,0}),t_gate)*amp*LFDNoise3.ar(fnoise)
	local sig = MembraneHexagon.ar(excitation, tension, loss)*0.3;
	Out.ar(out,Pan2.ar(sig,0))
end):store()

SynthDef("dwgreverb", { busin=0, busout=0,c1=4,c3=10,len=2000,mix = 1},function()
	local source=Mix(In.ar(busin,2))*2; 
	source = DWGReverb.ar(source,len,c1,c3,mix)
	ReplaceOut.ar(busout,source)
end):store();

SynthDef("bowsoundboard", { busin=0, busout=0,mix=0.8,db=20,bfreq=240,bypass=0},function()
	local inp=In.ar(busin,2); 
	local defdels = {199, 211, 223, 227, 229, 233, 239, 241}
	son = DWGSoundBoard.ar(inp,20,20,mix)
	son = BPF.ar(son,118,1)+son
	son = BPF.ar(son,430,1)+son
	son = BPF.ar(son,490,1)+son
	son = LPF.ar(son,6000)
	ReplaceOut.ar(busout,Select.ar(bypass,{son,inp}))
end):store();

SynthDef("plucksoundboard", { busin=0, busout=0,mix=0.8,db=20,bfreq=240,bypass=0},function()
	local inp=In.ar(busin,2); 
	local defdels = TA{199, 211, 223, 227, 229, 233, 239, 241}*1
	son = DWGSoundBoard.ar(inp,20,20,mix,unpack(defdels))
	ReplaceOut.ar(busout,Select.ar(bypass,{son,inp}))
end):store();

SynthDef("bowed", {out=0, freq=440, amp=0.5,velo=1,force=1, gate=1,pos=0.18,c1=0.25,c3=20,mistune = 4200,release=0.1,Z = 0.5,B=1,Ztor=1.8,c1tor=1,c3tor=3000,pan=0;
},function()
	amp = velo
	local vibratoF =  Vibrato.kr{freq, rate= 5, depth= 0.003, delay= 0.25, onset= 0, rateVariation= 0.1, depthVariation= 0.3, iphase =  0}
	local son = DWGBowedTor.ar(vibratoF, amp,force, gate,pos,release,c1,c3,Z,B,1 + mistune/1000,c1tor,c3tor,Ztor) 
	DetectSilence.ar(son, 0.001,nil,2);
	Out.ar(out, Pan2.ar(Mix(son*0.04) ,pan)) --LinLin.kr(freq,50,600,-1,1)));
end):store();

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

afripluck=SynthDef("afripluck", { fnoise=3500,out=0, freq=440, amp=0.5, gate=1,pos=1-1/7,c1=0.3,c3=200,mistune = 4,mp=0.55,gc=10,wfreq=20000,release=0.2,pan=0},function()
	local wide2 = LinExp.kr(amp,0,1,0.006,0.0001) 
	local pre = LinExp.kr(amp,0,1,1,0.0001) --- 0.5
	local env = Env.new({0,pre, 1, 0}, TA{0.001,wide2, 0.0005}*1,{5,-5, -8});
	fnoise = LinExp.kr(amp,0,1,1600,16000)
	local inp =amp*LFClipNoise.ar(fnoise) * EnvGen.ar(env,gate)
	wfreq = LinExp.kr(amp,20/127,1,50,20000)
	inp = LPF.ar(inp,wfreq)
	local son = DWGPlucked.ar(freq, amp, gate,pos,c1,c3,inp,release)
	son = son:tanh()
	DetectSilence.ar(son, 0.001,nil,2);
	son = HPF.ar(son,450)
	Out.ar(out, Pan2.ar(Mix(son) ,pan));
end):store();

SynthDef("clap2", {out=0,amp = 0.5,pan=0,dura=1,gate=1,q=1,fq=1,rnd1=0,rnd2=0,rnd3=0},function()
	local env1, env2, sig, noise1, noise2;
	-- noise 1 - 4 short repeats
	rnd2 = Rand(0,0.02)
	rnd1 = Rand(0,0.02)
	env1 = EnvGen.ar{Env.new({0, 1, 0, 1, 0, 1, 0, 1, 0}, {0.001, 0.013 + rnd1, 0, 0.01 +rnd2, 0, 0.01+rnd3, 0, 0.03},{0, -3, 0, -3, 0, -3, 0, -4}),timeScale=dura};
	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 300);
	noise1 = BPF.ar(noise1, 1500*fq, 3*q);
	-- noise 2 - 1 longer single
	env2 = EnvGen.ar{Env.new({0, 1, 0}, {0.02, 0.1}, {0, -4}),gate,doneAction=2, timeScale=dura};
	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000*fq);
	noise2 = BPF.ar(noise2, 1200*fq, 0.7*q, 0.7);
	sig = noise1 + noise2;
	sig = sig * 2;
	sig = sig*amp 
	sig=Pan2.ar(sig,pan);
	OffsetOut.ar(out,sig);
end):store()
