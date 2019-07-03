--local bit = 
--if not bit32 then
--bit=require("bitOp")
--end
require "sc.chords"
require "sc.scales"
require "sc.sysex"
require "sc.utils"

--these are updated inside the callback wrappers

inputNotesDown = {}
outputNotesDown = {}
inputCC = {}
outputCC = {}
midiFilters = {}

--type definitions
midi = {noteOn=9, noteOff=8, poly, at=10, cc=11, pc=12, channelAT=13, pb=14, sysex=15}

midiTypeNames = {[9]="Note on", [8]="Note off", [10]="Poly. aftertouch", [11]="CC", [12]="Program change", [13]="Channel aftertouch", [14]="Pitch bend"}

-- CC definitions
midicc = {bankSelect=0, modulation=1, breath=2, foot=4, portaTime=5, dataMSB=6, 
volume=7, balance=8, pan=10, expression=11, effect1=12, effect2=13, 
gp1=16,gp2=16,gp3=16,gp4=16,
sustain=64, portamento=65, sustenuto=66, softPedal=67, legato=68, 
hold2=69, soundController1=70, soundController2=71,soundController3=72,soundController4=73,
soundController5=74,soundController6=75,soundController7=76,soundController8=77,soundController9=78,
soundController10=79,gp5=80,gp6=81,gp7=82,gp8=83, portaControl=84, effect1Depth=91,
effect2Depth=92,effect3Depth=93,effect4depth= 94,effect5Depth=95,dataIncrement=96,
dataDecrement=97,NRPNLSB=98,NRPNMSB=99, RPNLSB=100, RPNMSB=101,
allSoundOff=120, resetAllControllers=121, localOnOff=122, allNotesOff=123, omniOff=124,
omniOn=125, monoOn=126, polyOn=127
}
function sendMidi(event) 
	print("sendMidi",tb2st(event))
    --record which notes are currently down
    if event.type==midi.noteOn then
        outputNotesDown[event.byte2+128*event.channel] = event.byte3
    end
    if event.type==midi.noteOff then
        outputNotesDown[event.byte2+128*event.channel] = nil
    end
    --record cc values
    if event.type==midi.cc then
        outputCC[event.byte2+128*event.channel] = event.byte3
    end
    return _sendMidi(event)
end
function _midiEventCb(midiEvent)
	if midi.doprint then
		--print(tb2st(midiEvent))
		print(midiEventToString(completeMidiFields(midiEvent)))
	end
	--prtable(midiEvent)
   -- midiEvent.inPort = {'host', 0}   
    newMidiEvent(midiEvent)
end
function newMidiEvent(midiEvent)
    --add the aliased accessors
    addMidiMetaTable(midiEvent)
    --zero velocity to note off mapping
    if midiEvent.type==midi.noteOn and midiEvent.velocity==0 then
        midiEvent.type = midi.noteOff    
    end
    --record which notes are currently down
    if midiEvent.type==midi.noteOn then
        inputNotesDown[midiEvent.byte2+128*midiEvent.channel] = midiEvent.byte3
    end
    if midiEvent.type==midi.noteOff then
        inputNotesDown[midiEvent.byte2+128*midiEvent.channel] = nil
    end
    --record cc values
    if midiEvent.type==midi.cc then
        inputCC[midiEvent.byte2+128*midiEvent.channel] = midiEvent.byte3
    end
    --deal with filters
    handleFilters(midiEvent)
    if midiEventCb then
        midiEventCb(midiEvent)
    elseif #midiFilters==0 then
        sendMidi(midiEvent)
    end
end


--aliases various accessors to midi events
function addMidiMetaTable(event)
    --define midi aliases
    local mt =
    {
    __index = function(t,k)
        if k=='note' then return t.byte2
        elseif k=='controller' then return t.byte2
        elseif k=='value' then return t.byte3
        elseif k=='velocity' then return t.byte3
        elseif k=='bend' then return bit.bor(bit.band(t.byte2,127),bit.lshift(bit.band(t.byte3,127),7))
        elseif k=='aftertouch' then return t.byte2
        elseif k=='program' then return byte2
        else return rawget(t,k)
        end
    end,
    
    __newindex = function(t,k,v)
        if k=='note' then t.byte2 = v
        elseif k=='controller' then t.byte2 = v
        elseif k=='value' then t.byte3 = v
        elseif k=='velocity' then t.byte3 = v
        elseif k=='bend' then t.byte3 = bit.band(bit.rshift(v,7),127) 
        t.byte2 = bit.band(v,127)
        elseif k=='aftertouch' then t.byte2=v
        elseif k=='program' then t.byte2=v
        else rawset(t,k,v)
        end
    end
    }
    setmetatable(event, mt)
    return event
end


ccnames = swapkeyvalue(midicc)


notenames = {
['C-']=0, ['B#']=0, 
['C#']=1, ['Db']=1,
['D-']=2, 
['D#']=3, ['Eb']=3,
['E-']=4, ['Fb']=4,
['F-']=5, ['E#']=5,
['F#']=6, ['Gb']=6,
['G-']=7,
['G#']=8, ['Ab']=8,
['A-']=9, 
['A#']=10, ['Bb']=10,
['B-']=11, ['Cb']=11}

plainnotenames = {
['C']=0, 
['C#']=1,
['D']=2, 
['D#']=3,
['E']=4, 
['F']=5, 
['F#']=6, 
['G']=7,
['G#']=8, 
['A']=9, 
['A#']=10, 
['B']=11,}

plainnotenumbers = swapkeyvalue(plainnotenames)

notenumbers = {
[0]='C-', 
 [1]='C#',
 [2]='D-',
 [3]='D#',
 [4]='E-',
 [5]='F-',
 [6]='F#',
 [7]='G-',
 [8]='G#',
 [9]='A-',
 [10]='A#',
 [11]='B-'}
 
 notenumbers_flat = {
 [0]='C-', 
 [1]='Db',
 [2]='D-',
 [3]='Eb',
 [4]='E-',
 [5]='F-',
 [6]='Gb',
 [7]='G-',
 [8]='Ab',
 [9]='A-',
 [10]='Bb',
 [11]='B-'}
 


--Convert a notespec of the form C-4 to a midi note number.  The last digit is the octave.
--Naturals are of the form C-4, sharps C#4, flats Cb4. Octave can be 0--9
function noteToNumberBAK(noteSpec)    
    local name = string.upper(string.sub(noteSpec, 1, 2))
	name = (name:len()==2) and name or (name.."-")
    local octave = string.sub(noteSpec,3,3) 
	octave = tonumber(octave) or 0
    local note = notenames[name] + octave*12
    return note
end
function noteToNumber(noteSpec) 
	if noteSpec == "REST" then return REST end
    local name,alt,octave = noteSpec:match("([ABCDEFGabcdefg])([-b#]?)(%d*)")
	--print(noteSpec,name,alt,octave)
	alt = (alt == "") and "-" or alt
	octave = tonumber(octave) or 0
	name = name:upper()..alt
    local note = notenames[name] + (octave + 1)*12
    return note
end
function notesToNumbers(noteSt)
	local res=TA{}
	if type(noteSt)=="string" then
	for w in noteSt:gmatch("([^,]+),?") do
       res[#res + 1]=noteToNumber(w)
	end
	else --table
	for i,w in ipairs(noteSt) do
		res[#res + 1]=noteToNumber(w)
	end
	end
	return res
end
-- Only ever returns natural or sharps -- never flats
function numberToNote(number,numbernote)
	numbernote = numbernote or notenumbers
	local numberround = math.floor(number + 0.5)
	local diffround = number - numberround
    local octave = math.floor(numberround / 12) - 1
    local note = numberround % 12
	local diffstr = ""
	if diffround ~=0 then diffstr = " "..tonumber(diffround) end
    return numbernote[note]..octave..diffstr
end

--port format: 
--{type, name}

--Examples:
-- {'host', 0}
-- {'native', 'USB Oxygen 61'}
-- {'remote', 'VSTLUA2'}
-- {'network', {'127.0.0.1', 9000}}
--nil: host
--return a copy of a midievent
function copyMidiEvent(event)
local nevent = {}
nevent.sysex = event.sysex
nevent.byte2= event.byte2
nevent.byte3= event.byte3
nevent.byte4= event.byte4
nevent.type= event.type
nevent.channel= event.channel
nevent.delta= event.delta
nevent.noteLength= event.noteLength
nevent.noteOffset = event.noteOffset
nevent.detune = event.detune
nevent.noteOffVelocity = event.noteOffVelocity
nevent.inPort = event.inPort
nevent.outPort = event.outPort
nevent.midisender = event.midisender
addMidiMetaTable(nevent)
return nevent
end


--fill in all missing fields of an event
function completeMidiFields(event)
local nevent = {}
nevent.sysex = event.sysex or ""
nevent.byte2= event.byte2 or 0
nevent.byte3= event.byte3 or 0
nevent.byte4= event.byte4 or 0
nevent.type= event.type or 0
nevent.channel= event.channel or 0
nevent.delta= event.delta or 0 
nevent.noteLength= event.noteLength or 0
nevent.noteOffset = event.noteOffset or 0
nevent.detune = event.detune or 0
nevent.noteOffVelocity = event.noteOffVelocity or 0
nevent.inPort = event.inPort --nil is acceptable for port
nevent.outPort = event.outPort --nil is acceptable for port
addMidiMetaTable(nevent)
return nevent
end

--midi utilities
function sysexMsg(sysex)
    return completeMidiFields({type=midi.sysex, sysex=sysex})
end

function noteOn(note, velocity, channel, delta, outPort)
    delta = delta or 0
    return completeMidiFields({type=midi.noteOn, channel=channel, byte2=note, byte3=velocity, delta=delta, outPort=outPort})
end

function noteOff(note, channel, delta, outPort)
    delta = delta or 0
    return completeMidiFields({type=midi.noteOff, channel=channel, byte2=note, byte3=0, delta=delta, outPort=outPort})
end

function setCC(cc, value, channel, delta)
    delta = delta or 0
    return completeMidiFields({type=midi.cc, channel=channel, byte2=cc, byte3=value, delta=delta})
end

function programChange(pc, channel, delta)
    delta = delta or 0
    return completeMidiFields({type=midi.pc, channel=channel, byte2=pc, delta=delta})
end

function pitchBend(bend, channel, delta)
    delta = delta or 0
    return completeMidiFields({type=midi.pb, channel=channel, byte2=bit.band(bend,127), byte3=bit.band(bit.rshift(bend,7),127), delta=delta})
end

function channelAftertouch(touch, channel, delta)
    delta = delta or 0
    return completeMidiFields({type=midi.channelAt, channel=channel, byte2=touch, delta=delta})
end

function polyAftertouch(note, touch, channel, delta)
    delta = delta or 0
    return completeMidiFields({type=midi.channelAt, channel=channel, byte2=note, byte3=touch, delta=delta})
end


--Pretty print a midi event
function midiEventToString(event)

    --sysex handler
    if event.type==midi.sysex then
        retval="Sysex: "..(event.channel+1).." "..event.byte2.." "..event.byte3.." "..event.byte4 --event.sysex --sysexToHex(event.sysex)
        return retval
    end
   
	
	retval = "Ch: "..(event.channel+1).." "..(midiTypeNames[event.type] or "type "..event.type).." "
	if event.type==midi.noteOn or event.type==midi.noteOff then
		retval = retval..(numberToNote(event.byte2).." "..event.byte3.." ")
	end
	
	if event.type==midi.cc  then
		name = " ("..ccnames[event.byte2]..")" or ""
	
		retval = retval..(event.byte2..name.." = "..event.byte3.." ")
	end
	
	if event.type==midi.pb then
		retval = retval..((bit.lshift(event.byte3,7) + event.byte2).." ")
	end
	
	if event.type==midi.at then
		retval = retval..(numberToNote(event.byte2).."  "..event.byte3.." ")
	end
	
	if event.type==midi.channelAT then
		retval = retval..(event.byte2.." ")
	end
	
	if event.type==midi.pc then
		retval = retval..(event.byte2.." ")
	end
	
	
	if event.noteOffset~=0 then
		retval = retval..("Note offset: "..event.noteOffset.." ")
	end
	
	if event.noteOffVelocity~=0 then
		retval = retval..("Off. vel.: "..event.noteOffVelocity.." ")
	end
	
	
	if event.noteLength~=0 then
		retval = retval..("Note len.: "..event.noteLength.." ")
	end
	
	if event.detune~=0 then
		retval = retval..("Detune: "..event.detune.." ")
	end
		
	
	retval = retval..("    [Delta: "..event.delta.."]\n")
    
    if event.inPort then
        retval = retval..("    [InPort: "..event.inPort.."]\n")
    end
    
    if event.outPort then
        retval = retval..("    [OutPort: "..event.outPort.."]\n")
    end
	
	
	return retval

end

--send all notes off/all sound off
function panic()
    for i=0,15 do
        event = setCC(123, 0, i)
        sendMidi(event)
    end
    
    for i=0,15 do
        event = setCC(120, 0, i)
        sendMidi(event)
    end
    
    --clear the output notes, they're all gone now!
    outputNotesDown = {}
    

end


--add a new filter.
--Filters have format:
-- callback. Function to be called. Same format as midiEventCb()
--numbers can be a single number,  a range of numbers, or a list of these. Ranges are strings with - separator, e.g. "4-13" or "6--15", "8 - 9"
-- type 
-- channel
-- byte2 
-- byte3
-- byte4
-- delta
-- noteLen
-- noteOffset
--noteOffVelocity
-- detune
--NB: no support for filtering sysex events

function addMidiFilter(filter)
    table.insert(midiFilters, filter)
end


function handleFilters(event)
    local fields = {'type', 'byte2', 'byte3', 'byte4', 'channel', 'delta', 'noteLen', 'noteOffset', 'noteOffVelocity', 'detune', 'note', 'value', 'velocity', 'controller', 'bend', 'aftertouch', 'program'}
    
    --check each filter
    for i,v in ipairs(midiFilters) do
        if v.callback then
            local match = true
                        
            --check for matches
            for j,k in ipairs(fields) do
                if v[k] and event[k] then match = match and inRange(event[k], v[k]) end
            end
            
            --call the filter function
            if match then
                v.callback(event)
            end
                       
        end    
    end    
end

--parses ranges as used in midifilter
function inRange(test, range)

    
    --simple number
    if type(range)=='number' then
        return test==range             
    end
    
    --string range
    if type(range)=='string' then
        --extract digits
        local match = "(%d+)%s*%-+%s*(%d+)"
        local first, last
        _,_,first,last = string.find(range, match)
        if first and last then
            return test>=(first+0) and test<=(last+0)
        else
            return false
        end
        
    end
    
    --check tables
    if type(range)=='table' then
        local inr = false
        for i,v in ipairs(range) do
            if inRange(test, v) then
                inr = true
            end
        end
        return inr
    end
        
end


--outputNotesDown is monitored in callback_wrappers.lua
function stopAllPlaying()
 --clear all playing notes
    for i,v in pairs(outputNotesDown) do
        note = i % 128
        channel = math.floor(i / 128)
        sendMidi(noteOff(note, channel))
    end   
end

MIDIOut = {sendMidi=function(self,event) sendMidi(event) end}