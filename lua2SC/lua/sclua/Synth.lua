local funcs = require("sclua.funcs")

local Synth_metatable = {}
Synth_metatable.__index = Synth_metatable


function Synth_metatable:__newindex(key, value)
	self.server:sendMsg('/n_set', self.nodeID, key, value)
end

function Synth_metatable:set(args)
	self.server:sendMsg('/n_set', self.nodeID, unpack(parseArgsX(args)) )
end

function Synth_metatable:setn(args)
	self.server:sendMsg('/n_setn', self.nodeID, unpack(args))
end

function Synth_metatable:above(aSynth)
	self.server:sendMsg('/n_before', self.nodeID, aSynth.nodeID )
end

function Synth_metatable:below(aSynth)
	self.server:sendMsg('/n_after', self.nodeID, aSynth.nodeID )
end

function Synth_metatable:moveToHead(aNode)
	self.server:sendMsg('/g_head', aNode.nodeID, self.nodeID )
end

function Synth_metatable:moveToTail(aNode)
	self.server:sendMsg('/g_tail', aNode.nodeID, self.nodeID )
end

function Synth_metatable:free()
	self.server:sendMsg('/n_free', self.nodeID )
end

function Synth_metatable:run(arg)
	self.server:sendMsg('/n_run', self.nodeID, arg)
end

function Synth_metatable:getNodeID()
	return self.nodeID
end

function Synth_metatable:map(args)
	self.server:sendMsg('/n_map', self.nodeID, unpack(parseArgsX(args,true)) )
end

function Synth_metatable:mapn(args) -- mapping from control bus
	self.server:sendMsg('/n_mapn', self.nodeID, unpack(args) )
end

function Synth_metatable:mapa(args) -- mapping from audio bus
	local msg = {}
	for k,v in pairs(args) do
		msg[#msg+1] = k
		msg[#msg+1] = {"int32",v}
	end
	self.server:sendMsg('/n_mapa', self.nodeID, unpack(msg) )
end

function Synth_metatable:after(defName, args)
	return self.server.Synth(defName, args, self, 3)
end

function Synth_metatable:before(defName, args)
	return self.server.Synth(defName, args, self, 2)
end

function Synth_metatable:getn(index, count, action)
	if action then
		OSCFunc.newfilter("/n_setn",self.nodeID,function(msg2)
			--prtable(msg2)
			local t = {}
			for i=4,#msg2[2] do
				t[#t+1] = msg2[2][i]
			end
			action(t)
		end,true)
	end
	ThreadServerSend{"/s_getn",{self.nodeID,index,count or 1}}
end

function Synth_metatable.gui(syn,updatetime)

	local notisink = {params=syn.args,node=syn.nodeID}
	function notisink:notify(control)
		--print("notisssssssssssssss",control.name,control.parameter,control:val())
		local on = {"/n_set", {self.node, control.parameter, {"float",control:val()}}}
		--prtable(on)
		sendBundle(on)
	end
--[[
	print"syngui doingjjjj"
	local igui = InstrumentsGUI(syn.name,false,parent,notisink.params,notisink)
	local tgui = igui.gui
	print"syngui done"
---]]

---[[
	--local panelInstOuter=addPanel{type="vbox",name="instrument",parent=parent}
	local panelParamfx=addPanel{type="hbox",parent=panelInstOuter,name=syn.name}
	local tgui = openSynthdefGuiA(syn.name,panelParamfx,notisink.params,notisink,true,false)
	print"syngui done"

	if updatetime then tgui.update(updatetime, syn.group.nodeID, syn.nodeID) end
--]]
	return tgui
end

-- support garbage collection:
function Synth_metatable:__gc() 
	self:free() 
end

return Synth_metatable
