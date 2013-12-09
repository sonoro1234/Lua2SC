
--[[
This example shows:
	- creating and using control busses
]]

local sclua = require "sclua.Server"
local s = sclua.Server()
local Synth, Group, Bus, Buffer = s.Synth, s.Group, s.Bus, s.Buffer

s:freeAll() -- free all synths playing and clear up the server

sine = Synth("luasine", { freq = 440 })
bus = Bus()
bus:set(1000)

sine:map("freq", bus)

lfo = Synth("lfo", { ctrlbus = bus:index() })

local ctx = "sclua test"
win = Window(ctx, 0, 0, 350, 150)

function win:mouse(event, btn, x, y)
	if ((event == "down") and (btn == "left"))then
		
	elseif event == "drag" then
--		lfo:set({ freq = x / 10 })
--		lfo:set({ mul = y })
		lfo:set({freq = x / 10, mul = y})
	elseif event == "up" then	

	end
end

function win:key(e, key)
	print("KEY", key)
	if e == "down" then	
		if key == 100 then -- KEY D
			lfo:free() -- stop the lfo synth
			bus:set(math.random(2000)) -- and set a static random frequency
		elseif key == 103 then -- KEY G - for grains
			lfo = Synth("lfo", { ctrlbus = bus:index() }) -- a sine LFO
		elseif key == 98 then -- KEY B - for buffer synth
			lfo:free()
			lfo = Synth("lfosaw", { ctrlbus = bus:index() }) -- a saw LFO

		elseif key == 118 then -- KEY V - for moving playbuf out of reverb and delay
			lfo:free()
			lfo = Synth("lfosaw", { ctrlbus = bus:index() })

		elseif key == 99 then -- KEY C - 
			sine:set({ freq = math.random(2000) }) -- we hardwire the frequency (not bus anymore)
			-- (note how and why this is different from key D (we set the arg to the freq, not the bus)
		elseif key == 120 then -- KEY X - we map the frequency back to the bus
			sine:map("freq", bus)
		end
	end
end
