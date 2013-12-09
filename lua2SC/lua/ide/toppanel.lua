function CreateTopPanel()
	local toppanel = {}
	
	local ID_PLAY_BUTTON=NewID()
	local ID_TEMPO_TEXT=NewID()
	local ID_POS_SLIDER=NewID()
	
	local panel = wx.wxPanel(frame, wx.wxID_ANY)-- ,wx.wxDefaultPosition, wx.wxSize(500,200))
	toppanel.window = panel
	
	toppanel.playButton = wx.wxToggleButton( panel, ID_PLAY_BUTTON, "Play")
	toppanel.tempoCtrl   = wx.wxTextCtrl( panel, ID_TEMPO_TEXT, "", wx.wxDefaultPosition, wx.wxSize(40,20), wx.wxTE_PROCESS_ENTER )
	toppanel.posSlider = wx.wxSlider(panel, ID_POS_SLIDER, 0, 0, 300,wx.wxDefaultPosition, wx.wxDefaultSize,wx.wxSL_LABELS)
	--posSlider:SetFont(wx.wxFont(6, wx.wxFONTFAMILY_MODERN, wx.wxFONTSTYLE_NORMAL, wx.wxFONTWEIGHT_NORMAL, false, "Andale Mono"))wx.wxNORMAL_FONT
	toppanel.timeStText = wx.wxStaticText(panel, wx.wxID_ANY," 00:00",wx.wxDefaultPosition, wx.wxDefaultSize)
	local label="0 UGens.\t0 Synths.\n0.00-AvgCPU\t0.00-PeakCPU\n0 Groups.\t0 SynthDefs."
	local SCStatusText=wx.wxStaticText(panel, wx.wxID_ANY,label,wx.wxDefaultPosition, wx.wxDefaultSize
		--,wx.wxBORDER_SIMPLE+wx.wxALIGN_CENTRE  
		)
	toppanel.SCStatusText = SCStatusText
	SCStatusText:Wrap(-1)
	local w,h=SCStatusText:GetTextExtent("0.00-AvgCPU\t0.00-PeakCPU\n")
	SCStatusText:SetSize(w+20,h*3)
	toppanel.posSlider:SetFont(wx.wxSMALL_FONT)
	
	
	local buttonSizer = wx.wxBoxSizer( wx.wxHORIZONTAL )
	buttonSizer:Add( toppanel.playButton, 0, wx.wxALIGN_CENTER+wx.wxALL, 3 )
	buttonSizer:Add( toppanel.tempoCtrl, 0, wx.wxALIGN_CENTER+wx.wxALL, 3 )
	buttonSizer:Add( toppanel.posSlider, 1, wx.wxALL, 0 )
	buttonSizer:Add( toppanel.timeStText, 0, wx.wxALIGN_CENTER+wx.wxALL, 3 )
	
	--local mainSizer = wx.wxBoxSizer(wx.wxVERTICAL)
	local panelSizer = wx.wxBoxSizer(wx.wxHORIZONTAL)
	
	--panelSizer:Add( buttonSizer, 1, wx.wxGROW + wx.wxALL, 0 )
	--panelSizer:Add( SCStatusText, 0, wx.wxFIXED_MINSIZE +wx.wxALIGN_CENTER+wx.wxALL, 0 )
	panelSizer:Add( buttonSizer, 1,  wx.wxALL, 0 )
	panelSizer:Add( SCStatusText, 0, wx.wxFIXED_MINSIZE +wx.wxALL, 0 )
	
	--mainSizer:Add( buttonSizer, 0, wx.wxGROW+wx.wxALIGN_CENTER+wx.wxALL, 0 )
	panel:SetSizer(panelSizer)
	panelSizer:SetSizeHints(panel)
	panel:Connect(ID_PLAY_BUTTON, wx.wxEVT_COMMAND_TOGGLEBUTTON_CLICKED,
		function(event) 
			if toppanel.playButton:GetValue() then
				--print("playButton")
				scriptlinda:send("play",1)
			else
				--print("playButton stop")
				scriptlinda:send("play",0)
			end
		end)
			
	panel:Connect(ID_TEMPO_TEXT, wx.wxEVT_COMMAND_TEXT_ENTER,
		function(event)
			--local tempo=tonumber(event:GetEventObject():DynamicCast("wxTextCtrl"):GetValue())
			toppanel.tempoCtrlChanging=false
			local tempo=tonumber(toppanel.tempoCtrl:GetValue())
			scriptlinda:send("tempo",tempo)
		end) 
	panel:Connect(ID_TEMPO_TEXT, wx.wxEVT_COMMAND_TEXT_UPDATED,
		function(event)
			toppanel.tempoCtrlChanging=true
		end) 
	panel:Connect(ID_POS_SLIDER, wx.wxEVT_SCROLL_THUMBTRACK,
            function (event) toppanel.settingPos = true end)

    panel:Connect(ID_POS_SLIDER, wx.wxEVT_SCROLL_THUMBRELEASE,
            function (event)
                local pos = event:GetPosition()
				--local len = 300
               -- local beat=(len*pos/slider_range)
                scriptlinda:send("beat",pos)
                toppanel.settingPos = false
            end )
	function toppanel:printStatus(msg)
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
	function toppanel:set_transport(val)
		if not self.tempoCtrlChanging then
			toppanel.tempoCtrl:ChangeValue(tostring(val.bpm))
		end
		toppanel.playButton:SetValue(val.playing==1)
		toppanel.timeStText:SetLabel(string.format("%02d:%02d",val.abstime/60,val.abstime%60))
		if not self.settingPos then
			local beat=math.floor(val.ppqPos)
			toppanel.posSlider:SetValue(beat)
			local maxpos=toppanel.posSlider:GetMax()
			if(maxpos <=beat) then
				toppanel.posSlider:SetRange(0,beat*2)
			end
		end
	end
	return toppanel
end