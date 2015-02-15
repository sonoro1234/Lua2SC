routine={MUSPOS=0,ppqPos=0,playing=true}
function routine:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end
Routines = {}
function Routine(body,t)
	local res = routine:new(t)
	res.body = body
	Routines[#Routines +1] = res
	return res
end
function routine:Reset()
	self.thread = coroutine.create(self.body)
	--if Debugger then
	--[[
		self.thread = coroutine.create(function(...)
			print("coroutine.running() is",coroutine.running(),debugger_hook)
			debug.sethook(coroutine.running(),debug_hook,"l")
			return self.body(...) end)
	--]]
		--debug.sethook(self.thread ,Debugger.debug_hook,"l")
		--print"sethook to routine"
	--else
	--	self.thread = coroutine.create(self.body)
	--end

	self.co = function() 
		local code,res = coroutine.resume(self.thread)
		if code then
			return res
		else
			error(res,1)
		end
	end
	--self.co = coroutine.wrap(self.body)
	self.ppqPos = self.MUSPOS
	self.prevppqPos = -math.huge 
	self.playing = true
	--self.used=false
	theMetro.queueEvent(self.ppqPos, self)
end
function routine:Pull()
	
	if self.prevppqPos > (theMetro.oldppqPos + theMetro.frame )then --and self.used then
		print("reset ppqPos" .. self.ppqPos .. " hostppqPos " .. theMetro.ppqPos .. " ",self.name)
		print(self.prevppqPos ,theMetro.oldppqPos)
		self:Reset()
	end
	if theMetro.playing > 0 then
		while self.playing and theMetro.oldppqPos > self.ppqPos do
			--local good,dur=coroutine.resume(self.co)
			-- if not good then print("error en co ",dur) end
			local dur=self.co()
			
			if not dur then --coroutine.status(self.co) == "dead"  then
				if  self.playing then
					if self.doneAction then
						self:doneAction()
					end
					print("se acabo: ",self.name)
				end
				self.playing = false
				break
			else
				self.prevppqPos = self.ppqPos
				self.ppqPos = self.ppqPos + dur
			end
		end

	end
end
function routine:Play()
	self:Pull()
	if theMetro.playing == 0 then
		return
	end
	--while theMetro.oldppqPos <= self.ppqPos and self.ppqPos < theMetro.ppqPos and self.playing do
		--local good,dur=coroutine.resume(self.co)
		--if not good then print("error en co ",dur) end
		local dur = self.co()		
		if not dur then --coroutine.status(self.co) == "dead"  then
			if  self.playing then
				if self.doneAction then
					self:doneAction()
				end
				print("se acabo: ",self.name)
			end
			self.playing = false
			--break
		else
			self.prevppqPos = self.ppqPos
			self.ppqPos = self.ppqPos + dur
			theMetro.queueEvent(self.ppqPos, self)
		end
	--end
end
function routine:findMyName()
	for k,v in pairs(_G) do
		if v==self then return k end
	end
	return "unnamedCO"
end
table.insert(initCbCallbacks,function() 
	for i,v in ipairs(Routines) do
			v.name = v.name or v:findMyName()
			v:Reset()
		end
end)
--[[
table.insert(onFrameCallbacks,function() 
		for i,v in ipairs(Routines) do
			--print("onframe player:",v.name)
			--coroutine.resume(v)
			v:Play()
		end
	end)
--]]