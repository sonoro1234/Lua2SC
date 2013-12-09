require("wx")

frame = nil

function main()

    -- create the frame window
    frame = wx.wxFrame( wx.NULL, wx.wxID_ANY, "wxLua Very Minimal Demo",
                        wx.wxDefaultPosition, wx.wxSize(450, 450),
                        wx.wxDEFAULT_FRAME_STYLE )

    -- show the frame window
    frame:Show(true)
end

main()

-- Call wx.wxGetApp():MainLoop() last to start the wxWidgets event loop,
-- otherwise the wxLua program will exit immediately.
-- Does nothing if running from wxLua, wxLuaFreeze, or wxLuaEdit since the
-- MainLoop is already running or will be started by the C++ program.
wx.wxGetApp():MainLoop()