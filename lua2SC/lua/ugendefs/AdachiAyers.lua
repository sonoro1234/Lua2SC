AdachiAyers=UGen:new{name="AdachiAyers"}
function AdachiAyers.ar(flip,p0,radio,buffnum,buffnum2,buffnum3,yequil,gate,delay,mul,add)
	local flip = flip or 231;p0 = p0 or 5000;radio= radio or 0.005;mul=mul or 1;add=add or 0;yequil = yequil or 0;gate = gate or 1;delay = delay or 0
	return AdachiAyers:MultiNew{2,flip,p0,radio,buffnum,buffnum2,buffnum3,yequil,gate,delay}:madd(mul,add)
end