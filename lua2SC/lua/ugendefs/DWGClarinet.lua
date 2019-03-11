DWGClarinet = UGen:new{name="DWGClarinet"}
function DWGClarinet.ar(freq, pm,pc,m, gate,release,c1,c3)
	freq=freq or 440;pm=pm or 1;pc= pc or 1;gate = gate or 1;m = m or 0.4;c1 = c1 or 0.25;c3 = c3 or 5;release = release or 0.1
	return DWGClarinet:MultiNew{2,freq, pm,pc,m, gate,release,c1,c3}
end
DWGClarinet2 = UGen:new{name="DWGClarinet2"}
function DWGClarinet2.ar(freq, pm,pc,m, gate,release,c1,c3)
	freq=freq or 440;pm=pm or 1;pc= pc or 1;gate = gate or 1;m = m or 0.4;c1 = c1 or 0.25;c3 = c3 or 5;release = release or 0.1
	return DWGClarinet2:MultiNew{2,freq, pm,pc,m, gate,release,c1,c3}
end
DWGClarinet3 = UGen:new{name="DWGClarinet3"}
function DWGClarinet3.ar(freq, pm,pc,m, gate,release,c1,c3)
	freq=freq or 440;pm=pm or 1;pc= pc or 1;gate = gate or 1;m = m or 0.4;c1 = c1 or 0.25;c3 = c3 or 5;release = release or 0.1
	return DWGClarinet3:MultiNew{2,freq, pm,pc,m, gate,release,c1,c3}
end