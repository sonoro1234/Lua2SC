--require"common.init"
require( "sc.stream")

----------
--[[
onFrameCallbacks={}
--table.insert(onFrameCallbacks,function()
	--ppqVSTFrameLength=theMetro.frame
--end)
table.insert(onFrameCallbacks,function()
	for i,v in ipairs(ActionPlayers) do
		--println("onframe player:",v.name)
		v:Play()
	end
end)
table.insert(onFrameCallbacks,function()
	for i,v in ipairs(Players) do
		--print("onframe player:",v.name)
		v:Play()
	end
end)
--]]
---replaces original-------work with ppq
eventQueue = {}
eventQueueDirty = false
function eventCompare(a, b)
    return b.delta>a.delta         
end 
function scheduleEvent(event)
    local q
    q = copyMidiEvent(event)
    table.insert(eventQueue, q)
	eventQueueDirty = true
end
function doSchedule(window)
	--print(" "..window.." ")
    --ensure the table is in order
	if eventQueueDirty then
		table.sort(eventQueue, eventCompare)
		eventQueueDirty = false
	end

    --send all events in this window
    local  continue = 0
    repeat        
        continue = 0
        if eventQueue[1] and eventQueue[1].delta<window then
            sendMidi(eventQueue[1])
            table.remove(eventQueue, 1)  
            continue = 1
        end              
    until continue==0    
        
end
----------replaces original works with ppq
--[[
function _onFrameCb()

    curHostTime = getHostTime()
	ppqVSTFrameLength=theMetro.frame
	---for i,v in ipairs(onFrameCallbacks) do
	--	v()
	--end
	local event = theMetro.queue[1]
	table.remove(theMetro.queue, 1)
	theMetro.queueEvent(event.player:Play())
    if onFrameCb then
        onFrameCb()
    end
    doSchedule(curHostTime.ppqPos)

end 
--]]
-------------------------------------------------------------------
function beats2Time(n)
	n=n or 4
	return n/theMetro.bps
end
function beats2Freq(n)
	n=n or 4
	return curHostTime.bpm/(n*60)
end
function BeatTime(n)
	return FS(function() return beats2Time(n) end,1)
end
function BeatFreq(n)
	return FS(function() return beats2Freq(n) end,1)
end
function getNote(nv, mode)
	local mode_notes
	if IsREST(nv) then return nv end
	if type(mode) == "table" then
		mode_notes = mode
	elseif modes[mode] then
		mode_notes = modes[mode]
	elseif scales[mode] then
		mode_notes = scales[mode]
	else
		error("mode "..tostring(mode).." not found")
	end
	if math.floor(nv) ~= nv then --fractional 0.5 between two degrees
		local nota1 = getNote(math.floor(nv),mode)
		local nota2 = getNote(math.floor(nv + 1),mode)
		--print("getNote",nota1,nota2,nv % 1)
		return nota1  + (nota2 - nota1) * (nv %1)
	else
		nv = nv - 1
		local nota = nv % #mode_notes
		local octava = math.floor(nv / #mode_notes)
		return mode_notes[nota + 1] + octava * 12
	end
	
end


--converts from pos to swinged pos
function swingtime(pos,swing,qsw)
	qsw = qsw or 0.5
	local qsw2 = qsw * 2.0
	local ss=pos%qsw2
	local ss2
	if ss > qsw then
		--ss2=qsw2*swing+(ss-qsw)*(1-swing)
		ss2=(1-swing)*(ss/qsw - 2)+qsw2
	else
		--ss2=ss*swing*2
		ss2=ss*swing/qsw
	end
	return pos - ss + ss2
	--return ss
end

--converts from pos to swinged pos
function swingtimeBAK(pos,swing,qsw)
	qsw = qsw or 0.5
	local qsw2 = qsw * 2.0
	local ss=pos%qsw2
	local ss2
	if ss > qsw then
		--ss2=qsw2*swing+(ss-qsw)*(1-swing)
		ss2=(1-swing)*(ss/qsw - 2)+qsw2
	else
		--ss2=ss*swing*2
		ss2=ss*swing*2
	end
	return pos - ss + ss2
	--return ss
end

EventPlayer={MUSPOS=0,ppqOffset=0,ppqPos=0,playing=true,dur=0}
function EventPlayer:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end
function EP(t)
	local res = EventPlayer:new(t)
	--Players[#Players +1] = res
	rawset(Players,#Players +1,res)
	return res
end
function EventPlayer:Bind(l)
	--local l = {...}
	local a
	--if not l.dur then l.dur = math.huge end
	self.binded = l
	if not l.isStream then 
		a=PS(l)
		--a=PairsStream:new{stlist=l}
	else
		a=l
	end
	self.lista = a
	--self.lista=copyObj(a)
	--self:Init()
	return self
end
function EventPlayer:ReBind(l)
	local a
	--if not l.dur then l.dur = math.huge end
	self.binded = l
	if not l.isStream then 
		a=PS(l)
	else
		a=l
	end
	self.lista=a
	--self.lista=copyObj(a)
	self:Reset()
	return self
end
function EventPlayer:MergeBind(a)
	self.lista:merge(a)
	--self.lista=copyObj(a)
	return self
end
function EventPlayer:MusPos2SamplePos(a)
	return a*(60/curHostTime.bpm)*curHostTime.sampleRate
end

function EventPlayer:UpdatePos(dur, doqueue)
	--print("UpdatePos1",self.name,self.prevppqPos,self.ppqPos,dur)
	self.prevppqPos = self.ppqPos
	self.ppqPos=self.ppqPos + dur
	if doqueue then
		theMetro.queueEvent(self.ppqPos, self)
	end
end
function EventPlayer:Reset()
	
	if not self.binded then self:Bind{dur=math.huge}  end
	self.lista:reset()
	self.ppqPos = self.MUSPOS + self.ppqOffset
	self.prevppqPos= -math.huge --self.MUSPOS
	--self:NextVals()
	self.playing=true
	--self:UpdatePos(0)
	self.used=false
	theMetro.queueEvent(self.ppqPos, self)
	print("Reset:",self.name,self.ppqPos)
end


function EventPlayer:Pull()
	--[[
	if self.prevppqPos > curHostTime.oldppqPos and self.used then
		prerror("pull reset ppqPos",self.name,self.prevppqPos,self.ppqPos,"hostppqPos",curHostTime.oldppqPos,curHostTime.ppqPos)
		self:Reset()
	
	end
--]]
	
	if curHostTime.playing > 0 then
		if self.playing and curHostTime.oldppqPos  > self.ppqPos then
			prerror("Pull ",self.name,(curHostTime.ppqPos  - self.ppqPos),theMetro.window)
			self:StopSound()
		end
		while self.playing and curHostTime.oldppqPos > self.ppqPos do
			--prerror(" wPull ",self.name,curHostTime.ppqPos - self.ppqPos)
			local havenext = self:NextVals()
			if havenext then
				self:UpdatePos(self.curlist.delta, false)
			else
			--if havenext == nil  then
				if  self.playing then
					--prtable(self.curlist)
					if self.doneAction then
						self:doneAction()
					end
					print("se acabo: ",self.name)
				end
				self.playing = false
				break
			end
		end
	end
end
function EventPlayer:NextVals()
	--print("NextVals ",self.name)
	self.used=true
	self.curlist = self.lista:nextval(self)
		
	if self.curlist == nil then
		return nil
	end
	--[[
	now in streams.lua
	-- convert arrys of streamss
	local lista=self.curlist
	for k,v in pairs(lista) do 
		if type(k) == "table" then
			for i2,v2 in ipairs(k) do
				lista[v2]=v[i2]
			end
			lista[k]=nil
		end
	end
	--]]
	if self.Filters then
		for k,v in pairs(self.Filters) do
			if self.curlist[k] then
				self.curlist[k] = v(self.curlist)
			end
		end
	end
	return true
	--self.dur=self.curlist.delta
	--self.curlist.delta = nil
	--return self.curlist.delta
end
function EventPlayer:StopSound()
	--works in derived classes
end
function EventPlayer:Play()
	--prerror("Play",self.name,self.prevppqPos,self.ppqPos,theMetro.ppqPos)
	self:Pull()
	if curHostTime.playing == 0 then
		return
	end
	if not self.playing then return end
	--if curHostTime.oldppqPos <= self.ppqPos then 
	--and self.ppqPos < curHostTime.ppqPos do
		local havenext = self:NextVals()
		if havenext == nil  then
			--if  self.playing then
				--prtable(self.curlist)
				if self.doneAction then
					self:doneAction()
				else
					self:Reset()
				end
				print("se acabo: ",self.name,self.ppqPos)
			--end
			self.playing = false
			--break
		else
			self:playEvent(self.curlist,self.ppqPos,self.curlist.dur,self.curlist.delta)
			self:UpdatePos(self.curlist.delta, true)
		end
	--end
end
MidiEventPlayer = EventPlayer:new({})
function MidiEventPlayer:playMidiNote(nv,vel,chan,beatTime, beatLen) 
	--print("beattime "..beatTime.." beatlen"..beatLen.."\n")
	on = noteOn(nv,vel,chan,beatTime)
	off = noteOff(nv, chan,beatTime + beatLen)
	--prtable(on)
	--prtable(off)
	scheduleEvent(on)
	scheduleEvent(off)      
end
function getmaxlen(lista)
	local max = math.max
	local maxlen = 1
	for k,v in pairs(lista) do
		maxlen = max(maxlen,len(v))
	end
	return maxlen
end
function EventPlayer:playEvent(lista,beatTime, beatLen,delta)
	--return self:playOneEvent(lista,beatTime, beatLen)
	---[[
	--local res = {}

	for i=1,getmaxlen(lista) do
		local keydata = {}
		for k,v in pairs(lista) do
			--need deepcopy in case item is altered in playOneEvent
			--and is a table reference (ex:ctrl_function)
			--keydata[k] = deepcopy(WrapAtSimple(v,i))
			keydata[k] = WrapAtSimple(v,i)
		end
		keydata.dur = nil
		keydata.delta = nil
		--res[i] = keydata
		self:playOneEvent(keydata,beatTime, beatLen,delta)
	end
	--for i,v in ipairs(res) do
	--	self:playOneEvent(v,beatTime, beatLen,delta)
	--end
	--]]
end
function EventPlayer:playEventBAK(lista,beatTime, beatLen,delta)
	--return self:playOneEvent(lista,beatTime, beatLen)
	---[[
	--local res = {}
	local max = math.max
	local maxlen = 1
	for k,v in pairs(lista) do
		maxlen = max(maxlen,len(v))
	end
	for i=1,maxlen do
		local keydata = {}
		for k,v in pairs(lista) do
			--need deepcopy in case item is altered in playOneEvent
			--and is a table reference (ex:ctrl_function)
			--keydata[k] = deepcopy(WrapAtSimple(v,i))
			keydata[k] = WrapAtSimple(v,i)
		end
		keydata.dur = nil
		keydata.delta = nil
		--res[i] = keydata
		self:playOneEvent(keydata,beatTime, beatLen,delta)
	end
	--for i,v in ipairs(res) do
	--	self:playOneEvent(v,beatTime, beatLen,delta)
	--end
	--]]
end
function EventPlayer:playOneEvent(lista,beatTime, beatLen)
	--prtable(lista)
	--println("EventPlayer:playNote")
	self.curbeatTime=beatTime
	self.curbeatLen=beatLen
end

function MidiEventPlayer:playOneEvent(lista,beatTime, beatLen) 
	local nota,velo,escale,chan
	
	escale = lista.escale or "ionian"
	
	if lista.note then
		nota = lista.note
	elseif lista.degree then
		nota = getNote(lista.degree,escale)
	end
	nota = nota or 69
	velo = lista.velo or 64
	chan = lista.chan or 0
	--if self.volumen then velo = velo * self.volumen end
	if IsREST(nota) then return end
	if type(nota) == "table" then
		for i,v in ipairs(nota) do
			self:playMidiNote(v,velo,chan,beatTime,beatLen)
		end
	else
		self:playMidiNote(nota,velo,chan,beatTime,beatLen)
	end
end
function EventPlayer:Init()
	self.name = self.name or self:findMyName()
	self:Reset()
	return self.ppqPos,self
end
function EventPlayer:findMyName()
	for k,v in pairs(_G) do
		if v==self then return k end
	end
	return "unnamed"
end
function EventPlayer:ccPlayBAK()end
ActionPlayers={}
function initplayers()
	for i,v in ipairs(ActionPlayers) do
		--println("init player:",v.name)
		--v.name = v.name or v:findMyName()
		v:Init()
	end
	for i,v in ipairs(Players) do
		--println("init player:",v.name)
		--v.name = v.name or v:findMyName()
		v:Init()
	end
end
function resetplayers()	
	print("resetplayers")
	for i,v in ipairs(Players) do
		--println("init player:",v.name)
		v:Reset()
	end
end
------------------------------Actions
function StartPlayer(beatTime,...)
	--print("StartPlayer")
	--prtable{...}
	for k,player in ipairs{...} do
		print("start ",player.name)
		player.MUSPOS=beatTime
		player:Reset()
	end
end
function StopPlayer(...)
	for k,player in ipairs{...} do
		print("stopPlayer ",player.name)
		player:Reset()
		player.playing=false
	end
end
function ACTION(ppq,verb,...)
	return {ppq=ppq,verb,{...}}
end
function BINDSTART(ppq,player,pat)
	return {ppq=ppq,function() player:Bind(pat);player.MUSPOS=ppq;player:Reset() end,{}}
end
function SEND(ppq,player,param,value)
	return {ppq=ppq,function()
		player.params[param]=value;player:SendParam(param)
	end,{}}
end
function SENDINSERT(ppq,player,ins,param,value)
	return {ppq=ppq,function()
		player._inserts[ins].params[param]=value;player._inserts[ins]:SendParam(param)
	end,{}}
end
function START(ppq,...)
	return {ppq=ppq,StartPlayer,{ppq,...}}
end
function STOP(ppq,...)
	return {ppq=ppq,StopPlayer,{...}}
end
function GOTO(ppq,pos)
	return {ppq=ppq,theMetro.GOTO,{theMetro,pos}}
end
function FADEOUTBAK(ppq1,ppq2,...)
	local function fadeseveral(...)
		for k,player in ipairs{...} do
			local level1 = player.channel.oldparams.level
			local steps = (ppq2 - ppq1)/0.1
			local step = level1 / steps
			player.channel:MergeBind{level = FS(function(arg) 
								return math.max(0,player.channel.oldparams.level - step )
							end,steps,{player.channel}),
							dur = ConstSt(0.1)}
			player.channel:Reset()
			player.channel.ppqPos=ppq1
		end
	end
	return {ppq=ppq1,fadeseveral,{...}}
end

function FADEOUT(ppq1,ppq2,...)
	local function fadeseveral(...)
		for k,player in ipairs{...} do
			player.channel.Filters = player.channel.Filters or {}
			player.channel.Filters.level = function(list) 
					--print("fadeout",list.level * clip(linearmap(ppq1,ppq2,1,0,player.channel.ppqPos),0,1))
					return list.level * clip(linearmap(ppq1,ppq2,1,0,player.channel.ppqPos),0,1)
				end
			player.channel:MergeBind{dur = ConstSt(0.1)}
			player.channel:Reset()
			player.channel.ppqPos=ppq1
		end
	end
	return {ppq=ppq1,fadeseveral,{...}}
end
function FADEIN(ppq1,ppq2,...)
	local function fadeseveral(...)
		for k,player in ipairs{...} do
			player.channel.Filters = player.channel.Filters or {}
			player.channel.Filters.level = function(list) 
					--print("fadeout",list.level * clip(linearmap(ppq1,ppq2,1,0,player.channel.ppqPos),0,1))
					return list.level * clip(linearmap(ppq1,ppq2,0,1,player.channel.ppqPos),0,1)
				end
			player.channel:MergeBind{dur = ConstSt(0.1)}
			player.channel:Reset()
			player.channel.ppqPos=ppq1
		end
	end
	return {ppq=ppq1,fadeseveral,{...}}
end
function FADEINBAK(ppq1,ppq2,level,...)
	local function fadeseveral(...)
		for k,player in ipairs{...} do
			local steps = (ppq2 - ppq1)/0.1
			local step = level / steps
			player.channel:MergeBind{level = FS(function(arg) 
								return math.min(level,player.channel.oldparams.level + step )
							end,steps,{player.channel}),
							dur = ConstSt(0.1)}
			player.channel:Reset()
			player.channel.ppqPos=ppq1
		end
	end
	return {ppq=ppq1,fadeseveral,{...}}
end

function MUTE(ppq,...)
	local function muteseveral(...)
		for k,player in ipairs{...} do
			player.channel:MergeBind{unmute = 0}
			player.channel.params.unmute = 0
			player.channel:SendParams()
		end
	end
	return {ppq=ppq,muteseveral,{...}}
end
function UNMUTE(ppq,...)
	local function muteseveral(...)
		for k,player in ipairs{...} do
			player.channel:MergeBind{unmute = 1}
			player.channel.params.unmute = 1
			player.channel:SendParams()
		end
	end
	return {ppq=ppq,muteseveral,{...}}
end
function ActionEP(t)
	local res = ActionEventPlayer:new(t)
	ActionPlayers[#ActionPlayers +1] = res
	return res
end
ActionEventPlayer = EventPlayer:new({})
function ActionEventPlayer:NextVals(doqueue)
	--print("NextVals ",self.name)
	self.used=true
	self.curlist = self.lista:nextval(self)
	--prtable(self.curlist)
	print("ActionEventPlayer self.curlist ",self.curlist)
	if self.curlist == nil then
		return nil
	end
	self:UpdatePos(doqueue)
	return true
end
function ActionEventPlayer:UpdatePos(doqueue)
--prtable(self.curlist)
	--if self.curlist.actions then
	print("Updatepos ", self.name,self.curlist.actions.ppq)
	self.prevppqPos=self.ppqPos
	self.ppqPos=self.curlist.actions.ppq
	if doqueue then
		theMetro.queueEvent(self.ppqPos, self)
	end
	--else
	--	self.playing=false
	--end
end
function ActionEventPlayer:Reset()
	self.lista:reset()
	self.ppqPos= -math.huge
	self.prevppqPos= -math.huge --self.MUSPOS
	self.playing=true
	self.used=false
	self.curlist = nil
	theMetro.queueEvent(self.ppqPos, self)
	print("Reset:",self.name,self.ppqPos)
end

function ActionEventPlayer:playEvent(lista,beatTime, beatLen)
	print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx play action ",beatTime,self.ppqPos)
	local v=lista.actions
	v[1](unpack(v[2]))
end

function ActionEventPlayer:Pull()
	
	--if self.prevppqPos > curHostTime.oldppqPos and self.used then
	--	print("reset ppqPos" .. self.ppqPos .. " hostppqPos " .. curHostTime.ppqPos .. " ",self.name)
	--	self:Reset()
		
	--else
	if curHostTime.playing > 0 then
		while self.playing and curHostTime.oldppqPos > self.ppqPos do
			--print("Pull ",self.name)
			if self.curlist then
				self:playEvent(self.curlist,self.ppqPos)
			end
			local havenext = self:NextVals()
			--self:playEvent(self.curlist,self.ppqPos)
			--self:UpdatePos(self.dur)
			if havenext == nil  then
				if  self.playing then
					--prtable(self.curlist)
					print("se acabo: ",self.name)
				end
				self.playing = false
				break
			end
		end
	end
end
function ActionEventPlayer:Play()
	--self:Pull()
	if curHostTime.playing == 0 then
		return
	end
	--if curHostTime.oldppqPos <= self.ppqPos and self.playing then
--and self.ppqPos < curHostTime.ppqPos and self.playing do
			if self.curlist then self:playEvent(self.curlist,self.ppqPos) end
			local havenext =self:NextVals(true)
			
			--prtable(self.curlist)
			--self:UpdatePos(self.dur)
			--end
			
			if havenext == nil  then
				if  self.playing then
					--prtable(self.curlist)
					print("se acabo: ",self.name)
				end
				self.playing = false
				return
			end

	--end
	
end
-----------------------------------
table.insert(initCbCallbacks,function()
  curHostTime = getHostTime() 
end)
table.insert(initCbCallbacks,initplayers)
table.insert(resetCbCallbacks,resetplayers)
Players={}
setmetatable(Players,{__newindex = function() error("attemp to write on Players",2) end})

