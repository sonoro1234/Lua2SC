require"sc.callback_wrappers"
require"sc.sc_comm"
InitSCCOMM()
require"sc.gui"
if typeshed == false then
	require"sc.playerssc"
elseif typeshed then
	require"sc.playersscSCH"
else
	error("typeshed is nil")
end
require"sc.miditoosc"
require"sc.playersscgui"
require"sc.scbuffer"
require"sc.ctrl_bus"
if typeshed == false then
	require"sc.MetronomLanes"
elseif typeshed then
	require"sc.MetronomLanesSCH"
else
	error("typeshed is nil")
end
MASTER_INIT1()
