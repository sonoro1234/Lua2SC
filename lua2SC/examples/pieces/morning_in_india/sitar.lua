
SynthDef("sitarsoundboard", { busin=0, busout=0,size=2.8,mix=0.9,c1=20,c3=1,bypass=0},function()
	local inp=In.ar(busin,2); 
	inpM = inp:sum()
	local defdels = TA{199, 211, 223, 227, 229, 233, 239, 241}*size
	local snd = DWGSoundBoard.ar(inpM,c1,c3,mix,unpack(defdels))
	snd = snd + BPF.ar(snd, {90, 132, 280}, {1.3, 0.9, 1.4}, {0.9, 0.6, 0.7}):sum();
	ReplaceOut.ar(busout,Select.ar(bypass,{snd:dup(),inp}))
end):store();

SynthDef("sitar", { fnoise=2000,out=0, freq=440,freqBase=midi2freq(noteToNumber"C-2"), amp=0.5,t_gate=1, gate=1,pos=0.1,c1=0.75,c3=15,mistune = 1,noisemix=1,mp=0.55,gc=5,wfreq=3000,release=0.2,jw=12*2,fB=0*2,jora=0.25,chikari=0.25},function()

	local joraratios = TA{12,12.01,19,0}--,24,36}
	joraratios = joraratios:Do(midi2ratio)
	local chikariratios = TA{24,36}
	chikariratios = chikariratios:Do(midi2ratio)

	local env = Env.perc(0.01,0.02)
	local noise = (1-noisemix)+noisemix*PinkNoise.ar() 
	local inp =noise* EnvGen.ar(env,t_gate)
	
	inp = LPF.ar(inp,wfreq)
	
	local glide = 1 --+ EnvGen.ar(Env.new({0,0.05*amp,0}, {0,0.2},-8),t_gate);
	local son = MyPlucked.ar(freq, amp, gate,pos,c1,c3,inp*amp,release,jw/10000)

	local sndjora = MyPlucked.ar{freqBase* joraratios, pos= pos, c1= c1, c3= c3, inp= inp*jora, jw=jw/10000}
	sndjora = sndjora:Doi(function(v,i) 
		return Pan2.ar(v,(linearmap(1,#joraratios ,-1,1,i)))	
	end)
	sndjora = sndjora:sum()

	local sndchikari = MyPlucked.ar{freqBase* chikariratios, pos= pos, c1= c1, c3= c3, inp= inp*chikari, jw=jw/10000}
	sndchikari = sndchikari:Doi(function(v,i) 
		return Pan2.ar(v,(linearmap(1,#chikariratios ,-1,1,i)))	
	end)
	sndchikari = sndchikari:sum()

	son = son:dup() + sndjora + sndchikari
	Out.ar(out, son);

end):store();

SynthDef("sympathetic_Sitar", {
		busout = Master.busin, inscale = 1, freqBase = midi2freq(noteToNumber"C-2"), jw = 12*4,
		pos = 0.24,level=1,scaleratios = Ref(TA():Fill(7)),
		c1 = 3, c3 = 10,mono=0,
		},function()
		local inp, jawari, snd;
		local ratios1 = TA{12,12.01,19,0,24,36}:Do(midi2ratio)
		--local ratiossymp = (TA{7,9,11,12,14,16,17,19,21,23,24}+12):Do(midi2ratio)
		local scr = scaleratios
		local ratiosymp = TA{scr[5],scr[6],scr[7]}*2 .. scr*4 .. TA{scr[1]*8}
		local ratios = ratios1..ratiosymp
		inp = Mix(In.ar(busout,2))*inscale/1000
		inp = LPF.ar(inp,3000)
		snd = MyPlucked.ar{freqBase* ratios, pos= pos, c1= c1, c3= c3, inp= inp, jw=jw/10000}
		
		local sndmono = snd:sum()
		snd = snd:Doi(function(v,i) 
			return PanAz.ar(2,v,
			(linearmap(1,#ratios ,-1,1,i) + LFSaw.kr(0.1)))
		end)
		snd = snd:sum()
		local sig = Select.ar(mono,{snd,sndmono:dup()*0.5})
		Out.ar(busout, sig*level );
end):store(true)

local function SimpSynth(escale)
	local baseNote = numberToNote(getNote(1+7*3,escale))
	local scaleratios = (escale:notes()-escale:notes()[1])
	--unique? name for scale
	local sr_name = 0
	--first always 0
	for i=2,#scaleratios do
		sr_name = sr_name + scaleratios[i]
	end
	local synname = "sSitar"..baseNote..sr_name
	assert(#synname <31)
	scaleratios = scaleratios:Do(midi2ratio)
SynthDef(synname, {
		out = Master.busin, amp = 0.5,pano=0, freqBase = midi2freq(getNote(1+7*3,escale)), jw = 12*4,
		pos = 0.14,level=1,--scaleratios = Ref(TA():Fill(7)),
		c1 = 1, c3 = 10,t_trig=0,deltrig=0.12,
		},function()
		local inp, jawari, snd;
		local scr = scaleratios
		local ratiosymp = TA{scr[5],scr[6],scr[7]}*2 .. scr*4 .. TA{scr[1]*8}
		local ratios = ratiosymp
		
		inp = ratios:Doi(function(v,i)
			return PinkNoise.ar() * EnvGen.kr(Env.perc(0.01, 0.02):delay(deltrig*(#ratios-i)), t_trig) * amp
		end)
		
		inp = LPF.ar(inp,3000)
		snd = MyPlucked.ar{freqBase* ratios, pos= pos, c1= c1, c3= c3, inp= inp, jw=jw/10000}
		snd = snd:sum()
		Out.ar(out, Pan2.ar(snd*level,pano) );
end):store(true)
	return synname
end

local M = {}
function M.SitarPlayer(escale)
	
	local pl = OscEP{inst="sitar",dontfree=true,mono=true}
	pl.inserts = {{"sympathetic_Sitar",{
					freqBase=midi2freq(getNote(1+7*3,escale)), 
					scaleratios = Ref{(escale:notes()-escale:notes()[1]):Do(midi2ratio)}
				}},{"sitarsoundboard"}}
	return pl
end
function M.SympSitarPlayer(escale)
	
	local synname = SimpSynth(escale)
	local pl = OscEP{inst=synname,dontfree=true,mono=true}
	pl.inserts = {{"sympathetic_Sitar",{
					freqBase=midi2freq(getNote(1+7*3,escale)), 
					scaleratios = Ref{(escale:notes()-escale:notes()[1]):Do(midi2ratio)}
				}},{"sitarsoundboard"}}
	return pl
end

return M
