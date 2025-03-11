SynthDef("impulse",{out=Master.busin,gate=1},function()
	local env = EnvGen.kr{Env.asr(0,1,0),gate,doneAction=2}
	local input = Impulse.ar(0)
	input = LPF.ar(input, 8000) * 3;
	Out.ar(out,input:dup());
end):store()

SynthDef("dwgreverb3band", { busin=0, busout=0,predelay=0.05,time=1,xover=200,rtlow=1,rtmid=1,fdamp=6000,len=1200,bypass=0},function()
	local input = In.ar(busin,2)
	--local fx = input[1] 
	local fx =	Mix(input); --mixing LR does comb effect
	fx = DelayC.ar(fx,0.5,predelay)
	fx = DWGReverb3Band_16.ar(fx,len,xover,time*rtlow,time*rtmid,fdamp)	
	ReplaceOut.ar(busout,Select.ar(bypass,{fx, input}))
end):store();

local ERmaker = require"sc.ER"
local ER = ERmaker(0.75,1,1,{atk=false, direct=false, part=true; compensation=false, bypass=true})
Sync()

--two clickers playing, each one with its early reflection5 parameters, try changing angle, distance and azimuth 
clicker = OscEP{inst="impulse",sends={db2amp(-10)},channel={level=db2amp(0)}}
clicker:Bind{dur=1}
ER:setER(clicker,-0.5)

clicker2 = OscEP{inst="impulse",sends={db2amp(-10)},channel={level=db2amp(0)}}
clicker2:Bind{dur=LS{0.5,LOOP{1}}}
ER:setER(clicker2,0.5)

Effects={FX("dwgreverb3band",db2amp(-10),nil,{rtmid=1,rtlow=1,time=2,len=2700})}
MASTER{level=db2amp(0)}
Master.inserts = {{"to_mono",{bypass=1}}}

FScope()
theMetro:tempo(60)
theMetro:start()