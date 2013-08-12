
GetMetroID=IDGenerator(10)
Metronom={bpm=120,beat=0,rate=100,actualbeat=0,playing=0,frame=1,playNotifyCb={}}
function Metronom:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end
function getHostTime()
	local ret={}
	if theMetro then
		ret.ppqPos=theMetro.actualbeat
		ret.tempo=theMetro.bpm
		ret.playing=theMetro.playing
	else
		ret.ppqPos=0
		ret.tempo=120
		ret.playing=0
	end
	return ret
end


function Metronom:play(bpm,beat,run,rate)
	if bpm then self.bpm=bpm end
	if beat then self.actualbeat=beat end
	self.beat=self.actualbeat
	if rate then self.rate=rate end
	self.frame=self.bpm/(self.rate*60)
	if run then self.playing=run end
	if self.node ==nil then
		println("inicio reloj")
		self.id=self.id or GetMetroID()
		--_METRONOMS[self.id]=self
		self.node=GetNode()
		msg ={"/s_new", {"Clock", self.node, 0, 0,"id",{"int32",self.id},"rate",{"float",self.rate},"frame",{"float",self.frame},"beat",{"float",self.actualbeat},"t_reset",1,"run",self.playing}}
	else
		println("cambio reloj",bpm,beat,rate)
		prtable(self)
		msg={"/n_set", {self.node,"rate",{"float",self.rate},"frame",{"float",self.frame},"beat",{"float",self.actualbeat},"t_reset",1,"run",self.playing}}
	end
	self.timestamp=os.clock()
	udp:send(toOSC(msg))
	for k,v in ipairs(self.playNotifyCb) do
		v(self)
	end
end
function Metronom:Free()
	msg={"/n_free", {self.node}}
	udp:send(toOSC(msg))
	self.node=nil
	self.playing=0
	self.timestamp=os.clock()
end
function Metronom:start()
	println("start reloj")
	self.playing=1
	msg={"/n_set", {self.node,"rate",{"float",self.rate},"frame",{"float",self.frame},"beat",{"float",self.actualbeat},"t_reset",1,"run",self.playing}}
	udp:send(toOSC(msg))
	self.timestamp=os.clock()
end
function Metronom:stop()
	println("paro reloj")
	self.playing=0
	msg={"/n_set", {self.node,"rate",{"float",self.rate},"frame",{"float",self.frame},"beat",{"float",self.actualbeat},"t_reset",1,"run",self.playing}}
	udp:send(toOSC(msg))
	self.timestamp=os.clock()
end
--_METRONOMS={}
function setMetronom(id,beat)
	--print("setMetronom")
	--_METRONOMS[id].actualbeat=beat
	theMetro.actualbeat=beat
	_onFrameCb()
	--[[
			local beat=theMetro.actualbeat%8
			if beat>=0 and beat<theMetro.frame then
				local computedbeat=(theMetro.playing*(os.clock()-theMetro.timestamp)*theMetro.bpm/60)+theMetro.beat
				print("alive",theMetro.actualbeat," computed:",computedbeat," difference:",computedbeat-theMetro.actualbeat)
			end
	--]]
end
theMetro=Metronom:new()
table.insert(initCbCallbacks,function() theMetro:play(120,-4,0,100) end)
table.insert(resetCbCallbacks,function() theMetro:stop() end)