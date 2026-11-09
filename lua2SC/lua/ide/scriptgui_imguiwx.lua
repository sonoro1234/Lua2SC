local wxImguiCanvas = require"ide.wxImguiCanvas"
local ig = require"imgui.GLFW"
local ffi = require"ffi"
local function prstak(stk)
	local str=""
	for i,lev in ipairs(stk) do
		str= str..i..": \n"
		for k,v in pairs(lev) do
			str=str.."\t["..k.."]:"..v.."\n"
		end
	end
	io.write(str)
end

local function finalizer_func(err,stk)
	print("scriptgui_lane finalizer:")
	if err and type(err)~="userdata" then 
		print( "after error: "..tostring(err) )
		print("finalizer stack table")
		prstak(stk)
	elseif type(err)=="userdata" then
		print( "after cancel " )
	else
		print( "after normal return" )
	end
	--mainlinda:send("ide_exit",1)
	print( "finalizer ok" )
end

--[[
local function ide_main()
	lanes = require "lanes" --.configure()
	set_finalizer( finalizer_func ) 
	set_error_reporting("extended")
	set_debug_threadname("scriptgui_lane")
	require"sc.utils"
	local igwin = require"imgui.window"
	local win = igwin:GLFW(800,400, "widgets")
	local ig = win.ig


local ffi = require"ffi"
local val = ffi.new("float[1]")
local padval = ffi.new("float[2]")
local curve = win.ig.Curve("mycurve",12,100)
local Quat = ffi.new("quat",{1,0,0,0})
local v3 = ffi.new("G3Dvec3",{1,0,0})
local mat4 = win.ig.mat4_cast(Quat)
--]]
local Controls = {}
local Sizers = {main={type="hbox"}}
local ScriptWindows = {MainWindow={childs={}}}
local function SetValue(this,value)
	this.pointer[0] = value
end
local function val2pos(val)
	--return (1-val)*10000
	return val
end
local function pos2val(pos)
	return (10000-pos)*0.0001
end
local function AddControl(const)
	if const.typex == "toggle" then
		const.pointer = ffi.new("bool[1]",const.value or false)
	elseif const.typex == "vslider" or  const.typex=="hslider" then
		const.pointer = ffi.new("float[1]",val2pos(const.value or 0))
	--elseif const.typex == "text" then
	else
		const.pointer = ffi.new("float[1]",const.value or 0)
	end
	const.SetValue = SetValue
	if const.window then
		const.panel = const.panel or ScriptWindows[const.window]
	else
		const.panel = const.panel or "main"
	end	
	local container = Sizers[const.panel]
	if container.type=="gridbag" then
		const.pos = const.pos or {0,0}
		container.childs = container.childs or {}
		container.childs[const.pos[1]] = container.childs[const.pos[1]] or {}
		container.childs[const.pos[1]][const.pos[2]] = container.childs[const.pos[1]][const.pos[2]] or {}
		table.insert(container.childs[const.pos[1]][const.pos[2]],const)
		container.maxrow = container.maxrow > const.pos[1] and container.maxrow or const.pos[1]
		container.maxcol = container.maxcol > const.pos[2] and container.maxcol or const.pos[2]
	else
		container.childs = container.childs or {}
		table.insert(container.childs,const)
	end
	Controls[const.tag] = const
end
local function AddPanel(pan)
	local window = ScriptWindows[pan.window or "MainWindow"]
	table.insert(window.childs,pan)
	if pan.type == "gridbag" then
		pan.maxrow = -1
		pan.maxcol = -1
	end
	pan.parent = pan.parent or (pan.window and ScriptWindows[pan.window]) or "main"
	local parent = Sizers[pan.parent]
	if parent.type=="gridbag" then
		pan.pos = pan.pos or {0,0}
		parent.childs = parent.childs or {}
		parent.childs[pan.pos[1]] = parent.childs[pan.pos[1]] or {}
		parent.childs[pan.pos[1]][pan.pos[2]] = parent.childs[pan.pos[1]][pan.pos[2]] or {}
		table.insert(parent.childs[pan.pos[1]][pan.pos[2]],pan)
		parent.maxrow = parent.maxrow > pan.pos[1] and parent.maxrow or pan.pos[1]
		parent.maxcol = parent.maxcol > pan.pos[2] and parent.maxcol or pan.pos[2]
	else
		parent.childs = parent.childs or {}
		table.insert(parent.childs,pan)
	end
	Sizers[pan.tag] = pan
end
local function DeleteControl(v)
	Controls[v.tag] = nil
end
local function DeletePanel(v)
	Sizers[v.tag]=nil
end
local function EmptyPanel(v)
	Sizers[v.tag].childs = {}
end
local function addWindow(win)
	ScriptWindows[win.tag] = win
end
local function SetValueControl(tag,val)
		local co=Controls[tag]
		--todo could check if co==nil (not yet created or already deleted)
		if co then

				if co.typex=="toggle" then
					val= (val==1) and true or false
					co:SetValue(val)
				elseif co.typex=="button" then
					--co.control:SetValue(val)
				elseif co.typex=="vslider"  or  co.typex=="hslider" then
					co:SetValue(val2pos(val))
				elseif co.typex=="knob" then
					co:SetValue(val)
				elseif co.typex=="vumeter" then
					--co:SetValue(val)
				elseif co.typex=="newcontrol" then
					--co:SetValue(val)
				elseif co.typex=="funcgraph" then
					--co:SetValue(val)
				elseif co.typex=="funcgraph2" then
					--co:SetValue(val)
				elseif co.typex=="funcgraph3" then
					--co:SetValue(val)
				elseif co.typex=="timeplot" then
					--co:SetValue(val)
				elseif co.typex=="freqscope" then
					--co:SetValue(val)
				elseif co.typex=="scope" then
					--co:SetValue(val)
				elseif co.typex=="combo" then
					--co:SetSelection(val)
				elseif co.typex=="text" then
					co.value = tostring(val)
				elseif co.typex=="glcanvas" then
					--co:SetValue(val)
				else
					DisplayOutput("SetValueControl bad typex",true)
					prtable(co)
				end
		else
			print("SetValueControl tag "..tag.." not found")
		end
		--print("SetValueControl",tag,val)
end
local function SetLabelControl(tag,val)
--[[
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
--]]
end
local function GetValueControl(a)
end
local theLog = ig.Log()




local ShowCP
local function ShowControl(c,lev)
	--ig.Text(string.rep(" ",lev)..c.typex)
	if c.typex == "toggle" then
		if ig.Checkbox(tostring(c.label).."##"..c.tag,c.pointer) then
		end
	elseif c.typex == "button" then
		if ig.SmallButton(tostring(c.label).."##"..c.tag) then
		end
	elseif c.typex == "vslider" then
		ig.BeginGroup()
		if ig.VSliderFloat("##"..tostring(c.name)..c.tag,ig.ImVec2(20,100),c.pointer,c.min or 0,c.max or 10000) then
			scriptlinda:send("_valueChangedCb",{c.tag,c.pointer[0],nil})
		end
		ig.Text(tostring(c.label or ""))
		ig.EndGroup()
	elseif c.typex == "hslider" then
		if ig.SliderFloat(tostring(c.name).."##"..c.tag,ig.ImVec2(100,20),c.pointer,0,10000) then
		end
	elseif c.typex == "knob" then
		if ig.dial(tostring(c.name).."##"..c.tag,c.pointer,20) then
			scriptlinda:send("_valueChangedCb",{c.tag,c.pointer[0],nil})
		end
	elseif c.typex== "text" then
		ig.Text(tostring(c.value))
	else
	
		ig.Text(c.typex)
	end
end
local function ShowPanel(p,lev)
	--ig.BeginChild("panel"..tostring(p.tag),ig.ImVec2(0,0),true,ig.lib.ImGuiWindowFlags_AlwaysAutoResize)
	ig.BeginGroup()
	if p.type=="vbox" then
		if p.name then ig.Text(p.name) end
		if p.childs then
			for i,ch in ipairs(p.childs) do
				ShowCP(ch,lev+1)
			end
		else
			--ig.Text"empty"
		end
	elseif p.type == "hbox" then
		if p.name then ig.Text(p.name) end
		if p.childs then
			--ig.Columns(#p.childs)
			for i,ch in ipairs(p.childs) do
				ShowCP(ch,lev+1)
				--ig.NextColumn()
				ig.SameLine()
			end
		else
			--ig.Text"empty"
		end
		--ig.Columns(1)
		ig.NewLine()
	elseif p.type == "flexi" then
		--ig.Columns(p.cols)
		if p.childs then
			for i,ch in ipairs(p.childs) do
				local col = (i-1)%p.cols
				ShowCP(ch,lev+1)
				--ig.NextColumn()
				if col < p.cols then ig.SameLine() end
			end
		else
			--ig.Text"empty"
		end
		--ig.Columns(1)
	elseif false then --p.type == "gridbag" then
		--ig.Columns(p.maxcol+1)
		if p.childs then
			for row=0,p.maxrow do
				for col=0,p.maxcol do
					if p.childs[row] and p.childs[row][col] then
						for i,ch in ipairs(p.childs[row][col]) do
							ShowCP(ch,lev+1)
						end
					else
						ig.Text("empty"..row..","..col)
					end
					--ig.NextColumn()
					ig.SameLine()
				end
				ig.NewLine()
			end
		else
			--ig.Text"empty"
		end
		--ig.Columns(1)
	elseif p.type == "gridbag" then
		if p.childs then
			if (ig.BeginTable("test", p.maxcol+1,ig.lib.ImGuiTableFlags_Borders +ig.lib.ImGuiTableFlags_SizingFixedFit*1 + ig.lib.ImGuiTableFlags_NoHostExtendX*1)) then
				for row=0,p.maxrow do
					ig.TableNextRow()
					for col=0,p.maxcol do
						ig.TableNextColumn();
						if p.childs[row] and p.childs[row][col] then
							for i,ch in ipairs(p.childs[row][col]) do
								--ig.Text("r"..row..","..col)
								ShowCP(ch,lev+1)
							end
						else
							ig.Text("empty"..row..","..col)
						end
						--ig.NextColumn()
						--ig.SameLine()
					end
					--ig.NewLine()
				end
				
				ig.EndTable();
			end
		else
			ig.Text"empty gridbag"
		end
	elseif p.type == "collapse" then
		ig.Text"collapse panel type"
	else
		ig.Text"unknown panel type"
	end
	--ig.EndChild()
	ig.EndGroup()
	ig.GetWindowDrawList():AddRect(ig.GetItemRectMin(), ig.GetItemRectMax(), ig.U32(1,1,1,1));
end
ShowCP = function(c,lev)
	lev = lev or 0
	if c.typex then
		ShowControl(c,lev)
	else
		ShowPanel(c,lev)
	end
end
function func_draw()
	-----------------------------------
				for mes=1,1000 do
				local key,val=scriptguilinda:receive(0,"guiModify","guiSetValue","guiUpdate","guiGetValue","guiSetLabel","/vumeter","ClearScriptGUI" )
				if val then
					if type(val)=="table" then
						theLog:Add(tostring(key)..":"..tostring(val[1])..","..tostring(val[2]).."\n")
					else
						theLog:Add(tostring(key)..":"..tostring(val).."\n")
					end
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
					elseif key=="guiSetValue" then
						SetValueControl(val[1],val[2])
					elseif key=="guiUpdate" then
--[[
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
						for k,win in pairs(ScriptWindows) do
							local siz = Sizers[win]
							siz.sizer:Layout()
							siz.sizer:SetSizeHints(win)
							win:SetSizerAndFit(siz.sizer)
							-- win:Refresh()
						end
--]]
					elseif key=="guiGetValue" then
						GetValueControl(val)
					elseif key=="guiSetLabel" then
						SetLabelControl(val[1],val[2])
					elseif key=="/vumeter" then -- node,id,peak,rms
					--[=[
						local vumet=Controls[val[2]]
						if vumet then
							--prtable(val)
							--prtable(vumet)
							vumet.control:SetValue({val[4],val[3]})
						end
					--]=]
					elseif key=="ClearScriptGUI" then
						Controls = {}
						Sizers = {main={type="hbox"}}
						ScriptWindows = {MainWindow={childs={}}}
					end
				else -- nothing received
					break;
				end
			end --for
	---------------------------------
	if ig.Button("show") then
		theLog:Add("\nControls\n")
		theLog:Add(ToStr(Controls))
		theLog:Add("\nSizers\n")
		theLog:Add(ToStr(Sizers))
		theLog:Add("\nWindows\n")
		theLog:Add(ToStr(ScriptWindows))
	end
	if ig.Button("show sizers") then
		theLog:Add(ToStr(Sizers))
	end
	if ig.Button("show panel 6") then
		theLog:Add(ToStr(Sizers[6]))
	end
	if ig.Button("show panel 6B") then
		local p = Sizers[6]
		for row=0,p.maxrow do
			for col=0,p.maxcol do
				if p.childs[col] and p.childs[col][row] then
					theLog:Add(""..row.." ".. col.." "..tostring(p.childs[col][row]).." full\n")
				else
					theLog:Add(""..row.." ".. col.." "..tostring(p.childs[col][row]).." empty\n")
				end
			end
		end
		for k,v in pairs(p.childs) do
			theLog:Add(tostring(k).." type:"..type(k)..","..tostring(v).." type:"..type(v).."\n")
			if type(v)=="table" then
				for k1,v1 in pairs(v) do
					theLog:Add(" "..tostring(k1).." type:"..type(k1)..","..tostring(v1).." type:"..type(v1).."\n")
				end
			end
		end
		theLog:Add(tostring(p.childs[3][0]).."\n")
	end
	
	ig.ShowDemoWindow()
	theLog:Draw()
	if ig.Begin("MainWindow",nil,ig.lib.ImGuiWindowFlags_HorizontalScrollbar) then
		-- for i,ch in ipairs(ScriptWindows.MainWindow.childs) do
			-- ShowCP(ch,0)
		-- end
		ShowCP(Sizers.main,0)
	end
	ig.End()
	--[[
	if ig.Begin("widgets",nil, ig.lib.ImGuiWindowFlags_AlwaysAutoResize) then
		if ig.TreeNode"dial" then
			ig.dial("turns",val,nil,0.5/math.pi)
			ig.SameLine()
			ig.dial("radians",val)
			ig.TreePop();
			ig.Separator();
		end
		if ig.TreeNode"pad" then
			ig.pad("mypad", padval)
			ig.InputFloat2("vals",padval)
			ig.TreePop();
			ig.Separator();
		end
		if ig.TreeNode"curve" then
			if curve:draw(ig.ImVec2(400,300)) then
			--do something with curve.LUT array of 100 floats
			end
			ig.InputFloat2("first two",curve.LUT, nil, ig.lib.ImGuiInputTextFlags_ReadOnly)
			ig.TreePop();
			ig.Separator();
		end
		if ig.TreeNode"gizmoquat" then

			if ig.gizmo3D("###guizmo0",v3,Quat,150) then 
				mat4 = ig.mat4_pos_cast(Quat,v3)
			end
			
			ig.SameLine()
			ig.BeginGroup()
			ig.InputFloat4("##1",mat4.f, nil, ig.lib.ImGuiInputTextFlags_ReadOnly)
			ig.InputFloat4("##2",mat4.f+4, nil, ig.lib.ImGuiInputTextFlags_ReadOnly)
			ig.InputFloat4("##3",mat4.f+8, nil, ig.lib.ImGuiInputTextFlags_ReadOnly)
			ig.InputFloat4("##4",mat4.f+12, nil, ig.lib.ImGuiInputTextFlags_ReadOnly)
			ig.EndGroup()
			ig.imguiGizmo_setDirectionColor(ig.ImVec4(1,0,0,1))
			ig.gizmo3D("guizmo3",v3,150)
			ig.imguiGizmo_restoreDirectionColor()
			ig.InputFloat3("dir",ffi.new("float[3]",{v3.x,v3.y,v3.z}), nil, ig.lib.ImGuiInputTextFlags_ReadOnly)
			ig.TreePop();
			ig.Separator();
		end
	end
	ig.End()
	--]]
end




local ScriptGUI
local wakeupidletimer
function CreateScriptGUI()
	print"calling ide lane"
	--ide_lane()
	--local wxImguiCanvas = require"ide.wxImguiCanvas"
	ScriptGUI = wxImguiCanvas(managedpanel)
	--ig = wxImguiCanvas.ig
	manager:AddPane(ScriptGUI, wxaui.wxAuiPaneInfo():Name("ScriptGUI"):Right():Row(0):Layer(0):CloseButton(false):MaximizeButton(true):PaneBorder(true))
	ScriptGUI:set_imgui_func(func_draw)
	manager:Update()
	-- show the frame window
    local ID_TIMERIDLEWAKEUP = 2
	wakeupidletimer  = wx.wxTimer(frame,ID_TIMERIDLEWAKEUP)
	frame:Connect(wx.wxEVT_TIMER,
		function (event)
			local id=event:GetId()
			if id==ID_TIMERIDLEWAKEUP then
				ScriptGUI.onpaint()
			end
		end)
	
	wakeupidletimer:Start(10,false)
end

function CloseScriptGUI()
end

function ClearScriptGUI()
	scriptguilinda:send("ClearScriptGUI",true)
end