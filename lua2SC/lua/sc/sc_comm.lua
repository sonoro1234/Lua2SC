--- udp comunication
require("socket")
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
function sendBundle(msg,time)

	if time then
		local timestamp = OSCTime(time + SERVER_CLOCK_LATENCY)
		udp:send(toOSC({timestamp,msg}))
	else
		udp:send(toOSC(msg))
	end
end
function sendMultiBundle(time,msg)
		--print("send time",time)
	local timestamp = OSCTime(time + SERVER_CLOCK_LATENCY)
	table.insert(msg,1,timestamp)
    udp:send(toOSC(msg))
end
function sendBlocked(msg)
    udpB:send(toOSC(msg))
    local dgram = assert(udpB:receive(),"Not receiving from SCSYNTH\n")
    return fromOSC(dgram)
end
--------------------------------


-------------------------------------------------

function initudp()
	initblockudp()
	initsendudp()
	--initreceiveudp()
end
function initblockudp()
	print("initblockudp")
	local host = "127.0.0.1"
	local port = _run_options and _run_options.SC_UDP_PORT or 57110
	local hostt = socket.dns.toip(host)
	assert(udpB == nil,"udpB not closed")
	udpB = socket.udp()
	assert(udpB,"udpB es nulo")
	udpB:setpeername(host, port)
	local ip, port2 = udpB:getsockname()
	--udpB:settimeout(2)
	print("udpB sends to ip:"..host.." port:"..port)
	print("udpB reveives as ip:"..ip.." port:"..port2)
end
function initsendudp()
	print("initsendudp")
	local host = "127.0.0.1"
	local port = _run_options and _run_options.SC_UDP_PORT or 57110
	local hostt = socket.dns.toip(host)
	assert(udp==nil,"udp not closed")
	udp = socket.udp()
	assert(udp,"udp es nulo")
	udp:setpeername(host, port)
	local ip, port2 = udp:getsockname()
	--udp:settimeout(0)
	print("udp sends to ip:"..host.." port:"..port)
	print("udp reveives as ip:"..ip.." port:"..port2)
    --udpB=udp
	
end
function inittcp()
	print("initsendtcp")
	local host = "127.0.0.1"
	local port = _run_options and _run_options.SC_UDP_PORT or 57110
	local hostt = socket.dns.toip(host)
	assert(udp==nil,"tcp not closed")
	local tcp = socket.connect(host, port)
	assert(tcp,"tcp es nulo")
	local ip, port2 = tcp:getsockname()
	--udp:settimeout(0)
	print("tcp sends to ip:"..host.." port:"..port)
	print("tcp reveives as ip:"..ip.." port:"..port2)
	
	print("initblocktcp")
	local host = "127.0.0.1"
	local port = _run_options and _run_options.SC_UDP_PORT or 57110
	local hostt = socket.dns.toip(host)
	assert(udpB == nil,"tcpB not closed")
	local tcpB = socket.connect(host, port)
	tcpB:settimeout(4)
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
function testQuit(msg)
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

function prdgram(d)
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
--[[
function quitSC(block)
	val=val or 1
	if block==nil then block=false end
	local dgram=toOSC{"/quit",{}}
	if block then
		udpB:send(dgram)
		dgram = assert(udpB:receive(),"Not receiving from SCSYNTH\n")
		print("quit con block")
	else
		udp:send(dgram)
    end
	
end
function notifySC(val,block)
	val=val or 1
	if block==nil then block=false end
	if block then
		print("sending notify con block")
		udpB:send(toOSC({"/notify",{val}}))
		dgram = assert(udpB:receive(),"Not receiving from SCSYNTH\n")
		print("notify con block")
	else
		udp:send(toOSC({"/notify",{val}}))
    end
	
end
_SYNCED={}
function SyncSC(block)
	if block==nil then block=false end
	--print("cccccccc ",math.huge)
	local id = math.random(2^10)
	_SYNCED.id=id
	_SYNCED.isdone=false
	if block then
		udpB:send(toOSC({"/sync",{id}}))
		dgram = assert(udpB:receive(),"Not receiving from SCSYNTH\n")
		msg=fromOSC(dgram)
		print("/synced con block")
		assert(msg[2][1]==id)
		assert(msg[1]=="/synced")
	else
		udp:send(toOSC({"/sync",{id}}))
	end
end
function loadSynthDef(path,block)
	if block==nil then block=true end
	if block then
		udpB:send(toOSC({"/d_load",{path}}))
		dgram = assert(udpB:receive(),"Not receiving from SCSYNTH\n")
		msg=fromOSC(dgram)
		assert(msg[2][1]=="/d_load")
		assert(msg[1]=="/done")
		print(prOSC(msg))
	else
		udp:send(toOSC({"/d_load",{path}}))
    end
end
function Status(block)
	if block==nil then block=false end
	if block then
		udpB:send(toOSC({"/status",{1}}))
		dgram = assert(udpB:receive(),"Not receiving from SCSYNTH\n")
		printStatus(fromOSC(dgram))
	else
		udp:send(toOSC({"/status",{1}}))
    end
end
function dumpTree(on)
	on = on or 1
	udp:send(toOSC({"/g_dumpTree",{0,on}}))
end
--]]
function IDGenerator(ini)
	local index = ini or -1
	return function(inc)
		inc = inc or 1
		index = index + inc
		return index
	end
end
function initinternal()
	local t = {}
	function t:send(msg)
		mainlinda:send("sendsc",msg)
	end
	function t:close() end
	local tb = {}
	function tb:send(msg,done)--,path,templ)
		done = done or "/done"
		self.tmplinda = lanes.linda()
		OSCFunc.newfilter(done,"ALL",function(msg) print"sending to tmplinda";end,true,false,self.tmplinda)
		mainlinda:send("sendsc",msg)
	end
	function tb:close() end
	function tb:receive()
		local key,val = self.tmplinda:receive("OSCReceive")
		OSCFunc.handleOSCReceive(val)
		return toOSC(val)
	end
	return t,tb
end
GetNode=IDGenerator(1000)
GetBus=IDGenerator(8) --first after audio busses
--dumpOSC=0
function InitSCCOMM()
	print("InitSCCOMM")
	if sc_comm_type == "udp" then
		SERVER_CLOCK_LATENCY = 0.4
		initudp()
	elseif sc_comm_type == "internal" then
		SERVER_CLOCK_LATENCY = 0.07
		udp ,udpB = initinternal()
		print("SERVER_CLOCK_LATENCY",SERVER_CLOCK_LATENCY)
	elseif sc_comm_type == "tcp" then
		SERVER_CLOCK_LATENCY = 0.4
		udp ,udpB = inittcp()
	else
		udp ,udpB = {}, {}
		local msg = "not supported sc_comm_type:"..tostring(sc_comm_type).." Did you boot sc?"
		prerror(msg)
		error(msg)
		return
	end
	udp:send(toOSC{"/clearSched",{}})
	--udp:send(toOSC({"/dumpOSC",{dumpOSC}})) -- escribir scsynt lo que le llega
	udp:send(toOSC({"/g_freeAll",{0}}))
	udp:send(toOSC({"/g_deepFree",{0}}))
	udp:send(toOSC({"/error",{{"int32",1}}}))
	udp:send(toOSC({"/g_dumpTree",{0,1}}))
	table.insert(resetCbCallbacks,ResetUDP)
end
--table.insert(initCbCallbacks,InitUDP)
--table.insert(resetCbCallbacks,ResetUDP)
function ResetUDP()
	print("reset udps")
	local ret,err=udp:send(toOSC{"/clearSched",{}})
	if not ret then print(err) end
	--local ret,err=udp:send(toOSC({"/dumpOSC",{dumpOSC}}))
	--if not ret then print(err) end
	local ret,err=udp:send(toOSC({"/g_freeAll",{0}}))
	if not ret then print(err) end
	local ret,err=udp:send(toOSC({"/g_deepFree",{0}}))
	if not ret then print(err) end
	local ret,err=udp:send(toOSC({"/error",{{"int32",1}}}))
	if not ret then print(err) end
	local ret,err=udp:send(toOSC({"/g_dumpTree",{0,1}}))
	if not ret then print(err) end
	sendBlocked{"/sync",{1}}
	print("closing udps")
	udp:close()
	udpB:close()
	print("closed udps")
	--
	--udp2:close()
end

--table.insert(initCbCallbacks,InitUDP)
--InitUDP()


