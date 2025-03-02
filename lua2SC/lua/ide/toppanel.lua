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
	local label="   \n   \n   \n   " --"0 UGens.\t0 Synths.\n0.00-AvgCPU\t0.00-PeakCPU\n0 Groups.\t0 SynthDefs."
	local SCStatusText = wx.wxStaticText(panel, wx.wxID_ANY,label,wx.wxDefaultPosition, wx.wxDefaultSize,wx.wxBORDER_NONE)
	local SCStatusText2 = wx.wxStaticText(panel, wx.wxID_ANY,label,wx.wxDefaultPosition, wx.wxDefaultSize,wx.wxBORDER_NONE)
	toppanel.SCStatusText = SCStatusText
	SCStatusText:Wrap(-1)
	SCStatusText2:Wrap(-1)
	--local w,h = panel:GetTextExtent("0.00-AvgCPU\t0.00-PeakCPU")
	--local w,h = SCStatusText:GetTextExtent("000 Groups.\t000 SynthDefs.")
	--local size = SCStatusText:GetSizeFromTextSize(w,h)
	--SCStatusText:SetSize(w+20,h*4)
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
	panelSizer:Add( SCStatusText, 0, wx.wxFIXED_MINSIZE, 0 )
	panelSizer:Add( SCStatusText2, 0, wx.wxFIXED_MINSIZE, 0 )
	
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
	--Fails because "\t" width is not respected by GetTextExtent
	function toppanel:printStatusNO(msg)
		local str = msg[2].." UGens.".."\t"..msg[3].." Synths."
		str = str.."\n"..string.format("%0.2f",msg[6]).." AvgCPU".."\t"..string.format("%0.2f",msg[7]).." PeakCPU"
		str = str.."\n"..msg[4].." Groups.".."\t"..msg[5].." SynthDefs."
		str = str.."\n"..msg[8].." S.Rate"
		str = str.."\t"..string.format("%0.3f",msg[9])--.." Nom S.Rate"
		SCStatusText:SetLabel(str)
		--local w,h = SCStatusText:GetTextExtent(str)
		--print(w," ",h)
		--SCStatusText:SetSize(w+100,h*4)
		--local w,h,e,f = SCStatusText:GetTextExtent(str)
		local w,h,e,f = SCStatusText:GetMultiLineTextExtent(str)
		--local size = SCStatusText:GetSizeFromTextSize(w,h)
		print(w," ",h,e,f)
		SCStatusText:SetMinSize(wx.wxSize(w+20,h))
		--SCStatusText:SetSize(w+20,h)
		panelSizer:Layout()
		--panelSizer:SetSizeHints(panel)
		--manager:Update()
	end
	function toppanel:printStatus(msg)
		local str = msg[2].." UGens."
		str = str.."\n"..string.format("%0.2f",msg[6]).." AvgCPU"
		str = str.."\n"..msg[4].." Groups."
		str = str.."\n"..msg[8].." S.Rate"
		local str2 = msg[3].." Synths."
		str2 = str2 .. "\n"..string.format("%0.2f",msg[7]).." PeakCPU"
		str2 = str2 .. "\n"..msg[5].." SynthDefs."
		str2 = str2 .. "\n"..string.format("%0.3f",msg[9]) --.." Nom S.Rate"
		local wDC = wx.wxWindowDC(panel)
		SCStatusText:SetLabel(str)
		SCStatusText2:SetLabel(str2)
		local _,w,h,f = wDC:GetMultiLineTextExtent(str)
		--SCStatusText:SetMinSize(wx.wxSize(w,h))
		SCStatusText:SetMinSize(SCStatusText:ClientToWindowSize(wx.wxSize(w+f,h)))
		local _,w,h,f = wDC:GetMultiLineTextExtent(str2)
		--SCStatusText2:SetMinSize(wx.wxSize(200,h))
		SCStatusText2:SetMinSize(SCStatusText2:ClientToWindowSize(wx.wxSize(w+f,h)))
		panelSizer:Layout()
	end
	function toppanel:set_transport(val)
		if not self.tempoCtrlChanging then
			toppanel.tempoCtrl:ChangeValue(tostring(val.bpm))
		end
		toppanel.playButton:SetValue(val.playing==1)
		toppanel.timeStText:SetLabel(string.format("%02d:%02d",math.floor(val.abstime/60),val.abstime%60))
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