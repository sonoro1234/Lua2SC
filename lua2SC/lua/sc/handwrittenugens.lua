--------------not real ugens
--------------------------------------
function VarLag:new1(rate,inp, time, curvature, warp, start)
	print(rate,inp, time, curvature, warp, start)
	start = start or inp
	local curve = Env.shapeNames[warp] or warp
	if curve~=1 then
		--print"with EnvGen"
		local e = Env({start, inp}, {time}, warp)
		--prtable(e:prAsArray())
		if rate == 1 then
			local trig = Changed.kr(inp) + Impulse.kr(0)
			if type(time)~="number" then
				 trig = trig + Changed.kr(time)
			end
			return EnvGen.kr(e, trig);
		else
			error("VarLag.ar not working")
		end
	else
		--print"with Varlag"
		return UGen.new1(self,rate,inp,time,start)
	end
	
end
Changed = {}
function Changed.kr(inp,th)
	th = th or 0
	return BinaryOpUGen.newop(">",HPZ1.kr(inp):abs(),th)
end
function Changed.ar(inp,th)
	th = th or 0
	return BinaryOpUGen.newop(">",HPZ1.ar(inp):abs(),th)
end
PMOsc = {}
function PMOsc.ar(carfreq,modfreq,pmindex,modphase,mul,add)
	pmindex=pmindex or 0.0;modphase=modphase or 0.0;mul=mul or 1.0; add=add or 0.0;
	return SinOsc.ar(carfreq, SinOsc.ar(modfreq, modphase, pmindex),mul,add)
end
function PMOsc.kr(carfreq,modfreq,pmindex,modphase,mul,add)
	pmindex=pmindex or 0.0;modphase=modphase or 0.0;mul=mul or 1.0; add=add or 0.0;
	return SinOsc.kr(carfreq, SinOsc.kr(modfreq, modphase, pmindex),mul,add)
end
LinLin={}
function LinLin.ar( inp, srclo, srchi, dstlo, dsthi)
	inp=inp or 0.0; srclo = srclo or 0.0; srchi = srchi or 1.0; dstlo = dstlo or 1.0; dsthi = dsthi or 2.0
	local scale  = (dsthi - dstlo) / (srchi - srclo);
	local offset = dstlo - (scale * srclo);
	return MulAdd:newmuladd(inp, scale, offset)
end
function LinLin.kr( inp, srclo, srchi, dstlo, dsthi)
	inp=inp or 0.0; srclo = srclo or 0.0; srchi = srchi or 1.0; dstlo = dstlo or 1.0; dsthi = dsthi or 2.0
	local scale  = (dsthi - dstlo) / (srchi - srclo);
	--print("scale", srclo, srchi, dstlo, dsthi,scale)
	local offset = dstlo - (scale * srclo);
	return (inp * scale + offset)
end
SoundIn = {}
function SoundIn.ar(bus,mul,add)
	bus = bus or 0;mul = mul or 1; add = add or 0
	if not bus.isUGenArr and not isSimpleTable(bus) then
		return In.ar(NumOutputBuses.ir()+bus,1):madd(mul,add)
	else
		local consecutive = true
		for i=2,#bus  do
			if bus[i] ~= bus[i-1] + 1 then
				consecutive = false
				break
			end
		end
		if consecutive then
			return In.ar(NumOutputBuses.ir()+bus[1],#bus):madd(mul,add)
		else
			--multichannel expand not implemented TODO
			error("soundin multichannel not implemented")
			return In.ar(NumOutputBuses.ir()+bus):madd(mul,add)
		end
	end
end
Silent = {}
function Silent.ar(numChannels)
	numChannels = numChannels or 1
	local sig = DC.ar(0)
	if numChannels == 1 then
		return sig
	else
		return sig:dup(numChannels)
	end
end

-----------------
--specificationsArrayRef, input, freqscale = 1.0, freqoffset = 0.0, decayscale = 1.0;
Klank=UGen:new({name="Klank"})
function Klank.ar(specificationsArrayRef, input, freqscale, freqoffset,decayscale)
	freqscale =freqscale or 1.0; freqoffset =freqoffset or 0.0; decayscale = decayscale or 1.0
	return Klank:MultiNew{2,input, freqscale, freqoffset,decayscale,specificationsArrayRef}
end
--TODO mirar si flop iguala en size las rows
function Klank:init(input, freqscale, freqoffset,decayscale,arrRef)
	--print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx arrRef")
	--prtable(arrRef)
	local freqs, amps, times = unpack(arrRef)
		-- specs = [freqs,
				-- amps ?? {Array.fill(freqs.size,1.0)},
				-- times ?? {Array.fill(freqs.size,1.0)}
				-- ].flop.flat;
	amps=amps or {}
	times=times or {}
	--print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx freqs")
	--prtable(freqs)
	local specs={}
	for i,v in ipairs(freqs) do
		specs[(i-1)*3+1]=v
		specs[(i-1)*3+2]=amps[i] or 1
		specs[(i-1)*3+3]=times[i] or 1
	end
	--print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx specs")
	--prtable(specs)
	self.inputs={input, freqscale, freqoffset,decayscale,unpack(specs)}
	return self
end
DynKlank={}
function DynKlank.ar(spec, input, freqscale, freqoffset,decayscale)
	freqscale =freqscale or 1.0; freqoffset =freqoffset or 0.0; decayscale = decayscale or 1.0
	--return Mix(Ringz:MultiNew{2,input, freqscale*spec[1]+freqoffset, spec[3]*decayscale, spec[2]})
	return Mix(Ringz.ar(input, freqscale*spec[1]+freqoffset, spec[3]*decayscale, spec[2]))
end
DynKlankS={}
function DynKlankS.ar(spec, input, freqscale, freqoffset,decayscale)
	freqscale =freqscale or 1.0; freqoffset =freqoffset or 0.0; decayscale = decayscale or 1.0
	--return Ringz:MultiNew{2,input, freqscale*spec[1]+freqoffset,spec[3]*decayscale,spec[2]}
	return Ringz.ar(input, freqscale*spec[1]+freqoffset, spec[3]*decayscale, spec[2])
end
DynKlang={}
function DynKlang.ar(spec, freqscale, freqoffset)
	freqscale =freqscale or 1.0; freqoffset =freqoffset or 0.0;
	return Mix(SinOsc.ar(freqscale*spec[1]+freqoffset, spec[3], spec[2]))
end
DynKlangS={}
function DynKlangS.ar(spec, freqscale, freqoffset)
	freqscale =freqscale or 1.0; freqoffset =freqoffset or 0.0;
	--return Ringz:MultiNew{2,input, freqscale*spec[1]+freqoffset,spec[3]*decayscale,spec[2]}
	return SinOsc.ar(freqscale*spec[1]+freqoffset, spec[3], spec[2])
end
---[[
function GVerb.ar(in_a,roomsize,revtime,damping,inputbw,spread,drylevel,earlyreflevel,taillevel,maxroomsize)
	roomsize=roomsize or 10;revtime=revtime or 3;damping=damping or 0.5;inputbw=inputbw or 0.5;spread=spread or 15;drylevel=drylevel or 1;earlyreflevel=earlyreflevel or 0.7;taillevel=taillevel or 0.5;maxroomsize=maxroomsize or 300;
	return GVerb:MultiNew{2,2,in_a,roomsize,revtime,damping,inputbw,spread,drylevel,earlyreflevel,taillevel,maxroomsize}
end
FreeVerb2=MultiOutUGen:new{name='FreeVerb2'}
function FreeVerb2.ar(...)
	local   inp, in2, mix, room, damp, mul, add   = assign({ 'inp', 'in2', 'mix', 'room', 'damp', 'mul', 'add' },{ nil, nil, 0.33, 0.5, 0.5, 1.0, 0.0 },...)
	return FreeVerb2:MultiNew{2,2,inp,in2,mix,room,damp}:madd(mul,add)
end
--]]
function Select.kr(which,array)
	return Select:MultiNew{1,which,unpack(array)}
end

function Select.ar(which,array)
	return Select:MultiNew{2,which,unpack(array)}
end
DiskOut=UGen:new{name='DiskOut'}
function DiskOut.ar(bufnum,channelsArray)
	return DiskOut:MultiNew{2,bufnum,unpack(channelsArray)}
end
---[[
function DC.ar(inp)
	inp = inp or 0
	if type(inp)=="number" or (not inp.isUGenArr and not isSimpleTable(inp)) then
		return DC:MultiNew{2,1,inp}
	else
		return DC:MultiNew{2,len(inp),unpack(inp)} -- dont know
	end
end
function DC.kr(inp)
	inp = inp or 0
	if type(inp)=="number" or (not inp.isUGenArr and not isSimpleTable(inp)) then
		return DC:MultiNew{1,1,inp}
	else
		return DC:MultiNew{1,len(inp),unpack(inp)} -- dont know
	end
end
--]]

---------------------------------------------
SendTrig=UGen:new{name='SendTrig'}
function SendTrig.kr(in_a,id,value)
	in_a=in_a or 0;id=id or 0;value=value or 0;
	return SendTrig:MultiNew{1,in_a,id,value}
end
function SendTrig.ar(in_a,id,value)
	in_a=in_a or 0;id=id or 0;value=value or 0;
	return SendTrig:MultiNew{2,in_a,id,value}
end
function SendTrig:init(...)
	self.inputs={...}
	_BUILDSYNTHDEF.outputugens=_BUILDSYNTHDEF.outputugens or {}
	_BUILDSYNTHDEF.outputugens[#_BUILDSYNTHDEF.outputugens+1]=self
	return 0
end
SendReply=SendTrig:new{name='SendReply'}
function SendReply.kr(trig, cmdName, values, replyID)
	trig = trig or 0.0;cmdName = cmdName or '/reply';replyID = replyID or -1
	local ascii = {cmdName:byte(1,-1)}
	return SendReply:MultiNew(concatTables(concatTables({1,trig, replyID,#ascii},ascii),values))
end
---------------------------
function SendReply.ar(trig, cmdName, values, replyID)
	trig = trig or 0.0;cmdName = cmdName or '/reply';replyID = replyID or -1
	local ascii = {cmdName:byte(1,-1)}
	return SendReply:MultiNew(concatTables(concatTables({2,trig, replyID,#ascii},ascii),values))
end
Poll=SendTrig:new{name='Poll'}
function Poll.kr(trig, inp, label, replyID)
	trig = trig or 0.0;label = label or '/poll';replyID = replyID or -1
	local ascii = {label:byte(1,-1)}
	return Poll:MultiNew(concatTables({1,trig,inp, replyID,#ascii},ascii))
end
function Poll.ar(trig, inp, label, replyID)
	trig = trig or 0.0;label = label or '/poll';replyID = replyID or -1
	local ascii = {label:byte(1,-1)}
	return Poll:MultiNew(concatTables({2,trig,inp, replyID,#ascii},ascii))
end

SendPeakRMS=SendTrig:new{name='SendPeakRMS'}
function SendPeakRMS.kr(sig,replyRate,peakLag,cmdName,replyID)
	replyRate=replyRate or 20;peakLag=peakLag or 3;cmdName=cmdName or '/reply';replyID=replyID or -1;
	local ascii = {cmdName:byte(1,-1)}
	return SendPeakRMS:MultiNew(concatTables({1,replyRate,peakLag,replyID,#sig},sig,#ascii,ascii))
end
function SendPeakRMS.ar(sig,replyRate,peakLag,cmdName,replyID)
	replyRate=replyRate or 20;peakLag=peakLag or 3;cmdName=cmdName or '/reply';replyID=replyID or -1;
	local ascii = {cmdName:byte(1,-1)}
	return SendPeakRMS:MultiNew(concatTables({2,replyRate,peakLag,replyID,#sig},sig,#ascii,ascii))
end

DetectSilence=SendTrig:new{name='DetectSilence'}
function DetectSilence.kr(in_a,amp,time,doneAction)
	in_a=in_a or 0;amp=amp or 0.0001;time=time or 0.1;doneAction=doneAction or 0;
	return DetectSilence:MultiNew{1,in_a,amp,time,doneAction}
end
function DetectSilence.ar(in_a,amp,time,doneAction)
	in_a=in_a or 0;amp=amp or 0.0001;time=time or 0.1;doneAction=doneAction or 0;
	return DetectSilence:MultiNew{2,in_a,amp,time,doneAction}
end
function FreeOnSilence(a)
	return DetectSilence.ar(a,nil,nil,2)
end
---------In
In=MultiOutUGen:new{name='In'}
function In.kr(bus,numChannels)
	bus=bus or 0;numChannels=numChannels or 1;
	return In:MultiNew{1,numChannels,bus}
end
function In.ar(bus,numChannels)
	bus=bus or 0;numChannels=numChannels or 1;
	return In:MultiNew{2,numChannels,bus}
end
function InFeedback.ar(...)
	local   bus, numChannels   = assign({ 'bus', 'numChannels' },{ 0, 1 },...)
	return InFeedback:MultiNew{2,numChannels,bus}
end
SoundOut = {}
function SoundOut.ar(bus,numChannels)
	assert(bus + numChannels <= _run_options.SC_NOUTS)
	return Out.ar(bus, numChannels)
end
LocalIn=MultiOutUGen:new{name='LocalIn'}
function LocalIn.kr(numChannels,default)
	numChannels=numChannels or 1;default = default or 0;
	local alldefaults = {}
	for i=1,numChannels do
		alldefaults[i] = WrapAtUG(default,i)
	end
	return LocalIn:MultiNew{1,numChannels,unpack(alldefaults)}
end
function LocalIn.ar(numChannels,default)
	numChannels=numChannels or 1;default = default or 0;
	local alldefaults = {}
	for i=1,numChannels do
		alldefaults[i] = WrapAtUG(default,i)
	end
	return LocalIn:MultiNew{2,numChannels,unpack(alldefaults)}
end
-- dont work with assign because first arg can be a table
LocalOut=Out:new{name='LocalOut'}
function LocalOut.ar(channels)
	return LocalOut:donew(2,channels)
end
function LocalOut.kr(channels)
	return LocalOut:donew(1,channels)
end

-----------Pan2
Pan2=MultiOutUGen:new{name="Pan2"}
function Pan2.ar(inp,pos,level)
	inp=inp or 0;pos=pos or 0;level=level or 1
	return Pan2:MultiNew{2,2,inp,pos,level}
end
function Pan2.kr(inp,pos,level)
	inp=inp or 0;pos=pos or 0;level=level or 1
	return Pan2:MultiNew{1,2,inp,pos,level}
end
function LinPan2.ar(inp,pos,level)
	inp=inp or 0;pos=pos or 0;level=level or 1
	return LinPan2:MultiNew{2,2,inp,pos,level}
end
function LinPan2.kr(inp,pos,level)
	inp=inp or 0;pos=pos or 0;level=level or 1
	return LinPan2:MultiNew{1,2,inp,pos,level}
end
-- function Pan2:init(...)
	-- self.inputs={...}
	-- return self:initOutputs(2)
-- end
Balance2=MultiOutUGen:new{name='Balance2'}
function Balance2.kr(left,right,pos,level)
	pos=pos or 0;level=level or 1;
	return Balance2:MultiNew{1,2,left,right,pos,level}
end
function Balance2.ar(left,right,pos,level)
	pos=pos or 0;level=level or 1;
	return Balance2:MultiNew{2,2,left,right,pos,level}
end


RecordBuf=UGen:new{name='RecordBuf'}
function RecordBuf.kr(inputArray,bufnum,offset,recLevel,preLevel,run,loop,trigger,doneAction)
	bufnum=bufnum or 0;offset=offset or 0;recLevel=recLevel or 1;preLevel=preLevel or 0;run=run or 1;loop=loop or 1;trigger=trigger or 1;doneAction=doneAction or 0;
	return RecordBuf:MultiNew{1,bufnum,offset,recLevel,preLevel,run,loop,trigger,doneAction,unpack(inputArray)}
end

function RecordBuf.ar(inputArray,bufnum,offset,recLevel,preLevel,run,loop,trigger,doneAction)
	bufnum=bufnum or 0;offset=offset or 0;recLevel=recLevel or 1;preLevel=preLevel or 0;run=run or 1;loop=loop or 1;trigger=trigger or 1;doneAction=doneAction or 0;
	return RecordBuf:MultiNew{2,bufnum,offset,recLevel,preLevel,run,loop,trigger,doneAction,unpack(inputArray)}
end
MaxLocalBufs=UGen:new{name='MaxLocalBufs'}
function MaxLocalBufs.ir()
		return MaxLocalBufs:MultiNew{0, 0};
end
function MaxLocalBufs:increment()
		self.inputs[1] = self.inputs[1] + 1;
end
LocalBuf=UGen:new{name='LocalBuf'}
function LocalBuf.create(samp,chan)
	samp = samp or 1;chan = chan or 1
	return LocalBuf:MultiNew{0,chan,samp}
end
function LocalBuf:init(a,b)
	--prtable{...}
		local maxLocalBufs = _BUILDSYNTHDEF.maxLocalBufs;
		if maxLocalBufs==nil then
			maxLocalBufs = MaxLocalBufs.ir();
			_BUILDSYNTHDEF.maxLocalBufs = maxLocalBufs;
		end
		maxLocalBufs:increment();
		self.inputs={a,b,maxLocalBufs}
		return self
end

function PackFFT.kr(chain, bufsize, magsphases, frombin, tobin, zeroothers)
	frombin = frombin or 0;tobin = tobin or #magsphases/2;zeroothers = zeroothers or 0
	--^this.multiNewList(['control', chain, bufsize, frombin, tobin, zeroothers, magsphases.size] ++ magsphases.asArray)
	return PackFFT:MultiNew(concatTables({1,chain,bufsize, frombin, tobin, zeroothers,#magsphases},magsphases))
end

LFPulse.signalRange="unipolar"
MouseX.signalRange="unipolar"
MouseY.signalRange="unipolar"
MouseButton.signalRange="unipolar"
------------pseudo ugens
Splay=UGen:new{name='Splay'}
function Splay.kr(...)
	local   inArray, spread, level, center, levelComp   = assign({ 'inArray', 'spread', 'level', 'center', 'levelComp' },{ nil, 1, 1, 0.0, true },...)
	return Splay:MultiNew({1,spread,level,center,levelComp}..TA(inArray))
end
function Splay.ar(...)
	local   inArray, spread, level, center, levelComp   = assign({ 'inArray', 'spread', 'level', 'center', 'levelComp' },{ nil, 1, 1, 0.0, true },...)
	return Splay:MultiNew(concatTables({2,spread,level,center,levelComp},inArray))
end
function Splay:new1(rate,spread,level,center,levelComp,...)
	local inArray = {...}
	local n = math.max(2, #inArray);
	local n1 = n - 1;
	local positions = (TA():series(n,0,1) * (2 / n1) - 1) * spread + center;
	
	if levelComp then
		if(rate == 2) then
			level = level * math.sqrt(1/n)
		else
			level = level / n
		end
	end
	--TODO care about kr but what for?
	return Mix(Pan2.ar(inArray, positions)) * level;
end
NTube=UGen:new{name='NTube'}
function NTube.ar(input,lossarray,karray,delaylengtharray,mul,add)
	input=input or 0;lossarray=lossarray or 1;mul=mul or 1;add=add or 0;
	--local lossarrayfix = (type(lossarray)=="table" and lossarray.isRef) and lossarray or TA():Fill(#delaylengtharray + 1,lossarray)
	local lossarrayfix = lossarray
	--local allargs= TA(lossarrayfix)..TA(karray)..TA(delaylengtharray);
	local allargs= concatTables(lossarrayfix,karray,delaylengtharray);
	--prtable("karray",delaylengtharray)
	return NTube:MultiNew{2,input,unpack(allargs)}:madd(mul,add)
end

----------------------
---[[
Gendy1=UGen:new{name='Gendy1'}
function Gendy1.kr(...)
	local ampdist,durdist,adparam,ddparam,minfreq,maxfreq,ampscale,durscale,initCPs,knum,mul,add = assign({"ampdist","durdist","adparam","ddparam","minfreq","maxfreq","ampscale","durscale","initCPs","knum","mul","add"},
	{1,1,1,1,20,1000,0.5,0.5,12,nil,1,0},...)
	--ampdist=ampdist or 1;durdist=durdist or 1;adparam=adparam or 1;ddparam=ddparam or 1;minfreq=minfreq or 20;maxfreq=maxfreq or 1000;ampscale=ampscale or 0.5;durscale=durscale or 0.5;initCPs=initCPs or 12;mul=mul or 1;add=add or 0;
	return Gendy1:MultiNew{1,ampdist,durdist,adparam,ddparam,minfreq,maxfreq,ampscale,durscale,initCPs,knum or initCPs}:madd(mul,add)
end
function Gendy1.ar(ampdist,durdist,adparam,ddparam,minfreq,maxfreq,ampscale,durscale,initCPs,knum,mul,add)
	ampdist=ampdist or 1;durdist=durdist or 1;adparam=adparam or 1;ddparam=ddparam or 1;minfreq=minfreq or 440;maxfreq=maxfreq or 660;ampscale=ampscale or 0.5;durscale=durscale or 0.5;initCPs=initCPs or 12;mul=mul or 1;add=add or 0;
	return Gendy1:MultiNew{2,ampdist,durdist,adparam,ddparam,minfreq,maxfreq,ampscale,durscale,initCPs,knum or initCPs}:madd(mul,add)
end
--]]
-----------------------


function Tartini.kr(inp,threshold,n,k,overlap,smallCutoff)
	inp=inp or 0;threshold=threshold or 0.93;n=n or 2048;k=k or 0;overlap=overlap or 1024;smallCutoff=smallCutoff or 0.5;
	return Tartini:MultiNew{1,2,inp,threshold,n,k,overlap,smallCutoff}
end
function Pitch.kr(...)
	local   inp, initFreq, minFreq, maxFreq, execFreq, maxBinsPerOctave, median, ampThreshold, peakThreshold, downSample, clar   = assign({ 'inp', 'initFreq', 'minFreq', 'maxFreq', 'execFreq', 'maxBinsPerOctave', 'median', 'ampThreshold', 'peakThreshold', 'downSample', 'clar' },{ 0.0, 440.0, 60.0, 4000.0, 100.0, 16, 1, 0.01, 0.5, 1, 0 },...)
	return Pitch:MultiNew{1,2,inp,initFreq,minFreq,maxFreq,execFreq,maxBinsPerOctave,median,ampThreshold,peakThreshold,downSample,clar}
end

StereoConvolution2L=MultiOutUGen:new{name='StereoConvolution2L'}
function StereoConvolution2L.ar(...)
	local   inp, kernelL, kernelR, trigger, framesize, crossfade, mul, add   = assign({ 'inp', 'kernelL', 'kernelR', 'trigger', 'framesize', 'crossfade', 'mul', 'add' },{ nil, nil, nil, 0, 2048, 1, 1.0, 0.0 },...)
	return StereoConvolution2L:MultiNew{2,2,inp,kernelL,kernelR,trigger,framesize,crossfade}:madd(mul,add)
end

Demand=MultiOutUGen:new{name='Demand'}
function Demand.kr(trig,reset,demandUGens)
	--local ddd = {1,#demandUGens,trig,reset}..TA(demandUGens)
	--prtable("zzzz",ddd,demandUGens)
		--return Demand:MultiNew({1,#demandUGens,trig,reset}..TA(demandUGens))
		return Demand:MultiNew{1,#demandUGens,trig,reset,unpack(demandUGens)}
end
function Demand.ar(trig,reset,demandUGens)
		return Demand:MultiNew({2,#demandUGens,trig,reset}..TA(demandUGens))
end

BeatTrack=MultiOutUGen:new{name='BeatTrack'}
function BeatTrack.kr(...)
	local   chain, lock   = assign({ 'chain', 'lock' },{ nil, 0 },...)
	return BeatTrack:MultiNew{1,4,chain,lock}
end
MFCC=MultiOutUGen:new{name='MFCC'}
function MFCC.kr(...)
	local   chain, numcoeff   = assign({ 'chain', 'numcoeff' },{ nil, 13 },...)
	return MFCC:MultiNew{1,numcoeff,chain,numcoeff}
end
FFTPeak=MultiOutUGen:new{name='FFTPeak'}
function FFTPeak.kr(...)
	local   buffer, freqlo, freqhi   = assign({ 'buffer', 'freqlo', 'freqhi' },{ nil, 0, 50000 },...)
	return FFTPeak:MultiNew{1,2,buffer,freqlo,freqhi}
end