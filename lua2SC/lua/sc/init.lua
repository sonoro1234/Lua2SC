require"sc.callback_wrappers"
require"sc.oscfunc"(scriptlinda)
require"sc.sc_comm"
InitSCCOMM()
require"sc.gui"
require"sc.synthdefsc"

require"sc.scbuffer"
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
--table.insert(initCbCallbacks,MASTER_INIT1)

require"sc.miditoosc"
require"sc.playersscgui"
require"sc.ctrl_bus"
require"sc.named_events"
require"sc.routines"

--theMetro:play(120,-4,0,30)
theMetro:init()
--MASTER_INIT1()
--require"sc.lilypond"
table.insert(initCbCallbacks,1,MASTER_INIT1)
