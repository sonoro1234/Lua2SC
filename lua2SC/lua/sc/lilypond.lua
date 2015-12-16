local LILY = {}
function LILY:Gen() end
if typerun==1 then return LILY end

require"sc.oscfunc"(scriptlinda)
require"sc.callback_wrappers"
require"sc.sc_comm"
--InitSCCOMM()
require"sc.gui"
if typeshed == false then
	require"sc.playerssc"
elseif typeshed then
	require"sc.playersscSCH"
else
	error("typeshed is nil")
end
--table.insert(initCbCallbacks,MASTER_INIT1)
require"sc.miditoosc"
require"sc.playersscgui"
require"sc.scbuffer"
require"sc.ctrl_bus"
require"sc.named_events"
if typeshed == false then
	require"sc.MetronomLanes"
elseif typeshed then
	require"sc.MetronomLanesSCH"
else
	error("typeshed is nil")
end

    sendBundle = function(msg,ti)
	end
	sendMultiBundle = function(ti,msg)
	end
	sendBlocked = function(msg)
		return {"/done",{}}
	end
--MASTER_INIT1()
table.insert(initCbCallbacks,1,MASTER_INIT1)
-------------------------------------


local notenumbers = {[0]="c","cis","d","dis","e","f","fis","g","gis","a","ais","b"}
local notenumbers = {[0]="c","des","d","ees","e","f","ges","g","aes","a","bes","b"}
local function numberToNote(number,numbernote)
	numbernote = numbernote or notenumbers
	if number == REST or number==NOP then return "r",0 end
	local numberround = math.floor(number + 0.5)
    local octave = math.floor(numberround / 12) - 1
    local note = numberround % 12
	octave = octave - 3 --??
	local octavestr
	if octave >=0 then
		octavestr = ("'"):rep(octave)
	else
		octavestr = (","):rep(-octave)
	end
    return numbernote[note]..octavestr ---..diffstr
end
local function makeLilyEvent(name,beatTime,note,dur)
	--if note == NOP then return "" end
	--local dura = math.floor(4/(dur))
	local nota = numberToNote(note)
	--prerror(name,beatTime,nota,dur,dura)
	return " "..nota --..dura
end
local function torational(x,maxden)
    local startx = x 
    -- initialize matrix */
	local m = {[0]={},{}}
    m[0][0] =1; m[1][1] = 1;
    m[0][1] =0; m[1][0] = 0;

    -- loop finding terms until denom gets too big */
	local t
	local ai = math.floor(x)
    while (m[1][0] *  ai + m[1][1] <= maxden) do

		t = m[0][0] * ai + m[0][1];
		m[0][1] = m[0][0];
		m[0][0] = t;
		t = m[1][0] * ai + m[1][1];
		m[1][1] = m[1][0];
		m[1][0] = t;
		if(x == ai) then break end    -- AF: division by zero
		x = 1/(x - ai);
		if(x >0x7FFFFFFF) then break end  -- AF: representation failure
		ai = math.floor(x)
    end 

    -- now remaining x is between 0 and 1/ai */
    -- approx as either 0 or 1/m where m is max that will fit in maxden */
    -- first try zero */
  -- print( string.format("%d/%d, error = %e\n", m[0][0], m[1][0],startx - ( m[0][0] /  m[1][0])));
	return m[0][0],m[1][0],startx - ( m[0][0] /  m[1][0])

    -- now try other possibility */
    --ai = (maxden - m[1][1]) / m[1][0];
    --m[0][0] = m[0][0] * ai + m[0][1];
    --m[1][0] = m[1][0] * ai + m[1][1];
    --print(string.format("%d/%d, error = %e\n", m[0][0], m[1][0], startx - ( m[0][0] / m[1][0])));
end
local function getmode(sc)
	local sc2 = {}
	for i,v in ipairs(sc) do
		sc2[i] = sc[i]-sc[1]
	end
	for k,v in pairs(modes) do
		local bad = false
		for i,n in ipairs(v) do
			if n~=sc2[i] then bad=true;break end
		end
		if bad==false then return k end
	end
	return "ionian"
end
local function calcduration(score,beatLen)
	local dura
	if beatLen <=4 then
		dura = math.floor(4/(beatLen))
		table.insert(score,dura)
	else
--[[
		local rest = beatLen
		if beatLen > 24 then
			local laststr = score[#score]
			if laststr~=">" then
				while rest > 24 do
					score[#score + 1] = "1*6" --24/6
					score[#score + 1] = laststr
					rest = rest - 24
				end
			end
		end
--]]
		local laststr = score[#score]
		local bars = math.floor(beatLen/4)
		for i=1,bars do
			score[#score + 1] = "1" --24/6
			score[#score + 1] = "~"..laststr
		end
		local rest = beatLen - bars*4
--------------
		if rest > 0 then
			--local scale = rest/4
			--local N,M = torational(scale,10000)
			--dura = "1*"..N.."/"..M
			dura = math.floor(4/(rest))
			table.insert(score,dura)
		else
			score[#score] = nil --undo
		end
	end
	
end
local function LILYplayEvent(self,lista,beatTime, beatLen,delta)
	beatLen = math.min(beatLen,LILY.endppq - beatTime)
	if beatLen <= 0 then return end
	local maxlen = getmaxlen(lista)
	local allkeydata = {}
	local score = LILY.score[self.lilyscorenum]
	local started = LILY.started[self.lilyscorenum]
	if not started then
		LILY.started[self.lilyscorenum] = true
		if beatTime > LILY.inippq then
			table.insert(score," \\key c \\minor ")
			score[#score+1] = " r"
			calcduration(score,beatTime - LILY.inippq)
		end
	end
	if maxlen > 1 then
		table.insert(score,"<")
	end
	for i=1,maxlen do
		local keydata = {}
		for k,v in pairs(lista) do
			--need deepcopy in case item is altered in playOneEvent
			--and is a table reference (ex:ctrl_function)
			--keydata[k] = deepcopy(WrapAtSimple(v,i))
			keydata[k] = WrapAtSimple(v,i)
		end
		
		local note
		if keydata.freq then
			note = freq2midi(keydata.freq)
		elseif keydata.note then
			note = keydata.note
		elseif keydata.degree then
			note = getNote(keydata.degree,keydata.escale or "ionian")
		end
		keydata.note = note
		--keep ranges
		if note~=REST and note~=NOP then
		local minnote = LILY.minnote[self.lilyscorenum] or math.huge
		local maxnote = LILY.maxnote[self.lilyscorenum] or -math.huge
		minnote = (note < minnote ) and note or minnote
		maxnote = (note > maxnote ) and note or maxnote
		LILY.minnote[self.lilyscorenum] = minnote
		LILY.maxnote[self.lilyscorenum] = maxnote
		end
		--armadura
		if keydata.escale then
			local tonic = keydata.escale[1]
			if LILY.tonics[self.lilyscorenum]~=tonic then
				LILY.tonics[self.lilyscorenum]=tonic
				local key = notenumbers[tonic%12]
				table.insert(score," \\key "..key.." \\"..getmode(keydata.escale).." ")
			end
		end
		--if note == NOP then return end
		local str = makeLilyEvent(self.name,beatTime,note,keydata.dur)
		table.insert(score,str)
		allkeydata[i] = keydata
	end
	if maxlen > 1 then
		table.insert(score,">")
	end
	calcduration(score,beatLen)
	
	--print("dur",beatLen,dura)
end

function LILY:open(filepath)
	local file,err = io.open(filepath,"wb")
	self.file = file
	if not self.file then error(err) end
	self.filepath = filepath
	
end
function LILY:sendBundle(msg,time)

end
function LILY:sendMultiBundle(time,msg)

end
local osctable = {}
local clefs = {[0]="treble",[1]="treble^8",[2]="treble^15",[-1]="bass",[-2]="bass_8",[-3]="bass_15"}
function LILY:SaveStr(file)
	local fich,err=io.open(file,"wb")
	if not fich then error(err) end
	fich:write[[\version "2.18.2"]]
	fich:write[[\layout{\context{\Voice 
\override Beam.breakable = ##t 
\remove "Forbid_line_break_engraver"
\remove "Note_heads_engraver"
\consists "Completion_heads_engraver" 
}} ]]
	fich:write("<<")
	for i=1,#self.players do
		local pl = self.players[i]
		local minn = self.minnote[pl.lilyscorenum]
		local maxn = self.maxnote[pl.lilyscorenum]
		local midn = (minn + maxn)*0.5
		local clindex = math.floor(0.5+((midn - 67)/12))
		clindex = clip(clindex,-3,2)
		local clef = clefs[clindex]
		table.insert(self.score[i],2,"\\clef \""..clef.."\" ")
		print(pl.name,clef,midn,clindex,self.minnote[pl.lilyscorenum],self.maxnote[pl.lilyscorenum])
		fich:write(table.concat(self.score[i]))
	end
	fich:write(">>")
	fich:close()
end

function LILY:close()
	self.file:close()
	self.closed = true
end
function LILY:Gen(inippq,endppq,players)
	print"LILY:Gen"
	self.inippq = inippq
	self.endppq = endppq
	self.score = {}
	self.started = {}
	self.players = players
	self.tonics = {}
	self.minnote = {}
	self.maxnote = {}
	for i=1,#players do
		players[i].name =  players[i].name or players[i]:findMyName()
		local staftype = players[i].isOscPianoEP and "PianoStaff" or "Staff" 
--%\remove "Note_heads_engraver"
--%\consists "Completion_heads_engraver"
--%\remove "Rest_engraver"
--%\consists "Completion_rest_engraver"
--%\consists "Rhythmic_column_engraver" 
		self.score[i] = {string.format("\n\\new %s \\with{instrumentName = #%q } {",staftype,players[i].name)}
		players[i].lilyscorenum = i
	end
	self.test = test
	local function pathnoext(P)
		return P:match("([^%.]+)")
	end

	theMetro:play(nil,0,0,25)
	local lastt = 0
    sendBundle = function(msg,ti)
	end
	sendMultiBundle = function(ti,msg)
	end
	sendBlocked = function(msg)
		return {"/done",{}}
	end
	EventPlayer.playEvent = LILYplayEvent
	curHostTime = theMetro
	_initCb()
   -- table.insert(initCbCallbacks,function()
		print"LILYPOND work"
		theMetro:play(nil,inippq,0,25)
		theMetro.oldtimestamp = -theMetro.period
		while theMetro.ppqPos < endppq do
			theMetro.timestamp = theMetro.oldtimestamp + theMetro.period
			theMetro.oldppqPos = theMetro.ppqPos
			theMetro.ppqPos = theMetro.ppqPos + theMetro.frame
			--print("theMetro",theMetro.oldppqPos,theMetro.ppqPos)
			--_onFrameCb()
			for i,v in ipairs(players) do
				--println("onframe player:",v.name)
				--v:Play()
				EventPlayer.Play(v)
			end
			theMetro.oldtimestamp = theMetro.timestamp
		end

		print"saving osc table"
		for i=1,#players do
			local score = self.score[i]
			score[#score+1] = "}"
		end
		local lilyfile = pathnoext(scriptname)..".ly"
		local pdffile = pathnoext(scriptname)..".pdf"
		self:SaveStr(lilyfile)
		print"osc table saved"
		--require"lfs"
		--print(lfs.currentdir())
		--os.execute([[C:\Program Files\LilyPond\usr\bin\lilypond.exe -fpdf ]].. lilyfile)
		os.remove(pdffile)
		os.execute(string.format([["C:\Program Files (x86)\LilyPond\usr\bin\lilypond" -V -fpdf -o%s %s]],pathnoext(scriptname),lilyfile))
		print"pdf done"
		--os.execute(pathnoext(scriptname)..".pdf")
		io.popen(pdffile)
    --end)
end
return LILY