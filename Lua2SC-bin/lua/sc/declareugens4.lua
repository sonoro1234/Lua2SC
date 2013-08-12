Line=UGen:new{name='Line'}
function Line.kr(...)
	local   start, endp, dur, mul, add, doneAction   = assign({ 'start', 'endp', 'dur', 'mul', 'add', 'doneAction' },{ 0.0, 1.0, 1.0, 1.0, 0.0, 0 },...)
	return Line:MultiNew{1,start,endp,dur,doneAction}:madd(mul,add)
end
function Line.ar(...)
	local   start, endp, dur, mul, add, doneAction   = assign({ 'start', 'endp', 'dur', 'mul', 'add', 'doneAction' },{ 0.0, 1.0, 1.0, 1.0, 0.0, 0 },...)
	return Line:MultiNew{2,start,endp,dur,doneAction}:madd(mul,add)
end
IEnvGen=UGen:new{name='IEnvGen'}
function IEnvGen.kr(...)
	local   envelope, index, mul, add   = assign({ 'envelope', 'index', 'mul', 'add' },{ nil, nil, 1, 0 },...)
	return IEnvGen:MultiNew{1,envelope,index}:madd(mul,add)
end
function IEnvGen.ar(...)
	local   envelope, index, mul, add   = assign({ 'envelope', 'index', 'mul', 'add' },{ nil, nil, 1, 0 },...)
	return IEnvGen:MultiNew{2,envelope,index}:madd(mul,add)
end
ListTrig=UGen:new{name='ListTrig'}
function ListTrig.kr(...)
	local   bufnum, reset, offset, numframes   = assign({ 'bufnum', 'reset', 'offset', 'numframes' },{ 0, 0, 0, nil },...)
	return ListTrig:MultiNew{1,bufnum,reset,offset,numframes}
end
GendyI=UGen:new{name='GendyI'}
function GendyI.kr(...)
	local   ampdist, durdist, adparam, ddparam, minfreq, maxfreq, ampscale, durscale, initCPs, knum, interpolation, mul, add   = assign({ 'ampdist', 'durdist', 'adparam', 'ddparam', 'minfreq', 'maxfreq', 'ampscale', 'durscale', 'initCPs', 'knum', 'interpolation', 'mul', 'add' },{ 1, 1, 1.0, 1.0, 20, 1000, 0.5, 0.5, 12, nil, 0, 1.0, 0.0 },...)
	return GendyI:MultiNew{1,ampdist,durdist,adparam,ddparam,minfreq,maxfreq,ampscale,durscale,initCPs,knum,interpolation}:madd(mul,add)
end
function GendyI.ar(...)
	local   ampdist, durdist, adparam, ddparam, minfreq, maxfreq, ampscale, durscale, initCPs, knum, interpolation, mul, add   = assign({ 'ampdist', 'durdist', 'adparam', 'ddparam', 'minfreq', 'maxfreq', 'ampscale', 'durscale', 'initCPs', 'knum', 'interpolation', 'mul', 'add' },{ 1, 1, 1.0, 1.0, 440, 660, 0.5, 0.5, 12, nil, 0, 1.0, 0.0 },...)
	return GendyI:MultiNew{2,ampdist,durdist,adparam,ddparam,minfreq,maxfreq,ampscale,durscale,initCPs,knum,interpolation}:madd(mul,add)
end
DFM1=UGen:new{name='DFM1'}
function DFM1.ar(...)
	local   inp, freq, res, inputgain, type, noiselevel, mul, add   = assign({ 'inp', 'freq', 'res', 'inputgain', 'type', 'noiselevel', 'mul', 'add' },{ nil, 1000.0, 0.1, 1.0, 0.0, 0.0003, 1.0, 0.0 },...)
	return DFM1:MultiNew{2,inp,freq,res,inputgain,type,noiselevel}:madd(mul,add)
end
AbstractOut=Out:new{name='AbstractOut'}
function AbstractOut.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return AbstractOut:donew(2,maxSize)
end
Logistic=UGen:new{name='Logistic'}
function Logistic.kr(...)
	local   chaosParam, freq, init, mul, add   = assign({ 'chaosParam', 'freq', 'init', 'mul', 'add' },{ 3.0, 1000.0, 0.5, 1.0, 0.0 },...)
	return Logistic:MultiNew{1,chaosParam,freq,init}:madd(mul,add)
end
function Logistic.ar(...)
	local   chaosParam, freq, init, mul, add   = assign({ 'chaosParam', 'freq', 'init', 'mul', 'add' },{ 3.0, 1000.0, 0.5, 1.0, 0.0 },...)
	return Logistic:MultiNew{2,chaosParam,freq,init}:madd(mul,add)
end
DWGBowedTor=UGen:new{name='DWGBowedTor'}
function DWGBowedTor.ar(...)
	local   freq, velb, force, gate, pos, release, c1, c3, impZ, fB, mistune, c1tor, c3tor, iZtor   = assign({ 'freq', 'velb', 'force', 'gate', 'pos', 'release', 'c1', 'c3', 'impZ', 'fB', 'mistune', 'c1tor', 'c3tor', 'iZtor' },{ 440, 0.5, 1, 1, 0.14, 0.1, 1, 3, 0.55, 2, 5.2, 1, 3000, 1.8 },...)
	return DWGBowedTor:MultiNew{2,freq,velb,force,gate,pos,release,c1,c3,impZ,fB,mistune,c1tor,c3tor,iZtor}
end
LinRand=UGen:new{name='LinRand'}
function LinRand.create(...)
	local   lo, hi, minmax   = assign({ 'lo', 'hi', 'minmax' },{ 0.0, 1.0, 0 },...)
	return LinRand:MultiNew{0,lo,hi,minmax}
end
KeyState=UGen:new{name='KeyState'}
function KeyState.kr(...)
	local   keycode, minval, maxval, lag   = assign({ 'keycode', 'minval', 'maxval', 'lag' },{ 0, 0, 1, 0.2 },...)
	return KeyState:MultiNew{1,keycode,minval,maxval,lag}
end
OSFold8=UGen:new{name='OSFold8'}
function OSFold8.ar(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ nil, nil, nil },...)
	return OSFold8:MultiNew{2,inp,lo,hi}
end
PitchShift=UGen:new{name='PitchShift'}
function PitchShift.ar(...)
	local   inp, windowSize, pitchRatio, pitchDispersion, timeDispersion, mul, add   = assign({ 'inp', 'windowSize', 'pitchRatio', 'pitchDispersion', 'timeDispersion', 'mul', 'add' },{ 0.0, 0.2, 1.0, 0.0, 0.0, 1.0, 0.0 },...)
	return PitchShift:MultiNew{2,inp,windowSize,pitchRatio,pitchDispersion,timeDispersion}:madd(mul,add)
end
LTI=UGen:new{name='LTI'}
function LTI.ar(...)
	local   input, bufnuma, bufnumb, mul, add   = assign({ 'input', 'bufnuma', 'bufnumb', 'mul', 'add' },{ nil, 0, 1, 1.0, 0.0 },...)
	return LTI:MultiNew{2,input,bufnuma,bufnumb}:madd(mul,add)
end
ExpRand=UGen:new{name='ExpRand'}
function ExpRand.create(...)
	local   lo, hi   = assign({ 'lo', 'hi' },{ 0.01, 1.0 },...)
	return ExpRand:MultiNew{0,lo,hi}
end
MatchingPResynth=UGen:new{name='MatchingPResynth'}
function MatchingPResynth.kr(...)
	local   dict, method, trigger, residual, activs   = assign({ 'dict', 'method', 'trigger', 'residual', 'activs' },{ nil, 0, nil, 0, {  } },...)
	return MatchingPResynth:MultiNew{1,dict,method,trigger,residual,activs}
end
function MatchingPResynth.ar(...)
	local   dict, method, trigger, residual, activs   = assign({ 'dict', 'method', 'trigger', 'residual', 'activs' },{ nil, 0, nil, 0, {  } },...)
	return MatchingPResynth:MultiNew{2,dict,method,trigger,residual,activs}
end
PV_XFade=UGen:new{name='PV_XFade'}
function PV_XFade.create(...)
	local   bufferA, bufferB, fade   = assign({ 'bufferA', 'bufferB', 'fade' },{ nil, nil, 0.0 },...)
	return PV_XFade:MultiNew{1,bufferA,bufferB,fade}
end
Gammatone=UGen:new{name='Gammatone'}
function Gammatone.ar(...)
	local   input, centrefrequency, bandwidth, mul, add   = assign({ 'input', 'centrefrequency', 'bandwidth', 'mul', 'add' },{ nil, 440.0, 200.0, 1.0, 0.0 },...)
	return Gammatone:MultiNew{2,input,centrefrequency,bandwidth}:madd(mul,add)
end
AtsUGen=UGen:new{name='AtsUGen'}
function AtsUGen.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return AtsUGen:MultiNew{2,maxSize}
end
WeaklyNonlinear=UGen:new{name='WeaklyNonlinear'}
function WeaklyNonlinear.ar(...)
	local   input, reset, ratex, ratey, freq, initx, inity, alpha, xexponent, beta, yexponent, mul, add   = assign({ 'input', 'reset', 'ratex', 'ratey', 'freq', 'initx', 'inity', 'alpha', 'xexponent', 'beta', 'yexponent', 'mul', 'add' },{ nil, 0, 1, 1, 440, 0, 0, 0, 0, 0, 0, 1.0, 0.0 },...)
	return WeaklyNonlinear:MultiNew{2,input,reset,ratex,ratey,freq,initx,inity,alpha,xexponent,beta,yexponent}:madd(mul,add)
end
Compander=UGen:new{name='Compander'}
function Compander.ar(...)
	local   inp, control, thresh, slopeBelow, slopeAbove, clampTime, relaxTime, mul, add   = assign({ 'inp', 'control', 'thresh', 'slopeBelow', 'slopeAbove', 'clampTime', 'relaxTime', 'mul', 'add' },{ 0.0, 0.0, 0.5, 1.0, 1.0, 0.01, 0.1, 1.0, 0.0 },...)
	return Compander:MultiNew{2,inp,control,thresh,slopeBelow,slopeAbove,clampTime,relaxTime}:madd(mul,add)
end
PSinGrain=UGen:new{name='PSinGrain'}
function PSinGrain.ar(...)
	local   freq, dur, amp   = assign({ 'freq', 'dur', 'amp' },{ 440.0, 0.2, 1.0 },...)
	return PSinGrain:MultiNew{2,freq,dur,amp}
end
VOSIM=UGen:new{name='VOSIM'}
function VOSIM.ar(...)
	local   trig, freq, nCycles, decay, mul, add   = assign({ 'trig', 'freq', 'nCycles', 'decay', 'mul', 'add' },{ 0.1, 400.0, 1, 0.9, 1.0, 0.0 },...)
	return VOSIM:MultiNew{2,trig,freq,nCycles,decay}:madd(mul,add)
end
Pause=UGen:new{name='Pause'}
function Pause.kr(...)
	local   gate, id   = assign({ 'gate', 'id' },{ nil, nil },...)
	return Pause:MultiNew{1,gate,id}
end
FreeSelf=UGen:new{name='FreeSelf'}
function FreeSelf.kr(...)
	local   inp   = assign({ 'inp' },{ nil },...)
	return FreeSelf:MultiNew{1,inp}
end
StkShakers=UGen:new{name='StkShakers'}
function StkShakers.kr(...)
	local   instr, energy, decay, objects, resfreq, mul, add   = assign({ 'instr', 'energy', 'decay', 'objects', 'resfreq', 'mul', 'add' },{ 0, 64, 64, 64, 64, 1.0, 0.0 },...)
	return StkShakers:MultiNew{1,instr,energy,decay,objects,resfreq}:madd(mul,add)
end
function StkShakers.ar(...)
	local   instr, energy, decay, objects, resfreq, mul, add   = assign({ 'instr', 'energy', 'decay', 'objects', 'resfreq', 'mul', 'add' },{ 0, 64, 64, 64, 64, 1.0, 0.0 },...)
	return StkShakers:MultiNew{2,instr,energy,decay,objects,resfreq}:madd(mul,add)
end
MoogVCF=UGen:new{name='MoogVCF'}
function MoogVCF.ar(...)
	local   inp, fco, res, mul, add   = assign({ 'inp', 'fco', 'res', 'mul', 'add' },{ nil, nil, nil, 1, 0 },...)
	return MoogVCF:MultiNew{2,inp,fco,res}:madd(mul,add)
end
NL=UGen:new{name='NL'}
function NL.ar(...)
	local   input, bufnuma, bufnumb, guard1, guard2, mul, add   = assign({ 'input', 'bufnuma', 'bufnumb', 'guard1', 'guard2', 'mul', 'add' },{ nil, 0, 1, 1000.0, 100.0, 1.0, 0.0 },...)
	return NL:MultiNew{2,input,bufnuma,bufnumb,guard1,guard2}:madd(mul,add)
end
GravityGrid=UGen:new{name='GravityGrid'}
function GravityGrid.ar(...)
	local   reset, rate, newx, newy, bufnum, mul, add   = assign({ 'reset', 'rate', 'newx', 'newy', 'bufnum', 'mul', 'add' },{ 0, 0.1, 0.0, 0.0, nil, 1.0, 0.0 },...)
	return GravityGrid:MultiNew{2,reset,rate,newx,newy,bufnum}:madd(mul,add)
end
SpecPcile=UGen:new{name='SpecPcile'}
function SpecPcile.kr(...)
	local   buffer, fraction, interpolate   = assign({ 'buffer', 'fraction', 'interpolate' },{ nil, 0.5, 0 },...)
	return SpecPcile:MultiNew{1,buffer,fraction,interpolate}
end
ScopeOut=UGen:new{name='ScopeOut'}
function ScopeOut.kr(...)
	local   inputArray, bufnum   = assign({ 'inputArray', 'bufnum' },{ nil, 0 },...)
	return ScopeOut:MultiNew{1,inputArray,bufnum}
end
function ScopeOut.ar(...)
	local   inputArray, bufnum   = assign({ 'inputArray', 'bufnum' },{ nil, 0 },...)
	return ScopeOut:MultiNew{2,inputArray,bufnum}
end
FFTComplexDev=UGen:new{name='FFTComplexDev'}
function FFTComplexDev.kr(...)
	local   buffer, rectify, powthresh   = assign({ 'buffer', 'rectify', 'powthresh' },{ nil, 0, 0.1 },...)
	return FFTComplexDev:MultiNew{1,buffer,rectify,powthresh}
end
SoftClipper8=UGen:new{name='SoftClipper8'}
function SoftClipper8.ar(...)
	local   inp   = assign({ 'inp' },{ nil },...)
	return SoftClipper8:MultiNew{2,inp}
end
ToggleFF=UGen:new{name='ToggleFF'}
function ToggleFF.kr(...)
	local   trig   = assign({ 'trig' },{ 0.0 },...)
	return ToggleFF:MultiNew{1,trig}
end
function ToggleFF.ar(...)
	local   trig   = assign({ 'trig' },{ 0.0 },...)
	return ToggleFF:MultiNew{2,trig}
end
PrintVal=UGen:new{name='PrintVal'}
function PrintVal.kr(...)
	local   inp, numblocks, id   = assign({ 'inp', 'numblocks', 'id' },{ nil, 100, 0 },...)
	return PrintVal:MultiNew{1,inp,numblocks,id}
end
Convolution2=UGen:new{name='Convolution2'}
function Convolution2.ar(...)
	local   inp, kernel, trigger, framesize, mul, add   = assign({ 'inp', 'kernel', 'trigger', 'framesize', 'mul', 'add' },{ nil, nil, 0, 2048, 1.0, 0.0 },...)
	return Convolution2:MultiNew{2,inp,kernel,trigger,framesize}:madd(mul,add)
end
Balance=UGen:new{name='Balance'}
function Balance.ar(...)
	local   inp, test, hp, stor, mul, add   = assign({ 'inp', 'test', 'hp', 'stor', 'mul', 'add' },{ nil, nil, 10, 0, 1, 0 },...)
	return Balance:MultiNew{2,inp,test,hp,stor}:madd(mul,add)
end
MaxLocalBufs=UGen:new{name='MaxLocalBufs'}
function MaxLocalBufs.create(...)
		return MaxLocalBufs:MultiNew{0}
end
ScopeOut2=UGen:new{name='ScopeOut2'}
function ScopeOut2.kr(...)
	local   inputArray, scopeNum, maxFrames, scopeFrames   = assign({ 'inputArray', 'scopeNum', 'maxFrames', 'scopeFrames' },{ nil, 0, 4096, nil },...)
	return ScopeOut2:MultiNew{1,inputArray,scopeNum,maxFrames,scopeFrames}
end
function ScopeOut2.ar(...)
	local   inputArray, scopeNum, maxFrames, scopeFrames   = assign({ 'inputArray', 'scopeNum', 'maxFrames', 'scopeFrames' },{ nil, 0, 4096, nil },...)
	return ScopeOut2:MultiNew{2,inputArray,scopeNum,maxFrames,scopeFrames}
end
GaussTrig=UGen:new{name='GaussTrig'}
function GaussTrig.kr(...)
	local   freq, dev, mul, add   = assign({ 'freq', 'dev', 'mul', 'add' },{ 440.0, 0.3, 1.0, 0.0 },...)
	return GaussTrig:MultiNew{1,freq,dev}:madd(mul,add)
end
function GaussTrig.ar(...)
	local   freq, dev, mul, add   = assign({ 'freq', 'dev', 'mul', 'add' },{ 440.0, 0.3, 1.0, 0.0 },...)
	return GaussTrig:MultiNew{2,freq,dev}:madd(mul,add)
end
MarkovSynth=UGen:new{name='MarkovSynth'}
function MarkovSynth.ar(...)
	local   inp, isRecording, waitTime, tableSize   = assign({ 'inp', 'isRecording', 'waitTime', 'tableSize' },{ 0.0, 1, 2, 10 },...)
	return MarkovSynth:MultiNew{2,inp,isRecording,waitTime,tableSize}
end
Pulse=UGen:new{name='Pulse'}
function Pulse.kr(...)
	local   freq, width, mul, add   = assign({ 'freq', 'width', 'mul', 'add' },{ 440.0, 0.5, 1.0, 0.0 },...)
	return Pulse:MultiNew{1,freq,width}:madd(mul,add)
end
function Pulse.ar(...)
	local   freq, width, mul, add   = assign({ 'freq', 'width', 'mul', 'add' },{ 440.0, 0.5, 1.0, 0.0 },...)
	return Pulse:MultiNew{2,freq,width}:madd(mul,add)
end
FFTPhaseDev=UGen:new{name='FFTPhaseDev'}
function FFTPhaseDev.kr(...)
	local   buffer, weight, powthresh   = assign({ 'buffer', 'weight', 'powthresh' },{ nil, 0, 0.1 },...)
	return FFTPhaseDev:MultiNew{1,buffer,weight,powthresh}
end
Gendy2=UGen:new{name='Gendy2'}
function Gendy2.kr(...)
	local   ampdist, durdist, adparam, ddparam, minfreq, maxfreq, ampscale, durscale, initCPs, knum, a, c, mul, add   = assign({ 'ampdist', 'durdist', 'adparam', 'ddparam', 'minfreq', 'maxfreq', 'ampscale', 'durscale', 'initCPs', 'knum', 'a', 'c', 'mul', 'add' },{ 1, 1, 1.0, 1.0, 20, 1000, 0.5, 0.5, 12, nil, 1.17, 0.31, 1.0, 0.0 },...)
	return Gendy2:MultiNew{1,ampdist,durdist,adparam,ddparam,minfreq,maxfreq,ampscale,durscale,initCPs,knum,a,c}:madd(mul,add)
end
function Gendy2.ar(...)
	local   ampdist, durdist, adparam, ddparam, minfreq, maxfreq, ampscale, durscale, initCPs, knum, a, c, mul, add   = assign({ 'ampdist', 'durdist', 'adparam', 'ddparam', 'minfreq', 'maxfreq', 'ampscale', 'durscale', 'initCPs', 'knum', 'a', 'c', 'mul', 'add' },{ 1, 1, 1.0, 1.0, 440, 660, 0.5, 0.5, 12, nil, 1.17, 0.31, 1.0, 0.0 },...)
	return Gendy2:MultiNew{2,ampdist,durdist,adparam,ddparam,minfreq,maxfreq,ampscale,durscale,initCPs,knum,a,c}:madd(mul,add)
end
PulseCount=UGen:new{name='PulseCount'}
function PulseCount.kr(...)
	local   trig, reset   = assign({ 'trig', 'reset' },{ 0.0, 0.0 },...)
	return PulseCount:MultiNew{1,trig,reset}
end
function PulseCount.ar(...)
	local   trig, reset   = assign({ 'trig', 'reset' },{ 0.0, 0.0 },...)
	return PulseCount:MultiNew{2,trig,reset}
end
Sweep=UGen:new{name='Sweep'}
function Sweep.kr(...)
	local   trig, rate   = assign({ 'trig', 'rate' },{ 0.0, 1.0 },...)
	return Sweep:MultiNew{1,trig,rate}
end
function Sweep.ar(...)
	local   trig, rate   = assign({ 'trig', 'rate' },{ 0.0, 1.0 },...)
	return Sweep:MultiNew{2,trig,rate}
end
InfoUGenBase=UGen:new{name='InfoUGenBase'}
function InfoUGenBase.ir(...)
		return InfoUGenBase:MultiNew{0}
end
SendTrig=UGen:new{name='SendTrig'}
function SendTrig.kr(...)
	local   inp, id, value   = assign({ 'inp', 'id', 'value' },{ 0.0, 0, 0.0 },...)
	return SendTrig:MultiNew{1,inp,id,value}
end
function SendTrig.ar(...)
	local   inp, id, value   = assign({ 'inp', 'id', 'value' },{ 0.0, 0, 0.0 },...)
	return SendTrig:MultiNew{2,inp,id,value}
end
LastValue=UGen:new{name='LastValue'}
function LastValue.kr(...)
	local   inp, diff   = assign({ 'inp', 'diff' },{ 0.0, 0.01 },...)
	return LastValue:MultiNew{1,inp,diff}
end
function LastValue.ar(...)
	local   inp, diff   = assign({ 'inp', 'diff' },{ 0.0, 0.01 },...)
	return LastValue:MultiNew{2,inp,diff}
end
PV_CommonMag=UGen:new{name='PV_CommonMag'}
function PV_CommonMag.create(...)
	local   bufferA, bufferB, tolerance, remove   = assign({ 'bufferA', 'bufferB', 'tolerance', 'remove' },{ nil, nil, 0.0, 0.0 },...)
	return PV_CommonMag:MultiNew{1,bufferA,bufferB,tolerance,remove}
end
FreqShift=UGen:new{name='FreqShift'}
function FreqShift.ar(...)
	local   inp, freq, phase, mul, add   = assign({ 'inp', 'freq', 'phase', 'mul', 'add' },{ nil, 0.0, 0.0, 1.0, 0.0 },...)
	return FreqShift:MultiNew{2,inp,freq,phase}:madd(mul,add)
end
CoinGate=UGen:new{name='CoinGate'}
function CoinGate.kr(...)
	local   prob, inp   = assign({ 'prob', 'inp' },{ nil, nil },...)
	return CoinGate:MultiNew{1,prob,inp}
end
function CoinGate.ar(...)
	local   prob, inp   = assign({ 'prob', 'inp' },{ nil, nil },...)
	return CoinGate:MultiNew{2,prob,inp}
end
FFTFluxPos=UGen:new{name='FFTFluxPos'}
function FFTFluxPos.kr(...)
	local   buffer, normalise   = assign({ 'buffer', 'normalise' },{ nil, 1 },...)
	return FFTFluxPos:MultiNew{1,buffer,normalise}
end
LPFVS6=UGen:new{name='LPFVS6'}
function LPFVS6.kr(...)
	local   inp, freq, slope   = assign({ 'inp', 'freq', 'slope' },{ nil, 1000, 0.5 },...)
	return LPFVS6:MultiNew{1,inp,freq,slope}
end
function LPFVS6.ar(...)
	local   inp, freq, slope   = assign({ 'inp', 'freq', 'slope' },{ nil, 1000, 0.5 },...)
	return LPFVS6:MultiNew{2,inp,freq,slope}
end
Dbrown2=UGen:new{name='Dbrown2'}
function Dbrown2.create(...)
	local   lo, hi, step, dist, length   = assign({ 'lo', 'hi', 'step', 'dist', 'length' },{ nil, nil, nil, nil, "math.huge" },...)
	return Dbrown2:MultiNew{3,lo,hi,step,dist,length}
end
CompanderD=UGen:new{name='CompanderD'}
function CompanderD.ar(...)
	local   inp, thresh, slopeBelow, slopeAbove, clampTime, relaxTime, mul, add   = assign({ 'inp', 'thresh', 'slopeBelow', 'slopeAbove', 'clampTime', 'relaxTime', 'mul', 'add' },{ 0.0, 0.5, 1.0, 1.0, 0.01, 0.01, 1.0, 0.0 },...)
	return CompanderD:MultiNew{2,inp,thresh,slopeBelow,slopeAbove,clampTime,relaxTime}:madd(mul,add)
end
MoogLadder=UGen:new{name='MoogLadder'}
function MoogLadder.kr(...)
	local   inp, ffreq, res, mul, add   = assign({ 'inp', 'ffreq', 'res', 'mul', 'add' },{ nil, 440.0, 0.0, 1.0, 0.0 },...)
	return MoogLadder:MultiNew{1,inp,ffreq,res}:madd(mul,add)
end
function MoogLadder.ar(...)
	local   inp, ffreq, res, mul, add   = assign({ 'inp', 'ffreq', 'res', 'mul', 'add' },{ nil, 440.0, 0.0, 1.0, 0.0 },...)
	return MoogLadder:MultiNew{2,inp,ffreq,res}:madd(mul,add)
end
Clipper32=UGen:new{name='Clipper32'}
function Clipper32.ar(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ nil, -0.8, 0.8 },...)
	return Clipper32:MultiNew{2,inp,lo,hi}
end
FitzHughNagumo=UGen:new{name='FitzHughNagumo'}
function FitzHughNagumo.ar(...)
	local   reset, rateu, ratew, b0, b1, initu, initw, mul, add   = assign({ 'reset', 'rateu', 'ratew', 'b0', 'b1', 'initu', 'initw', 'mul', 'add' },{ 0, 0.01, 0.01, 1, 1, 0, 0, 1.0, 0.0 },...)
	return FitzHughNagumo:MultiNew{2,reset,rateu,ratew,b0,b1,initu,initw}:madd(mul,add)
end
WrapSummer=UGen:new{name='WrapSummer'}
function WrapSummer.kr(...)
	local   trig, step, min, max, reset, resetval   = assign({ 'trig', 'step', 'min', 'max', 'reset', 'resetval' },{ 0, 1, 0, 1, 0, nil },...)
	return WrapSummer:MultiNew{1,trig,step,min,max,reset,resetval}
end
function WrapSummer.ar(...)
	local   trig, step, min, max, reset, resetval   = assign({ 'trig', 'step', 'min', 'max', 'reset', 'resetval' },{ 0, 1, 0, 1, 0, nil },...)
	return WrapSummer:MultiNew{2,trig,step,min,max,reset,resetval}
end
CheckBadValues=UGen:new{name='CheckBadValues'}
function CheckBadValues.kr(...)
	local   inp, id, post   = assign({ 'inp', 'id', 'post' },{ 0.0, 0, 2 },...)
	return CheckBadValues:MultiNew{1,inp,id,post}
end
function CheckBadValues.ar(...)
	local   inp, id, post   = assign({ 'inp', 'id', 'post' },{ 0.0, 0, 2 },...)
	return CheckBadValues:MultiNew{2,inp,id,post}
end
Hasher=UGen:new{name='Hasher'}
function Hasher.kr(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return Hasher:MultiNew{1,inp}:madd(mul,add)
end
function Hasher.ar(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return Hasher:MultiNew{2,inp}:madd(mul,add)
end
StkBlowHole=UGen:new{name='StkBlowHole'}
function StkBlowHole.kr(...)
	local   freq, reedstiffness, noisegain, tonehole, register, breathpressure, mul, add   = assign({ 'freq', 'reedstiffness', 'noisegain', 'tonehole', 'register', 'breathpressure', 'mul', 'add' },{ 440, 64, 4, 64, 11, 64, 1.0, 0.0 },...)
	return StkBlowHole:MultiNew{1,freq,reedstiffness,noisegain,tonehole,register,breathpressure}:madd(mul,add)
end
function StkBlowHole.ar(...)
	local   freq, reedstiffness, noisegain, tonehole, register, breathpressure, mul, add   = assign({ 'freq', 'reedstiffness', 'noisegain', 'tonehole', 'register', 'breathpressure', 'mul', 'add' },{ 440, 64, 20, 64, 11, 64, 1.0, 0.0 },...)
	return StkBlowHole:MultiNew{2,freq,reedstiffness,noisegain,tonehole,register,breathpressure}:madd(mul,add)
end
BufInfoUGenBase=UGen:new{name='BufInfoUGenBase'}
function BufInfoUGenBase.ir(...)
	local   bufnum   = assign({ 'bufnum' },{ nil },...)
	return BufInfoUGenBase:MultiNew{0,bufnum}
end
function BufInfoUGenBase.kr(...)
	local   bufnum   = assign({ 'bufnum' },{ nil },...)
	return BufInfoUGenBase:MultiNew{1,bufnum}
end
XFade2=UGen:new{name='XFade2'}
function XFade2.kr(...)
	local   inA, inB, pan, level   = assign({ 'inA', 'inB', 'pan', 'level' },{ nil, 0.0, 0.0, 1.0 },...)
	return XFade2:MultiNew{1,inA,inB,pan,level}
end
function XFade2.ar(...)
	local   inA, inB, pan, level   = assign({ 'inA', 'inB', 'pan', 'level' },{ nil, 0.0, 0.0, 1.0 },...)
	return XFade2:MultiNew{2,inA,inB,pan,level}
end
Latoocarfian2DN=UGen:new{name='Latoocarfian2DN'}
function Latoocarfian2DN.kr(...)
	local   minfreq, maxfreq, a, b, c, d, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'a', 'b', 'c', 'd', 'x0', 'y0', 'mul', 'add' },{ 40, 100, 1, 3, 0.5, 0.5, 0.34082301375036, -0.38270086971332, 1, 0.0 },...)
	return Latoocarfian2DN:MultiNew{1,minfreq,maxfreq,a,b,c,d,x0,y0}:madd(mul,add)
end
function Latoocarfian2DN.ar(...)
	local   minfreq, maxfreq, a, b, c, d, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'a', 'b', 'c', 'd', 'x0', 'y0', 'mul', 'add' },{ 11025, 22050, 1, 3, 0.5, 0.5, 0.34082301375036, -0.38270086971332, 1, 0.0 },...)
	return Latoocarfian2DN:MultiNew{2,minfreq,maxfreq,a,b,c,d,x0,y0}:madd(mul,add)
end
TExpRand=UGen:new{name='TExpRand'}
function TExpRand.kr(...)
	local   lo, hi, trig   = assign({ 'lo', 'hi', 'trig' },{ 0.01, 1.0, 0.0 },...)
	return TExpRand:MultiNew{1,lo,hi,trig}
end
function TExpRand.ar(...)
	local   lo, hi, trig   = assign({ 'lo', 'hi', 'trig' },{ 0.01, 1.0, 0.0 },...)
	return TExpRand:MultiNew{2,lo,hi,trig}
end
Free=UGen:new{name='Free'}
function Free.kr(...)
	local   trig, id   = assign({ 'trig', 'id' },{ nil, nil },...)
	return Free:MultiNew{1,trig,id}
end
Unpack1FFT=UGen:new{name='Unpack1FFT'}
function Unpack1FFT.create(...)
	local   chain, bufsize, binindex, whichmeasure   = assign({ 'chain', 'bufsize', 'binindex', 'whichmeasure' },{ nil, nil, nil, 0 },...)
	return Unpack1FFT:MultiNew{3,chain,bufsize,binindex,whichmeasure}
end
MCLDChaosGen=UGen:new{name='MCLDChaosGen'}
function MCLDChaosGen.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return MCLDChaosGen:MultiNew{2,maxSize}
end
SwitchDelay=UGen:new{name='SwitchDelay'}
function SwitchDelay.ar(...)
	local   inp, drylevel, wetlevel, delaytime, delayfactor, maxdelaytime, mul, add   = assign({ 'inp', 'drylevel', 'wetlevel', 'delaytime', 'delayfactor', 'maxdelaytime', 'mul', 'add' },{ nil, 1.0, 1.0, 1.0, 0.7, 20.0, 1.0, 0.0 },...)
	return SwitchDelay:MultiNew{2,inp,drylevel,wetlevel,delaytime,delayfactor,maxdelaytime}:madd(mul,add)
end
ZeroCrossing=UGen:new{name='ZeroCrossing'}
function ZeroCrossing.kr(...)
	local   inp   = assign({ 'inp' },{ 0.0 },...)
	return ZeroCrossing:MultiNew{1,inp}
end
function ZeroCrossing.ar(...)
	local   inp   = assign({ 'inp' },{ 0.0 },...)
	return ZeroCrossing:MultiNew{2,inp}
end
OSWrap8=UGen:new{name='OSWrap8'}
function OSWrap8.ar(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ nil, nil, nil },...)
	return OSWrap8:MultiNew{2,inp,lo,hi}
end
Dunique=UGen:new{name='Dunique'}
function Dunique.create(...)
	local   source   = assign({ 'source' },{ nil },...)
	return Dunique:MultiNew{2,source}
end
SensoryDissonance=UGen:new{name='SensoryDissonance'}
function SensoryDissonance.kr(...)
	local   fft, maxpeaks, peakthreshold, norm, clamp   = assign({ 'fft', 'maxpeaks', 'peakthreshold', 'norm', 'clamp' },{ nil, 100, 0.1, nil, 1.0 },...)
	return SensoryDissonance:MultiNew{1,fft,maxpeaks,peakthreshold,norm,clamp}
end
EnvFollow=UGen:new{name='EnvFollow'}
function EnvFollow.kr(...)
	local   input, decaycoeff, mul, add   = assign({ 'input', 'decaycoeff', 'mul', 'add' },{ nil, 0.99, 1.0, 0.0 },...)
	return EnvFollow:MultiNew{1,input,decaycoeff}:madd(mul,add)
end
function EnvFollow.ar(...)
	local   input, decaycoeff, mul, add   = assign({ 'input', 'decaycoeff', 'mul', 'add' },{ nil, 0.99, 1.0, 0.0 },...)
	return EnvFollow:MultiNew{2,input,decaycoeff}:madd(mul,add)
end
Meddis=UGen:new{name='Meddis'}
function Meddis.kr(...)
	local   input, mul, add   = assign({ 'input', 'mul', 'add' },{ nil, 1.0, 0.0 },...)
	return Meddis:MultiNew{1,input}:madd(mul,add)
end
function Meddis.ar(...)
	local   input, mul, add   = assign({ 'input', 'mul', 'add' },{ nil, 1.0, 0.0 },...)
	return Meddis:MultiNew{2,input}:madd(mul,add)
end
PosRatio=UGen:new{name='PosRatio'}
function PosRatio.ar(...)
	local   inp, period, thresh   = assign({ 'inp', 'period', 'thresh' },{ nil, 100, 0.1 },...)
	return PosRatio:MultiNew{2,inp,period,thresh}
end
StkMandolin=UGen:new{name='StkMandolin'}
function StkMandolin.kr(...)
	local   freq, bodysize, pickposition, stringdamping, stringdetune, aftertouch, trig, mul, add   = assign({ 'freq', 'bodysize', 'pickposition', 'stringdamping', 'stringdetune', 'aftertouch', 'trig', 'mul', 'add' },{ 220, 64, 64, 69, 10, 64, 1, 1.0, 0.0 },...)
	return StkMandolin:MultiNew{1,freq,bodysize,pickposition,stringdamping,stringdetune,aftertouch,trig}:madd(mul,add)
end
function StkMandolin.ar(...)
	local   freq, bodysize, pickposition, stringdamping, stringdetune, aftertouch, trig, mul, add   = assign({ 'freq', 'bodysize', 'pickposition', 'stringdamping', 'stringdetune', 'aftertouch', 'trig', 'mul', 'add' },{ 520, 64, 64, 69, 10, 64, 1, 1.0, 0.0 },...)
	return StkMandolin:MultiNew{2,freq,bodysize,pickposition,stringdamping,stringdetune,aftertouch,trig}:madd(mul,add)
end
StandardTrig=UGen:new{name='StandardTrig'}
function StandardTrig.kr(...)
	local   minfreq, maxfreq, k, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'k', 'x0', 'y0', 'mul', 'add' },{ 5, 10, 1.4, 4.9789799812499, 5.7473416156381, 1, 0.0 },...)
	return StandardTrig:MultiNew{1,minfreq,maxfreq,k,x0,y0}:madd(mul,add)
end
function StandardTrig.ar(...)
	local   minfreq, maxfreq, k, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'k', 'x0', 'y0', 'mul', 'add' },{ 5, 10, 1.4, 4.9789799812499, 5.7473416156381, 1, 0.0 },...)
	return StandardTrig:MultiNew{2,minfreq,maxfreq,k,x0,y0}:madd(mul,add)
end
TBetaRand=UGen:new{name='TBetaRand'}
function TBetaRand.kr(...)
	local   lo, hi, prob1, prob2, trig, mul, add   = assign({ 'lo', 'hi', 'prob1', 'prob2', 'trig', 'mul', 'add' },{ 0, 1.0, nil, nil, 0.0, 1.0, 0.0 },...)
	return TBetaRand:MultiNew{1,lo,hi,prob1,prob2,trig}:madd(mul,add)
end
function TBetaRand.ar(...)
	local   lo, hi, prob1, prob2, trig, mul, add   = assign({ 'lo', 'hi', 'prob1', 'prob2', 'trig', 'mul', 'add' },{ 0, 1.0, nil, nil, 0.0, 1.0, 0.0 },...)
	return TBetaRand:MultiNew{2,lo,hi,prob1,prob2,trig}:madd(mul,add)
end
DynKlank=UGen:new{name='DynKlank'}
function DynKlank.kr(...)
	local   specificationsArrayRef, input, freqscale, freqoffset, decayscale   = assign({ 'specificationsArrayRef', 'input', 'freqscale', 'freqoffset', 'decayscale' },{ nil, nil, 1.0, 0.0, 1.0 },...)
	return DynKlank:MultiNew{1,specificationsArrayRef,input,freqscale,freqoffset,decayscale}
end
function DynKlank.ar(...)
	local   specificationsArrayRef, input, freqscale, freqoffset, decayscale   = assign({ 'specificationsArrayRef', 'input', 'freqscale', 'freqoffset', 'decayscale' },{ nil, nil, 1.0, 0.0, 1.0 },...)
	return DynKlank:MultiNew{2,specificationsArrayRef,input,freqscale,freqoffset,decayscale}
end
HenonTrig=UGen:new{name='HenonTrig'}
function HenonTrig.kr(...)
	local   minfreq, maxfreq, a, b, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'a', 'b', 'x0', 'y0', 'mul', 'add' },{ 5, 10, 1.4, 0.3, 0.30501993062401, 0.20938865431933, 1, 0.0 },...)
	return HenonTrig:MultiNew{1,minfreq,maxfreq,a,b,x0,y0}:madd(mul,add)
end
function HenonTrig.ar(...)
	local   minfreq, maxfreq, a, b, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'a', 'b', 'x0', 'y0', 'mul', 'add' },{ 5, 10, 1.4, 0.3, 0.30501993062401, 0.20938865431933, 1, 0.0 },...)
	return HenonTrig:MultiNew{2,minfreq,maxfreq,a,b,x0,y0}:madd(mul,add)
end
MouseButton=UGen:new{name='MouseButton'}
function MouseButton.kr(...)
	local   minval, maxval, lag   = assign({ 'minval', 'maxval', 'lag' },{ 0, 1, 0.2 },...)
	return MouseButton:MultiNew{1,minval,maxval,lag}
end
Pluck=UGen:new{name='Pluck'}
function Pluck.ar(...)
	local   inp, trig, maxdelaytime, delaytime, decaytime, coef, mul, add   = assign({ 'inp', 'trig', 'maxdelaytime', 'delaytime', 'decaytime', 'coef', 'mul', 'add' },{ 0.0, 1.0, 0.2, 0.2, 1.0, 0.5, 1.0, 0.0 },...)
	return Pluck:MultiNew{2,inp,trig,maxdelaytime,delaytime,decaytime,coef}:madd(mul,add)
end
GravityGrid2=UGen:new{name='GravityGrid2'}
function GravityGrid2.ar(...)
	local   reset, rate, newx, newy, bufnum, mul, add   = assign({ 'reset', 'rate', 'newx', 'newy', 'bufnum', 'mul', 'add' },{ 0, 0.1, 0.0, 0.0, nil, 1.0, 0.0 },...)
	return GravityGrid2:MultiNew{2,reset,rate,newx,newy,bufnum}:madd(mul,add)
end
PV_MagGate=UGen:new{name='PV_MagGate'}
function PV_MagGate.create(...)
	local   buffer, thresh, remove   = assign({ 'buffer', 'thresh', 'remove' },{ nil, 1.0, 0.0 },...)
	return PV_MagGate:MultiNew{1,buffer,thresh,remove}
end
Latch=UGen:new{name='Latch'}
function Latch.kr(...)
	local   inp, trig   = assign({ 'inp', 'trig' },{ 0.0, 0.0 },...)
	return Latch:MultiNew{1,inp,trig}
end
function Latch.ar(...)
	local   inp, trig   = assign({ 'inp', 'trig' },{ 0.0, 0.0 },...)
	return Latch:MultiNew{2,inp,trig}
end
SawDPW=UGen:new{name='SawDPW'}
function SawDPW.kr(...)
	local   freq, iphase, mul, add   = assign({ 'freq', 'iphase', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return SawDPW:MultiNew{1,freq,iphase}:madd(mul,add)
end
function SawDPW.ar(...)
	local   freq, iphase, mul, add   = assign({ 'freq', 'iphase', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return SawDPW:MultiNew{2,freq,iphase}:madd(mul,add)
end
Dust2=UGen:new{name='Dust2'}
function Dust2.kr(...)
	local   density, mul, add   = assign({ 'density', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return Dust2:MultiNew{1,density}:madd(mul,add)
end
function Dust2.ar(...)
	local   density, mul, add   = assign({ 'density', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return Dust2:MultiNew{2,density}:madd(mul,add)
end
DWGPlucked=UGen:new{name='DWGPlucked'}
function DWGPlucked.ar(...)
	local   freq, amp, gate, pos, c1, c3, inp, release   = assign({ 'freq', 'amp', 'gate', 'pos', 'c1', 'c3', 'inp', 'release' },{ 440, 0.5, 1, 0.14, 1, 30, 0, 0.1 },...)
	return DWGPlucked:MultiNew{2,freq,amp,gate,pos,c1,c3,inp,release}
end
MantissaMask=UGen:new{name='MantissaMask'}
function MantissaMask.kr(...)
	local   inp, bits, mul, add   = assign({ 'inp', 'bits', 'mul', 'add' },{ 0.0, 3, 1.0, 0.0 },...)
	return MantissaMask:MultiNew{1,inp,bits}:madd(mul,add)
end
function MantissaMask.ar(...)
	local   inp, bits, mul, add   = assign({ 'inp', 'bits', 'mul', 'add' },{ 0.0, 3, 1.0, 0.0 },...)
	return MantissaMask:MultiNew{2,inp,bits}:madd(mul,add)
end
PlaneTree=UGen:new{name='PlaneTree'}
function PlaneTree.kr(...)
	local   treebuf, inp, gate   = assign({ 'treebuf', 'inp', 'gate' },{ nil, nil, 1 },...)
	return PlaneTree:MultiNew{1,treebuf,inp,gate}
end
Dust=UGen:new{name='Dust'}
function Dust.kr(...)
	local   density, mul, add   = assign({ 'density', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return Dust:MultiNew{1,density}:madd(mul,add)
end
function Dust.ar(...)
	local   density, mul, add   = assign({ 'density', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return Dust:MultiNew{2,density}:madd(mul,add)
end
TTendency=UGen:new{name='TTendency'}
function TTendency.kr(...)
	local   trigger, dist, parX, parY, parA, parB   = assign({ 'trigger', 'dist', 'parX', 'parY', 'parA', 'parB' },{ nil, 0, 0, 1, 0, 0 },...)
	return TTendency:MultiNew{1,trigger,dist,parX,parY,parA,parB}
end
function TTendency.ar(...)
	local   trigger, dist, parX, parY, parA, parB   = assign({ 'trigger', 'dist', 'parX', 'parY', 'parA', 'parB' },{ nil, 0, 0, 1, 0, 0 },...)
	return TTendency:MultiNew{2,trigger,dist,parX,parY,parA,parB}
end
SoftClipAmp8=UGen:new{name='SoftClipAmp8'}
function SoftClipAmp8.ar(...)
	local   inp, pregain, mul, add   = assign({ 'inp', 'pregain', 'mul', 'add' },{ nil, 1, 1, 0 },...)
	return SoftClipAmp8:MultiNew{2,inp,pregain}:madd(mul,add)
end
LorenzTrig=UGen:new{name='LorenzTrig'}
function LorenzTrig.kr(...)
	local   minfreq, maxfreq, s, r, b, h, x0, y0, z0, mul, add   = assign({ 'minfreq', 'maxfreq', 's', 'r', 'b', 'h', 'x0', 'y0', 'z0', 'mul', 'add' },{ 40, 100, 10, 28, 2.6666667, 0.02, 0.090879182417163, 2.97077458055, 24.282041054363, 1.0, 0.0 },...)
	return LorenzTrig:MultiNew{1,minfreq,maxfreq,s,r,b,h,x0,y0,z0}:madd(mul,add)
end
function LorenzTrig.ar(...)
	local   minfreq, maxfreq, s, r, b, h, x0, y0, z0, mul, add   = assign({ 'minfreq', 'maxfreq', 's', 'r', 'b', 'h', 'x0', 'y0', 'z0', 'mul', 'add' },{ 11025, 22050, 10, 28, 2.6666667, 0.02, 0.090879182417163, 2.97077458055, 24.282041054363, 1.0, 0.0 },...)
	return LorenzTrig:MultiNew{2,minfreq,maxfreq,s,r,b,h,x0,y0,z0}:madd(mul,add)
end
DWGBowed=UGen:new{name='DWGBowed'}
function DWGBowed.ar(...)
	local   freq, velb, force, gate, pos, release, c1, c3, impZ, fB   = assign({ 'freq', 'velb', 'force', 'gate', 'pos', 'release', 'c1', 'c3', 'impZ', 'fB' },{ 440, 0.5, 1, 1, 0.14, 0.1, 1, 3, 0.55, 2 },...)
	return DWGBowed:MultiNew{2,freq,velb,force,gate,pos,release,c1,c3,impZ,fB}
end
NTube=UGen:new{name='NTube'}
function NTube.ar(...)
	local   input, lossarray, karray, delaylengtharray, mul, add   = assign({ 'input', 'lossarray', 'karray', 'delaylengtharray', 'mul', 'add' },{ 0, 1.0, nil, nil, 1.0, 0.0, nil, nil },...)
	return NTube:MultiNew{2,input,lossarray,karray,delaylengtharray}:madd(mul,add)
end
CrossoverDistortion=UGen:new{name='CrossoverDistortion'}
function CrossoverDistortion.ar(...)
	local   inp, amp, smooth, mul, add   = assign({ 'inp', 'amp', 'smooth', 'mul', 'add' },{ nil, 0.5, 0.5, 1.0, 0 },...)
	return CrossoverDistortion:MultiNew{2,inp,amp,smooth}:madd(mul,add)
end
Onsets=UGen:new{name='Onsets'}
function Onsets.kr(...)
	local   chain, threshold, odftype, relaxtime, floor, mingap, medianspan, whtype, rawodf   = assign({ 'chain', 'threshold', 'odftype', 'relaxtime', 'floor', 'mingap', 'medianspan', 'whtype', 'rawodf' },{ nil, 0.5, 'rcomplex', 1, 0.1, 10, 11, 1, 0 },...)
	return Onsets:MultiNew{1,chain,threshold,odftype,relaxtime,floor,mingap,medianspan,whtype,rawodf}
end
LPF1=UGen:new{name='LPF1'}
function LPF1.kr(...)
	local   inp, freq   = assign({ 'inp', 'freq' },{ nil, 1000 },...)
	return LPF1:MultiNew{1,inp,freq}
end
function LPF1.ar(...)
	local   inp, freq   = assign({ 'inp', 'freq' },{ nil, 1000 },...)
	return LPF1:MultiNew{2,inp,freq}
end
WeaklyNonlinear2=UGen:new{name='WeaklyNonlinear2'}
function WeaklyNonlinear2.ar(...)
	local   input, reset, ratex, ratey, freq, initx, inity, alpha, xexponent, beta, yexponent, mul, add   = assign({ 'input', 'reset', 'ratex', 'ratey', 'freq', 'initx', 'inity', 'alpha', 'xexponent', 'beta', 'yexponent', 'mul', 'add' },{ nil, 0, 1, 1, 440, 0, 0, 0, 0, 0, 0, 1.0, 0.0 },...)
	return WeaklyNonlinear2:MultiNew{2,input,reset,ratex,ratey,freq,initx,inity,alpha,xexponent,beta,yexponent}:madd(mul,add)
end
Tap=UGen:new{name='Tap'}
function Tap.ar(...)
	local   bufnum, numChannels, delaytime   = assign({ 'bufnum', 'numChannels', 'delaytime' },{ 0, 1, 0.2, nil },...)
	return Tap:MultiNew{2,bufnum,numChannels,delaytime}
end
NRand=UGen:new{name='NRand'}
function NRand.create(...)
	local   lo, hi, n   = assign({ 'lo', 'hi', 'n' },{ 0.0, 1.0, 0 },...)
	return NRand:MultiNew{0,lo,hi,n}
end
Sieve1=UGen:new{name='Sieve1'}
function Sieve1.kr(...)
	local   bufnum, gap, alternate, mul, add   = assign({ 'bufnum', 'gap', 'alternate', 'mul', 'add' },{ nil, 2, 1, 1.0, 0.0 },...)
	return Sieve1:MultiNew{1,bufnum,gap,alternate}:madd(mul,add)
end
function Sieve1.ar(...)
	local   bufnum, gap, alternate, mul, add   = assign({ 'bufnum', 'gap', 'alternate', 'mul', 'add' },{ nil, 2, 1, 1.0, 0.0 },...)
	return Sieve1:MultiNew{2,bufnum,gap,alternate}:madd(mul,add)
end
PeakFollower=UGen:new{name='PeakFollower'}
function PeakFollower.kr(...)
	local   inp, decay   = assign({ 'inp', 'decay' },{ 0.0, 0.999 },...)
	return PeakFollower:MultiNew{1,inp,decay}
end
function PeakFollower.ar(...)
	local   inp, decay   = assign({ 'inp', 'decay' },{ 0.0, 0.999 },...)
	return PeakFollower:MultiNew{2,inp,decay}
end
FFTSlope=UGen:new{name='FFTSlope'}
function FFTSlope.kr(...)
	local   buffer   = assign({ 'buffer' },{ nil },...)
	return FFTSlope:MultiNew{1,buffer}
end
SOMAreaWr=UGen:new{name='SOMAreaWr'}
function SOMAreaWr.kr(...)
	local   bufnum, inputdata, coords, netsize, numdims, nhood, gate   = assign({ 'bufnum', 'inputdata', 'coords', 'netsize', 'numdims', 'nhood', 'gate' },{ nil, nil, nil, 10, 2, 0.5, 1 },...)
	return SOMAreaWr:MultiNew{1,bufnum,inputdata,coords,netsize,numdims,nhood,gate}
end
Clipper4=UGen:new{name='Clipper4'}
function Clipper4.ar(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ nil, -0.8, 0.8 },...)
	return Clipper4:MultiNew{2,inp,lo,hi}
end
SendPeakRMS=UGen:new{name='SendPeakRMS'}
function SendPeakRMS.kr(...)
	local   sig, replyRate, peakLag, cmdName, replyID   = assign({ 'sig', 'replyRate', 'peakLag', 'cmdName', 'replyID' },{ nil, 20.0, 3, '/reply', -1 },...)
	return SendPeakRMS:MultiNew{1,sig,replyRate,peakLag,cmdName,replyID}
end
function SendPeakRMS.ar(...)
	local   sig, replyRate, peakLag, cmdName, replyID   = assign({ 'sig', 'replyRate', 'peakLag', 'cmdName', 'replyID' },{ nil, 20.0, 3, '/reply', -1 },...)
	return SendPeakRMS:MultiNew{2,sig,replyRate,peakLag,cmdName,replyID}
end
PVSynth=UGen:new{name='PVSynth'}
function PVSynth.ar(...)
	local   pvbuffer, numBins, binStart, binSkip, filePointer, freqMul, freqAdd, mul, add   = assign({ 'pvbuffer', 'numBins', 'binStart', 'binSkip', 'filePointer', 'freqMul', 'freqAdd', 'mul', 'add' },{ nil, 0, 0, 1, 0, 1.0, 0.0, 1.0, 0.0 },...)
	return PVSynth:MultiNew{2,pvbuffer,numBins,binStart,binSkip,filePointer,freqMul,freqAdd}:madd(mul,add)
end
LPCSynth=UGen:new{name='LPCSynth'}
function LPCSynth.ar(...)
	local   buffer, signal, pointer, mul, add   = assign({ 'buffer', 'signal', 'pointer', 'mul', 'add' },{ nil, nil, nil, 1, 0 },...)
	return LPCSynth:MultiNew{2,buffer,signal,pointer}:madd(mul,add)
end
PV_Morph=UGen:new{name='PV_Morph'}
function PV_Morph.create(...)
	local   bufferA, bufferB, morph   = assign({ 'bufferA', 'bufferB', 'morph' },{ nil, nil, 0.0 },...)
	return PV_Morph:MultiNew{1,bufferA,bufferB,morph}
end
HairCell=UGen:new{name='HairCell'}
function HairCell.kr(...)
	local   input, spontaneousrate, boostrate, restorerate, loss, mul, add   = assign({ 'input', 'spontaneousrate', 'boostrate', 'restorerate', 'loss', 'mul', 'add' },{ nil, 0.0, 200.0, 1000.0, 0.99, 1.0, 0.0 },...)
	return HairCell:MultiNew{1,input,spontaneousrate,boostrate,restorerate,loss}:madd(mul,add)
end
function HairCell.ar(...)
	local   input, spontaneousrate, boostrate, restorerate, loss, mul, add   = assign({ 'input', 'spontaneousrate', 'boostrate', 'restorerate', 'loss', 'mul', 'add' },{ nil, 0.0, 200.0, 1000.0, 0.99, 1.0, 0.0 },...)
	return HairCell:MultiNew{2,input,spontaneousrate,boostrate,restorerate,loss}:madd(mul,add)
end
NeedleRect=UGen:new{name='NeedleRect'}
function NeedleRect.ar(...)
	local   rate, imgWidth, imgHeight, rectX, rectY, rectW, rectH   = assign({ 'rate', 'imgWidth', 'imgHeight', 'rectX', 'rectY', 'rectW', 'rectH' },{ 1.0, 100, 100, 0, 0, 100, 100 },...)
	return NeedleRect:MultiNew{2,rate,imgWidth,imgHeight,rectX,rectY,rectW,rectH}
end
InRect=UGen:new{name='InRect'}
function InRect.kr(...)
	local   x, y, rect   = assign({ 'x', 'y', 'rect' },{ 0.0, 0.0, nil },...)
	return InRect:MultiNew{1,x,y,rect}
end
function InRect.ar(...)
	local   x, y, rect   = assign({ 'x', 'y', 'rect' },{ 0.0, 0.0, nil },...)
	return InRect:MultiNew{2,x,y,rect}
end
Adachi=UGen:new{name='Adachi'}
function Adachi.ar(...)
	local   flip, p0, a1, bufernum   = assign({ 'flip', 'p0', 'a1', 'bufernum' },{ 231, 5000, 0.0005, 0 },...)
	return Adachi:MultiNew{2,flip,p0,a1,bufernum}
end
TermanWang=UGen:new{name='TermanWang'}
function TermanWang.ar(...)
	local   input, reset, ratex, ratey, alpha, beta, eta, initx, inity, mul, add   = assign({ 'input', 'reset', 'ratex', 'ratey', 'alpha', 'beta', 'eta', 'initx', 'inity', 'mul', 'add' },{ 0, 0, 0.01, 0.01, 1.0, 1.0, 1.0, 0, 0, 1.0, 0.0 },...)
	return TermanWang:MultiNew{2,input,reset,ratex,ratey,alpha,beta,eta,initx,inity}:madd(mul,add)
end
EnvGen=UGen:new{name='EnvGen'}
function EnvGen.kr(...)
	local   envelope, gate, levelScale, levelBias, timeScale, doneAction   = assign({ 'envelope', 'gate', 'levelScale', 'levelBias', 'timeScale', 'doneAction' },{ nil, 1.0, 1.0, 0.0, 1.0, 0 },...)
	return EnvGen:MultiNew{1,envelope,gate,levelScale,levelBias,timeScale,doneAction}
end
function EnvGen.ar(...)
	local   envelope, gate, levelScale, levelBias, timeScale, doneAction   = assign({ 'envelope', 'gate', 'levelScale', 'levelBias', 'timeScale', 'doneAction' },{ nil, 1.0, 1.0, 0.0, 1.0, 0 },...)
	return EnvGen:MultiNew{2,envelope,gate,levelScale,levelBias,timeScale,doneAction}
end
TBrownRand=UGen:new{name='TBrownRand'}
function TBrownRand.kr(...)
	local   lo, hi, dev, dist, trig, mul, add   = assign({ 'lo', 'hi', 'dev', 'dist', 'trig', 'mul', 'add' },{ 0, 1.0, 1.0, 0, 0, 1.0, 0.0 },...)
	return TBrownRand:MultiNew{1,lo,hi,dev,dist,trig}:madd(mul,add)
end
function TBrownRand.ar(...)
	local   lo, hi, dev, dist, trig, mul, add   = assign({ 'lo', 'hi', 'dev', 'dist', 'trig', 'mul', 'add' },{ 0, 1.0, 1.0, 0, 0, 1.0, 0.0 },...)
	return TBrownRand:MultiNew{2,lo,hi,dev,dist,trig}:madd(mul,add)
end
Coyote=UGen:new{name='Coyote'}
function Coyote.kr(...)
	local   inp, trackFall, slowLag, fastLag, fastMul, thresh, minDur   = assign({ 'inp', 'trackFall', 'slowLag', 'fastLag', 'fastMul', 'thresh', 'minDur' },{ 0.0, 0.2, 0.2, 0.01, 0.5, 0.05, 0.1 },...)
	return Coyote:MultiNew{1,inp,trackFall,slowLag,fastLag,fastMul,thresh,minDur}
end
TextVU=UGen:new{name='TextVU'}
function TextVU.kr(...)
	local   trig, inp, label, width, reset, ana   = assign({ 'trig', 'inp', 'label', 'width', 'reset', 'ana' },{ 2, nil, nil, 21, 0, nil },...)
	return TextVU:MultiNew{1,trig,inp,label,width,reset,ana}
end
function TextVU.ar(...)
	local   trig, inp, label, width, reset, ana   = assign({ 'trig', 'inp', 'label', 'width', 'reset', 'ana' },{ 2, nil, nil, 21, 0, nil },...)
	return TextVU:MultiNew{2,trig,inp,label,width,reset,ana}
end
AmplitudeMod=UGen:new{name='AmplitudeMod'}
function AmplitudeMod.kr(...)
	local   inp, attackTime, releaseTime, mul, add   = assign({ 'inp', 'attackTime', 'releaseTime', 'mul', 'add' },{ 0.0, 0.01, 0.01, 1.0, 0.0 },...)
	return AmplitudeMod:MultiNew{1,inp,attackTime,releaseTime}:madd(mul,add)
end
function AmplitudeMod.ar(...)
	local   inp, attackTime, releaseTime, mul, add   = assign({ 'inp', 'attackTime', 'releaseTime', 'mul', 'add' },{ 0.0, 0.01, 0.01, 1.0, 0.0 },...)
	return AmplitudeMod:MultiNew{2,inp,attackTime,releaseTime}:madd(mul,add)
end
BFDecoder=UGen:new{name='BFDecoder'}
function BFDecoder.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return BFDecoder:MultiNew{2,maxSize}
end
FFTSpread=UGen:new{name='FFTSpread'}
function FFTSpread.kr(...)
	local   buffer, centroid   = assign({ 'buffer', 'centroid' },{ nil, nil },...)
	return FFTSpread:MultiNew{1,buffer,centroid}
end
Maxamp=UGen:new{name='Maxamp'}
function Maxamp.ar(...)
	local   inp, numSamps   = assign({ 'inp', 'numSamps' },{ nil, 1000 },...)
	return Maxamp:MultiNew{2,inp,numSamps}
end
Streson=UGen:new{name='Streson'}
function Streson.kr(...)
	local   input, delayTime, res, mul, add   = assign({ 'input', 'delayTime', 'res', 'mul', 'add' },{ nil, 0.003, 0.9, 1.0, 0.0 },...)
	return Streson:MultiNew{1,input,delayTime,res}:madd(mul,add)
end
function Streson.ar(...)
	local   input, delayTime, res, mul, add   = assign({ 'input', 'delayTime', 'res', 'mul', 'add' },{ nil, 0.003, 0.9, 1.0, 0.0 },...)
	return Streson:MultiNew{2,input,delayTime,res}:madd(mul,add)
end
Instruction=UGen:new{name='Instruction'}
function Instruction.ar(...)
	local   bufnum, mul, add   = assign({ 'bufnum', 'mul', 'add' },{ 0, 1.0, 0.0 },...)
	return Instruction:MultiNew{2,bufnum}:madd(mul,add)
end
Logger=UGen:new{name='Logger'}
function Logger.kr(...)
	local   inputArray, trig, bufnum, reset   = assign({ 'inputArray', 'trig', 'bufnum', 'reset' },{ nil, 0.0, 0, 0.0 },...)
	return Logger:MultiNew{1,inputArray,trig,bufnum,reset}
end
Concat2=UGen:new{name='Concat2'}
function Concat2.ar(...)
	local   control, source, storesize, seektime, seekdur, matchlength, freezestore, zcr, lms, sc, st, randscore, threshold, mul, add   = assign({ 'control', 'source', 'storesize', 'seektime', 'seekdur', 'matchlength', 'freezestore', 'zcr', 'lms', 'sc', 'st', 'randscore', 'threshold', 'mul', 'add' },{ nil, nil, 1.0, 1.0, 1.0, 0.05, 0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.01, 1.0, 0.0 },...)
	return Concat2:MultiNew{2,control,source,storesize,seektime,seekdur,matchlength,freezestore,zcr,lms,sc,st,randscore,threshold}:madd(mul,add)
end
RunningSum=UGen:new{name='RunningSum'}
function RunningSum.kr(...)
	local   inp, numsamp   = assign({ 'inp', 'numsamp' },{ nil, 40 },...)
	return RunningSum:MultiNew{1,inp,numsamp}
end
function RunningSum.ar(...)
	local   inp, numsamp   = assign({ 'inp', 'numsamp' },{ nil, 40 },...)
	return RunningSum:MultiNew{2,inp,numsamp}
end
IIRFilter=UGen:new{name='IIRFilter'}
function IIRFilter.ar(...)
	local   inp, freq, rq, mul, add   = assign({ 'inp', 'freq', 'rq', 'mul', 'add' },{ nil, 440.0, 1.0, 1.0, 0.0 },...)
	return IIRFilter:MultiNew{2,inp,freq,rq}:madd(mul,add)
end
DPW3Tri=UGen:new{name='DPW3Tri'}
function DPW3Tri.ar(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 440.0, 1.0, 0.0 },...)
	return DPW3Tri:MultiNew{2,freq}:madd(mul,add)
end
LPCAnalyzer=UGen:new{name='LPCAnalyzer'}
function LPCAnalyzer.ar(...)
	local   input, source, n, p, testE, delta, windowtype, mul, add   = assign({ 'input', 'source', 'n', 'p', 'testE', 'delta', 'windowtype', 'mul', 'add' },{ 0, 0.01, 256, 10, 0, 0.999, 0, 1.0, 0.0 },...)
	return LPCAnalyzer:MultiNew{2,input,source,n,p,testE,delta,windowtype}:madd(mul,add)
end
StkBeeThree=UGen:new{name='StkBeeThree'}
function StkBeeThree.kr(...)
	local   freq, op4gain, op3gain, lfospeed, lfodepth, adsrtarget, trig, mul, add   = assign({ 'freq', 'op4gain', 'op3gain', 'lfospeed', 'lfodepth', 'adsrtarget', 'trig', 'mul', 'add' },{ 440, 10, 20, 64, 0, 64, 1, 1.0, 0.0 },...)
	return StkBeeThree:MultiNew{1,freq,op4gain,op3gain,lfospeed,lfodepth,adsrtarget,trig}:madd(mul,add)
end
function StkBeeThree.ar(...)
	local   freq, op4gain, op3gain, lfospeed, lfodepth, adsrtarget, trig, mul, add   = assign({ 'freq', 'op4gain', 'op3gain', 'lfospeed', 'lfodepth', 'adsrtarget', 'trig', 'mul', 'add' },{ 440, 10, 20, 64, 0, 64, 1, 1.0, 0.0 },...)
	return StkBeeThree:MultiNew{2,freq,op4gain,op3gain,lfospeed,lfodepth,adsrtarget,trig}:madd(mul,add)
end
PV_Compander=UGen:new{name='PV_Compander'}
function PV_Compander.create(...)
	local   buffer, thresh, slopeBelow, slopeAbove   = assign({ 'buffer', 'thresh', 'slopeBelow', 'slopeAbove' },{ nil, 50, 1, 1 },...)
	return PV_Compander:MultiNew{1,buffer,thresh,slopeBelow,slopeAbove}
end
BufWr=UGen:new{name='BufWr'}
function BufWr.kr(...)
	local   inputArray, bufnum, phase, loop   = assign({ 'inputArray', 'bufnum', 'phase', 'loop' },{ nil, 0, 0.0, 1.0 },...)
	return BufWr:MultiNew{1,inputArray,bufnum,phase,loop}
end
function BufWr.ar(...)
	local   inputArray, bufnum, phase, loop   = assign({ 'inputArray', 'bufnum', 'phase', 'loop' },{ nil, 0, 0.0, 1.0 },...)
	return BufWr:MultiNew{2,inputArray,bufnum,phase,loop}
end
Rand=UGen:new{name='Rand'}
function Rand.create(...)
	local   lo, hi   = assign({ 'lo', 'hi' },{ 0.0, 1.0 },...)
	return Rand:MultiNew{0,lo,hi}
end
Splay=UGen:new{name='Splay'}
function Splay.kr(...)
	local   inArray, spread, level, center, levelComp   = assign({ 'inArray', 'spread', 'level', 'center', 'levelComp' },{ nil, 1, 1, 0.0, true },...)
	return Splay:MultiNew{1,inArray,spread,level,center,levelComp}
end
function Splay.ar(...)
	local   inArray, spread, level, center, levelComp   = assign({ 'inArray', 'spread', 'level', 'center', 'levelComp' },{ nil, 1, 1, 0.0, true },...)
	return Splay:MultiNew{2,inArray,spread,level,center,levelComp}
end
PauseSelf=UGen:new{name='PauseSelf'}
function PauseSelf.kr(...)
	local   inp   = assign({ 'inp' },{ nil },...)
	return PauseSelf:MultiNew{1,inp}
end
BlitB3Tri=UGen:new{name='BlitB3Tri'}
function BlitB3Tri.ar(...)
	local   freq, leak, leak2, mul, add   = assign({ 'freq', 'leak', 'leak2', 'mul', 'add' },{ 440.0, 0.99, 0.99, 1.0, 0.0 },...)
	return BlitB3Tri:MultiNew{2,freq,leak,leak2}:madd(mul,add)
end
BlitB3=UGen:new{name='BlitB3'}
function BlitB3.ar(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 440.0, 1.0, 0.0 },...)
	return BlitB3:MultiNew{2,freq}:madd(mul,add)
end
BasicOpUGen=UGen:new{name='BasicOpUGen'}
function BasicOpUGen.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return BasicOpUGen:MultiNew{2,maxSize}
end
StkBowed=UGen:new{name='StkBowed'}
function StkBowed.kr(...)
	local   freq, bowpressure, bowposition, vibfreq, vibgain, loudness, trig, mul, add   = assign({ 'freq', 'bowpressure', 'bowposition', 'vibfreq', 'vibgain', 'loudness', 'trig', 'mul', 'add' },{ 220, 64, 64, 64, 64, 64, 1, 1.0, 0.0 },...)
	return StkBowed:MultiNew{1,freq,bowpressure,bowposition,vibfreq,vibgain,loudness,trig}:madd(mul,add)
end
function StkBowed.ar(...)
	local   freq, bowpressure, bowposition, vibfreq, vibgain, loudness, gate, attackrate, decayrate, mul, add   = assign({ 'freq', 'bowpressure', 'bowposition', 'vibfreq', 'vibgain', 'loudness', 'gate', 'attackrate', 'decayrate', 'mul', 'add' },{ 220, 64, 64, 64, 64, 64, 1, 1, 1, 1.0, 0.0 },...)
	return StkBowed:MultiNew{2,freq,bowpressure,bowposition,vibfreq,vibgain,loudness,gate,attackrate,decayrate}:madd(mul,add)
end
Linen=UGen:new{name='Linen'}
function Linen.kr(...)
	local   gate, attackTime, susLevel, releaseTime, doneAction   = assign({ 'gate', 'attackTime', 'susLevel', 'releaseTime', 'doneAction' },{ 1.0, 0.01, 1.0, 1.0, 0 },...)
	return Linen:MultiNew{1,gate,attackTime,susLevel,releaseTime,doneAction}
end
Clockmus=UGen:new{name='Clockmus'}
function Clockmus.kr(...)
		return Clockmus:MultiNew{1}
end
PV_MagScale=UGen:new{name='PV_MagScale'}
function PV_MagScale.create(...)
	local   bufferA, bufferB   = assign({ 'bufferA', 'bufferB' },{ nil, nil },...)
	return PV_MagScale:MultiNew{1,bufferA,bufferB}
end
FeatureSave=UGen:new{name='FeatureSave'}
function FeatureSave.kr(...)
	local   features, trig   = assign({ 'features', 'trig' },{ nil, nil },...)
	return FeatureSave:MultiNew{1,features,trig}
end
StkClarinet=UGen:new{name='StkClarinet'}
function StkClarinet.kr(...)
	local   freq, reedstiffness, noisegain, vibfreq, vibgain, breathpressure, trig, mul, add   = assign({ 'freq', 'reedstiffness', 'noisegain', 'vibfreq', 'vibgain', 'breathpressure', 'trig', 'mul', 'add' },{ 440, 64, 4, 64, 11, 64, 1, 1.0, 0.0 },...)
	return StkClarinet:MultiNew{1,freq,reedstiffness,noisegain,vibfreq,vibgain,breathpressure,trig}:madd(mul,add)
end
function StkClarinet.ar(...)
	local   freq, reedstiffness, noisegain, vibfreq, vibgain, breathpressure, trig, mul, add   = assign({ 'freq', 'reedstiffness', 'noisegain', 'vibfreq', 'vibgain', 'breathpressure', 'trig', 'mul', 'add' },{ 440, 64, 4, 64, 11, 64, 1, 1.0, 0.0 },...)
	return StkClarinet:MultiNew{2,freq,reedstiffness,noisegain,vibfreq,vibgain,breathpressure,trig}:madd(mul,add)
end
OSTrunc4=UGen:new{name='OSTrunc4'}
function OSTrunc4.ar(...)
	local   inp, quant   = assign({ 'inp', 'quant' },{ nil, 0.5 },...)
	return OSTrunc4:MultiNew{2,inp,quant}
end
Peak=UGen:new{name='Peak'}
function Peak.kr(...)
	local   inp, trig   = assign({ 'inp', 'trig' },{ 0.0, 0.0 },...)
	return Peak:MultiNew{1,inp,trig}
end
function Peak.ar(...)
	local   inp, trig   = assign({ 'inp', 'trig' },{ 0.0, 0.0 },...)
	return Peak:MultiNew{2,inp,trig}
end
Sum3=UGen:new{name='Sum3'}
--there was fail in
AverageOutput=UGen:new{name='AverageOutput'}
function AverageOutput.kr(...)
	local   inp, trig, mul, add   = assign({ 'inp', 'trig', 'mul', 'add' },{ nil, 0.0, 1.0, 0.0 },...)
	return AverageOutput:MultiNew{1,inp,trig}:madd(mul,add)
end
function AverageOutput.ar(...)
	local   inp, trig, mul, add   = assign({ 'inp', 'trig', 'mul', 'add' },{ nil, 0.0, 1.0, 0.0 },...)
	return AverageOutput:MultiNew{2,inp,trig}:madd(mul,add)
end
JoshGrain=UGen:new{name='JoshGrain'}
function JoshGrain.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return JoshGrain:MultiNew{2,maxSize}
end
Concat=UGen:new{name='Concat'}
function Concat.ar(...)
	local   control, source, storesize, seektime, seekdur, matchlength, freezestore, zcr, lms, sc, st, randscore, mul, add   = assign({ 'control', 'source', 'storesize', 'seektime', 'seekdur', 'matchlength', 'freezestore', 'zcr', 'lms', 'sc', 'st', 'randscore', 'mul', 'add' },{ nil, nil, 1.0, 1.0, 1.0, 0.05, 0, 1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0 },...)
	return Concat:MultiNew{2,control,source,storesize,seektime,seekdur,matchlength,freezestore,zcr,lms,sc,st,randscore}:madd(mul,add)
end
FFTCrest=UGen:new{name='FFTCrest'}
function FFTCrest.kr(...)
	local   buffer, freqlo, freqhi   = assign({ 'buffer', 'freqlo', 'freqhi' },{ nil, 0, 50000 },...)
	return FFTCrest:MultiNew{1,buffer,freqlo,freqhi}
end
WidthFirstUGen=UGen:new{name='WidthFirstUGen'}
function WidthFirstUGen.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return WidthFirstUGen:MultiNew{2,maxSize}
end
Duty=UGen:new{name='Duty'}
function Duty.kr(...)
	local   dur, reset, level, doneAction   = assign({ 'dur', 'reset', 'level', 'doneAction' },{ 1.0, 0.0, 1.0, 0 },...)
	return Duty:MultiNew{1,dur,reset,level,doneAction}
end
function Duty.ar(...)
	local   dur, reset, level, doneAction   = assign({ 'dur', 'reset', 'level', 'doneAction' },{ 1.0, 0.0, 1.0, 0 },...)
	return Duty:MultiNew{2,dur,reset,level,doneAction}
end
Squiz=UGen:new{name='Squiz'}
function Squiz.kr(...)
	local   inp, pitchratio, zcperchunk, memlen, mul, add   = assign({ 'inp', 'pitchratio', 'zcperchunk', 'memlen', 'mul', 'add' },{ nil, 2, 1, 0.1, 1, 0 },...)
	return Squiz:MultiNew{1,inp,pitchratio,zcperchunk,memlen}:madd(mul,add)
end
function Squiz.ar(...)
	local   inp, pitchratio, zcperchunk, memlen, mul, add   = assign({ 'inp', 'pitchratio', 'zcperchunk', 'memlen', 'mul', 'add' },{ nil, 2, 1, 0.1, 1, 0 },...)
	return Squiz:MultiNew{2,inp,pitchratio,zcperchunk,memlen}:madd(mul,add)
end
WhiteNoise=UGen:new{name='WhiteNoise'}
function WhiteNoise.kr(...)
	local   mul, add   = assign({ 'mul', 'add' },{ 1.0, 0.0 },...)
	return WhiteNoise:MultiNew{1}:madd(mul,add)
end
function WhiteNoise.ar(...)
	local   mul, add   = assign({ 'mul', 'add' },{ 1.0, 0.0 },...)
	return WhiteNoise:MultiNew{2}:madd(mul,add)
end
SVF=UGen:new{name='SVF'}
function SVF.kr(...)
	local   signal, cutoff, res, lowpass, bandpass, highpass, notch, peak, mul, add   = assign({ 'signal', 'cutoff', 'res', 'lowpass', 'bandpass', 'highpass', 'notch', 'peak', 'mul', 'add' },{ nil, 2200.0, 0.1, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0 },...)
	return SVF:MultiNew{1,signal,cutoff,res,lowpass,bandpass,highpass,notch,peak}:madd(mul,add)
end
function SVF.ar(...)
	local   signal, cutoff, res, lowpass, bandpass, highpass, notch, peak, mul, add   = assign({ 'signal', 'cutoff', 'res', 'lowpass', 'bandpass', 'highpass', 'notch', 'peak', 'mul', 'add' },{ nil, 2200.0, 0.1, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0 },...)
	return SVF:MultiNew{2,signal,cutoff,res,lowpass,bandpass,highpass,notch,peak}:madd(mul,add)
end
SpecFlatness=UGen:new{name='SpecFlatness'}
function SpecFlatness.kr(...)
	local   buffer   = assign({ 'buffer' },{ nil },...)
	return SpecFlatness:MultiNew{1,buffer}
end
TBall=UGen:new{name='TBall'}
function TBall.kr(...)
	local   inp, g, damp, friction   = assign({ 'inp', 'g', 'damp', 'friction' },{ 0.0, 10, 0, 0.01 },...)
	return TBall:MultiNew{1,inp,g,damp,friction}
end
function TBall.ar(...)
	local   inp, g, damp, friction   = assign({ 'inp', 'g', 'damp', 'friction' },{ 0.0, 10, 0, 0.01 },...)
	return TBall:MultiNew{2,inp,g,damp,friction}
end
FFTMKL=UGen:new{name='FFTMKL'}
function FFTMKL.kr(...)
	local   buffer, epsilon   = assign({ 'buffer', 'epsilon' },{ nil, 1e-006 },...)
	return FFTMKL:MultiNew{1,buffer,epsilon}
end
LPF18=UGen:new{name='LPF18'}
function LPF18.ar(...)
	local   inp, freq, res, dist   = assign({ 'inp', 'freq', 'res', 'dist' },{ nil, 100, 1, 0.4 },...)
	return LPF18:MultiNew{2,inp,freq,res,dist}
end
MostChange=UGen:new{name='MostChange'}
function MostChange.kr(...)
	local   a, b   = assign({ 'a', 'b' },{ 0.0, 0.0 },...)
	return MostChange:MultiNew{1,a,b}
end
function MostChange.ar(...)
	local   a, b   = assign({ 'a', 'b' },{ 0.0, 0.0 },...)
	return MostChange:MultiNew{2,a,b}
end
SLOnset=UGen:new{name='SLOnset'}
function SLOnset.kr(...)
	local   input, memorysize1, before, after, threshold, hysteresis, mul, add   = assign({ 'input', 'memorysize1', 'before', 'after', 'threshold', 'hysteresis', 'mul', 'add' },{ nil, 20, 5, 5, 10, 10, 1.0, 0.0 },...)
	return SLOnset:MultiNew{1,input,memorysize1,before,after,threshold,hysteresis}:madd(mul,add)
end
FFTPower=UGen:new{name='FFTPower'}
function FFTPower.kr(...)
	local   buffer, square   = assign({ 'buffer', 'square' },{ nil, true },...)
	return FFTPower:MultiNew{1,buffer,square}
end
WaveTerrain=UGen:new{name='WaveTerrain'}
function WaveTerrain.ar(...)
	local   bufnum, x, y, xsize, ysize, mul, add   = assign({ 'bufnum', 'x', 'y', 'xsize', 'ysize', 'mul', 'add' },{ 0, nil, nil, 100, 100, 1.0, 0.0 },...)
	return WaveTerrain:MultiNew{2,bufnum,x,y,xsize,ysize}:madd(mul,add)
end
LFNoise0=UGen:new{name='LFNoise0'}
function LFNoise0.kr(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 500.0, 1.0, 0.0 },...)
	return LFNoise0:MultiNew{1,freq}:madd(mul,add)
end
function LFNoise0.ar(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 500.0, 1.0, 0.0 },...)
	return LFNoise0:MultiNew{2,freq}:madd(mul,add)
end
LatoocarfianTrig=UGen:new{name='LatoocarfianTrig'}
function LatoocarfianTrig.kr(...)
	local   minfreq, maxfreq, a, b, c, d, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'a', 'b', 'c', 'd', 'x0', 'y0', 'mul', 'add' },{ 5, 10, 1, 3, 0.5, 0.5, 0.34082301375036, -0.38270086971332, 1, 0.0 },...)
	return LatoocarfianTrig:MultiNew{1,minfreq,maxfreq,a,b,c,d,x0,y0}:madd(mul,add)
end
function LatoocarfianTrig.ar(...)
	local   minfreq, maxfreq, a, b, c, d, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'a', 'b', 'c', 'd', 'x0', 'y0', 'mul', 'add' },{ 5, 10, 1, 3, 0.5, 0.5, 0.34082301375036, -0.38270086971332, 1, 0.0 },...)
	return LatoocarfianTrig:MultiNew{2,minfreq,maxfreq,a,b,c,d,x0,y0}:madd(mul,add)
end
DUGen=UGen:new{name='DUGen'}
function DUGen.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return DUGen:MultiNew{2,maxSize}
end
Breakcore=UGen:new{name='Breakcore'}
function Breakcore.ar(...)
	local   bufnum, capturein, capturetrigger, duration, ampdropout   = assign({ 'bufnum', 'capturein', 'capturetrigger', 'duration', 'ampdropout' },{ 0, nil, nil, 0.1, nil },...)
	return Breakcore:MultiNew{2,bufnum,capturein,capturetrigger,duration,ampdropout}
end
Disintegrator=UGen:new{name='Disintegrator'}
function Disintegrator.ar(...)
	local   inp, probability, multiplier, mul, add   = assign({ 'inp', 'probability', 'multiplier', 'mul', 'add' },{ nil, 0.5, 0.0, 1.0, 0 },...)
	return Disintegrator:MultiNew{2,inp,probability,multiplier}:madd(mul,add)
end
DelTapWr=UGen:new{name='DelTapWr'}
function DelTapWr.kr(...)
	local   buffer, inp   = assign({ 'buffer', 'inp' },{ nil, nil },...)
	return DelTapWr:MultiNew{1,buffer,inp}
end
function DelTapWr.ar(...)
	local   buffer, inp   = assign({ 'buffer', 'inp' },{ nil, nil },...)
	return DelTapWr:MultiNew{2,buffer,inp}
end
TPV=UGen:new{name='TPV'}
function TPV.ar(...)
	local   chain, windowsize, hopsize, maxpeaks, currentpeaks, freqmult, tolerance, noisefloor, mul, add   = assign({ 'chain', 'windowsize', 'hopsize', 'maxpeaks', 'currentpeaks', 'freqmult', 'tolerance', 'noisefloor', 'mul', 'add' },{ nil, 1024, 512, 80, nil, 1.0, 4, 0.2, 1.0, 0.0 },...)
	return TPV:MultiNew{2,chain,windowsize,hopsize,maxpeaks,currentpeaks,freqmult,tolerance,noisefloor}:madd(mul,add)
end
Gendy3=UGen:new{name='Gendy3'}
function Gendy3.kr(...)
	local   ampdist, durdist, adparam, ddparam, freq, ampscale, durscale, initCPs, knum, mul, add   = assign({ 'ampdist', 'durdist', 'adparam', 'ddparam', 'freq', 'ampscale', 'durscale', 'initCPs', 'knum', 'mul', 'add' },{ 1, 1, 1.0, 1.0, 440, 0.5, 0.5, 12, nil, 1.0, 0.0 },...)
	return Gendy3:MultiNew{1,ampdist,durdist,adparam,ddparam,freq,ampscale,durscale,initCPs,knum}:madd(mul,add)
end
function Gendy3.ar(...)
	local   ampdist, durdist, adparam, ddparam, freq, ampscale, durscale, initCPs, knum, mul, add   = assign({ 'ampdist', 'durdist', 'adparam', 'ddparam', 'freq', 'ampscale', 'durscale', 'initCPs', 'knum', 'mul', 'add' },{ 1, 1, 1.0, 1.0, 440, 0.5, 0.5, 12, nil, 1.0, 0.0 },...)
	return Gendy3:MultiNew{2,ampdist,durdist,adparam,ddparam,freq,ampscale,durscale,initCPs,knum}:madd(mul,add)
end
NestedAllpassN=UGen:new{name='NestedAllpassN'}
function NestedAllpassN.ar(...)
	local   inp, maxdelay1, delay1, gain1, maxdelay2, delay2, gain2, mul, add   = assign({ 'inp', 'maxdelay1', 'delay1', 'gain1', 'maxdelay2', 'delay2', 'gain2', 'mul', 'add' },{ nil, 0.036, 0.036, 0.08, 0.03, 0.03, 0.3, 1.0, 0.0 },...)
	return NestedAllpassN:MultiNew{2,inp,maxdelay1,delay1,gain1,maxdelay2,delay2,gain2}:madd(mul,add)
end
Getenv=UGen:new{name='Getenv'}
function Getenv.create(...)
	local   key, defaultval   = assign({ 'key', 'defaultval' },{ nil, 0 },...)
	return Getenv:MultiNew{0,key,defaultval}
end
FhnTrig=UGen:new{name='FhnTrig'}
function FhnTrig.kr(...)
	local   minfreq, maxfreq, urate, wrate, b0, b1, i, u0, w0, mul, add   = assign({ 'minfreq', 'maxfreq', 'urate', 'wrate', 'b0', 'b1', 'i', 'u0', 'w0', 'mul', 'add' },{ 4, 10, 0.1, 0.1, 0.6, 0.8, 0.0, 0.0, 0.0, 1.0, 0.0 },...)
	return FhnTrig:MultiNew{1,minfreq,maxfreq,urate,wrate,b0,b1,i,u0,w0}:madd(mul,add)
end
function FhnTrig.ar(...)
	local   minfreq, maxfreq, urate, wrate, b0, b1, i, u0, w0, mul, add   = assign({ 'minfreq', 'maxfreq', 'urate', 'wrate', 'b0', 'b1', 'i', 'u0', 'w0', 'mul', 'add' },{ 4, 10, 0.1, 0.1, 0.6, 0.8, 0.0, 0.0, 0.0, 1.0, 0.0 },...)
	return FhnTrig:MultiNew{2,minfreq,maxfreq,urate,wrate,b0,b1,i,u0,w0}:madd(mul,add)
end
KmeansToBPSet1=UGen:new{name='KmeansToBPSet1'}
function KmeansToBPSet1.ar(...)
	local   freq, numdatapoints, maxnummeans, nummeans, tnewdata, tnewmeans, soft, bufnum, mul, add   = assign({ 'freq', 'numdatapoints', 'maxnummeans', 'nummeans', 'tnewdata', 'tnewmeans', 'soft', 'bufnum', 'mul', 'add' },{ 440, 20, 4, 4, 1, 1, 1.0, nil, 1.0, 0.0 },...)
	return KmeansToBPSet1:MultiNew{2,freq,numdatapoints,maxnummeans,nummeans,tnewdata,tnewmeans,soft,bufnum}:madd(mul,add)
end
KMeansRT=UGen:new{name='KMeansRT'}
function KMeansRT.kr(...)
	local   bufnum, inputdata, k, gate, reset, learn   = assign({ 'bufnum', 'inputdata', 'k', 'gate', 'reset', 'learn' },{ nil, nil, 5, 1, 0, 1 },...)
	return KMeansRT:MultiNew{1,bufnum,inputdata,k,gate,reset,learn}
end
BufDelayN=UGen:new{name='BufDelayN'}
function BufDelayN.kr(...)
	local   buf, inp, delaytime, mul, add   = assign({ 'buf', 'inp', 'delaytime', 'mul', 'add' },{ 0, 0.0, 0.2, 1.0, 0.0 },...)
	return BufDelayN:MultiNew{1,buf,inp,delaytime}:madd(mul,add)
end
function BufDelayN.ar(...)
	local   buf, inp, delaytime, mul, add   = assign({ 'buf', 'inp', 'delaytime', 'mul', 'add' },{ 0, 0.0, 0.2, 1.0, 0.0 },...)
	return BufDelayN:MultiNew{2,buf,inp,delaytime}:madd(mul,add)
end
Crackle=UGen:new{name='Crackle'}
function Crackle.kr(...)
	local   chaosParam, mul, add   = assign({ 'chaosParam', 'mul', 'add' },{ 1.5, 1.0, 0.0 },...)
	return Crackle:MultiNew{1,chaosParam}:madd(mul,add)
end
function Crackle.ar(...)
	local   chaosParam, mul, add   = assign({ 'chaosParam', 'mul', 'add' },{ 1.5, 1.0, 0.0 },...)
	return Crackle:MultiNew{2,chaosParam}:madd(mul,add)
end
Spring=UGen:new{name='Spring'}
function Spring.kr(...)
	local   inp, spring, damp   = assign({ 'inp', 'spring', 'damp' },{ 0.0, 1, 0 },...)
	return Spring:MultiNew{1,inp,spring,damp}
end
function Spring.ar(...)
	local   inp, spring, damp   = assign({ 'inp', 'spring', 'damp' },{ 0.0, 1, 0 },...)
	return Spring:MultiNew{2,inp,spring,damp}
end
PeakEQ4=UGen:new{name='PeakEQ4'}
function PeakEQ4.ar(...)
	local   inp, freq, rs, db   = assign({ 'inp', 'freq', 'rs', 'db' },{ nil, 1200.0, 1.0, 0.0 },...)
	return PeakEQ4:MultiNew{2,inp,freq,rs,db}
end
StkModalBar=UGen:new{name='StkModalBar'}
function StkModalBar.kr(...)
	local   freq, instrument, stickhardness, stickposition, vibratogain, vibratofreq, directstickmix, volume, trig, mul, add   = assign({ 'freq', 'instrument', 'stickhardness', 'stickposition', 'vibratogain', 'vibratofreq', 'directstickmix', 'volume', 'trig', 'mul', 'add' },{ 440, 0, 64, 64, 20, 20, 64, 64, 1, 1.0, 0.0 },...)
	return StkModalBar:MultiNew{1,freq,instrument,stickhardness,stickposition,vibratogain,vibratofreq,directstickmix,volume,trig}:madd(mul,add)
end
function StkModalBar.ar(...)
	local   freq, instrument, stickhardness, stickposition, vibratogain, vibratofreq, directstickmix, volume, trig, mul, add   = assign({ 'freq', 'instrument', 'stickhardness', 'stickposition', 'vibratogain', 'vibratofreq', 'directstickmix', 'volume', 'trig', 'mul', 'add' },{ 440, 0, 64, 64, 20, 20, 64, 64, 1, 1.0, 0.0 },...)
	return StkModalBar:MultiNew{2,freq,instrument,stickhardness,stickposition,vibratogain,vibratofreq,directstickmix,volume,trig}:madd(mul,add)
end
SplayAz=UGen:new{name='SplayAz'}
function SplayAz.kr(...)
	local   numChans, inArray, spread, level, width, center, orientation, levelComp   = assign({ 'numChans', 'inArray', 'spread', 'level', 'width', 'center', 'orientation', 'levelComp' },{ 4, nil, 1, 1, 2, 0.0, 0.5, true, nil, nil },...)
	return SplayAz:MultiNew{1,numChans,inArray,spread,level,width,center,orientation,levelComp}
end
function SplayAz.ar(...)
	local   numChans, inArray, spread, level, width, center, orientation, levelComp   = assign({ 'numChans', 'inArray', 'spread', 'level', 'width', 'center', 'orientation', 'levelComp' },{ 4, nil, 1, 1, 2, 0.0, 0.5, true, nil, nil },...)
	return SplayAz:MultiNew{2,numChans,inArray,spread,level,width,center,orientation,levelComp}
end
Metro=UGen:new{name='Metro'}
function Metro.kr(...)
	local   bpm, numBeats, mul, add   = assign({ 'bpm', 'numBeats', 'mul', 'add' },{ nil, nil, 1, 0 },...)
	return Metro:MultiNew{1,bpm,numBeats}:madd(mul,add)
end
function Metro.ar(...)
	local   bpm, numBeats, mul, add   = assign({ 'bpm', 'numBeats', 'mul', 'add' },{ nil, nil, 1, 0 },...)
	return Metro:MultiNew{2,bpm,numBeats}:madd(mul,add)
end
Henon2DN=UGen:new{name='Henon2DN'}
function Henon2DN.kr(...)
	local   minfreq, maxfreq, a, b, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'a', 'b', 'x0', 'y0', 'mul', 'add' },{ 40, 100, 1.4, 0.3, 0.30501993062401, 0.20938865431933, 1, 0.0 },...)
	return Henon2DN:MultiNew{1,minfreq,maxfreq,a,b,x0,y0}:madd(mul,add)
end
function Henon2DN.ar(...)
	local   minfreq, maxfreq, a, b, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'a', 'b', 'x0', 'y0', 'mul', 'add' },{ 11025, 22050, 1.4, 0.3, 0.30501993062401, 0.20938865431933, 1, 0.0 },...)
	return Henon2DN:MultiNew{2,minfreq,maxfreq,a,b,x0,y0}:madd(mul,add)
end
Ball=UGen:new{name='Ball'}
function Ball.kr(...)
	local   inp, g, damp, friction   = assign({ 'inp', 'g', 'damp', 'friction' },{ 0.0, 1, 0, 0.01 },...)
	return Ball:MultiNew{1,inp,g,damp,friction}
end
function Ball.ar(...)
	local   inp, g, damp, friction   = assign({ 'inp', 'g', 'damp', 'friction' },{ 0.0, 1, 0, 0.01 },...)
	return Ball:MultiNew{2,inp,g,damp,friction}
end
OteyPiano=UGen:new{name='OteyPiano'}
function OteyPiano.ar(...)
	local   freq, amp, gate, release   = assign({ 'freq', 'amp', 'gate', 'release' },{ 440, 0.5, 1, 0.1 },...)
	return OteyPiano:MultiNew{2,freq,amp,gate,release}
end
KeyTrack=UGen:new{name='KeyTrack'}
function KeyTrack.kr(...)
	local   chain, keydecay, chromaleak   = assign({ 'chain', 'keydecay', 'chromaleak' },{ nil, 2.0, 0.5 },...)
	return KeyTrack:MultiNew{1,chain,keydecay,chromaleak}
end
Clipper8=UGen:new{name='Clipper8'}
function Clipper8.ar(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ nil, -0.8, 0.8 },...)
	return Clipper8:MultiNew{2,inp,lo,hi}
end
OSFold4=UGen:new{name='OSFold4'}
function OSFold4.ar(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ nil, nil, nil },...)
	return OSFold4:MultiNew{2,inp,lo,hi}
end
DelTapRd=UGen:new{name='DelTapRd'}
function DelTapRd.kr(...)
	local   buffer, phase, delTime, interp, mul, add   = assign({ 'buffer', 'phase', 'delTime', 'interp', 'mul', 'add' },{ nil, nil, nil, 1, 1, 0 },...)
	return DelTapRd:MultiNew{1,buffer,phase,delTime,interp}:madd(mul,add)
end
function DelTapRd.ar(...)
	local   buffer, phase, delTime, interp, mul, add   = assign({ 'buffer', 'phase', 'delTime', 'interp', 'mul', 'add' },{ nil, nil, nil, 1, 1, 0 },...)
	return DelTapRd:MultiNew{2,buffer,phase,delTime,interp}:madd(mul,add)
end
SpecCentroid=UGen:new{name='SpecCentroid'}
function SpecCentroid.kr(...)
	local   buffer   = assign({ 'buffer' },{ nil },...)
	return SpecCentroid:MultiNew{1,buffer}
end
GaussClass=UGen:new{name='GaussClass'}
function GaussClass.kr(...)
	local   inp, bufnum, gate   = assign({ 'inp', 'bufnum', 'gate' },{ nil, 0, 0 },...)
	return GaussClass:MultiNew{1,inp,bufnum,gate}
end
FFTDiffMags=UGen:new{name='FFTDiffMags'}
function FFTDiffMags.kr(...)
	local   bufferA, bufferB   = assign({ 'bufferA', 'bufferB' },{ nil, nil },...)
	return FFTDiffMags:MultiNew{1,bufferA,bufferB}
end
DPW4Saw=UGen:new{name='DPW4Saw'}
function DPW4Saw.ar(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 440.0, 1.0, 0.0 },...)
	return DPW4Saw:MultiNew{2,freq}:madd(mul,add)
end
HilbertFIR=UGen:new{name='HilbertFIR'}
function HilbertFIR.ar(...)
	local   inp, buffer   = assign({ 'inp', 'buffer' },{ nil, nil, nil, nil },...)
	return HilbertFIR:MultiNew{2,inp,buffer}
end
Loudness=UGen:new{name='Loudness'}
function Loudness.kr(...)
	local   chain, smask, tmask   = assign({ 'chain', 'smask', 'tmask' },{ nil, 0.25, 1 },...)
	return Loudness:MultiNew{1,chain,smask,tmask}
end
DWGBowedSimple=UGen:new{name='DWGBowedSimple'}
function DWGBowedSimple.ar(...)
	local   freq, velb, force, gate, pos, release, c1, c3   = assign({ 'freq', 'velb', 'force', 'gate', 'pos', 'release', 'c1', 'c3' },{ 440, 0.5, 1, 1, 0.14, 0.1, 1, 30 },...)
	return DWGBowedSimple:MultiNew{2,freq,velb,force,gate,pos,release,c1,c3}
end
Standard2DN=UGen:new{name='Standard2DN'}
function Standard2DN.kr(...)
	local   minfreq, maxfreq, k, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'k', 'x0', 'y0', 'mul', 'add' },{ 40, 100, 1.4, 4.9789799812499, 5.7473416156381, 1, 0.0 },...)
	return Standard2DN:MultiNew{1,minfreq,maxfreq,k,x0,y0}:madd(mul,add)
end
function Standard2DN.ar(...)
	local   minfreq, maxfreq, k, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'k', 'x0', 'y0', 'mul', 'add' },{ 11025, 22050, 1.4, 4.9789799812499, 5.7473416156381, 1, 0.0 },...)
	return Standard2DN:MultiNew{2,minfreq,maxfreq,k,x0,y0}:madd(mul,add)
end
LPCError=UGen:new{name='LPCError'}
function LPCError.ar(...)
	local   input, p, mul, add   = assign({ 'input', 'p', 'mul', 'add' },{ nil, 10, 1.0, 0.0 },...)
	return LPCError:MultiNew{2,input,p}:madd(mul,add)
end
MembraneCircle=UGen:new{name='MembraneCircle'}
function MembraneCircle.ar(...)
	local   excitation, tension, loss, mul, add   = assign({ 'excitation', 'tension', 'loss', 'mul', 'add' },{ nil, 0.05, 0.99999, 1.0, 0.0 },...)
	return MembraneCircle:MultiNew{2,excitation,tension,loss}:madd(mul,add)
end
SoftClipAmp=UGen:new{name='SoftClipAmp'}
function SoftClipAmp.ar(...)
	local   inp, pregain, mul, add   = assign({ 'inp', 'pregain', 'mul', 'add' },{ nil, 1, 1, 0 },...)
	return SoftClipAmp:MultiNew{2,inp,pregain}:madd(mul,add)
end
DoubleWell=UGen:new{name='DoubleWell'}
function DoubleWell.ar(...)
	local   reset, ratex, ratey, f, w, delta, initx, inity, mul, add   = assign({ 'reset', 'ratex', 'ratey', 'f', 'w', 'delta', 'initx', 'inity', 'mul', 'add' },{ 0, 0.01, 0.01, 1, 0.001, 1, 0, 0, 1.0, 0.0 },...)
	return DoubleWell:MultiNew{2,reset,ratex,ratey,f,w,delta,initx,inity}:madd(mul,add)
end
XLine=UGen:new{name='XLine'}
function XLine.kr(...)
	local   start, endp, dur, mul, add, doneAction   = assign({ 'start', 'endp', 'dur', 'mul', 'add', 'doneAction' },{ 1.0, 2.0, 1.0, 1.0, 0.0, 0 },...)
	return XLine:MultiNew{1,start,endp,dur,doneAction}:madd(mul,add)
end
function XLine.ar(...)
	local   start, endp, dur, mul, add, doneAction   = assign({ 'start', 'endp', 'dur', 'mul', 'add', 'doneAction' },{ 1.0, 2.0, 1.0, 1.0, 0.0, 0 },...)
	return XLine:MultiNew{2,start,endp,dur,doneAction}:madd(mul,add)
end
AY=UGen:new{name='AY'}
function AY.ar(...)
	local   tonea, toneb, tonec, noise, control, vola, volb, volc, envfreq, envstyle, chiptype, mul, add   = assign({ 'tonea', 'toneb', 'tonec', 'noise', 'control', 'vola', 'volb', 'volc', 'envfreq', 'envstyle', 'chiptype', 'mul', 'add' },{ 1777, 1666, 1555, 1, 7, 15, 15, 15, 4, 1, 0, 1, 0 },...)
	return AY:MultiNew{2,tonea,toneb,tonec,noise,control,vola,volb,volc,envfreq,envstyle,chiptype}:madd(mul,add)
end
PV_MagMinus=UGen:new{name='PV_MagMinus'}
function PV_MagMinus.create(...)
	local   bufferA, bufferB, remove   = assign({ 'bufferA', 'bufferB', 'remove' },{ nil, nil, 1.0 },...)
	return PV_MagMinus:MultiNew{1,bufferA,bufferB,remove}
end
RMEQSuite=UGen:new{name='RMEQSuite'}
function RMEQSuite.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return RMEQSuite:MultiNew{2,maxSize}
end
BLBufRd=UGen:new{name='BLBufRd'}
function BLBufRd.kr(...)
	local   bufnum, phase, ratio   = assign({ 'bufnum', 'phase', 'ratio' },{ 0, 0, 1 },...)
	return BLBufRd:MultiNew{1,bufnum,phase,ratio}
end
function BLBufRd.ar(...)
	local   bufnum, phase, ratio   = assign({ 'bufnum', 'phase', 'ratio' },{ 0, 0, 1 },...)
	return BLBufRd:MultiNew{2,bufnum,phase,ratio}
end
OnsetsDS=UGen:new{name='OnsetsDS'}
function OnsetsDS.kr(...)
	local   inp, fftbuf, trackbuf, thresh, type, extchain, relaxtime, floor, smear, mingap, medianspan   = assign({ 'inp', 'fftbuf', 'trackbuf', 'thresh', 'type', 'extchain', 'relaxtime', 'floor', 'smear', 'mingap', 'medianspan' },{ nil, nil, nil, 0.5, 'power', false, 0.1, 0.1, 0, 0.05, 11, nil, nil, nil },...)
	return OnsetsDS:MultiNew{1,inp,fftbuf,trackbuf,thresh,type,extchain,relaxtime,floor,smear,mingap,medianspan}
end
StkFlute=UGen:new{name='StkFlute'}
function StkFlute.kr(...)
	local   freq, jetDelay, noisegain, jetRatio, mul, add   = assign({ 'freq', 'jetDelay', 'noisegain', 'jetRatio', 'mul', 'add' },{ 220, 49, 0.15, 0.32, 1.0, 0.0 },...)
	return StkFlute:MultiNew{1,freq,jetDelay,noisegain,jetRatio}:madd(mul,add)
end
function StkFlute.ar(...)
	local   freq, jetDelay, noisegain, jetRatio, mul, add   = assign({ 'freq', 'jetDelay', 'noisegain', 'jetRatio', 'mul', 'add' },{ 440, 49, 0.15, 0.32, 1.0, 0.0 },...)
	return StkFlute:MultiNew{2,freq,jetDelay,noisegain,jetRatio}:madd(mul,add)
end
TIRand=UGen:new{name='TIRand'}
function TIRand.kr(...)
	local   lo, hi, trig   = assign({ 'lo', 'hi', 'trig' },{ 0, 127, 0.0 },...)
	return TIRand:MultiNew{1,lo,hi,trig}
end
function TIRand.ar(...)
	local   lo, hi, trig   = assign({ 'lo', 'hi', 'trig' },{ 0, 127, 0.0 },...)
	return TIRand:MultiNew{2,lo,hi,trig}
end
DemandEnvGen=UGen:new{name='DemandEnvGen'}
function DemandEnvGen.kr(...)
	local   level, dur, shape, curve, gate, reset, levelScale, levelBias, timeScale, doneAction   = assign({ 'level', 'dur', 'shape', 'curve', 'gate', 'reset', 'levelScale', 'levelBias', 'timeScale', 'doneAction' },{ nil, nil, 1, 0, 1.0, 1.0, 1.0, 0.0, 1.0, 0 },...)
	return DemandEnvGen:MultiNew{1,level,dur,shape,curve,gate,reset,levelScale,levelBias,timeScale,doneAction}
end
function DemandEnvGen.ar(...)
	local   level, dur, shape, curve, gate, reset, levelScale, levelBias, timeScale, doneAction   = assign({ 'level', 'dur', 'shape', 'curve', 'gate', 'reset', 'levelScale', 'levelBias', 'timeScale', 'doneAction' },{ nil, nil, 1, 0, 1.0, 1.0, 1.0, 0.0, 1.0, 0 },...)
	return DemandEnvGen:MultiNew{2,level,dur,shape,curve,gate,reset,levelScale,levelBias,timeScale,doneAction}
end
SmoothDecimator=UGen:new{name='SmoothDecimator'}
function SmoothDecimator.ar(...)
	local   inp, rate, smoothing, mul, add   = assign({ 'inp', 'rate', 'smoothing', 'mul', 'add' },{ nil, 44100.0, 0.5, 1.0, 0 },...)
	return SmoothDecimator:MultiNew{2,inp,rate,smoothing}:madd(mul,add)
end
SoftClipper4=UGen:new{name='SoftClipper4'}
function SoftClipper4.ar(...)
	local   inp   = assign({ 'inp' },{ nil },...)
	return SoftClipper4:MultiNew{2,inp}
end
TRand=UGen:new{name='TRand'}
function TRand.kr(...)
	local   lo, hi, trig   = assign({ 'lo', 'hi', 'trig' },{ 0.0, 1.0, 0.0 },...)
	return TRand:MultiNew{1,lo,hi,trig}
end
function TRand.ar(...)
	local   lo, hi, trig   = assign({ 'lo', 'hi', 'trig' },{ 0.0, 1.0, 0.0 },...)
	return TRand:MultiNew{2,lo,hi,trig}
end
GbmanTrig=UGen:new{name='GbmanTrig'}
function GbmanTrig.kr(...)
	local   minfreq, maxfreq, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'x0', 'y0', 'mul', 'add' },{ 5, 10, 1.2, 2.1, 1, 0.0 },...)
	return GbmanTrig:MultiNew{1,minfreq,maxfreq,x0,y0}:madd(mul,add)
end
function GbmanTrig.ar(...)
	local   minfreq, maxfreq, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'x0', 'y0', 'mul', 'add' },{ 5, 10, 1.2, 2.1, 1, 0.0 },...)
	return GbmanTrig:MultiNew{2,minfreq,maxfreq,x0,y0}:madd(mul,add)
end
WAmp=UGen:new{name='WAmp'}
function WAmp.kr(...)
	local   inp, winSize   = assign({ 'inp', 'winSize' },{ 0.0, 0.1 },...)
	return WAmp:MultiNew{1,inp,winSize}
end
BMoog=UGen:new{name='BMoog'}
function BMoog.ar(...)
	local   inp, freq, q, mode, saturation, mul, add   = assign({ 'inp', 'freq', 'q', 'mode', 'saturation', 'mul', 'add' },{ nil, 440.0, 0.2, 0.0, 0.95, 1.0, 0.0 },...)
	return BMoog:MultiNew{2,inp,freq,q,mode,saturation}:madd(mul,add)
end
PulseDivider=UGen:new{name='PulseDivider'}
function PulseDivider.kr(...)
	local   trig, div, start   = assign({ 'trig', 'div', 'start' },{ 0.0, 2.0, 0.0 },...)
	return PulseDivider:MultiNew{1,trig,div,start}
end
function PulseDivider.ar(...)
	local   trig, div, start   = assign({ 'trig', 'div', 'start' },{ 0.0, 2.0, 0.0 },...)
	return PulseDivider:MultiNew{2,trig,div,start}
end
Sum4=UGen:new{name='Sum4'}
--there was fail in
FreeSelfWhenDone=UGen:new{name='FreeSelfWhenDone'}
function FreeSelfWhenDone.kr(...)
	local   src   = assign({ 'src' },{ nil },...)
	return FreeSelfWhenDone:MultiNew{1,src}
end
Klang=UGen:new{name='Klang'}
function Klang.ar(...)
	local   specificationsArrayRef, freqscale, freqoffset   = assign({ 'specificationsArrayRef', 'freqscale', 'freqoffset' },{ nil, 1.0, 0.0 },...)
	return Klang:MultiNew{2,specificationsArrayRef,freqscale,freqoffset}
end
RecordBuf=UGen:new{name='RecordBuf'}
function RecordBuf.kr(...)
	local   inputArray, bufnum, offset, recLevel, preLevel, run, loop, trigger, doneAction   = assign({ 'inputArray', 'bufnum', 'offset', 'recLevel', 'preLevel', 'run', 'loop', 'trigger', 'doneAction' },{ nil, 0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 0 },...)
	return RecordBuf:MultiNew{1,inputArray,bufnum,offset,recLevel,preLevel,run,loop,trigger,doneAction}
end
function RecordBuf.ar(...)
	local   inputArray, bufnum, offset, recLevel, preLevel, run, loop, trigger, doneAction   = assign({ 'inputArray', 'bufnum', 'offset', 'recLevel', 'preLevel', 'run', 'loop', 'trigger', 'doneAction' },{ nil, 0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 0 },...)
	return RecordBuf:MultiNew{2,inputArray,bufnum,offset,recLevel,preLevel,run,loop,trigger,doneAction}
end
IRand=UGen:new{name='IRand'}
function IRand.create(...)
	local   lo, hi   = assign({ 'lo', 'hi' },{ 0, 127 },...)
	return IRand:MultiNew{0,lo,hi}
end
DoubleNestedAllpassN=UGen:new{name='DoubleNestedAllpassN'}
function DoubleNestedAllpassN.ar(...)
	local   inp, maxdelay1, delay1, gain1, maxdelay2, delay2, gain2, maxdelay3, delay3, gain3, mul, add   = assign({ 'inp', 'maxdelay1', 'delay1', 'gain1', 'maxdelay2', 'delay2', 'gain2', 'maxdelay3', 'delay3', 'gain3', 'mul', 'add' },{ nil, 0.0047, 0.0047, 0.15, 0.022, 0.022, 0.25, 0.0083, 0.0083, 0.3, 1.0, 0.0 },...)
	return DoubleNestedAllpassN:MultiNew{2,inp,maxdelay1,delay1,gain1,maxdelay2,delay2,gain2,maxdelay3,delay3,gain3}:madd(mul,add)
end
Lorenz2DN=UGen:new{name='Lorenz2DN'}
function Lorenz2DN.kr(...)
	local   minfreq, maxfreq, s, r, b, h, x0, y0, z0, mul, add   = assign({ 'minfreq', 'maxfreq', 's', 'r', 'b', 'h', 'x0', 'y0', 'z0', 'mul', 'add' },{ 40, 100, 10, 28, 2.6666667, 0.02, 0.090879182417163, 2.97077458055, 24.282041054363, 1.0, 0.0 },...)
	return Lorenz2DN:MultiNew{1,minfreq,maxfreq,s,r,b,h,x0,y0,z0}:madd(mul,add)
end
function Lorenz2DN.ar(...)
	local   minfreq, maxfreq, s, r, b, h, x0, y0, z0, mul, add   = assign({ 'minfreq', 'maxfreq', 's', 'r', 'b', 'h', 'x0', 'y0', 'z0', 'mul', 'add' },{ 11025, 22050, 10, 28, 2.6666667, 0.02, 0.090879182417163, 2.97077458055, 24.282041054363, 1.0, 0.0 },...)
	return Lorenz2DN:MultiNew{2,minfreq,maxfreq,s,r,b,h,x0,y0,z0}:madd(mul,add)
end
Fhn2DN=UGen:new{name='Fhn2DN'}
function Fhn2DN.kr(...)
	local   minfreq, maxfreq, urate, wrate, b0, b1, i, u0, w0, mul, add   = assign({ 'minfreq', 'maxfreq', 'urate', 'wrate', 'b0', 'b1', 'i', 'u0', 'w0', 'mul', 'add' },{ 40, 100, 0.1, 0.1, 0.6, 0.8, 0.0, 0.0, 0.0, 1.0, 0.0 },...)
	return Fhn2DN:MultiNew{1,minfreq,maxfreq,urate,wrate,b0,b1,i,u0,w0}:madd(mul,add)
end
function Fhn2DN.ar(...)
	local   minfreq, maxfreq, urate, wrate, b0, b1, i, u0, w0, mul, add   = assign({ 'minfreq', 'maxfreq', 'urate', 'wrate', 'b0', 'b1', 'i', 'u0', 'w0', 'mul', 'add' },{ 11025, 22050, 0.1, 0.1, 0.6, 0.8, 0.0, 0.0, 0.0, 1.0, 0.0 },...)
	return Fhn2DN:MultiNew{2,minfreq,maxfreq,urate,wrate,b0,b1,i,u0,w0}:madd(mul,add)
end
Normalizer=UGen:new{name='Normalizer'}
function Normalizer.ar(...)
	local   inp, level, dur   = assign({ 'inp', 'level', 'dur' },{ 0.0, 1.0, 0.01 },...)
	return Normalizer:MultiNew{2,inp,level,dur}
end
DoubleWell3=UGen:new{name='DoubleWell3'}
function DoubleWell3.ar(...)
	local   reset, rate, f, delta, initx, inity, mul, add   = assign({ 'reset', 'rate', 'f', 'delta', 'initx', 'inity', 'mul', 'add' },{ 0, 0.01, 0, 0.25, 0, 0, 1.0, 0.0 },...)
	return DoubleWell3:MultiNew{2,reset,rate,f,delta,initx,inity}:madd(mul,add)
end
Summer=UGen:new{name='Summer'}
function Summer.kr(...)
	local   trig, step, reset, resetval   = assign({ 'trig', 'step', 'reset', 'resetval' },{ 0, 1, 0, 0 },...)
	return Summer:MultiNew{1,trig,step,reset,resetval}
end
function Summer.ar(...)
	local   trig, step, reset, resetval   = assign({ 'trig', 'step', 'reset', 'resetval' },{ 0, 1, 0, 0 },...)
	return Summer:MultiNew{2,trig,step,reset,resetval}
end
Dgauss=UGen:new{name='Dgauss'}
function Dgauss.create(...)
	local   lo, hi, length   = assign({ 'lo', 'hi', 'length' },{ nil, nil, "math.huge" },...)
	return Dgauss:MultiNew{3,lo,hi,length}
end
AudioMSG=UGen:new{name='AudioMSG'}
function AudioMSG.ar(...)
	local   inp, index, mul, add   = assign({ 'inp', 'index', 'mul', 'add' },{ nil, 0.0, 1.0, 0.0 },...)
	return AudioMSG:MultiNew{2,inp,index}:madd(mul,add)
end
Blip=UGen:new{name='Blip'}
function Blip.kr(...)
	local   freq, numharm, mul, add   = assign({ 'freq', 'numharm', 'mul', 'add' },{ 440.0, 200.0, 1.0, 0.0 },...)
	return Blip:MultiNew{1,freq,numharm}:madd(mul,add)
end
function Blip.ar(...)
	local   freq, numharm, mul, add   = assign({ 'freq', 'numharm', 'mul', 'add' },{ 440.0, 200.0, 1.0, 0.0 },...)
	return Blip:MultiNew{2,freq,numharm}:madd(mul,add)
end
SoftClipAmp4=UGen:new{name='SoftClipAmp4'}
function SoftClipAmp4.ar(...)
	local   inp, pregain, mul, add   = assign({ 'inp', 'pregain', 'mul', 'add' },{ nil, 1, 1, 0 },...)
	return SoftClipAmp4:MultiNew{2,inp,pregain}:madd(mul,add)
end
PauseSelfWhenDone=UGen:new{name='PauseSelfWhenDone'}
function PauseSelfWhenDone.kr(...)
	local   src   = assign({ 'src' },{ nil },...)
	return PauseSelfWhenDone:MultiNew{1,src}
end
PartConv=UGen:new{name='PartConv'}
function PartConv.ar(...)
	local   inp, fftsize, irbufnum, mul, add   = assign({ 'inp', 'fftsize', 'irbufnum', 'mul', 'add' },{ nil, nil, nil, 1.0, 0.0 },...)
	return PartConv:MultiNew{2,inp,fftsize,irbufnum}:madd(mul,add)
end
Perlin3=UGen:new{name='Perlin3'}
function Perlin3.kr(...)
	local   x, y, z   = assign({ 'x', 'y', 'z' },{ 0, 0, 0 },...)
	return Perlin3:MultiNew{1,x,y,z}
end
function Perlin3.ar(...)
	local   x, y, z   = assign({ 'x', 'y', 'z' },{ 0, 0, 0 },...)
	return Perlin3:MultiNew{2,x,y,z}
end
TwoTube=UGen:new{name='TwoTube'}
function TwoTube.ar(...)
	local   input, k, loss, d1length, d2length, mul, add   = assign({ 'input', 'k', 'loss', 'd1length', 'd2length', 'mul', 'add' },{ 0, 0.01, 1.0, 100, 100, 1.0, 0.0 },...)
	return TwoTube:MultiNew{2,input,k,loss,d1length,d2length}:madd(mul,add)
end
Gendy1=UGen:new{name='Gendy1'}
function Gendy1.kr(...)
	local   ampdist, durdist, adparam, ddparam, minfreq, maxfreq, ampscale, durscale, initCPs, knum, mul, add   = assign({ 'ampdist', 'durdist', 'adparam', 'ddparam', 'minfreq', 'maxfreq', 'ampscale', 'durscale', 'initCPs', 'knum', 'mul', 'add' },{ 1, 1, 1.0, 1.0, 20, 1000, 0.5, 0.5, 12, nil, 1.0, 0.0 },...)
	return Gendy1:MultiNew{1,ampdist,durdist,adparam,ddparam,minfreq,maxfreq,ampscale,durscale,initCPs,knum}:madd(mul,add)
end
function Gendy1.ar(...)
	local   ampdist, durdist, adparam, ddparam, minfreq, maxfreq, ampscale, durscale, initCPs, knum, mul, add   = assign({ 'ampdist', 'durdist', 'adparam', 'ddparam', 'minfreq', 'maxfreq', 'ampscale', 'durscale', 'initCPs', 'knum', 'mul', 'add' },{ 1, 1, 1.0, 1.0, 440, 660, 0.5, 0.5, 12, nil, 1.0, 0.0 },...)
	return Gendy1:MultiNew{2,ampdist,durdist,adparam,ddparam,minfreq,maxfreq,ampscale,durscale,initCPs,knum}:madd(mul,add)
end
OSTrunc8=UGen:new{name='OSTrunc8'}
function OSTrunc8.ar(...)
	local   inp, quant   = assign({ 'inp', 'quant' },{ nil, 0.5 },...)
	return OSTrunc8:MultiNew{2,inp,quant}
end
StkPluck=UGen:new{name='StkPluck'}
function StkPluck.kr(...)
	local   freq, decay, mul, add   = assign({ 'freq', 'decay', 'mul', 'add' },{ 440, 0.99, 1.0, 0.0 },...)
	return StkPluck:MultiNew{1,freq,decay}:madd(mul,add)
end
function StkPluck.ar(...)
	local   freq, decay, mul, add   = assign({ 'freq', 'decay', 'mul', 'add' },{ 440, 0.99, 1.0, 0.0 },...)
	return StkPluck:MultiNew{2,freq,decay}:madd(mul,add)
end
OSWrap4=UGen:new{name='OSWrap4'}
function OSWrap4.ar(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ nil, nil, nil },...)
	return OSWrap4:MultiNew{2,inp,lo,hi}
end
BlitB3Saw=UGen:new{name='BlitB3Saw'}
function BlitB3Saw.ar(...)
	local   freq, leak, mul, add   = assign({ 'freq', 'leak', 'mul', 'add' },{ 440.0, 0.99, 1.0, 0.0 },...)
	return BlitB3Saw:MultiNew{2,freq,leak}:madd(mul,add)
end
SortBuf=UGen:new{name='SortBuf'}
function SortBuf.ar(...)
	local   bufnum, sortrate, reset   = assign({ 'bufnum', 'sortrate', 'reset' },{ 0, 10, 0 },...)
	return SortBuf:MultiNew{2,bufnum,sortrate,reset}
end
Done=UGen:new{name='Done'}
function Done.kr(...)
	local   src   = assign({ 'src' },{ nil },...)
	return Done:MultiNew{1,src}
end
Saw=UGen:new{name='Saw'}
function Saw.kr(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 440.0, 1.0, 0.0 },...)
	return Saw:MultiNew{1,freq}:madd(mul,add)
end
function Saw.ar(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 440.0, 1.0, 0.0 },...)
	return Saw:MultiNew{2,freq}:madd(mul,add)
end
Phasor=UGen:new{name='Phasor'}
function Phasor.kr(...)
	local   trig, rate, start, endp, resetPos   = assign({ 'trig', 'rate', 'start', 'endp', 'resetPos' },{ 0.0, 1.0, 0.0, 1.0, 0.0 },...)
	return Phasor:MultiNew{1,trig,rate,start,endp,resetPos}
end
function Phasor.ar(...)
	local   trig, rate, start, endp, resetPos   = assign({ 'trig', 'rate', 'start', 'endp', 'resetPos' },{ 0.0, 1.0, 0.0, 1.0, 0.0 },...)
	return Phasor:MultiNew{2,trig,rate,start,endp,resetPos}
end
SkipNeedle=UGen:new{name='SkipNeedle'}
function SkipNeedle.ar(...)
	local   range, rate, offset   = assign({ 'range', 'rate', 'offset' },{ 44100, 10, 0 },...)
	return SkipNeedle:MultiNew{2,range,rate,offset}
end
DynKlang=UGen:new{name='DynKlang'}
function DynKlang.kr(...)
	local   specificationsArrayRef, freqscale, freqoffset   = assign({ 'specificationsArrayRef', 'freqscale', 'freqoffset' },{ nil, 1.0, 0.0 },...)
	return DynKlang:MultiNew{1,specificationsArrayRef,freqscale,freqoffset}
end
function DynKlang.ar(...)
	local   specificationsArrayRef, freqscale, freqoffset   = assign({ 'specificationsArrayRef', 'freqscale', 'freqoffset' },{ nil, 1.0, 0.0 },...)
	return DynKlang:MultiNew{2,specificationsArrayRef,freqscale,freqoffset}
end
BowSoundBoard=UGen:new{name='BowSoundBoard'}
function BowSoundBoard.ar(...)
	local   inp, c1, c3, mix, d1, d2, d3, d4, d5, d6, d7, d8   = assign({ 'inp', 'c1', 'c3', 'mix', 'd1', 'd2', 'd3', 'd4', 'd5', 'd6', 'd7', 'd8' },{ 0, 20, 20, 0.8, 199, 211, 223, 227, 229, 233, 239, 241 },...)
	return BowSoundBoard:MultiNew{2,inp,c1,c3,mix,d1,d2,d3,d4,d5,d6,d7,d8}
end
Klank=UGen:new{name='Klank'}
function Klank.ar(...)
	local   specificationsArrayRef, input, freqscale, freqoffset, decayscale   = assign({ 'specificationsArrayRef', 'input', 'freqscale', 'freqoffset', 'decayscale' },{ nil, nil, 1.0, 0.0, 1.0 },...)
	return Klank:MultiNew{2,specificationsArrayRef,input,freqscale,freqoffset,decayscale}
end
Convolution2L=UGen:new{name='Convolution2L'}
function Convolution2L.ar(...)
	local   inp, kernel, trigger, framesize, crossfade, mul, add   = assign({ 'inp', 'kernel', 'trigger', 'framesize', 'crossfade', 'mul', 'add' },{ nil, nil, 0, 2048, 1, 1.0, 0.0 },...)
	return Convolution2L:MultiNew{2,inp,kernel,trigger,framesize,crossfade}:madd(mul,add)
end
BlitB3Square=UGen:new{name='BlitB3Square'}
function BlitB3Square.ar(...)
	local   freq, leak, mul, add   = assign({ 'freq', 'leak', 'mul', 'add' },{ 440.0, 0.99, 1.0, 0.0 },...)
	return BlitB3Square:MultiNew{2,freq,leak}:madd(mul,add)
end
SineShaper=UGen:new{name='SineShaper'}
function SineShaper.ar(...)
	local   inp, limit, mul, add   = assign({ 'inp', 'limit', 'mul', 'add' },{ nil, 1.0, 1.0, 0 },...)
	return SineShaper:MultiNew{2,inp,limit}:madd(mul,add)
end
WalshHadamard=UGen:new{name='WalshHadamard'}
function WalshHadamard.ar(...)
	local   input, which, mul, add   = assign({ 'input', 'which', 'mul', 'add' },{ nil, 0, 1.0, 0.0 },...)
	return WalshHadamard:MultiNew{2,input,which}:madd(mul,add)
end
BufCombN=UGen:new{name='BufCombN'}
function BufCombN.ar(...)
	local   buf, inp, delaytime, decaytime, mul, add   = assign({ 'buf', 'inp', 'delaytime', 'decaytime', 'mul', 'add' },{ 0, 0.0, 0.2, 1.0, 1.0, 0.0 },...)
	return BufCombN:MultiNew{2,buf,inp,delaytime,decaytime}:madd(mul,add)
end
NL2=UGen:new{name='NL2'}
function NL2.ar(...)
	local   input, bufnum, maxsizea, maxsizeb, guard1, guard2, mul, add   = assign({ 'input', 'bufnum', 'maxsizea', 'maxsizeb', 'guard1', 'guard2', 'mul', 'add' },{ nil, 0, 10, 10, 1000.0, 100.0, 1.0, 0.0 },...)
	return NL2:MultiNew{2,input,bufnum,maxsizea,maxsizeb,guard1,guard2}:madd(mul,add)
end
Stepper=UGen:new{name='Stepper'}
function Stepper.kr(...)
	local   trig, reset, min, max, step, resetval   = assign({ 'trig', 'reset', 'min', 'max', 'step', 'resetval' },{ 0, 0, 0, 7, 1, nil },...)
	return Stepper:MultiNew{1,trig,reset,min,max,step,resetval}
end
function Stepper.ar(...)
	local   trig, reset, min, max, step, resetval   = assign({ 'trig', 'reset', 'min', 'max', 'step', 'resetval' },{ 0, 0, 0, 7, 1, nil },...)
	return Stepper:MultiNew{2,trig,reset,min,max,step,resetval}
end
DriveNoise=UGen:new{name='DriveNoise'}
function DriveNoise.ar(...)
	local   inp, amount, multi   = assign({ 'inp', 'amount', 'multi' },{ nil, 1, 5 },...)
	return DriveNoise:MultiNew{2,inp,amount,multi}
end
StkVoicForm=UGen:new{name='StkVoicForm'}
function StkVoicForm.kr(...)
	local   freq, vuvmix, vowelphon, vibfreq, vibgain, loudness, trig, mul, add   = assign({ 'freq', 'vuvmix', 'vowelphon', 'vibfreq', 'vibgain', 'loudness', 'trig', 'mul', 'add' },{ 440, 64, 64, 64, 20, 64, 1, 1.0, 0.0 },...)
	return StkVoicForm:MultiNew{1,freq,vuvmix,vowelphon,vibfreq,vibgain,loudness,trig}:madd(mul,add)
end
function StkVoicForm.ar(...)
	local   freq, vuvmix, vowelphon, vibfreq, vibgain, loudness, trig, mul, add   = assign({ 'freq', 'vuvmix', 'vowelphon', 'vibfreq', 'vibgain', 'loudness', 'trig', 'mul', 'add' },{ 440, 64, 64, 64, 20, 64, 1, 1.0, 0.0 },...)
	return StkVoicForm:MultiNew{2,freq,vuvmix,vowelphon,vibfreq,vibgain,loudness,trig}:madd(mul,add)
end
SinTone=UGen:new{name='SinTone'}
function SinTone.ar(...)
	local   freq, phase, mul, add   = assign({ 'freq', 'phase', 'mul', 'add' },{ 440, 0, 1, 0 },...)
	return SinTone:MultiNew{2,freq,phase}:madd(mul,add)
end
DiskOut=UGen:new{name='DiskOut'}
function DiskOut.ar(...)
	local   bufnum, channelsArray   = assign({ 'bufnum', 'channelsArray' },{ nil, nil },...)
	return DiskOut:MultiNew{2,bufnum,channelsArray}
end
Convolution3=UGen:new{name='Convolution3'}
function Convolution3.kr(...)
	local   inp, kernel, trigger, framesize, mul, add   = assign({ 'inp', 'kernel', 'trigger', 'framesize', 'mul', 'add' },{ nil, nil, 0, 2048, 1.0, 0.0 },...)
	return Convolution3:MultiNew{1,inp,kernel,trigger,framesize}:madd(mul,add)
end
function Convolution3.ar(...)
	local   inp, kernel, trigger, framesize, mul, add   = assign({ 'inp', 'kernel', 'trigger', 'framesize', 'mul', 'add' },{ nil, nil, 0, 2048, 1.0, 0.0 },...)
	return Convolution3:MultiNew{2,inp,kernel,trigger,framesize}:madd(mul,add)
end
InRange=UGen:new{name='InRange'}
function InRange.ir(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ 0.0, 0.0, 1.0 },...)
	return InRange:MultiNew{0,inp,lo,hi}
end
function InRange.kr(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ 0.0, 0.0, 1.0 },...)
	return InRange:MultiNew{1,inp,lo,hi}
end
function InRange.ar(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ 0.0, 0.0, 1.0 },...)
	return InRange:MultiNew{2,inp,lo,hi}
end
ListTrig2=UGen:new{name='ListTrig2'}
function ListTrig2.kr(...)
	local   bufnum, reset, numframes   = assign({ 'bufnum', 'reset', 'numframes' },{ 0, 0, nil },...)
	return ListTrig2:MultiNew{1,bufnum,reset,numframes}
end
LinXFade2=UGen:new{name='LinXFade2'}
function LinXFade2.kr(...)
	local   inA, inB, pan, level   = assign({ 'inA', 'inB', 'pan', 'level' },{ nil, 0.0, 0.0, 1.0 },...)
	return LinXFade2:MultiNew{1,inA,inB,pan,level}
end
function LinXFade2.ar(...)
	local   inA, inB, pan, level   = assign({ 'inA', 'inB', 'pan', 'level' },{ nil, 0.0, 0.0, 1.0 },...)
	return LinXFade2:MultiNew{2,inA,inB,pan,level}
end
StkBandedWG=UGen:new{name='StkBandedWG'}
function StkBandedWG.kr(...)
	local   freq, instr, bowpressure, bowmotion, integration, modalresonance, bowvelocity, setstriking, trig, mul, add   = assign({ 'freq', 'instr', 'bowpressure', 'bowmotion', 'integration', 'modalresonance', 'bowvelocity', 'setstriking', 'trig', 'mul', 'add' },{ 440, 0, 0, 0, 0, 64, 0, 0, 1, 1.0, 0.0 },...)
	return StkBandedWG:MultiNew{1,freq,instr,bowpressure,bowmotion,integration,modalresonance,bowvelocity,setstriking,trig}:madd(mul,add)
end
function StkBandedWG.ar(...)
	local   freq, instr, bowpressure, bowmotion, integration, modalresonance, bowvelocity, setstriking, trig, mul, add   = assign({ 'freq', 'instr', 'bowpressure', 'bowmotion', 'integration', 'modalresonance', 'bowvelocity', 'setstriking', 'trig', 'mul', 'add' },{ 440, 0, 0, 0, 0, 64, 0, 0, 1, 1.0, 0.0 },...)
	return StkBandedWG:MultiNew{2,freq,instr,bowpressure,bowmotion,integration,modalresonance,bowvelocity,setstriking,trig}:madd(mul,add)
end
Trig1=UGen:new{name='Trig1'}
function Trig1.kr(...)
	local   inp, dur   = assign({ 'inp', 'dur' },{ 0.0, 0.1 },...)
	return Trig1:MultiNew{1,inp,dur}
end
function Trig1.ar(...)
	local   inp, dur   = assign({ 'inp', 'dur' },{ 0.0, 0.1 },...)
	return Trig1:MultiNew{2,inp,dur}
end
NLFiltN=UGen:new{name='NLFiltN'}
function NLFiltN.kr(...)
	local   input, a, b, d, c, l, mul, add   = assign({ 'input', 'a', 'b', 'd', 'c', 'l', 'mul', 'add' },{ nil, nil, nil, nil, nil, nil, 1.0, 0.0 },...)
	return NLFiltN:MultiNew{1,input,a,b,d,c,l}:madd(mul,add)
end
function NLFiltN.ar(...)
	local   input, a, b, d, c, l, mul, add   = assign({ 'input', 'a', 'b', 'd', 'c', 'l', 'mul', 'add' },{ nil, nil, nil, nil, nil, nil, 1.0, 0.0 },...)
	return NLFiltN:MultiNew{2,input,a,b,d,c,l}:madd(mul,add)
end
FSinOsc=UGen:new{name='FSinOsc'}
function FSinOsc.kr(...)
	local   freq, iphase, mul, add   = assign({ 'freq', 'iphase', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return FSinOsc:MultiNew{1,freq,iphase}:madd(mul,add)
end
function FSinOsc.ar(...)
	local   freq, iphase, mul, add   = assign({ 'freq', 'iphase', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return FSinOsc:MultiNew{2,freq,iphase}:madd(mul,add)
end
Convolution=UGen:new{name='Convolution'}
function Convolution.ar(...)
	local   inp, kernel, framesize, mul, add   = assign({ 'inp', 'kernel', 'framesize', 'mul', 'add' },{ nil, nil, 512, 1.0, 0.0 },...)
	return Convolution:MultiNew{2,inp,kernel,framesize}:madd(mul,add)
end
Amplitude=UGen:new{name='Amplitude'}
function Amplitude.kr(...)
	local   inp, attackTime, releaseTime, mul, add   = assign({ 'inp', 'attackTime', 'releaseTime', 'mul', 'add' },{ 0.0, 0.01, 0.01, 1.0, 0.0 },...)
	return Amplitude:MultiNew{1,inp,attackTime,releaseTime}:madd(mul,add)
end
function Amplitude.ar(...)
	local   inp, attackTime, releaseTime, mul, add   = assign({ 'inp', 'attackTime', 'releaseTime', 'mul', 'add' },{ 0.0, 0.01, 0.01, 1.0, 0.0 },...)
	return Amplitude:MultiNew{2,inp,attackTime,releaseTime}:madd(mul,add)
end
Crest=UGen:new{name='Crest'}
function Crest.kr(...)
	local   inp, numsamps, gate, mul, add   = assign({ 'inp', 'numsamps', 'gate', 'mul', 'add' },{ nil, 400, 1, 1, 0 },...)
	return Crest:MultiNew{1,inp,numsamps,gate}:madd(mul,add)
end
Timer=UGen:new{name='Timer'}
function Timer.kr(...)
	local   trig   = assign({ 'trig' },{ 0.0 },...)
	return Timer:MultiNew{1,trig}
end
function Timer.ar(...)
	local   trig   = assign({ 'trig' },{ 0.0 },...)
	return Timer:MultiNew{2,trig}
end
CombLP=UGen:new{name='CombLP'}
function CombLP.ar(...)
	local   inp, gate, maxdelaytime, delaytime, decaytime, coef, mul, add   = assign({ 'inp', 'gate', 'maxdelaytime', 'delaytime', 'decaytime', 'coef', 'mul', 'add' },{ 0.0, 1.0, 0.2, 0.2, 1.0, 0.5, 1.0, 0.0 },...)
	return CombLP:MultiNew{2,inp,gate,maxdelaytime,delaytime,decaytime,coef}:madd(mul,add)
end
AnalyseEvents2=UGen:new{name='AnalyseEvents2'}
function AnalyseEvents2.ar(...)
	local   inp, bufnum, threshold, triggerid, circular, pitch   = assign({ 'inp', 'bufnum', 'threshold', 'triggerid', 'circular', 'pitch' },{ nil, 0, 0.34, 101, 0, 0 },...)
	return AnalyseEvents2:MultiNew{2,inp,bufnum,threshold,triggerid,circular,pitch}
end
PureUGen=UGen:new{name='PureUGen'}
function PureUGen.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return PureUGen:MultiNew{2,maxSize}
end
DoubleWell2=UGen:new{name='DoubleWell2'}
function DoubleWell2.ar(...)
	local   reset, ratex, ratey, f, w, delta, initx, inity, mul, add   = assign({ 'reset', 'ratex', 'ratey', 'f', 'w', 'delta', 'initx', 'inity', 'mul', 'add' },{ 0, 0.01, 0.01, 1, 0.001, 1, 0, 0, 1.0, 0.0 },...)
	return DoubleWell2:MultiNew{2,reset,ratex,ratey,f,w,delta,initx,inity}:madd(mul,add)
end
Gbman2DN=UGen:new{name='Gbman2DN'}
function Gbman2DN.kr(...)
	local   minfreq, maxfreq, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'x0', 'y0', 'mul', 'add' },{ 40, 100, 1.2, 2.1, 1, 0.0 },...)
	return Gbman2DN:MultiNew{1,minfreq,maxfreq,x0,y0}:madd(mul,add)
end
function Gbman2DN.ar(...)
	local   minfreq, maxfreq, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'x0', 'y0', 'mul', 'add' },{ 11025, 22050, 1.2, 2.1, 1, 0.0 },...)
	return Gbman2DN:MultiNew{2,minfreq,maxfreq,x0,y0}:madd(mul,add)
end
EnvDetect=UGen:new{name='EnvDetect'}
function EnvDetect.ar(...)
	local   inp, attack, release   = assign({ 'inp', 'attack', 'release' },{ nil, 100, 0 },...)
	return EnvDetect:MultiNew{2,inp,attack,release}
end
MouseX=UGen:new{name='MouseX'}
function MouseX.kr(...)
	local   minval, maxval, warp, lag   = assign({ 'minval', 'maxval', 'warp', 'lag' },{ 0, 1, 0, 0.2 },...)
	return MouseX:MultiNew{1,minval,maxval,warp,lag}
end
PeakEQ2=UGen:new{name='PeakEQ2'}
function PeakEQ2.ar(...)
	local   inp, freq, rs, db   = assign({ 'inp', 'freq', 'rs', 'db' },{ nil, 1200.0, 1.0, 0.0 },...)
	return PeakEQ2:MultiNew{2,inp,freq,rs,db}
end
Poll=UGen:new{name='Poll'}
function Poll.kr(...)
	local   trig, inp, label, trigid   = assign({ 'trig', 'inp', 'label', 'trigid' },{ nil, nil, nil, -1 },...)
	return Poll:MultiNew{1,trig,inp,label,trigid}
end
function Poll.ar(...)
	local   trig, inp, label, trigid   = assign({ 'trig', 'inp', 'label', 'trigid' },{ nil, nil, nil, -1 },...)
	return Poll:MultiNew{2,trig,inp,label,trigid}
end
RLPFD=UGen:new{name='RLPFD'}
function RLPFD.kr(...)
	local   inp, ffreq, res, dist, mul, add   = assign({ 'inp', 'ffreq', 'res', 'dist', 'mul', 'add' },{ nil, 440.0, 0.0, 0.0, 1.0, 0.0 },...)
	return RLPFD:MultiNew{1,inp,ffreq,res,dist}:madd(mul,add)
end
function RLPFD.ar(...)
	local   inp, ffreq, res, dist, mul, add   = assign({ 'inp', 'ffreq', 'res', 'dist', 'mul', 'add' },{ nil, 440.0, 0.0, 0.0, 1.0, 0.0 },...)
	return RLPFD:MultiNew{2,inp,ffreq,res,dist}:madd(mul,add)
end
FrameCompare=UGen:new{name='FrameCompare'}
function FrameCompare.kr(...)
	local   buffer1, buffer2, wAmount   = assign({ 'buffer1', 'buffer2', 'wAmount' },{ nil, nil, 0.5 },...)
	return FrameCompare:MultiNew{1,buffer1,buffer2,wAmount}
end
Decimator=UGen:new{name='Decimator'}
function Decimator.ar(...)
	local   inp, rate, bits, mul, add   = assign({ 'inp', 'rate', 'bits', 'mul', 'add' },{ nil, 44100.0, 24, 1.0, 0 },...)
	return Decimator:MultiNew{2,inp,rate,bits}:madd(mul,add)
end
LFBrownNoise0=UGen:new{name='LFBrownNoise0'}
function LFBrownNoise0.kr(...)
	local   freq, dev, dist, mul, add   = assign({ 'freq', 'dev', 'dist', 'mul', 'add' },{ 20, 1.0, 0, 1.0, 0.0 },...)
	return LFBrownNoise0:MultiNew{1,freq,dev,dist}:madd(mul,add)
end
function LFBrownNoise0.ar(...)
	local   freq, dev, dist, mul, add   = assign({ 'freq', 'dev', 'dist', 'mul', 'add' },{ 20, 1.0, 0, 1.0, 0.0 },...)
	return LFBrownNoise0:MultiNew{2,freq,dev,dist}:madd(mul,add)
end
TrigAvg=UGen:new{name='TrigAvg'}
function TrigAvg.kr(...)
	local   inp, trig   = assign({ 'inp', 'trig' },{ 0.0, 0 },...)
	return TrigAvg:MultiNew{1,inp,trig}
end
DWGPlucked2=UGen:new{name='DWGPlucked2'}
function DWGPlucked2.ar(...)
	local   freq, amp, gate, pos, c1, c3, inp, release, mistune, mp, gc   = assign({ 'freq', 'amp', 'gate', 'pos', 'c1', 'c3', 'inp', 'release', 'mistune', 'mp', 'gc' },{ 440, 0.5, 1, 0.14, 1, 30, 0, 0.1, 1.008, 0.55, 0.01 },...)
	return DWGPlucked2:MultiNew{2,freq,amp,gate,pos,c1,c3,inp,release,mistune,mp,gc}
end
ChaosGen=UGen:new{name='ChaosGen'}
function ChaosGen.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return ChaosGen:MultiNew{2,maxSize}
end
PV_SoftWipe=UGen:new{name='PV_SoftWipe'}
function PV_SoftWipe.create(...)
	local   bufferA, bufferB, wipe   = assign({ 'bufferA', 'bufferB', 'wipe' },{ nil, nil, 0.0 },...)
	return PV_SoftWipe:MultiNew{1,bufferA,bufferB,wipe}
end
TGaussRand=UGen:new{name='TGaussRand'}
function TGaussRand.kr(...)
	local   lo, hi, trig, mul, add   = assign({ 'lo', 'hi', 'trig', 'mul', 'add' },{ 0, 1.0, 0, 1.0, 0.0 },...)
	return TGaussRand:MultiNew{1,lo,hi,trig}:madd(mul,add)
end
function TGaussRand.ar(...)
	local   lo, hi, trig, mul, add   = assign({ 'lo', 'hi', 'trig', 'mul', 'add' },{ 0, 1.0, 0, 1.0, 0.0 },...)
	return TGaussRand:MultiNew{2,lo,hi,trig}:madd(mul,add)
end
Gendy4=UGen:new{name='Gendy4'}
function Gendy4.kr(...)
	local   ampdist, durdist, adparam, ddparam, minfreq, maxfreq, ampscale, durscale, initCPs, knum, mul, add   = assign({ 'ampdist', 'durdist', 'adparam', 'ddparam', 'minfreq', 'maxfreq', 'ampscale', 'durscale', 'initCPs', 'knum', 'mul', 'add' },{ 1, 1, 1.0, 1.0, 20, 1000, 0.5, 0.5, 12, nil, 1.0, 0.0 },...)
	return Gendy4:MultiNew{1,ampdist,durdist,adparam,ddparam,minfreq,maxfreq,ampscale,durscale,initCPs,knum}:madd(mul,add)
end
function Gendy4.ar(...)
	local   ampdist, durdist, adparam, ddparam, minfreq, maxfreq, ampscale, durscale, initCPs, knum, mul, add   = assign({ 'ampdist', 'durdist', 'adparam', 'ddparam', 'minfreq', 'maxfreq', 'ampscale', 'durscale', 'initCPs', 'knum', 'mul', 'add' },{ 1, 1, 1.0, 1.0, 440, 660, 0.5, 0.5, 12, nil, 1.0, 0.0 },...)
	return Gendy4:MultiNew{2,ampdist,durdist,adparam,ddparam,minfreq,maxfreq,ampscale,durscale,initCPs,knum}:madd(mul,add)
end
StkSaxofony=UGen:new{name='StkSaxofony'}
function StkSaxofony.kr(...)
	local   freq, reedstiffness, reedaperture, noisegain, blowposition, vibratofrequency, vibratogain, breathpressure, trig, mul, add   = assign({ 'freq', 'reedstiffness', 'reedaperture', 'noisegain', 'blowposition', 'vibratofrequency', 'vibratogain', 'breathpressure', 'trig', 'mul', 'add' },{ 220, 64, 64, 20, 26, 20, 20, 128, 1, 1.0, 0.0 },...)
	return StkSaxofony:MultiNew{1,freq,reedstiffness,reedaperture,noisegain,blowposition,vibratofrequency,vibratogain,breathpressure,trig}:madd(mul,add)
end
function StkSaxofony.ar(...)
	local   freq, reedstiffness, reedaperture, noisegain, blowposition, vibratofrequency, vibratogain, breathpressure, trig, mul, add   = assign({ 'freq', 'reedstiffness', 'reedaperture', 'noisegain', 'blowposition', 'vibratofrequency', 'vibratogain', 'breathpressure', 'trig', 'mul', 'add' },{ 220, 64, 64, 20, 26, 20, 20, 128, 1, 1.0, 0.0 },...)
	return StkSaxofony:MultiNew{2,freq,reedstiffness,reedaperture,noisegain,blowposition,vibratofrequency,vibratogain,breathpressure,trig}:madd(mul,add)
end
TWindex=UGen:new{name='TWindex'}
function TWindex.kr(...)
	local   inp, array, normalize   = assign({ 'inp', 'array', 'normalize' },{ nil, nil, 0 },...)
	return TWindex:MultiNew{1,inp,array,normalize}
end
function TWindex.ar(...)
	local   inp, array, normalize   = assign({ 'inp', 'array', 'normalize' },{ nil, nil, 0 },...)
	return TWindex:MultiNew{2,inp,array,normalize}
end
WaveletDaub=UGen:new{name='WaveletDaub'}
function WaveletDaub.ar(...)
	local   input, n, which, mul, add   = assign({ 'input', 'n', 'which', 'mul', 'add' },{ nil, 64, 0, 1.0, 0.0 },...)
	return WaveletDaub:MultiNew{2,input,n,which}:madd(mul,add)
end
LFGauss=UGen:new{name='LFGauss'}
function LFGauss.kr(...)
	local   duration, width, iphase, loop, doneAction   = assign({ 'duration', 'width', 'iphase', 'loop', 'doneAction' },{ 1, 0.1, 0.0, 1, 0 },...)
	return LFGauss:MultiNew{1,duration,width,iphase,loop,doneAction}
end
function LFGauss.ar(...)
	local   duration, width, iphase, loop, doneAction   = assign({ 'duration', 'width', 'iphase', 'loop', 'doneAction' },{ 1, 0.1, 0.0, 1, 0 },...)
	return LFGauss:MultiNew{2,duration,width,iphase,loop,doneAction}
end
FFTCentroid=UGen:new{name='FFTCentroid'}
function FFTCentroid.kr(...)
	local   buffer   = assign({ 'buffer' },{ nil },...)
	return FFTCentroid:MultiNew{1,buffer}
end
StkMoog=UGen:new{name='StkMoog'}
function StkMoog.kr(...)
	local   freq, filterQ, sweeprate, vibfreq, vibgain, gain, trig, mul, add   = assign({ 'freq', 'filterQ', 'sweeprate', 'vibfreq', 'vibgain', 'gain', 'trig', 'mul', 'add' },{ 440, 10, 20, 64, 0, 64, 1, 1.0, 0.0 },...)
	return StkMoog:MultiNew{1,freq,filterQ,sweeprate,vibfreq,vibgain,gain,trig}:madd(mul,add)
end
function StkMoog.ar(...)
	local   freq, filterQ, sweeprate, vibfreq, vibgain, gain, trig, mul, add   = assign({ 'freq', 'filterQ', 'sweeprate', 'vibfreq', 'vibgain', 'gain', 'trig', 'mul', 'add' },{ 440, 10, 20, 64, 0, 64, 1, 1.0, 0.0 },...)
	return StkMoog:MultiNew{2,freq,filterQ,sweeprate,vibfreq,vibgain,gain,trig}:madd(mul,add)
end
FFTFlux=UGen:new{name='FFTFlux'}
function FFTFlux.kr(...)
	local   buffer, normalise   = assign({ 'buffer', 'normalise' },{ nil, 1 },...)
	return FFTFlux:MultiNew{1,buffer,normalise}
end
Max=UGen:new{name='Max'}
function Max.kr(...)
	local   inp, numsamp   = assign({ 'inp', 'numsamp' },{ nil, 64 },...)
	return Max:MultiNew{1,inp,numsamp}
end
LocalOut=Out:new{name='LocalOut'}
function LocalOut.kr(...)
	local   channelsArray   = assign({ 'channelsArray' },{ nil },...)
	return LocalOut:donew(1,channelsArray)
end
function LocalOut.ar(...)
	local   channelsArray   = assign({ 'channelsArray' },{ nil },...)
	return LocalOut:donew(2,channelsArray)
end
XOut=Out:new{name='XOut'}
function XOut.kr(...)
	local   bus, xfade, channelsArray   = assign({ 'bus', 'xfade', 'channelsArray' },{ nil, nil, nil },...)
	return XOut:donew(1,bus,xfade,channelsArray)
end
function XOut.ar(...)
	local   bus, xfade, channelsArray   = assign({ 'bus', 'xfade', 'channelsArray' },{ nil, nil, nil },...)
	return XOut:donew(2,bus,xfade,channelsArray)
end
SharedOut=Out:new{name='SharedOut'}
function SharedOut.kr(...)
	local   bus, channelsArray   = assign({ 'bus', 'channelsArray' },{ nil, nil },...)
	return SharedOut:donew(1,bus,channelsArray)
end
OffsetOut=Out:new{name='OffsetOut'}
function OffsetOut.kr(...)
		return OffsetOut:donew(1)
end
function OffsetOut.ar(...)
	local   bus, channelsArray   = assign({ 'bus', 'channelsArray' },{ nil, nil },...)
	return OffsetOut:donew(2,bus,channelsArray)
end
ReplaceOut=Out:new{name='ReplaceOut'}
function ReplaceOut.kr(...)
	local   bus, channelsArray   = assign({ 'bus', 'channelsArray' },{ nil, nil },...)
	return ReplaceOut:donew(1,bus,channelsArray)
end
function ReplaceOut.ar(...)
	local   bus, channelsArray   = assign({ 'bus', 'channelsArray' },{ nil, nil },...)
	return ReplaceOut:donew(2,bus,channelsArray)
end
AtsNoiSynth=UGen:new{name='AtsNoiSynth'}
function AtsNoiSynth.ar(...)
	local   atsbuffer, numPartials, partialStart, partialSkip, filePointer, sinePct, noisePct, freqMul, freqAdd, numBands, bandStart, bandSkip, mul, add   = assign({ 'atsbuffer', 'numPartials', 'partialStart', 'partialSkip', 'filePointer', 'sinePct', 'noisePct', 'freqMul', 'freqAdd', 'numBands', 'bandStart', 'bandSkip', 'mul', 'add' },{ nil, 0, 0, 1, 0, 1.0, 1.0, 1.0, 0.0, 25, 0, 1, 1.0, 0.0 },...)
	return AtsNoiSynth:MultiNew{2,atsbuffer,numPartials,partialStart,partialSkip,filePointer,sinePct,noisePct,freqMul,freqAdd,numBands,bandStart,bandSkip}:madd(mul,add)
end
AtsNoise=UGen:new{name='AtsNoise'}
function AtsNoise.kr(...)
	local   atsbuffer, bandNum, filePointer, mul, add   = assign({ 'atsbuffer', 'bandNum', 'filePointer', 'mul', 'add' },{ nil, 0, 0, 1, 0 },...)
	return AtsNoise:MultiNew{1,atsbuffer,bandNum,filePointer}:madd(mul,add)
end
function AtsNoise.ar(...)
	local   atsbuffer, bandNum, filePointer, mul, add   = assign({ 'atsbuffer', 'bandNum', 'filePointer', 'mul', 'add' },{ nil, 0, 0, 1, 0 },...)
	return AtsNoise:MultiNew{2,atsbuffer,bandNum,filePointer}:madd(mul,add)
end
AtsSynth=UGen:new{name='AtsSynth'}
function AtsSynth.ar(...)
	local   atsbuffer, numPartials, partialStart, partialSkip, filePointer, freqMul, freqAdd, mul, add   = assign({ 'atsbuffer', 'numPartials', 'partialStart', 'partialSkip', 'filePointer', 'freqMul', 'freqAdd', 'mul', 'add' },{ nil, 0, 0, 1, 0, 1.0, 0.0, 1.0, 0.0 },...)
	return AtsSynth:MultiNew{2,atsbuffer,numPartials,partialStart,partialSkip,filePointer,freqMul,freqAdd}:madd(mul,add)
end
AtsAmp=UGen:new{name='AtsAmp'}
function AtsAmp.kr(...)
	local   atsbuffer, partialNum, filePointer, mul, add   = assign({ 'atsbuffer', 'partialNum', 'filePointer', 'mul', 'add' },{ nil, 0, 0, 1, 0 },...)
	return AtsAmp:MultiNew{1,atsbuffer,partialNum,filePointer}:madd(mul,add)
end
function AtsAmp.ar(...)
	local   atsbuffer, partialNum, filePointer, mul, add   = assign({ 'atsbuffer', 'partialNum', 'filePointer', 'mul', 'add' },{ nil, 0, 0, 1, 0 },...)
	return AtsAmp:MultiNew{2,atsbuffer,partialNum,filePointer}:madd(mul,add)
end
AtsBand=UGen:new{name='AtsBand'}
function AtsBand.ar(...)
	local   atsbuffer, band, filePointer, mul, add   = assign({ 'atsbuffer', 'band', 'filePointer', 'mul', 'add' },{ nil, nil, 0, 1.0, 0.0 },...)
	return AtsBand:MultiNew{2,atsbuffer,band,filePointer}:madd(mul,add)
end
AtsFreq=UGen:new{name='AtsFreq'}
function AtsFreq.kr(...)
	local   atsbuffer, partialNum, filePointer, mul, add   = assign({ 'atsbuffer', 'partialNum', 'filePointer', 'mul', 'add' },{ nil, 0, 0, 1, 0 },...)
	return AtsFreq:MultiNew{1,atsbuffer,partialNum,filePointer}:madd(mul,add)
end
function AtsFreq.ar(...)
	local   atsbuffer, partialNum, filePointer, mul, add   = assign({ 'atsbuffer', 'partialNum', 'filePointer', 'mul', 'add' },{ nil, 0, 0, 1, 0 },...)
	return AtsFreq:MultiNew{2,atsbuffer,partialNum,filePointer}:madd(mul,add)
end
AtsPartial=UGen:new{name='AtsPartial'}
function AtsPartial.ar(...)
	local   atsbuffer, partial, filePointer, freqMul, freqAdd, mul, add   = assign({ 'atsbuffer', 'partial', 'filePointer', 'freqMul', 'freqAdd', 'mul', 'add' },{ nil, nil, 0, 1.0, 0.0, 1.0, 0.0 },...)
	return AtsPartial:MultiNew{2,atsbuffer,partial,filePointer,freqMul,freqAdd}:madd(mul,add)
end
SetResetFF=UGen:new{name='SetResetFF'}
function SetResetFF.kr(...)
	local   trig, reset   = assign({ 'trig', 'reset' },{ 0.0, 0.0 },...)
	return SetResetFF:MultiNew{1,trig,reset}
end
function SetResetFF.ar(...)
	local   trig, reset   = assign({ 'trig', 'reset' },{ 0.0, 0.0 },...)
	return SetResetFF:MultiNew{2,trig,reset}
end
RadiansPerSample=UGen:new{name='RadiansPerSample'}
function RadiansPerSample.ir(...)
		return RadiansPerSample:MultiNew{0}
end
NumRunningSynths=UGen:new{name='NumRunningSynths'}
function NumRunningSynths.ir(...)
		return NumRunningSynths:MultiNew{0}
end
function NumRunningSynths.kr(...)
		return NumRunningSynths:MultiNew{1}
end
SampleDur=UGen:new{name='SampleDur'}
function SampleDur.ir(...)
		return SampleDur:MultiNew{0}
end
NumBuffers=UGen:new{name='NumBuffers'}
function NumBuffers.ir(...)
		return NumBuffers:MultiNew{0}
end
ControlDur=UGen:new{name='ControlDur'}
function ControlDur.ir(...)
		return ControlDur:MultiNew{0}
end
ControlRate=UGen:new{name='ControlRate'}
function ControlRate.ir(...)
		return ControlRate:MultiNew{0}
end
NumInputBuses=UGen:new{name='NumInputBuses'}
function NumInputBuses.ir(...)
		return NumInputBuses:MultiNew{0}
end
NumControlBuses=UGen:new{name='NumControlBuses'}
function NumControlBuses.ir(...)
		return NumControlBuses:MultiNew{0}
end
SubsampleOffset=UGen:new{name='SubsampleOffset'}
function SubsampleOffset.ir(...)
		return SubsampleOffset:MultiNew{0}
end
NumAudioBuses=UGen:new{name='NumAudioBuses'}
function NumAudioBuses.ir(...)
		return NumAudioBuses:MultiNew{0}
end
SampleRate=UGen:new{name='SampleRate'}
function SampleRate.ir(...)
		return SampleRate:MultiNew{0}
end
NumOutputBuses=UGen:new{name='NumOutputBuses'}
function NumOutputBuses.ir(...)
		return NumOutputBuses:MultiNew{0}
end
SendReply=UGen:new{name='SendReply'}
function SendReply.kr(...)
	local   trig, cmdName, values, replyID   = assign({ 'trig', 'cmdName', 'values', 'replyID' },{ 0.0, '/reply', nil, -1 },...)
	return SendReply:MultiNew{1,trig,cmdName,values,replyID}
end
function SendReply.ar(...)
	local   trig, cmdName, values, replyID   = assign({ 'trig', 'cmdName', 'values', 'replyID' },{ 0.0, '/reply', nil, -1 },...)
	return SendReply:MultiNew{2,trig,cmdName,values,replyID}
end
PV_CommonMul=UGen:new{name='PV_CommonMul'}
function PV_CommonMul.create(...)
	local   bufferA, bufferB, tolerance, remove   = assign({ 'bufferA', 'bufferB', 'tolerance', 'remove' },{ nil, nil, 0.0, 0.0 },...)
	return PV_CommonMul:MultiNew{1,bufferA,bufferB,tolerance,remove}
end
BufChannels=UGen:new{name='BufChannels'}
function BufChannels.ir(...)
	local   bufnum   = assign({ 'bufnum' },{ nil },...)
	return BufChannels:MultiNew{0,bufnum}
end
function BufChannels.kr(...)
	local   bufnum   = assign({ 'bufnum' },{ nil },...)
	return BufChannels:MultiNew{1,bufnum}
end
BufFrames=UGen:new{name='BufFrames'}
function BufFrames.ir(...)
	local   bufnum   = assign({ 'bufnum' },{ nil },...)
	return BufFrames:MultiNew{0,bufnum}
end
function BufFrames.kr(...)
	local   bufnum   = assign({ 'bufnum' },{ nil },...)
	return BufFrames:MultiNew{1,bufnum}
end
BufDur=UGen:new{name='BufDur'}
function BufDur.ir(...)
	local   bufnum   = assign({ 'bufnum' },{ nil },...)
	return BufDur:MultiNew{0,bufnum}
end
function BufDur.kr(...)
	local   bufnum   = assign({ 'bufnum' },{ nil },...)
	return BufDur:MultiNew{1,bufnum}
end
BufSamples=UGen:new{name='BufSamples'}
function BufSamples.ir(...)
	local   bufnum   = assign({ 'bufnum' },{ nil },...)
	return BufSamples:MultiNew{0,bufnum}
end
function BufSamples.kr(...)
	local   bufnum   = assign({ 'bufnum' },{ nil },...)
	return BufSamples:MultiNew{1,bufnum}
end
BufSampleRate=UGen:new{name='BufSampleRate'}
function BufSampleRate.ir(...)
	local   bufnum   = assign({ 'bufnum' },{ nil },...)
	return BufSampleRate:MultiNew{0,bufnum}
end
function BufSampleRate.kr(...)
	local   bufnum   = assign({ 'bufnum' },{ nil },...)
	return BufSampleRate:MultiNew{1,bufnum}
end
BufRateScale=UGen:new{name='BufRateScale'}
function BufRateScale.ir(...)
	local   bufnum   = assign({ 'bufnum' },{ nil },...)
	return BufRateScale:MultiNew{0,bufnum}
end
function BufRateScale.kr(...)
	local   bufnum   = assign({ 'bufnum' },{ nil },...)
	return BufRateScale:MultiNew{1,bufnum}
end
Latoocarfian2DC=UGen:new{name='Latoocarfian2DC'}
function Latoocarfian2DC.kr(...)
	local   minfreq, maxfreq, a, b, c, d, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'a', 'b', 'c', 'd', 'x0', 'y0', 'mul', 'add' },{ 40, 100, 1, 3, 0.5, 0.5, 0.34082301375036, -0.38270086971332, 1, 0.0 },...)
	return Latoocarfian2DC:MultiNew{1,minfreq,maxfreq,a,b,c,d,x0,y0}:madd(mul,add)
end
function Latoocarfian2DC.ar(...)
	local   minfreq, maxfreq, a, b, c, d, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'a', 'b', 'c', 'd', 'x0', 'y0', 'mul', 'add' },{ 11025, 22050, 1, 3, 0.5, 0.5, 0.34082301375036, -0.38270086971332, 1, 0.0 },...)
	return Latoocarfian2DC:MultiNew{2,minfreq,maxfreq,a,b,c,d,x0,y0}:madd(mul,add)
end
Latoocarfian2DL=UGen:new{name='Latoocarfian2DL'}
function Latoocarfian2DL.kr(...)
	local   minfreq, maxfreq, a, b, c, d, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'a', 'b', 'c', 'd', 'x0', 'y0', 'mul', 'add' },{ 40, 100, 1, 3, 0.5, 0.5, 0.34082301375036, -0.38270086971332, 1, 0.0 },...)
	return Latoocarfian2DL:MultiNew{1,minfreq,maxfreq,a,b,c,d,x0,y0}:madd(mul,add)
end
function Latoocarfian2DL.ar(...)
	local   minfreq, maxfreq, a, b, c, d, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'a', 'b', 'c', 'd', 'x0', 'y0', 'mul', 'add' },{ 11025, 22050, 1, 3, 0.5, 0.5, 0.34082301375036, -0.38270086971332, 1, 0.0 },...)
	return Latoocarfian2DL:MultiNew{2,minfreq,maxfreq,a,b,c,d,x0,y0}:madd(mul,add)
end
ChuaL=UGen:new{name='ChuaL'}
function ChuaL.ar(...)
	local   freq, a, b, c, d, rr, h, xi, yi, zi, mul, add   = assign({ 'freq', 'a', 'b', 'c', 'd', 'rr', 'h', 'xi', 'yi', 'zi', 'mul', 'add' },{ 22050, 0.3286, 0.9336, -0.8126, 0.399, nil, 0.05, 0.1, 0, 0, 1.0, 0.0 },...)
	return ChuaL:MultiNew{2,freq,a,b,c,d,rr,h,xi,yi,zi}:madd(mul,add)
end
RosslerResL=UGen:new{name='RosslerResL'}
function RosslerResL.ar(...)
	local   inp, stiff, freq, a, b, c, h, xi, yi, zi, mul, add   = assign({ 'inp', 'stiff', 'freq', 'a', 'b', 'c', 'h', 'xi', 'yi', 'zi', 'mul', 'add' },{ nil, 1.0, 22050, 0.2, 0.2, 5.7, 0.05, 0.1, 0, 0, 1.0, 0.0 },...)
	return RosslerResL:MultiNew{2,inp,stiff,freq,a,b,c,h,xi,yi,zi}:madd(mul,add)
end
Gate=UGen:new{name='Gate'}
function Gate.kr(...)
	local   inp, trig   = assign({ 'inp', 'trig' },{ 0.0, 0.0 },...)
	return Gate:MultiNew{1,inp,trig}
end
function Gate.ar(...)
	local   inp, trig   = assign({ 'inp', 'trig' },{ 0.0, 0.0 },...)
	return Gate:MultiNew{2,inp,trig}
end
BFDecode1=UGen:new{name='BFDecode1'}
function BFDecode1.ar(...)
	local   w, x, y, z, azimuth, elevation, wComp, mul, add   = assign({ 'w', 'x', 'y', 'z', 'azimuth', 'elevation', 'wComp', 'mul', 'add' },{ nil, nil, nil, nil, 0, 0, 0, 1, 0 },...)
	return BFDecode1:MultiNew{2,w,x,y,z,azimuth,elevation,wComp}:madd(mul,add)
end
FMHDecode1=UGen:new{name='FMHDecode1'}
function FMHDecode1.ar(...)
	local   w, x, y, z, r, s, t, u, v, azimuth, elevation, mul, add   = assign({ 'w', 'x', 'y', 'z', 'r', 's', 't', 'u', 'v', 'azimuth', 'elevation', 'mul', 'add' },{ nil, nil, nil, nil, nil, nil, nil, nil, nil, 0, 0, 1, 0 },...)
	return FMHDecode1:MultiNew{2,w,x,y,z,r,s,t,u,v,azimuth,elevation}:madd(mul,add)
end
RunningMin=UGen:new{name='RunningMin'}
function RunningMin.kr(...)
	local   inp, trig   = assign({ 'inp', 'trig' },{ 0.0, 0.0 },...)
	return RunningMin:MultiNew{1,inp,trig}
end
function RunningMin.ar(...)
	local   inp, trig   = assign({ 'inp', 'trig' },{ 0.0, 0.0 },...)
	return RunningMin:MultiNew{2,inp,trig}
end
RunningMax=UGen:new{name='RunningMax'}
function RunningMax.kr(...)
	local   inp, trig   = assign({ 'inp', 'trig' },{ 0.0, 0.0 },...)
	return RunningMax:MultiNew{1,inp,trig}
end
function RunningMax.ar(...)
	local   inp, trig   = assign({ 'inp', 'trig' },{ 0.0, 0.0 },...)
	return RunningMax:MultiNew{2,inp,trig}
end
SinGrain=UGen:new{name='SinGrain'}
function SinGrain.ar(...)
	local   trigger, dur, freq, mul, add   = assign({ 'trigger', 'dur', 'freq', 'mul', 'add' },{ 0, 1, 440, 1, 0 },...)
	return SinGrain:MultiNew{2,trigger,dur,freq}:madd(mul,add)
end
InGrain=UGen:new{name='InGrain'}
function InGrain.ar(...)
	local   trigger, dur, inp, mul, add   = assign({ 'trigger', 'dur', 'inp', 'mul', 'add' },{ 0, 1, nil, 1, 0 },...)
	return InGrain:MultiNew{2,trigger,dur,inp}:madd(mul,add)
end
FMGrainB=UGen:new{name='FMGrainB'}
function FMGrainB.ar(...)
	local   trigger, dur, carfreq, modfreq, index, envbuf, mul, add   = assign({ 'trigger', 'dur', 'carfreq', 'modfreq', 'index', 'envbuf', 'mul', 'add' },{ 0, 1, 440, 200, 1, nil, 1, 0 },...)
	return FMGrainB:MultiNew{2,trigger,dur,carfreq,modfreq,index,envbuf}:madd(mul,add)
end
FMGrainI=UGen:new{name='FMGrainI'}
function FMGrainI.ar(...)
	local   trigger, dur, carfreq, modfreq, index, envbuf1, envbuf2, ifac, mul, add   = assign({ 'trigger', 'dur', 'carfreq', 'modfreq', 'index', 'envbuf1', 'envbuf2', 'ifac', 'mul', 'add' },{ 0, 1, 440, 200, 1, nil, nil, 0.5, 1, 0 },...)
	return FMGrainI:MultiNew{2,trigger,dur,carfreq,modfreq,index,envbuf1,envbuf2,ifac}:madd(mul,add)
end
InGrainI=UGen:new{name='InGrainI'}
function InGrainI.ar(...)
	local   trigger, dur, inp, envbuf1, envbuf2, ifac, mul, add   = assign({ 'trigger', 'dur', 'inp', 'envbuf1', 'envbuf2', 'ifac', 'mul', 'add' },{ 0, 1, nil, nil, nil, 0.5, 1, 0 },...)
	return InGrainI:MultiNew{2,trigger,dur,inp,envbuf1,envbuf2,ifac}:madd(mul,add)
end
SinGrainB=UGen:new{name='SinGrainB'}
function SinGrainB.ar(...)
	local   trigger, dur, freq, envbuf, mul, add   = assign({ 'trigger', 'dur', 'freq', 'envbuf', 'mul', 'add' },{ 0, 1, 440, nil, 1, 0 },...)
	return SinGrainB:MultiNew{2,trigger,dur,freq,envbuf}:madd(mul,add)
end
FMGrain=UGen:new{name='FMGrain'}
function FMGrain.ar(...)
	local   trigger, dur, carfreq, modfreq, index, mul, add   = assign({ 'trigger', 'dur', 'carfreq', 'modfreq', 'index', 'mul', 'add' },{ 0, 1, 440, 200, 1, 1, 0 },...)
	return FMGrain:MultiNew{2,trigger,dur,carfreq,modfreq,index}:madd(mul,add)
end
InGrainB=UGen:new{name='InGrainB'}
function InGrainB.ar(...)
	local   trigger, dur, inp, envbuf, mul, add   = assign({ 'trigger', 'dur', 'inp', 'envbuf', 'mul', 'add' },{ 0, 1, nil, nil, 1, 0 },...)
	return InGrainB:MultiNew{2,trigger,dur,inp,envbuf}:madd(mul,add)
end
SinGrainI=UGen:new{name='SinGrainI'}
function SinGrainI.ar(...)
	local   trigger, dur, freq, envbuf1, envbuf2, ifac, mul, add   = assign({ 'trigger', 'dur', 'freq', 'envbuf1', 'envbuf2', 'ifac', 'mul', 'add' },{ 0, 1, 440, nil, nil, 0.5, 1, 0 },...)
	return SinGrainI:MultiNew{2,trigger,dur,freq,envbuf1,envbuf2,ifac}:madd(mul,add)
end
BufGrain=UGen:new{name='BufGrain'}
function BufGrain.ar(...)
	local   trigger, dur, sndbuf, rate, pos, interp, mul, add   = assign({ 'trigger', 'dur', 'sndbuf', 'rate', 'pos', 'interp', 'mul', 'add' },{ 0, 1, nil, 1, 0, 2, 1, 0 },...)
	return BufGrain:MultiNew{2,trigger,dur,sndbuf,rate,pos,interp}:madd(mul,add)
end
MonoGrain=UGen:new{name='MonoGrain'}
function MonoGrain.ar(...)
	local   inp, winsize, grainrate, winrandpct, mul, add   = assign({ 'inp', 'winsize', 'grainrate', 'winrandpct', 'mul', 'add' },{ nil, 0.1, 10, 0, 1, 0 },...)
	return MonoGrain:MultiNew{2,inp,winsize,grainrate,winrandpct}:madd(mul,add)
end
BufGrainI=UGen:new{name='BufGrainI'}
function BufGrainI.ar(...)
	local   trigger, dur, sndbuf, rate, pos, envbuf1, envbuf2, ifac, interp, mul, add   = assign({ 'trigger', 'dur', 'sndbuf', 'rate', 'pos', 'envbuf1', 'envbuf2', 'ifac', 'interp', 'mul', 'add' },{ 0, 1, nil, 1, 0, nil, nil, 0.5, 2, 1, 0 },...)
	return BufGrainI:MultiNew{2,trigger,dur,sndbuf,rate,pos,envbuf1,envbuf2,ifac,interp}:madd(mul,add)
end
BufGrainB=UGen:new{name='BufGrainB'}
function BufGrainB.ar(...)
	local   trigger, dur, sndbuf, rate, pos, envbuf, interp, mul, add   = assign({ 'trigger', 'dur', 'sndbuf', 'rate', 'pos', 'envbuf', 'interp', 'mul', 'add' },{ 0, 1, nil, 1, 0, nil, 2, 1, 0 },...)
	return BufGrainB:MultiNew{2,trigger,dur,sndbuf,rate,pos,envbuf,interp}:madd(mul,add)
end
RandID=UGen:new{name='RandID'}
function RandID.ir(...)
	local   id   = assign({ 'id' },{ 0 },...)
	return RandID:MultiNew{0,id}
end
function RandID.kr(...)
	local   id   = assign({ 'id' },{ 0 },...)
	return RandID:MultiNew{1,id}
end
ClearBuf=UGen:new{name='ClearBuf'}
function ClearBuf.create(...)
	local   buf   = assign({ 'buf' },{ nil },...)
	return ClearBuf:MultiNew{0,buf}
end
SetBuf=UGen:new{name='SetBuf'}
function SetBuf.create(...)
	local   buf, values, offset   = assign({ 'buf', 'values', 'offset' },{ nil, nil, 0 },...)
	return SetBuf:MultiNew{0,buf,values,offset}
end
IFFT=UGen:new{name='IFFT'}
function IFFT.kr(...)
	local   buffer, wintype, winsize   = assign({ 'buffer', 'wintype', 'winsize' },{ nil, 0, 0 },...)
	return IFFT:MultiNew{1,buffer,wintype,winsize}
end
function IFFT.ar(...)
	local   buffer, wintype, winsize   = assign({ 'buffer', 'wintype', 'winsize' },{ nil, 0, 0 },...)
	return IFFT:MultiNew{2,buffer,wintype,winsize}
end
PV_ChainUGen=UGen:new{name='PV_ChainUGen'}
function PV_ChainUGen.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return PV_ChainUGen:MultiNew{2,maxSize}
end
LocalBuf=UGen:new{name='LocalBuf'}
--there was fail in
RandSeed=UGen:new{name='RandSeed'}
function RandSeed.ir(...)
	local   trig, seed   = assign({ 'trig', 'seed' },{ 0.0, 56789 },...)
	return RandSeed:MultiNew{0,trig,seed}
end
function RandSeed.kr(...)
	local   trig, seed   = assign({ 'trig', 'seed' },{ 0.0, 56789 },...)
	return RandSeed:MultiNew{1,trig,seed}
end
function RandSeed.ar(...)
	local   trig, seed   = assign({ 'trig', 'seed' },{ 0.0, 56789 },...)
	return RandSeed:MultiNew{2,trig,seed}
end
PV_JensenAndersen=UGen:new{name='PV_JensenAndersen'}
function PV_JensenAndersen.ar(...)
	local   buffer, propsc, prophfe, prophfc, propsf, threshold, waittime   = assign({ 'buffer', 'propsc', 'prophfe', 'prophfc', 'propsf', 'threshold', 'waittime' },{ nil, 0.25, 0.25, 0.25, 0.25, 1.0, 0.04 },...)
	return PV_JensenAndersen:MultiNew{2,buffer,propsc,prophfe,prophfc,propsf,threshold,waittime}
end
PV_Whiten=UGen:new{name='PV_Whiten'}
function PV_Whiten.create(...)
	local   chain, trackbufnum, relaxtime, floor, smear, bindownsample   = assign({ 'chain', 'trackbufnum', 'relaxtime', 'floor', 'smear', 'bindownsample' },{ nil, nil, 2, 0.1, 0, 0 },...)
	return PV_Whiten:MultiNew{1,chain,trackbufnum,relaxtime,floor,smear,bindownsample}
end
PV_MagMap=UGen:new{name='PV_MagMap'}
function PV_MagMap.create(...)
	local   buffer, mapbuf   = assign({ 'buffer', 'mapbuf' },{ nil, nil },...)
	return PV_MagMap:MultiNew{1,buffer,mapbuf}
end
PV_MagFreeze=UGen:new{name='PV_MagFreeze'}
function PV_MagFreeze.create(...)
	local   buffer, freeze   = assign({ 'buffer', 'freeze' },{ nil, 0.0 },...)
	return PV_MagFreeze:MultiNew{1,buffer,freeze}
end
PV_MagShift=UGen:new{name='PV_MagShift'}
function PV_MagShift.create(...)
	local   buffer, stretch, shift   = assign({ 'buffer', 'stretch', 'shift' },{ nil, 1.0, 0.0 },...)
	return PV_MagShift:MultiNew{1,buffer,stretch,shift}
end
PV_MagSubtract=UGen:new{name='PV_MagSubtract'}
function PV_MagSubtract.create(...)
	local   bufferA, bufferB, zerolimit   = assign({ 'bufferA', 'bufferB', 'zerolimit' },{ nil, nil, 0 },...)
	return PV_MagSubtract:MultiNew{1,bufferA,bufferB,zerolimit}
end
FFT=UGen:new{name='FFT'}
function FFT.create(...)
	local   buffer, inp, hop, wintype, active, winsize   = assign({ 'buffer', 'inp', 'hop', 'wintype', 'active', 'winsize' },{ nil, 0.0, 0.5, 0, 1, 0 },...)
	return FFT:MultiNew{1,buffer,inp,hop,wintype,active,winsize}
end
PV_BinBufRd=UGen:new{name='PV_BinBufRd'}
function PV_BinBufRd.create(...)
	local   buffer, playbuf, point, binStart, binSkip, numBins, clear   = assign({ 'buffer', 'playbuf', 'point', 'binStart', 'binSkip', 'numBins', 'clear' },{ nil, nil, 1.0, 0, 1, 1, 0 },...)
	return PV_BinBufRd:MultiNew{1,buffer,playbuf,point,binStart,binSkip,numBins,clear}
end
PV_ExtractRepeat=UGen:new{name='PV_ExtractRepeat'}
function PV_ExtractRepeat.create(...)
	local   buffer, loopbuf, loopdur, memorytime, which, ffthop, thresh   = assign({ 'buffer', 'loopbuf', 'loopdur', 'memorytime', 'which', 'ffthop', 'thresh' },{ nil, nil, nil, 30, 0, 0.5, 1 },...)
	return PV_ExtractRepeat:MultiNew{1,buffer,loopbuf,loopdur,memorytime,which,ffthop,thresh}
end
PV_BinFilter=UGen:new{name='PV_BinFilter'}
function PV_BinFilter.create(...)
	local   buffer, start, endp   = assign({ 'buffer', 'start', 'endp' },{ nil, 0, 0 },...)
	return PV_BinFilter:MultiNew{1,buffer,start,endp}
end
PV_RectComb2=UGen:new{name='PV_RectComb2'}
function PV_RectComb2.create(...)
	local   bufferA, bufferB, numTeeth, phase, width   = assign({ 'bufferA', 'bufferB', 'numTeeth', 'phase', 'width' },{ nil, nil, 0.0, 0.0, 0.5 },...)
	return PV_RectComb2:MultiNew{1,bufferA,bufferB,numTeeth,phase,width}
end
PV_BrickWall=UGen:new{name='PV_BrickWall'}
function PV_BrickWall.create(...)
	local   buffer, wipe   = assign({ 'buffer', 'wipe' },{ nil, 0.0 },...)
	return PV_BrickWall:MultiNew{1,buffer,wipe}
end
PV_Freeze=UGen:new{name='PV_Freeze'}
function PV_Freeze.create(...)
	local   buffer, freeze   = assign({ 'buffer', 'freeze' },{ nil, 0.0 },...)
	return PV_Freeze:MultiNew{1,buffer,freeze}
end
PV_PhaseShift=UGen:new{name='PV_PhaseShift'}
function PV_PhaseShift.create(...)
	local   buffer, shift, integrate   = assign({ 'buffer', 'shift', 'integrate' },{ nil, nil, 0 },...)
	return PV_PhaseShift:MultiNew{1,buffer,shift,integrate}
end
PV_MagAbove=UGen:new{name='PV_MagAbove'}
function PV_MagAbove.create(...)
	local   buffer, threshold   = assign({ 'buffer', 'threshold' },{ nil, 0.0 },...)
	return PV_MagAbove:MultiNew{1,buffer,threshold}
end
PV_BufRd=UGen:new{name='PV_BufRd'}
function PV_BufRd.create(...)
	local   buffer, playbuf, point   = assign({ 'buffer', 'playbuf', 'point' },{ nil, nil, 1.0 },...)
	return PV_BufRd:MultiNew{1,buffer,playbuf,point}
end
PV_HainsworthFoote=UGen:new{name='PV_HainsworthFoote'}
function PV_HainsworthFoote.ar(...)
	local   buffer, proph, propf, threshold, waittime   = assign({ 'buffer', 'proph', 'propf', 'threshold', 'waittime' },{ nil, 0.0, 0.0, 1.0, 0.04 },...)
	return PV_HainsworthFoote:MultiNew{2,buffer,proph,propf,threshold,waittime}
end
FFTTrigger=UGen:new{name='FFTTrigger'}
function FFTTrigger.create(...)
	local   buffer, hop, polar   = assign({ 'buffer', 'hop', 'polar' },{ nil, 0.5, 0.0 },...)
	return FFTTrigger:MultiNew{1,buffer,hop,polar}
end
PV_BinScramble=UGen:new{name='PV_BinScramble'}
function PV_BinScramble.create(...)
	local   buffer, wipe, width, trig   = assign({ 'buffer', 'wipe', 'width', 'trig' },{ nil, 0.0, 0.2, 0.0 },...)
	return PV_BinScramble:MultiNew{1,buffer,wipe,width,trig}
end
PV_PitchShift=UGen:new{name='PV_PitchShift'}
function PV_PitchShift.create(...)
	local   buffer, ratio   = assign({ 'buffer', 'ratio' },{ nil, nil },...)
	return PV_PitchShift:MultiNew{1,buffer,ratio}
end
PV_MagMulAdd=UGen:new{name='PV_MagMulAdd'}
function PV_MagMulAdd.create(...)
	local   buffer, mul, add   = assign({ 'buffer', 'mul', 'add' },{ nil, 1, 0 },...)
	return PV_MagMulAdd:MultiNew{1,buffer}:madd(mul,add)
end
PV_MagLog=UGen:new{name='PV_MagLog'}
function PV_MagLog.create(...)
	local   buffer   = assign({ 'buffer' },{ nil },...)
	return PV_MagLog:MultiNew{1,buffer}
end
PV_NoiseSynthP=UGen:new{name='PV_NoiseSynthP'}
function PV_NoiseSynthP.create(...)
	local   buffer, threshold, numFrames, initflag   = assign({ 'buffer', 'threshold', 'numFrames', 'initflag' },{ nil, 0.1, 2, 0 },...)
	return PV_NoiseSynthP:MultiNew{1,buffer,threshold,numFrames,initflag}
end
PV_MagMul=UGen:new{name='PV_MagMul'}
function PV_MagMul.create(...)
	local   bufferA, bufferB   = assign({ 'bufferA', 'bufferB' },{ nil, nil },...)
	return PV_MagMul:MultiNew{1,bufferA,bufferB}
end
PV_MagDiv=UGen:new{name='PV_MagDiv'}
function PV_MagDiv.create(...)
	local   bufferA, bufferB, zeroed   = assign({ 'bufferA', 'bufferB', 'zeroed' },{ nil, nil, 0.0001 },...)
	return PV_MagDiv:MultiNew{1,bufferA,bufferB,zeroed}
end
PV_MagSquared=UGen:new{name='PV_MagSquared'}
function PV_MagSquared.create(...)
	local   buffer   = assign({ 'buffer' },{ nil },...)
	return PV_MagSquared:MultiNew{1,buffer}
end
PV_PlayBuf=UGen:new{name='PV_PlayBuf'}
function PV_PlayBuf.create(...)
	local   buffer, playbuf, rate, offset, loop   = assign({ 'buffer', 'playbuf', 'rate', 'offset', 'loop' },{ nil, nil, 1.0, 0.0, 0.0 },...)
	return PV_PlayBuf:MultiNew{1,buffer,playbuf,rate,offset,loop}
end
PV_Diffuser=UGen:new{name='PV_Diffuser'}
function PV_Diffuser.create(...)
	local   buffer, trig   = assign({ 'buffer', 'trig' },{ nil, 0.0 },...)
	return PV_Diffuser:MultiNew{1,buffer,trig}
end
PV_OddBin=UGen:new{name='PV_OddBin'}
function PV_OddBin.create(...)
	local   buffer   = assign({ 'buffer' },{ nil },...)
	return PV_OddBin:MultiNew{1,buffer}
end
PV_MagSmear=UGen:new{name='PV_MagSmear'}
function PV_MagSmear.create(...)
	local   buffer, bins   = assign({ 'buffer', 'bins' },{ nil, 0.0 },...)
	return PV_MagSmear:MultiNew{1,buffer,bins}
end
PV_BinWipe=UGen:new{name='PV_BinWipe'}
function PV_BinWipe.create(...)
	local   bufferA, bufferB, wipe   = assign({ 'bufferA', 'bufferB', 'wipe' },{ nil, nil, 0.0 },...)
	return PV_BinWipe:MultiNew{1,bufferA,bufferB,wipe}
end
PV_BinPlayBuf=UGen:new{name='PV_BinPlayBuf'}
function PV_BinPlayBuf.create(...)
	local   buffer, playbuf, rate, offset, binStart, binSkip, numBins, loop, clear   = assign({ 'buffer', 'playbuf', 'rate', 'offset', 'binStart', 'binSkip', 'numBins', 'loop', 'clear' },{ nil, nil, 1.0, 0.0, 0, 1, 1, 0.0, 0 },...)
	return PV_BinPlayBuf:MultiNew{1,buffer,playbuf,rate,offset,binStart,binSkip,numBins,loop,clear}
end
PackFFT=UGen:new{name='PackFFT'}
--there was fail in
PV_MagExp=UGen:new{name='PV_MagExp'}
function PV_MagExp.create(...)
	local   buffer   = assign({ 'buffer' },{ nil },...)
	return PV_MagExp:MultiNew{1,buffer}
end
PV_MagBuffer=UGen:new{name='PV_MagBuffer'}
function PV_MagBuffer.create(...)
	local   buffer, databuffer   = assign({ 'buffer', 'databuffer' },{ nil, nil },...)
	return PV_MagBuffer:MultiNew{1,buffer,databuffer}
end
PV_SpectralMap=UGen:new{name='PV_SpectralMap'}
function PV_SpectralMap.create(...)
	local   buffer, specBuffer, floor, freeze, mode, norm, window   = assign({ 'buffer', 'specBuffer', 'floor', 'freeze', 'mode', 'norm', 'window' },{ nil, nil, 0.0, 0.0, 0.0, 0.0, 0.0 },...)
	return PV_SpectralMap:MultiNew{1,buffer,specBuffer,floor,freeze,mode,norm,window}
end
PV_DiffMags=UGen:new{name='PV_DiffMags'}
--WARNING: PV_DiffMags has changed name to PV_MagSubtract. 'PV_DiffMags' will be removed in future
function PV_DiffMags.create(...)
	local   bufferA, bufferB   = assign({ 'bufferA', 'bufferB' },{ nil, nil },...)
	return PV_DiffMags:MultiNew{1,bufferA,bufferB}
end
Cepstrum=UGen:new{name='Cepstrum'}
function Cepstrum.create(...)
	local   cepbuf, fftchain   = assign({ 'cepbuf', 'fftchain' },{ nil, nil },...)
	return Cepstrum:MultiNew{1,cepbuf,fftchain}
end
PV_MaxMagN=UGen:new{name='PV_MaxMagN'}
function PV_MaxMagN.create(...)
	local   buffer, numbins   = assign({ 'buffer', 'numbins' },{ nil, nil },...)
	return PV_MaxMagN:MultiNew{1,buffer,numbins}
end
PV_RectComb=UGen:new{name='PV_RectComb'}
function PV_RectComb.create(...)
	local   buffer, numTeeth, phase, width   = assign({ 'buffer', 'numTeeth', 'phase', 'width' },{ nil, 0.0, 0.0, 0.5 },...)
	return PV_RectComb:MultiNew{1,buffer,numTeeth,phase,width}
end
PV_RandComb=UGen:new{name='PV_RandComb'}
function PV_RandComb.create(...)
	local   buffer, wipe, trig   = assign({ 'buffer', 'wipe', 'trig' },{ nil, 0.0, 0.0 },...)
	return PV_RandComb:MultiNew{1,buffer,wipe,trig}
end
PV_RecordBuf=UGen:new{name='PV_RecordBuf'}
function PV_RecordBuf.create(...)
	local   buffer, recbuf, offset, run, loop, hop, wintype   = assign({ 'buffer', 'recbuf', 'offset', 'run', 'loop', 'hop', 'wintype' },{ nil, nil, 0.0, 0.0, 0.0, 0.5, 0 },...)
	return PV_RecordBuf:MultiNew{1,buffer,recbuf,offset,run,loop,hop,wintype}
end
PV_SpectralEnhance=UGen:new{name='PV_SpectralEnhance'}
function PV_SpectralEnhance.create(...)
	local   buffer, numPartials, ratio, strength   = assign({ 'buffer', 'numPartials', 'ratio', 'strength' },{ nil, 8, 2, 0.1 },...)
	return PV_SpectralEnhance:MultiNew{1,buffer,numPartials,ratio,strength}
end
PV_ConformalMap=UGen:new{name='PV_ConformalMap'}
function PV_ConformalMap.create(...)
	local   buffer, areal, aimag   = assign({ 'buffer', 'areal', 'aimag' },{ nil, 0.0, 0.0 },...)
	return PV_ConformalMap:MultiNew{1,buffer,areal,aimag}
end
PV_Invert=UGen:new{name='PV_Invert'}
function PV_Invert.create(...)
	local   buffer   = assign({ 'buffer' },{ nil },...)
	return PV_Invert:MultiNew{1,buffer}
end
PV_MagSmooth=UGen:new{name='PV_MagSmooth'}
function PV_MagSmooth.create(...)
	local   buffer, factor   = assign({ 'buffer', 'factor' },{ nil, 0.1 },...)
	return PV_MagSmooth:MultiNew{1,buffer,factor}
end
PV_RandWipe=UGen:new{name='PV_RandWipe'}
function PV_RandWipe.create(...)
	local   bufferA, bufferB, wipe, trig   = assign({ 'bufferA', 'bufferB', 'wipe', 'trig' },{ nil, nil, 0.0, 0.0 },...)
	return PV_RandWipe:MultiNew{1,bufferA,bufferB,wipe,trig}
end
PV_BinShift=UGen:new{name='PV_BinShift'}
function PV_BinShift.create(...)
	local   buffer, stretch, shift, interp   = assign({ 'buffer', 'stretch', 'shift', 'interp' },{ nil, 1.0, 0.0, 0 },...)
	return PV_BinShift:MultiNew{1,buffer,stretch,shift,interp}
end
PV_BinDelay=UGen:new{name='PV_BinDelay'}
function PV_BinDelay.create(...)
	local   buffer, maxdelay, delaybuf, fbbuf, hop   = assign({ 'buffer', 'maxdelay', 'delaybuf', 'fbbuf', 'hop' },{ nil, nil, nil, nil, 0.5 },...)
	return PV_BinDelay:MultiNew{1,buffer,maxdelay,delaybuf,fbbuf,hop}
end
PV_MagClip=UGen:new{name='PV_MagClip'}
function PV_MagClip.create(...)
	local   buffer, threshold   = assign({ 'buffer', 'threshold' },{ nil, 0.0 },...)
	return PV_MagClip:MultiNew{1,buffer,threshold}
end
PV_MagBelow=UGen:new{name='PV_MagBelow'}
function PV_MagBelow.create(...)
	local   buffer, threshold   = assign({ 'buffer', 'threshold' },{ nil, 0.0 },...)
	return PV_MagBelow:MultiNew{1,buffer,threshold}
end
PV_LocalMax=UGen:new{name='PV_LocalMax'}
function PV_LocalMax.create(...)
	local   buffer, threshold   = assign({ 'buffer', 'threshold' },{ nil, 0.0 },...)
	return PV_LocalMax:MultiNew{1,buffer,threshold}
end
PV_PartialSynthF=UGen:new{name='PV_PartialSynthF'}
function PV_PartialSynthF.create(...)
	local   buffer, threshold, numFrames, initflag   = assign({ 'buffer', 'threshold', 'numFrames', 'initflag' },{ nil, 0.1, 2, 0 },...)
	return PV_PartialSynthF:MultiNew{1,buffer,threshold,numFrames,initflag}
end
PV_PartialSynthP=UGen:new{name='PV_PartialSynthP'}
function PV_PartialSynthP.create(...)
	local   buffer, threshold, numFrames, initflag   = assign({ 'buffer', 'threshold', 'numFrames', 'initflag' },{ nil, 0.1, 2, 0 },...)
	return PV_PartialSynthP:MultiNew{1,buffer,threshold,numFrames,initflag}
end
PV_NoiseSynthF=UGen:new{name='PV_NoiseSynthF'}
function PV_NoiseSynthF.create(...)
	local   buffer, threshold, numFrames, initflag   = assign({ 'buffer', 'threshold', 'numFrames', 'initflag' },{ nil, 0.1, 2, 0 },...)
	return PV_NoiseSynthF:MultiNew{1,buffer,threshold,numFrames,initflag}
end
PV_Max=UGen:new{name='PV_Max'}
function PV_Max.create(...)
	local   bufferA, bufferB   = assign({ 'bufferA', 'bufferB' },{ nil, nil },...)
	return PV_Max:MultiNew{1,bufferA,bufferB}
end
PV_Copy=UGen:new{name='PV_Copy'}
function PV_Copy.create(...)
	local   bufferA, bufferB   = assign({ 'bufferA', 'bufferB' },{ nil, nil },...)
	return PV_Copy:MultiNew{1,bufferA,bufferB}
end
PV_CopyPhase=UGen:new{name='PV_CopyPhase'}
function PV_CopyPhase.create(...)
	local   bufferA, bufferB   = assign({ 'bufferA', 'bufferB' },{ nil, nil },...)
	return PV_CopyPhase:MultiNew{1,bufferA,bufferB}
end
PV_Mul=UGen:new{name='PV_Mul'}
function PV_Mul.create(...)
	local   bufferA, bufferB   = assign({ 'bufferA', 'bufferB' },{ nil, nil },...)
	return PV_Mul:MultiNew{1,bufferA,bufferB}
end
PV_Add=UGen:new{name='PV_Add'}
function PV_Add.create(...)
	local   bufferA, bufferB   = assign({ 'bufferA', 'bufferB' },{ nil, nil },...)
	return PV_Add:MultiNew{1,bufferA,bufferB}
end
PV_Div=UGen:new{name='PV_Div'}
function PV_Div.create(...)
	local   bufferA, bufferB   = assign({ 'bufferA', 'bufferB' },{ nil, nil },...)
	return PV_Div:MultiNew{1,bufferA,bufferB}
end
PV_Min=UGen:new{name='PV_Min'}
function PV_Min.create(...)
	local   bufferA, bufferB   = assign({ 'bufferA', 'bufferB' },{ nil, nil },...)
	return PV_Min:MultiNew{1,bufferA,bufferB}
end
PV_PhaseShift270=UGen:new{name='PV_PhaseShift270'}
function PV_PhaseShift270.create(...)
	local   buffer   = assign({ 'buffer' },{ nil },...)
	return PV_PhaseShift270:MultiNew{1,buffer}
end
PV_Conj=UGen:new{name='PV_Conj'}
function PV_Conj.create(...)
	local   buffer   = assign({ 'buffer' },{ nil },...)
	return PV_Conj:MultiNew{1,buffer}
end
PV_MagNoise=UGen:new{name='PV_MagNoise'}
function PV_MagNoise.create(...)
	local   buffer   = assign({ 'buffer' },{ nil },...)
	return PV_MagNoise:MultiNew{1,buffer}
end
PV_PhaseShift90=UGen:new{name='PV_PhaseShift90'}
function PV_PhaseShift90.create(...)
	local   buffer   = assign({ 'buffer' },{ nil },...)
	return PV_PhaseShift90:MultiNew{1,buffer}
end
PV_EvenBin=UGen:new{name='PV_EvenBin'}
function PV_EvenBin.create(...)
	local   buffer   = assign({ 'buffer' },{ nil },...)
	return PV_EvenBin:MultiNew{1,buffer}
end
PV_FreqBuffer=UGen:new{name='PV_FreqBuffer'}
function PV_FreqBuffer.create(...)
	local   buffer, databuffer   = assign({ 'buffer', 'databuffer' },{ nil, nil },...)
	return PV_FreqBuffer:MultiNew{1,buffer,databuffer}
end
ICepstrum=UGen:new{name='ICepstrum'}
function ICepstrum.create(...)
	local   cepchain, fftbuf   = assign({ 'cepchain', 'fftbuf' },{ nil, nil },...)
	return ICepstrum:MultiNew{1,cepchain,fftbuf}
end
PV_MinMagN=UGen:new{name='PV_MinMagN'}
function PV_MinMagN.create(...)
	local   buffer, numbins   = assign({ 'buffer', 'numbins' },{ nil, nil },...)
	return PV_MinMagN:MultiNew{1,buffer,numbins}
end
TDuty=UGen:new{name='TDuty'}
function TDuty.kr(...)
	local   dur, reset, level, doneAction, gapFirst   = assign({ 'dur', 'reset', 'level', 'doneAction', 'gapFirst' },{ 1.0, 0.0, 1.0, 0, 0 },...)
	return TDuty:MultiNew{1,dur,reset,level,doneAction,gapFirst}
end
function TDuty.ar(...)
	local   dur, reset, level, doneAction, gapFirst   = assign({ 'dur', 'reset', 'level', 'doneAction', 'gapFirst' },{ 1.0, 0.0, 1.0, 0, 0 },...)
	return TDuty:MultiNew{2,dur,reset,level,doneAction,gapFirst}
end
PinkNoise=UGen:new{name='PinkNoise'}
function PinkNoise.kr(...)
	local   mul, add   = assign({ 'mul', 'add' },{ 1.0, 0.0 },...)
	return PinkNoise:MultiNew{1}:madd(mul,add)
end
function PinkNoise.ar(...)
	local   mul, add   = assign({ 'mul', 'add' },{ 1.0, 0.0 },...)
	return PinkNoise:MultiNew{2}:madd(mul,add)
end
BrownNoise=UGen:new{name='BrownNoise'}
function BrownNoise.kr(...)
	local   mul, add   = assign({ 'mul', 'add' },{ 1.0, 0.0 },...)
	return BrownNoise:MultiNew{1}:madd(mul,add)
end
function BrownNoise.ar(...)
	local   mul, add   = assign({ 'mul', 'add' },{ 1.0, 0.0 },...)
	return BrownNoise:MultiNew{2}:madd(mul,add)
end
ClipNoise=UGen:new{name='ClipNoise'}
function ClipNoise.kr(...)
	local   mul, add   = assign({ 'mul', 'add' },{ 1.0, 0.0 },...)
	return ClipNoise:MultiNew{1}:madd(mul,add)
end
function ClipNoise.ar(...)
	local   mul, add   = assign({ 'mul', 'add' },{ 1.0, 0.0 },...)
	return ClipNoise:MultiNew{2}:madd(mul,add)
end
GrayNoise=UGen:new{name='GrayNoise'}
function GrayNoise.kr(...)
	local   mul, add   = assign({ 'mul', 'add' },{ 1.0, 0.0 },...)
	return GrayNoise:MultiNew{1}:madd(mul,add)
end
function GrayNoise.ar(...)
	local   mul, add   = assign({ 'mul', 'add' },{ 1.0, 0.0 },...)
	return GrayNoise:MultiNew{2}:madd(mul,add)
end
LeastChange=UGen:new{name='LeastChange'}
function LeastChange.kr(...)
	local   a, b   = assign({ 'a', 'b' },{ 0.0, 0.0 },...)
	return LeastChange:MultiNew{1,a,b}
end
function LeastChange.ar(...)
	local   a, b   = assign({ 'a', 'b' },{ 0.0, 0.0 },...)
	return LeastChange:MultiNew{2,a,b}
end
LFClipNoise=UGen:new{name='LFClipNoise'}
function LFClipNoise.kr(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 500.0, 1.0, 0.0 },...)
	return LFClipNoise:MultiNew{1,freq}:madd(mul,add)
end
function LFClipNoise.ar(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 500.0, 1.0, 0.0 },...)
	return LFClipNoise:MultiNew{2,freq}:madd(mul,add)
end
LFDNoise3=UGen:new{name='LFDNoise3'}
function LFDNoise3.kr(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 500.0, 1.0, 0.0 },...)
	return LFDNoise3:MultiNew{1,freq}:madd(mul,add)
end
function LFDNoise3.ar(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 500.0, 1.0, 0.0 },...)
	return LFDNoise3:MultiNew{2,freq}:madd(mul,add)
end
LFDNoise0=UGen:new{name='LFDNoise0'}
function LFDNoise0.kr(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 500.0, 1.0, 0.0 },...)
	return LFDNoise0:MultiNew{1,freq}:madd(mul,add)
end
function LFDNoise0.ar(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 500.0, 1.0, 0.0 },...)
	return LFDNoise0:MultiNew{2,freq}:madd(mul,add)
end
LFNoise2=UGen:new{name='LFNoise2'}
function LFNoise2.kr(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 500.0, 1.0, 0.0 },...)
	return LFNoise2:MultiNew{1,freq}:madd(mul,add)
end
function LFNoise2.ar(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 500.0, 1.0, 0.0 },...)
	return LFNoise2:MultiNew{2,freq}:madd(mul,add)
end
LFDNoise1=UGen:new{name='LFDNoise1'}
function LFDNoise1.kr(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 500.0, 1.0, 0.0 },...)
	return LFDNoise1:MultiNew{1,freq}:madd(mul,add)
end
function LFDNoise1.ar(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 500.0, 1.0, 0.0 },...)
	return LFDNoise1:MultiNew{2,freq}:madd(mul,add)
end
LFNoise1=UGen:new{name='LFNoise1'}
function LFNoise1.kr(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 500.0, 1.0, 0.0 },...)
	return LFNoise1:MultiNew{1,freq}:madd(mul,add)
end
function LFNoise1.ar(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 500.0, 1.0, 0.0 },...)
	return LFNoise1:MultiNew{2,freq}:madd(mul,add)
end
LFDClipNoise=UGen:new{name='LFDClipNoise'}
function LFDClipNoise.kr(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 500.0, 1.0, 0.0 },...)
	return LFDClipNoise:MultiNew{1,freq}:madd(mul,add)
end
function LFDClipNoise.ar(...)
	local   freq, mul, add   = assign({ 'freq', 'mul', 'add' },{ 500.0, 1.0, 0.0 },...)
	return LFDClipNoise:MultiNew{2,freq}:madd(mul,add)
end
Dswitch1=UGen:new{name='Dswitch1'}
function Dswitch1.create(...)
	local   list, index   = assign({ 'list', 'index' },{ nil, nil },...)
	return Dswitch1:MultiNew{3,list,index}
end
Dseries=UGen:new{name='Dseries'}
function Dseries.create(...)
	local   start, step, length   = assign({ 'start', 'step', 'length' },{ 1, 1, "math.huge" },...)
	return Dseries:MultiNew{3,start,step,length}
end
Dpoll=UGen:new{name='Dpoll'}
function Dpoll.create(...)
	local   inp, label, run, trigid   = assign({ 'inp', 'label', 'run', 'trigid' },{ nil, nil, 1, -1 },...)
	return Dpoll:MultiNew{3,inp,label,run,trigid}
end
DbufTag=UGen:new{name='DbufTag'}
--there was fail in
Dbufwr=UGen:new{name='Dbufwr'}
function Dbufwr.create(...)
	local   input, bufnum, phase, loop   = assign({ 'input', 'bufnum', 'phase', 'loop' },{ 0.0, 0, 0.0, 1.0 },...)
	return Dbufwr:MultiNew{3,input,bufnum,phase,loop}
end
Dreset=UGen:new{name='Dreset'}
function Dreset.create(...)
	local   inp, reset   = assign({ 'inp', 'reset' },{ nil, 0.0 },...)
	return Dreset:MultiNew{3,inp,reset}
end
Dbrown=UGen:new{name='Dbrown'}
function Dbrown.create(...)
	local   lo, hi, step, length   = assign({ 'lo', 'hi', 'step', 'length' },{ 0.0, 1.0, 0.01, "math.huge" },...)
	return Dbrown:MultiNew{3,lo,hi,step,length}
end
Dwrand=UGen:new{name='Dwrand'}
--there was fail in
ListDUGen=UGen:new{name='ListDUGen'}
function ListDUGen.create(...)
	local   list, repeats   = assign({ 'list', 'repeats' },{ nil, 1 },...)
	return ListDUGen:MultiNew{3,list,repeats}
end
Dgeom=UGen:new{name='Dgeom'}
function Dgeom.create(...)
	local   start, grow, length   = assign({ 'start', 'grow', 'length' },{ 1, 2, "math.huge" },...)
	return Dgeom:MultiNew{3,start,grow,length}
end
Dstutter=UGen:new{name='Dstutter'}
function Dstutter.create(...)
	local   n, inp   = assign({ 'n', 'inp' },{ nil, nil },...)
	return Dstutter:MultiNew{3,n,inp}
end
DetaBlockerBuf=UGen:new{name='DetaBlockerBuf'}
function DetaBlockerBuf.create(...)
	local   bufnum, startpoint   = assign({ 'bufnum', 'startpoint' },{ 0, 0 },...)
	return DetaBlockerBuf:MultiNew{3,bufnum,startpoint}
end
Dwhite=UGen:new{name='Dwhite'}
function Dwhite.create(...)
	local   lo, hi, length   = assign({ 'lo', 'hi', 'length' },{ 0.0, 1.0, "math.huge" },...)
	return Dwhite:MultiNew{3,lo,hi,length}
end
Donce=UGen:new{name='Donce'}
function Donce.create(...)
	local   inp   = assign({ 'inp' },{ nil },...)
	return Donce:MultiNew{3,inp}
end
Dfsm=UGen:new{name='Dfsm'}
--there was fail in
Dbufrd=UGen:new{name='Dbufrd'}
function Dbufrd.create(...)
	local   bufnum, phase, loop   = assign({ 'bufnum', 'phase', 'loop' },{ 0, 0.0, 1.0 },...)
	return Dbufrd:MultiNew{3,bufnum,phase,loop}
end
Dswitch=UGen:new{name='Dswitch'}
function Dswitch.create(...)
	local   list, index   = assign({ 'list', 'index' },{ nil, nil },...)
	return Dswitch:MultiNew{3,list,index}
end
Dtag=UGen:new{name='Dtag'}
--there was fail in
Dibrown=UGen:new{name='Dibrown'}
function Dibrown.create(...)
	local   lo, hi, step, length   = assign({ 'lo', 'hi', 'step', 'length' },{ 0.0, 1.0, 0.01, "math.huge" },...)
	return Dibrown:MultiNew{3,lo,hi,step,length}
end
Dshuf=UGen:new{name='Dshuf'}
function Dshuf.create(...)
	local   list, repeats   = assign({ 'list', 'repeats' },{ nil, 1 },...)
	return Dshuf:MultiNew{3,list,repeats}
end
Dxrand=UGen:new{name='Dxrand'}
function Dxrand.create(...)
	local   list, repeats   = assign({ 'list', 'repeats' },{ nil, 1 },...)
	return Dxrand:MultiNew{3,list,repeats}
end
Drand=UGen:new{name='Drand'}
function Drand.create(...)
	local   list, repeats   = assign({ 'list', 'repeats' },{ nil, 1 },...)
	return Drand:MultiNew{3,list,repeats}
end
Dseq=UGen:new{name='Dseq'}
function Dseq.create(...)
	local   list, repeats   = assign({ 'list', 'repeats' },{ nil, 1 },...)
	return Dseq:MultiNew{3,list,repeats}
end
Dser=UGen:new{name='Dser'}
function Dser.create(...)
	local   list, repeats   = assign({ 'list', 'repeats' },{ nil, 1 },...)
	return Dser:MultiNew{3,list,repeats}
end
Diwhite=UGen:new{name='Diwhite'}
function Diwhite.create(...)
	local   lo, hi, length   = assign({ 'lo', 'hi', 'length' },{ 0.0, 1.0, "math.huge" },...)
	return Diwhite:MultiNew{3,lo,hi,length}
end
NestedAllpassC=UGen:new{name='NestedAllpassC'}
function NestedAllpassC.ar(...)
	local   inp, maxdelay1, delay1, gain1, maxdelay2, delay2, gain2, mul, add   = assign({ 'inp', 'maxdelay1', 'delay1', 'gain1', 'maxdelay2', 'delay2', 'gain2', 'mul', 'add' },{ nil, 0.036, 0.036, 0.08, 0.03, 0.03, 0.3, 1.0, 0.0 },...)
	return NestedAllpassC:MultiNew{2,inp,maxdelay1,delay1,gain1,maxdelay2,delay2,gain2}:madd(mul,add)
end
NestedAllpassL=UGen:new{name='NestedAllpassL'}
function NestedAllpassL.ar(...)
	local   inp, maxdelay1, delay1, gain1, maxdelay2, delay2, gain2, mul, add   = assign({ 'inp', 'maxdelay1', 'delay1', 'gain1', 'maxdelay2', 'delay2', 'gain2', 'mul', 'add' },{ nil, 0.036, 0.036, 0.08, 0.03, 0.03, 0.3, 1.0, 0.0 },...)
	return NestedAllpassL:MultiNew{2,inp,maxdelay1,delay1,gain1,maxdelay2,delay2,gain2}:madd(mul,add)
end
BufDelayC=UGen:new{name='BufDelayC'}
function BufDelayC.kr(...)
	local   buf, inp, delaytime, mul, add   = assign({ 'buf', 'inp', 'delaytime', 'mul', 'add' },{ 0, 0.0, 0.2, 1.0, 0.0 },...)
	return BufDelayC:MultiNew{1,buf,inp,delaytime}:madd(mul,add)
end
function BufDelayC.ar(...)
	local   buf, inp, delaytime, mul, add   = assign({ 'buf', 'inp', 'delaytime', 'mul', 'add' },{ 0, 0.0, 0.2, 1.0, 0.0 },...)
	return BufDelayC:MultiNew{2,buf,inp,delaytime}:madd(mul,add)
end
BufDelayL=UGen:new{name='BufDelayL'}
function BufDelayL.kr(...)
	local   buf, inp, delaytime, mul, add   = assign({ 'buf', 'inp', 'delaytime', 'mul', 'add' },{ 0, 0.0, 0.2, 1.0, 0.0 },...)
	return BufDelayL:MultiNew{1,buf,inp,delaytime}:madd(mul,add)
end
function BufDelayL.ar(...)
	local   buf, inp, delaytime, mul, add   = assign({ 'buf', 'inp', 'delaytime', 'mul', 'add' },{ 0, 0.0, 0.2, 1.0, 0.0 },...)
	return BufDelayL:MultiNew{2,buf,inp,delaytime}:madd(mul,add)
end
Henon2DC=UGen:new{name='Henon2DC'}
function Henon2DC.kr(...)
	local   minfreq, maxfreq, a, b, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'a', 'b', 'x0', 'y0', 'mul', 'add' },{ 40, 100, 1.4, 0.3, 0.30501993062401, 0.20938865431933, 1, 0.0 },...)
	return Henon2DC:MultiNew{1,minfreq,maxfreq,a,b,x0,y0}:madd(mul,add)
end
function Henon2DC.ar(...)
	local   minfreq, maxfreq, a, b, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'a', 'b', 'x0', 'y0', 'mul', 'add' },{ 11025, 22050, 1.4, 0.3, 0.30501993062401, 0.20938865431933, 1, 0.0 },...)
	return Henon2DC:MultiNew{2,minfreq,maxfreq,a,b,x0,y0}:madd(mul,add)
end
Henon2DL=UGen:new{name='Henon2DL'}
function Henon2DL.kr(...)
	local   minfreq, maxfreq, a, b, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'a', 'b', 'x0', 'y0', 'mul', 'add' },{ 40, 100, 1.4, 0.3, 0.30501993062401, 0.20938865431933, 1, 0.0 },...)
	return Henon2DL:MultiNew{1,minfreq,maxfreq,a,b,x0,y0}:madd(mul,add)
end
function Henon2DL.ar(...)
	local   minfreq, maxfreq, a, b, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'a', 'b', 'x0', 'y0', 'mul', 'add' },{ 11025, 22050, 1.4, 0.3, 0.30501993062401, 0.20938865431933, 1, 0.0 },...)
	return Henon2DL:MultiNew{2,minfreq,maxfreq,a,b,x0,y0}:madd(mul,add)
end
Standard2DC=UGen:new{name='Standard2DC'}
function Standard2DC.kr(...)
	local   minfreq, maxfreq, k, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'k', 'x0', 'y0', 'mul', 'add' },{ 40, 100, 1.4, 4.9789799812499, 5.7473416156381, 1, 0.0 },...)
	return Standard2DC:MultiNew{1,minfreq,maxfreq,k,x0,y0}:madd(mul,add)
end
function Standard2DC.ar(...)
	local   minfreq, maxfreq, k, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'k', 'x0', 'y0', 'mul', 'add' },{ 11025, 22050, 1.4, 4.9789799812499, 5.7473416156381, 1, 0.0 },...)
	return Standard2DC:MultiNew{2,minfreq,maxfreq,k,x0,y0}:madd(mul,add)
end
Standard2DL=UGen:new{name='Standard2DL'}
function Standard2DL.kr(...)
	local   minfreq, maxfreq, k, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'k', 'x0', 'y0', 'mul', 'add' },{ 40, 100, 1.4, 4.9789799812499, 5.7473416156381, 1, 0.0 },...)
	return Standard2DL:MultiNew{1,minfreq,maxfreq,k,x0,y0}:madd(mul,add)
end
function Standard2DL.ar(...)
	local   minfreq, maxfreq, k, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'k', 'x0', 'y0', 'mul', 'add' },{ 11025, 22050, 1.4, 4.9789799812499, 5.7473416156381, 1, 0.0 },...)
	return Standard2DL:MultiNew{2,minfreq,maxfreq,k,x0,y0}:madd(mul,add)
end
MembraneHexagon=UGen:new{name='MembraneHexagon'}
function MembraneHexagon.ar(...)
	local   excitation, tension, loss, mul, add   = assign({ 'excitation', 'tension', 'loss', 'mul', 'add' },{ nil, 0.05, 0.99999, 1.0, 0.0 },...)
	return MembraneHexagon:MultiNew{2,excitation,tension,loss}:madd(mul,add)
end
RMShelf2=UGen:new{name='RMShelf2'}
function RMShelf2.ar(...)
	local   inp, freq, k, mul, add   = assign({ 'inp', 'freq', 'k', 'mul', 'add' },{ nil, 440.0, 0, 1.0, 0.0 },...)
	return RMShelf2:MultiNew{2,inp,freq,k}:madd(mul,add)
end
Allpass2=UGen:new{name='Allpass2'}
function Allpass2.ar(...)
	local   inp, freq, rq, mul, add   = assign({ 'inp', 'freq', 'rq', 'mul', 'add' },{ nil, 1200.0, 1.0, 1.0, 0.0 },...)
	return Allpass2:MultiNew{2,inp,freq,rq}:madd(mul,add)
end
Allpass1=UGen:new{name='Allpass1'}
function Allpass1.ar(...)
	local   inp, freq, mul, add   = assign({ 'inp', 'freq', 'mul', 'add' },{ nil, 1200.0, 1.0, 0.0 },...)
	return Allpass1:MultiNew{2,inp,freq}:madd(mul,add)
end
RMShelf=UGen:new{name='RMShelf'}
function RMShelf.ar(...)
	local   inp, freq, k, mul, add   = assign({ 'inp', 'freq', 'k', 'mul', 'add' },{ nil, 440.0, 0, 1.0, 0.0 },...)
	return RMShelf:MultiNew{2,inp,freq,k}:madd(mul,add)
end
RMEQ=UGen:new{name='RMEQ'}
function RMEQ.ar(...)
	local   inp, freq, rq, k, mul, add   = assign({ 'inp', 'freq', 'rq', 'k', 'mul', 'add' },{ nil, 440, 0.1, 0, 1.0, 0.0 },...)
	return RMEQ:MultiNew{2,inp,freq,rq,k}:madd(mul,add)
end
RegaliaMitraEQ=UGen:new{name='RegaliaMitraEQ'}
function RegaliaMitraEQ.ar(...)
	local   inp, freq, rq, k, mul, add   = assign({ 'inp', 'freq', 'rq', 'k', 'mul', 'add' },{ nil, 440, 0.1, 0, 1.0, 0.0 },...)
	return RegaliaMitraEQ:MultiNew{2,inp,freq,rq,k}:madd(mul,add)
end
DoubleNestedAllpassL=UGen:new{name='DoubleNestedAllpassL'}
function DoubleNestedAllpassL.ar(...)
	local   inp, maxdelay1, delay1, gain1, maxdelay2, delay2, gain2, maxdelay3, delay3, gain3, mul, add   = assign({ 'inp', 'maxdelay1', 'delay1', 'gain1', 'maxdelay2', 'delay2', 'gain2', 'maxdelay3', 'delay3', 'gain3', 'mul', 'add' },{ nil, 0.0047, 0.0047, 0.15, 0.022, 0.022, 0.25, 0.0083, 0.0083, 0.3, 1.0, 0.0 },...)
	return DoubleNestedAllpassL:MultiNew{2,inp,maxdelay1,delay1,gain1,maxdelay2,delay2,gain2,maxdelay3,delay3,gain3}:madd(mul,add)
end
DoubleNestedAllpassC=UGen:new{name='DoubleNestedAllpassC'}
function DoubleNestedAllpassC.ar(...)
	local   inp, maxdelay1, delay1, gain1, maxdelay2, delay2, gain2, maxdelay3, delay3, gain3, mul, add   = assign({ 'inp', 'maxdelay1', 'delay1', 'gain1', 'maxdelay2', 'delay2', 'gain2', 'maxdelay3', 'delay3', 'gain3', 'mul', 'add' },{ nil, 0.0047, 0.0047, 0.15, 0.022, 0.022, 0.25, 0.0083, 0.0083, 0.3, 1.0, 0.0 },...)
	return DoubleNestedAllpassC:MultiNew{2,inp,maxdelay1,delay1,gain1,maxdelay2,delay2,gain2,maxdelay3,delay3,gain3}:madd(mul,add)
end
Lorenz2DL=UGen:new{name='Lorenz2DL'}
function Lorenz2DL.kr(...)
	local   minfreq, maxfreq, s, r, b, h, x0, y0, z0, mul, add   = assign({ 'minfreq', 'maxfreq', 's', 'r', 'b', 'h', 'x0', 'y0', 'z0', 'mul', 'add' },{ 40, 100, 10, 28, 2.6666667, 0.02, 0.090879182417163, 2.97077458055, 24.282041054363, 1.0, 0.0 },...)
	return Lorenz2DL:MultiNew{1,minfreq,maxfreq,s,r,b,h,x0,y0,z0}:madd(mul,add)
end
function Lorenz2DL.ar(...)
	local   minfreq, maxfreq, s, r, b, h, x0, y0, z0, mul, add   = assign({ 'minfreq', 'maxfreq', 's', 'r', 'b', 'h', 'x0', 'y0', 'z0', 'mul', 'add' },{ 11025, 22050, 10, 28, 2.6666667, 0.02, 0.090879182417163, 2.97077458055, 24.282041054363, 1.0, 0.0 },...)
	return Lorenz2DL:MultiNew{2,minfreq,maxfreq,s,r,b,h,x0,y0,z0}:madd(mul,add)
end
Lorenz2DC=UGen:new{name='Lorenz2DC'}
function Lorenz2DC.kr(...)
	local   minfreq, maxfreq, s, r, b, h, x0, y0, z0, mul, add   = assign({ 'minfreq', 'maxfreq', 's', 'r', 'b', 'h', 'x0', 'y0', 'z0', 'mul', 'add' },{ 40, 100, 10, 28, 2.6666667, 0.02, 0.090879182417163, 2.97077458055, 24.282041054363, 1.0, 0.0 },...)
	return Lorenz2DC:MultiNew{1,minfreq,maxfreq,s,r,b,h,x0,y0,z0}:madd(mul,add)
end
function Lorenz2DC.ar(...)
	local   minfreq, maxfreq, s, r, b, h, x0, y0, z0, mul, add   = assign({ 'minfreq', 'maxfreq', 's', 'r', 'b', 'h', 'x0', 'y0', 'z0', 'mul', 'add' },{ 11025, 22050, 10, 28, 2.6666667, 0.02, 0.090879182417163, 2.97077458055, 24.282041054363, 1.0, 0.0 },...)
	return Lorenz2DC:MultiNew{2,minfreq,maxfreq,s,r,b,h,x0,y0,z0}:madd(mul,add)
end
Fhn2DC=UGen:new{name='Fhn2DC'}
function Fhn2DC.kr(...)
	local   minfreq, maxfreq, urate, wrate, b0, b1, i, u0, w0, mul, add   = assign({ 'minfreq', 'maxfreq', 'urate', 'wrate', 'b0', 'b1', 'i', 'u0', 'w0', 'mul', 'add' },{ 40, 100, 0.1, 0.1, 0.6, 0.8, 0.0, 0.0, 0.0, 1.0, 0.0 },...)
	return Fhn2DC:MultiNew{1,minfreq,maxfreq,urate,wrate,b0,b1,i,u0,w0}:madd(mul,add)
end
function Fhn2DC.ar(...)
	local   minfreq, maxfreq, urate, wrate, b0, b1, i, u0, w0, mul, add   = assign({ 'minfreq', 'maxfreq', 'urate', 'wrate', 'b0', 'b1', 'i', 'u0', 'w0', 'mul', 'add' },{ 11025, 22050, 0.1, 0.1, 0.6, 0.8, 0.0, 0.0, 0.0, 1.0, 0.0 },...)
	return Fhn2DC:MultiNew{2,minfreq,maxfreq,urate,wrate,b0,b1,i,u0,w0}:madd(mul,add)
end
Fhn2DL=UGen:new{name='Fhn2DL'}
function Fhn2DL.kr(...)
	local   minfreq, maxfreq, urate, wrate, b0, b1, i, u0, w0, mul, add   = assign({ 'minfreq', 'maxfreq', 'urate', 'wrate', 'b0', 'b1', 'i', 'u0', 'w0', 'mul', 'add' },{ 40, 100, 0.1, 0.1, 0.6, 0.8, 0.0, 0.0, 0.0, 1.0, 0.0 },...)
	return Fhn2DL:MultiNew{1,minfreq,maxfreq,urate,wrate,b0,b1,i,u0,w0}:madd(mul,add)
end
function Fhn2DL.ar(...)
	local   minfreq, maxfreq, urate, wrate, b0, b1, i, u0, w0, mul, add   = assign({ 'minfreq', 'maxfreq', 'urate', 'wrate', 'b0', 'b1', 'i', 'u0', 'w0', 'mul', 'add' },{ 11025, 22050, 0.1, 0.1, 0.6, 0.8, 0.0, 0.0, 0.0, 1.0, 0.0 },...)
	return Fhn2DL:MultiNew{2,minfreq,maxfreq,urate,wrate,b0,b1,i,u0,w0}:madd(mul,add)
end
Limiter=UGen:new{name='Limiter'}
function Limiter.ar(...)
	local   inp, level, dur   = assign({ 'inp', 'level', 'dur' },{ 0.0, 1.0, 0.01 },...)
	return Limiter:MultiNew{2,inp,level,dur}
end
BufAllpassC=UGen:new{name='BufAllpassC'}
function BufAllpassC.ar(...)
	local   buf, inp, delaytime, decaytime, mul, add   = assign({ 'buf', 'inp', 'delaytime', 'decaytime', 'mul', 'add' },{ 0, 0.0, 0.2, 1.0, 1.0, 0.0 },...)
	return BufAllpassC:MultiNew{2,buf,inp,delaytime,decaytime}:madd(mul,add)
end
BufCombL=UGen:new{name='BufCombL'}
function BufCombL.ar(...)
	local   buf, inp, delaytime, decaytime, mul, add   = assign({ 'buf', 'inp', 'delaytime', 'decaytime', 'mul', 'add' },{ 0, 0.0, 0.2, 1.0, 1.0, 0.0 },...)
	return BufCombL:MultiNew{2,buf,inp,delaytime,decaytime}:madd(mul,add)
end
BufCombC=UGen:new{name='BufCombC'}
function BufCombC.ar(...)
	local   buf, inp, delaytime, decaytime, mul, add   = assign({ 'buf', 'inp', 'delaytime', 'decaytime', 'mul', 'add' },{ 0, 0.0, 0.2, 1.0, 1.0, 0.0 },...)
	return BufCombC:MultiNew{2,buf,inp,delaytime,decaytime}:madd(mul,add)
end
BufAllpassN=UGen:new{name='BufAllpassN'}
function BufAllpassN.ar(...)
	local   buf, inp, delaytime, decaytime, mul, add   = assign({ 'buf', 'inp', 'delaytime', 'decaytime', 'mul', 'add' },{ 0, 0.0, 0.2, 1.0, 1.0, 0.0 },...)
	return BufAllpassN:MultiNew{2,buf,inp,delaytime,decaytime}:madd(mul,add)
end
BufAllpassL=UGen:new{name='BufAllpassL'}
function BufAllpassL.ar(...)
	local   buf, inp, delaytime, decaytime, mul, add   = assign({ 'buf', 'inp', 'delaytime', 'decaytime', 'mul', 'add' },{ 0, 0.0, 0.2, 1.0, 1.0, 0.0 },...)
	return BufAllpassL:MultiNew{2,buf,inp,delaytime,decaytime}:madd(mul,add)
end
Clip=UGen:new{name='Clip'}
function Clip.ir(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ 0.0, 0.0, 1.0 },...)
	return Clip:MultiNew{0,inp,lo,hi}
end
function Clip.kr(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ 0.0, 0.0, 1.0 },...)
	return Clip:MultiNew{1,inp,lo,hi}
end
function Clip.ar(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ 0.0, 0.0, 1.0 },...)
	return Clip:MultiNew{2,inp,lo,hi}
end
Fold=UGen:new{name='Fold'}
function Fold.ir(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ 0.0, 0.0, 1.0 },...)
	return Fold:MultiNew{0,inp,lo,hi}
end
function Fold.kr(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ 0.0, 0.0, 1.0 },...)
	return Fold:MultiNew{1,inp,lo,hi}
end
function Fold.ar(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ 0.0, 0.0, 1.0 },...)
	return Fold:MultiNew{2,inp,lo,hi}
end
Schmidt=UGen:new{name='Schmidt'}
function Schmidt.ir(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ 0.0, 0.0, 1.0 },...)
	return Schmidt:MultiNew{0,inp,lo,hi}
end
function Schmidt.kr(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ 0.0, 0.0, 1.0 },...)
	return Schmidt:MultiNew{1,inp,lo,hi}
end
function Schmidt.ar(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ 0.0, 0.0, 1.0 },...)
	return Schmidt:MultiNew{2,inp,lo,hi}
end
Wrap=UGen:new{name='Wrap'}
function Wrap.ir(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ 0.0, 0.0, 1.0 },...)
	return Wrap:MultiNew{0,inp,lo,hi}
end
function Wrap.kr(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ 0.0, 0.0, 1.0 },...)
	return Wrap:MultiNew{1,inp,lo,hi}
end
function Wrap.ar(...)
	local   inp, lo, hi   = assign({ 'inp', 'lo', 'hi' },{ 0.0, 0.0, 1.0 },...)
	return Wrap:MultiNew{2,inp,lo,hi}
end
Trig=UGen:new{name='Trig'}
function Trig.kr(...)
	local   inp, dur   = assign({ 'inp', 'dur' },{ 0.0, 0.1 },...)
	return Trig:MultiNew{1,inp,dur}
end
function Trig.ar(...)
	local   inp, dur   = assign({ 'inp', 'dur' },{ 0.0, 0.1 },...)
	return Trig:MultiNew{2,inp,dur}
end
TDelay=UGen:new{name='TDelay'}
function TDelay.kr(...)
	local   inp, dur   = assign({ 'inp', 'dur' },{ 0.0, 0.1 },...)
	return TDelay:MultiNew{1,inp,dur}
end
function TDelay.ar(...)
	local   inp, dur   = assign({ 'inp', 'dur' },{ 0.0, 0.1 },...)
	return TDelay:MultiNew{2,inp,dur}
end
NLFiltL=UGen:new{name='NLFiltL'}
function NLFiltL.kr(...)
	local   input, a, b, d, c, l, mul, add   = assign({ 'input', 'a', 'b', 'd', 'c', 'l', 'mul', 'add' },{ nil, nil, nil, nil, nil, nil, 1.0, 0.0 },...)
	return NLFiltL:MultiNew{1,input,a,b,d,c,l}:madd(mul,add)
end
function NLFiltL.ar(...)
	local   input, a, b, d, c, l, mul, add   = assign({ 'input', 'a', 'b', 'd', 'c', 'l', 'mul', 'add' },{ nil, nil, nil, nil, nil, nil, 1.0, 0.0 },...)
	return NLFiltL:MultiNew{2,input,a,b,d,c,l}:madd(mul,add)
end
NLFiltC=UGen:new{name='NLFiltC'}
function NLFiltC.kr(...)
	local   input, a, b, d, c, l, mul, add   = assign({ 'input', 'a', 'b', 'd', 'c', 'l', 'mul', 'add' },{ nil, nil, nil, nil, nil, nil, 1.0, 0.0 },...)
	return NLFiltC:MultiNew{1,input,a,b,d,c,l}:madd(mul,add)
end
function NLFiltC.ar(...)
	local   input, a, b, d, c, l, mul, add   = assign({ 'input', 'a', 'b', 'd', 'c', 'l', 'mul', 'add' },{ nil, nil, nil, nil, nil, nil, 1.0, 0.0 },...)
	return NLFiltC:MultiNew{2,input,a,b,d,c,l}:madd(mul,add)
end
LFSaw=UGen:new{name='LFSaw'}
function LFSaw.kr(...)
	local   freq, iphase, mul, add   = assign({ 'freq', 'iphase', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return LFSaw:MultiNew{1,freq,iphase}:madd(mul,add)
end
function LFSaw.ar(...)
	local   freq, iphase, mul, add   = assign({ 'freq', 'iphase', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return LFSaw:MultiNew{2,freq,iphase}:madd(mul,add)
end
VOsc3=UGen:new{name='VOsc3'}
function VOsc3.kr(...)
	local   bufpos, freq1, freq2, freq3, mul, add   = assign({ 'bufpos', 'freq1', 'freq2', 'freq3', 'mul', 'add' },{ nil, 110.0, 220.0, 440.0, 1.0, 0.0 },...)
	return VOsc3:MultiNew{1,bufpos,freq1,freq2,freq3}:madd(mul,add)
end
function VOsc3.ar(...)
	local   bufpos, freq1, freq2, freq3, mul, add   = assign({ 'bufpos', 'freq1', 'freq2', 'freq3', 'mul', 'add' },{ nil, 110.0, 220.0, 440.0, 1.0, 0.0 },...)
	return VOsc3:MultiNew{2,bufpos,freq1,freq2,freq3}:madd(mul,add)
end
SinOsc=UGen:new{name='SinOsc'}
function SinOsc.kr(...)
	local   freq, phase, mul, add   = assign({ 'freq', 'phase', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return SinOsc:MultiNew{1,freq,phase}:madd(mul,add)
end
function SinOsc.ar(...)
	local   freq, phase, mul, add   = assign({ 'freq', 'phase', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return SinOsc:MultiNew{2,freq,phase}:madd(mul,add)
end
SinOscFB=UGen:new{name='SinOscFB'}
function SinOscFB.kr(...)
	local   freq, feedback, mul, add   = assign({ 'freq', 'feedback', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return SinOscFB:MultiNew{1,freq,feedback}:madd(mul,add)
end
function SinOscFB.ar(...)
	local   freq, feedback, mul, add   = assign({ 'freq', 'feedback', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return SinOscFB:MultiNew{2,freq,feedback}:madd(mul,add)
end
LFPulse=UGen:new{name='LFPulse'}
function LFPulse.kr(...)
	local   freq, iphase, width, mul, add   = assign({ 'freq', 'iphase', 'width', 'mul', 'add' },{ 440.0, 0.0, 0.5, 1.0, 0.0 },...)
	return LFPulse:MultiNew{1,freq,iphase,width}:madd(mul,add)
end
function LFPulse.ar(...)
	local   freq, iphase, width, mul, add   = assign({ 'freq', 'iphase', 'width', 'mul', 'add' },{ 440.0, 0.0, 0.5, 1.0, 0.0 },...)
	return LFPulse:MultiNew{2,freq,iphase,width}:madd(mul,add)
end
VarSaw=UGen:new{name='VarSaw'}
function VarSaw.kr(...)
	local   freq, iphase, width, mul, add   = assign({ 'freq', 'iphase', 'width', 'mul', 'add' },{ 440.0, 0.0, 0.5, 1.0, 0.0 },...)
	return VarSaw:MultiNew{1,freq,iphase,width}:madd(mul,add)
end
function VarSaw.ar(...)
	local   freq, iphase, width, mul, add   = assign({ 'freq', 'iphase', 'width', 'mul', 'add' },{ 440.0, 0.0, 0.5, 1.0, 0.0 },...)
	return VarSaw:MultiNew{2,freq,iphase,width}:madd(mul,add)
end
LinExp=UGen:new{name='LinExp'}
function LinExp.kr(...)
	local   inp, srclo, srchi, dstlo, dsthi   = assign({ 'inp', 'srclo', 'srchi', 'dstlo', 'dsthi' },{ 0.0, 0.0, 1.0, 1.0, 2.0 },...)
	return LinExp:MultiNew{1,inp,srclo,srchi,dstlo,dsthi}
end
function LinExp.ar(...)
	local   inp, srclo, srchi, dstlo, dsthi   = assign({ 'inp', 'srclo', 'srchi', 'dstlo', 'dsthi' },{ 0.0, 0.0, 1.0, 1.0, 2.0 },...)
	return LinExp:MultiNew{2,inp,srclo,srchi,dstlo,dsthi}
end
K2A=UGen:new{name='K2A'}
function K2A.ar(...)
	local   inp   = assign({ 'inp' },{ 0.0 },...)
	return K2A:MultiNew{2,inp}
end
DegreeToKey=UGen:new{name='DegreeToKey'}
function DegreeToKey.kr(...)
	local   bufnum, inp, octave, mul, add   = assign({ 'bufnum', 'inp', 'octave', 'mul', 'add' },{ nil, 0.0, 12.0, 1.0, 0.0 },...)
	return DegreeToKey:MultiNew{1,bufnum,inp,octave}:madd(mul,add)
end
function DegreeToKey.ar(...)
	local   bufnum, inp, octave, mul, add   = assign({ 'bufnum', 'inp', 'octave', 'mul', 'add' },{ nil, 0.0, 12.0, 1.0, 0.0 },...)
	return DegreeToKey:MultiNew{2,bufnum,inp,octave}:madd(mul,add)
end
AmpComp=UGen:new{name='AmpComp'}
function AmpComp.ir(...)
	local   freq, root, exp   = assign({ 'freq', 'root', 'exp' },{ nil, nil, 0.3333 },...)
	return AmpComp:MultiNew{0,freq,root,exp}
end
function AmpComp.kr(...)
	local   freq, root, exp   = assign({ 'freq', 'root', 'exp' },{ nil, nil, 0.3333 },...)
	return AmpComp:MultiNew{1,freq,root,exp}
end
function AmpComp.ar(...)
	local   freq, root, exp   = assign({ 'freq', 'root', 'exp' },{ nil, nil, 0.3333 },...)
	return AmpComp:MultiNew{2,freq,root,exp}
end
Select=UGen:new{name='Select'}
function Select.kr(...)
	local   which, array   = assign({ 'which', 'array' },{ nil, nil },...)
	return Select:MultiNew{1,which,array}
end
function Select.ar(...)
	local   which, array   = assign({ 'which', 'array' },{ nil, nil },...)
	return Select:MultiNew{2,which,array}
end
Index=UGen:new{name='Index'}
function Index.kr(...)
	local   bufnum, inp, mul, add   = assign({ 'bufnum', 'inp', 'mul', 'add' },{ nil, 0.0, 1.0, 0.0 },...)
	return Index:MultiNew{1,bufnum,inp}:madd(mul,add)
end
function Index.ar(...)
	local   bufnum, inp, mul, add   = assign({ 'bufnum', 'inp', 'mul', 'add' },{ nil, 0.0, 1.0, 0.0 },...)
	return Index:MultiNew{2,bufnum,inp}:madd(mul,add)
end
OscN=UGen:new{name='OscN'}
function OscN.kr(...)
	local   bufnum, freq, phase, mul, add   = assign({ 'bufnum', 'freq', 'phase', 'mul', 'add' },{ nil, 440.0, 0.0, 1.0, 0.0 },...)
	return OscN:MultiNew{1,bufnum,freq,phase}:madd(mul,add)
end
function OscN.ar(...)
	local   bufnum, freq, phase, mul, add   = assign({ 'bufnum', 'freq', 'phase', 'mul', 'add' },{ nil, 440.0, 0.0, 1.0, 0.0 },...)
	return OscN:MultiNew{2,bufnum,freq,phase}:madd(mul,add)
end
COsc=UGen:new{name='COsc'}
function COsc.kr(...)
	local   bufnum, freq, beats, mul, add   = assign({ 'bufnum', 'freq', 'beats', 'mul', 'add' },{ nil, 440.0, 0.5, 1.0, 0.0 },...)
	return COsc:MultiNew{1,bufnum,freq,beats}:madd(mul,add)
end
function COsc.ar(...)
	local   bufnum, freq, beats, mul, add   = assign({ 'bufnum', 'freq', 'beats', 'mul', 'add' },{ nil, 440.0, 0.5, 1.0, 0.0 },...)
	return COsc:MultiNew{2,bufnum,freq,beats}:madd(mul,add)
end
Osc=UGen:new{name='Osc'}
function Osc.kr(...)
	local   bufnum, freq, phase, mul, add   = assign({ 'bufnum', 'freq', 'phase', 'mul', 'add' },{ nil, 440.0, 0.0, 1.0, 0.0 },...)
	return Osc:MultiNew{1,bufnum,freq,phase}:madd(mul,add)
end
function Osc.ar(...)
	local   bufnum, freq, phase, mul, add   = assign({ 'bufnum', 'freq', 'phase', 'mul', 'add' },{ nil, 440.0, 0.0, 1.0, 0.0 },...)
	return Osc:MultiNew{2,bufnum,freq,phase}:madd(mul,add)
end
Delay1=UGen:new{name='Delay1'}
function Delay1.kr(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return Delay1:MultiNew{1,inp}:madd(mul,add)
end
function Delay1.ar(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return Delay1:MultiNew{2,inp}:madd(mul,add)
end
Filter=UGen:new{name='Filter'}
function Filter.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return Filter:MultiNew{2,maxSize}
end
Vibrato=UGen:new{name='Vibrato'}
function Vibrato.kr(...)
	local   freq, rate, depth, delay, onset, rateVariation, depthVariation, iphase   = assign({ 'freq', 'rate', 'depth', 'delay', 'onset', 'rateVariation', 'depthVariation', 'iphase' },{ 440.0, 6, 0.02, 0.0, 0.0, 0.04, 0.1, 0.0 },...)
	return Vibrato:MultiNew{1,freq,rate,depth,delay,onset,rateVariation,depthVariation,iphase}
end
function Vibrato.ar(...)
	local   freq, rate, depth, delay, onset, rateVariation, depthVariation, iphase   = assign({ 'freq', 'rate', 'depth', 'delay', 'onset', 'rateVariation', 'depthVariation', 'iphase' },{ 440.0, 6, 0.02, 0.0, 0.0, 0.04, 0.1, 0.0 },...)
	return Vibrato:MultiNew{2,freq,rate,depth,delay,onset,rateVariation,depthVariation,iphase}
end
Formant=UGen:new{name='Formant'}
function Formant.ar(...)
	local   fundfreq, formfreq, bwfreq, mul, add   = assign({ 'fundfreq', 'formfreq', 'bwfreq', 'mul', 'add' },{ 440.0, 1760.0, 880.0, 1.0, 0.0 },...)
	return Formant:MultiNew{2,fundfreq,formfreq,bwfreq}:madd(mul,add)
end
A2K=UGen:new{name='A2K'}
function A2K.kr(...)
	local   inp   = assign({ 'inp' },{ 0.0 },...)
	return A2K:MultiNew{1,inp}
end
CombN=UGen:new{name='CombN'}
function CombN.kr(...)
	local   inp, maxdelaytime, delaytime, decaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'decaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 1.0, 0.0 },...)
	return CombN:MultiNew{1,inp,maxdelaytime,delaytime,decaytime}:madd(mul,add)
end
function CombN.ar(...)
	local   inp, maxdelaytime, delaytime, decaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'decaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 1.0, 0.0 },...)
	return CombN:MultiNew{2,inp,maxdelaytime,delaytime,decaytime}:madd(mul,add)
end
VOsc=UGen:new{name='VOsc'}
function VOsc.kr(...)
	local   bufpos, freq, phase, mul, add   = assign({ 'bufpos', 'freq', 'phase', 'mul', 'add' },{ nil, 440.0, 0.0, 1.0, 0.0 },...)
	return VOsc:MultiNew{1,bufpos,freq,phase}:madd(mul,add)
end
function VOsc.ar(...)
	local   bufpos, freq, phase, mul, add   = assign({ 'bufpos', 'freq', 'phase', 'mul', 'add' },{ nil, 440.0, 0.0, 1.0, 0.0 },...)
	return VOsc:MultiNew{2,bufpos,freq,phase}:madd(mul,add)
end
DelayN=UGen:new{name='DelayN'}
function DelayN.kr(...)
	local   inp, maxdelaytime, delaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 0.0 },...)
	return DelayN:MultiNew{1,inp,maxdelaytime,delaytime}:madd(mul,add)
end
function DelayN.ar(...)
	local   inp, maxdelaytime, delaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 0.0 },...)
	return DelayN:MultiNew{2,inp,maxdelaytime,delaytime}:madd(mul,add)
end
Impulse=UGen:new{name='Impulse'}
function Impulse.kr(...)
	local   freq, phase, mul, add   = assign({ 'freq', 'phase', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return Impulse:MultiNew{1,freq,phase}:madd(mul,add)
end
function Impulse.ar(...)
	local   freq, phase, mul, add   = assign({ 'freq', 'phase', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return Impulse:MultiNew{2,freq,phase}:madd(mul,add)
end
SyncSaw=UGen:new{name='SyncSaw'}
function SyncSaw.kr(...)
	local   syncFreq, sawFreq, mul, add   = assign({ 'syncFreq', 'sawFreq', 'mul', 'add' },{ 440.0, 440.0, 1.0, 0.0 },...)
	return SyncSaw:MultiNew{1,syncFreq,sawFreq}:madd(mul,add)
end
function SyncSaw.ar(...)
	local   syncFreq, sawFreq, mul, add   = assign({ 'syncFreq', 'sawFreq', 'mul', 'add' },{ 440.0, 440.0, 1.0, 0.0 },...)
	return SyncSaw:MultiNew{2,syncFreq,sawFreq}:madd(mul,add)
end
LFTri=UGen:new{name='LFTri'}
function LFTri.kr(...)
	local   freq, iphase, mul, add   = assign({ 'freq', 'iphase', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return LFTri:MultiNew{1,freq,iphase}:madd(mul,add)
end
function LFTri.ar(...)
	local   freq, iphase, mul, add   = assign({ 'freq', 'iphase', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return LFTri:MultiNew{2,freq,iphase}:madd(mul,add)
end
LFCub=UGen:new{name='LFCub'}
function LFCub.kr(...)
	local   freq, iphase, mul, add   = assign({ 'freq', 'iphase', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return LFCub:MultiNew{1,freq,iphase}:madd(mul,add)
end
function LFCub.ar(...)
	local   freq, iphase, mul, add   = assign({ 'freq', 'iphase', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return LFCub:MultiNew{2,freq,iphase}:madd(mul,add)
end
LFPar=UGen:new{name='LFPar'}
function LFPar.kr(...)
	local   freq, iphase, mul, add   = assign({ 'freq', 'iphase', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return LFPar:MultiNew{1,freq,iphase}:madd(mul,add)
end
function LFPar.ar(...)
	local   freq, iphase, mul, add   = assign({ 'freq', 'iphase', 'mul', 'add' },{ 440.0, 0.0, 1.0, 0.0 },...)
	return LFPar:MultiNew{2,freq,iphase}:madd(mul,add)
end
T2A=UGen:new{name='T2A'}
function T2A.ar(...)
	local   inp, offset   = assign({ 'inp', 'offset' },{ 0.0, 0 },...)
	return T2A:MultiNew{2,inp,offset}
end
AmpCompA=UGen:new{name='AmpCompA'}
function AmpCompA.ir(...)
	local   freq, root, minAmp, rootAmp   = assign({ 'freq', 'root', 'minAmp', 'rootAmp' },{ 1000, 0, 0.32, 1.0 },...)
	return AmpCompA:MultiNew{0,freq,root,minAmp,rootAmp}
end
function AmpCompA.kr(...)
	local   freq, root, minAmp, rootAmp   = assign({ 'freq', 'root', 'minAmp', 'rootAmp' },{ 1000, 0, 0.32, 1.0 },...)
	return AmpCompA:MultiNew{1,freq,root,minAmp,rootAmp}
end
function AmpCompA.ar(...)
	local   freq, root, minAmp, rootAmp   = assign({ 'freq', 'root', 'minAmp', 'rootAmp' },{ 1000, 0, 0.32, 1.0 },...)
	return AmpCompA:MultiNew{2,freq,root,minAmp,rootAmp}
end
Shaper=UGen:new{name='Shaper'}
function Shaper.kr(...)
	local   bufnum, inp, mul, add   = assign({ 'bufnum', 'inp', 'mul', 'add' },{ nil, 0.0, 1.0, 0.0 },...)
	return Shaper:MultiNew{1,bufnum,inp}:madd(mul,add)
end
function Shaper.ar(...)
	local   bufnum, inp, mul, add   = assign({ 'bufnum', 'inp', 'mul', 'add' },{ nil, 0.0, 1.0, 0.0 },...)
	return Shaper:MultiNew{2,bufnum,inp}:madd(mul,add)
end
DetectIndex=UGen:new{name='DetectIndex'}
function DetectIndex.kr(...)
	local   bufnum, inp, mul, add   = assign({ 'bufnum', 'inp', 'mul', 'add' },{ nil, 0.0, 1.0, 0.0 },...)
	return DetectIndex:MultiNew{1,bufnum,inp}:madd(mul,add)
end
function DetectIndex.ar(...)
	local   bufnum, inp, mul, add   = assign({ 'bufnum', 'inp', 'mul', 'add' },{ nil, 0.0, 1.0, 0.0 },...)
	return DetectIndex:MultiNew{2,bufnum,inp}:madd(mul,add)
end
WrapIndex=UGen:new{name='WrapIndex'}
function WrapIndex.kr(...)
	local   bufnum, inp, mul, add   = assign({ 'bufnum', 'inp', 'mul', 'add' },{ nil, 0.0, 1.0, 0.0 },...)
	return WrapIndex:MultiNew{1,bufnum,inp}:madd(mul,add)
end
function WrapIndex.ar(...)
	local   bufnum, inp, mul, add   = assign({ 'bufnum', 'inp', 'mul', 'add' },{ nil, 0.0, 1.0, 0.0 },...)
	return WrapIndex:MultiNew{2,bufnum,inp}:madd(mul,add)
end
IndexInBetween=UGen:new{name='IndexInBetween'}
function IndexInBetween.kr(...)
	local   bufnum, inp, mul, add   = assign({ 'bufnum', 'inp', 'mul', 'add' },{ nil, 0.0, 1.0, 0.0 },...)
	return IndexInBetween:MultiNew{1,bufnum,inp}:madd(mul,add)
end
function IndexInBetween.ar(...)
	local   bufnum, inp, mul, add   = assign({ 'bufnum', 'inp', 'mul', 'add' },{ nil, 0.0, 1.0, 0.0 },...)
	return IndexInBetween:MultiNew{2,bufnum,inp}:madd(mul,add)
end
IndexL=UGen:new{name='IndexL'}
function IndexL.kr(...)
	local   bufnum, inp, mul, add   = assign({ 'bufnum', 'inp', 'mul', 'add' },{ nil, 0.0, 1.0, 0.0 },...)
	return IndexL:MultiNew{1,bufnum,inp}:madd(mul,add)
end
function IndexL.ar(...)
	local   bufnum, inp, mul, add   = assign({ 'bufnum', 'inp', 'mul', 'add' },{ nil, 0.0, 1.0, 0.0 },...)
	return IndexL:MultiNew{2,bufnum,inp}:madd(mul,add)
end
Delay2=UGen:new{name='Delay2'}
function Delay2.kr(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return Delay2:MultiNew{1,inp}:madd(mul,add)
end
function Delay2.ar(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return Delay2:MultiNew{2,inp}:madd(mul,add)
end
VarLag=UGen:new{name='VarLag'}
function VarLag.kr(...)
	local   inp, time, curvature, warp, start, mul, add   = assign({ 'inp', 'time', 'curvature', 'warp', 'start', 'mul', 'add' },{ 0.0, 0.1, 0, 5, nil, 1.0, 0.0 },...)
	return VarLag:MultiNew{1,inp,time,curvature,warp,start}:madd(mul,add)
end
function VarLag.ar(...)
	local   inp, time, curvature, warp, start, mul, add   = assign({ 'inp', 'time', 'curvature', 'warp', 'start', 'mul', 'add' },{ 0.0, 0.1, 0, 5, nil, 1.0, 0.0 },...)
	return VarLag:MultiNew{2,inp,time,curvature,warp,start}:madd(mul,add)
end
BPF=UGen:new{name='BPF'}
function BPF.kr(...)
	local   inp, freq, rq, mul, add   = assign({ 'inp', 'freq', 'rq', 'mul', 'add' },{ 0.0, 440.0, 1.0, 1.0, 0.0 },...)
	return BPF:MultiNew{1,inp,freq,rq}:madd(mul,add)
end
function BPF.ar(...)
	local   inp, freq, rq, mul, add   = assign({ 'inp', 'freq', 'rq', 'mul', 'add' },{ 0.0, 440.0, 1.0, 1.0, 0.0 },...)
	return BPF:MultiNew{2,inp,freq,rq}:madd(mul,add)
end
FreeVerb=UGen:new{name='FreeVerb'}
function FreeVerb.ar(...)
	local   inp, mix, room, damp, mul, add   = assign({ 'inp', 'mix', 'room', 'damp', 'mul', 'add' },{ nil, 0.33, 0.5, 0.5, 1.0, 0.0 },...)
	return FreeVerb:MultiNew{2,inp,mix,room,damp}:madd(mul,add)
end
CircleRamp=UGen:new{name='CircleRamp'}
function CircleRamp.kr(...)
	local   inp, lagTime, circmin, circmax, mul, add   = assign({ 'inp', 'lagTime', 'circmin', 'circmax', 'mul', 'add' },{ 0.0, 0.1, -180, 180, 1.0, 0.0 },...)
	return CircleRamp:MultiNew{1,inp,lagTime,circmin,circmax}:madd(mul,add)
end
function CircleRamp.ar(...)
	local   inp, lagTime, circmin, circmax, mul, add   = assign({ 'inp', 'lagTime', 'circmin', 'circmax', 'mul', 'add' },{ 0.0, 0.1, -180, 180, 1.0, 0.0 },...)
	return CircleRamp:MultiNew{2,inp,lagTime,circmin,circmax}:madd(mul,add)
end
LPF=UGen:new{name='LPF'}
function LPF.kr(...)
	local   inp, freq, mul, add   = assign({ 'inp', 'freq', 'mul', 'add' },{ 0.0, 440.0, 1.0, 0.0 },...)
	return LPF:MultiNew{1,inp,freq}:madd(mul,add)
end
function LPF.ar(...)
	local   inp, freq, mul, add   = assign({ 'inp', 'freq', 'mul', 'add' },{ 0.0, 440.0, 1.0, 0.0 },...)
	return LPF:MultiNew{2,inp,freq}:madd(mul,add)
end
InsideOut=UGen:new{name='InsideOut'}
function InsideOut.kr(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return InsideOut:MultiNew{1,inp}:madd(mul,add)
end
function InsideOut.ar(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return InsideOut:MultiNew{2,inp}:madd(mul,add)
end
LPZ2=UGen:new{name='LPZ2'}
function LPZ2.kr(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return LPZ2:MultiNew{1,inp}:madd(mul,add)
end
function LPZ2.ar(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return LPZ2:MultiNew{2,inp}:madd(mul,add)
end
LagUD=UGen:new{name='LagUD'}
function LagUD.kr(...)
	local   inp, lagTimeU, lagTimeD, mul, add   = assign({ 'inp', 'lagTimeU', 'lagTimeD', 'mul', 'add' },{ 0.0, 0.1, 0.1, 1.0, 0.0 },...)
	return LagUD:MultiNew{1,inp,lagTimeU,lagTimeD}:madd(mul,add)
end
function LagUD.ar(...)
	local   inp, lagTimeU, lagTimeD, mul, add   = assign({ 'inp', 'lagTimeU', 'lagTimeD', 'mul', 'add' },{ 0.0, 0.1, 0.1, 1.0, 0.0 },...)
	return LagUD:MultiNew{2,inp,lagTimeU,lagTimeD}:madd(mul,add)
end
Decay2=UGen:new{name='Decay2'}
function Decay2.kr(...)
	local   inp, attackTime, decayTime, mul, add   = assign({ 'inp', 'attackTime', 'decayTime', 'mul', 'add' },{ 0.0, 0.01, 1.0, 1.0, 0.0 },...)
	return Decay2:MultiNew{1,inp,attackTime,decayTime}:madd(mul,add)
end
function Decay2.ar(...)
	local   inp, attackTime, decayTime, mul, add   = assign({ 'inp', 'attackTime', 'decayTime', 'mul', 'add' },{ 0.0, 0.01, 1.0, 1.0, 0.0 },...)
	return Decay2:MultiNew{2,inp,attackTime,decayTime}:madd(mul,add)
end
Decay=UGen:new{name='Decay'}
function Decay.kr(...)
	local   inp, decayTime, mul, add   = assign({ 'inp', 'decayTime', 'mul', 'add' },{ 0.0, 1.0, 1.0, 0.0 },...)
	return Decay:MultiNew{1,inp,decayTime}:madd(mul,add)
end
function Decay.ar(...)
	local   inp, decayTime, mul, add   = assign({ 'inp', 'decayTime', 'mul', 'add' },{ 0.0, 1.0, 1.0, 0.0 },...)
	return Decay:MultiNew{2,inp,decayTime}:madd(mul,add)
end
OnePole=UGen:new{name='OnePole'}
function OnePole.kr(...)
	local   inp, coef, mul, add   = assign({ 'inp', 'coef', 'mul', 'add' },{ 0.0, 0.5, 1.0, 0.0 },...)
	return OnePole:MultiNew{1,inp,coef}:madd(mul,add)
end
function OnePole.ar(...)
	local   inp, coef, mul, add   = assign({ 'inp', 'coef', 'mul', 'add' },{ 0.0, 0.5, 1.0, 0.0 },...)
	return OnePole:MultiNew{2,inp,coef}:madd(mul,add)
end
Resonz=UGen:new{name='Resonz'}
function Resonz.kr(...)
	local   inp, freq, bwr, mul, add   = assign({ 'inp', 'freq', 'bwr', 'mul', 'add' },{ 0.0, 440.0, 1.0, 1.0, 0.0 },...)
	return Resonz:MultiNew{1,inp,freq,bwr}:madd(mul,add)
end
function Resonz.ar(...)
	local   inp, freq, bwr, mul, add   = assign({ 'inp', 'freq', 'bwr', 'mul', 'add' },{ 0.0, 440.0, 1.0, 1.0, 0.0 },...)
	return Resonz:MultiNew{2,inp,freq,bwr}:madd(mul,add)
end
Friction=UGen:new{name='Friction'}
function Friction.kr(...)
	local   inp, friction, spring, damp, mass, beltmass, mul, add   = assign({ 'inp', 'friction', 'spring', 'damp', 'mass', 'beltmass', 'mul', 'add' },{ nil, 0.5, 0.414, 0.313, 0.1, 1, 1, 0 },...)
	return Friction:MultiNew{1,inp,friction,spring,damp,mass,beltmass}:madd(mul,add)
end
function Friction.ar(...)
	local   inp, friction, spring, damp, mass, beltmass, mul, add   = assign({ 'inp', 'friction', 'spring', 'damp', 'mass', 'beltmass', 'mul', 'add' },{ nil, 0.5, 0.414, 0.313, 0.1, 1, 1, 0 },...)
	return Friction:MultiNew{2,inp,friction,spring,damp,mass,beltmass}:madd(mul,add)
end
MoogFF=UGen:new{name='MoogFF'}
function MoogFF.kr(...)
	local   inp, freq, gain, reset, mul, add   = assign({ 'inp', 'freq', 'gain', 'reset', 'mul', 'add' },{ nil, 100, 2, 0, 1, 0 },...)
	return MoogFF:MultiNew{1,inp,freq,gain,reset}:madd(mul,add)
end
function MoogFF.ar(...)
	local   inp, freq, gain, reset, mul, add   = assign({ 'inp', 'freq', 'gain', 'reset', 'mul', 'add' },{ nil, 100, 2, 0, 1, 0 },...)
	return MoogFF:MultiNew{2,inp,freq,gain,reset}:madd(mul,add)
end
Median=UGen:new{name='Median'}
function Median.kr(...)
	local   length, inp, mul, add   = assign({ 'length', 'inp', 'mul', 'add' },{ 3, 0.0, 1.0, 0.0 },...)
	return Median:MultiNew{1,length,inp}:madd(mul,add)
end
function Median.ar(...)
	local   length, inp, mul, add   = assign({ 'length', 'inp', 'mul', 'add' },{ 3, 0.0, 1.0, 0.0 },...)
	return Median:MultiNew{2,length,inp}:madd(mul,add)
end
Integrator=UGen:new{name='Integrator'}
function Integrator.kr(...)
	local   inp, coef, mul, add   = assign({ 'inp', 'coef', 'mul', 'add' },{ 0.0, 1.0, 1.0, 0.0 },...)
	return Integrator:MultiNew{1,inp,coef}:madd(mul,add)
end
function Integrator.ar(...)
	local   inp, coef, mul, add   = assign({ 'inp', 'coef', 'mul', 'add' },{ 0.0, 1.0, 1.0, 0.0 },...)
	return Integrator:MultiNew{2,inp,coef}:madd(mul,add)
end
DetectSilence=UGen:new{name='DetectSilence'}
function DetectSilence.kr(...)
	local   inp, amp, time, doneAction   = assign({ 'inp', 'amp', 'time', 'doneAction' },{ 0.0, 0.0001, 0.1, 0 },...)
	return DetectSilence:MultiNew{1,inp,amp,time,doneAction}
end
function DetectSilence.ar(...)
	local   inp, amp, time, doneAction   = assign({ 'inp', 'amp', 'time', 'doneAction' },{ 0.0, 0.0001, 0.1, 0 },...)
	return DetectSilence:MultiNew{2,inp,amp,time,doneAction}
end
Lag=UGen:new{name='Lag'}
function Lag.kr(...)
	local   inp, lagTime, mul, add   = assign({ 'inp', 'lagTime', 'mul', 'add' },{ 0.0, 0.1, 1.0, 0.0 },...)
	return Lag:MultiNew{1,inp,lagTime}:madd(mul,add)
end
function Lag.ar(...)
	local   inp, lagTime, mul, add   = assign({ 'inp', 'lagTime', 'mul', 'add' },{ 0.0, 0.1, 1.0, 0.0 },...)
	return Lag:MultiNew{2,inp,lagTime}:madd(mul,add)
end
LPZ1=UGen:new{name='LPZ1'}
function LPZ1.kr(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return LPZ1:MultiNew{1,inp}:madd(mul,add)
end
function LPZ1.ar(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return LPZ1:MultiNew{2,inp}:madd(mul,add)
end
Ringz=UGen:new{name='Ringz'}
function Ringz.kr(...)
	local   inp, freq, decaytime, mul, add   = assign({ 'inp', 'freq', 'decaytime', 'mul', 'add' },{ 0.0, 440.0, 1.0, 1.0, 0.0 },...)
	return Ringz:MultiNew{1,inp,freq,decaytime}:madd(mul,add)
end
function Ringz.ar(...)
	local   inp, freq, decaytime, mul, add   = assign({ 'inp', 'freq', 'decaytime', 'mul', 'add' },{ 0.0, 440.0, 1.0, 1.0, 0.0 },...)
	return Ringz:MultiNew{2,inp,freq,decaytime}:madd(mul,add)
end
WaveLoss=UGen:new{name='WaveLoss'}
function WaveLoss.kr(...)
	local   inp, drop, outof, mode, mul, add   = assign({ 'inp', 'drop', 'outof', 'mode', 'mul', 'add' },{ 0.0, 20, 40, 1, 1.0, 0.0 },...)
	return WaveLoss:MultiNew{1,inp,drop,outof,mode}:madd(mul,add)
end
function WaveLoss.ar(...)
	local   inp, drop, outof, mode, mul, add   = assign({ 'inp', 'drop', 'outof', 'mode', 'mul', 'add' },{ 0.0, 20, 40, 1, 1.0, 0.0 },...)
	return WaveLoss:MultiNew{2,inp,drop,outof,mode}:madd(mul,add)
end
FOS=UGen:new{name='FOS'}
function FOS.kr(...)
	local   inp, a0, a1, b1, mul, add   = assign({ 'inp', 'a0', 'a1', 'b1', 'mul', 'add' },{ 0.0, 0.0, 0.0, 0.0, 1.0, 0.0 },...)
	return FOS:MultiNew{1,inp,a0,a1,b1}:madd(mul,add)
end
function FOS.ar(...)
	local   inp, a0, a1, b1, mul, add   = assign({ 'inp', 'a0', 'a1', 'b1', 'mul', 'add' },{ 0.0, 0.0, 0.0, 0.0, 1.0, 0.0 },...)
	return FOS:MultiNew{2,inp,a0,a1,b1}:madd(mul,add)
end
RLPF=UGen:new{name='RLPF'}
function RLPF.kr(...)
	local   inp, freq, rq, mul, add   = assign({ 'inp', 'freq', 'rq', 'mul', 'add' },{ 0.0, 440.0, 1.0, 1.0, 0.0 },...)
	return RLPF:MultiNew{1,inp,freq,rq}:madd(mul,add)
end
function RLPF.ar(...)
	local   inp, freq, rq, mul, add   = assign({ 'inp', 'freq', 'rq', 'mul', 'add' },{ 0.0, 440.0, 1.0, 1.0, 0.0 },...)
	return RLPF:MultiNew{2,inp,freq,rq}:madd(mul,add)
end
MeanTriggered=UGen:new{name='MeanTriggered'}
function MeanTriggered.kr(...)
	local   inp, trig, length, mul, add   = assign({ 'inp', 'trig', 'length', 'mul', 'add' },{ 0.0, 0.0, 10, 1.0, 0.0 },...)
	return MeanTriggered:MultiNew{1,inp,trig,length}:madd(mul,add)
end
function MeanTriggered.ar(...)
	local   inp, trig, length, mul, add   = assign({ 'inp', 'trig', 'length', 'mul', 'add' },{ 0.0, 0.0, 10, 1.0, 0.0 },...)
	return MeanTriggered:MultiNew{2,inp,trig,length}:madd(mul,add)
end
MedianTriggered=UGen:new{name='MedianTriggered'}
function MedianTriggered.kr(...)
	local   inp, trig, length, mul, add   = assign({ 'inp', 'trig', 'length', 'mul', 'add' },{ 0.0, 0.0, 10, 1.0, 0.0 },...)
	return MedianTriggered:MultiNew{1,inp,trig,length}:madd(mul,add)
end
function MedianTriggered.ar(...)
	local   inp, trig, length, mul, add   = assign({ 'inp', 'trig', 'length', 'mul', 'add' },{ 0.0, 0.0, 10, 1.0, 0.0 },...)
	return MedianTriggered:MultiNew{2,inp,trig,length}:madd(mul,add)
end
MidEQ=UGen:new{name='MidEQ'}
function MidEQ.kr(...)
	local   inp, freq, rq, db, mul, add   = assign({ 'inp', 'freq', 'rq', 'db', 'mul', 'add' },{ 0.0, 440.0, 1.0, 0.0, 1.0, 0.0 },...)
	return MidEQ:MultiNew{1,inp,freq,rq,db}:madd(mul,add)
end
function MidEQ.ar(...)
	local   inp, freq, rq, db, mul, add   = assign({ 'inp', 'freq', 'rq', 'db', 'mul', 'add' },{ 0.0, 440.0, 1.0, 0.0, 1.0, 0.0 },...)
	return MidEQ:MultiNew{2,inp,freq,rq,db}:madd(mul,add)
end
Slew=UGen:new{name='Slew'}
function Slew.kr(...)
	local   inp, up, dn, mul, add   = assign({ 'inp', 'up', 'dn', 'mul', 'add' },{ 0.0, 1.0, 1.0, 1.0, 0.0 },...)
	return Slew:MultiNew{1,inp,up,dn}:madd(mul,add)
end
function Slew.ar(...)
	local   inp, up, dn, mul, add   = assign({ 'inp', 'up', 'dn', 'mul', 'add' },{ 0.0, 1.0, 1.0, 1.0, 0.0 },...)
	return Slew:MultiNew{2,inp,up,dn}:madd(mul,add)
end
LeakDC=UGen:new{name='LeakDC'}
function LeakDC.kr(...)
	local   inp, coef, mul, add   = assign({ 'inp', 'coef', 'mul', 'add' },{ 0.0, 0.9, 1.0, 0.0 },...)
	return LeakDC:MultiNew{1,inp,coef}:madd(mul,add)
end
function LeakDC.ar(...)
	local   inp, coef, mul, add   = assign({ 'inp', 'coef', 'mul', 'add' },{ 0.0, 0.995, 1.0, 0.0 },...)
	return LeakDC:MultiNew{2,inp,coef}:madd(mul,add)
end
TwoPole=UGen:new{name='TwoPole'}
function TwoPole.kr(...)
	local   inp, freq, radius, mul, add   = assign({ 'inp', 'freq', 'radius', 'mul', 'add' },{ 0.0, 440.0, 0.8, 1.0, 0.0 },...)
	return TwoPole:MultiNew{1,inp,freq,radius}:madd(mul,add)
end
function TwoPole.ar(...)
	local   inp, freq, radius, mul, add   = assign({ 'inp', 'freq', 'radius', 'mul', 'add' },{ 0.0, 440.0, 0.8, 1.0, 0.0 },...)
	return TwoPole:MultiNew{2,inp,freq,radius}:madd(mul,add)
end
BEQSuite=UGen:new{name='BEQSuite'}
function BEQSuite.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return BEQSuite:MultiNew{2,maxSize}
end
Slope=UGen:new{name='Slope'}
function Slope.kr(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return Slope:MultiNew{1,inp}:madd(mul,add)
end
function Slope.ar(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return Slope:MultiNew{2,inp}:madd(mul,add)
end
Formlet=UGen:new{name='Formlet'}
function Formlet.kr(...)
	local   inp, freq, attacktime, decaytime, mul, add   = assign({ 'inp', 'freq', 'attacktime', 'decaytime', 'mul', 'add' },{ 0.0, 440.0, 1.0, 1.0, 1.0, 0.0 },...)
	return Formlet:MultiNew{1,inp,freq,attacktime,decaytime}:madd(mul,add)
end
function Formlet.ar(...)
	local   inp, freq, attacktime, decaytime, mul, add   = assign({ 'inp', 'freq', 'attacktime', 'decaytime', 'mul', 'add' },{ 0.0, 440.0, 1.0, 1.0, 1.0, 0.0 },...)
	return Formlet:MultiNew{2,inp,freq,attacktime,decaytime}:madd(mul,add)
end
SOS=UGen:new{name='SOS'}
function SOS.kr(...)
	local   inp, a0, a1, a2, b1, b2, mul, add   = assign({ 'inp', 'a0', 'a1', 'a2', 'b1', 'b2', 'mul', 'add' },{ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0 },...)
	return SOS:MultiNew{1,inp,a0,a1,a2,b1,b2}:madd(mul,add)
end
function SOS.ar(...)
	local   inp, a0, a1, a2, b1, b2, mul, add   = assign({ 'inp', 'a0', 'a1', 'a2', 'b1', 'b2', 'mul', 'add' },{ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0 },...)
	return SOS:MultiNew{2,inp,a0,a1,a2,b1,b2}:madd(mul,add)
end
Changed=UGen:new{name='Changed'}
function Changed.kr(...)
	local   input, threshold   = assign({ 'input', 'threshold' },{ nil, 0 },...)
	return Changed:MultiNew{1,input,threshold}
end
function Changed.ar(...)
	local   input, threshold   = assign({ 'input', 'threshold' },{ nil, 0 },...)
	return Changed:MultiNew{2,input,threshold}
end
BRF=UGen:new{name='BRF'}
function BRF.kr(...)
	local   inp, freq, rq, mul, add   = assign({ 'inp', 'freq', 'rq', 'mul', 'add' },{ 0.0, 440.0, 1.0, 1.0, 0.0 },...)
	return BRF:MultiNew{1,inp,freq,rq}:madd(mul,add)
end
function BRF.ar(...)
	local   inp, freq, rq, mul, add   = assign({ 'inp', 'freq', 'rq', 'mul', 'add' },{ 0.0, 440.0, 1.0, 1.0, 0.0 },...)
	return BRF:MultiNew{2,inp,freq,rq}:madd(mul,add)
end
HPF=UGen:new{name='HPF'}
function HPF.kr(...)
	local   inp, freq, mul, add   = assign({ 'inp', 'freq', 'mul', 'add' },{ 0.0, 440.0, 1.0, 0.0 },...)
	return HPF:MultiNew{1,inp,freq}:madd(mul,add)
end
function HPF.ar(...)
	local   inp, freq, mul, add   = assign({ 'inp', 'freq', 'mul', 'add' },{ 0.0, 440.0, 1.0, 0.0 },...)
	return HPF:MultiNew{2,inp,freq}:madd(mul,add)
end
GlitchHPF=UGen:new{name='GlitchHPF'}
function GlitchHPF.kr(...)
	local   inp, freq, mul, add   = assign({ 'inp', 'freq', 'mul', 'add' },{ 0.0, 440.0, 1.0, 0.0 },...)
	return GlitchHPF:MultiNew{1,inp,freq}:madd(mul,add)
end
function GlitchHPF.ar(...)
	local   inp, freq, mul, add   = assign({ 'inp', 'freq', 'mul', 'add' },{ 0.0, 440.0, 1.0, 0.0 },...)
	return GlitchHPF:MultiNew{2,inp,freq}:madd(mul,add)
end
HPZ2=UGen:new{name='HPZ2'}
function HPZ2.kr(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return HPZ2:MultiNew{1,inp}:madd(mul,add)
end
function HPZ2.ar(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return HPZ2:MultiNew{2,inp}:madd(mul,add)
end
BPZ2=UGen:new{name='BPZ2'}
function BPZ2.kr(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return BPZ2:MultiNew{1,inp}:madd(mul,add)
end
function BPZ2.ar(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return BPZ2:MultiNew{2,inp}:madd(mul,add)
end
BRZ2=UGen:new{name='BRZ2'}
function BRZ2.kr(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return BRZ2:MultiNew{1,inp}:madd(mul,add)
end
function BRZ2.ar(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return BRZ2:MultiNew{2,inp}:madd(mul,add)
end
Lag2UD=UGen:new{name='Lag2UD'}
function Lag2UD.kr(...)
	local   inp, lagTimeU, lagTimeD, mul, add   = assign({ 'inp', 'lagTimeU', 'lagTimeD', 'mul', 'add' },{ 0.0, 0.1, 0.1, 1.0, 0.0 },...)
	return Lag2UD:MultiNew{1,inp,lagTimeU,lagTimeD}:madd(mul,add)
end
function Lag2UD.ar(...)
	local   inp, lagTimeU, lagTimeD, mul, add   = assign({ 'inp', 'lagTimeU', 'lagTimeD', 'mul', 'add' },{ 0.0, 0.1, 0.1, 1.0, 0.0 },...)
	return Lag2UD:MultiNew{2,inp,lagTimeU,lagTimeD}:madd(mul,add)
end
Lag3UD=UGen:new{name='Lag3UD'}
function Lag3UD.kr(...)
	local   inp, lagTimeU, lagTimeD, mul, add   = assign({ 'inp', 'lagTimeU', 'lagTimeD', 'mul', 'add' },{ 0.0, 0.1, 0.1, 1.0, 0.0 },...)
	return Lag3UD:MultiNew{1,inp,lagTimeU,lagTimeD}:madd(mul,add)
end
function Lag3UD.ar(...)
	local   inp, lagTimeU, lagTimeD, mul, add   = assign({ 'inp', 'lagTimeU', 'lagTimeD', 'mul', 'add' },{ 0.0, 0.1, 0.1, 1.0, 0.0 },...)
	return Lag3UD:MultiNew{2,inp,lagTimeU,lagTimeD}:madd(mul,add)
end
OneZero=UGen:new{name='OneZero'}
function OneZero.kr(...)
	local   inp, coef, mul, add   = assign({ 'inp', 'coef', 'mul', 'add' },{ 0.0, 0.5, 1.0, 0.0 },...)
	return OneZero:MultiNew{1,inp,coef}:madd(mul,add)
end
function OneZero.ar(...)
	local   inp, coef, mul, add   = assign({ 'inp', 'coef', 'mul', 'add' },{ 0.0, 0.5, 1.0, 0.0 },...)
	return OneZero:MultiNew{2,inp,coef}:madd(mul,add)
end
Ramp=UGen:new{name='Ramp'}
function Ramp.kr(...)
	local   inp, lagTime, mul, add   = assign({ 'inp', 'lagTime', 'mul', 'add' },{ 0.0, 0.1, 1.0, 0.0 },...)
	return Ramp:MultiNew{1,inp,lagTime}:madd(mul,add)
end
function Ramp.ar(...)
	local   inp, lagTime, mul, add   = assign({ 'inp', 'lagTime', 'mul', 'add' },{ 0.0, 0.1, 1.0, 0.0 },...)
	return Ramp:MultiNew{2,inp,lagTime}:madd(mul,add)
end
Lag3=UGen:new{name='Lag3'}
function Lag3.kr(...)
	local   inp, lagTime, mul, add   = assign({ 'inp', 'lagTime', 'mul', 'add' },{ 0.0, 0.1, 1.0, 0.0 },...)
	return Lag3:MultiNew{1,inp,lagTime}:madd(mul,add)
end
function Lag3.ar(...)
	local   inp, lagTime, mul, add   = assign({ 'inp', 'lagTime', 'mul', 'add' },{ 0.0, 0.1, 1.0, 0.0 },...)
	return Lag3:MultiNew{2,inp,lagTime}:madd(mul,add)
end
Lag2=UGen:new{name='Lag2'}
function Lag2.kr(...)
	local   inp, lagTime, mul, add   = assign({ 'inp', 'lagTime', 'mul', 'add' },{ 0.0, 0.1, 1.0, 0.0 },...)
	return Lag2:MultiNew{1,inp,lagTime}:madd(mul,add)
end
function Lag2.ar(...)
	local   inp, lagTime, mul, add   = assign({ 'inp', 'lagTime', 'mul', 'add' },{ 0.0, 0.1, 1.0, 0.0 },...)
	return Lag2:MultiNew{2,inp,lagTime}:madd(mul,add)
end
HPZ1=UGen:new{name='HPZ1'}
function HPZ1.kr(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return HPZ1:MultiNew{1,inp}:madd(mul,add)
end
function HPZ1.ar(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ 0.0, 1.0, 0.0 },...)
	return HPZ1:MultiNew{2,inp}:madd(mul,add)
end
GlitchRHPF=UGen:new{name='GlitchRHPF'}
function GlitchRHPF.kr(...)
	local   inp, freq, rq, mul, add   = assign({ 'inp', 'freq', 'rq', 'mul', 'add' },{ 0.0, 440.0, 1.0, 1.0, 0.0 },...)
	return GlitchRHPF:MultiNew{1,inp,freq,rq}:madd(mul,add)
end
function GlitchRHPF.ar(...)
	local   inp, freq, rq, mul, add   = assign({ 'inp', 'freq', 'rq', 'mul', 'add' },{ 0.0, 440.0, 1.0, 1.0, 0.0 },...)
	return GlitchRHPF:MultiNew{2,inp,freq,rq}:madd(mul,add)
end
RHPF=UGen:new{name='RHPF'}
function RHPF.kr(...)
	local   inp, freq, rq, mul, add   = assign({ 'inp', 'freq', 'rq', 'mul', 'add' },{ 0.0, 440.0, 1.0, 1.0, 0.0 },...)
	return RHPF:MultiNew{1,inp,freq,rq}:madd(mul,add)
end
function RHPF.ar(...)
	local   inp, freq, rq, mul, add   = assign({ 'inp', 'freq', 'rq', 'mul', 'add' },{ 0.0, 440.0, 1.0, 1.0, 0.0 },...)
	return RHPF:MultiNew{2,inp,freq,rq}:madd(mul,add)
end
TwoZero=UGen:new{name='TwoZero'}
function TwoZero.kr(...)
	local   inp, freq, radius, mul, add   = assign({ 'inp', 'freq', 'radius', 'mul', 'add' },{ 0.0, 440.0, 0.8, 1.0, 0.0 },...)
	return TwoZero:MultiNew{1,inp,freq,radius}:madd(mul,add)
end
function TwoZero.ar(...)
	local   inp, freq, radius, mul, add   = assign({ 'inp', 'freq', 'radius', 'mul', 'add' },{ 0.0, 440.0, 0.8, 1.0, 0.0 },...)
	return TwoZero:MultiNew{2,inp,freq,radius}:madd(mul,add)
end
APF=UGen:new{name='APF'}
function APF.kr(...)
	local   inp, freq, radius, mul, add   = assign({ 'inp', 'freq', 'radius', 'mul', 'add' },{ 0.0, 440.0, 0.8, 1.0, 0.0 },...)
	return APF:MultiNew{1,inp,freq,radius}:madd(mul,add)
end
function APF.ar(...)
	local   inp, freq, radius, mul, add   = assign({ 'inp', 'freq', 'radius', 'mul', 'add' },{ 0.0, 440.0, 0.8, 1.0, 0.0 },...)
	return APF:MultiNew{2,inp,freq,radius}:madd(mul,add)
end
BBandStop=UGen:new{name='BBandStop'}
function BBandStop.ar(...)
	local   inp, freq, bw, mul, add   = assign({ 'inp', 'freq', 'bw', 'mul', 'add' },{ nil, 1200.0, 1.0, 1.0, 0.0 },...)
	return BBandStop:MultiNew{2,inp,freq,bw}:madd(mul,add)
end
BHiPass=UGen:new{name='BHiPass'}
function BHiPass.ar(...)
	local   inp, freq, rq, mul, add   = assign({ 'inp', 'freq', 'rq', 'mul', 'add' },{ nil, 1200.0, 1.0, 1.0, 0.0 },...)
	return BHiPass:MultiNew{2,inp,freq,rq}:madd(mul,add)
end
BLowShelf=UGen:new{name='BLowShelf'}
function BLowShelf.ar(...)
	local   inp, freq, rs, db, mul, add   = assign({ 'inp', 'freq', 'rs', 'db', 'mul', 'add' },{ nil, 1200.0, 1.0, 0.0, 1.0, 0.0 },...)
	return BLowShelf:MultiNew{2,inp,freq,rs,db}:madd(mul,add)
end
BPeakEQ=UGen:new{name='BPeakEQ'}
function BPeakEQ.ar(...)
	local   inp, freq, rq, db, mul, add   = assign({ 'inp', 'freq', 'rq', 'db', 'mul', 'add' },{ nil, 1200.0, 1.0, 0.0, 1.0, 0.0 },...)
	return BPeakEQ:MultiNew{2,inp,freq,rq,db}:madd(mul,add)
end
BAllPass=UGen:new{name='BAllPass'}
function BAllPass.ar(...)
	local   inp, freq, rq, mul, add   = assign({ 'inp', 'freq', 'rq', 'mul', 'add' },{ nil, 1200.0, 1.0, 1.0, 0.0 },...)
	return BAllPass:MultiNew{2,inp,freq,rq}:madd(mul,add)
end
BHiShelf=UGen:new{name='BHiShelf'}
function BHiShelf.ar(...)
	local   inp, freq, rs, db, mul, add   = assign({ 'inp', 'freq', 'rs', 'db', 'mul', 'add' },{ nil, 1200.0, 1.0, 0.0, 1.0, 0.0 },...)
	return BHiShelf:MultiNew{2,inp,freq,rs,db}:madd(mul,add)
end
BBandPass=UGen:new{name='BBandPass'}
function BBandPass.ar(...)
	local   inp, freq, bw, mul, add   = assign({ 'inp', 'freq', 'bw', 'mul', 'add' },{ nil, 1200.0, 1.0, 1.0, 0.0 },...)
	return BBandPass:MultiNew{2,inp,freq,bw}:madd(mul,add)
end
BLowPass=UGen:new{name='BLowPass'}
function BLowPass.ar(...)
	local   inp, freq, rq, mul, add   = assign({ 'inp', 'freq', 'rq', 'mul', 'add' },{ nil, 1200.0, 1.0, 1.0, 0.0 },...)
	return BLowPass:MultiNew{2,inp,freq,rq}:madd(mul,add)
end
T2K=UGen:new{name='T2K'}
function T2K.kr(...)
	local   inp   = assign({ 'inp' },{ 0.0 },...)
	return T2K:MultiNew{1,inp}
end
CombL=UGen:new{name='CombL'}
function CombL.kr(...)
	local   inp, maxdelaytime, delaytime, decaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'decaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 1.0, 0.0 },...)
	return CombL:MultiNew{1,inp,maxdelaytime,delaytime,decaytime}:madd(mul,add)
end
function CombL.ar(...)
	local   inp, maxdelaytime, delaytime, decaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'decaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 1.0, 0.0 },...)
	return CombL:MultiNew{2,inp,maxdelaytime,delaytime,decaytime}:madd(mul,add)
end
CombC=UGen:new{name='CombC'}
function CombC.kr(...)
	local   inp, maxdelaytime, delaytime, decaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'decaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 1.0, 0.0 },...)
	return CombC:MultiNew{1,inp,maxdelaytime,delaytime,decaytime}:madd(mul,add)
end
function CombC.ar(...)
	local   inp, maxdelaytime, delaytime, decaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'decaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 1.0, 0.0 },...)
	return CombC:MultiNew{2,inp,maxdelaytime,delaytime,decaytime}:madd(mul,add)
end
AllpassC=UGen:new{name='AllpassC'}
function AllpassC.kr(...)
	local   inp, maxdelaytime, delaytime, decaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'decaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 1.0, 0.0 },...)
	return AllpassC:MultiNew{1,inp,maxdelaytime,delaytime,decaytime}:madd(mul,add)
end
function AllpassC.ar(...)
	local   inp, maxdelaytime, delaytime, decaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'decaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 1.0, 0.0 },...)
	return AllpassC:MultiNew{2,inp,maxdelaytime,delaytime,decaytime}:madd(mul,add)
end
AllpassN=UGen:new{name='AllpassN'}
function AllpassN.kr(...)
	local   inp, maxdelaytime, delaytime, decaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'decaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 1.0, 0.0 },...)
	return AllpassN:MultiNew{1,inp,maxdelaytime,delaytime,decaytime}:madd(mul,add)
end
function AllpassN.ar(...)
	local   inp, maxdelaytime, delaytime, decaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'decaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 1.0, 0.0 },...)
	return AllpassN:MultiNew{2,inp,maxdelaytime,delaytime,decaytime}:madd(mul,add)
end
AllpassL=UGen:new{name='AllpassL'}
function AllpassL.kr(...)
	local   inp, maxdelaytime, delaytime, decaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'decaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 1.0, 0.0 },...)
	return AllpassL:MultiNew{1,inp,maxdelaytime,delaytime,decaytime}:madd(mul,add)
end
function AllpassL.ar(...)
	local   inp, maxdelaytime, delaytime, decaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'decaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 1.0, 0.0 },...)
	return AllpassL:MultiNew{2,inp,maxdelaytime,delaytime,decaytime}:madd(mul,add)
end
DelayL=UGen:new{name='DelayL'}
function DelayL.kr(...)
	local   inp, maxdelaytime, delaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 0.0 },...)
	return DelayL:MultiNew{1,inp,maxdelaytime,delaytime}:madd(mul,add)
end
function DelayL.ar(...)
	local   inp, maxdelaytime, delaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 0.0 },...)
	return DelayL:MultiNew{2,inp,maxdelaytime,delaytime}:madd(mul,add)
end
DelayC=UGen:new{name='DelayC'}
function DelayC.kr(...)
	local   inp, maxdelaytime, delaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 0.0 },...)
	return DelayC:MultiNew{1,inp,maxdelaytime,delaytime}:madd(mul,add)
end
function DelayC.ar(...)
	local   inp, maxdelaytime, delaytime, mul, add   = assign({ 'inp', 'maxdelaytime', 'delaytime', 'mul', 'add' },{ 0.0, 0.2, 0.2, 1.0, 0.0 },...)
	return DelayC:MultiNew{2,inp,maxdelaytime,delaytime}:madd(mul,add)
end
Gbman2DL=UGen:new{name='Gbman2DL'}
function Gbman2DL.kr(...)
	local   minfreq, maxfreq, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'x0', 'y0', 'mul', 'add' },{ 40, 100, 1.2, 2.1, 1, 0.0 },...)
	return Gbman2DL:MultiNew{1,minfreq,maxfreq,x0,y0}:madd(mul,add)
end
function Gbman2DL.ar(...)
	local   minfreq, maxfreq, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'x0', 'y0', 'mul', 'add' },{ 11025, 22050, 1.2, 2.1, 1, 0.0 },...)
	return Gbman2DL:MultiNew{2,minfreq,maxfreq,x0,y0}:madd(mul,add)
end
Gbman2DC=UGen:new{name='Gbman2DC'}
function Gbman2DC.kr(...)
	local   minfreq, maxfreq, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'x0', 'y0', 'mul', 'add' },{ 40, 100, 1.2, 2.1, 1, 0.0 },...)
	return Gbman2DC:MultiNew{1,minfreq,maxfreq,x0,y0}:madd(mul,add)
end
function Gbman2DC.ar(...)
	local   minfreq, maxfreq, x0, y0, mul, add   = assign({ 'minfreq', 'maxfreq', 'x0', 'y0', 'mul', 'add' },{ 11025, 22050, 1.2, 2.1, 1, 0.0 },...)
	return Gbman2DC:MultiNew{2,minfreq,maxfreq,x0,y0}:madd(mul,add)
end
MouseY=UGen:new{name='MouseY'}
function MouseY.kr(...)
	local   minval, maxval, warp, lag   = assign({ 'minval', 'maxval', 'warp', 'lag' },{ 0, 1, 0, 0.2 },...)
	return MouseY:MultiNew{1,minval,maxval,warp,lag}
end
Brusselator=MultiOutUGen:new{name='Brusselator'}
function Brusselator.ar(...)
	local   reset, rate, mu, gamma, initx, inity, mul, add   = assign({ 'reset', 'rate', 'mu', 'gamma', 'initx', 'inity', 'mul', 'add' },{ 0, 0.01, 1.0, 1.0, 0.5, 0.5, 1.0, 0.0 },...)
	return Brusselator:MultiNew{2,reset,rate,mu,gamma,initx,inity}:madd(mul,add)
end
RosslerL=MultiOutUGen:new{name='RosslerL'}
function RosslerL.ar(...)
	local   freq, a, b, c, h, xi, yi, zi, mul, add   = assign({ 'freq', 'a', 'b', 'c', 'h', 'xi', 'yi', 'zi', 'mul', 'add' },{ 22050, 0.2, 0.2, 5.7, 0.05, 0.1, 0, 0, 1.0, 0.0 },...)
	return RosslerL:MultiNew{2,freq,a,b,c,h,xi,yi,zi}:madd(mul,add)
end
Chromagram=MultiOutUGen:new{name='Chromagram'}
function Chromagram.kr(...)
	local   fft, fftsize, n, tuningbase, octaves, integrationflag, coeff   = assign({ 'fft', 'fftsize', 'n', 'tuningbase', 'octaves', 'integrationflag', 'coeff' },{ nil, 2048, 12, 32.703195662575, 8, 0, 0.9 },...)
	return Chromagram:MultiNew{1,fft,fftsize,n,tuningbase,octaves,integrationflag,coeff}
end
LADSPA=MultiOutUGen:new{name='LADSPA'}
function LADSPA.ar(...)
	local   nChans, id, args   = assign({ 'nChans', 'id', 'args' },{ nil, nil, {  } },...)
	return LADSPA:MultiNew{2,nChans,id,args}
end
PanX2D=MultiOutUGen:new{name='PanX2D'}
function PanX2D.kr(...)
	local   numChansX, numChansY, inp, posX, posY, level, widthX, widthY   = assign({ 'numChansX', 'numChansY', 'inp', 'posX', 'posY', 'level', 'widthX', 'widthY' },{ nil, nil, nil, 0.0, 0.0, 1.0, 2.0, 2.0 },...)
	return PanX2D:MultiNew{1,numChansX,numChansY,inp,posX,posY,level,widthX,widthY}
end
function PanX2D.ar(...)
	local   numChansX, numChansY, inp, posX, posY, level, widthX, widthY   = assign({ 'numChansX', 'numChansY', 'inp', 'posX', 'posY', 'level', 'widthX', 'widthY' },{ nil, nil, nil, 0.0, 0.0, 1.0, 2.0, 2.0 },...)
	return PanX2D:MultiNew{2,numChansX,numChansY,inp,posX,posY,level,widthX,widthY}
end
Rotate2=MultiOutUGen:new{name='Rotate2'}
function Rotate2.kr(...)
	local   x, y, pos   = assign({ 'x', 'y', 'pos' },{ nil, nil, 0.0 },...)
	return Rotate2:MultiNew{1,x,y,pos}
end
function Rotate2.ar(...)
	local   x, y, pos   = assign({ 'x', 'y', 'pos' },{ nil, nil, 0.0 },...)
	return Rotate2:MultiNew{2,x,y,pos}
end
SpectralEntropy=MultiOutUGen:new{name='SpectralEntropy'}
function SpectralEntropy.kr(...)
	local   fft, fftsize, numbands   = assign({ 'fft', 'fftsize', 'numbands' },{ nil, 2048, 1 },...)
	return SpectralEntropy:MultiNew{1,fft,fftsize,numbands}
end
ArrayMax=MultiOutUGen:new{name='ArrayMax'}
function ArrayMax.kr(...)
	local   array   = assign({ 'array' },{ nil },...)
	return ArrayMax:MultiNew{1,array}
end
function ArrayMax.ar(...)
	local   array   = assign({ 'array' },{ nil },...)
	return ArrayMax:MultiNew{2,array}
end
WarpZ=MultiOutUGen:new{name='WarpZ'}
function WarpZ.ar(...)
	local   numChannels, bufnum, pointer, freqScale, windowSize, envbufnum, overlaps, windowRandRatio, interp, zeroSearch, zeroStart, mul, add   = assign({ 'numChannels', 'bufnum', 'pointer', 'freqScale', 'windowSize', 'envbufnum', 'overlaps', 'windowRandRatio', 'interp', 'zeroSearch', 'zeroStart', 'mul', 'add' },{ 1, 0, 0, 1, 0.2, -1, 8, 0.0, 1, 0, 0, 1, 0 },...)
	return WarpZ:MultiNew{2,numChannels,bufnum,pointer,freqScale,windowSize,envbufnum,overlaps,windowRandRatio,interp,zeroSearch,zeroStart}:madd(mul,add)
end
GrainIn=MultiOutUGen:new{name='GrainIn'}
function GrainIn.ar(...)
	local   numChannels, trigger, dur, inp, pan, envbufnum, maxGrains, mul, add   = assign({ 'numChannels', 'trigger', 'dur', 'inp', 'pan', 'envbufnum', 'maxGrains', 'mul', 'add' },{ 1, 0, 1, nil, 0, -1, 512, 1, 0 },...)
	return GrainIn:MultiNew{2,numChannels,trigger,dur,inp,pan,envbufnum,maxGrains}:madd(mul,add)
end
BeatTrack=MultiOutUGen:new{name='BeatTrack'}
function BeatTrack.kr(...)
	local   chain, lock   = assign({ 'chain', 'lock' },{ nil, 0 },...)
	return BeatTrack:MultiNew{1,chain,lock}
end
AbstractIn=MultiOutUGen:new{name='AbstractIn'}
function AbstractIn.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return AbstractIn:MultiNew{2,maxSize}
end
BufMax=MultiOutUGen:new{name='BufMax'}
function BufMax.kr(...)
	local   bufnum, gate   = assign({ 'bufnum', 'gate' },{ 0, 1 },...)
	return BufMax:MultiNew{1,bufnum,gate}
end
CQ_Diff=MultiOutUGen:new{name='CQ_Diff'}
function CQ_Diff.kr(...)
	local   in1, in2, databufnum   = assign({ 'in1', 'in2', 'databufnum' },{ 0.0, 0.0, nil },...)
	return CQ_Diff:MultiNew{1,in1,in2,databufnum}
end
Demand=MultiOutUGen:new{name='Demand'}
function Demand.kr(...)
	local   trig, reset, demandUGens   = assign({ 'trig', 'reset', 'demandUGens' },{ nil, nil, nil },...)
	return Demand:MultiNew{1,trig,reset,demandUGens}
end
function Demand.ar(...)
	local   trig, reset, demandUGens   = assign({ 'trig', 'reset', 'demandUGens' },{ nil, nil, nil },...)
	return Demand:MultiNew{2,trig,reset,demandUGens}
end
PanX=MultiOutUGen:new{name='PanX'}
function PanX.kr(...)
	local   numChans, inp, pos, level, width   = assign({ 'numChans', 'inp', 'pos', 'level', 'width' },{ nil, nil, 0.0, 1.0, 2.0 },...)
	return PanX:MultiNew{1,numChans,inp,pos,level,width}
end
function PanX.ar(...)
	local   numChans, inp, pos, level, width   = assign({ 'numChans', 'inp', 'pos', 'level', 'width' },{ nil, nil, 0.0, 1.0, 2.0 },...)
	return PanX:MultiNew{2,numChans,inp,pos,level,width}
end
LPCVals=MultiOutUGen:new{name='LPCVals'}
function LPCVals.kr(...)
	local   buffer, pointer   = assign({ 'buffer', 'pointer' },{ nil, nil },...)
	return LPCVals:MultiNew{1,buffer,pointer}
end
function LPCVals.ar(...)
	local   buffer, pointer   = assign({ 'buffer', 'pointer' },{ nil, nil },...)
	return LPCVals:MultiNew{2,buffer,pointer}
end
DecodeB2=MultiOutUGen:new{name='DecodeB2'}
function DecodeB2.kr(...)
	local   numChans, w, x, y, orientation   = assign({ 'numChans', 'w', 'x', 'y', 'orientation' },{ nil, nil, nil, nil, 0.5 },...)
	return DecodeB2:MultiNew{1,numChans,w,x,y,orientation}
end
function DecodeB2.ar(...)
	local   numChans, w, x, y, orientation   = assign({ 'numChans', 'w', 'x', 'y', 'orientation' },{ nil, nil, nil, nil, 0.5 },...)
	return DecodeB2:MultiNew{2,numChans,w,x,y,orientation}
end
Pan4=MultiOutUGen:new{name='Pan4'}
function Pan4.kr(...)
	local   inp, xpos, ypos, level   = assign({ 'inp', 'xpos', 'ypos', 'level' },{ nil, 0.0, 0.0, 1.0 },...)
	return Pan4:MultiNew{1,inp,xpos,ypos,level}
end
function Pan4.ar(...)
	local   inp, xpos, ypos, level   = assign({ 'inp', 'xpos', 'ypos', 'level' },{ nil, 0.0, 0.0, 1.0 },...)
	return Pan4:MultiNew{2,inp,xpos,ypos,level}
end
Warp1=MultiOutUGen:new{name='Warp1'}
function Warp1.ar(...)
	local   numChannels, bufnum, pointer, freqScale, windowSize, envbufnum, overlaps, windowRandRatio, interp, mul, add   = assign({ 'numChannels', 'bufnum', 'pointer', 'freqScale', 'windowSize', 'envbufnum', 'overlaps', 'windowRandRatio', 'interp', 'mul', 'add' },{ 1, 0, 0, 1, 0.2, -1, 8, 0.0, 1, 1, 0 },...)
	return Warp1:MultiNew{2,numChannels,bufnum,pointer,freqScale,windowSize,envbufnum,overlaps,windowRandRatio,interp}:madd(mul,add)
end
MdaPiano=MultiOutUGen:new{name='MdaPiano'}
function MdaPiano.ar(...)
	local   freq, gate, vel, decay, release, hard, velhard, muffle, velmuff, velcurve, stereo, tune, random, stretch, sustain, mul, add   = assign({ 'freq', 'gate', 'vel', 'decay', 'release', 'hard', 'velhard', 'muffle', 'velmuff', 'velcurve', 'stereo', 'tune', 'random', 'stretch', 'sustain', 'mul', 'add' },{ 440.0, 1, 100, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.2, 0.5, 0.1, 0.1, 0, 1, 0 },...)
	return MdaPiano:MultiNew{2,freq,gate,vel,decay,release,hard,velhard,muffle,velmuff,velcurve,stereo,tune,random,stretch,sustain}:madd(mul,add)
end
GrainSin=MultiOutUGen:new{name='GrainSin'}
function GrainSin.ar(...)
	local   numChannels, trigger, dur, freq, pan, envbufnum, maxGrains, mul, add   = assign({ 'numChannels', 'trigger', 'dur', 'freq', 'pan', 'envbufnum', 'maxGrains', 'mul', 'add' },{ 1, 0, 1, 440, 0, -1, 512, 1, 0 },...)
	return GrainSin:MultiNew{2,numChannels,trigger,dur,freq,pan,envbufnum,maxGrains}:madd(mul,add)
end
PanAz=MultiOutUGen:new{name='PanAz'}
function PanAz.kr(...)
	local   numChans, inp, pos, level, width, orientation   = assign({ 'numChans', 'inp', 'pos', 'level', 'width', 'orientation' },{ nil, nil, 0.0, 1.0, 2.0, 0.5 },...)
	return PanAz:MultiNew{1,numChans,inp,pos,level,width,orientation}
end
function PanAz.ar(...)
	local   numChans, inp, pos, level, width, orientation   = assign({ 'numChans', 'inp', 'pos', 'level', 'width', 'orientation' },{ nil, nil, 0.0, 1.0, 2.0, 0.5 },...)
	return PanAz:MultiNew{2,numChans,inp,pos,level,width,orientation}
end
Pitch=MultiOutUGen:new{name='Pitch'}
function Pitch.kr(...)
	local   inp, initFreq, minFreq, maxFreq, execFreq, maxBinsPerOctave, median, ampThreshold, peakThreshold, downSample, clar   = assign({ 'inp', 'initFreq', 'minFreq', 'maxFreq', 'execFreq', 'maxBinsPerOctave', 'median', 'ampThreshold', 'peakThreshold', 'downSample', 'clar' },{ 0.0, 440.0, 60.0, 4000.0, 100.0, 16, 1, 0.01, 0.5, 1, 0 },...)
	return Pitch:MultiNew{1,inp,initFreq,minFreq,maxFreq,execFreq,maxBinsPerOctave,median,ampThreshold,peakThreshold,downSample,clar}
end
FFTPeak=MultiOutUGen:new{name='FFTPeak'}
function FFTPeak.kr(...)
	local   buffer, freqlo, freqhi   = assign({ 'buffer', 'freqlo', 'freqhi' },{ nil, 0, 50000 },...)
	return FFTPeak:MultiNew{1,buffer,freqlo,freqhi}
end
FincoSprottL=MultiOutUGen:new{name='FincoSprottL'}
function FincoSprottL.ar(...)
	local   freq, a, h, xi, yi, zi, mul, add   = assign({ 'freq', 'a', 'h', 'xi', 'yi', 'zi', 'mul', 'add' },{ 22050, 2.45, 0.05, 0, 0, 0, 1.0, 0.0 },...)
	return FincoSprottL:MultiNew{2,freq,a,h,xi,yi,zi}:madd(mul,add)
end
VBAP=MultiOutUGen:new{name='VBAP'}
function VBAP.kr(...)
	local   numChans, inp, bufnum, azimuth, elevation, spread   = assign({ 'numChans', 'inp', 'bufnum', 'azimuth', 'elevation', 'spread' },{ nil, nil, nil, 0.0, 1.0, 0.0 },...)
	return VBAP:MultiNew{1,numChans,inp,bufnum,azimuth,elevation,spread}
end
function VBAP.ar(...)
	local   numChans, inp, bufnum, azimuth, elevation, spread   = assign({ 'numChans', 'inp', 'bufnum', 'azimuth', 'elevation', 'spread' },{ nil, nil, nil, 0.0, 1.0, 0.0 },...)
	return VBAP:MultiNew{2,numChans,inp,bufnum,azimuth,elevation,spread}
end
PlayBuf=MultiOutUGen:new{name='PlayBuf'}
function PlayBuf.kr(...)
	local   numChannels, bufnum, rate, trigger, startPos, loop, doneAction   = assign({ 'numChannels', 'bufnum', 'rate', 'trigger', 'startPos', 'loop', 'doneAction' },{ nil, 0, 1.0, 1.0, 0.0, 0.0, 0 },...)
	return PlayBuf:MultiNew{1,numChannels,bufnum,rate,trigger,startPos,loop,doneAction}
end
function PlayBuf.ar(...)
	local   numChannels, bufnum, rate, trigger, startPos, loop, doneAction   = assign({ 'numChannels', 'bufnum', 'rate', 'trigger', 'startPos', 'loop', 'doneAction' },{ nil, 0, 1.0, 1.0, 0.0, 0.0, 0 },...)
	return PlayBuf:MultiNew{2,numChannels,bufnum,rate,trigger,startPos,loop,doneAction}
end
TGrains3=MultiOutUGen:new{name='TGrains3'}
function TGrains3.ar(...)
	local   numChannels, trigger, bufnum, rate, centerPos, dur, pan, amp, att, dec, window, interp   = assign({ 'numChannels', 'trigger', 'bufnum', 'rate', 'centerPos', 'dur', 'pan', 'amp', 'att', 'dec', 'window', 'interp' },{ nil, 0, 0, 1, 0, 0.1, 0, 0.1, 0.5, 0.5, 1, 4 },...)
	return TGrains3:MultiNew{2,numChannels,trigger,bufnum,rate,centerPos,dur,pan,amp,att,dec,window,interp}
end
Balance2=MultiOutUGen:new{name='Balance2'}
function Balance2.kr(...)
	local   left, right, pos, level   = assign({ 'left', 'right', 'pos', 'level' },{ nil, nil, 0.0, 1.0 },...)
	return Balance2:MultiNew{1,left,right,pos,level}
end
function Balance2.ar(...)
	local   left, right, pos, level   = assign({ 'left', 'right', 'pos', 'level' },{ nil, nil, 0.0, 1.0 },...)
	return Balance2:MultiNew{2,left,right,pos,level}
end
Spreader=MultiOutUGen:new{name='Spreader'}
function Spreader.ar(...)
	local   inp, theta, filtsPerOctave, mul, add   = assign({ 'inp', 'theta', 'filtsPerOctave', 'mul', 'add' },{ nil, 1.5707963267949, 8, 1, 0 },...)
	return Spreader:MultiNew{2,inp,theta,filtsPerOctave}:madd(mul,add)
end
MatchingP=MultiOutUGen:new{name='MatchingP'}
function MatchingP.kr(...)
	local   dict, inp, dictsize, ntofind, hop, method   = assign({ 'dict', 'inp', 'dictsize', 'ntofind', 'hop', 'method' },{ 0, 0, 1, 1, 1, 0 },...)
	return MatchingP:MultiNew{1,dict,inp,dictsize,ntofind,hop,method}
end
function MatchingP.ar(...)
	local   dict, inp, dictsize, ntofind, hop, method   = assign({ 'dict', 'inp', 'dictsize', 'ntofind', 'hop', 'method' },{ 0, 0, 1, 1, 1, 0 },...)
	return MatchingP:MultiNew{2,dict,inp,dictsize,ntofind,hop,method}
end
AtsParInfo=MultiOutUGen:new{name='AtsParInfo'}
function AtsParInfo.kr(...)
	local   atsbuffer, partialNum, filePointer, mul, add   = assign({ 'atsbuffer', 'partialNum', 'filePointer', 'mul', 'add' },{ nil, 0, 0, 1, 0 },...)
	return AtsParInfo:MultiNew{1,atsbuffer,partialNum,filePointer}:madd(mul,add)
end
function AtsParInfo.ar(...)
	local   atsbuffer, partialNum, filePointer, mul, add   = assign({ 'atsbuffer', 'partialNum', 'filePointer', 'mul', 'add' },{ nil, 0, 0, 1, 0 },...)
	return AtsParInfo:MultiNew{2,atsbuffer,partialNum,filePointer}:madd(mul,add)
end
UnpackFFT=MultiOutUGen:new{name='UnpackFFT'}
--there was fail in
FreeVerb2=MultiOutUGen:new{name='FreeVerb2'}
function FreeVerb2.ar(...)
	local   inp, in2, mix, room, damp, mul, add   = assign({ 'inp', 'in2', 'mix', 'room', 'damp', 'mul', 'add' },{ nil, nil, 0.33, 0.5, 0.5, 1.0, 0.0 },...)
	return FreeVerb2:MultiNew{2,inp,in2,mix,room,damp}:madd(mul,add)
end
SOMRd=MultiOutUGen:new{name='SOMRd'}
function SOMRd.kr(...)
	local   bufnum, inputdata, netsize, numdims, gate   = assign({ 'bufnum', 'inputdata', 'netsize', 'numdims', 'gate' },{ nil, nil, 10, 2, 1 },...)
	return SOMRd:MultiNew{1,bufnum,inputdata,netsize,numdims,gate}
end
function SOMRd.ar(...)
	local   bufnum, inputdata, netsize, numdims, gate   = assign({ 'bufnum', 'inputdata', 'netsize', 'numdims', 'gate' },{ nil, nil, 10, 2, 1 },...)
	return SOMRd:MultiNew{2,bufnum,inputdata,netsize,numdims,gate}
end
RMAFoodChainL=MultiOutUGen:new{name='RMAFoodChainL'}
function RMAFoodChainL.ar(...)
	local   freq, a1, b1, d1, a2, b2, d2, k, r, h, xi, yi, zi, mul, add   = assign({ 'freq', 'a1', 'b1', 'd1', 'a2', 'b2', 'd2', 'k', 'r', 'h', 'xi', 'yi', 'zi', 'mul', 'add' },{ 22050, 5.0, 3.0, 0.4, 0.1, 2.0, 0.01, 1.0943, 0.8904, 0.05, 0.1, 0, 0, 1.0, 0.0 },...)
	return RMAFoodChainL:MultiNew{2,freq,a1,b1,d1,a2,b2,d2,k,r,h,xi,yi,zi}:madd(mul,add)
end
GrainFM=MultiOutUGen:new{name='GrainFM'}
function GrainFM.ar(...)
	local   numChannels, trigger, dur, carfreq, modfreq, index, pan, envbufnum, maxGrains, mul, add   = assign({ 'numChannels', 'trigger', 'dur', 'carfreq', 'modfreq', 'index', 'pan', 'envbufnum', 'maxGrains', 'mul', 'add' },{ 1, 0, 1, 440, 200, 1, 0, -1, 512, 1, 0 },...)
	return GrainFM:MultiNew{2,numChannels,trigger,dur,carfreq,modfreq,index,pan,envbufnum,maxGrains}:madd(mul,add)
end
Control=MultiOutUGen:new{name='Control'}
function Control.ir(...)
	local   values   = assign({ 'values' },{ nil },...)
	return Control:MultiNew{0,values}
end
function Control.kr(...)
	local   values   = assign({ 'values' },{ nil },...)
	return Control:MultiNew{1,values}
end
AudioControl=MultiOutUGen:new{name='AudioControl'}
function AudioControl.ar(...)
	local   values   = assign({ 'values' },{ nil },...)
	return AudioControl:MultiNew{2,values}
end
TGrains2=MultiOutUGen:new{name='TGrains2'}
function TGrains2.ar(...)
	local   numChannels, trigger, bufnum, rate, centerPos, dur, pan, amp, att, dec, interp   = assign({ 'numChannels', 'trigger', 'bufnum', 'rate', 'centerPos', 'dur', 'pan', 'amp', 'att', 'dec', 'interp' },{ nil, 0, 0, 1, 0, 0.1, 0, 0.1, 0.5, 0.5, 4 },...)
	return TGrains2:MultiNew{2,numChannels,trigger,bufnum,rate,centerPos,dur,pan,amp,att,dec,interp}
end
TGrains=MultiOutUGen:new{name='TGrains'}
function TGrains.ar(...)
	local   numChannels, trigger, bufnum, rate, centerPos, dur, pan, amp, interp   = assign({ 'numChannels', 'trigger', 'bufnum', 'rate', 'centerPos', 'dur', 'pan', 'amp', 'interp' },{ nil, 0, 0, 1, 0, 0.1, 0, 0.1, 4 },...)
	return TGrains:MultiNew{2,numChannels,trigger,bufnum,rate,centerPos,dur,pan,amp,interp}
end
SpruceBudworm=MultiOutUGen:new{name='SpruceBudworm'}
function SpruceBudworm.ar(...)
	local   reset, rate, k1, k2, alpha, beta, mu, rho, initx, inity, mul, add   = assign({ 'reset', 'rate', 'k1', 'k2', 'alpha', 'beta', 'mu', 'rho', 'initx', 'inity', 'mul', 'add' },{ 0, 0.1, 27.9, 1.5, 0.1, 10.1, 0.3, 10.1, 0.9, 0.1, 1.0, 0.0 },...)
	return SpruceBudworm:MultiNew{2,reset,rate,k1,k2,alpha,beta,mu,rho,initx,inity}:madd(mul,add)
end
FFTSubbandFlux=MultiOutUGen:new{name='FFTSubbandFlux'}
function FFTSubbandFlux.kr(...)
	local   chain, cutfreqs, posonly   = assign({ 'chain', 'cutfreqs', 'posonly' },{ nil, nil, 0 },...)
	return FFTSubbandFlux:MultiNew{1,chain,cutfreqs,posonly}
end
Foa=MultiOutUGen:new{name='Foa'}
function Foa.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return Foa:MultiNew{2,maxSize}
end
Hilbert=MultiOutUGen:new{name='Hilbert'}
function Hilbert.ar(...)
	local   inp, mul, add   = assign({ 'inp', 'mul', 'add' },{ nil, 1, 0 },...)
	return Hilbert:MultiNew{2,inp}:madd(mul,add)
end
Tartini=MultiOutUGen:new{name='Tartini'}
function Tartini.kr(...)
	local   inp, threshold, n, k, overlap, smallCutoff   = assign({ 'inp', 'threshold', 'n', 'k', 'overlap', 'smallCutoff' },{ 0.0, 0.93, 2048, 0, 1024, 0.5 },...)
	return Tartini:MultiNew{1,inp,threshold,n,k,overlap,smallCutoff}
end
PVInfo=MultiOutUGen:new{name='PVInfo'}
function PVInfo.kr(...)
	local   pvbuffer, binNum, filePointer, mul, add   = assign({ 'pvbuffer', 'binNum', 'filePointer', 'mul', 'add' },{ nil, 0, 0, 1, 0 },...)
	return PVInfo:MultiNew{1,pvbuffer,binNum,filePointer}:madd(mul,add)
end
function PVInfo.ar(...)
	local   pvbuffer, binNum, filePointer, mul, add   = assign({ 'pvbuffer', 'binNum', 'filePointer', 'mul', 'add' },{ nil, 0, 0, 1, 0 },...)
	return PVInfo:MultiNew{2,pvbuffer,binNum,filePointer}:madd(mul,add)
end
FincoSprottS=MultiOutUGen:new{name='FincoSprottS'}
function FincoSprottS.ar(...)
	local   freq, a, b, h, xi, yi, zi, mul, add   = assign({ 'freq', 'a', 'b', 'h', 'xi', 'yi', 'zi', 'mul', 'add' },{ 22050, 8, 2, 0.05, 0, 0, 0, 1.0, 0.0 },...)
	return FincoSprottS:MultiNew{2,freq,a,b,h,xi,yi,zi}:madd(mul,add)
end
BBlockerBuf=MultiOutUGen:new{name='BBlockerBuf'}
function BBlockerBuf.ar(...)
	local   freq, bufnum, startpoint   = assign({ 'freq', 'bufnum', 'startpoint' },{ nil, 0, 0 },...)
	return BBlockerBuf:MultiNew{2,freq,bufnum,startpoint}
end
StereoConvolution2L=MultiOutUGen:new{name='StereoConvolution2L'}
function StereoConvolution2L.ar(...)
	local   inp, kernelL, kernelR, trigger, framesize, crossfade, mul, add   = assign({ 'inp', 'kernelL', 'kernelR', 'trigger', 'framesize', 'crossfade', 'mul', 'add' },{ nil, nil, nil, 0, 2048, 1, 1.0, 0.0 },...)
	return StereoConvolution2L:MultiNew{2,inp,kernelL,kernelR,trigger,framesize,crossfade}:madd(mul,add)
end
FincoSprottM=MultiOutUGen:new{name='FincoSprottM'}
function FincoSprottM.ar(...)
	local   freq, a, b, h, xi, yi, zi, mul, add   = assign({ 'freq', 'a', 'b', 'h', 'xi', 'yi', 'zi', 'mul', 'add' },{ 22050, -7, 4, 0.05, 0, 0, 0, 1.0, 0.0 },...)
	return FincoSprottM:MultiNew{2,freq,a,b,h,xi,yi,zi}:madd(mul,add)
end
PanB2=MultiOutUGen:new{name='PanB2'}
function PanB2.kr(...)
	local   inp, azimuth, gain   = assign({ 'inp', 'azimuth', 'gain' },{ nil, 0, 1 },...)
	return PanB2:MultiNew{1,inp,azimuth,gain}
end
function PanB2.ar(...)
	local   inp, azimuth, gain   = assign({ 'inp', 'azimuth', 'gain' },{ nil, 0, 1 },...)
	return PanB2:MultiNew{2,inp,azimuth,gain}
end
DC=MultiOutUGen:new{name='DC'}
function DC.kr(...)
	local   inp   = assign({ 'inp' },{ 0.0 },...)
	return DC:MultiNew{1,inp}
end
function DC.ar(...)
	local   inp   = assign({ 'inp' },{ 0.0 },...)
	return DC:MultiNew{2,inp}
end
Oregonator=MultiOutUGen:new{name='Oregonator'}
function Oregonator.ar(...)
	local   reset, rate, epsilon, mu, q, initx, inity, initz, mul, add   = assign({ 'reset', 'rate', 'epsilon', 'mu', 'q', 'initx', 'inity', 'initz', 'mul', 'add' },{ 0, 0.01, 1.0, 1.0, 1.0, 0.5, 0.5, 0.5, 1.0, 0.0 },...)
	return Oregonator:MultiNew{2,reset,rate,epsilon,mu,q,initx,inity,initz}:madd(mul,add)
end
DiskIn=MultiOutUGen:new{name='DiskIn'}
function DiskIn.ar(...)
	local   numChannels, bufnum, loop   = assign({ 'numChannels', 'bufnum', 'loop' },{ nil, nil, 0 },...)
	return DiskIn:MultiNew{2,numChannels,bufnum,loop}
end
GrainBuf=MultiOutUGen:new{name='GrainBuf'}
function GrainBuf.ar(...)
	local   numChannels, trigger, dur, sndbuf, rate, pos, interp, pan, envbufnum, maxGrains, mul, add   = assign({ 'numChannels', 'trigger', 'dur', 'sndbuf', 'rate', 'pos', 'interp', 'pan', 'envbufnum', 'maxGrains', 'mul', 'add' },{ 1, 0, 1, nil, 1, 0, 2, 0, -1, 512, 1, 0 },...)
	return GrainBuf:MultiNew{2,numChannels,trigger,dur,sndbuf,rate,pos,interp,pan,envbufnum,maxGrains}:madd(mul,add)
end
BufRd=MultiOutUGen:new{name='BufRd'}
function BufRd.kr(...)
	local   numChannels, bufnum, phase, loop, interpolation   = assign({ 'numChannels', 'bufnum', 'phase', 'loop', 'interpolation' },{ nil, 0, 0.0, 1.0, 2 },...)
	return BufRd:MultiNew{1,numChannels,bufnum,phase,loop,interpolation}
end
function BufRd.ar(...)
	local   numChannels, bufnum, phase, loop, interpolation   = assign({ 'numChannels', 'bufnum', 'phase', 'loop', 'interpolation' },{ nil, 0, 0.0, 1.0, 2 },...)
	return BufRd:MultiNew{2,numChannels,bufnum,phase,loop,interpolation}
end
PanB=MultiOutUGen:new{name='PanB'}
function PanB.kr(...)
	local   inp, azimuth, elevation, gain   = assign({ 'inp', 'azimuth', 'elevation', 'gain' },{ nil, 0, 0, 1 },...)
	return PanB:MultiNew{1,inp,azimuth,elevation,gain}
end
function PanB.ar(...)
	local   inp, azimuth, elevation, gain   = assign({ 'inp', 'azimuth', 'elevation', 'gain' },{ nil, 0, 0, 1 },...)
	return PanB:MultiNew{2,inp,azimuth,elevation,gain}
end
BinData=MultiOutUGen:new{name='BinData'}
function BinData.kr(...)
	local   buffer, bin, overlaps   = assign({ 'buffer', 'bin', 'overlaps' },{ nil, nil, 0.5 },...)
	return BinData:MultiNew{1,buffer,bin,overlaps}
end
function BinData.ar(...)
	local   buffer, bin, overlaps   = assign({ 'buffer', 'bin', 'overlaps' },{ nil, nil, 0.5 },...)
	return BinData:MultiNew{2,buffer,bin,overlaps}
end
VMScan2D=MultiOutUGen:new{name='VMScan2D'}
function VMScan2D.ar(...)
	local   bufnum, mul, add   = assign({ 'bufnum', 'mul', 'add' },{ 0, 1.0, 0.0 },...)
	return VMScan2D:MultiNew{2,bufnum}:madd(mul,add)
end
MFCC=MultiOutUGen:new{name='MFCC'}
function MFCC.kr(...)
	local   chain, numcoeff   = assign({ 'chain', 'numcoeff' },{ nil, 13 },...)
	return MFCC:MultiNew{1,chain,numcoeff}
end
Goertzel=MultiOutUGen:new{name='Goertzel'}
function Goertzel.kr(...)
	local   inp, bufsize, freq, hop   = assign({ 'inp', 'bufsize', 'freq', 'hop' },{ 0.0, 1024, nil, 1 },...)
	return Goertzel:MultiNew{1,inp,bufsize,freq,hop}
end
GVerb=MultiOutUGen:new{name='GVerb'}
function GVerb.ar(...)
	local   inp, roomsize, revtime, damping, inputbw, spread, drylevel, earlyreflevel, taillevel, maxroomsize, mul, add   = assign({ 'inp', 'roomsize', 'revtime', 'damping', 'inputbw', 'spread', 'drylevel', 'earlyreflevel', 'taillevel', 'maxroomsize', 'mul', 'add' },{ nil, 10, 3, 0.5, 0.5, 15, 1, 0.7, 0.5, 300, 1, 0 },...)
	return GVerb:MultiNew{2,inp,roomsize,revtime,damping,inputbw,spread,drylevel,earlyreflevel,taillevel,maxroomsize}:madd(mul,add)
end
NearestN=MultiOutUGen:new{name='NearestN'}
function NearestN.kr(...)
	local   treebuf, inp, gate, num   = assign({ 'treebuf', 'inp', 'gate', 'num' },{ nil, nil, 1, 1 },...)
	return NearestN:MultiNew{1,treebuf,inp,gate,num}
end
SOMTrain=MultiOutUGen:new{name='SOMTrain'}
function SOMTrain.kr(...)
	local   bufnum, inputdata, netsize, numdims, traindur, nhood, gate, initweight   = assign({ 'bufnum', 'inputdata', 'netsize', 'numdims', 'traindur', 'nhood', 'gate', 'initweight' },{ nil, nil, 10, 2, 5000, 0.5, 1, 1 },...)
	return SOMTrain:MultiNew{1,bufnum,inputdata,netsize,numdims,traindur,nhood,gate,initweight}
end
LoopBuf=MultiOutUGen:new{name='LoopBuf'}
function LoopBuf.ar(...)
	local   numChannels, bufnum, rate, gate, startPos, startLoop, endLoop, interpolation   = assign({ 'numChannels', 'bufnum', 'rate', 'gate', 'startPos', 'startLoop', 'endLoop', 'interpolation' },{ nil, 0, 1.0, 1.0, 0.0, nil, nil, 2 },...)
	return LoopBuf:MultiNew{2,numChannels,bufnum,rate,gate,startPos,startLoop,endLoop,interpolation}
end
Qitch=MultiOutUGen:new{name='Qitch'}
function Qitch.kr(...)
	local   inp, databufnum, ampThreshold, algoflag, ampbufnum, minfreq, maxfreq   = assign({ 'inp', 'databufnum', 'ampThreshold', 'algoflag', 'ampbufnum', 'minfreq', 'maxfreq' },{ 0.0, nil, 0.01, 1, nil, 0, 2500 },...)
	return Qitch:MultiNew{1,inp,databufnum,ampThreshold,algoflag,ampbufnum,minfreq,maxfreq}
end
BFPanner=MultiOutUGen:new{name='BFPanner'}
function BFPanner.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return BFPanner:MultiNew{2,maxSize}
end
FFTSubbandFlatness=MultiOutUGen:new{name='FFTSubbandFlatness'}
function FFTSubbandFlatness.kr(...)
	local   chain, cutfreqs   = assign({ 'chain', 'cutfreqs' },{ nil, nil },...)
	return FFTSubbandFlatness:MultiNew{1,chain,cutfreqs}
end
FFTSubbandPower=MultiOutUGen:new{name='FFTSubbandPower'}
function FFTSubbandPower.kr(...)
	local   chain, cutfreqs, square, scalemode   = assign({ 'chain', 'cutfreqs', 'square', 'scalemode' },{ nil, nil, 1, 1 },...)
	return FFTSubbandPower:MultiNew{1,chain,cutfreqs,square,scalemode}
end
Pan2=MultiOutUGen:new{name='Pan2'}
function Pan2.kr(...)
	local   inp, pos, level   = assign({ 'inp', 'pos', 'level' },{ nil, 0.0, 1.0 },...)
	return Pan2:MultiNew{1,inp,pos,level}
end
function Pan2.ar(...)
	local   inp, pos, level   = assign({ 'inp', 'pos', 'level' },{ nil, 0.0, 1.0 },...)
	return Pan2:MultiNew{2,inp,pos,level}
end
FoaPanB=MultiOutUGen:new{name='FoaPanB'}
function FoaPanB.ar(...)
	local   inp, azimuth, elevation, mul, add   = assign({ 'inp', 'azimuth', 'elevation', 'mul', 'add' },{ nil, 0, 0, 1, 0 },...)
	return FoaPanB:MultiNew{2,inp,azimuth,elevation}:madd(mul,add)
end
BiPanB2=MultiOutUGen:new{name='BiPanB2'}
function BiPanB2.kr(...)
	local   inA, inB, azimuth, gain   = assign({ 'inA', 'inB', 'azimuth', 'gain' },{ nil, nil, nil, 1 },...)
	return BiPanB2:MultiNew{1,inA,inB,azimuth,gain}
end
function BiPanB2.ar(...)
	local   inA, inB, azimuth, gain   = assign({ 'inA', 'inB', 'azimuth', 'gain' },{ nil, nil, nil, 1 },...)
	return BiPanB2:MultiNew{2,inA,inB,azimuth,gain}
end
BeatTrack2=MultiOutUGen:new{name='BeatTrack2'}
function BeatTrack2.kr(...)
	local   busindex, numfeatures, windowsize, phaseaccuracy, lock, weightingscheme   = assign({ 'busindex', 'numfeatures', 'windowsize', 'phaseaccuracy', 'lock', 'weightingscheme' },{ nil, nil, 2.0, 0.02, 0, nil },...)
	return BeatTrack2:MultiNew{1,busindex,numfeatures,windowsize,phaseaccuracy,lock,weightingscheme}
end
SMS=MultiOutUGen:new{name='SMS'}
function SMS.ar(...)
	local   input, maxpeaks, currentpeaks, tolerance, noisefloor, freqmult, freqadd, formantpreserve, useifft, ampmult, graphicsbufnum, mul, add   = assign({ 'input', 'maxpeaks', 'currentpeaks', 'tolerance', 'noisefloor', 'freqmult', 'freqadd', 'formantpreserve', 'useifft', 'ampmult', 'graphicsbufnum', 'mul', 'add' },{ nil, 80, 80, 4, 0.2, 1.0, 0.0, 0, 0, 1.0, nil, 1.0, 0.0 },...)
	return SMS:MultiNew{2,input,maxpeaks,currentpeaks,tolerance,noisefloor,freqmult,freqadd,formantpreserve,useifft,ampmult,graphicsbufnum}:madd(mul,add)
end
VDiskIn=MultiOutUGen:new{name='VDiskIn'}
function VDiskIn.ar(...)
	local   numChannels, bufnum, rate, loop, sendID   = assign({ 'numChannels', 'bufnum', 'rate', 'loop', 'sendID' },{ nil, nil, 1, 0, 0 },...)
	return VDiskIn:MultiNew{2,numChannels,bufnum,rate,loop,sendID}
end
JoshMultiOutGrain=MultiOutUGen:new{name='JoshMultiOutGrain'}
function JoshMultiOutGrain.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return JoshMultiOutGrain:MultiNew{2,maxSize}
end
JoshMultiChannelGrain=MultiOutUGen:new{name='JoshMultiChannelGrain'}
function JoshMultiChannelGrain.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return JoshMultiChannelGrain:MultiNew{2,maxSize}
end
ArrayMin=MultiOutUGen:new{name='ArrayMin'}
function ArrayMin.kr(...)
	local   array   = assign({ 'array' },{ nil },...)
	return ArrayMin:MultiNew{1,array}
end
function ArrayMin.ar(...)
	local   array   = assign({ 'array' },{ nil },...)
	return ArrayMin:MultiNew{2,array}
end
LocalIn=MultiOutUGen:new{name='LocalIn'}
function LocalIn.kr(...)
	local   numChannels, default   = assign({ 'numChannels', 'default' },{ 1, 0.0 },...)
	return LocalIn:MultiNew{1,numChannels,default}
end
function LocalIn.ar(...)
	local   numChannels, default   = assign({ 'numChannels', 'default' },{ 1, 0.0 },...)
	return LocalIn:MultiNew{2,numChannels,default}
end
SharedIn=MultiOutUGen:new{name='SharedIn'}
function SharedIn.kr(...)
	local   bus, numChannels   = assign({ 'bus', 'numChannels' },{ 0, 1 },...)
	return SharedIn:MultiNew{1,bus,numChannels}
end
LagIn=MultiOutUGen:new{name='LagIn'}
function LagIn.kr(...)
	local   bus, numChannels, lag   = assign({ 'bus', 'numChannels', 'lag' },{ 0, 1, 0.1 },...)
	return LagIn:MultiNew{1,bus,numChannels,lag}
end
InFeedback=MultiOutUGen:new{name='InFeedback'}
function InFeedback.ar(...)
	local   bus, numChannels   = assign({ 'bus', 'numChannels' },{ 0, 1 },...)
	return InFeedback:MultiNew{2,bus,numChannels}
end
InTrig=MultiOutUGen:new{name='InTrig'}
function InTrig.kr(...)
	local   bus, numChannels   = assign({ 'bus', 'numChannels' },{ 0, 1 },...)
	return InTrig:MultiNew{1,bus,numChannels}
end
In=MultiOutUGen:new{name='In'}
function In.kr(...)
	local   bus, numChannels   = assign({ 'bus', 'numChannels' },{ 0, 1 },...)
	return In:MultiNew{1,bus,numChannels}
end
function In.ar(...)
	local   bus, numChannels   = assign({ 'bus', 'numChannels' },{ 0, 1 },...)
	return In:MultiNew{2,bus,numChannels}
end
BufMin=MultiOutUGen:new{name='BufMin'}
function BufMin.kr(...)
	local   bufnum, gate   = assign({ 'bufnum', 'gate' },{ 0, 1 },...)
	return BufMin:MultiNew{1,bufnum,gate}
end
LagControl=MultiOutUGen:new{name='LagControl'}
function LagControl.ir(...)
		return LagControl:MultiNew{0}
end
function LagControl.kr(...)
	local   values, lags   = assign({ 'values', 'lags' },{ nil, nil, nil },...)
	return LagControl:MultiNew{1,values,lags}
end
TrigControl=MultiOutUGen:new{name='TrigControl'}
function TrigControl.ir(...)
	local   values   = assign({ 'values' },{ nil },...)
	return TrigControl:MultiNew{0,values}
end
function TrigControl.kr(...)
	local   values   = assign({ 'values' },{ nil },...)
	return TrigControl:MultiNew{1,values}
end
FoaRotate=MultiOutUGen:new{name='FoaRotate'}
function FoaRotate.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaRotate:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaProximity=MultiOutUGen:new{name='FoaProximity'}
function FoaProximity.ar(...)
	local   inp, distance, mul, add   = assign({ 'inp', 'distance', 'mul', 'add' },{ nil, 1, 1, 0, nil, nil, nil, nil },...)
	return FoaProximity:MultiNew{2,inp,distance}:madd(mul,add)
end
FoaDirectX=MultiOutUGen:new{name='FoaDirectX'}
function FoaDirectX.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, nil, 1, 0, nil, nil, nil, nil },...)
	return FoaDirectX:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaPsychoShelf=MultiOutUGen:new{name='FoaPsychoShelf'}
function FoaPsychoShelf.ar(...)
	local   inp, freq, k0, k1, mul, add   = assign({ 'inp', 'freq', 'k0', 'k1', 'mul', 'add' },{ nil, 400, nil, nil, 1, 0, nil, nil, nil, nil },...)
	return FoaPsychoShelf:MultiNew{2,inp,freq,k0,k1}:madd(mul,add)
end
FoaDirectO=MultiOutUGen:new{name='FoaDirectO'}
function FoaDirectO.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, nil, 1, 0, nil, nil, nil, nil },...)
	return FoaDirectO:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaDominateX=MultiOutUGen:new{name='FoaDominateX'}
function FoaDominateX.ar(...)
	local   inp, gain, mul, add   = assign({ 'inp', 'gain', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaDominateX:MultiNew{2,inp,gain}:madd(mul,add)
end
FoaNFC=MultiOutUGen:new{name='FoaNFC'}
function FoaNFC.ar(...)
	local   inp, distance, mul, add   = assign({ 'inp', 'distance', 'mul', 'add' },{ nil, 1, 1, 0, nil, nil, nil, nil },...)
	return FoaNFC:MultiNew{2,inp,distance}:madd(mul,add)
end
FoaPushY=MultiOutUGen:new{name='FoaPushY'}
function FoaPushY.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaPushY:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaFocusX=MultiOutUGen:new{name='FoaFocusX'}
function FoaFocusX.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaFocusX:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaAsymmetry=MultiOutUGen:new{name='FoaAsymmetry'}
function FoaAsymmetry.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaAsymmetry:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaPushZ=MultiOutUGen:new{name='FoaPushZ'}
function FoaPushZ.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaPushZ:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaPushX=MultiOutUGen:new{name='FoaPushX'}
function FoaPushX.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaPushX:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaFocusZ=MultiOutUGen:new{name='FoaFocusZ'}
function FoaFocusZ.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaFocusZ:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaZoomX=MultiOutUGen:new{name='FoaZoomX'}
function FoaZoomX.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaZoomX:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaPressX=MultiOutUGen:new{name='FoaPressX'}
function FoaPressX.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaPressX:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaZoomY=MultiOutUGen:new{name='FoaZoomY'}
function FoaZoomY.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaZoomY:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaPressZ=MultiOutUGen:new{name='FoaPressZ'}
function FoaPressZ.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaPressZ:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaFocusY=MultiOutUGen:new{name='FoaFocusY'}
function FoaFocusY.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaFocusY:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaTilt=MultiOutUGen:new{name='FoaTilt'}
function FoaTilt.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaTilt:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaTumble=MultiOutUGen:new{name='FoaTumble'}
function FoaTumble.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaTumble:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaZoomZ=MultiOutUGen:new{name='FoaZoomZ'}
function FoaZoomZ.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaZoomZ:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaPressY=MultiOutUGen:new{name='FoaPressY'}
function FoaPressY.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaPressY:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaDirectZ=MultiOutUGen:new{name='FoaDirectZ'}
function FoaDirectZ.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, nil, 1, 0, nil, nil, nil, nil },...)
	return FoaDirectZ:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaDirectY=MultiOutUGen:new{name='FoaDirectY'}
function FoaDirectY.ar(...)
	local   inp, angle, mul, add   = assign({ 'inp', 'angle', 'mul', 'add' },{ nil, nil, 1, 0, nil, nil, nil, nil },...)
	return FoaDirectY:MultiNew{2,inp,angle}:madd(mul,add)
end
FoaDominateZ=MultiOutUGen:new{name='FoaDominateZ'}
function FoaDominateZ.ar(...)
	local   inp, gain, mul, add   = assign({ 'inp', 'gain', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaDominateZ:MultiNew{2,inp,gain}:madd(mul,add)
end
FoaDominateY=MultiOutUGen:new{name='FoaDominateY'}
function FoaDominateY.ar(...)
	local   inp, gain, mul, add   = assign({ 'inp', 'gain', 'mul', 'add' },{ nil, 0, 1, 0, nil, nil, nil, nil },...)
	return FoaDominateY:MultiNew{2,inp,gain}:madd(mul,add)
end
A2B=MultiOutUGen:new{name='A2B'}
function A2B.ar(...)
	local   a, b, c, d   = assign({ 'a', 'b', 'c', 'd' },{ nil, nil, nil, nil },...)
	return A2B:MultiNew{2,a,b,c,d}
end
BFEncode1=MultiOutUGen:new{name='BFEncode1'}
function BFEncode1.ar(...)
	local   inp, azimuth, elevation, rho, gain, wComp   = assign({ 'inp', 'azimuth', 'elevation', 'rho', 'gain', 'wComp' },{ nil, 0, 0, 1, 1, 0 },...)
	return BFEncode1:MultiNew{2,inp,azimuth,elevation,rho,gain,wComp}
end
Rotate=MultiOutUGen:new{name='Rotate'}
function Rotate.ar(...)
	local   w, x, y, z, rotate   = assign({ 'w', 'x', 'y', 'z', 'rotate' },{ nil, nil, nil, nil, nil, nil, nil },...)
	return Rotate:MultiNew{2,w,x,y,z,rotate}
end
Tilt=MultiOutUGen:new{name='Tilt'}
function Tilt.ar(...)
	local   w, x, y, z, tilt   = assign({ 'w', 'x', 'y', 'z', 'tilt' },{ nil, nil, nil, nil, nil, nil, nil },...)
	return Tilt:MultiNew{2,w,x,y,z,tilt}
end
Tumble=MultiOutUGen:new{name='Tumble'}
function Tumble.ar(...)
	local   w, x, y, z, tilt   = assign({ 'w', 'x', 'y', 'z', 'tilt' },{ nil, nil, nil, nil, nil, nil, nil },...)
	return Tumble:MultiNew{2,w,x,y,z,tilt}
end
BFEncodeSter=MultiOutUGen:new{name='BFEncodeSter'}
function BFEncodeSter.ar(...)
	local   l, r, azimuth, width, elevation, rho, gain, wComp   = assign({ 'l', 'r', 'azimuth', 'width', 'elevation', 'rho', 'gain', 'wComp' },{ nil, nil, 0, 1.5707963267949, 0, 1, 1, 0 },...)
	return BFEncodeSter:MultiNew{2,l,r,azimuth,width,elevation,rho,gain,wComp}
end
B2A=MultiOutUGen:new{name='B2A'}
function B2A.ar(...)
	local   w, x, y, z   = assign({ 'w', 'x', 'y', 'z' },{ nil, nil, nil, nil },...)
	return B2A:MultiNew{2,w,x,y,z}
end
UHJ2B=MultiOutUGen:new{name='UHJ2B'}
function UHJ2B.ar(...)
	local   ls, rs   = assign({ 'ls', 'rs' },{ nil, nil },...)
	return UHJ2B:MultiNew{2,ls,rs}
end
BFManipulate=MultiOutUGen:new{name='BFManipulate'}
function BFManipulate.ar(...)
	local   w, x, y, z, rotate, tilt, tumble   = assign({ 'w', 'x', 'y', 'z', 'rotate', 'tilt', 'tumble' },{ nil, nil, nil, nil, 0, 0, 0 },...)
	return BFManipulate:MultiNew{2,w,x,y,z,rotate,tilt,tumble}
end
FMHEncode2=MultiOutUGen:new{name='FMHEncode2'}
function FMHEncode2.ar(...)
	local   inp, point_x, point_y, elevation, gain, wComp   = assign({ 'inp', 'point_x', 'point_y', 'elevation', 'gain', 'wComp' },{ nil, 0, 0, 0, 1, 0 },...)
	return FMHEncode2:MultiNew{2,inp,point_x,point_y,elevation,gain,wComp}
end
B2UHJ=MultiOutUGen:new{name='B2UHJ'}
function B2UHJ.ar(...)
	local   w, x, y   = assign({ 'w', 'x', 'y' },{ nil, nil, nil },...)
	return B2UHJ:MultiNew{2,w,x,y}
end
FMHEncode0=MultiOutUGen:new{name='FMHEncode0'}
function FMHEncode0.ar(...)
	local   inp, azimuth, elevation, gain   = assign({ 'inp', 'azimuth', 'elevation', 'gain' },{ nil, 0, 0, 1 },...)
	return FMHEncode0:MultiNew{2,inp,azimuth,elevation,gain}
end
FMHEncode1=MultiOutUGen:new{name='FMHEncode1'}
function FMHEncode1.ar(...)
	local   inp, azimuth, elevation, rho, gain, wComp   = assign({ 'inp', 'azimuth', 'elevation', 'rho', 'gain', 'wComp' },{ nil, 0, 0, 1, 1, 0 },...)
	return FMHEncode1:MultiNew{2,inp,azimuth,elevation,rho,gain,wComp}
end
B2Ster=MultiOutUGen:new{name='B2Ster'}
function B2Ster.ar(...)
	local   w, x, y, mul, add   = assign({ 'w', 'x', 'y', 'mul', 'add' },{ nil, nil, nil, 1, 0 },...)
	return B2Ster:MultiNew{2,w,x,y}:madd(mul,add)
end
BFEncode2=MultiOutUGen:new{name='BFEncode2'}
function BFEncode2.ar(...)
	local   inp, point_x, point_y, elevation, gain, wComp   = assign({ 'inp', 'point_x', 'point_y', 'elevation', 'gain', 'wComp' },{ nil, 1, 1, 0, 1, 0 },...)
	return BFEncode2:MultiNew{2,inp,point_x,point_y,elevation,gain,wComp}
end
LinPan2=MultiOutUGen:new{name='LinPan2'}
function LinPan2.kr(...)
	local   inp, pos, level   = assign({ 'inp', 'pos', 'level' },{ nil, 0.0, 1.0 },...)
	return LinPan2:MultiNew{1,inp,pos,level}
end
function LinPan2.ar(...)
	local   inp, pos, level   = assign({ 'inp', 'pos', 'level' },{ nil, 0.0, 1.0 },...)
	return LinPan2:MultiNew{2,inp,pos,level}
end
FMGrainIBF=MultiOutUGen:new{name='FMGrainIBF'}
function FMGrainIBF.ar(...)
	local   trigger, dur, carfreq, modfreq, index, envbuf1, envbuf2, ifac, azimuth, elevation, rho, wComp, mul, add   = assign({ 'trigger', 'dur', 'carfreq', 'modfreq', 'index', 'envbuf1', 'envbuf2', 'ifac', 'azimuth', 'elevation', 'rho', 'wComp', 'mul', 'add' },{ 0, 1, 440, 200, 1, nil, nil, 0.5, 0, 0, 1, 0, 1, 0 },...)
	return FMGrainIBF:MultiNew{2,trigger,dur,carfreq,modfreq,index,envbuf1,envbuf2,ifac,azimuth,elevation,rho,wComp}:madd(mul,add)
end
BufGrainBF=MultiOutUGen:new{name='BufGrainBF'}
function BufGrainBF.ar(...)
	local   trigger, dur, sndbuf, rate, pos, azimuth, elevation, rho, interp, wComp, mul, add   = assign({ 'trigger', 'dur', 'sndbuf', 'rate', 'pos', 'azimuth', 'elevation', 'rho', 'interp', 'wComp', 'mul', 'add' },{ 0, 1, nil, 1, 0, 0, 0, 1, 2, 0, 1, 0 },...)
	return BufGrainBF:MultiNew{2,trigger,dur,sndbuf,rate,pos,azimuth,elevation,rho,interp,wComp}:madd(mul,add)
end
SinGrainBBF=MultiOutUGen:new{name='SinGrainBBF'}
function SinGrainBBF.ar(...)
	local   trigger, dur, freq, envbuf, azimuth, elevation, rho, wComp, mul, add   = assign({ 'trigger', 'dur', 'freq', 'envbuf', 'azimuth', 'elevation', 'rho', 'wComp', 'mul', 'add' },{ 0, 1, 440, nil, 0, 0, 1, 0, 1, 0 },...)
	return SinGrainBBF:MultiNew{2,trigger,dur,freq,envbuf,azimuth,elevation,rho,wComp}:madd(mul,add)
end
BufGrainIBF=MultiOutUGen:new{name='BufGrainIBF'}
function BufGrainIBF.ar(...)
	local   trigger, dur, sndbuf, rate, pos, envbuf1, envbuf2, ifac, azimuth, elevation, rho, interp, wComp, mul, add   = assign({ 'trigger', 'dur', 'sndbuf', 'rate', 'pos', 'envbuf1', 'envbuf2', 'ifac', 'azimuth', 'elevation', 'rho', 'interp', 'wComp', 'mul', 'add' },{ 0, 1, nil, 1, 0, nil, nil, 0.5, 0, 0, 1, 2, 0, 1, 0 },...)
	return BufGrainIBF:MultiNew{2,trigger,dur,sndbuf,rate,pos,envbuf1,envbuf2,ifac,azimuth,elevation,rho,interp,wComp}:madd(mul,add)
end
FMGrainBBF=MultiOutUGen:new{name='FMGrainBBF'}
function FMGrainBBF.ar(...)
	local   trigger, dur, carfreq, modfreq, index, envbuf, azimuth, elevation, rho, wComp, mul, add   = assign({ 'trigger', 'dur', 'carfreq', 'modfreq', 'index', 'envbuf', 'azimuth', 'elevation', 'rho', 'wComp', 'mul', 'add' },{ 0, 1, 440, 200, 1, nil, 0, 0, 1, 0, 1, 0 },...)
	return FMGrainBBF:MultiNew{2,trigger,dur,carfreq,modfreq,index,envbuf,azimuth,elevation,rho,wComp}:madd(mul,add)
end
SinGrainIBF=MultiOutUGen:new{name='SinGrainIBF'}
function SinGrainIBF.ar(...)
	local   trigger, dur, freq, envbuf1, envbuf2, ifac, azimuth, elevation, rho, wComp, mul, add   = assign({ 'trigger', 'dur', 'freq', 'envbuf1', 'envbuf2', 'ifac', 'azimuth', 'elevation', 'rho', 'wComp', 'mul', 'add' },{ 0, 1, 440, nil, nil, 0.5, 0, 0, 1, 0, 1, 0 },...)
	return SinGrainIBF:MultiNew{2,trigger,dur,freq,envbuf1,envbuf2,ifac,azimuth,elevation,rho,wComp}:madd(mul,add)
end
BFGrainPanner=MultiOutUGen:new{name='BFGrainPanner'}
function BFGrainPanner.create(...)
	local   maxSize   = assign({ 'maxSize' },{ 0 },...)
	return BFGrainPanner:MultiNew{2,maxSize}
end
SinGrainBF=MultiOutUGen:new{name='SinGrainBF'}
function SinGrainBF.ar(...)
	local   trigger, dur, freq, azimuth, elevation, rho, wComp, mul, add   = assign({ 'trigger', 'dur', 'freq', 'azimuth', 'elevation', 'rho', 'wComp', 'mul', 'add' },{ 0, 1, 440, 0, 0, 1, 0, 1, 0 },...)
	return SinGrainBF:MultiNew{2,trigger,dur,freq,azimuth,elevation,rho,wComp}:madd(mul,add)
end
FMGrainBF=MultiOutUGen:new{name='FMGrainBF'}
function FMGrainBF.ar(...)
	local   trigger, dur, carfreq, modfreq, index, azimuth, elevation, rho, wComp, mul, add   = assign({ 'trigger', 'dur', 'carfreq', 'modfreq', 'index', 'azimuth', 'elevation', 'rho', 'wComp', 'mul', 'add' },{ 0, 1, 440, 200, 1, 0, 0, 1, 0, 1, 0 },...)
	return FMGrainBF:MultiNew{2,trigger,dur,carfreq,modfreq,index,azimuth,elevation,rho,wComp}:madd(mul,add)
end
BufGrainBBF=MultiOutUGen:new{name='BufGrainBBF'}
function BufGrainBBF.ar(...)
	local   trigger, dur, sndbuf, rate, pos, envbuf, azimuth, elevation, rho, interp, wComp, mul, add   = assign({ 'trigger', 'dur', 'sndbuf', 'rate', 'pos', 'envbuf', 'azimuth', 'elevation', 'rho', 'interp', 'wComp', 'mul', 'add' },{ 0, 1, nil, 1, 0, nil, 0, 0, 1, 2, 0, 1, 0 },...)
	return BufGrainBBF:MultiNew{2,trigger,dur,sndbuf,rate,pos,envbuf,azimuth,elevation,rho,interp,wComp}:madd(mul,add)
end
InGrainBBF=MultiOutUGen:new{name='InGrainBBF'}
function InGrainBBF.ar(...)
	local   trigger, dur, inp, envbuf, azimuth, elevation, rho, wComp, mul, add   = assign({ 'trigger', 'dur', 'inp', 'envbuf', 'azimuth', 'elevation', 'rho', 'wComp', 'mul', 'add' },{ 0, 1, nil, nil, 0, 0, 1, 0, 1, 0 },...)
	return InGrainBBF:MultiNew{2,trigger,dur,inp,envbuf,azimuth,elevation,rho,wComp}:madd(mul,add)
end
InGrainBF=MultiOutUGen:new{name='InGrainBF'}
function InGrainBF.ar(...)
	local   trigger, dur, inp, azimuth, elevation, rho, wComp, mul, add   = assign({ 'trigger', 'dur', 'inp', 'azimuth', 'elevation', 'rho', 'wComp', 'mul', 'add' },{ 0, 1, nil, 0, 0, 1, 0, 1, 0 },...)
	return InGrainBF:MultiNew{2,trigger,dur,inp,azimuth,elevation,rho,wComp}:madd(mul,add)
end
InGrainIBF=MultiOutUGen:new{name='InGrainIBF'}
function InGrainIBF.ar(...)
	local   trigger, dur, inp, envbuf1, envbuf2, ifac, azimuth, elevation, rho, wComp, mul, add   = assign({ 'trigger', 'dur', 'inp', 'envbuf1', 'envbuf2', 'ifac', 'azimuth', 'elevation', 'rho', 'wComp', 'mul', 'add' },{ 0, 1, nil, nil, nil, 0.5, 0, 0, 1, 0, 1, 0 },...)
	return InGrainIBF:MultiNew{2,trigger,dur,inp,envbuf1,envbuf2,ifac,azimuth,elevation,rho,wComp}:madd(mul,add)
end
MonoGrainBF=MultiOutUGen:new{name='MonoGrainBF'}
function MonoGrainBF.ar(...)
	local   inp, winsize, grainrate, winrandpct, azimuth, azrand, elevation, elrand, rho, mul, add   = assign({ 'inp', 'winsize', 'grainrate', 'winrandpct', 'azimuth', 'azrand', 'elevation', 'elrand', 'rho', 'mul', 'add' },{ nil, 0.1, 10, 0, 0, 0, 0, 0, 1, 1, 0 },...)
	return MonoGrainBF:MultiNew{2,inp,winsize,grainrate,winrandpct,azimuth,azrand,elevation,elrand,rho}:madd(mul,add)
end
LFBrownNoise1=UGen:new{name='LFBrownNoise1'}
function LFBrownNoise1.kr(...)
	local   freq, dev, dist, mul, add   = assign({ 'freq', 'dev', 'dist', 'mul', 'add' },{ 20, 1.0, 0, 1.0, 0.0 },...)
	return LFBrownNoise1:MultiNew{1,freq,dev,dist}:madd(mul,add)
end
function LFBrownNoise1.ar(...)
	local   freq, dev, dist, mul, add   = assign({ 'freq', 'dev', 'dist', 'mul', 'add' },{ 20, 1.0, 0, 1.0, 0.0 },...)
	return LFBrownNoise1:MultiNew{2,freq,dev,dist}:madd(mul,add)
end
LFBrownNoise2=UGen:new{name='LFBrownNoise2'}
function LFBrownNoise2.kr(...)
	local   freq, dev, dist, mul, add   = assign({ 'freq', 'dev', 'dist', 'mul', 'add' },{ 20, 1.0, 0, 1.0, 0.0 },...)
	return LFBrownNoise2:MultiNew{1,freq,dev,dist}:madd(mul,add)
end
function LFBrownNoise2.ar(...)
	local   freq, dev, dist, mul, add   = assign({ 'freq', 'dev', 'dist', 'mul', 'add' },{ 20, 1.0, 0, 1.0, 0.0 },...)
	return LFBrownNoise2:MultiNew{2,freq,dev,dist}:madd(mul,add)
end
FBSineN=UGen:new{name='FBSineN'}
function FBSineN.ar(...)
	local   freq, im, fb, a, c, xi, yi, mul, add   = assign({ 'freq', 'im', 'fb', 'a', 'c', 'xi', 'yi', 'mul', 'add' },{ 22050, 1, 0.1, 1.1, 0.5, 0.1, 0.1, 1, 0 },...)
	return FBSineN:MultiNew{2,freq,im,fb,a,c,xi,yi}:madd(mul,add)
end
LatoocarfianN=UGen:new{name='LatoocarfianN'}
function LatoocarfianN.ar(...)
	local   freq, a, b, c, d, xi, yi, mul, add   = assign({ 'freq', 'a', 'b', 'c', 'd', 'xi', 'yi', 'mul', 'add' },{ 22050, 1, 3, 0.5, 0.5, 0.5, 0.5, 1.0, 0.0 },...)
	return LatoocarfianN:MultiNew{2,freq,a,b,c,d,xi,yi}:madd(mul,add)
end
QuadN=UGen:new{name='QuadN'}
function QuadN.ar(...)
	local   freq, a, b, c, xi, mul, add   = assign({ 'freq', 'a', 'b', 'c', 'xi', 'mul', 'add' },{ 22050, 1, -1, -0.75, 0, 1, 0 },...)
	return QuadN:MultiNew{2,freq,a,b,c,xi}:madd(mul,add)
end
HenonN=UGen:new{name='HenonN'}
function HenonN.ar(...)
	local   freq, a, b, x0, x1, mul, add   = assign({ 'freq', 'a', 'b', 'x0', 'x1', 'mul', 'add' },{ 22050, 1.4, 0.3, 0, 0, 1.0, 0.0 },...)
	return HenonN:MultiNew{2,freq,a,b,x0,x1}:madd(mul,add)
end
LinCongN=UGen:new{name='LinCongN'}
function LinCongN.ar(...)
	local   freq, a, c, m, xi, mul, add   = assign({ 'freq', 'a', 'c', 'm', 'xi', 'mul', 'add' },{ 22050, 1.1, 0.13, 1.0, 0, 1.0, 0.0 },...)
	return LinCongN:MultiNew{2,freq,a,c,m,xi}:madd(mul,add)
end
LorenzL=UGen:new{name='LorenzL'}
function LorenzL.ar(...)
	local   freq, s, r, b, h, xi, yi, zi, mul, add   = assign({ 'freq', 's', 'r', 'b', 'h', 'xi', 'yi', 'zi', 'mul', 'add' },{ 22050, 10, 28, 2.667, 0.05, 0.1, 0, 0, 1.0, 0.0 },...)
	return LorenzL:MultiNew{2,freq,s,r,b,h,xi,yi,zi}:madd(mul,add)
end
StandardN=UGen:new{name='StandardN'}
function StandardN.ar(...)
	local   freq, k, xi, yi, mul, add   = assign({ 'freq', 'k', 'xi', 'yi', 'mul', 'add' },{ 22050, 1.0, 0.5, 0, 1.0, 0.0 },...)
	return StandardN:MultiNew{2,freq,k,xi,yi}:madd(mul,add)
end
GbmanN=UGen:new{name='GbmanN'}
function GbmanN.ar(...)
	local   freq, xi, yi, mul, add   = assign({ 'freq', 'xi', 'yi', 'mul', 'add' },{ 22050, 1.2, 2.1, 1, 0 },...)
	return GbmanN:MultiNew{2,freq,xi,yi}:madd(mul,add)
end
CuspN=UGen:new{name='CuspN'}
function CuspN.ar(...)
	local   freq, a, b, xi, mul, add   = assign({ 'freq', 'a', 'b', 'xi', 'mul', 'add' },{ 22050, 1, 1.9, 0, 1, 0 },...)
	return CuspN:MultiNew{2,freq,a,b,xi}:madd(mul,add)
end
FBSineC=UGen:new{name='FBSineC'}
function FBSineC.ar(...)
	local   freq, im, fb, a, c, xi, yi, mul, add   = assign({ 'freq', 'im', 'fb', 'a', 'c', 'xi', 'yi', 'mul', 'add' },{ 22050, 1, 0.1, 1.1, 0.5, 0.1, 0.1, 1, 0 },...)
	return FBSineC:MultiNew{2,freq,im,fb,a,c,xi,yi}:madd(mul,add)
end
FBSineL=UGen:new{name='FBSineL'}
function FBSineL.ar(...)
	local   freq, im, fb, a, c, xi, yi, mul, add   = assign({ 'freq', 'im', 'fb', 'a', 'c', 'xi', 'yi', 'mul', 'add' },{ 22050, 1, 0.1, 1.1, 0.5, 0.1, 0.1, 1, 0 },...)
	return FBSineL:MultiNew{2,freq,im,fb,a,c,xi,yi}:madd(mul,add)
end
LatoocarfianC=UGen:new{name='LatoocarfianC'}
function LatoocarfianC.ar(...)
	local   freq, a, b, c, d, xi, yi, mul, add   = assign({ 'freq', 'a', 'b', 'c', 'd', 'xi', 'yi', 'mul', 'add' },{ 22050, 1, 3, 0.5, 0.5, 0.5, 0.5, 1.0, 0.0 },...)
	return LatoocarfianC:MultiNew{2,freq,a,b,c,d,xi,yi}:madd(mul,add)
end
LatoocarfianL=UGen:new{name='LatoocarfianL'}
function LatoocarfianL.ar(...)
	local   freq, a, b, c, d, xi, yi, mul, add   = assign({ 'freq', 'a', 'b', 'c', 'd', 'xi', 'yi', 'mul', 'add' },{ 22050, 1, 3, 0.5, 0.5, 0.5, 0.5, 1.0, 0.0 },...)
	return LatoocarfianL:MultiNew{2,freq,a,b,c,d,xi,yi}:madd(mul,add)
end
QuadL=UGen:new{name='QuadL'}
function QuadL.ar(...)
	local   freq, a, b, c, xi, mul, add   = assign({ 'freq', 'a', 'b', 'c', 'xi', 'mul', 'add' },{ 22050, 1, -1, -0.75, 0, 1, 0 },...)
	return QuadL:MultiNew{2,freq,a,b,c,xi}:madd(mul,add)
end
QuadC=UGen:new{name='QuadC'}
function QuadC.ar(...)
	local   freq, a, b, c, xi, mul, add   = assign({ 'freq', 'a', 'b', 'c', 'xi', 'mul', 'add' },{ 22050, 1, -1, -0.75, 0, 1, 0 },...)
	return QuadC:MultiNew{2,freq,a,b,c,xi}:madd(mul,add)
end
HenonL=UGen:new{name='HenonL'}
function HenonL.ar(...)
	local   freq, a, b, x0, x1, mul, add   = assign({ 'freq', 'a', 'b', 'x0', 'x1', 'mul', 'add' },{ 22050, 1.4, 0.3, 0, 0, 1.0, 0.0 },...)
	return HenonL:MultiNew{2,freq,a,b,x0,x1}:madd(mul,add)
end
HenonC=UGen:new{name='HenonC'}
function HenonC.ar(...)
	local   freq, a, b, x0, x1, mul, add   = assign({ 'freq', 'a', 'b', 'x0', 'x1', 'mul', 'add' },{ 22050, 1.4, 0.3, 0, 0, 1.0, 0.0 },...)
	return HenonC:MultiNew{2,freq,a,b,x0,x1}:madd(mul,add)
end
LinCongL=UGen:new{name='LinCongL'}
function LinCongL.ar(...)
	local   freq, a, c, m, xi, mul, add   = assign({ 'freq', 'a', 'c', 'm', 'xi', 'mul', 'add' },{ 22050, 1.1, 0.13, 1.0, 0, 1.0, 0.0 },...)
	return LinCongL:MultiNew{2,freq,a,c,m,xi}:madd(mul,add)
end
LinCongC=UGen:new{name='LinCongC'}
function LinCongC.ar(...)
	local   freq, a, c, m, xi, mul, add   = assign({ 'freq', 'a', 'c', 'm', 'xi', 'mul', 'add' },{ 22050, 1.1, 0.13, 1.0, 0, 1.0, 0.0 },...)
	return LinCongC:MultiNew{2,freq,a,c,m,xi}:madd(mul,add)
end
StandardL=UGen:new{name='StandardL'}
function StandardL.ar(...)
	local   freq, k, xi, yi, mul, add   = assign({ 'freq', 'k', 'xi', 'yi', 'mul', 'add' },{ 22050, 1.0, 0.5, 0, 1.0, 0.0 },...)
	return StandardL:MultiNew{2,freq,k,xi,yi}:madd(mul,add)
end
GbmanL=UGen:new{name='GbmanL'}
function GbmanL.ar(...)
	local   freq, xi, yi, mul, add   = assign({ 'freq', 'xi', 'yi', 'mul', 'add' },{ 22050, 1.2, 2.1, 1, 0 },...)
	return GbmanL:MultiNew{2,freq,xi,yi}:madd(mul,add)
end
CuspL=UGen:new{name='CuspL'}
function CuspL.ar(...)
	local   freq, a, b, xi, mul, add   = assign({ 'freq', 'a', 'b', 'xi', 'mul', 'add' },{ 22050, 1, 1.9, 0, 1, 0 },...)
	return CuspL:MultiNew{2,freq,a,b,xi}:madd(mul,add)
end
PV_Cutoff=UGen:new{name='PV_Cutoff'}
function PV_Cutoff.create(...)
	local   bufferA, bufferB, wipe   = assign({ 'bufferA', 'bufferB', 'wipe' },{ nil, nil, 0.0 },...)
	return PV_Cutoff:MultiNew{1,bufferA,bufferB,wipe}
end
Gendy5=UGen:new{name='Gendy5'}
function Gendy5.kr(...)
	local   ampdist, durdist, adparam, ddparam, minfreq, maxfreq, ampscale, durscale, initCPs, knum, mul, add   = assign({ 'ampdist', 'durdist', 'adparam', 'ddparam', 'minfreq', 'maxfreq', 'ampscale', 'durscale', 'initCPs', 'knum', 'mul', 'add' },{ 1, 1, 1.0, 1.0, 20, 1000, 0.5, 0.5, 12, nil, 1.0, 0.0 },...)
	return Gendy5:MultiNew{1,ampdist,durdist,adparam,ddparam,minfreq,maxfreq,ampscale,durscale,initCPs,knum}:madd(mul,add)
end
function Gendy5.ar(...)
	local   ampdist, durdist, adparam, ddparam, minfreq, maxfreq, ampscale, durscale, initCPs, knum, mul, add   = assign({ 'ampdist', 'durdist', 'adparam', 'ddparam', 'minfreq', 'maxfreq', 'ampscale', 'durscale', 'initCPs', 'knum', 'mul', 'add' },{ 1, 1, 1.0, 1.0, 440, 660, 0.5, 0.5, 12, nil, 1.0, 0.0 },...)
	return Gendy5:MultiNew{2,ampdist,durdist,adparam,ddparam,minfreq,maxfreq,ampscale,durscale,initCPs,knum}:madd(mul,add)
end
