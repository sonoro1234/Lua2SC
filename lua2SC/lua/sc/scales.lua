--some basic scales, and some wacky ones too

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
    return notes
end

--construct the modes, using the offset from ionian
modes = {
ionian = constructMode(0),
dorian = constructMode(1),
phyrgian = constructMode(2),
lydian = constructMode(3),
mixolydian = constructMode(4),
aeolian = constructMode(5),
locrian = constructMode(6),
}

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