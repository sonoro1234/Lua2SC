-- ------------------------------wxKnob------------------------------------------
function TableToPen(penTable)
    local c = wx.wxColour(unpack(penTable.colour))
    local pen = wx.wxPen(c, penTable.width, penTable.style)
    c:delete()
    return pen
end

function wxKnob(parent,name,label,id,radio)
	id = id or wx.wxID_ANY
	
	local mx=0
	local my=0
	local radio=radio or 15
	local diam=2*radio
	local label_height=12
	local name_height=14
	local extra_w=5
	local x1=radio+extra_w
	local y1=radio+name_height
	local penwidth=1

	local gamma=math.pi/4 -- 0 value in knob
	local alpha=gamma
	
	
	local wxwindow = wx.wxControl(parent,id,wx.wxDefaultPosition,wx.wxDefaultSize,wx.wxNO_BORDER)
	wxwindow:SetMinSize(wx.wxSize((radio+extra_w)*2,radio*2+label_height+name_height))
	wxwindow:SetMaxSize(wx.wxSize((radio+extra_w)*2,radio*2+label_height+name_height))
	wxwindow:SetBackgroundColour(parent:GetBackgroundColour())
	wxwindow:SetLabel(label)
	
	local KnobClass={value=0,window=wx.wxNULL,customclass="KnobClass"}
	
	function KnobClass.SetValue(_,val)
		KnobClass.value=val
		alpha=(math.pi-gamma)*val*2+gamma
		wxwindow:Refresh()
	end
	function KnobClass.SetLabel(_,val)
		wxwindow:SetLabel(val)
		wxwindow:Refresh()
	end
	

	local function Draw(dc)
		--local pen = TableToPen({ colour = { 0, 0, 0 }, width = penwidth, style = wx.wxSOLID })
		--dc:SetPen(pen)
		--pen:delete()
		dc:SetPen(wx.wxBLACK_PEN)
		
		dc:DrawEllipse(extra_w, name_height, diam,diam);
		
		x2=-math.sin(alpha)*radio+x1
		y2=math.cos(alpha)*radio+y1
		dc:DrawLine(x1,y1, x2, y2);
		dc:SetFont(wx.wxNORMAL_FONT)
		dc:DrawLabel(wxwindow:GetLabel(),wx.wxRect(0, diam+name_height, diam+extra_w*2, label_height), wx.wxALIGN_CENTER)
		dc:DrawLabel(name,wx.wxRect(0, 0, diam+extra_w*2-3, name_height))
		--dc:DrawText(name,0,0)
		dc:SetPen(wx.wxNullPen)
	end

	local function CalcValue()
		alpha=math.atan2(mx-x1,y1-my) + math.pi
		alpha=math.max(gamma,math.min(2*math.pi-gamma,alpha))
		KnobClass.value=0.5*(alpha-gamma)/(math.pi-gamma)
		scriptlinda:send("_valueChangedCb",{id,KnobClass.value,str})
	end

	wxwindow:Connect(wx.wxEVT_PAINT, function(event)
			local dc = wx.wxPaintDC(wxwindow)
			Draw(dc)
			dc:delete() 
		end)
    wxwindow:Connect(wx.wxEVT_ERASE_BACKGROUND, function(event) 
			event:Skip() 
		end) 
    wxwindow:Connect(wx.wxEVT_LEFT_DOWN,function (event)
			mx = event:GetX()
			my = event:GetY()
			CalcValue()
			wxwindow:Refresh()
			if (not wxwindow:HasCapture()) then wxwindow:CaptureMouse() end
			event:Skip()
		end )
    wxwindow:Connect(wx.wxEVT_LEFT_UP,function (event)
			if wxwindow:HasCapture() then   
				mx = event:GetX()
				my = event:GetY()
				CalcValue()				
				wxwindow:ReleaseMouse()
				wxwindow:Refresh()
			end
			event:Skip()
		end)
    wxwindow:Connect(wx.wxEVT_MOTION,function (event)
			--frame:SetStatusText(string.format("MousePos %d, %d", event:GetX(), event:GetY()))
			if wxwindow:HasCapture() then
				if event:LeftIsDown() then
					mx = event:GetX()
					my = event:GetY() 
					CalcValue()
					-- draw directly on the panel, we'll draw on the bitmap in OnLeftUp
					-- local drawDC = wx.wxClientDC(wxwindow)
					-- Draw(drawDC)
					-- drawDC:delete()
					wxwindow:Refresh()
				else -- just in case we lost focus somehow
					wxwindow:ReleaseMouse()
				end
			end
			event:Skip()
		end)
	wxwindow:Connect(wx.wxEVT_SIZE,function (event)
			wxwindow:Refresh();
		end)
	KnobClass.window=wxwindow
	return KnobClass 
end
---------------------------wxVumeter
function amp2db(amp)
	return 20*math.log10(amp)
end
function setVumeter(vumet)
		--prtable(vumet)
		for i=1,2 do
			VUMETERS[i]:guiSetScaledValue({vumet[2+2*i],vumet[1+2*i]})
		end
	end
function wxVuMeter(parent,name,label,id,params)
	id = id or wx.wxID_ANY
	
	assert(params.node)
	assert(params.busin)
	local msg ={"/s_new", {params.vumeter, params.node, 1, 0,"rate",{"float",10},"lag",{"float",0},"id",id,"busin",params.busin}}
	SCSERVER:send(toOSC(msg))
	
	local height=params.height or 200
	local width= params.width or 10
	local label_height=12
	local name_height=14
	local extra_w=10
	local halfdb=params.halfdb or 18
	local penwidth=1
	
	local wxwindow = wx.wxControl(parent,id,wx.wxDefaultPosition,wx.wxDefaultSize,wx.wxNO_BORDER)
	wxwindow:SetMinSize(wx.wxSize(width+extra_w*2,height+label_height+name_height))
	wxwindow:SetMaxSize(wx.wxSize(width+extra_w*2,height+label_height+name_height))
	wxwindow:SetBackgroundColour(parent:GetBackgroundColour())
	wxwindow:SetLabel(label)
	
	local VuMeterClass={value={0,0},window=wx.wxNULL,customclass="VuMeterClass"}
	
	--faderExcessDb=3
	local faderBaseLog=(1/0.5)^(1/halfdb) -- 1.05946
	--function db2faderPos(val,ceroval)
		--return clip(faderBaseLog ^ (val - faderExcessDb),0,1)
	--end
	
	function VuMeterClass.SetValue(_,val)
		VuMeterClass.value={faderBaseLog^amp2db(val[1]),faderBaseLog^amp2db(val[2])}
		wxwindow:SetLabel(string.format("%.2f",val[2]))
		wxwindow:Refresh()
	end
	function VuMeterClass.SetLabel(_,val)
		wxwindow:SetLabel(val)
		wxwindow:Refresh(true,wx.wxRect(0,height+name_height,width+extra_w*2,label_height))
		--wxwindow:RefreshRect()
	end
	

	local function Draw(dc)
		--local pen = TableToPen({ colour = { 0, 0, 0 }, width = penwidth, style = wx.wxSOLID })
		--dc:SetPen(pen)
		--pen:delete()
		
		local alto=height*VuMeterClass.value[1]
		local alto2=height*VuMeterClass.value[2]
		dc:SetPen(wx.wxBLACK_PEN)
		dc:DrawRectangle(0, name_height, width+extra_w*2,height);
		dc:SetPen(wx.wxGREEN_PEN)
		dc:SetBrush(wx.wxGREEN_BRUSH)
		dc:DrawRectangle(extra_w, name_height+height-alto, width,alto);
		dc:SetPen(wx.wxRED_PEN)
		dc:SetBrush(wx.wxRED_BRUSH)
		dc:DrawRectangle(extra_w, name_height+height-alto2-2,width,2);
		
		dc:SetFont(wx.wxNORMAL_FONT)
		dc:DrawLabel(wxwindow:GetLabel(),wx.wxRect(0,height+name_height,width+extra_w*2,label_height), wx.wxALIGN_CENTER)
		dc:DrawText(name,0,0)
		
		dc:SetPen(wx.wxBLACK_PEN)
		for dbs=0,-46,-6 do
			--local dbs=amp2db(i)
			local alto=name_height+height-height*faderBaseLog^dbs
			dc:DrawLine(0,alto,width,alto)
			dc:DrawText(tostring(-dbs),0,alto)
		end
		dc:SetPen(wx.wxNullPen)
		dc:SetBrush(wx.wxNullBrush)

	end
	
	wxwindow:Connect(wx.wxEVT_PAINT, function(event)
			local dc = wx.wxPaintDC(wxwindow)
			Draw(dc)
			dc:delete() 
		end)
    wxwindow:Connect(wx.wxEVT_ERASE_BACKGROUND, function(event) 
			event:Skip() 
		end) 
    
	wxwindow:Connect(wx.wxEVT_SIZE,function (event)
			wxwindow:Refresh();
		end)
	VuMeterClass.window=wxwindow
	return VuMeterClass 
end
---------------------------wxFuncGraph2
function wxFuncGraph2(parent,name,label,id,co)
	id = id or wx.wxID_ANY
	local miny = co.miny or 0
	local maxy = co.maxy or 1
	local minx = co.minx or 0
	local maxx = co.maxx or 1
	local height=co.height or 150
	local width= co.width or 200
	local facX=width/(maxx-minx)
	local facY=height/(maxy-miny)
	local label_height=20
	local name_height=20
	local extra_w=25
	
	local penwidth=1
	
	local wxwindow = wx.wxControl(parent,id,wx.wxDefaultPosition,wx.wxDefaultSize,wx.wxNO_BORDER)
	wxwindow:SetMinSize(wx.wxSize(width+extra_w*2,height+label_height+name_height))
	wxwindow:SetMaxSize(wx.wxSize(width+extra_w*2,height+label_height+name_height))
	wxwindow:SetBackgroundColour(parent:GetBackgroundColour())
	wxwindow:SetLabel(label)
	
	local GraphClass={value={{0,0},{1,0}},window=wx.wxNULL,customclass="GraphClass"}
	
	function GraphClass.SetValue(_,val)
		GraphClass.value=val
		minx=val[1][1]
		maxx=val[#val][1]
		miny=math.huge
		maxy=-math.huge
		for _,v in ipairs(val) do
			if v[2] > maxy then maxy = v[2] end
			if v[2] < miny then miny = v[2] end
		end
		facX=width/(maxx-minx)
		facY=height/(maxy-miny)
		wxwindow:Refresh()
	end
	function GraphClass.SetLabel(_,val)
		wxwindow:SetLabel(val)
		wxwindow:Refresh(true,wx.wxRect(0,height+name_height,width+extra_w*2,label_height))
		--wxwindow:RefreshRect()
	end
	
	local function Draw(dc)
		dc:SetPen(wx.wxBLACK_PEN)
		dc:SetFont(wx.wxNORMAL_FONT)
		dc:DrawRectangle(extra_w, name_height, width ,height);
		local parts = 5
		local widthf=width/parts
		local widthx = maxx - minx
		for i=0,parts do
			local x1=widthf*i + extra_w
			dc:DrawLine(x1, name_height, x1,name_height + height);
			local str=string.format("%.2f",minx + widthx*i/parts)
			dc:DrawText(str,x1,0)
		end
		local heightf=height/parts
		local heighty = maxy - miny
		for i=0,parts do
			local y1=height + name_height - heightf*i
			dc:DrawLine(extra_w, y1, width+extra_w,y1);
			local str=string.format("%.2f",miny + heighty*i/parts)
			dc:DrawText(str,0,y1)
		end
		dc:SetPen(wx.wxGREEN_PEN)
		dc:SetBrush(wx.wxGREEN_BRUSH)
		local maxbin=#GraphClass.value
		if maxbin > 1 then
			local vals = GraphClass.value
			local x
			local y
			local points = {}
			for i=1,maxbin do
				x =extra_w + (vals[i][1]-minx)*facX
				y=name_height-(vals[i][2]-miny)*facY
				points[#points +1]={x,y}
			end
			dc:DrawLines(points,0,height)
		end
		--dc:SetFont(wx.wxNORMAL_FONT)
		--dc:DrawLabel(wxwindow:GetLabel(),wx.wxRect(0,height+name_height,width+extra_w*2,label_height), wx.wxALIGN_CENTER)
		--dc:DrawText(name,0,0)
		dc:SetPen(wx.wxNullPen)
		dc:SetBrush(wx.wxNullBrush)

	end
	
	wxwindow:Connect(wx.wxEVT_PAINT, function(event)
			local dc = wx.wxPaintDC(wxwindow)
			Draw(dc)
			dc:delete() 
		end)
    wxwindow:Connect(wx.wxEVT_ERASE_BACKGROUND, function(event) 
			event:Skip() 
		end) 
    
	wxwindow:Connect(wx.wxEVT_SIZE,function (event)
			wxwindow:Refresh();
		end)
	GraphClass.window=wxwindow
	return GraphClass 
end
---------------------------wxFuncGraph
function wxFuncGraph(parent,name,label,id,co)
	id = id or wx.wxID_ANY
	local miny = co.miny or 0
	local maxy = co.maxy or 1
	local height=co.height or 150
	local width= co.width or 200
	local label_height=0
	local name_height=0
	local extra_w=0
	
	local penwidth=1
	
	local wxwindow = wx.wxControl(parent,id,wx.wxDefaultPosition,wx.wxDefaultSize,wx.wxNO_BORDER)
	wxwindow:SetMinSize(wx.wxSize(width+extra_w*2,height+label_height+name_height))
	wxwindow:SetMaxSize(wx.wxSize(width+extra_w*2,height+label_height+name_height))
	wxwindow:SetBackgroundColour(parent:GetBackgroundColour())
	wxwindow:SetLabel(label)
	
	local GraphClass={value={0,0},window=wx.wxNULL,customclass="GraphClass"}
	
	function GraphClass.SetValue(_,val)
		GraphClass.value=val
		wxwindow:Refresh()
	end
	function GraphClass.SetLabel(_,val)
		wxwindow:SetLabel(val)
		wxwindow:Refresh(true,wx.wxRect(0,height+name_height,width+extra_w*2,label_height))
		--wxwindow:RefreshRect()
	end
	

	local function Draw(dc)
		--local pen = TableToPen({ colour = { 0, 0, 0 }, width = penwidth, style = wx.wxSOLID })
		--dc:SetPen(pen)
		--pen:delete()
		
		dc:SetPen(wx.wxBLACK_PEN)
		dc:DrawRectangle(0, name_height, width+extra_w*2,height);
		
		dc:SetPen(wx.wxGREEN_PEN)
		dc:SetBrush(wx.wxGREEN_BRUSH)
		local maxbin=#GraphClass.value
		if maxbin > 1 then
			local facX=width/(maxbin-1)
			local facY=height/(maxy-miny)
			--[[
			local x1=0
			local y1=height-(GraphClass.value[1]-miny)*facY
			for i=2,maxbin do
				local x2=(i-1)*facX
				local y2=height-(GraphClass.value[i]-miny)*facY
				dc:DrawLine(x1, y1, x2,y2);
				x1=x2
				y1=y2
			end
			--]]
			---[[
			local x
			local y
			local points = {}
			for i=1,maxbin do
				x=(i-1)*facX
				y=-(GraphClass.value[i]-miny)*facY
				points[#points +1]={x,y}
			end
			dc:DrawLines(points,0,height)
			--]]
		end
		
		
		--dc:SetFont(wx.wxNORMAL_FONT)
		--dc:DrawLabel(wxwindow:GetLabel(),wx.wxRect(0,height+name_height,width+extra_w*2,label_height), wx.wxALIGN_CENTER)
		--dc:DrawText(name,0,0)
		dc:SetPen(wx.wxNullPen)
		dc:SetBrush(wx.wxNullBrush)

	end
	
	wxwindow:Connect(wx.wxEVT_PAINT, function(event)
			local dc = wx.wxPaintDC(wxwindow)
			Draw(dc)
			dc:delete() 
		end)
    wxwindow:Connect(wx.wxEVT_ERASE_BACKGROUND, function(event) 
			event:Skip() 
		end) 
    
	wxwindow:Connect(wx.wxEVT_SIZE,function (event)
			wxwindow:Refresh();
		end)
	GraphClass.window=wxwindow
	return GraphClass 
end
---------------------------wxFreqScope
function wxFreqScope(parent,name,label,id,co)
	id = id or wx.wxID_ANY
	local miny = co.miny or 0
	local maxy = co.maxy or 1
	local height=co.height or 150
	local width= co.width or 200
	local label_height=0
	local name_height=15
	local extra_w=10
	
	local penwidth=1
	co.phase = co.phase or 1
	co.bins = co.bins or 512
	co.rate = co.rate or 4
	co.scopebufnum = co.scopebufnum or 0
	local fftsize=co.rate * co.bins


	local msg ={"/s_new", {co.scope, co.node, 1, 0, "in",{"int32",co.busin}, "busin",{"int32",co.busin},"rate",{"int32",co.rate},"phase",{"float",co.phase}, "scopebufnum", {"int32",co.scopebufnum},"fftsize", {"int32",fftsize}}}

	
	msg ={"/b_alloc",{ co.scopebufnum, co.bins, 1,{"blob",toOSC(msg)}}}
	SCSERVER:send(toOSC(msg))
	
	
	local wxwindow = wx.wxControl(parent,id,wx.wxDefaultPosition,wx.wxDefaultSize,wx.wxNO_BORDER)
	wxwindow:SetMinSize(wx.wxSize(width+extra_w*2,height+label_height+name_height))
	wxwindow:SetMaxSize(wx.wxSize(width+extra_w*2,height+label_height+name_height))
	wxwindow:SetBackgroundColour(parent:GetBackgroundColour())
	wxwindow:SetLabel(label)
	
	local FreqScopeClass={value={0,0},window=wx.wxNULL,customclass="FreqScopeClass"}
	
	function FreqScopeClass.SetValue(_,val)
		--print("setet freqscope",FreqScopeClass)
		FreqScopeClass.value={}
		local j=1
		--print(val[150])
		for i=4,co.bins+3 do
			FreqScopeClass.value[j]=val[i]
			j=j+1
		end
		--if not wxwindow.Refresh then
		--	print(wxwindow)
		--else
			wxwindow:Refresh()
		--end
	end
	function FreqScopeClass.SetLabel(_,val)
		wxwindow:SetLabel(val)
		wxwindow:Refresh(true,wx.wxRect(0,height+name_height,width+extra_w*2,label_height))
		--wxwindow:RefreshRect()
	end
	

	local function Draw(dc)
		--local pen = TableToPen({ colour = { 0, 0, 0 }, width = penwidth, style = wx.wxSOLID })
		--dc:SetPen(pen)
		--pen:delete()
		dc:SetFont(wx.wxNORMAL_FONT)
		dc:SetPen(wx.wxBLACK_PEN)
		dc:DrawRectangle(extra_w, name_height, width,height);
		local widthf=width/10
		for i=1,10 do
			local x1=widthf*i + extra_w
			dc:DrawLine(x1, name_height, x1,name_height + height);
			--local str=string.format("%.0f",(i*22050/10)^(i/10))
			--local str=string.format("%.0f",(i*22050/10))
			local str
			if co.scope == "freqScopeLocal" then --linear
				str=string.format("%.0f",22050*i/10)
			else	--logarithmic
				str=string.format("%.0f",22050*((fftsize*0.5)^(i/10 -1)))
			end
			dc:DrawText(str,x1,0)
		end
		dc:SetPen(wx.wxGREEN_PEN)
		dc:SetBrush(wx.wxGREEN_BRUSH)
		local maxbin=#FreqScopeClass.value
		if maxbin > 1 then
			local facX=width/(maxbin-1)
			local facY=height/(maxy-miny)
			local base = name_height+height	
			
			--local y1=name_height+height-(FreqScopeClass.value[1]-miny)*facY
			--take care of 1.INF not well behaved in DrawLine
			--[[
			local y1
			if FreqScopeClass.value[1] <= miny then
				y1=base
			else
				y1=base-(FreqScopeClass.value[1]-miny)*facY
			end
			local x1= 0 + extra_w
			for i=2,maxbin do
				local x2=(i-1)*facX + extra_w 
				--local y2=base -(FreqScopeClass.value[i]-miny)*facY
				local y2
				if FreqScopeClass.value[i] <= miny then
					y2=base
				else
					y2=base-(FreqScopeClass.value[i]-miny)*facY
				end
				dc:DrawLine(x1, y1, x2,y2);
				x1=x2
				y1=y2
			end
			--]]
			---[[
			local x
			local y
			local points = {}
			for i=1,maxbin do
				x=(i-1)*facX
				y=-(FreqScopeClass.value[i]-miny)*facY
				points[#points +1]={x,y}
			end
			dc:DrawLines(points,extra_w,base)
			--]]
		end
		
		--dc:SetFont(wx.wxNORMAL_FONT)
		--dc:DrawLabel(wxwindow:GetLabel(),wx.wxRect(0,height+name_height,width+extra_w*2,label_height), wx.wxALIGN_CENTER)
		--dc:DrawText(name,0,0)
		dc:SetPen(wx.wxNullPen)
		dc:SetBrush(wx.wxNullBrush)

	end
	wxwindow:Connect(wx.wxEVT_DESTROY, function(event)
			print("wxEVT_DESTROY freqscope")
			FreqScopeClass.notclosed=false
			OSCFunc.clearfilters("/b_setn",co.scopebufnum)
			--??QueAction 0.1 /b_free
			event:Skip()
		end)
	wxwindow:Connect(wx.wxEVT_PAINT, function(event)
			local dc = wx.wxPaintDC(wxwindow)
			Draw(dc)
			dc:delete() 
		end)
    wxwindow:Connect(wx.wxEVT_ERASE_BACKGROUND, function(event) 
			event:Skip() 
		end) 
    
	wxwindow:Connect(wx.wxEVT_SIZE,function (event)
			wxwindow:Refresh();
		end)
	FreqScopeClass.window=wxwindow

	--OSCFunc.clearfilters("/b_setn",co.scopebufnum)
	OSCFunc.newfilter("/b_setn",co.scopebufnum,function(msg)
			if FreqScopeClass.notclosed then
				--print("set freqscope",co.scopebufnum)
				FreqScopeClass:SetValue(msg[2])
				QueueAction(0.1,{function() SCSERVER:send(toOSC{"/b_getn",{co.scopebufnum,0,co.bins}}) end})
			end
		end)
	QueueAction(0.1,{function() SCSERVER:send(toOSC{"/b_getn",{co.scopebufnum,0,co.bins}}) end})
	FreqScopeClass.notclosed=true
	return FreqScopeClass 
end
function wxGLCanvas(parent,name,label,id,co)

	id = id or wx.wxID_ANY
	local height=co.height or 150
	local width= co.width or 200
	
	local wxwindow = wx.wxGLCanvas(parent, id, wx.wxDefaultPosition, wx.wxSize(width,height), wx.wxEXPAND)
	local canvas = wxwindow
	local context = wx.wxGLContext(canvas)
	local mouseLD = co.mouseLD or function() end
	local gl = require"luagl"
	local Draw = co.DrawCb
	local CanvasClass={value=0,window=canvas,height=height,width=width,customclass="CanvasClass"}
	wxwindow:Connect(wx.wxEVT_LEFT_DOWN,function (event)
			mx = event:GetX()
			my = event:GetY()
			mouseLD(mx,my,CanvasClass)
			wxwindow:Refresh()
			--if (not wxwindow:HasCapture()) then wxwindow:CaptureMouse() end
			event:Skip()
	end )
	function CanvasClass.SetValue(_,val)
		for k,v in pairs(val) do
			CanvasClass[k]=v
		end
		wxwindow:Refresh()
	end
	wxwindow:Connect(wx.wxEVT_PAINT, function(event)
			local dc = wx.wxPaintDC(wxwindow)
			canvas:SetCurrent(context)
			Draw(CanvasClass)
			canvas:SwapBuffers()
			dc:delete() 
	end)
		
	return CanvasClass
end
---------------------------wxScope
function wxScope(parent,name,label,id,co)
	id = id or wx.wxID_ANY
	local miny = co.miny or -1
	local maxy = co.maxy or 1
	local height=co.height or 150
	local width= co.width or 200
	local label_height=0
	local name_height=15
	local extra_w=10
	
	local penwidth=1
	co.bins = co.bins or 512
	co.rate = co.rate or 4
	co.scopebufnum = co.scopebufnum or 0
	
	
	local msg ={"/s_new", {co.scope, co.node, 1, 0, "busin",{"int32",co.busin}, "scopebufnum", {"int32",co.scopebufnum}}}
	--SCUDP.udp:send(toOSC(msg))
	--prtable(msg)
	msg ={"/b_alloc",{ co.scopebufnum, co.bins, 1,{"blob",toOSC(msg)}}}
	--local msg2 = {"/b_alloc",{ co.scopebufnum, co.bins, 1}}
	--SCUDP.udp:send(toOSC(msg2))
	SCSERVER:send(toOSC(msg))
		
	local wxwindow = wx.wxControl(parent,id,wx.wxDefaultPosition,wx.wxDefaultSize,wx.wxNO_BORDER)
	wxwindow:SetMinSize(wx.wxSize(width+extra_w*2,height+label_height+name_height))
	wxwindow:SetMaxSize(wx.wxSize(width+extra_w*2,height+label_height+name_height))
	wxwindow:SetBackgroundColour(parent:GetBackgroundColour())
	wxwindow:SetLabel(label)
	
	local FreqScopeClass={value={0,0},window=wx.wxNULL,customclass="ScopeClass"}
	
	function FreqScopeClass.SetValue(_,val)
		--print("setet scope",FreqScopeClass)
		FreqScopeClass.value={}
		local j=1
		--print(val[150])
		for i=4,co.bins+3 do
			FreqScopeClass.value[j]=val[i]
			j=j+1
		end
		--if not wxwindow.Refresh then
		--	print(wxwindow)
		--else
			wxwindow:Refresh()
		--end
	end
	function FreqScopeClass.SetLabel(_,val)
		wxwindow:SetLabel(val)
		wxwindow:Refresh(true,wx.wxRect(0,height+name_height,width+extra_w*2,label_height))
		--wxwindow:RefreshRect()
	end
	

	local function Draw(dc)
		--local pen = TableToPen({ colour = { 0, 0, 0 }, width = penwidth, style = wx.wxSOLID })
		--dc:SetPen(pen)
		--pen:delete()
		dc:SetFont(wx.wxNORMAL_FONT)
		dc:SetPen(wx.wxBLACK_PEN)
		dc:DrawRectangle(extra_w, name_height, width,height);
		local widthf=width/10
		for i=1,10 do
			local x1=widthf*i + extra_w
			dc:DrawLine(x1, name_height, x1,name_height + 10 )--height);
			local str
			str=string.format("%.0f",co.bins*i/10)
			dc:DrawText(str,x1,0)
		end
		dc:DrawLine(extra_w, name_height +height/2,extra_w + width,name_height +height/2 )
		dc:SetPen(wx.wxGREEN_PEN)
		dc:SetBrush(wx.wxGREEN_BRUSH)
		local maxbin=#FreqScopeClass.value
		if maxbin > 1 then
			local facX=width/(maxbin-1)
			local facY=height/(maxy-miny)
			local base = name_height+height	
			
			--local y1=name_height+height-(FreqScopeClass.value[1]-miny)*facY
			--take care of 1.INF not well behaved in DrawLine
			
			---[[
			local x
			local y
			local points = {}
			for i=1,maxbin do
				x=(i-1)*facX
				y=-(FreqScopeClass.value[i]-miny)*facY
				points[#points +1]={x,y}
			end
			dc:DrawLines(points,extra_w,base)
			--]]
		end
		
		--dc:SetFont(wx.wxNORMAL_FONT)
		--dc:DrawLabel(wxwindow:GetLabel(),wx.wxRect(0,height+name_height,width+extra_w*2,label_height), wx.wxALIGN_CENTER)
		--dc:DrawText(name,0,0)
		dc:SetPen(wx.wxNullPen)
		dc:SetBrush(wx.wxNullBrush)

	end
	wxwindow:Connect(wx.wxEVT_DESTROY, function(event)
			print("wxEVT_DESTROY scope")
			FreqScopeClass.notclosed=false
			OSCFunc.clearfilters("/b_setn",co.scopebufnum)
			--??QueAction 0.1 /b_free
			event:Skip()
		end)
	wxwindow:Connect(wx.wxEVT_PAINT, function(event)
			local dc = wx.wxPaintDC(wxwindow)
			Draw(dc)
			dc:delete() 
		end)
    wxwindow:Connect(wx.wxEVT_ERASE_BACKGROUND, function(event) 
			event:Skip() 
		end) 
    
	wxwindow:Connect(wx.wxEVT_SIZE,function (event)
			wxwindow:Refresh();
		end)
	FreqScopeClass.window=wxwindow

	--OSCFunc.clearfilters("/b_setn",co.scopebufnum)
	OSCFunc.newfilter("/b_setn",co.scopebufnum,function(msg)
			if FreqScopeClass.notclosed then
				--print("set scope",co.scopebufnum)
				FreqScopeClass:SetValue(msg[2])
				QueueAction(0.1,{function() SCSERVER:send(toOSC{"/b_getn",{co.scopebufnum,0,co.bins}}) end})
			end
		end)
	QueueAction(0.1,{function() SCSERVER:send(toOSC{"/b_getn",{co.scopebufnum,0,co.bins}}) end})
	FreqScopeClass.notclosed=true
	return FreqScopeClass 
end
--------------------------------ScriptGUI

theScriptGUI={}
function CloseScriptGUI()
	print("CloseScriptGUI ",ScriptGUI)
    if theScriptGUI.window then
		ScriptGUI=theScriptGUI.window
		manager:DetachPane(ScriptGUI)
        ScriptGUI:Destroy()
        ScriptGUI = nil
		manager:Update()
		theScriptGUI.window=nil
    end
end
function DeleteSizerItems(sizer)
	--print("DeleteSizerItemsxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
	--collect
	local wndArr={}
	local spcArr={}
	local sizArr={}

	--local ind=0
	--while true do
	local countChildren = sizer:GetChildren():GetCount()
	for ind=0,countChildren-1 do
		local item=sizer:GetItem(ind)
		if item==wx.wxNULL then break end
		if item:IsWindow() then
			--print(ind," is window") 
			local wnd=item:GetWindow()
			wndArr[#wndArr +1]=wnd
		elseif item:IsSizer() then
			--print(ind," is sizer")
			local siz=item:GetSizer()
			--DeleteSizerItems(siz)
			--print("Recurrence endedxxxxxxxxxxx")
			sizArr[#sizArr +1]=siz
		elseif item:IsSpacer() then 
			--print(ind," is spacer")
			local spc=item:GetSpacer()
			spcArr[#spcArr +1]=spc
		end
		ind = ind + 1
		--item:DeleteWindows()
	end
	--end
	
	--destroy items
	
	for i,siz in ipairs(sizArr) do
		DeleteSizerItems(siz)
		-- if siz:IsKindOf(wx.wxClassInfo("wxStaticBoxSizer")) then
			-- print("es box sizer")
			-- local sizst= siz:DynamicCast("wxStaticBoxSizer")
			-- local stbox=sizst:GetStaticBox()
			-- siz:Detach(stbox)
			-- stbox:Destroy()
		-- end
		sizer:Detach(siz)
		----siz:delete()
	end
	for i,wnd in ipairs(wndArr) do
		sizer:Detach(wnd)
		wnd:Destroy()
		wnd=nil
	end
	for i,spc in ipairs(spcArr) do
		--sizer:Detach(spc)
		spc=nil
	end
end

function ClearScriptGUI()
	if theScriptGUI.window==nil then return end
	--print("ClearScriptGUIxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
	--prtable(theScriptGUI.Controls)
	--prtable(theScriptGUI.Sizers)
	theScriptGUI.window:DestroyChildren()
	DeleteSizerItems(theScriptGUI.Sizers["main"].sizer)
	
	--print("after deletesizeritmes ClearScriptGUIxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
	--DeleteSizerItems(theScriptGUI.Sizers["main"])
	--DeleteSizerItems(theScriptGUI.Sizers["main"])
	
	--print("after deletesizeritmes ClearScriptGUIxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
	--prtable(theScriptGUI.Controls)
	--prtable(theScriptGUI.Sizers)
	for i,v in ipairs(theScriptGUI.Sizers) do
		theScriptGUI.Sizers[i].sizer=nil
		theScriptGUI.Sizers[i]=nil
	end
	for i,v in ipairs(theScriptGUI.Controls) do
		theScriptGUI.Controls[i]=nil
	end
	for i,v in ipairs(theScriptGUI.ScriptWindows) do
		v:Close()
		theScriptGUI.ScriptWindows[i]=nil
	end
	-- local cont=theScriptGUI.Controls
	-- cont={}
	-- local sizers=theScriptGUI.Sizers
	-- sizers={main=theScriptGUI.Sizers["main"]}
	--print("ended ClearScriptGUIxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
	collectgarbage()
	--prtable(theScriptGUI.Controls)
	--prtable(theScriptGUI.Sizers)
	--clear linda--
	repeat
		local key,val=scriptguilinda:receive(0,"guiSetValue","guiGetValue","guiSetLabel","guiDeleteControl","guiDeletePanel" ,"/vumeter")
		print("xxxxxxxxxxxxxxxxxxxxxxScriptGUI clear linda ",key)
	until val==nil
end
function CreateScriptGUI()

	if theScriptGUI.window then return end
	local Controls={}
	local Sizers={}
	local ScriptWindows = {}
	--setmetatable(Controls,{__mode = "v"})
	--setmetatable(Sizers,{__mode = "v"})
	theScriptGUI.Controls=Controls
	theScriptGUI.Sizers=Sizers
	theScriptGUI.ScriptWindows=ScriptWindows
	--makes control.control control.label control.insobj control.tipex
	local function val2pos(val)
		return (1-val)*10000
	end
	local function pos2val(pos)
		return (10000-pos)*0.0001
	end
	
	local function EmptyPanel(tag)
		--print("DeletePanel panel N:",tag)
		local sizer=Sizers[tag].sizer
		DeleteSizerItems(sizer)
		--Sizers[tag]=nil
		--sizer=nil
		--prtable(Controls)
		--prtable(Sizers)
		manager:Update()
	end
	local function DeletePanel(tag)
		EmptyPanel(tag)
		local sizer=Sizers[tag].sizer
		local parent=Sizers[Sizers[tag].parent].sizer
		if sizer:IsKindOf(wx.wxClassInfo("wxStaticBoxSizer")) then
			-- print("es box sizer")
			local sizst= sizer:DynamicCast("wxStaticBoxSizer")
			local stbox=sizst:GetStaticBox()
			sizer:Detach(stbox)
			stbox:Destroy()
		end
		parent:Detach(sizer)
		manager:Update()
	end
	local function DeleteControl(tag)
		--print("DeleteControl control N:",tag)
		local control=Controls[tag]
		if control.customclass then --custom control
			control.control.window:Destroy()
		else
			control.control:Destroy()
			if control.label then
				control.label:Destroy()
			end
			if control.panel then
				control.panel:GetStaticBox():Destroy()
			end
		end
		Controls[tag]=nil
		control=nil
		--manager:Update()
	end
	--control tipex ,control (and control.window) label insobj
	--co tipex tag label name menu
	local function CreateControl(co)
		local control={}
		control.typex=co.typex
		control.pos = co.pos
		control.span = co.span
		local ScriptGUI = ScriptWindows[co.window] or ScriptGUI
		if co.typex=="toggle" then
			control.control=wx.wxToggleButton(ScriptGUI,co.tag, tostring(co.label),wx.wxDefaultPosition,wx.wxSize(40,20))
		elseif co.typex=="button" then
			control.control=wx.wxButton(ScriptGUI,co.tag, tostring(co.label),wx.wxDefaultPosition,wx.wxSize(40,20))
		elseif co.typex=="vslider" then
			control.control=wx.wxSlider(ScriptGUI,co.tag, val2pos(co.value or 0) , 0, 10000, wx.wxDefaultPosition,wx.wxDefaultSize,wx.wxSL_VERTICAL )
			if co.label then
				control.label=wx.wxStaticText(ScriptGUI,  wx.wxID_ANY, tostring(co.label), wx.wxDefaultPosition,wx.wxDefaultSize, wx.wxALIGN_CENTRE)
			end
		elseif co.typex=="hslider" then
			co.value = co.value or 0
			local size = (co.width and co.height) and wx.wxSize(co.width,co.height) or wx.wxDefaultSize
			control.control=wx.wxSlider(ScriptGUI,co.tag, co.value*10000 , 0, 10000, wx.wxDefaultPosition,size,wx.wxSL_HORIZONTAL)
			if co.label then
				control.label=wx.wxStaticText(ScriptGUI,  wx.wxID_ANY, tostring(co.label), wx.wxDefaultPosition,wx.wxDefaultSize, wx.wxALIGN_CENTRE)
			end
		elseif co.typex=="combo" then
			control.control=wx.wxChoice(ScriptGUI,co.tag,wx.wxDefaultPosition,wx.wxDefaultSize,co.menu)
			if co.label then
				control.label=wx.wxStaticText(ScriptGUI,  wx.wxID_ANY, tostring(co.label), wx.wxDefaultPosition,wx.wxDefaultSize, wx.wxALIGN_CENTRE)
			end
		elseif co.typex=="text" then
			control.control=wx.wxTextCtrl(ScriptGUI,co.tag,tostring(co.value),wx.wxDefaultPosition,wx.wxSize(40,20),wx.wxTE_PROCESS_ENTER)
			if co.label then
				control.label=wx.wxStaticText(ScriptGUI,  wx.wxID_ANY, tostring(co.label), wx.wxDefaultPosition,wx.wxDefaultSize, wx.wxALIGN_CENTRE)
			end
		elseif co.typex=="label" then
			control.control=wx.wxStaticText(ScriptGUI,co.tag, tostring(co.label), wx.wxDefaultPosition,wx.wxDefaultSize, wx.wxALIGN_CENTRE) -- wx.wxST_NO_AUTORESIZE +
		elseif co.typex=="knob" then
			control.control=wxKnob(ScriptGUI,tostring(co.name), tostring(co.label),co.tag,co.radio) -- wx.wxST_NO_AUTORESIZE +
			control.control.window:SetToolTip(tostring(co.name))
			control.customclass=true
		elseif co.typex=="vumeter" then
			control.control=wxVuMeter(ScriptGUI,tostring(co.name), tostring(co.label),co.tag,co) -- wx.wxST_NO_AUTORESIZE +
			control.customclass=true
		elseif co.typex=="funcgraph" then
			control.control=wxFuncGraph(ScriptGUI,tostring(co.name), tostring(co.label),co.tag,co) 
			control.customclass=true
		elseif co.typex=="funcgraph2" then
			control.control=wxFuncGraph2(ScriptGUI,tostring(co.name), tostring(co.label),co.tag,co) 
			control.customclass=true
		elseif co.typex=="freqscope" then
			control.control=wxFreqScope(ScriptGUI,tostring(co.name), tostring(co.label),co.tag,co) 
			control.customclass=true
		elseif co.typex=="scope" then
			control.control=wxScope(ScriptGUI,tostring(co.name), tostring(co.label),co.tag,co) 
			control.customclass=true
		elseif co.typex=="glcanvas" then
			control.control=wxGLCanvas(ScriptGUI,tostring(co.name), tostring(co.label),co.tag,co) 
			control.customclass=true
		else
			print(co.typex," control not implemented ",co.type)
			control= {control=false}
		end
		if not control.customclass then -- the not custom types (knob...)
			if control.label or co.name then
				local panel= wx.wxStaticBoxSizer(wx.wxVERTICAL, ScriptGUI,tostring(co.name))
				--local panel=wx.wxBoxSizer(wx.wxVERTICAL)
				panel:Add(control.control,0,wx.wxALIGN_CENTER_HORIZONTAL)--+ wx.wxGROW)
				if control.label then
					panel:Add(control.label,0,wx.wxALIGN_CENTER_HORIZONTAL)-- + wx.wxGROW )
				end
				control.panel=panel
				control.insobj=panel
			else
				control.insobj=control.control
			end
		else
			control.insobj=control.control.window
		end
		return control
	end
	
	local function SetLabelControl(tag,val)
		if Controls[tag] then
			local control=Controls[tag].label or Controls[tag].control
			if control then
				control:SetLabel(tostring(val))
			end
			--print("SetLabelControl",tag,val)
			--prtable(control)
		else
			print("SetLabelControl tag "..tag.." not found")
		end
	end
	local function GetValueControl(tag)
		assert(false)
		local control=Controls[tag].control
		local val
		if control then
			if control:IsKindOf(wx.wxClassInfo("wxToggleButton")) then
				--val= (val==1) and true or false
				val=control:GetValue(val) and 1 or 0
			elseif control:IsKindOf(wx.wxClassInfo("wxSlider")) then
				--control:SetValue(val*10000)
				val=control:GetValue(val)/10000
			else
				print("get value no encuentra a")
				prtable(control)
			end
		end
		print("GetValueControl",tag,val)
		--prtable(control)
		linda:send("GetValueControlResponse",val)
	end
	local function SetValueControlBAK(tag,val)
		local control=Controls[tag].control
		if control then
			if control:IsKindOf(wx.wxClassInfo("wxToggleButton")) then
				val= (val==1) and true or false
				control:SetValue(val)
			elseif control:IsKindOf(wx.wxClassInfo("wxSlider")) then
				control:SetValue(val*10000)
			else
				print("set value no encuentra a")
				prtable(control)
			end
		end
		--print("SetValueControl",tag,val)
	end
	local function SetValueControl(tag,val)
		local co=Controls[tag]
		--todo could check if co==nil (not yet created or already deleted)
		if co then
			if co.control then
				if co.typex=="toggle" then
					val= (val==1) and true or false
					co.control:SetValue(val)
				--elseif co.typex=="button" then
				--	co.control:SetValue(val)
				elseif co.typex=="vslider"  or  co.typex=="hslider" then
					co.control:SetValue(val2pos(val))
				elseif co.typex=="knob" then
					co.control:SetValue(val)
				elseif co.typex=="vumeter" then
					co.control:SetValue(val)
				elseif co.typex=="funcgraph" then
					co.control:SetValue(val)
				elseif co.typex=="funcgraph2" then
					co.control:SetValue(val)
				elseif co.typex=="freqscope" then
					co.control:SetValue(val)
				elseif co.typex=="scope" then
					co.control:SetValue(val)
				elseif co.typex=="combo" then
					co.control:SetSelection(val)
				elseif co.typex=="text" then
					co.control:SetValue(tostring(val))
				elseif co.typex=="glcanvas" then
					co.control:SetValue(val)
				else
					DisplayOutput("SetValueControl bad typex",true)
					prtable(co)
				end
			else
				print("SetValueControl co.control with tag "..tag.." not found")
			end
		else
			print("SetValueControl tag "..tag.." not found")
		end
		--print("SetValueControl",tag,val)
	end
	
	local function AddControl(const)
		--print("xxxxxxxxxxxxxxxxAddControl control N:",const.tag)
		--prtable(const)
		
		const.panel = const.panel or "main"
		local container=Sizers[const.panel]
		assert(container.sizer,"Sizer doesnot exist")
		local control=CreateControl(const)
		--DisplayOutput("xxxxxxxxxxxxxxxxAddControl control N:",const.tag)
		--print(control)
		--prtable(control)
		if control then
			local prop=0
			local style=wx.wxALIGN_CENTER_HORIZONTAL  +wx.wxALL  --+ wx.wxEXPAND  
			if const.typex=="toggle" then prop=0; style=wx.wxALIGN_CENTER_HORIZONTAL  +wx.wxALL; end
			if const.panel=="main" then prop=0; style=0; end
			--container.sizer:Add(control.insobj,prop,style)
			if container.type=="gridbag" then
				control.pos = control.pos or {0,0}
				control.span = control.span or {1,1}
				assert((control.pos[1]>=0) and (control.pos[1]>=0))
				local goodadd=container.sizer:Add(control.insobj,wx.wxGBPosition(control.pos[1],control.pos[2]),wx.wxGBSpan(control.span[1],control.span[2]))
				if goodadd == wx.wxNULL then
					--DisplayOutput("gridbag AddControl control bad position"..tostring(const.tag),true)
					print("gridbag AddControl control bad position"..tostring(const.tag))
				end
			else
				container.sizer:Add(control.insobj,prop,style)
				--if container.type == "collapse" then
				--	Sizers[container.parent].sizer:Hide(container.sizer,true)
				--	print("hide collapse xxxxxxxxxxxxxxx")
				--end
			end
			-- ScriptGUI:InvalidateBestSize()
			-- sizer:Layout()
			-- ScriptGUImainSizer:SetSizeHints(ScriptGUI)
			-- ScriptGUI:Layout()
			-- ScriptGUI:SetSize(wx.wxDefaultCoord, wx.wxDefaultCoord, wx.wxDefaultCoord, wx.wxDefaultCoord, wx.wxSIZE_AUTO);
			--ScriptGUI:SetAutoLayout(true)
			--[[
			ScriptGUImainSizer:Layout()
			ScriptGUImainSizer:SetSizeHints(ScriptGUI)
			manager:GetPane(ScriptGUI):FloatingSize(ScriptGUI:GetSize()):BestSize(ScriptGUI:GetSize()):MinSize(wx.wxSize(100,100))--:MinSize(ScriptGUI:GetSize())
			manager:Update()
			--]]
		end
		Controls[const.tag]=control
	end
	-- button for collapsible
	local function CollapButton(parent,ids,texto,panelSizer,collapSizer)
		local collapsed = true
		local width = 40
		local height = 20
		--local wxwindow = wx.wxControl(parent,ids,wx.wxDefaultPosition,wx.wxSize(width,height))--,wx.wxNO_BORDER)
		local wxwindow = wx.wxWindow(parent,ids,wx.wxDefaultPosition,wx.wxSize(width,height))--,wx.wxNO_BORDER)
		wxwindow:Connect(wx.wxEVT_PAINT, function(event)
			local dc = wx.wxPaintDC(wxwindow)
			--local pen = collapsed and wx.wxBLACK_PEN or wx.wxGREY_PEN
			dc:SetPen(wx.wxBLACK_PEN)
			dc:SetBrush(wx.wxTRANSPARENT_BRUSH)
			dc:DrawRectangle(0, 0, width,height);
			dc:SetFont(wx.wxNORMAL_FONT)
			dc:SetTextBackground(wx.wxLIGHT_GREY)
			dc:SetTextForeground(collapsed and wx.wxBLACK or wx.wxWHITE)

			dc:DrawLabel(texto,wx.wxRect(0, 0, width, height), wx.wxALIGN_CENTER)
			
			dc:SetTextBackground(wx.wxNullColour)
			dc:SetTextForeground(wx.wxNullColour)
			--dc:DrawText(name,0,0)
			dc:SetPen(wx.wxNullPen)
			dc:SetBrush(wx.wxNullBrush)
			dc:delete() 
		end)
		--wxwindow:Connect(wx.wxEVT_ERASE_BACKGROUND, function(event) 
		--			event:Skip() 
		--		end) 
		wxwindow:Connect(wx.wxEVT_LEFT_DOWN,function (event)
					collapsed = not collapsed
					--wxwindow:Command(wx.wxCommandEvent(wx.wxEVT_COMMAND_TOGGLEBUTTON_CLICKED,ids))
					if not collapsed then
						panelSizer:Show(collapSizer,true)
					else
						panelSizer:Hide(collapSizer,true)
					end
					parent:Layout()
					wxwindow:Refresh()
					event:Skip()
				end )
		return wxwindow
	end
	--makes collapsible sizer
	local function Collapsible(parent,parentSizer,texto)
		local panelSizer = wx.wxBoxSizer( wx.wxVERTICAL )
		local collapSizer = wx.wxBoxSizer( wx.wxVERTICAL )
		local ids = NewID()
		--local button = wx.wxToggleButton(parent,ids,texto,wx.wxDefaultPosition,wx.wxSize(40,20))
		--button:SetFont(wx.wxSMALL_FONT)
		local button = CollapButton(parent,ids,texto,panelSizer,collapSizer)
		parentSizer:Add(panelSizer,0,wx.wxALIGN_CENTER_HORIZONTAL + wx.wxALL,0)
		panelSizer:Add(button, 0, wx.wxALIGN_CENTER_HORIZONTAL + wx.wxALL, 0);
		--[[
		parent:Connect(ids, wx.wxEVT_COMMAND_TOGGLEBUTTON_CLICKED,
		function(event) 
			if button:GetValue() then
				panelSizer:Show(collapSizer,true)
			else
				panelSizer:Hide(collapSizer,true)
			end
			parent:Layout()
		end)
		--]]
		panelSizer:Add(collapSizer, 0, wx.wxALIGN_CENTER_HORIZONTAL + wx.wxALL, 0);
		--parentSizer:Add(panelSizer,0,wx.wxALIGN_CENTER_HORIZONTAL + wx.wxALL,0)
		panelSizer:Hide(collapSizer,true)
		return collapSizer
	end
	local function CommadEventProcess(event)
		local val
		local str
		
		local evtype=event:GetEventType()
		if evtype==wx.wxEVT_COMMAND_TOGGLEBUTTON_CLICKED then
			val=event:IsChecked() and 1 or 0
		elseif evtype==wx.wxEVT_COMMAND_BUTTON_CLICKED  then
			val=1
		elseif evtype==wx.wxEVT_SCROLL_THUMBRELEASE or evtype==wx.wxEVT_SCROLL_THUMBTRACK then
			val=pos2val(event:GetPosition())
		elseif evtype==wx.wxEVT_COMMAND_CHOICE_SELECTED  then
			val=event:GetSelection()
			str=event:GetString()
		elseif evtype==wx.wxEVT_COMMAND_TEXT_ENTER  then 
			--val=event:GetSelection()
			str=event:GetString()
			val=str
		else
			event:Skip()
			return
		end
		local id=event:GetId()
		scriptlinda:send("_valueChangedCb",{id,val,str})
		event:Skip()
	end
	local function ConnectComands(win)
		local win = win or ScriptGUI
		local wxEVT_Array=wxlua.GetBindings()[4].GetEventArray --wxcore events
		for i = 1, #wxEVT_Array do
            --if not skipEVTs[wxEVT_Array[i].name] then
                win:Connect(wx.wxID_ANY, wxEVT_Array[i].eventType, CommadEventProcess)
            --end
        end
	end
	function addWindow(win)
		win.w = win.w or 200
		win.h = win.h or 200
		win.x = win.x or 200
		win.y = win.y or 200
		ScriptWindows[win.tag] = wx.wxFrame(frame,wx.wxID_ANY,"window script",wx.wxPoint(win.x,win.y),wx.wxSize(win.w,win.h),wx.wxMINIMIZE_BOX + wx.wxMAXIMIZE_BOX + wx.wxRESIZE_BORDER + wx.wxSYSTEM_MENU + wx.wxCAPTION + wx.wxCLIP_CHILDREN + wx.wxFRAME_FLOAT_ON_PARENT)
		ConnectComands(ScriptWindows[win.tag])
		ScriptWindows[win.tag]:Show()
		
		--[[
		local ScriptGUI = ScriptWindows[win.tag]
		local ScriptGUImainSizer=wx.wxBoxSizer(wx.wxHORIZONTAL)
		ScriptGUI:SetAutoLayout(true)
		ScriptGUI:SetSizer( ScriptGUImainSizer )	
		
		local container = wx.wxFlexGridSizer( 0,10)
		local style= wx.wxALIGN_CENTER_HORIZONTAL  +wx.wxALL
		ScriptGUImainSizer:Add(container,0,style)
		
		for i=1,100 do
			local control = wx.wxButton(ScriptWindows[win.tag],wx.wxID_ANY, "label",wx.wxDefaultPosition,wx.wxSize(40,20))
			container:Add(control,0,style)
		end
		
		ScriptGUImainSizer:SetSizeHints(ScriptGUI)
		--]]
				--[[
		local ScriptGUI = ScriptWindows[win.tag]
		local ScriptGUImainSizer=wx.wxBoxSizer(wx.wxHORIZONTAL)
		ScriptGUI:SetAutoLayout(true)
		ScriptGUI:SetSizer( ScriptGUImainSizer )	
		local tagp = 100
		AddPanel{type="flexi",cols=10,tag=tagp}

		local style= wx.wxALIGN_CENTER_HORIZONTAL  +wx.wxALL
		ScriptGUImainSizer:Add(Sizers[tagp].sizer,0,style)
		
		for i=1,100 do
			local cont = {typex="button",name="pan",label="label",panel=tagp,tag=i}
			--scriptguilinda:send("guiModify",{"addControl",cont})
			AddControl(cont)
		end
		
		ScriptGUImainSizer:SetSizeHints(ScriptGUI)
		--]]
		--print("window added",ScriptWindows[win.tag])
	end
	--[[
	function addWindowAV(win)
		win.w = win.w or 200
		win.h = win.h or 200
		win.x = win.x or 200
		win.y = win.y or 200
		local window = wx.wxFrame(frame,wx.wxID_ANY,"window script",wx.wxPoint(win.x,win.y),wx.wxSize(win.w,win.h),wx.wxMINIMIZE_BOX + wx.wxMAXIMIZE_BOX + wx.wxRESIZE_BORDER + wx.wxSYSTEM_MENU + wx.wxCAPTION + wx.wxCLIP_CHILDREN + wx.wxFRAME_FLOAT_ON_PARENT)
		ScriptWindows[win.tag] = window
		window:Connect(wx.wxEVT_LEFT_DOWN,function (event)
			if event::Moving() then
				event:Skip()
				return
			end

			scriptlinda:send("_valueChangedCb",{id,val,str})
			mx = event:GetX()
			my = event:GetY()
			mouseLD(mx,my,CanvasClass)
			wxwindow:Refresh()
			--if (not wxwindow:HasCapture()) then wxwindow:CaptureMouse() end
			event:Skip()
		end)
		ScriptWindows[win.tag]:Show()
	end
	--]]
	--{type,parent,cols,rows,tag(auto),name}
	function AddPanel(pan)
		local ScriptGUI = ScriptWindows[pan.window] or ScriptGUI
		pan.parent=pan.parent or "main"
		local panel
		if pan.type=="vbox" then
			if pan.name then
				panel=wx.wxStaticBoxSizer(wx.wxVERTICAL, ScriptGUI,tostring(pan.name)) 
			else
				panel=wx.wxBoxSizer(wx.wxVERTICAL)
			end
		elseif pan.type=="hbox" then
			if pan.name then
				panel=wx.wxStaticBoxSizer(wx.wxHORIZONTAL, ScriptGUI,tostring(pan.name)) 
			else
				panel=wx.wxBoxSizer(wx.wxHORIZONTAL)
			end
		elseif pan.type=="collapse" then
			panel = Collapsible(ScriptGUI,Sizers[pan.parent].sizer,pan.name or "xx")
		elseif pan.type=="flexi" then
			panel=wx.wxFlexGridSizer(pan.rows or 0,pan.cols or 0)
		elseif pan.type=="gridbag" then
			panel=wx.wxGridBagSizer()
		end
		--print("xxxxxxxxxxxxxxxAddPanel")
		--prtable(pan)
		--print(panel)
		pan.sizer=panel
		Sizers[pan.tag]=pan
		-- add to parent
		if pan.type ~="collapse" then
			local prop=0
			local style= wx.wxALIGN_CENTER_HORIZONTAL  +wx.wxALL-- + wx.wxEXPAND 
			if pan.parent=="main" then prop=0; style=0; end
			local parent=Sizers[pan.parent]
			if parent.type=="gridbag" then
				pan.pos = pan.pos or {0,0}
				pan.span = pan.span or {1,1}
				parent.sizer:Add(panel,wx.wxGBPosition(pan.pos[1],pan.pos[2]),wx.wxGBSpan(pan.span[1],pan.span[2]))
			else
				parent.sizer:Add(panel,prop,style)
			end
		end
		--[[
		-- sizer:Layout()
		ScriptGUImainSizer:Layout()
		-- ScriptGUImainSizer:SetSizeHints(ScriptGUI)
		manager:GetPane(ScriptGUI):FloatingSize(ScriptGUI:GetSize()):BestSize(ScriptGUI:GetSize())--:MinSize(ScriptGUI:GetSize())
		manager:Update()
		--]]
	end
	--ScriptGUI = wx.wxPanel(frame, wx.wxID_ANY, "Script GUI",wx.wxDefaultPosition, wx.wxDefaultSize)--,wx.wxDEFAULT_FRAME_STYLE)-- + wx.wxFRAME_FLOAT_ON_PARENT)
	--ScriptGUI = wx.wxPanel(frame, wx.wxID_ANY,wx.wxDefaultPosition, wx.wxDefaultSize)

	ScriptGUI = wx.wxScrolledWindow(managedpanel, wx.wxID_ANY,wx.wxDefaultPosition, wx.wxDefaultSize)
	ScriptGUI:SetScrollbars(20, 20, 50, 50);
	--ScriptGUI:SetFont(wx.wxSMALL_FONT)
	theScriptGUI.window = ScriptGUI
	--[[
	local font=ScriptGUI:GetFont()
	wx.wxMessageDialog(ScriptGUI,tostring(font:GetPointSize())):ShowModal()
	font:SetPointSize(font:GetPointSize()*0.9)
	wx.wxMessageDialog(ScriptGUI,tostring(font:GetPointSize())):ShowModal()
	ScriptGUI:SetFont(font)
	--]]
	

	ScriptGUImainSizer=wx.wxBoxSizer(wx.wxHORIZONTAL)
	Sizers["main"]={sizer=ScriptGUImainSizer}
	ScriptGUI:SetAutoLayout(true)
	ScriptGUI:SetSizer( ScriptGUImainSizer )	
	ScriptGUImainSizer:SetSizeHints(ScriptGUI)
    --ScriptGUI:Show(true)
	
	--manager:AddPane(ScriptGUI, wxaui.wxAuiPaneInfo():Name("ScriptGUI"):Right():Row(0):Layer(0):CloseButton(false):MaximizeButton(true):MinSize(wx.wxSize(100,100)):PaneBorder(true))--:FloatingSize(wx.wxSize(300,200)));MinimizeButton(true):
	manager:AddPane(ScriptGUI, wxaui.wxAuiPaneInfo():Name("ScriptGUI"):Right():Row(0):Layer(0):CloseButton(false):MaximizeButton(true):PaneBorder(true))
	
	manager:Update()
	
	--clear linda--
	repeat
		local key,val=scriptguilinda:receive(0,"guiModify","guiUpdate","guiSetValue","guiGetValue","guiSetLabel","guiDeleteControl","guiDeletePanel","/vumeter" )
		print("xxxxxxxxxxxxxxxxxxxxxxScriptGUI clear linda ",key)
	until val==nil

	ScriptGUI:Connect(wx.wxEVT_IDLE,
        function(event)
			local requestmore = true
			for mes=1,10 do
				local key,val=scriptguilinda:receive(0,"guiModify","guiUpdate","guiSetValue","guiGetValue","guiSetLabel","/vumeter" )
				if val then
					--only one linda key, order in creation is important for layout
					if key=="guiModify" then
						--print("guiModify",val[1])
						if(val[1]=="addControl") then
							AddControl(val[2])
						elseif val[1]=="addPanel" then
							AddPanel(val[2])
						elseif val[1]=="deleteControl" then
							DeleteControl(val[2])
						elseif val[1]=="deletePanel" then
							DeletePanel(val[2])
						elseif val[1]=="emptyPanel" then
							EmptyPanel(val[2])
						elseif val[1]=="addWindow" then
							addWindow(val[2])
						elseif val[1]=="addWindowAV" then
							addWindowAV(val[2])
						else
							assert(false)
						end
					elseif key=="guiUpdate" then
						--ScriptGUI:SetSizer(ScriptGUImainSizer)
						-- hide collapsibles
						for k,cont in pairs(Sizers) do
							if cont.type =="collapse" then
								Sizers[cont.parent].sizer:Hide(cont.sizer,true)
							end
						end
						--------------------------
						ScriptGUImainSizer:Layout()
						ScriptGUImainSizer:SetSizeHints(ScriptGUI)
						manager:GetPane(ScriptGUI):FloatingSize(ScriptGUI:GetSize()):BestSize(ScriptGUI:GetSize()):MinSize(wx.wxSize(100,100))
						manager:Update()
					elseif key=="guiSetValue" then
						SetValueControl(val[1],val[2])
					elseif key=="guiGetValue" then
						GetValueControl(val)
					elseif key=="guiSetLabel" then
						SetLabelControl(val[1],val[2])
					elseif key=="/vumeter" then -- node,id,peak,rms
						local vumet=Controls[val[2]]
						if vumet then
							--prtable(val)
							--prtable(vumet)
							vumet.control:SetValue({val[4],val[3]})
						end
					end
					--event:RequestMore()
				else -- nothing received
					requestmore = false
					break;
				end
			end --for
			event:RequestMore(requestmore)
			--event:Skip()
		end)


    ScriptGUI:Connect( wx.wxEVT_CLOSE_WINDOW,
            function (event)
				print("ScriptGUI wxEVT_CLOSE_WINDOW")
                CloseScriptGUI()
                event:Skip()
            end)
	ConnectComands()
end
