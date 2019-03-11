Karplus=UGen:new{name="Karplus"}
function Karplus.ar(inp,trig,maxdelaytime,delaytime,decaytime,coef,coefsA,coefsB,mul,add)
	inp=inp or 0;trig=trig or 1;maxdelaytime=maxdelaytime or 0.2;delaytime=delaytime or 0.2
	decaytime=decaytime or 1;coef=coef or 0.5;coefsA=coefsA or {-0.6};coefsB=coefsB or {1-0.6};mul=mul or 1;add=add or 0
	return Karplus:MultiNew(concatTables({2,inp,trig,maxdelaytime,delaytime,decaytime,coef},#coefsA,#coefsB,coefsA,coefsB)):madd(mul,add)
end