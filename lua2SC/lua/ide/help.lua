-- ---------------------------------------------------------------------------
-- Create the Help menu and attach the callback functions
local function DisplayHelp()
--[[
	local htmlframe = wx.wxFrame(wx.NULL, wx.wxID_ANY, "Lua2SC",wx.wxDefaultPosition, wx.wxSize(800, 600),wx.wxBORDER_SIMPLE + wx.wxDEFAULT_FRAME_STYLE )
	local html = wx.wxLuaHtmlWindow(htmlframe, wx.wxID_ANY,
                                    wx.wxDefaultPosition, wx.wxSize(360, 150),wx.wxHW_SCROLLBAR_AUTO)

	--html:SetBorders(0)
	html:LoadPage(lua2scpath.."doc\\index.html")
    --html:SetSize(html:GetInternalRepresentation():GetWidth(),html:GetInternalRepresentation():GetHeight())

    local topsizer = wx.wxBoxSizer(wx.wxVERTICAL)
    topsizer:Add(html,1,wx.wxGROW)

    --htmlframe:SetAutoLayout(true)
    htmlframe:SetSizer(topsizer)
	topsizer:SetSizeHints(htmlframe)
	htmlframe:Show()
--]]
io.popen(lua2scpath.."doc\\index.html")
end
local function DisplayAbout(event)
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
function InitHelpMenu()
	local ID_ABOUT = wx.wxID_ABOUT
	local ID_HELP         = NewID()
	helpMenu = wx.wxMenu{
        { ID_ABOUT,      "&About",       "About Lua2SC IDE" },
		{ ID_HELP,      "&Help\tF1",       "Help" }}
	menuBar:Append(helpMenu, "&Help")
	frame:Connect(ID_ABOUT, wx.wxEVT_COMMAND_MENU_SELECTED, DisplayAbout)
	frame:Connect(ID_HELP, wx.wxEVT_COMMAND_MENU_SELECTED, DisplayHelp)
end