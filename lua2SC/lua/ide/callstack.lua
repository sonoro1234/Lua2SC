--call stack
local CallStack={}
function CallStack:Create(managedpanel)
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
		local levi = event:GetIndex() + 1 
		--print("selecciono: ",lev)
		if self.luastack then
			local lev=self.luastack[levi]
			if  lev and lev.what~="C" then
				abriredit(lev.source:sub(2),lev.currentline)
			end
			ClearLog(DebugLog)
			if self.vars then
				DisplayLog(ToStr(self.vars[levi]),DebugLog)
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
function CallStack:MakeStack(stack,err,vars)
	stack = stack or {}
	local watchListCtrl=self.window
	self.luastack=stack
	self.vars = vars
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
	ClearLog(DebugLog)
	if self.vars then
		DisplayLog(ToStr(self.vars[1],true),DebugLog)
	end
end

return CallStack