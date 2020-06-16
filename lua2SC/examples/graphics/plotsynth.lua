
SynthDef("source3",{out=0},function() 
	local sig = SinOsc.ar(200)
	Out.ar(out,sig)
end):plot(0.2)

