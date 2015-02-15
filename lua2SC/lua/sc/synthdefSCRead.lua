---  functions for reading synthdef supercollider files
--  Copyright (C) 2012 Victor Bombi

require "sc.number2string"
function getEnvSc()
    --print( io.popen"set":read'*all')
    return os.getenv("SC_SYNTHDEF_PATH")
end
if _run_options then
    if _run_options.SC_SYNTHDEF_PATH=="default" then
        SynthDefs_path=getEnvSc()
    else
        SynthDefs_path=_run_options.SC_SYNTHDEF_PATH
    end
else
    SynthDefs_path=getEnvSc()
end
--SynthDefs_path=[[C:\VSTLUA\vstluaORIGsrc-0.06-lua5.1.4v3noTab2\bin\scsynth\synthdefs\]]
--SynthDefs_path=[[C:\Users\Public\Documents\bin\scsynth\synthdefs\]]
--print("SynthDefs_path es:",SynthDefs_path)
function readpstring(f)
    local len = str2int(f:read(1))
    assert(len <=31,"pstring len "..len)
    return f:read(len)
end
function writepstring(f,str)
    assert(#str <31)
    f:write(int2str(#str,1))
    f:write(str)
end
function pstring(str)
    assert(#str <31)
    local ret=int2str(#str,1)
    return ret..str
end
function readSCSynthFile(namefile)
    local inp = assert(io.open(namefile, "rb"),"Cant read synth file:"..namefile)
    return readSCSynthStream(inp)
end
--- Reads sc.scsyndef file and return table with info
-- @tparam string name name of the synthdef
-- @treturn table with info
function readSCLibSynth(name)
    return readSCSynthFile(SynthDefs_path..name..".scsyndef")
end
-- function takes a string that behaves like a file to be read
function StrFileOpen(strg)
    local strptr = 1
    local str = strg
    local strfile = {}
    function strfile:read(len)
        local oldstrptr = strptr
        strptr = strptr + len
        return str:sub(oldstrptr,strptr-1)
    end
    function strfile:close()
        self = nil
        return true
    end
    return strfile
end
function readString(str,strptr,len)
    return str:sub(strptr,strptr+len)
end
function readSCSynthString(defstring)
    local inp = StrFileOpen(defstring)
    return readSCSynthStream(inp)
end
function readSCSynthStream(inp)
    local res={}
    local buff=inp:read(4)
    assert(buff=="SCgf")
    res.version=str2int(inp:read(4)) --version
    --print("version: " .. res.version)
    local lenvint = 2
    if res.version > 1 then
        lenvint = 4
    end
    --------------------------
    local numdefs=str2int(inp:read(2)) --numero definiciones
    --print(" syndefs: " .. buff)
    assert(numdefs==1,"El numero de definiciones no es 1 sino "..numdefs)
    res.name=readpstring(inp)
    --print(" name: "..res.name)
    local K=str2int(inp:read(lenvint)) --numero de constantes
    --print(" constantes: " .. K)
    Kt={}
    for i=1,K do
        Kt[i]=str2float32(inp:read(4))
    end
    --prtable(Kt)
    res.constants=Kt

    local P=str2int(inp:read(lenvint)) --numero de parametros

    Pt={}
    for i=1,P do
        Pt[i]=str2float32(inp:read(4))
    end
    res.parameters=Pt
    local N=str2int(inp:read(lenvint)) --nombre de parametros
    --assert(N==P)
    Nt={}
    for i=1,N do
        local cad=readpstring(inp)
        Nt[str2int(inp:read(lenvint)) + 1]=cad
    end
    res.paramnames=Nt
    U=str2int(inp:read(lenvint)) --ugens

    Ut={}
    for i=1,U do
        local thisUt = {}
        Ut[i] = thisUt
        Ut[i].name=readpstring(inp)
        Ut[i].calcrate=str2int(inp:read(1))
        Ut[i].inputs=str2int(inp:read(lenvint))
        Ut[i].outputs=str2int(inp:read(lenvint))
        Ut[i].special=str2int(inp:read(2))
        Ut[i].inputspec={}
        if thisUt.inputs > 0 then
            for j=1,thisUt.inputs do
                thisUt.inputspec[j]={}
                thisUt.inputspec[j]["i1"]=str2int(inp:read(lenvint))+1
                thisUt.inputspec[j]["i2"]=str2int(inp:read(lenvint))+1
                
                ------------------------------para entender yo
                if not(Ut[i].inputspec[j]["i1"] < i) then prtable(res) end
                assert(Ut[i].inputspec[j]["i1"] < i,"Bad topological sort")
                if thisUt.inputspec[j]["i1"]==0 then
                    thisUt.inputspec[j]["valor"]=Kt[thisUt.inputspec[j]["i2"]]
                else
                    thisUt.inputspec[j]["ugen"]=Ut[thisUt.inputspec[j]["i1"]].name.." rate:"..Ut[thisUt.inputspec[j]["i1"]].calcrate
                    if Ut[thisUt.inputspec[j]["i1"]].name=="Control" or Ut[thisUt.inputspec[j]["i1"]].name=="TrigControl"then
                        local paramind = thisUt.inputspec[j]["i2"] + Ut[thisUt.inputspec[j]["i1"]].special
                        thisUt.inputspec[j]["ugen"]=thisUt.inputspec[j]["ugen"].." - "..tostring(Nt[paramind])
                    elseif Ut[Ut[i].inputspec[j]["i1"]].name=="UnaryOpUGen" or Ut[Ut[i].inputspec[j]["i1"]].name=="BinaryOpUGen" then
                        Ut[i].inputspec[j]["ugen"]=Ut[i].inputspec[j]["ugen"].." -special:"..Ut[Ut[i].inputspec[j]["i1"]].special
                    end
                end
                ---------------------------------
            end
        end
        Ut[i].outputspec={}
        if Ut[i].outputs > 0 then
            for j=1,Ut[i].outputs do
                Ut[i].outputspec[j]=str2int(inp:read(1))
            end
        end
    end
    --prtable(Ut)
    -- for i,v in ipairs(Ut) do
        -- print("\n")
        -- prtable(v)
    -- end
    res.ugens=Ut
    inp:close()
    return res
end
