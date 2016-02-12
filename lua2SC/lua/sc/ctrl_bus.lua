--GetControlBus=IDGenerator(0)

ctrl_buses = {holes = {},allocated = {}}
GetCtrlBus=IDGenerator(0)
function ctrl_buses:new_bus(N)
	N = N or 1
	return GetCtrlBus(N)
	--[[
	local busnum
	if N and N > 1 then --sequentially allocate
		table.insert(self.allocated,true)
		busnum = #self.allocated
		for i=1,N-1 do table.insert(self.allocated,true) end
		return busnum --returns first busnum
	end

	local hole = table.remove(self.holes)
	if hole then
		self.allocated[hole] = true
		busnum = hole
	else
		table.insert(self.allocated,true)
		busnum = #self.allocated
	end
	return busnum
--]]
end

function ctrl_buses:free_bus(n)
	error"not implemented"
	table.insert(self.holes,n)
	--self.allocated[n] = nil
end

function SendCtrlSynth(synname,lista,paramname,player,beatTime)
	--prtable(lista)
	if not player.ctrl_group then
		player.ctrl_group = GetNode()
		local msg={"/g_new",{player.ctrl_group,0,player.group}}
		sendBundle(msg)
	end
	local bundle = {}
	player.ctrl_buses = player.ctrl_buses or {buses = {},nodes = {}}
	if player.ctrl_buses.buses[paramname] then
		local on = {"/n_set", {player.ctrl_buses.nodes[paramname],"t_gate",1}}
		getMsgLista(on,lista)
		--sendBundle(on,theMetro:ppq2time(beatTime))
		--table.insert(bundle,on)
        bundle[#bundle+1] = on
		--local mapmsg = {"/n_map",{player.node,paramname,{"int32",player.ctrl_buses.buses[paramname]}}}
		--sendBundle(mapmsg,theMetro:ppq2time(beatTime))
	else
		local node = GetNode()
		local bus = ctrl_buses:new_bus()
		player.ctrl_buses.buses[paramname] = bus
		player.ctrl_buses.nodes[paramname] = node
		local on = {"/s_new", {synname, node, 0, player.ctrl_group, "bus", {"int32",bus},"t_gate",1}}
		getMsgLista(on,lista)
		--sendBundle(on,theMetro:ppq2time(beatTime))
		--table.insert(bundle,on)
        bundle[#bundle+1] = on
		--local mapmsg = {"/n_map",{player.node,paramname,{"int32",bus}}}
		--sendBundle(mapmsg,theMetro:ppq2time(beatTime))
		--prerror("new envel one ",synname,paramname)
	end
	local mapmsg = {"/n_map",{player.node,paramname,{"int32",player.ctrl_buses.buses[paramname]}}}
	--table.insert(bundle,mapmsg)
    bundle[#bundle+1] = mapmsg
	--sendMultiBundle(theMetro:ppq2time(beatTime),bundle)
	return bundle
end

--for sending several envs
function SendCtrlSynth_ar(synname,envel_ar,paramname,player,beatTime)
	--error("SendCtrlSynth_ar")
	if not player.ctrl_group then
		player.ctrl_group = GetNode()
		msg={"/g_new",{player.ctrl_group,0,player.group}}
		sendBundle(msg)
	end
	local bundle = {}
    player.ctrl_buses = player.ctrl_buses or {buses = {},nodes = {}}
    local firstbus
    if player.ctrl_buses.buses[paramname] then
        firstbus = player.ctrl_buses.buses[paramname]
		local nodes = player.ctrl_buses.nodes[paramname]
		for i=1,#envel_ar do
			local node = nodes[i]
			local bus = firstbus + i -1
			local on = {"/n_set", {node,"t_gate",1}}
			getMsgLista(on,envel_ar[i])
			--sendBundle(on,theMetro:ppq2time(beatTime))
			--table.insert(bundle,on)
			bundle[i] = on
		end
		--local mapmsg = {"/n_mapn",{player.node,paramname,{"int32",firstbus},{"int32",#envel_ar}}}
		--sendBundle(mapmsg,theMetro:ppq2time(beatTime))
    else
        firstbus = ctrl_buses:new_bus(#envel_ar)
        player.ctrl_buses.buses[paramname] = firstbus
		player.ctrl_buses.nodes[paramname] = {}
		local nodes = player.ctrl_buses.nodes[paramname]
		for i=1,#envel_ar do
			local node = GetNode()
			--table.insert(nodes,node)
            nodes[#nodes+1]=node
			local bus = firstbus + i -1
			local on = {"/s_new", {synname, node, 0, player.ctrl_group, "bus", {"int32",bus},"t_gate",1}}
			getMsgLista(on,envel_ar[i])
			--sendBundle(on,theMetro:ppq2time(beatTime))
			--table.insert(bundle,on)
			bundle[i] = on
			--prerror("new envel ",synname)
		end
		
    end
	local mapmsg = {"/n_mapn",{player.node,paramname,{"int32",firstbus},{"int32",#envel_ar}}}
	--sendBundle(mapmsg,theMetro:ppq2time(beatTime))
    bundle[#bundle+1] = mapmsg
	--sendMultiBundle(theMetro:ppq2time(beatTime),bundle)
	return bundle
end
table.insert(initCbCallbacks,function()
	print("init ctrl_bus")

	SynthDef("RAMP",{inip=0,endp=0,time=1,bus=0,t_gate=1},function()
		--Out.kr(bus,Line.kr(inip,endp,time,t_gate,0,0))
		Out.kr(bus,EnvGen.kr(Env({inip,inip,endp},{0,time}),t_gate))
	end):store()
	SynthDef("ERAMP",{inip=0,endp=0,time=1,bus=0,t_gate=1},function()
		--Out.kr(bus,XLine.kr(inip,endp,time,t_gate,0,0))
		Out.kr(bus,EnvGen.kr(Env({inip,inip,endp},{0,time},"exp"),t_gate))
	end):store()
	SynthDef("SINE",{freq=44 ,phase=0 ,amp=1,add=0,bus=0,t_gate=1},function()
		Out.kr(bus,SinOsc.kr(freq,phase,amp,add))
	end):store()
	SynthDef("VIB",{bus=0,freq=1,rate=5,delay=0,depth=0.1,rv=0.04,dv=0.1,t_gate=1},function()
		Out.kr(bus,Vibrato.kr{freq=freq, rate=rate, depth=depth, delay=delay,rateVariation=rv,depthVariation=dv,trig=t_gate})
	end):store()
end)

-----------------------------
ctrl_mapper = {is_ctrl_mapper=true}
function ctrl_mapper:new(o)
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
ctrl_mapper.__add = function (a,b)
	local A,B
	if type(a)=="table" and a.is_ctrl_mapper then
		A,B = a,b
	else
		A,B = b,a
	end
	local C = A:new()
	C.inip = A.inip + B
	C.endp = A.endp + B
	return C
end
ctrl_mapper.__mul = function (a,b)
	local A,B
	if type(a)=="table" and a.is_ctrl_mapper then
		A,B = a,b
	else
		A,B = b,a
	end
	local C = A:new()
	if A.inip then
		C.inip = A.inip * B
		C.endp = A.endp * B
	elseif A.levels then
		local levels = {}
		for i,v in ipairs(A.levels) do
			levels[i] = v * B
		end
		C.levels = levels
	else --SINE?
		
	end
	return C
end
ctrl_mapper.__div = function (a,b)
	return a*(1/b)
end
--------------------------

function RAMP(inip,endp,time)
	local ctmap = ctrl_mapper:new{inip=inip,endp=endp,time=time}
	function ctmap:verb(paramname,player,beatTime,beatLen)
		local time = self.time or beatLen
		return SendCtrlSynth("RAMP",{inip=self.inip ,endp=self.endp ,time=beats2Time(time)},paramname,player,beatTime)
	end
	return ctmap
end
function SINE(freq,phase,amp,add)
	local ctmap = ctrl_mapper:new{}
	function ctmap:verb(paramname,player,beatTime,beatLen)
		return SendCtrlSynth("SINE",{freq=freq ,phase=phase ,amp=amp,add=add},paramname,player,beatTime)
	end
	return ctmap
end
function SINEr(freq,phase,lo,hi)
	local amp = hi-lo
	local add = (hi+lo)*0.5
	return SINE(freq,phase,amp,add)
end
function ERAMP(inip,endp,time)
	local ctmap = ctrl_mapper:new{inip=inip,endp=endp,time=time}
	function ctmap:verb(paramname,player,beatTime,beatLen)
		local time = self.time or beatLen
		return SendCtrlSynth("ERAMP",{inip=self.inip ,endp=self.endp ,time=beats2Time(time)},paramname,player,beatTime)
	end
	return ctmap
end
function VIB(val,rate,depth,delay,rv,dv)
	rate = rate or 5
	depth = depth or 0.1
	delay = delay or 0
	local ctmap = ctrl_mapper:new{}
	function ctmap:verb(paramname,player,beatTime,beatLen)
		return SendCtrlSynth("VIB",{freq=val, rate=rate, depth=depth, delay=delay,rv=rv,dv=dv,trig=t_gate},paramname,player,beatTime)
	end
	return ctmap
end

----------ENV

local MAX_ENVEL_STEPS = 15
local MAX_ENVEL_prosc = (MAX_ENVEL_STEPS +1)*4
table.insert(initCbCallbacks,function()
SynthDef("ENVEL",{envel=Ref(Env().newClear(MAX_ENVEL_STEPS):prAsArray()),bus=0,t_gate=1},
			function()
			local sig = EnvGen.kr{envel,t_gate}
			CheckBadValues.kr(sig,0,2)
			ReplaceOut.kr(bus,sig)--doneAction=2})
		end):store()
---[[
SynthDef("ENVELm",{lev=Ref(TA():Fill(MAX_ENVEL_STEPS +1,0)),tim=Ref(TA():Fill(MAX_ENVEL_STEPS,0)),cur=Ref(TA():Fill(MAX_ENVEL_STEPS,0)),bus=0,t_gate=1},
			function()
			ReplaceOut.kr(bus,EnvGen.kr{Env(lev,tim,cur),t_gate})--doneAction=2})
		end):store()
SynthDef("ENVELm_st",{lev=Ref(TA():Fill(MAX_ENVEL_STEPS +1,0)),tim=Ref(TA():Fill(MAX_ENVEL_STEPS,0)),cur=Ref(TA():Fill(MAX_ENVEL_STEPS,0)),bus=0,t_gate=1},
			function()
			ReplaceOut.kr(bus,EnvGen.kr{Env.new_str_curves(lev,tim,cur),t_gate})--doneAction=2})
		end):store()

--]]
end)
local function LastPad(arr,N)
	local res = {}
	local last = arr[#arr]
	for i=1,N do
		res[i] = arr[i] or last
	end
	return res
end
local function ZeroPad(arr,N)
	local res = {}
	for i=1,N do
		res[i] = arr[i] or 0
	end
	return res
end
local function E2ppq(levels,timesppq,curves,beatLen,istime,loopnode)
	--print("E2ppq",beatLen)
	local times = {}
	beatLen = istime and beatLen or beats2Time(beatLen)
	for i,v in ipairs(timesppq) do
		times[i] = v*beatLen
	end
	--print(prOSC(times))
	levels = LastPad(levels,MAX_ENVEL_STEPS + 1)
	times = ZeroPad(times,MAX_ENVEL_STEPS)
	return Env(levels,times,curves,nil,loopnode):prAsArray()
end

local function Make_createtable(narr)
  return loadstring("return {"..("0,"):rep(narr).."}");
end
local crtab = {}
local function createtable(size)
	if not crtab[size] then
		crtab[size] = Make_createtable(size)
	end
	return crtab[size]()
end
--local createtable = Make_createtable(MAX_ENVEL_prosc)
--local function createtable(a,b)
--	return {nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil}
--end


local function make_multienvel(args)
	local size=0
	--for k,v in ipairs(args) do
	for ii=1,#args do
		local v = args[ii]
		if type(v)=="table" then
			local vlen = #v
			size= (vlen > size) and vlen or size
		end
	end
	if size==0 then return {{envel=args}} end
	local results = createtable(size) --{}
	for i=1,size do
		local newargs = createtable(MAX_ENVEL_prosc) --{}
		--for k,v in ipairs(args) do
		for ii=1,#args do
			local v = args[ii]
			if type(v)=="table" then 
				newargs[ii] = WrapAt(v,i)
			else
				newargs[ii] = v
			end
		end
		results[i] = {envel=newargs}
	end
	return results
end


function ENV(levels,times,curves,relative,istime,loopnode)
	--MakeEnvelSynthNEW(#times)
	local ctmap = ctrl_mapper:new{levels=levels,times=times}
	function ctmap:verb(paramname,player,beatTime,beatLen)
		local lev,tim,cur
		if type(levels)=="function" then
			lev = levels(player)
		else
			lev = self.levels
		end
		if type(times)=="function" then
			tim = times(player)
		else
			tim = self.times
		end
		if type(curves)=="function" then
			cur = curves(player)
		else
			cur = curves
		end
		--print(prOSC(tim))
		local envel = E2ppq(lev,tim,cur,relative and beatLen or 1,istime,loopnode)
		local envel_ar = make_multienvel(envel)
		if #envel_ar == 1 then
			return SendCtrlSynth("ENVEL",envel_ar[1],paramname,player,beatTime)
		else
			return SendCtrlSynth_ar("ENVEL",envel_ar,paramname,player,beatTime)
		end
		--return 0
	end
	return ctmap
end
function ENVstep(levels,times,curves,relative,istime)
	--MakeEnvelSynthNEW(#times)
	local ctmap = ctrl_mapper:new{levels=levels,times=times}
	function ctmap:verb(paramname,player,beatTime,beatLen)
		local lev,tim,cur
		if type(levels)=="function" then
			lev = levels(player)
		else
			lev = self.levels
		end
		if type(times)=="function" then
			tim = times(player)
		else
			tim = self.times
		end

		local envel = E2ppq(lev,tim,"step",relative and beatLen or 1,istime)
		local envel_ar = make_multienvel(envel)
		if #envel_ar == 1 then
			return SendCtrlSynth("ENVEL",envel_ar[1],paramname,player,beatTime)
		else
			return SendCtrlSynth_ar("ENVEL",envel_ar,paramname,player,beatTime)
		end
		--return 0
	end
	return ctmap
end
function ENVr(levels,times,curves)
	return ENV(levels,times,curves,true)
end




--swaps row and files 2d (transpose matrix)
local function flop(t)
	if type(t[1])~="table" then return {t} end
	local res={}
	local files=#t
	local rows=#t[1]
	for i=1,rows  do
		res[i]={}
		for j=1,files do
			res[i][j]=t[j][i]
		end
	end
	return res
end
local function Envflop(lev,tim,cur)
	lev = flop(lev)
	local lista = {}
	for i=1,#lev do
		lista[i] = {lev=lev[i],tim=tim,cur=cur}
	end
	return lista
end
--works with separated lev,tim,cur being more efficient
function ENVm(levels,times,curves,relative,istime)
	local function E2ppqm(levels,timesppq,curves,beatLen)
		local times = {}
		beatLen = istime and beatLen or beats2Time(beatLen)
		for i,v in ipairs(timesppq) do
			times[i] = v*beatLen
		end
		levels = LastPad(levels,MAX_ENVEL_STEPS + 1)
		times = ZeroPad(times,MAX_ENVEL_STEPS)
		local cur = (type(curves)=="table") and curves or {curves}
		local synthname = "ENVELm"
		for i,v in ipairs(cur) do
			if type(v)=="string" then
				synthname = "ENVELm_st"
				cur[i] = Env.shapeNames[v]
			end
		end
		cur = LastPad(cur,MAX_ENVEL_STEPS)
		return levels,times,cur,synthname --Env(levels,times,curves):prAsArray()
	end
	curves = curves or 0
	local ctmap = ctrl_mapper:new{levels=levels,times=times}
	function ctmap:verb(paramname,player,beatTime,beatLen)
		local lev,tim,cur,synthname
		if type(levels)=="function" then
			lev = levels(player)
		else
			lev = levels
		end
		if type(times)=="function" then
			tim = times(player)
		else
			tim = times
		end
		if type(curves)=="function" then
			cur = curves(player)
		else
			cur = curves
		end
		lev,tim,cur,synthname = E2ppqm(lev,tim,cur,relative and beatLen or 1,istime)
		local lev_ar = Envflop(lev,tim,cur)
		if #lev_ar == 1 then
			return SendCtrlSynth(synthname,lev_ar[1],paramname,player,beatTime)
		else
			return SendCtrlSynth_ar(synthname,lev_ar,paramname,player,beatTime)
		end
	end
	return ctmap
end

function ENVmx(levels,times,curves)
	--MakeEnvelSynthNEW(#times)
	curves = curves or 0
	local function E2ppqmX(levels,timesppq,curves)
		local times = {}
		--beatLen = beats2Time(beatLen)
		for i,v in ipairs(timesppq) do
			times[i] = v --*beatLen
		end
		levels = LastPad(levels,MAX_ENVEL_STEPS + 1)
		times = ZeroPad(times,MAX_ENVEL_STEPS)
		local cur = type(curves)=="table" and curves or {curves}
		cur = ZeroPad(cur,MAX_ENVEL_STEPS)
		return levels,times,cur --Env(levels,times,curves):prAsArray()
	end
	local lev,tim,cur = E2ppqmX(levels,times,curves)
	
	local ctmap = ctrl_mapper:new{levels=levels,times=times}
	function ctmap:verb(paramname,player,beatTime,beatLen)
		beatLen = beats2Time(beatLen)
		for i,v in ipairs(tim) do
			tim[i] = type(v)=="function" and v(beatLen) or v
		end
		local lev_ar = Envflop(lev,tim,cur)
		if #lev_ar == 1 then
			return SendCtrlSynth("ENVELm",lev_ar[1],paramname,player,beatTime)
		else
			return SendCtrlSynth_ar("ENVELm",lev_ar,paramname,player,beatTime)
		end
		--return 0
	end
	return ctmap
end
-- ENV for degree---------------------------------------
local function gnote(val,escale) return midi2freq(getNote(val,escale)) end
--convert dummy degree according to lev values and return freq 
local function envlev(pl,lev)
	local l = pl.curvals
	local _dummy = l.degree
	if IsREST(_dummy) then return REST end
	local res = {}
	for i,v in ipairs(lev) do
		res[i] = gnote(_dummy + v,l.escale)
	end
	table.insert(res,1,res[1]) --repeat first value
	return res
end
--just get _dummy
function getdegree(pl)
	local l = pl.curvals
	return gnote(l.degree,l.escale)
end
function ENVdeg(levels,times,absolute)
	local relative = not absolute
	assert(#levels==#times + 1,"levels and times dont match")
	--add zero initial time
	local tim = deepcopy(times)
	table.insert(tim,1,0)
	local ctmap = ctrl_mapper:new{levels=levels}
	function ctmap:verb(paramname,player,beatTime,beatLen)
		local lev = envlev(player,levels)
		if IsREST(lev) then return nil end
		local envel = E2ppq(lev,tim,"exp",relative and beatLen or 1)
		local envel_ar = make_multienvel(envel)
		if #envel_ar == 1 then
			return SendCtrlSynth("ENVEL",envel_ar[1],paramname,player,beatTime)
		else
			return SendCtrlSynth_ar("ENVEL",envel_ar,paramname,player,beatTime)
		end
	end
	return ctmap
end
