MembraneCircleV=UGen:new{name='MembraneCircleV'}
function MembraneCircleV.ar(...)
	local   excitation, tension, loss,ewidth,epos,size,a1,doprint, mul, add   = assign({ 'excitation', 'tension', 'loss','ewidth','epos','size','a1','doprint', 'mul', 'add' },{ nil, 0.05, 0.99999,0.5,0,1,0.5,0, 1.0, 0.0 },...)
	return MembraneCircleV:MultiNew{2,excitation,tension,loss,ewidth,epos,size,a1,doprint}:madd(mul,add)
end

MembraneHexagonV=UGen:new{name='MembraneHexagonV'}
function MembraneHexagonV.ar(...)
	local   excitation, tension, loss,ewidth,epos,size,a1,doprint, mul, add   = assign({ 'excitation', 'tension', 'loss','ewidth','epos','size','a1','doprint', 'mul', 'add' },{ nil, 0.05, 0.99999,0.5,0,1,0.5,0, 1.0, 0.0 },...)
	return MembraneHexagonV:MultiNew{2,excitation,tension,loss,ewidth,epos,size,a1,doprint}:madd(mul,add)
end