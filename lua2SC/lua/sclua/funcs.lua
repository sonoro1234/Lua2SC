-- Global Functions

local funcs = {}
local bufnum = -1
local nodeID = 999
local groupID = 1
local busIndex = 15

function parseArgsX(args)
	local a = {}
	if args ~= nil then
		for name,value in pairs(args) do
			table.insert(a,name)
			if type(value) ~= "table" then
				table.insert(a,{"float",value})
			else
				table.insert(a,{"["})
				for i,val in ipairs(value) do
					table.insert(a,{"float",val})
				end
				table.insert(a,{"]"})
			end
		end
--		for arg, val in pairs(args) do 
--			table.insert(a, arg)
--			table.insert(a, val)
--		end
	end
	return a
end

function nextBufNum()
	bufnum = bufnum + 1
	return bufnum
end
nextBufNum = GetBuffNum or nextBufNum
function nextNodeID()
	nodeID = nodeID + 1
	return nodeID
end
nextNodeID = GetNode or nextNodeID 
function nextGroupID()
	groupID = groupID + 1
	return groupID
end
nextGroupID = GetNode or nextGroupID 
function nextBusIndex()
	busIndex = busIndex + 1
	return busIndex
end
nextBusIndex = GetCtrlBus or nextBusIndex
return funcs