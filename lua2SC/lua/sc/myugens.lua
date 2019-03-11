KLJunction=UGen:new{name='KLJunction'}
function KLJunction.ar(input,lossarray,karray,delaylengtharray,mul,add)
	input=input or 0;lossarray=lossarray or 1;mul=mul or 1;add=add or 0;
	--local lossarrayfix = (type(lossarray)=="table" and lossarray.isRef) and lossarray or TA():Fill(#delaylengtharray + 1,lossarray)
	local lossarrayfix = lossarray
	--local allargs= TA(lossarrayfix)..TA(karray)..TA(delaylengtharray);
	local allargs= concatTables(lossarrayfix,karray,delaylengtharray);
	--prtable("karray",delaylengtharray)
	return KLJunction:MultiNew{2,input,unpack(allargs)}:madd(mul,add)
end
KLJunction2=UGen:new{name='KLJunction2'}
function KLJunction2.ar(input,lossarray,karray,delaylengtharray,mul,add)
	input=input or 0;lossarray=lossarray or 1;mul=mul or 1;add=add or 0;
	--local lossarrayfix = (type(lossarray)=="table" and lossarray.isRef) and lossarray or TA():Fill(#delaylengtharray + 1,lossarray)
	local lossarrayfix = lossarray
	--local allargs= TA(lossarrayfix)..TA(karray)..TA(delaylengtharray);
	local allargs= concatTables(lossarrayfix,karray,delaylengtharray);
	--prtable("karray",delaylengtharray)
	return KLJunction2:MultiNew{2,input,unpack(allargs)}:madd(mul,add)
end
KLJunction3=UGen:new{name='KLJunction3'}
function KLJunction3.ar(input,lossarray,karray,delaylengtharray,mul,add)
	input=input or 0;lossarray=lossarray or 1;mul=mul or 1;add=add or 0;
	--local lossarrayfix = (type(lossarray)=="table" and lossarray.isRef) and lossarray or TA():Fill(#delaylengtharray + 1,lossarray)
	local lossarrayfix = lossarray
	--local allargs= TA(lossarrayfix)..TA(karray)..TA(delaylengtharray);
	local allargs= concatTables(lossarrayfix,karray,delaylengtharray);
	--prtable("karray",delaylengtharray)
	return KLJunction3:MultiNew{2,input,unpack(allargs)}:madd(mul,add)
end
HumanV=UGen:new{name='HumanV'}
function HumanV.ar(input,loss,rg,rl,areas,mul,add)
	input=input or 0;loss=loss or 1;mul=mul or 1;add=add or 0;
	rg = rg or 1;rl = rl or -1;
	return HumanV:MultiNew{2,input,loss,rg,rl,unpack(areas)}:madd(mul,add)
end
HumanVdel=UGen:new{name='HumanVdel'}
function HumanVdel.ar(input,loss,rg,rl,dels,areas,mul,add)
	input=input or 0;loss=loss or 1;mul=mul or 1;add=add or 0;
	rg = rg or 1;rl = rl or -1;
	local data = concatTables(#dels,dels,#areas,areas)
	return HumanVdel:MultiNew{2,input,loss,rg,rl,unpack(data)}:madd(mul,add)
end
--(input, loss,rg,rl,rn,area1len,numtubes, areas,areasNlen,areasN );
HumanVN=UGen:new{name='HumanVN'}
function HumanVN.ar(input,loss,rg,rl,rn,lmix,nmix,area1len,areas,areasN,mul,add)
	input=input or 0;loss=loss or 1;mul=mul or 1;add=add or 0;
	rg = rg or 1;rl = rl or -1;rn = rn or 1
	lmix = lmix or 1;nmix = nmix or 1
	area1len = area1len or math.floor(#areas/2)
	local data = concatTables(#areas,areas,#areasN,areasN)
	return HumanVN:MultiNew{2,input,loss,rg,rl,rn,lmix,nmix,area1len,unpack(data)}:madd(mul,add)
end
--(input, loss,rg,rl,rn,area1len,numtubes, areas,areasNlen,areasN );
HumanVNdel=UGen:new{name='HumanVNdel'}
function HumanVNdel.ar(input ,inputnoise,noiseloc,loss,rg,rl,rn,lmix,nmix,area1len,del,areas,areasN,mul,add)
	input=input or 0;loss=loss or 1;mul=mul or 1;add=add or 0;
	rg = rg or 1;rl = rl or -1;rn = rn or 1
	lmix = lmix or 1;nmix = nmix or 1
	del = del or 0
	inputnoise = inputnoise or 0
	noiseloc = noiseloc or 0
	area1len = area1len or math.floor(#areas/2)
	local data = concatTables(#del,del,#areas,areas,#areasN,areasN)
	return HumanVNdel:MultiNew{2,input,loss,rg,rl,rn,lmix,nmix,area1len,inputnoise,noiseloc,unpack(data)}:madd(mul,add)
end
HumanVNdelO2=UGen:new{name='HumanVNdelO2'}
function HumanVNdelO2.ar(input ,inputnoise,noiseloc,loss,rg,rl,rn,lmix,nmix,area1len,del,areas,areasN,mul,add)
	input=input or 0;loss=loss or 1;mul=mul or 1;add=add or 0;
	rg = rg or 1;rl = rl or -1;rn = rn or 1
	lmix = lmix or 1;nmix = nmix or 1
	del = del or 0
	inputnoise = inputnoise or 0
	noiseloc = noiseloc or 0
	area1len = area1len or math.floor(#areas/2)
	local data = concatTables(#del,del,#areas,areas,#areasN,areasN)
	return HumanVNdelO2:MultiNew{2,input,loss,rg,rl,rn,lmix,nmix,area1len,inputnoise,noiseloc,unpack(data)}:madd(mul,add)
end
HumanVNdelU=UGen:new{name='HumanVNdelU'}
function HumanVNdelU.ar(input ,inputnoise,noiseloc,loss,rg,rl,rn,lmix,nmix,area1len,del,areas,areasN,mul,add)
	input=input or 0;loss=loss or 1;mul=mul or 1;add=add or 0;
	rg = rg or 1;rl = rl or -1;rn = rn or 1
	lmix = lmix or 1;nmix = nmix or 1
	del = del or 0
	inputnoise = inputnoise or 0
	noiseloc = noiseloc or 0
	area1len = area1len or math.floor(#areas/2)
	local data = concatTables(#areas,areas,#areasN,areasN)
	return HumanVNdelU:MultiNew{2,input,loss,rg,rl,rn,lmix,nmix,area1len,del,inputnoise,noiseloc,unpack(data)}:madd(mul,add)
end
LFglottal = UGen:new{name="LFglottal"}
function LFglottal.ar(freq, Tp,Te,Ta,alpha,namp,nwidth)
	freq = freq or 100; Tp = Tp or 0.4;Te = Te or 0.5;Ta = Ta or 0.028;alpha= alpha or 3.2;namp= namp or 0.04;nwidth = nwidth or 0.4
	return LFglottal:MultiNew{2,freq,Tp,Te,Ta,alpha,namp,nwidth}
end
VeldhuisGlot = UGen:new{name="VeldhuisGlot"}
function VeldhuisGlot.ar(freq, Tp,Te,Ta,namp,nwidth)
	freq = freq or 100; Tp = Tp or 0.4;Te = Te or 0.5;Ta = Ta or 0.028;namp= namp or 0.04;nwidth = nwidth or 0.4
	return VeldhuisGlot:MultiNew{2,freq,Tp,Te,Ta,namp,nwidth}
end
ChenglottalU = UGen:new{name="ChenglottalU"}
function ChenglottalU.ar(freq, OQ,asym,Sop,Scp)
	freq = freq or 100; OQ = OQ or 0.8; asym = asym or 0.6; Sop = Sop or 0.5;Scp = Scp or 0.5
	return ChenglottalU:MultiNew{2,freq, OQ,asym,Sop,Scp}
end
DWGReverbC1C3 = MultiOutUGen:new{name="DWGReverbC1C3"}
function DWGReverbC1C3.ar(inp,len,c1,c3,mix,coefs,perm,doprime)
	inp = inp or 0;c1 = c1 or 1;c3 = c3 or 1;len = len or 32000;mix = mix or 1
	coefs = coefs or {1,0.9464,0.87352,0.83,0.8123,0.7398,0.69346,0.6349}
	doprime = doprime or 1
  --perm = perm or {0,1,2,3,4,5,6,7} 
	perm = perm or {1,2,3,4,5,6,7,0}
	--perm = perm or {3,4,5,6,7,0,1,2}
	--perm = perm or {7,0,1,2,3,4,5,6}
	assert(#coefs==8)
	assert(#perm==8)
	return DWGReverbC1C3:MultiNew(concatTables({ 2,2,inp,len,c1,c3,mix,doprime},coefs,perm))
end
DWGReverb = DWGReverbC1C3
DWGReverbC1C3_16 = MultiOutUGen:new{name="DWGReverbC1C3_16"}
function DWGReverbC1C3_16.ar(inp,len,c1,c3,mix,coefs,perm,doprime)
	inp = inp or 0;c1 = c1 or 1;c3 = c3 or 1;len = len or 32000;mix = mix or 1
	coefs = coefs or {1, 0.97498666666667, 0.94997333333333, 0.917248, 0.88323733333333, 0.85901333333333, 0.838704, 0.82528, 0.81702, 0.7978, 0.76396666666667, 0.73362133333333, 0.711996, 0.689556, 0.662228, 0.6349}	
	doprime = doprime or 1
  --perm = perm or {0,1,2,3,4,5,6,7} 
	perm = perm or {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0}
	--perm = perm or {3,4,5,6,7,0,1,2}
	--perm = perm or {7,0,1,2,3,4,5,6}
	assert(#coefs==16)
	assert(#perm==16)
	return DWGReverbC1C3_16:MultiNew(concatTables({ 2,2,inp,len,c1,c3,mix,doprime},coefs,perm))
end
EarlyRefGen = UGen:new{name='EarlyRefGen'}
function EarlyRefGen.kr(bufL,bufR,Ps,Pr,L,HW,B,N)
	bufL = bufL or 0;bufR = bufR or 0
	Ps = Ps or {0,0,0};Pr = Pr or {0,0,0};L = L or {1,1,1};HW = HW or 0.2;B= B or 0.97;N = N or 0
	return EarlyRefGen:MultiNew(concatTables({1,bufL,bufR},Ps,Pr,L,{HW,B,N}))
end
PartConvT = UGen:new{name='PartConvT'}
function PartConvT.ar(inp,fftsize,irbufnum,trig)
	assert(inp)
	trig = trig or 1
	return PartConvT:MultiNew{2,inp,fftsize,irbufnum,trig}
end
LDelay = UGen:new{name="LDelay"}
function LDelay.ar(inp, delay)
	inp=inp or 0;delay = delay or 0;
	return LDelay:MultiNew{2,inp, delay}
end
Adachi=UGen:new{name="Adachi"}
function Adachi.ar(flip,p0,radio,buffnum,yequil,mul,add)
	local flip = flip or 231;p0 = p0 or 5000;radio= radio or 0.005;mul=mul or 1;add=add or 0;yequil = yequil or 0;gate = gate or 1
	return Adachi:MultiNew{2,flip,p0,radio,buffnum,yequil,gate}:madd(mul,add)
end
AdachiAyers=UGen:new{name="AdachiAyers"}
function AdachiAyers.ar(flip,p0,radio,buffnum,buffnum2,buffnum3,yequil,gate,delay,mul,add)
	local flip = flip or 231;p0 = p0 or 5000;radio= radio or 0.005;mul=mul or 1;add=add or 0;yequil = yequil or 0;gate = gate or 1;delay = delay or 0
	return AdachiAyers:MultiNew{2,flip,p0,radio,buffnum,buffnum2,buffnum3,yequil,gate,delay}:madd(mul,add)
end
AdachiIIR=UGen:new{name="AdachiIIR"}
function AdachiIIR.ar(flip,p0,radio,buffnum1b,buffnum1a,buffnum2,buffnum3,yequil,gate,delay,mul,add)
	local flip = flip or 231;p0 = p0 or 5000;radio= radio or 0.005;mul=mul or 1;add=add or 0;yequil = yequil or 0;gate = gate or 1;delay = delay or 0
	return AdachiIIR:MultiNew{2,flip,p0,radio,buffnum1b,buffnum1a,buffnum2,buffnum3,yequil,gate,delay}:madd(mul,add)
end
ParamTest=UGen:new{name="ParamTest"}
function ParamTest.ar(P1,buf)
	return ParamTest:MultiNew{2,P1,buf}
end

MichaelPhaser1 = {}
function MichaelPhaser1.ar(...)
		--input, depth = 0.5, rate = 1, fb = 0.3, cfb = 0.1, rot = 0.5pi;
	local   input, depth,rate, fb,cfb,rot   = assign({'input', 'depth','rate', 'fb','cfb','rot' },{ nil, 0.5, 1, 0.3,0.1,0.5*math.pi },...)
	local  output, lfo, feedback, ac;

	-- compute allpass coefficient
	local function ac(freq)
		local theta = math.pi*SampleDur.ir()*freq;
		local tantheta = theta:tan()
		local a1 = (1 - tantheta)/(1 + tantheta);
		return a1;
	end

	local lfo = TA({0, rot}):Do( function(w) return SinOsc.ar(rate, w):range(0, 1) end)
	local feedback = LocalIn.ar(2);
	local output = input + (feedback*fb) + (feedback:reverse()*cfb);
	TA({{16, 1600}, {33, 3300}, {48, 4800}, {98, 9800}, {160, 16000}, {260, 22050}}):Do(function(freqs)
		local a1 = ac(freqs[1] + ((freqs[2] - freqs[1])*lfo));
		output = FOS.ar(output, a1, -1, a1);   -- 1st order allpass
	end)
	output = depth*output;
	LocalOut.ar(output);

	return ((1 - depth)*input + output);
end

Karplus=UGen:new{name="Karplus"}
function Karplus.ar(inp,trig,maxdelaytime,delaytime,decaytime,coef,coefsA,coefsB,mul,add)
	inp=inp or 0;trig=trig or 1;maxdelaytime=maxdelaytime or 0.2;delaytime=delaytime or 0.2
	decaytime=decaytime or 1;coef=coef or 0.5;coefsA=coefsA or {-0.6};coefsB=coefsB or {1-0.6};mul=mul or 1;add=add or 0
	return Karplus:MultiNew(concatTables({2,inp,trig,maxdelaytime,delaytime,decaytime,coef},#coefsA,#coefsB,coefsA,coefsB)):madd(mul,add)
end
------------------------

IIRf = UGen:new{name="IIRf"}
function IIRf.ar(inp, kB,kA)
	inp = inp or 0;
	return IIRf:MultiNew(concatTables({2,inp, #kB,#kA},kB,kA))
end
