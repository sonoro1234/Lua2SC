local autoCompleteEnable = true -- value of ID_AUTOCOMPLETE_ENABLE menu item
G_do_write_midi = false
G_do_write_midi_number = false


local wxver = string.match(wx.wxVERSION_STRING, "[%d%.]+")
local useoldindicator = wxver <= "2.9.5"
local BOX_INDICATOR = wxver <= "2.9.5" and 0 or wxstc.wxSTC_INDIC_CONTAINER
print("wxver",wxver)

local function FoldSome()
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
function OnUpdateUIEditMenu(event) -- enable if there is a valid focused editor
	local editor = GetEditor()
	event:Enable(editor ~= nil)
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
--[[
function stsplit(s,c)
	local t = {}
	local pat = ""..c.."?([^"..c.."]*)"..c.."?"
	--local pat = ""..c.."?([^"..c.."]+)"..c.."?"
	for w in string.gmatch(s, pat) do  -- ";?[^;]+;?"
		t[#t + 1] = w
	end
	return t
end
--]]
function stsplit(str, pat)
	local t = {} 
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		table.insert(t,cap)
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	elseif str:sub(-1)==pat then
		table.insert(t, "")
	end
	return t
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

		---[[
		if not sckeywords then
			require"ide.getkeywords"
            sckeywords = GetSCKeyWords()
        end
        editor:SetKeyWords(5, sckeywords or "")
		--]]
    else
        editor:SetLexer(wxstc.wxSTC_LEX_NULL)
        editor:SetKeyWords(0, "")
    end

    editor:Colourise(0, -1)
end

function CreateAutoCompList(key_) -- much faster than iterating the wx. table
	--escape magic characters ^$()%.[]*+-?
	local key = key_:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1")
	--print("CreateAutoCompList",key_,key)
	local a, b = string.find(sckeywords, " "..key, 1)
    local key_list = ""

    while a do
        local c, d = string.find(sckeywords, " ", b, 1)

        key_list = key_list..string.sub(sckeywords, a+1, c or -1)
		a, b = string.find(sckeywords, " "..key, d)
    end
    return key_list
end
-- ----------------------------------------------------------------------------
-- Create an editor and add it to the notebook
local editorID         = 100    -- window id to create editor pages with, incremented for new editors
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
	--editor:SetCodePage(wx.wxFONTENCODING_CP1253)
    for i = 0, 32 do
        editor:StyleSetFont(i, font)
    end
	for i = 0, 32 do
        editor:StyleSetCharacterSet(i, wxstc.wxSTC_CHARSET_GREEK) --wxSTC_CHARSET_ANSI)
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
    editor:StyleSetBackground(wxstc.wxSTC_LUA_WORD7, wx.wxColour(0,   127, 127)) -- Keyword 7 background

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
	editor.calltipdef = ""
	local function CallTipsProcess(back)
		if not editor:CallTipActive() then return end
		local pos = editor:GetCurrentPos()
		if back then pos = pos - 1 end
		local st_pos = editor:PositionFromLine(editor:LineFromPosition(pos))
		local word = editor:GetTextRange(st_pos, pos)
		local pieces = stsplit(word,",")
		local npieces = #pieces
		--DisplayOutput(tostring(word).." "..tostring(npieces)..ToStr(pieces).."\n")
		if #editor.calltipdef > 0 then
			local a,b=0,0
			local def = stsplit(editor.calltipdef,",")
			for i=1,npieces-1 do
				if def[i] then
					a = a + #def[i] + 1
				end
			end
			if def[npieces] then
				b = a + #def[npieces] + 1
			end
			--local a,b = editor.calltipdef:find(".-,")
			editor:CallTipSetHighlight((a or 1),b or 1)
		end
	end
	editor:Connect(wx.wxEVT_KEY_DOWN, --wxstc.wxEVT_STC_KEY, cant work!!
		function(event) 
			if wx.WXK_BACK == event:GetKeyCode() then
				CallTipsProcess(true)
			end
			event:Skip()
		end)
	
    editor:Connect(wxstc.wxEVT_STC_CHARADDED,
            function (event)
                -- auto-indent
                local ch = event:GetKey()
				--DisplayOutput(tostring(ch).."\n")
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
				elseif ch == string.byte('(') then
					local pos = editor:GetCurrentPos()
                    local start_pos = editor:WordStartPosition(pos-1, true)
					local word = editor:GetTextRange(start_pos, pos-1)
					local prevchar = editor:GetTextRange(start_pos-1, start_pos)
					--DisplayOutput("prevchar "..tostring(prevchar).."\n")
					if prevchar == '.' or prevchar == ':' then
						start_pos = editor:WordStartPosition(start_pos-2, true)
						word = editor:GetTextRange(start_pos, pos-1)
					end
					--DisplayOutput("sckeywordsSource "..tostring(word).."\n")
					local def = ""
					if sckeywordsSource[word] then def = tostring(sckeywordsSource[word].args)  end
					--if sckeywordsSource[word] then def = tostring(sckeywordsSource[word].def)..tostring(sckeywordsSource[word].args)  end
					editor:CallTipShow(editor:GetCurrentPos(),tostring(def))
					local a,b = def:find(".-,")
					editor:CallTipSetHighlight((a or 1) - 1,b or 1)
					editor.calltipdef = def
				elseif ch == string.byte(",") then
					CallTipsProcess()
				elseif ch == string.byte(')') then
					if editor:CallTipActive() then editor:CallTipCancel() end
					editor.calltipdef = ""
                elseif autoCompleteEnable then -- code completion prompt
					--[[
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
					--]]
					AutoComplete(editor)
                end
            end)

    editor:Connect(wxstc.wxEVT_STC_USERLISTSELECTION,
            function (event)
                local pos = editor:GetCurrentPos()
                local start_pos = editor:WordStartPosition(pos, true)
				local prevchar = editor:GetTextRange(start_pos-1, start_pos)
				--DisplayOutput("prevchar "..tostring(prevchar).."\n")
				if prevchar == '.' or prevchar == ':' then
					start_pos = editor:WordStartPosition(start_pos-2, true)
				end
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
	editor:IndicatorSetStyle(BOX_INDICATOR,wxstc.wxSTC_INDIC_BOX)
	local MarkWords,ClearMarkWords
	if useoldindicator then
		MarkWords = function(editor,what)
			
			local flags=wxstc.wxSTC_FIND_WHOLEWORD + wxstc.wxSTC_FIND_MATCHCASE
			local len=editor:GetLength()
			local wlen=string.len(what)
			
			editor:StartStyling(0,wxstc.wxSTC_INDICS_MASK)
			editor:SetStyling(len,0)
			
			local posFind=editor:FindText(0,len,what,flags)
			while posFind~=-1 do
				--print("editor:GetStyleAt(posFind)",editor:GetStyleAt(posFind))
				editor:StartStyling(posFind,wxstc.wxSTC_INDICS_MASK)
				editor:SetStyling(wlen,wxstc.wxSTC_INDIC0_MASK) --0x20
				posFind=editor:FindText(posFind+wlen,len,what,flags)
			end
		end
		ClearMarkWords = function(editor)
			editor:StartStyling(0,wxstc.wxSTC_INDICS_MASK)
			editor:SetStyling(editor:GetLength(),0)
		end
	else --new indicators
		MarkWords = function(editor,what)
			
			local flags=wxstc.wxSTC_FIND_WHOLEWORD + wxstc.wxSTC_FIND_MATCHCASE
			local len=editor:GetLength()
			local wlen=string.len(what)
			
			editor:SetIndicatorCurrent(BOX_INDICATOR)
			editor:IndicatorClearRange(0,len)
			
			local posFind=editor:FindText(0,len,what,flags)
			while posFind~=-1 do
				--print("editor:GetStyleAt(posFind)",editor:GetStyleAt(posFind))
				editor:IndicatorFillRange(posFind,wlen)
				posFind=editor:FindText(posFind+wlen,len,what,flags)
			end
		end
		ClearMarkWords = function(editor)
			editor:SetIndicatorCurrent(BOX_INDICATOR)
			editor:IndicatorClearRange(0,editor:GetLength())
		end
	end
	---[[
	editor:Connect(wxstc.wxEVT_STC_DOUBLECLICK,
            function (event)
				local startSel = editor:GetSelectionStart()
				local endSel   = editor:GetSelectionEnd()
				if (startSel ~= endSel) and (editor:LineFromPosition(startSel) == editor:LineFromPosition(endSel)) then
					MarkWords(editor,editor:GetSelectedText())
					--print(editor:GetSelectedText())
				else
					ClearMarkWords(editor)
				end
            end)
			--]]
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
	SetupKeywords(editor, IsLuaFile(name))
    return editor
end
function AutoComplete(editor)
	local pos = editor:GetCurrentPos()
	local start_pos = editor:WordStartPosition(pos, true)
	local prevchar = editor:GetTextRange(start_pos-1, start_pos)
	if prevchar == '.' or prevchar == ':' then
		start_pos = editor:WordStartPosition(start_pos-2, true)
	end
	if (pos - start_pos > 2) and (start_pos > 2) then
		--local range = editor:GetTextRange(start_pos-3, start_pos)
		--if range == "wx." then
			local key = editor:GetTextRange(start_pos, pos)
			key = key:gsub(":",".")
			local userList = CreateAutoCompList(key)
			if userList and string.len(userList) > 0 then
				editor:UserListShow(1, userList)
			end
		--end
	end
end
-- ---------------------------------------------------------------------------
-- Create the Edit menu and attach the callback functions

function InitEditMenu()
	local ID_CUT              = wx.wxID_CUT
	local ID_COPY             = wx.wxID_COPY
	local ID_PASTE            = wx.wxID_PASTE
	local ID_SELECTALL        = wx.wxID_SELECTALL
	local ID_UNDO             = wx.wxID_UNDO
	local ID_REDO             = wx.wxID_REDO
	local ID_AUTOCOMPLETE     = NewID()
	local ID_AUTOCOMPLETE_ENABLE = NewID()
	local ID_WRITE_MIDI = NewID()
	local ID_WRITE_MIDI_NUMBER = NewID()
	local ID_COMMENT          = NewID()
	local ID_FOLD             = NewID()
	local editMenu = wx.wxMenu{
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
			{ ID_WRITE_MIDI, "Write MIDI\tCtrl+M", "Write MIDI", wx.wxITEM_CHECK },
			{ ID_WRITE_MIDI_NUMBER, "Write MIDI number", "Write MIDI number", wx.wxITEM_CHECK },
			{ },
			{ ID_COMMENT, "C&omment/Uncomment\tCtrl-Q", "Comment or uncomment current or selected lines"},
			{ },
			{ ID_FOLD,    "&Fold/Unfold all\tF12", "Fold or unfold all code folds"} }
	menuBar:Append(editMenu, "&Edit")
	local function PasteToANSI(editor)
		print"PasteToANSI"
		local clipboard=wx.wxClipboard.Get()
		if (clipboard:Open()) then
			--clipboard:SetData( wx.wxTextDataObject(text) );
			if clipboard:IsSupported(wx.wxDataFormat(wx.wxDF_TEXT)) then
				local data = wx.wxTextDataObject() 
				clipboard:GetData( data );
				local str = data:GetText()--:ToAscii() 
				--wx.wxMessageBox( str);
				--editor:ReplaceSelection(fixUTF8(str,"X"))
				editor:ReplaceSelection(str:gsub("[\128-\255]"," "))
			end
			clipboard:Close();
		end
	end
	local function OnEditMenu(event)
		local menu_id = event:GetId()
		local editor = GetEditor()
		if editor == nil then return end
		
		if     menu_id == ID_CUT       then editor:Cut()
		elseif menu_id == ID_COPY      then editor:Copy()
		elseif menu_id == ID_PASTE     then PasteToANSI(editor) --editor:Paste()
		elseif menu_id == ID_SELECTALL then editor:SelectAll()
		elseif menu_id == ID_UNDO      then editor:Undo()
		elseif menu_id == ID_REDO      then editor:Redo()
		end
	end
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
				AutoComplete(editor)
			end)
	frame:Connect(ID_AUTOCOMPLETE, wx.wxEVT_UPDATE_UI, OnUpdateUIEditMenu)
	
	frame:Connect(ID_AUTOCOMPLETE_ENABLE, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				autoCompleteEnable = event:IsChecked()
			end)
	frame:Connect(ID_WRITE_MIDI, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				G_do_write_midi = event:IsChecked()
			end)
	frame:Connect(ID_WRITE_MIDI_NUMBER, wx.wxEVT_COMMAND_MENU_SELECTED,
			function (event)
				G_do_write_midi_number = event:IsChecked()
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

