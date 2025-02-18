sfzR = require"sc.sfzreader"

-- set this paths where you have sfz file installed

-- this is from https://github.com/sgossner/VSCO-2-CE/releases
VSCO = [[C:\supercolliderrepos\SFZ\VSCO-2-CE-1.1.0\]]
-- this is from http://virtualplaying.com/virtual-playing-orchestra/
VPO = [[C:\supercolliderrepos\SFZ\Virtual-Playing-Orchestra3\]]
-- https://github.com/peastman/sso
SSO = [[C:\supercolliderrepos\SFZ\sso-master\Sonatina Symphonic Orchestra\]]
SSO3 = [[C:\supercolliderrepos\SFZ\sso-3.0\Sonatina Symphonic Orchestra\]]
SSO4 = [[C:\supercolliderrepos\SFZ\sso-4.0\Sonatina Symphonic Orchestra\]]
--file dialog to choose .sfz file
local fpath= openFileSelector(SSO4,"sfz")

--fpath = [[C:\supercolliderrepos\SFZ\VSCO-2-CE-1.1.0\UprightPiano.sfz]]
--fpath =	[[C:\supercolliderrepos\SFZ\sso-4.0\Sonatina Symphonic Orchestra\Strings - Notation\Violin Solo 1 KS.sfz]]
--fpath = [[C:\supercolliderrepos\SFZ\Virtual-Playing-Orchestra3\Strings\1st-violin-SOLO-KS-C2.sfz]]	
print("fpath",fpath)
local sfz = sfzR.read(fpath,{ampeg_release=0.1})

-- all sw will be printed
print"sw keys"
prtable(sfz.sw)
-- all opcodes not known will be printed
print"unknown opcodes"
prtable(sfz.unknown_opcodes)

-- uncomment to print some info while playing
sfz.dump = true

-- this function will get the sfz data
function mmm(pl,freq,amp)
	local nota = freq2midi(freq)
	local allparams = sfz:getParams(nota,amp)
	if not allparams then pl.params.gate = 0;return end
	return allparams
end

Effects={FX("gverb",db2amp(0),0,{revtime=1,roomsize=100})}

-- midi.doprint = true
-- remember to set your midi-in in Debug->Settings
MidiToOsc.AddChannel(0,nil,{0.2},mmm,nil ,{retrig=true})
