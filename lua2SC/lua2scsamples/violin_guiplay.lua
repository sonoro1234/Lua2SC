
body_resons={{118, 18, -33},
{274, 22, -34.5},
{449, 10, -16},
{547, 16, -15.5},
{840, 50, -31},
{997, 30, -20.4},
{1100, 30, -34},
{1290, 25, -29},
{1500, 50, -28},
{1675, 60, -22},
{1900, 60, -20}}

SynthDef("violin",{out=Master.busin,freqN=400,velb=0.4,force=1,pos=0.14,c1=16,c3=40,impZ=1,fB=2,lpf=4300,size=1,bof=1,gainL=40,gainH=1,tt=0.1,dura=0.3},function() 
	
	--envelope for vel
	local t = {-1,-1,-1,1,1,-1,-1}
	local times = {0,dura-tt,tt,dura-tt,tt,0}
	velb = EnvGen.kr(Env(t,times,"lin",5,0))*velb

	--string bowed
	local vibratoF =  Vibrato.kr{freqN, rate= 5, depth= 0.003, delay= 0.25, onset= 0, rateVariation= 0.1, depthVariation= 0.3, iphase =  0}
	local str = DWGBowedTor.ar(vibratoF,velb,force,0,pos,nil,c1,c3,impZ,fB)*0.1

	--body resonance
	local coefs = TA{199, 211, 223, 227, 229, 233, 239, 241 } *size
	local fdn = DWGSoundBoard.ar(str,nil,nil,nil,unpack(coefs:asSimpleTable()));
	local bodyf = 0
	for i,v in ipairs(body_resons) do
		bodyf = bodyf + BPF.ar(str,v[1]*bof,1/v[2])*db2amp(v[3])
	end
	local son = bodyf*gainL + fdn*gainH
	son = LPF.ar(son,lpf)

	Out.ar(out,son:dup())
end):guiplay()

Scope()
FreqScope()


