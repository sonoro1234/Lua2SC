PitchTracker=MultiOutUGen:new{name="PitchTracker"}
function PitchTracker.kr(inp,size,hop,dfreq,thresh,kind,useef,bufnum)
	size = size or 1024;hop = hop or 0.5;inp = inp or 0;bufnum = bufnum or -1;dfreq= dfreq or 440;thresh = thresh or 0.85;kind = kind or 0;useef = useef or 0
	return PitchTracker:MultiNew{1,3,inp,size,hop,dfreq,thresh,kind,useef,bufnum}
end