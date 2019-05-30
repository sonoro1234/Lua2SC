-----------------------------------------------------------
local OSCFuncLinda 
OSCFunc={filters={}}
function OSCFunc.newfilter(path,template,func,runonce,block,alt_linda)
	template = template or "ALL"
	local handleOSCFuncLinda = alt_linda or OSCFuncLinda
	OSCFunc.filters[path] = OSCFunc.filters[path] or {} 
	OSCFunc.filters[path][#OSCFunc.filters[path]+1] ={template=template,func=func,runonce=runonce}
	if block then -- TODO: it is too slow, may be having a dedicated linda for that ...
		local tmplinda = lanes.linda()
		udpsclinda:send("addFilter",{path,handleOSCFuncLinda,tmplinda})
		tmplinda:receive("addFilterResponse")
	else
		udpsclinda:send("addFilter",{path,handleOSCFuncLinda})
	end
end

local function CheckTemplate(msg,template)
	if not template or template=="ALL" then
		return true
	end
	if type(template)=="table" then
		for i,v in ipairs(template) do
			if msg[i]~=v then return false end
		end
		return true
	else
		return msg[1]==template
	end
end

function OSCFunc.clearfilters(path,template,alt_linda)
	local handleOSCFuncLinda = alt_linda or OSCFuncLinda
	--print("OSCFunc.clearfilters ",path," ",template)
	
	if OSCFunc.filters[path] then
		for i,filter in pairs(OSCFunc.filters[path]) do
			if CheckTemplate(template,filter.template) then
			--if (template==nil) or (template==filter.template) then
				OSCFunc.filters[path][i]=nil
				print(" is done OSCFunc.clearfilters ",path," ",template)
			end
		end
	end
	if #OSCFunc.filters[path] == 0 then
		udpsclinda:send("clearFilter",{path,handleOSCFuncLinda})
		OSCFunc.filters[path] = nil
	end
end
function OSCFunc.clearall(alt_linda)
	local handleOSCFuncLinda = alt_linda or OSCFuncLinda
	for path,v in pairs(OSCFunc.filters) do
		OSCFunc.clearfilters(path)
	end
end

function OSCFunc.handleOSCReceive(msg)
	--print("OSCFunc.handleOSCReceive",msg[1])
	if msg[1]=="/fail" then
		print(tb2st(msg))
	end
	if OSCFunc.filters[msg[1]] then
		for i,filter in pairs(OSCFunc.filters[msg[1]]) do
			if CheckTemplate(msg[2],filter.template) then
				filter.func(msg)
				if filter.runonce then
					OSCFunc.filters[msg[1]][i]=nil
				end
			end
		end
	end
end
function OSCFunc.process_all(timeout)
	timeout = timeout or 0.2
	while true do
		local key,val = OSCFuncLinda:receive(timeout,"OSCReceive")
		if key == "OSCReceive" then
			OSCFunc.handleOSCReceive(val)
		elseif val==nil then
			--timeout
			break
		end
	end
end
function OSCFunc.trace(doit,status)
	udpsclinda:send("trace",{doit,status})
end
--this is called from scriptrun
--but not from ide
return function(linda) 
	OSCFuncLinda = linda 
	if linda==scriptlinda then
	table.insert(resetCbCallbacks,
		function()
			print"reset clear OSCFunc"
			OSCFunc.clearall() 
		end)
	end
end
------------------------------------------
