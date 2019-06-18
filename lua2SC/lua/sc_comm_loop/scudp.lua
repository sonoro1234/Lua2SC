
local SCUDP={}
local function ReceiveTCPLoop(tcppars)
	local listenudp
	local trace = false
	local tracestatus = false
	local lanes = require "lanes" --.configure()
    --[=[ logging
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
		print("UDPSC: ReceiveLoop finalizer:")
		if err and type(err)~="userdata" then 
			prerror( "UDPSC: after error: "..tostring(err) )
			prerror("UDPSC: finalizer stack table")
			prstak(stk)
            io.write("UDPSC: after error: "..tostring(err))
		elseif type(err)=="userdata" then
			print( "UDPSC: after cancel " )
		else
			print( "UDPSC: after normal return" )
		end
        --io.close(file) --logging
		if listenudp then
			print("closing listenudp",listenudp)
			listenudp:close()
			print"closed listenudp"
		end
	end
	
	set_finalizer( finalizer_func ) 
	set_error_reporting("extended")
	set_debug_threadname("ReceiveUDPLoop")
	
	local socket = require("socket")
	require("osclua")
	local toOSC=osclua.toOSC
	local fromOSC=osclua.fromOSC

    require"sc.number2string"

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
                listenudp:send(val)
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
	listenudp = assert(socket.udp(),"UDPSC: could not open listenudp")
	listenudp:setpeername(tcppars.host,tcppars.port)
	local ip3, port3 =listenudp:getsockname()
	print("UDPSC: listenudp sends to:"..tcppars.host.." port:"..tcppars.port.." receives as ip:"..ip3.." port"..port3)
	listenudp:settimeout(0.01)
	
	while true do
		listenudp:send(toOSC({"/status",{1}}))
        local dgram,status = listenudp:receive()
        if dgram then 
			print("SCUDP: connected")
			listenudp:send(toOSC({"/notify",{1}}))
			lanes.timer(idlelinda,"statusSC",1,0)
			break 
		end
        print("SCUDP waiting for server")
		if lindaloop(1) then return end
    end

	listenudp:settimeout(0.01)
	-----comm loop
	while true do
		local dgram,status = listenudp:receive()
		if lindaloop(0) then return end
		if dgram then
            --[[ for debugging tcp
			local succ,msg = pcall(fromOSC,dgram)
            if not succ then 
                io.write(msg.."\n");io.write(dgram.."\n");io.write("status:"..tostring(status).."\n") 
                --filelog(dgram)
            end
            --]]
			-- normal version
            local msg = fromOSC(dgram)
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
			else
				--print("UDPSC: "..prOSC(msg))
			end
		elseif status == "closed" then --closed ?
			print("UDPSC: error: "..status)
			return true
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
	if SCUDP.tcp then SCUDP.tcp:close() end
	SCUDP.tcp = nil
	if SCUDP.ReceiveTCPLoop_lane then
        udpsclinda:send("exit",1)
	end
end	
function SCUDP:init(settings,receivelinda)
	print("initudp SCUDP")
	local options = {}
	options.host = "127.0.0.1"
	options.port = settings.SC_UDP_PORT
	assert(SCUDP.tcp==nil,"tcp not closed")

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
	SCUDP.ReceiveTCPLoop_lane = tcp_lane_gen(options)
    return true
end
require"sc.number2string"
function SCUDP:send(msg)
    udpsclinda:send("sendsc",msg)
end

return SCUDP