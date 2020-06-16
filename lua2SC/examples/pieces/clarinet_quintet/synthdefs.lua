--theMetro:NRTGen(100)
-- SynthDefs------------------------------
SynthDef("resonDWG", {busout=0,freqC= 1, amp=1, gate=1,pos=1-1/7,c1=1,c3=1,mistune = 8,mp=0.55,gc=10,wfreq=18000,release=0.2,ingain=1,outgain=1},function()
	freqC = midi2freq(24)*freqC
	local N = 12*2
	local inp =Mix(In.ar(busout,2))*ingain --* EnvGen.ar(env,gate)
	inp = LPF.ar(inp,wfreq)

	local resons = TA():series(N,1,1) --TA{1,2,3,4,5,6,7,8,9,10,11,12} 
	resons = resons:Do(midi2ratio)

	local son = resons:Doi(function(v,i) 
		return DWGPlucked2.ar(freqC*v, amp, gate,
		(linearmap(1,#resons,0,1,i)+pos):mod(1),
		c1,c3,inp,release,1 + mistune/1000,mp,gc/1000)*0.01 
	end)

	local pan = SinOsc.kr(0.2,0,1,1)
	son = son:Doi(function(v,i) 
	return PanAz.ar(2,v,
	--return Pan2.ar(v,
	--(linearmap(1,#resons ,-1,1,i)))
	(linearmap(1,#resons ,-1,1,i) + LFSaw.kr(0.1)))
	end)

	son = son:sum()
	Out.ar(busout, son*outgain);
end):store();

SynthDef("bowsoundboard", { busin=0, busout=0,mix=0.8,db=20,bfreq=240,f1=118,f2=430,f3=490,f4=4300},function()
	local son=In.ar(busin,2); 
	
	son = DWGSoundBoard.ar(son,20,20,mix)
	son = BPF.ar(son,f1,1)+son
	son = BPF.ar(son,f2,1)+son
	son = BPF.ar(son,f3,1)+son
	son = LPF.ar(son,f4)
	--son = BLowShelf.ar(son,bfreq,1,db)
	ReplaceOut.ar(busout,son)
end):store();

SynthDef("bowed", {out=0, freq=440, amp=0.5,force=1, gate=1,pos=0.07,c1=0.25,c3=20,mistune = 4200,release=0.1,Z = 0.5*2,B=2,Ztor=1.8,c1tor=1,c3tor=3000,pan=0;
},function()

local vibratoF =  Vibrato.kr{freq, rate= 5, depth= 0.003, delay= 0.25, onset= 0, rateVariation= 0.1, depthVariation= 0.3, iphase =  0}
	local son = DWGBowedTor.ar(vibratoF, amp,force, gate,pos,release,c1,c3,Z,B,1 + mistune/1000,c1tor,c3tor,Ztor) 
	DetectSilence.ar(son, 0.001,nil,2);
	Out.ar(out, Pan2.ar(Mix(son*0.04) ,pan)) --LinLin.kr(freq,50,600,-1,1)));
end):store();


SynthDef("early27piano",{busin=0,phase=0,width =2,lev=4,busout=0,bypass=0,L=Ref{8,12,4},Ps = Ref{2,4.5,1.2},Pr = Ref{4,3,1.2},B=0.35,HW=0.4},function() 
	local input = In.ar(busout,2)
	local effect1 = EarlyRef.ar(input[1],{Pr[1]-width,4.5,1.2},Pr,L,HW,B)*lev
	local effect2 = EarlyRef.ar(input[2],{Pr[1]+width,4.5,1.2},Pr,L,HW,B)*lev
	local effect = {effect1[1]+effect2[1],effect1[2]+effect2[2]}
	ReplaceOut.ar(busout,Select.ar(bypass,{effect,input}))
end):store()


SynthDef("help_oteypiano", { out=0, freq=440, amp=0.5, t_gate=1,gate=1, release=0.1, rmin = 0.35,rmax =  2,rampl =  4,rampr = 8, rcore=1, lmin =  0.07,lmax =  1.4;lampl =  -4;lampr =  4, rho=1, e=1, zb=2, zh=0, mh=1.6, k=0.5, alpha=1, p=1, pos=0.142, loss = 1,detunes = 6,pan=0},function()

	vel = 1.5*amp --1.5
	local son = OteyPianoStrings.ar(freq, vel,t_gate, rmin,rmax,rampl,rampr, rcore, lmin,lmax,lampl,lampr, rho, e, zb, zh, mh, k, alpha, p, pos, loss,detunes*0.0001)
	son = son*EnvGen.ar{Env.asr(0,1,0.1),gate,doneAction=2}
	DetectSilence.ar(son, 0.001,nil,2);
	Out.ar(out, Pan2.ar(son *0.15,pan));
end):store();

SynthDef("soundboard", { busin=0, busout=0},function()
	local input=In.ar(busin,2); 
	local son = OteySoundBoard.ar(input,15,20,0.9)
	CheckBadValues.ar(son,28)
	ReplaceOut.ar(busout,son)
end):store();

SynthDef("clarinet",{out=0,freq=400,att=0.01,amp=0.5,pc= 1, m= 1.2, gate= 1, release= 0.01, c1= 0.2, c3= 1,time=0.2,vibdelay=0.2,vibonset=2,ampvibu=0.001,pan=0},function()

	amp = LinLin.kr(amp,0,1,0.76,1)
	local env = EnvGen.ar(Env.asr(att,1,0.2,1),gate)*amp +
	EnvGen.ar(Env.perc(0.01,2,0.01,1),gate)*WhiteNoise.ar() --*GendyI.ar{}

	local freq2 = Vibrato.kr(freq,6,ampvibu,vibdelay,vibonset,0.6)
	local signal = DWGClarinet3.ar(freq2, env,amp,m, gate,release,c1,c3)*0.2 --+SinOsc.ar(freq)*2
	signal = LeakDC.ar(signal)

	signal = HPF.ar(signal,200)
	Out.ar(out,Pan2.ar(signal,pan))
end):store()

