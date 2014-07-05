--GetControlBus=IDGenerator(0)
ctrl_buses = {holes = {},allocated = {}}
function ctrl_buses:new_bus()
	local busnum
	local hole = table.remove(self.holes)
	if hole then
		self.allocated[hole] = true
		busnum = hole
	else
		table.insert(self.allocated,true)
		busnum = #self.allocated
	end
	return busnum
end

function ctrl_buses:free_bus(n)
	table.insert(self.holes,n)
	self.allocated[n] = nil
end

function SendCtrlSynth(synname,lista,paramname,player,beatTime)
	local node = GetNode()
	local bus = ctrl_buses:new_bus()
	local on = {"/s_new", {synname, node, 0, player.group, "bus", {"int32",bus}}}
	getMsgLista(on,lista)

	OSCFunc.newfilter("/n_end", node, function(noty) 
				ctrl_buses:free_bus(bus)
			end,true)
	sendBundle(on,theMetro:ppq2time(beatTime))
	local mapmsg = {"/n_map",{player.node,paramname,{"int32",bus}}}
	sendBundle(mapmsg,theMetro:ppq2time(beatTime))
end



SynthDef("RAMP",{inip=0,endp=0,time=1,bus=0},function()
	Out.kr(bus,Line.kr(inip,endp,time,1,0,2))
end):store()
SynthDef("ERAMP",{inip=0,endp=0,time=1,bus=0},function()
	Out.kr(bus,XLine.kr(inip,endp,time,1,0,2))
end):store()

-----------------------------
ctrl_mapper = {is_ctrl_mapper=true}
function ctrl_mapper:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
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
--------------------------

function RAMP(inip,endp,time)
	local ctmap = ctrl_mapper:new{inip=inip,endp=endp,time=time}
	function ctmap:verb(paramname,player,beatTime,beatLen)
		local time = self.time or beatLen
		SendCtrlSynth("RAMP",{inip=self.inip ,endp=self.endp ,time=beats2Time(time)},paramname,player,beatTime)
		return 0
	end
	return ctmap
end
function ERAMP(inip,endp)
	return function(paramname,player,beatTime,beatLen)
		SendCtrlSynth("ERAMP",{inip=inip,endp=endp,time=beats2Time(beatLen)},paramname,player,beatTime)
	end
end