named_events = {events = {}}

function named_events:subscribe(name, func, ...)
	prerror("subscribe ev",name)
	self.events[name] = self.events[name] or {}
	table.insert(self.events[name], {func = func , args = {...} })
	-- for already setted ev do this subscr
	if self.events[name].is_setted then
		func(self.events[name].ppq,...) 
	end
end

function named_events:set(name, ppq)
	prerror("setting ev",name)
	self.events[name] = self.events[name] or {}
	local evlist = self.events[name]
	evlist.is_setted = true
	evlist.ppq = ppq
	for i,v in ipairs(evlist) do
		v.func(ppq,unpack(v.args))
	end
end

function named_events:is_set(name)
	local evlist = self.events and self.events[name]
	return evlist and evlist.is_setted
end

function named_events:delete_events()
	self.events = {}
end

--for writing streams

function SETEv(name)
	return FS(function(pl)
					named_events:set(name,pl.ppqPos)
					return {delta=0,dur=0,freq=NOP}
				end)
end
function WAITEv(name)
	return FS(function(e) 
					e.playing = false; 
					named_events:subscribe(name,function(ppq) 
														e.prevppqPos = -math.huge --avoid reset
														e.ppqPos = ppq;
														e.playing = true
														e:Play()
													end)
					if named_events:is_set(name) then 
						return nil 
					end
					return {dur=1,delta=math.huge,freq=NOP}
				end)
end

function UNTILEv(name,pat)
	local finished = false
	return SF2(pat,function(val,e,first)
				if first then
					--print"UNTILEV subscribe"
					named_events:subscribe(name,function(ppq) 
														--print"UNTILEV subscribe called"
														--print(e.prevppqPos,e.ppqPos)
														e.prevppqPos = -math.huge --avoid reset
														e.ppqPos = ppq; 
														e:Play()
														--print"UNTILEV subscribe called2"
													end)
					finished = false
				end
				if named_events:is_set(name) then 
					--print"Ev return nil"; 
					return nil 
				end
				if val == nil then finished = true end
				if finished then return {dur=1,delta=math.huge,freq=NOP} end
				return val
				end)
end