
return function(NN)
local required = string.format("num.tract_male%d",NN)
local Tract = require(required)
local function copy_phoneme(a,b)
	for k,v in pairs(Tract) do
		if type(v)=="table" and v[b] then
			v[a] = v[b]
		end
	end
end
copy_phoneme("Nv","N")
copy_phoneme("Mv","M")
Tract["areas"]["B"] = Tract["areas"]["P"]
Tract["areas"]["D"] = Tract["areas"]["T"]

--Tract["areas"]["R"] = Tract["areas"]["L"]
Tract["areas"]["S"] = Tract["areas"]["N"]
Tract["areas"]["S"][#Tract.areas.S] = 3
Tract["areas"]["F"] = Tract["areas"]["M"]
Tract["areas"]["Z"] = Tract["areas"]["F"]
Tract["areas"][" "] = Tract["areas"]["Ae"]
Tract.rate = {}
Tract.rate.K  = 0
Tract.rate.S  = 0
Tract.rate.M = 0.05
Tract.rate.N = 0.05
Tract.rate.R = 0.05
Tract.rate.T = 0.01
Tract.rate.B = 0.05
Tract.rate.D = 0.01
Tract.rate[" "] = 0.01
Tract.rate.P = 0.01
Tract.rate.L = 0
Tract.dur = {}
Tract.dur.Z = 0.1
Tract.dur.R = 0.05
Tract.dur.B = 0.08
Tract.dur.P = 0.08
Tract.dur.T = 0.08
Tract.dur.K = 0.02
Tract.dur.D = 0.05
Tract.krate = {}
Tract.krate.R = 0.02
Tract.krate.P = 0.06
Tract.krate.T = 0.03
Tract.krate.D = 0.06
Tract.krate.B = 0.06
Tract.krate.S = 0.05
Tract.vocals = {A=true,Ae=true,E=true,I=true,O=true,U1=true,U=true,Mv=true,Nv=true,[" "]=true}
-----------------------------------------------------------------------------------
function GlottalRossB(N,fac1,fac2)
	local datos = {}
	N = N or 100
	fac1 = fac1 or 0.4
	fac2= fac2 or 0.36
	fac2 = fac1 + fac2
	local N1 = math.floor(fac1*N)
	local N2 = math.floor(fac2*N)
	for i=0,N do

		if i<N1 then
			datos[i] = 3*(i/N1)^2 - 2*(i/N1)^3
		elseif i < N2 then
			datos[i]= 1 - ((i - N1)/(N2 - N1))^2
		else
			datos[i] = 0
		end
	end
	--datos = differenciate(datos)
	return datos
end
function GlottalRossBP(N,fac1,fac2)
	local datos = {}
	N = N or 100
	fac1 = fac1 or 0.4
	fac2= fac2 or 0.16
	fac2 = fac1 + fac2
	local N1 = math.floor(fac1*N)
	local N2 = math.floor(fac2*N)
	for i=0,N do

		if i<N1 then
			--datos[i] = 3*(i/N1)^2 - 2*(i/N1)^3
			datos[i+1] = 50*(6*(i/N1) - 6*(i/N1)^2)/N1
		elseif i < N2 then
			--datos[i]= 1 - ((i - N1)/(N2 - N1))^2
			datos[i+1]=  - 50*2*((i - N1)/(N2 - N1))/(N2 - N1)
		else
			datos[i+1] = 0 --50*0.005*(2*math.random()-1)
		end
	end
	--datos = differenciate(datos)
	return datos
end
--local elbuf = DataBuffer(GlottalRossBP(math.floor(44100/400),0.4,0.25))

--local elbuf1 = DataBuffer(GlottalRossBP(math.floor(44100/400),1,0))
--local elbuf2 = DataBuffer(GlottalRossBP(math.floor(44100/400),0,1))

Area = Tract.areas.A
--AreaNose = {0,1.35,1.7,1.7,1.3,0.9}
Tract.sinte=SynthDef("testHumanVN"..NN, {samples= 1,out=0, gate=1,t_gate=1, freq=60,amp=0.6,pan=0,lossG=0.95,lossL=0.95,lossN=0.95,lossT=1,lossF=1,rate=2,rateN=1,gainE=1,excibuf=0,excibuf1=0,excibuf2=0,area1len=8*22/17.5,gainN=gainN,Gain=1,lmix=1,nmix=1,Ar=Ref(TA():Fill(#Area,1.5)),ArN=Ref(Tract.AreaNose),lenT = 17.5,df=Ref(TA():Fill(#Area,1)),noiseloc=0,glot=1,noisef=Ref{2500,7500},noisebw=Ref{1,1},plosive=0,fA=1,fAc=1,fG1=0.4,fG2=0.2,fG2f=1,thlev=0.4,fexci=6000,Tp=0.4,Tefac=1.15,Ta=0.028},function ()
	local srdur = SampleDur.ir()
	--freq = {freq,freq*1.01,freq*1.03,freq*0.98}
	local vibratoF =  Vibrato.kr{freq, rate= 5, depth= 0.01, delay= 0.2, onset= 0, rateVariation= 0.5, depthVariation= 0.1, iphase =  0}
	--glot = Lag.kr(glot,rate)
	glot  = EnvGen.kr(Env({glot,glot},{rate}),t_gate)
	Gain  = EnvGen.kr(Env({Gain,Gain},{rate}),t_gate)
	plosive  = EnvGen.kr(Env({plosive,plosive},{rate}),t_gate)

	local exci = LFglottal.ar(vibratoF,Tp,Tefac,Ta)*Gain*amp*glot*3

	--local exci = PlayBuf.ar(1,excibuf,vibratoF/100,Impulse.ar(vibratoF),0,0,0)*Gain*amp*glot*3
	--local exci = PlayBuf.ar(1,excibuf,1,Impulse.ar(vibratoF),0,0,0)*Gain*amp*glot 
--[[
	local trigexci = Impulse.ar(vibratoF)
	local phasor1  = EnvGen.ar(Env({0.0,0.0,1,0},{0,vibratoF:reciprocal()*fG1,0},0),trigexci)
	local phasor2  = EnvGen.ar(Env({0.0,0.0,1,0},{vibratoF:reciprocal()*fG1,vibratoF:reciprocal()*fG2,0},0),trigexci)
	local exci = BufRd.ar(1, excibuf1, phasor1*BufFrames.kr(excibuf1),0,2)*Gain*amp*glot/fG1
	local exci2 = BufRd.ar(1, excibuf2, phasor2*BufFrames.kr(excibuf2),0,2)*Gain*amp*glot/fG2*fG2f
	exci = exci + exci2
--]]
	--local lenexci1 = 0.01
	--local exci1 = Trig.ar(T2A.ar(t_gate),lenexci1)*10 --Blip.ar(300)*10 *LinLin.kr(lenexci1,0.003,0.04,1.25,0.5)
	--exci = exci1
	--exci = HPZ1.ar(exci)*30
	exci = LPF.ar(exci,fexci)
	exci = exci + PinkNoise.ar()*plosive*EnvGen.ar(Env({0,0,1},{0,0.04}),t_gate)*1
	
	--local exci = Impulse.ar(vibratoF)
	local env=EnvGen.ar(Env.asr(0.1, 1, 0.1), gate, nil,nil,nil,2);
	--local perdidas = TA{lossG}..TA():Fill(#KK,lossT)..TA{-lossL}
	--local times = TA():Fill(#KK + 1,segs/(#KK + 1))
	--local times = TA():Fill(#KK + 1,samples*SampleDur.ir())
	--local signal=NTube.ar(exci,Lag.kr(perdidas,rate),Lag.kr(Karr,rate),Lag.kr(times,rate))*env*Lag.kr(Gain,rate)
	--local signal= KLJunction.ar(exci,perdidas,Karr,times) --*0.1 --*env*Lag.kr(Gain,rate)
	
	Ar  = EnvGen.kr(Env({Ar,Ar},{rate}),t_gate)
	ArN  = EnvGen.kr(Env({ArN,ArN},{rate}),t_gate)
	local nsecs = 7
	local pend = (1- fAc)/(nsecs - 1)
	for ii=1,nsecs do
		Ar[ii] = Ar[ii]*(fAc + (ii-1)*pend)
	end
	--Ar = Ar*fA
	--Ar = Lag.kr(Ar,rate)
	--Ar = VarLag.kr(Ar,rate,0)
	--local signal = HumanV.ar(exci,lossT,lossG,-lossL,-lossN,Ar)*10*Lag.kr(Gain,rate)
	--local signal = HumanVN.ar(exci,lossF,lossG,-lossL,-lossN,lmix,nmix,area1len,Ar,Lag.kr(ArN,rateN))*10*Lag.kr(Gain,rate)
	local noise = WhiteNoise.ar()*EnvGen.ar(Env({0,0,1},{0,0.08}),t_gate)*0.2*amp
	noise = BBandPass.ar(noise,noisef,noisebw) --Resonz.ar(noise,noisef,0.08)
	noise = Mix(noise)
	lossF = (17/#Area)*4e-3*lossF
	lenT  = EnvGen.kr(Env({lenT,lenT},{rate}),t_gate)
	--lenT = 17
	--local dels = TA():Fill(#Ar,SampleRate.ir()*lenT*fA/(35000*#Ar))
	local lenf = SampleRate.ir()*lenT*fA/(35000*#Ar)
	local dels = df*lenf
	local signal = HumanVNdel.ar(exci,noise,noiseloc,lossF,lossG,-lossL,-lossN,lmix,nmix,area1len,dels,Ar,ArN)*env --Lag.kr(Gain,rate)
	--signal=HPF.ar(signal,100);
	--signal = LPF.ar(signal,14000)
	local throat = LPF.ar(exci,400)
	signal = signal + throat*thlev
	--signal = HPZ1.ar(signal)*50
	--return Out.ar(out, signal);
	signal = LeakDC.ar(signal,0.91)
	return Out.ar(out,  Pan2.ar(signal,pan));
end):store() --:play({freq=150})

Tract.sinte2=SynthDef("test2HumanVN"..NN, {samples= 1,out=0, gate=1,t_gate=1, freq=60,amp=0.6,pan=0,lossG=0.95,lossL=0.95,lossN=0.95,lossT=1,lossF=1,gainE=1,excibuf=0,excibuf1=0,excibuf2=0,area1len=8*22/17.5,gainN=gainN,Gain=1,lmix=1,nmix=1,Ar=Ref(TA():Fill(#Area,1.5)),ArN=Ref(Tract.AreaNose),lenT = 17.5,df=Ref(TA():Fill(#Area,1)),noiseloc=0,glot=1,noisef=Ref{2500,7500},noisebw=Ref{1,1},plosive=0,fA=1,fAc=1,fG1=0.4,fG2=0.2,fG2f=1,thlev=0.4,fexci=6000,Tp=0.4,Tefac=1.15,Ta=0.028},function ()
	local srdur = SampleDur.ir()
	--freq = {freq,freq*1.01,freq*1.03,freq*0.98}
	local vibratoF =  Vibrato.kr{freq, rate= 5, depth= 0.01, delay= 0.2, onset= 0, rateVariation= 0.5, depthVariation= 0.1, iphase =  0}
	--glot = Lag.kr(glot,rate)
	--glot  = EnvGen.kr(Env({glot,glot},{rate}),t_gate)
	--Gain  = EnvGen.kr(Env({Gain,Gain},{rate}),t_gate)
	--plosive  = EnvGen.kr(Env({plosive,plosive},{rate}),t_gate)

	local exci = LFglottal.ar(vibratoF,Tp,Tefac,Ta)*Gain*amp*glot*3

	--local exci = PlayBuf.ar(1,excibuf,vibratoF/100,Impulse.ar(vibratoF),0,0,0)*Gain*amp*glot*3
	--local exci = PlayBuf.ar(1,excibuf,1,Impulse.ar(vibratoF),0,0,0)*Gain*amp*glot 
--[[
	local trigexci = Impulse.ar(vibratoF)
	local phasor1  = EnvGen.ar(Env({0.0,0.0,1,0},{0,vibratoF:reciprocal()*fG1,0},0),trigexci)
	local phasor2  = EnvGen.ar(Env({0.0,0.0,1,0},{vibratoF:reciprocal()*fG1,vibratoF:reciprocal()*fG2,0},0),trigexci)
	local exci = BufRd.ar(1, excibuf1, phasor1*BufFrames.kr(excibuf1),0,2)*Gain*amp*glot/fG1
	local exci2 = BufRd.ar(1, excibuf2, phasor2*BufFrames.kr(excibuf2),0,2)*Gain*amp*glot/fG2*fG2f
	exci = exci + exci2
--]]
	--local lenexci1 = 0.01
	--local exci1 = Trig.ar(T2A.ar(t_gate),lenexci1)*10 --Blip.ar(300)*10 *LinLin.kr(lenexci1,0.003,0.04,1.25,0.5)
	--exci = exci1
	--exci = HPZ1.ar(exci)*30
	exci = LPF.ar(exci,fexci)
	exci = exci + PinkNoise.ar()*plosive *EnvGen.ar(Env({0,0,1},{0,0.04}),t_gate)*1
	
	--local exci = Impulse.ar(vibratoF)
	local env=EnvGen.ar(Env.asr(0.1, 1, 0.1), gate, nil,nil,nil,2);

	
	--Ar  = EnvGen.kr(Env({Ar,Ar},{rate}),t_gate)
	--ArN  = EnvGen.kr(Env({ArN,ArN},{rate}),t_gate)
	local nsecs = 7
	local pend = (1- fAc)/(nsecs - 1)
	for ii=1,nsecs do
		Ar[ii] = Ar[ii]*(fAc + (ii-1)*pend)
	end

	local noise = WhiteNoise.ar()*0.2*amp *EnvGen.ar(Env({0,0,1},{0,0.08}),t_gate)
	noise = BBandPass.ar(noise,noisef,noisebw) --Resonz.ar(noise,noisef,0.08)
	noise = Mix(noise)
	lossF = (17/#Area)*4e-3*lossF
	--lenT  = EnvGen.kr(Env({lenT,lenT},{rate}),t_gate)

	local lenf = SampleRate.ir()*lenT*fA/(35000*#Ar)
	local dels = df*lenf
	--local signal = SinOsc.ar(100) 
	local signal = HumanVNdel.ar(exci,noise,noiseloc,lossF,lossG,-lossL,-lossN,lmix,nmix,area1len,dels,Ar,ArN)*env 
	local throat = LPF.ar(exci,400)
	signal = signal + throat*thlev

	signal = LeakDC.ar(signal,0.91)
	return Out.ar(out,  Pan2.ar(signal,pan));
end):store() 

function Tract.get_sylabes(tex)
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
	--prtable(syls)
	return syls
end
function Tract.syl2phon(syl,DURAT)
	local totdur = 0
	local numvocals = 0
	local dur = 0
	local is_vocal
	local lastvocalpos = 0
	for i,v in ipairs(syl) do
		is_vocal = Tract.vocals[v] or v==" "
		numvocals = numvocals + (is_vocal and 1 or 0)
		lastvocalpos = is_vocal and i
		dur = Tract.dur[v] or 0.1
		totdur = totdur + dur
	end
	local syl2 = {}
	for i,v in ipairs(syl) do
		dur = 0
		local rate = Tract.rate[v] or 0.1
		is_vocal = Tract.vocals[v] or v==" "
		if is_vocal then
			--rate = Tract.krate[syl[i-1]] or rate
			if i == lastvocalpos then
				local DURA = beats2Time(DURAT)
				dur = (DURA - totdur +0.1) - rate
			else
				dur = (Tract.dur[v] or 0.1) - rate
			end
		--if is_vocal then
			--dur = (DURA - totdur)/numvocals
			--rate = Tract.krate[syl[i-1]] or rate
		else
			dur = (Tract.dur[v] or 0.1) - rate
			--totdur = totdur + dur
		end
		--dur = Time2beats(dur)
		dur = math.max(0,dur)
		syl2[i] = {v,rate,dur,Tract.krate[v]}
	end
	return syl2
end
Tract.paramskey_speak = {"Ar","ArN","Gain","lenT","noiseloc","noisef","noisebw","glot","plosive","area1len"}
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
function Tract.doSpeak(syl)

	local res = {}

	for i2,v in ipairs(syl) do
		local ph = v[1]
		local isN = Tract.nasal[ph]
		local rate = v[2]
		local gain = Tract.gains[ph] or 1
		local lenT = Tract.len[ph] or 17

		local noise = Tract.noise[ph]
		local noiseloc = noise and noise.pos or 0
		local noisefreq = noise and noise.freqs or {2500,7500}
		local noisebw = noise and noise.bw or {1,1}

		local glot = Tract.glot[ph] or 1
		local plosive = Tract.plosive[ph] or 0
		
		assert(Tract.areas[ph],"ph is "..ph)
		local dur = v[3]
		--assert(rate >=0)
		--assert(dur >=0)
		makeenv(res,"Ar",Tract.areas[ph],rate,dur)
		makeenv(res,"ArN",isN and Tract.AreaNose or Tract.AreaNoseC,rate,dur)
		makeenv(res,"Gain",gain,rate,dur)
		makeenv(res,"lenT",lenT,rate,dur)
		makeenv(res,"noiseloc",noiseloc,0,rate+dur)
		makeenv(res,"noisefreq",noisefreq,rate,dur)
		makeenv(res,"noisebw",noisebw,rate,dur)
		makeenv(res,"glot",glot,rate,dur)
		makeenv(res,"plosive",plosive,rate,dur)
		makeenv(res,"area1len",Tract.area1len,rate,dur)

		--table.insert(res,{{Tract.areas[ph]},isN and {Tract.AreaNose} or {Tract.AreaNoseC},gain,rate,lenT,noiseloc,{noisefreq},{noisebw},glot,plosive,Tract.area1len,dur})
	end
	for k,p in pairs(res) do
		--print(k)
		--prtable(p)
		res[k] = ENVr(p[1],p[2])
	end
	return res
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
			is_vocal = Tract.vocals[v] or v==" "
			numvocals = numvocals + (is_vocal and 1 or 0)
			lastvocalpos = is_vocal and i
			dur = Tract.dur[v] or 0.1
			totdur = totdur + dur
		end
		local syl2 = {}
		for i,v in ipairs(syl) do
			dur = 0
			local rate = Tract.rate[v] or 0.1
			is_vocal = Tract.vocals[v] or v==" "
			if is_vocal then
				rate = Tract.krate[syl[i-1]] or rate
				if i == lastvocalpos then
					local DURA = beats2Time(WrapAt(DURAT,is))
					dur = (DURA - totdur +0.1)
				else
					dur = Tract.dur[v] or 0.1
				end
			--if is_vocal then
				--dur = (DURA - totdur)/numvocals
				--rate = Tract.krate[syl[i-1]] or rate
			else
				dur = Tract.dur[v] or 0.1
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
	prtable(syls)
	--local args = {...}
	for i,syl in ipairs(syls) do
		for i2,v in ipairs(syl) do
			local ph = v[1]
			local isN = Tract.nasal[ph]
			local rate = v[2]
			local gain = Tract.gains[ph] or 1
			local lenT = Tract.len[ph] or 17

			local noise = Tract.noise[ph]
			local noiseloc = noise and noise.pos or 0
			local noisefreq = noise and noise.freqs or {2500,7500}
			local noisebw = noise and noise.bw or {1,1}

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
			local lenT = Tract.len[ph] or 17

			local noise = Tract.noise[ph]
			local noiseloc = noise and noise.pos or 0
			local noisefreq = noise and noise.freqs or {2500,7500}
			local noisebw = noise and noise.bw or {1,1}

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
	return Tract
end