
--gui types
GUITypes = {onOffButton=0, kickButton=1, transientLed=2, stickLed=3, knob=4, hSlider=5, vSlider=6, label=7, menu=8, xypad=9, text=10, vuMeter=11}

wxGUITypes = {[0]="toggle","button","none", "none","knob","hslider", "vslider", "label", "combo", "none", "text", "vumeter","funcgraph","funcgraph2"}

--list of all controls by tag
guiControlTable = {}
guiPanelTable = {}
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
	
	if self.typex=="combo" then
		self:setLabel(self.menu[value+1])
	else
		self:setLabel(self.FormatLabel(value,self))
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
function IDGenerator(ini)
	local index=ini or -1
	return function(step)
		step = step or 1
		index=index + step
		return index
	end
end
GetTag=IDGenerator(0)	
GetTagPanel=IDGenerator(0)
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
	--dont use the same constructor table twice
    for i,v in pairs(guiControlTable) do
			assert(v~=constructor)
    end
	
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

