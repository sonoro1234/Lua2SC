
	---[===[
local oldpr=print
require("wx")
print=oldpr

os.setlocale("C")	--to let serialize work for numbers
local ID_IDCOUNTER = wx.wxID_HIGHEST + 1
function NewID()
    ID_IDCOUNTER = ID_IDCOUNTER + 1
    return ID_IDCOUNTER
end



Config = require"ide.config"
Config:init("Lua2SCIDE", "sonoro")
config = Config.config

require"ide.settings"
require"ide.perspectives"
require"ide.findreplace"
require"ide.scriptgui"
require"ide.bootsc"
require"ide.editor"
IdentifiersList = require"ide.identifiers"
CallStack = require"ide.callstack"
require"ide.help"
require"ide.toppanel"
require"ide.idescriptrun"
require"sc.midi"


---------------------------------
-- Equivalent to C's "cond ? a : b", all terms will be evaluated
function iff(cond, a, b) if cond then return a else return b end end


-- Markers for editor marker margin
BREAKPOINT_MARKER         = 1
BREAKPOINT_MARKER_VALUE   = 2 -- = 2^BREAKPOINT_MARKER
CURRENT_LINE_MARKER       = 2
CURRENT_LINE_MARKER_VALUE = 4 -- = 2^CURRENT_LINE_MARKER

-- ASCII values for common chars
local char_CR  = string.byte("\r")
local char_LF  = string.byte("\n")

-- Global variables
programName      = nil    -- the name of the wxLua program to be used when starting debugger
editorApp        = wx.wxGetApp()

-- wxWindow variables
frame            = nil    -- wxFrame the main top level window
notebook         = nil    -- wxNotebook of editors
errorLog         = nil    -- wxStyledTextCtrl log window for messages

in_evt_focus     = false  -- true when in editor focus event to avoid recursion
openDocuments    = {}     -- open notebook editor documents[winId] = {
                          --   editor     = wxStyledTextCtrl,
                          --   index      = wxNotebook page index,
                          --   filePath   = full filepath, nil if not saved,
                          --   fileName   = just the filename,
                          --   modTime    = wxDateTime of disk file or nil,
                          --   isModified = bool is the document modified? }

exitingProgram   = false  -- are we currently exiting, ID_EXIT
wxkeywords       = nil    -- a string of the keywords for scintilla of wxLua's wx.XXX items
font             = nil    -- fonts to use for the editor
fontItalic       = nil

-- Pick some reasonable fixed width fonts to use for the editor
if wx.__WXMSW__ then
    font       = wx.wxFont(10, wx.wxFONTFAMILY_MODERN, wx.wxFONTSTYLE_NORMAL, wx.wxFONTWEIGHT_NORMAL, false,"",wx.wxFONTENCODING_CP1253 )--,wx.wxFONTENCODING_ISO8859_1)--, "Andale Mono")
    fontItalic = wx.wxFont(10, wx.wxFONTFAMILY_MODERN, wx.wxFONTSTYLE_ITALIC, wx.wxFONTWEIGHT_NORMAL, false,"",wx.wxFONTENCODING_CP1253)--,wx.wxFONTENCODING_ISO8859_1)--, "Andale Mono")
else
    font       = wx.wxFont(10, wx.wxFONTFAMILY_MODERN, wx.wxFONTSTYLE_NORMAL, wx.wxFONTWEIGHT_NORMAL, false, "")--,wx.wxFONTENCODING_ISO8859_1)
    fontItalic = wx.wxFont(10, wx.wxFONTFAMILY_MODERN, wx.wxFONTSTYLE_ITALIC, wx.wxFONTWEIGHT_NORMAL, false, "")--,wx.wxFONTENCODING_ISO8859_1)
end

-- ----------------------------------------------------------------------------


---------------------------------------------------
function DoDir(func,path,pattern,recur,level)
	level=level or 0
	if recur==nil then recur=false end
	pattern=pattern or ""
	local dir=wx.wxDir(path);
    if ( not dir:IsOpened() ) then
		print("error apertura")
		error()
        return;
    end
    --print("Enumerating object files in current directory:",dir:GetName());
    local cont,filename = dir:GetFirst(pattern,wx.wxDIR_FILES + wx.wxDIR_HIDDEN)-- filespec, flags);
    while ( cont ) do
		func(filename,level,path)
        cont,filename = dir:GetNext();
    end
	if recur then
		local cont,filename = dir:GetFirst("",wx.wxDIR_DIRS + wx.wxDIR_HIDDEN)-- filespec, flags);
		while ( cont ) do
			func(filename,level,path)
			DoDir(func,path.."\\"..filename,pattern,recur,level+1)
			cont,filename = dir:GetNext();
		end
	end
end

function abriredit(eventFileName_,line)
	eventFileName_ = wx.wxFileName(eventFileName_):GetFullPath()
	--print("abriredit",eventFileName_,line)
	if line then line=line-1 end
	--try to reuse
	for id, document in pairs(openDocuments) do
		local editor   = document.editor
		local filePath =  document.filePath
		--TODO: unix is case sensitive
		--check that now
		if filePath and string.upper(filePath) == string.upper(eventFileName_) and filePath ~=eventFileName_ then
			wx.wxMessageBox("different case in filepath xxxxxxxxx " .. filePath .. " " ..eventFileName_)
		end
		----------------------------
		--if filePath and string.upper(filePath) == string.upper(eventFileName_) then
		if filePath and filePath == eventFileName_ then
			--print("reuse ",filePath , eventFileName_)
			editor:MarkerDeleteAll(CURRENT_LINE_MARKER)
			local selection = document.index
			notebook:SetSelection(selection)
			SetEditorSelection(selection)
			if line then
                editor:SetSelection(editor:PositionFromLine(line), editor:GetLineEndPosition(line))
				editor:MarkerAdd(line, CURRENT_LINE_MARKER)
				editor:EnsureVisibleEnforcePolicy(line)
			end
			return true
		end
    end
	local editor = LoadFile(eventFileName_, nil, true)
    if editor then
        if line then
			editor:SetSelection(editor:PositionFromLine(line), editor:GetLineEndPosition(line))
			editor:MarkerAdd(line, CURRENT_LINE_MARKER)
			editor:EnsureVisibleEnforcePolicy(line)
		end
		
        --editor:SetReadOnly(true)
        return true
	else
		return false
	end
end
function ideGetScriptLaneStatus()
	local tmplinda = lanes.linda()
	mainlinda:send("GetScriptLaneStatus",tmplinda)
	local key,val=tmplinda:receive(3,"GetScriptLaneStatusResp")
	if key then
		return val
	else --timeout
		return nil
	end
end
function checkendScript(lane)
	if not lane then return true end
	local status=ideGetScriptLaneStatus()
	if status=="error" or status=="done" or status=="cancelled" or status=="killed" then
		print("checkend status ",status)
	end
	if status=="error" or status=="done" or status=="cancelled" then --or status=="killed" then
		print("checkend ffinished",status)
		EnableDebugCommands(false,false)
		return true
	end
	return false
end
function checkend(lane)
	if not lane then return true end
	local status=lane.status
	if status=="error" or status=="done" or status=="cancelled" or status=="killed" then
		print("checkend status ",status)
	end
	if status=="error" or status=="done" or status=="cancelled" then --or status=="killed" then
		print("checkend ffinished",status)
		EnableDebugCommands(false,false)
		return true
	end
	return false
end
function checkendBAK(lane)
	if not lane then return true end
	local status=lane.status
	--print("checkend status ",status)
	if status=="error" or status=="done" or status=="cancelled" or status=="killed" then
		print("checkend ffinished",status)
		--do return true end
		print"going to join"
		local v,err,stack_tbl= lane:join(0.1)
		print("checkend post lane:join")
		EnableDebugCommands(false,false)
		if v==nil then
			if err then
				local onlyerrorst=err:match(":%d+:(.+)")
				print( "Error: "..tostring(err).."\n" )
				--idlelinda:send("prerror","Error: "..tostring(err).."\n"..tostring(onlyerrorst).."\n")
				if  type(stack_tbl)=="table"  then
					local function compile_error(err)
						local info = {}
						--catch error from require
						local err2=err:match("from file%s+'.-':.-([%w%p]*:%d+:)")
						--catch error from loadfile
						if not err2 then
							err2 = err:match("loadfile error:([%w%p]*:%d+:)")
						end
						if err2 then
							info.source="@"..err2:match(":-(.-):%d*:")
							info.currentline=err2:match(":(%d*):")
							return info
						end
					end
					local info=compile_error(err)
					if (info) then
						print("comp err source: ",info.source)
						print("comp err line: ",info.currentline)
						local stack_tbl2={}
						for i,v in ipairs(stack_tbl) do
							stack_tbl2[i+1]=stack_tbl[i]
						end
						stack_tbl2[1]=info
						stack_tbl=stack_tbl2
					end
					print("print stack table")
					prtable(stack_tbl)
					--io.stderr:write( "\t", table.concat(stack_tbl,"\n\t"), "\n" );
					for k,v in ipairs(stack_tbl) do
						if v.what~="C" then
							abriredit(v.source:sub(2),v.currentline)
							break
						end
					end
					
					CallStack:MakeStack(stack_tbl,onlyerrorst)
				else
					print( "checkend no stack" );
				end
			else
				print( "checkend time out" );
			end
		else
			print("lane returns:",v)
		end
		--print("hiding panel")
		--manager:GetPane(panel):Hide()
		return true
	end
	return false
end
function CreateLog()
	local errorLog = wxstc.wxStyledTextCtrl(managedpanel,--notebookLogs,
	wx.wxID_ANY, wx.wxDefaultPosition, wx.wxDefaultSize,wx.wxBORDER_NONE )
	--errorLog:Show(false)
	errorLog:SetFont(font)
	errorLog:StyleSetFont(wxstc.wxSTC_STYLE_DEFAULT, font)
	--errorLog:SetCodePage(wxstc.wxSTC_CP_UTF8)
	errorLog:SetCodePage(0)
	for i = 0, 32 do
        errorLog:StyleSetCharacterSet(i, wxstc.wxSTC_CHARSET_ANSI)
    end
	errorLog:StyleClearAll()
	errorLog:StyleSetForeground(1,  wx.wxColour(128, 0, 0)) -- error
	errorLog:SetMarginWidth(1, 16) -- marker margin
	errorLog:SetMarginType(1, wxstc.wxSTC_MARGIN_SYMBOL);
	errorLog:MarkerDefine(CURRENT_LINE_MARKER, wxstc.wxSTC_MARK_ARROWS, wx.wxBLACK, wx.wxWHITE)
	errorLog:SetReadOnly(true)
	errorLog:SetUseTabs(true)
	errorLog:SetTabWidth(4)
	errorLog:SetIndent(4)
	--errorLog:SetUseHorizontalScrollBar(false)
	errorLog:Connect(wx.wxEVT_SET_FOCUS,function (event)
					currentSTC=errorLog
					event:Skip()
				end)
	--errorLog:SetWrapMode(1)
	return errorLog
end
--ok with cycles
local function tableTotree(t,dometatables,tree)
	local strTG = {}
	local basicToStr=tostring
	if type(t) ~="table" then  return basicToStr(t) end
	local recG = 0
	local nameG="SELF"..recG
	local ancest ={}
	local root = tree:AddRoot("Root",-1)
	local function _ToStr(t,strT,rec,name,tparent)
		if ancest[t] then
			strT[#strT + 1]=ancest[t]
			tree:AppendItem(tparent,ancest[t])
			return
		end
		rec = rec + 1
		ancest[t]=name
		strT[#strT + 1]='{'
		--local tlevel = tree:AppendItem(tparent,name)
		local count=0
		-------------
		--if t.name then strT[#strT + 1]=string.rep("\t",rec).."name:"..tostring(t.name) end
		----------------
---[[
		local sorted_names = {}
		for k,v in pairs(t) do
			table.insert(sorted_names, k)
		end
		table.sort(sorted_names,function(a,b) return tostring(a) < tostring(b) end)
		-----------------
		for _, namek in ipairs(sorted_names) do

			local k,v = namek,t[namek]
--]]
			
		--for k,v in pairs(t) do
			local str = ""
			count=count+1
			strT[#strT + 1]="\n"
			local kstr
			if type(k) == "table" then
				local name2=string.format("%s.KEY%d",name,count)
				strT[#strT + 1]=string.rep("\t",rec).."["
				local strTK = {}
				_ToStr(k,strTK,rec,name2)
				kstr=table.concat(strTK)
				strT[#strT + 1]=kstr.."]="
			else
				kstr = basicToStr(k)
				strT[#strT + 1]=string.rep("\t",rec).."["..kstr.."]="
				str = str .. kstr
			end
			
			if type(v) == "table" then
					local name2=string.format("%s[%s]",name,kstr)
					local tlev2 = tree:AppendItem(tparent,kstr .. " : " .. tostring(v))
					_ToStr(v,strT,rec,name2,tlev2)
			else
				strT[#strT + 1]=basicToStr(v)
				str = str .. " : ".. basicToStr(v)
				tree:AppendItem(tparent,str)
			end
		end
		if dometatables then
			local mt = getmetatable(t)
			if mt then
				local namemt = string.format("%s.METATABLE",name)
				local strMT = {}
				local tlev2 = tree:AppendItem(tparent,namemt)
				_ToStr(mt,strMT,rec,namemt,tlev2)
				local metastr=table.concat(strMT)
				strT[#strT + 1] = "\n"..string.rep("\t",rec).."[METATABLE]="..metastr
			end
		end
		strT[#strT + 1]='}'
		rec = rec - 1
		return
	end
	_ToStr(t,strTG,recG,nameG,root)
	return table.concat(strTG)
end
function CreateTreeLog()
	local tree = wx.wxTreeCtrl(managedpanel,wx.wxID_ANY, wx.wxDefaultPosition, wx.wxDefaultSize,wx.wxBORDER_NONE + wx.wxTR_HIDE_ROOT + wx.wxTR_HAS_BUTTONS  )
	function tree:ShowTable(t)
		tree:DeleteAllItems()
		tableTotree(t,true,tree)
		--tree:Expand(tree:GetRootItem())
        local root = tree:GetRootItem()
        local child, cookie = tree:GetFirstChild(root)
        while child:IsOk() do
            tree:Expand(child)
            child, cookie = tree:GetNextChild(root,cookie)
        end
	end
	return tree
end
function AppInit()



	frame = wx.wxFrame(wx.NULL, wx.wxID_ANY, "Lua2SC",wx.wxDefaultPosition, wx.wxSize(800, 600),wx.wxBORDER_SIMPLE + wx.wxDEFAULT_FRAME_STYLE )
	-- wrap into protected call as DragAcceptFiles fails on MacOS with
	-- wxwidgets 2.8.12 even though it should work according to change notes
	-- for 2.8.10: "Implemented wxWindow::DragAcceptFiles() on all platforms."
	pcall(function() frame:DragAcceptFiles(true) end)
	frame:Connect(wx.wxEVT_DROP_FILES,function(evt)
			local files = evt:GetFiles()
			if not files or #files == 0 then return end
			for i,f in ipairs(files) do
				LoadFile(f,nil,true)
			end
		end)
	managedpanel = wx.wxPanel(frame, wx.wxID_ANY)
	
	manager = Manager() 
	manager:SetManagedWindow(managedpanel);
		
	statusBar = frame:CreateStatusBar( 5 )
	local status_txt_width = statusBar:GetTextExtent("OVRW")
	frame:SetStatusWidths({-1, status_txt_width, status_txt_width, status_txt_width*5,-1})
	frame:SetStatusText("Welcome to Lua2SC")
	
	toppanel = CreateTopPanel()
	
	local mainsizer = wx.wxBoxSizer(wx.wxVERTICAL)
	mainsizer:Add(toppanel.window,0,wx.wxGROW)
	mainsizer:Add(managedpanel,1,wx.wxGROW)
	frame:SetSizer(mainsizer)
	mainsizer:SetSizeHints(frame)

	-- ----------------------------------------------------------------------------
	-- Add the child windows to the frame

	notebook = wxaui.wxAuiNotebook(managedpanel, wx.wxID_ANY,
                         wx.wxDefaultPosition, wx.wxDefaultSize,
                         --wx.wxCLIP_CHILDREN + wx.wxBORDER_NONE + 
						 wxaui.wxAUI_NB_CLOSE_ON_ACTIVE_TAB + wxaui.wxAUI_NB_TAB_MOVE + wxaui.wxAUI_NB_WINDOWLIST_BUTTON + wxaui.wxAUI_NB_SCROLL_BUTTONS )

	notebook:Connect(wxaui.wxEVT_COMMAND_AUINOTEBOOK_PAGE_CHANGED,--wx.wxEVT_COMMAND_NOTEBOOK_PAGE_CHANGED,
        function (event)
            if not exitingProgram then
                SetEditorSelection(event:GetSelection())
				local editor   = GetEditor(event:GetSelection())
				local id       = editor:GetId()
				--print("id",id)
				if(openDocuments[id]) then
					frame:SetTitle(openDocuments[id].filePath or "")
				end
            end
            event:Skip() -- skip to let page change
			--wx.wxMessageBox(wxT("pagina cambia"));
        end)
	notebook:Connect(wx.wxID_ANY, wxaui.wxEVT_COMMAND_AUINOTEBOOK_PAGE_CLOSE, function(evt)
			--local ctrl = evt:GetEventObject():DynamicCast("wxAuiNotebook");
			--if (ctrl:GetPage(evt:GetSelection()):IsKindOf(wx.wxClassInfo.FindClass("wxHtmlWindow"))) then
			local editor = GetEditor()
            local id     = editor:GetId()
            if SaveModifiedDialog(editor, true) ~= wx.wxID_CANCEL then
                RemovePage(openDocuments[id].index)
			else
				evt:Veto();
            end
			evt:Skip()
		end)
	--------------- notebookLogs
	notebookLogs = wxaui.wxAuiNotebook(managedpanel, wx.wxID_ANY,
                         wx.wxDefaultPosition, wx.wxDefaultSize,
                          wxaui.wxAUI_NB_TAB_MOVE  + wxaui.wxAUI_NB_TAB_SPLIT) --   + wxaui.wxAUI_NB_TAB_EXTERNAL_MOVE

	errorLog = CreateLog()
	ScLog = CreateLog()
	DebugLog = CreateTreeLog()
	
	notebookLogs:AddPage(errorLog, "Log", true)
	notebookLogs:AddPage(ScLog, "SC Log", false)
	notebookLogs:AddPage(CallStack:Create(managedpanel).window, "Call stack", false)
	notebookLogs:AddPage(DebugLog, "DebugLog", false)
	
	--------- manager
	manager:AddPane(notebook, wxaui.wxAuiPaneInfo():Name("notebook"):CenterPane():CloseButton(false):PaneBorder(false))
	manager:AddPane(notebookLogs, wxaui.wxAuiPaneInfo():Name("notebookLogs"):Bottom():CaptionVisible(false):CloseButton(false):PaneBorder(false):MinSize(100,100):BestSize(200,200):FloatingSize(400,200));
	manager:AddPane(IdentifiersList:Create(managedpanel).window, wxaui.wxAuiPaneInfo():Name("IdentifiersList"):Right():Row(1):Layer(0):CloseButton(false):CaptionVisible(false):PaneBorder(false))
	
	CreateScriptGUI()


	-- ---------------------------------------------------------------------------
	-- Finish creating the frame and show it
	
	manager:GetArtProvider():SetMetric(wxaui.wxAUI_DOCKART_PANE_BORDER_SIZE,2)
	manager:GetArtProvider():SetMetric(wxaui.wxAUI_DOCKART_SASH_SIZE,2)
	--manager:GetArtProvider():SetMetric(wxaui.wxAUI_DOCKART_CAPTION_SIZE,7)
	manager:GetArtProvider():SetMetric(wxaui.wxAUI_DOCKART_GRADIENT_TYPE, wxaui.wxAUI_GRADIENT_NONE)
	manager:Update()
	ConfigLoadOpenDocuments(Config)
	
	if notebook:GetPageCount() > 0 then
		notebook:SetSelection(0)
	else
		local editor = NewFile()
	end
	
	--frame:SetIcon(wxLuaEditorIcon) --FIXME add this back
	local bitmap = wx.wxBitmap(require"ide.LUA_xpm")
    local icon = wx.wxIcon()
    icon:CopyFromBitmap(bitmap)
    frame:SetIcon(icon)
    bitmap:delete()
    icon:delete()
	
	frame:Show(true)
	--wx.wxToolTip.Enable(true)
	notebookLogs:SetArtProvider(wxaui.wxAuiSimpleTabArt())--wxAuiDefaultTabArt wxAuiSimpleTabArt
	notebook:SetArtProvider(wxaui.wxAuiSimpleTabArt())
	--notebookLogs:Refresh();
	notebookLogs:Split(notebookLogs:GetPageIndex(errorLog),wx.wxLEFT)
	--InitUdP()
	---------
	menuBar = wx.wxMenuBar()
	InitFileMenu()
	InitEditMenu()
	InitFindMenu()
	InitRunMenu()
	InitSCMenu()
	InitPerspectivesMenu()
	InitDocumentsMenu()
	InitHelpMenu()
	frame:Connect(wx.wxEVT_CLOSE_WINDOW, CloseWindow)
	frame:SetMenuBar(menuBar)
	manager:Update()
	--------
	--midilane = pmidi.gen(this_file_settings.options.midiin, this_file_settings.options.midiout, lanes ,scriptlinda,midilinda,{print=thread_print,
	--prerror=thread_error_print,
	--prtable=prtable,idlelinda = idlelinda})
	
	-- print"globals"
	-- for k,v in pairs(_G) do
	-- print(k,v)
	-- end
	-- print("ID_CANCEL_BUTTON",ID_CANCEL_BUTTON)
end

--from ZeroBrane
function fixUTF8(s, replacement)
  local p, len, invalid = 1, #s, {}
  while p <= len do
    if     p == s:find("[%z\1-\127]", p) then p = p + 1
    elseif p == s:find("[\194-\223][\128-\191]", p) then p = p + 2
    elseif p == s:find(       "\224[\160-\191][\128-\191]", p)
        or p == s:find("[\225-\236][\128-\191][\128-\191]", p)
        or p == s:find(       "\237[\128-\159][\128-\191]", p)
        or p == s:find("[\238-\239][\128-\191][\128-\191]", p) then p = p + 3
    elseif p == s:find(       "\240[\144-\191][\128-\191][\128-\191]", p)
        or p == s:find("[\241-\243][\128-\191][\128-\191][\128-\191]", p)
        or p == s:find(       "\244[\128-\143][\128-\191][\128-\191]", p) then p = p + 4
    else
      s = s:sub(1, p-1)..replacement..s:sub(p+1)
      table.insert(invalid, p)
    end
  end
  return s, invalid
end
function fixSTCOutput(s)
	s = s:gsub("[\128-\255]","\022")
    return s:gsub("[^%w%s%p]+",function(m) return string.format("%q",m) end)
end
function DisplayOutput(message, iserror)
	--print("DisplayOutput",message)
	--message = wx.wxString(message):ToUTF8()
	--message = fixUTF8(message,"\022")
	message = fixSTCOutput(message)
	--print("DisplayOutput",message)
	local wlen=string.len(message)
	local pos=errorLog:GetLength()
    
    errorLog:SetReadOnly(false)
    errorLog:AppendText(message)
    
    errorLog:GotoPos(errorLog:GetLength())
	if iserror then
        --errorLog:MarkerAdd(errorLog:GetLineCount()-1, CURRENT_LINE_MARKER)
		errorLog:StartStyling(pos,255)
		errorLog:SetStyling(wlen,1)
    end
	errorLog:SetReadOnly(true)
	--if currentSTCed then currentSTCed:SetFocus() end
end

function ClearLog(LogW)
    LogW:SetReadOnly(false)
    LogW:ClearAll()
    LogW:SetReadOnly(true)
end

function DisplayLog(message, LogW)
    LogW:SetReadOnly(false)
    LogW:AppendText(message)
    LogW:GotoPos(LogW:GetLength())
	LogW:SetReadOnly(true)
end

function ConfigSaveOpenDocuments(config)
	local config_openDocuments={}
	local sortedDocs = {}
	for id, document in pairs(openDocuments) do
					sortedDocs[#sortedDocs + 1] = {name = notebook:GetPageText(document.index),
												document = document}
	end
	table.sort(sortedDocs, function(a, b) return string.upper(a.name) < string.upper(b.name) end)
	for i,v in ipairs(sortedDocs) do
		config_openDocuments[#config_openDocuments +1]=v.document.filePath
		print(v.document.filePath)
	end
	---table.sort(config_openDocuments,function(a,b) return string.upper(a) < string.upper(b) end)
	config_openDocuments.lastDirectory = lastDirectory
	config:save_table("openDocuments",config_openDocuments)
end
function ConfigLoadOpenDocuments(config)
	--print"ConfigLoadOpenDocuments"
	local config_openDocuments = config:load_table("openDocuments")
	--prtable(config_openDocuments)
	if config_openDocuments then
		for i,v in ipairs(config_openDocuments) do
			print(v)
			abriredit(v)
		end
		lastDirectory = config_openDocuments.lastDirectory
	end
	--print"ConfigLoadOpenDocuments end"
end
-- ----------------------------------------------------------------------------
-- Get/Set notebook editor page, use nil for current page, returns nil if none
function GetEditor(selection)
    local editor = nil
    if selection == nil then
        selection = notebook:GetSelection()
    end
    if (selection >= 0) and (selection < notebook:GetPageCount()) then
        editor = notebook:GetPage(selection):DynamicCast("wxStyledTextCtrl")
    end
    return editor
end

-- init new notebook page selection, use nil for current page
function SetEditorSelection(selection)
    local editor = GetEditor(selection)
    if editor then
        editor:SetFocus()
        editor:SetSTCFocus(true)
        IsFileAlteredOnDisk(editor)
    end
    UpdateStatusText(editor) -- update even if nil
end

-- ----------------------------------------------------------------------------
-- Update the statusbar text of the frame using the given editor.
--  Only update if the text has changed.
statusTextTable = { "OVR?", "R/O?", "Cursor Pos","CodeP" }

function UpdateStatusText(editor)
    local texts = { "", "", "" }
    if frame and editor then
        local pos  = editor:GetCurrentPos()
        local line = editor:LineFromPosition(pos)
        local col  = 1 + pos - editor:PositionFromLine(line)

        texts = { iff(editor:GetOvertype(), "OVR", "INS"),
                  iff(editor:GetReadOnly(), "R/O", "R/W"),
                  "Ln "..tostring(line + 1).." Col "..tostring(col), 
				  "CodeP "..tostring(editor:GetCodePage())}

        for n = 1, 4 do
            if (texts[n] ~= statusTextTable[n]) then
                frame:SetStatusText(texts[n], n)
                statusTextTable[n] = texts[n]
            end
        end
    end
end

-- ----------------------------------------------------------------------------
-- Get file modification time, returns a wxDateTime (check IsValid) or nil if
--   the file doesn't exist
function GetFileModTime(filePath)
    if filePath and (string.len(filePath) > 0) then
        local fn = wx.wxFileName(filePath)
        if fn:FileExists() then
            return fn:GetModificationTime()
        end
    end

    return nil
end

-- Check if file is altered, show dialog to reload it
function IsFileAlteredOnDisk(editor)
    if not editor then return end

    local id = editor:GetId()
    if openDocuments[id] then
        local filePath   = openDocuments[id].filePath
        local fileName   = openDocuments[id].fileName
        local oldModTime = openDocuments[id].modTime

        if filePath and (string.len(filePath) > 0) and oldModTime and oldModTime:IsValid() then
            local modTime = GetFileModTime(filePath)
            if modTime == nil then
                openDocuments[id].modTime = nil
                wx.wxMessageBox(fileName.." is no longer on the disk.",
                                "Lua2SC Message",
                                wx.wxOK + wx.wxCENTRE, frame)
            elseif modTime:IsValid() and oldModTime:IsEarlierThan(modTime) then
                local ret = wx.wxMessageBox(fileName.." has been modified on disk.\nDo you want to reload it?",
                                            "Lua2SC Message",
                                            wx.wxYES_NO + wx.wxCENTRE, frame)
                if ret ~= wx.wxYES or LoadFile(filePath, editor, true) then
                    openDocuments[id].modTime = nil
                end
            end
        end
    end
end

-- Set if the document is modified and update the notebook page text
function SetDocumentModified(id, modified)
    local pageText = openDocuments[id].fileName or "untitled.lua"

    if modified then
        pageText = "* "..pageText
    end

    openDocuments[id].isModified = modified
    notebook:SetPageText(openDocuments[id].index, pageText)
end



function IsLuaFile(filePath)
    return filePath and (string.len(filePath) > 4) and
           (string.lower(string.sub(filePath, -4)) == ".lua")
end



--]]


function InitDocumentsMenu()
	local ID_DOCS=NewID()
	local ID_CLOSEALL=NewID()
	local ID_CLOSEALL_BUT_THIS=NewID()
	local ID_SORT_DOCS = NewID()
	local docsMenu=wx.wxMenu({
								{ ID_CLOSEALL,"Close All","Close All" },
								{ ID_CLOSEALL_BUT_THIS,"Close All But this","Close All But this" },
								{ ID_SORT_DOCS,"Sort Alphabetic","Order Documents" },
								{}
							})
	menuBar:Append(docsMenu, "Documents")
	frame:Connect(ID_CLOSEALL, wx.wxEVT_COMMAND_MENU_SELECTED,function(event)
				-- local editor = GetEditor()
				-- local id     = editor:GetId()
				-- if SaveModifiedDialog(editor, true) ~= wx.wxID_CANCEL then
					-- RemovePage(openDocuments[id].index,true)
				-- end
				for id, document in pairs(openDocuments) do
					if (SaveModifiedDialog(document.editor, true) ~= wx.wxID_CANCEL) then
						document.isModified = false
						RemovePage(openDocuments[id].index,true)
					end
				end
		end)
	frame:Connect(ID_CLOSEALL_BUT_THIS, wx.wxEVT_COMMAND_MENU_SELECTED,function(event)
				local editor = GetEditor()
				local thisid     = editor:GetId()
				for id, document in pairs(openDocuments) do
					if (thisid~=id) and (SaveModifiedDialog(document.editor, true) ~= wx.wxID_CANCEL) then
						document.isModified = false
						RemovePage(openDocuments[id].index,true)
					end
				end
		end)
	frame:Connect(ID_SORT_DOCS, wx.wxEVT_COMMAND_MENU_SELECTED,function(event)
				local editor = GetEditor()
				local thisid     = editor:GetId()
				local sortedDocs = {}
				for id, document in pairs(openDocuments) do
					sortedDocs[#sortedDocs + 1] = {name = notebook:GetPageText(document.index),
												document = document}
				--	notebook:RemovePage(document.index)
				end
				while notebook:GetPageCount() > 0 do
					notebook:RemovePage(0)
				end
				table.sort(sortedDocs, function(a, b) return string.upper(a.name) < string.upper(b.name) end)
				for i, v in ipairs(sortedDocs) do
					notebook:AddPage(v.document.editor, v.name, true)
					v.document.index = notebook:GetSelection()
				end
				notebook:SetSelection(openDocuments[thisid].index)
		end)
end
-- -----------------------------------------------------------------
function InitFileMenu()
	local ID_NEW              = wx.wxID_NEW
	local ID_OPEN             = wx.wxID_OPEN
	local ID_CLOSE            = NewID()
	local ID_SAVE             = wx.wxID_SAVE
	local ID_SAVEAS           = wx.wxID_SAVEAS
	local ID_SAVEALL          = NewID()
	local ID_EXIT             = wx.wxID_EXIT
	fileMenu = wx.wxMenu({
			{ ID_NEW,     "&New\tCtrl-N",        "Create an empty document" },
			{ ID_OPEN,    "&Open...\tCtrl-O",    "Open an existing document" },
			{ ID_CLOSE,   "&Close page\tCtrl+W", "Close the current editor window" },
			{ },
			{ ID_SAVE,    "&Save\tCtrl-S",       "Save the current document" },
			{ ID_SAVEAS,  "Save &As...\tAlt-S",  "Save the current document to a file with a new name" },
			{ ID_SAVEALL, "Save A&ll...\tCtrl-Shift-S", "Save all open documents" },
			{ },
			{ ID_EXIT,    "E&xit\tAlt-X",        "Exit Program" }})
	menuBar:Append(fileMenu, "&File")
	local ID_MRU=NewID()
	mruMenu=wx.wxMenu()
	fileMenu:Append(ID_MRU,"Recent Files",mruMenu)
	file_history=wx.wxFileHistory()
	file_history:Load(Config.config)
	file_history:UseMenu(mruMenu)
	file_history:AddFilesToMenu()
	
	frame:Connect(ID_NEW, wx.wxEVT_COMMAND_MENU_SELECTED, NewFile)
	frame:Connect(wx.wxID_FILE1, wx.wxID_FILE9, wx.wxEVT_COMMAND_MENU_SELECTED, function(event)
			--print(file_history:GetHistoryFile(event:GetId() - wx.wxID_FILE1))
			local file=file_history:GetHistoryFile(event:GetId() - wx.wxID_FILE1)
			local ret=abriredit(file)
			if not ret then
				wx.wxMessageBox("Unable to load file '"..file.."'.",
								"Lua2SC Error",
								wx.wxOK + wx.wxCENTRE, frame)
				file_history:RemoveFileFromHistory(event:GetId() - wx.wxID_FILE1)
			end
		end)
	frame:Connect(ID_OPEN, wx.wxEVT_COMMAND_MENU_SELECTED, OpenFile)
	frame:Connect(ID_SAVE, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				local editor   = GetEditor()
				local id       = editor:GetId()
				local filePath = openDocuments[id].filePath
				SaveFile(editor, filePath)
			end)
	
	frame:Connect(ID_SAVE, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				if editor then
					local id = editor:GetId()
					if openDocuments[id] then
						event:Enable(openDocuments[id].isModified)
					end
				end
			end)
	frame:Connect(ID_SAVEAS, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				local editor = GetEditor()
				SaveFileAs(editor)
			end)
	frame:Connect(ID_SAVEAS, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				event:Enable(editor ~= nil)
			end)
	
	frame:Connect(ID_SAVEALL, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				SaveAll()
			end)
	
	frame:Connect(ID_SAVEALL, wx.wxEVT_UPDATE_UI,
			function (event)
				local atLeastOneModifiedDocument = false
				for id, document in pairs(openDocuments) do
					if document.isModified then
						atLeastOneModifiedDocument = true
						break
					end
				end
				event:Enable(atLeastOneModifiedDocument)
			end)
	
	frame:Connect(ID_CLOSE, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				local editor = GetEditor()
				local id     = editor:GetId()
				if SaveModifiedDialog(editor, true) ~= wx.wxID_CANCEL then
					RemovePage(openDocuments[id].index,true)
				end
			end)
	
	frame:Connect(ID_CLOSE, wx.wxEVT_UPDATE_UI,
			function (event)
				event:Enable((GetEditor() ~= nil))
			end)
	frame:Connect( ID_EXIT, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				if not SaveOnExit(true) then return end
				frame:Close() -- will handle wxEVT_CLOSE_WINDOW
				--CloseWatchWindow()
				CloseScriptGUI()
			end)
end
------------------------------------------
function NewFile(event)
    local editor = CreateEditor("untitled.lua")
	frame:SetTitle("untitled.lua")
	--[[
	print("codepage",editor:GetCodePage())
	local _text = ""
	for i=0,255 do
		_text = _text .. string.char(i) .. string.format(" represents %4d\r\n",i)
	end
	local text2,rep = fixUTF8(_text,"\22")
	--editor:AddText(wx.wxString(text2))
	editor:AddTextRaw(_text)
	--]]
    --SetupKeywords(editor, true)
	return editor
end



-- Find an editor page that hasn't been used at all, eg. an untouched NewFile()
function FindDocumentToReuse()
    local editor = nil
    for id, document in pairs(openDocuments) do
        if (document.editor:GetLength() == 0) and
           (not document.isModified) and (not document.filePath) and
           not (document.editor:GetReadOnly() == true) then
            editor = document.editor
			print("FindDocumentToReuse",document.filePath)
            break
        end
    end
    return editor
end

function LoadFile(filePath, editor, file_must_exist)
    local file_text = ""
    local handle = io.open(filePath, "rb")
    if handle then
        file_text = handle:read("*a")
        handle:close()
    elseif file_must_exist then
        return nil
    end

    if not editor then
        editor = FindDocumentToReuse()
    end
    if not editor then
        editor = CreateEditor(wx.wxFileName(filePath):GetFullName() or "untitled.lua")
     end

    editor:Clear()
    editor:ClearAll()
    --SetupKeywords(editor, IsLuaFile(filePath))
    editor:MarkerDeleteAll(BREAKPOINT_MARKER)
    editor:MarkerDeleteAll(CURRENT_LINE_MARKER)
    editor:AppendText(file_text)
    editor:EmptyUndoBuffer()
    local id = editor:GetId()
    openDocuments[id].filePath = filePath
    openDocuments[id].fileName = wx.wxFileName(filePath):GetFullName()
    openDocuments[id].modTime = GetFileModTime(filePath)
	
    SetDocumentModified(id, false)
    editor:Colourise(0, -1)
	--openDocuments[id].identifiers=MakeIdentifiers(editor)
	frame:SetTitle(filePath or "")
	IdentifiersList:SetEditor(editor)
    return editor
end
lastDirectory=""
function OpenFile(event)
    local fileDialog = wx.wxFileDialog(frame, "Open file",
                                       lastDirectory,
                                       "",
                                       "Lua files (*.lua)|*.lua|Text files (*.txt)|*.txt|All files (*)|*",
                                       wx.wxFD_OPEN + wx.wxFD_FILE_MUST_EXIST)
    if fileDialog:ShowModal() == wx.wxID_OK then
        --if not LoadFile(fileDialog:GetPath(), nil, true) then
		if not abriredit(fileDialog:GetPath(), nil) then
            wx.wxMessageBox("Unable to load file '"..fileDialog:GetPath().."'.",
                            "Lua2SC Error",
                            wx.wxOK + wx.wxCENTRE, frame)
		else
			file_history:AddFileToHistory(fileDialog:GetPath())
			lastDirectory=fileDialog:GetDirectory()
        end
    end
    fileDialog:Destroy()
end

function _FileSelector(path,pattern,save)
	local msg,flags
	if save then
		msg = "Save file as"
		flags = wx.wxFD_SAVE + wx.wxFD_OVERWRITE_PROMPT 
	else
		msg = "Open file"
		flags = wx.wxFD_OPEN + wx.wxFD_FILE_MUST_EXIST 
	end
	pattern= pattern or "*"
	path=path or lastDirectory
	local ret=""
    local fileDialog = wx.wxFileDialog(frame, msg,
                                       path,
                                       "",
                                       pattern.." files (*."..pattern..")|*."..pattern.."|All files (*)|*",
                                       flags)
    if fileDialog:ShowModal() == wx.wxID_OK then
        ret= fileDialog:GetPath()
		lastDirectory=fileDialog:GetDirectory()
    end
    fileDialog:Destroy()
	return ret
end


-- save the file to filePath or if filePath is nil then call SaveFileAs
function SaveFile(editor, filePath)
    if not filePath then
        local saved =SaveFileAs(editor)
		if saved then
			IdentifiersList:SetEditor(editor)
		end
    else
        local backPath = filePath..".bak"
        os.remove(backPath)
        os.rename(filePath, backPath)

        local handle = io.open(filePath, "wb")
        if handle then
            local st = editor:GetText()
            handle:write(st)
            handle:close()
            editor:EmptyUndoBuffer()
            local id = editor:GetId()
            openDocuments[id].filePath = filePath
            openDocuments[id].fileName = wx.wxFileName(filePath):GetFullName()
            openDocuments[id].modTime  = GetFileModTime(filePath)
            SetDocumentModified(id, false)
			IdentifiersList:SetEditor(editor)
            return true
        else
            wx.wxMessageBox("Unable to save file '"..filePath.."'.",
                            "Lua2SC Error Saving",
                            wx.wxOK + wx.wxCENTRE, frame)
        end
    end

    return false
end


function SaveFileAs(editor)
    local id       = editor:GetId()
    local saved    = false
    local fn       = wx.wxFileName(openDocuments[id].filePath or lastDirectory.."\\untitled.lua")
	--print("openDocuments[id].filePath",openDocuments[id].filePath)
	--print("lastDirectory",lastDirectory)
	
    fn:Normalize() -- want absolute path for dialog
	--print("fn es:",fn:GetPath(wx.wxPATH_GET_VOLUME))
    local fileDialog = wx.wxFileDialog(frame, "Save file as",
                                       fn:GetPath(wx.wxPATH_GET_VOLUME),
                                       fn:GetFullName(),
                                       "Lua files (*.lua)|*.lua|Text files (*.txt)|*.txt|All files (*)|*",
                                       wx.wxFD_SAVE + wx.wxFD_OVERWRITE_PROMPT)

    if fileDialog:ShowModal() == wx.wxID_OK then
        local filePath = fileDialog:GetPath()

        if SaveFile(editor, filePath) then
            --SetupKeywords(editor, IsLuaFile(filePath))
            saved = true
        end
    end

    fileDialog:Destroy()
    return saved
end

function SaveAll()
    for id, document in pairs(openDocuments) do
        local editor   = document.editor
        local filePath = document.filePath

        if document.isModified then
            SaveFile(editor, filePath) -- will call SaveFileAs if necessary
        end
    end
end

function RemovePage(index,delete)
    local  prevIndex = nil
    local  nextIndex = nil
    local newOpenDocuments = {}
	local todestroy
    for id, document in pairs(openDocuments) do
        if document.index < index then
            newOpenDocuments[id] = document
            prevIndex = document.index
        elseif document.index == index then
            --document.editor:Destroy()
			todestroy=document.editor
        elseif document.index > index then
            document.index = document.index - 1
            if nextIndex == nil then
                nextIndex = document.index
            end
            newOpenDocuments[id] = document
        end
    end
	
	openDocuments = newOpenDocuments
	if delete then
		--notebook:RemovePage(index)
		-- todestroy:Destroy()
		notebook:DeletePage(index)

		if nextIndex then
			notebook:SetSelection(nextIndex)
		elseif prevIndex then
			notebook:SetSelection(prevIndex)
		end
	
		SetEditorSelection(nil) -- will use notebook GetSelection to update
	end
end

-- Show a dialog to save a file before closing editor.
--   returns wxID_YES, wxID_NO, or wxID_CANCEL if allow_cancel
function SaveModifiedDialog(editor, allow_cancel)
    local result   = wx.wxID_NO
    local id       = editor:GetId()
    local document = openDocuments[id]
    local filePath = document.filePath
    local fileName = document.fileName
    if document.isModified then
        local message
        if fileName then
            message = "Save changes to '"..fileName.."' before exiting?"
        else
            message = "Save changes to 'untitled' before exiting?"
        end
        local dlg_styles = wx.wxYES_NO + wx.wxCENTRE + wx.wxICON_QUESTION
        if allow_cancel then dlg_styles = dlg_styles + wx.wxCANCEL end
        local dialog = wx.wxMessageDialog(frame, message,
                                          "Save Changes?",
                                          dlg_styles)
        result = dialog:ShowModal()
        dialog:Destroy()
        if result == wx.wxID_YES then
            SaveFile(editor, filePath)
        end
    end

    return result
end

function SaveOnExit(allow_cancel)
    for id, document in pairs(openDocuments) do
        if (SaveModifiedDialog(document.editor, allow_cancel) == wx.wxID_CANCEL) then
            return false
        end

        document.isModified = false
    end

    return true
end

function AppIDLE(event)
			if exitingProgram then return end
			local requestmore=false
			---[[
			--if not timer:IsRunning() then print("timer stoped") end
			--if not checkstatus(script_lane) then print(script_lane.status)  end
			if checkendScript(script_lane) then 
				script_lane = nil 
                --print("collectgarbage",collectgarbage"count")
				--collectgarbage()
                --print("collectgarbage",collectgarbage"count")
			end
			local key,val=idlelinda:receive(0,"Metro","DoDir","_FileSelector","TextToClipBoard","prout","proutSC","debugger","QueueAction","statusSC","/status.reply","OSCReceive","_midiEventCb","wxeval" ) 
			if val then
				--print("idlelinda receive ",key,val)
				if key=="prout" then
					DisplayOutput(val[1],val[2])
				elseif key=="proutSC" then
					DisplayLog(val, ScLog)
					for looppr = 1,10 do
						local key2,val2 = idlelinda:receive(0,"proutSC")
						if val2 then
							DisplayLog(val2, ScLog)
						else
							break
						end
					end
				elseif key=="debugger" then
					for k,v in ipairs(val[3]) do
						if v.what~="C" then
							abriredit(v.source:sub(2),v.currentline)
							break
						end
					end
					--abriredit(val[1]:sub(2),val[2])
					CallStack:MakeStack(val[3],"",val[4])
					if val[5] then
						EnableDebugCommands(val[5]);
					end
				elseif key=="Metro" then
					toppanel:set_transport(val)
					--timer:Start(300,wx.wxTIMER_ONE_SHOT)
					lanes.timer(scriptlinda,"beatRequest",0.3,0)
				elseif key=="TextToClipBoard" then
					putTextToClipBoard(val)
				elseif key=="statusSC" then 
					--thread_print("timerstatus")
					IDESCSERVER:status()
				
				elseif key=="/status.reply" then 
					toppanel:printStatus(val)
					lanes.timer(idlelinda,"statusSC",1,0)
				elseif key=="OSCReceive" then 
					OSCFunc.handleOSCReceive(val)
				elseif key=="QueueAction" then
					doQueueAction(val)
				elseif key == "_midiEventCb" then
					--if write note send to editor
					if G_do_write_midi then
						if val.type==midi.noteOn then
							local editor = GetEditor()
							if editor then
								if not G_do_write_midi_number then
									editor:AddText([["]] .. numberToNote(val.byte2) .. [[",]])
								else
									editor:AddText(tostring(val.byte2) .. [[,]])
								end
							end
						end
					end
				elseif key=="DoDir" then
					--print("receive DoDir")
					local res={}
					local function ff(n,l,p)
						--print(n,l,p)
						res[#res+1]={file=n,lev=l,path=p}
					end
					DoDir(ff,val[1],val[2],val[3])
					--print("res es:")
					--prtable(res)
					val[4]:send("dodirResp",res)
				elseif key=="_FileSelector" then
					local res=_FileSelector(val[1],val[2],val[3])
					val[4]:send("_FileSelectorResp",res)
                elseif key == "wxeval" then
                    local succes,res = pcall(val[1])
                    val[2]:send("wxevalResp",{succes,res})
				end
				requestmore=true
			end
			if requestmore then event:RequestMore() end
			--event:Skip()
end

function ToggleDebugMarker(editor, line)
    local markers = editor:MarkerGet(line)
    if markers >= CURRENT_LINE_MARKER_VALUE then
        markers = markers - CURRENT_LINE_MARKER_VALUE
    end
    local id       = editor:GetId()
   
    if markers >= BREAKPOINT_MARKER_VALUE then
        editor:MarkerDelete(line, BREAKPOINT_MARKER)
		if debuggerlinda then
			debuggerlinda:send("brpoints",{"delete","@"..openDocuments[editor:GetId()].filePath,line+1})
		end
    else
        editor:MarkerAdd(line, BREAKPOINT_MARKER)
		if debuggerlinda then
			debuggerlinda:send("brpoints",{"add","@"..openDocuments[editor:GetId()].filePath,line+1})
		end
    end
end

function ClearAllCurrentLineMarkers()
    for id, document in pairs(openDocuments) do
        local editor = document.editor
        editor:MarkerDeleteAll(CURRENT_LINE_MARKER)
    end
end


--[[
frame:Connect(ID_TOGGLEBREAKPOINT, wx.wxEVT_COMMAND_MENU_SELECTED,
        function (event)
            local editor = GetEditor()
            local line = editor:LineFromPosition(editor:GetCurrentPos())
            ToggleDebugMarker(editor, line)
        end)
frame:Connect(ID_TOGGLEBREAKPOINT, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)
--]]

function SaveIfModified(editor)
    local id = editor:GetId()
    if openDocuments[id].isModified then
        local saved = false
        if not openDocuments[id].filePath then
            local ret = wx.wxMessageBox("You must save the program before running it.\nPress cancel to abort running.","Save file?",  wx.wxOK + wx.wxCANCEL + wx.wxCENTRE, frame)
            if ret == wx.wxOK then
                saved = SaveFileAs(editor)
            end
        else
            saved = SaveFile(editor, openDocuments[id].filePath)
        end

        if saved then
            openDocuments[id].isModified = false
        else
            return false -- not saved
        end
    end

    return true -- saved
end



-----------------------------------------
ActionsQueue={}
function QueueAction(interval,action)
	action.timestamp = lanes.now_secs() + interval
	ActionsQueue[#ActionsQueue+1] = action
	table.sort(ActionsQueue,function(a,b) return a.timestamp > b.timestamp end)
	lanes.timer(idlelinda,"QueueAction",interval,0)
end
function doQueueAction(clocktimestamp)
	local action=ActionsQueue[#ActionsQueue]
	while action  and action.timestamp <= lanes.now_secs() do
		table.remove(ActionsQueue)
		action[1](action[2])
		action=ActionsQueue[#ActionsQueue]
		--print("doit","\t",#ActionsQueue)
	end
	if #ActionsQueue > 0 then
		lanes.timer(idlelinda,"QueueAction",ActionsQueue[#ActionsQueue].timestamp - lanes.now_secs(),0)
	end
end
-----------------------------------------------------

local function strconcat(...)
	local str=""
	for i=1, select('#', ...) do
		str = str .. tostring(select(i, ...)) .. "\t"
	end
	str = str .. "\n"
	return str
end
function thread_print(...)
	idlelinda:send("prout",{strconcat(...),false})
end
function thread_error_print(...)
	idlelinda:send("prout",{strconcat(...),true})
end



function putTextToClipBoard(text)
	local clipboard=wx.wxClipboard.Get()

	if (clipboard:Open()) then
		clipboard:SetData( wx.wxTextDataObject(text) );
		clipboard:Close();
	end
end
-- ---------------------------------------------------------------------------
-- Attach the handler for closing the frame

function CloseWindow(event)
    exitingProgram = true -- don't handle focus events

    if not SaveOnExit(event:CanVeto()) then
        event:Veto()
        exitingProgram = false
        return
    end
	print("Main frame Closing")
    local count_cancel = 0
	while script_lane and (count_cancel < 10) do
		--local cancelled,err=script_lane:cancel(0.1)
		local cancelled,err = ideCancelScript(0.1)
		print("script cancel on close",cancelled,err)
		if cancelled then
			script_lane = nil
		end
        count_cancel = count_cancel + 1
	end
	ConfigSaveOpenDocuments(Config)
	file_history:Save(Config.config)
	ConfigSavePerspectives()
	CloseScriptGUI()
	manager:UnInit();
	Config:delete() -- always delete the config
	config=nil
    event:Skip()
	if IDESCSERVER.inited then
		IDESCSERVER:quit()
		IDESCSERVER:close()
	end
	--midilane:cancel(0.1)
	--MidiClose()
	--pmidi.exit_midi_thread()
	print("Main frame Closed")
end

AppInit()

wx.wxGetApp():MainLoop()

--]===]
