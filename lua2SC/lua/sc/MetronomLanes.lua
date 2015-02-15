--- MetronomLanes
--require"init"
require"sc.playersppq"

theMetro={bpm=120,bps=2,beat=0,rate=100,ppqPos=0,playing=0,frame=1,playNotifyCb={},abstime=0}
--EP for computing abstime on scrolling theMetro
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

--]]
------------------------------------------
function getHostTime()
	return theMetro
end
function theMetro:GOTO(beat)
	self:play(nil,beat)
end
function theMetro:play(bpm,beat,run,rate)
	if rate then self.rate=rate end
	if bpm then self:tempo(bpm) end
	if beat then self.ppqPos=beat; theMetro.oldtimestamp = lanes.now_secs() end
	--self.beat=self.ppqPos
	

	self.frame=self.bps/self.rate
	self.period=1/self.rate

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
	self.frame=self.bps/self.rate
	self.period=1/self.rate
end

function theMetro:Free()
	self.playing=0
end
function theMetro:start()
	--print("start reloj")
	self.playing=1
	theMetro.oldtimestamp = lanes.now_secs()
	--lanes.timer(scriptlinda,"metronomLanes",self.period,0)--self.period)
	lanes.timer(scriptlinda,"metronomLanes",self.period,self.period)
end
function theMetro:stop()
	--print("paro reloj")
	self.playing=0
	lanes.timer(scriptlinda,"metronomLanes",0)
end

function theMetro:ppq2time(ppq)
	return self.timestamp + (ppq - self.oldppqPos) / self.bps
end

function theMetro.backwards(ppq)
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
		v:Reset(true)
	end
	if Routines then
		for i,v in ipairs(Routines) do
			v:Reset()
		end
	end
	if named_events then
		named_events:delete_events()
	end
end

local initial_time
function setMetronomLanes(timestamp)
	--print("setMetronomLanes")
	--[[
	if theMetro.oldtimestamp then
		theMetro.realperiod = timestamp - theMetro.oldtimestamp
		local errorl =(theMetro.realperiod - theMetro.period) --*theMetro.rate
		if  math.abs(errorl) >= 1/100 then
			prerror("error metronomLanes ",errorl,theMetro.period)
		end
	else
		theMetro.realperiod = theMetro.period
	end
		--]]

	local tms1 = lanes.now_secs()
	initial_time = initialtime or tms1
	local errorl = tms1 - timestamp
	if  math.abs(errorl) >= 1/100 then
		prerror("error metronomLanes ",errorl, theMetro.period)
	end
	-------------------------------
	if theMetro.oldppqPos and theMetro.oldppqPos > theMetro.ppqPos then --backwards
		prerror("xxxxxxxxxmetro back")
		theMetro.backwards(theMetro.ppqPos)
	end 

---------------------------------------
	theMetro.timestamp = timestamp
	theMetro.realperiod = timestamp - theMetro.oldtimestamp
	--theMetro.abstime = theMetro.abstimeAcum + (theMetro.player.ppqPos - theMetro.ppqPosSave) / theMetro.bps
	 
	theMetro.oldppqPos = theMetro.ppqPos
	theMetro.ppqPos = theMetro.ppqPos + theMetro.frame --theMetro.bps * theMetro.period 

	--theMetro.abstime = theMetro.abstime + theMetro.realperiod
	
	_onFrameCb()

	theMetro.oldtimestamp = timestamp
	--lanes.timer(scriptlinda,"metronomLanes",theMetro.period,0)
	--collectgarbage("collect")
end

theMetro:play(120,-4,0,30)
--table.insert(initCbCallbacks,function() print("init metronom");theMetro:play(120,-4,0,100) end)
resetCbCallbacks = resetCbCallbacks or {}
table.insert(resetCbCallbacks,function() theMetro:stop() end)