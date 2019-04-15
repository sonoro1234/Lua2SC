require("sc.synthdefSCRead")

function openSynthdefGuiA(synthfile,panel,params,notified,dontusedefaults,usetext)
	return openSynthdefGuiB(SynthDefs_path..synthfile..".scsyndef",panel,params,notified,dontusedefaults,usetext)
end
function openSynthdefGui(fx,panel,dontusedefaults,usetext,minrows)
	return openSynthdefGuiB(SynthDefs_path..fx.name..".scsyndef",panel,fx.params,fx,dontusedefaults,usetext,minrows)
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
function openSynthdefGuiB(synthfile,panelC,params,notified,dontusedefaults,usetext,minrows)
	--print("openSynthdefGuiB")
	
	--addPanel{type="vbox",name=synthfile,parent=panelC}
	minrows=minrows or 3
	local panel=addPanel{type="gridbag",parent=panelC}
	if dontusedefaults==nil then dontusedefaults=true end

	local parameterCtl={}
	syntdef=readSCSynthFile(synthfile)
	parameterCtl.syntdef=syntdef
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
				if defval > 0 then
					--maxval=(defval <=1) and 1 or defval*2
					maxval= defval * 4
					minval=0
				elseif defval==0 then
					maxval = 1
					minval = -1
				else
					--probably db
					maxval = -defval * 6
					minval = defval * 6
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
							cont:val(tonumber(str)) --there is no loop: tecont uses str
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
	--guiUpdate()
	return parameterCtl
end

