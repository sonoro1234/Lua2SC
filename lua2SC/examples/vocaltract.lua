-- DOAUTOGUI = false
-- OSCFunc.trace(false,false,false)
-- local Tract = require"num.vocaltractB"(32,false,true)
local Tract = require"num.ParametricTractC"(24,17)
-- local Tract = require"num.tract"(26)

local sclua = require "sclua.Server"
local s = sclua.Server()
local syn

local vbox = addPanel{type="vbox",name="tract",parentNO = MainUpPanel}
local hbox = addPanel{type="hbox",parent = vbox}
grafic = addControl{ typex="funcgraph",panel=hbox,width=300,height=300,miny=0,maxy=3}
grafic2 = addControl{ typex="funcgraph",panel=hbox,width=300,height=300,miny=0,maxy=3}

local phons = {}
for k,v in pairs(Tract.areas) do
	print("area",k)
	table.insert(phons,k)
end
table.sort(phons)

function mod_areas(Ar,fAc,fAc2,fAc3,pos)
	local Arc = {}
	Arc[1] = Ar[1]
	local nsecs = math.floor(#Ar*pos + 0.5)

	local pend = (fAc2- fAc)/(nsecs - 2)

	for ii=2,nsecs do
		Arc[ii] = Ar[ii]*(fAc + (ii-2)*pend)
	end
	local pend2 = (fAc3- fAc2)/(#Ar - (nsecs+1))
	for ii=nsecs+1,#Ar do
		Arc[ii] = Ar[ii]*(fAc2 + (ii-(nsecs+1))*pend2)
	end
	return Arc
end

local freq,fA,fPreoral,fAc,fAc2,fAc3,pos = 130,1,1,1,1,1,0.5
local boca = 1
local iph = 2
local phon1 = Tract.phon.getArgs(phons[1])
Sync()
local syn_group = s.ParGroup()

local syn = s.Synth(Tract.sinteRdO2.name, phon1,syn_group)

--------------------------------------
local function AreaPlotter()
	local synpars = getSynthdefParams(SynthDefs_path..Tract.sinteRdO2.name..".scsyndef")
	local firstind = synpars.NameToIndex.Ar
	local lenind = synpars.paramlens.Ar
	local Q = require"sc.queryTree"
	local up_time = 0.1

	local function get_syn(syn)
		local diam = {}
		--if next(syn.mapped) then print"mapped " else print"not mapped" end
		for j=1,lenind do
			local argind = syn.args[firstind+j][1]
			local val = syn.mapped[argind] or syn.params[argind]
			diam[j] = math.sqrt(val)
		end
		grafic2:val(diam)
	end

	local work
	local function update_controls()
			Q.querySynthValues(syn.nodeID,get_syn)
			if work then QueueAction(up_time,{update_controls}) end
	end
	local function run()
		work = true
		QueueAction(up_time,{update_controls})
	end
	local function stop()
		work = false
	end
	return {run = run, stop = stop}
end
Arp = AreaPlotter()
Arp.run()
-- Arp.stop()
---------------------------------------------------------------
function setsyn()
	print("Setting",iph, phons[iph])
	local phon = Tract.phon.getArgs(phons[iph])
	
	phon.Ar = mod_areas(phon.Ar,fAc,fAc2,fAc3,pos)
	phon.Ar[#phon.Ar] = boca * phon.Ar[#phon.Ar]
	local diam = {}
	for i=1,#phon.Ar do diam[i] = math.sqrt(phon.Ar[i]) end
	
	grafic:val(diam)
	phon.freq = freq
	phon.fA = fA
	phon.fPreoral = fPreoral
	phon.out = Master.busin
	phon.Rd = 1
	syn:set(phon)

end

local panelflexi=addPanel{type="flexi",cols=6,parent=vbox,window=win}
for i=1,#phons do
	 local newcontrol = {
					--name=phons[i],
					panel=panelflexi, 
					typex = "button",
					label=phons[i],
					callback=function(value,str,c) 
						iph = i
						setsyn()
						end
				}
				addControl(newcontrol)
end

local hbox = addPanel{type="hbox",parent=vbox}
curr_panel = hbox

Slider("freq",50,600,freq,function(val) freq=val;setsyn() end)
Slider("fA",0,2,fA,function(val) fA=val;setsyn() end)
Slider("fPreoral",0,2,fPreoral,function(val) fPreoral=val;setsyn() end)
Slider("fAc",0,4,fAc,function(val) fAc=val;setsyn() end)
Slider("fAc2",0,4,fAc2,function(val) fAc2=val;setsyn() end)
Slider("fAc3",0,4,fAc3,function(val) fAc3=val;setsyn() end)
Slider("pos",0,1,pos,function(val) pos=val;setsyn() end)
Slider("boca",0,4,boca,function(val) boca=val;setsyn() end)

local hbox = addPanel{type="hbox",parent=vbox}
curr_panel = hbox

-- only for parametric
--[=[
if Tract.vowel_coefs then
local voc = "U"
Slider(voc.."pos1",0,1,Tract.vowel_coefs[voc][1],function(val) 
	Tract.vowel_coefs[voc][1]=val--*Tract.n
	Tract.areas[voc],Tract.Di[voc] = Tract.CalcAreas(voc)
	setsyn()
end)
Slider(voc.."pos2",0,1,Tract.vowel_coefs[voc][2],function(val) 
	Tract.vowel_coefs[voc][2]=val
	Tract.areas[voc],Tract.Di[voc] = Tract.CalcAreas(voc)
	setsyn()
end)
Slider(voc.."pos3",0,10,Tract.vowel_coefs[voc][3],function(val) 
	Tract.vowel_coefs[voc][3]=val
	Tract.areas[voc],Tract.Di[voc] = Tract.CalcAreas(voc)
	setsyn()
end)
Slider(voc.."pos4",0,5,Tract.vowel_coefs[voc][4],function(val) 
	Tract.vowel_coefs[voc][4]=val
	Tract.areas[voc],Tract.Di[voc] = Tract.CalcAreas(voc)
	setsyn()
end)
end
--]=]

-- several frases
local frase = "DI-ME-KE-ME-KIE-RES-_v"
--frase = "NE-LE-PE-KE-RE-ZE-DE-HE-FE-GE-XE-MvE-ME-TE-BE-SE-JE-NvE-_v"
--frase = "KA-JA-ZA-_v"
--frase = "ZA-ZE-ZI-ZO-ZU-_v"
--frase = "LA-LUZ-BUS-KAN-DO-_v"
--frase = "AI-KE-A-ZER-AL-GO-_v"
--frase = "MES-TOI-MAR_R-TXANv-DO-LE-JOS-DEA-KI -MES-TOI-MAR_R-TXANv-DO-_v"
frase = "MES-TOI-MAR_R-TXAN-DO-LE-JOS-DEA-KI -MES-TOI-MAR_R-TXAN-DO-_v"
--local frase = ""
--for k,v in pairs(Tract.cons) do frase = frase .. "-"..k.."E" end
--frase = frase:sub(2).."_v"
frase = "LA-LUZ-BUS-KAN-DO-KEUN-DI-A-BI -LA-LUZ-BUS-KAN-DO-_v"
--frase = "NAN-Nv-NEN-NIN-NON-NUN-_v"
--frase = "OM-MA-NI-PAD-ME-HUMv- "
--frase = "ME-HUMv"
--frase = "HUMv- "
--frase = "AMv-EMv-IMv-OMv-UMv- "
--frase = "MAMv-_v-MEMv-_v-MIMv-_v-MOMv-_v-MUMv-_v"
--frase = "LA-LUZ-LAZ-LUS-ES-GA-JA-ZA-LAZ-LUZ-_v"

Text("frase",frase,function(val) frase=val end,200,75,true)
local dura = 1
Slider("dur",0.1,2,dura,function(val) dura=val end)
local player = {group=0,node=syn.nodeID}
Button("speack",function()
	print"SPEAK"
	local syls = Tract.get_sylabes(frase,true)
	prtable(syls)
	local now = lanes.now_secs()
	for j,syl in ipairs(syls) do
		local ret1 = Tract.syl2phon(syl,false)
		prtable(ret1)
		local ret2 = Tract.doSpeak(ret1,Time2beats(dura))
	
		local gbundle = {}
		for k,v in pairs(ret2) do
			if type(v)=="table" and v.is_ctrl_mapper then
	
				local bund = v:verb(k,player)--,0,1)--,beatTime,beatLen)
				if bund then
					for i,vv in ipairs(bund) do table.insert(gbundle,vv) end
				end
			else
				--print(k,type(v),v)
			end
		end
		sendMultiBundle(now+(j-1)*dura,gbundle)
	end
end, true)

-- test ENV
local sweept_player = {group=0,node=syn.nodeID}
local env_synth = SINEr(1,0,150,200)
Button("sweap",function()
	local bundle = env_synth:verb("freq", sweept_player, nil, nil)
	ThreadServerSendT(bundle)
end, true)


MASTER{level=0.15}
syn:gui(0.1)--0.5)

