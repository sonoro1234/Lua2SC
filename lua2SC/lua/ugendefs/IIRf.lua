IIRf = UGen:new{name="IIRf"}
function IIRf.ar(inp, kB,kA)
	inp = inp or 0;
	if isMultiExpandable(kB[1]) then
		kB = flop(kB)
	end
	if isMultiExpandable(kB[1]) then
		kA = flop(kA)
	end
	return IIRf:MultiNew(concatTables({2,inp, #kB,#kA},kB,kA))
end