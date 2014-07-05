Settings={
--[[
	options={
		midiin={},
		midiout={},
		SCpath="",
		SC_SYNTHDEF_PATH="default",
		SC_PLUGIN_PATH={"default"},
		SC_UDP_PORT=57110,
		SC_AUDIO_DEVICE=""
	},
	--]]
	ID_CANCEL_BUTTON=NewID(),
	ID_SAVE_BUTTON=NewID(),
	ID_RESET_MIDI_BUTTON=NewID(),
	ID_SC_BUTTON=NewID(),
	ID_SYNTHPATH_BUTTON=NewID(),
	ID_PLUGINS_BUTTON=NewID(),
	ID_PLUGINS_DELETE_BUTTON=NewID()
}
function Settings:ConfigSave(config)
	config:save_table("settings",self.options)
end
function Settings:ConfigRestore(config)
	self.options = config:load_table("settings") --or this_file_settings.options
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
	
	self:ConfigRestore(file_settings)
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
			--thread_print("cancel midilane ",midilane:cancel(0.2))
			MidiClose()
			--thread_print(Settings.options.midiin,Settings.options.midiout,lanes,scriptlinda,midilinda)
			--midilane=pmidi.gen(Settings.options.midiin,Settings.options.midiout,lanes,scriptlinda,midilinda,
			--{print=thread_print,
			--prerror=thread_error_print,
			--prtable=prtable,
			--idlelinda = idlelinda})
			MidiOpen(self.options)
			--lanes.timer( midilinda, "wait", 1, 0 )	--wait a second
			--local key,val=midilinda:receive("wait") 
			--thread_print("status",midilane.status)
			--checkend(midilane)
			--assert(midilane,"midilane could not be created")
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
			self:ConfigSave(file_settings)
			this:Close() 
		end)
	return self;
end
