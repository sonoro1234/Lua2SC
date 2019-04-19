--- gui classes
--gui types
GUITypes = {onOffButton=0, kickButton=1, transientLed=2, stickLed=3, knob=4, hSlider=5, vSlider=6, label=7, menu=8, xypad=9, text=10, vuMeter=11}

wxGUITypes = {[0]="toggle","button","none", "none","knob","hslider", "vslider", "label", "combo", "none", "text", "vumeter","funcgraph","funcgraph2","funcgraph3"}

--list of all controls by tag
local guiControlTable = {}
local guiPanelTable = {}
--callbacks from gui

function _valueChangedCb(tag, value, str)
   --print("_valueChangedCb",tag," ", value," ", str)
    v = guiControlTable[tag]
	assert(v,"Invalid tag in _valueChangedCb: "..tag)
	
	v.value=v.Gui2Value(value,v)
	
    --if v.FormatLabel then
	if guiControlTable[tag].typex=="button" then
		--
	elseif str then
		v:setLabel(str)
	elseif not v.clabel then
		v:setLabel(v.FormatLabel(v.value,v))
	end
	--end
    if v.callback then
        v.callback(v.value, str,v)
    end 
	v:donotify()  
end


---------------------------------------------------------
GUIconstructor={isGUIcontrol = true}
function GUIconstructor:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end
function GUIconstructor:donotify()
	if self.notify then
		for _,v2 in ipairs(self.notify) do
			v2:notify(self)
		end
	end
end
function GUIconstructor.FormatLabel(value,self)
	return tostring(value)
end
function GUIconstructor:setLabel(str)
	--self.label=str
	guiSetLabel(self.tag,str)
end
---[[
--facility for gettin index of a menu
function GUIconstructor:getmenuindex(str)
	assert(self.typex=="combo","called menuval on not menu control")
	local index=-1
	for i,v in ipairs(self.menu) do
		if str==v then index=i-1; break; end
	end
	if index==-1 then print("Error: menu value not found:",str); return -1 end
	return index
end
function GUIconstructor:menuval(str,docallbak)
	local index=self:getmenuindex(str)
	self:val(index,docallbak)
	return index
end
--]]
function GUIconstructor:val(val,docallback)
	--print("GUIconstructor:val",val)
	if val~=nil then
		self:guiSetScaledValue(val,docallback)
		--self:donotify()
		self.value=val
	else
		if self.typex=="combo" then
			local str=self.menu[self.value+1]
			return self.value,str
		else
			return self.value
		end
	end
end

--return the value of a control, rescaling if necessary
--[[ not used
function GUIconstructor:guiGetScaledValue()
	local str
	if self.type==GUITypes.menu then
			str=self.menu[self.value+1]
	end
     return self.value,str
end
--]]
--from value in the gui to value
function GUIconstructor.Gui2Value(value,self)
	local ret
    if self.min and self.max then
        ret=value*(self.max-self.min)+self.min
    else
        ret=value
    end
	return ret
end
--from value to value in the gui
function GUIconstructor.Value2Gui(value,self)
    if self.min and self.max then
		return (value-self.min)/(self.max-self.min)
	else
		return value
	end
end

--set the value of control, rescaling if necessaryu
function GUIconstructor:guiSetScaledValue(value,docallback)
	--print("guiSetScaledValue ",value)
	if docallback ==  nil then docallback=true end
	self.value=value
  
	--scale the value
	local realValue = self.Value2Gui(value,self)
	
	--update the control itself
	guiSetValue(self.tag, realValue)
	
	if self.label and type(value)=="number" or type(value)=="string" then
	if self.typex=="combo" then
		self:setLabel(self.menu[value+1])
	else
		self:setLabel(self.FormatLabel(value,self))
	end
	end
	--igual se quita
	if self.callback and docallback then
		if self.typex=="combo" then
			--print("es menu \n")
			self.callback(value,self.menu[value+1],self)
		else
			self.callback(value,nil,self)
		end
	end
end
--------------------------------------------------------
function GUIIDGenerator(ini)
	local index=ini or -1
	return function(step)
		step = step or 1
		index=index + step
		return index
	end
end
GetTag=GUIIDGenerator(0)	
GetTagPanel=GUIIDGenerator(0)
GetTagWindow=GUIIDGenerator(0)
function doAddControl(constructor)
	if constructor.clabel then constructor.label = constructor.clabel end
	guiAddControl(constructor)
	
	if constructor.value then
		if constructor.typex=="combo" then
			--constructor:guiSetScaledValue(constructor.label,true)
		else
			constructor:guiSetScaledValue(constructor.value,true)
		end
	end
	if constructor.clabel then  constructor:setLabel(constructor.clabel) end
	
end

function addControl(constructor)
	--defaults
	--constructor.value = constructor.value or 0
	--dont use the same constructor table twice
    for i,v in pairs(guiControlTable) do
			assert(v~=constructor)
    end
	--TODO: only use typex
	constructor=GUIconstructor:new(constructor)
	if not constructor.typex then
		constructor.typex=wxGUITypes[constructor.type]
	end
	constructor.tag = GetTag()
	guiControlTable[constructor.tag] = constructor
		
	--do it now if it's already open
	--if windowOpen==true then	
	doAddControl(constructor)
	--end	        	
	return constructor
end

function doAddPanel(constructor)
	guiAddPanel(constructor)
end

function addPanel(constructor)
	constructor.tag = GetTagPanel()
	guiPanelTable[constructor.tag] = constructor
	doAddPanel(constructor)       	
	return constructor.tag
end
function deletePanel(tag)
	guiDeletePanel(tag)
end
function emptyPanel(tag)
	guiEmptyPanel(tag)
end

function deleteControl(const)
	return closeControl(const)
end

function closeControl(const)
	if not const.tag then 
	--error("control ya cerrado") 
	return 0 
	end  --probably on closeCb
	
	local res=guiDeleteControl(const.tag)
	guiControlTable[const.tag]=nil
	const.tag=nil
	return res
end

function addWindow(win)
	win.tag = GetTagWindow()
	guiAddWindow(win)
	return win.tag
end

function addWindowAV(win)
	win.tag = GetTagWindow()
	guiAddWindowAV(win)
	return win.tag
end

function Window(title, x, y, w, h)
	local win = addWindow{x=x,y=y,w=w,h=h}
	local panel=addPanel{window=win,type="hbox"}
	local glcanvas=addControl{window=win,panel=panel,typex="glcanvas",
	DrawCb = function(self) 
		local mx = self.mx or 0
		local my = self.my or 0
		--thread_print(mx,my)
		gl.ClearColor(self.r or 0, self.g or 0, mx/self.width, 0)
		gl.Clear(gl.COLOR_BUFFER_BIT)
		gl.Begin('TRIANGLES')
		gl.Vertex( 0,  my/self.height, 0)
		gl.Vertex(-0.75, -0.75, 0)
		gl.Vertex( 0.75, -0.75, 0)
		gl.End()

	end,
	mouseLD = function(x,y,Ob) 
		Ob.mx=x;Ob.my = y 
		--thread_print(x,y)
	end}
end
function Slider(name,min,max,val,func)
	local min = min or 0
	local max = max or 1
	local name = name or ""
	local newcontrol = {panel=curr_panel,value =val or min,min=min,max=max, typex="vslider",label=0,name=name,
			callback = function(value,str,c) 
					c:setLabel(string.format("%.2f",value),0)
					func(value)
			end}
	return addControl(newcontrol)
end

function Button(name,func)
	local newcontrol = {panel=curr_panel,value =0, typex="button",clabel=name,name=name,
	callback = function(value,str,c) 
					--c:setLabel(string.format("%.2f",value),0)
					func(value)
	end}
	return addControl(newcontrol)
end

function Toggle(name,func)
	local newcontrol = {panel=curr_panel,value =0, typex="toggle",clabel=name,name=name,
	callback = function(value,str,c) 
					--c:setLabel(string.format("%.2f",value),0)
					func(value)
	end}
	return addControl(newcontrol)
end

function PlotBus(bus,secs,when,rate)
	rate = rate or 2
	local sampspersec = rate==2 and 44100 or 44100/64
	local nsamples = math.floor(secs*sampspersec) 
	local window = addWindow{w=350,h=370,label="bus"..tostring(bus)}
	--local panel = addPanel{}
	local grafic = addControl{window=window, typex="funcgraph2",width=300,height=300,expand=true}

	local sclua = require"sclua.Server"
	local s = sclua.Server()
	local buff = s.Buffer()

	buff:alloc(nsamples,1)
	local msg = receiveBundle()
	--prtable(msg)
	local bufwr = rate==2 and "bufferwriter" or "bufferwriter_k"
	
	local syn2 = s.Synth(bufwr,{busin=bus,bufnum=buff.bufnum,run=0},nil,1)--tail

	OSCFunc.newfilter("/n_end",syn2.nodeID,function(msg) 
		print"bufwriter ended"
		buff:getn(0,nsamples,function(vals)
			local t = {}
			for i=1,#vals do
				t[#t+1] = {(i-1)/sampspersec,vals[i]}
			end
			grafic:val(t)
			guiUpdate()
		end)
	end)
	if not when then
		syn2:set{run=1,trig=1}
	else
		s:makeBundle(when,function() syn2:set{run=1,trig=1} end)
	end
end

gui = {default_control = "knob"}
