-------------------------------------------------------------------------=---
-- Name:        Lua2SC
-- Purpose:     Lua2SC IDE
-- Author:      Victor Bombi
-- Created:     2012
-- Copyright:   (c) 2012 Victor Bombi. All rights reserved.
-- Licence:     wxWidgets licence
-------------------------------------------------------------------------=---

lanes=require("lanes")
lanes.configure({ nb_keepers = 1, with_timers = true, on_state_create = nil,track_lanes=true}) --,verbose_errors=true})
idlelinda= lanes.linda()
scriptlinda= lanes.linda()
scriptguilinda= lanes.linda()
midilinda= lanes.linda()
udpsclinda=lanes.linda()
debuggerlinda=lanes.linda()

require("pmidi")
--------------------------------
oldpr=print
require("wx")
print=oldpr

os.setlocale("C")	--to let serialize work for numbers
function SetLuaPath(arg)
	local fn=wx.wxFileName(arg[0])
	fn:Normalize()
	lua2scpath = fn:GetPath(wx.wxPATH_GET_VOLUME + wx.wxPATH_GET_SEPARATOR)
	_presetsDir = lua2scpath.."presets\\"
	--_scscriptsdir = lua2scpath .."sc\\"
	package.path = lua2scpath .. "lua\\?.lua;" .. lua2scpath .. "lua\\?\\init.lua;" .. package.path 
	print(package.path)
end
SetLuaPath(arg) 
local ID_IDCOUNTER = wx.wxID_HIGHEST + 1
function NewID()
    ID_IDCOUNTER = ID_IDCOUNTER + 1
    return ID_IDCOUNTER
end
require("sc.utils")
--if not bit32 then
--	require("bitOp")	--not nedded here but to avoid lanes wx crash
--end
require("random") 	--not nedded here but to avoid lanes wx crash
--require"profiler"
require("socket")
require("osclua")
toOSC=osclua.toOSC
fromOSC=osclua.fromOSC
Config = require"ide.config"
Config:init("Lua2SCIDE", "sonoro")
config = Config.config
require"ide.settings"
Settings:ConfigRestore(Config)
SCUDP = require"ide.scudp"
SCUDP:init()
require"ide.ide"
----------------------------------

AppInit()
wx.wxGetApp():MainLoop()

print"exit: print lindas:"
lindas = {idlelinda,scriptlinda,scriptguilinda,midilinda,udpsclinda,debuggerlinda}
for i,linda in ipairs(lindas) do
	print("linda",i)
	prtable(linda:count(),linda:dump())
end
prtable(lanes.timers())
prtable(lanes.threads())
