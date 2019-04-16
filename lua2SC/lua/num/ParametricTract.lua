
local function Init(SEGMENTS,LEN)
local DEFDUR = 0.1
local DEFRATE = 0.1
local function round(a)
	return math.floor(a+0.5)
end
local vowel_coefs = {
I	={29.084991982217,	0.05,0.9},--0.6	
--i	={29.084991982217,	0.05,1.1},--0.6
E	= {26.811695886117,	0.75,1.1},
U	= {25.401305243582,	0.22,1.65},
--U	= {0.6*44,	0.05,1.65},
O	= {15.336840104866,	0.05,1.6},
Ae	= {13.969803375406,	0.8,1.1},
A	= {12.755816060722,	0.3,1.1},
E2	= {20.756675819539,	1.03,1.1}
}

local Tract = {
    --n = 44,
    bladeStart = 10,
    tipStart = 32,
    lipStart = 39,
	maxconstrictionwidth =25,
    tongueIndex = 12.9,
    tongueDiameter = 2.43,
    --innerTongueControlRadius = 2.05,
    --outerTongueControlRadius = 3.5,
	outerTongueControlRadius = 1.45,
	restDiameter = {},
	targetDiameter = {},
	noseDiameter = {},
	curvecoef = 1.1

}
Tract.vowel_coefs = vowel_coefs
Tract.vocals = {A=true,Ae=true,E=true,I=true,E2=true,O=true,U=true,Mv=true,Nv=true,[" "]=false,_v=true}

function Tract:init(N,len)
	self.deflen = len
	local this = self
	local Tract = self
	self.n = N
	for i=0,this.n-1 do
        local diameter = 0;
        if (i<N*7/44) then diameter = 0.6; 
        elseif (i<N*12/44) then diameter = 1.1;
        else diameter = 1.5; end
        this.restDiameter[i+1]  = diameter;
    end
	for k,v in pairs(vowel_coefs) do
		v[1] = v[1]*N/44
	end
	Tract.bladeStart = round(N*10/44)
	--Tract.tipStart  = round(N*39/44)
	Tract.tipStart  = round(N*32/44)
	Tract.lipStart = round(N*39/44)
	self.maxconstrictionwidth = round(N*25/44)
	this.tongueLowerIndexBound = Tract.bladeStart +2;
    this.tongueUpperIndexBound = Tract.tipStart -3;
    this.tongueIndexCentre = 0.5*(this.tongueLowerIndexBound+this.tongueUpperIndexBound);

	this.noseLength = math.floor(28*this.n/44)
    this.noseStart = this.n-this.noseLength + 1;
	for i=0,this.noseLength-1 do
        local diameter;
        local d = 2*(i/this.noseLength);
        if (d<1) then diameter = 0.4+1.6*d;
        else diameter = 0.5+1.5*(2-d); end
        diameter = math.min(diameter, 1.9);
        this.noseDiameter[i+1] = diameter*2;
    end      
end
function Tract:setRestDiameter()
	local Tract = self
	local this = self
	--print("curve",(this.outerTongueControlRadius-this.tongueDiameter))
    for i=Tract.bladeStart,Tract.lipStart-1 do
		local fac = (this.tongueIndex - i)/(Tract.tipStart - Tract.bladeStart)
		--local coef = linearmap(0,1,1.1,this.curvecoef,fac)
        local t = this.curvecoef * math.pi*fac;
		local curve = (this.outerTongueControlRadius-this.tongueDiameter)*math.cos(t)
        Tract.restDiameter[i+1] = 1.8 - curve;
		--print((this.tongueIndex - i)/(Tract.tipStart - Tract.bladeStart),math.cos(t))
    end
end


local function clamp(x,a,b)
	return math.min(math.max(x,a),b)
end


function Tract:set_vocalpars(index,diameter,curvecoef)
	self.curvecoef = curvecoef or 1.1
	local this = self

    this.tongueDiameter = clamp(diameter, 0, this.outerTongueControlRadius);
    this.tongueIndex = clamp(index, this.tongueLowerIndexBound, this.tongueUpperIndexBound);

	--print(vowel,index,diameter,this.tongueIndex)
	this:setRestDiameter();   
    for i=0,self.n-1 do self.targetDiameter[i+1] = self.restDiameter[i+1]; end
end

function  Tract:add_constriction(indexfac,diameter,Di)
	local resDi = {}
	local index = indexfac*self.n
    --Di = Di or self.targetDiameter
	for i=1,#Di do resDi[i] = Di[i] end

	local maxwidth = round(10*self.n/44)
	local minwidth = round(5*self.n/44)
--[[
    local width=2;
    if (index<self.maxconstrictionwidth) then width = maxwidth;
    elseif (index>=self.tipStart) then width= minwidth;
    else width = maxwidth-minwidth*(index-self.maxconstrictionwidth)/(self.tipStart-self.maxconstrictionwidth); end
--]]
	local width = maxwidth-minwidth*(index - self.maxconstrictionwidth)/(self.tipStart -self.maxconstrictionwidth)
	width = clamp(width, minwidth, maxwidth)
    if (index >= 2 and index < self.n)
    then
        local intIndex = round(index);
        for i=-math.ceil(width)-1,width+1 do  
            if (intIndex+i<0 or intIndex+i>=self.n) then goto continue end
            local relpos = (intIndex+i) - index;
            relpos = math.abs(relpos)-0.5;
            local shrink;
            if (relpos <= 0) then shrink = 0;
            elseif (relpos > width) then shrink = 1;
            else shrink = 0.5*(1-math.cos(math.pi * relpos / width)); end
            if (diameter < Di[intIndex+i+1]) then
                resDi[intIndex+i+1] = diameter + (Di[intIndex+i+1]-diameter)*shrink;
            end
			::continue::
        end
    end
	return resDi
end

function Tract:set_vocal(vowel)
	local this = self
	local coef = vowel_coefs[vowel]

	local index = coef[1]
    local diameter = coef[2]
	local curvecoef = coef[3]
	self:set_vocalpars(index,diameter,curvecoef)
    
end


local function CalcAreas(voc)
	local A,D = {},{}
	Tract:set_vocal(voc)
	for i=1,Tract.n do
		A[i] = (Tract.targetDiameter[i])^2
		D[i] = Tract.targetDiameter[i]
	end
	--prtable(voc,Tract.targetDiameter)
	return A,D
end
local function CalcAreasPars(index,diameter,curvecoef)
	local A,D = {},{}
	Tract:set_vocalpars(index,diameter,curvecoef)
	for i=1,Tract.n do
		A[i] = (Tract.targetDiameter[i])^2
		D[i] = Tract.targetDiameter[i]
	end
	--prtable(voc,Tract.targetDiameter)
	return A,D
end
Tract.CalcAreasPars = CalcAreasPars
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
local function LFexci()
		--freq = freq + freq*WhiteNoise.kr(0.01)
		--freq = freq + freq * LFDNoise3.kr(50,jitter)
		local jitfac = LFDNoise3.kr(2*10,jitter,1)
		local jitfac2 = LFDNoise3.kr(2*10,jitter*6,1)
		
		--local jsig = LFDNoise3.kr(4)+LFDNoise3.kr(10) +LFDNoise3.kr(20)*0.5
		--local jitfac = 1 + jsig*0.5*jitter
		
		freq = freq*jitfac
		local vibratoF =  Vibrato.kr{freq, rate= vibrate, depth= vibdepth, delay= vibdelay, onset= 0, 	rateVariation= rv, depthVariation= 0.1, iphase =  0,trig=t_gate}
		local Tp,Te,Ta,alpha,Ee = Rd2Times(Rd*jitfac2)
		--glot = VarLag.kr(glot,timeVar,0,"cub")
		local exci = LFglottal.ar(vibratoF,Tp,Te,Ta,alpha,namp,nwidth)*glot*3*Ee
		--local exci = VeldhuisGlot.ar(vibratoF,Tp,Te,Ta,namp,nwidth)*glot*3*Ee
		exci =  WhiteNoise.ar()*plosive*Ee + exci
		exci = Mix(exci)
		exci = LPF.ar(exci,fexci)*jitfac2*SinOsc.ar(vibrate,nil,vibdepth*vibampfac,1)
		--exci =  BrownNoise.ar()*plosive*EnvGen.ar(Env({0,0,1},{0.02,0.04}),t_gate) + exci
		return exci
end

local function MakeGlottalSynth(Tract, syname, args, excifunc)
	local defargs = {out=0,gate=1,amp=1,pan=0,freq=60,glot=1,plosive=0}
	local function deffunc(excifunc)
		return function(newgt)
		setfenv(excifunc,newgt)
		local env=EnvGen.ar(Env.asr(0.001, 1, 0.1), gate, nil,nil,nil,2);
		local exci = excifunc()
		exci = exci*amp*env
		local signal = Pan2.ar(exci,pan);
		return Out.ar(out, signal)
		end
	end
	for k,v in pairs(args) do
		defargs[k]=v
	end
	Tract[syname] = SynthDef(syname.."Par",defargs,deffunc(excifunc)):store()
end

local function MakeTractOnlySynth(Tract, syname, args,resamp)
	local defargs = {busout=0,busin=0, gate=1,t_gate=1,amp=0.6,pan=0,lossG=0.97,lossL=0.97,lossN=0.95,lossF=1,area1len=Tract.area1len,Gain=1,lmix=1,nmix=1,fA0=1,Ar=Ref(TA():Fill(Tract.n,1.5)),ArN=Ref(Tract.AreaNoseC),lenT = Tract.deflen,
noiseloc=0,noisef=Ref{2500,2500},noisebw=Ref{1.1,1},plosive=0,fA=1,fAc=1,fAc2=1,thlev=0,fexci=6000,fout=18000,fPreoral=1,timeVar=0.15,t_send=0}
	local function deffunc()
		return function(newgt)

		if resamp then
			fA = fA*2
		end
		local exci = In.ar(busin,1)
		exci = exci*amp 
		local env=EnvGen.ar(Env.asr(0.001, 1, 0.1), gate, nil,nil,nil,2);


		local noise = WhiteNoise.ar()*amp*0.4 --*EnvGen.ar(Env({0,0,1},{0,0.08}),t_gate)
		noise = BBandPass.ar(noise,noisef,noisebw) --Resonz.ar(noise,noisef,0.08)
		noise = Mix(noise)
		lossF = (17/Tract.n)*4e-3*lossF

		local lenf = SampleRate.ir()*lenT*fA/(35000*Tract.n) --35000 cm/seg

		local inioral = math.floor(23/44*Tract.n)
		local dels = TA():Fill(Tract.n,lenf)
		for i=1,inioral do
			dels[i] = dels[i]*fPreoral
		end
		
		local nsecs = math.floor(21/44*Tract.n + 0.5)
		local pend = (1)/(nsecs - 2)
		for ii=2,nsecs do
			Ar[ii] = Ar[ii]*((fAc-1)*(1-(ii-2)*pend)^2+1)
		end
		----------------------
		local signal 
		if resamp then
			signal = HumanVNdelO2.ar(exci*1,noise,noiseloc,lossF,lossG,-lossL,-lossN,lmix,nmix,area1len,dels,Ar,ArN)*env 
		else
			signal = HumanVNdel.ar(exci,noise,noiseloc,lossF,lossG,-lossL,-lossN,lmix,nmix,area1len,dels,Ar,ArN)*env 
		end
		signal = signal*Gain
		local throat = LPF.ar(exci,400)
		signal = signal + throat*thlev
		signal = LPF.ar(signal,fout)
		signal = LeakDC.ar(signal,0.95)
		signal = Pan2.ar(signal*3,pan);
		return ReplaceOut.ar(busout, signal)
		end
	end
	for k,v in pairs(args) do
		defargs[k]=v
	end
	Tract[syname] = SynthDef(syname.."Par"..Tract.NN,defargs,deffunc(excifunc)):store()
end

local function MakeTractSynth(Tract,syname,args,excifunc,resamp)

	local defargs = {out=0, gate=1,t_gate=1, freq=60,amp=0.6,pan=0,lossG=0.97,lossL=0.97,lossN=0.95,lossF=1,area1len=Tract.area1len,Gain=1,lmix=1,nmix=1,fA0=1,Ar=Ref(TA():Fill(Tract.n,1.5)),ArN=Ref(Tract.AreaNoseC),lenT = Tract.deflen,
noiseloc=0,glot=1,noisef=Ref{2500,2500},noisebw=Ref{1.1,1},plosive=0,fA=1,fAc=1,fAc2=1,thlev=0,fexci=6000,fout=18000,fPreoral=1,timeVar=0.15,t_send=0}

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

		--local isnoise = BinaryOpUGen.newop(">",noiseloc,0)
		--local isnoise = VarLag.kr(isnoise,timeVar,0,"cub")
		local noise = WhiteNoise.ar()*amp*0.4 --*EnvGen.ar(Env({0,0,1},{0,0.08}),t_gate)
		noise = BBandPass.ar(noise,noisef,noisebw) --Resonz.ar(noise,noisef,0.08)
		noise = Mix(noise)
		lossF = (17/Tract.n)*4e-3*lossF

		local lenf = SampleRate.ir()*lenT*fA/(35000*Tract.n) --35000 cm/seg

		local inioral = math.floor(23/44*Tract.n)
		local dels = TA():Fill(Tract.n,lenf)
		for i=1,inioral do
			dels[i] = dels[i]*fPreoral
			--Ar[i] = Ar[i]*fPreoral
		end
		
--[[
		local nsecs = math.floor(23/44*Tract.n + 0.5)
		local pend = (1- fAc)/(nsecs - 2)
		for ii=2,nsecs do
			Ar[ii] = Ar[ii]*(fAc + (ii-2)*pend)
		end
--]]
		local nsecs = math.floor(21/44*Tract.n + 0.5)
		local pend = (1)/(nsecs - 2)
		for ii=2,nsecs do
			Ar[ii] = Ar[ii]*((fAc-1)*(1-(ii-2)*pend)^2+1)
		end
		----------------------
		t_send = Impulse.kr(10)
		SendReply.kr(t_send,"areas",Ar)
		--SendReply.kr(t_send,"areasN",ArN)
		--Di = Lag.kr(Di,0.6)
		--Di = VarLag.kr(Di,0.1)
		--ArN = Lag.kr(ArN,0.1)
		--ArN[1] = VarLag.kr(ArN[1],timeVar)
		--local Ar = Di*Di
		--Ar = VarLag.kr(Ar,0.1,0,"lin")
		local signal 
		if resamp then
			signal = HumanVNdelO2.ar(exci*1,noise,noiseloc,lossF,lossG,-lossL,-lossN,lmix,nmix,area1len,dels,Ar,ArN)*env 
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
	Tract[syname] = SynthDef(syname.."Par"..Tract.NN,defargs,deffunc(excifunc)):store()
end
----------------------------------------------
Tract:init(SEGMENTS,LEN)--round(44*14.29/17.46))
Tract.NN = Tract.n

Tract.areas = {}
Tract.Di = {}
for k,v in pairs(vowel_coefs) do
	Tract.areas[k],Tract.Di[k] = CalcAreas(k)
end

------------------nose

local NNnose = Tract.noseLength
local res1,res2 = {},{}
for i=1,NNnose do
	res1[i] = (Tract.noseDiameter[i])^2
	res2[i] = res1[i]
end

res2[1]=0.01^2
Tract.area1len = Tract.noseStart --0.45*Tract.NN
Tract.AreaNose = res1
Tract.AreaNoseC = res2
---------------
Tract.nasal = {M=true,N=true}
Tract.gains = {}
Tract.len = {}
Tract.noise = {}
Tract.glot = {}
Tract.plosive = {}
-----------------
Tract.phon = {}
--for sclua.Synth:set
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
--for OscEP
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

MakeTractSynth(Tract,"sinteRdO2",{Rd=0.7,alpha=3.2,namp=0.04,nwidth=0.4,vibrate=5,vibdepth=0.01,vibdelay=0,rv=0.1,jitter=0.01,vibampfac=20},LFexci,true)

MakeTractOnlySynth(Tract,"TractOnlyO2",{},true)

MakeGlottalSynth(Tract,"GlottalSynth",{Rd=0.7,alpha=3.2,namp=0.04,nwidth=0.4,vibrate=5,vibdepth=0.01,vibdelay=0,rv=0.1,jitter=0.01,vibampfac=20},LFexci)


Tract.cons = {}
Tract.cons.M = {40/44,0} --41
Tract.cons.N = {33/44,0}
Tract.cons.L = {38/44,0.7}
Tract.cons.B = {40/44,0}
Tract.cons.P = {43/44,0}
Tract.cons.D = {35/44,0}
Tract.cons.T = {35/44,0} --35
Tract.cons.K = {22/44,0}
Tract.cons.R = {38/44,0}
Tract.cons.Z = {43/44,0.5}
Tract.cons.F = {42/44,0.5}
Tract.cons.S = {43/44,0.5}
Tract.cons.G = {22/44,0}
Tract.cons.J = {22/44,0}
Tract.cons.H = {5/44,1}

Tract.glot = {}
Tract.glot.S = 0 --0.5
Tract.glot.F = 0
Tract.glot.Z = 0
Tract.glot.J = 0
Tract.glot[" "] = 0
Tract.glot.T = 0 --1
Tract.glot.D = 0.5
Tract.glot.P = 0 --1
Tract.glot.B = 0 --0.25 --1 --0.5
Tract.glot.K = 1
Tract.glot.G = 1
Tract.glot.H = 0

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

Tract.plosive = {}
Tract.plosive.K = 0.5 --.5 --1 --0.5 --db2amp(-15)
Tract.plosive.G = 0
Tract.plosive.P  = 2 --0.5
Tract.plosive.B = 0.25
Tract.plosive.T = 0 --2
Tract.plosive.D  = 0
Tract.plosive.H = 0.35
Tract.plosive.R = 0

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

Tract.gains.J = db2amp(16)
Tract.gains.H = db2amp(10)

Tract.noise = {}
Tract.noise.F = {freqs={2000,7000},bw={0.1,0.5}} 
Tract.noise.S = {freqs={7500,7500},bw={0.05,0.05}}
--Tract.noise.Z = {freqs={700,8000},bw={2.7,2.7}}
Tract.noise.Z = {freqs={4000,4500},bw={0.15,0.15}}
Tract.noise.J = {freqs={800,1000},bw={2.5,2.5}}
Tract.noise.H = {freqs={1800,1000},bw={2.5,2.5}}

local function copy_phoneme(a,b)
	for k,v in pairs(Tract) do
		if type(v)=="table" and v[b] then
			v[a] = deepcopy(v[b])
		end
	end
end
copy_phoneme("Nv","N")
copy_phoneme("Mv","M")
copy_phoneme(" ","Ae")
Tract.glot[" "] = 0
Tract.vocals[" "] = false
copy_phoneme("_"," ")
Tract.dur._ = 0.02
Tract.krate._ = 0.00
copy_phoneme("_v"," ")
Tract.rate._v = 0.01
Tract.gains._v = 0
Tract.vocals._v = true
copy_phoneme("X","S")
--Tract.noise.X = deepcopy(Tract.noise.S)
Tract.noise.X.freqs = {2000,5500}
Tract.plosive.X = 1
Tract.glot.X = 0
Tract.rate.X = 0.03
Tract.krate.X = 0
Tract.gains.X = db2amp(10)
copy_phoneme("_q"," ")
Tract.rate._q = 0.0
Tract.dur._q = 0.03
Tract.krate._q = 0.0

copy_phoneme("Eq","Ae")
Tract.rate.Eq = 0.0
Tract.dur.Eq = 0.03
	-------------------------------------------------
	Tract.paramskey_speak = {"Ar","ArN","Gain","lenT","noiseloc","noisef","noisebw","glot","plosive","area1len","t_gate"}
local function makeenv(t,name,val,rate,dur,curve)
	local first = not t[name]
	t[name] = t[name] or {{},{}}
	table.insert(t[name][1],val)
	table.insert(t[name][1],val)
	if first then table.insert(t[name][1],val) end
	--if not first then table.insert(t[name][2],rate) end
	table.insert(t[name][2],rate)
	table.insert(t[name][2],dur)
	--if curve then t[name]
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
function Tract:doSpeak(syl,DURA,fade)
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
		local noiseloc = noise and Tract.cons[ph][1]*Tract.n or 0
		local noisefreq = noise and noise.freqs or {2500,7500}
		local noisebw = noise and noise.bw or {0.1,0.1}

		local glot = Tract.glot[ph] or 1
		local plosive = Tract.plosive[ph] or 0
		
		local dur = v[3]
		if v.usetotdur then
			--dur = DURA - syl.totdur - rate
			dur = math.max(0,vocaldur - rate)
		end
		
		local constpars

		if vowel_coefs[ph] then
			self.thisv_coef = vowel_coefs[ph]
		else
			local voc = syl[syl.lastpos]
			self.thisv_coef = voc and vowel_coefs[voc[1]] or vowel_coefs["Ae"]
			assert(self.thisv_coef)
			--self.thisv_coef = self.thisv_coef or vowel_coefs["Ae"]
			constpars = assert(self.cons[ph])
		end
		self.thisv_coef = self.thisv_coef or vowel_coefs["Ae"]
		constpars = constpars or {0.5,4}

		local ind,ra,co = unpack(self.thisv_coef)
		local Ar,Di = CalcAreasPars(ind,ra,0.9)
		Di = Tract:add_constriction(constpars[1],constpars[2],Di)
		for i=1,#Di do Ar[i]=Di[i]*Di[i] end

		makeenv(res,"Ar",Ar,rate,dur)
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
		makeenv(res,"plosive",0,rate,dur)
		makeenv(res,"area1len",Tract.area1len,rate,dur)
		--print(ph,rate,dur)
		--table.insert(res,{{Tract.areas[ph]},isN and {Tract.AreaNose} or {Tract.AreaNoseC},gain,rate,lenT,noiseloc,{noisefreq},{noisebw},glot,plosive,Tract.area1len,dur})
	end
	for k,p in pairs(res) do
		--res[k] = ENV(p[1],p[2],"cub",false,true) 
		res[k] = ENVm(p[1],p[2],p[3] or "cub",false,true)
	end
	--res.t_gate = ENVstep(res_t_gate.t_gate[1],res_t_gate.t_gate[2],nil,false,true)
	res.t_gate = ENV(res_t_gate.t_gate[1],res_t_gate.t_gate[2],"step",false,true)
	res.advance = -Time2beats(syl.timetillvoc)
	return res
end
function Tract.get_sylabes(tex)
	local phon = {}
	--get phonemes symbols and silabe separator (-)
	--one uppercase or space or - or _  followed by several (or none) lowecase or number
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

		if has_vocal and (v=="-") then
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
function Tract.syl2phon(syl,allvocals)
	local totdur = 0
	local numvocals = 0
	local dur = 0
	local is_vocal
	local lastvocalpos = 0
	for i,v in ipairs(syl) do
		is_vocal = vowel_coefs[v] --Tract.vocals[v] --or v==" "
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
function Tract:doTalk(tex,allvocals,fade)
	local syls = self.get_sylabes(tex)
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
		local ret2 = Tract:doSpeak(ret,e.tmplist.dur,fade)
		--prtable(ret2)
		local ret = {}
		for i,v in ipairs(self.paramskey_speak) do
			ret[i] = ret2[v]
		end
		--prtable(ret2)
		return ret 
	end)
end
	function Tract:Talk(frase,allvocals,fade)
		return {[Tract.paramskey_speak] = LS{Tract:doTalk(frase,allvocals,fade)}}
	end

return Tract
end
return Init

--[[
TT = Init(30,17)
ins = {{TT.TractOnlyO2.name,TT.phon.getK"A"}}
instGui = InstrumentsGUI(TT.GlottalSynth.name) 
MidiToOsc.AddChannel(0,instGui,{0.0},nil,ins)

pl = OscEP{inst=TT.sinteRdO2.name,mono=true}
pl:Bind(PS({dur=1,freq=200,amp=0.5},TT.phon.getK"E"))
--]]
