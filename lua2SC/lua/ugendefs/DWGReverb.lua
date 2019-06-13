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
DWGReverb3Band = MultiOutUGen:new{name="DWGReverb3Band"}
function DWGReverb3Band.ar(inp,len,xover,rtlow,rtmid,fdamp,coefs,perm,doprime)
	inp = inp or 0;xover = xover or 200;rtlow = rtlow or 3;rtmid = rtmid or 2;fdamp = fdamp or 6000;len = len or 32000;
	coefs = coefs or {1,0.9464,0.87352,0.83,0.8123,0.7398,0.69346,0.6349}
	doprime = doprime or 0
	perm = perm or {1,2,3,4,5,6,7,0}
	assert(#coefs==8)
	assert(#perm==8)
	return DWGReverb3Band:MultiNew(concatTables({2,2,inp,len,xover,rtlow,rtmid,fdamp,doprime},coefs,perm))
end
DWGReverb3Band_16 = MultiOutUGen:new{name="DWGReverb3Band_16"}
function DWGReverb3Band_16.ar(inp,len,xover,rtlow,rtmid,fdamp,coefs,perm,doprime)
	inp = inp or 0;xover = xover or 200;rtlow = rtlow or 3;rtmid = rtmid or 2;fdamp = fdamp or 6000;len = len or 32000;
	coefs = coefs or {1, 0.97498666666667, 0.94997333333333, 0.917248, 0.88323733333333, 0.85901333333333, 0.838704, 0.82528, 0.81702, 0.7978, 0.76396666666667, 0.73362133333333, 0.711996, 0.689556, 0.662228, 0.6349}	
	doprime = doprime or 0
  --perm = perm or {0,1,2,3,4,5,6,7} 
	perm = perm or {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0}
	assert(#coefs==16)
	assert(#perm==16)
	return DWGReverb3Band_16:MultiNew(concatTables({2,2,inp,len,xover,rtlow,rtmid,fdamp,doprime},coefs,perm))
end

EarlyRef = MultiOutUGen:new{name='EarlyRef'}
function EarlyRef.ar(inp,Ps,Pr,L,HW,B,N,p,allp_lens,allp_c)
	inp = inp or 0;p = p or 0;N = N or 1
	Ps = Ps or {0,0,0};Pr = Pr or {0,0,0};L = L or {1,1,1};HW = HW or 0.2;B= B or 0.97;allp_c = allp_c or 0.7;allp_lens = allp_lens or {347,113,37}
--todo assert on table lengts!=3
	return EarlyRef:MultiNew(concatTables({2,2,inp},Ps,Pr,L,{HW,B,N,p},allp_lens,{allp_c}))
end

EarlyRefGen = UGen:new{name='EarlyRefGen'}
function EarlyRefGen.kr(bufL,bufR,Ps,Pr,L,HW,B,N,Hangle)
	bufL = bufL or 0;bufR = bufR or 0
	Ps = Ps or {0,0,0};Pr = Pr or {0,0,0};L = L or {1,1,1};HW = HW or 0.2;B= B or 0.97;N = N or 0; Hangle = Hangle or 0
	return EarlyRefGen:MultiNew(concatTables({1,bufL,bufR},Ps,Pr,L,{HW,B,N,Hangle}))
end
EarlyRef27 = UGen:new{name='EarlyRef27'}
function EarlyRef27.kr(inp,Ps,Pr,L,HW,B)
	Ps = Ps or {0,0,0};Pr = Pr or {0,0,0};L = L or {1,1,1};HW = HW or 0.2;B= B or 0.97;
	return EarlyRef27:MultiNew(concatTables({2,2,inp},Ps,Pr,L,{HW,B}))
end

EarlyRefAtkGen = UGen:new{name='EarlyRefAtkGen'}
function EarlyRefAtkGen.kr(bW,bX,bY,bZ,Ps,Pr,L,HW,B,N)
	bW = bW or 0;bX = bX or 0;bY = bY or 0;bZ = bZ or 0;
	Ps = Ps or {0,0,0};Pr = Pr or {0,0,0};L = L or {1,1,1};HW = HW or 0.2;B= B or 0.97;N = N or 0
	return EarlyRefAtkGen:MultiNew(concatTables({1,bW,bX,bY,bZ},Ps,Pr,L,{HW,B,N}))
end
PartConvT = UGen:new{name='PartConvT'}
function PartConvT.ar(inp,fftsize,irbufnum,trig)
	assert(inp)
	trig = trig or 1
	return PartConvT:MultiNew{2,inp,fftsize,irbufnum,trig}
end