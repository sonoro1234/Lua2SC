
SynthDef("tamboura_soundboard", { busin=0, busout=0,size=2.8,mix=0.8,bypass=0},function()
	local inp=Mix(In.ar(busin,2)); 
	local defdels = TA{199, 211, 223, 227, 229, 233, 239, 241}*size
	son = DWGSoundBoard.ar(inp,20,20,mix,unpack(defdels))
	ReplaceOut.ar(busout,Select.ar(bypass,{son:dup(),inp}))
end):store();

SynthDef("tamboura", { fnoise=2000,out=0, freq=440, amp=0.5,t_gate=1, gate=1,pos=1-1/7,c1=0.5,c3=15,mistune = 1,noisemix=0.2,mp=0.55,gc=5,wfreq=3000,release=0.2,jw=12,fB=0*2},function()

	local env = Env.perc(0.02,0.02)
	local noise = (1-noisemix)+noisemix*LFClipNoise.ar(fnoise) --LFClipNoise.ar(fnoise)
	local inp =amp*noise* EnvGen.ar(env,t_gate)
	inp = LPF.ar(inp,wfreq)
	local glide = 1 + EnvGen.ar(Env.new({0,0.05*amp,0}, {0,0.2},-8),t_gate);
	local son = MyPlucked2.ar(freq*glide, amp, gate,pos,c1,c3,inp,release,1+mistune/1000,mp,gc/1000,jw/10000)
	Out.ar(out, Pan2.ar(Mix(son*0.3) ,pan));

end):store(true);

SynthDef("sympathetic_Tamboura", {
		busout = Master.busin, inscale = 1, freq = midi2freq(noteToNumber"G2"), jw = 12,
		pos = 0.14,level=1,
		c1 = 0.25, c3 = 10,
		},function()
		local inp, jawari, snd;
		local ratios = TA{0,7,12,12.01}:Do(midi2ratio)
		inp = Mix(In.ar(busout,2))*inscale/1000
		snd = MyPlucked.ar{freq* ratios, pos= pos, c1= c1, c3= c3, inp= inp, jw=jw/10000}

		snd = snd:Doi(function(v,i) 
			return PanAz.ar(2,v,
			(linearmap(1,#ratios ,-1,1,i) + LFSaw.kr(0.1)))
		end)
		snd = snd:sum()
		Out.ar(busout, snd*level );
end):store(true)

local function TambouraPlayer(escale)
	local pl = OscVoicerEP{inst="tamboura"}
	pl.inserts = {{"synpathetic_Tamboura",{freq=midi2freq(getNote(1+7*3,escale))}},{"tamboura_soundboard"}}
	return pl
end


return TambouraPlayer
