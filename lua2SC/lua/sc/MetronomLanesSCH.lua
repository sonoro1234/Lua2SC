--- MetronomLanes
--require"init"
require"sc.playersppqSCH"

theMetro={bpm=120,bps=2,beat=0,rate=100,ppqPos=0,playing=0,frame=1,playNotifyCb={},abstime=0}
--EP for computing abstime
---[[
function updateAbsTime(p)
	p.abstimeAcum = p.abstimeAcum + (p.ppqPos - p.ppqPosSave )/theMetro.bps
	p.ppqPosSave = p.ppqPos
	theMetro.abstime = p.abstimeAcum
	--print(theMetro.abstime, theMetro.player.ppqPos, theMetro.player.ppqPosSave, theMetro.bps,theMetro.ppqPos)
	return 1
end
theMetro.player = EP{ppqPosSave=0,abstimeAcum=0,name="MetroPlayer"}
theMetro.player:Bind{dur = 0.5,
	abst = FS(updateAbsTime,-1,theMetro.player)
}
function theMetro:Init()
	self.abstimeAcum = 0
	self.ppqPosSave = 0
end
--]]
------------------------------------------
function getHostTime()
	return theMetro
end
function theMetro:GOTO(beat)
	self:play(nil,beat)
end
function theMetro:play(bpm,beat,run,rate)
	if bpm then self:tempo(bpm) end
	if beat then self.ppqPos=beat; theMetro.timestamp = lanes.now_secs() end
	--self.beat=self.ppqPos
	if rate then self.rate=rate end
	--self.frame=self.bpm/(self.rate*60)
	self.frame=self.bps/self.rate
	--self.period=1/self.rate
	if run then self.playing=run end
	
	--print("cambio reloj",bpm,beat,rate)
	--prtable(self)
	
	if self.playing==1 then
		self:start()
	else
		self:stop()
	end
	--lanes.timer(scriptlinda,"metronomLanes",self.period,self.period)
	for k,v in ipairs(self.playNotifyCb) do
		v(self)
	end
end
--data for lindas
function theMetro:send()
	return {bpm = self.bpm, playing = self.playing, abstime = self.abstime, ppqPos = self.ppqPos}
end
function theMetro:tempo(bpm)
	--self.abstimeAcum = self.abstimeAcum + (self.player.ppqPos - self.ppqPosSave )/self.bps
	--print(self.abstimeAcum)
	--self.ppqPosSave = self.player.ppqPos
	self.bpm=bpm;
	self.bps=bpm/60
	self.invbps = 1/self.bps
	self.frame = self.bps/self.rate -- beats in 1/rate seconds
end

function theMetro:Free()
	self.playing=0
end
function theMetro:start()
	--print("start reloj")
	self.playing=1
	theMetro.timestamp = lanes.now_secs()
	lanes.timer(scriptlinda,"metronomLanes",0,0)--self.period)

	--self.period=1/self.rate
	--lanes.timer(scriptlinda,"metronomLanes",self.period,self.period)
end
function theMetro:stop()
	--print("paro reloj")
	self.playing=0
	lanes.timer(scriptlinda,"metronomLanes",nil)
end

function theMetro:ppq2time(ppq)
	return self.timestamp + (ppq - self.ppqPos) * self.invbps
end
theMetro.queue = {}
function printqueue()
	print"---------queue----------------"
	for i,v in ipairs(theMetro.queue) do
		print(i, v.time, v.player.name,v.player.prevppqPos, v.player.ppqPos)
	end
	print"-----------------------------"
end
function theMetro.queueEvent(time, player)
	if time then 
		--table.insert(theMetro.queue,{time=time, player=player}) 
		--print("xxxxxx queueEvent",time, player and player.name)
		--insert sorted
		for k,v in ipairs(theMetro.queue) do
			if time <= v.time then
				table.insert(theMetro.queue,k,{time=time, player=player})
				return
			end
		end
		--goes in the end
		table.insert(theMetro.queue,{time=time, player=player})
	end
	--prtable({time=time, player=player})
	--dumpObj(theMetro.queue)
end
function theMetro.backwards()
	for i,v in ipairs(ActionPlayers) do
		v:Reset()
	end
	for i,v in ipairs(Players) do
		v:Reset()
	end
		--MASTER_INIT2()
	for i,v in ipairs(Effects) do
		v:Reset()
	end
	for i,v in ipairs(OSCPlayers) do
		v:Reset()
	end
	if Routines then
	for i,v in ipairs(Routines) do
		v:Reset()
	end
	end
end
function setMetronomLanes(timestamp)
	local tms1 = lanes.now_secs()
	--[[
	if theMetro.oldtimestamp then
		theMetro.realdelta = timestamp - theMetro.oldtimestamp
		if theMetro.delta then
		local errorl =(theMetro.realdelta - theMetro.delta) --*theMetro.rate
		if  math.abs(errorl) >= 1/100 then
			prerror("error metronomLanes ",errorl, theMetro.delta)
		end
		end
	else
		theMetro.realperiod = 0 --first theMetro.period
		--print("theMetro.timestamp",timestamp, theMetro.timestamp,theMetro.ppqPos)
	end
		--]]
	local errorl = tms1 - timestamp
	if  math.abs(errorl) >= 1/100 then
		prerror("error metronomLanes ",errorl, theMetro.delta)
	end
	
	theMetro.timestamp = timestamp
	--theMetro.abstime = theMetro.abstimeAcum + (theMetro.player.ppqPos - theMetro.ppqPosSave) / theMetro.bps
	
	if theMetro.oldppqPos and theMetro.oldppqPos > theMetro.ppqPos then --backwards
		prerror("xxxxxxxxxmetro back")
		theMetro.queue = {}
		theMetro.backwards()
		--printqueue()
	end 

	local tms2 = lanes.now_secs()
	-------------------------------------
	local Mqueue = theMetro.queue
	--prtable(Mqueue)
	--print("setMetronomLanes",theMetro.oldppqPos, theMetro.ppqPos, #theMetro.queue, theMetro.queue[1].time)
	local limtimeevents = theMetro.ppqPos + theMetro.frame
	--table.sort(theMetro.queue,function(a,b) return a.time < b.time end)
	while Mqueue[1] and Mqueue[1].time <= limtimeevents do
		--printqueue()
		local event = table.remove(Mqueue, 1)
		event.player:Play()
	end
	
	doSchedule(limtimeevents)	
	doOscSchedule(limtimeevents)
--printqueue()
	local tms3 = lanes.now_secs()
	--local delta = theMetro:ppq2time(Mqueue[1].time) - lanes.now_secs()
	local delta = theMetro:ppq2time(limtimeevents) - lanes.now_secs()
	if delta <=0 then 
		prerror("negative delta",delta,Mqueue[1].player.name,Mqueue[1].player.ppqPos,Mqueue[1].time,theMetro.ppqPos)
		prerror("timestamps",timestamp,tms1,tms2,tms3)
		delta = 0	
	end
--prtable(lanes.timers())

	theMetro.oldppqPos = theMetro.ppqPos
	theMetro.ppqPos = limtimeevents --Mqueue[1].time --theMetro.ppqPos + theMetro.bps * theMetro.realperiod 
	--theMetro.abstime = theMetro.abstime + theMetro.realperiod
	--dumpObj(theMetro.queue)
	theMetro.delta = delta
	theMetro.oldtimestamp = lanes.now_secs()
	lanes.timer(scriptlinda,"metronomLanes",delta,0)
	
	--if delta ==0 then 
		--prtable(lanes.timers())
	--end
	--collectgarbage("collect")
end

theMetro:play(120,-4,0,30)
idlelinda:send("Metro",theMetro:send())
--table.insert(initCbCallbacks,function() print("init metronom");theMetro:play(120,-4,0,100) end)
resetCbCallbacks = resetCbCallbacks or {}
table.insert(resetCbCallbacks,function() theMetro:stop() end)