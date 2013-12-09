-------IdentifiersList
local function MakeIdentifiers(editor)
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
local IdentifiersList={}
function IdentifiersList:Create(managedpanel)
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
	local arrSt = {}
	for k,v in ipairs(idents) do
		 table.insert(arrSt,v.text)
	end
	self.control:Set(arrSt)
	self.current_identifiers=idents
end

function IdentifiersList:SetEditor(editor)
	local id=editor:GetId()
	openDocuments[id].identifiers=MakeIdentifiers(editor)
	self:Set(openDocuments[id].identifiers)
end

return IdentifiersList
-----------