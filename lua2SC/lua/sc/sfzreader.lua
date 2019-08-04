local M = {}

local known_opcodes = {hikey=0,lokey=0,hivel=0,lovel=0,key=0,group=0,pan=0,pitch_keycenter=0,tune=0,sample=0,volume=0,loop_start=0,loop_end=0,offset=0,pitch_random=0,xfin_hikey=0,xfin_hivel=0,xfin_lokey=0,xfin_lovel=0,xfout_hikey=0,xfout_hivel=0,xfout_lokey=0,xfout_lovel=0,seq_length=0,seq_position=0,transpose=0,default_path=0,hirand=0,lorand=0}
M.known_opcodes = known_opcodes

local xf_opcodes = {xfin_hikey=0,xfin_hivel=0,xfin_lokey=0,xfin_lovel=0,xfout_hikey=0,xfout_hivel=0,xfout_lokey=0,xfout_lovel=0}

local key_opcodes = {xfin_hikey=0, xfin_lokey=0, xfout_hikey=0, xfout_lokey=0,lokey=0,hikey=0,key=0,pitch_keycenter=0}

local ampeg_def = {ampeg_start=0,ampeg_sustain=100,ampeg_delay=0,ampeg_attack=0,ampeg_hold=0,ampeg_decay=0,ampeg_release=0.1,ampeg_vel2delay=0,ampeg_vel2attack=0,ampeg_vel2hold=0,ampeg_vel2decay=0,ampeg_vel2sustain=0,ampeg_vel2release=0}

for k,v in pairs(ampeg_def) do known_opcodes[k]=v end
for k,v in pairs(xf_opcodes) do known_opcodes[k]=v end

local function getSFZdata(sfz,nota,amp)
	nota = math.floor(nota+0.5)
	if sfz.dump then print(nota,amp,amp*127) end
	if not sfz.keyboard[nota] then prtable(sfz.keyboard) end
	local vel = amp*127
	local rand = math.random()
	local regs = sfz.keyboard[nota]
	if not regs then return nil end
	local good_regs = {}
	for i,r in ipairs(regs) do
		local reg = sfz.regions[r.region]
		if reg.lovel<=vel and (reg.hivel+1)>vel and reg.lorand<=rand and reg.hirand>rand then
			if reg.xfin_lovel and vel <= reg.xfin_lovel then goto CONTINUE end
			if reg.xfout_hivel and vel >= reg.xfout_hivel then goto CONTINUE end
			--now seq
			if reg.seq_length then
				sfz.seq_counters[r.region] = sfz.seq_counters[r.region] or 1
				if sfz.seq_counters[r.region] == reg.seq_position then
					table.insert(good_regs,r)
				end
				sfz.seq_counters[r.region] = sfz.seq_counters[r.region] + 1
				if sfz.seq_counters[r.region] > reg.seq_length then
					sfz.seq_counters[r.region] = 1
				end
			else
				table.insert(good_regs,r)
			end
		end
		::CONTINUE::
	end
    assert(#good_regs>0)
	return good_regs
end
local min,max = math.min,math.max
local function clip01(x)
	return min(1,max(0,x))
end

local sqrt = math.sqrt
local function EqPower(x,l,h)
	return sqrt(clip01((x-l)/(h-l)))
end

local function CalcXF(reg,note,amp)
	local vel = amp*127
	local xfv = 1
	if reg.xfin_lovel then
		xfv = EqPower(vel, reg.xfin_lovel, reg.xfin_hivel)
	end
	if reg.xfout_lovel then
		xfv = EqPower(vel, reg.xfout_hivel, reg.xfout_lovel)*xfv
	end
	local xfn = 1
	if reg.xfin_lokey then
		xfn = EqPower(note, reg.xfin_lokey, reg.xfin_hikey)
	end
	if reg.xfout_lokey then
		xfn = EqPower(note, reg.xfout_hikey, reg.xfout_lokey)*xfn
	end
	return xfv*xfn
end
local function getParams(sfz,nota,amp)
	amp = math.min(1,amp)
	local allparams = {}
	local dat = sfz:getSFZdata(nota,amp)
	if not dat or #dat==0 then 
		return nil 
	end
	if sfz.dump then 
		print("good regs",#dat)
		for i=1,#dat do
			local tdat = dat[i]
			local reg = sfz.regions[tdat.region]
			print(reg.sample,tdat.detune,numberToNote(nota))
		end
	end

	for i=1,#dat do
		local dati = dat[i]
		local params = {}
		local ri = dati.region
		local reg = sfz.regions[ri]
		local buffer = sfz.buffers[reg.bufindex]
		--local buffer = allbuffers[reg.bufindex]

		params.bufnum = buffer.bufnum
		if reg.loop_start then --looped
			params.stloop = reg.loop_start
			params.endloop = reg.loop_end
	
			if buffer.channels == 1 then
				params.inst = "sfzloopbuf1"
			else
				params.inst = "sfzloopbuf2"
			end
	
		else
			if buffer.channels == 1 then
				params.inst = "sfzplayer1"
			else
				params.inst = "sfzplayer2"
			end
		end
		params.rate = midi2ratio(dati.detune + (reg.tune and reg.tune*0.01 or 0) + (reg.transpose or 0) 
		+ (reg.pitch_random and reg.pitch_random*(math.random()*2-1)*0.01 or 0))
		params.volume = reg.volume or 0
		params.xf = CalcXF(reg,nota,amp)
		params.gate = 1
		params.amp = amp
		params.offset = reg.offset or 0
		params.pan = reg.pan and reg.pan/100 or 0
		--ampeg
		for op,val in pairs(ampeg_def) do
			params[op] = reg[op]
		end
		if params.xf > 0 then
			table.insert(allparams,params)
		else
			prtable(reg)
		end
	end
	return allparams
end
local function append(t1,t2)
	for k,v in pairs(t2) do
		if t1[k] then
			if type(t1[k])=="table" then
				table.insert(t1[k],v)
			else
				t1[k] = {t1[k],v}
			end
		else
			t1[k] = v
		end
	end
end
function M.make_player(sfz)
	return FS(function(e) 
		local nota = e.tmplist.note
		local scale = e.tmplist.escale[1]
		if not nota then
			local degree = e.tmplist.degree
			if type(degree)~="table" then degree = {degree} end
			nota = {}
			for i,v in ipairs(degree) do
				nota[i] = getNote(v,scale)
			end
		elseif type(nota)~="table" then 
			nota = {nota}
		end
		local amp = e.tmplist.amp
		local params = {}
		for i,v in ipairs(nota) do
			local pars = getParams(sfz,v,amp)
			if not pars then
				print("note:",v,"out of range for sfz player:",sfz.inst,amp)
				print("range:",sfz.minkey,sfz.maxkey)
				error"out of range"
			end
			for ii=1,#pars do
				append(params,pars[ii])
			end
		end
		return params
	end,-1)
end
function M.free_buffers(sfz)
	local s = require"sclua.Server".Server()
	for i,buf in ipairs(sfz.buffers) do
		buf:free()
	end
end

local bufbyname = {}
local allbuffers = {}
function M.load_buffers(sfz)
	-------load buffers get wav info
	local s = require"sclua.Server".Server()
	local sndfile = require"sndfile_ffi"
	local ffi = require"ffi"
	
	for i,r in ipairs(sfz.regions) do

		local default_path = sfz.control and sfz.control.default_path or ""
		local path = sfz.folder.."/"..default_path..r.sample
		
		if not (r.loop_start or r.loop_end) then
			--get loop info
			local sf = sndfile.Sndfile(path)
			print("sf load",path,sf:channels(),sf:frames(),sf:samplerate(),sf:format())
			local inst = ffi.new"SF_INSTRUMENT[1]"
			local instret = sndfile.sf_command (sf.sf, sndfile.SFC_GET_INSTRUMENT, inst, ffi.sizeof(inst[0])) ;
			if instret==sndfile.SF_TRUE and inst[0].loop_count > 0 then
				r.loop_start = r.loop_start or inst[0].loops[0].start
				r.loop_end = r.loop_end or inst[0].loops[0]["end"]
			end
			sf:close()
		end
		if not bufbyname[path] then
			local buf = s.Buffer()
			buf:allocRead(path,0,-1)
			table.insert(allbuffers, buf)
			r.bufindex = #allbuffers
			bufbyname[path] = r.bufindex
		else --alredy have this sample
			r.bufindex = bufbyname[path]
		end
	end
	sfz.buffers = allbuffers
	if not (sfz.options.dontsync or USING_LILYPOND) then
		s:sync()
		--assert(buffers[1].channels)
	end
end
--------------------
function M.compile_synthdefs()
local function AEG(t)
	for op,val in pairs(ampeg_def) do
		t[op]=val
	end
	return t
end

local function ampeg(amp,ampeg_start,ampeg_sustain,ampeg_delay,ampeg_attack,ampeg_hold,ampeg_decay,ampeg_release,ampeg_vel2delay,ampeg_vel2attack,ampeg_vel2hold,ampeg_vel2decay,ampeg_vel2sustain, ampeg_vel2release)
	return Env({0,0,ampeg_start,1,1,(ampeg_sustain+ampeg_vel2sustain*amp)*0.01,0},
			{ampeg_delay+ampeg_vel2delay*amp, 0, ampeg_attack+ampeg_vel2attack*amp, ampeg_hold+ampeg_vel2hold*amp, ampeg_decay+ampeg_vel2decay*amp, ampeg_release + ampeg_vel2release*amp},nil,
			5)
end

SynthDef("sfzloopbuf2",AEG{out=0,bufnum=-1,gate=0,rate=1,offset=0,stloop=0,endloop=0,amp=1,volume=0,xf=1},
function()
	local ampeg_vars = {amp,ampeg_start,ampeg_sustain,ampeg_delay,ampeg_attack,ampeg_hold,ampeg_decay,ampeg_release,ampeg_vel2delay,ampeg_vel2attack,ampeg_vel2hold,ampeg_vel2decay,ampeg_vel2sustain, ampeg_vel2release}
	local env = EnvGen.ar{ampeg(unpack(ampeg_vars)), gate, doneAction= 2}
	local sig = LoopBuf.ar(2,bufnum,BufRateScale.kr(bufnum)*rate,1,offset,stloop,endloop)*env*amp*volume:dbamp()*xf
	Out.ar(out,sig)
end):store(true)

SynthDef("sfzloopbuf1",AEG{out=0,bufnum=-1,gate=0,rate=1,offset=0,stloop=0,endloop=0,amp=1,volume=0,pan=0,xf=1},function()
	local ampeg_vars = {amp,ampeg_start,ampeg_sustain,ampeg_delay,ampeg_attack,ampeg_hold,ampeg_decay,ampeg_release,ampeg_vel2delay,ampeg_vel2attack,ampeg_vel2hold,ampeg_vel2decay,ampeg_vel2sustain, ampeg_vel2release}
	local env = EnvGen.ar{ampeg(unpack(ampeg_vars)), gate, doneAction= 2}
	local sig = LoopBuf.ar(1,bufnum,BufRateScale.kr(bufnum)*rate,1,offset,stloop,endloop)*env*amp*volume:dbamp()*xf
	Out.ar(out,Pan2.ar(sig,pan))
end):store(true)

SynthDef("sfzplayer2",AEG{out=0,bufnum=-1,gate=0,rate=1,amp=1,volume=0,offset=0,xf=1},function()
	local ampeg_vars = {amp,ampeg_start,ampeg_sustain,ampeg_delay,ampeg_attack,ampeg_hold,ampeg_decay,ampeg_release,ampeg_vel2delay,ampeg_vel2attack,ampeg_vel2hold,ampeg_vel2decay,ampeg_vel2sustain, ampeg_vel2release}
	local env = EnvGen.ar{ampeg(unpack(ampeg_vars)), gate, doneAction= 2}
	local sig = PlayBuf.ar(2,bufnum,BufRateScale.kr(bufnum)*rate,1,offset,0,0)*env*amp*volume:dbamp()*xf
	Out.ar(out,sig)
end):store(true)

SynthDef("sfzplayer1",AEG{out=0,bufnum=-1,gate=0,rate=1,amp=1,volume=0,pan=0,offset=0,xf=1},function()
	local ampeg_vars = {amp,ampeg_start,ampeg_sustain,ampeg_delay,ampeg_attack,ampeg_hold,ampeg_decay,ampeg_release,ampeg_vel2delay,ampeg_vel2attack,ampeg_vel2hold,ampeg_vel2decay,ampeg_vel2sustain, ampeg_vel2release}
	local env = EnvGen.ar{ampeg(unpack(ampeg_vars)), gate, doneAction= 2}
	local sig = PlayBuf.ar(1,bufnum,BufRateScale.kr(bufnum)*rate,1,offset,0,0)*env*amp*volume:dbamp()*xf
	Out.ar(out,Pan2.ar(sig,pan))
end):store(true)

end

--utility for giving notes as numbers
local function keynote(note)
		local tonum = tonumber(note)
		if tonum then 
			return tonum
		else
			assert(type(note)=="string")
			return noteToNumber(note)
		end
	end
------------------------
-- given the sfz file path returns sfz object
function M.read(fpath,options)
	local path = require"sc.path"
	local folder,inst = path.splitpath(fpath)

	local lines = {}
	for line in io.lines(folder.."/"..inst) do
		line = line:gsub("%s*//[^\n]*","")
		if #line > 0 then table.insert(lines,line) end
	end
	local cont = table.concat(lines,"\n")
	
	local sfz = {regions={},headers={},groups = {},inst=inst,folder=folder,options=options or {}}
	--get headers
	for w in cont:gmatch("(<[^<>]+>[^<>]+)") do
		--clean comments
		--w = w:gsub("//[^\n]+","")
		--clean empty lines
		--w = w:gsub("")
		table.insert(sfz.headers,w)
	end
	local all_opcodes = {}
	sfz.all_opcodes = all_opcodes
	local function getopcodes(v)
		local r = {}
		--opcodes that allow spaces
		local k,va = v:match("(sample)=([^\n\r]+)")
		if k then 
			va = va:gsub("([^%s]+=[^%s]+)","") --clean other opcodes
			va = va:gsub("\\","/")
			r[k]=va 
		end
		local k,va = v:match("(default_path)=([^\n\r]+)")
		if k then 
			va = va:gsub("([^%s]+=[^%s]+)","") --clean other opcodes
			va = va:gsub("\\","/")
			r[k]=va 
		end
		--others
		for k,va in v:gmatch"([^%s=]+)=([^%s=]+)" do
			if not r[k] then
				local val = tonumber(va)
				r[k] = val or va
			end
		end
		-- opcodes inventary
		for k,v in pairs(r) do
			all_opcodes[k] = true
		end
		--key opcodes to number
		for k,v in pairs(key_opcodes) do
			if r[k] then r[k]=keynote(r[k]) end
		end
		return r
	end
	--get regions,control,group
	for i,v in ipairs(sfz.headers) do
		if v:match"<region>" then
			local r = getopcodes(v)
			r.group = #sfz.groups
			table.insert(sfz.regions,r)
		elseif v:match"<control>" then
			local r = getopcodes(v)
			assert(not sfz.control)
			sfz.control = r
		elseif v:match"<group>" then
			local r = getopcodes(v)
			table.insert(sfz.groups,r)
		elseif v:match"<global>" then
			local r = getopcodes(v)
			assert(not sfz.global)
			sfz.global = r
		else
			prerror"unknown header"
			prerror(v:match"(<[^<>]+>)")
			error"unknown header"
		end
	end
	--copy group and global to regions and add defaults
	for i,r in ipairs(sfz.regions) do
		local g = sfz.groups[r.group]
		if g then
			for k,v in pairs(g) do
				r[k]=v
			end
		end
		--global
		if sfz.global then
			for k,v in pairs(sfz.global) do
				r[k]= r[k] or v
			end
		end
		--defaults
		r.lovel = r.lovel or 0
		r.hivel = r.hivel or 127
		r.lorand = r.lorand or 0
		r.hirand = r.hirand or 1
		if r.key then
			r.lokey = r.lokey or r.key
			r.hikey = r.hikey or r.key
			r.pitch_keycenter = r.key
		end
		for op,val in pairs(ampeg_def) do
			r[op] = r[op] or val
		end
		if not r.pitch_keycenter then 
			--print"not pitch_keycenter";prtable(r);
			assert(r.lokey<=60 and r.hikey>=60)
			r.pitch_keycenter=60 
		end
	end
	-- find keyboard
	sfz.keyboard = {}
	--get max and min midi
	local minmidi = math.huge
	local maxmidi = -math.huge
	for i,r in ipairs(sfz.regions) do
		if minmidi > r.lokey then
			minmidi= r.lokey
		end
		if maxmidi < r.hikey then
			maxmidi = r.hikey
		end
	end
	local minmidi_r,maxmidi_r = {},{}
	for i,r in ipairs(sfz.regions) do
		if minmidi == r.lokey then
			table.insert(minmidi_r,i)
		end
		if maxmidi == r.hikey then
			table.insert(maxmidi_r,i)
		end
	end
	--sfz.keyboard.maxmidi = maxmidi
	--sfz.keyboard.minmidi = minmidi
	sfz.minkey, sfz.maxkey = minmidi,maxmidi

	for n=noteToNumber"c1",noteToNumber"c8" do
		for i,r in ipairs(sfz.regions) do
			if n >= r.lokey and n <= r.hikey then
				if not (r.xfout_hikey and (r.xfout_hikey <= n)) then
					if not (r.xfin_lokey and (r.xfin_lokey >= n)) then
						sfz.keyboard[n] = sfz.keyboard[n] or {}
						table.insert(sfz.keyboard[n], {region=i,detune=n-r.pitch_keycenter})
					end
				end
			end
		end
		--if not found a region assign to lowest or highest
		---[[
		if not sfz.keyboard[n] and sfz.options.extend_range then
			if minmidi > n then
				for j,v in ipairs(minmidi_r) do
					local kcenter = sfz.regions[v].pitch_keycenter
					sfz.keyboard[n] = sfz.keyboard[n] or {}
					table.insert(sfz.keyboard[n],{region=v,detune = n - kcenter})
				end
			else
				assert(maxmidi < n)
				for j,v in ipairs(maxmidi_r) do
					local kcenter = sfz.regions[v].pitch_keycenter
					sfz.keyboard[n] = sfz.keyboard[n] or {}
					table.insert(sfz.keyboard[n] ,{region=v,detune = n - kcenter})
				end
			end
		end
		--]]
	end
	--get unknown opcodes
	local unknown_opcodes = {}
	for k,v in pairs(all_opcodes) do
		if not known_opcodes[k] then
			unknown_opcodes[k]=true
		end
	end
	sfz.unknown_opcodes = unknown_opcodes

	if not sfz.options.dontloadbuffers then
		M.load_buffers(sfz)
	end
	sfz.getSFZdata = getSFZdata
	sfz.getParams = getParams
	sfz.seq_counters = {}
	sfz.free_buffers = M.free_buffers
	print("Range",sfz.minkey,sfz.maxkey)
	sfz.stream_player = M.make_player(sfz)
	return sfz
end

M.compile_synthdefs()
M.ampeg_def = ampeg_def
return M