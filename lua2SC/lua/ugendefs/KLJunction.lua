
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