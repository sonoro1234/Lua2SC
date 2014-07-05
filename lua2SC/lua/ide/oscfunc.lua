-----------------------------------------------------------
OSCFuncLinda = idlelinda
OSCFunc={filters={}}
function OSCFunc.newfilter(path,template,func,runonce,block,alt_linda)
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
function OSCFunc.clearfilters(path,template,alt_linda)
	local handleOSCFuncLinda = alt_linda or OSCFuncLinda
	--print("OSCFunc.clearfilters ",path," ",template)
	udpsclinda:send("clearFilter",{path,handleOSCFuncLinda})
	if OSCFunc.filters[path] then
		for i,filter in pairs(OSCFunc.filters[path]) do
			if (template==nil) or (template==filter.template) then
				OSCFunc.filters[path][i]=nil
				print(" is done OSCFunc.clearfilters ",path," ",template)
			end
		end
	end
end
function OSCFunc.handleOSCReceive(msg)
	if msg[1]=="/fail" then
		print(tb2st(msg))
	end
	if OSCFunc.filters[msg[1]] then
		for i,filter in pairs(OSCFunc.filters[msg[1]]) do
			if (filter.template=="ALL") or (msg[2][1]==filter.template) then
				filter.func(msg)
				if filter.runonce then
					OSCFunc.filters[msg[1]][i]=nil
				end
			end
		end
	end
end
------------------------------------------
