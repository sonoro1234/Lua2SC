DWGFlute = UGen:new{name="DWGFlute"}
function DWGFlute.ar(freq, pm,endr,jetr,jetRa, gate,release)
	freq=freq or 440;pm=pm or 1;endr= endr or 0.5;gate = gate or 1;jetr =jetr or 0.5;c1 = c1 or 0.25;c3 = c3 or 5;release = release or 0.1;jetRa = jetRa or 0.33
	return DWGFlute:MultiNew{2,freq, pm,endr,jetr,jetRa, gate,release}
end

DWGFlute2 = UGen:new{name="DWGFlute2"}
function DWGFlute2.ar(freq, pm,endr,jetr,jetRa, gate,release)
	freq=freq or 440;pm=pm or 1;endr= endr or 0.5;gate = gate or 1;jetr =jetr or 0.5;c1 = c1 or 0.25;c3 = c3 or 5;release = release or 0.1;jetRa = jetRa or 0.33
	return DWGFlute2:MultiNew{2,freq, pm,endr,jetr,jetRa, gate,release}
end