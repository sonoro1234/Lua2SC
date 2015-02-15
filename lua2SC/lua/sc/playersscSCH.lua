require( "sc.playersppqSCH")
require"sc.sc_comm"

NEW_GROUP = "/g_new" --"/p_new" -- "/g_new"
--------------------------------------------------------
OsceventQueue = {}
OsceventQueueDirty = false
function OsceventCompare(a, b)
    return b.time>a.time       
end 
function scheduleOscEvent(event,time)
    table.insert(OsceventQueue,{time=time,event=event}) 
	OsceventQueueDirty = true
end
function doOscSchedule(window)
	--print("doOscSchedule")
    --ensure the table is in order
	if OsceventQueueDirty then
		table.sort(OsceventQueue, OsceventCompare)
		OsceventQueueDirty = false
	end

    --send all events in this window
    local  continue = 0
    repeat        
        continue = 0
        if OsceventQueue[1] and OsceventQueue[1].time<window then
			
			if printOSC then
				print(tb2st(OsceventQueue[1]))
			end
			
			sendBundle(OsceventQueue[1].event, theMetro:ppq2time(OsceventQueue[1].time))
            table.remove(OsceventQueue, 1)  
            continue = 1
        end              
    until continue==0    
           
end
function ValsToOsc(msg,lista)
	for name,value in pairs(lista) do
		table.insert(msg,name)
		if type(value) ~= "table" then
			table.insert(msg,{"float",value})
		else
			table.insert(msg,{"["})
			for i,val in ipairs(value) do
				table.insert(msg,{"float",val})
			end
			table.insert(msg,{"]"})
		end
	end
	return msg
end
-----------------------------------------------------
-- reads lista={name=value,name2=value...} into osc msg
function getMsgLista(msg,lista) 
	ValsToOsc(msg[2],lista)
	return msg
end
function getMsgValue(msg,name,value)
	ValsToOsc(msg[2],{[name]=value})
	return msg
end

----------------------------------------------------------------
scEventPlayer=EventPlayer:new{inst="default",name=nil,dontfree=true,autom_dur=0} --automatecount=-1,automateskip=1
function scEventPlayer:Init(setnode)
	self.oldparams={}
	if setnode then
		self.node = GetNode()
		msg ={"/s_new", {self.inst, self.node, self.headtail, self.group,"busin",{"int32",self.busin},"busout",{"int32",self.busout}}}
		--prtable(msg)
		sendBundle(msg)
		--sendBundle(msg,lanes.now_secs())
	end
	return EventPlayer.Init(self)
end
function scEventPlayer:UsePreset(preset)
	local pre=LoadPreset(preset)
	assert(self.inst == pre.inst)
	local preN,preV=NamesAndValues(pre.params)
	--return mergeTable(self.lista.stlist,{[preN]=ConstSt(preV)})
	return self:MergeBind{[preN] = ConstSt(preV)}
end
function scEventPlayer:Release()
	if self.node == nil then return end
	local msg = {"/n_set",{self.node,"gate",{"float",0}}}
	--udp:send(toOSC(msg))
	sendBundle(msg,lanes.now_secs())
	self.node = nil
	self.havenode = false
end
function scEventPlayer:StopSound()
	self:FreeNode()
end
function scEventPlayer:FreeNode()
	--print("Freenode",self.name,self.node)
	if self.poly and self.NodeQueue then
		for i,v in ipairs(self.NodeQueue) do
			local msg = {"/n_set",{v,"gate",{"float",0}}}
			sendBundle(msg,lanes.now_secs())
			msg = {"/n_free",{v}}
			sendBundle(msg,lanes.now_secs())
		end
		return
	end
	if self.node == nil then return end
	local msg = {"/n_set",{self.node,"gate",{"float",0}}}
	sendBundle(msg,lanes.now_secs())
	msg = {"/n_free",{self.node}}
	sendBundle(msg,lanes.now_secs())
	self.node = nil
end
function scEventPlayer:playOneEvent(lista,beatTime, beatLen)
	--print("scEventPlayer:playEvent ",self.name ," self.node ",self.node,"self.group",self.group,beatTime)
	--prtable(self)
	local dur=beatLen
	lista.dur=nil
	--local inst=lista.inst
	lista.inst=nil
	--play osc-----------------
	if self.node == nil then
		self.node = GetNode()
		msg ={"/s_new", {self.inst, self.node, self.headtail, self.group,"busin",{"int32",self.busin},"busout",{"int32",self.busout}}}
	else
		msg ={"/n_set", {self.node}}
	end	
	-- print("antes")
	-- prtable(self.oldparams)
	-- prtable(lista)
	for k,v in pairs(lista) do
		if self.oldparams[k]~=v then
			self.params[k]=v
			self.oldparams[k]=v
		else
			self.params[k]=nil
		end
		-- self.params[k]=v
	end
	-- print("despues")
	-- prtable(self.oldparams)
	-- prtable(self.params)
	--if #self.params > 0 then
		getMsgLista(msg,self.params)

		--scheduleOscEvent(msg)
		--dont scheudule order is important for same delta
		--udp:send(toOSC(msg))
		--sendBundle(msg,theMetro.timestamp + (beatTime - theMetro.oldppqPos) / theMetro.bps)
		sendBundle(msg,theMetro:ppq2time(beatTime))
	--end
	-- the gui updates every half beat
	if _GUIAUTOMATE then
		self.autom_dur=self.autom_dur+ dur
		if self.autom_dur >= 0.5 then
			self.autom_dur=0
			self:sendToRegisteredControls()
		end
	end
	
	if self.dontfree==false then
		local off = {"/n_set",{self.node,"gate",{"float",0}}}
		scheduleOscEvent(off,beatTime + beatLen)
		self.node = nil	
	end
	
end
function scEventPlayer:SendParam(parnam)
	--assert(self.node," sin nodo")
	if not self.node then return end
	--local msg ={"/n_set", { self.node,parnam,{"float",self.params[parnam]}}}
	local msg ={"/n_set", { self.node}}
	msg = getMsgValue(msg,parnam,self.params[parnam])
	--udp:send(toOSC(msg))
	sendBundle(msg,lanes.now_secs())
end
function scEventPlayer:SendParams()
	--if not self.node then print("scEventPlayer:SendParams ",self.name, " sin nodo"); return end
	assert(self.node," sin nodo")
	local msg ={"/n_set", { self.node}}
	msg = getMsgLista(msg,self.params)
	--udp:send(toOSC(msg))
	sendBundle(msg,lanes.now_secs())
	self:sendToRegisteredControls()
end
function scEventPlayer:RegisterControl(control)
	--print(self.name," RegisterControl ",control.variable[1]," tag ",control.tag)
	self.RegControls=self.RegControls or {}
	local contvarname = control.variable[1]
	if control.variable[2] then
		self.RegControls[contvarname] = self.RegControls[contvarname] or {}
		self.RegControls[contvarname][control.variable[2]] = control
	else
		self.RegControls[contvarname]=control
	end
	
end
function scEventPlayer:sendToRegisteredControls()
	if not self.RegControls then return end
	--prtable("self.RegControls",self.RegControls,"self.params",self.params)
	for name,value in pairs(self.params) do
		local control = self.RegControls[name]
		if  control then
			if control.isGUIcontrol then
				control:guiSetScaledValue(value)--,false) --do loop on callback'??
			else --table of controls
				for i,v in ipairs(control) do
					v:guiSetScaledValue(value[i])--,false)
				end
			end
		end
	end
end
-- for being notified of guicontrol changes
--gets params from control.variable and sends to sc
function scEventPlayer:notify(control)
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
	--self:SendParams()
	self:SendParam(control.variable[1])
end 

-----------------------Insert----------------------------
Insert=scEventPlayer:new{name=nil,dontfree=true}
function INS(insert,oscplayer,doinit)
	local ins= Insert:new{name=insert[1],inst=insert[1],oscplayer=oscplayer,params={}}
	print("inserting ",ins.inst,ins.name)
	insert[2] = insert[2] or {}
	insert[2].dur=insert[2].dur or math.huge
	--insert[2].inst=insert[2].inst or ins.name
	ins.dontfree=insert.dontfree
	ins:Bind(PS(insert[2]))
	-------------------------
	ins.headtail=1
	ins.group=oscplayer.insertsgroup
	ins.busin=oscplayer.channel.busin
	ins.busout=ins.busin
	---------------------------
	ins:Init(doinit)
	return ins
end

------------------------Effect--------------------------------
Effect=scEventPlayer:new{name=nil,dontfree=true}
function FX(name,level,pan,params2)
	level = level or 1
	pan = pan or 0
	params2 = params2 or {}
	local eff= Effect:new({name=name,inst=name,params={},channel={level=level,pan=pan}})
	
	params2.dur=params2.dur or math.huge
	--params2.inst= eff.name

	
	-------------------------
	--chn.node = GetNode()
	eff.headtail=0
	eff.group=GetNode()
	eff.busin=nil--GetBus(2)
	eff.busout=nil--0
	---------------------------
	eff:Bind(params2)
	--eff:Init()
	return eff
end
function Effect:Init()
    print("Effect:Init ",self.name)	
	
	
	--local msg={NEW_GROUP,{self.group,0,0}}
	local msg={NEW_GROUP,{self.group,2,Master.group}}
	sendBundle(msg)
	
	--sendBundle(msg,lanes.now_secs())
	self.channel=CHN(self.channel,self)
	
	self.busin=self.channel.busin
	self.busout=self.busin
	scEventPlayer.Init(self)
	--prtable(self)
	--error("break error")
end
function Effect:PlayBAK()
	self.channel:Play()
	--for i,insert in ipairs(self._inserts) do
--		insert:Play()
--	end
	EventPlayer.Play(self)
end

------------------------------OscEventPlayer--------------
OscEventPlayer = scEventPlayer:new({isOscEP=true,dontfree=false})
function OscEP(t)
	local player = OscEventPlayer:new(t)
	player.params={}
	OSCPlayers[#OSCPlayers + 1]= player
	return player
end

-----------------------Master---------------------------------
Master=scEventPlayer:new{name="Master",dontfree=true,busout=0,busin=GetBus(2),group=GetNode(),inst="channel",headtail=1,params={}}
function MASTER(t)
	Master.params2 = t
end
function MASTER_INIT1()
	Master.params2 = Master.params2 or {}
	Master.params2.dur = Master.params2.dur or math.huge
	Master.params2.inst = "channel"
	Master.params2.level = Master.params2.level or 1
	Master.params2.unmute =	Master.params2.unmute or 1
	Master.params2.pan = Master.params2.pan or 0
	--prtable(Master)
	Master:Bind(Master.params2)
	Master.inserts = Master.inserts or {}
	Master._inserts = Master._inserts or {}
	print("xxxxxxxxxxxxxxxxxxxxxxxmaster")
	local msg={NEW_GROUP,{Master.group,1,0}}
	sendBundle(msg)
	--sendBundle(msg,lanes.now_secs())
	return Master:Init(true)
end
function MASTER_INIT2()
	Master.inserts=Master.inserts or {}
	for i,insert in ipairs(Master.inserts) do
		Master._inserts[i]=MASTER_INS(insert)
	end
	
end
function MASTER_INS(insert)
	local ins= scEventPlayer:new{name=insert[1],inst=insert[1],params={},dontfree=true}
	
	insert[2] = insert[2] or {}
	insert[2].dur=insert[2].dur or math.huge
	--insert[2].inst=insert[2].inst or ins.name
	--ins.dontfree=insert.dontfree
	ins:Bind(PS(insert[2]))
	------------------------
	--Master.inserts[#Master.inserts +1] = insert
	Master._inserts[#Master._inserts +1] = ins
	if Master.insertsgroup == nil then
		Master.insertsgroup = GetNode()
		local msg={NEW_GROUP,{Master.insertsgroup,0,Master.group}}
		sendBundle(msg)
		--sendBundle(msg,lanes.now_secs())
	end
	-------------------------
	ins.headtail=1
	ins.group=Master.insertsgroup
	ins.busin=Master.busin
	ins.busout=ins.busin
	---------------------------
	ins:Init()
	return ins
end
function Master:Play()
	--println("OscEventPlayer:Play",self.name)
	--self.channel:Play()
	for i,insert in ipairs(self._inserts) do
		--println("OscEventPlayer:Play insert",insert.name)
		insert:Play()
	end
	EventPlayer.Play(self)
end
--MASTER_INIT1()
-----------------------Channel----------------------------
Channel=scEventPlayer:new{name=nil,dontfree=true}
function CHN(channel,oscplayer,busout)
	busout = busout or Master.busin
	--prtable(oscplayer)
	local chn= Channel:new{name="CHN"..(oscplayer.name or ""),oscplayer=oscplayer,params={}}
	--prtable(channel)
	channel.dur=channel.dur or math.huge
	channel.inst=channel.inst or "channel"
	channel.level=channel.level or 1
	channel.unmute=channel.unmute or 1
	channel.pan=channel.pan or 0.0

	chn.inst=channel.inst
	--print("xxxxxxxxxxxxxxxchn bind")
	chn:Bind(PS(channel))
	-------------------------
	--chn.node = GetNode()
	chn.headtail=1
	chn.group=oscplayer.group
	chn.busin=GetBus(2)
	chn.busout=busout
	---------------------------
	
	--prtable(chn)
	chn:Init(true)
	return chn
end
function OscEventPlayer:Init()
	EventPlayer.Init(self)
	print("OscEventPlayer:Init",self.name)
	--prtable(self)
	if self.group ~= nil then return end
	self.group = GetNode()
	local msg={NEW_GROUP,{self.group,0,0}}
	sendBundle(msg)
	--sendBundle(msg,lanes.now_secs())
	
	self.instr_group = GetNode()
	msg={"/p_new",{self.instr_group,0,self.group}}
	sendBundle(msg)
	--sendBundle(msg,lanes.now_secs())
	--prtable(self.channel)
	self.channel=CHN(self.channel or {},self)
	-----inserts
	if self.inserts then
		self.insertsgroup = GetNode()
		--local msg={NEW_GROUP,{self.insertsgroup,1,self.group}}
		local msg={"/g_new",{self.insertsgroup,3,self.instr_group}}
		sendBundle(msg)
		--sendBundle(msg,lanes.now_secs())
	end
	self.inserts=self.inserts or {}
	self._inserts={}
	for i,insert in ipairs(self.inserts) do
		self._inserts[i]=INS(insert,self)
	end
	self:MakeSends()
	---------------
	--EventPlayer.Init(self)
	--self.ppqPos=self.MUSPOS
--	self.prevppqPos=self.ppqPos
--	self:UpdatePos(0)
end

function OscEventPlayer:Send(fx,lev)
	lev =lev or 0
	self.envios = self.envios or {}
	node=GetNode() --lo coloca en la tail
	table.insert(self.envios,{node=node,level=lev})
	msg ={"/s_new", {"envio", node, 1, self.group,"busin",{"int32",self.channel.busin},"busout",{"int32",fx.channel.busin},"level",{"float",lev}}}
	--udp:send(toOSC(msg)) 
	sendBundle(msg,lanes.now_secs())
	return node
end
function OscEventPlayer:SendLevel(i,lev)
	self.envios[i].level = lev
	local msg = {"/n_set",{self.envios[i].node,"level",{"float",lev}}}
	sendBundle(msg,lanes.now_secs())
	if self.envios[i].control then
		self.envios[i].control:guiSetScaledValue(lev,false)
	end
end
function OscEventPlayer:MakeSends()

	for i2,v2 in ipairs(Effects) do
			self.sends = self.sends or {}
			self:Send(v2,self.sends[i2] or 0)
	end
end
function OscEventPlayer:SetSends()
	--self.channel:SendParams() --ya lo hago con notify
	if(self.envios) then
		for i,v in ipairs(self.envios) do
			msg ={"/n_set", {self.envios[i].node,"level",{"float",self.envios[i].level}}}
			sendBundle(msg,lanes.now_secs())
		end 
	end
end
function OscEventPlayer:FreeGroup()
	--udp:send(toOSC({"/g_freeAll",{self.group}}))
	--udp:send(toOSC({"/g_deepFree",{self.group}}))
	sendBundle({"/g_freeAll",{self.group}},lanes.now_secs())
	sendBundle({"/g_deepFree",{self.group}},lanes.now_secs())
end
function OscEventPlayer:Reset()
	EventPlayer.Reset(self)
	self:FreeNode()
end
--called once a frame
function OscEventPlayer:ccPlayBAK()
	local event
	if self.group and self.cclist then
	--if self.node then
		event ={"/n_set", {self.group}}
		for k,v in pairs(self.cclist) do
			local val=v:nextval()
			table.insert(event[2],k)
			table.insert(event[2],{"float",val})
		end
		--print(event)
		sendBundle(event)
	end
end
--[[
function OscEventPlayer:Play()
	--print("OscEventPlayer:Play",self.name)
--[=[
	self.channel:Play()
	for i,insert in ipairs(self._inserts) do
		--println("OscEventPlayer:Play insert",insert.name)
		insert:Play()
	end
--]=]
	EventPlayer.Play(self)
end
--]]
function OscEventPlayer:GetNode(beatTime)
	if self.poly then
		local node = GetNode()
		--print("addfilter",node)
		OSCFunc.newfilter("/n_end",node,function(noty) 
			--self.NodeList[node] = nil
			--print(noty[2][1],node)
			for i,v in ipairs(self.NodeQueue) do
				if v == node then
					--print("remove",node)
					table.remove(self.NodeQueue,i)
					break
				end
			end
		end,true)
		--self.NodeList = self.NodeList or {}
		--self.NodeList[node] = true
		self.NodeQueue = self.NodeQueue or {}
		table.insert(self.NodeQueue,node)
		--self.NodesCount = (self.NodesCount or 0) + 1
		if self.poly < #self.NodeQueue  then
			local nodeout = self.NodeQueue[1]
			local msg = {"/n_set",{nodeout,"gate",{"float",0}}}
			sendBundle(msg,theMetro:ppq2time(beatTime))
			--msg={"/n_free",{nodeout}}
			--sendBundle(msg,theMetro.timestamp + (beatTime - theMetro.oldppqPos) / theMetro.bps)
			--print("polyfree",self.NodeQueue[1])
			table.remove(self.NodeQueue,1)
		end
		return node
	else
		return GetNode()
	end
end
function OscEventPlayer:playOneEvent(listaO,beatTime, beatLen,delta) 

	--set defaults, get freq,escale,legato,inst
	local lista=listaO --deepcopy(listaO)
	self.curvals = lista
	--local inst
	--lista.dur=beatLen / theMetro.bps

	--eval funcs
	for k,v in pairs(lista) do
		if type(v)=="function" then
			lista[k]=v(self)
		end
	end

	--------------
	local escale = lista.escale or "ionian"
	
	--freq
	local freq
	if lista.freq then
		freq = lista.freq
	elseif lista.note then
		--freq = functabla(lista.note,midi2freq)
		freq = midi2freq(lista.note)
	elseif lista.degree then
		freq = midi2freq(getNote(lista.degree,escale))
		--freq = functabla(freq,midi2freq)
	end
	lista.note=nil;lista.degree=nil;lista.freq=freq
	--legato
	local legato
	if lista.legato then 
		beatLen = beatLen * lista.legato;legato=lista.legato;lista.legato=nil 
	end

	--inst = lista.inst or "default";
	local inst = lista.inst or self.inst
	lista.inst=nil
	
	lista.amp	= lista.amp or lista.velo;lista.velo=nil
	--lista.amp	= lista.amp or 0.5
	
	if IsREST(freq) then
		--self.havenode = false
		self:Release() 
		return  
	end
	if lista.detune then
		lista.freq=freq*lista.detune
		lista.detune=nil
	end
	--play osc-----------------
	--[[
	if self.mono == true then
		if self.node == nil then
		--if self.dontfree == false then
			self.node = GetNode()
			on ={"/s_new", {inst, self.node, 0, self.instr_group}}
		else
			on ={"/n_set", {self.node}}
		end
		
		if legato and legato < 1 then
			self.dontfree = false
		else
			self.dontfree = true
		end
	else
		self.node = GetNode()
		on ={"/s_new", {inst, self.node, 0, self.instr_group}}
	end
	--]]
	local dontfree = self.dontfree
	if self.mono then
		if self.havenode then
			lista.type = "n_set"
		end
		if legato and legato < 1 then
		--if beatLen < delta then
			dontfree = false
		else
			dontfree = true
		end
	elseif lista.type == "n_set" then
		dontfree = true
	end
	
	local on
	if lista.type == "n_set" and self.node then
		--if not self.node then print("n_set without node") return end
		on ={"/n_set", {self.node}}
	else
		if lista.type == "n_set" then prerror("n_set without node") end
		self.node = self:GetNode(beatTime)
		self.havenode = true
		on ={"/s_new", {inst, self.node, 0, self.instr_group}}
	end
	lista.type = nil
---[[
	-- get functions
	local listafunc = {}
	for k,v in pairs(lista) do
		--if type(v)=="function" then
		if type(v)=="table" and v.is_ctrl_mapper then
			listafunc[k]=v
			lista[k]=nil
		end
	end
	--
--]]
	lista.escale=nil --dont send escale
	getMsgLista(on,lista)
	lista.escale=escale

	table.insert(on[2],"out")
	table.insert(on[2],{"int32",self.channel.busin})
	
--	if freq then
--		table.insert(on[2],"freq")
--		table.insert(on[2],{"float",freq})
--	end
	sendBundle(on,theMetro:ppq2time(beatTime))
	--send functions
	for k,v in pairs(listafunc) do
		--v(k,self,beatTime,beatLen)
		v:verb(k,self,beatTime,beatLen)
	end
	---
	if _GUIAUTOMATE then
		self.autom_dur=self.autom_dur+ beatLen
		if self.autom_dur >= 0.5 then
			self.autom_dur=0
			self.params = lista
			self:sendToRegisteredControls()
		end
	end
	if dontfree == false then
			local off = {"/n_set",{self.node,"gate",{"float",0}}}
			scheduleOscEvent(off,beatTime + beatLen)
			--if self.mono then
			--	self.node = nil
			--end
			--if not self.monogate then
				--self.node = nil
			--end
			self.havenode = false
	end	
end
--------------------------------------Inicio
function FillSends(val)
	local res={}
	for i,v in ipairs(Effects) do
		res[i]={}
		for i2,v2 in ipairs(OSCPlayers) do
			res[i][i2]=val
			v2.sends = v2.sends or {}
			v2.sends[i] = val
		end
	end
	return res
end
function CrearEnvios()
	print("crear envios")
	----arreglar antiguos envios TODO quitar
	if Envios then
		for i,pl in ipairs(OSCPlayers) do
			pl.sends = pl.sends or {}
			for i2,envi in ipairs(Envios) do
				pl.sends[i2]=pl.sends[i2] or envi[i]
			end
		end
	end
	------------------------
	for i,v in ipairs(OSCPlayers) do
		v:MakeSends()
	end
end
OSCPlayers={}
Effects={}
function initOSCplayers()
	print("initOSCplayers")
	MASTER_INIT2()
	for i,v in ipairs(Effects) do
		--prtable(v)
		--v.name = v.name or v:findMyName()
		v:Init()
	end
	for i,v in ipairs(OSCPlayers) do
		--v.name = v.name or v:findMyName()
		v:Init()
	end
	--CrearEnvios()
end
function resetOSCplayers()
	print("resetOSCplayers")
	-- for i,v in ipairs(Effects) do
		-- v:FreeGroup()
	-- end
	for i,v in ipairs(OSCPlayers) do
		v:FreeGroup()
	end
	--CrearEnvios()
	--TODO liberar uno a uno
	--udp:send(toOSC({"/g_freeAll",{0}}))
	--udp:send(toOSC({"/g_deepFree",{0}}))
	udp:send(toOSC({"/g_dumpTree",{0,1}}))
	print("end_resetOSCplayers")
end
table.insert(initCbCallbacks,initOSCplayers)
table.insert(resetCbCallbacks,resetOSCplayers)
--[[
table.insert(onFrameCallbacks,function()
	Master:Play()
	for i,v in ipairs(Effects) do
		v:Play()
	end
	for i,v in ipairs(OSCPlayers) do
		v:Play()
	end
	doOscSchedule(curHostTime.ppqPos)
end)
--]]
------------
function copyplayer(player)
	local player2=deepcopy(player)
	OSCPlayers[#OSCPlayers+1]=player2
	return player2
end
