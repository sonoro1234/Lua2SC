IIRf = UGen:new{name="IIRf"}
function IIRf.ar(inp, kB,kA)
	inp = inp or 0;
	return IIRf:MultiNew(concatTables({2,inp, #kB,#kA},kB,kA))
end