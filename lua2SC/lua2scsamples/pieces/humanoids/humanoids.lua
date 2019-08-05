---------------first the SynthDefs

local tract = require"num.tract"(20)

-- reverb
SynthDef("dwgreverb", { busin=0, busout=0,predelay=0.1,c1=4,c3=4,len=1200,mix = 1},function()
	local source=Mix(In.ar(busin,2)); 
	source = DelayC.ar(source,0.5,predelay)
	source = DWGReverbC1C3_16.ar(source,len,c1,c3,mix)	
	ReplaceOut.ar(busout,source)
end):store();

ER = require"sc.ER"(0.9,1.5,1,{part=true,L={20,30,6},Pr={10,5,1.2}})
Sync()

------------------utility function for transforming sequences
-- seq: the sequence
-- off: time offset
-- dur: if not nil maximum duration of sequence
-- lenfac: multiplier for dur
-- trans: transposition in degrees
-- text: text to sing
function DoVoice(seq,off,dur,lenfac,trans,text)
	lenfac = lenfac or 1
	trans = trans or 0

	local seq2 = deepcopy(seq)
	seq2.dur = seq2.dur*lenfac
	seq2.degree = seq2.degree  + trans

	local findur
	if dur then 
		findur = FinDur(dur,LOOP{PS(seq2,LOOP(PS(tract:Talk(text))))}) 
	else 
		findur = PS(seq2,LOOP(PS(tract:Talk(text)))) 
	end
	if off == 0 then 
		return findur 
	else 
		return LS{DOREST(off), findur} 
	end
	
end
-------------------the main phrase
-- degree is keeped in degree as data for freq modulations

scale = TA{0, 1.5, 3, 5, 7, 8, 10} + 3

phrase = {
	dur = LOOP{2,1,2,1}*0.5,
	escale = {scale} ,
	freq = LOOP{ENVdeg({0,-1,0,0},{0.2,0.2,3},true),getdegree,ENVdeg({0,-1,0,0},{0.2,0.2,3},true),REST},
	degree = LOOP{LS{1,2,3,5,4,2,1}:rep(4),LS{4,2,1,1}} + 7*5,
	pan = 0 ,
	t_gate = 1,
	fA = 0.82,
	fAc = 2,
	fA0 = 1,
	fexci = 18500,
	Rd = 1.97,
	namp = 0.02,
	nwidth = 0.5,
}

------------------- intro phrase variation
sini1 = deepcopy(phrase)
sini1.dur = 3*0.5
sini1.freq = LOOP{ENVdeg({0,-1,0,0},{0.2,0.2,3},true),getdegree,ENVdeg({0,-1,0,0},{0.2,0.2,3},true),getdegree}
sini1.degree = LS{1,2,3,5,4,2,1,REST}:rep(1) + 7*5

sini2 = deepcopy(sini1)
sini2.dur = LOOP{2,1}*0.5
sini2.legato = LOOP{LS{1}:rep(6),0.5,1}
sini2.degree = LS{LS{1,2,3,5,4,2,1}:rep(4),LS{4,2,1,REST}} + 7*5

texto = [[A-E-I-O-U]]
intro = LS{PS(sini1,LOOP(PS(tract:Talk(texto)))),PS(sini2,LOOP(PS(tract:Talk(texto))))}

----------------------- humm  voices --------------------

seqHmm = {
	dur = LOOP{2,4}*0.5,
	escale = {scale},
	freq = LOOP{ENVdeg({-1,0,0,-1},{0.5,0.4,0.1}),REST}, 
	degree = 1+7*5,--LOOP{1,1} + 7*5,
	fA = 0.72,
	fAc = 3.85,
	fexci = 18500,
	Rd = 1.2,
	namp = 0.02,
}

Hmm2 = DoVoice(seqHmm,1.5 ,nil,1,0,[[UMv]])
Hmm = DoVoice(seqHmm,0 ,nil,1,7,[[UMv]])
Hmm3 = DoVoice(seqHmm,1.5 ,nil,1,2,[[UMv]])

-------------------- part1-----------------
-- three voices singing phrase with an offset of 24, each one at half speed and with transposition
phrase3 = deepcopy(phrase)
phrase3.fA = ConstSt(1.1)
phrase3.fAc = ConstSt(1)
phrase3.amp = ConstSt(0.8)

Le = 24 -- phrase lengh four bars 12/8
--DoVoice( 	  voz,      	off,  	dur,pan,	lenfac,trans,text)
voic1 = DoVoice(phrase,	0, 		Le*5,     1,    0,texto)
voic2 = DoVoice(phrase,	Le, 	Le*4,     2,    3,texto)
voic3 = DoVoice(phrase3,	Le*2, 	Le*3,     4,   -3,texto)

--------------------- part2 ----------------
-- three voices singing the same phrase with an offset of delta

delta = Le  + 6 + 1 --four bars plus one bar plus 1/8
N = 2
part2 = {}
for i=0,N do
	part2[i+1] = DoVoice(phrase, delta*i ,Le*(N + 5 -i),nil,nil,texto)
end

---------------------- the score structure with named_events ----------
require"sc.named_events"
player = OscEventPlayer:new{inst=tract.sinteRdO2.name,mono=true,sends={db2amp(-6)},channel={level=0.3}}

v1 = copyplayer(player):Bind(LS{intro, SETEv"part1" ,voic1, SETEv"part2",part2[1]})
v2 = copyplayer(player):Bind(LS{WAITEv"part1" ,voic2,part2[2]})
v3 = copyplayer(player):Bind(LS{WAITEv"part1" ,voic3,part2[3]})
h1 = copyplayer(player):Bind(LS{WAITEv"part2" ,DOREST(Le) ,Hmm})
h2 = copyplayer(player):Bind(LS{WAITEv"part2",DOREST(Le) ,Hmm2})
h3 = copyplayer(player):Bind(LS{WAITEv"part2",DOREST(Le) ,Hmm3})

h1.channel.level = db2amp(-14)
h2.channel.level = db2amp(-12.62)
h3.channel.level = db2amp(-32.62)

-- early reflection settings
-- player, pan, distance
ER:setER(v1,0.1,1.5)
ER:setER(v2,-0.75,1.5)
ER:setER(v3,0.75,1.5)
ER:setER(h1,-0.5,2.5)
ER:setER(h2,0.5,2.5)
ER:setER(h3,0.5,2.5)

----------------stop on 340.5 ------
ActionEP{name="actioncue"}:Bind{
	actions=LS{
			STOP(340.5,unpack(OSCPlayers)),
	}
}
----------------------------------

Effects={FX("dwgreverb",db2amp(-11),nil,{c1=2.9,len=1551})}
theMetro:play(120,-4,nil,30)
theMetro:start()
--DiskOutBuffer("humanoides4ER.wav")
FreqScope()

