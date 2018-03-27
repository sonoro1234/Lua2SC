local socket = require("socket")

local SCTCP={}
local function ReceiveTCPLoop(host,port,host1,port1)
	local listenudp
	local lanes = require "lanes" --.configure()
    --[=[
    local file  = io.open([[C:\LUA\lua2sc\logsctcp.txt]],"w+")
    local function filelog(str)
        file:write("line\n")
        file:write(str)
        file:write("\nendline\n")
    end
    --]=]
	local function prstak(stk)
		local str=""
		for i,lev in ipairs(stk) do
			str= str..i..": \n"
			for k,v in pairs(lev) do
				str=str.."\t["..k.."]:"..v.."\n"
			end
		end
		prerror(str)
        io.write(str)
	end
	
	local function finalizer_func(err,stk)
		print("TCPSC: ReceiveLoop finalizer:")
		if err and type(err)~="userdata" then 
			prerror( "TCPSC: after error: "..tostring(err) )
			prerror("TCPSC: finalizer stack table")
			prstak(stk)
            io.write("TCPSC: after error: "..tostring(err))
		elseif type(err)=="userdata" then
			print( "TCPSC: after cancel " )
		else
			print( "TCPSC: after normal return" )
		end
		--[[
		local succes,e = pcall(listenudp.close,listenudp)
		if not succes then 
			print("TCPSC:error closing listenudp"..tostring(e))
		else
			print( "TCPSC: finalizer ended " )
		end
		--]]
        --io.close(file)
		print("closing listenudp",listenudp)
		listenudp:close()
		print"closed listenudp"
	end
	
	set_finalizer( finalizer_func ) 
	set_error_reporting("extended")
	set_debug_threadname("ReceiveUDPLoop")
	
	local socket = require("socket")
	require("osclua")
	toOSC=osclua.toOSC
	fromOSC=osclua.fromOSC

	local err 
	listenudp,err = socket.connect(host1,port1) --,host,port)
	if not listenudp then print("TCPSC: could not open listenudp:",err) end
    require"sc.number2string"
    local function sendtcp(msg)
		--io.write("sendtcp:"..msg.."\n")
        msg = int2str(#msg,4)..msg
        listenudp:send(msg)
    end
    local function receivetcp()
        local len,stat = listenudp:receive(4)
        if not len then return nil,stat end
        return listenudp:receive(str2int(len))
    end
	local function Detect()
		io.write("Detect\n")
        listenudp:settimeout(1)
		while true do
			print("Detect sending /status in loop")
            --sendtcp(toOSC({"/dumpOSC",{1}}))
			sendtcp(toOSC({"/status",{1}}))
			--print("sended /status in loop")
			local dgram,status = receivetcp()
			if dgram then -- detected
				local msg = fromOSC(dgram)
				print("TCPSC: Detected "..prOSC(msg))
				--io.write("TCPSC detected: "..prOSC(msg).."\n")
				sendtcp(toOSC({"/notify",{1}}))
				lanes.timer(udpsclinda, "wait", 0) --stop
				udpsclinda:receive(0, "wait" ) --clear
				lanes.timer(idlelinda,"statusSC",1,0)
				detected=true
				break
			elseif status=="closed" then -- closed, lets wait.
				print("TCPSC: closed ")
				lanes.timer( udpsclinda, "wait", 1, 0 )	--wait a second
				local key,val=udpsclinda:receive("wait") 
				print("TCPSC: ",key," ",val)
				detected=false
			else
				print("TCPSC: ",status) --may be timeout?
				lanes.timer( udpsclinda, "wait", 0) --stop
				udpsclinda:receive (0, "wait" ) --clear
			end	
		end
        listenudp:settimeout(0.01)
	end
--[[
	local success, msg = listenudp:setsockname(host, port) 
	if not success then error("TCPSC: "..tostring(msg))end
	
	local ok,err=listenudp:setpeername(host1, port1)
	if not ok then print("TCPSC: "..tostring(err)) return end
--]]
	local ip3, port3 = listenudp:getsockname()
    print("TCPSC: args ",host,port,host1,port1)
	--print("TCPSC: listenudp sends to:"..host.." port:"..port.." receives as ip:"..ip3.." port"..port3)
	listenudp:settimeout(0.01)
	local detected=false
	local Filters = {}
	while true do
		--io.write("SCTCP LOOP...\n")
		local dgram,status = receivetcp()
		-- if cancel_test() then
			-- io.stderr:write("required to cancel\n")
			-- break
		-- end
		local key,val = udpsclinda:receive(0,"sendsc","clearFilter","addFilter","Detect","exit")
		while val do
			if key == "addFilter" then
				--print("TCPSC: addFilter",val[1],val[2])
				Filters[val[1]] = Filters[val[1]] or {}
				Filters[val[1]][val[2]] = true
				if val[3] then val[3]:send("addFilterResponse",1) end --for block
			elseif key == "clearFilter" then
				--print("TCPSC: clearFilter",val)
				if Filters[val[1]]  then
					Filters[val[1]][val[2]] = nil
					if #Filters[val[1]] == 0 then
						Filters[val[1]] = nil
					end
				end
            elseif key == "sendsc" then
				--io.write("sendsc\n")
                sendtcp(val)
			elseif key == "Detect" then
				Detect()
            elseif key == "exit" then
                print("exit on udpsclinda")
				return true
			end
			key,val = udpsclinda:receive(0,"sendsc","addFilter","clearFilter","Detect","exit")
		end
		if dgram then
            ---[[
			local succ,msg = pcall(fromOSC,dgram)
            if not succ then 
                io.write(msg.."\n");io.write(dgram.."\n");io.write("status:"..tostring(status).."\n") 
                --filelog(dgram)
            end
            --]]
           -- local msg = fromOSC(dgram)
			--io.write("TCPSC: "..prOSC(msg).."\n")
			--print("SCTCP receives",msg[1])
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
				--print("TCPSC: "..prOSC(msg))
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
				--print("TCPSC: "..prOSC(msg))
			end
		elseif status == "closed" then --closed ?
			print("TCPSC: error: "..status..". did you boot SC?")
			--io.write("TCPSC: error: "..status..". did you boot SC?\n")
			--try to detect
			Detect()
		elseif status == "timeout" then
			--print("TCPSC: timeout ")
			if cancel_test() then
				print("TCPSC:required to cancel\n")
				return true
			end
		else --timeout
			prerror("TCPSC: ",status)
		end
	end
end	
function SCTCP:close()
	if SCTCP.tcp then SCTCP.tcp:close() end
	SCTCP.tcp = nil
	if SCTCP.ReceiveTCPLoop_lane then
        udpsclinda:send("exit",1)
		-- local cancelled,reason = SCTCP.ReceiveTCPLoop_lane:cancel(1)
		-- if cancelled then
			-- SCTCP.ReceiveTCPLoop_lane = nil
		-- else
			-- print("Unable to cancel ReceiveTCPLoop_lane",cancelled,reason)
		-- end
	end
end	
function SCTCP:init(settings,receivelinda)
	print("initudp SCTCP")
	SCTCP.host = "127.0.0.1"
	SCTCP.port = settings.SC_UDP_PORT
	--local hostt = socket.dns.toip(host)
	assert(SCTCP.tcp==nil,"tcp not closed")
	--SCTCP.tcp = socket.tcp()
	--assert(SCTCP.tcp,"could not create tcp socket")
	--local suc,err = SCTCP.tcp:connect(SCTCP.host, SCTCP.port)
    --if not suc then print("cant connect SCTCP",err); return false end
    while true do
        SCTCP.tcp,err = socket.connect(SCTCP.host, SCTCP.port)
        if SCTCP.tcp then SCTCP.tcp:close();SCTCP.tcp=nil; break end
        thread_print("SCTCP waiting for server")
        wait(1)
    end
	--if not SCTCP.tcp then print("TCPSC: could not open SCTCP.tcp:",err);return false end
	--local ip, port2 = SCTCP.tcp:getsockname()
	--SCTCP.tcp:settimeout(0)
	print("tcp sends to ip:"..SCTCP.host.." port:"..SCTCP.port)
	--print("tcp reveives as ip:"..tostring(ip).." port:"..tostring(port2))
	
	local tcp_lane_gen = lanes.gen("*",--"base,math,os,package,string,table",
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
		ReceiveTCPLoop)
    udpsclinda:set("exit") --delete previous exits
	SCTCP.ReceiveTCPLoop_lane = tcp_lane_gen(ip,port2,SCTCP.host,SCTCP.port)
	SCTCP.listen_ip = ip
	SCTCP.listen_port = port2
    return true
end
require"sc.number2string"
function SCTCP:send(msg)
    --msg = int2str(#msg,4)..msg
	--local suc,err = self.tcp:send(msg)
    --if not suc then print("error sending tcp",err) end
    udpsclinda:send("sendsc",msg)
end
function SCTCP:receive()
    error"dont use that"
    local len,stat = self.tcp:receive(4)
    if not len then return nil,stat end
    return self.tcp:receive(str2int(len))
end
return SCTCP