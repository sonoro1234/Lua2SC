--  functions for compiling synthdef supercollider files
--  Copyright (C) 2012 Victor Bombi
require "sc.synthdefSCRead"
--------------utility functions
--allow defaults as in:
--function fun4d(defval)	
--	local an,en,inp = assign({"an","en","inp"},{1,2,3},defval)
--	print("fun4d",an,en,inp)
--end
--fun4d{en=67,5}
function assign(defs,defv,...)
	local defval 
	if select('#', ...)==1 and type(select(1, ...))=="table" and getmetatable(select(1, ...)) == nil then
		defval = select(1, ...)
	else
		defval = {...}
	end
	local def ={}
	--assign default
	for k,v in ipairs(defs) do
		def[v]=defv[k]
	end
	--prtable("def1",def)
	--assign integer indexed
	for k,v in pairs(defval) do
		--print("def2a ",k,v)
		if type(k)=="number" and math.floor(k)==k then
			if defs[k] then
				def[defs[k]]=v
			else
				error("bad arg index:"..k.."from only "..#defs.."args",3)
			end
		else
			def[k]=v
		end
	end
	--prtable("def2",def)
	local ret = {}
	for i,v in ipairs(defs) do
		ret[i] = def[defs[i]]
	end
	return unpack(ret,1,#defs)
end
--accepts several tables or items
local function concatTables(...)
	local res={}
	for i=1, select('#', ...) do
		local t = select(i, ...)
		if type(t)=="table" then
			assert(t~=REST)
			for _,v in ipairs(t) do
				table.insert(res,v)
			end
		else
			table.insert(res,t)
		end
	end
	return res
end
local function isSimpleTable(t)
	return (type(t)=="table" and (getmetatable(t)==nil or getmetatable(t)==_TAmt))
end
function AtUG(v,i)
	if type(v)=="table" and not v.isUGen then
		return v[i]
	else
		--print("AtUg is ugen")
		return v
	end
end
--values must be unique
local function swapkeyvalue(t)
	local res={}
	for k,v in pairs(t) do
		res[v]=k
	end
	return res
end
-- all items not just numbered sequential
local function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
local function len(t)
	return type(t)=="table" and #t or 1 
end
local function WrapAt(t,i)
	if type(t)=="table" then
		i=i%#t
		i= (i~=0) and i or #t
		return t[i]
	else
		return t
	end
end
function WrapAtUG(v,i)
	if type(v)=="table" and not v.isUGen then
		return WrapAt(v,i)
	else
		return v
	end
end
-----------------------------------
Env={isEnv=true}
function Env.new(levels,times,curve,releaseNode,loopNode)
	levels= levels or {0,1,0}
	times=times or {1,1}
	curve=curve or 'lin'
	local ret={levels=levels,times=times,curve=curve,releaseNode=releaseNode,loopNode=loopNode}
	setmetatable(ret,Env)
	Env.__index=Env
	return ret
end
--Env.create = Env.new
Env_mt = {}
Env_mt.__call=function(self,...)
	return self.new(...)
end
setmetatable(Env,Env_mt)
function Env.newClear(numSegments)
		local numSegments = numSegments or 8;
		return Env.new(TA():Fill(numSegments+1,0), TA():Fill(numSegments,1))
end
function Env:prAsArray() 

		local contents = {self.levels[1], #self.times,
				self.releaseNode or -99, self.loopNode or -99}
	
		for i=1,#self.times do
			contents[#contents+1] = self.levels[i+1]
			contents[#contents+1] = self.times[i]
			if type(self.curve)=="table" then
				--println("curva tipo table")
				contents[#contents+1] = 5
				contents[#contents+1] = WrapAtUG(self.curve,i)--self.curve[i]
			elseif type(self.curve)=="string" then
				--println("curva tipo string")
				local val=Env.shapeNames[self.curve]
				assert(type(val)=="number","not valid curve name: "..self.curve)
				contents[#contents+1] = val
				contents[#contents+1] = 0
			else
				--println("curva tipo otro:"..self.curve)
				assert(type(self.curve)=="number")
				contents[#contents+1] = 5
				contents[#contents+1] = self.curve
			end
		end
	return contents
end
function Env:asArray()
	if not self.array then
		self.array = self:prAsArray()
	end
	return self.array
end
Env.shapeNames = {
			step = 0,
			lin = 1,
			linear = 1,
			exp = 2,
			exponential = 2,
			sin = 3,
			sine = 3,
			wel = 4,
			welch = 4,
			sqr = 6,
			squared = 6,
			cub = 7,
			cubed = 7
		}

function Env.triangle(dur,level) 
		dur=dur or 1.0 
		level=level or 1.0;
		dur = dur * 0.5;
		return Env.new(
			{0, level, 0},
			{dur, dur}
		)
end
function Env.sine(dur,level) 
		dur=dur or 1.0
		level=level or 1.0;
		dur = dur * 0.5;
		return Env.new(
			{0, level, 0},
			{dur, dur},
			'sine'
		)
end
function Env.perc(attackTime, releaseTime, level, curve)
		attackTime=attackTime or 0.01
		releaseTime=releaseTime or 1.0
		level=level or 1.0
		curve = curve or -4.0;
		return Env.new(
			{0, level, 0},
			{attackTime, releaseTime},
			curve
		)
end
function Env.linen(attackTime,sustainTime, releaseTime, level, curve)
		attackTime=attackTime or 0.01
		sustainTime=sustainTime or 1.0
		releaseTime=releaseTime or 1.0
		level=level or 1.0
		curve = curve or 'lin';
		return Env.new(
			{0, level, level, 0},
			{attackTime, sustainTime, releaseTime},
			curve
		)
end

function Env.asr(attackTime,sustainLevel, releaseTime, curve)
		attackTime=attackTime or 0.01
		releaseTime=releaseTime or 1.0
		sustainLevel=sustainLevel or 1.0
		curve = curve or -4.0;
		return Env.new(
			{0, sustainLevel, 0},
			{attackTime, releaseTime},
			curve,
			1)
end
function Env.adsr(attackTime,decayTime,sustainLevel,releaseTime,peakLevel,curve, bias)
		attackTime=attackTime or 0.01;decayTime=decayTime or 0.3;sustainLevel=sustainLevel or 0.5;
		releaseTime=releaseTime or 1.0;peakLevel=peakLevel or 1.0; curve = curve or -4.0; bias = bias or 0.0
		return Env.new(
			{0 + bias, peakLevel + bias, peakLevel * sustainLevel + bias, 0 + bias},
			{attackTime, decayTime, releaseTime},
			curve,
			2)
end
--[[
	
	// envelopes with sustain
	*cutoff { arg releaseTime = 0.1, level = 1.0, curve = \lin;
		var curveNo = this.shapeNumber(curve);
		var releaseLevel = if(curveNo==2){
			-100.dbamp
		}{
			0
		};
		^this.new({level, releaseLevel}, {releaseTime}, curve, 0)
	}
	*dadsr { arg delayTime=0.1, attackTime=0.01, decayTime=0.3,
			sustainLevel=0.5, releaseTime=1.0,
				peakLevel=1.0, curve = -4.0, bias = 0.0;
		^this.new(
			{0, 0, peakLevel, peakLevel * sustainLevel, 0} + bias,
			{delayTime, attackTime, decayTime, releaseTime},
			curve,
			3
		)
	}
	

--]]
--------------not real ugens
--------------------------------------
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


------------------------------------------------

UGen={isUGen=true,specialIndex=0,visited=false,channels={}}
function UGen:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	-- self.__index=function (t, key)
		-- if type(self[key])=='function'
		-- assert(not (self[key]==nil),"index not defined:"..key)
		-- return self[key]
	-- end
	-- for copying parent metamethods (__add, ...)
	local m=getmetatable(self)
    if m then
        for k,v in pairs(m) do
            if not rawget(self,k) and k:match("^__") then
                self[k] = m[k]
            end
        end
    end
	return o
end
function UGen:new1(rate,...)
	--print("NEW1 name:"..self.name.."\n")
	local ret=self:new({calcrate=rate})
	--print("ret1 name:"..ret.name.."\n")
	_BUILDSYNTHDEF.Allugens=_BUILDSYNTHDEF.Allugens or {}
	_BUILDSYNTHDEF.Allugens[#_BUILDSYNTHDEF.Allugens+1]=ret
	return ret:init(...)
end
function UGen:init(...)
	self.inputs={...}
	return self
end
--For not expanding in MutiNew
function Ref(t)
	t.isRef=true
	return t
end
function isMultiExpandable(v)
	return type(v)=="table" and not v.isUGen and not v.isRef
end
function UGen:MultiNew(args)
	--prtable("Multinew args",args)
	local size=0
	for k,v in pairs(args) do
		if type(v)=="table" and not v.isUGen and not v.isRef then
			size= (#v>size) and #v or size
		end
	end
	--print(self.name,"MultiNew size:",size)
	if size==0 then return self:new1(unpack(args)) end
	------------------
--[[
	if size==1 then --collapse size 1 arrays
		local argscolap = {}
		for k,v in ipairs(args) do
			if type(v)=="table" and not v.isUGen and not v.isRef then
				argscolap[#argscolap +1]=WrapAt(v,i)
			else
				argscolap[#argscolap +1]=v
			end
		end
	end
--]]
	------------------
	local results=UGenArr:new()--{}
	--local results={}
	for i=1,size do
		local newargs={}
		for k,v in ipairs(args) do
			if type(v)=="table" and not v.isUGen and not v.isRef then
				newargs[#newargs +1]=WrapAt(v,i)
			else
				newargs[#newargs +1]=v
			end
		end
		results[i]=self:MultiNew(newargs)
	end
	if size == 1 then return results[1] end --collapse
	return results
end
UGen.__mul=function(a,b)
	if b == 1 then return a end
	if a == 1 then return b end
	return BinaryOpUGen.newop('*',a,b)
end
UGen.__add=function(a,b)
	if b == 0 then return a end
	if a == 0 then return b end
	return BinaryOpUGen.newop('+',a,b)
end
UGen.__sub=function(a,b)
	print"zzzzzzzzzzzzzzzzzzzzzzzzzzzzzsoy sub"
	if b == 0 then return a end
	if a == 0 then return -b end
	return BinaryOpUGen.newop('-',a,b)
end
UGen.__unm=function(a)
	return UnaryOpUGen.newop('neg',a)
end
UGen.__div=function(a,b)
	if b == 1 then return a end
	return BinaryOpUGen.newop('/',a,b)
end
UGen.__pow=function(a,b)
	if b == 1 then return a end
	return BinaryOpUGen.newop('pow',a,b)
end
UGen.__call=function(self,...)
	return self.create(...)
end
function BinOp(a,op,b)
	return BinaryOpUGen.newop(op,a,b)
end
function UGen:BOp(op,b)
	return BinaryOpUGen.newop(op,self,b)
end

--[[
--does not work metametod returns always boolean
UGen.__lt=function(a,b)
	return BinaryOpUGen.newop('<',a,b)
end
UGen.__le=function(a,b)
	return BinaryOpUGen.newop('<=',a,b)
end
--]]

function UGen:dup(n)
	--print("UGen:dup")
	n = n or 2
	local res = {}
	for i=1,n do
		res[i]=self
	end
	return UGenArr:new(res)
end
--TODO falta emular MulAdd ugen reemplazando a dos ugens
function UGen:madd(mul,add)
	if add==0 then
		if mul==1 then
			return self
		else
			return self * mul
		end
	else
		if mul==1 then
			return self + add
		else
			--return self * mul + add
			print("zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz MULADD")
			return MulAdd:newmuladd(self,mul,add)
		end
	end
end
function UGen:lag(t1,t2)
	local t1 = t1 or 0.1
	if t2 then
		return LagUD:MultiNew({self.calcrate,self,t1,t2})
	else
		return Lag:MultiNew({self.calcrate,self,t1})
	end
end
-------------operators
--[[
function UGen:round(b) return BinaryOpUGen.newop('round',self,b) end
function UGen:pow(b) return BinaryOpUGen.newop('pow',self,b) end
function UGen:max(b) return BinaryOpUGen.newop('max',self,b) end
function UGen:min(b) return BinaryOpUGen.newop('min',self,b) end
function UGen:clip2(b) return BinaryOpUGen.newop('clip2',self,b) end
function UGen:ring1(b) return BinaryOpUGen.newop('ring1',self,b) end
function UGen:midicps() return UnaryOpUGen.newop('midicps',self) end
function UGen:ampdb() return UnaryOpUGen.newop('ampdb',self) end
function UGen:dbamp() return UnaryOpUGen.newop('dbamp',self) end
function UGen:neg() return UnaryOpUGen.newop('neg',self) end
function UGen:reciprocal() return UnaryOpUGen.newop('reciprocal',self) end
--function UGen:round() return UnaryOpUGen.newop('round',self) end
function UGen:tanh() return UnaryOpUGen.newop('tanh',self) end
function UGen:distort() return UnaryOpUGen.newop('distort',self) end
function UGen:sqrt() return UnaryOpUGen.newop('sqrt',self) end
function UGen:squared() return UnaryOpUGen.newop('squared',self) end
function UGen:cubed() return UnaryOpUGen.newop('cubed',self) end
function UGen:exp() return UnaryOpUGen.newop('exp',self) end
function UGen:log() return UnaryOpUGen.newop('log',self) end
function UGen:abs() return UnaryOpUGen.newop('abs',self) end
function UGen:sign() return UnaryOpUGen.newop('sign',self) end
function UGen:cos() return UnaryOpUGen.newop('cos',self) end
function UGen:tan() return UnaryOpUGen.newop('tan',self) end
--]]
operators={["neg"]=0,["reciprocal"]=16,["bitNot"]=4,["abs"]=5,["asFloat"]=6,["ceil"]=8,["floor"]=9,["frac"]=10,["sign"]=11,["squared"]=12,["cubed"]=13,["sqrt"]=14,["exp"]=15,["midicps"]=17,["cpsmidi"]=18,["midiratio"]=19,["ratiomidi"]=20,["ampdb"]=22,["dbamp"]=21,["octcps"]=23,["cpsoct"]=24,["log"]=25,["log2"]=26,["log10"]=27,["sin"]=28,["cos"]=29,["tan"]=30,["asin"]=31,["acos"]=32,["atan"]=33,["sinh"]=34,["cosh"]=35,["tanh"]=36,["rand"]=37,["rand2"]=38,["linrand"]=39,["bilinrand"]=40,["sum3rand"]=41,["distort"]=42,["softclip"]=43,["coin"]=44,["rectWindow"]=48,["hanWindow"]=49,["welWindow"]=50,["triWindow"]=51,["scurve"]=53,["ramp"]=52,["+"]=0,["-"]=1,["*"]=2,["/"]=4,["div"]=3,["mod"]=5,["pow"]=25,["min"]=12,["max"]=13,["<"]=8,["<="]=10,[">"]=9,[">="]=11,["lcm"]=17,["gcd"]=18,["round"]=19,["roundUp"]=20,["trunc"]=21,["atan2"]=22,["hypot"]=23,["hypotApx"]=24,["leftShift"]=26,["rightShift"]=27,["unsignedRightShift"]=28,["ring1"]=30,["ring2"]=31,["ring3"]=32,["ring4"]=33,["difsqr"]=34,["sumsqr"]=35,["sqrsum"]=36,["sqrdif"]=37,["absdif"]=38,["thresh"]=39,["amclip"]=40,["scaleneg"]=41,["clip2"]=42,["fold2"]=44,["wrap2"]=45,["excess"]=43,["rrand"]=47,["exprand"]=48,["not"]=1}

binops = {'+','-','*','/','div','%','**','min','max','<','<=','>','>=','&','|','lcm','gcd','pow',
'round','trunc','atan2','hypot','hypotApx','>>','+>>','fill','ring1','ring2','ring3',
'ring4','difsqr','sumsqr','sqrdif','absdif','amclip','scaleneg','clip2','excess',
'<!','rrand','exprand','rotate','dist','bitAnd','bitOr','bitXor','bitHammingDistance','@','mod'}

unaryopst = {}
unaryops = {}
for k,v in pairs(operators) do
	unaryopst[k] = true
end
for k,v in ipairs(binops) do
	unaryopst[v] = nil
end
for k,v in pairs(unaryopst) do
	unaryops[#unaryops + 1] = k
end
--prtable(unaryops)
---[[
for i,v in ipairs(unaryops) do
	UGen[v] = function(self) return UnaryOpUGen.newop(v,self) end
end
for i,v in ipairs(binops) do
	UGen[v] = function(self,b) return BinaryOpUGen.newop(v,self,b) end
end
--]]
------------------------------------------
function UGen:clip(lo, hi)
	lo = lo or 0.0; hi = hi or 1.0
	if (self.calcrate == 2) then
		return Clip.ar(self, lo, hi)
	else
		--if(rate == \demand) {
		--	max(lo, min(hi, this))
		--} {
			Clip.kr(self, lo, hi)
		--}
	end
end
UGen.signalRange = "bipolar"
function UGen:range(lo,hi)
	lo = lo or 0; hi = hi or 1
	local mul , add
	if self.signalRange == "bipolar" then
			mul = (hi - lo) * 0.5;
			add = mul + lo;
	else
			mul = (hi - lo) ;
			add = lo;
	end
 	return MulAdd:newmuladd(self, mul, add);
end

function UGen:prune(min, max, type)
	if type=="minmax" then
		return self:clip(min, max)
	elseif type=="min" then 
		return self:max(min)
	elseif type=="max" then 
		return self:min(max)
	end
	return self
end
function UGen:linlin(inMin, inMax, outMin, outMax, clip)
	if self.calcrate==1 then
		return LinLin.kr(self:prune(inMin, inMax, clip),inMin, inMax, outMin, outMax)
	end
	return LinLin.ar(self:prune(inMin, inMax, clip),inMin, inMax, outMin, outMax)
end
function UGen:linexp(inMin, inMax, outMin, outMax, clip)
	if self.calcrate==1 then
		return LinExp.kr(self:prune(inMin, inMax, clip),inMin, inMax, outMin, outMax)
	end
	return LinExp.ar(self:prune(inMin, inMax, clip),inMin, inMax, outMin, outMax)
end
function UGen:varlag(time, curvature, warp, start)
	time = time or 0.1;curvature = curvature or 0; warp = warp or 5
	return VarLag:MultiNew{self.calcrate,self, time, curvature, warp, start}
end
--for Mix and MultiNew():madd and table with * or +
UGenArr={name="UGenArr",isUGenArr=true}
function UGenArr:new(o)
	o = o or {}
	setmetatable(o, UGenArr)
	--self.__index = self
	return o
end
UGenArr.__index = function(t,key)
	if UGenArr[key] then return UGenArr[key] end
	if _TAmt[key] then return _TAmt[key] end
end
function UGenArr:madd(mul,add)
	-- for i,v in ipairs(self) do
		-- self[i]=v:madd(mul,add)
	-- end
	if add==0 then
		if mul==1 then
			return self
		else
			return self * mul
		end
	else
		if mul==1 then
			return self + add
		else
			return self * mul + add
		end
	end
	-- self=self*mul + add
	-- return self
end
function UGenArr:dumpInputs(tab,ugens)
	tab=tab or ""
	print(tab.."Error: UGenArr slots: ",#self,"\n")
	for i,v in ipairs(self) do
		v:dumpInputs(tab.."\t",ugens)
	end
end
function UGenArr:DoBinaryOp(op,b)
	--local res=UGenArr:new()
--	for i,v in ipairs(self) do
--		res[i]=op(v,b)
--	end
--	return res
	local res=UGenArr:new()
	local maxlen=math.max(len(self),len(b))
	for i=1,maxlen do
		res[i]=op(WrapAtUG(self,i),WrapAtUG(b,i))
	end
	return res
end
function UGenArr:DoUnaryOp(op)
	local res=UGenArr:new()
	for i,v in ipairs(self) do
		res[i]=op(v)
	end
	return res

--	local res=UGenArr:new()
--	local maxlen=len(self)
--	print("maxlen",maxlen)
--	for i=1,maxlen do
--		res[i]=op(AtUG(self,i))
--	end
--	return res
end
-- alarga la ugenarr
function UGenArr:dup(n)
	--print("UGenArr:dup")
	n = n or 2
	local res = {}
	for i=1,n do
		for j,v in ipairs(self) do
			res[#res +1]=v
		end
	end
	return UGenArr:new(res)
end
UGenArr.__div=function (a,b)
	local res=UGenArr:new()
	local maxlen=math.max(len(a),len(b))
	for i=1,maxlen do
		res[i]=WrapAtUG(a,i)/WrapAtUG(b,i)
	end
	return res
end
UGenArr.__mul=function (a,b)
	local res=UGenArr:new()
	local maxlen=math.max(len(a),len(b))
	for i=1,maxlen do
		res[i]=WrapAtUG(a,i)*WrapAtUG(b,i)
	end
	return res
end
UGenArr.__unm=function (a)
	local res=UGenArr:new()
	for i=1,len(a) do
		res[i]=-WrapAtUG(a,i)
	end
	return res
end
UGenArr.__add=function (a,b)
	local res=UGenArr:new()
	local maxlen=math.max(len(a),len(b))
	for i=1,maxlen do
		res[i]=WrapAtUG(a,i)+WrapAtUG(b,i)
	end
	return res
end
UGenArr.__sub=function (a,b)
	local res=UGenArr:new()
	local maxlen=math.max(len(a),len(b))
	for i=1,maxlen do
		res[i]=WrapAtUG(a,i)-WrapAtUG(b,i)
	end
	return res
end
--[[
function UGenArr:ampdb() return self:DoUnaryOp(UGen.ampdb) end
function UGenArr:cubed() return self:DoUnaryOp(UGen.cubed) end
function UGenArr:clip2(b) return self:DoBinaryOp(UGen.clip2,b) end
function UGenArr:max(b) return self:DoBinaryOp(UGen.max,b) end
function UGenArr:min(b) return self:DoBinaryOp(UGen.min,b) end
function UGenArr:distort() return self:DoUnaryOp(UGen.distort) end
function UGenArr:cos() return self:DoUnaryOp(UGen.cos) end
--]]
---[[
for i,v in ipairs(unaryops) do
	UGenArr[v] = function(self) return self:DoUnaryOp(UGen[v]) end
end
for i,v in ipairs(binops) do
	UGenArr[v] = function(self,b) return self:DoBinaryOp(UGen[v],b) end
end
--]]
----------------------------------------------
MultiOutUGen=UGen:new{name="MultiOutUGen"}
function MultiOutUGen:init(numChannels,...)
	self.inputs={...}
	return self:initOutputs(numChannels)
end
function MultiOutUGen:initOutputs(size,rate)
	--print("size es:",size)

	self.channels=UGenArr:new()
	for i=1,size do
		self.channels[#self.channels +1]=OutputProxy.create(self,i)
	end
	--if size == 1 then self.channels = self.channels[1] end
	return self.channels
end
Out=UGen:new({name="Out",isOutUGen=true})
function Out:donew(rate,...)
	--prtable(self)
	--get last in ...
	--print(select('#',...))
	--prtable{...}
	local channels=select(select('#',...),...)
	--get everything but last in ... which is channels(Must take care about nils)
	local args={...}
	args[#args]=nil
	--append channels to arg
	if channels.isUGen then
		args[#args+1]=channels
	else
		for i,v in ipairs(channels) do args[#args+1]=v end
	end
	--prtable("chanels",channels)
	--prtable("args",args)
	--return self:new1(rate,unpack(args))
	return self:MultiNew{rate,unpack(args)}
end
function Out.ar(bus,channels)
	bus=bus or 0
	return Out:donew(2,bus,channels)
end
function Out.kr(bus,channels)
	bus=bus or 0
	return Out:donew(1,bus,channels)
end
function Out:init(...)
	self.inputs={...}
	_BUILDSYNTHDEF.outputugens=_BUILDSYNTHDEF.outputugens or {}
	_BUILDSYNTHDEF.outputugens[#_BUILDSYNTHDEF.outputugens+1]=self
	return 0 --,self
end


require "sc.declareugens4"


---------------------------
--[[
------------------------------------------------------
--for allowing comparisions in lua
--does not work metametod returns always boolean
ConstantUGen = UGen:new{name="ConstantUGen"}
ConstantUGen.calcrate = 0
function CUg(val) 
	assert(val,"ConstantUGen with nil value");
	assert(type(val)=="number","Only numeric values for ConstantUGens");
	return ConstantUGen:new{val=val} 
end
--]]
---------------------------------------
--function Rand.ir(lo,hi)
--	lo = lo or 0; hi = hi or 1
--	return Rand:MultiNew{0,lo,hi}
--end
---------sum4
Sum4 = UGen:new{name="Sum4"}
function Sum4.create(in0, in1, in2, in3)
	return Sum4:MultiNew{0, in0, in1, in2, in3}
end
function Sum4:new1(dummyRate, in0, in1, in2, in3)
	assert(in0 and in1 and in2 and in3,"Sum4 with nil arg")
		--prtable("in0",in0)
		--if (in0 == 0.0) { ^Sum3.new1(nil, in1, in2, in3) };
		--if (in1 == 0.0) { ^Sum3.new1(nil, in0, in2, in3) };
		--if (in2 == 0.0) { ^Sum3.new1(nil, in0, in1, in3) };
		--if (in3 == 0.0) { ^Sum3.new1(nil, in0, in1, in2) };
		local argArray = TA{in0, in1, in2, in3}
		local sortedArgs = argArray:sort(function(a, b) return a.calcrate > b.calcrate end)
		local rate = sortedArgs[1].calcrate;
		return UGen.new1(self,rate, unpack(sortedArgs))
end
Sum3 = UGen:new{name="Sum3"}
function Sum3.create(in0, in1, in2)
	return Sum3:MultiNew{0, in0, in1, in2}
end
function Sum3:new1(dummyRate, in0, in1, in2)
	--print("calling sum3 new1",in0, in1, in2)
	assert(in0 and in1 and in2,"Sum3 with nil arg")
		--if (in0 == 0.0) { ^Sum3.new1(nil, in1, in2, in3) };
		--if (in1 == 0.0) { ^Sum3.new1(nil, in0, in2, in3) };
		--if (in2 == 0.0) { ^Sum3.new1(nil, in0, in1, in3) };
		--if (in3 == 0.0) { ^Sum3.new1(nil, in0, in1, in2) };
		local argArray = TA{in0, in1, in2}
		local sortedArgs = argArray:sort(function(a, b) return a.calcrate > b.calcrate end)
		local rate = sortedArgs[1].calcrate;
		return UGen.new1(self,rate, unpack(sortedArgs))
end
--------------------------------------------------
OutputProxy=UGen:new{name="OutputProxy"}
function OutputProxy.create(source,index)
	return OutputProxy:new{source=source,index=index,calcrate=source.calcrate}
end

---------Control
_BUILDSYNTHDEF={}
Control=MultiOutUGen:new({name="Control"})
function Control.kr(...)
	return Control:MultiNew{1,...}
end
function Control.names(names)
	--print("Control.names")
	--prtable(names)
	synthdef=_BUILDSYNTHDEF
	synthdef.parameters=synthdef.parameters or {}
	synthdef.paramnames=synthdef.paramnames or {}
	local offset= #synthdef.parameters
	for i,v in ipairs(names) do
		synthdef.paramnames[#synthdef.paramnames +1]={name=v,index=nil}
	end
	return Control
end
function Control:init(...)
--println("control init args:")
--prtable{...}
	synthdef=_BUILDSYNTHDEF
	self.inputs={}
	self.specialIndex=#synthdef.parameters
	--search first parametername not indexed
	local lastindexedname=0
	for i,v in ipairs(synthdef.paramnames) do
		if not v.index then
			lastindexedname=i
			break
		end
	end
	assert(lastindexedname>0,"Init Control without names")
	--------------------------------
	local numUnitaryOutputs=0
	for i,v in ipairs({...}) do
		synthdef.paramnames[lastindexedname].index=#synthdef.parameters+1
		lastindexedname=lastindexedname+1
		if type(v)~="table" then
			synthdef.parameters[#synthdef.parameters +1]=v
			numUnitaryOutputs=numUnitaryOutputs+1
			assert(type(v)=="number")
		else
			--println("xxxxxxxxxxxxxxxxxxxxxparameter es tabla:")
			--prtable(v)
			for i2,v2 in ipairs(v) do
				numUnitaryOutputs=numUnitaryOutputs+1
				synthdef.parameters[#synthdef.parameters +1]=v2
				assert(type(v2)=="number")
			end
		end
	end
	return self:initOutputs(numUnitaryOutputs)
end
TrigControl=Control:new({name="TrigControl"})
function TrigControl.kr(...)
	return TrigControl:MultiNew{1,...}
end
function TrigControl.names(names)
	synthdef=_BUILDSYNTHDEF
	synthdef.parameters=synthdef.parameters or {}
	synthdef.paramnames=synthdef.paramnames or {}
	local offset= #synthdef.parameters
	for i,v in ipairs(names) do
		synthdef.paramnames[#synthdef.paramnames +1]={name=v,index=nil}
	end
	return TrigControl
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
LocalIn=MultiOutUGen:new{name='LocalIn'}
function LocalIn.kr(numChannels)
	numChannels=numChannels or 1;
	return LocalIn:MultiNew{1,numChannels}
end
function LocalIn.ar(numChannels)
	numChannels=numChannels or 1;
	return LocalIn:MultiNew{2,numChannels}
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
----------------------------------------------------
--in = 0.0, trig = 1.0, maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0,coef = 0.5, mul = 1.0, add = 0.0;
Pluck=UGen:new{name="Pluck"}
function Pluck.ar(inp,trig,maxdelaytime,delaytime,decaytime,coef,mul,add)
	inp=inp or 0;trig=trig or 1;maxdelaytime=maxdelaytime or 0.2;delaytime=delaytime or 0.2
	decaytime=decaytime or 1;coef=coef or 0.5;mul=mul or 1;add=add or 0
	--local this=Pluck:new{calcrate=2}
	return Pluck:MultiNew({2,inp,trig,maxdelaytime,delaytime,decaytime,coef}):madd(mul,add)
end
Karplus=UGen:new{name="Karplus"}
function Karplus.ar(inp,trig,maxdelaytime,delaytime,decaytime,coef,coefsA,coefsB,mul,add)
	inp=inp or 0;trig=trig or 1;maxdelaytime=maxdelaytime or 0.2;delaytime=delaytime or 0.2
	decaytime=decaytime or 1;coef=coef or 0.5;coefsA=coefsA or {-0.6};coefsB=coefsB or {1-0.6};mul=mul or 1;add=add or 0
	return Karplus:MultiNew(concatTables({2,inp,trig,maxdelaytime,delaytime,decaytime,coef},#coefsA,#coefsB,coefsA,coefsB)):madd(mul,add)
end
------------------
Lag=UGen:new{name="Lag"}
function Lag.ar(inp,lagTime,mul,add)
	inp = inp or 0.0; lagTime = lagTime or 0.1; mul = mul or 1.0; add = add or 0.0
	return Lag:MultiNew({2,inp,lagTime}):madd(mul,add)
end
function Lag.kr(inp,lagTime,mul,add)
	inp = inp or 0.0; lagTime = lagTime or 0.1; mul = mul or 1.0; add = add or 0.0
	return Lag:MultiNew({1,inp,lagTime}):madd(mul,add)
end
--------------------------------
SinOsc=UGen:new{name="SinOsc"}
function SinOsc.ar(freq,phase,mul,add)
	freq=freq or 440.0; phase=phase or 0.0; mul = mul or 1.0; add = add or 0.0
	return SinOsc:MultiNew({2,freq,phase}):madd(mul,add)
end
function SinOsc.kr(freq,phase,mul,add)
	freq=freq or 440.0; phase=phase or 0.0; mul = mul or 1.0; add = add or 0.0
	return SinOsc:MultiNew({1,freq,phase}):madd(mul,add)
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
------------------------------
--fundfreq = 440.0, formfreq = 1760.0, bwfreq = 880.0, mul = 1.0, add = 0.0
Formant=UGen:new{name="Formant"}
function Formant.ar(fundfreq,formfreq,bwfreq,mul,add)
	fundfreq=fundfreq or 440.0; formfreq = formfreq or 1760.0; bwfreq = bwfreq or 880.0; mul = mul or 1.0; add = add or 0.0
	return Formant:MultiNew({2,fundfreq,formfreq,bwfreq}):madd(mul,add)
end
---------------------------
EnvGen=UGen:new({name="EnvGen"})
--envelope, gate = 1.0, levelScale = 1.0, levelBias = 0.0, timeScale = 1.0, doneAction = 0
-- TODO Multiespansion in envelope
---[[
function EnvGen.ar(...)
	local envelope,gate, levelScale, levelBias, timeScale, doneAction 
	= assign(
	{"envelope", "gate", "levelScale", "levelBias", "timeScale", "doneAction"},
	{{},1,1,0,1,0},...)
	local arrEnv
	if envelope.isEnv then
		arrEnv = envelope:prAsArray()
	else
		arrEnv = envelope
	end
	return EnvGen:MultiNew{2,gate, levelScale, levelBias, timeScale, doneAction,unpack(arrEnv)}
end
function EnvGen.kr(...)
	local envelope,gate, levelScale, levelBias, timeScale, doneAction 
	= assign(
	{"envelope", "gate", "levelScale", "levelBias", "timeScale", "doneAction"},
	{{},1,1,0,1,0},...)
	local arrEnv
	if envelope.isEnv then
		arrEnv = envelope:prAsArray()
	else
		arrEnv = envelope
	end
	return EnvGen:MultiNew{1,gate, levelScale, levelBias, timeScale, doneAction,unpack(arrEnv)}
end
--]]
--[[
function EnvGen.ar(envelope,gate, levelScale, levelBias, timeScale, doneAction)
	gate =gate or 1.0; levelScale =levelScale or 1.0; levelBias =levelBias or 0.0; timeScale =timeScale or 1.0; doneAction =doneAction or 0
	local arrEnv
	if envelope.isEnv then
		arrEnv = envelope:prAsArray()
	else
		arrEnv = envelope
	end
	return EnvGen:MultiNew{2,gate, levelScale, levelBias, timeScale, doneAction,unpack(arrEnv)}
end
function EnvGen.kr(envelope,gate, levelScale, levelBias, timeScale, doneAction)
	--debuglocals()
	gate =gate or 1.0; levelScale =levelScale or 1.0; levelBias =levelBias or 0.0; timeScale =timeScale or 1.0; doneAction =doneAction or 0
	local arrEnv
	if envelope.isEnv then
		arrEnv = envelope:prAsArray()
	else
		arrEnv = envelope
	end
	return EnvGen:MultiNew{1,gate, levelScale, levelBias, timeScale, doneAction,unpack(arrEnv)}
end
--]]
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
	return Mix(Ringz:MultiNew{2,input, freqscale*spec[1]+freqoffset,spec[3]*decayscale,spec[2]})
end
DynKlankS={}
function DynKlankS.ar(spec, input, freqscale, freqoffset,decayscale)
	freqscale =freqscale or 1.0; freqoffset =freqoffset or 0.0; decayscale = decayscale or 1.0
	return Ringz:MultiNew{2,input, freqscale*spec[1]+freqoffset,spec[3]*decayscale,spec[2]}
end
---[[
function GVerb.ar(in_a,roomsize,revtime,damping,inputbw,spread,drylevel,earlyreflevel,taillevel,maxroomsize)
	roomsize=roomsize or 10;revtime=revtime or 3;damping=damping or 0.5;inputbw=inputbw or 0.5;spread=spread or 15;drylevel=drylevel or 1;earlyreflevel=earlyreflevel or 0.7;taillevel=taillevel or 0.5;maxroomsize=maxroomsize or 300;
	return GVerb:MultiNew{2,2,in_a,roomsize,revtime,damping,inputbw,spread,drylevel,earlyreflevel,taillevel,maxroomsize}
end
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

--[[
function PV_BrickWall.kr(buffer, wipe)
	wipe = wipe or 0
	return PV_BrickWall:MultiNew{1,buffer,wipe}
end
function PV_BinShift.kr(buffer, stretch,shift)
	stretch = stretch or 1.0; shift = shift or 0.0
	return PV_BinShift:MultiNew{1,buffer,stretch,shift}
end
function PV_MagShift.kr(buffer, stretch,shift)
	stretch = stretch or 1.0; shift = shift or 0.0
	return PV_MagShift:MultiNew{1,buffer,stretch,shift}
end
function PV_BinScramble.kr(buffer, wipe,width,trig)
	wipe = wipe or 0.0; width = width or 0.2; trig = trig or 0.0;
	return PV_BinScramble:MultiNew{1,buffer, wipe,width,trig}
end
function PV_MagMul.kr(a,b)
	return PV_MagMul:MultiNew{1,a, b}
end
PV_MagSmear=UGen:new{name='PV_MagSmear'}
function PV_MagSmear.kr(buffer,bins)
	bins = bins or 0
	return PV_MagSmear:MultiNew{1,buffer,bins}
end

--]]
-----------------------
--[[
LPF=UGen:new({name="LPF"})
function LPF.ar(inp, freq , mul , add ) 
	inp =inp or 0.0; freq =freq or 440.0; mul =mul or 1.0; add = add or 0.0;
	return LPF:MultiNew({2,inp, freq}):madd(mul,add) 
end
HPF=UGen:new{name="HPF"}
function HPF.ar(inp, freq , mul , add ) 
	inp =inp or 0.0; freq =freq or 440.0; mul =mul or 1.0; add = add or 0.0;
	return HPF:MultiNew({2,inp, freq}):madd(mul,add) 
end
--]]
----------------------------------------------------
--[[
WhiteNoise=UGen:new({name="WhiteNoise"})
function WhiteNoise.ar(mul,add)
	mul=mul or 1;add=add or 0
	return WhiteNoise:MultiNew({2}):madd(mul,add)
end
BrownNoise=WhiteNoise:new{name="BrownNoise"}
--]]
-------------------------------------------------------


LocalOut=Out:new{name='LocalOut'}
function LocalOut.ar(channels)
	return LocalOut:donew(2,channels)
end
function LocalOut.kr(channels)
	return LocalOut:donew(1,channels)
end
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
-- function SendReply:new1(rate,trig,cmdName,values, replyID)
	-- local ascii = {cmdName:byte(1,-1)},
		-- ^super.new1(*[rate, trig, replyID, ascii.size].addAll(ascii).addAll(values));
-- end
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
--------------------------------------------------------------
MulAdd=UGen:new{name="MulAdd"}
function MulAdd:newmuladd(inp,mul,add)
	local ratemul= (type(mul)=="number") and 0 or mul.calcrate
	local rateadd= (type(add)=="number") and 0 or add.calcrate
	--assert(inp.calcrate>=ratemul and inp.calcrate>=rateadd)
	return MulAdd:MultiNew({inp.calcrate,inp,mul,add})
end
BinaryOpUGen=UGen:new({name="BinaryOpUGen"})
function BinaryOpUGen.newop(selector,a,b)
	return BinaryOpUGen:MultiNew({2,selector,a,b})
end
function BinaryOpUGen:init(selector,a,b)
	--debuglocals()
	self.selector=selector
	self.specialIndex=operators[selector]
	assert(operators[selector],"This selector does not exist")
	self.inputs={a,b}
	local ratea= (type(a)=="number") and 0 or a.calcrate
	local rateb= (type(b)=="number") and 0 or b.calcrate
	self.calcrate=math.max(ratea,rateb)
	return self
end
UnaryOpUGen=UGen:new({name="UnaryOpUGen"})
function UnaryOpUGen.newop(selector,a)
	return UnaryOpUGen:MultiNew({2,selector,a})
end
function UnaryOpUGen:init(selector,a)
	self.selector=selector
	self.specialIndex=operators[selector]
	assert(operators[selector],"This selector does not exist")
	self.inputs={a}
	self.calcrate= type(a)=="number" and 0 or a.calcrate
	return self
end
--muy limitado: espera un array de ugens o un array de arrays de ugens
-- function MixBAK(t)
	-- if not t.isUGenArr then  return t end
	-- assert(#t>1)
	-- local ret=t[1]
	-- for i=2,#t do
		-- if isSimpleTable(ret) then
			-- for j=1,#ret do
				-- ret[j]=ret[j]+t[i][j]
			-- end
		-- else
			-- ret=ret + t[i]
		-- end
	-- end
	-- return ret
-- end
--[[
function Mix(t)
	if not t.isUGenArr and not isSimpleTable(t) then  return t end
	print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxMIX")
	--prtable(t)
	if(#t<=1) then print"mixing less than two chanels" end
	local ret=t[1]
	for i=2,#t do
		ret=ret + t[i]
	end
	return ret
end
--]]
---[[
function Mix(t)
	--if t.asSimpleTable then t = t:asSimpleTable() end
	--if not t.isUGenArr and not isSimpleTable(t) then  return t end
	
	if t.isUGen then return t end
	if isSimpleTable(t) then t = UGenArr:new(t) end
	print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxMIX")
	--prtable(t)
	if(#t<=1) then print"mixing less than two chanels" end
	local reducedArray = t:clump(4)
	local mixedarray = reducedArray:Do(function(v) 
			if #v == 4 then
				return Sum4(unpack(v))
			elseif #v == 3 then
				return Sum3(unpack(v))
			else
				return v:sum()
			end
		end)
	if #mixedarray == 3 then
		return Sum3(unpack(mixedarray:asSimpleTable()))
	elseif #mixedarray < 3 then
		return mixedarray:sum()
	else
		return Mix(mixedarray:asSimpleTable())
	end
end
--]]
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
--[[
function ExpRand.ir(lo,hi)
	lo = lo or 0.01; hi = hi or 1
	return ExpRand:MultiNew{0,lo,hi}
end
function IRand.ir(lo,hi)
	lo = lo or 0; hi = hi or 127
	return IRand:MultiNew{0,lo,hi}
end
function Rand.ir(lo,hi)
	lo = lo or 0; hi = hi or 1
	return Rand:MultiNew{0,lo,hi}
end
--]]
function PackFFT.kr(chain, bufsize, magsphases, frombin, tobin, zeroothers)
	frombin = frombin or 0;tobin = tobin or #magsphases/2;zeroothers = zeroothers or 0
	--^this.multiNewList(['control', chain, bufsize, frombin, tobin, zeroothers, magsphases.size] ++ magsphases.asArray)
	return PackFFT:MultiNew(concatTables({1,chain,bufsize, frombin, tobin, zeroothers,#magsphases},magsphases))
end
--[[
function FFT.kr(buffer, inp, hop , wintype, active , winsize)
	inp = inp or 0.0 ; hop = hop or 0.5; wintype = wintype or 0 ; active = active or 1; winsize= winsize or 0
	return FFT:MultiNew{1, buffer, inp, hop, wintype, active, winsize}
end
function FFTTrigger.kr(buffer, hop, polar )
	hop = hop or 0.5 ; polar = polar or 0
	return FFTTrigger:MultiNew{1,buffer,hop,polar}
end
--]]
LFPulse.signalRange="unipolar"
MouseX.signalRange="unipolar"
MouseY.signalRange="unipolar"
MouseButton.signalRange="unipolar"
----------------------------------------------
SYNTHDef={isBuild=false}
function SYNTHDef:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	local m=getmetatable(self)
    if m then
        for k,v in pairs(m) do
            if not rawget(self,k) and k:match("^__") then
                self[k] = m[k]
            end
        end
    end
	return o
end
function SYNTHDef:dumpInputs()
	print("Dumping SYNTHDef:",self.name,"xxxxxxxxxxxxxxxxxxxxxxxx")
	self:findTerminals()
	self.theUgens={}
	for i,v in ipairs(self.outputugens) do
		--prtable("outputugen",v)
		v:dumpInputs("",self.theUgens)
	end
	print("\nnumero de ugens:"..tablelength(self.theUgens))
	print("Dumping SYNTHDef:",self.name," ENDED xxxxxxxxxxxxxxxxxxxxxxxx")
end
function SYNTHDef:findTerminals()
	local terminals={}
	--copy all
	for i,v in ipairs(self.Allugens) do
		--print(i," ",v.name)
		terminals[v]=true
	end
	-- delete those which are inputs of something
	for i,ug in ipairs(self.Allugens) do
		local inputs={}
		local actualugen=ug
		if ug.name=="OutputProxy" then
			inputs=ug.source.inputs or {}
			actualugen=ug.source
		else
			inputs=ug.inputs or {}
		end
		--print(i," ",ug.name," #inputs ",ug.inputs)
		for i2,v in ipairs(inputs) do
			local actualv=v
			--maybe number
			while type(actualv)=="table" and actualv.name=="OutputProxy" do
				actualv=actualv.source
			end
			--print("delete terminal ",actualv.name)
			terminals[actualv]=nil
		end
	end
	--print("terminals")
	self.outputugens={}
	for k,v in pairs(terminals) do
		self.outputugens[#self.outputugens+1]=k
		--print(k.name)
	end
end
function SYNTHDef:build()
	self.ugens= {}
	self.indugens={}
	self.constants= {}
	--find terminal ugens
	self:findTerminals()
	--------------------
	for i,v in ipairs(self.outputugens) do
		v:doInputs(self)
	end
	--[[
	---------sort breath first from input----------
	--seems not necessary
	--find input ugens
	local S={}
	local Sadded={}
	--local Skey={}
	local L={}
	local sorted={}
	for i,v in ipairs(self.indugens) do
		if #v.inputs==0 then
			--Skey[v]=#S+1
			S[#S+1]=v
			Sadded[v]=true
			
		end
	end
	while next(S) do
		local skey,ug=next(S)
		print("next S ",skey,ug.name)
		S[skey]=nil
		if not sorted[ug] then
			sorted[ug]=#L+1
			L[#L+1]=ug
		end
		for i,v in ipairs(ug.sucesors) do
			--print("sucesor ",i,v.name)
			local allinputs=true
			for i2,v2 in ipairs(v.inputs_toposort) do
				if type(v2)~="number" then
					--print("inputs toposort ",i2,v2.name)
					if not sorted[v2] then
						allinputs=false
					end
				end
			end
			if allinputs and not Sadded[v] then
				print("add to S ",v.name)
				--Skey[v]=#S+1
				S[#S+1]=v
				Sadded[v]=true
				if not sorted[v] then
					sorted[v]=#L+1
					L[#L+1]=v
				end
			end
		end
	end
	self.ugens=sorted
	self.indugens=L
	--]]
	self.isBuild=true
	return self
end
function SYNTHDef:writeDefFile()
	--assert(self.isBuild,"Not already build!!")
	--if not self.isBuild then self:build() end
	if not self.compiledStr then self:makeDefStr() end
	local fout = assert(io.open(SynthDefs_path..self.name..".scsyndef", "wb"),"cannot open "..SynthDefs_path..self.name..".scsyndef")
	fout:write(self.compiledStr)
	fout:close()
	return self
end
function SYNTHDef:makeDefStr()
	--assert(self.isBuild,"Not already build!!")
	if not self.isBuild then self:build() end
	local tout = {}
	table.insert(tout,"SCgf")
	table.insert(tout,int2str(1,4)) --version
	table.insert(tout,int2str(1,2)) --numdefs
	table.insert(tout,pstring(self.name))
	
	local constants=swapkeyvalue(self.constants)
	table.insert(tout,int2str(#constants,2)) --numconstants
	for i,v in ipairs(constants) do
		table.insert(tout,float2str(v)) 
	end
	table.insert(tout,int2str(#self.parameters,2)) --paramaeters
	for i,v in ipairs(self.parameters) do
		table.insert(tout,float2str(v)) 
	end
	table.insert(tout,int2str(#self.paramnames,2)) --paramnames
	for i,v in ipairs(self.paramnames) do
		table.insert(tout,pstring(v.name))
		table.insert(tout,int2str(v.index-1,2))
	end
	
	local ugens=self.indugens
	--fout:write(int2str(0,2))
	--print("xxxxxxxxxxxxxxxxxxxxxxxxxescribo numugens",#ugens)
	--prtable(ugens)
	table.insert(tout,int2str(#ugens,2)) 
	for i,v in ipairs(ugens) do
		table.insert(tout,pstring(v.name))
		table.insert(tout,int2str(v.calcrate,1))
		table.insert(tout,int2str(#v.inputs,2))
		if #v.channels > 0 then --numoutputs
			table.insert(tout,int2str(#v.channels,2))
		else
			if v.isOutUGen then
				table.insert(tout,int2str(0,2))
			else
				table.insert(tout,int2str(1,2))
			end
		end
		table.insert(tout,int2str(v.specialIndex,2))
		--inputspec
		for i2,v2 in ipairs(v.inputs) do
			if type(v2)=="number" then
				table.insert(tout,int2str(-1,2))
				table.insert(tout,int2str(self.constants[v2]-1,2))
			else
				if v2.name=="OutputProxy" then
					table.insert(tout,int2str(self.ugens[v2.source]-1,2))
					table.insert(tout,int2str(v2.index-1,2))
				else
					table.insert(tout,int2str(self.ugens[v2]-1,2))
					table.insert(tout,int2str(0,2))
				end
			end
		end
		--outputspec
		if #v.channels > 0 then --numoutputs
			for i2,v2 in ipairs(v.channels) do
				table.insert(tout,int2str(v2.source.calcrate,1))
			end
		else
			if v.isOutUGen then
				--
			else
				table.insert(tout,int2str(v.calcrate,1))
			end
		end
	end
	table.insert(tout,int2str(0,2))
	self.compiledStr=table.concat(tout)
	return self
end
function SYNTHDef:send(block)
	if not self.compiledStr then self:makeDefStr() end
	if block==nil then block=true end
	if block then
---[[
		udpB:send(toOSC{"/d_recv",{{"blob",self.compiledStr}}})
		local dgram = assert(udpB:receive(),"Not receiving from SCSYNTH\n")
		msg=fromOSC(dgram)
		print(prOSC(msg))
		assert(msg[2][1]=="/d_recv")
		assert(msg[1]=="/done")
--]]
--[[
		udpB:send(toOSC{"/d_recv",{{"blob",self.compiledStr}}})
		while true do
			local dgram = assert(udpB:receive(),"Not receiving from SCSYNTH\n")
			if dgram then
				msg=fromOSC(dgram)
				print(prOSC(msg))
				break
			end
		end
--]]
	else
		udp:send(toOSC{"/d_recv",{{"blob",self.compiledStr}}})
    end
	return self
end
function SYNTHDef:store()
	self:writeDefFile()
	self:send()
	return self
end
function SYNTHDef:play()
	self:send()
	udp:send(toOSC{"/s_new", {self.name, GetNode(), 0, 0}})
	return self
end
function SynthDef(name,parametersDef,graphfunc)
	--print("SynthDef: ",name)
	--prtable(parametersDef)
	_BUILDSYNTHDEF=SYNTHDef:new()
	_BUILDSYNTHDEF.name=name
	local parameters={}
	local paramnames={}
	local t_parameters={}
	local t_paramnames={}

	
	for k,v in pairs(parametersDef) do
		if type(k)=="number" then
			error("must suply default value for "..tostring(v))
		elseif k:sub(1,2)=="t_" then
			t_paramnames[#t_paramnames+1]=k
			t_parameters[#t_parameters+1]=v
		else
			paramnames[#paramnames+1]=k
			parameters[#parameters+1]=v
		end
	end
 -- println("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
	-- prtable(paramnames)
	-- prtable(parameters)
	-- prtable(t_paramnames)
	-- prtable(t_parameters)
	local controls,t_controls
	if(#t_paramnames>0) then
		t_controls=TrigControl.names(t_paramnames).kr(unpack(t_parameters))
	end
	if(#paramnames>0) then
		controls=Control.names(paramnames).kr(unpack(parameters))
	end
	
	
	--prtable(_BUILDSYNTHDEF)
	-- println("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxcontrols")
	-- prtable(controls)
	-- prtable(t_controls)
	local paramControl={}
	local ind=1
	for i,name in ipairs(t_paramnames) do
		if type(t_parameters[i])=="table" then
			local param={}
			for i2,v2 in ipairs(t_parameters[i]) do
				param[i2]=t_controls[ind]
				ind=ind+1
			end
			paramControl[name]=param
		else
			paramControl[name]=t_controls[ind]
			ind=ind+1
		end
	end
	ind=1
	for i,name in ipairs(paramnames) do
		if type(parameters[i])=="table" then
			local param=UGenArr:new()--{}
			for i2,v2 in ipairs(parameters[i]) do
				param[i2]=controls[ind]
				ind=ind+1
			end
			paramControl[name]=param
		else
			paramControl[name]=controls[ind]
			ind=ind+1
		end
	end
	--prtable(paramControl)
	--ind=1
	-- for k,v in pairs(parametersDef) do
		-- if type(v)=="table" then
			-- local param={}
			-- for i2,v2 in ipairs(v) do
				-- param[i2]=controls[ind]
				-- ind=ind+1
			-- end
			-- paramControl[k]=param
		-- else
			-- paramControl[k]=controls[ind]
			-- ind=ind+1
		-- end
	-- end
	
	-- println("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxparamControl")
	-- prtable(paramControl)
	local newgt = paramControl -- create new environment
	setmetatable(newgt, {__index = _G})
	setfenv(graphfunc, newgt) -- set it
	--print("amp es "..amp)
	graphfunc()
	local thissynthdef=_BUILDSYNTHDEF
	_BUILDSYNTHDEF={} --erase global for new builds
	return thissynthdef
end
function UGen:dumpInputs(tab,ugens)
	ugens=ugens or {}
	tab=tab or ""
	local ug=self
	local inputs=0
	local name=""
	local actualugen=ug
	--local indexout=1
	
	if ug.name=="OutputProxy" then
		inputs=ug.source.inputs
		name="OutputProxy-"..ug.source.name.."-"..ug.index
		actualugen=ug.source
		if actualugen.name=="Control" then name=name.." special: "..actualugen.specialIndex end
	elseif ug.name=="BinaryOpUGen" or ug.name=="UnaryOpUGen" then
		inputs=ug.inputs
		name=ug.name..ug.selector
	else
		inputs=ug.inputs
		name=ug.name
	end
	--print("AAAA ES:"..type(actualugen).."\n")
	if not ugens[actualugen] then ugens[actualugen]=true end 
	--print(tab..name)
	--print(" rate:"..ug.calcrate)
	--print(" #inputs:"..#inputs.."\n")
	print(tab..name.." rate:"..ug.calcrate.." #inputs:"..#inputs)
	for i,v in ipairs(inputs) do
		if type(v)=="number" then
			print(tab.."\t".."constant:",v)
		elseif v.isUGen then
			v:dumpInputs(tab.."\t",ugens)
		elseif v.isUGenArr then
			v:dumpInputs(tab.."\t",ugens)
		else
			print("Error compilacion: ")
			--io.write("name: ",v.name,"\n")
			print("name: ",tostring(v),"\n")
		end
	end
end
function UGen:doInputs(syndef,sucesor)
	--print("doInputs from ",self.name)
	syndef.indugens=syndef.indugens or {}
	syndef.ugens= syndef.ugens or {}
	syndef.constants= syndef.constants or {}
	local ug=self
	local inputs=0
	local actualugen=ug
	if ug.name=="OutputProxy" then
		inputs=ug.source.inputs
		actualugen=ug.source
	else
		inputs=ug.inputs
	end
	actualugen.sucesors = actualugen.sucesors or {}
	actualugen.sucesors[#actualugen.sucesors+1]=sucesor
	--if not syndef.ugens[actualugen] then syndef.ugens[actualugen]=tablelength(syndef.ugens)+1 end
	if not actualugen.visited then actualugen.visited=true else return end 	
	actualugen.inputs_toposort=actualugen.inputs_toposort or {}
	for i,v in ipairs(inputs) do
		if type(v)=="number" then
			if not syndef.constants[v] then syndef.constants[v]=tablelength(syndef.constants)+1 end 
			actualugen.inputs_toposort[#actualugen.inputs_toposort+1]=v
		else
			--[[
			--does not work metametod returns always boolean
			if v.name=="ConstantUGen" then
				if not syndef.constants[v.val] then syndef.constants[v.val]=tablelength(syndef.constants)+1 end 
				actualugen.inputs_toposort[#actualugen.inputs_toposort+1]=v.val
			else
			--]]
			if v.name=="OutputProxy" then
				actualugen.inputs_toposort[#actualugen.inputs_toposort+1]=v.source
			else
				actualugen.inputs_toposort[#actualugen.inputs_toposort+1]=v
			end
			if v.doInputs == nil then
				print("dumping false ugen: this:",self.name)
				print("dumping false ugen:")
				prtable(v)
				error("not ugen")
			end
			v:doInputs(syndef,actualugen)
		end
	end
	syndef.ugens[actualugen]=#syndef.indugens+1
	syndef.indugens[#syndef.indugens+1]=actualugen
	
end


-- function rateNumber(t) {
		-- if rate == \audio, { ^2 });
		-- if rate == \control, { ^1 });
		-- if rate == \demand, { ^3 });
		-- ^0 // scalar
-- end
----------------------------------------------------
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
	local lossarrayfix = (type(lossarray)=="table" and lossarray.isRef) and lossarray or TA():Fill(#delaylengtharray + 1,lossarray)
	local allargs= TA(lossarrayfix)..TA(karray)..TA(delaylengtharray);
	--prtable("karray",delaylengtharray)
	return NTube:MultiNew{2,input,unpack(allargs)}:madd(mul,add)
end
----------------------
--[[
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
Adachi=UGen:new{name="Adachi"}
function Adachi.ar(flip,p0,radio,buffnum,yequil,mul,add)
	local flip = flip or 231;p0 = p0 or 5000;radio= radio or 0.005;mul=mul or 1;add=add or 0;yequil = yequil or 0;gate = gate or 1
	return Adachi:MultiNew{2,flip,p0,radio,buffnum,yequil,gate}:madd(mul,add)
end
AdachiAyers=UGen:new{name="AdachiAyers"}
function AdachiAyers.ar(flip,p0,radio,buffnum,buffnum2,buffnum3,yequil,gate,delay,mul,add)
	local flip = flip or 231;p0 = p0 or 5000;radio= radio or 0.005;mul=mul or 1;add=add or 0;yequil = yequil or 0;gate = gate or 1;delay = delay or 0
	return AdachiAyers:MultiNew{2,flip,p0,radio,buffnum,buffnum2,buffnum3,yequil,gate,delay}:madd(mul,add)
end
AdachiIIR=UGen:new{name="AdachiIIR"}
function AdachiIIR.ar(flip,p0,radio,buffnum1b,buffnum1a,buffnum2,buffnum3,yequil,gate,delay,mul,add)
	local flip = flip or 231;p0 = p0 or 5000;radio= radio or 0.005;mul=mul or 1;add=add or 0;yequil = yequil or 0;gate = gate or 1;delay = delay or 0
	return AdachiIIR:MultiNew{2,flip,p0,radio,buffnum1b,buffnum1a,buffnum2,buffnum3,yequil,gate,delay}:madd(mul,add)
end
ParamTest=UGen:new{name="ParamTest"}
function ParamTest.ar(P1,buf)
	return ParamTest:MultiNew{2,P1,buf}
end
function Tartini.kr(inp,threshold,n,k,overlap,smallCutoff)
	inp=inp or 0;threshold=threshold or 0.93;n=n or 2048;k=k or 0;overlap=overlap or 1024;smallCutoff=smallCutoff or 0.5;
	return Tartini:MultiNew{1,2,inp,threshold,n,k,overlap,smallCutoff}
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
Diwhite=UGen:new{name='Diwhite'}
function Diwhite.create(lo,hi,length)
	lo=lo or 0;hi=hi or 1;length=length or math.huge;
	return Diwhite:MultiNew{3,length,lo,hi}
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