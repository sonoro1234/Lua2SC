--inherits from polynomial.lua for filter design transfer functions
--by Victor Bombi
require"num.polynomial"
filterpoly_mt = deepcopy(RationalPoly_mt)
--setmetatable(filterpoly_mt,filterpoly_mt)
function filterpoly_mt.filter(self,inp,len)
	local len = len or 100
	local a = ArrayReverse(self.Den:GetCoefs())
	local b = ArrayReverse(self.Num:GetCoefs())
	local res = {}
	for i=1,len do
		local val = 0
		for ib,vb in ipairs(b) do
			val = val + vb * (inp[i - ib + 1] or 0)
		end
		for ia=2,#a do
			val = val - a[ia] * (res[i - ia + 1] or 0)
		end
		res[i] = val
	end
	return res
end
function filterpoly_mt.magnitude(self,x)
	return (complex.abs(self(complex.exp(complex.new(0,1)*x))))
end
function filterpoly_mt.phase(self,x)
	return Phase(self(complex.exp(complex.new(0,1)*x)))
end
function filterpoly_mt.UnitCircleEval(self,x)
	return self(complex.exp(complex.new(0,1)*x))
end
function filterpoly_mt.GroupDelayFunction(H)
	local function RampedPoly(A)
		local res = Polynomial{}
		for i=0,A.deg do
			res[i]=i*A[i]
		end
		return res
	end
	local rA = RampedPoly(H.Den)
	local rB = RampedPoly(H.Num)
	local AB = H.Den*H.Num
	local Num = rB*H.Den-H.Num*rA
	local hh = RatPoly(Num,AB) -- - H.Den.deg
	return function(x)
			return -complex.real(UnitCircleEval(hh,x))
		end
end
function filterpoly_mt.GroupDelayFunction2(H)
	local Hder = H:derive()
	local hh = (Hder / H):Simplify()
	return function(x)
			local ew = complex.exp(complex.new(0,1)*x)
			local a = hh(ew)*ew*complex.i
			return -complex.imag(a)
		end
end
function filterpoly_mt.GroupDelay(H,om)
	if not H.grupdelf then H.grupdelf = H:GroupDelayFunction() end
	return H.grupdelf(om)
end
function FilterPoly(B,A)
	local res = ZRatPoly(B,A)
	return setmetatable(res, filterpoly_mt)
end

function PhaseDelay(Hz,i)
	local freq = complex.exp(complex.new(0,1)*i)
	return -Phase(Hz(freq))/(i~=0 and i or 1)
end
function PhaseShift(Hz,i)
	local freq = complex.exp(complex.new(0,1)*i)
	return Phase(Hz(freq))
end
function PhaseShiftUnwrap(Hz)
	local add = 0
	local last -- = Hz(1) -- 0 freq
	return function(i)
			local freq = complex.exp(complex.new(0,1)*i)
			local v = Phase(Hz(freq))
			local diff = last and (v + add - last) or 0
			--[[
			if diff > math.pi then
				add = add - 2*math.pi
			elseif diff < -math.pi then
				add = add + 2*math.pi
			end
			--]]
			--print(i,diff)
			if diff > math.pi then
				while diff > math.pi do
					add = add - 2*math.pi
					diff = diff - 2*math.pi
					--print"xxxxxxxxxlower"
				end
			elseif diff < -math.pi then
				--add = add + 2*math.pi
				while diff < -math.pi do
					add = add + 2*math.pi
					diff = diff + 2*math.pi
					--print"xxxxxxxxxhigher"
				end
			end
			last = v + add
			return last
		end
end
function PhaseDelayUnwrap(Hz)
	local phf=PhaseShiftUnwrap(Hz)
	return function(i)
		return -phf(i)/(i~=0 and i or 1)
	end
end
function ampDb(v,L0)
	L0 = L0 or 1
	return 20*math.log10(v/L0)
end
function Db2amp(v,L0)
	L0 = L0 or 1
	return 10^(v/20)*L0
end
function UnitCircleEval(fun,x)
	return fun(complex.exp(complex.new(0,1)*x))
end

--receives phase data table
--returns unwraped phase data table
function UnwrapPhase(t)
	local res = {t[1]}
	local last = t[1]
	local add = 0
	for i,v in ipairs(t) do
		local diff = v + add - last
		if dif > math.pi then
			add = add - 2*math.pi
		elseif dif < -math.pi then
			add = add + 2*math.pi
		end
		res[i] = v + add
		last = res[i]
	end
	return res
end
function Phase(c)
	return math.atan2(complex.imag(c),complex.real(c))
end

function ArrayReverse(t)
	local res = {}
	for i=#t,1,-1 do
		res[#t-i+1]=t[i]
	end
	return res
end
--with den max degree coef to 1
--fits rational Hz = Bz / Az by minimizing || Hz * Az - Bz || 
function cfit_rational(h,xi,N,M,weights)
	local function expjf(f)
		return complex.exp(complex.new(0,1)*f)
	end
	local function unfold_complex(i,h)
		if i%2==1 then 
			return complex.real(h[(i+1)/2]) 
		else 
			return complex.imag(h[i/2]) 
		end
	end
	local Len = #h
	assert(Len == #xi)
	assert(M > 0)
	local W0
	if weights then
		W0=matrix.new(Len*2,1,function(i)
				local ifolded = (i+(i%2))/2
				return weights[ifolded] 
			end)
	end
	--local y0=matrix.new(Len*2,1,function(i) return -unfold_complex(i,h) end)
	local y0=matrix.new(Len*2,1,function(i)
				local ifolded = (i+(i%2))/2
				if i%2==1 then 
					return complex.real(-h[ifolded]*(expjf(xi[ifolded])^(M-1))) 
				else 
					return complex.imag(-h[ifolded]*(expjf(xi[ifolded])^(M-1))) 
				end
			end)
	local X = matrix.new(Len*2, N+M-1,function(i,j)
				local ifolded = (i+(i%2))/2
				local efreq=expjf(xi[ifolded])
				if j < M then
					if i%2==1 then 
						return complex.real((efreq^(j-1))*h[ifolded])
					else
						return complex.imag((efreq^(j-1))*h[ifolded])
					end
				elseif j==M then
					if i%2==1 then 
						return -1
					else
						return 0
					end
				else
					if i%2==1 then 
						return complex.real(-(efreq)^(j-M))
					else
						return complex.imag(-(efreq)^(j-M))
					end
				end	
		end)
	local co, chisq, cov = num.linfit(X, y0,W0)
	--print("chisq", chisq)
	--print(cov)
	local coA={}
	for i=1,M-1 do coA[i]=co[i] end
	coA[M]=1
	local coB = {}
	for i=1,N do coB[i]=co[M-1+i] end
	return coB,coA,chisq,cov
end
--with den 0 degree coef to 1
function cfit_rational2(h,xi,N,M)
	local function expjf(f)
		return complex.exp(complex.new(0,1)*f)
	end
	local function unfold_complex(i,h)
		if i%2==1 then 
			return complex.real(h[(i+1)/2]) 
		else 
			return complex.imag(h[i/2]) 
		end
	end
	local Len = #h
	assert(Len == #xi)
	assert(M > 0)
	
	local y0=matrix.new(Len*2,1,function(i) return -unfold_complex(i,h) end)
	local X = matrix.new(Len*2, N+M-1,function(i,j)
				local ifolded = (i+(i%2))/2
				local efreq=expjf(xi[ifolded])
				if j < M then
					if i%2==1 then 
						return complex.real((efreq^j)*h[ifolded])
					else
						return complex.imag((efreq^j)*h[ifolded])
					end
				elseif j==M then
					if i%2==1 then 
						return -1
					else
						return 0
					end
				else
					if i%2==1 then 
						return complex.real(-(efreq)^(j-M))
					else
						return complex.imag(-(efreq)^(j-M))
					end
				end	
		end)
	local co, chisq, cov = num.linfit(X, y0)
	--print("chisq", chisq)
	--print(cov)
	local coA={1}
	for i=1,M-1 do coA[i+1]=co[i] end
	local coB = {}
	for i=1,N do coB[i]=co[M-1+i] end
   return coB,coA,chisq,cov
end
-- computes the minimum phase complex transfer from a desired amplitude transfer
-- does it by making the cepstrum causal
function minPhase(desired)
	local nfft = 2*(matrix.dim(desired) - 1)
	local sq = matrix.new(nfft, 1)
	local ft = num.fft(sq)
	--Mag design with log
	local Nikf=#ft/2
	for k=0,Nikf  do  
		ft[k] = complex.log(desired[k+1])
	end
	
	local ceps = num.fftinv(ft)
	--fold to causal in time domain
	local Nik=Nikf+1
	local ceps2 = matrix.new(nfft, 1)
	ceps2[1] = ceps[1] -- *2 ??
	ceps2[Nik] = ceps[Nik]
	for k=2,Nik-1 do
		ceps2[k] = ceps[k] + ceps[nfft - k + 2]
	end
	for k=Nik+1,nfft do
		ceps2[k] = 0
	end
	--gets freq domain again
	local ft2 = num.fft(ceps2)
	return matrix.cnew(Nik, 1, function(i) return complex.exp(ft2[i-1]) end)
end
--nfft: databins, nzeros desired, npoles desired, trunc: make 0 coeffs less than trunc,
--func: function returnning amplitude for a given freq in angular frequency
function FilterFromFFT(nzeros,npoles,trunc,values,weights)

	local Nikf =#values --nfft/2 + 1
	local x = matrix.new(Nikf, 1, function(i) return (i-1)/(Nikf-1) * math.pi end)
	--local desiredMag = matrix.new(Nikf,1,function(i) return func(x[i]) end)
	--local mPh=minPhase(desiredMag)
	--unwrap phase--------------
	----------------------------
	local mPh = matrix.vec(values)
	print("tostring(mPh[1])",tostring(mPh[1]))
	local coB,coA,chi = cfit_rational(mPh,x,nzeros,npoles,weights)
	local HzminPH=FilterPoly(Polynomial(coB),Polynomial(coA))
	--HzminPH=HzminPH:Normalize()
	HzminPH=HzminPH:Truncate(trunc):realCoefs()
	return HzminPH,chi
end
function FilterFromFFTAmp(nzeros,npoles,trunc,values,weights)
	local Nikf = #values -- nfft/2 + 1
	--local x = matrix.new(Nikf, 1, |i|  (i-1)/(Nikf-1) * math.pi)
	local x = matrix.new(Nikf, 1,function(i) return (i-1)/(Nikf-1) * math.pi end)
	local desiredMag = matrix.new(Nikf,1,function(i) return complex.abs(values[i]) end)
	local mPh=minPhase(desiredMag)
	local coB,coA,chi = cfit_rational(mPh,x,nzeros,npoles,weights)
	local HzminPH=FilterPoly(Polynomial(coB),Polynomial(coA))
	--HzminPH=HzminPH:Normalize()
	HzminPH=HzminPH:Truncate(trunc):realCoefs()
	return HzminPH,chi
end
function FilterFromAmp(nfft,nzeros,npoles,trunc,func)
	local Nikf = nfft/2 + 1
	--local x = matrix.new(Nikf, 1, |i|  (i-1)/(Nikf-1) * math.pi)
	local x = matrix.new(Nikf, 1,function(i) return (i-1)/(Nikf-1) * math.pi end)
	local desiredMag = matrix.new(Nikf,1,function(i) return func(x[i]) end)
	local mPh=minPhase(desiredMag)
	local coB,coA,chi = cfit_rational(mPh,x,nzeros,npoles)
	local HzminPH=FilterPoly(Polynomial(coB),Polynomial(coA))
	--HzminPH=HzminPH:Normalize()
	HzminPH=HzminPH:Truncate(trunc):realCoefs()
	return HzminPH,chi
end
---------------------durbin
function EvalZm1(Hz)
	local aa = RatPoly(Hz.Num,Hz.Den)(RatPoly({1},{0,1}))
	if type(aa)~="number" then aa=aa:Simplify() end
	return aa
end
function Flip(Hz)
	local zN = Polynomial{0}
	zN[Hz.Den.deg] = 1
	local zminusN = RatPoly({1},zN)
	return zminusN*EvalZm1(Hz)
end
function Durbin_recursion(Hz)
	local Kaes = {}
	local N = Hz.Den.deg
	local HzN = Hz
	print("HzN durbin ",tostring(HzN))
	for i=N,1,-1 do
		Kaes[i] = HzN.Num[0]
		assert(math.abs(Kaes[i]) < 1,"inestable filter coeffs in Durbin K:"..tostring(Kaes[i]))
		HzN = (HzN - Kaes[i]*Flip(HzN))/(1 - Kaes[i]*Kaes[i])
		HzN = HzN:Simplify():Normalize()
		--print("HzN d ",tostring(HzN))
	end
	return Kaes
end

function Durbin_recursionInv(Kaes)
	local HzN = RatPoly({1},{1})
	print("HzN di ",tostring(HzN))
	for i=1,#Kaes do
		local zN = Polynomial{0}
		--zN[i] = Kaes[i]
		--HzN = HzN + EvalZm1(RatPoly(zN,{1})
		HzN = (HzN + Zpow(-i)*Kaes[i]*EvalZm1(HzN)) --/(1 - Kaes[i]*Kaes[i])
		
		print("HzN di ",tostring(HzN))
		--HzN = HzN:Simplify():Normalize()
		--print("HzN nor",tostring(HzN))
	end
	return HzN
end