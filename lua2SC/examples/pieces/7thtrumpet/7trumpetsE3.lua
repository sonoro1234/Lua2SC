RANDOM:seed(17) --for getting the same piece always we seed it with fixed number
-------------------------first the SynthDefs------------------------------
-- we will getting requiring a lua file with synthdefs in this script folder
-- and call sync for waiting to async complete
path = require"sc.path"
path.require_here()
require"synthdefs2"
Sync()
----------functions for loading AdachiAyers impulse responses-------------------------------

local ffi = require"ffi"
local float_pointer_type = ffi.typeof("float *")
local function str2float(str)
	local fp = ffi.cast(float_pointer_type, str)
	return fp[0]
end

function loadimpulse(name)
	local res = {}
	local file = io.open(name,"rb")
	if not file then error("fail open "..name) end
	while true do
		local str = file:read(4)
		if not str then break end
		res[#res +1] = str2float(str)
	end
	file:close()
	return TA(res)
end

this_dir = path.file_path()
dir = this_dir.."/ayers/"
--radio = 0.012 
--radio = 0.0045 
radio = 0.0085 

buf=FileBuffer( dir.."POUI.wav");
bufr = DataBuffer(loadimpulse(dir..[[Rgi.raw]]))
bufr2 = DataBuffer(loadimpulse(dir..[[Rgd.raw]]))
bufr3 = DataBuffer(loadimpulse(dir..[[Rrbri.raw]]))

---------------------- functions for getting flip and del for AdachiAyers -----------
local function CrearTabla(base)
	local modos = [[c3,c4,g4,c5,e5,g5,c6]]--..[[a#5,c6]]
	local modos_n = notesToNumbers(modos)
	modos_n = TA(modos_n)-noteToNumber("c3")+noteToNumber(base)
	--prtable(modos_n)
	local todas = {}
	for semi=0,6 do
		for i,v in ipairs(modos_n) do
			local nota = v - semi
			todas[nota] = todas[nota] or {name= numberToNote(nota)}
			table.insert(todas[nota],{pos=semi,modo=i})
		end
	end
	return todas
end

local trumpet_pos = {560,604,656,694,765,820,876}
local trumpet_notes = CrearTabla("a#2")

--make pedal notes
semifac = math.pow(1193*1.00/trumpet_pos[#trumpet_pos],1/5)

for i=1,11 do
	table.insert(trumpet_pos,trumpet_pos[#trumpet_pos]*semifac)
	--"e3" is get on pos 6 (876) modo 2
	local note = noteToNumber"e3"-i
	local notename = numberToNote(note)
	trumpet_notes[note] = {name=notename,{pos=#trumpet_pos-1,modo=2}}
	--"e2" is get on pos 6 (876) modo 1
	local note = noteToNumber"e2"-i
	local notename = numberToNote(note)
	trumpet_notes[note] = {name=notename,{pos=#trumpet_pos-1,modo=1}}
end
--prtable(trumpet_notes)
local function getTrumpetPos(note)
	note = math.floor(note+0.5)
	local poses = trumpet_notes[note]--[1]
	local pos = poses[1]
	for i=2,#poses do
		if pos.modo > poses[i].modo then
			pos = poses[i]
		end
	end
	return trumpet_pos[pos.pos+1],pos.modo
end

flipdelayK = {"flip","delay"}

function flipfromfreqF()
	return function(freq) 
		local flip = freq*0.9
		local note = freq2midi(freq)
		local del = getTrumpetPos(note)
		return {flip,del}
	end
end
--------------------------Tibetan trumpets
fref = 82.4 --90 --85 --82.4
adachi2=OscEP{inst = "AdachiAyers",sends={db2amp(-15)},mono=true,channel={level=db2amp(-12)}}:Bind{
	dur = RSinf{5,3},

	[flipdelayK] = RSinf((TA{85,245,299}*(fref/85)):Do(flipfromfreqF())),
	presion = 13000,

	kernel = buf.buffnum,
	reflec = bufr.buffnum,
	reflec2 = bufr2.buffnum,
	reflec3 = bufr3.buffnum,

	radio = radio,
	gdamp = 0.06,
	pan = 0,
	legato = WRS({1,0.8},{2,1},-1)
}


adachi2b = copyplayer(adachi2)
adachi2c = copyplayer(adachi2):MergeBind{[flipdelayK] = RSinf((TA{85,245,299,370}*(fref/85)):Do(flipfromfreqF()))}

adachi3 = copyplayer(adachi2):MergeBind{[flipdelayK] = SF(LOOP{midi2freq(43+12+0.3)},flipfromfreqF()),presion=13000,gdamp=0.03,pan=-1}
adachi3.channel.level = db2amp(-8)

adachi4 = copyplayer(adachi3):MergeBind{pan=1}
adachi5 = copyplayer(adachi3):MergeBind{pan=0}

adachi6 = copyplayer(adachi3):MergeBind{[flipdelayK]  = SF(RSinf{46, 86}*(fref/85),flipfromfreqF()),presion=13000,pan=-1,gdamp=0.01}
adachi6.channel.level = db2amp(-12)
adachi7 = copyplayer(adachi6):MergeBind{pan=0}

-------- some bell players ------------
korean=OscEP{inst="korean_bell",mono=true,dontfree=true,sends={db2amp(-15)},channel={level=db2amp(-8)}}:Bind{
	degree = 1+7*6,
	amp = 0.8,
	dur = RSinf{20,0.25,0.25,1,0.75},
	pan = noisefStream{-0.5,0.5},
	t_trig = 1
}
korean2 = copyplayer(korean):MergeBind{detune = 1.01,dur = RSinf{10,0.25,0.25,1,0.75},}
korean3 = copyplayer(korean2):MergeBind{detune = 0.99}

korean_end = OscEP{inst="korean_bell",mono=true,dontfree=true,sends={db2amp(-15)},channel={level=db2amp(-6)}}:Bind{
	degree = 1+7*6,
	amp = 1,
	dur = LS{0.25,0.25,0.25,20},
	pan = 0.5,
	t_trig = 1
}
korean_end2 = copyplayer(korean_end):MergeBind{pan=-0.5,detune = 1.01,dur = LS{0.5,0.25,20},}

-- two talking bells
require("sc.Phonemes")
voz = "bass"
voicebell=OscEP{inst="Voicebell",mono=true,dontfree=true,sends={db2amp(-15)},channel={level=db2amp(6)}}
voicebell:Bind{
	escale = "aeolian",
	degree=LOOP{
			5,LS{5, 8,10}:rep(RS{1,2}),LS{12}:rep(RS{0,1}),
			4,LS{9},LS{11,12}:rep(RS{0,1}),
			0,RS{8,LS{8,10}}}+ 7*3 ,--AT{7*4,7*3}, 
	dur=LS{14,1,17,LOOP{16}},
	amp= 1,
	sweepRate=4,
	[{"f","a","q"}]=LOOP(Formants:paramsPalabra({voz.."I",voz.."O",voz.."A",voz.."E",voz.."U"})),
	t_gate = 1,
	pan = 0 
}
voicebell2=OscEP{inst="Voicebell",mono=true,dontfree=true,sends={db2amp(-15)},channel={level=db2amp(6)}}
voicebell2:Bind{
	escale = "aeolian",
	degree= 7*3 + 5 , 
	dur=20,
	amp= 1,
	sweepRate=4,
	[{"f","a","q"}]=LOOP(Formants:paramsPalabra({voz.."I",voz.."A",voz.."E",voz.."U"})),
	t_gate = 1,
	pan = 0
}
----------three monks singing "OM-MA-NI-PAD-ME-HUMv" ------------------
Tract = require"num.Tract"(22)
Tract18 = require"num.Tract"(18)

frase = "OM-MA-NI-PAD-ME-HUMv"
scale = newScale{0,2,3,5,7,8,10} + 7
Rd = 0.5 --glottal intensity
ommani=OscEP{inst=Tract.sinteRdO2.name,mono=true,sends ={db2amp(-15)},channel={level=db2amp(-16),pan=0}}:Bind(LS{
PS(
	{
		fA = 1.1,
		fAc = 1,
		vibrate = 5,
		Rd = Rd,
		pan=0,
		dur=LS{2,1,1,1,1,2}*2,
    },
	LOOP(PS(Tract:Talk(frase,false,false))),
	{escale={scale},degree=7*3+1,freq=LS{ENVdeg({-2,0},{0.25}),LS{getdegree}:rep(4),ENVdeg({0,0,-2},{0.75,0.25})}}
),
PS({freq=REST,legato=0.5,dur=LS{4},amp=0.1})
})

bassvoice=OscEP{inst=Tract.sinteRdO2.name,mono=true,sends ={db2amp(-15)},channel={level=db2amp(-16),pan=0}}:Bind(LOOP{
PS(
	{
		fA = 1.3,
		fAc = 1,
		vibrate = 5,
		Rd = Rd,
		pan=-0.8,
		dur=LS{LS{1,1,1,1},LS{2,2},4}:rep(LOOP{4,5,6})*2,
    },
	LOOP(PS(Tract:Talk(frase,true,true))),
	{escale={scale},degree=7*3+1,freq=LS{ENVdeg({-2,0},{0.25}),LOOP{getdegree}}}
),
PS({freq=REST,legato=0.5,dur=LS{4},amp=0.1})
})

bass2=OscEP{inst=Tract.sinteRdO2.name,mono=true,sends ={db2amp(-15)},channel={level=db2amp(-16),pan=0}}:Bind(LOOP{
PS(
	{
		fA = 1.3,
		fAc = 1,
		vibrate = 5,
		Rd = Rd,
		pan=0.8,
		detune=1.01,
		dur=LS{LS{2,2},LS{1,1,1,1},4}:rep(LOOP{4,5,6})*2,
    },
	LOOP(PS(Tract:Talk(frase,true,true))),
	{escale={scale},degree=7*3+1,freq=LS{ENVdeg({-2,0},{0.25}),LOOP{getdegree}}}
),
PS({freq=REST,legato=0.5,dur=LS{4},amp=0.1})
})
-- a very deep bass voice
bass3=OscEP{inst="formantVoice2",mono=true,sends ={db2amp(-15)},channel={level=db2amp(-23),pan=0}}
bass3:Bind(LS({PS({
    note=43-12,
    sweepRate= 0.3,
    amp=0.6,
    pan=-0.8,
    legato=WRS({1,0.8},{0.9,0.1},-1),
    dur=RS{LS{1,1,1,1},LS{2,2}}:rep(LOOP{4,5,6})*2,
    [{"f","a","q"}]=RS(Formants:paramsPalabra({"bassA","bassE","bassI","bassO","bassU"}),-1)
    }),PS({freq=REST,legato=0.5,dur=LS{4},amp=0.1})},-1))


------------ five sopranos
-- soprano2 sings the reverse of soprano1
-- soprano3 to 5 do random singing over soprano1 melody
-- the result is a quasi static chord
soprano1=OscEP{inst=Tract18.sinteRdO2.name,mono=true,sends ={db2amp(-15)},channel={level=db2amp(-11),pan=0}}:Bind(PS({
    fA = SliderControl("fA",0.5,1.5,1),
	fAc = SliderControl("fAc",0.1,10,1),
	fexci = SliderControl("fe",1000,20000,18500),
	Rd = SliderControl("Rd",0.3,4,1.31),
	
    escale={scale},
    sweepRate= 0.3,
    amp=0.4,
	detune=noisefStream{0.99,1.01},
    pan=noisefStream{-1,1},
    dur= RSinf{5,3,7},

    },
	{[Tract18.paramskey_speak] = LOOP{Tract18:doTalk([[SE-LI-NA-KO-FE-NO-MU-I]],true,true,true)},
	degree = LOOP{1,2,3,5-7,6-7,7-7,8-7} + 7*5}

))

soprano2=copyplayer(soprano1):MergeBind{[Tract18.paramskey_speak] = LOOP{Tract18:doTalk([[MIA-LEI-OU-AE]],true,true,true)},degree = LOOP(TA{1,2,3,5-7,6-7,7-7,8-7}:reverse()) + 7*5} 
soprano3=copyplayer(soprano1):MergeBind{[Tract18.paramskey_speak] = LOOP{Tract18:doTalk([[MOU-O-KOU-EI]],true,true,true)},degree = RSinf{1,2,3,5-7,6-7,7-7,8-7} + 7*5}
soprano4=copyplayer(soprano3):MergeBind{[Tract18.paramskey_speak] = LOOP{Tract18:doTalk([[MA-EA-OA-AE]],true,true,true)}} 
soprano5=copyplayer(soprano3):MergeBind{[Tract18.paramskey_speak] = LOOP{Tract18:doTalk([[MIAI-NEI-IOU-MAIE]],true,true,true)}}

------------------------- structure -----------------------------
actionlist = ActionEP{}:Bind{
	actions = LS{STOP(-1,unpack(OSCPlayers)),

				START(0,voicebell,korean,korean2,korean3),
				START(16,bass2,bassvoice),
				START(16,bass3,ommani),
				START(40,adachi3),
				START(50,adachi4,adachi5),
				START(80,adachi2),
				START(90,adachi6),
				START(110,adachi2b),
				START(120,adachi7,adachi2c),
				STOP(145,bassvoice,bass3,bass2),
				STOP(150,adachi6,adachi2,adachi7,adachi2b,adachi2c),
				
				START(164,soprano1,soprano2,soprano3,soprano4,soprano5),

				START(194,korean,korean2,korean3,voicebell2),
				STOP(200,korean,korean2,korean3,voicebell2),
				START(201,korean,korean2,korean3,voicebell2),
				STOP(207,korean,korean2,korean3,voicebell2),

				START(256,adachi2c),
				START(280,adachi2b,adachi2),

				STOP(290,korean,korean2,korean3,voicebell),

				STOP(293,soprano1,soprano2,soprano3,soprano4,soprano5),
				STOP(293,adachi2c,adachi2b,adachi2),
				STOP(293,adachi3,adachi4,adachi5),
				

				START(296,korean,korean2,korean3,voicebell2),
				START(296,bassvoice,bass2), --,bass3

				START(302,ommani),
				START(307,bass3), 

				STOP(307,korean,korean2,korean3,voicebell2),
				STOP(317,bass3),
				STOP(318,bassvoice,bass2),
				
				STOP(320,unpack(OSCPlayers)),
				START(321,korean_end,korean_end2,voicebell2),
				ACTION(330,function() theMetro:stop() end),

				}
}
------------ Master -------------------
Effects = {FX("dwgreverb",nil,nil,{c1=2.3,c3=50})}
--DiskOutBuffer([[the7DoorJ-80.wav]])
theMetro:tempo(80)
theMetro:start()