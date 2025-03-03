
local SCTCP={}
local function ReceiveTCPLoop(tcppars, numsccomm)
	local listentcp
	local trace = false
	local tracestatus = false
	local lanes = require "lanes" --.configure()
    --[=[ logging
    local file  = io.open([[C:\supercolliderrepos\build_Lua2SC\install\logsctcp.txt]],"w+")
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
        if file then io.close(file) end --logging
		if listentcp then
			print("closing listentcp",listentcp)
			listentcp:close()
			print("closed listentcp",listentcp)
		end
		print( "finalizer ok" )
	end
	
	set_finalizer( finalizer_func ) 
	set_error_reporting("extended")
	set_debug_threadname("ReceiveTCPLoop"..numsccomm)
	
	local socket = require("socket")
	require("osclua")
	local toOSC=osclua.toOSC
	local fromOSC=osclua.fromOSC

    require"sc.number2string"
    local function sendtcp(msg)
		if not listentcp then return end
        msg = int2str(#msg,4)..msg
        listentcp:send(msg)
    end
    local function receivetcp()
        local len,stat = listentcp:receive(4)
        if not len then return nil,stat end
        return listentcp:receive(str2int(len))
    end
	local function notify_and_done(val)
		print("notify_and_done called", val)
		sendtcp(toOSC({"/notify",{val}}))
		listentcp:settimeout(0.01)
		while true do
			local dgram,status = receivetcp()
			if dgram then
				local msg = fromOSC(dgram)
				if msg[1] == "/done" and msg[2][1] == "/notify" then
					print("notify_and_done msg done", msg[1])
					return
				elseif msg[1] == "/fail" and msg[2][1] == "/notify" then
					prerror("notify_and_done msg failed", msg[2][2])
				else
					print("notify_and_done msg", msg[1])
					return
				end
			elseif status ~= "timeout" then
				print("notify_and_done status", status)
			end
		end
	end
	local Filters = {}
	require"sc.utils"
	local function lindaloop(timeout)
		local key,val = udpsclinda:receive(timeout,"sendsc","clearFilter","addFilter","trace","exit")
		while val do
			if key == "addFilter" then
				Filters[val[1]] = Filters[val[1]] or {}
				Filters[val[1]][val[2]] = true
				if val[3] then val[3]:send("addFilterResponse",1) end --for block
			elseif key == "clearFilter" then
				if Filters[val[1]]  then
					Filters[val[1]][val[2]] = nil
					if #Filters[val[1]] == 0 then
						Filters[val[1]] = nil
					end
				end
            elseif key == "sendsc" then
                sendtcp(val)
			elseif key == "trace" then
                trace = val[1]
				tracestatus = val[2]
				prtable(Filters)
            elseif key == "exit" then
                print("exit on udpsclinda")
				return true
			end
			key,val = udpsclinda:receive(0,"sendsc","addFilter","clearFilter","exit")
		end
	end
	-----connect
	local err 
	while true do
        listentcp,err = socket.connect(tcppars.host,tcppars.port)
        if listentcp then 
			--sendtcp(toOSC({"/notify",{1}}))
			notify_and_done(1)
			lanes.timer(idlelinda,"statusSC",1,0)
			break 
		end
        print("SCTCP waiting for server",listentcp,err)
		if lindaloop(1) then return end
    end
	local ip3, port3 = listentcp:getsockname()
	print("TCPSC: listentcp sends to:"..tcppars.host.." port:"..tcppars.port.." receives as ip:"..ip3.." port"..port3)
	listentcp:settimeout(0.01)
	-----comm loop
	local olddgram = ""
	while true do
		local dgram,status = receivetcp()
		--if lindaloop(0) then print("send notify 0");sendtcp(toOSC({"/notify",{0}})); return end
		if lindaloop(0) then print("send notify 0");notify_and_done(0); return end
		if dgram then
			if #dgram%4~=0 then prerror("osc not 4 multiple");prerror(dgram) end
            --[[ for debugging tcp
			local succ,msg = pcall(fromOSC,dgram)
            if not succ then 
                prerror(msg);prerror("olddgram",olddgram,"len",#olddgram);
				prerror(dgram,"len",#dgram);prerror("status:",tostring(status)) 
                filelog("olddgram"..olddgram);filelog(dgram)
            end
            --]]
			-- normal version
            local msg = fromOSC(dgram)
			olddgram = dgram
			if trace then
				if msg[1]~="/status.reply" or tracestatus then
					print("TCPSC: "..prOSC(msg))
				end
			end
			if msg[1]=="/metronom" then
				scriptlinda:send("/metronom",msg[2])
			elseif msg[1]=="/vumeter" then
				scriptguilinda:send("/vumeter",msg[2])
			elseif msg[1]=="/status.reply" then
				idlelinda:send("/status.reply",msg[2])
			elseif msg[1] == "/fail" then
				scriptlinda:send("OSCReceive",msg)
			elseif Filters[msg[1]] then
				for onelinda,_ in pairs(Filters[msg[1]]) do
					onelinda:send("OSCReceive",msg)
				end
			elseif Filters.ALL then
				msg[1] = "ALL"
				for onelinda,_ in pairs(Filters.ALL) do
					onelinda:send("OSCReceive",msg)
				end
			--else --use OSCFunc.trace
				--print("TCPSC: "..prOSC(msg))
			end
		elseif status == "closed" then --closed ?
			print("TCPSC: error closed: "..status)
			return true
		elseif status == "timeout" then
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
		print"setting ReceiveTCPLoop_lane=nil"
        udpsclinda:send("exit",1)
		SCTCP.ReceiveTCPLoop_lane = nil
	end
end	
function SCTCP:init(settings,receivelinda, numsccomm)
	print("initudp SCTCP")
	local options = {}
	options.host = "127.0.0.1"
	options.port = settings.SC_UDP_PORT
	assert(SCTCP.tcp==nil,"tcp not closed")

	local tcp_lane_gen = lanes.gen("*",
		{
		--cancelstep=10000,
		required={},
		globals={print=thread_print,
				prerror=thread_error_print,
				prOSC=prOSC,
				idlelinda = idlelinda,
				udpsclinda = receivelinda,
				scriptguilinda = scriptguilinda,
				scriptlinda = scriptlinda
				},
		priority=0},
		ReceiveTCPLoop)
    udpsclinda:set("exit") --delete previous exits
	udpsclinda:set("sendsc") --delete previous sendsc
	SCTCP.ReceiveTCPLoop_lane = tcp_lane_gen(options,numsccomm)
    return true
end
require"sc.number2string"
function SCTCP:send(msg)
    udpsclinda:send("sendsc",msg)
end

return SCTCP