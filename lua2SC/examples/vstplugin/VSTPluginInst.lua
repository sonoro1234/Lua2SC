OSCFunc.trace(false,false)

DONT_OPENGUI = true
s = require"sclua.Server".Server()

sdef = SynthDef("vsti", { out = 0,bypass=0,p1=1},function()
    -- VST instruments usually don't have inputs
   Out.ar(out, VSTPlugin.ar(nil, 2,bypass))--,{0,SinOsc.kr(1):range(0,1),2,0.5}))
end):store()
s:sync()
---[[
VSTPlugin.clear()
print"doing search"
VSTPlugin.search(nil,nil,nil,true)
s:sync()
print"done search"
VSTPlugin.print()
--prtable("dictprint",VSTPlugin.plugins())
--pdict = VSTPlugin.getDict()
--for k,v in pairs(pdict) do print(k,v.name) end
--]]

---[[
syn = s.Synth("vsti",{out=Master.busin})

fx = VSTPluginController:new(syn,nil,sdef)
s:sync()

plname = "Model-E"--"Helm" --"Model-E"--"VB-1" --"TAL-Elek7ro - TAL"
fx:open(plname,true,true)
s:sync()
fx:editor()

--fx:program_(1)
--fx:set(14,0.5)
--fx:set(15,0.6)
--fx:sendMidi(programChange(2,0))

--fx:writeProgram("c:/vstprog1")
--fx:readProgram("c:/vstprog1")

---[=[
pl = MidiEP{}
pl:Bind(PS{
	dur = 4,
	note = LOOP{60,65,55}-12,
	velo = 67,
	chan = 0,	midisender = fx
})
theMetro:start()

--print(fx.program)
--print(fx:numPrograms())
--]=]
--]]