-- inp: input
-- size: of buffer for analysis
-- hop : fraction of size that triggers a new analysis
-- dfreq : desired frequency
-- thresh : minimum level of valid peak
-- kind : kind of analysis, 0 ACR, 1 NSDF, 2 SDF(worst performant)
-- useef : use dfreq value to accelerate peak searching
-- bufnum : SndBuffer representing analysys
-- t_clear : zeroes analysis buffer when is not 0
-- returns : estimated frequency, estimated clarity (0 to 1 on kind acr and nsdf), R0 (power of signal)
PitchTracker=MultiOutUGen:new{name="PitchTracker"}
function PitchTracker.kr(inp,size,hop,dfreq,thresh,kind,useef,bufnum,t_clear)
	size = size or 1024;hop = hop or 0.5;inp = inp or 0;bufnum = bufnum or -1;dfreq= dfreq or 440;thresh = thresh or 0.85;kind = kind or 0;useef = useef or 0;t_clear = t_clear or 0
	return PitchTracker:MultiNew{1,3,inp,size,hop,dfreq,thresh,kind,useef,bufnum,t_clear}
end