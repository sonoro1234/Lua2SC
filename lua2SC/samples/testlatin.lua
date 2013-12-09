require("sc.Phonemes")
function part(t)
	--return partition(t[1],t[2],t[3])
	return composition(t[1],t[2],t[3])
	--local aaa
	--if not pcall(function()
		--aaa=composition(t[1],t[2],t[3])
	--end) then debuglocals(true);error() end
	--return aaa
end
--[[
conductor=EP{name="conductor",MUSPOS=0}:Bind{
	dur=32,
	seq=FS(permutation,-1,{1,2,3,4,5,6,7,8}),
	durlist=FS(part,-1,{8,8,0.5})
}
--]]
voz="soprano"
soprano=OscEP{inst="formantVoice2",mono=true,sends={0.5},MUSPOS=2,channel={level=db2amp(-1.5)}}
soprano:Bind{
	
	degree=48,--LOOP{AGLS(function (c) print"generandooooooooooooooooooooooooooooooo";error()--if not c.curlist then return nil end 
		--return AT(c.curlist.seq) + 7*5  end,conductor,2),REST },
	escale=escala,
	sweepRate= 1,--0.3,
	velo=0.4,
	pan=-0.3,
	legato=WRS({1,0.8},{0.9,0.1},-1),--RS({1,0.5},-1),
	dur=1,--LOOP{AGLS(function (c)  return c.curlist.durlist end,conductor,2),16},
	--[{"f","a","q"}]=LS(Formants:paramsPalabra({voz.."A",voz.."E",voz.."I",voz.."O",voz.."A",voz.."E",voz.."I",voz.."O",voz.."U"}),-1)
}

soprano.inserts = {
					--{"BLowShelf",{bypass=1}},
					--{"BPeakEQ",{bypass=1}},
					{"BHiShelf",{bypass=0,db=6,freqEQ=1500,rs=4}}
}

--prtable(soprano:NextVals())