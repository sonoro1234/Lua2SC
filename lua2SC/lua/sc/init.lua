require"sc.callback_wrappers"
require"sc.oscfunc"(scriptlinda)
require"sc.sc_comm"
InitSCCOMM()
require"sc.gui"
require"sc.synthdefsc"

require"sc.scbuffer"
if not no_players then
if typeshed == false then
	require"sc.MetronomLanes"
elseif typeshed then
	require"sc.MetronomLanesSCH"
else
	error("typeshed is nil")
end
if typeshed == false then
	require"sc.playerssc"
elseif typeshed then
	require"sc.playersscSCH"
else
	error("typeshed is nil")
end
else
	require"sc.MetronomDummy"
end --not no_players

require"sc.miditoosc"
if not no_players then require"sc.playersscgui" end
require"sc.ctrl_bus"
require"sc.named_events"
require"sc.routines"
require"sc.queue_action"

if not no_players then theMetro:init() end
--table.insert(initCbCallbacks,1,MASTER_INIT1)
