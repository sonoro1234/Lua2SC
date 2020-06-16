-- Humoristic and algorythmic piece playing automatic salsa

-------------------------first the SynthDefs------------------------------
-- we will get them requiring a lua file with synthdefs in this script folder
-- and call sync for waiting to async complete
path = require"sc.path"
path.require_here()
require"synthdefs"
Sync()
--------------------------------------------------------------------------
require("sc.PhonemesOLD") -- for using Formants 
RANDOM:seed(17) --for getting the same piece always we seed it with fixed number
escala={{0, 2, 3, 5, 7, 8, 10}} -- the scale

-- functions that will be used in providing durations
-- composition(n,p,m) returns p parts summing n with smaller part being m
function part(t)
	return composition(t[1],t[2],t[3])
end
function part2(t)
	local durini = choose{0,0.5}
	local left = t[1]-durini;
	local durs = composition(left,t[2],t[3])
	table.insert(durs,1,durini)
	return durs
end

--------- conductor ---------------------------
-- this wont sound but will provide a common phrase for soprano and pluk1 so that pluk1 answers to soprano melody
conductor=EP{name="conductor"}:Bind{
	dur=32,
	seq = FS(function() return permutation{1,2,3,4,5,6,7,8} end,-1),
	durlist = FS(function() return part{8,8,0.5} end,-1)
}
------------------------ counterbass ---------------------
-- plays rythmic variations over fraseB
fraseB=TA{1,5,4,RS{5,6},RS{1,5,6}} +7*3 
dursB2={2,2,2,1.5,0.5}
dursB2a={1.5,2.5,1.5,1.5,0.5} -- 8-0.5 for letting other durs do tumbao
dursB2b={2,2,2,RS{LS{1.5,0.5},LS{1,1}}}

bass=OscEP{inst="cbass",mono=true,sends={0},channel={inst="channel1x2",level=db2amp(0)}}
bass:Bind{
	
	escale=escala,
	decay=5,
	degree=LOOP(fraseB), 
	dur=LS{LS(dursB2a),LOOP{LS(dursB2b),LS(dursB2),AGLS(permutation,dursB2),LS(dursB2)}},
	legato = 0.9,
	coef=0.95,
	coef2=0.8,
	amp=0.8
}
bass.inserts = {{"Compander",{slopeAbove=.5,thresh=-30,postGain=1.7,bypass=0}}}
------------ soprano -------------------------------
voz="soprano"
soprano=OscEP{inst="formantVoice2",mono=true,sends={0.5},channel={level=db2amp(-1.5)}}
soprano:Bind{
	degree=LOOP{AGLS(function (c) if not c.curlist then return nil end 
		return TA(c.curlist.seq) + 7*5  end,conductor,2),REST },
	escale=escala,
	sweepRate= 1,--0.3,
	velo=0.4,
	pan=-0.3,
	legato=WRS({1,0.8},{0.9,0.1},-1),--RS({1,0.5},-1),
	dur=LOOP{AGLS(function (c)  return c.curlist.durlist end,conductor,2),16},
	[{"f","a","q"}]=LS(Formants:paramsPalabra({voz.."A",voz.."E",voz.."I",voz.."O",voz.."A",voz.."E",voz.."I",voz.."O",voz.."U"}),-1)
}

soprano.inserts = {{"BHiShelf",{bypass=0,db=6,freqEQ=1500,rs=4}}}
---------------- choir -------------------------------------
voz ="tenor"
coros =OscEP{inst="formantVoice2",ppqOffset=0,sends={db2amp(-2)},channel={level=db2amp(-7)}}
coros:Bind{
	dur=			LOOP{1, 0.5,0.5, 0.5,0.5, 0.5,0.5, 0.5,0.5,0.5,0.5,2},
	escale=escala,
	sweepRate= 0.01,
	degree = 7*5 + 	LOOP{REST,{1,3},{1,3},{1,3},{1,3},REST,{1,3}, {0,2},{0,2},{0,2},{2,4},REST,
						REST,{1,3},{1,3},{1,3},{1,3},REST,{1,3},{0,2},{0,2},{0,2},{-3,0},REST} ,
	pan = {-0.5,0.5},
	[{"f","a","q"}]=RS(Formants:paramsPalabra({voz.."A",voz.."E",voz.."I",voz.."O",voz.."U"}),-1)
}

-------------------- pluk1 ----------------------
-- it will answer to soprano (see conductor)
pluk1=OscEP{inst="plukVm",dontfree=false,MUSPOS=8*4,sends={db2amp(-4)},channel={inst="channel1x2",level=db2amp(1.5),pan=0.5}}
pluk1:Bind{
	escale=escala,
	coef=0.5,
	velo=0.9,
	dur=LOOP{16,AGLS(function (c)  return c.curlist.durlist end,conductor),AGLS(part,{6,8,0.5}),AGLS(part,{2,8,0.25})},
	degree=LOOP{REST,AGLS(function (c)  return c.curlist.seq +TA{7*6,7*5}  end,conductor,3)}
}

-------------- pluk2 --------------------------------------
-- it will play rythmic variations from frase2
frase2={1,3,5,3,5,7,6,4,4,6,6}
pluk2=OscEP{inst="plukVm",dontfree=false,sends={db2amp(-10)},channel={inst = "channel1x2",level=db2amp(-1.5),pan=-0.5}}
pluk2:Bind{
	escale=escala,
	velo=1,
	coef=0.99,
	dur=LOOP{AGLS(part2,{8,#frase2,0.5})},
	degree=LOOP(concatTables({REST},frase2))+{7*4,7*5}
}
pluk2.inserts = {{"early",{lat=0.06}}}

-------------- cowbell ---------------------------------------
bell=LoadPreset([[cowbell]])
bellN,bellV=NamesAndValues(bell.params)

cowbell=OscEP({inst=bell.inst,dontfree=true,sends={db2amp(-6)},channel={level=db2amp(-18)}})
cowbell:Bind{
	note=63,
	velo=LOOP{1,0.5,0.5},
	pan=RSinf{-1,1},
	dur=LOOP{1,0.5,0.5},
	[bellN]=LOOP{bellV,bell2V,bell2V}
}	

--------------conga player ----------------------------
-- will play a tumbao pattern
pre=LoadPreset([[congapr]])
openN,openV=NamesAndValues(pre.params)

slap=LoadPreset([[congaslappr]]).params
_,slapV=NamesAndValues(slap)

cbass=LoadPreset([[congabasspr]]).params
_,cbassV=NamesAndValues(cbass)

tips=LoadPreset([[congatipspr]]).params
_,tipsV=NamesAndValues(tips)


conga=OscEP({inst="klankperc2dofree",dontfree=false,sends={db2amp(-15)},channel={level=db2amp(-18)}})
conga:Bind{
	
	dur=0.5,
	note=LOOP{	55,55,55,55,55,55,55,55,55,55,55,50,50,55,55,55} +(-16),
	velo=0.8,
	pan=0.5,
	[openN]=LOOP{cbassV,tipsV,slapV,tipsV,cbassV,tipsV,openV,openV,cbassV,tipsV,slapV,openV,openV,tipsV,openV,openV}
}

----------------- conga2 --------------------
-- will play some algorythmic solo patterns generated by congaphrase
-------------------------------------------
function congaphrase(val)
	local res = {note = 47,pan=-0.5}
	local totdur=0
	local duras = {}
	local congasound = {}
	local amps = {}
	while totdur < val.len do
		local durs=choose{{0.25,0.25,0.25,0.25},{0.5,0.5,0.5,0.5},{2/3,2/3,2/3}}
		local resto
		for i,v in ipairs(durs) do
			if totdur >=val.len then break end
			if (totdur + v)<= val.len then
				resto = v
			else
				resto=val.len - totdur
			end
			amps[#amps +1]=whitef{0.4,1}
			duras[#duras + 1]=resto
			congasound[#congasound + 1]=choose{slapV,slapV,slapV,tipsV,tipsV,openV,openV}
			totdur = totdur + v
		end
	end
	res.dur=LS(duras)
	res[openN]=LS(congasound)
	res.amp=LS(amps)
	return LS{PS(res)}:rep(val.reps)
end
-- conga2 player
conga2=OscEP{inst="klankperc2dofree",dontfree=true,sends={db2amp(-10)},channel={level=db2amp(-12)}}
conga2:Bind(LOOP{
			AGS(congaphrase,{len=4,reps=3}),
			AGS(congaphrase,{len=4,reps=1}),
			PS{dur=16,note=LS{REST}}
})	

------------------- shaker --------------------------------------
shaker=OscEP({inst="shaker",sends={db2amp(-20)},channel={level=db2amp(-20)}})
shaker:Bind{
	note=70,
	velo=LOOP{1,0.2,0.2,0.2,0.5,0.2,0.2,0.2},
	density=LOOP{4000,2000,2000,2000},
	attack=LOOP{0,0.2,0.05,0.2,0.05,0.2,0.05,0.2},
	decay=0.2,
	pan=0,
	dur=LOOP{0.5},
}
----------------- structure ---------------------------------
actioncue=ActionEP()
actioncue:Bind{
	actions=LS{
			STOP(0,soprano,conga2,cowbell,conga,coros),
			STOP(4*4,pluk2,conga),
			START(4*4,conga),
			START(8*4,pluk2),
			START(12*4,pluk1,soprano,conductor,shaker),
			STOP(12*4,pluk2,conga),
			START(16*4,pluk2,conga),
			STOP(36*4,bass,pluk1,pluk2,cowbell),
			START(40*4,conga2),
			{ppq=59*4+2,StartPlayer,{52*4,pluk1}},
			--ACTION(59*4 +2,StartPlayer,52*4,pluk1),
			START(60*4,bass,pluk2,cowbell),
			STOP(60*4,conga2),
			START(16*17,coros),
			STOP(16*19,soprano),
			START(16*21,soprano),
			FADEOUT(16*27,16*36,unpack(OSCPlayers))
	}
}

----------------------------- Master ------------------
--DiskOutBuffer([[salsomatic.wav]])
MASTER{level=db2amp(-6)}
Master.inserts={
				{"Compander",{slopeAbove=.67,bypass=0,postGain=0.9}},
				{"Limiter",{thresh=3,bypass=1,postGain=0.9}},
			}

FreqScope()
Effects={FX("gverb",db2amp(-5))}
theMetro:play(180,-8,1)	    
