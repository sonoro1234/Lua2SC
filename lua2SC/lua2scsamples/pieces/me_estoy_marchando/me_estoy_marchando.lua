--local NRT = require"sc.nrt":Gen(490)
-----------------------------------------SynthDefs
tract = require"num.tract"(32)

SynthDef("dwgreverb", { busin=0, busout=0,c1=4,c3=4,len=1200,mix = 1},function()
	local source=Mix(In.ar(busin,2)); 	
	source = DWGReverbC1C3_16.ar(source,len,c1,c3,mix)	
	ReplaceOut.ar(busout,source)
end):store();


ER = require"sc.ER"(0.9,1,1,{L={20,30,6},Pr={5,3,1.2},direct=true,N=4,l={125,42,12}})

SynthDef("testMembrane",{out=0,pos=0.2,t_gate=1,gate=1,ancho=200,fnoise=10000,amp=0.5,wsamp=100,tension=0.1,loss=1},function()
	loss = (-loss/1000):dbamp()
	local freeenv = EnvGen.kr{Env.asr(0,1,0),gate,doneAction=2}
	local bb = wsamp/44100
	amp = Latch.ar(amp, t_gate)
	local excitation = EnvGen.ar(Env.new({0,1,1,0},{bb,ancho/44100,0}),t_gate)*amp*LFDNoise3.ar(fnoise)
	local sig = MembraneCircle.ar(excitation, tension, loss)*0.3;
	Out.ar(out,Pan2.ar(sig,0))
end):store()

SynthDef("tambbody", { busin=0, busout=0,size=1,mics=1},function()
	local input=In.ar(busin,2); 
	local coefs = TA{199, 211, 223, 227, 229, 233, 239, 241 } *size
	local son = DWGSoundBoard.ar(input,nil,nil,mics,unpack(coefs:asSimpleTable()));
	ReplaceOut.ar(busout,son)
end):store();

------------------------- players ----------------------------------
---------------tambseq
tambpat = SF(PS{
	dur = LOOP{1,0.5,0.5,0.5,0.5,LS({1,1,1},3)},
	amp = noisefStream{0.5,1},
	ancho = 200,
	fnoise = noisefStream{7000,10000},
	wsamp = noisefStream{0,1000},
	tension = LOOP{1.1,4,4,4,RS{1.1,4} ,1.1,4,4, 1.1,4,1.1, 1.1,4,4}*0.01,
	loss = LOOP{1,6,2,6,RS{1,6}, 1,6,6, 1,6,RS{1,6}, 1,6,2},
	t_gate = 1
},function(val,e) --repetition for dur 1
	if val.delta == 1 then
		val.delta = 0.5
		local val2 = deepcopy(val)
		val2.amp = val2.amp * 0.2
		return LS{val,val2}
	end
	return val 
end)

tamb = OscEP{inst="testMembrane",mono=true,dontfree=true,sends={db2amp(-10)},channel={level=db2amp(4)}}:Bind(tambpat)

tamb.ppqOffset = 1/6 --little delay

--------------voices
voicparams = {
	fA = 0.85,
	fexci = 18500,
	Rd = 1.97,
	namp = 0.02,
	nwidth = 0.5,
	thlev = 0.14,
	vibrate = 5,
}

m1 = ENVdeg({-1,-1,0,0},{0.3,0.1,0.6})
m2 = ENVdeg({0,0,1,0},{0.5,0.25,0.25})
m1b = ENVdeg({0,0,-5},{0.9,0.1})
m0 = getdegree
frases = {}
frases[1] = "MES-TOI-MAR_R-TXANv-DO-LE-JOS-DEA-KI -MES-TOI-MAR_R-TXANv-DO-_v"
frases[2] = "LA-LUZ-BUS-KAN-DO-KEUN-DI-A-BI -LA-LUZ-BUS-KAN-DO-_v"
frases[3] = "SI-GOU-NAES-T_qRE-IA-KON-KO-RA-ZON -SI-GOU-NAES-T_qRE-IA-_v"
 

modfA0 = VIB(1,5,0.3,beats2Time(1.5))
modvibdeph = ENVr({1,1,1,3},{0,0.5,0.1}) 
melo = {
		dur = LS{1,1,1,1.5,1.5,1,1,1,3, 1,1,1,1.5,1.5+3,3,
				 1,1,1,1.5,1.5,1,1,1,3, 3,1,2,1.5,1.5+1,2},
		escale = {TA(scales.harmonicMinor) + (5)},
		fA0 = LOOP{1,1,1,1,1,1,1,1,1,1,1,1,1,modfA0,1},
		vibdeph = LOOP{1,1,1,1,1,1,1,1,1,1,1,1,1,modvibdeph,1}*0.01,
		rv = 0,
		degree = LOOP{3,5,5,4,3,3,3,2,4,3,5,5,4,3,REST} + 7*5,
		freq = LOOP{m1,m0,m0,m2,m0,m1,m0,m0,m0,m1,m0,m0,m2,m1b,m0}
}


function habla(fras)
	fras = fras or frases
	local talk = tract:Talk(fras[1])
	local talk2 = tract:Talk(fras[2])
	local talk3 = tract:Talk(fras[3])
	return LS{LS(PS(talk3),2),LS(PS(talk),2),LS(PS(talk2),2)}
end
function habla_ini(fras)
	fras = fras or frases
	local talk = tract:Talk(fras[1])
	local talk2 = tract:Talk(fras[2])
	local talk3 = tract:Talk(fras[3])
	return LS{LS(PS(talk),2),LS(PS(talk2),2)}
end
function habla_fin(fras)
	fras = fras or frases
	local talk = tract:Talk(fras[1])
	local talk2 = tract:Talk(fras[2])
	local talk3 = tract:Talk(fras[3])
	return LS{LS(PS(talk),2),LS(PS(talk2),2)}
end

--voice 1
sing = OscEP{inst=tract.sinteRdO2.name,mono=true,sends={db2amp(-10)},channel={level=0.5}}

sing:Bind(LS{DONOP(24),PS(LOOP{PS(melo,voicparams)},habla_ini(frases)),
DOREST(12),SETEv"voice2",LS{PS(LOOP{PS(melo,voicparams,{Rd=1.8})},habla_ini(frases))},
SETEv"voiceall",LS{PS(LOOP{PS(melo,voicparams,{Rd=1.7})},habla(frases))},
PS(LOOP{PS(melo,voicparams)},habla_fin(frases)),
DONOP(1),
FS(function() 
	local function fun()
		tamb.playing = false
	end
	return {delta=0,dur=0,freq=NOP,_=fun}
end)
})


-- voice 2
m4 = ENVdeg({0,0,1,0,-1,0,0,1,0,-1,0},{2/6,1/18,1/18,1/18,1/18,2/6,1/18,1/18,1/18,1/18})

melo2 = deepcopy(melo)
melo2.degree = melo2.degree + (-2)
melo2.freq = LOOP{m1,m0,m0,m2,m0,m1,m0,m0,m0, m1,m0,m0,m2,m4,m0}
melo2.amp = 0.6
melo2.fA0 = 1
melo2.vibdeph = nil
sing2 = copyplayer(sing)
sing2:Bind(LS{WAITEv"voiceall",PS(LOOP{PS(melo2,voicparams,{Rd=1.4,fA=0.85})},habla())
})

-- voice 3
melo3 = deepcopy(melo)
melo3.degree = LOOP{1,1,1,1,1,5-7,5-7,5-7,5-7,5-7,5-7,5-7,1,1,REST} + 7*5
melo3.fA0 = 1
melo3.vibdeph = nil
sing3 = copyplayer(sing)
sing3:Bind(LS{
WAITEv"voice2",PS(LOOP{PS(melo3,voicparams,{Rd=1.4,fA=0.95})},habla_ini()),
WAITEv"voiceall",PS(LOOP{PS(melo3,voicparams,{Rd=1.3,fA=0.95})},habla())
})

--- early reflections
ER:setER(tamb,-0.2,2)
ER:set(sing,{angle=0.5,bypass=0,dist=LS{1,RAMP(1,20,24*3)},dur=LS{372 + 24,25}})
ER:setER(sing2,-0.04,1)
ER:setER(sing3,-0.5,1)
------------------------ master

--DiskOutBuffer("me_estoy_marchando.wav")

MASTER{level=0.5}
Effects={FX("dwgreverb",db2amp(-3),nil,{c1=6,c3=6,len=1200})}
theMetro:tempo(170)
theMetro:start()