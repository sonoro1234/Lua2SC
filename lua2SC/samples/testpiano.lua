require("sc.utilsstream")
require("sc.synthdefSCGUI")
require("sc.miditoosc")
require("sc.playersscgui")

function debuglocals(prtables)
	print"debuglocals1"
	local str=""
	local prtables = prtables or false
	print"\n"
	for level = 2, 2 do
		local info = debug.getinfo(level, "Sln")
		if not info then break end
		if info.what == "C" then -- is a C function?
			print(level, "C function")
		else -- a Lua function
			print(string.format("\nfunction %s[%s]:%d",tostring(info.name), info.short_src,info.currentline))
		end
		local a = 1
		while true do
			local name, value = debug.getlocal(level, a)
			if not name then break end
			--print("local variable:",name, value)
			str = str .. name .."=" ..tostring(value)..","
			if type(value)=="table" and prtables then dumpObj(value) end
			a = a + 1
		end
	end
	print(str)
	print("end debug print1")
end

OteyPiano = UGen:new{name="OteyPiano"}
--freq, gate, release, vel, minr,maxr,ampr,centerr, rcore, minl,maxl,ampl,centerl, rho, e, zb, zh, mh, k, alpha, p, pos, loss,detune
function OteyPiano.ar(freq, gate, release, vel, rmin, rmax, rampl, rampr, rcore, lmin, lmax, lampl, lampr, rho, e, zb, zh, mh, k, alpha, p, hpos, loss,detune)
	freq=freq or 440;vel=vel or 1;gate = gate or 1;release = release or 0.1;hpos = hpos or 1/7 ;rho = rho or 1;lmin = lmin or 0.07;lmax = lmax or 1.4;lampl = lampl or -4;lampr = lampr or 4;rcore = rcore or 1;e = e or 1;rmin = rmin or 0.35;rmax = rmax or 2;rampr = rampr or 8;rampl = rampl or 4;detune = detune or 0.0003;loss = loss or 1; e = e or 1; zb = zb or 1; zh= zh or 0; mh= mh or 1; k = k or 1; alpha= alpha or 1; p = p or 1
--debuglocals()
	return OteyPiano:MultiNew{2,freq, gate, release, vel, rmin,rmax,rampl,rampr, rcore, lmin,lmax,lampl,lampr, rho, e, zb, zh, mh, k, alpha, p, hpos, loss,detune}
end
OteyPiano.ar()
SynthDef("help_oteypiano", { out=0, freq=440, amp=0.5, gate=1, release=0.1, rmin = 0.35,rmax =  2,rampl =  4,rampr = 8, rcore=1, lmin =  0.07,lmax =  1.4;lampl =  -4;lampr =  4, rho=1, e=1, zb=2, zh=0, mh=1.6, k=0.5, alpha=1, p=1, pos=0.142, loss = 1,detunes = 6,pan=0},function()

	vel = amp
	--k = LinLin.kr(amp,0,1,0.2,0.5)
	local son = OteyPiano.ar(freq, gate, release, vel, rmin,rmax,rampl,rampr, rcore, lmin,lmax,lampl,lampr, rho, e, zb, zh, mh, k, alpha, p, pos, loss,detunes*0.0001)
	--son = OteySoundBoard.ar(son,20,20)
	--local son = OteyPiano2.ar(freq, vel, gate, release)
	DetectSilence.ar(son, 0.001,nil,2);
	Out.ar(out, Pan2.ar(son *0.1,LinLin.kr(freq,midi2freq(21),midi2freq(80),-0.75,0.75)));
	--Out.ar(out, Pan2.ar(son *0.1,pan));
end):store();

Effects={FX("gverb",db2amp(0.77),nil,{revtime=2.5,earlylevel=0.45,roomsize=100})}
--[[
sinte=OscEP{inst="help_oteypiano",dontrelease=true,sends={db2amp(-9)},channel={level=db2amp(3)},poly=6}:Bind(LOOP{PS{
	dur = 4,
	note = LS{REST},
	amp = LOOP{1,0.8,0.7,0.9,0.7,0.6},--noisefStream{0.8,1}
},PS{
	delta=LOOP{1/3},
	dur = 3,
	--escale = "aeolian",
	amp=noisefStream{0.05,0.1},
	pan=0,--noisefStream({-1,1}),
	note=LOOP{56,61,64},
}
})
sinte.inserts = {{"soundboard"},{"early",{mix=0.6,lat=0.1,ff=15000,fac=8.87}}} --,{"ocean"}
sinte2=OscEP{inst="help_oteypiano",dontrelease=true,sends={db2amp(-9)},channel={level=db2amp(-5)},poly=15}:Bind(LOOP{
PS{
	delta= RSinf({LS{1}:rep(7)}..TA():series(3,2,1))/3,
	dur = 8,
	note = LOOP{56,63,68, 68,63,56, 64,73,80, 80,73,64,REST},
	amp = noisefStream{0.4,1}
},PS{
	dur = LS{4},--LS{8,2,5+1/3,1/3,1/3,2,6},
	note = LS{REST,61,58,61,61,61,58},
	amp = noisefStream{0.2,0.4}
}})
sinte2.inserts = {{"soundboard"},{"early",{mix=0.6,lat=0.32,ff=15000,fac=9}}}
EPinstGUI(sinte2)
---]]
--[[
player = OscEP{inst="help_oteypiano",mono=false,dontfree=true}:Bind{
	dur = LOOP{1.5,1.5,1},
	amp = 0.5,
	note = LOOP{60,64}
}
--player.inserts = {{"soundboard"}}
--]]
instgui=InstrumentsGUI("help_oteypiano",false)
MidiToOsc.AddChannel(0,instgui,{0.5},mmm5,inss)
FreqScope()
--Scope()
theMetro:tempo(140)
theMetro:start()
