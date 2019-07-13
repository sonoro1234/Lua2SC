
s = require"sclua.Server".Server()

sdef = SynthDef("vsti", { out = 0,bypass=0,param=Ref{15,1}},function()
    -- VST instruments usually don't have inputs
    Out.ar(out, VSTPlugin.ar(nil, 2,bypass))--,param));
end):store()

--[[
VSTPlugin.search(nil,nil,nil,true)
prtable(VSTPlugin.getDict())
pdict = VSTPlugin.getDict()
for k,v in pairs(pdict) do print(k,v.name) end
--]]

syn = s.Synth("vsti",{out=Master.busin})

fx = VSTPluginController:new(syn,nil,sdef)
s:sync()

local name = "Model-E"--"VB-1" --"TAL-Elek7ro - TAL"
fx:open(name,true)
s:sync()
fx:editor()

--fx:program_(0)
--fx:set(14,0.5)
--fx:set(15,0.6)

pl = MidiEP{}
pl:Bind(PS{
	dur = 4,
	note = LOOP{60,65,55}-12,
	velo = 67,
	chan = 0,	midisender = fx
})
theMetro:start()

