--require"init.init"
--require "sc.synthdefsc"
sintes={}
--require "synthdefSCGUI"
---------------------------------------------------------------------------------------------
Membrane=SynthDef("Membrane",{out=0,tension=0.05,loss=0.99999,amp=1},function()
		--local e=EnvGen.ar(Env.perc(0.005, 0.1),1) * PinkNoise.ar(0.4);
		local e2 = EnvGen.kr(Env.perc(0.0, 1, amp, -4),nil,nil,nil,nil,2); 
		local  i = Decay.ar(Impulse.ar(0), 0.01, ClipNoise.ar(amp));
		local s=MembraneCircle.ar(i,tension,loss)*e2
		--DetectSilence.ar(s,0.001,0.1, 2)
		Out.ar(out,s)	
	end)
sintes[#sintes+1]=Membrane	

drone=SynthDef("drone",{out=0,freq=200,amp=0.1,gate=1},function()
	local e2 = EnvGen.kr(Env.asr(0.0005, amp, 1, -4),gate,nil,nil,nil,2);
	Out.ar(out,e2*RLPF.ar(LFPulse.ar({freq,freq*1.5}, 0.15),SinOsc.kr(0.1, 0, 20, 84):midicps(), 0.1,amp));
end);
sintes[#sintes+1]=drone	
---[[

SOStom=SynthDef("SOStom",
	{out = 0, sustain = 0.4, drum_mode_level = 0.25,
	freq = 90, drum_timbre = 1.0, amp = 0.8,pan=0;},function()
	local drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix, drum_mode_env;
	local stick_noise, stick_env;
	local drum_reson, tom_mix;

	drum_mode_env = EnvGen.ar(Env.perc(0.005, sustain), 1.0,nil,nil,nil,2);
	drum_mode_sin_1 = SinOsc.ar(freq*0.8, 0, drum_mode_env * 0.5);
	drum_mode_sin_2 = SinOsc.ar(freq, 0, drum_mode_env * 0.5);
	drum_mode_pmosc = PMOsc.ar(	Saw.ar(freq*0.9),
								freq*0.85,
								drum_timbre/1.3,nil,
								drum_mode_env*5,
								0);
	drum_mode_mix = Mix({drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc}) * drum_mode_level;
	stick_noise = Crackle.ar(2.01, 1);
	stick_env = EnvGen.ar(Env.perc(0.005, 0.01), 1.0) * 3;
	tom_mix = Mix({drum_mode_mix, stick_env}) * 2 * amp;
	--Out.ar(out, {tom_mix, tom_mix})
	Out.ar(out, Pan2.ar(tom_mix,pan))
end)
sintes[#sintes+1]=SOStom

SOSsnare=SynthDef("SOSsnare",
	{out = 0, sustain = 0.1, drum_mode_level = 0.25,snare_level = 40, snare_tightness = 1000,freq = 405, amp = 0.8,pan=0},
	function()
	local drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix, drum_mode_env;
	local snare_noise, snare_brf_1, snare_brf_2, snare_brf_3, snare_brf_4, snare_reson;
	local snare_env;
	local snare_drum_mix;

	drum_mode_env = EnvGen.ar(Env.perc(0.005, sustain,1), 1.0,nil,nil,nil,2);
	drum_mode_sin_1 = SinOsc.ar(freq*0.53, 0, drum_mode_env * 0.5);
	drum_mode_sin_2 = SinOsc.ar(freq, 0, drum_mode_env * 0.5);
	drum_mode_pmosc = PMOsc.ar(	Saw.ar(freq*0.85),
					184,
					0.5/1.3,nil,
					drum_mode_env*5,
					0);
	drum_mode_mix = Mix({drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc}) * drum_mode_level;

	-- choose either noise source below
	--snare_noise = Crackle.ar(2.0001, 1);
		snare_noise = LFNoise0.ar(20000, 0.1);
	--snare_env = EnvGen.ar(Env.perc(0.005, sustain), 1.0,nil,nil,nil,2);
	snare_brf_1 = BRF.ar(snare_noise,8000, 0.1,0.5);
	snare_brf_2 = BRF.ar(snare_brf_1,5000,0.1,0.5);
	snare_brf_3 = BRF.ar(snare_brf_2,3600,0.1, 0.5 );
	snare_brf_4 = BRF.ar(snare_brf_3,2000,0.0001,drum_mode_env)--snare_env);
	snare_reson = Resonz.ar(snare_brf_4, snare_tightness, nil,snare_level) ;
	snare_drum_mix = Mix({drum_mode_mix, snare_reson}) * 5 * amp;
	--Out.ar(out, {snare_drum_mix, snare_drum_mix})
	Out.ar(out,Pan2.ar(snare_drum_mix,pan))
	end)
sintes[#sintes+1]=SOSsnare
--]]
--[[
Clock=SynthDef("Clock",{rate=1,t_reset=0,id=0,frame=1,beat=0,run=1},function()
	local trig =Impulse.ar(rate)
	local pulsecount=PulseCount.ar(trig*run,t_reset)
	SendReply.ar(trig,"/metronom",{frame*pulsecount + beat}, id)
end)
sintes[#sintes+1]=Clock
--]]
---[[
vumeter1=SynthDef("vumeter1",{busin=0,rate=20,lag=3,id=-1},function() 
					local trig =Impulse.ar(rate)
					local canales = In.ar(busin, 1);

					local numsamp=SampleRate.ir()/rate
					local squared=canales:squared() --canales[1]:squared()
					local rms = RunningSum.ar(squared, numsamp)/numsamp

					rms = rms:sqrt()

					local peaks=PeakFollower.ar(canales, 0.99999)
						--SendPeakRMS.ar(canales, rate,lag,"/vumeter",id)
					--SendReply.ar(trig,"/vumeter",{peaks:ampdb(),rms:ampdb()}, id)	
					SendReply.ar(trig,"/vumeter",{peaks,rms}, id)	
				end)
sintes[#sintes+1]=vumeter1

vumeter2=SynthDef("vumeter2",{busin=0,rate=20,lag=3,id=-1},function() 
					local trig =Impulse.ar(rate)
					local canales = In.ar(busin, 2);

					local numsamp=SampleRate.ir()/rate
					local squared=canales*canales
					local rms = RunningSum.ar(squared, numsamp)/numsamp

					rms[1] = rms[1]:sqrt()
					rms[2] = rms[2]:sqrt()
					local peaks=PeakFollower.ar(canales, 0.999)
						--SendPeakRMS.ar(canales, rate,lag,"/vumeter",id)
					SendReply.ar(trig,"/vumeter",{peaks[1],rms[1],peaks[2],rms[2]}, id)	
					
				end)
sintes[#sintes+1]=vumeter2
 --]]
---[[
vumeter1b=SynthDef("vumeter1b",{busin=0,rate=20,lag=3,id=-1},function() 
						local canales = In.ar(busin, 1);
						SendPeakRMS.ar(canales, rate,lag,"/vumeter",id)
				end)
sintes[#sintes+1]=vumeter1b
vumeter2b=SynthDef("vumeter2b",{busin=0,rate=20,lag=3,id=-1},function() 
						local canales = In.ar(busin, 2);
						SendPeakRMS.ar(canales, rate,lag,"/vumeter",id)
				end)
sintes[#sintes+1]=vumeter2b

checkbadval=SynthDef("checkbadval",{busin=0,id=-1},function() 
						local canales = In.ar(busin, 1);
						CheckBadValues.kr(canales,id)
				end)
sintes[#sintes+1]=checkbadval
 --]]

---[[
--Logarithmic stereomix localbuffer
freqScopeLstLocal=SynthDef("freqScopeLstLocal", {busin = 0, fftsize = 2048,scopebufnum=1, phase = 1,rate = 4, dbFactor=0.02,maxfreq=22050  },function ()
	local signal=Mix(In.ar(busin,2))*0.5
	--dumpObj(LocalBuf)
	local buf=LocalBuf(fftsize,1)
	PV_MagSmear(FFT(buf,signal),1)
	local posfac = maxfreq/SampleRate.ir()
	local pos=fftsize*posfac
	pos=pos:pow(LFSaw.ar(rate*SampleRate.ir()/fftsize,phase,0.5,0.5))
	pos=(pos*2):round(2)
	local read=BufRd.ar(1,buf,pos,1,1)*0.00285
	read=read:ampdb()
	--prtable(read)
	read=read*dbFactor+1
	RecordBuf.ar(read,scopebufnum)
end);
sintes[#sintes+1]=freqScopeLstLocal

freqScopeLmnLocal=SynthDef("freqScopeLmnLocal", {busin = 0, fftsize = 2048,scopebufnum=1, phase = 1,rate = 4, dbFactor=0.02,maxfreq=22050 },function ()
	local signal=Mix(In.ar(busin,1)) --*0.5
	--dumpObj(LocalBuf)
	local buf=LocalBuf(fftsize,1)
	PV_MagSmear(FFT(buf,signal),1)
	local posfac = maxfreq/SampleRate.ir()
	local pos=fftsize*posfac
	pos=pos:pow(LFSaw.ar(rate*SampleRate.ir()/fftsize,phase,0.5,0.5))
	pos=(pos*2):round(2)
	local read=BufRd.ar(1,buf,pos,1,1) *0.00285
	read=read:ampdb()
	--prtable(read)
	read=read*dbFactor+1
	RecordBuf.ar(read,scopebufnum)
end);
sintes[#sintes+1]=freqScopeLmnLocal

--linear stereomix localbuffer
freqScopeLocal=SynthDef("freqScopeLocal", {busin = 0, fftsize = 2048,scopebufnum=1, phase = 1,rate = 4, dbFactor=0.02,maxfreq=22050 },function ()
	local signal=Mix(In.ar(busin,2))*0.5
	--dumpObj(LocalBuf)
	local buf=LocalBuf(fftsize,1)
	PV_MagSmear(FFT(buf,signal),1)
	local posfac = maxfreq/SampleRate.ir()
	local pos=fftsize*posfac
	--pos=pos:pow(LFSaw.ar(rate*SampleRate.ir()/fftsize,phase,0.5,0.5))
	pos=pos*(LFSaw.ar(rate*SampleRate.ir()/fftsize,phase,0.5,0.5))
	pos=(pos*2):round(2)
	local read=BufRd.ar(1,buf,pos,1,1) *0.00285
	read=read:ampdb()
	--prtable(read)
	read=read*dbFactor+1
	RecordBuf.ar(read,scopebufnum)
end);
sintes[#sintes+1]=freqScopeLocal 

Scope_mn=SynthDef("scope_mn",{busin = 0, scopebufnum = 0},function()
	local signal = In.ar(busin)
	RecordBuf.ar(signal,scopebufnum)
end);
sintes[#sintes+1]=Scope_mn 

 --]]
---[[
gverb= SynthDef("gverb",{gate = 1.0,busout=0,roomsize=50,revtime=3,damping=0.4,
		inputbw=0.4,spread= 15,drylevel=0,earlylevel= 0.35,taillevel= 0.25,maxroomsize=300},
		function()
			local env,sig,inp;
			--env = EnvGen.ar(Env.asr(0, 1.0, 16.0), gate,nil,nil,nil,2);
			inp=Mix(In.ar(busout, 2))
			sig=GVerb.ar(inp,roomsize,revtime,damping,inputbw,spread,drylevel,earlylevel,taillevel,maxroomsize)--*env
			ReplaceOut.ar(busout,sig)
		end);
sintes[#sintes+1]=gverb
--]]
--------------------------------------------------------------------------------------
---[[
pluck=SynthDef("pluck",{freq=440, amp = 1, decay = 1,pan=0,coef=0.6 ,out=0,gate=1},function ()
		--dumpObj(amp)
		local signal;
		local freqreciprocal = freq:reciprocal()
		signal = Pluck.ar(LPF.ar(WhiteNoise.ar(1),(amp*15000)), 1, freqreciprocal,freqreciprocal, 10, 
		1-(coef*amp),amp)*
		EnvGen.ar(Env.perc(0.0,decay,amp),gate,nil,nil,nil,2);
		signal = Pan2.ar(signal,pan);
		return Out.ar(out, signal); 
		end)
sintes[#sintes+1]=pluck
--]]
---[[
plukV=SynthDef("plukV",{freq=440,amp = 1,decay = 10,pan=0,coef=0.6 ,out=0,gate=1,excit=0.1},
	function ()
		--dumpObj(amp)
		--local signal=LPF.ar(WhiteNoise.ar(1),1000 + amp*15000);
		--local signal=Impulse.ar(0) 
		--local signal = WhiteNoise.ar(1)
		--local signal= LFSaw.ar(0,0)
		local signal = Decay.ar(Impulse.ar(0), excit, PinkNoise.ar(amp));
		--local signal = Decay2.ar(Impulse.ar(0),0.1, 1, ClipNoise.ar(amp));
		--local signal = Pulse.ar(0,0.1,0.005*amp) + WhiteNoise.ar(1)
		local freqreciprocal=freq:reciprocal()
		signal = Pluck.ar(signal, 1, freqreciprocal, freqreciprocal, 9, LinExp.kr(amp,0,1,0.9,LinExp.kr(freq,50,1000,coef,0.2*coef)))
		signal=signal*EnvGen.kr(Env.perc(0.01,decay,amp),gate,nil,nil,nil,2);
		--DetectSilence.ar(signal)
		signal=LeakDC.ar(signal)
		DetectSilence.ar(signal,0.001,0.1,2);
		signal = Pan2.ar(signal,pan);
		CheckBadValues.kr(signal,14)
		return Out.ar(out, signal); 
		end)
sintes[#sintes+1]=plukV

plukVm=SynthDef("plukVm",{freq=440,amp = 1,decay = 10,pan=0,coef=0.6 ,out=0,gate=1,excit=0.1},
	function ()
		--dumpObj(amp)
		--local signal=LPF.ar(WhiteNoise.ar(1),1000 + amp*15000);
		--local signal=Impulse.ar(0) 
		--local signal = WhiteNoise.ar(1)
		--local signal= LFSaw.ar(0,0)
		local signal = Decay.ar(Impulse.ar(0), excit, PinkNoise.ar(amp));
		CheckBadValues.kr(signal,15)
		--local signal = Decay2.ar(Impulse.ar(0),0.1, 1, ClipNoise.ar(amp));
		--local signal = Pulse.ar(0,0.1,0.005*amp) + WhiteNoise.ar(1)
		local freqreciprocal=freq:reciprocal()
		signal = Pluck.ar(signal, 1, freqreciprocal, freqreciprocal, 9, LinExp.kr(amp,0,1,0.9,LinExp.kr(freq,50,1000,coef,0.2*coef)))
		CheckBadValues.kr(signal,16)
		signal=signal*EnvGen.kr(Env.perc(0.01,decay,amp),gate,nil,nil,nil,2);
		--DetectSilence.ar(signal)
		signal=LeakDC.ar(signal)
		DetectSilence.ar(signal,0.001,0.1,2);
		CheckBadValues.kr(signal,13)
		--signal = Pan2.ar(signal,pan);
		return Out.ar(out, signal); 
		end)
sintes[#sintes+1]=plukVm

KarplusVm=SynthDef("KarplusVm",{freq=440,amp = 1,decay = 10,pan=0,coef=0.6 ,out=0,gate=1,excit=0.1},
	function ()
		--dumpObj(amp)
		--local signal=LPF.ar(WhiteNoise.ar(1),1000 + amp*15000);
		--local signal=Impulse.ar(0) 
		--local signal = WhiteNoise.ar(1)
		--local signal= LFSaw.ar(0,0)
		local signal = Decay.ar(Impulse.ar(0), excit, PinkNoise.ar(amp));
		CheckBadValues.kr(signal,15)
		--local signal = Decay2.ar(Impulse.ar(0),0.1, 1, ClipNoise.ar(amp));
		--local signal = Pulse.ar(0,0.1,0.005*amp) + WhiteNoise.ar(1)
		local freqreciprocal=freq:reciprocal()
		signal = Karplus.ar(signal, 1, freqreciprocal, freqreciprocal, 9, LinExp.kr(amp,0,1,0.9,LinExp.kr(freq,50,1000,coef,0.2*coef)))
		CheckBadValues.kr(signal,16)
		signal=signal*EnvGen.kr(Env.perc(0.01,decay,amp),gate,nil,nil,nil,2);
		--DetectSilence.ar(signal)
		signal=LeakDC.ar(signal)
		DetectSilence.ar(signal,0.001,0.1,2);
		CheckBadValues.kr(signal,13)
		--signal = Pan2.ar(signal,pan);
		return Out.ar(out, signal); 
		end)
sintes[#sintes+1]=KarplusVm
--]]
plukBassV=SynthDef("plukBassV", {freq=440, amp = 1, decay = 6,pan=0,coef=0.9,coef2=0.8,coeftime=0.7,out=0,gate=1},function()
		local signal;
		coef=Line.ar(coef,coef2,coeftime);
		local facamp=LinExp.kr(amp,0,1,500,15000)
		signal=LPF.ar(BrownNoise.ar(1),facamp);
		freqreciprocal=freq:reciprocal()
		signal = LeakDC.ar(Pluck.ar(signal, 1, freqreciprocal, freqreciprocal,decay, 
		coef))*EnvGen.kr(Env.adsr(0.01,0.1,0.8,0.05),gate,nil,nil,nil,2)*amp;
		signal=LeakDC.ar(signal)
		DetectSilence.ar(signal,0.001,0.1,2);
		signal = Pan2.ar(signal,pan);
		Out.ar(out, signal);
		end);
sintes[#sintes+1]=plukBassV
plukBassVm=SynthDef("plukBassVm", {freq=440, amp = 1, decay = 6,pan=0,coef=0.9,coef2=0.8,coeftime=0.7,out=0,gate=1},function()
		local signal;
		coef=Line.ar(coef,coef2,coeftime);
		local facamp=LinExp.kr(amp,0,1,500,15000)
		signal=LPF.ar(BrownNoise.ar(1),facamp);
		freqreciprocal=freq:reciprocal()
		signal = LeakDC.ar(Pluck.ar(signal, 1, freqreciprocal, freqreciprocal,decay, 
		coef))*EnvGen.kr(Env.adsr(0.01,0.1,0.8,0.05),gate,nil,nil,nil,2)*amp;
		signal=LeakDC.ar(signal)
		DetectSilence.ar(signal,0.001,0.1,2);
		--signal = Pan2.ar(signal,pan);
		Out.ar(out, signal);
		end);
sintes[#sintes+1]=plukBassVm

plukBassVm2=SynthDef("plukBassVm2", {freq=440, amp = 1, decay = 6,pan=0,coef=0.95,coef2=0.8,coeftime=0.7,out=0,gate=1
},function()
		local signal;
		coef=Line.ar(coef,coef2,coeftime);
		local facamp=LinExp.kr(amp,0,1,200,500)
		--signal=LPF.ar(BrownNoise.ar(1),facamp);
		--signal=LPF.ar(LFNoise0.ar(1000,0.5)+SinOsc.ar(40,math.pi*0.5,0.5),facamp);
		signal=LPF.ar(LFNoise0.ar(1000),facamp);
		freqreciprocal=freq:reciprocal()
		signal = LeakDC.ar(Pluck.ar(signal, 1, freqreciprocal, freqreciprocal,decay, 
		coef))
		signal= signal*EnvGen.kr(Env.adsr(0.01,0.1,0.8,0.05),gate,nil,nil,nil,2)*amp;
		signal=LeakDC.ar(signal)
		DetectSilence.ar(signal,0.001,0.1,2);
		Out.ar(out, signal);
		end);
sintes[#sintes+1]=plukBassVm2

plukBassVm3=SynthDef("plukBassVm3", {freq=440, amp = 1, decay = 6,pan=0,coef=0.95,coef2=0.8,coeftime=0.7,out=0,gate=1
},function()
		local signal;
		coef=Line.ar(coef,coef2,coeftime);
		local facamp=LinExp.kr(amp,0,1,200,500)
		--signal=LPF.ar(BrownNoise.ar(1),facamp);
		signal=LPF.ar(LFNoise0.ar(1000,0.5)+SinOsc.ar(40,math.pi*0.5,0.5),facamp);
		--signal=LPF.ar(LFNoise0.ar(1000),facamp);
		freqreciprocal=freq:reciprocal()
		signal = Pluck.ar(signal, 1, freqreciprocal, freqreciprocal,deca,coef)
		CheckBadValues.kr(signal,11)
		signal= signal*EnvGen.kr(Env.adsr(0.01,0.1,0.8,0.05),gate,nil,nil,nil,2)*amp;
		CheckBadValues.kr(signal,12)
		signal=LeakDC.ar(signal)
		DetectSilence.ar(signal,0.001,0.1,2);
		Out.ar(out, signal);
		end);
sintes[#sintes+1]=plukBassVm3
--[[
 
--]]
---[[
klankperc2=SynthDef("klankperc2", {out = 0,fattack=6000,attack=0.0,decay=5, freq = 144, pan = 0,amp=1.0,klf = Ref{1,2,3,4,5,6,7},kla=Ref{1,1,1,1,1,1,1},klr=Ref{2,2,2,2,2,2,2}}, function()
	local e2 = EnvGen.kr(Env.perc(attack, decay, amp, -4),nil,nil,nil,nil,2);
	local i = Decay.ar(Impulse.ar(0), 0.01, LPF.ar(ClipNoise.ar(amp),fattack));
	local signal = Klank.ar(
		-- specs (partials, amplitudes, ringtimes)
		Ref{klf, kla, klr},	
		i*e2, -- +i2*e,								// input
		freq,			
		0,	
		--1 
		freq:linlin(0,500,1.5,0.1)	
	);
	signal=LeakDC.ar(signal)
	DetectSilence.ar(signal,0.001,0.1,2);
	Out.ar(out, Pan2.ar(signal, pan));
end)
sintes[#sintes+1]=klankperc2
---[[		
klankperc2dofree=SynthDef("klankperc2dofree", {out = 0,fattack=6000,attack=0.0,decay=5, freq = 144, pan = 0,amp=1.0,klf = Ref{1,2,3,4,5,6,7},kla=Ref{1,1,1,1,1,1,1},klr=Ref{2,2,2,2,2,2,2},gate=1}, function()
	--local kla2={}
--	for i,v in ipairs(kla) do
--		kla2[i]=(i/7)*v
--	end
	--local e2 = EnvGen.kr(Env.perc(attack, decay, amp, -4),gate,nil,nil,nil,2);
	local e2 = EnvGen.ar(Env.adsr(attack, decay,0.5, 0.05),gate,nil,nil,nil,2);
	local i = Decay.ar(Impulse.ar(0), 0.01, LPF.ar(ClipNoise.ar(amp),fattack));
	local signal = Klank.ar(
		-- specs (partials, amplitudes, ringtimes)
		Ref{klf, kla, klr},	
		i*e2, -- +i2*e,								// input
		freq,			
		0,	
		--1 
		freq:linlin(0,500,1.5,0.1) --(freq-200)*(-0.5/200)+1		// scale decay times
		--freq:linlin(100,500,1,0.1,"minmax")
	)
	signal=LeakDC.ar(signal)
	DetectSilence.ar(signal,0.001,0.1,2);
	Out.ar(out, Pan2.ar(signal, pan));
end)
sintes[#sintes+1]=klankperc2dofree
klankperc3b=SynthDef("klankperc3b", {out = 0,atk = 5, sus = 8, rel = 5, freq = 144, pan = 0,amp = 1.0, gate=1, klf = Ref{1,2,3,4,5,6,7}, kla = Ref{0.4,0.4,0.4,0.4,0.4,0.4,0.4}, klr = Ref{1.3,1.3,1.3,1.3,1.3,1.3,1.3}},function ()
	local e = EnvGen.kr(Env.linen(atk, sus, rel, amp, 4),gate,nil,nil,nil,2);
	--local i = WhiteNoise.ar(0.012);
	--local i = Decay.ar(Impulse.ar(Rand.ir(0.2, 0.6)), 0.8, ClipNoise.ar(0.01));
	--local i = Decay.ar(Impulse.ar(Rand.ir(0.8, 2.2)), 0.03, ClipNoise.ar(0.01));
	local i = ClipNoise.ar(0.012);
	local z = Klank.ar(Ref{klf, kla, klr},i,freq);
	z= LPF.ar(z,klf[7]*freq)
	return Out.ar(out, Pan2.ar(z*e, pan));
end);
sintes[#sintes+1]=klankperc3b
--]]
---[[
formantVoice2=SynthDef("formantVoice2", {out=0, gate=1, freq=60, amp=0.3,pan=0, voiceGain=1.0, noiseGain=0.0,sweepRate=0.01},function ()
	local f = Control.names({'f'}).kr(Ref{ 400, 750, 2400, 2600, 2900 });
	-- println("xxxxxxxxxxxxxxxx f")
	-- dumpObj(f)
	local q = Control.names({'q'}).kr(Ref{ 0.1, 0.10666666666667, 0.041666666666667,0.046153846153846, 0.041379310344828 });
	local a = Control.names({'a'}).kr(Ref{ 1, 0.28183829312645, 0.089125093813375, 0.1, 0.01 });
	local env=EnvGen.ar(Env.asr(0.1, 1.0, 0.1), gate, nil,nil,nil,2);
	local filters,filter,freqlag;
	local vibrato = SinOsc.kr(4,Rand(0,2*math.pi));
	freqlag=Lag.kr(freq,sweepRate*0.1);
	filters = Formant.ar(freqlag+vibrato, Lag.kr(f, sweepRate), Lag.kr(f*q, sweepRate), Lag.kr(a, sweepRate));
	filter=HPF.ar(Mix(filters),200)*env;
	return Out.ar(out, Pan2.ar(amp*filter,pan,amp ));
end);
sintes[#sintes+1]=formantVoice2
--]]

---[[
channel=SynthDef("channel", {busin=0, busout=0, level=1, pan=0,unmute=1},function()
						local l, r, out;
						--#l, r = In.ar(busin, 2);
						--out = Balance2.ar(l, r, pan, level*unmute);
						local canales = In.ar(busin, 2);
						out = Balance2.ar(canales[1], canales[2], pan, level*unmute*math.sqrt(2));
						ReplaceOut.ar(busin, out); -- for postsend
						Out.ar(busout, out);
					end);
sintes[#sintes+1]=channel
channel1x2=SynthDef("channel1x2", {busin=0, busout=0, level=1, pan=0,unmute=1},function()
						local canales = In.ar(busin, 1);
						local out = Pan2.ar(canales[1], pan, level*unmute*math.sqrt(2));
						ReplaceOut.ar(busin, out);
						Out.ar(busout, out);
					end);
sintes[#sintes+1]=channel1x2
--]]
---[[
envio=SynthDef("envio", {busin=0, busout=0, level=1},function()
				Out.ar(busout, In.ar(busin, 2) * level);
			end);
sintes[#sintes+1]=envio
envio=SynthDef("to_mono", {busin=0, busout=0, bypass=1},function()
				local input = In.ar(busin, 2)
				local effect = Mix(input)*0.5
				ReplaceOut.ar(busout,Select.ar(bypass,{effect,input}))
			end);
sintes[#sintes+1]=envio
--]]
---[[
bpeakeq=SynthDef("BPeakEQ", {busin=0, busout=0,freqEQ= 1200, rq= 1, db= -4,bypass=0},function()
	local input, effect;
	input=In.ar(busin,2); 
	effect = BPeakEQ.ar(input,freqEQ,rq,db)
	ReplaceOut.ar(busout,Select.ar(bypass,{effect,input}))
end)
sintes[#sintes+1]=bpeakeq

blowshelf=SynthDef("BLowShelf", {busin=0, busout=0,freqEQ= 1200, rs= 1, db= -4,bypass=0},function()
	local input, effect;
	input=In.ar(busin,2); 
	effect = BLowShelf.ar(input,freqEQ,rs,db)
	ReplaceOut.ar(busout,Select.ar(bypass,{effect,input}))
end)
sintes[#sintes+1]=blowshelf

bhightshelf=SynthDef("BHiShelf", {busin=0, busout=0,freqEQ= 1200, rs= 1, db= -4,bypass=0},function()
	local input, effect;
	input=In.ar(busin,2); 
	effect = BHiShelf.ar(input,freqEQ,rs,db)
	ReplaceOut.ar(busout,Select.ar(bypass,{effect,input}))
end)
sintes[#sintes+1]=bhightshelf


--]]
---[[
flangerb=SynthDef("flangerb", {busin=0, busout=0,flangefreq=0.1, fdback=0.25,flangems=20,bypass=0},function()
	local input, effect;
	flangems=flangems*0.001
	local msosc=flangems*0.5
	input=In.ar(busin,2); 
	local inputf= input + LocalIn.ar(2); --//add some feedback
	effect= DelayC.ar(inputf,flangems,SinOsc.kr(flangefreq*{1,1.01},0,msosc,msosc)); --//max delay of 20msec
	--without leakdc breaks in 3.5
	effect = LeakDC.ar(effect)
	
	LocalOut.ar(fdback*effect);
	--LocalOut.ar(fdback*BPF.ar(effect,MouseX.kr(1000,10000),0.1)); --alternative with filter in the feedback loop
	
	ReplaceOut.ar(busout,Select.ar(bypass,{0.5*(effect + input),input}))
	--Out.ar(busout,effect); --adds to bus 0 where original signal is already playing
end)
sintes[#sintes+1]=flangerb
--]]
spaceySynth2=SynthDef("spaceySynth2", {freq=440, out=0,ffreq=200,rq=0.2,pan=0,amp=0.5,gate=1,detF=0.001},function()
	local x, env;
	x = RLPF.ar(
		LFSaw.ar( freq,nil,EnvGen.kr( Env.asr(0.001,amp,0.3,-4),gate,amp,nil,nil,2 )),
		ffreq,--LFNoise1.kr(2, 56, 80).midicps,
		rq
	);
	--x = Mix(x)*{1-detF,1+detF}
	Out.ar(out, Pan2.ar(x,pan));
end);
sintes[#sintes+1]=spaceySynth2
---[[
sinte=SynthDef("phaser", {busin=0, busout=0,phaserfreq=0.2,phaserms=0.02},function()
	local input, effect;
	local msosc=phaserms*0.5 
	input=In.ar(busin,2); 
	--effect= AllpassN.ar(input,phaserms,SinOsc.kr(phaserfreq,0,msosc,msosc));
	effect= CombN.ar(input,phaserms,SinOsc.kr(phaserfreq,0,msosc,msosc)); 
	Out.ar(busout,effect);
end);  
--]]
---[[
BandCompander=SynthDef("BandCompander", {busin=0,busout=0,thresh=25,slopeBelow=1,slopeAbove=0.25,bypass=0},function()
    local input, chain;
	local fftsize = 2048
    input=In.ar(busin,2);
	--thresh=thresh:dbamp()
    chain = FFT({LocalBuf(fftsize),LocalBuf(fftsize)}, input);
    chain = PV_Compander(chain, thresh, slopeBelow, slopeAbove);
	local effect = IFFT.ar(chain) 
    ReplaceOut.ar(busout,Select.ar(bypass,{effect,input}))
end)
sintes[#sintes+1]=BandCompander

limiter=SynthDef("Limiter", {busin=0, busout=0,thresh=-10,dur=0.01,bypass=0,postGain=1},function()
	local input, effect; 
	input=In.ar(busin,2);
	thresh=thresh:dbamp()
	thresh=thresh:max(0.001)
	effect= Limiter.ar(input,thresh,dur)
	effect = effect / thresh
	ReplaceOut.ar(busout,Select.ar(bypass,{effect,input}))
end);
sintes[#sintes+1]=limiter

distorsion=SynthDef("Distorsion", {busin=0, busout=0,bypass=0,preGain=2},function()
	local input, effect; 
	input=In.ar(busin,1);
	effect = input * preGain
	effect=input:distort() 
	effect = effect * preGain
	effect=effect:distort()
	effect = effect * 2
	ReplaceOut.ar(busout,Select.ar(bypass,{effect,input}))

end);
sintes[#sintes+1]=distorsion

crossdistorsion=SynthDef("CrossDistorsion", {busin=0, busout=0,bypass=0,preGain=0.1,smooth=0.25},function()
	local input, effect; 
	input=In.ar(busin,1);
	effect = LeakDC.ar(input)
	effect = CrossoverDistortion.ar(effect,preGain,smooth)
	effect = LeakDC.ar(effect)
	ReplaceOut.ar(busout,Select.ar(bypass,{effect,input}))
end);
sintes[#sintes+1]=crossdistorsion

normalizer=SynthDef("Normalizer", {busin=0, busout=0,thresh=-10,dur=0.01,bypass=0,postGain=1},function()
	local input, effect; 
	input=In.ar(busin,2);
	thresh=thresh:dbamp()
	thresh=thresh:max(0.001)
	effect= Normalizer.ar(input,thresh,dur)
	--effect = effect / thresh
	ReplaceOut.ar(busout,Select.ar(bypass,{effect,input}))
end);    
sintes[#sintes+1]=normalizer

compander=SynthDef("Compander", {busin=0, busout=0,thresh=-10,slopeBelow=1,slopeAbove=0.25,clampTime=0.01,relaxTime=0.1,bypass=0,postGain=1},function()
	local input, effect; 
	input=In.ar(busin,2);
	thresh=thresh:dbamp()
	thresh=thresh:max(0.00001)
	effect= Compander.ar(input, input,
        thresh,
        slopeBelow,
        slopeAbove,
        clampTime,
        relaxTime
		,postGain/(thresh + ((1-thresh)*slopeAbove))
    );
	--ReplaceOut.ar(busout,effect)
	ReplaceOut.ar(busout,Select.ar(bypass,{effect,input}))
end);  
sintes[#sintes+1]=compander

compander2=SynthDef("Compander2", {busin=0, busout=0,thresh=-3,thresh2=-3,clampTime=0.01,relaxTime=0.1,bypass=0,postGain=1},function()
	local input, effect; 
	input=In.ar(busin,2);
	thresh=thresh:dbamp()
	thresh=thresh:max(0.00001):min(0.999)
	thresh2=thresh2:dbamp()
	thresh2=thresh2:max(0.00001):min(0.999)
	effect= Compander.ar(input, input,
        thresh,
        thresh2/thresh,
        (1-thresh2)/(1-thresh),
        clampTime,
        relaxTime
		,postGain
    );
	--ReplaceOut.ar(busout,effect)
	ReplaceOut.ar(busout,Select.ar(bypass,{effect,input}))
end);  
sintes[#sintes+1]=compander2

companderm=SynthDef("Companderm", {busin=0, busout=0,thresh=20,slopeBelow=1,slopeAbove=1/3,clampTime=0.01,relaxTime=0.1,gain=2},function()
	local input, effect; 
	input=In.ar(busin,1);
	thresh=thresh:dbamp()
	thresh=thresh:max(0.001)
	effect= Compander.ar(input, input,
        thresh,
        slopeBelow,
        slopeAbove,
        clampTime,
        relaxTime
		,1/(thresh+(1-thresh)*slopeAbove)
    );
	ReplaceOut.ar(busout,effect)
end);  
sintes[#sintes+1]=companderm

diskout=SynthDef("DiskoutSt", {bufnum=0,busin=0},function()
    DiskOut.ar(bufnum, In.ar(busin,2):clip2(1));
end)
sintes[#sintes+1]=diskout
--]]

--[[
-- with mix/dry (xfade)
sinte=SynthDef("delay", {busin=0, busout=0,delaytime=0.3,decaytime=4,xfade=1},function()
	local input, effect; 
	input=In.ar(busin,2);
	effect= CombL.ar(input, 4,delaytime,decaytime); 
	--XOut.ar(busout,Lag.kr(xfade,0.3),effect);
	Out.ar(busout,XFade2.ar(Silent.ar(), effect, Lag.kr(xfade,0.1) * 2 - 1))
	--Out.ar(busout,effect)
	--ReplaceOut.ar(busout,input)
end);  
--]]
--[[
-- with mix/dry (xfade)
sinte=SynthDef("delay", {busin=0, busout=0,delaytime=0.3,decaytime=4,xfade=1},function()
	local input, effect; 
	input=XFade2.ar(Silent.ar(), In.ar(busin,2), Lag.kr(xfade,0.1) * 2 - 1)
	--Linen.kr( gate = 1.0, attackTime = 0.01, susLevel = 1.0, releaseTime = 1.0, doneAction = 0 )
	effect= CombL.ar(input, 4,delaytime,decaytime); 
	--XOut.ar(busout,Lag.kr(xfade,0.3),effect);
	--Out.ar(busout,XFade2.ar(Silent.ar(), effect, Lag.kr(xfade,0.1) * 2 - 1))
	Out.ar(busout,effect)
	--ReplaceOut.ar(busout,input)
end);  
--]]
---[[
--with gated envelope
delay=SynthDef("delay", {busin=0, busout=0,delaytime=0.3,decaytime=4,gate=1,bypass=0,maxdelay=2},function()
	local input, effect,linen; 
	linen=Linen.kr( gate,0.1,1.0,decaytime,2)
	input= In.ar(busin,2)*linen
	delaytime = Lag.kr(delaytime)
	effect= CombL.ar(input,maxdelay,delaytime,decaytime)*linen; 
	Out.ar(busout,Select.ar(bypass,{effect,Silent.ar(1)}))
end);  
sintes[#sintes+1]=delay

---[[
soundin=SynthDef("SoundIn", {inp=0,out=0,gate=1},function()
	local env = EnvGen.ar(Env.asr(0,1,0.03),gate,nil,nil,nil,2)	
	--local input=In.ar(NumOutputBuses.ir()+inp,1)*env
    local input=SoundIn.ar(inp)*env
	Out.ar(out,LeakDC.ar(input))
end)
sintes[#sintes+1]=soundin
--]]
--]]

---[[
-- BPfiltered feedback chain an envelope
delayF=SynthDef("delayF", {gate=1,busin=0, busout=0,ffreq=1500,rq=0.4, fdback=0.25,delaytime=0.5,volumen=2,bypass=0},function()
	local input, effect,linen;
	linen=Linen.kr( gate,0.1,1.0,5,2)
	input=In.ar(busin,2)*linen; 
	input= input + fdback*LocalIn.ar(2)*linen;
	--input=BPF.ar(input,ffreq,rq)
	--input=Resonz.ar(input*linen,ffreq,rq)
	input=Resonz.ar(input,ffreq,rq)
	effect= DelayN.ar(input*linen,delaytime,delaytime-ControlDur.ir());
	effect=effect*linen	
	LocalOut.ar(effect)
	--LocalOut.ar(fdback*BPF.ar(effect,ffreq,rq));
	--Out.ar(busout,effect*volumen); --adds to bus 0 where original signal is already playing
	Out.ar(busout,Select.ar(bypass,{effect *volumen,Silent.ar(2)}))
end)
sintes[#sintes+1]=delayF
--]]
--[[
sinte=SynthDef("delayLocalBuf", {busin=0, busout=0,delaytime=0.3,decaytime=4},function()
	local input, effect; 
	input=In.ar(busin,2);
	effect=BufCombL.ar(LocalBuf(SampleRate.ir()*4, 2), input, delaytime, decaytime);
	Out.ar(busout,effect);
end);  
--]]
---[[
rbassb=SynthDef("rbassb", { out=0, freq = 1000, gate = 1, pan = 0.0, cut = 4800, rez = 0.5, amp = 0.7},function() 
	local  fltenv, ampenv, sig; 

    fltenv=EnvGen.kr(Env.adsr(0.02, 0.15, 0.05, 0.2, 1, -4)); 
    ampenv=EnvGen.kr(Env.adsr(0.03, 0.1, 0.7, 0.3), gate, 1,nil,nil,2); 
    Out.ar(out, 
        Pan2.ar( 
            MoogFF.ar( 
            LPF.ar( 
                Mix({ 
                Pulse.ar(freq*1.001, 0.5, amp), LFPar.ar(freq*(0.999), 0, amp*3):tanh()}), 
                freq*16), 
            (cut*fltenv), rez), 
        pan) * ampenv
    ) 
 end); 
 sintes[#sintes+1]=rbassb
 --]]
 ---[[
kik=SynthDef("kik", {freq=50,ratio=7,sweeptime=0.05,preamp=1,amp=1,decay1=0.3,
decay1L=0.8,decay2=0.15,out=0},function()
	local fcurve = EnvGen.kr(Env.new({freq * ratio, freq}, {sweeptime}, 'exp'))
	local env = EnvGen.kr(Env.new({1, decay1L, 0}, {decay1, decay2}, -4),nil,nil,nil,nil,2)
	local sig = SinOsc.ar(fcurve, 0.5*math.pi, preamp):distort() * env * amp;
	Out.ar(out,{sig,sig})
end);
sintes[#sintes+1]=kik
 --]]
 ---[[
kraftySnr=SynthDef("kraftySnr", {amp = 1, freq = 2000, rq = 3, decay = 0.3, pan=0, out=0},function()
	local	sig = PinkNoise.ar(amp)
	local	env = EnvGen.kr(Env.perc(0.01, decay),nil,nil,nil,nil,2);
	sig = BPF.ar(sig, freq, rq, env);
	Out.ar(out, Pan2.ar(sig, pan))
end);
sintes[#sintes+1]=kraftySnr
kraftySnr2=SynthDef("kraftySnr2", {amp = 1, freq = 2000, rq = 3, decay = 0.3, pan=0, out=0},function()
	local	sig = PinkNoise.ar(amp*15)
	local	env = EnvGen.kr(Env.perc(0.01, decay),nil,nil,nil,nil,2);
	sig = BPF.ar(sig, freq, rq, env);
	Out.ar(out, Pan2.ar(sig, pan))
end);
sintes[#sintes+1]=kraftySnr2
 --]]
 ---[[
PlayBuf1=SynthDef("PlayBuf1", { out = 0, bufnum = 0 ,rate=1,t_trigger=1,loop=0},function()
	Out.ar(out, 
		PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*rate,t_trigger,loop ,0)
	)
end)
sintes[#sintes+1]=PlayBuf1
--]]
 ---[[
PlayBuf2=SynthDef("PlayBuf2", { out = 0, bufnum = 0 ,rate=1,t_trigger=0,loop=0},function()
	Out.ar(out, 
		PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum)*rate,t_trigger,loop,0)
	)
end)
sintes[#sintes+1]=PlayBuf2
--]]


------------------------------------------------------


--klf={1,2,3,4,5,6,7};kla={1,1,1,1,1,1,1};klr={2,2,2,2,2,2,2}
--elpan=Klank.ar(Ref{klf, kla, klr},WhiteNoise.ar(),440)--*WhiteNoise.ar() 
--elpan=Control.names({'freq','klf','kla'}).kr(400,Ref{11,12,13},Ref(klf))
-- elpan=Control.names({'freq'}).kr(400)
--elpan=Control.names({'klf'}).kr(Ref{11,12,13})
-- elpan=Control.names({'klf2'}).kr(Ref(klf))

--prtable(elformvoice.syngraph)
----xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--sinte=elformvoice
--elformvoice:dumpInputs()
---[[
marimbaV=SynthDef("marimbaV", {out = 0, freq = 144, pan = 0,amp=1.0,decayscale=1},function()
	local e2 = EnvGen.kr(Env.perc(0.0, 5, amp, -4),nil,nil,nil,nil,2);
	local  i = Decay.ar(Impulse.ar(0), 0.01, ClipNoise.ar(amp));
	local z = Klank.ar(
			-- specs (partials, amplitudes, ringtimes)
		Ref{Ref{ 1, 3.9230769230769, 9.2366863905325, 16.266272189349, 24.218934911243, 33.544378698225, 42.970414201183 },
		Ref{1, 0.44668359215096, 0.63095734448019, 0.25118864315096, 0.31622776601684, 0.22387211385683, 0.22387211385683},
		Ref{1.5, 0.5, 0.3,0.3,0.05,0.03,0.03}},	
		i*e2,
		freq,
		0,
		decayscale --freq.linlin(0,500,1.5,0.1)//(freq-200)*(-0.5/200)+1		// scale decay times
	);
	Out.ar(out, Pan2.ar(z, pan));
end)
sintes[#sintes+1]=marimbaV
--]]
---[[
shaker=SynthDef("shaker",{density=3000,freqmod=300,amp = 1,attack=0.00,decay = 0.5,pan=0,out=0,gate=1,ffreq=4000},
	function ()
		--local sh= HPZ2.ar(Dust2.ar( Lag.kr( LFPulse.kr(2, 0.12, 10000), 0.1), 2 )) ;
		local sh= HPZ2.ar(Dust2.ar( density, 2 ))
		local signal=Resonz.ar( -- shaker
			sh*EnvGen.ar(Env.perc(attack,decay),gate,nil,nil,nil,2),
			SinOsc.ar(2, TRand.kr(0,math.pi*2,gate), freqmod, ffreq), 0.2);--TRand.ar(0,math.pi*2,gate)
		Out.ar(out,Pan2.ar(signal,pan,amp*20))
	end)
sintes[#sintes+1]=shaker
--]]
--[[
table.insert(initCbCallb
acks,function()
	sinte:dumpInputs()
	sinte:build()
	sinte:writeDefFile()
	loadSynthDef(Synth_path.."synthdefs\\"..sinte.name..".scsyndef",true)
	local tt=readSCSynthFile(Synth_path.."synthdefs\\"..sinte.name..".scsyndef")
	prtable(tt)
end)
--]]
--[[
_initCb()
--function initCb()
	print("path es:",SynthDefs_path)
	for k,sinte in ipairs(sintes) do
		print("building synth: ",sinte.name)
		sinte:build()
		print("writing synth: ",sinte.name)
		sinte:writeDefFile()
		loadSynthDef(SynthDefs_path..sinte.name..".scsyndef",true)
	end
--
_resetCb()
--]]
for k,sinte in ipairs(sintes) do
	print("storing synth: ",sinte.name)
	sinte:store()
end


