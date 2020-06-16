-- first the synthdefs

require"sc.Compilesynth" -- for Compander

--12 resonator strings
SynthDef("resonDWG", {busout=0,freqC= 40, amp=0.5, gate=1,pos=1-1/7,c1=0.3,c3=1,mistune = 3,mp=0.55,gc=10,wfreq=18000,release=0.2,ingain=5},function()
	local N = 12
	local inp =Mix(In.ar(busout,2))*ingain --* EnvGen.ar(env,gate)
	inp = LPF.ar(inp,wfreq)
	pos = SinOsc.kr(0.1,0.45,0.5)
	local resons = TA{1,2,3,4,5,6,7,8,9,10,11,12} 
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
	son = son:sum()
	Out.ar(busout, OteySoundBoard.ar(son));
end):store();

--early reflection simulator
function EarlyRef(sin,fac,lat,ff,mix)
	local ff = ff or 5000
	local mix = mix or 1
	local s = Mix(sin)*0.5 --Resonz.ar(Impulse.ar(1), 2000 , 0.3)*3
	local z = (1-lat)*{2,3,5,7,11,13,17}*fac
	z = z:Do(function(v) return DelayC.ar(s, 0.2,v/1000)*z[1]/v end) --*z[1]/v
	z = Mix(z)
	local z2 = (1+lat)*{2,3,5,7,11,13,17}*fac
	z2 = z2:Do(function(v) return DelayC.ar(s, 0.2,v/1000)*z2[1]/v end) --*z2[1]/v
	z2 = Mix(z2)
	
	return LPF.ar({z,z2},ff)*mix + sin 
end

-- TBall
SynthDef("tball",{out=0,freq=1000,amp=0.5,pan=0,gate=1,g= 0.5, damp= 0, friction= 0.01,level=1,qq=0.3,lat=0.1},function() 
	local e = amp*LPF.ar(Impulse.ar(0),5000);
	local sig = e
	sig = TBall.ar(sig,g,damp,friction)*level
	sig = Ringz.ar(sig, {freq, freq*65/60}, qq)
	sig = EarlyRef(sig,1.66,lat,5000)
	DetectSilence.ar(sig, 0.001,1,2);
	Out.ar(out,sig)
end):store()


-- dynklank synth
klankperc3b=SynthDef("dynklankperc10", {out = 0,atk = 5, sus = 1, rel = 0.1, freq = 144, pan = 0,panor=0,amp = 1.0, gate=1, klf = Ref(TA():Fill(10,function() return exprandrngV(1,10)end):sort()), kla = Ref(TA():Fill(10,0.4)), klr = Ref(TA():gseries(10,1,0.9)),resfac=0.05,fnoise=15000,fac=2.5,lat=0.1},function ()
	local e = EnvGen.kr(Env.asr(atk, sus, rel),gate,nil,nil,nil,2)*amp;
	local i = LFDNoise3.ar(fnoise)*0.03*amp --LFDClipNoise.ar(fnoise)*0.03 
	i= LPF.ar(i,klf[10]*freq)
	local z = DynKlankS.ar(Ref{klf, kla, klr},i,freq,nil,resfac);
	local cc = Splay.ar(z*e)
	cc = EarlyRef(cc,fac,SinOsc.kr(0.1,Rand(-math.pi,math.pi),0.8),16000)
	CheckBadValues.ar(cc,-1)
	Out.ar(out,cc)
end):store()
-- soundboard
SynthDef("soundboard", { busin=0, busout=0},function()
	local input=In.ar(busin,2); 
	local son = OteySoundBoard.ar(input,15,20,0.9)
	CheckBadValues.ar(son,28)
	ReplaceOut.ar(busout,son)
end):store();

-- waiting to synthdefs
Sync()

------------------------- two players -----------------------------
player1 = OscEP{inst="dynklankperc10",sends={0,0.3},channel={level=db2amp(-14)}}:Bind{
	note = noisefStream{60,90},
	delta = noisefStream{10,20},
	dur = noisefStream{0.5,2},
	fnoise = RSinf{2000,5000,18000},
	resfac = noisefStream{0.05,2},
	fac = noisefStream{1.66,10},
}
player1.inserts = {{"soundboard"}}

player2 = OscEP{inst="tball",sends={0,0.9}}:Bind{
	note = noisefStream{60,100},
	delta = noisefStream{1,10},
	dur = noisefStream{0.5,2},
	lat = noisefStream{-0.8,0.8},
	g = noisefStream{0.2,0.6},
	qq = noisefStream{0.03,0.3},
}

------------------------------ Master ---------------------------------
Effects={FX("gverb",db2amp(0),nil,{revtime=5,roomsize=100}),FX("resonDWG")}
Master.inserts={{"Compander",{thresh=-25,slopeAbove=1/3,bypass=0}}}
--DiskOutBuffer[[resonator2.wav]]	
--FreqScopeSt()
--Scope()
theMetro:start()
