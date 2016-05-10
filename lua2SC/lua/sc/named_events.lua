named_events = {events = {}}
local checkpl = {}
function named_events:subscribe(name, func, pl,...)
	prerror("subscribe ev",name,pl.name,pl)

	checkpl[pl] = checkpl[pl] or {}
	if checkpl[pl][name] then error("already set") end
	checkpl[pl][name]=true

	self.events[name] = self.events[name] or {}
	table.insert(self.events[name], {func = func , args = {...} })
	-- for already setted ev do this subscr
	if self.events[name].is_setted then
		func(self.events[name].ppq,...) 
	end
end

function named_events:set(name, ppq)
	if self:is_set(name) then return end
	prerror("setting ev",name,ppq)
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
	checkpl = {}
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
					if named_events:is_set(name) then
						e.playing = true
						return nil 
					end
					named_events:subscribe(name,function(ppq) 
														--print("WatiEv triger",ppq)
														e.prevppqPos = -math.huge --avoid reset
														e.ppqPos = ppq;
														e.playing = true
														e:Play()
													end,e)
					
					return {dur=0,delta=math.huge,freq=NOP}
				end)
end
--[[
function UNTILEv(name,pat,waitmark)
	local finished = false
	return SF2(pat,function(val,e,first)

				if first then
					--print"UNTILEV subscribe"

					named_events:subscribe(name,function(ppq) 
														print"UNTILEV subscribe called"
														print(ppq,e.prevppqPos,e.ppqPos)
														e.prevppqPos = -math.huge --avoid reset
														e.ppqPos = ppq; 
														e:Play()
														print"UNTILEV subscribe called2"
													end)
	
				finished = false
				end
				if named_events:is_set(name) then 
					--if not waitmark then
						print("UNTILEV returns nil",lanes.now_secs())
						return nil
					--else
					--	if val._mark then return nil end
					--end
				end
				print("UNTILEV not setted",val.degree,lanes.now_secs())
				if val == nil then finished = true end
				if finished then return {dur=1,delta=math.huge,freq=NOP} end
				return val
				end)
end
--]]
local function genUntilev(name,waitmark)
	local finished = false
	local first = true
	local function func(val,e,stream)
		if first then
			first = false
			if not waitmark then
			--print("UNTILEV subscribe",name)
			named_events:subscribe(name,function(ppq) 
										--print"UNTILEV subscribe called"
										--print(e.prevppqPos,e.ppqPos)
											e.prevppqPos = -math.huge --avoid reset
											e.ppqPos = ppq; 
											e:Play()
										--print"UNTILEV subscribe called2"
										end,e)
			end
		end
		if named_events:is_set(name) then
			if waitmark then
				if val._mark then
					--print("UNTILEV returns mark nil",e.name)
					return nil
				end
			else
				--print("UNTILEV returns nil",e.name) 
				return nil
			end
		end
		--print("UNTILEV not setted",val.degree,lanes.now_secs())
		if val == nil then finished = true end
		if finished then return {dur=1,delta=math.huge,freq=NOP} end --NOP
		return val
	end
	local function rfunc()
		finished = false
		first = true
		--unsubscribe?
	end
	return func,rfunc
end

function UNTILEv(name,pat,waitmark)
	return SFr(pat,genUntilev,name,waitmark)
end
function MARK()
	return PS{dur=LS{0},_mark=1}
end