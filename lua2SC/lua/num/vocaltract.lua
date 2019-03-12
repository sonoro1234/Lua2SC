
local function MakeTractSynth(Tract,syname,args,excifunc,resamp)

	local defargs = {out=0, gate=1,t_gate=1, freq=60,amp=0.6,pan=0,lossG=0.97,lossL=0.97,lossN=0.95,lossF=1,area1len=8*22/17.5,Gain=1,lmix=1,nmix=1,fA0=1,Ar=Ref(TA():Fill(#Tract.areas.A,1.5)),ArN=Ref(Tract.AreaNoseC),lenT = 17.5,
--df=Ref(TA():Fill(#Tract.areas.A,1)),
noiseloc=0,glot=1,noisef=Ref{2500,7500},noisebw=Ref{1,1},plosive=0,fA=1,fAc=1,fAc2=1,thlev=0,fexci=6000,fout=18000,fPreoral=1}

	local function deffunc(excifunc)
		return function(newgt)
		setfenv(excifunc,newgt)
		if resamp then
			fA = fA*2
		end
		local exci = excifunc()
		--exci =   exci + Decay2.ar(Impulse.ar(LFDNoise3.kr(5,5,8)), 0.0005, 0.005)*4
		--exci =   Decay2.ar(Dust.ar(8), 0.0005, 0.005)*4
		--exci = Saw.ar(freq)
		exci = exci*amp --*Gain
		local env=EnvGen.ar(Env.asr(0.001, 1, 0.1), gate, nil,nil,nil,2);
		
		---[[
		local nsecs = math.floor(#Ar*0.5 + 0.5)
		--local pend = (1- fAc)/(nsecs - 2)
		local pend = (fAc2- fAc)/(nsecs - 2)

		for ii=2,nsecs do
			Ar[ii] = Ar[ii]*(fAc + (ii-2)*pend)
			--df[ii] = df[ii]*(fAc + (ii-1)*pend)
		end
		local pend2 = (1- fAc2)/(#Ar - (nsecs+1))
		for ii=nsecs+1,#Ar do
			Ar[ii] = Ar[ii]*(fAc2 + (ii-(nsecs+1))*pend2)
		end
		--]]
		--[[
		for ii=1,#Ar do
			Ar[ii] = Ar[ii]*fA0
		end
		--]]
		--Ar[1] = Ar[1]*fA0
		--Ar[#Ar] = Ar[#Ar]*fA0
		local noise = WhiteNoise.ar()*0.1*amp --*EnvGen.ar(Env({0,0,1},{0,0.08}),t_gate)
		noise = BBandPass.ar(noise,noisef,noisebw) --Resonz.ar(noise,noisef,0.08)
		noise = Mix(noise)
		lossF = (17/#Tract.areas.A)*4e-3*lossF

		local lenf = SampleRate.ir()*lenT*fA/(35000*#Ar) --35000 cm/seg

		local inioral = math.floor(0.4*#Ar)
		local dels = TA():Fill(#Tract.areas.A,lenf)
		for i=1,inioral do
			dels[i] = dels[i]*fPreoral
		end
--[[
		local fP2 = (1 - 0.4*fPreoral)/0.6
		for i=inioral+1,#Ar do
			dels[i] = dels[i]*fP2
		end
--]]
		local signal 
		if resamp then
			signal = HumanVNdelO2.ar(exci,noise,noiseloc,lossF,lossG,-lossL,-lossN,lmix,nmix,area1len,dels,Ar,ArN)*env 
		else
			signal = HumanVNdel.ar(exci,noise,noiseloc,lossF,lossG,-lossL,-lossN,lmix,nmix,area1len,dels,Ar,ArN)*env 
		end
		signal = signal*Gain
		local throat = LPF.ar(exci,400)
		signal = signal + throat*thlev
		signal = LPF.ar(signal,fout)
		signal = LeakDC.ar(signal,0.95)
		signal = Pan2.ar(signal*3,pan);
		return Out.ar(out, signal)
		end
	end
	for k,v in pairs(args) do
		defargs[k]=v
	end
	Tract[syname] = SynthDef(syname..Tract.NN,defargs,deffunc(excifunc)):store()
end

local function Rd2Times(Rd)
	local ra = (0.048*Rd-0.01)
	local rk = (0.118*Rd+0.224)
	local den = 0.44*Rd-4*ra*(0.5 + 1.2*rk)
	local rg = (0.5 + 1.2*rk)*rk/den
	local Ta = ra --*to
	local Tp = 1/(2*rg)
	local Te = Tp*(rk + 1)
	
	local num =34.83839405219 -9.3865444973664*Rd
	local den = 1 + 7.9184898828409*Rd
	alpha = num/den

	--local Ee = freq/(110*Rd)
	local Ee = 1/(Rd)
	return Tp,Te,Ta,alpha,Ee
end

local function MakeCoralSynth(Tract,name,freqs,resamp)
	Tract:MakeSynth(name,{Rd=0.3,namp=0.04,nwidth=0.4,vibrate=5,vibdeph=0.01,rv=0.05,jitter=0.01,vibampfac=20},
	function()
	
	--local freqs = TA():series(10,1 - 0.002*5,0.002)
	freqs = freq * freqs
	freqs = freqs + freqs * LFDNoise3.kr(10,jitter)
	local vibratoF =  Vibrato.kr{freqs, rate= vibrate, depth= vibdeph, delay= 0.0, onset= 0, 	rateVariation= rv, depthVariation= 0.1, iphase =  0}

	local Tp,Te,Ta,alpha,Ee = Rd2Times(Rd)

	local exci = LFglottal.ar(vibratoF,Tp,Te,Ta,alpha,namp,nwidth)*glot*3*Ee
	
	local excinoise =  WhiteNoise.ar()*plosive*Ee 
	--exci = exci + excinoise
	--exci = exci:Doi(function(v,i) return DelayC.ar(v,0.1,Rand(0,0.1)) end)
	--exci = exci:Doi(function(v,i) return DelayC.ar(v,0.2,LFDNoise3.kr(0.1,0.05,0.05))*SinOsc.ar(5,Rand(-math.pi,math.pi),0.3,0.7) end)
	exci = exci:Doi(function(v,i) return DelayC.ar(v,0.2,LFDNoise3.kr(0.1,0.05,0.05))*LFDNoise3.kr(5,0.3,0.7) end)
	exci = Mix(exci)
	exci = LPF.ar(exci,fexci)
	--exci =  BrownNoise.ar()*plosive*EnvGen.ar(Env({0,0,1},{0.02,0.04}),t_gate) + exci
	return exci +excinoise
	end,resamp)
end

local function LFexci()
		--freq = freq + freq*WhiteNoise.kr(0.01)
		--freq = freq + freq * LFDNoise3.kr(50,jitter)
		local jitfac = LFDNoise3.kr(2*10,jitter,1)
		local jitfac2 = LFDNoise3.kr(2*10,jitter*6,1)
		
		--local jsig = LFDNoise3.kr(4)+LFDNoise3.kr(10) +LFDNoise3.kr(20)*0.5
		--local jitfac = 1 + jsig*0.5*jitter
		
		freq = freq*jitfac
		local vibratoF =  Vibrato.kr{freq, rate= vibrate, depth= vibdeph, delay= 0.0, onset= 0, 	rateVariation= rv, depthVariation= 0.1, iphase =  0,trig=t_gate}
		local Tp,Te,Ta,alpha,Ee = Rd2Times(Rd*jitfac2)
		
		local exci = LFglottal.ar(vibratoF,Tp,Te,Ta,alpha,namp,nwidth)*glot*3*Ee
		--local exci = VeldhuisGlot.ar(vibratoF,Tp,Te,Ta,namp,nwidth)*glot*3*Ee
		exci =  WhiteNoise.ar()*plosive*Ee + exci
		exci = Mix(exci)
		exci = LPF.ar(exci,fexci)*jitfac2*SinOsc.ar(vibrate,nil,vibdeph*vibampfac,1)
		--exci =  BrownNoise.ar()*plosive*EnvGen.ar(Env({0,0,1},{0.02,0.04}),t_gate) + exci
		return exci
	end

local function InitSynths(Tract)
	Tract.Rd2Times = Rd2Times
	function Tract:MakeSynth(syname,args,excifunc,resamp)
		return MakeTractSynth(self,syname,args,excifunc,resamp)
	end
	function Tract:MakeCoralSynth(name,freqs,resamp)
		MakeCoralSynth(self,name,freqs,resamp)
	end

	local fratio = midi2ratio(0.05)
	local freqs = TA():gseries(10,1 * fratio^(-5),fratio)
	Tract:MakeCoralSynth("coral",freqs)
	Tract:MakeCoralSynth("coralO2",freqs,true)


	Tract:MakeSynth("sinteRd",{Rd=0.3,alpha=3.2,namp=0.04,nwidth=0.4,vibrate=5,vibdeph=0.01,rv=0.1,jitter=0.01,vibampfac=20},LFexci)
	Tract:MakeSynth("sinteRdO2",{Rd=0.3,alpha=3.2,namp=0.04,nwidth=0.4,vibrate=5,vibdeph=0.01,rv=0.1,jitter=0.01,vibampfac=20},LFexci,true)
	Tract:MakeSynth("sinte_chen",{OQ=0.8,asym=0.6,Sop=0.4,Scp=0.12,vibrate=5,vibdeph=0.01,rv=0.1},function()
		local vibratoF =  Vibrato.kr{freq, rate= vibrate, depth= vibdepth, delay= 0.0, onset= 0, 	rateVariation= rv, depthVariation= 0.1, iphase =  0}
		local exci = ChenglottalU.ar(vibratoF,OQ,asym,Sop,Scp)*glot*3
		exci = HPZ1.ar(exci)
		exci = LPF.ar(exci,fexci)*30
		exci =  WhiteNoise.ar()*plosive + exci
		return exci
	end)
	
end

local function Init(NN,male,resamp,DEFDUR,DEFRATE)

DEFDUR = DEFDUR or 0.1
DEFRATE = DEFRATE or 0.1
local MINIMAL = 0 --1e-9
local required
if male then
	required = "num.male_tract_data"
else
	required = "num.female_tract_data"
end
local Tract = require(required)(NN,resamp)
Tract.NN = NN
local function copy_phoneme(a,b)
	for k,v in pairs(Tract) do
		if type(v)=="table" and v[b] then
			v[a] = deepcopy(v[b])
		end
	end
end


Tract.areas.B = deepcopy(Tract.areas.P)
Tract.areas.D = deepcopy(Tract.areas.T)
Tract.areas.G = deepcopy(Tract.areas.K)

--Tract["areas"]["R"] = Tract["areas"]["L"]
Tract.areas.S = deepcopy(Tract.areas.N)
Tract.areas.Z = deepcopy(Tract.areas.M)
Tract.areas.F = deepcopy(Tract.areas.N)
Tract.areas[" "] = deepcopy(Tract.areas.Ae)
Tract.areas.H = deepcopy(Tract.areas.Ae)
------------------
Tract.glot = {}
Tract.glot.S = 0 --0.5
Tract.glot.F = 0
Tract.glot.Z = 0
Tract.glot[" "] = 0
Tract.glot.T = 1
Tract.glot.D = 1
Tract.glot.P = 0 --1
Tract.glot.B = 0 --0.25 --1 --0.5
Tract.glot.K = 0
Tract.glot.G = 1
Tract.glot.H = 0
Tract.plosive = {}
Tract.plosive.K = 0.5 --.5 --1 --0.5 --db2amp(-15)
Tract.plosive.G = 0
Tract.plosive.P  = 2 --0.5
Tract.plosive.B = 0.25
Tract.plosive.T = 2
Tract.plosive.D  = 0


Tract.plosive.H = 0.35
Tract.plosive.R = 0
-----------------------------
Tract.rate = {}
Tract.rate.K  = 0.02
Tract.rate.G  = 0.05
Tract.rate.S  = 0.02

Tract.rate.M = 0.03 --0.1 --0.05
Tract.rate.N = 0.03 --0.05
Tract.rate.R = 0.03 --0.05
Tract.rate.T = 0.02
Tract.rate.D = 0.05 --0.01
Tract.rate.B = 0.05
Tract.rate.P = 0 --0.05 --0.02 --0.01
Tract.rate.H = 0.01
Tract.rate._v = 0.01
Tract.gains._v = 0

Tract.rate.L = 0.1 --0.02
Tract.dur = {}
Tract.dur.Z = 0.1
Tract.dur.R = 0.05
Tract.dur.B = 0.05 --0.08
Tract.dur.P = 0.09 --0.09
Tract.dur.T = 0.08
Tract.dur.K = 0.09
Tract.dur.D = 0.05
Tract.dur.G = 0.05
Tract.dur.M = 0.1
Tract.dur.N = 0.1
Tract.krate = {}
Tract.krate.R = 0.02
Tract.krate.B = 0.07 --0.06
Tract.krate.P = 0.03 --0.01 --0.01
Tract.krate.T = 0.03
Tract.krate.D = 0.06
Tract.krate.K = 0.02
Tract.krate.G = 0.06
Tract.krate.S = 0.05
Tract.krate.M = 0.03 --0.07
Tract.krate.N = 0.03 --0.07
Tract.krate.H = 0.03
copy_phoneme("J","G")
Tract.gains.J = db2amp(6)
Tract.noise.J = deepcopy(Tract.noise.Z)
copy_phoneme("X","T")
Tract.noise.X = deepcopy(Tract.noise.S)
Tract.noise.X.freqs = {2500,5500}
Tract.plosive.X = 0
Tract.glot.X = 0
Tract.gains.X = db2amp(3)
copy_phoneme("_v"," ")
copy_phoneme("Nv","N")
copy_phoneme("Mv","M")
Tract.vocals = {A=true,Ae=true,E=true,I=true,I2=true,O=true,O1=true,O2=true,U1=true,U=true,Mv=true,Nv=true,[" "]=false,_v=true,Ate=true,Ete=true,Ite=true,Ote=true,Ute=true}
-------------------------------------------------------------------------------------------
copy_phoneme("_"," ")
Tract.dur._ = 0.00
Tract.krate._ = 0.00
copy_phoneme("Eq","E")
Tract.rate.Eq = 0.0
copy_phoneme("_q"," ")
Tract.rate._q = 0.0
Tract.dur._q = 0.01
Tract.krate._q = 0.0
--default noise
for ph,v in pairs(Tract.noise) do
	Tract.glot[ph] = Tract.glot.S
	Tract.krate[ph] = Tract.krate.S
	Tract.rate[ph] = Tract.rate.S
	Tract.areas[ph][#Tract.areas[ph]-1] = 1.6
	Tract.areas[ph][#Tract.areas[ph]] = 3
	--Tract.areas[ph][#Tract.areas.S] = 3
end
for k,v in pairs(Tract.areas) do
	Tract.len[k] = Tract.len[k] or Tract.deflen
end
--make closed
Tract.closed = {}
for ph,areas in pairs(Tract.areas) do
	local closed_secs = {}
	for i,v in ipairs(areas) do
		if v == 0 then closed_secs[#closed_secs + 1] = i;Tract.closed[ph] = closed_secs end
	end
end
--[[
--------convert zeros to tiny for allowing cub and exp curves
if true then
for k,par in pairs(Tract) do
	if type(par)=="table" then
		for k2,v in pairs(par) do
			if v==0 then
				par[k2] = MINIMAL
				print(k,k2,"minimal")
			elseif type(v)=="table" then
				for k3,v3 in pairs(v) do
					if v3==0 then
						v[k3] = MINIMAL
						print(k,k2,k3,"minimal")
					elseif type(v3)=="table" then
						for k4,v4 in pairs(v3) do
							if v4==0 then
								v3[k4] = MINIMAL
								print(k,k2,k3,k4,"minimal")
							end
						end
					end
				end
			end
		end
	end
end
end
--]]
-----------------------------------------------------------------------------------
InitSynths(Tract)

function Tract.get_sylabes(tex,sologuion)
	local phon = {}
	for m in tex:gmatch("[%u %-_][%l%d]*") do
		--print("match",m)
		table.insert(phon,m)
	end

	local syls = {}
	local j = 1
	local has_vocal = false
	for i,v in ipairs(phon) do
		has_vocal = Tract.vocals[v] or has_vocal
		local is_vocal = Tract.vocals[v]
		if sologuion then
			if has_vocal and (v=="-") then
				j = j + 1
				has_vocal = false
			end
		else
			if has_vocal and (not is_vocal) then
				j = j + 1
				has_vocal = false
			end
		end
		syls[j] = syls[j] or {}
		if v~="-" then
			table.insert(syls[j],v)
		end
	end
	--prtable(syls)
	return syls
end
function Tract.syl2phon(syl,allvocals)
	local totdur = 0
	local numvocals = 0
	local dur = 0
	local is_vocal
	local lastvocalpos = 0
	for i,v in ipairs(syl) do
		is_vocal = Tract.vocals[v] --or v==" "
		numvocals = numvocals + (is_vocal and 1 or 0)
		lastvocalpos = is_vocal and i or lastvocalpos
		dur = Tract.dur[v] or DEFDUR
		totdur = totdur + dur
	end
	local syl2 = {numvocals= allvocals and numvocals or 1,totdur=totdur,lastpos=lastvocalpos}
	local timetillvoc = 0
	for i,v in ipairs(syl) do
		dur = 0
		local usetotdur = false
		local rate = Tract.rate[v] or DEFRATE
		is_vocal = Tract.vocals[v] --or v==" "
		if is_vocal then
			rate = Tract.krate[syl[i-1]] or rate
			if allvocals or i == lastvocalpos then
				--local DURA = beats2Time(DURAT)
				--dur = (DURA - totdur +0.1) - rate
				dur = 0
				usetotdur = true
				--get time until first long vocal
				syl2.timetillvoc = syl2.timetillvoc or timetillvoc
			else
				dur = (Tract.dur[v] or DEFDUR) - rate
				timetillvoc = timetillvoc + dur + rate
			end
		--if is_vocal then
			--dur = (DURA - totdur)/numvocals
			--rate = Tract.krate[syl[i-1]] or rate
		else
			dur = (Tract.dur[v] or DEFDUR) - rate
			timetillvoc = timetillvoc + dur + rate
		end
		--dur = Time2beats(dur)
		dur = math.max(0,dur)
		syl2[i] = {v,rate,dur,Tract.krate[v],usetotdur=usetotdur}
	end
	return syl2
end
Tract.paramskey_speak = {"Ar","ArN","Gain","lenT","noiseloc","noisef","noisebw","glot","plosive","area1len","t_gate","advance"}

Tract.phon = {}
Tract.phon.keys = {"Ar","ArN","Gain","lenT","noiseloc","noisef","noisebw","glot","plosive","area1len","t_gate"}
function Tract.phon.get(ph)
	local res = {}
	local isN = Tract.nasal[ph]
	local gain = Tract.gains[ph] or 1
	local lenT = Tract.len[ph] or Tract.deflen

	local noise = Tract.noise[ph]
	local noiseloc = noise and noise.pos or MINIMAL --0
	local noisefreq = noise and noise.freqs or {2500,7500}
	local noisebw = noise and noise.bw or {0.1,0.1}

	local glot = Tract.glot[ph] or 1
	local plosive = Tract.plosive[ph] or MINIMAL --0
	
	return {{Tract.areas[ph]},isN and {Tract.AreaNose} or {Tract.AreaNoseC},gain,lenT,noiseloc,{noisefreq},{noisebw},glot,plosive,Tract.area1len,1}
end
function Tract.phon.getK(ph)
	local res = {}
	local isN = Tract.nasal[ph]
	local gain = Tract.gains[ph] or 1
	local lenT = Tract.len[ph] or Tract.deflen

	local noise = Tract.noise[ph]
	local noiseloc = noise and noise.pos or MINIMAL --0
	local noisefreq = noise and noise.freqs or {2500,7500}
	local noisebw = noise and noise.bw or {0.1,0.1}

	local glot = Tract.glot[ph] or 1
	local plosive = Tract.plosive[ph] or MINIMAL --0
	
	return {Ar={Tract.areas[ph]},ArN = ((isN and {Tract.AreaNose}) or {Tract.AreaNoseC}),Gain=gain,lenT=lenT,noiseloc=noiseloc,noisef={noisefreq},noisebw={noisebw},glot=glot,plosive=plosive,area1len=Tract.area1len,t_gate=1}
end
function Tract.phon.getArgs(ph)
	local res = {}
	local isN = Tract.nasal[ph]
	local gain = Tract.gains[ph] or 1
	local lenT = Tract.len[ph] or Tract.deflen

	local noise = Tract.noise[ph]
	local noiseloc = noise and noise.pos or MINIMAL --0
	local noisefreq = noise and noise.freqs or {2500,7500}
	local noisebw = noise and noise.bw or {0.1,0.1}

	local glot = Tract.glot[ph] or 1
	local plosive = Tract.plosive[ph] or MINIMAL --0
	
	return {Ar=Tract.areas[ph],ArN = ((isN and Tract.AreaNose) or Tract.AreaNoseC),Gain=gain,lenT=lenT,noiseloc=noiseloc,noisef=noisefreq,noisebw=noisebw,glot=glot,plosive=plosive,area1len=Tract.area1len,t_gate=1}
end
local function makeenv(t,name,val,rate,dur)
	local first = not t[name]
	t[name] = t[name] or {{},{}}
	table.insert(t[name][1],val)
	table.insert(t[name][1],val)
	if first then table.insert(t[name][1],val) end
	--if not first then table.insert(t[name][2],rate) end
	table.insert(t[name][2],rate)
	table.insert(t[name][2],dur)
end
local function makeenv_tgate(t,name,t1,t2)
	local first = not t[name]
	t[name] = t[name] or {{},{}}
	if first then table.insert(t[name][1],1) end
	table.insert(t[name][1],1)
	table.insert(t[name][1],0)
	
	--if not first then table.insert(t[name][2],rate) end
	table.insert(t[name][2],t1)
	table.insert(t[name][2],t2)
end
function Tract.doSpeak(syl,DURA,fade)
	assert(DURA)
	--print("DURA",DURA)
	DURA = beats2Time(DURA)
	local vocaldur = (DURA - (syl.totdur - DEFDUR*syl.numvocals))/syl.numvocals
	local res = {}
	local res_t_gate = {}
	--print"doSpeak"
	for i2,v in ipairs(syl) do
		local ph = v[1]
		local isN = Tract.nasal[ph]
		local rate = v.usetotdur and fade and vocaldur  or v[2]
		local gain = Tract.gains[ph] or 1
		local lenT = Tract.len[ph] or Tract.deflen

		local noise = Tract.noise[ph]
		local noiseloc = noise and noise.pos or MINIMAL --0
		local noisefreq = noise and noise.freqs or {2500,7500}
		local noisebw = noise and noise.bw or {0.1,0.1}

		local glot = Tract.glot[ph] or 1
		local plosive = Tract.plosive[ph] or MINIMAL --0
		
		assert(Tract.areas[ph],"ph is "..ph)
		local dur = v[3]
		if v.usetotdur then
			--dur = DURA - syl.totdur - rate
			dur = math.max(0,vocaldur - rate)
		end

		--assert(rate >=0)
		--assert(dur >=0)
		local tmpareas = Tract.areas[ph]
		--[=[
		if Tract.closed[ph] and syl[i2+1] then
			print("closing",ph,"to",syl[i2+1][1])
			tmpareas = deepcopy(Tract.areas[syl[i2+1][1]])
			for _,sec in ipairs(Tract.closed[ph]) do 
				tmpareas[sec] = 0
			end
		elseif Tract.fixed[ph] and syl[i2+1] then
			print("fiing",ph,"to",syl[i2+1][1])
			tmpareas = deepcopy(Tract.areas[syl[i2+1][1]])
			for _,sec in ipairs(Tract.fixed[ph]) do 
				tmpareas[sec] = Tract.areas[ph][sec]
			end
		else
			tmpareas = Tract.areas[ph]
		end
		--]=]
		makeenv(res,"Ar",tmpareas,rate,dur)
		makeenv(res,"ArN",isN and Tract.AreaNose or Tract.AreaNoseC,rate,dur)
		makeenv(res,"Gain",gain,rate,dur)
		makeenv(res,"lenT",lenT,rate,dur)
		--makeenv(res,"noiseloc",noiseloc,0,rate+dur)
		makeenv(res,"noiseloc",noiseloc,rate,dur)
		--makeenv_tgate(res_t_gate,"gate_t",0.01,rate+dur-0.01)
		makeenv_tgate(res_t_gate,"t_gate",0.01,rate+dur-0.01)
		makeenv(res,"noisef",noisefreq,rate,dur)
		makeenv(res,"noisebw",noisebw,rate,dur)
		makeenv(res,"glot",glot,rate,dur)
		makeenv(res,"plosive",plosive,rate,dur)
		makeenv(res,"area1len",Tract.area1len,rate,dur)
		--print(ph,rate,dur)
		--table.insert(res,{{Tract.areas[ph]},isN and {Tract.AreaNose} or {Tract.AreaNoseC},gain,rate,lenT,noiseloc,{noisefreq},{noisebw},glot,plosive,Tract.area1len,dur})
	end
	for k,p in pairs(res) do
		--res[k] = ENV(p[1],p[2],"cub",false,true) 
		res[k] = ENVm(p[1],p[2],"cub",false,true)
	end
	--res.t_gate = ENVstep(res_t_gate.t_gate[1],res_t_gate.t_gate[2],nil,false,true)
	res.t_gate = ENV(res_t_gate.t_gate[1],res_t_gate.t_gate[2],"step",false,true)
	res.advance = -Time2beats(syl.timetillvoc)
	return res
end

function Tract.doSpeakXtime(syl,fade)
	--local vocaldur = (DURA - (syl.totdur - DEFDUR*syl.numvocals))/syl.numvocals
	local vocaldur_minus = (syl.totdur - DEFDUR*syl.numvocals)/syl.numvocals
	local res = {}
	--DURA = beats2Time(DURA)
	for i2,v in ipairs(syl) do
		local ph = v[1]
		local isN = Tract.nasal[ph]
		local rate = v.usetotdur and fade and vocaldur  or v[2]
		local gain = Tract.gains[ph] or 1
		local lenT = Tract.len[ph] or Tract.deflen

		local noise = Tract.noise[ph]
		local noiseloc = noise and noise.pos or 0
		local noisefreq = noise and noise.freqs or {2500,7500}
		local noisebw = noise and noise.bw or {0.1,0.1}

		local glot = Tract.glot[ph] or 1
		local plosive = Tract.plosive[ph] or 0
		
		assert(Tract.areas[ph],"ph is "..ph)
		local dur = v[3]
		local rate_plus_dur = dur + rate
		if v.usetotdur then
			--dur = DURA - syl.totdur - rate
			dur = function(DURA) return DURA/syl.numvocals - rate - vocaldur_minus end
			rate_plus_dur = function(DURA) return DURA/syl.numvocals - vocaldur_minus end
		end

		--assert(rate >=0)
		--assert(dur >=0)
		makeenv(res,"Ar",Tract.areas[ph],rate,dur)
		makeenv(res,"ArN",isN and Tract.AreaNose or Tract.AreaNoseC,rate,dur)
		makeenv(res,"Gain",gain,rate,dur)
		makeenv(res,"lenT",lenT,rate,dur)
		makeenv(res,"noiseloc",noiseloc,0,rate_plus_dur)
		makeenv(res,"gate_t",1,0,rate_plus_dur)
		makeenv(res,"noisef",noisefreq,rate,dur)
		makeenv(res,"noisebw",noisebw,rate,dur)
		makeenv(res,"glot",glot,rate,dur)
		makeenv(res,"plosive",plosive,rate,dur)
		makeenv(res,"area1len",Tract.area1len,rate,dur)

		--table.insert(res,{{Tract.areas[ph]},isN and {Tract.AreaNose} or {Tract.AreaNoseC},gain,rate,lenT,noiseloc,{noisefreq},{noisebw},glot,plosive,Tract.area1len,dur})
	end
	for k,p in pairs(res) do
		--print(k)
		--prtable(p)
		res[k] = ENVmx(p[1],p[2],nil,false)
	end
	return res
end
function Tract:TalkS(pat,tex,sologuion,allvocals,fade)
	local syls = self.get_sylabes(tex,sologuion)
	--prtable(syls)
	local syls2 = {}
	for i,v in ipairs(syls) do
		table.insert(syls2,Tract.syl2phon(v,allvocals))
	end
	--prtable(syls2)
	syls = LOOP(syls2)
	return SF(pat,function(ret,e) 
		local syl = syls:nextval()
		if not syl then return nil end
		--if IsREST(ret.note) or IsREST(ret.freq) or IsREST(ret._dummy) then return ret end
		--prtable(syl)
		local ret2 = Tract.doSpeak(syl,ret.dur,fade)
		--prtable(ret2)
		for k,v in pairs(ret) do
			ret2[k] = v
		end
--		print"ret2"
		--prtable(syl)
		--prtable(ret2.glot)
		--local sum = 0
		--for ii,vv in ipairs(ret2.glot.times) do sum = sum + vv end
		--print("sum = ",sum)
		return ret2 
	end)
end
function Tract:doTalk(tex,sologuion,allvocals,fade)
	local syls = self.get_sylabes(tex,sologuion)
	--prtable(syls)
	local syls2 = {}
	for i,v in ipairs(syls) do
		table.insert(syls2,Tract.syl2phon(v,allvocals))
	end
	--prtable(syls2)
	--syls = LOOP(syls2)
	return SF(LS(syls2),function(ret,e) 
		--prtable(ret)
		--prtable(e.tmplist)
		local ret2 = Tract.doSpeak(ret,e.tmplist.dur,fade)
		--prtable(ret2)
		local ret = {}
		for i,v in ipairs(self.paramskey_speak) do
			ret[i] = ret2[v]
		end
		--prtable(ret2)
		return ret 
	end)
end
function Tract:doTalkX(tex,sologuion,allvocals,fade)
	local syls = self.get_sylabes(tex,sologuion)
	--prtable(syls)
	local syls2 = {}
	for i,v in ipairs(syls) do
		table.insert(syls2,Tract.syl2phon(v,allvocals))
	end
	local ret,ret2 = {},{}
	for i2,v2 in ipairs(syls2) do
		ret2[i2] = Tract.doSpeakXtime(v2,fade)
		ret[i2]={}
		for i,v in ipairs(self.paramskey_speak) do
			ret[i2][i] = ret2[i2][v]
		end
	end
	--prtable(syls2)
	--syls = LOOP(syls2)
	return LS(ret)

end
local function get_phonemes(tex,DURAT)
	--local 
	--DURA = DURA or 1
--	local vocals = "[AEIOUMN]"
--	local not_vocals = "[^AEIOUMN]"
--	local l_plus_vocals = "[%l%dAEIOUMN]"
--	local not_l_plus_vocals = "[^%l%dAEIOUMN]*"
--	--"(%u[%l%d]*)"
--	local pat = "("..not_l_plus_vocals.."[%l%d]*"..vocals.."*".."[%l%d]*"..")"
--	local pat = "("..not_l_plus_vocals.."[%l%d]*"..l_plus_vocals.."+"..")"
	local phon = {}
	for m in tex:gmatch("[%u %-][%l%d]*") do
		--print("match",m)
		table.insert(phon,m)
	end
	local syls = {}
	local j = 1
	local has_vocal = false
	for i,v in ipairs(phon) do
		has_vocal = Tract.vocals[v] or has_vocal
		local is_vocal = Tract.vocals[v]
		if has_vocal and (not is_vocal) then
			j = j + 1
			has_vocal = false
		end
		syls[j] = syls[j] or {}
		if v~="-" then
			table.insert(syls[j],v)
		end
	end
	prtable(syls)
	for is,syl in ipairs(syls) do
		local totdur = 0
		local numvocals = 0
		local dur = 0
		local is_vocal
		local lastvocalpos = 0
		for i,v in ipairs(syl) do
			is_vocal = Tract.vocals[v] --or v==" "
			numvocals = numvocals + (is_vocal and 1 or 0)
			lastvocalpos = is_vocal and i or lastvocalpos
			dur = Tract.dur[v] or DEFDUR
			totdur = totdur + dur
		end
		local syl2 = {}
		for i,v in ipairs(syl) do
			dur = 0
			local rate = Tract.rate[v] or DEFRATE
			is_vocal = Tract.vocals[v] --or v==" "
			if is_vocal then
				rate = Tract.krate[syl[i-1]] or rate
				if i == lastvocalpos then
					local DURA = beats2Time(WrapAt(DURAT,is))
					dur = (DURA - totdur + DEFDUR)
				else
					dur = Tract.dur[v] or DEFDUR
				end
			--if is_vocal then
				--dur = (DURA - totdur)/numvocals
				--rate = Tract.krate[syl[i-1]] or rate
			else
				dur = Tract.dur[v] or DEFDUR
				--totdur = totdur + dur
			end
			dur = Time2beats(dur)
			syl2[i] = {v,rate,dur,Tract.krate[v]}
		end
		syls[is]=syl2
	end
	--prtable(syls)
	return syls
end
Tract.get_phonemes = get_phonemes
function Tract.doM(args,dd)
	dd = dd or 1
	local res = {}
	local syls = get_phonemes(args,dd)
	--prtable(syls)
	--local args = {...}
	for i,syl in ipairs(syls) do
		for i2,v in ipairs(syl) do
			local ph = v[1]
			local isN = Tract.nasal[ph]
			local rate = v[2]
			local gain = Tract.gains[ph] or 1
			local lenT = Tract.len[ph] or Tract.deflen

			local noise = Tract.noise[ph]
			local noiseloc = noise and noise.pos or 0
			local noisefreq = noise and noise.freqs or {2500,7500}
			local noisebw = noise and noise.bw or {0.1,0.1}

			local glot = Tract.glot[ph] or 1
			local plosive = Tract.plosive[ph] or 0
			
			assert(Tract.areas[ph],"ph is "..ph)
			local dur = v[3]
			table.insert(res,{{Tract.areas[ph]},isN and {Tract.AreaNose} or {Tract.AreaNoseC},gain,rate,lenT,noiseloc,{noisefreq},{noisebw},glot,plosive,Tract.area1len,dur})
		end
	end
	prtable(res)
	return res
end
function Tract.doMnodur(args,dd)
	dd = dd or 1
	local res = {}
	local syls = get_phonemes(args,1)
	prtable(syls)
	--local args = {...}
	for i,syl in ipairs(syls) do
		for i2,v in ipairs(syl) do
			local ph = v[1]
			local isN = Tract.nasal[ph]
			local rate = v[2]
			local gain = Tract.gains[ph] or 1
			local lenT = Tract.len[ph] or Tract.deflen

			local noise = Tract.noise[ph]
			local noiseloc = noise and noise.pos or 0
			local noisefreq = noise and noise.freqs or {2500,7500}
			local noisebw = noise and noise.bw or {0.1,0.1}

			local glot = Tract.glot[ph] or 1
			local plosive = Tract.plosive[ph] or 0
			
			assert(Tract.areas[ph],"ph is "..ph)
			local dur = v[3]
			table.insert(res,{{Tract.areas[ph]},isN and {Tract.AreaNose} or {Tract.AreaNoseC},gain,rate,lenT,noiseloc,{noisefreq},{noisebw},glot,plosive,Tract.area1len})
		end
	end
	prtable(res)
	return res
end
Tract.paramskey = {"Ar","ArN","Gain","rate","lenT","noiseloc","noisef","noisebw","glot","plosive","area1len","dur"}
Tract.paramskey_nodur = {"Ar","ArN","Gain","rate","lenT","noiseloc","noisef","noisebw","glot","plosive","area1len"}
	function Tract:Talk(frase,allvocals,fade)
		return {[Tract.paramskey_speak] = LS{Tract:doTalk(frase,true,allvocals,fade)}}
	end

	return Tract
end

return Init