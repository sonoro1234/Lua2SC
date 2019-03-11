
LDelay = UGen:new{name="LDelay"}
function LDelay.ar(inp, delay)
	inp=inp or 0;delay = delay or 0;
	return LDelay:MultiNew{2,inp, delay}
end
Adachi=UGen:new{name="Adachi"}
function Adachi.ar(flip,p0,radio,buffnum,yequil,mul,add)
	local flip = flip or 231;p0 = p0 or 5000;radio= radio or 0.005;mul=mul or 1;add=add or 0;yequil = yequil or 0;gate = gate or 1
	return Adachi:MultiNew{2,flip,p0,radio,buffnum,yequil,gate}:madd(mul,add)
end

AdachiIIR=UGen:new{name="AdachiIIR"}
function AdachiIIR.ar(flip,p0,radio,buffnum1b,buffnum1a,buffnum2,buffnum3,yequil,gate,delay,mul,add)
	local flip = flip or 231;p0 = p0 or 5000;radio= radio or 0.005;mul=mul or 1;add=add or 0;yequil = yequil or 0;gate = gate or 1;delay = delay or 0
	return AdachiIIR:MultiNew{2,flip,p0,radio,buffnum1b,buffnum1a,buffnum2,buffnum3,yequil,gate,delay}:madd(mul,add)
end
ParamTest=UGen:new{name="ParamTest"}
function ParamTest.ar(P1,buf)
	return ParamTest:MultiNew{2,P1,buf}
end

MichaelPhaser1 = {}
function MichaelPhaser1.ar(...)
		--input, depth = 0.5, rate = 1, fb = 0.3, cfb = 0.1, rot = 0.5pi;
	local   input, depth,rate, fb,cfb,rot   = assign({'input', 'depth','rate', 'fb','cfb','rot' },{ nil, 0.5, 1, 0.3,0.1,0.5*math.pi },...)
	local  output, lfo, feedback, ac;

	-- compute allpass coefficient
	local function ac(freq)
		local theta = math.pi*SampleDur.ir()*freq;
		local tantheta = theta:tan()
		local a1 = (1 - tantheta)/(1 + tantheta);
		return a1;
	end

	local lfo = TA({0, rot}):Do( function(w) return SinOsc.ar(rate, w):range(0, 1) end)
	local feedback = LocalIn.ar(2);
	local output = input + (feedback*fb) + (feedback:reverse()*cfb);
	TA({{16, 1600}, {33, 3300}, {48, 4800}, {98, 9800}, {160, 16000}, {260, 22050}}):Do(function(freqs)
		local a1 = ac(freqs[1] + ((freqs[2] - freqs[1])*lfo));
		output = FOS.ar(output, a1, -1, a1);   -- 1st order allpass
	end)
	output = depth*output;
	LocalOut.ar(output);

	return ((1 - depth)*input + output);
end


