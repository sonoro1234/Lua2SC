--- udp, tcp or internal comunication, blocked or not
local comm, commB
local socket = require("socket")
require("osclua")
require("sc.number2string")
toOSC=osclua.toOSC
fromOSC=osclua.fromOSC
-------------------------------------------------
--converts unix time in seconds to osc timetag time
function OSCTime(time)
	local fSECONDS_FROM_1900_to_1970 = 2208988800
	local kSecondsToOSCunits = 4294967296 -- pow(2,32)   2.328306436538696e-10
	return (time + fSECONDS_FROM_1900_to_1970)*kSecondsToOSCunits
end
--SERVER_CLOCK_LATENCY = 0.2
strdatalens ={}
function sendBundle(msg,time)
	local ret,err
	if time then
		local timestamp = OSCTime(time + SERVER_CLOCK_LATENCY)
		ret,err = comm:send(toOSC({timestamp,msg}))
	else
		ret,err = comm:send(toOSC(msg))
	end
	if not ret then print("sendBundle error:",err);error(err) end
end

function sendMultiBundle(time,msg)
	local timestamp = OSCTime(time + SERVER_CLOCK_LATENCY)
	table.insert(msg,1,timestamp)
	local dgram = toOSC(msg)
    local ret,err = comm:send(dgram)
	if not ret then
			print("sendMultiBundle error:",err);
			error(err)
	end
end
function sendBlocked(msg)
    local ret,err = commB:send(toOSC(msg))
	if not ret then print("sendBlocked error:",err);error(err) end
    local dgram,err2 = commB:receive()
	if not dgram then print(err2,"Not receiving from SCSYNTH\n");error(err2) end
    return fromOSC(dgram)
end

--receiving in socket after sendBundle
function receiveBundle()
	local dgram,err2 = comm:receive()
	if not dgram then print(err2,"Not receiving from SCSYNTH\n");error(err2) end
    return fromOSC(dgram)
end
--------------------------------


-------------------------------------------------

local function initblockudp()
	print("initblockudp")
	local host = "127.0.0.1"
	local port = _run_options and _run_options.SC_UDP_PORT or 57110
	local hostt = socket.dns.toip(host)
	assert(commB == nil,"udpB not closed")
	local udpB = socket.udp()
	assert(udpB,"udpB es nulo")
	udpB:setpeername(host, port)
	local ip, port2 = udpB:getsockname()
	--udpB:settimeout(2)
	print("udpB sends to ip:"..host.." port:"..port)
	print("udpB reveives as ip:"..ip.." port:"..port2)
	return udpB
end
local function initsendudp()
	print("initsendudp")
	local host = "127.0.0.1"
	local port = _run_options and _run_options.SC_UDP_PORT or 57110
	local hostt = socket.dns.toip(host)
	assert(comm==nil,"udp not closed")
	local udp = socket.udp()
	assert(udp,"udp es nulo")
	udp:setpeername(host, port)
	local ip, port2 = udp:getsockname()
	--udp:settimeout(0)
	print("udp sends to ip:"..host.." port:"..port)
	print("udp reveives as ip:"..ip.." port:"..port2)

	return udp
end

local function initudp()
	local udpB = initblockudp()
	local udp = initsendudp()
	return udp, udpB
end

local function inittcp()
	print("initsendtcp")
	local host = "127.0.0.1"
	local port = _run_options and _run_options.SC_UDP_PORT or 57110
	local hostt = socket.dns.toip(host)
	assert(comm==nil,"tcp not closed")
	local tcp = socket.connect(host, port)
	assert(tcp,"tcp es nulo")
	local ip, port2 = tcp:getsockname()
	tcp:settimeout(6)
	print("tcp sends to ip:"..host.." port:"..port)
	print("tcp reveives as ip:"..ip.." port:"..port2)
	
	print("initblocktcp")
	local host = "127.0.0.1"
	local port = _run_options and _run_options.SC_UDP_PORT or 57110
	local hostt = socket.dns.toip(host)
	assert(commB == nil,"tcpB not closed")
	local tcpB = socket.connect(host, port)
	tcpB:settimeout(6)
	assert(tcpB,"tcpB es nulo")
	local ip, port2 = tcpB:getsockname()
	--tcpB:settimeout(2)
	print("tcpB sends to ip:"..host.." port:"..port)
	print("tcpB reveives as ip:"..ip.." port:"..port2)
    
    local tcpT = {tcp=tcp}
    function tcpT:send(msg)
        msg = int2str(#msg,4)..msg
        return self.tcp:send(msg)
    end
    function tcpT:receive()
        local len,stat = self.tcp:receive(4)
        if not len then return nil,stat end
        return self.tcp:receive(str2int(len))
    end
    function tcpT:close()
        return self.tcp:close()
    end
    
    local tcpBT = {tcp=tcpB}
    function tcpBT:send(msg)
        msg = int2str(#msg,4)..msg
        return self.tcp:send(msg)
    end
    function tcpBT:receive()
        local len,stat = self.tcp:receive(4)
        if not len then return nil,stat end
        return self.tcp:receive(str2int(len))
    end
    function tcpBT:close()
        return self.tcp:close()
    end
	return tcpT,tcpBT
end

function printStatus(msg)
	print("/status.reply:")
	print("\t",msg[2][2]," unit generators.")
	print("\t",msg[2][3]," synths.")
	print("\t",msg[2][4]," groups.")
	print("\t",msg[2][5]," loaded synth definitions.")
	print("\t",msg[2][6]," average CPU usage for signal processing.")
	print("\t",msg[2][7]," peak percent CPU usage for signal processing.")
	print("\t",msg[2][8]," nominal sample rate.")
	print("\t",msg[2][9]," actual sample rate.")
end
function printDone(msg,who)
	if who then print(who) end
	if msg[1]=="/done" then
		print(msg[1],":",msg[2][1])
	elseif msg[1]=="/fail" then
		print(msg[1],":",msg[2][1]," ",msg[2][2])
	else
		prtable(msg)
		assert(false,"not fail nor done")
	end
end
local function testQuit(msg)
	return msg[2][1]=="/quit" and msg[1]=="/done"
end
function printN_Go(msg)
	print(msg[1])
	if msg[2][5]== 0 then
		print(" synth id:",msg[2][1])
	else
		print(" group:",msg[2][1])
		print(" head:",msg[2][6])
		print(" tail:",msg[2][6])
	end
	print(" parent:",msg[2][2])
	print(" previous:",msg[2][3])
	print(" next:",msg[2][4],"\n")
	
end

local function prdgram(d)
		local str = ""
		str = str .. "datagram:\n"

		for i=1,string.len(d) do 
			str = str .. string.format("%4s",string.sub(d,i,i))
			--str = str .. string.sub(d,i,i)
			if i%4==0 then
				str = str .. "\t"
				for j=i-3,i do
					str = str .. string.format(" %3u",string.byte(d,j,j))
				end
				str = str .. "\n"
			end
		end

		print(str)
end


function IDGenerator(ini)
	local index = ini or 0
	return function(inc)
		local ret_index = index
		inc = inc or 1
		index = index + inc
		return ret_index
	end
end
local function initinternal()
	local t = {}
	function t:send(msg)
		mainlinda:send("sendsc",msg)
		return true
	end
	function t:close() end
	local tb = {}
	function tb:send(msg)
		self.tmplinda = lanes.linda()
		OSCFunc.newfilter("/done","ALL",function(msg) print"/done sending to tmplinda";end,true,false,self.tmplinda)
		OSCFunc.newfilter("/synced","ALL",function(msg) print"/sync sending to tmplinda";end,true,false,self.tmplinda)
		mainlinda:send("sendsc",msg)
		return true
	end
	function tb:close() end
	function tb:receive()
		--print"tb internal receive wait linda"
		local key,val = self.tmplinda:receive(6,"OSCReceive")
		--print("tb internal received",key,val)
		--prtable(val)
		if val then OSCFunc.handleOSCReceive(val) end
		OSCFunc.clearfilters("/done","ALL")
		OSCFunc.clearfilters("/synced","ALL")
		return val and toOSC(val) or nil
	end
	return t,tb
end
GetNode=IDGenerator(1001)
GetBus=IDGenerator(16) --first after audio busses
GetBuffNum=IDGenerator()
function ThreadServerSend(msg)
	udpsclinda:send("sendsc",toOSC(msg))
end
function ThreadServerSendT(msg,time)
	--time = time or lanes.now_secs()
	local timestamp = time and OSCTime(time + SERVER_CLOCK_LATENCY) or 1
	table.insert(msg,1,timestamp)
	ThreadServerSend(msg)
end

--local UniqueID = IDGenerator(0)
--local syncedlinda = lanes.linda()
local s = require"sclua.Server".Server()
function Sync()
	--local id = UniqueID()
	s:sync()
--	OSCFunc.newfilter("/synced",id,function(msg) end,true,true,syncedlinda)
--	ThreadServerSendT{{"/sync",{id}}}
--	local key,val = syncedlinda:receive("OSCReceive") -- wait
--	OSCFunc.handleOSCReceive(val) -- clean responder
end
local function ResetUDP()
	print("reset udps")
	--sendBlocked{"/sync",{1}}
	Sync()
	--sendBundle{"/clearSched",{}}
	--local ret,err=udp:send(toOSC({"/dumpOSC",{dumpOSC}}))
	--if not ret then print(err) end
	sendBundle{"/g_freeAll",{0}}
	sendBundle({"/g_deepFree",{0}})
	sendBundle{"/error",{{"int32",1}}}
	sendBundle{"/g_dumpTree",{0,1}}
	--sendBlocked{"/sync",{1}}
	Sync()
	print("closing udps")
	if sc_comm_type == "tcp" then
		comm.tcp:shutdown()
		commB.tcp:shutdown()
	end
	comm:close()
	commB:close()
	print("closed udps")
end

function InitSCCOMM()
	print("InitSCCOMM")
	if sc_comm_type == "udp" then
		SERVER_CLOCK_LATENCY = 0.4
		comm ,commB = initudp()
	elseif sc_comm_type == "internal" then
		SERVER_CLOCK_LATENCY = 0.07
		comm ,commB = initinternal()
		function ThreadServerSend(msg)
			mainlinda:send("sendsc",toOSC(msg))
		end
	elseif sc_comm_type == "tcp" then
		SERVER_CLOCK_LATENCY = 0.2
		comm ,commB = inittcp()
	else
		comm ,commB = {}, {}
		local msg = "not supported sc_comm_type:"..tostring(sc_comm_type).." Did you boot sc?"
		prerror(msg)
		error(msg)
		return
	end
	print("SERVER_CLOCK_LATENCY",SERVER_CLOCK_LATENCY, sc_comm_type)
	comm:send(toOSC{"/clearSched",{}})
	--comm:send(toOSC({"/dumpOSC",{dumpOSC}})) -- escribir scsynt lo que le llega
	comm:send(toOSC({"/g_freeAll",{0}}))
	comm:send(toOSC({"/g_deepFree",{0}}))
	comm:send(toOSC({"/error",{{"int32",1}}}))
	comm:send(toOSC({"/g_dumpTree",{0,1}}))
	table.insert(resetCbCallbacks,ResetUDP)
end



