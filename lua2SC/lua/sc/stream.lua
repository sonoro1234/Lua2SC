--- stream classes that respond to :nextval() and :reset()
--@module stream
require("sc.utils")
require("sc.utilsstream")
require("sc.combinatorics")

--- PriorityQ. Priority queue
-- @type PriorityQ
PriorityQ = {}
--- Creates a PriorityQ
-- @param o table of initial values
-- @return PriorityQ
function PriorityQ:new(o)
	o = o or {}
	o.queue = {}
	setmetatable(o, self)
	self.__index = self
	return o
end
--- put something in queue items get ordered by time and index after
-- @param time
-- @param item anything
-- @param index
function PriorityQ:put(time,item,index)
	self.queue[#self.queue + 1] = {time , item, index}
	table.sort(self.queue , function(a,b) 
								if a[1] == b[1] then
									return a[3] > b[3]
								else
									return a[1] > b[1] 
								end
							end)
end
--- pops the first item
-- @return  time
-- @return  item
-- @return  index
function PriorityQ:pop()
	local res = self.queue[#self.queue]
	self.queue[#self.queue] = nil
	return res[1],res[2],res[3]
end
--- gets first item time
function PriorityQ:topPrio()
	return self.queue[#self.queue][1]
end
--- Stream Class. Has metatable for mul add sub div
-- @type Stream
Stream = {reps=1,creps=0,recur=nil}
Stream.isStream = true
--- Creates a Stream
-- @param o provides initial values
-- @return Stream
function Stream:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	--copy metamethods from parent
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
--- Puts Stream in the initial position
function Stream:reset()
	self.pos=1
	self.creps=0
	self.recur=nil
	if self.repSt then
		--TODO: this is not a complete reset of the outer stream
		self.reps = self.repSt:nextval()
	end
end
--- Set the number of repetitions of stream
-- @param n number of repeats
-- @return Stream self
function Stream:rep(n)
	if type(n)=="table" then
		assert(n.isStream,"Received a not stream table for repetitions")
		self.repSt = n
	elseif type(n)=="number" then
		assert(n == math.floor(n),"Not integer number of repetitions")
		self.reps = n  
	else
		error("Not number or stream for repetitions")
	end 
	return self
end
--- Recursive function for streams inside streams
-- @return next value in stream
function Stream:nextval(e)
	while true do
		--local b
		if self.recur then  
			self.curval = self.recur:nextval(e)
		else
			self.curval = self:pnext(e)
		end
		
		if self.curval == nil then -- nulo
			if self.recur then
				self.recur = nil
			else
				return self.curval
			end
		elseif type(self.curval) ~="table" then --dato
			return self.curval
		else
			--if self.curval.nextval then   -- tabla stream
			if (self.curval.isStream == true) then
				assert(not(self.recur),"Should not be here")
				self.recur = self.curval
				--return b:nextval()
			else			-- tabla no stream
				return self.curval
			end
		end
	end
end

function Stream:pnext(e)
	error("Virtual Stream:pnext")
	return nil --virtual
end
Stream.__mul = function (a,b)
	return MUL(a,b)
end
Stream.__div = function (a,b)
	return DIV(a,b)
end
Stream.__add = function (a,b)
	return ADD(a,b)
end
Stream.__sub = function (a,b)
	return a +(-b)
end
Stream.__unm = function (a)
	return MUL(a,-1)
end

--- Derived from Stream. Custom function as stream provider
-- @type FuncStream
-- @usage FuncStream:new{}
FuncStream = Stream:new{verb=nil,argus=nil}
function FuncStream:pnext(e)
	if self.creps == self.reps then 
		self.creps=0
		return nil
	else
		self.creps = self.creps + 1
		return self.verb(e,unpack(self.argus))
		--return self.verb(unpack(self.argus))
	end
end
FuncStreamOld = Stream:new{verb=nil,argus=nil}
function FuncStreamOld:pnext(e)
	if self.creps == self.reps then 
		self.creps=0
		return nil
	else
		self.creps = self.creps + 1
		--return self.verb(e,unpack(self.argus))
		return self.verb(unpack(self.argus))
	end
end
-- @section end

--- Returns FuncStream with function v
-- @param v :the function
-- @param r integer number of repetitions
-- @param ... optional arguments to function
-- @return FuncStream
function FS(v,r,...)
	r= r or 1
	assert(type(v)=="function")
	assert(type(r)=="number","r should be a number!!")
	return FuncStream:new{verb=v,argus={...},reps=r}
end
function FSold(v,r,...)
	r= r or 1
	assert(type(v)=="function")
	assert(type(r)=="number","r should be a number!!")
	return FuncStreamOld:new{verb=v,argus={...},reps=r}
end
--- Returns FuncStream performing weigthed choices
-- @param a list to choose from.
-- @param b list of weigths
-- @param r number of repetitions
-- @return #FuncStream
-- @usage st = FS(function() return 3 end,-1)
-- print(st:nextval())
function WRS(a,b,r)
	r = r or 1
	return FS(function(e,...) return wchoice(...) end,r,a,b)
end
--- Returns FuncStream performing choices from list.
-- @param a list to choose from.
-- @param r number of repetitions
-- @return FuncStream
function RS(a,r)
	r = r or 1
	return FS(function(e,...) return choose(...) end,r,a)
end
--- Returns FuncStream performing choices from list infinite times.
-- @param a list to choose from.
-- @return FuncStream
function RSinf(a)
	return RS(a,-1)
end
------------------------------------------------------
FuncStreamLS = Stream:new{verb=nil,argus=nil}
function FuncStreamLS:pnext(e)
	if self.creps == self.reps then 
		self.creps=0
		return nil
	else
		self.creps = self.creps + 1
		return LS(self.verb(self.argus,self.argusb),self.repsls)
	end
end
function FSLS(v,a,b,r,r2)
	r=r or 1
	r2= r2 or 1
	return FuncStreamLS:new{verb=v,argus=a,argusb=b,reps=r,repsls=r2}
end
---- ListStream. Stream that iterates over a list
-- @type ListStream
ListStream = Stream:new{pos=1,list=nil}
function ListStream:pnext(e)
	while(true) do
		if self.creps == self.reps then -- contrl repeticiones
			self:reset()
			return nil
		else
			local b = self.list[self.pos]
			if b~=nil then
				self.pos = self.pos + 1
				return b
			else						-- list ended but still remain repetitions
				self.pos = 1
				self.creps = self.creps + 1
			end
		end
	end
end
--- For lists of items responding to merge (PS for example)
-- @param t key-val table to be merged with items in ListStream
--function ListStream:merge(t)
--	for i,v in ipairs(self.list) do
--		v:merge(t)
--	end
--end
function ListStream:reset()
	assert(#self.list > 0,"ListStream without list")
	for i,v in ipairs(self.list) do
		if type(v)=="table" and (v.isStream == true) then
			v:reset()
		end
	end
	Stream.reset(self)
end
-- @section end

--- Creates a ListStream from t with r repetitions
-- @param t list of events to provide in a infinite loop on each call to next
-- @param r number of repetitions of list t until ending stream
-- @return ListStream
-- @see ListStream
function LS(t,r)
	r = r or 1
	if(type(t)~="table" or  t.isStream) then 
		--prtable(t)
		--error("ListStream Error: List should be a not stream table!!",2) 
		t = {t}
	end

	return ListStream:new({reps=r,list=t})
end
--- Creates a ListStream from t with infinite repetitions
-- @param t list of events to provide in a infinite loop on each call to next
-- @return ListStream
-- @see ListStream
function LOOP(t)
	return LS(t,-1)
end
-----------------------------------------
function ConstSt(val)
	return ConstantStream:new{value=val}
end
ConstantStream=Stream:new{value=nil,isConstantStream=true}
function ConstantStream:pnext(e)
	return self.value
end
------------------------------------------------------------
AutoGenListStream=ListStream:new{}
function AutoGenListStream:pnext(e)
	if not self.list then self.list=self.generator(self.argus) end
	return ListStream.pnext(self,e)
end
function AutoGenListStream:reset()
	self.list= nil --self.generator(self.argus)
	self.creps=0
	self.pos=1
	self.recur=nil
end
--like FSLS(gen,data,nil,1,r)
function AGLS(gen,data,r)
	r=r or 1
	return AutoGenListStream:new{reps=r,argus=data,generator=gen}
end
-----------------------------------------------------------------
AutoGenStream=Stream:new()
function AutoGenStream:pnext(e)
	
	if not self.generated then self.generated=self.generator(self.argus) end
	local res=self.generated:nextval(e)
	if not res then 
		self:reset()
		return nil
	else
		return res
	end
end
function AutoGenStream:merge(t)
	if self.generated then
		self.generated:merge(t)
	end
	--for k,v in pairs(t) do
--		self.stlist[#self.stlist][k] = v
--	end
end
function AutoGenStream:reset()
	self.generated = nil --self.generator(self.argus)
	--error("averqu")
	--pritable(self.argus)
	--prtable(self.generated)
end
function AGS(generator,argus)
	return AutoGenStream:new{generator=generator,argus=argus}
end
--------List step streams-----------------------------------------
--give one and stops
ListStepsStream = ListStream:new{}
function ListStepsStream:pnext(e)
	while(true) do
		if self.creps == self.reps then -- contrl repeticiones
			self:reset()
			--print("NIL1")
			return nil
		else
			if self.active then
				--self.active = false
				local b = self.argus[self.pos]
				if b then
					self.pos = self.pos + 1
					self.active = false
					return b
				else						-- fin argus pero quedan repeticiones
					self.pos = 1
					self.creps = self.creps + 1
				end
			else
				self.active = true
				--print("NIL2")
				return nil
			end
		end
	end
end
function ListStepsStream:reset()
	self.creps=0
	self.pos=1
	self.active = true
	self.recur=nil
	Stream.reset(self)
end
function LSS(t,r)
	r = r or -1
	return ListStepsStream:new({active=true,reps=r,argus=t})
end
-------------------------------------------------------------
MarkovStream = Stream:new()
function MarkovStream:pnext(e)
	if self.old==nil then
		self.old = choose(self.keys)
		return self.old
	end
	local rr=self.marktable[self.old]
	local res
	if rr then
		res=wchoice(rr[1],rr[2])
	else
		res=rr
		print("markov nil xxxxxxxxxxxxxxxxxxxxxxxxxx")
	end
	self.old=res
	return res
end
function MarkovStream:reset()
	--print("reset markov")
	self.old=nil
	self.recur=nil
end
function MarkS(markt)
	local keys = {}
	for k,v in pairs(markt) do
		keys[#keys + 1] = k
	end
	return MarkovStream:new({marktable=markt,keys=keys})
end
------------------------------------
local function DataKeys(t)
	if t.keys then return t.keys end
	local keys = {}
	for k,v in pairs(t.data) do
		keys[#keys + 1] = k
	end
	t.keys = keys
	return keys
end
MarkovStreamO = Stream:new()
function MarkovStreamO:pnext(e)
	
	local node = self.marktable
	local pointer = self.pointer % self.order
	for i=1,self.order do
		if not self.memory[pointer] then
			if self.initable and i== 1 then
				self.memory[pointer] = choose(self.initable)
				--print("markov initable",self.memory[pointer])
			else
				self.memory[pointer] = choose(DataKeys(node))
			end
			return self.memory[pointer]
		end
		node = node.data[self.memory[pointer]]
		if not node then break end
		pointer = (pointer + 1) % self.order
	end

	local res
	if node then
		res=wchoice(node[1],node[2])
	else
		self:reset()
		print("markov nil xxxxxxxxxxxxxxxxxxxxxxxxxx")
		return nil
	end
	
	self.memory[self.pointer % self.order] = res
	self.pointer = self.pointer + 1
	return res
end
function MarkovStreamO:reset()
	--print("reset markov")
	self.memory={}
	self.pointer = 0
	self.recur=nil
end
function MarkSO(markt,initable)
	local keys = {}
	for k,v in pairs(markt) do
		keys[#keys + 1] = k
	end
	return MarkovStreamO:new({marktable=markt,keys=keys,order=markt.order,initable=initable})
end
--t sequence table, o order
function MarkovLearn(t)
	local m = {}
	local old
	for i=2,#t do
		old = t[i-1]
		v = t[i]
		m[old] = m[old] or {}
		m[old][v] = (m[old][v] or 0) + 1
	end
	for k,v in pairs(m) do
		local tt = {{},{}}
		for k2,v2 in pairs(v) do
			table.insert(tt[1],k2)
			table.insert(tt[2],v2)
		end
		Normalize(tt[2])
		m[k] = tt
	end
	return m
end
--t sequence table, o order
function MarkovLearnO(t,order)
	local order = order or 1
	assert((order > 0) and (order < #t),"MarkovLearnO: order must be less than sequence length")
	local m = {}
	for i = order + 1,#t do
		v = t[i]
		local node = m
		for i2=order,1,-1 do
			node.data = node.data or {}
			node.data[t[i - i2]] = node.data[t[i - i2]] or {}
			node = node.data[t[i - i2]]
		end
		--node.data[v] = (node.data[v] or 0) + 1
		node[v] = (node[v] or 0) + 1
	end
	--prtable(m)
	local function setmarkov(v)
			--print"setmarkov xxxxxxxxxxxxxxxxxxxx"
			--prtable(v)
			local tt = {{},{}}
			for k2,v2 in pairs(v) do
				table.insert(tt[1],k2)
				table.insert(tt[2],v2)
			end
			Normalize(tt[2])
			return tt
	end
	local function explorenodes(node,action,key,parent)
		--print("explore xxxxxxxxxxxxxxxxx",node,action,key,parent)
		--prtable(node)
		if not node.data then
			parent.data[key] = action(node) 
		else
			for k,v in pairs(node.data) do
				explorenodes(v,action,k,node)
			end
		end
	end
	explorenodes(m,setmarkov)
	m.order = order
	return m
end
--------------------------------------------------------
local function mulOp(A,B)
	return A * B
end
local function divOp(A,B)
	return A / B
end
local function addOp(A,B)
	return A + B
end
--local function mulOp(A,B)
--	return A * B
--end
OpStreams = Stream:new{stA=nil,stB=nil}
function OpStreams:pnext(e)
	local a = self.stA:nextval(e)
	local b = self.stB:nextval(e)
	if a == nil or b == nil then
		return nil
	elseif isSimpleTable(a) then
		return self.Op(TA(a), b)
	elseif isSimpleTable(b) then
		return self.Op(a ,TA(b))
	end
	return self.Op(a, b)
end
function OpStreams:reset()
	self.stA:reset()
	self.stB:reset()
	self.recur=nil
end
function ADD(A,B)
	if type(A) ~="table" or A.nextval == nil then --no es stream
			A=ConstSt(A)
	end
	if type(B) ~="table" or B.nextval == nil then --no es stream
			B=ConstSt(B)
	end
	return OpStreams:new({stA=A,stB=B,Op=addOp})
end
function MUL(A,B)
	if type(A) ~="table" or A.nextval == nil then --no es stream
			A=ConstSt(A)
	end
	if type(B) ~="table" or B.nextval == nil then --no es stream
			B=ConstSt(B)
	end
	return OpStreams:new({stA=A,stB=B,Op=mulOp})
end
function DIV(A,B)
	if type(A) ~="table" or A.nextval == nil then --no es stream
			A=ConstSt(A)
	end
	if type(B) ~="table" or B.nextval == nil then --no es stream
			B=ConstSt(B)
	end
	return OpStreams:new({stA=A,stB=B,Op=divOp})
end
--------pairs streams----------------------------------------------
PairsStream = Stream:new{stlist=nil}
PairsStream.isPairsStream=true
function PairsStream:pnext(e)
	local list= {}
	e.tmplist = list
	for i,t in ipairs(self.stlist) do
		local list2 = {}
		if t.isStream then
			list2 = t:nextval(e)
			if not list2 then
				self:reset()
				return nil
			end
		else -- simple table
			for k,v in pairs(t) do
				list2[k]=v:nextval(e)
				if list2[k] == nil then
					self:reset()
					return nil
				end
				-- convert arrys of streamss
				if type(k) == "table" then
					for i2,v2 in ipairs(k) do
						list2[v2]=list2[k][i2]
					end
					list2[k]=nil
				end
			end
		end
		list = mergeTable(list,list2)
	end
	list.delta = list.delta or list.dur
	--e.tmplist = nil
	return list
end
function PairsStream:reset()
	for i,t in ipairs(self.stlist) do
		if t.isStream then
			t:reset()
		else
			for k,v in pairs(t) do
				--if not pcall(function()
				v:reset()
				--end) then debuglocals(true);error("error in PairsStream:reset") end
			end
		end
	end
	self.recur=nil
end
function PairsStream:merge(t)
	StreamWrap(t)
	for k,v in pairs(t) do
		self.stlist[#self.stlist][k] = v
	end
end
--gets the last key
function PairsStream:getStream(key)
	local res 
	for i,t in ipairs(self.stlist) do
			res = t[key] or res
	end
	return res
end
--accepts several streampairs
function PS(...)
	local ps=PairsStream:new{stlist={...}}
	for i,t in ipairs{...} do
		if isSimpleTable(t) then
			StreamWrap(t)
		end
	end
	return ps
end

function StreamWrap(t)
	for k,v in pairs(t) do
		assert(type(k)~="number","PS item without key")
		if type(v) ~="table" or not v.isStream then --no es stream
			t[k]=ConstantStream:new{value=v}
		end
	end
	return t
end
-- named and number keys
--like ptuple
function ArrS(t)
	for k,v in ipairs(t) do
		--assert(type(k)~="number","PS item without key")
		if type(v) ~="table" or v.nextval == nil then --no es stream
			--t[k]=LS({v},-1)
			t[k]=ConstantStream:new{value=v}
		end
	end
	return StreamTuple:new{stlist=t}
end
---------------
--e is the player, tmplist created by PS
KeyStream = Stream:new{}
function KeyStream:pnext(e)
	return e.tmplist[self.key]
end
function KEY(key)
	assert(type(key)=="string")
	return KeyStream:new{key=key}
end
------------paralel stream
ParalelStream = Stream:new{ stlist = nil}
ParalelStream.isParalelStream = true
function ParalelStream:pnext(e)
	if not self.PQ then self:reset() end
	local t,st,k = self.PQ:pop()
	local res = st:nextval(e)
	if not res then self.PQ= nil; return res end
	local tdelta = res.delta
	-- to tell the player when call nextval again
	res.delta = math.min(self.PQ:topPrio() - t, res.delta)
	self.PQ:put(tdelta + t, st,k)
	return res
end
function ParalelStream:merge(t)
	for k,v in ipairs(self.stlist) do
		v:merge(t)
	end
end
function ParalelStream:reset()
	self.PQ = PriorityQ:new()
	for k,v in ipairs(self.stlist) do
		v:reset()
		self.PQ:put(0,v,k)
	end
	Stream.reset(self)
end
function ParS(t)
	return ParalelStream:new{stlist=t}
end
------------Merge stream
MergeStream = Stream:new{stlist = nil}
MergeStream.isMergeStream = true
function MergeStream:pnext(e)
	local res = {}
	for k,v in ipairs(self.stlist) do
		local res2 = v:nextval(e)
		for k,v in pairs(res2) do
			res[k] = v
		end
	end
	return res
end
function MergeStream:reset()
	for k,v in ipairs(self.stlist) do
		v:reset()
	end
	Stream.reset(self)
end
function MERGE(...)
	return MergeStream:new{stlist={...}}
end
--------Pclump
PclumpSt = Stream:new{}
function PclumpSt:pnext(e)
	local n = self.N:nextval(e)
	local res = {}
	for i = 1,n do
		res[i] = self.pat:nextval(e)
	end
	return res
end
function Pclump(n,pat)
	if type(n) ~="table" or not n.isStream then --no es stream
			n=ConstantStream:new{value=n}
	end
	if type(pat) ~="table" or not pat.isStream then --no es stream
			pat=ConstantStream:new{value=pat}
	end
	return PclumpSt:new{N=n,pat=pat}
end
--------RepeaterSt
-- gets a value from pat and repeats n times
RepeaterSt = Stream:new{}
function RepeaterSt:pnext(e)
	local n = self.N:nextval(e)
	local val = self.pat:nextval(e)
	if val then
		return LS({val},n)
	else
		return nil
	end
end
function REP(n,pat)
---[[
	if type(n) ~="table" or not n.isStream then --no es stream
			n=ConstantStream:new{value=n}
	end
	if type(pat) ~="table" or not pat.isStream then --no es stream
			pat=ConstantStream:new{value=pat}
	end
--]]
	return RepeaterSt:new{N=n,pat=pat}
end
-----StreamTuple
StreamTuple = Stream:new{}
function StreamTuple:pnext(e)
	--local list= e or {}
	local list2 = {}
	for k,v in ipairs(self.stlist) do
		list2[k]=v:nextval(e)
		if list2[k] == nil then
			self:reset()
			return nil
		end
	end
	return list2
end
function StreamTuple:reset()
	for i,v in ipairs(self.stlist) do
		v:reset()
	end
	self.recur=nil
end
function TUPLE(t)
	assert(isSimpleTable(t))
	for k,v in ipairs(t) do
		if type(v) ~="table" or v.nextval == nil then --no es stream
			t[k]=ConstantStream:new{value=v}
		end
	end
	return StreamTuple:new{stlist=t}
end
-----------------------------------------------------------

PdefStream = Stream:new({argus=nil,stlist=nil,def=nil})
function PdefStream:pnext(e)

	if self.def == nil then
		self.argus=self.stlist:nextval(e)
		self:makedef()
	end
	local ret = nil
	while true do
		ret = self.def:nextval(e)
		if ret == nil then
			self.argus=self.stlist:nextval(e)
			self:makedef()
		else
			ret = mergeMissingList(ret,self.argus)
			return ret
		end
	end
end
function PdefStream:reset()
	self.stlist:reset()
	self.def=nil
	self.recur=nil
end
function PdefStream:makedef()
--print("makedef")
--print(self.argus)
	self.def=FinDur(self.argus.dur,PS{
	inst=self.argus.inst,
	dur=LS({1,1.5,0.5},-1) * self.argus.factor,
	degree=LS(self.argus.degree,-1),
	escale=self.argus.escale,
	velo=self.argus.velo
	})
end
function PdefStream:input(pat)
	self.stlist = pat
	return deepcopy(self)
end

-----------------------------------------------------------------
StreamFunc = Stream:new()
function StreamFunc:pnext(e)
	local ret = self.argus:nextval(e)
	if ret == nil then self.argus:reset() return nil end
	ret = self.func(ret,e)
	return ret
end
function StreamFunc:reset()
	self.argus:reset()
end
function SF(pat,fun)
	if  (type(pat)~="table") or (pat.nextval == nil) then --no es stream
		pat=ConstantStream:new{value=pat}
	end
	return StreamFunc:new({argus=pat,func=fun})
end
-----------------used in named_events
--sends nil to funcs and has first
StreamFunc2 = Stream:new{first = true}
function StreamFunc2:pnext(e)
	local ret = self.argus:nextval(e)
	--if ret == nil then self.argus:reset() return nil end
	ret = self.func(ret,e,self.first)
	self.first = false
	return ret
end
function StreamFunc2:reset()
	self.first = true
	self.argus:reset()
end
function SF2(pat,fun)
	if  (type(pat)~="table") or (pat.nextval == nil) then --no es stream
		pat=ConstantStream:new{value=pat}
	end
	return StreamFunc2:new({argus=pat,func=fun})
end
-------------------
StreamArgsFunc = StreamFunc:new()
function StreamArgsFunc:pnext(e)
	local ret=self.argus:nextval(e)
	if ret == nil then self.argus:reset() return nil end
	ret=self.func(unpack(ret))
	return ret
end
function SArgsF(fun,...)
	return StreamArgsFunc:new({argus=ArrS{...},func=fun})
end

function quantize(val,q)
	return math.floor(val/q + 0.5)*q
end
--- Quantizes numbers provided by a stream to multiples of q
-- @param q length of quantization
-- @param pat a stream of numbers
-- @return Stream
function Quant(q,pat)
	return SF(pat,function(val) return math.floor(val/q + 0.5)*q end)
end
--------------------------------------------------------
SFindur = Stream:new({findur=1,cfindur=0,str=nil})
function SFindur:pnext(e)
	if self.acabado then return nil end
	local vals=self.str:nextval(e)
	if not vals then return nil end
	local cfindur = self.cfindur + vals.dur
	if cfindur < self.findur then
		self.cfindur = cfindur
		return vals
	else
		self.acabado = true
		vals.dur = self.findur - self.cfindur
		self.cfindur = self.findur
		if vals.dur > 0 then
			return vals
		else
			return nil
		end
	end
end
function SFindur:reset()
	self.str:reset()
	self.cfindur=0
	self.acabado=false
	self.recur=nil
end
function FinDur(findur,pat)
	return SFindur:new({findur=findur,cfindur=0,str=pat,acabado=false})
end



