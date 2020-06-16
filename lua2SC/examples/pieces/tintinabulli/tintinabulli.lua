-- This is a piece based on Arvo Part work
-- It uses the tintinabulation technique and the structure of Cantus in Memorian of Benjamin Britten
-- https://soundcloud.com/victor-bombi/arvo-parts-cantus-remake
-- motion track of movie in : https://vimeo.com/222002715

LILY = require"sc.lilypond"
--local NRT = require"sc.nrt":Gen(1100)
------------------------------- synthdefs -----------------------------

-- early reflections generations
ER = require"sc.ER"()

-- reverb
SynthDef("dwgreverb", { busin=0, busout=0,predelay=0.1,c1=4,c3=4,len=1200,mix = 1},function()
	local source=Mix(In.ar(busin,2)); 
	source = DelayC.ar(source,0.5,predelay)
	source = DWGReverbC1C3_16.ar(source,len,c1,c3,mix)	
	ReplaceOut.ar(busout,source)
end):store();

-- body resonances for bowed
body_resons={{118, 18, -33},
{274, 22, -34.5},
{449, 10, -16},
{547, 16, -15.5},
{840, 50, -31},
{997, 30, -20.4},
{1100, 30, -34},
{1290, 25, -29},
{1500, 50, -28},
{1675, 60, -22},
{1900, 60, -20}}
sc = require"sclua.Server".Server()
gainLB = sc.Bus()
curr_panel = addPanel{type="hbox",name="body"}
Slider("gainL",0,120,50,function(val) gainLB:set(val) end)
gainSB = sc.Bus()
Slider("gainS",0,2,0,function(val) gainSB:set(val) end)
gainHB = sc.Bus()
Slider("gainH",0,2,2,function(val) gainHB:set(val) end)
SynthDef("bowsoundboard", { busin=0, busout=0,mix=0.9,fLPF=6300,size=1,T1=1,gainS=0,gainL=60,gainH=2},function()
	local str=In.ar(busin,2); 
	
	local coefs = TA{199, 211, 223, 227, 229, 233, 239, 241 } *size
	local fdn = DWGSoundBoard.ar(str,nil,nil,mix,unpack(coefs:asSimpleTable()));
	local bodyf = 0
	T1 = T1:max(0.001)
	for i,v in ipairs(body_resons) do
		bodyf = bodyf + BPF.ar(str,v[1]*T1,1/(v[2]*T1))*db2amp(v[3])
	end
	gainL =  In.kr(gainLB.busIndex,1)
	gainS =  In.kr(gainSB.busIndex,1)
	gainH =  In.kr(gainHB.busIndex,1)
	local son = str*gainS + bodyf*gainL + fdn*gainH
	son = LPF.ar(son,fLPF)
	ReplaceOut.ar(busout,son)
end):store();

-- bowed section, set N=4 if it is too much for CPU
bowed = SynthDef("bowed", {out=0, freq=440, amp=0.5,velb=1,force=1, gate=1,pos=0.07,c1=2,c3=400,mistune = 5200,release=0.1,Z = 1,Zfac=1,B=4,Ztor=1.8,c1tor=2,c3tor=6000,pan=0,vibdeph=7,vibrate=4,vibonset=1,t_gate=1;
},function()

	N = 12 --4 -- number of voices
	local fratio = midi2ratio(0.025*12/N)
	local freqs = TA():gseries(N,1 * fratio^(-N/2),fratio)
	freq = freqs*freq
	
	local vibfreq = Vibrato.kr{freq, rate= vibrate, depth= vibdeph/1000, delay= 0, onset= vibonset, rateVariation= 0.2, depthVariation= 0.1, iphase =  0,trig=t_gate}
	amp = amp *velb
	Z = Z*Zfac
	local son = DWGBowedTor.ar(vibfreq, amp,force, gate,pos,release,c1,c3,Z,B,1 + mistune/1000,c1tor,c3tor,Ztor)*0.5
	local mdel = 0.03
	son = son:Doi(function(v,i) return DelayC.ar(v,0.2,LFDNoise3.kr(0.1,mdel,mdel))*LFDNoise3.kr(5,0.2,0.9) end)
	Out.ar(out, Pan2.ar(Mix(son*0.04) ,0))
end):store();

------------------------------- some functions ----------------
-- function for do tintinabuli voice from main voice (notes) for chord and order (-3 to 3)
function Tintinabuli(notes,chord,order)
	local tv = {}
	for i,low in ipairs(notes) do
		local tinv = {}
		local dists = {}
		local mindisindex = -1
		for j=1,#chord do
			local mid = chord[j]
			--put mid over low-------------
			local dist = low - mid
			tinv[j] = mid + math.ceil(dist/7)*7
			dist = tinv[j] - low
			
			dists[#dists + 1] = {index=j,dist=dist} 
		end
		table.sort(dists,function(a,b) return a.dist< b.dist end)
		--find most near up
		if order < 0 then
			tv[#tv + 1] = tinv[dists[-order].index] - 7
		else
			tv[#tv + 1] = tinv[dists[order].index]
		end
	end
	return tv
end

-- function to make real phrase from notes sequence
-- it repeats the sequence each time one note longer from ini to limit
function MakeFrase(notes,limit,ini)
	limit = limit or #notes
	ini = ini or 3
	local phrase = {}
	for i=ini,limit do
		phrase[#phrase + 1] = LS(TA(notes)(1,i),1)
	end
	return phrase
end

-- the scale
hungarianL = {0, 2, 3, 6, 7, 8, 11}
escale = newScale(hungarianL) + 9 ---12

-- the phrases
frase = TA{5,8,10,9,8,7,6,5,4,3,2,1} +0
frase = frase..(frase - 7)..(frase - 14)
Tfrase = TA(Tintinabuli(frase,{1,3,5},-3))
fraseBass = TA{8,7,6,5,4,3,2,1}
TfraseBass = TA(Tintinabuli(fraseBass,{1,3,5},3))

-- print phrases
print(frase:Do(function(v) return numberToNote(getNote(v,escale)) end))
print(Tfrase:Do(function(v) return numberToNote(getNote(v,escale)) end))

-- function providing amp
function ppqpos2amp()
	return linearmap(0,1000,0,0.5,theMetro.ppqPos)
end

------------------- sequences -------------------
seqM = {
	dur = LOOP{2,1},
	escale = {escale},
	pan = -0.75,
	vibdeph = 5,
	force = 1,
	pos = 0.14,
	t_gate = 1,
	Zfac = 1,
	Ztor = 3,
	B = 2,
	velb = 1,
	amp = LOOP{ENV({0.2,0.2,0.4,0.4},{0.0,0.2,0.7}),ENV({-0.2,-0.2,-0.5,-0.4},{0.0,0.2,0.7})} + LOOP{FS(ppqpos2amp),-FS(ppqpos2amp)},
	degree = LS(MakeFrase(frase,34)) + 7*6
}

-- end sequence
finM = {
	dur = LOOP{2,1}*10,
	escale = {escale},
	pan = -0.75,
	vibdeph = 5,
	force = seqM.force,
	pos = seqM.pos,
	Z = seqM.Z,
	Ztor = seqM.Ztor,
	B = seqM.B,
	amp = LOOP{ERAMP(0.3,0.5,nil),ERAMP(-0.3,-0.3,nil)}
	+ LOOP{FS(ppqpos2amp),-FS(ppqpos2amp)},
	degree = frase[34] + 7*6
}

-- tintinabuli sequences
seqT = deepcopy(seqM)
seqT.degree = LS(MakeFrase(Tfrase,34)) + 7*6

finT = deepcopy(finM)
finT.degree = Tfrase[34] + 7*6

-- create a player that wont be added to OSCPlayers (this is made by OscEP)
-- and will be used for being copied by other players
play1 = OscEventPlayer:new{inst="bowed",mono=true,sends = {0.5},channel={level=db2amp(-8)}}

-- function for creating players: a normal player and a tintinabuli player
function DoVoic(durfac,ff,oct,off,pan,db,limit,ini,fras,Tfras,Tonly)
	
	local Z = 1/ff
	fras = fras or frase
	Tfras = Tfras or Tfrase
	if Tonly==nil then Tonly = false end
	local seqM2 = deepcopy(seqM)
	seqM2.dur = seqM2.dur*durfac
	seqM2.degree = LS(MakeFrase(fras,limit,ini)) + 7*6 -7*oct
	seqM2.pan = pan
	seqM2.Z = Z
	seqM2.vibonset = 0.5*ff
	local finM2 = deepcopy(finM)
	finM2.dur = finM2.dur*durfac
	finM2.degree = fras[limit] + 7*6 -7*oct
	finM2.pan = pan
	finM2.Z = Z
	finM2.vibonset = 0.5*ff
	local seqT2 = deepcopy(seqT)
	seqT2.dur = seqT2.dur*durfac
	seqT2.degree = LS(MakeFrase(Tfras,limit,ini))+ 7*6 -7*oct
	seqT2.pan = pan
	seqT2.Z = Z
	seqT2.vibonset = 0.5*ff
	local finT2 = deepcopy(finT)
	finT2.dur = finT2.dur*durfac
	finT2.degree = Tfras[limit] + 7*6 -7*oct
	finT2.pan = pan
	finT2.Z = Z
	finT2.vibonset = 0.5*ff
	local fLPF = math.max(3000,linearmap(0,5,16000,2200,ff))
	local play2
	if not Tonly then
	play2 = copyplayer(play1)
	play2.channel.level = db2amp(db)
	play2.ppqOffset = off
	play2:Bind(LS{PS(seqM2),PS(finM2)})
	play2.inserts = {{"bowsoundboard",{T1=1/(ff),size=ff,fLPF=fLPF}},{ER.synname,{angle=pan,bypass=0,dist=1}}}
	end

	local play2T = copyplayer(play1)
	play2T.channel.level = db2amp(db)
	play2T.ppqOffset = off
	play2T:Bind(LS{PS(seqT2),PS(finT2)})
	play2T.inserts = {{"bowsoundboard",{T1=1/(ff),size=ff,fLPF=fLPF}},{ER.synname,{angle=pan,bypass=0,dist=1}}}
	return play2,play2T
end

-- use the function creating 10 voices
--durfac,body size,oct,offset,pan,db,limit,ini,fras,Tfras,Tonly
ply1,ply1T = DoVoic(1,1,0,0,-1,-2.5,34) --z=1
ply2,ply2T = DoVoic(2,1,1,18*1,-0.5,-0,24) --z=1
ply3,ply3T = DoVoic(4,2.5,2,(18 + 18*2)*1,-0.02,-0,13,nil,nil,nil,false) --z=0.5
ply4,ply4T = DoVoic(8,4,3,(18 + 18*2 + 18*4)*1,0.5,0,12) --z o.26
ply5,ply5T = DoVoic(16,5,4,(18 + 18*2 + 18*4 + 18*8)*1,1, 2,8,3,fraseBass,TfraseBass) --z=0.25

-------------------- stop players on beat 1070
actioncue=ActionEP{name="actioncue"}
actioncue:Bind{actions=LS{STOP(1070,unpack(OSCPlayers)),}}

------------------------- Master ----------------------------------------
MASTER{level=db2amp(-10)}

FreqScope()
--DiskOutBuffer("tintinabuli_bodys6.wav")
Effects={FX("dwgreverb",db2amp(-10),nil,{c1=2.4,c3=6,len=1551})}
theMetro:play(240,nil,nil,30)
theMetro:start()

-- uncomment to use lilypond
--LILY:Gen(0,1070,TA(OSCPlayers),{time="6/4"})