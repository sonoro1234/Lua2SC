require"sc.callback_wrappers"
require"sc.oscfunc"(scriptlinda)
require"sc.sc_comm"
InitSCCOMM()
-- get sc version
local res = sendBlocked({"/version",{}})
assert(res[1]=="/version.reply")
server_version = {name=res[2][1],major=res[2][2],minor=res[2][3]}
---
require"sc.gui"
require"sc.synthdefsc"

require"sc.scbuffer"
if not no_players then
	require"sc.MetronomLanes"
	require"sc.playerssc"
else
	require"sc.MetronomDummy"
end --not no_players

require"sc.miditoosc"
if not no_players then 
	require"sc.playersscgui"
	SetMainPanel()
end
require"sc.ctrl_bus"
require"sc.named_events"
require"sc.routines"
require"sc.queue_action"

if not no_players then theMetro:init() end
--table.insert(initCbCallbacks,1,MASTER_INIT1)
