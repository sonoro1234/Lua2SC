-------------------------------------------------------------------------=---
-- Name:        Lua2SC
-- Purpose:     Lua2SC IDE
-- Author:      Victor Bombi
-- Created:     2012
-- Copyright:   (c) 2012 Victor Bombi. All rights reserved.
-- Licence:     wxWidgets licence
-------------------------------------------------------------------------=---

local lanes=require("lanes")
lanes.configure({ nb_keepers = 1, with_timers = true, on_state_create = nil,track_lanes=true})
local idlelinda= lanes.linda()
local scriptlinda= lanes.linda()
local scriptguilinda= lanes.linda()
local midilinda= lanes.linda()
local udpsclinda=lanes.linda()
require("pmidi") 
oldpr=print
require("wx")
os.setlocale("C")	--to let serialize work for numbers
require("bitOp")	--not nedded here but to avoid lanes wx crash
require("random") 	--not nedded here but to avoid lanes wx crash
--require"profiler"
print=oldpr
require("init.utils")
require("socket")
require("osclua")
--require("queue")
toOSC=osclua.toOSC
fromOSC=osclua.fromOSC
--prtable(package)
---------------------------------
local wxT = function(s) return s end
--local _ = function(s) return s end
-- Equivalent to C's "cond ? a : b", all terms will be evaluated
function iff(cond, a, b) if cond then return a else return b end end

-- Does the num have all the bits in value
function HasBit(value, num)
    for n = 32, 0, -1 do
        local b = 2^n
        local num_b = num - b
        local value_b = value - b
        if num_b >= 0 then
            num = num_b
        else
            return true -- already tested bits in num
        end
        if value_b >= 0 then
            value = value_b
        end
        if (num_b >= 0) and (value_b < 0) then
            return false
        end
    end

    return true
end

-- Generate a unique new wxWindowID
local ID_IDCOUNTER = wx.wxID_HIGHEST + 1
function NewID()
    ID_IDCOUNTER = ID_IDCOUNTER + 1
    return ID_IDCOUNTER
end
ID_PLAY_BUTTON=NewID()
--ID_STOP_BUTTON=NewID()
ID_TEMPO_TEXT=NewID()
ID_POS_SLIDER=NewID()

-- File menu
local ID_NEW              = wx.wxID_NEW
local ID_OPEN             = wx.wxID_OPEN
local ID_CLOSE            = NewID()
local ID_SAVE             = wx.wxID_SAVE
local ID_SAVEAS           = wx.wxID_SAVEAS
local ID_SAVEALL          = NewID()
local ID_EXIT             = wx.wxID_EXIT
-- Edit menu
local ID_CUT              = wx.wxID_CUT
local ID_COPY             = wx.wxID_COPY
local ID_PASTE            = wx.wxID_PASTE
local ID_SELECTALL        = wx.wxID_SELECTALL
local ID_UNDO             = wx.wxID_UNDO
local ID_REDO             = wx.wxID_REDO
local ID_AUTOCOMPLETE     = NewID()
local ID_AUTOCOMPLETE_ENABLE = NewID()
local ID_COMMENT          = NewID()
local ID_FOLD             = NewID()
-- Find menu
local ID_FIND             = wx.wxID_FIND
local ID_FINDNEXT         = NewID()
local ID_FINDPREV         = NewID()
local ID_REPLACE          = NewID()
local ID_GOTOLINE         = NewID()
local ID_SORT             = NewID()
local ID_FIND_SOURCE	= NewID()
-- Debug menu
--local ID_TOGGLEBREAKPOINT = NewID()
local ID_COMPILE          = NewID()
local ID_RUN              = NewID()
--local ID_RUN2              = NewID()
local ID_RUN3              = NewID()
local ID_CANCELRUN       = NewID()
local ID_KILLRUN       = NewID()
local ID_DUMPTREE       = NewID()
local ID_DUMPOSC       = NewID()
local ID_BOOTSC       = NewID()
local ID_QUITSC       = NewID()
local ID_AUTODETECTSC       = NewID()
--local ID_SHOWHIDEWINDOW   = NewID()
local ID_CLEAROUTPUT      = NewID()
local ID_SETTINGS              = NewID()

-- Help menu
local ID_ABOUT            = wx.wxID_ABOUT

-- Markers for editor marker margin
local BREAKPOINT_MARKER         = 1
local BREAKPOINT_MARKER_VALUE   = 2 -- = 2^BREAKPOINT_MARKER
local CURRENT_LINE_MARKER       = 2
local CURRENT_LINE_MARKER_VALUE = 4 -- = 2^CURRENT_LINE_MARKER

-- ASCII values for common chars
local char_CR  = string.byte("\r")
local char_LF  = string.byte("\n")
local char_Tab = string.byte("\t")
local char_Sp  = string.byte(" ")

-- Global variables
programName      = nil    -- the name of the wxLua program to be used when starting debugger
editorApp        = wx.wxGetApp()

debuggee_running   = false  -- true when the debuggee is running
debugger_destroy   = 0      -- > 0 if the debugger is to be destroyed in wxEVT_IDLE
debuggee_pid       = 0      -- pid of the debuggee process
debuggerPortNumber = 1551   -- the port # to use for debugging

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
ignoredFilesList = {}
editorID         = 100    -- window id to create editor pages with, incremented for new editors
exitingProgram   = false  -- are we currently exiting, ID_EXIT
autoCompleteEnable = true -- value of ID_AUTOCOMPLETE_ENABLE menu item
wxkeywords       = nil    -- a string of the keywords for scintilla of wxLua's wx.XXX items
font             = nil    -- fonts to use for the editor
fontItalic       = nil

findReplace = {
    dialog           = nil,   -- the wxDialog for find/replace
    replace          = false, -- is it a find or replace dialog
    fWholeWord       = true, -- match whole words
    fMatchCase       = true, -- case sensitive
    fDown            = true,  -- search downwards in doc
    fRegularExpr     = false, -- use regex
    fWrap            = true, -- search wraps around
    findTextArray    = {},    -- array of last entered find text
    findText         = "",    -- string to find
    replaceTextArray = {},    -- array of last entered replace text
    replaceText      = "",    -- string to replace find string with
    foundString      = false, -- was the string found for the last search

    -- HasText()                 is there a string to search for
    -- GetSelectedString()       get currently selected string if it's on one line
    -- FindString(reverse)       find the findText string
    -- Show(replace)             create the dialog
}
-------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

-- Pick some reasonable fixed width fonts to use for the editor
if wx.__WXMSW__ then
    font       = wx.wxFont(10, wx.wxFONTFAMILY_MODERN, wx.wxFONTSTYLE_NORMAL, wx.wxFONTWEIGHT_NORMAL, false,"")--, "Andale Mono")
    fontItalic = wx.wxFont(10, wx.wxFONTFAMILY_MODERN, wx.wxFONTSTYLE_ITALIC, wx.wxFONTWEIGHT_NORMAL, false,"")--, "Andale Mono")
else
    font       = wx.wxFont(10, wx.wxFONTFAMILY_MODERN, wx.wxFONTSTYLE_NORMAL, wx.wxFONTWEIGHT_NORMAL, false, "")
    fontItalic = wx.wxFont(10, wx.wxFONTFAMILY_MODERN, wx.wxFONTSTYLE_ITALIC, wx.wxFONTWEIGHT_NORMAL, false, "")
end

-- ----------------------------------------------------------------------------
-- Initialize the wxConfig for loading/saving the preferences

config = wx.wxFileConfig("SCLuaIDE", "sonoro")
if config then
    config:SetRecordDefaults()
end
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
	for id, document in pairs(openDocuments) do
		local editor   = document.editor
		local filePath =  document.filePath
		if filePath and string.upper(filePath) == string.upper(eventFileName_) then
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

function checkend(lane)
	if not lane then return true end
	local status=lane.status
	--print("checkend status ",status)
	if status=="error" or status=="done" or status=="cancelled" or status=="killed" then
		print("checkend ffinished",status)
		--do return true end
		local v,err,stack_tbl= lane:join(0.1)
		print("checkend post lane:join")
		if v==nil then
			if err then
				local onlyerrorst=err:match(":%d+:(.+)")
				--DisplayOutput( "Error: "..tostring(err).."\n" )
				--idlelinda:send("prerror","Error: "..tostring(err).."\n"..tostring(onlyerrorst).."\n")
				if  type(stack_tbl)=="table"  then
					local function compile_error(err)
						local info = {}
						local err2=err:match("from file%s+'.-':.-([%w%p]*:%d+:)")
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


function AppInit()
	--plist=wx.wxList()
	--plist:Append(wx.wxObject():DynamicCast("wxPoint"):Set(0,0))
	--plist:Append(wx.wxPoint(30,30):DynamicCast("wxObject"))
	
	--frame = wx.wxFrame(wx.NULL, wx.wxID_ANY, "Lua2SC",wx.wxDefaultPosition, wx.wxDefaultSize,wx.wxBORDER_SIMPLE + wx.wxDEFAULT_FRAME_STYLE )
	frame = wx.wxFrame(wx.NULL, wx.wxID_ANY, "Lua2SC",wx.wxDefaultPosition, wx.wxSize(800, 600),wx.wxBORDER_SIMPLE + wx.wxDEFAULT_FRAME_STYLE )
	managedpanel = wx.wxPanel(frame, wx.wxID_ANY)
	
	manager = wxaui.wxAuiManager()
	manager:SetManagedWindow(managedpanel);
		
	statusBar = frame:CreateStatusBar( 4 )
	local status_txt_width = statusBar:GetTextExtent("OVRW")
	frame:SetStatusWidths({-1, status_txt_width, status_txt_width, status_txt_width*5})
	frame:SetStatusText("Welcome to Lua2SC")
	--[[
	toolBar = frame:CreateToolBar(wx.wxNO_BORDER + wx.wxTB_FLAT + wx.wxTB_DOCKABLE)
	-- note: Ususally the bmp size isn't necessary, but the HELP icon is not the right size in MSW
	local toolBmpSize = toolBar:GetToolBitmapSize()
	toolBar:AddTool(ID_NEW,     "New",      wx.wxArtProvider.GetBitmap(wx.wxART_NORMAL_FILE, wx.wxART_MENU, toolBmpSize), "Create an empty document")
	toolBar:AddTool(ID_OPEN,    "Open",     wx.wxArtProvider.GetBitmap(wx.wxART_FILE_OPEN, wx.wxART_MENU, toolBmpSize),   "Open an existing document")
	toolBar:AddTool(ID_SAVE,    "Save",     wx.wxArtProvider.GetBitmap(wx.wxART_FILE_SAVE, wx.wxART_MENU, toolBmpSize),   "Save the current document")
	toolBar:AddTool(ID_SAVEALL, "Save All", wx.wxArtProvider.GetBitmap(wx.wxART_NEW_DIR, wx.wxART_MENU, toolBmpSize),     "Save all documents")
	toolBar:AddSeparator()
	toolBar:AddTool(ID_CUT,   "Cut",   wx.wxArtProvider.GetBitmap(wx.wxART_CUT, wx.wxART_MENU, toolBmpSize),   "Cut the selection")
	toolBar:AddTool(ID_COPY,  "Copy",  wx.wxArtProvider.GetBitmap(wx.wxART_COPY, wx.wxART_MENU, toolBmpSize),  "Copy the selection")
	toolBar:AddTool(ID_PASTE, "Paste", wx.wxArtProvider.GetBitmap(wx.wxART_PASTE, wx.wxART_MENU, toolBmpSize), "Paste text from the clipboard")
	toolBar:AddSeparator()
	toolBar:AddTool(ID_UNDO, "Undo", wx.wxArtProvider.GetBitmap(wx.wxART_UNDO, wx.wxART_MENU, toolBmpSize), "Undo last edit")
	toolBar:AddTool(ID_REDO, "Redo", wx.wxArtProvider.GetBitmap(wx.wxART_REDO, wx.wxART_MENU, toolBmpSize), "Redo last undo")
	toolBar:AddSeparator()
	toolBar:AddTool(ID_FIND,    "Find",    wx.wxArtProvider.GetBitmap(wx.wxART_FIND, wx.wxART_MENU, toolBmpSize), "Find text")
	toolBar:AddTool(ID_REPLACE, "Replace", wx.wxArtProvider.GetBitmap(wx.wxART_FIND_AND_REPLACE, wx.wxART_MENU, toolBmpSize), "Find and replace text")
	toolBar:Realize()
	--]]
	--------------------------------------------panel
	---[[
	panel = wx.wxPanel(frame, wx.wxID_ANY)-- ,wx.wxDefaultPosition, wx.wxSize(500,200))
		
	playButton = wx.wxToggleButton( panel, ID_PLAY_BUTTON, "Play")
	--stopButton = wx.wxButton( panel, ID_STOP_BUTTON, "Stop")
	tempoCtrl   = wx.wxTextCtrl( panel, ID_TEMPO_TEXT, "", wx.wxDefaultPosition, wx.wxSize(40,20), wx.wxTE_PROCESS_ENTER )
	posSlider = wx.wxSlider(panel, ID_POS_SLIDER, 0, 0, 300,wx.wxDefaultPosition, wx.wxDefaultSize,wx.wxSL_LABELS)
	--posSlider:SetFont(wx.wxFont(6, wx.wxFONTFAMILY_MODERN, wx.wxFONTSTYLE_NORMAL, wx.wxFONTWEIGHT_NORMAL, false, "Andale Mono"))wx.wxNORMAL_FONT
	timeStText = wx.wxStaticText(panel, wx.wxID_ANY," 00:00",wx.wxDefaultPosition, wx.wxDefaultSize)
	local label="0 UGens.\t0 Synths.\n0.00-AvgCPU\t0.00-PeakCPU\n0 Groups.\t0 SynthDefs."
	SCStatusText=wx.wxStaticText(panel, wx.wxID_ANY,label,wx.wxDefaultPosition, wx.wxDefaultSize
		--,wx.wxBORDER_SIMPLE+wx.wxALIGN_CENTRE  
		)
	SCStatusText:Wrap(-1)
	local w,h=SCStatusText:GetTextExtent("0.00-AvgCPU\t0.00-PeakCPU\n")
	SCStatusText:SetSize(w+20,h*3)
	posSlider:SetFont(wx.wxSMALL_FONT)
	
	
	local buttonSizer = wx.wxBoxSizer( wx.wxHORIZONTAL )
	buttonSizer:Add( playButton, 0, wx.wxALIGN_CENTER+wx.wxALL, 3 )
	buttonSizer:Add( tempoCtrl, 0, wx.wxALIGN_CENTER+wx.wxALL, 3 )
	buttonSizer:Add( posSlider, 1, wx.wxALL, 0 )
	buttonSizer:Add( timeStText, 0, wx.wxALIGN_CENTER+wx.wxALL, 3 )
	
	--local mainSizer = wx.wxBoxSizer(wx.wxVERTICAL)
	panelSizer = wx.wxBoxSizer(wx.wxHORIZONTAL)
	
	--panelSizer:Add( buttonSizer, 1, wx.wxGROW + wx.wxALL, 0 )
	--panelSizer:Add( SCStatusText, 0, wx.wxFIXED_MINSIZE +wx.wxALIGN_CENTER+wx.wxALL, 0 )
	panelSizer:Add( buttonSizer, 1,  wx.wxALL, 0 )
	panelSizer:Add( SCStatusText, 0, wx.wxFIXED_MINSIZE +wx.wxALL, 0 )
	
	--mainSizer:Add( buttonSizer, 0, wx.wxGROW+wx.wxALIGN_CENTER+wx.wxALL, 0 )
	panel:SetSizer(panelSizer)
	panelSizer:SetSizeHints(panel)
	
	local mainsizer = wx.wxBoxSizer(wx.wxVERTICAL)
	mainsizer:Add(panel,0,wx.wxGROW)
	mainsizer:Add(managedpanel,1,wx.wxGROW)
	frame:SetSizer(mainsizer)
	mainsizer:SetSizeHints(frame)
	--manager:AddPane(panel, wxaui.wxAuiPaneInfo():Name("PlayerPannel"):CaptionVisible(false):CloseButton(false):BestSize(panel:GetSize()):MaxSize(panel:GetSize()):Top():PaneBorder(false)); 
	--manager:AddPane(panel, wxaui.wxAuiPaneInfo():Name("PlayerPannel"):CaptionVisible(false):CloseButton(false):Top():PaneBorder(false)); 
	--]]
	--[[
	panel = wx.wxToolBar(frame, wx.wxID_ANY, wx.wxDefaultPosition, wx.wxDefaultSize)
									--,wx.wxTB_FLAT + wx.wxTB_NODIVIDER );	
	panel:SetToolBitmapSize(wx.wxSize(48,48));
	panel:AddCheckTool(ID_PLAY_BUTTON,"Play", wx.wxArtProvider.GetBitmap(wx.wxART_GO_FORWARD))
	local tempoCtrl   = wx.wxTextCtrl( panel, ID_TEMPO_TEXT, "", wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxTE_PROCESS_ENTER )
	panel:AddControl(tempoCtrl)
	posSlider = wx.wxSlider(panel, ID_POS_SLIDER, 0, 0, 300,wx.wxDefaultPosition, wx.wxDefaultSize,wx.wxSL_LABELS)
	panel:AddControl(posSlider)
	local label="0 UGens.\t0 Synths.\n0.00-AvgCPU\t0.00-PeakCPU\n0 Groups.\t0 SynthDefs.\n"
	SCStatusText=wx.wxStaticText(panel, wx.wxID_ANY,label,wx.wxDefaultPosition, wx.wxDefaultSize
		--,wx.wxBORDER_SIMPLE+wx.wxALIGN_CENTRE  
		)
	SCStatusText:Wrap(-1)
	local w,h=SCStatusText:GetTextExtent("0.00-AvgCPU\t0.00-PeakCPU\n")
	SCStatusText:SetSize(w+20,h*4)
	panel:AddControl(SCStatusText)
	panel:Realize()
	manager:AddPane(panel, wxaui.wxAuiPaneInfo():
					Name(wxT("PlayerPannel")):Caption(wxT("Sample Bookmark Toolbar")):
					ToolbarPane():Top():Row(2):
					LeftDockable(false):RightDockable(false));
	--]]			  
	frame:Connect(ID_PLAY_BUTTON, wx.wxEVT_COMMAND_TOGGLEBUTTON_CLICKED,
		function(event) 
			if playButton:GetValue() then
				--print("playButton")
				scriptlinda:send("play",1)
			else
				--print("playButton stop")
				scriptlinda:send("play",0)
			end
		end)
			
	--frame:Connect(ID_STOP_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
		--function(event) scriptlinda:send("play",0) end)

	frame:Connect(ID_TEMPO_TEXT, wx.wxEVT_COMMAND_TEXT_ENTER,
		function(event)
			--local tempo=tonumber(event:GetEventObject():DynamicCast("wxTextCtrl"):GetValue())
			tempoCtrlChanging=false
			local tempo=tonumber(tempoCtrl:GetValue())
			scriptlinda:send("tempo",tempo)
		end) 
	frame:Connect(ID_TEMPO_TEXT, wx.wxEVT_COMMAND_TEXT_UPDATED,
		function(event)
			tempoCtrlChanging=true
		end) 
	frame:Connect(ID_POS_SLIDER, wx.wxEVT_SCROLL_THUMBTRACK,
            function (event) settingPos = true end)

    frame:Connect(ID_POS_SLIDER, wx.wxEVT_SCROLL_THUMBRELEASE,
            function (event)
                local pos = event:GetPosition()
				--local len = 300
               -- local beat=(len*pos/slider_range)
                scriptlinda:send("beat",pos)
                settingPos = false
            end )
	--manager:Connect(wx.wxID_ANY,wxaui.wxEVT_AUI_PANE_RESTORE,function(event) print("wxEVT_AUI_PANE_RESTORE") event:Skip() end)
	
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
			
	

	errorLog = wxstc.wxStyledTextCtrl(managedpanel,--notebookLogs,
	wx.wxID_ANY, wx.wxDefaultPosition, wx.wxDefaultSize,wx.wxBORDER_NONE )
	--errorLog:Show(false)
	errorLog:SetFont(font)
	errorLog:StyleSetFont(wxstc.wxSTC_STYLE_DEFAULT, font)
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
	--sclog
	ScLog = wxstc.wxStyledTextCtrl(managedpanel,--notebookLogs,
		wx.wxID_ANY, wx.wxDefaultPosition, wx.wxDefaultSize,wx.wxBORDER_NONE )
	--ScLog:Show(false)
	ScLog:SetFont(font)
	ScLog:StyleSetFont(wxstc.wxSTC_STYLE_DEFAULT, font)
	ScLog:StyleClearAll()
	ScLog:SetMarginWidth(1, 16) -- marker margin
	ScLog:SetMarginType(1, wxstc.wxSTC_MARGIN_SYMBOL);
	ScLog:MarkerDefine(CURRENT_LINE_MARKER, wxstc.wxSTC_MARK_ARROWS, wx.wxBLACK, wx.wxWHITE)
	ScLog:SetReadOnly(true)
	--ScLog:SetUseHorizontalScrollBar(false)
	--ScLog:SetWrapMode(1)
	ScLog:Connect(wx.wxEVT_SET_FOCUS,function (event)
					currentSTC=ScLog
					event:Skip()
				end)
	notebookLogs:AddPage(errorLog, "Log", true)
	notebookLogs:AddPage(ScLog, "SC Log", false)
	notebookLogs:AddPage(CallStack:Create().window, "Call stack", false)
	
	
	--------- manager
	manager:AddPane(notebook, wxaui.wxAuiPaneInfo():Name("notebook"):CenterPane():CloseButton(false):PaneBorder(false))
	manager:AddPane(notebookLogs, wxaui.wxAuiPaneInfo():Name("notebookLogs"):Bottom():CaptionVisible(false):CloseButton(false):PaneBorder(false))--:BestSize(200,200));
	manager:AddPane(IdentifiersList:Create().window, wxaui.wxAuiPaneInfo():Name("IdentifiersList"):Right():Row(1):Layer(0):CloseButton(false):CaptionVisible(false):PaneBorder(false))
	
	CreateScriptGUI()

--frame:Show(true)
--manager:Update()	
	InitFileMenu()
	
	MRUInit()
	frame:Connect(ID_NEW, wx.wxEVT_COMMAND_MENU_SELECTED, NewFile)
	InitEditMenu()
	InitFindMenu()
	
	InitRunMenu()
	InitSCMenu()
	InitPerspectivesMenu()
	InitDocumentsMenu()
	InitHelpMenu()
	frame:Connect(wx.wxEVT_CLOSE_WINDOW, CloseWindow)
	-- ---------------------------------------------------------------------------
	-- Finish creating the frame and show it
	
	frame:SetMenuBar(menuBar)
	--CreateScriptGUI()
	--ConfigRestoreFramePosition(frame, "MainFrame")
	Settings:ConfigRestore(config)
	
	manager:GetArtProvider():SetMetric(wxaui.wxAUI_DOCKART_PANE_BORDER_SIZE,2)
	manager:GetArtProvider():SetMetric(wxaui.wxAUI_DOCKART_SASH_SIZE,2)
	--manager:GetArtProvider():SetMetric(wxaui.wxAUI_DOCKART_CAPTION_SIZE,7)
	manager:GetArtProvider():SetMetric(wxaui.wxAUI_DOCKART_GRADIENT_TYPE, wxaui.wxAUI_GRADIENT_NONE)
	manager:Update()
	ConfigLoadOpenDocuments(config)
	-- ---------------------------------------------------------------------------
	-- Load the args that this script is run with
	
	--for k, v in pairs(arg) do print(k, v) end
	
	if arg then
		-- arguments pushed into wxLua are
		--   [C++ app and it's args][lua prog at 0][args for lua start at 1]
		print("arg2")
		prtable(arg)
		local n = 1
		while arg[n-1] do
			n = n - 1
			if arg[n] and not arg[n-1] then programName = arg[n] end
		end
		
		local fn=wx.wxFileName(arg[0])
		fn:Normalize()
		_presetsDir=fn:GetPath(wx.wxPATH_GET_VOLUME + wx.wxPATH_GET_SEPARATOR)
		
		fn=wx.wxFileName(arg[-1])
		fn:Normalize()
		_scscriptsdir=fn:GetPath(wx.wxPATH_GET_VOLUME + wx.wxPATH_GET_SEPARATOR).."lua\\sc\\"

		for index = 1, #arg do
			fileName = arg[index]
			if fileName ~= "--" then
				LoadFile(fileName, nil, true)
			end
		end
	
		if notebook:GetPageCount() > 0 then
			notebook:SetSelection(0)
		else
			--local editor = CreateEditor("untitled.lua")
			--SetupKeywords(editor, true)
			local editor = NewFile()
		end
	else
		--local editor = CreateEditor("untitled.lua")
		--SetupKeywords(editor, true)
		local editor = NewFile()
	end
	
	--frame:SetIcon(wxLuaEditorIcon) --FIXME add this back
	local bitmap = wx.wxBitmap(LUA_xpm)
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
	InitUdP()
	midilane=pmidi.gen(Settings.options.midiin,Settings.options.midiout,lanes,scriptlinda,midilinda,{print=thread_print,
	prerror=thread_error_print,
	prtable=prtable})
end
--call stack
CallStack={}
function CallStack:Create()
	local watchListCtrl = wx.wxListCtrl(managedpanel ,wx.wxID_ANY,--notebookLogs, wx.wxID_ANY,
                                  wx.wxDefaultPosition, wx.wxDefaultSize,
                                  wx.wxLC_REPORT + wx.wxLC_SINGLE_SEL )
	self.window=watchListCtrl
	local info = wx.wxListItem()
	info:SetMask(wx.wxLIST_MASK_TEXT)-- +wx.wxLIST_MASK_WIDTH)
	--watchListCtrl:SetColumnWidth(0,wx.wxLIST_AUTOSIZE)
	info:SetText("name")
	--info:SetWidth(wx.wxLIST_AUTOSIZE)
	watchListCtrl:InsertColumn(0, info)
	info:SetText("what")
	watchListCtrl:InsertColumn(1, info)
	info:SetText("namewhat")
	watchListCtrl:InsertColumn(2, info)
	info:SetText("source")
	watchListCtrl:InsertColumn(3, info)
	info:SetText("line")
	watchListCtrl:InsertColumn(4, info)
	info:SetText("") --err from lua
	watchListCtrl:InsertColumn(5, info)
	
	watchListCtrl:Connect(wx.wxEVT_COMMAND_LIST_ITEM_ACTIVATED,function(event)
		local levi = event:GetIndex()
		--print("selecciono: ",lev)
		if self.luastack then
			local lev=self.luastack[levi + 1]
			if  lev and lev.what~="C" then
				abriredit(lev.source:sub(2),lev.currentline)
			end
		end
	end)
	return self
end

function CallStack:AddToStack(lev)
	local watchListCtrl=self.window
	local row = watchListCtrl:InsertItem(watchListCtrl:GetItemCount(), "Expr")
	watchListCtrl:SetItem(row, 0, lev.name or "")
	watchListCtrl:SetItem(row, 1, lev.what or "")
	watchListCtrl:SetItem(row, 2, lev.namewhat or "")
    watchListCtrl:SetItem(row, 3, lev.source or "")
    watchListCtrl:SetItem(row, 4, tostring(lev.currentline))
	return row
end
function CallStack:Clear()
	local watchListCtrl=self.window
	watchListCtrl:DeleteAllItems()
end
function CallStack:MakeStack(stack,err)
	local watchListCtrl=self.window
	self.luastack=stack
	self:Clear()
	local marked=false
	for k,v in ipairs(stack) do
		local row=self:AddToStack(v)
		if v.what~="C" and not marked then
			--print(row,wx.wxLIST_STATE_FOCUSED)
			watchListCtrl:SetItem(row, 5, tostring(err))
			watchListCtrl:SetItemState(row,wx.wxLIST_STATE_SELECTED+wx.wxLIST_STATE_FOCUSED
				,wx.wxLIST_STATE_SELECTED+wx.wxLIST_STATE_FOCUSED )
			marked=true
		end
	end
	for i=0,4 do
		watchListCtrl:SetColumnWidth(i,wx.wxLIST_AUTOSIZE)
	end
end

-------IdentifiersList
function MakeIdentifiers(editor)
	local ret={}
	local totlines=editor:GetLineCount()
	for linea = 0,totlines do
		if (editor:GetFoldParent(linea)==-1) then --and editor:GetLastChild(linea,-1) >linea then
			local text = editor:GetLine(linea)
			local comment = text:find("^%s*%-%-")
			local linestate = editor:GetLineState(linea)
			local foldlevel = editor:GetFoldLevel(linea)
			local head = (bit.band(foldlevel,wxstc.wxSTC_FOLDLEVELHEADERFLAG) > 0)
			local whitef = (bit.band(foldlevel,wxstc.wxSTC_FOLDLEVELWHITEFLAG) > 0)
			if (text:match("%w")==nil) then whitef = true end
			
			if (comment == nil) and (linestate == 0) and (not whitef) then
				-- print(editor:GetFoldParent(linea))
				-- print(linea," ",
				-- editor:GetLastChild(linea,-1)," ",
				-- foldlevel," ",
				-- head," ",
				-- linestate," ",
				-- text)
				local identifier=text:match("^%s*function ([%w%._:]+)%s*%(")
				if (identifier==nil) then
					identifier=text:match("^%s*local%s*function ([%w%._:]+)%s*%(")
				end
				if (identifier==nil) then
					identifier=text:match("^%s*([%w_%.]+)%s*=")
				end
				if (identifier==nil) then
					identifier=text:match("^%s*local%s*([%w_%.]+)%s*=")
				end
				-- if (identifier==nil) then
					-- identifier=text:sub(1,10)
				-- end
				if identifier~=nil then
					ret[#ret +1]={line=linea,head=head,text=identifier}
				end
				--print("identifier",identifier)
			end
		end
	end
	table.sort(ret,function(a,b) return ((a.text):upper() < (b.text):upper()) end)
	return ret
end
IdentifiersList={}
function IdentifiersList:Create()
	--local window=wx.wxPanel(frame,wx.wxID_ANY)--,wx.wxDefaultPosition, wx.wxSize(200,200))
	local control=wx.wxListBox(managedpanel,wx.wxID_ANY)
	self.window=control
	self.control=control
	--,wx.wxID_ANY,wx.wxDefaultPosition, wx.wxDefaultSize,wx.wxLC_REPORT + wx.wxLC_SINGLE_SEL
	self.window:Connect(wx.wxEVT_COMMAND_LISTBOX_DOUBLECLICKED ,function (event) 
			local sel=control:GetSelection()
			if (sel~=-1) and self.current_identifiers then --wx.wxNOT_FOUND=-1
				local editor   = GetEditor()
				local id       = editor:GetId()
				assert(openDocuments[id].identifiers==self.current_identifiers)
				--editor:GotoLine(self.current_identifiers[sel+1].line)
				local line=self.current_identifiers[sel+1].line
				editor:GotoLine(line)
				editor:SetSelection(editor:PositionFromLine(line), editor:GetLineEndPosition(line))
			end
		end)
	--print("IdentifiersList")
	--prtable(self)
	return self
end
function IdentifiersList:Set(idents)
	local arrSt=wx.wxArrayString()
	for k,v in ipairs(idents) do
		arrSt:Add(v.text)
	end
	self.control:Set(arrSt)
	self.current_identifiers=idents
end
function IdentifiersList:SetEditor(editor)
	local id=editor:GetId()
	openDocuments[id].identifiers=MakeIdentifiers(editor)
	self:Set(openDocuments[id].identifiers)
end
-----------



function DisplayOutput(message, iserror)
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
    LogW:SetReadOnly(true)
    LogW:GotoPos(LogW:GetLength())
	--notebookLogs:SetSelection(notebookLogs:GetPageIndex(LogW))
	--if currentSTCed then currentSTCed:SetFocus() end
end
-- ----------------------------------------------------------------------------
-- wxConfig load/save preferences functions

function ConfigRestoreFramePosition(window, windowName)
	---[[
	--manager:Update()
    local path = config:GetPath()
    config:SetPath("/"..windowName)

    local _, s = config:Read("s", -1)
    local _, x = config:Read("x", 0)
    local _, y = config:Read("y", 0)
    local _, w = config:Read("w", 0)
    local _, h = config:Read("h", 0)
	print("ConfigRestoreFramePosition ",s,x,y,w,h)
    if (s == -1) then 
		--init
        local clientX, clientY, clientWidth, clientHeight
        clientX, clientY, clientWidth, clientHeight = wx.wxClientDisplayRect()
		
        x = clientX
        y = clientY 
        w = clientWidth 
        h = clientHeight 

        window:SetSize(x, y, w, h)
		local w1,h1 = frame:GetClientSizeWH()
		manager:GetPane(notebookLogs):BestSize(w1,h1/2)
		--manager:Update()
		print("init notebookLogs",w1," ",h1/2)
	end
    if s == 1 then
        window:Maximize(true)
    end

    config:SetPath(path)
	--]]
end

function ConfigSaveFramePosition(window, windowName)
	---[[
    local path = config:GetPath()
    config:SetPath("/"..windowName)

    local s    = 0
    local w, h = window:GetSizeWH()
    local x, y = window:GetPositionXY()

    if window:IsMaximized() then
        s = 1
    elseif window:IsIconized() then
        s = 2
    end

    config:Write("s", s)

    if s == 0 then
        config:Write("x", x)
        config:Write("y", y)
        config:Write("w", w)
        config:Write("h", h)
    end

    config:SetPath(path)
	--]]
end
function ConfigSaveOpenDocuments(config)
	print("ConfigSaveOpenDocuments")
	local path = config:GetPath()
	config:DeleteGroup("/openDocuments")
    config:SetPath("/openDocuments")
	local config_openDocuments={}
	--prtable(openDocuments)
	-- for i,v in pairs(openDocuments) do
		-- config_openDocuments[#config_openDocuments +1]=v.filePath
		-- print(v.filePath)
	-- end
	local sortedDocs = {}
	for id, document in pairs(openDocuments) do
					sortedDocs[#sortedDocs + 1] = {name = notebook:GetPageText(document.index),
												document = document}
	end
	table.sort(sortedDocs, function(a, b) return string.upper(a.name) < string.upper(b.name) end)
	for i,v in pairs(sortedDocs) do
		config_openDocuments[#config_openDocuments +1]=v.document.filePath
		print(v.document.filePath)
	end
	---table.sort(config_openDocuments,function(a,b) return string.upper(a) < string.upper(b) end)
	local serialized = serializeTable("config_openDocuments", config_openDocuments) 
	local goodwrite=false
	goodwrite=config:Write("Documents",serialized)
	if not goodwrite then wx.wxMessageBox("cant save config!! "..tostring(i)) end	
	config:Write("lastDirectory",lastDirectory or "")
	config:Flush()
	config:SetPath(path)
end
function ConfigLoadOpenDocuments(config)
	local path = config:GetPath()
    config:SetPath("/openDocuments")
	local _,str
	if config:HasEntry("Documents") then
		_,str=config:Read("Documents")
		if str and string.len(str)>1 then
			assert(loadstring(str))()
		end
	end
	_,lastDirectory=config:Read("lastDirectory")
	if config_openDocuments then
		for i,v in ipairs(config_openDocuments) do
			abriredit(v)
		end
	end
	config:SetPath(path)
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
statusTextTable = { "OVR?", "R/O?", "Cursor Pos" }

function UpdateStatusText(editor)
    local texts = { "", "", "" }
    if frame and editor then
        local pos  = editor:GetCurrentPos()
        local line = editor:LineFromPosition(pos)
        local col  = 1 + pos - editor:PositionFromLine(line)

        texts = { iff(editor:GetOvertype(), "OVR", "INS"),
                  iff(editor:GetReadOnly(), "R/O", "R/W"),
                  "Ln "..tostring(line + 1).." Col "..tostring(col) }
    end

    if frame then
        for n = 1, 3 do
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

-- ----------------------------------------------------------------------------
-- Create an editor and add it to the notebook
function CreateEditor(name)
    local editor = wxstc.wxStyledTextCtrl(notebook, editorID,
                                          wx.wxDefaultPosition, wx.wxDefaultSize
                                          ,wx.wxBORDER_NONE )
										  --,wx.wxBORDER_STATIC)
										  

    editorID = editorID + 1 -- increment so they're always unique
	--editor:SetUseHorizontalScrollBar(true)
	--editor:SetScrollWidth()
	editor:SetWrapMode(1)
    editor:SetBufferedDraw(true)
    editor:StyleClearAll()

    editor:SetFont(font)
    editor:StyleSetFont(wxstc.wxSTC_STYLE_DEFAULT, font)
    for i = 0, 32 do
        editor:StyleSetFont(i, font)
    end
	for i = 0, 32 do
        editor:StyleSetCharacterSet(i, wxstc.wxSTC_CHARSET_ANSI)
    end
	--[[
	%define wxstc.wxSTC_LUA_DEFAULT
	%define wxstc.wxSTC_LUA_COMMENT
	%define wxstc.wxSTC_LUA_COMMENTLINE
	%define wxstc.wxSTC_LUA_COMMENTDOC
	%define wxstc.wxSTC_LUA_NUMBER
	%define wxstc.wxSTC_LUA_WORD
	%define wxstc.wxSTC_LUA_STRING
	%define wxstc.wxSTC_LUA_CHARACTER
	%define wxstc.wxSTC_LUA_LITERALSTRING
	%define wxstc.wxSTC_LUA_PREPROCESSOR
	%define wxstc.wxSTC_LUA_OPERATOR
	%define wxstc.wxSTC_LUA_IDENTIFIER
	%define wxstc.wxSTC_LUA_STRINGEOL
	%define wxstc.wxSTC_LUA_WORD2
	%define wxstc.wxSTC_LUA_WORD3
	%define wxstc.wxSTC_LUA_WORD4
	%define wxstc.wxSTC_LUA_WORD5
	%define wxstc.wxSTC_LUA_WORD6
	%define wxstc.wxSTC_LUA_WORD7
	%define wxstc.wxSTC_LUA_WORD8
	--]]
    editor:StyleSetForeground(wxstc.wxSTC_LUA_DEFAULT,  wx.wxColour(128, 128, 128)) -- White space
    editor:StyleSetForeground(wxstc.wxSTC_LUA_COMMENT,  wx.wxColour(0,   127, 0))   -- Block Comment
    editor:StyleSetFont(wxstc.wxSTC_LUA_COMMENT, fontItalic)
    --editor:StyleSetUnderline(wxstc.wxSTC_LUA_COMMENT, false)
    editor:StyleSetForeground(wxstc.wxSTC_LUA_COMMENTLINE,  wx.wxColour(0,   127, 0))   -- Line Comment
    editor:StyleSetFont(wxstc.wxSTC_LUA_COMMENTLINE, fontItalic)                        
    --editor:StyleSetUnderline(wxstc.wxSTC_LUA_COMMENTLINE, false)						-- Doc. Comment
    editor:StyleSetForeground(wxstc.wxSTC_LUA_COMMENTDOC,  wx.wxColour(127, 127, 127)) 
    editor:StyleSetForeground(wxstc.wxSTC_LUA_NUMBER,  wx.wxColour(255, 150, 0)) -- Keyword
    editor:StyleSetForeground(wxstc.wxSTC_LUA_WORD,  wx.wxColour(0,   0,   255)) -- Double quoted string
    editor:StyleSetBold(wxstc.wxSTC_LUA_WORD,  true)
    --editor:StyleSetUnderline(wxstc.wxSTC_LUA_WORD, false)
    editor:StyleSetForeground(wxstc.wxSTC_LUA_STRING,  wx.wxColour(127, 0,   127)) -- Single quoted string
    editor:StyleSetForeground(wxstc.wxSTC_LUA_CHARACTER,  wx.wxColour(127, 0,   127)) -- not used
    editor:StyleSetForeground(wxstc.wxSTC_LUA_LITERALSTRING,  wx.wxColour( 127,0,  127)) -- Literal strings
    editor:StyleSetForeground(wxstc.wxSTC_LUA_PREPROCESSOR,  wx.wxColour(127, 127, 0))  -- Preprocessor
    editor:StyleSetForeground(wxstc.wxSTC_LUA_OPERATOR, wx.wxColour(0,   0,   127))   -- Operators
	editor:StyleSetBold(wxstc.wxSTC_LUA_OPERATOR, true)
    --editor:StyleSetBold(wxstc.wxSTC_LUA_OPERATOR, true)
    editor:StyleSetForeground(wxstc.wxSTC_LUA_IDENTIFIER, wx.wxColour(0,   0,   0))   -- Identifiers
    editor:StyleSetForeground(wxstc.wxSTC_LUA_STRINGEOL, wx.wxColour(0,   0,   0))   -- Unterminated strings
    editor:StyleSetBackground(wxstc.wxSTC_LUA_STRINGEOL, wx.wxColour(224, 192, 224))
    editor:StyleSetBold(wxstc.wxSTC_LUA_STRINGEOL, true)
    editor:StyleSetEOLFilled(wxstc.wxSTC_LUA_STRINGEOL, true)

    editor:StyleSetForeground(wxstc.wxSTC_LUA_WORD2, wx.wxColour(0,   127, 127))   -- Keyword 2 
    editor:StyleSetForeground(wxstc.wxSTC_LUA_WORD3, wx.wxColour(0,   127, 127))    -- Keyword 3
    editor:StyleSetForeground(wxstc.wxSTC_LUA_WORD4, wx.wxColour(0,   127, 127))    -- Keyword 4
    editor:StyleSetForeground(wxstc.wxSTC_LUA_WORD5, wx.wxColour(0, 127, 127))   -- Keyword 5
    editor:StyleSetForeground(wxstc.wxSTC_LUA_WORD6, wx.wxColour(50, 127, 127))  -- Keyword 6
    editor:StyleSetForeground(wxstc.wxSTC_LUA_WORD7, wx.wxColour(0,   127, 127)) -- Keyword 7
    editor:StyleSetBackground(wxstc.wxSTC_LUA_WORD7, wx.wxColour(0,   127, 127)) -- Keyword 8

    editor:StyleSetForeground(19, wx.wxColour(0,   127, 127))
    editor:StyleSetBackground(19, wx.wxColour(224, 255, 255))
    editor:StyleSetForeground(20, wx.wxColour(0,   127, 127))
    editor:StyleSetBackground(20, wx.wxColour(192, 255, 255))
    editor:StyleSetForeground(21, wx.wxColour(0,   127, 127))
    editor:StyleSetBackground(21, wx.wxColour(176, 255, 255))
    editor:StyleSetForeground(22, wx.wxColour(0,   127, 127))
    editor:StyleSetBackground(22, wx.wxColour(160, 255, 255))
    editor:StyleSetForeground(23, wx.wxColour(0,   127, 127))
    editor:StyleSetBackground(23, wx.wxColour(144, 255, 255))
    editor:StyleSetForeground(24, wx.wxColour(0,   127, 127))
    editor:StyleSetBackground(24, wx.wxColour(128, 155, 255))

    editor:StyleSetForeground(32, wx.wxColour(224, 192, 224))  
	editor:StyleSetBackground(wxstc.wxSTC_STYLE_LINENUMBER, wx.wxColour(192, 192, 192)) 
    editor:StyleSetForeground(wxstc.wxSTC_STYLE_LINENUMBER, wx.wxColour(100, 100, 100)) 
    --editor:StyleSetForeground(34, wx.wxColour(0,   0,   255))
    --editor:StyleSetBold(34, true)                              -- Brace incomplete highlight
	editor:StyleSetForeground(wxstc.wxSTC_STYLE_BRACELIGHT, wx.wxColour(0,   0,   255))
	editor:StyleSetBackground(wxstc.wxSTC_STYLE_BRACELIGHT, wx.wxColour(0,   255,   0))
    editor:StyleSetBold(wxstc.wxSTC_STYLE_BRACELIGHT, true)                              
    editor:StyleSetForeground(wxstc.wxSTC_STYLE_BRACEBAD, wx.wxColour(255, 0,   0))
	editor:StyleSetBackground(wxstc.wxSTC_STYLE_BRACEBAD, wx.wxColour(0, 255,   0))
    editor:StyleSetBold(wxstc.wxSTC_STYLE_BRACEBAD, true)                              
    editor:StyleSetForeground(wxstc.wxSTC_STYLE_INDENTGUIDE, wx.wxColour(192, 192, 192))-- Indentation guides
    editor:StyleSetBackground(wxstc.wxSTC_STYLE_INDENTGUIDE, wx.wxColour(255, 255, 255))

    editor:SetUseTabs(true)
    editor:SetTabWidth(4)
    editor:SetIndent(4)
    editor:SetIndentationGuides(true)

    editor:SetVisiblePolicy(wxstc.wxSTC_VISIBLE_SLOP, 3)
    --editor:SetXCaretPolicy(wxstc.wxSTC_CARET_SLOP, 10)
    --editor:SetYCaretPolicy(wxstc.wxSTC_CARET_SLOP, 3)

    editor:SetMarginWidth(0, editor:TextWidth(32, "9999")) -- line # margin

    editor:SetMarginWidth(1, 16) -- marker margin
    editor:SetMarginType(1, wxstc.wxSTC_MARGIN_SYMBOL)
    editor:SetMarginSensitive(1, true)

    editor:MarkerDefine(BREAKPOINT_MARKER,   wxstc.wxSTC_MARK_ROUNDRECT, wx.wxWHITE, wx.wxRED)
    editor:MarkerDefine(CURRENT_LINE_MARKER, wxstc.wxSTC_MARK_ARROW,     wx.wxBLACK, wx.wxGREEN)

    editor:SetMarginWidth(2, 16) -- fold margin
    editor:SetMarginType(2, wxstc.wxSTC_MARGIN_SYMBOL)
    editor:SetMarginMask(2, wxstc.wxSTC_MASK_FOLDERS)
    editor:SetMarginSensitive(2, true)

    editor:SetFoldFlags(wxstc.wxSTC_FOLDFLAG_LINEBEFORE_CONTRACTED +
                        wxstc.wxSTC_FOLDFLAG_LINEAFTER_CONTRACTED)

    editor:SetProperty("fold", "1")
    editor:SetProperty("fold.compact", "1")
    editor:SetProperty("fold.comment", "1")

    local grey = wx.wxColour(128, 128, 128)
    editor:MarkerDefine(wxstc.wxSTC_MARKNUM_FOLDEROPEN,    wxstc.wxSTC_MARK_BOXMINUS, wx.wxWHITE, grey)
    editor:MarkerDefine(wxstc.wxSTC_MARKNUM_FOLDER,        wxstc.wxSTC_MARK_BOXPLUS,  wx.wxWHITE, grey)
    editor:MarkerDefine(wxstc.wxSTC_MARKNUM_FOLDERSUB,     wxstc.wxSTC_MARK_VLINE,    wx.wxWHITE, grey)
    editor:MarkerDefine(wxstc.wxSTC_MARKNUM_FOLDERTAIL,    wxstc.wxSTC_MARK_LCORNER,  wx.wxWHITE, grey)
    editor:MarkerDefine(wxstc.wxSTC_MARKNUM_FOLDEREND,     wxstc.wxSTC_MARK_BOXPLUSCONNECTED,  wx.wxWHITE, grey)
    editor:MarkerDefine(wxstc.wxSTC_MARKNUM_FOLDEROPENMID, wxstc.wxSTC_MARK_BOXMINUSCONNECTED, wx.wxWHITE, grey)
    editor:MarkerDefine(wxstc.wxSTC_MARKNUM_FOLDERMIDTAIL, wxstc.wxSTC_MARK_TCORNER,  wx.wxWHITE, grey)
    grey:delete()

    editor:Connect(wxstc.wxEVT_STC_MARGINCLICK,
            function (event)
                local line = editor:LineFromPosition(event:GetPosition())
                local margin = event:GetMargin()
                if margin == 1 then
                    ToggleDebugMarker(editor, line)
					--editor:SetSelection(editor:PositionFromLine(line), editor:GetLineEndPosition(line))
					-- print(wxstc.wxSTC_INDIC0_MASK)
					-- print(wxstc.wxSTC_INDIC1_MASK)
					-- print(wxstc.wxSTC_INDIC2_MASK)
					-- editor:StartStyling(event:GetPosition(),wxstc.wxSTC_INDICS_MASK)
					-- editor:SetStyling(editor:GetLineEndPosition(line)-event:GetPosition(),wxstc.wxSTC_INDIC0_MASK+wxstc.wxSTC_INDIC2_MASK)
                elseif margin == 2 then
                    if wx.wxGetKeyState(wx.WXK_SHIFT) and wx.wxGetKeyState(wx.WXK_CONTROL) then
                        FoldSome()
                    else
                        local level = editor:GetFoldLevel(line)
                        --if HasBit(level, wxstc.wxSTC_FOLDLEVELHEADERFLAG) then
						if (bit.band(level,wxstc.wxSTC_FOLDLEVELHEADERFLAG) > 0) then
                            editor:ToggleFold(line)
                        end
                    end
                end
            end)

    editor:Connect(wxstc.wxEVT_STC_CHARADDED,
            function (event)
                -- auto-indent
                local ch = event:GetKey()
                if (ch == char_CR) or (ch == char_LF) then
					
                    local pos = editor:GetCurrentPos()
                    local line = editor:LineFromPosition(pos)

                    if (line > 0) then --and (editor:LineLength(line) == 0) then
                        local indent = editor:GetLineIndentation(line - 1)
                        if indent > 0 then
                            editor:SetLineIndentation(line, indent)
							editor:GotoPos(editor:GetLineIndentPosition(line))
                            --editor:GotoPos(pos)-- + indent/editor:GetTabWidth())
							--print("pos indent ",indent/editor:GetTabWidth())
							--print(pos," ",editor:GetLineIndentPosition(line)," ",pos + indent/editor:GetTabWidth())
                        end
                    end
                elseif autoCompleteEnable then -- code completion prompt
                    local pos = editor:GetCurrentPos()
                    local start_pos = editor:WordStartPosition(pos, true)
                    -- must have "wx.X" otherwise too many items
                    if (pos - start_pos > 0) and (start_pos > 2) then
                        --local range = editor:GetTextRange(start_pos-3, start_pos)
                        --if range == "wx." then
                            local commandEvent = wx.wxCommandEvent(wx.wxEVT_COMMAND_MENU_SELECTED,
                                                                   ID_AUTOCOMPLETE)
                            wx.wxPostEvent(frame, commandEvent)
                        --end
                    end
                end
            end)

    editor:Connect(wxstc.wxEVT_STC_USERLISTSELECTION,
            function (event)
                local pos = editor:GetCurrentPos()
                local start_pos = editor:WordStartPosition(pos, true)
                editor:SetSelection(start_pos, pos)
                editor:ReplaceSelection(event:GetText())
            end)

    editor:Connect(wxstc.wxEVT_STC_SAVEPOINTREACHED,
            function (event)
                SetDocumentModified(editor:GetId(), false)
            end)

    editor:Connect(wxstc.wxEVT_STC_SAVEPOINTLEFT,
            function (event)
                SetDocumentModified(editor:GetId(), true)
            end)

    editor:Connect(wxstc.wxEVT_STC_UPDATEUI,
            function (event)
                UpdateStatusText(editor)
				local braceAtCaret = -1
				local braceOpposite = -1
				local charBefore = nil
				local caretPos = editor:GetCurrentPos()
				--print(caretPos)
				if caretPos > 0 then
					charBefore = editor:GetCharAt(caretPos - 1)
					styleBefore = editor:GetStyleAt(caretPos - 1)
					--print("charBefore ",charBefore)
					--print("charBefore ",string.char(charBefore))
				else
					return
				end
				-- check before
				--if charBefore and chr(charBefore) in "[]{}()" and styleBefore == wxstc.wxSTC_LUA_OPERATOR then
				if charBefore and string.char(charBefore):find("[%[%]{}%(%)]") and styleBefore == wxstc.wxSTC_LUA_OPERATOR then
					braceAtCaret = caretPos - 1
					--print("braceAtCaret ",braceAtCaret)
				end
				-- check after
				if braceAtCaret < 0 then
					local charAfter = editor:GetCharAt(caretPos)
					local styleAfter = editor:GetStyleAt(caretPos)
					--if charAfter and chr(charAfter) in "[]{}()" and styleAfter == stc.STC_P_OPERATOR:
					if charAfter and string.char(charAfter):find("[%[%]{}%(%)]") and styleAfter == wxstc.wxSTC_LUA_OPERATOR then
						braceAtCaret = caretPos
					end
				end
				if braceAtCaret >= 0 then
					braceOpposite = editor:BraceMatch(braceAtCaret)
				end
				
				if braceAtCaret ~= -1  and braceOpposite == -1 then
					editor:BraceBadLight(braceAtCaret)
				else
					editor:BraceHighlight(braceAtCaret, braceOpposite)
				end
            end)
	editor:IndicatorSetStyle(0,wxstc.wxSTC_INDIC_BOX)
	function MarkWords(editor,what)
		
		local flags=wxstc.wxSTC_FIND_WHOLEWORD + wxstc.wxSTC_FIND_MATCHCASE
		local len=editor:GetLength()
		local wlen=string.len(what)
		
		editor:StartStyling(0,wxstc.wxSTC_INDICS_MASK)
		editor:SetStyling(len,0)
		
		local posFind=editor:FindText(0,len,what,flags)
		while posFind~=-1 do
			editor:StartStyling(posFind,wxstc.wxSTC_INDICS_MASK)
			editor:SetStyling(wlen,wxstc.wxSTC_INDIC0_MASK)
			posFind=editor:FindText(posFind+wlen,len,what,flags)
		end
	end
	editor:Connect(wxstc.wxEVT_STC_DOUBLECLICK,
            function (event)
				local startSel = editor:GetSelectionStart()
				local endSel   = editor:GetSelectionEnd()
				if (startSel ~= endSel) and (editor:LineFromPosition(startSel) == editor:LineFromPosition(endSel)) then
					MarkWords(editor,editor:GetSelectedText())
					--print(editor:GetSelectedText())
				else
					editor:StartStyling(0,wxstc.wxSTC_INDICS_MASK)
					editor:SetStyling(editor:GetLength(),0)
				end
            end)
    editor:Connect(wx.wxEVT_SET_FOCUS,
            function (event)
				currentSTC=editor
				--currentSTCed=editor
				if openDocuments[editor:GetId()] and openDocuments[editor:GetId()].identifiers then
					IdentifiersList:Set(openDocuments[editor:GetId()].identifiers)
				else
					IdentifiersList:Set({})
				end
                event:Skip()
                if in_evt_focus or exitingProgram then return end
                in_evt_focus = true
                IsFileAlteredOnDisk(editor)
                in_evt_focus = false
            end)
	--[[
	editor:Connect(wx.wxEVT_KILL_FOCUS,
            function (event)
				if (event:GetWindow()==errorLog) or (event:GetWindow()==ScLog) then
					--currentSTCed=editor
				else
					currentSTCed=nil
				end
                event:Skip()
            end)
	--]]
    if notebook:AddPage(editor, name, true) then
        local id            = editor:GetId()
        local document      = {}
        document.editor     = editor
        document.index      = notebook:GetSelection()
        document.fileName   = nil
        document.filePath   = nil
        document.modTime    = nil
        document.isModified = false
        openDocuments[id]   = document
    end

    return editor
end

function IsLuaFile(filePath)
    return filePath and (string.len(filePath) > 4) and
           (string.lower(string.sub(filePath, -4)) == ".lua")
end
----------------------------
if not setfenv then -- Lua 5.2
setfenv = setfenv or function(f, t)
    f = (type(f) == 'function' and f or debug.getinfo(f + 1, 'f').func)
    local name
    local up = 0
    repeat
        up = up + 1
        name = debug.getupvalue(f, up)
    until name == '_ENV' or name == nil
    if name then
		debug.upvaluejoin(f, up, function() return name end, 1) -- use unique upvalue
        debug.setupvalue(f, up, t)
    end
end

getfenv = getfenv or function(f)
    f = (type(f) == 'function' and f or debug.getinfo(f + 1, 'f').func)
    local name, val
    local up = 0
    repeat
        up = up + 1
        name, val = debug.getupvalue(f, up)
    until name == '_ENV' or name == nil
    return val
end
end


function stsplit(s,c)
	local t = {}
	local pat = ""..c.."?([^"..c.."]+)"..c.."?"
	for w in string.gmatch(s, pat) do  -- ";?[^;]+;?"
		t[#t + 1] = w
	end
	return t
end

function newrequire(cad)
	local env = getfenv(2)
	if package.loaded[cad] then return package.loaded[cad] end
	local chunk = loadfilefrompath(cad)
	setfenv(chunk, env)
	package.loaded[cad] = chunk()
	return package.loaded[cad]
end

function loadfilefrompath(cad)
	-- TODO win32,linux,mac?
	cad = string.gsub(cad, "%.","/")
	------------------------------------
	local paths = stsplit(package.path,";")
	for i, path in ipairs(paths) do
		local file=string.gsub(path,"?",cad)
		local chunk,errorst = loadfile(file)
		if chunk then
			return chunk
		end
	end
	error("could not loadfilefrompath "..cad) 
end
function loadinEnv(file,env)
	local function newindex(t,key,val)
		local info=debug.getinfo(2)
		--print ("setting "..key.." from line "..info.currentline.." in file "..info.short_src)
		sckeywordsSource[key] = {currentline = info.currentline,source = info.source}
		rawset(t,key,val)
	end
	if not env then
		env = setmetatable({}, {__index = _G,__newindex=newindex}) 
		env.require = newrequire
		env.package = setmetatable({}, {__index = _G.package})
		env.package.loaded = {}
	end
	local f = loadfilefrompath(file)
	setfenv(f, env)
	f()
	return env
end
-----------------------------
function SetupKeywords(editor, useLuaParser)
	
    if useLuaParser then
        editor:SetLexer(wxstc.wxSTC_LEX_LUA)

        -- Note: these keywords are shamelessly ripped from scite 1.68
        editor:SetKeyWords(0,
            [[and break do else elseif end false for function if
            in local nil not or repeat return then true until while]])
        editor:SetKeyWords(1,
            [[_VERSION assert collectgarbage dofile error gcinfo loadfile loadstring
            print rawget rawset require tonumber tostring type unpack]])
        editor:SetKeyWords(2,
            [[_G getfenv getmetatable ipairs loadlib next pairs pcall
            rawequal setfenv setmetatable xpcall
            string table math coroutine io os debug
            load module select]])
        editor:SetKeyWords(3,
            [[string.byte string.char string.dump string.find string.len
            string.lower string.rep string.sub string.upper string.format string.gfind string.gsub
            table.concat table.foreach table.foreachi table.getn table.sort table.insert table.remove table.setn
            math.abs math.acos math.asin math.atan math.atan2 math.ceil math.cos math.deg math.exp
            math.floor math.frexp math.ldexp math.log math.log10 math.max math.min math.mod
            math.pi math.pow math.rad math.random math.randomseed math.sin math.sqrt math.tan
            string.gmatch string.match string.reverse table.maxn
            math.cosh math.fmod math.modf math.sinh math.tanh math.huge]])
        editor:SetKeyWords(4,
            [[coroutine.create coroutine.resume coroutine.status
            coroutine.wrap coroutine.yield
            io.close io.flush io.input io.lines io.open io.output io.read io.tmpfile io.type io.write
            io.stdin io.stdout io.stderr
            os.clock os.date os.difftime os.execute os.exit os.getenv os.remove os.rename
            os.setlocale os.time os.tmpname
            coroutine.running package.cpath package.loaded package.loadlib package.path
            package.preload package.seeall io.popen
            debug.debug debug.getfenv debug.gethook debug.getinfo debug.getlocal
            debug.getmetatable debug.getregistry debug.getupvalue debug.setfenv
            debug.sethook debug.setlocal debug.setmetatable debug.setupvalue debug.traceback]])
		--[[
        -- Get the items in the global "wx" table for autocompletion
        if not wxkeywords then
            local keyword_table = {}
            for index, value in pairs(wx) do
                table.insert(keyword_table, "wx."..index.." ")
            end

            table.sort(keyword_table)
            wxkeywords = table.concat(keyword_table)
        end
		
        editor:SetKeyWords(5, wxkeywords)
		--]]
		---[[
		if not sckeywords then
			sckeywordsSource = {}
			local env = loadinEnv"sc.synthdefsc"
			loadinEnv("sc.playerssc",env)
			loadinEnv("sc.stream",env)
			local keyword_table = {}
            for index, value in pairs(env) do
				if type(value)=="function" then
					table.insert(keyword_table, index.." ")
				elseif type(value)=="table" then
					table.insert(keyword_table, index.." ")
					for i2,v2 in pairs(value) do
						if type(v2)=="function" then
							table.insert(keyword_table, index.."."..i2.." ")
							local info = debug.getinfo(v2)
							sckeywordsSource[index.."."..i2] = {currentline = info.linedefined,source = info.source}
							--print(index.."."..i2,info.linedefined,info.source)
							--table.insert(keyword_table, index.." ")
							--table.insert(keyword_table, "."..i2.." ")
						end
					end
				end
            end

            table.sort(keyword_table)
            sckeywords = table.concat(keyword_table)
			--print(sckeywords)
        end
        editor:SetKeyWords(5, sckeywords)
		--]]
    else
        editor:SetLexer(wxstc.wxSTC_LEX_NULL)
        editor:SetKeyWords(0, "")
    end

    editor:Colourise(0, -1)
end

function CreateAutoCompList(key_) -- much faster than iterating the wx. table
    local key = key_ --"wx."..key_;
    local a, b = string.find(sckeywords, key, 1, 1)
    local key_list = ""

    while a do
        local c, d = string.find(sckeywords, " ", b, 1)
        key_list = key_list..string.sub(sckeywords, a, c or -1)
        a, b = string.find(sckeywords, key, d, 1)
    end

    return key_list
end



-- ---------------------------------------------------------------------------
-- Create the File menu and attach the callback functions

-- force all the wxEVT_UPDATE_UI handlers to be called
function UpdateUIMenuItems()
    if frame and frame:GetMenuBar() then
        for n = 0, frame:GetMenuBar():GetMenuCount()-1 do
            frame:GetMenuBar():GetMenu(n):UpdateUI()
        end
    end
end
--]]
function InitFileMenu()
	menuBar = wx.wxMenuBar()
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
end
---------------------perspectives
------------------------------------------------------
function ConfigSavePerpectives()
	ConfigSaveFramePosition(frame,"MainFrame")
	local path = config:GetPath()
	config:DeleteGroup("/perspectives")
    config:SetPath("/perspectives")
	local goodwrite=false
	config:Write("currentperspective",currentperspective)
	if m_perspectives:GetCount() > 0 then
		for i=0,m_perspectives:GetCount()-1 do
			--wx.wxMessageBox("escribiendo perpective "..tostring(i))
			goodwrite=config:Write(string.format("p%u",i),m_perspectives:Item(i))
			--if not goodwrite then wx.wxMessageBox("No escribo perpective "..tostring(i)) end
			goodwrite=config:Write(string.format("pn%u",i),m_perspectives_names:Item(i))
			--if not goodwrite then wx.wxMessageBox("No escribo perpective name "..tostring(i)) end
		end
	end
	if currentperspective == -1 then
		print("saving -1 perspective")
		config:Write("p-1",manager:SavePerspective())
		config:Write("pn-1","LastPerspective")
	end
	config:SetPath(path)
end
function ConfigLoadPerpectives()
	
	local path = config:GetPath()
    config:SetPath("/perspectives")
	_,currentperspective=config:Read("currentperspective",-1)
	local more=true
	local i=0,p,pn
	m_perspectives_menu:AppendSeparator();
	while true do
		if config:HasEntry(string.format("p%u",i)) then
			more,p=config:Read(string.format("p%u",i))
			if not more then wx.wxMessageBox("No leo perpective "..tostring(i));break end
			more,pn=config:Read(string.format("pn%u",i))
			if not more then wx.wxMessageBox("No leo perpective name "..tostring(i)); break end
			--wx.wxMessageBox(pn)
			m_perspectives_names:Add(pn);
			m_perspectives:Add(p);
			m_perspectives_menu:AppendRadioItem(ID_FirstPerspective + i, pn);
			i=i+1
		else
			break
		end
	end
	if currentperspective >-1 then
		m_perspectives_menu:Check(ID_FirstPerspective+currentperspective,true)
		SetPerspective(currentperspective)
	else
		-- if (m_perspectives:GetCount() == 0) then
			-- print("init perspectives")
			-- m_perspectives_menu:AppendRadioItem(ID_FirstPerspective + 1, "Default perspective");
			-- m_perspectives_names:Add("Default perspective");
			-- m_perspectives:Add(manager:SavePerspective());
		-- end
		print("looking for -1 perpective")
		if config:HasEntry("p-1") then
			print("loading -1 perpective")
			more,p=config:Read("p-1")
			if not more then wx.wxMessageBox("No leo perpective "..tostring(-1)) end
			more,pn=config:Read("pn-1")
			if not more then wx.wxMessageBox("No leo perpective name "..tostring(-1)) end
			-- m_perspectives_names:Add(pn);
			-- m_perspectives:Add(p);
			-- m_perspectives_menu:AppendRadioItem(ID_FirstPerspective + i, pn);
			manager:LoadPerspective(p)
		end
	end
	config:SetPath(path)
	ConfigRestoreFramePosition(frame,"MainFrame")
end

function SetPerspective(val)
	print("SetPerspective",val)
	if (val >=0) then
		manager:LoadPerspective(m_perspectives:Item(val));
		currentperspective=val
	end
end

function OnCreatePerspective(event)
    local this = frame
	if (m_perspectives:GetCount() >= 9) then
		wx.wxMessageBox("Reached maximum of 9 perspectives.")
		return
	end
    local dlg = wx.wxTextEntryDialog(this, wxT("Enter a name for the new perspective:"),
                          wxT("wxAUI Test"));

    dlg:SetValue(string.format(wxT("Perspective %u"), (m_perspectives:GetCount() + 1)));
    if (dlg:ShowModal() ~= wx.wxID_OK) then
        return;
    end

    if (m_perspectives:GetCount() == 0) then
        m_perspectives_menu:AppendSeparator();
    end

    m_perspectives_menu:AppendRadioItem(ID_FirstPerspective + m_perspectives:GetCount(), dlg:GetValue());
	m_perspectives_names:Add(dlg:GetValue());
    m_perspectives:Add(manager:SavePerspective());
	
	currentperspective=m_perspectives:GetCount()-1
	m_perspectives_menu:Check(ID_FirstPerspective + m_perspectives:GetCount()-1,true)
	--local pp=manager:SavePaneInfo(manager:GetPane(notebookLogs))
	--print("notebookLogs")
	--print(pp)
	--wx.wxMessageBox(tostring(m_perspectives_names:GetCount()))
	--wx.wxMessageBox(m_perspectives_names:Item(m_perspectives_names:GetCount()-1))
end
function OnDeletePerspective(event)
    local this = frame
	if currentperspective==-1 then
		wx.wxMessageBox("There is not selected perspective.")
		return
	end
	
    m_perspectives_menu:Delete(ID_FirstPerspective + currentperspective);
	m_perspectives_names:RemoveAt(currentperspective);
    m_perspectives:RemoveAt(currentperspective);
	currentperspective=-1
	-- currentperspective=currentperspective-1
	-- if currentperspective > -1 then
		-- m_perspectives_menu:Check(ID_FirstPerspective + currentperspective,true)
	-- end
end

function OnRestorePerspective(evt)
	print("OnRestorePerspective",evt:GetId())
    manager:LoadPerspective(m_perspectives:Item(evt:GetId() - ID_FirstPerspective));
	currentperspective=evt:GetId() - ID_FirstPerspective
	--m_perspectives_menu:Check(evt:GetId(),true)
end

function InitPerspectivesMenu()

	ID_FullScreen = NewID()
	ID_CreatePerspective=NewID()
	ID_DeletePerspective=NewID()
	ID_FirstPerspective = NewID()
	for i=1,9 do NewID() end
	
	frame:Connect(ID_CreatePerspective, wx.wxEVT_COMMAND_MENU_SELECTED, function(event) OnCreatePerspective(event) end)
	frame:Connect(ID_DeletePerspective, wx.wxEVT_COMMAND_MENU_SELECTED, function(event) OnDeletePerspective(event) end)
	--frame:Connect(ID_CopyPerspectiveCode, wx.wxEVT_COMMAND_MENU_SELECTED, function(event) OnCopyPerspectiveCode(event) end)
	frame:Connect(ID_FirstPerspective+0,ID_FirstPerspective+9, wx.wxEVT_COMMAND_MENU_SELECTED, function(event) OnRestorePerspective(event) end)
	frame:Connect(ID_FullScreen,  wx.wxEVT_COMMAND_MENU_SELECTED,
		function(event)
			frame:ShowFullScreen(event:IsChecked(),
			--wx.wxFULLSCREEN_NOMENUBAR
			--wxFULLSCREEN_NOTOOLBAR
			--wxFULLSCREEN_NOSTATUSBAR
			wx.wxFULLSCREEN_NOBORDER
			+wx.wxFULLSCREEN_NOCAPTION )	
		end)
	
	m_perspectives = wx.wxArrayString()
	m_perspectives_names = wx.wxArrayString()
	m_perspectives_menu = wx.wxMenu();
	m_perspectives_menu:AppendCheckItem(ID_FullScreen,"&Full Screen\tCtrl+Shift+F");
	m_perspectives_menu:AppendSeparator()
	m_perspectives_menu:Append(ID_CreatePerspective,"Create Perspective");
	m_perspectives_menu:Append(ID_DeletePerspective, "Delete Perspective");
	
	menuBar:Append(m_perspectives_menu, "&View")
	--m_perspectives_menu:Check(ID_FullScreen, false)
	--currentperspective=0
	ConfigLoadPerpectives()

	
end
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
-- MRU
function MRUInit()
	ID_MRU=NewID()
	mruMenu=wx.wxMenu()
	fileMenu:Append(ID_MRU,"Recent Files",mruMenu)
	file_history=wx.wxFileHistory()
	file_history:Load(config)
	file_history:UseMenu(mruMenu)
	file_history:AddFilesToMenu()
	
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
    SetupKeywords(editor, true)
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
    SetupKeywords(editor, IsLuaFile(filePath))
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
	IdentifiersList:SetEditor(editor,true)
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
			IdentifiersList:SetEditor(editor,true)
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
			IdentifiersList:SetEditor(editor,true)
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
            SetupKeywords(editor, IsLuaFile(filePath))
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



-- ---------------------------------------------------------------------------
-- Create the Edit menu and attach the callback functions
function InitEditMenu()
	editMenu = wx.wxMenu{
			{ ID_CUT,       "Cu&t\tCtrl-X",        "Cut selected text to clipboard" },
			{ ID_COPY,      "&Copy\tCtrl-C",       "Copy selected text to the clipboard" },
			{ ID_PASTE,     "&Paste\tCtrl-V",      "Insert clipboard text at cursor" },
			{ ID_SELECTALL, "Select A&ll\tCtrl-A", "Select all text in the editor" },
			{ },
			{ ID_UNDO,      "&Undo\tCtrl-Z",       "Undo the last action" },
			{ ID_REDO,      "&Redo\tCtrl-Y",       "Redo the last action undone" },
			{ },
			{ ID_AUTOCOMPLETE,        "Complete &Identifier\tCtrl+K", "Complete the current identifier" },
			{ ID_AUTOCOMPLETE_ENABLE, "Auto complete Identifiers",    "Auto complete while typing", wx.wxITEM_CHECK },
			{ },
			{ ID_COMMENT, "C&omment/Uncomment\tCtrl-Q", "Comment or uncomment current or selected lines"},
			{ },
			{ ID_FOLD,    "&Fold/Unfold all\tF12", "Fold or unfold all code folds"} }
	menuBar:Append(editMenu, "&Edit")
	
	editMenu:Check(ID_AUTOCOMPLETE_ENABLE, autoCompleteEnable)
		frame:Connect(ID_CUT, wx.wxEVT_COMMAND_MENU_SELECTED, OnEditMenu)
	frame:Connect(ID_CUT, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)
	
	frame:Connect(ID_COPY, wx.wxEVT_COMMAND_MENU_SELECTED, OnEditMenu)
	frame:Connect(ID_COPY, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)
	
	frame:Connect(ID_PASTE, wx.wxEVT_COMMAND_MENU_SELECTED, OnEditMenu)
	frame:Connect(ID_PASTE, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				-- buggy GTK clipboard runs eventloop and can generate asserts
				event:Enable(editor and (wx.__WXGTK__ or editor:CanPaste()))
			end)
	
	frame:Connect(ID_SELECTALL, wx.wxEVT_COMMAND_MENU_SELECTED, OnEditMenu)
	frame:Connect(ID_SELECTALL, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)
	
	frame:Connect(ID_UNDO, wx.wxEVT_COMMAND_MENU_SELECTED, OnEditMenu)
	frame:Connect(ID_UNDO, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				event:Enable(editor and editor:CanUndo())
			end)
	
	frame:Connect(ID_REDO, wx.wxEVT_COMMAND_MENU_SELECTED, OnEditMenu)
	frame:Connect(ID_REDO, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				event:Enable(editor and editor:CanRedo())
			end)
	
	frame:Connect(ID_AUTOCOMPLETE, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				local editor = GetEditor()
				if (editor == nil) then return end
				local pos = editor:GetCurrentPos()
				local start_pos = editor:WordStartPosition(pos, true)
				-- must have "wx.XX" otherwise too many items
				if (pos - start_pos > 2) and (start_pos > 2) then
					--local range = editor:GetTextRange(start_pos-3, start_pos)
					--if range == "wx." then
						local key = editor:GetTextRange(start_pos, pos)
						local userList = CreateAutoCompList(key)
						if userList and string.len(userList) > 0 then
							editor:UserListShow(1, userList)
						end
					--end
				end
			end)
	frame:Connect(ID_AUTOCOMPLETE, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)
	
	frame:Connect(ID_AUTOCOMPLETE_ENABLE, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				autoCompleteEnable = event:IsChecked()
			end)
	
	frame:Connect(ID_COMMENT, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				local editor = GetEditor()
				local buf = {}
				if editor:GetSelectionStart() == editor:GetSelectionEnd() then
					local lineNumber = editor:GetCurrentLine()
					editor:SetSelection(editor:PositionFromLine(lineNumber), editor:GetLineEndPosition(lineNumber))
				end
				for line in string.gmatch(editor:GetSelectedText()..'\n', "(.-)\r?\n") do
					if string.sub(line,1,2) == '--' then
						line = string.sub(line,3)
					else
						line = '--'..line
					end
					table.insert(buf, line)
				end
				editor:ReplaceSelection(table.concat(buf,"\n"))
			end)
	frame:Connect(ID_COMMENT, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)
	frame:Connect(ID_FOLD, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				FoldSome()
			end)
	frame:Connect(ID_FOLD, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)
end
function OnUpdateUIEditMenu(event) -- enable if there is a valid focused editor
	local editor = GetEditor()
	event:Enable(editor ~= nil)
end
	
function OnEditMenu(event)
    local menu_id = event:GetId()
    local editor = GetEditor()
    if editor == nil then return end

    if     menu_id == ID_CUT       then editor:Cut()
    elseif menu_id == ID_COPY      then editor:Copy()
    elseif menu_id == ID_PASTE     then editor:Paste()
    elseif menu_id == ID_SELECTALL then editor:SelectAll()
    elseif menu_id == ID_UNDO      then editor:Undo()
    elseif menu_id == ID_REDO      then editor:Redo()
    end
end


function FoldSome()
    local editor = GetEditor()
    editor:Colourise(0, -1)       -- update doc's folding info
    local visible, baseFound, expanded, folded
    for ln = 2, editor.LineCount - 1 do
        local foldRaw = editor:GetFoldLevel(ln)
        local foldLvl = math.mod(foldRaw, 4096)
        local foldHdr = math.mod(math.floor(foldRaw / 8192), 2) == 1
        if not baseFound and (foldLvl ==  wxstc.wxSTC_FOLDLEVELBASE) then
            baseFound = true
            visible = editor:GetLineVisible(ln)
        end
        if foldHdr then
            if editor:GetFoldExpanded(ln) then
                expanded = true
            else
                folded = true
            end
        end
        if expanded and folded and baseFound then break end
    end
    local show = not visible or (not baseFound and expanded) or (expanded and folded)
    local hide = visible and folded

    if show then
        editor:ShowLines(1, editor.LineCount-1)
    end

    for ln = 1, editor.LineCount - 1 do
        local foldRaw = editor:GetFoldLevel(ln)
        local foldLvl = math.mod(foldRaw, 4096)
        local foldHdr = math.mod(math.floor(foldRaw / 8192), 2) == 1
        if show then
            if foldHdr then
                if not editor:GetFoldExpanded(ln) then editor:ToggleFold(ln) end
            end
        elseif hide and (foldLvl == wxstc.wxSTC_FOLDLEVELBASE) then
            if not foldHdr then
                editor:HideLines(ln, ln)
            end
        elseif foldHdr then
            if editor:GetFoldExpanded(ln) then
                editor:ToggleFold(ln)
            end
        end
    end
    editor:EnsureCaretVisible()
end



-- ---------------------------------------------------------------------------
-- Create the Search menu and attach the callback functions
function InitFindMenu()
	findMenu = wx.wxMenu{
        { ID_FIND,       "&Find\tCtrl-F",            "Find the specified text" },
        { ID_FINDNEXT,   "Find &Next\tF3",           "Find the next occurrence of the specified text" },
        { ID_FINDPREV,   "Find &Previous\tShift-F3", "Repeat the search backwards in the file" },
        { ID_REPLACE,    "&Replace\tCtrl-H",         "Replaces the specified text with different text" },
        { },
		{ID_FIND_SOURCE, "Find Source" , "Opens source file from keyword."},
		{},
        { ID_GOTOLINE,   "&Goto line\tCtrl-G",       "Go to a selected line" },
        { },
        { ID_SORT,       "&Sort",                    "Sort selected lines"}}
	menuBar:Append(findMenu, "&Search")
	frame:Connect(ID_FIND, wx.wxEVT_COMMAND_MENU_SELECTED,
        function (event)
            findReplace:GetSelectedString()
            findReplace:Show(false)
        end)
	frame:Connect(ID_FIND, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)
	frame:Connect(ID_FIND_SOURCE, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)
	frame:Connect(ID_FIND_SOURCE, wx.wxEVT_COMMAND_MENU_SELECTED,
        function (event)
            local editor = currentSTC --GetEditor()
			if editor then
				local startSel = editor:GetSelectionStart()
				local endSel   = editor:GetSelectionEnd()
				if (startSel ~= endSel) and (editor:LineFromPosition(startSel) == editor:LineFromPosition(endSel)) then
					local searchtex = editor:GetSelectedText()
					local v = sckeywordsSource[searchtex]
					if v then
						abriredit(v.source:sub(2),v.currentline)
						--print(v.source:sub(2),v.currentline)
					end
				end
			end
        end)
	frame:Connect(ID_REPLACE, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				findReplace:GetSelectedString()
				findReplace:Show(true)
			end)
	frame:Connect(ID_REPLACE, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)
	
	frame:Connect(ID_FINDNEXT, wx.wxEVT_COMMAND_MENU_SELECTED, function (event) findReplace:FindString() end)
	frame:Connect(ID_FINDNEXT, wx.wxEVT_UPDATE_UI, function (event) findReplace:HasText() end)
	
	frame:Connect(ID_FINDPREV, wx.wxEVT_COMMAND_MENU_SELECTED, function (event) findReplace:FindString(true) end)
	frame:Connect(ID_FINDPREV, wx.wxEVT_UPDATE_UI, function (event) findReplace:HasText() end)
	
	-------------------- Find replace end
	
	frame:Connect(ID_GOTOLINE, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				local editor = GetEditor()
				local linecur = editor:LineFromPosition(editor:GetCurrentPos())
				local linemax = editor:LineFromPosition(editor:GetLength()) + 1
				local linenum = wx.wxGetNumberFromUser( "Enter line number",
														"1 .. "..tostring(linemax),
														"Goto Line",
														linecur, 1, linemax,
														frame)
				if linenum > 0 then
					editor:GotoLine(linenum-1)
				end
			end)
	frame:Connect(ID_GOTOLINE, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)
	
	frame:Connect(ID_SORT, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				local editor = GetEditor()
				local buf = {}
				for line in string.gmatch(editor:GetSelectedText()..'\n', "(.-)\r?\n") do
					table.insert(buf, line)
				end
				if #buf > 0 then
					table.sort(buf)
					editor:ReplaceSelection(table.concat(buf,"\n"))
				end
			end)
	frame:Connect(ID_SORT, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)
end

function EnsureRangeVisible(editor,posStart, posEnd)
    --local editor = GetEditor()
    if posStart > posEnd then
        posStart, posEnd = posEnd, posStart
    end

    local lineStart = editor:LineFromPosition(posStart)
    local lineEnd   = editor:LineFromPosition(posEnd)
    for line = lineStart, lineEnd do
        editor:EnsureVisibleEnforcePolicy(line)
    end
end

-------------------- Find replace dialog

function SetSearchFlags(editor)
    local flags = 0
    if findReplace.fWholeWord   then flags = wxstc.wxSTC_FIND_WHOLEWORD end
    if findReplace.fMatchCase   then flags = flags + wxstc.wxSTC_FIND_MATCHCASE end
    if findReplace.fRegularExpr then flags = flags + wxstc.wxSTC_FIND_REGEXP end
    editor:SetSearchFlags(flags)
end

function SetTarget(editor, fDown, fInclude)
    local selStart = editor:GetSelectionStart()
    local selEnd =  editor:GetSelectionEnd()
    local len = editor:GetLength()
    local s, e
    if fDown then
        e= len
        s = iff(fInclude, selStart, selEnd +1)
    else
        s = 0
        e = iff(fInclude, selEnd, selStart-1)
    end
    if not fDown and not fInclude then s, e = e, s end
    editor:SetTargetStart(s)
    editor:SetTargetEnd(e)
    return e
end

function findReplace:HasText()
    return (findReplace.findText ~= nil) and (string.len(findReplace.findText) > 0)
end

function findReplace:GetSelectedString()
    local editor = currentSTC --GetEditor()
    if editor then
        local startSel = editor:GetSelectionStart()
        local endSel   = editor:GetSelectionEnd()
        if (startSel ~= endSel) and (editor:LineFromPosition(startSel) == editor:LineFromPosition(endSel)) then
            findReplace.findText = editor:GetSelectedText()
            findReplace.foundString = true
        end
    end
end

function findReplace:FindString(reverse)
    if findReplace:HasText() then
		local editor
		if currentSTC then
			editor =currentSTC --:DynamicCast("wxStyledTextCtrl")
		else
			--editor = GetEditor()
			return
		end

        local fDown = iff(reverse, not findReplace.fDown, findReplace.fDown)
        local lenFind = string.len(findReplace.findText)
        SetSearchFlags(editor)
        SetTarget(editor, fDown)
        local posFind = editor:SearchInTarget(findReplace.findText)
        if (posFind == -1) and findReplace.fWrap then
            editor:SetTargetStart(iff(fDown, 0, editor:GetLength()))
            editor:SetTargetEnd(iff(fDown, editor:GetLength(), 0))
            posFind = editor:SearchInTarget(findReplace.findText)
        end
        if posFind == -1 then
            findReplace.foundString = false
            frame:SetStatusText("Find text not found.")
        else
            findReplace.foundString = true
            local start  = editor:GetTargetStart()
            local finish = editor:GetTargetEnd()
            EnsureRangeVisible(editor,start, finish)
            editor:SetSelection(start, finish)
        end
    end
end

function ReplaceString(fReplaceAll)
    if findReplace:HasText() then
        local replaceLen = string.len(findReplace.replaceText)
        local editor = currentSTC --GetEditor()
		if not editor then return end
        local findLen = string.len(findReplace.findText)
        local endTarget  = SetTarget(editor, findReplace.fDown, fReplaceAll)
        if fReplaceAll then
            SetSearchFlags(editor)
            local posFind = editor:SearchInTarget(findReplace.findText)
            if (posFind ~= -1)  then
                editor:BeginUndoAction()
                while posFind ~= -1 do
                    editor:ReplaceTarget(findReplace.replaceText)
                    editor:SetTargetStart(posFind + replaceLen)
                    endTarget = endTarget + replaceLen - findLen
                    editor:SetTargetEnd(endTarget)
                    posFind = editor:SearchInTarget(findReplace.findText)
                end
                editor:EndUndoAction()
            end
        else
            if findReplace.foundString then
                local start  = editor:GetSelectionStart()
                editor:ReplaceSelection(findReplace.replaceText)
                editor:SetSelection(start, start + replaceLen)
                findReplace.foundString = false
            end
            findReplace:FindString()
        end
    end
end

function CreateFindReplaceDialog(replace)
    local ID_FIND_NEXT   = 1
    local ID_REPLACE     = 2
    local ID_REPLACE_ALL = 3
    findReplace.replace  = replace

    local findDialog = wx.wxDialog(frame, wx.wxID_ANY, "Find",  wx.wxDefaultPosition, wx.wxDefaultSize)

    -- Create right hand buttons and sizer
    local findButton = wx.wxButton(findDialog, ID_FIND_NEXT, "&Find Next")
    findButton:SetDefault()
    local replaceButton =  wx.wxButton(findDialog, ID_REPLACE, "&Replace")
    local replaceAllButton = nil
    if (replace) then
        replaceAllButton =  wx.wxButton(findDialog, ID_REPLACE_ALL, "Replace &All")
    end
    local cancelButton =  wx.wxButton(findDialog, wx.wxID_CANCEL, "Cancel")

    local buttonsSizer = wx.wxBoxSizer(wx.wxVERTICAL)
    buttonsSizer:Add(findButton,    0, wx.wxALL + wx.wxGROW + wx.wxCENTER, 3)
    buttonsSizer:Add(replaceButton, 0, wx.wxALL + wx.wxGROW + wx.wxCENTER, 3)
    if replace then
        buttonsSizer:Add(replaceAllButton, 0, wx.wxALL + wx.wxGROW + wx.wxCENTER, 3)
    end
    buttonsSizer:Add(cancelButton, 0, wx.wxALL + wx.wxGROW + wx.wxCENTER,  3)

    -- Create find/replace text entry sizer
    local findStatText  = wx.wxStaticText( findDialog, wx.wxID_ANY, "Find: ")
    local findTextCombo = wx.wxComboBox(findDialog, wx.wxID_ANY, findReplace.findText,  wx.wxDefaultPosition, wx.wxDefaultSize, findReplace.findTextArray, wx.wxCB_DROPDOWN)
    findTextCombo:SetFocus()

    local replaceStatText, replaceTextCombo
    if (replace) then
        replaceStatText  = wx.wxStaticText( findDialog, wx.wxID_ANY, "Replace: ")
        replaceTextCombo = wx.wxComboBox(findDialog, wx.wxID_ANY, findReplace.replaceText,  wx.wxDefaultPosition, wx.wxDefaultSize,  findReplace.replaceTextArray)
    end

    local findReplaceSizer = wx.wxFlexGridSizer(2, 2, 0, 0)
    findReplaceSizer:AddGrowableCol(1)
    findReplaceSizer:Add(findStatText,  0, wx.wxALL + wx.wxALIGN_LEFT, 0)
    findReplaceSizer:Add(findTextCombo, 1, wx.wxALL + wx.wxGROW + wx.wxCENTER, 0)

    if (replace) then
        findReplaceSizer:Add(replaceStatText,  0, wx.wxTOP + wx.wxALIGN_CENTER, 5)
        findReplaceSizer:Add(replaceTextCombo, 1, wx.wxTOP + wx.wxGROW + wx.wxCENTER, 5)
    end

    -- Create find/replace option checkboxes
    local wholeWordCheckBox  = wx.wxCheckBox(findDialog, wx.wxID_ANY, "Match &whole word")
    local matchCaseCheckBox  = wx.wxCheckBox(findDialog, wx.wxID_ANY, "Match &case")
    local wrapAroundCheckBox = wx.wxCheckBox(findDialog, wx.wxID_ANY, "Wrap ar&ound")
    local regexCheckBox      = wx.wxCheckBox(findDialog, wx.wxID_ANY, "Regular &expression")
    wholeWordCheckBox:SetValue(findReplace.fWholeWord)
    matchCaseCheckBox:SetValue(findReplace.fMatchCase)
    wrapAroundCheckBox:SetValue(findReplace.fWrap)
    regexCheckBox:SetValue(findReplace.fRegularExpr)

    local optionSizer = wx.wxBoxSizer(wx.wxVERTICAL, findDialog)
    optionSizer:Add(wholeWordCheckBox,  0, wx.wxALL + wx.wxGROW + wx.wxCENTER, 3)
    optionSizer:Add(matchCaseCheckBox,  0, wx.wxALL + wx.wxGROW + wx.wxCENTER, 3)
    optionSizer:Add(wrapAroundCheckBox, 0, wx.wxALL + wx.wxGROW + wx.wxCENTER, 3)
    optionSizer:Add(regexCheckBox,      0, wx.wxALL + wx.wxGROW + wx.wxCENTER, 3)
    local optionsSizer = wx.wxStaticBoxSizer(wx.wxVERTICAL, findDialog, "Options" );
    optionsSizer:Add(optionSizer, 0, 0, 5)

    -- Create scope radiobox
    local scopeRadioBox = wx.wxRadioBox(findDialog, wx.wxID_ANY, "Scope", wx.wxDefaultPosition, wx.wxDefaultSize,  {"&Up", "&Down"}, 1, wx.wxRA_SPECIFY_COLS)
    scopeRadioBox:SetSelection(iff(findReplace.fDown, 1, 0))
    local scopeSizer = wx.wxBoxSizer(wx.wxVERTICAL, findDialog );
    scopeSizer:Add(scopeRadioBox, 0, 0, 0)

    -- Add all the sizers to the dialog
    local optionScopeSizer = wx.wxBoxSizer(wx.wxHORIZONTAL)
    optionScopeSizer:Add(optionsSizer, 0, wx.wxALL + wx.wxGROW + wx.wxCENTER, 5)
    optionScopeSizer:Add(scopeSizer,   0, wx.wxALL + wx.wxGROW + wx.wxCENTER, 5)

    local leftSizer = wx.wxBoxSizer(wx.wxVERTICAL)
    leftSizer:Add(findReplaceSizer, 0, wx.wxALL + wx.wxGROW + wx.wxCENTER, 0)
    leftSizer:Add(optionScopeSizer, 0, wx.wxALL + wx.wxGROW + wx.wxCENTER, 0)

    local mainSizer = wx.wxBoxSizer(wx.wxHORIZONTAL)
    mainSizer:Add(leftSizer, 0, wx.wxALL + wx.wxGROW + wx.wxCENTER, 10)
    mainSizer:Add(buttonsSizer, 0, wx.wxALL + wx.wxGROW + wx.wxCENTER, 10)
    mainSizer:SetSizeHints( findDialog )
    findDialog:SetSizer(mainSizer)

    local function PrependToArray(t, s)
        if string.len(s) == 0 then return end
        for i, v in ipairs(t) do
            if v == s then
                table.remove(t, i) -- remove old copy
                break
            end
        end
        table.insert(t, 1, s)
        if #t > 15 then table.remove(t, #t) end -- keep reasonable length
    end

    local function TransferDataFromWindow()
        findReplace.fWholeWord   = wholeWordCheckBox:GetValue()
        findReplace.fMatchCase   = matchCaseCheckBox:GetValue()
        findReplace.fWrap        = wrapAroundCheckBox:GetValue()
        findReplace.fDown        = scopeRadioBox:GetSelection() == 1
        findReplace.fRegularExpr = regexCheckBox:GetValue()
        findReplace.findText     = findTextCombo:GetValue()
        PrependToArray(findReplace.findTextArray, findReplace.findText)
        if findReplace.replace then
            findReplace.replaceText = replaceTextCombo:GetValue()
            PrependToArray(findReplace.replaceTextArray, findReplace.replaceText)
        end
        return true
    end

    findDialog:Connect(ID_FIND_NEXT, wx.wxEVT_COMMAND_BUTTON_CLICKED,
        function(event)
            TransferDataFromWindow()
            findReplace:FindString()
        end)

    findDialog:Connect(ID_REPLACE, wx.wxEVT_COMMAND_BUTTON_CLICKED,
        function(event)
            TransferDataFromWindow()
            event:Skip()
            if findReplace.replace then
                ReplaceString()
            else
                findReplace.dialog:Destroy()
                findReplace.dialog = CreateFindReplaceDialog(true)
                findReplace.dialog:Show(true)
            end
        end)

    if replace then
        findDialog:Connect(ID_REPLACE_ALL, wx.wxEVT_COMMAND_BUTTON_CLICKED,
            function(event)
                TransferDataFromWindow()
                event:Skip()
                ReplaceString(true)
            end)
    end

    findDialog:Connect(wx.wxID_ANY, wx.wxEVT_CLOSE_WINDOW,
        function (event)
            TransferDataFromWindow()
            event:Skip()
            findDialog:Show(false)
            findDialog:Destroy()
			findReplace.dialog=nil
        end)

    return findDialog
end

function findReplace:Show(replace)
    --self.dialog = nil
	if self.dialog then 
		self.dialog:Destroy()
	end
    self.dialog = CreateFindReplaceDialog(replace)
    self.dialog:Show(true)
end



-- ---------------------------------------------------------------------------
-- Create the Debug menu and attach the callback functions
function InitRunMenu()
	local debugMenu = wx.wxMenu{
       -- { ID_TOGGLEBREAKPOINT, "Toggle &Breakpoint\tF9", "Toggle Breakpoint" },
       -- { },
        { ID_COMPILE,          "&Compile",           "Test compile the Lua program" },
        { ID_RUN,              "&Run\tF6",               "Execute the current file" },
		--{ ID_RUN2,              "&Run 2",               "Execute 2 the current file" },
		{ ID_RUN3,              "&Run plain lane\tF7",               "Execute current file" },
		{ ID_CANCELRUN,              "&Cancel Run\tF5",               "Stops execution" },
		{ ID_KILLRUN,              "&Kill script",               "Stops execution" },
        { },
        { ID_CLEAROUTPUT,      "C&lear Output Window",    "Clear the output window before compiling or debugging", wx.wxITEM_CHECK },
        { }, { ID_SETTINGS,    "Settings", "Set running options." }
        }
	menuBar:Append(debugMenu, "&Debug")
	menuBar:Check(ID_CLEAROUTPUT, true)
	frame:Connect(ID_COMPILE, wx.wxEVT_COMMAND_MENU_SELECTED,
        function (event)
            local editor = GetEditor()
            CompileProgram(editor)
        end)
	frame:Connect(ID_COMPILE, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)
	ID_TIMERBEATREQUEST = 2
	ID_TIMERIDLE = 1
	
	--local timeridle=wx.wxTimer(frame,ID_TIMERIDLE)
	--timeridle:Start(300)
	
	timer = wx.wxTimer(frame,ID_TIMERBEATREQUEST)
	frame:Connect(wx.wxEVT_TIMER,
			function (event)
				local id=event:GetId()
				if id==ID_TIMERBEATREQUEST then
					if script_lane then
						scriptlinda:send("beatRequest",1)
						timer:Start(300,wx.wxTIMER_ONE_SHOT)
					end
				else
					--wx.wxWakeUpIdle()
				end
			end)
	--timer:Start(300,wx.wxTIMER_ONE_SHOT):Start(300)
	frame:Connect(ID_RUN, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				event:Enable((editor ~= nil) and (not script_lane))
			end)
			--[[
	frame:Connect(ID_RUN2, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				event:Enable((editor ~= nil) and (not script_lane))
			end)
			--]]
	frame:Connect(ID_RUN3, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				event:Enable((editor ~= nil) and (not script_lane))
			end)
	frame:Connect(ID_CANCELRUN, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				event:Enable((editor ~= nil) and (script_lane~=nil))
			end)
	frame:Connect(ID_KILLRUN, wx.wxEVT_UPDATE_UI,
			function (event)
				local editor = GetEditor()
				event:Enable((editor ~= nil) and (script_lane~=nil))
			end)
	
	
	frame:Connect(ID_CANCELRUN,  wx.wxEVT_COMMAND_MENU_SELECTED,
			function(event) 
				--local cancelled=script_lane:cancel(0.1)
				--print("cancelled",cancelled);
				--print("script_lane.status",script_lane.status)
				scriptlinda:send("script_exit",1)
			end)
	frame:Connect(ID_KILLRUN,  wx.wxEVT_COMMAND_MENU_SELECTED,
			function(event)
				if script_lane then
					local cancelled=script_lane:cancel(0.1)
					if cancelled then
						idlelinda:set("prout",{"CANCEL!"})
					else
						print("trying to kill")
						cancelled=script_lane:cancel(0.1,true)
						idlelinda:set("prout",{"ABORT!"})
					end
					print("cancelled",cancelled);
					print("script_lane.status",script_lane.status)
					if cancelled then
						if script_lane.status=="cancelled" then
							script_lane=nil
						end
					end
				end
			end)
	
	frame:Connect(ID_RUN, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) return ScriptRun(1) end)
	--frame:Connect(ID_RUN2, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) return ScriptRun(2) end)
	frame:Connect(ID_RUN3, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) return ScriptRun(3) end)
	frame:Connect(ID_SETTINGS, wx.wxEVT_COMMAND_MENU_SELECTED,function(event) Settings:Create(frame).window:Show() end)
	frame:Connect(wx.wxEVT_IDLE,AppIDLE)
end
function InitSCMenu()
	local SCMenu = wx.wxMenu{
		{ ID_DUMPTREE,              "Dump SC Tree",               "Dumps SC Tree in SC console" },
		{ ID_DUMPOSC,              "Dump OSC",               "Dumps OSC" , wx.wxITEM_CHECK },
		{ ID_BOOTSC,              "Boot SC",               "Boots SC" },
		{ ID_QUITSC,              "Quit SC",               "Quits SC" },
		{ ID_AUTODETECTSC,              "Autodetect SC",               "Autodetect SC", wx.wxITEM_CHECK  },
        }
	menuBar:Append(SCMenu, "&Supercollider")
	frame:Connect(ID_DUMPTREE,  wx.wxEVT_COMMAND_MENU_SELECTED,
		function(event) 
			--linda:send("dumpTree",1)
			SCUDP:dumpTree(true)	
		end)
	frame:Connect(ID_DUMPOSC,  wx.wxEVT_COMMAND_MENU_SELECTED,
		function(event) 
			--linda:send("dumpTree",1)
			SCUDP:dumpOSC(event:IsChecked())	
		end)
	frame:Connect(ID_AUTODETECTSC,  wx.wxEVT_COMMAND_MENU_SELECTED,
		function(event) 
			if event:IsChecked() then
				SCUDP:sync()
				lanes.timer(idlelinda,"statusSC",1,0)
			else
				while idlelinda:receive(0,"statusSC") do end
				lanes.timer(idlelinda,"statusSC",0)
				idlelinda:receive(0,"statusSC")
			end
		end)
	frame:Connect(ID_BOOTSC,  wx.wxEVT_COMMAND_MENU_SELECTED,BootSC)
	frame:Connect(ID_QUITSC,  wx.wxEVT_COMMAND_MENU_SELECTED,function(event)
				SCUDP:quit()
				if SCProcess then
					SCProcess:cancel(0.3)
					print("SCProcess",SCProcess.status)
					SCProcess=nil
				end
			end)
	frame:Connect(ID_DUMPTREE, wx.wxEVT_UPDATE_UI,
			function (event)
				event:Enable(SCUDP.udp~=nil)
			end)
	frame:Connect(ID_DUMPOSC, wx.wxEVT_UPDATE_UI,
			function (event)
				event:Enable(SCUDP.udp~=nil)
			end)
	frame:Connect(ID_BOOTSC, wx.wxEVT_UPDATE_UI,
			function (event)
				event:Enable(SCProcess==nil)
			end)
	-- frame:Connect(ID_QUITSC, wx.wxEVT_UPDATE_UI,
			-- function (event)
				-- event:Enable(SCProcess~=nil)
			-- end)
end
function printStatus(msg)

	local str = msg[2].." UGens.".."\t"..msg[3].." Synths."
	str = str.."\n"..string.format("%0.2f",msg[6]).." AvgCPU".."\t"..string.format("%0.2f",msg[7]).." PeakCPU"
	str = str.."\n"..msg[4].." Groups.".."\t"..msg[5].." SynthDefs."
	--str=str.."\n"..msg[8].." S.Rate"
	--str=str.."\t"..msg[9].." Nom S.Rate"
	SCStatusText:SetLabel(str)
	local w,h =SCStatusText:GetTextExtent(str)
	--print(w," ",h)
	SCStatusText:SetSize(w+100,h*3)
	panelSizer:Layout()
	--panelSizer:SetSizeHints(panel)
	--manager:Update()
end
function AppIDLE(event)
			if exitingProgram then return end
			local requestmore=false
			---[[
			--if not timer:IsRunning() then print("timer stoped") end
			--if not checkstatus(script_lane) then print(script_lane.status)  end
			if checkend(script_lane) then script_lane=nil  end
			local key,val=idlelinda:receive(0,"Metro","DoDir","_FileSelector","TextToClipBoard","prout","proutSC","QueueAction","statusSC","/status.reply","OSCReceive" ) -- "beatResponse",
			if val then
				--print("idlelinda receive ",key,val)
				if key=="prout" then
					DisplayOutput(val[1],val[2])
				elseif key=="proutSC" then
					DisplayLog(val, ScLog)
				-- elseif key=="openEditor" then
					-- print("openEditor arrived")
					-- abriredit(val.source,val.line-1)
				elseif key=="Metro" then
					if not tempoCtrlChanging then
						tempoCtrl:ChangeValue(tostring(val.bpm))
					end
					playButton:SetValue(val.playing==1)
					timeStText:SetLabel(string.format("%02d:%02d",val.abstime/60,val.abstime%60))
				--elseif key=="beatResponse" then
					if not settingPos then
						local beat=math.floor(val.ppqPos)
						--print("BEAT:",beat)
						posSlider:SetValue(beat)
						local maxpos=posSlider:GetMax()
						if(maxpos <=beat) then
							posSlider:SetRange(0,beat*2)
						end
					else
						--print("settingPos")
					end
				elseif key=="TextToClipBoard" then
					putTextToClipBoard(val)
				elseif key=="statusSC" then 
					--thread_print("timerstatus")
					SCUDP:status()
				
				elseif key=="/status.reply" then 
					printStatus(val)
					lanes.timer(idlelinda,"statusSC",1,0)
				elseif key=="OSCReceive" then 
					OSCFunc.handleOSCReceive(val)
				elseif key=="QueueAction" then 
					doQueueAction(val)
					--SCUDP.udp:send(toOSC{"/b_getn",{0,0,512}})
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
				end
				requestmore=true
			end
			if requestmore then event:RequestMore() end
			event:Skip()
end
function SetAllEditorsReadOnly(enable)
    for id, document in pairs(openDocuments) do
        local editor = document.editor
        editor:SetReadOnly(enable)
    end
end


function ToggleDebugMarker(editor, line)
    local markers = editor:MarkerGet(line)
    if markers >= CURRENT_LINE_MARKER_VALUE then
        markers = markers - CURRENT_LINE_MARKER_VALUE
    end
    local id       = editor:GetId()
   
    if markers >= BREAKPOINT_MARKER_VALUE then
        editor:MarkerDelete(line, BREAKPOINT_MARKER)
       
    else
        editor:MarkerAdd(line, BREAKPOINT_MARKER)
       
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
function CompileProgram(editor)
    local editorText = editor:GetText()
    local id         = editor:GetId()
    local filePath   =  openDocuments[id].filePath
    local ret, errMsg, line_num = wxlua.CompileLuaScript(editorText, filePath)
    if menuBar:IsChecked(ID_CLEAROUTPUT) then
        ClearLog(errorLog)
    end

    if line_num > -1 then
        DisplayOutput("Compilation error on line number :"..tostring(line_num).."\n"..errMsg.."\n\n",true)
        --editor:GotoLine(line_num-1)
		abriredit(filePath,line_num)
    else
        DisplayOutput("Compilation successful!\n\n")
    end

    return line_num == -1 -- return true if it compiled ok
end



function SaveIfModified(editor)
    local id = editor:GetId()
    if openDocuments[id].isModified then
        local saved = false
        if not openDocuments[id].filePath then
            local ret = wx.wxMessageBox("You must save the program before running it.\nPress cancel to abort running.",
                                         "Save file?",  wx.wxOK + wx.wxCANCEL + wx.wxCENTRE, frame)
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


-----------------------------------------------------------
OSCFuncLinda = idlelinda
OSCFunc={filters={}}
function OSCFunc.newfilter(path,template,func,runonce)
	OSCFunc.filters[path] = OSCFunc.filters[path] or {} 
	OSCFunc.filters[path][#OSCFunc.filters[path]+1] ={template=template,func=func,runonce=runonce}
	udpsclinda:send("addFilter",{path,OSCFuncLinda})
end
function OSCFunc.clearfilters(path,template)
	print("OSCFunc.clearfilters ",path," ",template)
	udpsclinda:send("clearFilter",{path,OSCFuncLinda})
	if OSCFunc.filters[path] then
		for i,filter in pairs(OSCFunc.filters[path]) do
			if (template==nil) or (template==filter.template) then
				OSCFunc.filters[path][i]=nil
				print(" is done OSCFunc.clearfilters ",path," ",template)
			end
		end
	end
end
function OSCFunc.handleOSCReceive(msg)
	if msg[1]=="/fail" then
		print(tb2st(msg))
	end
	if OSCFunc.filters[msg[1]] then
		for i,filter in pairs(OSCFunc.filters[msg[1]]) do
			if (filter.template=="ALL") or (msg[2][1]==filter.template) then
				filter.func(msg)
				if filter.runonce then
					OSCFunc.filters[msg[1]][i]=nil
				end
			end
		end
	end
end
-----------------------------------------
--[[
ActionsFIFO=FIFO:new()
function QueueAction(interval,action)
	action.timestamp=lanes.now_secs() + interval
	ActionsFIFO:push(action)
	lanes.timer(idlelinda,"QueueAction",interval,0)
end
function doQueueAction()
	local action=ActionsFIFO:pop()
	action[1](action[2])
end
--]]
ActionsQueue={}
function QueueActionBAK(interval,action)
	print("QueueAction ",interval)
	action.timestamp=lanes.now_secs() + interval
	ActionsQueue[#ActionsQueue+1]=action
	table.sort(ActionsQueue,function(a,b) return a.timestamp > b.timestamp end)
	--local t= os.date( "*t", os.time()+60 )    -- now + 1min
	lanes.timer(idlelinda,"QueueAction",os.date("*t",ActionsQueue[#ActionsQueue].timestamp),0)
	--print(action.timestamp)
	prtable(os.date("*t",ActionsQueue[#ActionsQueue].timestamp))
end
function QueueAction(interval,action)
	action.timestamp=lanes.now_secs() + interval
	ActionsQueue[#ActionsQueue+1]=action
	table.sort(ActionsQueue,function(a,b) return a.timestamp > b.timestamp end)
	lanes.timer(idlelinda,"QueueAction",interval,0)
end
--local lastclocktimestamp=0
function doQueueAction(clocktimestamp)
	--print("doQueueAction ",clocktimestamp)
	--print(clocktimestamp - lastclocktimestamp,"\t",#ActionsQueue)
	--lastclocktimestamp = clocktimestamp
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
------------------------------------------
SCUDP={}
function ReceiveUDPLoop(host,port,host1,port1)
	
	local function prstak(stk)
		local str=""
		for i,lev in ipairs(stk) do
			str= str..i..": \n"
			for k,v in pairs(lev) do
				str=str.."\t["..k.."]:"..v.."\n"
			end
		end
		prerror(str)
	end
	
	local function finalizer_func(err,stk)
		print("UDPSC: ReceiveLoop finalizer:")
		if err and type(err)~="userdata" then 
			prerror( "UDPSC: after error: "..tostring(err) )
			prerror("UDPSC: finalizer stack table")
			prstak(stk)
		elseif type(err)=="userdata" then
			print( "UDPSC: after cancel " )
		else
			print( "UDPSC: after normal return" )
		end
		listenudp:close()
	end
	
	set_finalizer( finalizer_func ) 
	set_error_reporting("extended")
	set_debug_threadname("ReceiveUDPLoop")
	
	require("socket")
	require("osclua")
	toOSC=osclua.toOSC
	fromOSC=osclua.fromOSC
	
	local listenudp = assert(socket.udp(),"UDPSC: could not open listenudp")
	local success, msg = listenudp:setsockname(host, port) 
	if not success then error("UDPSC: "..tostring(msg))end
	
	local ok,err=listenudp:setpeername(host1, port1)
	if not ok then print("UDPSC: "..tostring(err)) return end
	
	local ip3, port3 = listenudp:getsockname()
	print("UDPSC: listenudp receives as ip:"..ip3.." port"..port3)
	listenudp:settimeout(1)
	local detected=false
	local Filters = {}
	while true do
		local dgram,status = listenudp:receive()
		-- if cancel_test() then
			-- io.stderr:write("required to cancel\n")
			-- break
		-- end
		local key,val = udpsclinda:receive(0,"clearFilter","addFilter")
		while val do
			if key == "addFilter" then
				--print("UDPSC: addFilter",val[1])
				Filters[val[1]] = Filters[val[1]] or {}
				Filters[val[1]][val[2]] = true
			elseif key == "clearFilter" then
				print("UDPSC: clearFilter",val)
				if Filters[val[1]]  then
					Filters[val[1]][val[2]] = nil
					if #Filters[val[1]] == 0 then
						Filters[val[1]] = nil
					end
				end
			end
			key,val = udpsclinda:receive(0,"addFilter","clearFilter")
		end
		if dgram then
			local msg = fromOSC(dgram)
			if msg[1]=="/metronom" then
				--prtable(msg)
				--setMetronom(msg[2][2],msg[2][3])
				scriptlinda:send("/metronom",msg[2])
			elseif msg[1]=="/vumeter" then
				--setVumeter(msg[2])
				scriptguilinda:send("/vumeter",msg[2])
			--elseif msg[1]=="/b_setn" then
				--setVumeter(msg[2])
				--scriptguilinda:send("/b_setn",msg[2])
			elseif msg[1]=="/status.reply" then
				idlelinda:send("/status.reply",msg[2])
				--print("UDPSC: "..prOSC(msg))
			--elseif msg[1]=="/n_go" or msg[1]=="/n_end" or msg[1]=="/n_on" or msg[1]=="/n_off" or msg[1]=="/n_move" or msg[1]=="/n_info" then
				--printN_Go(msg)
			elseif msg[1] == "/fail" then
				idlelinda:send("OSCReceive",msg)
			elseif Filters[msg[1]] then
				for onelinda,_ in pairs(Filters[msg[1]]) do
					onelinda:send("OSCReceive",msg)
				end
			--else
			--	print("UDPSC: "..prOSC(msg))
			end
		elseif status == "closed" then --closed ?
			print("UDPSC: error: "..status..". did you boot SC?")
			--try to detect
			while true do
				print("sending /status in loop")
				listenudp:send(toOSC({"/status",{1}}))
				local dgram,status = listenudp:receive()
				if dgram then -- detected
					local msg = fromOSC(dgram)
					print("UDPSC: "..prOSC(msg))
					listenudp:send(toOSC({"/notify",{1}}))
					lanes.timer(udpsclinda, "wait", 0) --stop
					udpsclinda:receive(0, "wait" ) --clear
					detected=true
					break
				elseif status=="closed" then -- closed, lets wait.
					lanes.timer( udpsclinda, "wait", 1, 0 )	--wait a second
					local key,val=udpsclinda:receive("wait") 
					print("UDPSC: ",key," ",val)
					detected=false
				else
					print("UDPSC: ",status) --may be timeout?
					lanes.timer( udpsclinda, "wait", 0) --stop
					udpsclinda:receive (0, "wait" ) --clear
				end	
			end
		elseif status == "timeout" then
			if cancel_test() then
				print("UDPSC:required to cancel\n")
				return true
			end
		else --timeout
			prerror("UDPSC: ",status)
		end
	end
end	
function CloseUdP()
	SCUDP.udp:close()
	--SCUDP.udpBlock:close()
	SCUDP.ReceiveUDPLoop_lane:cancel(1)
end	
function InitUdP()
	print("initudp SCUDP")
	SCUDP.host = "127.0.0.1"
	SCUDP.port = Settings.options.SC_UDP_PORT
	--local hostt = socket.dns.toip(host)
	assert(SCUDP.udp==nil,"udp not closed")
	SCUDP.udp = socket.udp()
	assert(SCUDP.udp,"could not create udp socket")
	SCUDP.udp:setpeername(SCUDP.host, SCUDP.port)
	local ip, port2 = SCUDP.udp:getsockname()
	--SCUDP.udp:settimeout(0)
	print("udp sends to ip:"..SCUDP.host.." port:"..SCUDP.port)
	print("udp reveives as ip:"..tostring(ip).." port:"..tostring(port2))
	--[[
	SCUDP.udpBlock = socket.udp()
	assert(SCUDP.udpBlock,"could not create udp socket")
	SCUDP.udpBlock:setpeername(SCUDP.host, SCUDP.port)
	local ipB, port2B = SCUDP.udpBlock:getsockname()
	print("udp reveives as ip:"..tostring(ipB).." port:"..tostring(port2B))
	--]]
	--[[
	assert(SCUDP.udp2==nil,"udp2 not closed")
	SCUDP.udp2 = assert(socket.udp(),"could not open udp2")
	--success, msg = udp2:setsockname("127.0.0.1", 57110) 
	local success, msg = SCUDP.udp2:setsockname(ip, port2) 
	if not success then
		error(msg)
	end
	--udp2:settimeout(0.1)
	local ip3, port3 = SCUDP.udp2:getsockname()
	print("udp2 receves as ip:"..ip3.." port"..port3)
	--]]
	local udp_lane_gen=lanes.gen("*",--"base,math,os,package,string,table",
		{
		cancelstep=10000,
		required={},
		globals={print=thread_print,
				prerror=thread_error_print,
				prOSC=prOSC,
				lanes=lanes,
				--linda=linda
				},
		priority=0},
		ReceiveUDPLoop)
	SCUDP.ReceiveUDPLoop_lane=udp_lane_gen(ip,port2,SCUDP.host,SCUDP.port)
	SCUDP.listen_ip=ip
	SCUDP.listen_port=port2
	--SCUDP.udp:send(toOSC({"/notify",{1}}))
end
function SCUDP:dumpTree(withvalues)
	withvalues=withvalues or true
	local p= withvalues and 1 or 0
	SCUDP.udp:send(toOSC({"/g_dumpTree",{0,p}}))
end
function SCUDP:quit()
	while idlelinda:receive(0,"statusSC") do end
	lanes.timer(idlelinda,"statusSC",0)
	idlelinda:receive(0,"statusSC")
	SCUDP.udp:send(toOSC({"/quit",{}}))
end
function SCUDP:dumpOSC(doit)
	--if doit==nil then doit=SCUDP.dumpOSCval end
	local val= doit and 1 or 0
	--SCUDP.dumpOSCval=doit
	SCUDP.udp:send(toOSC({"/dumpOSC",{val}}))
end
function SCUDP:status()
	--thread_print("sending /status")
	SCUDP.udp:send(toOSC({"/status",{1}}))
end
function SCUDP:sync(id)
	--SCUDP.udp:settimeout(5)
	-- SCUDP.udp:send(toOSC({"/notify",{1}}))
	-- local dgram,status  = SCUDP.udp:receive()
	-- if not dgram then
		-- print("Error on notify: ",status)
	-- end
	--thread_print("sending /sync")
	SCUDP.udp:send(toOSC({"/sync",{id or 1}}))
end

-------------------BootSC-----------------------
function SCProcess_Loop(cmd)

	local function prstak(stk)
		local str=""
		for i,lev in ipairs(stk) do
			str= str..i..": \n"
			for k,v in pairs(lev) do
				str=str.."\t["..k.."]:"..v.."\n"
			end
		end
		print(str)
	end
	
	local function finalizer_func(err,stk)
		print("SCProcess_Loop finalizer:")
		if err and type(err)~="userdata" then 
			print( "after error: "..tostring(err) )
			print("finalizer stack table")
			prstak(stk)
		elseif type(err)=="userdata" then
			print( "after cancel " )
		else
			print( "after normal return" )
		end
		exe:close()
		print( "finalizer ok" )
	end
	print("soy sc loop ....")
	set_finalizer( finalizer_func ) 
	set_error_reporting("extended")
	set_debug_threadname("SCProcess_Loop")
	
	exe,err=io.popen(cmd)
	if not exe then
		print("Could not popen. Error: ",err)
		return false
	else
		--print("Command run successfully... ready!")
		exe:setvbuf("no")
	end
	repeat
		--print(stdout:read("*all") or stderr:read("*all") or "nil")
		exe:flush()
		local line=exe:read("*l")
		if line then
			print(line)
		else
			return false
		end
		--exe:flush()
	until false
end		

function BootSC() 
	local path=wx.wxFileName.SplitPath(Settings.options.SCpath)
	wx.wxSetWorkingDirectory(path)
	wx.wxSetEnv("SC_SYSAPPSUP_PATH",path)
	--wx.wxSetEnv("SC_PLUGIN_PATH",path.."\\plugins") 
	if Settings.options.SC_SYNTHDEF_PATH~="default" then
		wx.wxSetEnv("SC_SYNTHDEF_PATH",Settings.options.SC_SYNTHDEF_PATH)
	end
	local plugpath=[["]]..path..[[\plugins"]]
	for i,v in ipairs(Settings.options.SC_PLUGIN_PATH) do
		if(v=="default") then
		else	
			plugpath=plugpath..[[;"]]..v..[["]]
		end
	end
	--local cmd="\"\""..Settings.options.SCpath.."\"".." -u "..Settings.options.SC_UDP_PORT.." -H ASIO ".."-U \""..path.."\\plugins\"\""
	local cmd=[[""]]..Settings.options.SCpath..[["]]..[[ -v 2 ]]..[[ -u ]]..Settings.options.SC_UDP_PORT..[[ -o 2 -i 2 ]]..[[ -H "]]..Settings.options.SC_AUDIO_DEVICE..[[" -U ]]..plugpath..[[ -m 65536]]..[[ 2>&1"]]
	--local cmd=[["]]..Settings.options.SCpath..[["]]	
	print(cmd)
	local function sc_print(...)
		local str=""
		for i=1, select('#', ...) do
			str = str .. tostring(select(i, ...))
		end
		str = str .. "\n"
		idlelinda:send("proutSC",str)
	end
	local process_gen=lanes.gen("*",--"base,math,os,package,string,table",
		{
		cancelstep=10000,
		required={},
		globals={
				print=sc_print,
				--prOSC=prOSC,
				lanes=lanes,
				--linda=linda
				},
		priority=0},
		SCProcess_Loop)

	SCProcess=process_gen(cmd)
	
	if not SCProcess then
		wx.wxMessageBox("Could not boot scsynth.")
		SCProcess=nil
	else
		ClearLog(ScLog)
		--DisplayLog("Process id is: "..tostring(pid).."\n", ScLog)
		--SCUDP:dumpOSC()
		SCUDP:sync()
		lanes.timer(idlelinda,"statusSC",1,0)
	end
	menuBar:Check(ID_DUMPOSC, false)
	
end
		
function QuitSC()
	if SCProcess then
		DisplayLog(string.format("Trying to kill process scproces \n"),ScLog)
		while idlelinda:receive(0,"statusSC") do end
		lanes.timer(idlelinda,"statusSC",0)
		idlelinda:receive(0,"statusSC")
		SCProcess:cancel(1)
	end
end

--[[
frame:Connect(wx.wxEVT_END_PROCESS,function(event)
			print("finish process" ,event:GetId())
			--print(event:GetPid())
			--print(event:GetExitCode())
			local proc=SCProcess
			while proc:IsInputAvailable() do
					local procout=proc:GetInputStream()
					local output=procout:Read(1024)
					DisplayLog(output, ScLog)
					if procout:Eof() then break end
			end
			
			if event:GetExitCode()~=0 then
				DisplayLog("xxxxxxxxxxxxxxxxxxxxxx\nErrors:", ScLog)
				while proc:IsErrorAvailable() do
					local procout=proc:GetErrorStream()
					local output=procout:Read(1024)
					DisplayLog(output, ScLog)
					if procout:Eof() then break end
				end
			end
			proc=nil
			SCProcess=nil
		end)
--]]
function thread_print(...)
	local str=""
	for i=1, select('#', ...) do
		str = str .. tostring(select(i, ...)) .. "\t"
	end
	str = str .. "\n"
	idlelinda:send("prout",{str,false})
end
function thread_error_print(...)
	local str=""
	for i=1, select('#', ...) do
		str = str .. tostring(select(i, ...)) .. "\t"
	end
	str = str .. "\n"
	idlelinda:send("prout",{str,true})
end
function ScriptRun(typerun)
	ClearAllCurrentLineMarkers()
	CallStack:Clear()
	local editor = GetEditor();
	-- test compile it before we run it, if successful then ask to save
	
	if not SaveIfModified(editor) then
		return
	end
	if not CompileProgram(editor) then
		return
	end
	local id = editor:GetId();
	local cmd=""
	if openDocuments[id].filePath then
		cmd = '"'..programName..'" '..openDocuments[id].filePath
		print(programName," ",editorApp:GetAppName())
	else
		return
	end
	----------------------------------------
	local function debuglocals()
		for level = 1, math.huge do
				local info = debug.getinfo(level, "Sln")
				if not info then break end
				if info.what == "C" then -- is a C function?
					print(level, "C function")
				else -- a Lua function
					print(string.format("%s[%s]:%d",tostring(info.name), info.short_src,info.currentline))
				end
				local a = 1
				while true do
					local name, value = debug.getlocal(level, a)
					if not name then break end
					print("local variable:",name, value)
					a = a + 1
				end
			end
			print("end debug print")
	end
	
	local function prstak(stk)
		local str=""
		for i,lev in ipairs(stk) do
			str= str..i..": \n"
			for k,v in pairs(lev) do
				str=str.."\t["..k.."]:"..v.."\n"
			end
		end
		prerror(str)
	end
	local function finalizer_func(err,stk)
		if err and type(err)~="userdata" then 
			prerror( "SCRIPT: finalizer after error: ")
			local onlyerrorst=err:match(":%d+:(.+)")
			prerror(tostring(err).."\n"..tostring(onlyerrorst) )
			--prerror("SCRIPT: finalizer stack table")
			--prstak(stk)
			--debuglocals()
			--print("end debug print")
		elseif type(err)=="userdata" then
			print( "SCRIPT: finalizer after cancel " )
		else
			print( "SCRIPT: finalizer after normal return" )
		end
		-- if _resetCb then
            -- _resetCb()
        -- end
		--linda:send("exit_midi_thread",1)
		print("SCRIPT: finalizer ok")
	end
	
	function ScriptExit()
		scriptlinda:send("script_exit",1)
		--manager:GetPane(panel):Hide()
	end
	function TextToClipBoard(text)
		idlelinda:send("TextToClipBoard",text)
	end
	local function CopyControl(con)
		local res = {}
		for k,v in pairs(con) do
			local typev = type(v)
			if (typev=="number") or (typev=="string") then
				res[k]=v
			elseif typev=="table" and (k=="pos" or k=="menu") then
				res[k]=v
			elseif typev=="function" then --and (k=="DrawCb") then
				res[k]=v
			else
				--print("No CopyControl",k,v)
			end
		end
		return res
	end
	local function guiAddWindow(window)
		scriptguilinda:send("guiModify",{"addWindow",CopyControl(window)})
	end
	-- tipex tag label name menu panel
	local function guiAddControl(control)
		--print("guiAddControl",control.tag)
		--scriptguilinda:send("guiModify",{"addControl",control})
		scriptguilinda:send("guiModify",{"addControl",CopyControl(control)})
		--local co={typex=control.typex,tag=control.tag,label=control.label,name=control.name,menu=control.menu,panel=control.panel,pos=control.pos,value=control.value,width=control.width,height=control.height,miny=control.miny,maxy=control.maxy}
		--scriptguilinda:send("guiModify",{"addControl",co})
	end
	function guiAddPanel(panel)
			--print("voy a linda send guiaddpanel",lastpanelID)
			--prtable(panel)
			--scriptguilinda:send("guiAdd",{"Panel",panel})
			scriptguilinda:send("guiModify",{"addPanel",panel})
	end
	local function guiDeleteControl(tag)
		--print("guiDeleteControl",tag)
		--scriptguilinda:send("guiDeleteControl",tag)
		scriptguilinda:send("guiModify",{"deleteControl",tag})
	end
	local function guiDeletePanel(tag)
		--print("guiDeletePanel",tag)
		--scriptguilinda:send("guiDeletePanel",tag)
		scriptguilinda:send("guiModify",{"deletePanel",tag})
	end
	local function guiEmptyPanel(tag)
		--print("guiDeletePanel",tag)
		--scriptguilinda:send("guiDeletePanel",tag)
		scriptguilinda:send("guiModify",{"emptyPanel",tag})
	end
	local function guiUpdate()
		print"guiUpdate"
		scriptguilinda:send("guiUpdate",1)
	end
	local function guiSetValue(tag,value)
		scriptguilinda:send("guiSetValue",{tag,value})
	end
	local function guiSetLabel(tag,value)
		scriptguilinda:send("guiSetLabel",{tag,value})
	end
	
	local function dodir(func,path,pattern,recur,level)
		local tmplinda=lanes.linda()
		idlelinda:send("DoDir",{path,pattern,recur,tmplinda})
		local key,val=tmplinda:receive("dodirResp")
		assert(key=="dodirResp")
		for k,v in ipairs(val) do
			func(v.file,v.lev,v.path)
		end
	end
	local function openFileSelector(path,pat,save)
		pat=pat or "*"
		if save==nil then save=false end
		local tmplinda=lanes.linda()
		idlelinda:send("_FileSelector",{path,pat,save,tmplinda})
		local key,val=tmplinda:receive("_FileSelectorResp")
		assert(key=="_FileSelectorResp")
		return val
	end
	local function guiGetValue(tag)
		assert(false)
	end
	--[[
	local function addOSCFilter(path,template,func,runonce)
		OSCFunc.newfilter(path,template,func,runonce)
	end
	local function clearOSCFilter(path,template)
		OSCFunc.clearfilters(path,template)
	end
	--]]
	--------------------------------------------------------
	local function main_lanes(script)
		set_finalizer( finalizer_func ) 
		set_error_reporting("extended")
		set_debug_threadname("script_thread")
		--require("pmidi")
		--clear linda-------------
		repeat
			local key,val= scriptlinda:receive(0,"script_exit","/metronom","metronomLanes","beat","tempo","play","beatRequest","_valueChangedCb","_midiEventCb")
			--print("xxxxxxxxxxxxxxxxxxxxxxMain clear linda",key)
		until val==nil
		--------------
		--midilane=pmidi.gen(_run_options.midiin,_run_options.midiout,lanes,linda,{print=thread_print,prtable=prtable})
		
		require("sc.init")
		if typerun==1 then
			theMetro.playNotifyCb[#theMetro.playNotifyCb+1] = function(met) 
				idlelinda:send("Metro",met) 
				end
		end
		--dofile(script)
		local fs,err = loadfile(script)
		if fs then 
			fs() 
		else 
			print("loadfile error:",err)
			--error("loadfile error:"..tostring(err)) 
		end
		_initCb()

		while true do

				--local dgram,status = udp2:receive()
				--from the gui (editor and scriptgui)
				local key,val= scriptlinda:receive("script_exit","tempo","play","/metronom","metronomLanes","beat","beatRequest","_valueChangedCb","_midiEventCb","OSCReceive")
				if val then
					--print("xxxxxxxxxxxxrequired linda: ",key," : ",val)
					if key=="beat" then
						theMetro:play(nil,val)
					elseif key=="tempo" then
						theMetro:play(val)
					elseif key=="/metronom" then
						setMetronom(val[2],val[3])
					elseif key=="metronomLanes" then
						--print("metronomLanes")
						setMetronomLanes(val)
					--elseif key=="/vumeter" then
						--setVumeter(val)
					elseif key=="script_exit" then
						print("SCRIPT: script_exit arrived")
						break
					elseif key=="beatRequest" then
						--linda:send("beatResponse",theMetro.actualbeat)
						idlelinda:send("Metro",theMetro)
						--print("beatRequest")
					elseif key=="_valueChangedCb" then
						--print("_valueChangedCbzzz")
						_valueChangedCb(val[1],val[2],val[3])
					elseif key=="_midiEventCb" then
						_midiEventCb(val)
					elseif key=="play" then
						if val==1 then
							theMetro:start()
						else
							theMetro:stop()
						end
					elseif key=="OSCReceive" then 
						OSCFunc.handleOSCReceive(val)
					end
				end
				if cancel_test() then
					io.stderr:write("required to cancel\n")
					break
				end
		end
		print("SCRIPT: to reset\n")
		if _resetCb then
			_resetCb()
		end
		return true
	end
	local function main_lanes_plain(script)
		set_finalizer(function (err,stk)
		if err and type(err)~="userdata" then 
			prerror( "SCRIPT: plain script finalizer after error: ")
			local onlyerrorst=err:match(":%d+:(.+)")
			prerror(tostring(err).."\n"..tostring(onlyerrorst) )
		elseif type(err)=="userdata" then
			print( "SCRIPT: plain script finalizer after cancel " )
		else
			print( "SCRIPT: plain script finalizer after normal return" )
			print("SCRIPT: finalizer ok")
		end
	end ) 
		set_error_reporting("extended")
		set_debug_threadname("script_thread")
		
		dofile(script)
		
		return true
	end
	--CloseScriptGUI()
	ClearScriptGUI()
	--CreateScriptGUI()
	
	local runmain=nil
	if typerun==1 then
		timer:Start(300,wx.wxTIMER_ONE_SHOT)
		--manager:GetPane(panel):Show()
		runmain=main_lanes
	elseif typerun==2 then
		--manager:GetPane(panel):Hide()
		runmain=main_lanes
	elseif typerun==3 then
		--manager:GetPane(panel):Hide()
		runmain=main_lanes_plain
	end
	--DisplayOutput(ToStr(package))
	local script_lane_gen=lanes.gen("*",--"base,math,os,package,string,table",
		{
		cancelstep=false,
		required={},
		globals={print=thread_print,
				prerror=thread_error_print,
				guiAddWindow=guiAddWindow,
				guiAddControl=guiAddControl,
				guiDeleteControl=guiDeleteControl,
				guiDeletePanel=guiDeletePanel,
				guiEmptyPanel=guiEmptyPanel,
				guiSetValue=guiSetValue,
				guiSetLabel=guiSetLabel,
				guiAddPanel=guiAddPanel,
				guiUpdate=guiUpdate,
				ScriptExit=ScriptExit,
				dodir=dodir,
				openFileSelector=openFileSelector,
				TextToClipBoard=TextToClipBoard,
				lanes=lanes,
				scriptlinda=scriptlinda,
				midilinda=midilinda,
				_sendMidi=pmidi._sendMidi,
				_run_options=Settings.options,
				_presetsDir=_presetsDir,
				prtable=prtable,
				--addOSCFilter = addOSCFilter,
				--clearOSCFilter = clearOSCFilter
				OSCFunc = OSCFunc,
				OSCFuncLinda = scriptlinda
				--pmidi=pmidi
				},
		priority=1},
		runmain)
		
	-- if midilane then
		-- midilane:cancel(0.01)
	-- end
	--midilane=midi_lane_gen(Settings.options.midiin,Settings.options.midiout)
	--midilane=pmidi.gen(Settings.options.midiin,Settings.options.midiout,lanes,linda,{print=thread_print,prtable=prtable})
	script_lane=script_lane_gen(openDocuments[id].filePath)

end


function putTextToClipBoard(text)
	clipboard=wx.wxClipboard.Get()

	if (clipboard:Open()) then
		clipboard:SetData( wx.wxTextDataObject(text) );
		clipboard:Close();
	end
end
--------------


-- ---------------------------------------------------------------------------
-- Create the Help menu and attach the callback functions
function InitHelpMenu()
	helpMenu = wx.wxMenu{
        { ID_ABOUT,      "&About\tF1",       "About Lua2SC IDE" }}
	menuBar:Append(helpMenu, "&Help")
	frame:Connect(ID_ABOUT, wx.wxEVT_COMMAND_MENU_SELECTED, DisplayAbout)
end
function DisplayAbout(event)
    local page = [[
        <html>
        <body bgcolor = "#FFFFFF">
        <table cellspacing = 4 cellpadding = 4 width = "100%">
          <tr>
            <td bgcolor = "#202020">
            <center>
                <font size = +2 color = "#FFFFFF"><br><b>]]..
                    "Lua2SC"..[[</b></font><br>
                <font size = +1 color = "#FFFFFF">built with</font><br>
                <font size = +2 color = "#FFFFFF"><b>]]..
                    wxlua.wxLUA_VERSION_STRING.." "..wx.wxVERSION_STRING..[[</b></font>
            </center>
            </td>
          </tr>
          <tr>
            <td bgcolor = "#DCDCDC">
            <b>Copyright (C) 2012 Victor Bombi</b>
            <p>
            <font size=-1>
              <table cellpadding = 0 cellspacing = 0 width = "100%">
                <tr>
                  <td width = "65%">
                    Victor Bombi (sonoro@telefonica.net)<br>
                    <p>
                  </td>
                  <td valign = top>
                    <img src = "memory:wxLua">
                  </td>
                </tr>
              </table>
            <font size = 1>
                Licenced under ??? Licence.
            </font>
            </font>
            </td>
          </tr>
        </table>
        </body>
        </html>
    ]]

    local dlg = wx.wxDialog(frame, wx.wxID_ANY, "About Lua2SC IDE")

    local html = wx.wxLuaHtmlWindow(dlg, wx.wxID_ANY,
                                    wx.wxDefaultPosition, wx.wxSize(360, 150),
                                    wx.wxHW_SCROLLBAR_NEVER)
    local line = wx.wxStaticLine(dlg, wx.wxID_ANY)
    local button = wx.wxButton(dlg, wx.wxID_OK, "OK")

    button:SetDefault()

    html:SetBorders(0)
    html:SetPage(page)
    html:SetSize(html:GetInternalRepresentation():GetWidth(),
                 html:GetInternalRepresentation():GetHeight())

    local topsizer = wx.wxBoxSizer(wx.wxVERTICAL)
    topsizer:Add(html, 1, wx.wxALL, 10)
    topsizer:Add(line, 0, wx.wxEXPAND + wx.wxLEFT + wx.wxRIGHT, 10)
    topsizer:Add(button, 0, wx.wxALL + wx.wxALIGN_RIGHT, 10)

    dlg:SetAutoLayout(true)
    dlg:SetSizer(topsizer)
    topsizer:Fit(dlg)

    dlg:ShowModal()
    dlg:Destroy()
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
	while script_lane do
		local cancelled,err=script_lane:cancel(0.1)
		print("script cancel on close",cancelled,err)
		if cancelled then
			script_lane = nil
		end
	end
    --ConfigSaveFramePosition(frame, "MainFrame")
	ConfigSaveOpenDocuments(config)
	file_history:Save(config)
	ConfigSavePerpectives()
	CloseScriptGUI()
	manager:UnInit();
	config:delete() -- always delete the config
	config=nil
    event:Skip()
	SCUDP.quit()
	QuitSC()
	CloseUdP()
	midilane:cancel(0.1)
	--pmidi.exit_midi_thread()
	--CloseUdP()
	print("Main frame Closed")
end

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
	SCUDP.udp:send(toOSC(msg))
	
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
	--[[
	local msg
	for i=0,3 do
		OSCFunc.newfilter("/b_info",i,function(msg)
				DisplayOutput("/b_info: ".."buffer:"..msg[2][1].." frames:"..msg[2][2].." channels:"..msg[2][3].." samprate:"..msg[2][4].."\n")
			end,true)
		SCUDP.udp:send(toOSC{"/b_query",{{"int32",i}}})
	end
	--]]
	--[[
	msg ={"/b_alloc",{ 0, co.bins, 1}}
	SCUDP.udpBlock:send(toOSC(msg))
	local dgram2 = assert(SCUDP.udpBlock:receive(),"Not receiving from SCSYNTH\n")
	DisplayOutput(tb2st(fromOSC(dgram2)).."\n")
	msg ={"/b_alloc",{ 1, fftsize, 1}}
	SCUDP.udpBlock:send(toOSC(msg))
	dgram2 = assert(SCUDP.udpBlock:receive(),"Not receiving from SCSYNTH\n")
	DisplayOutput(tb2st(fromOSC(dgram2)).."\n")
	--]]
	
	
	--msg ={"/s_new", {co.scope, co.node, 1, 0, "in",{"int32",co.busin}, "busin",{"int32",co.busin},"rate",{"int32",co.rate},"phase",{"float",co.phase}, "fftbufnum", {"int32",1}, "scopebufnum", {"int32",0},"fftsize", {"int32",fftsize}}}
	local msg ={"/s_new", {co.scope, co.node, 1, 0, "in",{"int32",co.busin}, "busin",{"int32",co.busin},"rate",{"int32",co.rate},"phase",{"float",co.phase}, "scopebufnum", {"int32",co.scopebufnum},"fftsize", {"int32",fftsize}}}
	--SCUDP.udp:send(toOSC(msg))
	
	msg ={"/b_alloc",{ co.scopebufnum, co.bins, 1,{"blob",toOSC(msg)}}}
	SCUDP.udp:send(toOSC(msg))
	
	--[[
	for i=0,3 do
		OSCFunc.newfilter("/b_info",i,function(msg)
				DisplayOutput("/b_info: ".."buffer:"..msg[2][1].." frames:"..msg[2][2].." channels:"..msg[2][3].." samprate:"..msg[2][4].."\n")
			end,true)
		SCUDP.udp:send(toOSC{"/b_query",{{"int32",i}}})
	end
	--]]
	--[[
	for i=0,3 do
		SCUDP.udpBlock:send(toOSC{"/b_query",{{"int32",i}}})
		local dgram2 = assert(SCUDP.udpBlock:receive(),"Not receiving from SCSYNTH\n")
		msg=fromOSC(dgram2)
		assert(msg[1]=="/b_info")
		DisplayOutput("/b_info: ".."buffer:"..msg[2][1].." frames:"..msg[2][2].." channels:"..msg[2][3].." samprate:"..msg[2][4].."\n")
	end
	--]]
	
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
				QueueAction(0.1,{function() SCUDP.udp:send(toOSC{"/b_getn",{co.scopebufnum,0,co.bins}}) end})
			end
		end)
	QueueAction(0.1,{function() SCUDP.udp:send(toOSC{"/b_getn",{co.scopebufnum,0,co.bins}}) end})
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
	require"luagl"
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
	SCUDP.udp:send(toOSC(msg))
		
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
				QueueAction(0.1,{function() SCUDP.udp:send(toOSC{"/b_getn",{co.scopebufnum,0,co.bins}}) end})
			end
		end)
	QueueAction(0.1,{function() SCUDP.udp:send(toOSC{"/b_getn",{co.scopebufnum,0,co.bins}}) end})
	FreqScopeClass.notclosed=true
	return FreqScopeClass 
end
--------------------------------ScriptGUI
theScriptGUI={}
function CloseScriptGUI()
	print("CloseScriptGUI ",ScriptGUI)
    if theScriptGUI.window then
		ScriptGUI=theScriptGUI.window
		--ConfigSaveFramePosition(ScriptGUI, "ScriptGUI")
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
		local key,val=scriptguilinda:receive(0,"guiAdd","guiSetValue","guiGetValue","guiSetLabel","guiDeleteControl","guiDeletePanel" ,"/vumeter")
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
			control.control=wxKnob(ScriptGUI,tostring(co.name), tostring(co.label),co.tag) -- wx.wxST_NO_AUTORESIZE +
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
		local id=event:GetId()
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
		--print("_valueChangedCb",id,val,str)
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
		ScriptWindows[win.tag] = wx.wxFrame(frame,wx.wxID_ANY,"window script",wx.wxDefaultPosition,wx.wxDefaultSize,wx.wxMINIMIZE_BOX + wx.wxMAXIMIZE_BOX + wx.wxRESIZE_BORDER + wx.wxSYSTEM_MENU + wx.wxCAPTION + wx.wxCLIP_CHILDREN + wx.wxFRAME_FLOAT_ON_PARENT)
		ConnectComands(ScriptWindows[win.tag])
		ScriptWindows[win.tag]:Show()
		--print("window added",ScriptWindows[win.tag])
	end
	--{type,parent,cols,rows,tag(auto),name}
	function AddPanel(pan)
		local ScriptGUI = pan.window or ScriptGUI
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
	
	--ScriptGUI:CentreOnParent()
    --ConfigRestoreFramePosition(ScriptGUI, "ScriptGUI")
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
		local key,val=scriptguilinda:receive(0,"guiModify","guiUpdate","guiAdd","guiSetValue","guiGetValue","guiSetLabel","guiDeleteControl","guiDeletePanel","/vumeter" )
		print("xxxxxxxxxxxxxxxxxxxxxxScriptGUI clear linda ",key)
	until val==nil

	ScriptGUI:Connect(wx.wxEVT_IDLE,
        function(event)
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
				event:RequestMore()
			end
			event:Skip()
		end)


    ScriptGUI:Connect( wx.wxEVT_CLOSE_WINDOW,
            function (event)
				print("ScriptGUI wxEVT_CLOSE_WINDOW")
                CloseScriptGUI()
                event:Skip()
            end)
	ConnectComands()
end
-------------------------------settings panel
Settings={
	options={
		midiin={},
		midiout={},
		SCpath="",
		SC_SYNTHDEF_PATH="default",
		SC_PLUGIN_PATH={"default"},
		SC_UDP_PORT=57110,
		SC_AUDIO_DEVICE=""
	},
	ID_CANCEL_BUTTON=NewID(),
	ID_SAVE_BUTTON=NewID(),
	ID_RESET_MIDI_BUTTON=NewID(),
	ID_SC_BUTTON=NewID(),
	ID_SYNTHPATH_BUTTON=NewID(),
	ID_PLUGINS_BUTTON=NewID(),
	ID_PLUGINS_DELETE_BUTTON=NewID()
}
function Settings:ConfigSave(config)
	local path = config:GetPath()
	config:DeleteGroup("/settings")
    config:SetPath("/settings")
	local serialized = serializeTable("Settings.options", self.options) 
	local goodwrite=false
	goodwrite=config:Write("options",serialized)
	if not goodwrite then wx.wxMessageBox("No escribo opciones "..tostring(i)) end	
	config:Flush()
	config:SetPath(path)
end
function Settings:ConfigRestore(config)
	local path = config:GetPath()
    config:SetPath("/settings")
	local more,str
	if config:HasEntry("options") then
		more,str=config:Read("options")
		if str and string.len(str)>1 then
			assert(loadstring(str))()
		end
	end
	config:SetPath(path)
	--erase inexistent devices
	self.MIDIdev=pmidi.GetMidiDevices()
	local midiout={}
	for i,v in ipairs(self.MIDIdev.out) do
		midiout[v.name]=self.options.midiout[v.name]
	end
	self.options.midiout=midiout
	local midiin={}
	for i,v in ipairs(self.MIDIdev.inp) do
		midiin[v.name]=self.options.midiin[v.name]
	end
	self.options.midiin=midiin
end
function Settings:FindSC(event)
	local exepath
    local fileDialog = wx.wxFileDialog(frame, "Find scsynth.exe",
                                       "",
									   self.options.SCpath or "",
                                       "Exe files (*.exe)|*.exe|All files (*)|*",
                                       wx.wxFD_OPEN + wx.wxFD_FILE_MUST_EXIST)
    if fileDialog:ShowModal() == wx.wxID_OK then
       exepath=fileDialog:GetPath()
	end
	fileDialog:Destroy()
	return exepath
end
function Settings:FindSynthPath(event)
	local path
    local fileDialog = wx.wxDirDialog(frame, "Find synthdefs directory",
                                       Settings.options.SC_SYNTHDEF_PATH,
                                        wx.wxDD_DIR_MUST_EXIST)
    if fileDialog:ShowModal() == wx.wxID_OK then
       path=fileDialog:GetPath()
	end
	fileDialog:Destroy()
	return path
end
function Settings:Create(parent)
	
	self:ConfigRestore(config)
	self.window=wx.wxFrame(parent,wx.wxID_ANY,"Settings",wx.wxDefaultPosition,wx.wxDefaultSize,wx.wxDEFAULT_FRAME_STYLE + wx.wxFRAME_FLOAT_ON_PARENT)
	local this=self.window
	
	
	local grid_sizer = wx.wxGridBagSizer();
	grid_sizer:SetHGap(2)
	grid_sizer:SetVGap(2)
	
	local row=0
	grid_sizer:Add(wx.wxStaticText(this, wx.wxID_ANY,"Sc Synth udp port:"),wx.wxGBPosition(row,0))
	local udpTC = wx.wxTextCtrl(this, wx.wxID_ANY,tostring(self.options.SC_UDP_PORT))
	grid_sizer:Add(udpTC,wx.wxGBPosition(row,1))
	row = row + 1
	
	grid_sizer:Add(wx.wxStaticText(this, wx.wxID_ANY,"Audio Device:"),wx.wxGBPosition(row,0))
	local Au_Dev_TC = wx.wxTextCtrl(this, wx.wxID_ANY,tostring(self.options.SC_AUDIO_DEVICE),wx.wxDefaultPosition)
	grid_sizer:Add(Au_Dev_TC,wx.wxGBPosition(row,1), wx.wxGBSpan(1,1), wx.wxEXPAND)
	row = row + 1
	
	grid_sizer:Add(wx.wxStaticText(this, wx.wxID_ANY,"Sc synthdefs path:"),wx.wxGBPosition(row,0))
	local synthTC = wx.wxTextCtrl(this, wx.wxID_ANY,self.options.SC_SYNTHDEF_PATH or "")
	grid_sizer:Add(synthTC, wx.wxGBPosition(row,1), wx.wxGBSpan(1,1), wx.wxEXPAND)
	grid_sizer:Add(wx.wxButton( this, self.ID_SYNTHPATH_BUTTON, "Browse"), wx.wxGBPosition(row,2))
	row = row + 1
	
	grid_sizer:Add(wx.wxStaticText(this, wx.wxID_ANY,"Sc plugins path:"),wx.wxGBPosition(row,0))
	local pluginTC=wx.wxListBox(this, wx.wxID_ANY)--,wx.wxDefaultPosition,wx.wxDefaultSize,wx.wxNULL,wx.wxLB_HSCROLL)--,self.options.SC_PLUGIN_PATH or "")wxLB_HSCROLL 
	for i,v in ipairs(self.options.SC_PLUGIN_PATH) do
		pluginTC:Append(v)
	end
	grid_sizer:Add(pluginTC,wx.wxGBPosition(row,1),wx.wxGBSpan(1,1),wx.wxEXPAND)
	local botplug=wx.wxButton( this, self.ID_PLUGINS_BUTTON, "Browse")
	local delplug=wx.wxButton( this, self.ID_PLUGINS_DELETE_BUTTON, "Delete")
	local botplugsizer=wx.wxBoxSizer(wx.wxVERTICAL)
	botplugsizer:Add(botplug)
	botplugsizer:Add(delplug)
	grid_sizer:Add(botplugsizer,wx.wxGBPosition(row,2))
	
	row = row + 1
	grid_sizer:Add(wx.wxStaticText(this, wx.wxID_ANY,"ScSynth.exe path:"),wx.wxGBPosition(row,0))
	local scTC=wx.wxTextCtrl(this, wx.wxID_ANY,self.options.SCpath or "")
	grid_sizer:Add(scTC,wx.wxGBPosition(row,1),wx.wxGBSpan(1,1),wx.wxEXPAND)
	grid_sizer:Add(wx.wxButton( this, self.ID_SC_BUTTON, "Browse"),wx.wxGBPosition(row,2))
	
	row = row + 1
	self.MIDIdev=pmidi.GetMidiDevices()
	prtable(self.MIDIdev)
	
	local devnamesout=wx.wxArrayString()
	for i,v in ipairs(self.MIDIdev.out) do
		devnamesout:Add(v.name)
	end
	grid_sizer:Add(wx.wxStaticText(this, wx.wxID_ANY,"midi out:"),wx.wxGBPosition(row,0))
	local midioutCHLB=wx.wxCheckListBox(this, wx.wxID_ANY,wx.wxDefaultPosition,wx.wxDefaultSize,devnamesout)
	grid_sizer:Add(midioutCHLB,wx.wxGBPosition(row,1),wx.wxGBSpan(1,1),wx.wxEXPAND)
	for i,v in ipairs(self.MIDIdev.out) do
		midioutCHLB:Check(i-1,self.options.midiout[v.name] or false)
	end
	
	row = row + 1
	local devnamesin=wx.wxArrayString()
	for i,v in ipairs(self.MIDIdev.inp) do
		devnamesin:Add(v.name)
	end
	grid_sizer:Add(wx.wxStaticText(this, wx.wxID_ANY,"midi in:"),wx.wxGBPosition(row,0))
	local midiinCHLB=wx.wxCheckListBox(this, wx.wxID_ANY,wx.wxDefaultPosition,wx.wxDefaultSize,devnamesin)
	grid_sizer:Add(midiinCHLB,wx.wxGBPosition(row,1),wx.wxGBSpan(1,1),wx.wxEXPAND)
	for i,v in ipairs(self.MIDIdev.inp) do
		midiinCHLB:Check(i-1,self.options.midiin[v.name] or false)
	end
	
	local cont_sizer = wx.wxBoxSizer(wx.wxVERTICAL);
    cont_sizer:Add(grid_sizer, 0, wx.wxEXPAND + wx.wxALL, 5);
	local but_sizer = wx.wxBoxSizer(wx.wxHORIZONTAL);
    cont_sizer:Add(but_sizer, 0,  wx.wxALL, 5);
	local saveButton = wx.wxButton( this, self.ID_SAVE_BUTTON, "Save")
	local cancelButton = wx.wxButton( this, self.ID_CANCEL_BUTTON, "Cancel")
	local resetmidiButton = wx.wxButton( this, self.ID_RESET_MIDI_BUTTON, "Reset MIDI")
	but_sizer:Add( saveButton, 0, wx.wxALL, 3 )
	but_sizer:Add( cancelButton, 0,wx.wxALL, 3 )
	but_sizer:Add( resetmidiButton, 0,wx.wxALL, 3 )
    this:SetSizer(cont_sizer);
    cont_sizer:SetSizeHints(this);
	this:Connect(self.ID_SC_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
		function(event)
			local path=self:FindSC()
			if path then
				scTC:SetValue(path)
			end
		end)
	this:Connect(self.ID_SYNTHPATH_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
		function(event)
			local path=self:FindSynthPath()
			if path then
				if string.sub(path,-1)~="\\" then path=path.."\\" end 
				synthTC:SetValue(path)
			end
		end)
	this:Connect(self.ID_PLUGINS_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
		function(event)
			local path=self:FindSynthPath()
			if path then
				--if string.sub(path,-1)~="\\" then path=path.."\\" end 
				pluginTC:Append(path)
			end
		end)
	this:Connect(self.ID_PLUGINS_DELETE_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
		function(event)
			local sel=pluginTC:GetSelection()
			--print("delete ",sel," ",wxNOT_FOUND)
			if sel~=-1 then
				pluginTC:Delete(sel)
			end
		end)	
	this:Connect(self.ID_CANCEL_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
		function(event) this:Close() end)
	local function GetMidiOptions(self)
		self.options.midiout={}
		for i=1,midioutCHLB:GetCount() do
			if midioutCHLB:IsChecked(i-1) then
				self.MIDIdev.out[i].check=true
				self.options.midiout[self.MIDIdev.out[i].name]=true
			else
				self.MIDIdev.out[i].check=false
				self.options.midiout[self.MIDIdev.out[i].name]=false
			end
		end
		self.options.midiin={}
		for i=1,midiinCHLB:GetCount() do
			if midiinCHLB:IsChecked(i-1) then
				self.MIDIdev.inp[i].check=true
				self.options.midiin[self.MIDIdev.inp[i].name]=true
			else
				self.MIDIdev.inp[i].check=false
				self.options.midiin[self.MIDIdev.inp[i].name]=false
			end
		end
	end
	
	this:Connect(self.ID_RESET_MIDI_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
		function(event)
			GetMidiOptions(self)
			--linda:send("exit_midi_thread",1)
			--if midilane.status == "running" or midilane.status == "waiting" then
				--pmidi.exit_midi_thread()	
			--end
			thread_print("cancel midilane ",midilane:cancel(0.2))
			midilane=pmidi.gen(Settings.options.midiin,Settings.options.midiout,lanes,scriptlinda,midilinda,
			{print=thread_print,
			prerror=thread_error_print,
			prtable=prtable})
		end)
	this:Connect(self.ID_SAVE_BUTTON, wx.wxEVT_COMMAND_BUTTON_CLICKED,
		function(event)
			GetMidiOptions(self)
			self.options.SCpath=scTC:GetValue()
			self.options.SC_SYNTHDEF_PATH=synthTC:GetValue()
			
			self.options.SC_PLUGIN_PATH={}
			for i=0,pluginTC:GetCount()-1 do
					self.options.SC_PLUGIN_PATH[i+1]=pluginTC:GetString(i)
			end
			self.options.SC_UDP_PORT=udpTC:GetValue()
			self.options.SC_AUDIO_DEVICE=Au_Dev_TC:GetValue()
			--prtable(self.MIDIdev)
			self:ConfigSave(config)
			this:Close() 
		end)
	return self;
end
-----------
LUA_xpm = {
"32 32 189 2",
"   c None",
"(. c #7E7EBD",
"J. c #2B2B93",
"<. c #6F6FB6",
"#  c #000009",
"7  c #00000A",
"@  c #00000B",
"o  c #00000C",
"]  c #00000D",
"<  c #00000E",
"O  c #00000F",
"OX c #000010",
"2. c #0D0D83",
"/  c #0D0D84",
"X  c #000011",
"p  c #000012",
"6  c #000013",
".  c #000014",
">  c #000015",
"q  c #000016",
"&  c #000017",
"l. c #8686C0",
"5  c #000018",
"k  c #000019",
"E  c #CACAE3",
"%  c #00001A",
"y  c #00001B",
"$  c #00001C",
".X c #00001D",
"w  c #00001E",
"p. c #BBBBDB",
",  c #00001F",
"*  c #000020",
"S. c #000021",
"+  c #000022",
"I. c #242490",
"a  c #000023",
"N. c #ACACD3",
"h  c #000024",
"_  c #ACACD4",
"J  c #000025",
"9. c #000026",
"m  c #000027",
"e  c #000028",
"t  c #000029",
"=  c #00002B",
"r  c #00002C",
"V  c #00002D",
"n  c #060680",
"`  c #060681",
"). c #3B3B9B",
"1  c #000035",
"o. c #2C2C93",
"=. c #7070B7",
"[. c #1D1D8A",
"j. c #1D1D8C",
"q. c #A5A5D0",
"|  c #E9E9F3",
"O. c #0E0E84",
"0  c #000045",
"b. c #9696C8",
"h. c #5252A7",
":  c #000047",
"M  c #000048",
"x  c #000049",
"A. c #00004A",
"XX c #00004B",
"f. c #4343A0",
"'  c #00004D",
"M. c #00004E",
"g  c #000050",
"s  c #000051",
"U. c #BCBCDC",
"-  c #000053",
"l  c #000054",
"C. c #252591",
"i  c #000058",
";  c #00005C",
"A  c #5A5AAB",
"g. c #9E9ECD",
"8. c #070780",
"Z  c #070781",
" . c #4B4BA4",
"B  c #000063",
")  c #D3D3E8",
"4  c #000066",
"8  c #000067",
" X c #000068",
"|. c #000069",
"H. c #8080BE",
"^  c #C4C4E0",
"d  c #00006A",
"{. c #00006B",
"c  c #00006C",
"^. c #2D2D94",
"K  c #00006D",
"w. c #2D2D95",
"j  c #00006F",
"N  c #000071",
"C  c #000072",
"z. c #000073",
"!. c #6262AF",
"u  c #000074",
"2  c #000075",
"z  c #000076",
"5. c #0F0F84",
".. c #000077",
"oX c #000078",
">. c #000079",
"f  c #00007A",
"3  c #00007B",
"9  c #00007C",
"i. c #7979BB",
";. c #171788",
"7. c #5B5BAB",
"t. c #080882",
"T  c #3D3D9C",
"1. c #2E2E94",
"'. c #7272B7",
"d. c #2E2E96",
"S  c #B6B6D9",
"F  c #A7A7D1",
"b  c #101085",
"Y. c #5454A8",
"}. c #01017C",
"L  c #01017D",
"y. c #8989C2",
"6. c #4545A1",
"m. c #7A7ABC",
"0. c #090982",
"*. c #9191C5",
"D. c #9191C6",
"]. c #8282BF",
"c. c #2F2F96",
"Z. c #7373B8",
"H  c #020271",
"k. c #111185",
"r. c #9999CA",
"-. c #02027D",
"`. c #8A8AC2",
"L. c #4646A1",
"X. c #373799",
"n. c #BFBFDE",
"(  c #19198A",
"W  c #A1A1CE",
"v  c #0A0A82",
",. c #9292C5",
"T. c #4E4EA5",
"G. c #8383BF",
"R. c #B8B8D9",
"+. c #7474B9",
"U  c #FCFCFC",
"P. c #A9A9D2",
"P  c #6565B1",
"3. c #121286",
"V. c #5656A9",
"Y  c #DEDEED",
"[  c #03037E",
"@. c #CFCFE5",
"{  c #7C7CBD",
"!  c #292992",
"}  c #F5F5F9",
"u. c #A2A2CE",
"K. c #A2A2CF",
"~  c #E6E6F1",
"a. c #4F4FA6",
"G  c #40409E",
"D  c #C8C8E2",
"B. c #313197",
"F. c #B9B9DA",
"s. c #AAAAD3",
"%. c #5757AA",
"Q  c #04047E",
"_. c #4848A2",
"Q. c #39399A",
"$. c #C1C1DF",
"4. c #2A2A92",
"~. c #5F5FAE",
"W. c #0C0C83",
"v. c #5050A6",
"/. c #8585BF",
"e. c #41419F",
":. c #23238E",
"x. c #ABABD3",
"I  c #EFEFF6",
"R  c #141488",
"E. c #9C9CCB",
"&. c #05057E",
"#. c #E0E0EE",
"                              .   X o                   O       ",
"                        + @ # $   % &   *           = - ; : &   ",
"                  > ,                   <   & &   1 2 3 3 3 4 5 ",
"              6 O                             < 7 8 3 3 3 3 9 0 ",
"              q           # w e r t y #         % u 3 3 3 3 3 i ",
"          w p         a s d 2 f 3 f 2 d g h     > j 3 3 3 3 3 g ",
"          O       k l 2 3 3 3 3 3 3 3 3 3 z l q   x 3 3 3 3 u h ",
"      > y       = c 3 3 3 3 3 3 3 3 3 9 v b n d m 7 M c N B V   ",
"      X       V C 3 3 3 3 3 3 3 3 3 Z A S D F G H J   O 5 o     ",
"    y O     k K 3 3 3 3 3 3 3 3 3 L P I U U U Y T d &       q   ",
"    6       l 3 3 3 3 3 3 3 3 3 3 R E U U U U U W Q g       a   ",
"          J z 3 3 3 3 3 3 3 3 3 3 ! ~ U U U U U ^ / 2 +         ",
"  w <     g 3 3 3 3 3 3 3 3 3 3 3 ( ) U U U U U _ ` 3 '     ] , ",
"        # d 3 3 3 3 3 3 3 3 3 3 3 [ { } U U U |  .9 3 8 @     @ ",
"@ &     % ..3 9 X.o.3 3 3 3 3 3 3 9 O.+.@.#.$.%.&.3 3 2 %     # ",
"# 5     m 3 3 9 *.=.3 3 3 3 3 3 3 3 3 -.;.:.b 9 3 3 3 >.h     $ ",
"        = 3 3 9 ,.<.3 3 3 -.1.2.3 3.4.9 5.6.7.T 8.3 3 3 9.      ",
". ,     9.3 3 9 ,.<.3 3 3 0.q.w.3 e.r.t.y.u.i.p.a.3 3 f a     k ",
"  @     y ..3 9 ,.<.3 3 3 0.s.d.3 f.g.0.h.j.k.l.i.3 3 z.%     q ",
"  p     # d 3 9 ,.<.3 3 3 0.x.c.3 f.g.Z v.b.b.n.m.3 3 4 o       ",
"  ,       M.3 9 ,.=.9 9 9 0.N.B.9 V.u.C.p.G 3.Z.{ 9 3 A.    o $ ",
"          S.z 9 D.F.G.G.H.J.K.G.L.P.W I.U.Y.T.R.E.W.u S.        ",
"    S.      s 9 Q.!.!.!.~.j.^./.(.G ).Q _.`.'.6.].[.g       5   ",
"    X       q {.3 3 3 3 3 3 9 9 9 9 3 3 9 }.9 9 }.8 6     O %   ",
"      O       m j 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 j h       O     ",
"      > O       J |.9 3 3 3 3 3 3 3 3 3 3 3 9  Xa       .XO     ",
"          O       & s 2 3 3 3 3 3 3 3 3 3 u M.6       ]         ",
"          + O         a XX8 z.oXf oXz.4 XX*         OX,         ",
"              %           o % a 9.S.% o           .             ",
"              OX  o                             OXO             ",
"                  q k   o               <   + OX                ",
"                        $   q 5   , 7 7 $                       "}

--------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------
-- Load the args that this script is run with
--for k, v in pairs(arg) do print(k, v) end

if #{...} > 0 then
	-- arguments pushed into wxLua are
	--   [C++ app and it's args][lua prog at 0][args for lua start at 1]
		print("arg1")
		prtable{...}
		arg = {...}
		local n = 1
		while arg[n-1] do
			n = n - 1
			if arg[n] and not arg[n-1] then programName = arg[n] end
		end
		
		local fn=wx.wxFileName(arg[0])
		fn:Normalize()
		_presetsDir=fn:GetPath(wx.wxPATH_GET_VOLUME + wx.wxPATH_GET_SEPARATOR)
		
		fn=wx.wxFileName(arg[-1])
		fn:Normalize()
		_scscriptsdir=fn:GetPath(wx.wxPATH_GET_VOLUME + wx.wxPATH_GET_SEPARATOR).."lua\\sc\\"
end
AppInit()
wx.wxGetApp():MainLoop()

