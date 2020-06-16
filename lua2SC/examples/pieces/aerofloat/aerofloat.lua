RANDOM:seed(17) --for getting the same piece always we seed it with fixed number
-------------------------first the SynthDefs------------------------------
-- we will getting requiring a lua file with synthdefs in this script folder
-- and call sync for waiting to async complete
path = require"sc.path"
path.require_here()
require"synthdefs"
Sync()
------------------------------------the sequences and players  ------------------------------------
-- this are sequences for metalophon player
-- initseq formed by three consecutive sequences, dur halves each seq
initseq = TA{PS{
			degree=LOOP{1,4,0}+7*5, 
			dur=WRS({0.5,0.25},{3,1},20)*4,
			amp=noisefStream{0.2,0.9},
		},
		PS{
			degree=LOOP{
					1,LS{5, 8,10}:rep(RS{0,1}),
					4,LS{9}:rep(RS{0,1}),LS{11,12}:rep(RS{0,1}),
					0,RS{8,10}}+7*5,
			dur=WRS({0.5,LS{0.25,0.25}},{20,1},30*2)*2,
			amp=noisefStream{0.2,0.9},
		},
		PS{
			degree=LOOP{
					1,LS{5, 8,10}:rep(RS{0,1}),LS{12}:rep(RS{0,1}),
					4,LS{9},LS{11,12}:rep(RS{0,1}),
					0,RS{8,LS{8,10}}}+7*5,
			dur=WRS({1,LS{0.5,0.5}},{4,3},30*4)*1,
		}}

-- the order of sequences is reversed
reverseseq = PS({
					escale = "aeolian",
					amp=noisefStream{0.2,0.9},
					pan1 = noisefStream{-1,1},
					pan2 = noisefStream{-1,1}
				},
				LS(initseq:reverse())
			)

-- metalophon player creation and sequence binding
met=OscEP{inst="metalophon",mono=false,dontfree=true,sends={db2amp(-18)},channel={inst="channel",level=db2amp(0)}}

met:Bind(PS({
					escale = "aeolian",
					amp=noisefStream{0.2,0.9},
					pan1 = noisefStream{-1,1},
					pan2 = noisefStream{-1,1}
				},
				LS(initseq..{
					PS{ -- this fourth seq is chainned with initseq
						degree=LOOP{
								1,LS{5, 8,10}:rep(RS{1,2}),LS{12}:rep(RS{0,1}),
								4,LS{9},LS{11,12}:rep(RS{0,1}),
								0,RS{8,LS{8,10}}}+7*5,
						dur=WRS({0.5,LS{0.25,0.25}},{20,1},-1),
					}}
				)))




-- copy met player (including binded sequence) in 3 players
-- because is a randomized pattern it will be different on each player
-- set channel level to -5 db
met1 = copyplayer(met)
met1.channel.level =  db2amp(-5)
met2 = copyplayer(met)
met2.channel.level =  db2amp(-5)
met3 = copyplayer(met)
met3.channel.level =  db2amp(-5)

-- player alambres will folow amp and dur from met player
alambres=OscEP{inst="alambres",mono=false,dontfree=true,sends={db2amp(-16)},channel={inst="channel",level=db2amp(-28)}}

alambres:Bind{
	degree = RSinf{1,3,5,8}+7*2,
	amp = FS(function(e,p) return p.curlist and p.curlist.amp or nil end,-1,met),
	dur = FS(function(e,p) return p.curlist and p.curlist.dur or nil end,-1,met),
	pan = noisefStream{-0.5,0.5},
	GAIN = 0.1
}

-- korean_bell player
korean=OscEP{inst="korean_bell",mono=false,dontfree=true,sends={db2amp(-18)},channel={inst="channel",level=db2amp(0)}}
korean:Bind{
	degree = 1+7*6,
	amp = 0.8,
	dur = RSinf{20,0.25},
	pan = noisefStream{-0.5,0.5}
}

-------------- koto player with its markov sequence
markovkoto = OscEP{inst = "KarplusMiniArp",dontfree=true,sends={0.5},channel={level=(db2amp(0))}}
-- inserts for koto: equalizer and ping-pong delay
markovkoto.inserts = {{"BPeakEQ",{db = 7.4, freqEQ = 1416}},{"PPongF",{volumen=0.6, ffreq=1000, rq=1,  fdback=0.9, delaytime=BeatTime(4)}}}

-- sequence for koto will be a 6th order markov sequence learned from this
kotoseq = {72,72,72,72,72,75,70,72,67,70,72,72,72,72,70,67,65,67,70,63,65,67,60,63,65,67,67,67,70,65,67,70,72,72,75,75,75,77,72,75,75,70,72,75,67,70,72,72,72,67,70,79,79,79,79,82,79,77,77,79,75,77,79,72,75,77,77,70,72,75,70,70,70,70,70,70,72,72,72,72,75,75,70,72,72,67,70,72,63,67,70,70,70,70,70,70,70,70,70,70,67,70,65,65,65,65,63,65,60,60,60,63,63,72,72,72,72,72,72,75,70,72,72,}
mark2 = MarkovLearnO(kotoseq,6)

markovkoto:Bind(LOOP{PS{
	note = LS{MarkSO(mark2)},
	dur = RS({LS{0.25}:rep(4),2,LS{0.5}:rep(2),LS{1/3}:rep(6)}):rep(LOOP{7,7,14})*1.5,
	amp = noisefStream{0.4,0.9} ,
	pan = brownSt(-1,1,0.1),---0.5,
	delayComp = -1.0,
	wideF2 = 2.5,
	freqR3 = 6000},
	PS{
		note = LS{REST},
		dur = 24
	}
})

-------------- sinpad player
-- voicer used by sinpad
-- does voice conduction for N voices with minimum distance movements
function voicer(N)	
	local oldval
	local permut = permutations(TA():series(N))
	--prtable(permut)
	return function(val)
		local res =TA{}
		local distM = {}
		if oldval then
			for i,v in ipairs(oldval) do
				distM[i] = {}
				for i2,v2 in ipairs(val) do
					local dist = (v2 - v)%7
					if math.abs(dist) > 3 then
						if dist > 0 then
							dist = dist - 7
						else
							dist = dist + 7
						end
					end
					distM[i][i2] = dist
				end
			end
			print(tb2st(distM))
			--search best transition
			local mindist = math.huge
			local bper
			for i, per in ipairs(permut) do
				local dist = 0
				for i2,v2 in ipairs(per) do
					dist = dist + math.abs(distM[i2][v2])
				end
				if mindist > dist then
					mindist = dist
					bper = per
				end
			end
			if mindist ==0 then
				local tperm = choose(permut)
				for i,v in ipairs(tperm) do
					res[i] = val[v]
					if i > 1 then
						while res[i] < res[i-1] do
							res[i] = res [i] + 7
						end
					end
				end
			else
				for i,v in ipairs(bper) do
					res[i] = oldval[i] + distM[i][v]
				end
			end
		else
			local tperm = choose(permut)
			for i,v in ipairs(tperm) do
				res[i] = val[v]
				if i > 1 then
					while res[i] < res[i-1] do
						res[i] = res [i] + 7
					end
				end
			end
		end
		oldval = res
		print(res)
		return res
	end
end

sinpad = OscEP{inst="sinpad",channel={level=db2amp(-6)}}:Bind{
	escale = "aeolian",
	dur = LS{LS{16}:rep(2),LS{24}:rep(3),LOOP{32}},
	delta = LOOP{LS{16}:rep(2),LS{32}:rep(3)},
	degree  = SF(LOOP{{1,3,5},{1,3,5},{2,5,7},{1,4,6.5},{1,4,6}},voicer(3))+7*5,
	amp = 1,
	gdamp = noisefStream{0.003,0.008}
}

-- sinpadF
sinpadF = OscEP{inst="sinpadF",MUSPOS=0,channel={level=db2amp(-10)}}:Bind{
	escale = "aeolian",
	dur = 32,
	degree  = LOOP{{1,3,5},{0,2,5},{1,4,6.5},{1,4,6}} + 7*5,
	amp = 1,
	ffreq2 = LOOP{500,6000},
	ffreq1 = LOOP{6000,500},
	rq = 0.1,
	pw = 0.1,
	fftime = beats2Time(32),
	gdamp = noisefStream{0.003,0.008}
}
sinpadF.inserts = {{"BLowShelf",{db=-24,freqEQ=1000}}}

-- sinpad2 will begin on beat 210
sinpad2 = OscEP{inst="sinpad",MUSPOS=210,channel={level=db2amp(-3)}}:Bind{
	dur = LOOP{32,32,32,32},
	delta = 32,
	escale = "aeolian",
	--degree = LOOP{{1,3,5},{2,5,7},{1,4,6.5},{1,4,6}} + 7*5,
	degree  = {1+7*3,1+7*4},
	amp = 1,--{1,0.75},
	gdamp = 0.003 --noisefStream{0.003,0.008}
}

-----------------------------------the structure
actions =ActionEP():Bind{
	actions = LS{
		--STOP(0,unpack(OSCPlayers)),
		STOP(0,sinpadF,sinpad,markovkoto),
		MUTE(0,met1,met2,met3,alambres),
		UNMUTE(60,alambres),
		START(80,sinpad),
		UNMUTE(280,met1),
		UNMUTE(320,met2),
		UNMUTE(360,met3),
		START(480,markovkoto),
		START(592,sinpadF), --80 +128 *4
		STOP(750,met,met1,met2,met3,alambres,sinpad2,korean,sinpadF),
		ACTION(976 -32,StartPlayer,976 - 128,sinpadF),
		START(970,korean),
		ACTION(976,StartPlayer,976 - 220, met,met1, met2, met3, alambres,korean),
		START(976,sinpad2),
		STOP(1360,markovkoto),
		ACTION(1360,function() met:Bind(reverseseq) end),
		START(1360,met),
		FADEOUT(1370,1400,sinpad,sinpad2,sinpadF),
		STOP(1370,met3),
		STOP(1380,met2),
		STOP(1400,met1),
		STOP(1470,met,korean,alambres),
		
	}
}


---------------------------Master section ------------------------

Effects={FX("gverb",nil,nil,{revtime=9})}
theMetro:play(160,-4,1)	
-- uncomment to record
--DiskOutBuffer([[aerofloat.wav]])

