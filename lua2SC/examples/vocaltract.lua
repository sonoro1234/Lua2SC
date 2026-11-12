
local Tract = require"num.vocaltractB"(16,false,true)


local sclua = require "sclua.Server"
local s = sclua.Server()
local syn

local vbox = addPanel{type="vbox",name="vbox"}
grafic = addControl{ typex="funcgraph",panel=vbox,width=300,height=300,miny=0,maxy=3}

local phons = {}
for k,v in pairs(Tract.areas) do
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

local freq,fA,fPreoral,fAc,fAc2,fAc3,pos = 100,1,1,1,1,1,0.5
local boca = 1
local iph = 2
local phon1 = Tract.phon.getArgs(phons[1])
Sync()
local syn = s.Synth(Tract.sinteRdO2.name)--, phon1)
--local syngui = syn:gui()--0.5)

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
	--phon.noiseloc = math.max(12,phon.noiseloc)
	syn:set(phon)
	--prtable(phon)

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

MASTER{level=0.25}
syn:gui(0.1)--0.5)
print"end script"

