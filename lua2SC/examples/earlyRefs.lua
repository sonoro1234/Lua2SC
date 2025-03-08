SynthDef("impulse",{out=Master.busin,gate=1},function()
	local env = EnvGen.kr{Env.asr(0,1,0),gate,doneAction=2}
	local input = Impulse.ar(0)
	input = LPF.ar(input, 8000) * 3;
	Out.ar(out,input:dup());
end):store()

local ERmaker = require"sc.ER"
local ER = ERmaker(0.75,1,1,{direct=false,part=true;compensation=false,N=5,bypass=true})
Sync()

--two clickers playing, each one with its early reflection5 parameters, try changing angle, distance and azimuth 
clicker = OscEP{inst="impulse",sends={db2amp(-24)},channel={level=db2amp(0)}}
clicker:Bind{dur=1}
ER:setER(clicker,-0.5)

clicker2 = OscEP{inst="impulse",sends={db2amp(-24)},channel={level=db2amp(0)}}
clicker2:Bind{dur=LS{0.5,LOOP{1}}}
ER:setER(clicker2,0.5)

MASTER{level=db2amp(0)}

theMetro:tempo(60)
theMetro:start()