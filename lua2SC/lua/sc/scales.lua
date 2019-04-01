--some basic scales, and some wacky ones too
local notenamesN = {[0]=0,0.5,1,1.5,2,3,3.5,4,4.5,5,5.5,6}
local notenames = {[0]="c","d","e","f","g","a","b"}
local nametonumber = {[0]=0,2,4,5,7,9,11}
local function min_semitones(dis)
	local dis2 = dis%12
	local dis3 = dis2 - 12
	if math.abs(dis2) < math.abs(dis3) then
		return dis2
	else
		return dis3
	end
end
local function get_scalenames(sc,up)
	up = up or 0
	local alts = 0
	local names = {}
	local note = sc[1]%12
	--print(note)
	local nameN = notenamesN[note]
	local nameI = math.modf(nameN +0.5*up)
	local nameF = min_semitones(note - nametonumber[nameI]) --%12
	local name = notenames[nameI]
	--alt = nameF < 0 and "b"
	--if nameF ~=0 then name= name.."#"..nameF end
	local nameT = {name,nameF}
	alts = alts + math.abs(nameF)
	names[1] = nameT
	for i=2,#sc do
		note = sc[i]%12
		nameI = (nameI + 1)%7
		nameF = min_semitones(note - nametonumber[nameI]) --%12
		name = notenames[nameI]
		--if nameF ~= 0 then name= name.."#"..nameF end
		nameT = {name,nameF}
		alts = alts + math.abs(nameF)
		names[i] = nameT
	end
	return names,alts
end
local function get_scale_notenames(sc)
	local names1,alts1 = get_scalenames(sc,0)
	local names2,alts2 = get_scalenames(sc,1)
	if alts1 < alts2 then
		return names1
	else
		return names2
	end
end
local scale = {}
scale.__index = scale
function scale:new(o)
	o = o or {}
	o.notenames = get_scale_notenames(o)
	setmetatable(o, scale)
	return o
end
function scale:init()
	self.notenames = get_scale_notenames(self)
end
function scale.__add(a,b)
	if getmetatable(a)~=scale then a,b = b,a end
	local res = {name=a.name}
	for i=1,#a do
		res[i] = a[i] + b
	end
	return a:new(res)
end
function scale.__sub(a,b)
	if getmetatable(a)~=scale then a,b = b,a end
	local res = {name=a.name}
	for i=1,#a do
		res[i] = a[i] - b
	end
	return a:new(res)
end
function scale.__eq(a,b)
	if #a~=#b then return false end
	if getmetatable(a)~=getmetatable(b) then return false end
	for i=1,#a do
		if a[i] ~= b[i] then return false end
	end
	return true
end
function newScale(t)
	return scale:new(t)
end

local function constructMode(offset)
    local note = 0
    local modeIncrements = {2,2,1,2,2,2,1}
    local notes = {}
    
    notes[1] = 0
    for i=1,6 do 
        index = ((offset+(i-1))%7)+1
        note = note + modeIncrements[index]        
        notes[i+1] = note
    end
    return scale:new(notes)
end

--construct the modes, using the offset from ionian
modes = {
ionian = constructMode(0),
dorian = constructMode(1),
phrygian = constructMode(2),
lydian = constructMode(3),
mixolydian = constructMode(4),
aeolian = constructMode(5),
locrian = constructMode(6),
}

for k,v in pairs(modes) do
	v.name = k
end
scales = 
{
    majorPentatonic = {0, 2, 3, 7, 9},
    newPentatonic = {0, 2, 3, 6, 9},
    japanesePentatonic = {0, 1, 5, 7, 8},
    balinesePentatonic = {0, 1, 5, 6, 8},
    pelogPentatonic = {0, 1, 3, 7, 10},
    hemitonicPentatonic = {0, 2, 3, 7, 11},
    variationPentatonic = {0, 4, 7, 9, 10},
    harmonicMinor = {0, 2, 3, 5, 7, 8, 11},
    melodicMinor = {0, 2, 3, 5, 7, 9, 11},
    wholeTone = {0, 2, 4, 6, 8, 10}, 
 augmented = {0, 3, 4, 6, 8, 11},
 diminished = {0, 2, 3, 5, 6, 8, 9, 11} ,
 enigmatic = {0, 1, 4, 6, 8, 10, 11}, 
 byzantine = {0, 1, 4, 5, 7, 8, 11},
 locrian = {0, 2, 4, 5, 6, 8, 10},
 persian = {0, 1, 4, 5, 7, 10, 11},
 spanish = {0, 1, 3, 4, 5, 6, 8, 10}, 
 hungarian = {0, 2, 3, 6, 7, 8, 10},
 nativeamerican = {0, 2, 4, 6, 9, 11},
 bebop = {0, 2, 4, 5, 7, 8, 9, 11},
 barbershop1  = {0, 2, 4, 5, 7, 11, 14, 17, 19, 23},
 barbershop2 = {0, 7, 12, 16, 19, 23},
 rain = {10, 14, 16, 18, 20, 24, 26, 30, 32},
 crystalline = {0, 7, 11, 15, 19, 26, 27, 34, 38, 42, 46, 53, 54, 61, 65, 69},
 popularblues ={0, 3, 5, 6, 7, 10},
 blues = {0, 3, 4, 7, 8, 15, 19},
 disharmony = {0, 1, 4, 5, 7, 8, 11, 12, 14, 15, 18, 19, 21, 22, 25, 26},
 gracemajor = {0, 5, 8, 13, 17, 19, 25, 30},
 eblues = {0, 2, 4, 7, 8, 6, 13, 17} 
 }

-- creates a scale by taking degree as tonic to
function modal_scale(scale,degree)
	local delta = 1 - degree + #scale
	local bb = TA(scale):rotate(delta)
	bb = bb(1,delta) - 12 .. bb(delta + 1,#bb)
	bb = bb - bb[1]
	return bb
end