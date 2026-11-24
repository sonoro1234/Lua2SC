require("sc.synthdefSCRead")

function openSynthdefGuiA(synthfile,panel,params,notified,dontusedefaults,usetext)
	return openSynthdefGuiB(SynthDefs_path..synthfile..".scsyndef",panel,params,notified,dontusedefaults,usetext)
end
--openSynthdefGui(fx,panelParamfx,true,false,3)
function openSynthdefGui(fx,panel,dontusedefaults,usetext,minrows)
	return openSynthdefGuiB(SynthDefs_path..fx.name..".scsyndef", panel, fx.params, fx, dontusedefaults,usetext,minrows)
end
function closeSynthdefGuiControls(parameterCtl)
	for i,v in ipairs(parameterCtl) do
		local res=deleteControl(v)
		--print("deletecontrol "..res.."\n")
	end
end
function closeSynthdefGui(panel)
	emptyPanel(panel)
end

function getSynthdefParams(synthname)
	--local syntdef=readSCSynthFile(SynthDefs_path..synthname..".scsyndef")
	local syntdef=readSCSynthFile(synthname)
		-- hallar las longitudes de los parametross
	local longitudes={}
	local lasti=0
	local lastv=""
	-- not consecutive number keys
	for i,v in	pairsByKeys(syntdef.paramnames) do
		--println(i," : ",v)
		if lasti > 0 then longitudes[lastv]=i-lasti end
		lasti=i
		lastv=v
	end
	longitudes[lastv]=#syntdef.parameters-lasti+1
	syntdef.paramlens = longitudes
	return syntdef
	--return {paramnames=syntdef.paramnames,paramlens=longitudes}
end
-- for n_getn
local function getSynthdefParams_getn(t)
	local tt = {}
	for i,v in pairs(t.paramnames) do
		table.insert(tt,v)
		table.insert(tt,t.paramlens[v])
	end
	return tt
end

function openSynthdefGuiB(synthfile,panelC,params,notified,dontusedefaults,usetext,minrows)
	--print("openSynthdefGuiB")
	
	--addPanel{type="vbox",name=synthfile,parent=panelC}
	minrows=minrows or 3
	local panel=addPanel{type="gridbag",parent=panelC}
	if dontusedefaults==nil then dontusedefaults=true end

	local parameterCtl={}
	--local syntdef=readSCSynthFile(synthfile)
	local syntdef=getSynthdefParams(synthfile)
	local longitudes = syntdef.paramlens
	parameterCtl.synthdef=syntdef
	--prtable(syntdef.parameters)

	params= params or {}
	-------------clean params
	-- delete params not in syntdef.paramnames and in the typical group freq,etc
	local parnames={}
	for i,v in pairs(syntdef.paramnames) do
		if v~="freq" and v~="gate" and v~="out" and v~="amp" and v~="pan" and v~="busin" and v~="busout" then
			parnames[v]=true
		end
	end
	--prtable("xxxxxxxparnames",parnames)
	for k,v in pairs(params) do
		if not parnames[k] then params[k]=nil end
	end
--[[
	-------------------------------------
	-- hallar las longitudes de los parametross
	local longitudes={}
	local lasti=0
	local lastv=""
	-- not consecutive number keys
	for i,v in	pairsByKeys(syntdef.paramnames) do
		--println(i," : ",v)
		if lasti > 0 then longitudes[lastv]=i-lasti end
		lasti=i
		lastv=v
	end
	longitudes[lastv]=#syntdef.parameters-lasti+1
--]]
	--prtable(longitudes)
	-- get the longest param
	local maxlongi=minrows
	for k,longi in pairs(longitudes) do
		if longi > maxlongi then
			maxlongi = longi
		end
	end
--  print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
--	prtable(params)
--	prtable(syntdef.paramnames)
--	prtable(syntdef.parameters)
--	prtable(longitudes)
	---------------------------------
	
	local row=0
	local col=-1
	local function compst(a,b) return a:upper() < b:upper() end
	--for i,v in pairsByKeys(syntdef.paramnames) do
	for i,v in pairsByValues(syntdef.paramnames,compst) do
		--print("xxxxxxxxxxxparamnames ",i," ",v)
		--prtable(params)
		local defval, defval_s
		if v~="freq" and v~="gate" and v~="out" and v~="amp" and v~="pan" and v~="busin" and v~="busout" then
			if longitudes[v]>1 then compuesto=true else compuesto=false end 
			--print("compuesto ",compuesto)
			for i2=i,i+longitudes[v]-1 do
				if dontusedefaults then
					--print("i2 ",i2," [i2-i+1] ",i2-i+1)
					if compuesto then 
						if params[v] then
							--print("i2 ",i2," [i2-i+1] ",i2-i+1," es ",params[v][i2-i+1])
							defval=params[v][i2-i+1] or syntdef.parameters[i2]
						else
							--print("i2 ",i2," [i2-i+1] ",i2-i+1," ","no params ",v)
							defval=syntdef.parameters[i2]
						end
					else
						defval=params[v] or syntdef.parameters[i2]
					end
				else
					--println("c0n defaults")
					defval=syntdef.parameters[i2]
				end
				defval_s = syntdef.parameters[i2]
				if defval_s > 0 then
					--maxval=(defval <=1) and 1 or defval*2
					maxval= defval_s * 4
					minval=0
				elseif defval_s==0 then
					maxval = 1
					minval = -1
				else
					--probably db
					maxval = -defval_s * 6
					minval = defval_s * 6
				end
				
				local textcontrol = {panel=panel,value=defval,type=GUITypes.text}
				local newcontrol 
				if v=="bypass" then
					newcontrol = {panel=panel,value=0,typex="toggle",label=v}
					newcontrol.FormatLabel=function(val) return v end
				else
					newcontrol = {panel=panel,value=defval,min=minval ,max=maxval,typex=gui.default_control,name=v,label=0} --vslider
					newcontrol.FormatLabel=function(val) return string.format("%4.2f",val) end
				end
				
				if compuesto then
					params[v]=params[v] or {}
					params[v][i2-i+1]=defval
					
					col=i2-i
					if (col==0) then --first
						row = row + 1
					end
					newcontrol.pos={row,col}
					if usetext then
						local row2=row*2
						newcontrol.pos={row2,col}
						textcontrol.pos={row2+1,col}
					end
					if (col==longitudes[v]-1) then --last
						col = col + 1
					end
					newcontrol.variable={v,i2-i+1}
					newcontrol.parameter = i2 - 1
					newcontrol.callback=function(val,s,c)
							params[v] = params[v] or {}
							params[v][i2-i+1]=val;
							--print("callbak ",val,s)
							--c:setLabel(string.format("%4.2f",val))
						end
					if notified~=nil then
						newcontrol.notify=newcontrol.notify or {}
						table.insert(newcontrol.notify,notified)
					end
				else --not compuesto
					params[v]=defval
					--newcontrol.pos={row,col}
					col=col +1
					if col >= maxlongi then
						col =0 
						row = row + 1
					end
					newcontrol.pos={row,col}
					if usetext then
						local row2=row*2
						newcontrol.pos={row2,col}
						textcontrol.pos={row2+1,col}
					end
					newcontrol.variable={v}
					newcontrol.parameter = i2 - 1
					newcontrol.callback=function(val,s,c)
							params[v]=val;
							--print(val,s)
							--c:setLabel(string.format("%4.2f",val))
						end
					if notified~=nil then
						newcontrol.notify=newcontrol.notify or {}
						table.insert(newcontrol.notify,notified) 
						
					end
				end
				
				local cont=addControl(newcontrol)
				if notified and notified.RegisterControl then
					notified:RegisterControl(cont)
				end
				if usetext then
					local oldcb=cont.callback
					local tecont=addControl(textcontrol)
					tecont.callback=function(val,str,c) 
						--print("tecont.callback",val,str)
						if str then
							cont:val(tonumber(str))--,false) --there is no loop: tecont uses str
							cont:donotify() --simulate _valueChangedCb
						end
					end
					cont.callback=function(val,str,c)
							--print("cont.callback",val,str)
							oldcb(val,str,c)
							tecont:val(tostring(val))--there is no loop: tecont uses str
						end
				end
				parameterCtl[#parameterCtl + 1] = cont
			end
		end
	end
	--- prepare /s_getn
	--[=[
	local msgpars = getSynthdefParams_getn({paramnames=syntdef.paramnames,paramlens=syntdef.paramlens})
	local controls = {}
	for i,v in ipairs(parameterCtl) do 
		if v.name then
			if v.variable[2] then
				controls[v.name]=controls[v.name] or {}
				controls[v.name][v.variable[2]]=v
			else
				controls[v.name] = v
			end
		end
	end

	function parameterCtl.updateONLYset(time,nodeID)
		time = time or 0.5
		OSCFunc.newfilter("/n_setn",nodeID, function(msg) 
			local resp = msg[2]
			local msglen = #msg[2]
			local i = 2
			while i<msglen do
				local name = resp[i]
				local long = resp[i+1]
				if controls[name] then
					if long==1 then
						controls[name]:val(resp[i+2])
					else
						for j=1,long do
							controls[name][j]:val(resp[i+1+j])
						end
					end
				end
				i = i + 2 + long
			end
			QueueAction(time,{function() ThreadServerSend{"/s_getn",{nodeID,unpack(msgpars)}} end})
		end)
		QueueAction(time,{function() ThreadServerSend{"/s_getn",{nodeID,unpack(msgpars)}} end})
	end
	--]=]
	-- nodeID is the group of synth
	local parcontrols = {}
	for i,v in ipairs(parameterCtl) do 
		if v.parameter then
			parcontrols[v.parameter] = v
		end
		if v.name then
			if v.variable[2] then
				if v.variable[2]==1 then
					parcontrols[v.name]=v
				end
			else
				parcontrols[v.name] = v
			end
		end
	end
	--print"parcontrols================="
	--print(parcontrols.fA)
	--for k,v in pairs(parcontrols) do print(k,v) end

	function parameterCtl.updateBAD(time, nodeID, synnodeID)
		time = time or 0.5
		local mapped, mapped_inv
		local function action(msg)
				assert(msg[2][3]==1,"several nodes in group")
				assert(msg[2][4]==synnodeID,"different ID")
				assert(msg[2][5]==-1,"not a synth")
				mapped, mapped_inv = {},{}
				local data = msg[2]
				for i=0,data[7]-1 do
					local param = data[i*2+8]
					local value = data[i*2+9]
					if type(value)=="string" then
						value = tonumber(value:sub(2))
						mapped[param] = value
						mapped_inv[value] = param
					else
						if parcontrols[param] then
							parcontrols[param]:val(value)--, false)
						else
							--print("parcontrols",param, "not found")
						end
					end
					--print(param,value)
				end
				if next(mapped) then
					local qbuses = {}
					for k,v in pairs(mapped) do
						qbuses[#qbuses+1] = v
					end
					OSCFunc.newfilter("/c_set",qbuses[1],function(msg) 
							local i=1
							local data = msg[2]
							while true do
								local bus = data[i]
								local value = data[i+1]
								if bus then
									local param = mapped_inv[bus]
									if parcontrols[param] then
										parcontrols[param]:val(value)--, false)
									else
										--print("parcontrols",param, "not found")
									end
								else
									break
								end
								i = i + 2
							end
						end, true)
					ThreadServerSend{"/c_get",qbuses}
				end
				QueueAction(time,{function() ThreadServerSend{'/g_queryTree', {nodeID, 1 }} end})
		end
		OSCFunc.newfilter("/g_queryTree.reply",{1, nodeID},action)
		--ThreadServerSend(syn.server:Msg('/g_queryTree', nodeID, 1 ))
		--ThreadServerSend{'/g_queryTree', {nodeID, 1 }}
		QueueAction(time,{function() ThreadServerSend{'/g_queryTree', {nodeID, 1 }} end})
	end
	
	function parameterCtl.update(time, groupnodeID, synnodeID)
		local Q = require"sc.queryTree"
		time = time or 0.5

		local function update_controls()
			local function action2(syn)
				for k,ctl in pairs(parcontrols) do
					--print(syn.name,k,ctl.autogui.name,syn.mapped[k], syn.params[k] )
					ctl:val(syn.mapped[k] or syn.params[k],false )
				end
				if DOAUTOGUI then
					QueueAction(time,{update_controls})
				end
			end
			Q.querySynthValues(synnodeID, action2, groupnodeID)
		end
		--if DOAUTOGUI then
			update_controls()
		--end
	end
	--guiUpdate()
	return parameterCtl
end

