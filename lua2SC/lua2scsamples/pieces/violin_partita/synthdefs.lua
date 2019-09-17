

SynthDef("dwgreverb3band", { busin=0, busout=0,xover = 400;rtlow = 3,rtmid = 2,fdamp = 6000,len=2500,timfac=1},function()
	local source=Mix(In.ar(busin,2)); 
	source = DWGReverb3Band_16.ar(source,len,xover,rtlow*timfac,rtmid*timfac,fdamp)	
	ReplaceOut.ar(busout,source)
end):store();

SynthDef("piano_soundboard", { busin=0, busout=0},function()
	local input=In.ar(busin,2); 
	local son = OteySoundBoard.ar(input,15,20,0.9)
	ReplaceOut.ar(busout,son)
end):store();

SynthDef("resonDWG", {busout=0,freqC= 440*0.25, amp=0.5, gate=1,pos=1-1/7,c1=0.3,c3=1,mistune = 3,mp=0.55,gc=10,wfreq=18000,release=0.2,ingain=1,level=1},function()
	local N = 12 
	local inp = Mix(In.ar(busout,2))*ingain 
	inp = LPF.ar(inp,wfreq)
	pos = SinOsc.kr(0.1,0.45,0.5)
	local resons = TA():gseries(N,1,math.pow(2,1/12))
	local son = resons:Doi(function(v,i) 
		local freq = freqC*v*SinOsc.kr(0.1,linearmap(1,#resons,-math.pi,math.pi,i),0.001,1-0.001/2)
		return DWGPlucked2.ar(freqC*v, amp, gate,
		(linearmap(1,#resons,0,1,i)+pos):mod(1),
		c1,c3,inp,release,1 + mistune/1000,mp,gc/1000)*0.01 
	end)
	
	local pan = SinOsc.kr(0.2,0,1,1)
	son = son:Doi(function(v,i) 
	return PanAz.ar(2,v,
	(linearmap(1,#resons ,-1,1,i) + LFSaw.kr(0.1)))
	end)
	son = son:sum()*0.3
	Out.ar(busout, son*level);
end):store()

SynthDef("help_oteypiano", { out=0, freq=440, amp=0.5, t_gate=1,gate=1, release=0.1, rmin = 0.35,rmax =  2,rampl =  4,rampr = 8, rcore=1, lmin =  0.07,lmax =  1.4;lampl =  -4;lampr =  4, rho=1, e=1, zb=2, zh=0, mh=1.6, k=0.5, alpha=1, p=1, pos=0.142, loss = 1,detunes = 6,pan=0},function()

	vel = amp
	local son = OteyPianoStrings.ar(freq, vel*1.5,t_gate, rmin,rmax,rampl,rampr, rcore, lmin,lmax,lampl,lampr, rho, e, zb, zh, mh, k, alpha, p, pos, loss,detunes*0.0001,1)
	son = son*EnvGen.ar{Env.asr(0,1,0.1),gate,doneAction=2}
	DetectSilence.ar(son, 0.001,nil,2);
	Out.ar(out, Pan2.ar(son *0.1,LinLin.kr(freq,midi2freq(21),midi2freq(80),-0.75,0.75)));
end):store();


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

SynthDef("bowsoundboard", { busin=0, busout=0,mix=0.9,fLPF=6300,size=1,T1=1,gainS=1,gainL=120,gainH=2},function()
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

SynthDef("bowed", {out=0, freq=440, amp=0.0,amp2=0,force=1, gate=1,pos=0.07,c1=4,c3=40,mistune = 4200,release=0.1,Z = 0.5,B=4,Ztor=1.8,c1tor=2,c3tor=3000,pan=0,vibdeph=7;
},function()

	local vibfreq = Vibrato.kr{freq, rate= 5, depth= vibdeph/1000, delay= 1, onset= 0, rateVariation= 0.1, depthVariation= 0.1, iphase =  0,trig=1}
	local son = DWGBowedTor.ar(vibfreq, amp,force, gate,pos,release,c1,c3,Z,B,1 + mistune/1000,c1tor,c3tor,Ztor) 
	son = LeakDC.ar(son,0.995)
	Out.ar(out, Pan2.ar(Mix(son)*0.005 ,0))
end):store();

