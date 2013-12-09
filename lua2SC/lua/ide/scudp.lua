-----------------------------------------------------------
OSCFuncLinda = idlelinda
OSCFunc={filters={}}
function OSCFunc.newfilter(path,template,func,runonce)
	OSCFunc.filters[path] = OSCFunc.filters[path] or {} 
	OSCFunc.filters[path][#OSCFunc.filters[path]+1] ={template=template,func=func,runonce=runonce}
	udpsclinda:send("addFilter",{path,OSCFuncLinda})
end
function OSCFunc.clearfilters(path,template)
	print("OSCFunc.clearfilters ",path," ",template)
	udpsclinda:send("clearFilter",{path,OSCFuncLinda})
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

local SCUDP={}
local function ReceiveUDPLoop(host,port,host1,port1)
	local lanes = require "lanes" --.configure()
	local function prstak(stk)
		local str=""
		for i,lev in ipairs(stk) do
			str= str..i..": \n"
			for k,v in pairs(lev) do
				str=str.."\t["..k.."]:"..v.."\n"
			end
		end
		prerror(str)
	end
	
	local function finalizer_func(err,stk)
		print("UDPSC: ReceiveLoop finalizer:")
		if err and type(err)~="userdata" then 
			prerror( "UDPSC: after error: "..tostring(err) )
			prerror("UDPSC: finalizer stack table")
			prstak(stk)
		elseif type(err)=="userdata" then
			print( "UDPSC: after cancel " )
		else
			print( "UDPSC: after normal return" )
		end
		--[[
		local succes,e = pcall(listenudp.close,listenudp)
		if not succes then 
			print("UDPSC:error closing listenudp"..tostring(e))
		else
			print( "UDPSC: finalizer ended " )
		end
		--]]
		print"closing listenudp"
		listenudp:close()
		print"closed listenudp"
	end
	
	set_finalizer( finalizer_func ) 
	set_error_reporting("extended")
	set_debug_threadname("ReceiveUDPLoop")
	
	require("socket")
	require("osclua")
	toOSC=osclua.toOSC
	fromOSC=osclua.fromOSC
	
	local listenudp = assert(socket.udp(),"UDPSC: could not open listenudp")
	local success, msg = listenudp:setsockname(host, port) 
	if not success then error("UDPSC: "..tostring(msg))end
	
	local ok,err=listenudp:setpeername(host1, port1)
	if not ok then print("UDPSC: "..tostring(err)) return end
	
	local ip3, port3 = listenudp:getsockname()
	print("UDPSC: listenudp receives as ip:"..ip3.." port"..port3)
	listenudp:settimeout(1)
	local detected=false
	local Filters = {}
	while true do
		local dgram,status = listenudp:receive()
		-- if cancel_test() then
			-- io.stderr:write("required to cancel\n")
			-- break
		-- end
		local key,val = udpsclinda:receive(0,"clearFilter","addFilter")
		while val do
			if key == "addFilter" then
				--print("UDPSC: addFilter",val[1])
				Filters[val[1]] = Filters[val[1]] or {}
				Filters[val[1]][val[2]] = true
			elseif key == "clearFilter" then
				print("UDPSC: clearFilter",val)
				if Filters[val[1]]  then
					Filters[val[1]][val[2]] = nil
					if #Filters[val[1]] == 0 then
						Filters[val[1]] = nil
					end
				end
			end
			key,val = udpsclinda:receive(0,"addFilter","clearFilter")
		end
		if dgram then
			local msg = fromOSC(dgram)
			if msg[1]=="/metronom" then
				--prtable(msg)
				--setMetronom(msg[2][2],msg[2][3])
				scriptlinda:send("/metronom",msg[2])
			elseif msg[1]=="/vumeter" then
				--setVumeter(msg[2])
				scriptguilinda:send("/vumeter",msg[2])
			--elseif msg[1]=="/b_setn" then
				--setVumeter(msg[2])
				--scriptguilinda:send("/b_setn",msg[2])
			elseif msg[1]=="/status.reply" then
				idlelinda:send("/status.reply",msg[2])
				--print("UDPSC: "..prOSC(msg))
			--elseif msg[1]=="/n_go" or msg[1]=="/n_end" or msg[1]=="/n_on" or msg[1]=="/n_off" or msg[1]=="/n_move" or msg[1]=="/n_info" then
				--printN_Go(msg)
			elseif msg[1] == "/fail" then
				idlelinda:send("OSCReceive",msg)
			elseif Filters[msg[1]] then
				for onelinda,_ in pairs(Filters[msg[1]]) do
					onelinda:send("OSCReceive",msg)
				end
			--else
			--	print("UDPSC: "..prOSC(msg))
			end
		elseif status == "closed" then --closed ?
			print("UDPSC: error: "..status..". did you boot SC?")
			--try to detect
			while true do
				print("sending /status in loop")
				listenudp:send(toOSC({"/status",{1}}))
				print("sended /status in loop")
				local dgram,status = listenudp:receive()
				if dgram then -- detected
					local msg = fromOSC(dgram)
					print("UDPSC: "..prOSC(msg))
					listenudp:send(toOSC({"/notify",{1}}))
					lanes.timer(udpsclinda, "wait", 0) --stop
					udpsclinda:receive(0, "wait" ) --clear
					detected=true
					break
				elseif status=="closed" then -- closed, lets wait.
					print("UDPSC: closed ")
					lanes.timer( udpsclinda, "wait", 1, 0 )	--wait a second
					local key,val=udpsclinda:receive("wait") 
					print("UDPSC: ",key," ",val)
					detected=false
				else
					print("UDPSC: ",status) --may be timeout?
					lanes.timer( udpsclinda, "wait", 0) --stop
					udpsclinda:receive (0, "wait" ) --clear
				end	
			end
		elseif status == "timeout" then
			if cancel_test() then
				print("UDPSC:required to cancel\n")
				return true
			end
		else --timeout
			prerror("UDPSC: ",status)
		end
	end
end	
function SCUDP:close()
	SCUDP.udp:close()
	if SCUDP.ReceiveUDPLoop_lane then
		local cancelled,reason = SCUDP.ReceiveUDPLoop_lane:cancel(1)
		if cancelled then
			SCUDP.ReceiveUDPLoop_lane = nil
		else
			print("Unable to cancel ReceiveUDPLoop_lane",cancelled,reason)
		end
	end
end	
function SCUDP:init()
	print("initudp SCUDP")
	SCUDP.host = "127.0.0.1"
	SCUDP.port = Settings.options.SC_UDP_PORT
	--local hostt = socket.dns.toip(host)
	assert(SCUDP.udp==nil,"udp not closed")
	SCUDP.udp = socket.udp()
	assert(SCUDP.udp,"could not create udp socket")
	SCUDP.udp:setpeername(SCUDP.host, SCUDP.port)
	local ip, port2 = SCUDP.udp:getsockname()
	--SCUDP.udp:settimeout(0)
	print("udp sends to ip:"..SCUDP.host.." port:"..SCUDP.port)
	print("udp reveives as ip:"..tostring(ip).." port:"..tostring(port2))
	
	local udp_lane_gen=lanes.gen("*",--"base,math,os,package,string,table",
		{
		cancelstep=10000,
		required={},
		globals={print=thread_print,
				prerror=thread_error_print,
				prOSC=prOSC,
				idlelinda = idlelinda,
				udpsclinda = udpsclinda,
				scriptguilinda = scriptguilinda
				},
		priority=0},
		ReceiveUDPLoop)
	SCUDP.ReceiveUDPLoop_lane=udp_lane_gen(ip,port2,SCUDP.host,SCUDP.port)
	SCUDP.listen_ip=ip
	SCUDP.listen_port=port2
	--SCUDP.udp:send(toOSC({"/notify",{1}}))
end
function SCUDP:dumpTree(withvalues)
	withvalues=withvalues or true
	local p= withvalues and 1 or 0
	SCUDP.udp:send(toOSC({"/g_dumpTree",{0,p}}))
end
function SCUDP:quit()
	while idlelinda:receive(0,"statusSC") do end
	lanes.timer(idlelinda,"statusSC",0)
	idlelinda:receive(0,"statusSC")
	SCUDP.udp:send(toOSC({"/quit",{}}))
end
function SCUDP:dumpOSC(doit)
	--if doit==nil then doit=SCUDP.dumpOSCval end
	local val= doit and 1 or 0
	print("dumpOSC",val)
	SCUDP.udp:send(toOSC({"/dumpOSC",{val}}))
end
function SCUDP:status()
	--thread_print("sending /status")
	SCUDP.udp:send(toOSC({"/status",{1}}))
end
function SCUDP:sync(id)
	--SCUDP.udp:settimeout(5)
	-- SCUDP.udp:send(toOSC({"/notify",{1}}))
	-- local dgram,status  = SCUDP.udp:receive()
	-- if not dgram then
		-- print("Error on notify: ",status)
	-- end
	--thread_print("sending /sync")
	SCUDP.udp:send(toOSC({"/sync",{id or 1}}))
end
return SCUDP