-- NRT = require"sc.nrt":Gen(2500)
-- KarplusMiniArp produces NAN with Karplus UGen so I changed it for DWGPluckedStiff
-- Although now Karplus is wrapped with Sanitize

-------------------------first the SynthDefs------------------------------
-- we will getting requiring a lua file with synthdefs in this script folder
-- and call sync for waiting to async complete
path = require"sc.path"
path.require_here()
require"synthdefs"
Sync()
-------------------------------------the sequences

--this sequence was live recorded with midirecord 
player = OscEP{inst="plukVm",dontfree=true,sends={0.3},channel={inst="channel1x2",pan= 0,dur=1}}
player:Bind(LOOP{PS{
	note = LS{57,50,64,67,57,50,62,65,50,57,64,67,65,50,64,57,65,},
	amp = SF(LS{0.26771653543307,0.15748031496063,0.24409448818898,0.25984251968504,0.44094488188976,0.37795275590551,0.32283464566929,0.31496062992126,0.66141732283465,0.73228346456693,0.58267716535433,0.85826771653543,0.50393700787402,0.39370078740157,0.45669291338583,0.76377952755906,0.47244094488189,}*noisefStream{1,2}, function(val) return 0.2 + val*0.7 end), --compression
	delta = LS{0.019999980926514,0.019999980926514,0,4.039999961853,0.019999980926514,0.019999980926514,0.039999961853027,3.9800000190735,0.38000011444092,0.44000005722046,0.53999996185303,1.6799998283386,0.90000009536743,0.099999904632568,0.82000017166138,0.53999996185303,2.539999961853 - 0.079999923706	,},
	dur = LS{3.6599998474121,3.6199998855591,3.5599999427795,3.6199998855591,3.7800002098083,3.7800002098083,3.7000002861023,3.6400003433228,0.80000019073486,0.76000022888184,0.6399998664856,1.7400002479553,1.0199999809265,4,1.460000038147,3.0999999046326,2.539999961853,}
}})


desfase = 1.02

player2 = copyplayer(player)
player2.channel.pan = -1 
player2.Filters = {note = function(l) return l.note + 12 end,
					delta = function(l) return l.delta * desfase end}

player3 = copyplayer(player)
player3.channel.pan = 0 
player3.inst = "KarplusMiniArp"
player3.Filters = {note = function(l) return l.note + 24 end,
					delta = function(l) return l.delta * desfase^2 end}

player4 = copyplayer(player)
player4.channel.pan = 1 
player4.inst = "KarplusMiniArp"
player4.Filters = {note = function(l) return l.note + 12 end,
					delta = function(l) return l.delta * desfase^3 end}

bell = OscEP{MUSPOS=50,inst ="korean_bell" ,dontfree=true,sends={0.3},channel={level=1}}:Bind{
	dur = RSinf{30,0.25,0.25},
	freq = 800,
	amp =0.7,
	pan = noisefStream{-1,1}
}

----a player for theMetro
EP():Bind{
	dur=1,
	seq=LS{
		FS(function() theMetro:tempo(80) return 1 end,1),
		FS(function() theMetro:tempo(theMetro.bpm + 1) return 1 end,1640),
		FS(function() return 1 end,200),
		FS(function() theMetro:tempo(theMetro.bpm - 4) return 1 end,210),
		FS(function() theMetro:tempo(theMetro.bpm - 2) return 1 end,400),
		FS(function() return 1 end,83),
		FS(function() theMetro:stop() return 1 end,800)}
}

MASTER{level = db2amp(-10)}
--DiskOutBuffer([[cicles.wav]])
--Effects={FX("gverb",db2amp(0.77),nil,{revtime=10})}
Effects={FX("dwgreverb",db2amp(-1.6),nil,{c1=0.77,c3=15})}
theMetro:tempo(80)
theMetro:start()
