-- local lanes=require("lanes")
 -- lanes.configure({ nb_keepers = 1, with_timers = true, on_state_create = nil})
-- local linda= lanes.linda()
-- module setup
local mm=require("pmidi.core")
local modname = "pmidi" --...
local M = {}
_G[modname] = M
package.loaded[modname] = M
local midilinda
--local pmidi={}

M.OpenInput=mm.OpenInput
M.OpenOutput=mm.OpenOutput
--M.listDevices=mm.listDevices
function M._sendMidi(ev)
	midilinda:send("midiWriteShort",ev)
end
function M.exit_midi_thread()
	midilinda:send("exit_midi_thread",1)
	midilinda:receive( "exit_midi_thread_done" )
end
function M.GetMidiDevices()
	local devices=mm.listDevices()
	local res={inp={},out={}}
	for i,device in pairs(devices) do
		device.devID=i
		if device.input==1 then
			res.inp[#res.inp+1]=device
		end
		if device.output==1 then
			res.out[#res.out+1]=device
		end
	end
	return res
end
function M.GetMidiDevicesByName()
	local devices=mm.listDevices()
	local res={inp={},out={}}
	for i,device in pairs(devices) do
		device.devID=i
		if device.input==1 then
			res.inp[device.name]=device
		end
		if device.output==1 then
			res.out[device.name]=device
		end
	end
	return res
end
---[[
function M.midi_thread(inp,out)
	local midiin={}
	local midiout={}
	local err
	local midi_out_opened=false
	if prerror==nil then prerror=print end
	local function prstak(stk)
		local str=""
		for i,lev in ipairs(stk) do
			str= str..i..": \n"
			for k,v in pairs(lev) do
				str=str.."\t["..k.."]:"..v.."\n"
			end
		end
		prerror(str)
	end
	set_finalizer( function(err,stk)
			if err and type(err)~="userdata" then 
			--if err and err~=lanes.cancel_error then 
				prerror("PMIDI: midi_thread finalizer after error: "..tostring(err))
				prerror("PMIDI: finalizer stack table:")
				--prstak(stk)
			elseif type(err)=="userdata" then 
			--elseif err==lanes.cancel_error then 
				print("PMIDI: midi_thread finalizer after cancel")
				--print("tipo",type(err))
			else
				print("PMIDI: midi_thread finalizer ok")
			end
			print("PMIDI: midi_thread finalizer beguin")
			lanes.timer(midilinda, "miditimer", 0 ) --reset
			midilinda:receive (0, "miditimer" ) --clear last
			print("PMIDI: midi_thread closing devices")
			for i,v in ipairs( midiout) do
				v.stream:close()
			end
			for i,v in ipairs( midiin) do
				v.stream:close()
			end
			print("PMIDI: midi_thread closed devices")
		end)
	set_error_reporting("extended")
	set_debug_threadname("midi_thread")
	print("PMIDI: Opening midi devices")
	local MIDIdev=pmidi.GetMidiDevicesByName()
	for name,use in pairs(inp) do
		if use then
			if MIDIdev.inp[name]==nil then error("PMIDI: There is no input device :"..name,0) end
			local mdin,err=pmidi.OpenInput(MIDIdev.inp[name].devID)
			if not mdin then 
				print("PMIDI: "..tostring(err)) 
			else 
				midiin[#midiin+1]={stream=mdin,port=MIDIdev.inp[name].devID}
				print("PMIDI: midiin: ", #midiin, " opened:",name) 
			end
		end
	end
	for name,use in pairs(out) do
		if use then
			if MIDIdev.out[name]==nil then error("There is no output device :"..name,0) end
			local mdin,err=pmidi.OpenOutput(MIDIdev.out[name].devID)
			if not mdin then 
				print("PMIDI: "..tostring(err)) 
			else 
				midi_out_opened=true
				midiout[#midiout+1]={stream=mdin,port=MIDIdev.out[name].devID}
				print("PMIDI: midiout: ",#midiout," opened:",name) 
			end
		end
	end
	print("PMIDI: Starting midi-loop ...")
	if #midiin > 0 or midi_out_opened then
		lanes.timer( midilinda, "miditimer", 0.01, 0) --0.01 )
		while(true) do
			local key,val= midilinda:receive( "miditimer","midiWriteShort","exit_midi_thread" )
			
			--if key=="miditimer" and #midiin > 0 then
			if key=="miditimer" then
				lanes.timer( midilinda, "miditimer", 0.01, 0)
				--print(key,val)
				local ev,err
				for i,v in ipairs(midiin) do
					while true do
						ev,err=v.stream:read()
						if not ev then break end
						--print("sending to _midiEventCb")
						ev.inPort=i
						callbacklinda:send("_midiEventCb",ev)
					end
					if ev==nil then
						print("PMIDI: "..tostring(err))
					end
				end
			elseif key=="midiWriteShort"  and midi_out_opened then
				--print(key,val)
				local outPort = val.outPort or 1
				local erro=midiout[outPort].stream:writeShort(val)
				if erro then
					prerror("PMIDI: "..tostring(erro))
				else
					--print("envio")
					--prtable(val)
				end
			elseif key=="exit_midi_thread"  then
				midilinda:send("exit_midi_thread_done",1)
				--print(key,val)
				break
			end
		end
	end
	print("PMIDI: midi_thread exit")
end
--]]
---[[
function M.gen(inp,out,thelanes,callbacklinda,midilin,globals)
	globals.lanes=thelanes
	--midilinda=thelanes.linda()
	assert(midilin,"must provide a linda for sending")
	midilinda=midilin
	globals.midilinda=midilin
	assert(callbacklinda,"must provide a linda callbak")
	globals.callbacklinda=callbacklinda
	local generator=thelanes.gen("*",--"base,math,os,package,string,table",
		{
		required={"pmidi"},
		globals=globals,
		priority=0},
		pmidi.midi_thread)
		--print("generado")
		return generator(inp,out)
end

--]]	
--return M	


		
