SonLPC=UGen:new{name="SonLPC"}
function SonLPC.ar(buff,inp,hop,poles)
	buff = buff or -1;inp = inp or 0;hop = hop or 0.5;poles = poles or 4
	return SonLPC:MultiNew{2,buff,inp,hop,poles}
end

SonLPCSynth=UGen:new{name="SonLPCSynth"}
function SonLPCSynth.ar(chain)
	chain = chain or -1;
	return SonLPCSynth:MultiNew{2,chain}
end

SonLPCError=UGen:new{name="SonLPCError"}
function SonLPCError.ar(chain)
	chain = chain or -1;
	return SonLPCError:MultiNew{2,chain}
end

SonLPCSynthInput=UGen:new{name="SonLPCSynthInput"}
function SonLPCSynthInput.ar(chain,inp,useG)
	chain = chain or -1;inp = inp or 0;useG = useG or 0
	return SonLPCSynthInput:MultiNew{2,chain,inp,useG}
end

SonLPCSynthIn=UGen:new{name="SonLPCSynthIn"}
function SonLPCSynthIn.ar(chain,inp)
	chain = chain or -1;inp = inp or 0
	return SonLPCSynthIn:MultiNew{2,chain,inp}
end

SonLPCMorph=UGen:new{name="SonLPCMorph"}
function SonLPCMorph.ar(chain, chain2)
	chain = chain or -1;chain2 = chain2 or -1;
	return SonLPCMorph:MultiNew{2,chain, chain2}
end