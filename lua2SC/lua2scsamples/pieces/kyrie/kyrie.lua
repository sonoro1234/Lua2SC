-- General plan:
-- 10 cycles singing Kyrie eleison two times with phrygian scale ending with shifted third degree

-- first cycle starting on unison an moving two voices apart
-- second cycle transposing secondary voices a fourth down
-- third cycle transposing secondary voices a third up
-- 3 more cycles as the first 3 with addition of two tintinabuli voices
-- 3 more cycles using only the shifted third degree scales
-- last cycle with no transposition

-- piano punctuates the separation between cycles
-------------------------------
-- uncomment LILY at the end of script to generate score
LILY = require"sc.lilypond"

--------------------- synthdefs ----------------------
tract = require"num.Tract"(26)
--tract = require"num.vocaltract"(26,true,true)
--tract = require"num.vocaltract"(26,false,true)

SynthDef("dwgreverb", { busin=0, busout=0,c1=4,c3=4,len=1200,mix = 1},function()
	local source=Mix(In.ar(busin,2)); 	
	source = DWGReverbC1C3_16.ar(source,len,c1,c3,mix)	
	ReplaceOut.ar(busout,source)
end):store();

SynthDef("soundboard", { busin=0, busout=0,c1=15,c2=20,mix=0.9},function()
	local input=In.ar(busin,2); 
	local son = OteySoundBoard.ar(input,c1,c2,mix)
	son = AllpassC.ar(son,0.02,{0.01,0.0113})
	ReplaceOut.ar(busout,son)
end):store();
--------
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


SynthDef("bowsoundboard", { busin=0, busout=0,mix=1,fLPF=6300,size=3.4,T1=0.2,gainS=0.6,gainL=2,gainH=5},function()
	local str=In.ar(busin,2); 
	
	local coefs = TA{199, 211, 223, 227, 229, 233, 239, 241 } *size
	local fdn = DWGSoundBoard.ar(str,nil,nil,mix,unpack(coefs:asSimpleTable()));
	local bodyf = 0
	T1 = T1:max(0.001)
	for i,v in ipairs(body_resons) do
		bodyf = bodyf + BPF.ar(str,v[1]*T1,1/(v[2]*T1))*db2amp(v[3])
	end
	local son = str*gainS + bodyf*gainL + fdn*gainH
	--son = LPF.ar(son,fLPF)
	ReplaceOut.ar(busout,son)
end):store();

SynthDef("oteypiano", { out=0, freq=440, amp=0.5, t_gate=1,gate=1, rmin = 0.35,rmax =  2,rampl =  4,rampr = 8, rcore=1, lmin =  0.07,lmax =  1.4;lampl =  -4;lampr =  4, rho=1, e=1, zb=2, zh=0, mh=1.6, k=0.1, alpha=1, p=1, pos=0.142, loss = 1,detunes = 6,pan=0},function()

	local vel = amp
	local env = EnvGen.kr{Env.adsr(0,0,1,0.1),gate,doneAction=2}
	local son =  OteyPianoStrings.ar(freq, vel, t_gate, rmin,rmax,rampl,rampr, rcore, lmin,lmax,lampl,lampr, rho, e, zb, zh, mh, k, alpha, p, pos, loss,detunes*0.0001,2)*env
	Out.ar(out, Pan2.ar(son *0.1,LinLin.kr(freq,midi2freq(21),midi2freq(80),-0.75,0.75)));
end):store();

-- make coral synth for 3 voices
local fratio = midi2ratio(0.05) --0.05
local freqs = TA():gseries(3,1 * fratio^(-1),fratio)
tract:MakeCoralSynth("coral2",freqs,true)
Sync()

------------------------------- some functions ----------------
-- function for do tintinabuli voice from main voice (low) for chord and order (-3 to 3)
function Tintinabuli(chord,order)
	return function(low)
	if low == REST then return REST end
	local tv 

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
			tv = tinv[dists[-order].index] - 7
		else
			tv = tinv[dists[order].index]
		end
		return tv
	end
end

-- function returning amp factor from current beat
function ppqpos2amp()
	return linearmap(0,420,1,2,theMetro.ppqPos)
end

------------------------ music ------------
-- scales
transpose = 4 
escale = modes.phrygian + transpose
escale2 = modes.phrygian + transpose
escale2[3] = escale2[3] + 1 -- third degree shifted
escale2 = newScale(escale2)

-- general voice parameters
--curr_panel = addPanel{type="hbox",name="voicepars"}
voicparams = {
	fA = SliderControl("fA",0.5,3,1),
	fAc = SliderControl("fAc",0.1,3,1),
	
	fexci = SliderControl("fe",1000,16000,16000),
	fout = SliderControl("fo",1000,20000,20000),

	namp = SliderControl("namp",0,0.08,0.01),
	nwidth = SliderControl("nwidth",0.0,1,0.5),
	
	thlev = 0.1,
	vibrate = SliderControl("Vr",0.5,20,5),
	vibdeph = SliderControl("Vd",0,0.1,0.01),
}


-- for transposing melody each cycle
sequ = {0,-3,-5+7}
-- 10 cycles of 18 events (42 beats): 16 notes and 2 RESTs
melody = {
	pan = 0,
	escale = LS{LS{LS({{escale}},14),LS({{escale2}},4)}:rep(6),LOOP{{escale2}}},
	amp = LOOP{LS{LS(1,6),0.4,0.4}:rep(2),1,1}*0.6,
	degree = LOOP{LS{1}:rep(16),REST,REST} + 7*5, 
	dur = LS{LS{LS{2}:rep(16),4,6}:rep(3*3),LS{LS{2}:rep(15),4,2,6}}
}

talk = tract:Talk("KI-RI-IE-_E-LE-EI-SO-Nv-KI-RI-IE-_E-LE-EI-SO-Nv-_v-_v")
talk = LOOP(PS(talk))
RDseq = {Rd= REP(18,LS{2.7,2.5,2.2,2,1.9,1.8,1.5,1.3,1.2,1.1})}

--first singer
s1 = OscEP{inst=tract.coral2.name,mono=true,sends={db2amp(0)},channel={level=db2amp(-15)}}
s1:Bind(LS{PS(melody,voicparams,talk,RDseq)})

-- second voice
-- every two events note goes up
-- uses transpose seq each cycle
melo2 = deepcopy(melody)
melo2.degree = REP(2,LOOP{0,1,2,3,4,5-7,6-7,0,REST}) + 7*5+1 + REP(18,LOOP(sequ))
melo2.detune = 1.005
s2 = copyplayer(s1)
s2:Bind(LS{PS(melo2,voicparams,deepcopy(RDseq),deepcopy(talk))})

-- third voice as second voice but going down
melo3 = deepcopy(melody)
melo3.degree = REP(2,LOOP{0,-1,-2,-3,-4,-5+7,-6+7,0,REST}) + 7*5+1 + REP(18,LOOP(sequ))
melo3.detune = 1/1.005
s3 = copyplayer(s1)
s3:Bind(LS{PS(melo3,voicparams,deepcopy(RDseq),deepcopy(talk))})

-- after 3 cycles two tintinabulations --
-- 3 cycles with escale-escale2 and the rest 4 cycles with escale2
tindelay = 42*3
RDseqtin = {Rd=REP(18,LS{2,1.9,1.8,1.5,1.3,1.2,1.1})}

-- tintinabulation of second voice
local tinf = Tintinabuli({1,3,5},-3)
melo2t = deepcopy(melo2)
melo2t.escale = LS{LS{LS({{escale}},14),LS({{escale2}},4)}:rep(3),LOOP{{escale2}}}
melo2t.degree = SF(melo2t.degree,tinf)
melo2t.dur = LS{LS{LS{2}:rep(16),4,6}:rep(3*2),LS{LS{2}:rep(15),4,2,6}}
s2t = copyplayer(s1)
s2t:Bind(LS{DONOP(tindelay),LS{PS(melo2t,voicparams,RDseqtin,deepcopy(talk))}})

-- tintinabulation of third voice
local tinf2 = Tintinabuli({1,3,5},2)
melo3t = deepcopy(melo3)
melo3t.escale = LS{LS{LS({{escale}},14),LS({{escale2}},4)}:rep(3),LOOP{{escale2}}}
melo3t.degree = SF(melo3t.degree,tinf2)
melo3t.dur = LS{LS{LS{2}:rep(16),4,6}:rep(3*2),LS{LS{2}:rep(15),4,2,6}}
s3t = copyplayer(s1)
s3t:Bind(LS{DONOP(tindelay),LS{PS(melo3t,voicparams,deepcopy(RDseqtin),deepcopy(talk))}})

------------ piano --------------------
-- ostinato piano sequence inside cycles
p_osti = {
	dur = LS{1,0.5,1,0.5,1, 1,1,1,1}*0.5,
	amp = LOOP{1,0.3,0.7,0.3,0.5, 1,0.5,0.3,0.5}*0.5*FS(ppqpos2amp,-1),
	alpha = 1,
	p = 1, 
	t_gate = 1,
	pianopedal = true,
	escale = {escale},
	degree = LOOP{1,8+7,1+7,8+7,1+7,1,8+7,1+7,8+7} +7*2
}
-- break piano sequence between cycles
p_break ={
	dur = LS{LS{1,0.5,1,0.5,1}*0.5,LS{1,1,1,1},LS{ 1,1,1,1}*0.5,LS{1,0.5,1,0.5,1}*0.5},
	t_gate = 1,
	p = 1.3,
	pianopedal = LS{LS{true}:rep(17),true},
	escale = LS{LS{{escale2}}:rep(9),LS{{escale}}:rep(9)},
	amp = LS{LS{1,0.3,0.7,0.3,0.5}*0.5,LS{1,0.5,0.7,0.5},LS{2,0.5,0.3,0.5}*0.3,LS{1,0.3,0.7,0.3,0.5}*0.3}*FS(ppqpos2amp,-1),
	degree = LS{LS{1,8+7,1+7,8+7,1+7} +7*2,LS{{1,8+7,3+7*2,5+7*3,1+7*3},{5+7*2,1+7*3,3+7*3},{1,1+7*2,3+7*2,5+7*2,7+7*2,2+7*3},{5+7*2,1+7*3,3+7*3}} +7*2,LS{{1,9+7,4+7*2,5+7*3,1+7*3},8+7,1+7,8+7,1,8+7,1+7,8+7,1+7} +7*2},
}
piano = OscPianoEP{inst="oteypiano",sends={1},channel={level=db2amp(-10)}}
piano:Bind(LOOP{LS(PS(p_osti),8),PS(p_break)})
piano.inserts = {{"soundboard"}}

----- piece ending
ActionEP():Bind{actions = LS{ACTION(42*10+0.5,theMetro.stop,theMetro)}}

---------- early reflections room simulation -----------------
ER = require"sc.ER"(0.85,1,1,{part=true,N=5,L={20,30,6},Pr={10,5,1.2},compensation=true,bypass=true})
ER:setER(piano,-0.33,3)
ER:setER(s1,-0.1)
ER:setER(s2,-1)
ER:setER(s3,1)
ER:setER(s2t,-0.5)
ER:setER(s3t,0.5)

---------------- Master -----------------------

MASTER{level=db2amp(-5)} 
Effects={FX("dwgreverb",db2amp(-12),nil,{c1=1.5,c3=1,len=1551})}

--LILY:Gen(0,42*10,{s1,s2,s2t,s3,s3t})
--DiskOutBuffer("kyrie5d-7.wav")
--LILY:Gen(42*(3*3+2),{s2,s2t})

FreqScope()
theMetro:tempo(60)
theMetro:start()
