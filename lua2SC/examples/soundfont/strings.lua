sfzR = require"sc.sfzreader"

-- set SOSpath in your system
SOSpath = [[C:\supercolliderrepos\SFZ\sso-master\Sonatina Symphonic Orchestra\]]
local violin1 = sfzR.read(SOSpath..[[Strings - 1st Violins Sustain.sfz]])
local violin2 = sfzR.read(SOSpath..[[Strings - 2nd Violins Sustain.sfz]])
local viola = sfzR.read(SOSpath..[[Strings - Violas Sustain.sfz]])
local celli = sfzR.read(SOSpath..[[Strings - Celli Sustain.sfz]])
local bass = sfzR.read(SOSpath..[[Strings - Basses Sustain.sfz]])

-- synthdef for reverb
SynthDef("dwgreverb", { busin=0, busout=0,predelay=0.1,c1=1.2,c3=4,len=1200,mix = 1},function()
	local source=Mix(In.ar(busin,2)); 
	source = DelayC.ar(source,0.5,predelay)
	source = DWGReverbC1C3_16.ar(source,len,c1,c3,mix)	
	ReplaceOut.ar(busout,source)
end):store(true);


local scale = {modes.aeolian}
local amp = 0.4


v1 = OscEP{sends={0.5},channel={level=db2amp(-20)}}
v1:Bind(PS({
	dur = 2,
	escale = scale,
	degree = LOOP{1,2,3,4,5,6,7,8} + 7*6,
	amp = amp
},violin1.stream_player, sfzR.ampeg_def -- this sfzR.ampeg_def will override ampeg definitions
))

v2 = OscEP{sends={0.5},channel={level=db2amp(-20)}}
v2:Bind(PS({
	dur = 2,
	escale = scale,
	degree = LOOP{1,0,-1,-2,4,3,2,1} + 7*6,
	amp = amp
},violin2.stream_player, sfzR.ampeg_def))

vl = OscEP{sends={0.5},channel={level=db2amp(-20)}}
vl:Bind(PS({
	dur = 4,
	escale = scale,
	degree = LOOP{3,2,1,0,-1,-2,-3,-4} + 7*5,
	amp = amp
},viola.stream_player, sfzR.ampeg_def))

ce = OscEP{sends={0.5},channel={level=db2amp(-20)}}
ce:Bind(PS({
	dur = 4,
	escale = scale,
	degree = LOOP{1,1,1,1,1,1,1,1} + 7*4,
	amp = amp
},celli.stream_player, sfzR.ampeg_def))

cb = OscEP{sends={0.5},channel={level=db2amp(-20)}}
cb:Bind(PS({
	dur = 4*2,
	escale = scale,
	degree = LOOP{1,0,-1,-2,-3,-4,-5,-6} + REP(8,LOOP{7*4,7*3}),
	amp = amp
},bass.stream_player, sfzR.ampeg_def))

Effects ={FX("dwgreverb",nil,nil,{c1=1.2})}
theMetro:tempo(100)
theMetro:start()