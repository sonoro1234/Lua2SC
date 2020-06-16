sfzR = require"sc.sfzreader"

-- set this paths where you have sfz file installed

-- this is from https://github.com/sgossner/VSCO-2-CE/releases
VSCO = [[C:\supercolliderrepos\SFZ\VSCO-2-CE-1.1.0\]]
-- this is from http://virtualplaying.com/virtual-playing-orchestra/
VPO = [[C:\supercolliderrepos\SFZ\Virtual-Playing-Orchestra3\]]
-- https://github.com/peastman/sso
SSO = [[C:\supercolliderrepos\SFZ\sso-master\Sonatina Symphonic Orchestra\]]

-- file dialog to choose .sfz file
local fpath= openFileSelector(VSCO,"sfz")
print("fpath",fpath)
local sfz = sfzR.read(fpath)

-- all opcodes not known will be printed
print"unknown opcodes"
prtable(sfz.unknown_opcodes)

-- uncomment to print some info while playing
-- sfz.dump = true

-- this function will get the sfz data
function mmm(pl,freq,amp)
	local nota = freq2midi(freq)
	local allparams = sfz:getParams(nota,amp)
	if not allparams then pl.params.gate = 0;return end
	return allparams
end

-- remember to set your midi-in in Debug->Settings
MidiToOsc.AddChannel(0,nil,{0.5},mmm)
