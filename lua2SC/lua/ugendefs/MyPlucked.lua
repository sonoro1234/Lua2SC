MyPlucked=UGen:new{name='MyPlucked'}
function MyPlucked.ar(...)
	local   freq, amp, gate, pos, c1, c3, inp, release,jw   = assign({ 'freq', 'amp', 'gate', 'pos', 'c1', 'c3', 'inp', 'release','jw' },{ 440, 0.5, 1, 0.14, 1, 30, 0, 0.1,1 },...)
	return MyPlucked:MultiNew{2,freq,amp,gate,pos,c1,c3,inp,release,jw}
end

MyPluckedStiff=UGen:new{name='MyPluckedStiff'}
function MyPluckedStiff.ar(...)
	local   freq, amp, gate, pos, c1, c3, inp, release, fB, jw   = assign({ 'freq', 'amp', 'gate', 'pos', 'c1', 'c3', 'inp', 'release', 'fB', 'jw' },{ 440, 0.5, 1, 0.14, 1, 30, 0, 0.1, 2, 0 },...)
	return MyPluckedStiff:MultiNew{2,freq,amp,gate,pos,c1,c3,inp,release,fB,jw}
end

MyPlucked2=UGen:new{name='MyPlucked2'}
function MyPlucked2.ar(...)
	local   freq, amp, gate, pos, c1, c3, inp, release, mistune, mp, gc, jw   = assign({ 'freq', 'amp', 'gate', 'pos', 'c1', 'c3', 'inp', 'release', 'mistune', 'mp', 'gc', 'jw' },{ 440, 0.5, 1, 0.14, 1, 30, 0, 0.1, 1.008, 0.55, 0.01, 0 },...)
	return MyPlucked2:MultiNew{2,freq,amp,gate,pos,c1,c3,inp,release,mistune,mp,gc,jw}
end