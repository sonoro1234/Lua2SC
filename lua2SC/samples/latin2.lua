--require "init.init"
--require("sc.playersscgui")
require("sc.Phonemes")
require("sc.scbuffer")
--require("combinatorics")

SWING=0.5
escala={{0, 2, 3, 5, 7, 8, 10}}
--escala={0, 2, 4, 5, 7, 9, 11}
--escala={0, 1, 3, 5, 7, 8, 10}
frase2={1,3,5,3,5,7,6,4,4,6,6}
fraseP=FS(permutation,1,{1,3,5,3,5,7,6,4,4,6,6})
amps=TA{2.2,1.5,1.8}*0.25


function part(t)
	--return partition(t[1],t[2],t[3])
--ll.oo=9
	return composition(t[1],t[2],t[3])
	--local aaa
	--if not pcall(function()
		--aaa=composition(t[1],t[2],t[3])
	--end) then debuglocals(true);error() end
	--return aaa
end
function ppqamp(amps,player)
	local barpos=math.floor(player.swppqPos) % #amps
	return amps[barpos+1]
end
function part2(t)
	local durini=choose{0,0.5}
	local queda=t[1]-durini;
	--local durs=partition(queda,t[2],t[3],t[4])
	local durs=composition(queda,t[2],t[3],t[4])
	table.insert(durs,1,durini)
	return durs
end

------------------------------
fraseB=TA{1,5,4,5,RS{1,5}} +7*3 --#[0,3,4,3];
--dursB={1.5,2.5,1.5,RS{LS{1.5,1},LS{1,1.5}}}
dursB={1.5,2.5,1.5,1.5,1}
dursB2={2,2,2,1.5,0.5}
dursB2a={1.5,2.5,1.5,1.5,0.5}
--plukBassVm3 KarplusCB
bass=OscEP{inst="plukBassVm3",mono=false,sends={0},channel={inst="channel1x2",level=db2amp(-3)}}
bass:Bind{
	
	escale=escala,
	decay=5,
	degree=LOOP(fraseB), 
	--degree=LOOP{FSLS(permutation,fraseB)}, --+AT{7,0},

	--dur=LOOP{FSLS(permutation,dursB),LS(dursB)},
	--dur=LOOP{FSLS(permutation,dursB)},
	--dur=LS{LS(dursB2a),LOOP(dursB2)},
	dur=LS{LS(dursB2a),LOOP{FSLS(permutation,dursB2),LS(dursB2)}},
	--dur=LOOP{AGLS(part2,{8,#fraseB,1,0.5})},
	coef=0.95,
	coef2=0.8,
	velo=0.8
}
--bass.inserts={{"Companderm",{thresh=30,slopeAbove=0.3,clampTime=0.01} }}
conductor=EP{name="conductor",MUSPOS=0}:Bind{
	dur=32,
	seq=FS(permutation,-1,{1,2,3,4,5,6,7,8}),
	durlist=FS(part,-1,{8,8,0.5})
}
voz="soprano"
soprano=OscEP{inst="formantVoice2",mono=true,sends={0.5},MUSPOS=8*4,channel={level=db2amp(-1.5)}}
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

soprano.inserts = {
					--{"BLowShelf",{bypass=1}},
					--{"BPeakEQ",{bypass=1}},
					{"BHiShelf",{bypass=0,db=6,freqEQ=1500,rs=4}}
}
voz ="tenor"
coros =OscEP{inst="formantVoice2",ppqOffset=0,sends={db2amp(-2)},channel={level=db2amp(-0)}}
coros:Bind{
	dur=			LOOP{1, 0.5,0.5, 0.5,0.5, 0.5,0.5, 0.5,0.5,0.5,0.5,2},
	escale=escala,
	sweepRate= 0.01,
	degree = 7*5 + 	LOOP{REST,{1,3},{1,3},{1,3},{1,3},REST,{1,3}, {0,2},{0,2},{0,2},{2,4},REST,
						REST,{1,3},{1,3},{1,3},{1,3},REST,{1,3},{0,2},{0,2},{0,2},{-3,0},REST} ,
	pan = {-0.5,0.5},
	[{"f","a","q"}]=RS(Formants:paramsPalabra({voz.."A",voz.."E",voz.."I",voz.."O",voz.."U"}),-1)
}
--prtable(soprano)

pluk1=OscEP{inst="plukVm",dontfree=false,MUSPOS=8*4,sends={db2amp(-4)},channel={inst="channel1x2",level=db2amp(-0),pan=0.5}}
pluk1:Bind{
	
	escale=escala,
	coef=0.5,
	velo=0.9,
	--dur=LOOP{AGLS(function (c) return c.curlist.durlist end,conductor,1),AGLS(part,{8,8,0.5},1),LS{16}},
	--degree=LOOP{AGLS(function (c) return c.curlist.seq +AT{7*6,7*5}  end,conductor,2),REST}
	--dur=LOOP{AGLS(function (c) return c.curlist.durlist end,conductor),AGLS(part,{8,16,0.5}),LS{16}},
	--degree=LOOP{AGLS(function (c) return c.curlist.seq +AT{7*6,7*5}  end,conductor,3),REST}
	dur=LOOP{16,AGLS(function (c)  return c.curlist.durlist end,conductor),AGLS(part,{6,8,0.5}),AGLS(part,{2,8,0.25})},
	degree=LOOP{REST,AGLS(function (c)  return c.curlist.seq +TA{7*6,7*5}  end,conductor,3)}
}
function ValorElControl()
	return FS(function() return elcontrol.value end,-1)
end
newcontrol = {value=0.5,min=0,max=1, type=GUITypes.vSlider,label=0,
			callback=function(value,str,c) 
					c:setLabel(string.format("%.2f",value),0)
			end}
elcontrol= addControl(newcontrol)
pluk2=OscEP{inst="plukVm",dontfree=false,sends={db2amp(-7)},channel={inst = "channel1x2",level=db2amp(-0)}}
pluk2:Bind{
	escale=escala,
	velo=1,
	coef=0.99, --ValorElControl(),
	dur=LOOP{AGLS(part2,{8,#frase2,0.5})},
	degree=LOOP(concatTables({REST},frase2))+{7*4,7*5}
	--dur=LOOP{AGLS(part2,{6,#frase2,0.5}),LS{2}},
	--degree=LOOP(concatTables({REST},frase2,{REST}))+AT{7*4,7*5}
}
--[[
piano=OscEP{inst="Macpiano",dontfree=false,swing=SWING,name="piano",channel={level=db2amp(-15)}}
piano:Bind{
	escale=escala,
	velo=0.6,
	--detune=LOOP{AT{1.01,1}},
	--detune=LOOP{{1.01,1}},
	dur=LOOP{FS(function() return (pluk2.curlist.dur) end)},
	--degree=LOOP{FS(function() return (pluk2.curlist.degree) end)}
	degree=LOOP(concatTables({REST},frase2))+AT{7*6,7*5}	
}
--]]
bell=LoadPreset([[cowbell]])
bellN,bellV=NamesAndValues(bell.params)
bell2=LoadPreset([[cowbell2]])
bell2N,bell2V=NamesAndValues(bell2.params)

cowbell=OscEP({inst=bell.inst,dontfree=true,sends={db2amp(-6)},channel={level=db2amp(-18)}})
cowbell:Bind{
	note=63,
	velo=LOOP{1,0.5,0.5},
	pan=RSinf{-1,1},
	dur=LOOP{1,0.5,0.5},
	[bellN]=LOOP{bellV,bell2V,bell2V}
	}	

--------------conga2
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
-------------------------------------------
function frase(val)
	local res = {note = 47,pan=-0.5}
	local totdur=0
	local duras = {}
	local congasound = {}
	local amps = {}
	while totdur < val.len do
		local durs=choose({{0.25,0.25,0.25,0.25},{0.5,0.5,0.5,0.5},{2/3,2/3,2/3}})
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

conga2=OscEP({inst="klankperc2dofree",dontfree=true,sends={db2amp(-10)},channel={level=db2amp(-12)}})
conga2:Bind(LOOP{
			AGS(frase,{len=4,reps=3}),
			AGS(frase,{len=4,reps=1}),
			PS{dur=16,note=LS{REST}}
})	
shaker=OscEP({inst="shaker",sends={db2amp(-20)},channel={level=db2amp(-20)}})
shaker:Bind{
	note=70,
	--velo=LOOP{1,0.2,0.5,0.2},
	--density=LOOP{4000,2000,4000,2000},
	--attack=LOOP{0,0.2,0.05,0.2},
	velo=LOOP{1,0.2,0.2,0.2,0.5,0.2,0.2,0.2},
	density=LOOP{4000,2000,2000,2000},
	attack=LOOP{0,0.2,0.05,0.2,0.05,0.2,0.05,0.2},
	decay=0.2,
	pan=0,
	--dur=0.5
	dur=LOOP{0.5},
	}
actioncue=ActionEventPlayer:new({name="actioncue"})
--OSCPlayers ={pluk2}
actioncue:Bind{
	actions=LS{
			STOP(0,soprano,conga2,cowbell,conga,coros),
	---[[
			
			--GOTO(1,16*14),
			STOP(4*4,pluk2,conga),
			START(4*4,conga),
			
			START(8*4,pluk2),
			
			START(12*4,pluk1,soprano,conductor,shaker),
			STOP(12*4,pluk2,conga),
			
			START(16*4,pluk2,conga),--,cowbell),
			
			--GOTO(24*4,20*4),
			STOP(36*4,bass,pluk1,pluk2,cowbell),
			START(40*4,conga2),
			
			--START(52*4,pluk1),
			{ppq=59*4+2,StartPlayer,{52*4,pluk1}},
			--ACTION(59*4 +2,StartPlayer,52*4,pluk1),
			START(60*4,bass,pluk2,cowbell),
			STOP(60*4,conga2),
			START(16*17,coros),
			STOP(16*19,soprano),
			START(16*21,soprano),
	--]]
			ACTION(320*4,print,"Estoy aqui compas 30")
	}
}
ActionPlayers={actioncue}
-------------------------------------------------------
--DiskOutBuffer([[salsomaticggg.wav]])
Master.inserts={
				{"Compander",{slopeAbove=.67,bypass=0}},
				{"Limiter",{thresh=3,bypass=1}},
				--{"Normalizer",{dur=0.3,thresh=3}}
				--{"flangerb",{bypass=1}}
				{"checkbadval"}
			}

MainPanel=addPanel{type="vbox"}
FreqScope()


--OSCPlayers={bass,cowbell,pluk1,pluk2,soprano,conga2}--,piano}
--OSCPlayers={conga2}
Envios={{0,db2amp(-6),db2amp(-2),0.5,0.6,db2amp(-15),0.5}}
Effects={FX("gverb",db2amp(-5))}
GUIPlayers=OSCPlayers
--Envios=FillEnvios(0.6)
--dumpOSC=1
NOTRECEIVELOOP=true
--Players[#Players + 1] = conductor
--prtable(ArrS(preset["params"]["kla"]))
--prtable(conga)
--prtable(conga2)
function initCb()
    theMetro:play(180,-8,1)	    
end
