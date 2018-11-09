-- Global Functions

local funcs = {}
local bufnum = -1
local nodeID = 999
local groupID = 1
local busIndex = 15
local osctypes = {int32=true,float=true}
function parseArgsX(args,useint)
	local a = {}
	local numbertype = useint and "int32" or "float"
	if args ~= nil then
		for name,value in pairs(args) do
			table.insert(a,name)
			if type(value) ~= "table" then
				if type(value)=="number" then
					table.insert(a,{numbertype,value})
				else
					table.insert(a,value)
				end
			else -- is table
				if type(value[1]) == "string" then
					if osctypes[value[1]] then
						assert(#value == 2)
						table.insert(a,value)
					else
						table.insert(a,{"["})
						for i,val in ipairs(value) do
							table.insert(a,val)
						end
						table.insert(a,{"]"})
					end
				else
					table.insert(a,{"["})
					for i,val in ipairs(value) do
						table.insert(a,{numbertype,val})
					end
					table.insert(a,{"]"})
				end
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

return funcs