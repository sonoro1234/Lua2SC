local Q = {}

local function dump(msg)
	local tab = "    "
	local tabs = 0
	local data = msg[2]
	local ctrl_inc = data[1] == 1 and true or false
	local numchilds = data[3]
	print(string.rep(tab,tabs).."------------group", data[2],"ctrl_inc",ctrl_inc)
	print(string.rep(tab,tabs).."numchilds:",numchilds)
	local iq = 2
	if numchilds > 0 then
		local function dochilds(numch)
			tabs = tabs + 1
			for i=1,numch do
				if data[iq+1]>=0 then --group
					iq = iq + 2 
				else --synth
					iq = iq + 3
					if ctrl_inc then
						iq = iq + data[iq]*2 + 1
					end
				end
				local childnode = data[iq]
				local numsubchilds = data[iq + 1]
				local childkind = numsubchilds == -1 and "synth" or "group"
				
				if childkind == "group" then
					print(string.rep(tab,tabs), i, childnode, childkind,"subchilds",numsubchilds)
					if numsubchilds > 0 then
						dochilds(numsubchilds)
					end
				--if childkind == "synth" then
				else
					local sname = data[iq + 2]
					print(string.rep(tab,tabs), i, childnode, childkind,"synname",sname)
					if ctrl_inc then
						local numctrl = data[iq + 3]
						--print(string.rep(tab,tabs),"numctrl",numctrl)
						tabs = tabs + 1
						local iq2 = iq + 4
						for j=0,numctrl-1 do
							local param = data[iq2 + j*2]
							local value = data[iq2 + j*2 + 1]
							print(string.rep(tab,tabs),j+1,param,value)
						end
						tabs = tabs - 1
					end
				end
			end
			tabs = tabs - 1
		end
		dochilds(numchilds)
	end
end

local function get_synths(msg)
	local S,G = {},{}
	local data = msg[2]
	local ctrl_inc = data[1] == 1 and true or false
	local numchilds = data[3]
	--print(string.rep(tab,tabs).."------------group", data[2],"ctrl_inc",ctrl_inc)
	--print(string.rep(tab,tabs).."numchilds:",numchilds)
	G[data[2]] = {}

	local iq = 2
	if numchilds > 0 then
		local function dochilds(numch, group)
			local tab = G[group]
			for i=1,numch do
				if data[iq+1]>=0 then --group
					iq = iq + 2 
				else --synth
					iq = iq + 3
					if ctrl_inc then
						iq = iq + data[iq]*2 + 1
					end
				end
				local childnode = data[iq]
				local numsubchilds = data[iq + 1]
				local childkind = numsubchilds == -1 and "synth" or "group"
				
				if childkind == "group" then
					--print(string.rep(tab,tabs), i, childnode, childkind,"subchilds",numsubchilds)
					G[childnode] = {}
					tab[i] = childnode
					if numsubchilds > 0 then
						dochilds(numsubchilds, childnode)
					end
				else
					local sname = data[iq + 2]
					--print(string.rep(tab,tabs), i, childnode, childkind,"synname",sname)
					S[childnode] = {name=sname, group = group}
					tab[i] = S[childnode]
					if ctrl_inc then
						S[childnode].args = {}
						S[childnode].params = {}
						local numctrl = data[iq + 3]
						--print(string.rep(tab,tabs),"numctrl",numctrl)

						--tabs = tabs + 1
						local iq2 = iq + 4
						for j=0,numctrl-1 do
							local param = data[iq2 + j*2]
							local value = data[iq2 + j*2 + 1]
							--print(string.rep(tab,tabs),j+1,param,value)
							S[childnode].args[j+1] = {param,value} 
							S[childnode].params[param] = value
						end
						--tabs = tabs - 1
					end
				end
			end
			--tabs = tabs - 1
		end
		dochilds(numchilds,data[2])
	end
	return {S=S,G=G}
end

function Q.queryTree(groupID, action, include_ctrl_vals, block)
	include_ctrl_vals = include_ctrl_vals and 1 or 0
	if block then
		local tmplinda = lanes.linda()
		OSCFunc.newfilter("/g_queryTree.reply",{include_ctrl_vals, groupID},action,true, true, tmplinda)
		ThreadServerSend{'/g_queryTree', {groupID, include_ctrl_vals }}
		local key,val = tmplinda:receive("OSCReceive") -- wait
		OSCFunc.handleOSCReceive(val) -- clean responder and print
	else
		OSCFunc.newfilter("/g_queryTree.reply",{include_ctrl_vals, groupID},action,true)
		ThreadServerSend{'/g_queryTree', {groupID, include_ctrl_vals }}
	end
end

function Q.dumpTree(groupID, ctrols)
	Q.queryTree(groupID, dump, ctrols)
end

function Q.getTree(groupID, ctrols, action2)
	local function action(msg)
		local QQ = get_synths(msg)
		action2(QQ)
	end
	Q.queryTree(groupID, action, ctrols)
end 

-- uses group from Info = getTree(0,false)
function Q.querySynths2(nodes, Info)
	local neededGroups = {}
	local Synths = {}
	for i,n in ipairs(nodes) do
		local syn = Info.S[n]
		if syn then
			neededGroups[syn.group] = true
			Synths[n] = true
		end
	end
	for k,n in pairs(neededGroups) do
		local QQ = Q.getTree(k,true)
		for ns,_ in pairs(Synths) do
			if QQ.S[ns] then
				Synths[ns] = QQ.S[ns]
			end
		end
	end
	return Synths
end
-- uses n_info
function Q.querySynths(nodes)
	-- node alone
	if type(nodes)~="table" then nodes = {nodes} end
	-- nil nodes
	local nodes2 = {}
	for k,n in pairs(nodes) do  nodes2[#nodes2+1] = n end
	--prtable("nodes2",nodes2)
	local Synths = {}
	for i,n in ipairs(nodes2) do
		OSCFunc.newfilter("/n_info",n,function(v) 
			--prtable("ninfo",v) 
			local data = v[2]
			assert(data[5]==0,"querySynths called with group")
			local group = data[2]
			local QQ = Q.getTree(group, true)
			local syn = QQ.S[n]
			Synths[n] = syn
		end,true)
	end
	--toOSC{'/n_query', nodes}
	ThreadServerSend{'/n_query', nodes2}
end

function Q.querySynthBlock(node)
	if not node then return false end
	local info 
	function action(v)
			print("action",v, node)
			--prtable("ninfo",v) 
			local data = v[2]
			assert(data[5]==0,"querySynths called with group")
			local group = data[2]
			local QQ = Q.getTree(group, true)
			local syn = QQ.S[node]
			info = syn
			print("action done",node)
		end
	local tmplinda = lanes.linda()
	OSCFunc.newfilter("/n_info",node,action,true,true,tmplinda)
	ThreadServerSend{'/n_query', {node}}
	local key,val = tmplinda:receive("OSCReceive") -- wait
	OSCFunc.handleOSCReceive(val) -- clean responder and print
	print("return info",node,info)
	return info
end

function Q.querySynth(node, action2)
	if not node then return false end
	local function action_tree(QQ)
		local syn = QQ.S[node]
		action2(syn)
	end
	function action(v)
			local data = v[2]
			assert(data[5]==0,"querySynths called with group")
			local group = data[2]
			Q.getTree(group, true, action_tree)
		end
	OSCFunc.newfilter("/n_info",node,action,true)
	ThreadServerSend{'/n_query', {node}}
	return true
end

function Q.querySynthValues(node, action2, group)
	if not node then return false end
	local function action_tree(QQ)
		local syn = QQ.S[node]
		if not syn then
			prerror(node,group,"not found in querySynthValues")
			return
		end
		local mapped, mapped_inv = {},{}
		for i,v in ipairs(syn.args) do
			local param = v[1]
			local value = v[2]
			if type(value)=="string" then
				value = tonumber(value:sub(2))
				mapped[param] = value
				mapped_inv[value] = param
			end
		end
		syn.mapped = mapped
		if next(mapped) then
			local qbuses = {}
			local template = {}
			for k,v in pairs(mapped) do
				qbuses[#qbuses+1] = v
				template[v] = true
			end
			local function tempf(data)
				for i=1,#data,2 do
					if template[data[i]] then return true end
				end
				return false
			end
			--OSCFunc.newfilter("/c_set",v,function(msg)
			OSCFunc.newfilter("/c_set",qbuses[1],function(msg) 
						local i=1
						local data = msg[2]
						while true do
							local bus = data[i]
							local value = data[i+1]
							if bus then
								local param = mapped_inv[bus]
								syn.mapped[param] = value
							else
								break
							end
							i = i + 2
						end
						action2(syn)
					end, true)
				--ThreadServerSend{"/c_get",{v}}
			--end
			ThreadServerSend{"/c_get",qbuses}

		else
			action2(syn)
		end
	end
	if not group then
		function action(v)
			local data = v[2]
			assert(data[5]==0,"querySynths called with group")
			local group = data[2]
			Q.getTree(group, true, action_tree)
		end
		OSCFunc.newfilter("/n_info",node,action,true)
		ThreadServerSend{'/n_query', {node}}
	else --group is given
		Q.getTree(group, true, action_tree)
	end
	return true
end

return Q