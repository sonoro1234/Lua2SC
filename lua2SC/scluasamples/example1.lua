
--[[
This example shows:
	- starting server
	- loading a buffer
	- creating synths
	- creating groups
	- ordering synths and groups
]]
SynthDef("luaimpulse", { out=0, freq=2, amp=1},function()
	Out.ar(out, Pan2.ar(Impulse.ar(freq)*amp, 0))
end):store()

SynthDef("luagrain", {out=0, freq=880, amp=1},function()
	local signal;
	signal = EnvGen.ar{Env.perc(), doneAction=2} * SinOsc.ar(freq, 0, amp);
	Out.ar(out, Pan2.ar(signal, 0))
end):store()

SynthDef("luaplaybuf", {out=0, bufnum=0, rate=1, amp=1},function()
	local signal;
	signal = PlayBuf.ar{1, bufnum, rate, doneAction=2} * amp;
	Out.ar(out, Pan2.ar(signal, 0))
end):store()

SynthDef("luareverb", {inp=0, out=0, mix = 0.83, room = 0.5, damp = 0.5},function()
	local signal;
	signal = In.ar(0, 2);
	Out.ar(out, FreeVerb.ar(signal, mix, room, damp))
end):store()

SynthDef("luadelay", {inp=0, out=0, maxdelaytime = 0.2, delaytime = 0.2, decaytime = 1.0},function()
	local signal;
	signal = In.ar(0, 2);
	Out.ar(out, AllpassC.ar(signal, maxdelaytime, delaytime, decaytime))
end):store()

SynthDef("luasine", { out=0, freq=440, amp=0.5},function()
	Out.ar(out, Pan2.ar(SinOsc.ar(freq, 0, amp), 0));
end):store()
---------------------------------------------------------
local sclua = require "sclua.Server"
local s = sclua.Server()
local Synth, Group, Bus, Buffer = s.Synth, s.Group, s.Bus, s.Buffer

s:freeAll() -- free all synths playing and clear up the server

-- provide a path to your own sample here:
mybuf = Buffer([[C:\Program Files\SuperCollider-3.6.5\sounds/a11wlk01.wav]])

impulse = Synth("luaimpulse", { freq = 2 })
impulse2 = Synth("luaimpulse", { freq = 3 })
default = Synth("luasine", { freq = 2 })
reverb = Synth("luareverb", { freq = 2 })
delay = Synth("luadelay", { delaytime = 0.4, decaytime = 3 })
	
impulse:above(default)

groop = Group()
impulse:moveToHead(groop)
impulse2:moveToHead(groop)
delay:moveToTail(groop)

groox = Group(groop)
groox:below(groop)
reverb:moveToTail(groox)
---[[
local ctx = "sclua test"
win = Window(ctx, 0, 0, 380, 200)

function win:mouse(event, btn, x, y)
	--print(event, btn, x, y)
	if ((event == "down") and (btn == "left"))then
		mouseSynth = Synth("luaimpulse", { freq = 2222, amp = 0.1 })
		mouseSynth:moveToHead(groox)
		groox:above(groop)
	elseif event == "drag" then
		-- TWO POSSIBLE WAYS OF SENDING VALUES TO THE SYNTH
		-- a) using the set argument and giving an argval list
		--		mouseSynth:set({freq = 3*y, amp = x/250})
		-- b) setting the value directly
		mouseSynth.freq = 3*y
		mouseSynth.amp = x/250
	elseif event == "up" then	
		mouseSynth:free()
		groox:below(groop)
	end
end

function win:key(e, key)
	print("KEY", key)
	if e == "down" then	
		if key == 100 then -- KEY D
			reverb:below(mouseSynth)
			delay:below(mouseSynth)
		elseif key == 103 then -- KEY G - for grains
			Synth("luagrain", { freq = math.random(5222), amp = 0.05 }) -- no variable (synth frees itself)
		elseif key == 98 then -- KEY B - create buffer synth
			bufsynth = Synth("luaplaybuf", { amp = 0.9 , loop=1})
		elseif key == 102 then -- KEY F - free buffer synth
			bufsynth:free()
		elseif key == 118 then -- KEY V - for moving playbuf into a new group
			bufsynth:moveToHead(groox)
		elseif key == 99 then -- KEY C - for moving playbuf back on top w. reverb and delay
			bufsynth:moveToHead(groop)
		elseif key == 120 then -- KEY X - for moving playbuf back on top w. reverb and delay
			bufsynth:above(groop)
		elseif key == 122 then -- KEY Z 
			bufsynth:moveToTail(s.defaultGroup) -- move to original position
		elseif key == 110 then -- KEY N 
			impulse:set({freq = math.random(800)}) -- set a random frequency of impulse synth
		elseif key == 109 then -- KEY M 
			impulse:set({freq = 3}) -- set the impulse back to 3 Hz
		end
	end
end
--]]