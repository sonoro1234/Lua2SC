require("socket")

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
		print("closing listenudp",listenudp)
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
	
	--local 
	listenudp = assert(socket.udp(),"UDPSC: could not open listenudp")
	
	local function Detect()
		while true do
			print("Detect sending /status in loop")
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
	end
	
	local success, msg = listenudp:setsockname(host, port) 
	if not success then error("UDPSC: "..tostring(msg))end
	
	local ok,err=listenudp:setpeername(host1, port1)
	if not ok then print("UDPSC: "..tostring(err)) return end
	
	local ip3, port3 = listenudp:getsockname()
    print("UDPSC: args ",host,port,host1,port1)
	print("UDPSC: listenudp sends to:"..host.." port:"..port.." receives as ip:"..ip3.." port"..port3)
	listenudp:settimeout(1)
	local detected=false
	local Filters = {}
	while true do
		--print("SCUDP LOOP...")
		local dgram,status = listenudp:receive()
		-- if cancel_test() then
			-- io.stderr:write("required to cancel\n")
			-- break
		-- end
		local key,val = udpsclinda:receive(0,"clearFilter","addFilter","Detect")
		while val do
			if key == "addFilter" then
				--print("UDPSC: addFilter",val[1],val[2])
				Filters[val[1]] = Filters[val[1]] or {}
				Filters[val[1]][val[2]] = true
				if val[3] then val[3]:send("addFilterResponse",1) end --for block
			elseif key == "clearFilter" then
				--print("UDPSC: clearFilter",val)
				if Filters[val[1]]  then
					Filters[val[1]][val[2]] = nil
					if #Filters[val[1]] == 0 then
						Filters[val[1]] = nil
					end
				end
			elseif key == "Detect" then
				Detect()
			end
			key,val = udpsclinda:receive(0,"addFilter","clearFilter","Detect")
		end
		if dgram then
			local msg = fromOSC(dgram)
			--print("UDPSC: "..prOSC(msg))
			--print("SCUDP receives",msg[1])
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
					--print("sending",msg[1],onelinda)
					onelinda:send("OSCReceive",msg)
				end
			--else
				--print("UDPSC: "..prOSC(msg))
			end
		elseif status == "closed" then --closed ?
			print("UDPSC: error: "..status..". did you boot SC?")
			--try to detect
			Detect()
		elseif status == "timeout" then
			--print("UDPSC: timeout ")
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
	if SCUDP.udp then SCUDP.udp:close() end
	SCUDP.udp = nil
	if SCUDP.ReceiveUDPLoop_lane then
		local cancelled,reason = SCUDP.ReceiveUDPLoop_lane:cancel(1)
		if cancelled then
			SCUDP.ReceiveUDPLoop_lane = nil
		else
			print("Unable to cancel ReceiveUDPLoop_lane",cancelled,reason)
		end
	end
end	
function SCUDP:init(settings,receivelinda)
	print("initudp SCUDP")
	SCUDP.host = "127.0.0.1"
	SCUDP.port = settings.SC_UDP_PORT
	--local hostt = socket.dns.toip(host)
	assert(SCUDP.udp==nil,"udp not closed")
	SCUDP.udp = socket.udp()
	assert(SCUDP.udp,"could not create udp socket")
	SCUDP.udp:setpeername(SCUDP.host, SCUDP.port)
	local ip, port2 = SCUDP.udp:getsockname()
	--SCUDP.udp:settimeout(0)
	print("udp sends to ip:"..SCUDP.host.." port:"..SCUDP.port)
	print("udp reveives as ip:"..tostring(ip).." port:"..tostring(port2))
	
	local udp_lane_gen = lanes.gen("*",--"base,math,os,package,string,table",
		{
		cancelstep=10000,
		required={},
		globals={print=thread_print,
				prerror=thread_error_print,
				prOSC=prOSC,
				idlelinda = idlelinda,
				udpsclinda = receivelinda,
				scriptguilinda = scriptguilinda
				},
		priority=0},
		ReceiveUDPLoop)
	SCUDP.ReceiveUDPLoop_lane = udp_lane_gen(ip,port2,SCUDP.host,SCUDP.port)
	SCUDP.listen_ip = ip
	SCUDP.listen_port = port2

end

function SCUDP:send(msg)
	self.udp:send(msg)
end
return SCUDP