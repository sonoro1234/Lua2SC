
return function(NN,DEFDUR,DEFRATE)
DEFDUR = DEFDUR or 0.1
DEFRATE = DEFRATE or 0.1
local MINIMAL = 0 --1e-9

local required = string.format("num.tract_male%d",NN)
local Tract = require(required)
local function copy_phoneme(a,b)
	for k,v in pairs(Tract) do
		if type(v)=="table" and v[b] then
			v[a] = v[b]
		end
	end
end


Tract.areas.B = Tract.areas.P
Tract.areas.D = Tract.areas.T
Tract.areas.G = Tract.areas.K

--Tract["areas"]["R"] = Tract["areas"]["L"]
Tract["areas"]["S"] = Tract["areas"]["N"]
Tract["areas"]["S"][#Tract.areas.S] = 3
Tract["areas"]["F"] = Tract["areas"]["M"]
Tract["areas"]["Z"] = Tract["areas"]["F"]
Tract["areas"][" "] = Tract["areas"]["Ae"]
Tract.areas.H = Tract.areas.Ae
------------------
Tract["glot"] = {}
Tract["glot"]["S"] = 0.5
Tract["glot"]["F"] = 0
Tract["glot"]["Z"] = 0
Tract["glot"][" "] = 0
Tract.glot.T = 1
Tract.glot.D = 1
Tract.glot.P = 0 --1
Tract.glot.B = 1 --1 --0.5
Tract.glot.K = 0
Tract.glot.G = 1
Tract.glot.H = 0
Tract.plosive = {}
Tract.plosive.K = 1 --db2amp(-15)
Tract.plosive.G = 0
Tract.plosive.P  = 0.5
Tract.plosive.B = 0.5
Tract.plosive.T = 2
Tract.plosive.D  = 0


Tract.plosive.H = 0.35
Tract["plosive"]["R"] = 0
--------------gains
Tract["gains"] = {}
Tract.gains.Ate = db2amp(6)
Tract.gains.Ete = db2amp(0)
Tract.gains.Ite = db2amp(5)
Tract.gains.Ote = db2amp(0)
Tract.gains.Ute = db2amp(0)

Tract.gains.B = db2amp(-61)
Tract.gains.P = db2amp(-25)
Tract.gains.D = db2amp(-15)
Tract.gains.T = db2amp(-20)
Tract.gains.R = db2amp(-5) --db2amp(-10)
Tract.gains.K = 1 --db2amp(-14)
Tract.gains.G = db2amp(-20)
Tract["gains"]["O"] = db2amp(-4)
Tract.gains.L = db2amp(0)
Tract["gains"]["E"] = 1.4125375446228
Tract["gains"]["I"] = db2amp(-3)
Tract["gains"]["M"] = db2amp(-12)
Tract["gains"]["Ui"] = 0.50118723362727
Tract["gains"]["U1"] = db2amp(-18)
Tract["gains"]["U"] = db2amp(-18)
Tract["gains"]["N"] = db2amp(-6)
Tract["gains"]["A"] = db2amp(5)
-----------------
Tract.rate = {}
Tract.rate.K  = 0.02
Tract.rate.G  = 0.05
Tract.rate.S  = 0.02
Tract.rate.M = 0.1 --0.1 --0.05
Tract.rate.N = 0.1 --0.05
Tract.rate.R = 0.05
Tract.rate.T = 0.01
Tract.rate.D = 0.05 --0.01
Tract.rate.B = 0.05
Tract.rate.P = 0 --0.05 --0.02 --0.01
Tract.rate.H = 0.01
--Tract.rate[" "] = 0.1

Tract.rate.L = 0
Tract.dur = {}
Tract.dur.Z = 0.1
Tract.dur.R = 0.05
Tract.dur.B = 0.05 --0.08
Tract.dur.P = 0.09 --0.09
Tract.dur.T = 0.08
Tract.dur.K = 0.09
Tract.dur.D = 0.05
Tract.dur.G = 0.05
Tract.krate = {}
Tract.krate.R = 0.02
Tract.krate.B = 0.07 --0.06
Tract.krate.P = 0.03 --0.01 --0.01
Tract.krate.T = 0.03
Tract.krate.D = 0.06
Tract.krate.K = 0.03
Tract.krate.G = 0.06
Tract.krate.S = 0.05
Tract.krate.M = 0.07
Tract.krate.N = 0.07
Tract.krate.H = 0.03
copy_phoneme("_v"," ")
copy_phoneme("Nv","N")
copy_phoneme("Mv","M")
Tract.vocals = {A=true,Ae=true,E=true,I=true,I2=true,O=true,U1=true,U=true,Mv=true,Nv=true,[" "]=false,_v=true,Ate=true,Ete=true,Ite=true,Ote=true,Ute=true}
-------------------------------------------------------------------------------------------
copy_phoneme("_"," ")
Tract.dur._ = 0.005
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
Tract.sinte=SynthDef("testHumanVN"..NN, {samples= 1,out=0, gate=1,t_gate=1, freq=60,amp=0.6,pan=0,lossG=0.95,lossL=0.95,lossN=0.95,lossT=1,lossF=1,rate=2,rateN=1,gainE=1,excibuf=0,excibuf1=0,excibuf2=0,area1len=8*22/17.5,gainN=gainN,Gain=1,lmix=1,nmix=1,Ar=Ref(TA():Fill(#Area,1.5)),ArN=Ref(Tract.AreaNose),lenT = 17.5,df=Ref(TA():Fill(#Area,1)),noiseloc=0,glot=1,noisef=Ref{2500,7500},noisebw=Ref{1,1},plosive=0,fA=1,fAc=1,fG1=0.4,fG2=0.2,fG2f=1,thlev=0.4,fexci=6000,Tp=0.4,Te=0.5,Ta=0.028},function ()
	local srdur = SampleDur.ir()
	--freq = {freq,freq*1.01,freq*1.03,freq*0.98}
	local vibratoF =  Vibrato.kr{freq, rate= 5, depth= 0.01, delay= 0.2, onset= 0, rateVariation= 0.5, depthVariation= 0.1, iphase =  0}
	--glot = Lag.kr(glot,rate)
	glot  = EnvGen.kr(Env({glot,glot},{rate}),t_gate)
	Gain  = EnvGen.kr(Env({Gain,Gain},{rate}),t_gate)
	plosive  = EnvGen.kr(Env({plosive,plosive},{rate}),t_gate)

	local exci = LFglottal.ar(vibratoF,Tp,Te,Ta)*Gain*amp*glot*3

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

Tract.sinte2=SynthDef("test2HumanVN"..NN, {samples= 1,out=0, gate=1,t_gate=1, freq=60,amp=0.6,pan=0,lossG=0.97,lossL=0.97,lossN=0.95,lossT=1,lossF=1,gainE=1,excibuf=0,excibuf1=0,excibuf2=0,area1len=8*22/17.5,gainN=gainN,Gain=1,lmix=1,nmix=1,Ar=Ref(TA():Fill(#Area,1.5)),ArN=Ref(Tract.AreaNoseC),lenT = 17.5,df=Ref(TA():Fill(#Area,1)),noiseloc=0,glot=1,noisef=Ref{2500,7500},noisebw=Ref{1,1},plosive=0,fA=1,fAc=1,fG1=0.4,fG2=0.2,fG2f=1,thlev=0,fexci=5000,Tp=0.4,Te=0.5,Ta=0.028},function ()
	local srdur = SampleDur.ir()
	--freq = {freq,freq*1.01,freq*1.03,freq*0.98}
	local vibratoF =  Vibrato.kr{freq, rate= 5, depth= 0.01, delay= 0.2, onset= 0, rateVariation= 0.5, depthVariation= 0.1, iphase =  0}

	--local sig2 = SinOsc.ar(vibratoF,0.0,0.5,0.5)
	--local sig2 = LFPulse.ar(vibratoF,0,0.5,0.75,0.25)
	--local exci = LFglottal.ar(vibratoF*2,Tp,Tefac,Ta)*glot*3*sig2

	local exci = LFglottal.ar(vibratoF,Tp,Te,Ta)*glot*3
	exci = LPF.ar(exci,fexci)
	--exci =  BrownNoise.ar()*plosive*EnvGen.ar(Env({0,0,1},{0.02,0.04}),t_gate) + exci
	exci =  WhiteNoise.ar()*plosive + exci

	--SendTrig.kr(t_gate,22,Ar[1])
	--SendReply.kr(Impulse.kr(4),"/tr",Ar)
	--SendTrig.kr(Impulse.kr(10),0,plosive)

	exci = exci*amp*Gain
	--local exci = Impulse.ar(vibratoF)
	local env=EnvGen.ar(Env.asr(0.01, 1, 0.1), gate, nil,nil,nil,2);

	local nsecs = math.floor(#Ar*0.5 + 0.5)
	local pend = (1- fAc)/(nsecs - 1)
	for ii=1,nsecs do
		--Ar[ii] = Ar[ii]*(fAc + (ii-1)*pend)
		df[ii] = df[ii]*(fAc + (ii-1)*pend)
	end

	local noise = WhiteNoise.ar()*0.1*amp *EnvGen.ar(Env({0,0,1},{0,0.08}),t_gate)
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
	--signal = signal + SinOsc.ar(200)*EnvGen.ar(Env.perc(0,0.2,1),t_gate)
	signal = LeakDC.ar(signal,0.91)

	--signal = {signal*3,K2A.ar(t_gate)}
	signal = Pan2.ar(signal*3,pan);
	return Out.ar(out,  signal) --
end):store() 
Tract.sinteRd=SynthDef("testRdHumanVN"..NN, {samples= 1,out=0, gate=1,t_gate=1, freq=60,amp=0.6,pan=0,lossG=0.97,lossL=0.97,lossN=0.95,lossT=1,lossF=1,gainE=1,excibuf=0,excibuf1=0,excibuf2=0,area1len=8*22/17.5,gainN=gainN,Gain=1,lmix=1,nmix=1,Ar=Ref(TA():Fill(#Area,1.5)),ArN=Ref(Tract.AreaNoseC),lenT = 17.5,df=Ref(TA():Fill(#Area,1)),noiseloc=0,glot=1,noisef=Ref{2500,7500},noisebw=Ref{1,1},plosive=0,fA=1,fAc=1,fG1=0.4,fG2=0.2,fG2f=1,thlev=0,fexci=5000,Rd=0.3,alpha=3.2,namp=0.04,nwidth=0.4,vibrate=5,fout=8000},function ()

	local vibratoF =  Vibrato.kr{freq, rate= vibrate, depth= 0.01, delay= 0.2, onset= 0, rateVariation= 0.5, depthVariation= 0.1, iphase =  0}

	local ra = (0.048*Rd-0.01)
	local rk = (0.118*Rd+0.224)
	local den = 0.44*Rd-4*ra*(0.5 + 1.2*rk)
	local rg = (0.5 + 1.2*rk)*rk/den
	local Ta = ra --*to
	local Tp = 1/(2*rg)
	local Te = Tp*(rk + 1)


	local exci = LFglottal.ar(vibratoF,Tp,Te,Ta,alpha,namp,nwidth)*glot*3
	--exci = Mix(exci
	exci = LPF.ar(exci,fexci)
	--exci =  BrownNoise.ar()*plosive*EnvGen.ar(Env({0,0,1},{0.02,0.04}),t_gate) + exci
	exci =  WhiteNoise.ar()*plosive + exci

	exci = exci*amp*Gain

	local env=EnvGen.ar(Env.asr(0.01, 1, 0.1), gate, nil,nil,nil,2);

	local nsecs = math.floor(#Ar*0.5 + 0.5)
	local pend = (1- fAc)/(nsecs - 1)
	for ii=1,nsecs do
		--Ar[ii] = Ar[ii]*(fAc + (ii-1)*pend)
		df[ii] = df[ii]*(fAc + (ii-1)*pend)
	end

	local noise = WhiteNoise.ar()*0.1*amp *EnvGen.ar(Env({0,0,1},{0,0.08}),t_gate)
	noise = BBandPass.ar(noise,noisef,noisebw) --Resonz.ar(noise,noisef,0.08)
	noise = Mix(noise)
	lossF = (17/#Area)*4e-3*lossF
	--lenT  = EnvGen.kr(Env({lenT,lenT},{rate}),t_gate)
	--lenT = 17.5
	local lenf = SampleRate.ir()*lenT*fA/(35000*#Ar)
	local dels = df*lenf
	--local signal = SinOsc.ar(100) 
	local signal = HumanVNdel.ar(exci,noise,noiseloc,lossF,lossG,-lossL,-lossN,lmix,nmix,area1len,dels,Ar,ArN)*env 
	
	local throat = LPF.ar(exci,400)
	signal = signal + throat*thlev
	signal = LPF.ar(signal,fout)
	--signal = signal + SinOsc.ar(200)*EnvGen.ar(Env.perc(0,0.2,1),t_gate)
	signal = LeakDC.ar(signal,0.91)

	--signal = {signal*3,K2A.ar(t_gate)}
	signal = Pan2.ar(signal*3,pan);
	return Out.ar(out,  signal) --
end):store() 

Tract.sinte_chen=SynthDef("testChenHumanVN"..NN, {samples= 1,out=0, gate=1,t_gate=1, freq=60,amp=0.6,pan=0,lossG=0.97,lossL=0.97,lossN=0.95,lossT=1,lossF=1,gainE=1,excibuf=0,excibuf1=0,excibuf2=0,area1len=8*22/17.5,gainN=gainN,Gain=1,lmix=1,nmix=1,Ar=Ref(TA():Fill(#Area,1.5)),ArN=Ref(Tract.AreaNoseC),lenT = 17.5,df=Ref(TA():Fill(#Area,1)),noiseloc=0,glot=1,noisef=Ref{2500,7500},noisebw=Ref{1,1},plosive=0,fA=1,fAc=1,fG1=0.4,fG2=0.2,fG2f=1,thlev=0,fexci=5000,OQ=0.8,asym=0.6,Sop=0.4,Scp=0.12},function ()

	local vibratoF =  Vibrato.kr{freq, rate= 5, depth= 0.01, delay= 0.2, onset= 0, rateVariation= 0.5, depthVariation= 0.1, iphase =  0}

	local exci = ChenglottalU.ar(vibratoF,OQ,asym,Sop,Scp)*glot*3
	exci = HPZ1.ar(exci)
	exci = LPF.ar(exci,fexci)*30
	--exci =  BrownNoise.ar()*plosive*EnvGen.ar(Env({0,0,1},{0.02,0.04}),t_gate) + exci
	exci =  WhiteNoise.ar()*plosive + exci

	--SendTrig.kr(t_gate,22,Ar[1])
	--SendReply.kr(Impulse.kr(4),"/tr",Ar)
	--SendTrig.kr(Impulse.kr(10),0,plosive)

	exci = exci*amp*Gain
	--local exci = Impulse.ar(vibratoF)
	local env=EnvGen.ar(Env.asr(0.01, 1, 0.1), gate, nil,nil,nil,2);

	local nsecs = math.floor(#Ar*0.5 + 0.5)
	local pend = (1- fAc)/(nsecs - 1)
	for ii=1,nsecs do
		--Ar[ii] = Ar[ii]*(fAc + (ii-1)*pend)
		df[ii] = df[ii]*(fAc + (ii-1)*pend)
	end

	local noise = WhiteNoise.ar()*0.1*amp *EnvGen.ar(Env({0,0,1},{0,0.08}),t_gate)
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
	--signal = signal + SinOsc.ar(200)*EnvGen.ar(Env.perc(0,0.2,1),t_gate)
	signal = LeakDC.ar(signal,0.91)

	--signal = {signal*3,K2A.ar(t_gate)}
	signal = Pan2.ar(signal*3,pan);
	return Out.ar(out,  signal) --
end):store() 

function Tract:MakeSynth(syname,args,excifunc)
	local defargs = {out=0, gate=1,t_gate=1, freq=60,amp=0.6,pan=0,lossG=0.97,lossL=0.97,lossN=0.95,lossT=1,lossF=1,area1len=8*22/17.5,Gain=1,lmix=1,nmix=1,Ar=Ref(TA():Fill(#Tract.areas.A,1.5)),ArN=Ref(Tract.AreaNoseC),lenT = 17.5,df=Ref(TA():Fill(#Tract.areas.A,1)),noiseloc=0,glot=1,noisef=Ref{2500,7500},noisebw=Ref{1,1},plosive=0,fA=1,fAc=1,thlev=0,fexci=6000,fout=8000}
	local function deffunc(excifunc)
		return function(newgt)
		setfenv(excifunc,newgt)
		local exci = excifunc()
		exci = exci*amp*Gain
		local env=EnvGen.ar(Env.asr(0.01, 1, 0.1), gate, nil,nil,nil,2);
		local nsecs = math.floor(#Ar*0.5 + 0.5)
		local pend = (1- fAc)/(nsecs - 1)
		for ii=1,nsecs do
			--Ar[ii] = Ar[ii]*(fAc + (ii-1)*pend)
			df[ii] = df[ii]*(fAc + (ii-1)*pend)
		end
		local noise = WhiteNoise.ar()*0.1*amp *EnvGen.ar(Env({0,0,1},{0,0.08}),t_gate)
		noise = BBandPass.ar(noise,noisef,noisebw) --Resonz.ar(noise,noisef,0.08)
		noise = Mix(noise)
		lossF = (17/#Area)*4e-3*lossF
		--lenT  = EnvGen.kr(Env({lenT,lenT},{rate}),t_gate)
		local lenf = SampleRate.ir()*lenT*fA/(35000*#Ar)
		local dels = df*lenf
		local signal = HumanVNdel.ar(exci,noise,noiseloc,lossF,lossG,-lossL,-lossN,lmix,nmix,area1len,dels,Ar,ArN)*env 
		local throat = LPF.ar(exci,400)
		signal = signal + throat*thlev
		signal = LPF.ar(signal,fout)
		signal = LeakDC.ar(signal,0.91)
		signal = Pan2.ar(signal*3,pan);
		return Out.ar(out,  signal)
		end
	end
	for k,v in pairs(args) do
		defargs[k]=v
	end
	self[syname] = SynthDef(syname..NN,defargs,deffunc(excifunc)):store()
end
---[[
Tract:MakeSynth("coral",{Rd=0.3,alpha=3.2,namp=0.04,nwidth=0.4,vibrate=5},
function()
	local fratio = midi2ratio(0.05)
	local freqs = TA():gseries(10,1 * fratio^(-5),fratio)
	--local freqs = TA():series(10,1 - 0.002*5,0.002)
	freqs = freq * freqs
	local vibratoF =  Vibrato.kr{freqs, rate= vibrate, depth= 0.01, delay= 0.0, onset= 0, 	rateVariation= 0.5, depthVariation= 0.1, iphase =  0}

	local ra = (0.048*Rd-0.01)
	local rk = (0.118*Rd+0.224)
	local den = 0.44*Rd-4*ra*(0.5 + 1.2*rk)
	local rg = (0.5 + 1.2*rk)*rk/den
	local Ta = ra --*to
	local Tp = 1/(2*rg)
	local Te = Tp*(rk + 1)


	local exci = LFglottal.ar(vibratoF,Tp,Te,Ta,alpha,namp,nwidth)*glot*3
	
	exci =  WhiteNoise.ar()*plosive + exci
	--exci = exci:Doi(function(v,i) return DelayC.ar(v,0.1,Rand(0,0.1)) end)
	exci = exci:Doi(function(v,i) return DelayC.ar(v,0.2,LFDNoise3.kr(0.1,0.05,0.05)) end)
	exci = Mix(exci)
	exci = LPF.ar(exci,fexci)
	--exci =  BrownNoise.ar()*plosive*EnvGen.ar(Env({0,0,1},{0.02,0.04}),t_gate) + exci
	
	return exci
end)
--]]
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
	local lenT = Tract.len[ph] or 17

	local noise = Tract.noise[ph]
	local noiseloc = noise and noise.pos or MINIMAL --0
	local noisefreq = noise and noise.freqs or {2500,7500}
	local noisebw = noise and noise.bw or {1,1}

	local glot = Tract.glot[ph] or 1
	local plosive = Tract.plosive[ph] or MINIMAL --0
	
	return {{Tract.areas[ph]},isN and {Tract.AreaNose} or {Tract.AreaNoseC},gain,lenT,noiseloc,{noisefreq},{noisebw},glot,plosive,Tract.area1len,1}
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
		local lenT = Tract.len[ph] or 17

		local noise = Tract.noise[ph]
		local noiseloc = noise and noise.pos or MINIMAL --0
		local noisefreq = noise and noise.freqs or {2500,7500}
		local noisebw = noise and noise.bw or {1,1}

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
		makeenv(res,"Ar",Tract.areas[ph],rate,dur)
		makeenv(res,"ArN",isN and Tract.AreaNose or Tract.AreaNoseC,rate,dur)
		makeenv(res,"Gain",gain,rate,dur)
		makeenv(res,"lenT",lenT,rate,dur)
		makeenv(res,"noiseloc",noiseloc,0,rate+dur)
		--makeenv_tgate(res_t_gate,"gate_t",0.01,rate+dur-0.01)
		makeenv_tgate(res_t_gate,"t_gate",0.01,rate+dur-0.01)
		makeenv(res,"noisefreq",noisefreq,rate,dur)
		makeenv(res,"noisebw",noisebw,rate,dur)
		makeenv(res,"glot",glot,rate,dur)
		makeenv(res,"plosive",plosive,rate,dur)
		makeenv(res,"area1len",Tract.area1len,rate,dur)
		--print(ph,rate,dur)
		--table.insert(res,{{Tract.areas[ph]},isN and {Tract.AreaNose} or {Tract.AreaNoseC},gain,rate,lenT,noiseloc,{noisefreq},{noisebw},glot,plosive,Tract.area1len,dur})
	end
	for k,p in pairs(res) do
		res[k] = ENV(p[1],p[2],"cub",false,true) 
		--res[k] = ENVm(p[1],p[2],nil,false,true)
	end
	--res.t_gate = ENVstep(res_t_gate.t_gate[1],res_t_gate.t_gate[2],nil,false,true)
	res.t_gate = ENV(res_t_gate.t_gate[1],res_t_gate.t_gate[2],"step",false,true)
	res.advance = -beats2Time(syl.timetillvoc)
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
		local lenT = Tract.len[ph] or 17

		local noise = Tract.noise[ph]
		local noiseloc = noise and noise.pos or 0
		local noisefreq = noise and noise.freqs or {2500,7500}
		local noisebw = noise and noise.bw or {1,1}

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
		res[k] = ENVmx(p[1],p[2],nil,false)
	end
	return res
end
function Tract:Talk(pat,tex,sologuion,allvocals,fade)
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
	prtable(syls2)
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