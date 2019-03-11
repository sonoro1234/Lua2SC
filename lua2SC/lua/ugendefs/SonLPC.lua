SonLPC=UGen:new{name="SonLPC"}
function SonLPC.ar(buff,size,hop,poles,inp)
	buff = buff or -1;size = size or 1024;hop = hop or 0.5;poles = poles or 4;inp = inp or 0
	return SonLPC:MultiNew{2,buff,size,hop,poles,inp}
end

SonLPCSynth=UGen:new{name="SonLPCSynth"}
function SonLPCSynth.ar(chain,inp)
	chain = chain or -1;inp = inp or 0
	return SonLPCSynth:MultiNew{2,chain,inp}
end