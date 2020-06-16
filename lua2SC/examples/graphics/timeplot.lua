
grafic = addControl{ typex="timeplot",width=500,height=300,miny=-1,maxy=1}

SynthDef("repl",{out=0,t_trigNO=0},function()
	t_trig = Impulse.kr(10)
	local amp = TRand.kr(-1,1,t_trig)
	SendReply.kr(t_trig,"repl",{amp})
	local sig = SinOsc.ar(50)*amp
	Out.ar(out,sig:dup())
end):store(true):play()


OSCFunc.newfilter("repl",nil,function(msg) 
	grafic:val(msg[2][3])
end)