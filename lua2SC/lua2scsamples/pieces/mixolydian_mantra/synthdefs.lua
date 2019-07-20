require"sc.Compilesynth"
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

SynthDef("soundboard", { busin=0, busout=0},function()
	local input=In.ar(busin,2); 
	local son = OteySoundBoard.ar(input,15,20,0.9)
	--son = AllpassC.ar(son,0.02,{0.01,0.0113})
	ReplaceOut.ar(busout,son)
end):store();


SynthDef("dwgreverb", { busin=0, busout=0,c1=4,c3=4,len=1200,mix = 1},function()
	local source=Mix(In.ar(busin,2)); 	
	source = DWGReverbC1C3_16.ar(source,len,c1,c3,mix)	
	ReplaceOut.ar(busout,source)
end):store();


SynthDef("oteypiano", { out=0, freq=440, amp=0.5, t_gate=1,gate=1, release=0.1, rmin = 0.35,rmax =  2,rampl =  4,rampr = 8, rcore=1, lmin =  0.07,lmax =  1.4;lampl =  -4;lampr =  4, rho=1, e=1, zb=2, zh=0, mh=1.6, k=0.5, alpha=1, p=1, pos=0.142, loss = 1,detunes = 6,pan=0},function()

	vel = 1.5*amp --1.5
	local son = OteyPianoStrings.ar(freq, vel,t_gate, rmin,rmax,rampl,rampr, rcore, lmin,lmax,lampl,lampr, rho, e, zb, zh, mh, k, alpha, p, pos, loss,detunes*0.0001)
	son = son*EnvGen.ar{Env.asr(0,1,0.1),gate,doneAction=2}
	DetectSilence.ar(son, 0.001,nil,2);
	Out.ar(out, Pan2.ar(son *0.15,pan));
end):store();

SynthDef("bowdrone", { fnoise=2000,out=0, freq=440, amp=0.5, gate=1,pos=1-1/7,c1=1,c3=31,mistune = 1,mp=0.55,gc=10,wfreq=20000,
bpfreq=457,brq = 1, bdb = -0,release=0.2},function()
	local wide2 = LinExp.kr(amp,0,1,0.006,0.0001) 
	local pre = LinExp.kr(amp,0,1,1,0.0001) - 0.5
	local env = Env.new({0,pre, 1, 0}, TA{0.001,wide2, 0.0005}*1,{5,-5, -8});

	local inp =amp*LFClipNoise.ar(fnoise) 
	wfreq = LinExp.kr(amp,20/127,1,600,20000)
	inp = LPF.ar(inp,wfreq)

	local glide = 1 + EnvGen.ar(Env.new({0.002*amp,0}, {1.5},-8),gate)
	local son = DWGPlucked.ar(freq*glide, amp, gate,pos,c1,c3,inp,release)
	DetectSilence.ar(son, 0.001,nil,2);
	Out.ar(out, Pan2.ar(Mix(son*0.05) ,pan));

end):store();


SynthDef("Jetsound",{out=0,busin=0,pan=0,time=25},function()
	local omega1 = 2*math.pi*XLine.kr(6000,50,time)/SampleRate.ir()
	
	local R = 0.95
	local R2 = R*R
	local sig = (BrownNoise.ar()+WhiteNoise.ar() + LFDNoise3.ar(XLine.kr(5000,50,time)))*0.3 
	sig = RLPF.ar(sig,XLine.kr(6000*0.9,50*0.9,time),0.3)
	local all = sig
	TA{1,1.1,1.2,1.3}:Do(function(val)
		local b1 = -2*R*(val*omega1):cos()
		local b2 = -2*R*(val*omega1*1.05):cos()
		all = IIRf.ar(all,{{R2,b1,1},{R2,b2,1}},{{b1,R2},{b2,R2}})
	end)
	
	local eff = all + sig
	eff = LPF.ar(eff,Line.kr(20000,1000,time))
	eff = eff * Line.kr(1,0,time)*Line.kr(0,1,0.2)
	Out.ar(out,Balance2.ar(eff[1],eff[2],Line.kr(-0.25,0.25,time,1,0,2)))
end):store()

SynthDef("Jetsound2",{out=0,busin=0,pan=0,time=25},function()
	local omega1 = 2*math.pi*XLine.kr(5000,50,time)/SampleRate.ir()
	
	local R = 0.95 --MouseY.kr(0.1,0.9)
	local R2 = R*R
	local sig = (BrownNoise.ar() + LFDNoise3.ar(XLine.kr(5000,50,time)))*0.1 --*{0.1,0.1}
	sig = RLPF.ar(sig,XLine.kr(5000*0.9,50*0.9,time),0.3)
	
	local Q = 1
	local a = 1/(2*(math.pi*XLine.kr(5000,50,time)/SampleRate.ir()):tan());
	local a2 = a*a;
	local aoQ = a/Q;
	local d = (4*a2+2*aoQ+1);
		
	local KernelA = {}
	KernelA[1] = -(8*a2-2) / d;
	KernelA[2] = (4*a2 - 2*aoQ + 1) / d;
	local KernelB = {}
	KernelB[1] = (1+4*a2)/d;
	KernelB[2] = (2-8*a2)/d;
	KernelB[3] = (1+4*a2)/d;
	
	local eff = IIRf.ar(sig,KernelB,KernelA)
	
	eff = LPF.ar(eff,Line.kr(20000,1000,time))
	eff = eff * Line.kr(1,0,time)*Line.kr(0,1,0.2)
	Out.ar(out,Pan2.ar(eff,Line.kr(0.75,-0.75,time,1,0,2)))
end):store()

