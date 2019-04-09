PluckSynth = UGen:new{name="PluckSynth"}
function PluckSynth.ar(freq, amp, gate,pos,c1,c3,release,F0,M,K,R,L,r,rho)
	freq=freq or 440;amp=amp or 1;gate = gate or 1;pos = pos or 1/7;c1 = c1 or 0.25;c3 = c3 or 5;F0 = F0 or 0;release = release or 0.1;M= M or 0;K = K or 0;R = R or 0;L = L or 0.65;r=r or 0.001;rho = rho or 7850
	return PluckSynth:MultiNew{2,freq, amp,gate,pos,c1,c3,release,F0,M,K,R,L,r,rho}
end