--- miditoosc
require"sc.midi"
--require"sc.playerssc"
--require"sc.synthdefsc"
table.insert(initCbCallbacks,function() SynthDef("ClickSynth",{out=0,freq=200,gate=1},function()
	local env = EnvGen.kr{Env.asr(0,1,0),gate,doneAction=2}
	local sig = env*SinOsc.ar(freq)
	Out.ar(out,sig:dup())
end):store() end)
function Click(beats,transpose)
	local beats = beats or 4
	local transpose = transpose or 0
	click = OscEP{inst="ClickSynth"}
	click:Bind{note=LOOP{72,LS{60}:rep(beats-1)} + transpose,delta=1,dur=0.03,amp=0.1}
end
function MIDIRecord(instgui,ini,endr)
	assert(ini,"ini not set in MIDIRecord")
	assert(endr,"endr not set in MIDIRecord")
	local function midiSeq(t)
		if #t ==0 then
			print"nothing recorded"
			return
		end
		table.sort(t,function(a,b) return a.ppq < b.ppq end)
		local played = {}
		local inievent = {ppq=ini,event={note = REST,amp = 0,dur = 0}}
		local seq = {inievent}
		for k,v in ipairs(t) do
			if v.event.type == midi.noteOn then
				--assert(played[v.event.note]==nil,"on without off")
				local e = {ppq=v.ppq,event={note = v.event.note,amp = v.event.velocity/127}}
				played[v.event.note] = e
				local eprev = seq[#seq] 
				if eprev then eprev.event.delta = e.ppq - eprev.ppq end
				seq[#seq+1] = e
			elseif played[v.event.note] then --off
				--assert(played[v.event.note],"off without on")
				local e = played[v.event.note]
				played[v.event.note] = nil
				e.event.dur = v.ppq - e.ppq
			end
		end
		-- last delta
		local laste = seq[#seq]
		laste.event.delta = endr - laste.ppq --laste.event.dur
		prtable(seq)
		
		
		local function LSdump(seq,key,str)
			str[#str +1] = "\t"..key.." = LS{"
			for i,v in ipairs(seq) do
				str[#str +1] = tostring(v.event[key]) .. ","
			end
			str[#str +1] = "},\n"
		end
		
		local function LSmake(seq,key)
			local rr = {}
			for i,v in ipairs(seq) do
				rr[#rr +1] = v.event[key]
			end
			return rr
		end
		
		local str = {"{\n"}
		LSdump(seq,"note",str)
		LSdump(seq,"amp",str)
		LSdump(seq,"delta",str)
		LSdump(seq,"dur",str)
		str[#str +1] = "}"
		
		print(t[1].ppq,table.concat(str))
		
		local seqC = {}
		seqC.note = LS(LSmake(seq,"note"))
		seqC.amp = LS(LSmake(seq,"amp"))
		seqC.delta = LS(LSmake(seq,"delta"))
		seqC.dur = LS(LSmake(seq,"dur"))
		--prtable(seqC)
		return seqC, t[1].ppq
	end
	local parent = addPanel{type="vbox",parent=instgui.panelInst}
	local recpanel = addPanel{type="vbox",parent=parent}
	local butrec = addControl{value=0, typex="toggle",clabel="record",panel=recpanel,
			callback=function(value,str,c) 
					if value==1 then
						instgui.record = true
						print("record on")
					else
						instgui.record = false
						print("record of")
					end
			end}
	local butdump = addControl{ typex="button",clabel="dump",panel=recpanel,
			callback=function() 
				print(tb2st(instgui.recorded));
				midiSeq(instgui.recorded) 
			end}
	local rec = {}
	rec.start = function() butrec:val(1,true) end
	rec.stop = function() butrec:val(0,true) end
	rec.dump = function() return midiSeq(instgui.recorded) end
	--return rec
	local recorder = rec
	recordlooper=ActionEP{}:Bind{
		actions = LS{
			ACTION(ini,recorder.start),
			ACTION(endr,function()
					local seq,ppq=recorder.dump()
					if seq then
						recordrepeater:Bind(seq)
						recordrepeater.MUSPOS= ini --ppq
						recordrepeater:Reset()
					end
				end),
			GOTO(endr,ini),
			--ACTION(320*5,print,"Estoy aqui compas 30")
		}
	}
	recordrepeater = OscEP{inst = instgui.inst, sends={0.2}}
end
--GUI for EventPlayer
function EPinstGUI(player,parent)
	--copy params from player
	--[[
	local params = {}
	--prtable(player.lista.stlist)
	for k,v in pairs(player.lista.stlist) do
		if type(v)=="number" then
			params[k]=v
		elseif  v.isConstantStream  then
			params[k]=v.value
		end
	end
	prtable("params en EPinstGUI",params)
	--]]
	--------------------------
	local notysink ={}
	function notysink:RegisterControl(control)
		player:RegisterControl(control)
	end
	function notysink:notify(control)
		--prtable(control)
		--prtable(player)
		player:notify(control)
		--does not work for array values
		local actualvalue = player.params[control.variable[1]]
		--prtable("actualvalue",actualvalue)
		if type(actualvalue)=="table" then actualvalue = {actualvalue} end
		local bb ={[control.variable[1]] = FS(function() return actualvalue end,-1)}
		player:MergeBind(bb)
		
	end
	local igui=InstrumentsGUI(player.inst,false,parent,params,notysink)
	--[[
	local parnames={}
	for k,_ in pairs(igui.params) do
		parnames[#parnames +1]=k
	end
	
	local bb={[parnames]=FS(function(pa)
							local res={}
							for i,name in ipairs(parnames) do
								res[i]=pa[name]
							end
							--prtable(res)
							return res 
						end,igui.params,nil,-1)}
	--]]
	--return mergeTable(player.lista.stlist,bb)
	--return player:MergeBind(bb)
end

function InstrumentsGUI(synname,chooser,parent,params,notified)
	--if chooser==nil then chooser=true end
	
	local self={inst=synname or "default",params=params or {},oscfree=true}
	--self.notify = function(ss,control)
	--	print("noti:")
	--	prtable("noti:",control.variable)
	--end
	local menu_instruments={}
	local function fillmenu_instruments(name)
		--coje la parte de la cadena antes del primer .
		table.insert(menu_instruments,name:match("(.-)%."))
	end	
	function self:notify(control)
		prtable("InstGUINotify",control.variable)
	end
	dodir(fillmenu_instruments,SynthDefs_path,"*.scsyndef")
	self.panelInstOuter=addPanel{type="vbox",name="instrument",parent=parent}
	local panelbuttons=addPanel{type="hbox",parent=self.panelInstOuter}
	self.panelInst=addPanel{type="hbox",parent=self.panelInstOuter}
	addControl{
				panel=panelbuttons,
				value=1,
				type=GUITypes.onOffButton,
				FormatLabel=function() return "Release" end,
				callback=function(val,str,c) 
					self.oscfree =(val==1)
					--if self.free_queue
				end
				}
	addControl{panel=panelbuttons,type=GUITypes.kickButton,label="Clipboard",
		callback=function(val)
			if  val==1 then
				local preset={inst=self.inst}
				preset.params=self.params
				TextToClipBoard(serializeTable("preset",preset))
			end
		end}
	
	addControl{panel=panelbuttons,type=GUITypes.kickButton,label="Defaults",
		callback=function(val)
			if  val==1 then
				if self.inst then
					--closeSynthdefGui(self.panelParamfx)
					deletePanel(self.panelParamfx)
					self.panelParamfx=addPanel{type="hbox",parent=self.panelInst,name=self.inst}
					openSynthdefGuiA(self.inst,self.panelParamfx,self.params,notified or self,false,true)
			end
		end
	end}
	addControl{panel=panelbuttons,type=GUITypes.kickButton,  label="Save",
		callback=function(val)
			if  val==1 then
				local file = openFileSelector(_presetsDir,"prSC",true)
				if file~="" then
					--local preset = {inst = select(2,self.menuinst:val())}
					local preset = {inst= self.inst}
					preset.params=self.params
					if not file:find("%.prSC$") then file=file..".prSC" end
					fich=io.open(file,"w")
					fich:write("local ")
					fich:write(serializeTable("preset",preset))
					fich:write("return preset ")
					fich:close()
				end
			end
		end}
	addControl{panel=panelbuttons,type=GUITypes.kickButton,  label="Load",
		callback=function(val)
			if  val==1 then
				local file = openFileSelector(_presetsDir,"prSC")
				if file~="" then
					fich=io.open(file,"r")
					local str=fich:read("*a")
					fich:close()
					local preset=assert(loadstring(str))()
					--local index=instgui.menuinst:getmenuindex(preset.inst)
					
					--self.params=preset.params
					mergeTable(self.params,preset.params)
					
					prtable(preset.params)
					prtable(self.params)
					--self.menuinst:menuval(preset.inst)
					self.inst=preset.inst
					--closeSynthdefGui(self.panelParamfx)
					deletePanel(self.panelParamfx)
					self.panelParamfx=addPanel{type="hbox",parent=self.panelInst,name=self.inst}
					openSynthdefGuiA(self.inst,self.panelParamfx,self.params,notified or self,true,true)
					if self.menuinst then
						--self.menuinst:val(index)--,false)
						self.menuinst:menuval(self.inst,false)
					end
			
				end
			end
		end}
	if chooser then
		local panel=addPanel{type="hbox",name="select",parent=self.panelInst}
		self.menuinst = addControl{
				panel=panel,
				value=0,
				type=GUITypes.menu,
				menu=menu_instruments,
				callback=function(val,str,c)
						--print("callback menuinst")
						--assert(false)
						self.inst=str
						--closeSynthdefGui(self.panelParamfx)
						deletePanel(self.panelParamfx)
						self.panelParamfx=addPanel{type="hbox",parent=self.panelInst,name=self.inst}
						openSynthdefGuiA(str,self.panelParamfx,self.params,notified or self,true,true)
					end
			}
		self.panelParamfx=addPanel{type="hbox",parent=self.panelInst,name=synname}
		self.menuinst:menuval(self.inst)
		guiUpdate()
	else
		--self.panelParamfx=addPanel{type="vbox",parent=self.panelInst,name=synname}
		--closeSynthdefGui(self.panelParamfx)
		--deletePanel(self.panelParamfx)
		self.panelParamfx=addPanel{type="hbox",parent=self.panelInst,name=self.inst}
		openSynthdefGuiA(self.inst,self.panelParamfx,self.params,notified or self,true,true)
		
	end
	return self
end

-------------------------------------------------------------
--midiin to out osc
MidiToOsc={
	nodesMidi2Osc={},
	free_queue = {},
	vars={}
	}
	
function Midi2OSCEnvio(ch,fx,lev)
	lev =lev or 0
	MidiToOsc.vars[ch].envios = MidiToOsc.vars[ch].envios or {}
	local node=GetNode() --lo coloca en la tail
	table.insert(MidiToOsc.vars[ch].envios,{node=node,level=lev})
	msg ={"/s_new", {"envio", node, 1, MidiToOsc.vars[ch].group,"busin",{"int32",MidiToOsc.vars[ch].channel.busin},"busout",{"int32",fx.channel.busin},"level",{"float",lev}}}
	--prtable(msg)
	sendBundle(msg)
end
function iguiSendLevel(self,i,lev)
	self.envios[i].level = lev
	local msg = {"/n_set",{self.envios[i].node,"level",{"float",lev}}}
	sendBundle(msg) --,lanes.now_secs())
	if self.envios[i].control then
		self.envios[i].control:guiSetScaledValue(lev,false)
	end
end
function iguiSendParam(self,parnam)
	--assert(self.node," sin nodo")
	for _,node in pairs(self.nodes) do
		local msg = {"/n_set",{node,parnam}}
		if type(self.params[parnam])=="table" then
			table.insert(msg[2],{"["})
			for i,val in ipairs(self.params[parnam]) do
				table.insert(msg[2],{"float",val})
			end
			table.insert(msg[2],{"]"})
		else
			table.insert(msg[2],{"float",self.params[parnam]})
		end
		sendBundle(msg)
	end
end
function iguinotify(self,control)
	--print("scEventPlayer:notify")
	local var=self.params
	--control variable is {name} for simple params
	-- or {name,index} for params with several indexes
	for i=1,#control.variable-1 do
		--if indexed take in var the param[name] of this guicontrol
		var=var[control.variable[i]]
	end
	-- param[name] or param[name][index]
	var[control.variable[#control.variable]]=control:val()
	self:SendParam(control.variable[1])
end 
function MidiToOsc.AddChannel(ch,igui,sends,on_maker,inserts,mono)
	local ch = ch or 0
	local igui = igui or {inst="default",params={},oscfree=true}
	MidiToOsc.vars[ch]=igui 
	--function igui:notify(control)
	--	prtable("InstGUINotifyMidiToOsc",control.variable)
	--end
	igui.SendParam = iguiSendParam
	igui.SendLevel = iguiSendLevel
	igui.notify = iguinotify
	MidiToOsc.nodesMidi2Osc[ch] = {}
	igui.nodes = MidiToOsc.nodesMidi2Osc[ch]
	MidiToOsc.free_queue[ch] = {}
	igui.free_queue = MidiToOsc.free_queue[ch]
	igui.inserts=inserts or {}
	
	MidiToOsc.vars[ch].on_maker = on_maker
	MidiToOsc.vars[ch].recorded = {}
	addMidiFilter{callback=MidiToOsc.midi2osc,channel=ch}
	MidiToOsc.vars[ch].sends = sends or {}
	MidiToOsc.vars[ch].mono = mono
	MidiToOsc.vars[ch].keylist = {}
	return igui
end
function MidiToOsc.Init(ch)
	print"Miditooscinit"
	MidiToOsc.vars[ch].group = GetNode()
	local msg={NEW_GROUP,{MidiToOsc.vars[ch].group,0,0}}
	sendBundle(msg)
	MidiToOsc.vars[ch].instr_group = GetNode()
	msg={"/p_new",{MidiToOsc.vars[ch].instr_group,0,MidiToOsc.vars[ch].group}}
	sendBundle(msg)
	--prtable(MidiToOsc.vars[ch].channel)
	MidiToOsc.vars[ch].channel=CHN(MidiToOsc.vars[ch].channel or {},MidiToOsc.vars[ch])
	-----inserts
	local self = MidiToOsc.vars[ch]
	if self.inserts then
		self.insertsgroup = GetNode()
		--local msg={NEW_GROUP,{self.insertsgroup,1,self.group}}
		local msg={"/g_new",{self.insertsgroup,3,self.instr_group}}

		sendBundle(msg) --,lanes.now_secs())
	end
	
	self._inserts={}
	for i,insert in ipairs(self.inserts) do
		print"miditoosc creo ins"
		self._inserts[i]=INS(insert,self,true)
	end
	------------------------------------
	for i2,v2 in ipairs(Effects) do
		print"miditoosc creo send"

		Midi2OSCEnvio(ch,v2,MidiToOsc.vars[ch].sends[i2] or 0)
	end
end
table.insert(initCbCallbacks,function()
	for ch=0,15 do
		if MidiToOsc.vars[ch] then
			MidiToOsc.Init(ch)
		end
	end
end)
onFrameCallbacks = onFrameCallbacks or {}
table.insert(onFrameCallbacks,function()
	for ch=0,15 do
		if MidiToOsc.vars[ch] then
			MidiToOsc.vars[ch].channel:Play()
			for i,insert in ipairs(MidiToOsc.vars[ch]._inserts) do
				insert:Play()
			end
		end
	end
end)
function MidiToOsc.midi2osc(midiEvent) 
	--prtable(midiEvent)
	local ch = midiEvent.channel
	local thisMidiOsc = MidiToOsc.vars[ch]
	local mono = thisMidiOsc.mono
	if thisMidiOsc.record then
		local ppqpos = curHostTime.oldppqPos - SERVER_CLOCK_LATENCY * theMetro.bps
		--print("recordmidi xxxxx",#thisMidiOsc.recorded,ppqpos)
		thisMidiOsc.recorded[#thisMidiOsc.recorded +1] = {ppq=ppqpos,event=midiEvent}
	end
	if midiEvent.type==midi.noteOn then
		local nodo,snew 
		if mono then
			snew = not thisMidiOsc.node
			nodo = thisMidiOsc.node or GetNode()
			thisMidiOsc.node = nodo
			--thisMidiOsc.keylist = thisMidiOsc.keylist or {}
			table.insert(thisMidiOsc.keylist,midiEvent.byte2)
		else
			nodo = MidiToOsc.nodesMidi2Osc[midiEvent.channel][midiEvent.byte2]
			if not nodo then
				nodo = GetNode()
				snew = true
			end
		end
		local freq = midi2freq(midiEvent.byte2)
		local amp = midiEvent.byte3/127.0
		--thisMidiOsc.node = nodo
		--print(amp)
		local on
		if snew then
			if thisMidiOsc.on_maker then
				on ={"/s_new", {thisMidiOsc.inst, nodo, 0, thisMidiOsc.instr_group}}
				thisMidiOsc:on_maker(freq,amp)
			else
				on ={"/s_new", {thisMidiOsc.inst, nodo, 0, thisMidiOsc.instr_group, "freq", {"float" ,freq},"amp",{"float",amp}}}
			end
			MidiToOsc.nodesMidi2Osc[midiEvent.channel][midiEvent.byte2]=nodo
			--OSCFunc.newfilter("/n_end",nodo,function(noty)
			--	MidiToOsc.nodesMidi2Osc[midiEvent.channel][midiEvent.byte2]=nil
			--end,true)
		else
			if thisMidiOsc.on_maker then
				on ={"/n_set", {nodo}}
				thisMidiOsc:on_maker(freq,amp)
			else
				on ={"/n_set", { nodo, "freq", {"float" ,freq},"amp",{"float",amp}}}
			end
			MidiToOsc.free_queue[ch][nodo] = nil
		end
		ValsToOsc(on[2],thisMidiOsc.params)
		table.insert(on[2],"out")
		table.insert(on[2],{"int32",thisMidiOsc.channel.busin})
		sendBundle(on)
		
		--if not MidiToOsc.nodesMidi2Osc[midiEvent.channel][midiEvent.byte2] then
			--sendBundle(on) --,lanes.now_secs())
			--MidiToOsc.nodesMidi2Osc[midiEvent.channel][midiEvent.byte2]=nodo
		--end

    elseif midiEvent.type==midi.noteOff then
		
		if mono then
			--local nodo = MidiToOsc.nodesMidi2Osc[midiEvent.channel][midiEvent.byte2]
			local nodo = thisMidiOsc.node
			assert(nodo)
			MidiToOsc.nodesMidi2Osc[midiEvent.channel][midiEvent.byte2] = nil
			for i,v in ipairs(thisMidiOsc.keylist) do
				if v == midiEvent.byte2 then
					table.remove(thisMidiOsc.keylist, i)
					break
				end
			end
			--set freq from last key
			local lastnote = thisMidiOsc.keylist[#thisMidiOsc.keylist]
			if lastnote then
				local freq = midi2freq(lastnote)
				on ={"/n_set", { nodo, "freq", {"float" ,freq}}}
				sendBundle(on)
			else
				local off = {"/n_set",{nodo,"gate",{"float",0}}}
				sendBundle(off) --,lanes.now_secs())
				thisMidiOsc.node = nil
			end
		
		elseif thisMidiOsc.oscfree then
			local nodo = MidiToOsc.nodesMidi2Osc[midiEvent.channel][midiEvent.byte2]
			MidiToOsc.nodesMidi2Osc[midiEvent.channel][midiEvent.byte2] = nil
			if nodo then
				local off = {"/n_set",{nodo,"gate",{"float",0}}}
				sendBundle(off)

			else
				print"off without on"
			end
		else --poly dontfree
			local nodo = MidiToOsc.nodesMidi2Osc[midiEvent.channel][midiEvent.byte2]
			if nodo then MidiToOsc.free_queue[ch][nodo] = true end
		end
	else
		--sendMidi(midiEvent)
    end
end

