require("sc.playerssc")
require("sc.synthdefSCgui")


faderExcessDb=3
faderBaseLog=(1/0.5)^(1/18) -- 1.05946
function db2faderPos(val,excess)
	excess = excess or faderExcessDb
	return clip(faderBaseLog ^ (val - excess),0,1)
end
function faderPos2db(pos,excess)
	excess = excess or faderExcessDb
	return excess + math.log(pos)/math.log(faderBaseLog)
end
----------------------------------------------------
_GUIAUTOMATE=true
GUIControls={}

function vumet(parent)
	parent = parent or panelMixer
	local panelVUMETER=addPanel{type="flexi",cols=2,parent=parent}
	for i=1,2 do
		local newcontrol = {
						name="vu "..i,
						panel=panelVUMETER,
						value={0,0},
						typex="vumeter",
						vumeter="vumeter1",
						busin=i-1,
						label=0.00,
						halfdb=18,
						node = GetNode()
					}
		addControl(newcontrol)
	end
end

function _FreqScope(panel,scopesynth,busin)
	local scopesynth = scopesynth or "freqScopeLstLocal" 
	local panel=panel or panelMasterV
	local busin=busin or 0
	addControl{value={0,0}, typex="freqscope",width=512,height=200,miny=-1,maxy=1,busin=busin,node=GetNode(),scope=scopesynth,scopebufnum = GetBuffNum(),bins=512,rate=4,panel=panel}
end
function FreqScopeSt(...)
	local args = {...}
	table.insert(initCbCallbacks,function()_FreqScope(nil,"freqScopeLmnLocal",0)end)
	table.insert(initCbCallbacks,function()_FreqScope(nil,"freqScopeLmnLocal",1)end)
end
function FreqScope(...)
	local args = {...}
	table.insert(initCbCallbacks,function()_FreqScope(unpack(args))end)
end

function _Scope(panel,scopesynth)
	local scopesynth = scopesynth or "scope_mn" 
	local panel=panel or panelMasterV
	local busin=busin or 0
	addControl{value={0,0}, typex="scope",width=512,height=200,miny=-1,maxy=1,busin=busin,node=GetNode(),scope=scopesynth,scopebufnum = GetBuffNum(),bins=441 * 2,rate=4,panel=panel}
end

function Scope(...)
	local args = {...}
	table.insert(initCbCallbacks,function()_Scope(unpack(args))end)
end
function MIDIButton(value)
	local value = value or 40
	local notetext=addControl{value=value, typex="text",name="midinote",label=0}
	addControl{value=0, typex="toggle",label=0,
			callback=function(value,str,c) 
					if value==1 then
						print(tonumber(notetext:val()))
						_midiEventCb(noteOn(tonumber(notetext:val()), 127, 0, 0))
					else
						_midiEventCb(noteOff(tonumber(notetext:val()),0, 0))
					end
			end}
end
function SliderControl(name,min,max,val)
	local min = min or 0
	local max = max or 1
	local name = name or ""
	local newcontrol = {value =val or min,min=min,max=max, typex="vslider",label=0,name=name,
			callback=function(value,str,c) 
					c:setLabel(string.format("%.2f",value),0)
			end}
	local elcontrol= addControl(newcontrol)
	return FS(function() return elcontrol.value end,nil,nil,-1)
end
--GUIOPENED=false
function opengui()
	print("opengui\n")
	--if GUIOPENED then return end
	-- ppqcounter=addControl({type=GUITypes.label,label="0.0.0"})
	-- table.insert(onFrameCallbacks,function()
		-- if ppqcounter.tag then
			-- guiSetLabel(ppqcounter.tag,string.format("beat:%3u",math.floor(curHostTime.ppqPos)))
		-- end
	-- end)
	--restoreBut=addControl{x=50,y=5,type=GUITypes.onOffButton,label="Restore controls",
--	value=globalPersistence.restoreBut,function(value,str,c)
--		if value==1 then restoregui() end
--	end}
	--local newcontrol
	----------------------------------------------
	local function pan2gui(val)
		return linearmap(1,-1,1,0,val)
	end
	local function gui2pan(val)
		return linearmap(1,0,1,-1,val)
	end
	local panelMixer=addPanel{type="hbox",parent=MainPanel}
	GUIPlayers= GUIPlayers or OSCPlayers
	if #GUIPlayers >0 then
		--paneles
		-- for i=1, #GUIPlayers do
			-- addPanel{tag=i,type="vbox"}
		-- end
		--local panelMixer=addPanel{type="hbox",cols=#GUIPlayers,parent=MainPanel}
		local panelcanales=addPanel{type="flexi",cols=#GUIPlayers,parent=panelMixer}
		--onoff={}
		for i,player in ipairs(GUIPlayers) do 
			if player.isOscEP then
				local newcontrol = {
					panel=panelcanales, --panelcanales[i],
					value=player.channel.params.unmute or 1,
					variable={"unmute"},
					type=GUITypes.onOffButton,
					label=player.name or i,
					FormatLabel=function() return player.name or i end,
					callback=function(value,str,c) 
							print("callback unmute ",player.channel.name," valor ",value)
							player.channel.params.unmute = value;
							player.channel:SendParam("unmute") 
						end
						--,notify={player.channel}
				}
				GUIControls[#GUIControls +1] = addControl(newcontrol)
				player.channel:RegisterControl(GUIControls[#GUIControls])
			end
		end
		--volumenes={}

		for i,player in ipairs(GUIPlayers) do
			if player.isOscEP then
				local newcontrol = {
					name="vol.",
					panel=panelcanales, --i,
					value=db2faderPos(amp2db(player.channel.params.level or 1)),
					variable={"level"},
					type=GUITypes.vSlider,
					label=string.format("%.2f",amp2db(player.channel.params.level or 1)),
					Gui2Value=function(val) return db2amp(faderPos2db(val)) end,
					Value2Gui=function(val) return db2faderPos(amp2db(val)) end,
					FormatLabel=function(val) return string.format("%.2f",amp2db(val)) end,
					callback=function(value,str,c) 
							--print("callback volumen ",player.channel.name," valor ",value," tag ",c.tag)
							--player.channel.params.level = value
							--player.channel:SendParam("level")
						end
						,notify={player.channel}
				}
                local cont=addControl(newcontrol)
				GUIControls[#GUIControls +1] = cont
				player.channel:RegisterControl(cont)
			end
		end
		--pans={}
		
		for i,player in ipairs(GUIPlayers) do
			if player.isOscEP then
				local newcontrol = {
					name="pan.",
					panel=panelcanales, --i,
					value=player.channel.params.pan or 0,
					variable={"pan"},
					--width = 40,
					--height = 30,
					type=GUITypes.knob, --GUITypes.hSlider,
					label=string.format("%.2f",player.channel.params.pan or 0),
					Gui2Value=function(val) return gui2pan(val) end,
					Value2Gui=function(val) return pan2gui(val) end,
					FormatLabel=function(val) return string.format("%.2f",val) end,
					callback=function(value,str,c) 
							--print("callback volumen ",player.channel.name," valor ",value," tag ",c.tag)
							--player.channel.params.level = value
							--player.channel:SendParam("level")
						end
						,notify={player.channel}
				}
                local cont=addControl(newcontrol)
				GUIControls[#GUIControls +1] = cont
				player.channel:RegisterControl(cont)
			end
		end

		--fx={}
		--[[
		panelfxS=addPanel{type="hbox",name="Effects",parent=panelMixer}
		for i,fx in ipairs(Effects) do
			panelfx=addPanel{type="hbox",name=fx.name,parent=panelfxS}
			panelVolfx=addPanel{type="vbox",parent=panelfx}
			local newcontrol = {
				name="fxvolume",
				panel=panelVolfx,
				value=db2faderPos(amp2db(fx.channel.params.level or 1)),
				variable={"level"},
				type=GUITypes.vSlider,
				label=string.format("%.2f",amp2db(fx.channel.params.level or 1)),
				Gui2Value=function(val) return db2amp(faderPos2db(val)) end,
				Value2Gui=function(val) return db2faderPos(amp2db(val)) end,
                FormatLabel=function(val) return string.format("%.2f",amp2db(val)) end,
				callback=function(value,str,c)
						--fx.channel.params.level =value
						--fx.channel:SendParam("level")   
					end
				,notify={fx.channel}
			}
			local cont=addControl(newcontrol)
			GUIControls[#GUIControls +1] = cont
			fx.channel:RegisterControl(cont)
			
			panelParamfx=addPanel{type="flexi",cols=3,parent=panelfx}
			openSynthdefGui(fx,panelParamfx,true,false,3)
		end
		--]]

		--sends={}
		for i2,fx in ipairs(Effects) do
		for i,player in ipairs(GUIPlayers) do
			--sends[i]={}
			if player.isOscEP then
				--for i2,fx in ipairs(Effects) do
					local newcontrol = {
						name=fx.name,
						panel=panelcanales, --i,
						--value=db2faderPos(amp2db(GUIPlayers[i].envios[i2].level)),
						value=GUIPlayers[i].envios[i2].level,
						variable={"level"},
						type=GUITypes.knob,--GUITypes.hSlider ,--GUITypes.knob,
						--label=string.format("%.2f",amp2db(GUIPlayers[i].envios[i2].level)),
                        Gui2Value=function(val) return db2amp(faderPos2db(val)) end,
                        Value2Gui=function(val) return db2faderPos(amp2db(val)) end,
                        FormatLabel=function(val) return string.format("%.2f",amp2db(val)) end,
						callback=function(value,str,c)
							--print("callback send",value)
							--error("bla bla")
                                player.envios[i2].level=value
                                player:SendLevel(i2,value) 
                            end,
						--notify={player.envios[i2]}
					}
					local cont = addControl(newcontrol)
					GUIControls[#GUIControls +1] = cont
					player.envios[i2].control = cont
				--end
			end
		end
		end
		--inserts={}
		for i,player in ipairs(GUIPlayers) do
			panelInserts=addPanel{type="vbox",parent=panelcanales}
			if player.isOscEP then
				for i2,insert in ipairs(player._inserts) do
					panelInsertsOne=addPanel{type="collapse",name=insert.name,parent=panelInserts}
					print("insert:",insert.name)
					openSynthdefGui(insert,panelInsertsOne,true,false,1)
				end
			end
		end	
	end
	--fx={}
	---[[
	panelfxS=addPanel{type="hbox",name="Effects",parent=panelMixer}
	for i,fx in ipairs(Effects) do
		panelfx=addPanel{type="hbox",name=fx.name,parent=panelfxS}
		panelVolfx=addPanel{type="vbox",parent=panelfx}
		local newcontrol = {
			name="vol.",
			panel=panelVolfx,
			value=db2faderPos(amp2db(fx.channel.params.level or 1)),
			variable={"level"},
			type=GUITypes.vSlider,
			label=string.format("%.2f",amp2db(fx.channel.params.level or 1)),
			Gui2Value=function(val) return db2amp(faderPos2db(val)) end,
			Value2Gui=function(val) return db2faderPos(amp2db(val)) end,
            FormatLabel=function(val) return string.format("%.2f",amp2db(val)) end,
			callback=function(value,str,c)
					--fx.channel.params.level =value
					--fx.channel:SendParam("level")   
				end
			,notify={fx.channel}
		}
		local cont=addControl(newcontrol)
		GUIControls[#GUIControls +1] = cont
		fx.channel:RegisterControl(cont)
		
		panelParamfx=addPanel{type="flexi",cols=3,parent=panelfx}
		openSynthdefGui(fx,panelParamfx,true,false,3)
	end
	--]]
	-------master
	panelMasterV=addPanel{type="vbox",name="Master",parent=panelMixer}
	panelMaster=addPanel{type="hbox",parent=panelMasterV}
	--prtable(Master)
	local newcontrol = {
				name="vol.",
				panel=panelMaster, --i,
				value=db2faderPos(amp2db(Master.params.level or 1),6),
				variable={"level"},
				type=GUITypes.vSlider,
				label=string.format("%.2f",amp2db(Master.params.level or 1)),
				Gui2Value=function(val) return db2amp(faderPos2db(val,6)) end,
				Value2Gui=function(val) return db2faderPos(amp2db(val),6) end,
				FormatLabel=function(val) return string.format("%.2f",amp2db(val)) end,
				callback=function(value,str,c) 
						--print("callback volumen ",player.channel.name," valor ",value," tag ",c.tag)
						--player.channel.params.level = value
						--player.channel:SendParam("level")
					end
				,notify={Master}
			}
            local cont=addControl(newcontrol)
			GUIControls[#GUIControls +1] = cont
			Master:RegisterControl(cont)
			-- master inserts
			
			for _,insert in ipairs(Master._inserts) do
				panelInsertMaster = addPanel{type = "hbox",name = insert.name,parent = panelMaster}
				--panelInsertMaster2=addPanel{type="flexi",name=insert.name,parent=panelInsertMaster}
				print("Master insert:",insert.name)
				openSynthdefGui(insert,panelInsertMaster,true,false,3)
			end

	vumet(panelMaster)
	---FreqScopes
	for i,player in ipairs(GUIPlayers) do
		if player.freqscope then
			local panelFs = addPanel{type="collapse",name=player.name,parent=panelMasterV}
			_FreqScope(panelFs,nil,player.channel.busin)
		end
	end
	--MidiToOssc
	print("Miditooscgui beguin")
	for i=0,15 do
		if MidiToOsc and MidiToOsc.vars[i] then
			print("Miditooscgui",i)
			--volumen
			local player = MidiToOsc.vars[i]
			local panel = addPanel{type="vbox",parent=player.panelInst}  -- guiPanelTable[player.panelInst].parent

			local newcontrol = {
				name="vol.",
				panel=panel,
				value=db2faderPos(amp2db(player.channel.params.level or 1)),
				variable={"level"},
				type=GUITypes.vSlider,
				label=string.format("%.2f",amp2db(player.channel.params.level or 1)),
				Gui2Value=function(val) return db2amp(faderPos2db(val)) end,
				Value2Gui=function(val) return db2faderPos(amp2db(val)) end,
				FormatLabel=function(val) return string.format("%.2f",amp2db(val)) end,
				callback=function(value,str,c) 
						--print("callback volumen ",player.channel.name," valor ",value," tag ",c.tag)
						--player.channel.params.level = value
						--player.channel:SendParam("level")
					end
					,notify={player.channel}
			}
            local cont=addControl(newcontrol)
			GUIControls[#GUIControls +1] = cont
			player.channel:RegisterControl(cont)
			--pans
			local newcontrol = {
					name="pan.",
					panel=panel, 
					value=player.channel.params.pan or 0,
					variable={"pan"},
					type=GUITypes.knob, --GUITypes.hSlider,
					label=string.format("%.2f",player.channel.params.pan or 0),
					Gui2Value=function(val) return gui2pan(val) end,
					Value2Gui=function(val) return pan2gui(val) end,
					FormatLabel=function(val) return string.format("%.2f",val) end,
					callback=function(value,str,c) 
							--print("callback volumen ",player.channel.name," valor ",value," tag ",c.tag)
							--player.channel.params.level = value
							--player.channel:SendParam("level")
						end
						,notify={player.channel}
				}
                local cont=addControl(newcontrol)
				GUIControls[#GUIControls +1] = cont
				player.channel:RegisterControl(cont)
			--sends
			for i2,fx in ipairs(Effects) do
					local newcontrol = {
						name=fx.name,
						panel=panel, 
						--value=db2faderPos(amp2db(GUIPlayers[i].envios[i2].level)),
						value=player.envios[i2].level,
						variable={"level"},
						type=GUITypes.knob,--GUITypes.hSlider ,--GUITypes.knob,
						--label=string.format("%.2f",amp2db(GUIPlayers[i].envios[i2].level)),
                        Gui2Value=function(val) return db2amp(faderPos2db(val)) end,
                        Value2Gui=function(val) return db2faderPos(amp2db(val)) end,
                        FormatLabel=function(val) return string.format("%.2f",amp2db(val)) end,
						callback=function(value,str,c)
							--print("callback send",value)
							--error("bla bla")
                                player.envios[i2].level=value
                                player:SendLevel(i2,value) 
                            end,
						--notify={player.envios[i2]}
					}
					local cont = addControl(newcontrol)
					GUIControls[#GUIControls +1] = cont
					player.envios[i2].control = cont
				end
			--inserts={}

			panelInserts=addPanel{type="vbox",parent=panel}
			--if player.isOscEP then
			for i2,insert in ipairs(player._inserts) do
				panelInsertsOne=addPanel{type="collapse",name=insert.name,parent=panelInserts}
				print("insert:",insert.name)
				openSynthdefGui(insert,panelInsertsOne,true,false,1)
			end
			--end

		------
		end
	end
	--------------
	guiUpdate()
end
table.insert(initCbCallbacks,opengui)

