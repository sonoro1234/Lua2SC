tract = require"num.Tract"(20)
tract18 = require"num.Tract"(18)
-------------------

escala = modes.aeolian +6 

--women pattern
patron={
	degree = LOOP{1,2,3,1,5,4,3,-2} + LOOP{LS{7}:rep(64), LS{6}:rep(64), LS{5}:rep(64), LS{4}:rep(64), LS{3}:rep(64),LS{2}:rep(64), LS{1}:rep(64), LS{0}:rep(64)} + 7*4,
	escale={escala},
	fA = 0.95,
	Rd = 1,
	dur=LOOP{0.75,0.25,0.5,0.5},
	amp=0.4, 
	legato=LOOP{0.75,LS{1}:rep(2),0.5,LS{1}:rep(4)}
}

--men pattern
patronH={
	degree = LOOP{{5,3},{4,2},{3,1},{4,2},{5,1}} + LOOP{LS{7}:rep(64), LS{6}:rep(64), LS{5}:rep(64), LS{4}:rep(64), LS{3}:rep(64),LS{2}:rep(64), LS{1}:rep(64), LS{0}:rep(64)} + 7*3,
	escale={escala},
	fA = 1.05,
	Rd = 1,
	dur=LOOP{0.75,0.25,0.5,0.5,2},
	amp=0.3, --noisefStream({0.4,0.9}),
	legato=LOOP{0.5,LS{1}:rep(3),0.5}
}

--the words to be singed
frase = "Ate-Ete-Ite-Ote-Ute" --"A-E-I-O-U" Ate is vocal A with bell canto impostation
talk = {[tract.paramskey_speak] = LOOP{tract:doTalk(frase,true,true,false)}}
talk18 = {[tract18.paramskey_speak] = LOOP{tract18:doTalk(frase,true,true,false)}}


MAXINST=4
-------------- 4 female singers ----------------------
-- created from patron and stored in MUJERES
MUJERES = {}
for i=1,MAXINST  do
	local tmppatt = deepcopy_values(patron) -- copy patron
	tmppatt.dur = tmppatt.dur *(0.99^i) -- make dur shorter for each singer to get a phasing effect
	tmppatt.pan = -1+2/(MAXINST-1)*(i-1) -- pan them
	
	-- the player
	local temp = OscEP{inst=tract18.sinteRd.name, sends={db2amp(-9)}, mono=true, name="f"..i, channel = {level = db2amp(-3)}}
	temp:Bind(PS(tmppatt,deepcopy(talk18))) -- give pattern to player
	temp.ppqOffset = 4*(i-1) -- each singer starting 4 beats later
	MUJERES[i] = temp -- keep players in table
end

------------- 4 male singers -----------------------
HOMBRES = {}
for i=1,MAXINST  do
	local tmppatt = deepcopy_values(patronH)
	tmppatt.dur = tmppatt.dur *(0.99^i)
	tmppatt.pan = 1-2/(MAXINST-1)*(i-1)

	local temp = OscEP{inst=tract.sinteRd.name,mono=true,sends={db2amp(-9)},name="m"..i,channel={level=db2amp(-3)}}
	temp:Bind(PS(tmppatt,deepcopy(talk)))
	temp.ppqOffset = 4*(i-1)
	HOMBRES[i] = temp
end

--------- a bass voice singer --------------
-- the singing note will be changed in structure with ACTION going down an octave
bass=OscEP{inst=tract.sinteRd.name,Filters={},mono=true,sends ={db2amp(-10)},channel={level=db2amp(-8),pan=0}}
bass:Bind(LOOP({PS({
    degree=7*3+1,
    escale={escala},
    amp=0.4,
	fA = 1.2,
	Rd = 0.4,
    pan=0,
    legato=WRS({1,0.8},{0.9,0.1},-1),
    dur=RS({LS({1,1,1,1}),LS({2,2}),4},4),
    },deepcopy(talk)), PS({freq=REST,legato=0.5,dur=LS{1},amp=0.1},deepcopy(talk))}))

------------ structure ---------------------------
actioncue=ActionEP{name="actioncue"}
actioncue:Bind{
	actions=LS{
			START(0,unpack(MUJERES)),
			STOP(0,unpack(HOMBRES)),
			
			START(140,unpack(HOMBRES)),
			ACTION(170,function() bass.Filters.degree = function(val) return val.degree - 1 end end),
			FADEOUT(190,220,unpack(MUJERES)),
			
			FADEIN(230,240,unpack(MUJERES)),
			FADEOUT(240,250,unpack(MUJERES)),
			ACTION(240,function() bass.Filters.degree = function(val) return val.degree - 2 end end),
			FADEIN(270,290,unpack(MUJERES)),
			FADEOUT(300,340,unpack(MUJERES)),
			ACTION(300,function() bass.Filters.degree = function(val) return val.degree - 3 end end),
			
			ACTION(320,function() bass.Filters.degree = function(val) return val.degree - 4 end end),

			ACTION(370,StartPlayer,0, unpack(MUJERES)),
			FADEIN(370,390,unpack(MUJERES)),
			ACTION(390,function() bass.Filters.degree = function(val) return val.degree - 5 end end),
			
			ACTION(480,function() bass.Filters.degree = function(val) return val.degree -7 end end),
			STOP(540,unpack(OSCPlayers)),
	}
}

------------------ Master section --------------------------------
MASTER{level=db2amp(-6)}
Effects={FX("gverb",nil,nil,{roomsize = 50,revtime=1})}

FreqScope()

theMetro:tempo(100)
theMetro:start()
--DiskOutBuffer([[nineVoices.wav]])
