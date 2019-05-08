local ActionsQueue={}
function QueueAction(interval,action)
	--print("QueueAction-----------------------------------------", interval,action,ActionsQueue)
	action.timestamp = lanes.now_secs() + interval
	ActionsQueue[#ActionsQueue+1] = action
	table.sort(ActionsQueue,function(a,b) return a.timestamp > b.timestamp end)
	lanes.timer(scriptlinda,"QueueAction",interval,0)
end
function doQueueAction(clocktimestamp)
	--print("doQueueAction--------------------",ActionsQueue,ActionsQueue[#ActionsQueue])
	local action=ActionsQueue[#ActionsQueue]
	while action  and action.timestamp <= lanes.now_secs() do
		table.remove(ActionsQueue)
		action[1](action[2])
		action=ActionsQueue[#ActionsQueue]
	end
	if #ActionsQueue > 0 then
		lanes.timer(scriptlinda,"QueueAction",ActionsQueue[#ActionsQueue].timestamp - lanes.now_secs(),0)
	end
end