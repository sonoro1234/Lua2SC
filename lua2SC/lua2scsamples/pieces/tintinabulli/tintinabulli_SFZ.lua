-- tintinabulli piece for SFZ strings
-- more explanations on tintinabuli script
-- you must set your SFZ path in SOSpath

----------- synthdefs --------------------------
SynthDef("dwgreverb", { busin=0, busout=0,c1=4,c3=4,len=1200,mix = 1},function()
	local source=Mix(In.ar(busin,2)); 
	--source = DWGReverb.ar(source,len,c1,c3,mix)*0.5	
	source = DWGReverbC1C3_16.ar(source,len,c1,c3,mix)	
	ReplaceOut.ar(busout,source)
end):store(true);

sfzR = require"sc.sfzreader"

---[=[
options = {extend_range=true}
SOSpath = [[C:\supercolliderrepos\SFZ\sso-master\Sonatina Symphonic Orchestra\]]
local violin1 = sfzR.read(SOSpath..[[Strings - 1st Violins Sustain.sfz]],options)
local violin2 = sfzR.read(SOSpath..[[Strings - 2nd Violins Sustain.sfz]],options)
local viola = sfzR.read(SOSpath..[[Strings - Violas Sustain.sfz]],options)
local celli = sfzR.read(SOSpath..[[Strings - Celli Sustain.sfz]],options)
local bass = sfzR.read(SOSpath..[[Strings - Basses Sustain.sfz]],options)
--]=]

--[=[
options = {extend_range=true}
VPOpath = [[C:\supercolliderrepos\SFZ\VSCO-2-CE-1.1.0\]]
local violin1 = sfzR.read(VPOpath..[[ViolinEnsSusVib.sfz]],options)
local violin2 = sfzR.read(VPOpath..[[ViolinEnsSusVib.sfz]],options)
local viola = sfzR.read(VPOpath..[[ViolaEnsSusVib.sfz]],options)
local celli = sfzR.read(VPOpath..[[CelloEnsSusVib.sfz]],options)
local bass = sfzR.read(VPOpath..[[ContrabassSusVB.sfz]],options)
--]=]

------------------- some functions ---------------------

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
function MakeFrase(notes,limit,ini)
	limit = limit or #notes
	ini = ini or 3
	local phrase = {}
	for i=ini,limit do
		phrase[#phrase + 1] = LS(TA(notes)(1,i),1)
	end
	return phrase
end

-- scale
hungarianL = {0, 2, 3, 6, 7, 8, 11}
escale = newScale(hungarianL) + 9 ---12

-- phrases
frase = TA{5,8,10,9,8,7,6,5,4,3,2,1} +0
frase = frase..(frase - 7)..(frase - 14)
Tfrase = TA(Tintinabuli(frase,{1,3,5},-3))
fraseBass = TA{8,7,6,5,4,3,2,1}
TfraseBass = TA(Tintinabuli(fraseBass,{1,3,5},3))

print(frase:Do(function(v) return numberToNote(getNote(v,escale)) end))
print(Tfrase:Do(function(v) return numberToNote(getNote(v,escale)) end))

-- getting amp from beat
function ppqpos2amp()
	return linearmap(0,1000,0,0.5,theMetro.ppqPos)
end

----------- sequences -----------------------
seqM = {
	dur = LOOP{2,1},
	escale = {escale},
	pan = -0.75,
	amp = LOOP{0.4,0.5} + LOOP{FS(ppqpos2amp)},
	degree = LS(MakeFrase(frase,34)) + 7*6
}
finM = {
	dur = LOOP{2,1}*10,
	escale = {escale},
	pan = -0.75,
	amp = LOOP{0.5,0.3} + LOOP{FS(ppqpos2amp),FS(ppqpos2amp)}*0.3,
	degree = frase[34] + 7*6
}

seqT = deepcopy(seqM)
seqT.degree = LS(MakeFrase(Tfrase,34)) + 7*6

finT = deepcopy(finM)
finT.degree = Tfrase[34] + 7*6


play1 = OscEventPlayer:new{mono=false,sends = {0.5},channel={level=db2amp(-8)}}

function DoVoic(sfz,durfac,ff,oct,off,pan,db,limit,ini,fras,Tfras,Tonly)
	
	fras = fras or frase
	Tfras = Tfras or Tfrase
	if Tonly==nil then Tonly = false end
	local seqM2 = deepcopy(seqM)
	seqM2.dur = seqM2.dur*durfac
	seqM2.degree = LS(MakeFrase(fras,limit,ini)) + 7*6 -7*oct
	seqM2.pan = pan
	local finM2 = deepcopy(finM)
	finM2.dur = finM2.dur*durfac
	finM2.degree = fras[limit] + 7*6 -7*oct
	finM2.pan = pan
	local seqT2 = deepcopy(seqT)
	seqT2.dur = seqT2.dur*durfac
	seqT2.degree = LS(MakeFrase(Tfras,limit,ini))+ 7*6 -7*oct
	seqT2.pan = pan
	local finT2 = deepcopy(finT)
	finT2.dur = finT2.dur*durfac
	finT2.degree = Tfras[limit] + 7*6 -7*oct
	finT2.pan = pan
	local fLPF = math.max(3000,linearmap(0,5,16000,2200,ff))
	local play2
	if not Tonly then
	play2 = copyplayer(play1)
	play2.channel.level = db2amp(db)
	play2.ppqOffset = off
	play2:Bind(LS{PS(seqM2,sfz.stream_player, sfzR.ampeg_def),PS(finM2,sfz.stream_player, sfzR.ampeg_def)})
	end

	local play2T = copyplayer(play1)
	play2T.channel.level = db2amp(db)
	play2T.ppqOffset = off
	play2T:Bind(LS{PS(seqT2,sfz.stream_player, sfzR.ampeg_def),PS(finT2,sfz.stream_player, sfzR.ampeg_def)})
	return play2,play2T
end

--sfz,durfac,size_notused, oct,offset,pan,db,limit,ini,fras,Tfras,Tonly
ply1,ply1T = DoVoic(violin1,1,1,0,0,-1,-2.5,34) --z=1
ply2,ply2T = DoVoic(violin2,2,1,1,18*1,-0.5,-0,24) --z=1
ply3,ply3T = DoVoic(viola,4,2.5,2,(18 + 18*2)*1,-0.02,-0,13,nil,nil,nil,false) --z=0.5
ply4,ply4T = DoVoic(celli,8,4,3,(18 + 18*2 + 18*4)*1,0.5,0,12) --z o.26
ply5,ply5T = DoVoic(bass,16,5,4,(18 + 18*2 + 18*4 + 18*8)*1,1, 2,8,3,fraseBass,TfraseBass) --z=0.25
--------------------------------
actioncue=ActionEP{name="actioncue"}
actioncue:Bind{actions=LS{STOP(1070,unpack(OSCPlayers)),}}

--------------------- Master --------------------------------------------
MASTER{level=db2amp(-20)}

FreqScope()
--DiskOutBuffer("tintinabuli_bodys6.wav")
Effects={FX("dwgreverb",db2amp(-3),nil,{c1=1.2,c3=6,len=1551})}
theMetro:play(240,nil,nil,30)
theMetro:start()

--LILY:Gen(0,1070,TA(OSCPlayers),{time="6/4"})