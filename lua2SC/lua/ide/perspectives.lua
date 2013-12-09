-- expected globals are frame,manager (wxauimanager),Config (from config.lua)
local ID_FullScreen = NewID()
local ID_CreatePerspective=NewID()
local ID_DeletePerspective=NewID()
local ID_FirstPerspective = NewID()
for i=1,9 do NewID() end
function Manager()
	local m = wxaui.wxAuiManager()
	function m:GetPerspective()
		local persp = m:SavePerspective()
		local panes = m:GetAllPanes()
		local notebooks = {}

		for i = 0,panes:GetCount()-1 do
			local it = panes:Item(i)
			if it then
				--if it.window:IsKindOf(wx.wxClassInfo.FindClass("wxAuiNotebook")))
				--print("Manager",it.window,it.window:GetClassInfo():GetClassName())
				if it.window:GetClassInfo():GetClassName() == "wxAuiNotebook" then
					print("notebook",it.name,it.caption)
					notebooks[it.name] = saveNotebook(it.window:DynamicCast("wxAuiNotebook"))
					--print("notebook",it.name,it.caption)
				end
			end
		end
		return {perspective = persp, notebooks = notebooks}
	end
	-- necesary after loadNotebook
	local function ResetDocumentsIndex()
		for id, document in pairs(openDocuments) do
			document.index = notebook:GetPageIndex(document.editor)
		end
	end
	function m:SetPerspective(pers)
		print("m:SetPerspective",pers)
		m:LoadPerspective(pers.perspective,true)
		for k,v in pairs(pers.notebooks) do
			loadNotebook(m:GetPane(k).window:DynamicCast("wxAuiNotebook"), v)
		end
		m:Update()
		ResetDocumentsIndex()
	end
	return m
end
function saveNotebook(nb)
  local cnt = nb:GetPageCount()
  
  local function addTo(tab,key,value)
    local out = tab[key] or {}
    table.insert(out,value)
    tab[key] = out
  end
  
  local pagesX = {}
  local pagesY = {}
  
  local str = "nblayout|"
  
  for i=1,cnt do
    local id = nb:GetPageText(i-1)
    local pg = nb:GetPage(i-1)
    local x,y = pg:GetPosition():GetXY()
    addTo(pagesX,x,id)
    addTo(pagesY,y,id)
  end
  
  local function sortedPages(tab)
    local t = {}
    for i,v in pairs(tab) do
      table.insert(t,i)
    end
    table.sort(t)
    return t
  end
  
  local sortedX = sortedPages(pagesX)
  local sortedY = sortedPages(pagesY)
  
  -- for now only support "1D" splits and prefer
  -- dimension which has more, anything else
  -- requires a more complex algorithm, yet to do
  
  local pagesUse
  local sortedUse
  local split
  
  if ( #sortedX >= #sortedY) then
    pagesUse  = pagesX
    sortedUse = sortedX
    split = "<X>"
  else
    pagesUse  = pagesY
    sortedUse = sortedY
    split = "<Y>"
  end
  
  for i,v in ipairs(sortedUse) do
    local pages = pagesUse[v]
    for n,id in ipairs(pages) do
      str = str..id.."|"
    end
    str = str..split.."|"
  end
  
  return str
end

function loadNotebook(nb,str,fnIdConvert)
  str = str:match("nblayout|(.+)")
  if (not str) then return end
  local cnt = nb:GetPageCount()
  local sel = nb:GetSelection()

  -- store old pages
  local currentpages, order = {}, {}
  for i=1,cnt do
    local id = nb:GetPageText(i-1)
    local newid = fnIdConvert and fnIdConvert(id) or id
    currentpages[newid] = currentpages[newid] or {}
    table.insert(currentpages[newid], {page = nb:GetPage(i-1), text = id, index = i-1})
    order[i] = newid
  end

  -- remove them
  for i=cnt,1,-1 do nb:RemovePage(i-1) end

  -- read them and perform splits
  local t = 0
  local newsel
  local function finishPage(page)
    if (page.index == sel) then
      newsel = t
    end
    t = t + 1
  end

  local direction
  local splits = { X = wx.wxRIGHT, Y = wx.wxBOTTOM }
  for cmd in str:gmatch("([^|]+)") do
    local instr = cmd:match("<(%w)>")
    if (not instr) then
      local id = fnIdConvert and fnIdConvert(cmd) or cmd
      local pageind = next(currentpages[id] or {})
      if (pageind) then
        local page = currentpages[id][pageind]
        currentpages[id][pageind] = nil

        nb:AddPage(page.page, page.text)
        if (direction) then nb:Split(t, direction) end
        finishPage(page)
      end
    end
    direction = instr and splits[instr]
  end
  
  -- add anything we forgot; make sure page groups are in the order specified
  for i=1,cnt do
    local pagelist = currentpages[order[i]]
    for _,page in pairs(pagelist) do
      nb:AddPage(page.page, page.text)
      finishPage(page)
    end
  end
  
  -- set the active page as it was before
  if (newsel) then nb:SetSelection(newsel) end
  --check selection
  --print("checking selection")
 -- for id, document in pairs(openDocuments) do
		--print(id,document.editor:GetId(),document.index,document.editor,nb:GetPage(document.index))
  --end
end

------------------------------------------------------------
function ConfigRestoreFramePosition(window, windowName)
	local s,x,y,w,h
	local c_framepos = Config:load_table(windowName)
	if c_framepos then
		s = c_framepos.s
		x = c_framepos.x
		y = c_framepos.y
		w = c_framepos.w
		h = c_framepos.h
	else
        x, y, w, h = wx.wxClientDisplayRect()
		s = -1
	end
	
	s = s==2 and 1 or s --iconized as maximized
	
	if (s == -1) or s == 0 then
        window:SetSize(x, y, w, h)
		local w1,h1 = frame:GetClientSizeWH()
	end
    if s == 1 then
        window:Maximize(true)
    end
end

function ConfigSaveFramePosition(window, windowName)

    local s    = 0
    local w, h = window:GetSizeWH()
    local x, y = window:GetPositionXY()

    if window:IsMaximized() then
        s = 1
    elseif window:IsIconized() then
        s = 2
    end
	
	Config:save_table(windowName,{s=s,w=w,h=h,x=x,y=y})
	print("ConfigSaveFramePosition",s,x,y,w,h)

end
---------------------perspectives
------------------------------------------------------
function ConfigSavePerspectives()
	manager:GetPerspective()
	ConfigSaveFramePosition(frame,"MainFrame")
	local config_perspectives = {}
	config_perspectives.m_perspectives = m_perspectives
	config_perspectives.m_perspectives_names = m_perspectives_names
	config_perspectives.currentperspective = currentperspective
	config_perspectives.lastPerspective = manager:GetPerspective() 
	Config:save_table("perspectives",config_perspectives)
end

function Perspectives_MakeMenu()
	for i=0,9 do
		m_perspectives_menu:Destroy(ID_FirstPerspective + i)
	end
	for i,v in ipairs(m_perspectives_names) do
		m_perspectives_menu:AppendRadioItem(ID_FirstPerspective + i - 1, v);
	end
	if currentperspective >0 then
		m_perspectives_menu:Check(ID_FirstPerspective + currentperspective -1,true)
		SetPerspective(currentperspective)
	end
end

function ConfigLoadPerspectives()
	ConfigRestoreFramePosition(frame,"MainFrame")
	local config_perspectives = Config:load_table("perspectives")
	if config_perspectives then
		m_perspectives = config_perspectives.m_perspectives
		m_perspectives_names = config_perspectives.m_perspectives_names
		--currentperspective = config_perspectives.currentperspective
		manager:SetPerspective(config_perspectives.lastPerspective)
	end
	currentperspective = 0
	Perspectives_MakeMenu()

end

function SetPerspective(val)
	print("SetPerspective",val)
	if (val >0) then
		manager:SetPerspective(m_perspectives[val]);
		currentperspective=val
	end
end

function OnCreatePerspective(event)

	if (#m_perspectives >= 9) then
		wx.wxMessageBox("Reached maximum of 9 perspectives.")
		return
	end
    local dlg = wx.wxTextEntryDialog(frame,"Enter a name for the new perspective:","wxAUI Test");

    dlg:SetValue(string.format("Perspective %u", (#m_perspectives + 1)));
    if (dlg:ShowModal() ~= wx.wxID_OK) then
        return;
    end

    --if (#m_perspectives == 0) then
    --    m_perspectives_menu:AppendSeparator();
    --end

    m_perspectives_menu:AppendRadioItem(ID_FirstPerspective + #m_perspectives, dlg:GetValue());
	table.insert(m_perspectives_names,dlg:GetValue());
	table.insert(m_perspectives, manager:GetPerspective());
	
	currentperspective = #m_perspectives
	m_perspectives_menu:Check(ID_FirstPerspective + #m_perspectives-1,true)

end
function OnDeletePerspective(event)
	if currentperspective == 0 then
		wx.wxMessageBox("There is not selected perspective.")
		return
	end
    --m_perspectives_menu:Delete(ID_FirstPerspective + currentperspective - 1);
	table.remove(m_perspectives_names,currentperspective)
	table.remove(m_perspectives,currentperspective)
	currentperspective = 0
	Perspectives_MakeMenu()
end



function InitPerspectivesMenu()

	frame:Connect(ID_CreatePerspective, wx.wxEVT_COMMAND_MENU_SELECTED, function(event) OnCreatePerspective(event) end)
	frame:Connect(ID_DeletePerspective, wx.wxEVT_COMMAND_MENU_SELECTED, function(event) OnDeletePerspective(event) end)
	--frame:Connect(ID_CopyPerspectiveCode, wx.wxEVT_COMMAND_MENU_SELECTED, function(event) OnCopyPerspectiveCode(event) end)
	frame:Connect(ID_FirstPerspective+0,ID_FirstPerspective+9, wx.wxEVT_COMMAND_MENU_SELECTED,
		function(event)
			local pers = event:GetId()- ID_FirstPerspective + 1
			print("OnRestorePerspective",pers)
			manager:SetPerspective(m_perspectives[pers]);
			currentperspective = pers 
		end)
	frame:Connect(ID_FullScreen,  wx.wxEVT_COMMAND_MENU_SELECTED,
		function(event)
			frame:ShowFullScreen(event:IsChecked(),
			--wx.wxFULLSCREEN_NOMENUBAR
			--wxFULLSCREEN_NOTOOLBAR
			--wxFULLSCREEN_NOSTATUSBAR
			wx.wxFULLSCREEN_NOBORDER
			+wx.wxFULLSCREEN_NOCAPTION )	
		end)
	
	m_perspectives = {}
	m_perspectives_names = {}
	m_perspectives_menu = wx.wxMenu();
	m_perspectives_menu:AppendCheckItem(ID_FullScreen,"&Full Screen\tCtrl+Shift+F");
	m_perspectives_menu:AppendSeparator()
	m_perspectives_menu:Append(ID_CreatePerspective,"Create Perspective");
	m_perspectives_menu:Append(ID_DeletePerspective, "Delete Perspective");
	m_perspectives_menu:AppendSeparator();
	
	menuBar:Append(m_perspectives_menu, "&View")
	ConfigLoadPerspectives()

end