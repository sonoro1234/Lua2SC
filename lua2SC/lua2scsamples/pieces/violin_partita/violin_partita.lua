
--LILY=require"sc.lilypond"

-----------------------SynthDefs------------
ER = require"sc.ER"(nil,1,1)

-- we will require a lua file with synthdefs in this script folder
-- and call sync for waiting to async complete
path = require"sc.path"
path.require_here()
require"synthdefs"
Sync()
------------------------------- music ----------------------------
-- phrygian scale with third shifted
escale = modes.phrygian +7 
escale[3] = escale[3] + 1
escale = newScale(escale)

midvoice = TA{5,5,5,5,4,6,5,4,3,4,5,6,7,8,9,10,10}
ampvoice = TA{2,1.5,1.25,1,2,1,2,1,2,1,2,2.25,2.5,2.75,3,3.5,3.75,4} 
fraselen = #midvoice

-- given a sequence of degress calculates the tintinabullation sequence for a chord and order
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
			dists[#dists + 1] = {index=j,dist=dist,val=tinv[j]} 
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

-- given a midvoice sequence and a transposition makes two types of phrase
-- type1: for each midnote add tonic, midnote and a third to midnote
-- not type1: for each midnote form a sequence of 6 notes including tintinabullations
function makedegrees(midvoice,dd,type1)
	local mid = midvoice + dd 
	local hi = mid + 5 --sixth above
	-- 2+2/3 equals to 3 in the actual scale with third lowered
	local tin = Tintinabuli(mid,{1,2+2/3,5},2)
	local ret = {}
	local retAmp = {}
	if type1 then
		for i=1,#mid do
			table.insert(ret,1)
			table.insert(ret,mid[i])
			table.insert(ret,hi[i])
		end
		for i=1,#mid do
			for j=1,3 do
			table.insert(retAmp,ampvoice[i])
			end
		end
	else
		for i=1,#mid do
			table.insert(ret,1)
			table.insert(ret,mid[i])
			table.insert(ret,tin[i])
			table.insert(ret,hi[i])
			table.insert(ret,tin[i])
			table.insert(ret,mid[i])
		end
		for i=1,#mid do
			for j=1,6 do
			table.insert(retAmp,ampvoice[i])
			end
		end
	end

	return LS(ret) + 7*5, LS(retAmp)
end

-- calls makedegrees several time to make the piece
function alldegrees()
	local ret = {}
	local retamp = {}
	local midvoice_reverse = midvoice:reverse()
	-- nine times calling makedegress, each time two degrees lower
	for i=0,8 do
		-- for going up an octave on iterations 5 to 8
		local up = i<5 and 0 or 7
		--will call type1 and not type1 in alternation
		local first = i%2==0 and true or false

		local deg,amp = makedegrees(midvoice,-i*2+up,first)
		table.insert(ret,deg)
		table.insert(retamp,amp)
		
		deg,amp = makedegrees(midvoice_reverse,-i*2+up,first)
		table.insert(ret,deg)
		table.insert(retamp,amp)
		
	end
	-- repeat last iteration but not type1
	local deg,amp = makedegrees(midvoice,-8*2+7*2,false)
	table.insert(ret,deg)
	table.insert(retamp,amp)
		
	deg,amp = makedegrees(midvoice_reverse,-8*2+7*2,false)
	table.insert(ret,deg)
	table.insert(retamp,amp)

	return LS(ret),LS(retamp)
end

---------this gives duration of bowing phases
local durab = 0.4
local function durabow() 
	return {0,0.5*(1 - durab),durab,0.5*(1 - durab)}
	--return {0,0.5*(1 - durab),0.5,0}
end
local function durabowini() 
	return {0,(1 - durab),durab,0}
end
-- slider for changing durabow and durabowini parameter
sl = Slider("durav",0,1,0,function(val) durab= val end)

-- the player
violin = OscEP{inst="bowed",sends={db2amp(-6)},channel={level=db2amp(0),pan=0.2},poly=nil}
violin.inserts = {{"bowsoundboard",{T1=0.2,size=2.67,fLPF=8000}}}

local degpat1,amppat1 = alldegrees() -- degree and amplitudes for violin second part
amppat2 = deepcopy(amppat1) -- one for force the other for amp

curves = nil 
pat1 = PS{
	escale = {escale},
	amp = LOOP{ENVr({0,0,1,1,0},durabow,curves),ENVr({0,0,-1,-1,0},durabow,curves)}*FS(function(e) return linearmap_c(110,625,0.75,4,e.ppqPos) end,-1)*amppat2,

	force = FS(function(e) return linearmap_c(110,625,0.75,4,e.ppqPos) end,-1)*amppat1,
	degree = degpat1,
	release = 0,
	pos = brownSt(0.1,0.2,0.03),
	c1 = 4,
	c3 = 40,
	dur = 1/3 
}

-- initial and ending phrase
patini = PS{

	escale = {escale},
	amp = LOOP{ENVr({0,0,1,1,0},durabowini),ENVr({0,0,-1,-1,0},durabowini)}*LS(TA():series(18,0.5,0.1)),
	force = LS(TA():series(18,1,0.1)),
	degree = LS{1,2,1,3,4,2,1,LSS{5-7,5},REST}:rep(2) + 7*5,
	pos = brownSt(0.12,0.2,0.02),
	dur = LOOP{2,1,1,1,1,3,1,3,0.5}*4
}

violin:Bind(LS{patini,DONOP(3),SETEv("arp"),pat1,patini})

--------------- piano
piano = OscPianoEP{inst="help_oteypiano",sends={db2amp(-6)},channel={level=db2amp(-7)}}

-- this will expects a func to map ppq to amp
-- and will remember ppq position when firs called
local function mapppq(func)
	local firstppq 
	return function(e)
		-- firsppq is set the first time executed
		firstppq = firstppq or e.ppqPos
		return func(e.ppqPos-firstppq)
	end
end

pianopat=PS{
	escale = {escale},
	t_gate = 1,
	dur = LOOP{ LS{fraselen*3/3}:rep(5), fraselen*3/3},
	strum = 0.4,
	degree = LOOP{{1,8,5,12}} + LOOP{7*3,7*5,7*3,7*5,7*5,7*5} ,
	amp = FS(mapppq(function(pos) return linearmap_c(0,515,0.4,1.5,pos) end),-1),
	k = 0.2,
	p = 0.35
}
piano:Bind(LS{WAITEv("arp"),pianopat})

-- get first degree note from scale to set resonDWG
local freC = midi2freq(getNote(1+7*3,escale))
piano.inserts = {{"piano_soundboard"},{"resonDWG",{freqC=freC*0.5,level=0.75}}}

------------------------------
-- early reflections
ER:setER(piano,0.1,3)
ER:setER(violin,-0.3,2)

-- stop on 750
ActionEP{}:Bind{
	actions = LS{
				ACTION(750,function() theMetro:stop() end),
				}
}

--- master
Effects={FX("dwgreverb3band",db2amp(-1.5),nil,{c1=3.5,c3=6,len=2950})}

theMetro:tempo(140) --160
theMetro:start()

--LILY:Gen(0,700,TA({piano}))
--LILY:Gen(0,750,TA(OSCPlayers),{clefs={[1]=0}})
--DiskOutBuffer("partitaTinAmpER.wav")
