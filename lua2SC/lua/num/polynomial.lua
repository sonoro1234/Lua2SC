--Polynomial
--class for polynomial and rational calculations by Victor Bombi 
--TODO IsPolynomial must be local when filter_design arranged
-------------------------------------------------------------------
-- adaptors for  complex
local ZEROc = complex.new(0,0)
local function isZero(a)
	return a == 0 or a == ZEROc
end
local function to_real(c)
	if type(c) =="number" then
		return c
	else
		return complex.real(c)
	end
end
local function truncate(c,tol)
	tol = tol or 1e-12
	if type(c) == "number" then
		return (math.abs(c) < tol) and 0 or c
	end
	local re,im =complex.real(c),complex.imag(c)
	if math.abs(re) < tol then re=0 end
	if math.abs(im) < tol then im=0 end
	return complex.new(re,im)
end
--------------------------------------------------------------------
local function IsPolynomial(P)
	return getmetatable(P)==Polynomial_mt
end
local function IsRatPoly(P)
	return type(P)=="table" and P.isRatPoly
end
Polynomial_mt ={}
local function ToPoly(a)
	if getmetatable(a)==Polynomial_mt then
		return a
	elseif type(a)=="number" then
		return Polynomial{a}
	elseif is_complex(a) then
		return Polynomial{a}
	else
		--return Polynomial({a},a)
		print("ToPoly type",type(a))
		print("topoly",a)
		return Polynomial(a)
	end
end
local function prepareOpRes(a,b)
	local A = ToPoly(a)
	local B = ToPoly(b)
	return A,B,Polynomial{}
end
function Polynomial_mt.__add(a,b)
	if IsRatPoly(b) then
		return b + a
	end
	local A,B,res = prepareOpRes(a,b)
	
	local maxdeg = math.max(A.deg,B.deg)
	for i=0,maxdeg do
		res[i] = A[i] + B[i]
	end
	return res
end
function Polynomial_mt.__sub(a,b)
	return a +(- b)
end
function Polynomial_mt.__unm(A)
	local res = Polynomial{}
	--for i=0,A.deg do
	for i,v in pairs(A.pol) do
		res[i] = -A[i]
	end
	return res
end
--Evaluation
function Polynomial_mt.__call(t,val)
	local res = t[t.deg]
	for i=t.deg-1,0,-1 do
		res = val * res + t[i]
	end
	return res
end
function Polynomial_mt.__mul(a,b)
	if IsRatPoly(b) then
		return b * a
	end
	if not IsPolynomial(b) then --must be number or complex
		local res = Polynomial{}
		for k,v in pairs(a.pol) do
			res[k] = v * b
		end
		return res
	end
	
	local A,B,res = prepareOpRes(a,b)
	
	for i=0,A.deg do
		for j=0,B.deg do
			res[i+j] = A[i] * B[j] + (res[i+j] or 0)
		end
	end
	return res
end
function Polynomial_mt.__pow(a,b)
	assert(type(b)=="number")
	assert(math.floor(b)==b and b > 0)
	local res = Polynomial{1}
	for i=1,b do
		res = res * a
	end
	return res
end
--returns {Q,R}
function Polynomial_mt.__div(a,b)
	if IsRatPoly(b) then
		return b:new(a)/b
	end
	local A,B,Q = prepareOpRes(a,b)
	local R = Polynomial{}
	--normalize
	local fac = 1/B[B.deg]
	A = A * fac
	B = B * fac
	------------
	for j=0,A.deg do
		R[j]=A[j]
	end
	for k=A.deg-B.deg,0,-1 do
		Q[k]=R[B.deg + k]/B[B.deg]
		for j=B.deg+k-1,k,-1 do
			R[j]=R[j]-Q[k]*B[j-k]
		end
	end
	for j=B.deg,A.deg do R[j]=nil end
	return {Q=Q,R=R}
end
function Polynomial_mt.GetCoefs(t)
	local res = {}
	for i=0,t.deg do
		res[i+1] = t[i]
	end
	return res
end
function Polynomial_mt.derive(t)
	local res = Polynomial{}
	for i=1,t.deg do
		res[i-1] = i*t[i]
	end
	return res
end
function Polynomial_mt.__index(t,key)
	if type(key)=="number" and (math.floor(key)==key) then --integer key
		return rawget(t.pol,key) or 0
	else
		return rawget(getmetatable(t),key)
	end
end
function Polynomial_mt.__newindex(t,key,val)
	local value = val
	if type(key)=="number" and (math.floor(key)==key) then --integer key
		if val and not isZero(val) then --val~=t.zero then
			if t.deg < key then
				t.deg = key
			end
		else
			--print("reduzco deg")
			value = nil
			if t.deg == key then
				t.deg=-1
				for i=key-1,-1,-1 do
					if t[i]~=0 then
						t.deg=i
						break
					end
				end
			end
		end
		rawset(t.pol,key,value)
		return
	end
	rawset(t,key,value)
end
function Polynomial_mt.__tostring(t)
	local str={"["}
	for i=0,t.deg do
		str[#str+1]=tostring(t[i])
	end
	str[#str+1]="]"
	return table.concat(str,",")
end
function Polynomial_mt.BAK__tostring(t)
	local str={}
	for i=0,t.deg do
		str[#str+1]="("..tostring(t[i])..")X^"..i
	end
	--str[#str+1]="]"
	return table.concat(str,"+")
end
--expects coefs from a0 to an
function Polynomial(t)
	local t = t or {}
	local a = {}
	assert(not(#t > 1 and isZero(t[#t])),"zero value in Polynomial max degree coef ") --..tb2st(t))
	a.deg = #t-1
	a.pol ={}
	for i,v in ipairs(t) do
		a.pol[i-1]=v
	end
	return setmetatable(a,Polynomial_mt)
end
function PolyFromRoots(t,one)
	local res = Polynomial{1}
	for i,v in ipairs(t) do
		res = res * Polynomial{-v,1}
	end
	return res
end
function Polynomial_mt:reverse()
	local res = Polynomial{}
	local t = self:GetCoefs()
	for i=#t,1,-1 do
		res[#t-i]=t[i]
	end
	return res
end
--tol minimum distance between different roots (see solvePoly2)
function Polynomial_mt:roots(tol)
	return solvePoly2(self:GetCoefs(),tol)
end
function Polynomial_mt.realCoefs(P)
	local real = {}
	for i=0,P.deg do
		real[i+1] = to_real(P[i])
	end
	return Polynomial(real)
end
function Polynomial_mt.MCD(a,b,tol)
	local tol = tol or 1e-12
	local r
	if a.deg < b.deg  then b,a = a,b end
	if b.deg == -1 then return 1 end
	while true do
		--normalize
		local fac = 1/b[b.deg]
		a=a*fac
		b=b*fac
		--------------
		r=(a/b).R
		--print("MCD xxxxxxxxxxxxx",tostring(a),tostring(b),tostring(r))
		r = r:Truncate(tol)
		if r.deg == -1 or (r.deg == 0 and isZero(r[0])) then 
			--print("acabo MCD xxxxxxxxxxxxx",tostring(b * (1/b[b.deg])))
			return b * (1/b[b.deg])  --(b/b[b.deg]).Q 
		end
		--r = r * (1/r[r.deg])
		a,b = b,r
	end
end
function Polynomial_mt.MCM(a,b,tol)
	local gcd = a:MCD(b,tol)
	local A = a / gcd
	local B = b / gcd
	--print("MCM ",tostring(A.R),tostring(B.R))
	--print("MCM ",tostring(A.Q * B.Q) , tostring(gcd), tostring(A.Q), tostring(B.Q))
	return a * B.Q , gcd, A.Q , B.Q
end
function Polynomial_mt.Truncate(R,minv)

	local res = Polynomial{}
	for i=0,R.deg do
		res[i]=truncate(R[i],minv)
	end
	return res
end
------------------------------------------------
RationalPoly_mt = {}
RationalPoly_mt.Num = Polynomial{1}
RationalPoly_mt.Den = Polynomial{1}
function RationalPoly_mt:new(Num,Den)
	local Num = Num or {1}
	local Den = Den or {1}
	local rat = {}
	rat.Num = getmetatable(Num)==Polynomial_mt and Num or Polynomial(Num)
	rat.Den = getmetatable(Den)==Polynomial_mt and Den or Polynomial(Den)
	setmetatable(rat, getmetatable(self))
	----self.__index = self
	--[[
	setmetatable(rat, self)
	self.__index = self
	local m=getmetatable(self)
    if m then
        for k,v in pairs(m) do
            if not rawget(self,k) and k:match("^__") then
                self[k] = m[k]
            end
        end
    end
	--]]
	return rat
end
RationalPoly_mt.__index = RationalPoly_mt
--setmetatable(RationalPoly_mt, RationalPoly_mt)
RationalPoly_mt.isRatPoly = true
function RationalPoly_mt:ToRatPoly(a)
	if type(a)=="table" and a.isRatPoly then
		return a -- RatPoly or inherited class
	elseif getmetatable(a)==Polynomial_mt then
		return self:new(a)
	elseif type(a)=="number" then
		return self:new(Polynomial{a})
	else --expect complex
		return self:new(Polynomial{a})
	end
end
local function prepareOp(a,b)
	if type(a)=="table" and a.isRatPoly then
		return a,a:ToRatPoly(b)
	else
		return b:ToRatPoly(a),b
	end
end
function RationalPoly_mt.__mul(a,b)
	local A,B = prepareOp(a,b)
	return A:new(A.Num * B.Num,A.Den * B.Den)
end
function RationalPoly_mt.__pow(a,b)
	assert(type(b)=="number")
	assert(math.floor(b)==b)
	local res = a:new(a.Num,a.Den)
	for i=2,b do
		res = res * a
	end
	return res
end
function RationalPoly_mt.__div(a,b)
	local A,B = prepareOp(a,b)
	return A:new(A.Num * B.Den,A.Den * B.Num)
end
function RationalPoly_mt.__add(a,b)
	local A,B = prepareOp(a,b)
	local mcm,gcd,Af,Bf = A.Den:MCM(B.Den)
	return A:new(A.Num*Bf + B.Num*Af,mcm) --:Simplify()
end
function RationalPoly_mt.__sub(a,b)
	return a + (-b)
end
function RationalPoly_mt.__unm(a)
	return -1 * a
end
function RationalPoly_mt.__tostring(t)
	return tostring(t.Num).." / "..tostring(t.Den)
end
function RationalPoly_mt.__call(t,val)
	local tden = t.Den(val)
	if IsRatPoly(tden) then
		return t:ToRatPoly(t.Num(val))/tden
	else
		return t.Num(val)/tden
	end
end
function RationalPoly_mt:Normalize()
	local fac = 1/self.Den[self.Den.deg]
	return self:new(self.Num*fac,self.Den*fac)
end
function RationalPoly_mt:Simplify(tol)
	--self = self:Truncate()
	local mcd = self.Num:MCD(self.Den,tol)
	return self:new((self.Num/mcd).Q,(self.Den/mcd).Q)
end
function RationalPoly_mt:derive()
	local B = self.Num ; local A = self.Den
	local derB = B:derive()
	local derA = A:derive()
	return self:new(derB*A-derA*B,A*A):Simplify()
end

function RationalPoly_mt:Truncate(minv)
	local Num=self.Num:Truncate(minv)
	local Den=self.Den:Truncate(minv)
	return self:new(Num,Den)
end
-- performs partial fraction decomposition or Rational, tol is for root
-- returns table of {root = ro, coeffs = { multiplicity ordered coeffs }} , integer part
function RationalPoly_mt.pfe(Hz,tol)
	local tol = tol or 0.0001;
	--resi2 with deflaccion already done
	local function resi2b(u,v,pole,n,k)
		n = n or 1; k = k or n; 
		local function fact(n)
			if n == 0 then return 1
			else return n*fact(n-1) 
			end
		end
		local ration = Hz:new(u,v)
		for j = 1,n-k do ration = ration:derive(); end
		local c = 1; if k < n then c = fact(n-k); end
		return ration(pole) / c;
	end
	Hz = Hz:Normalize()
	local B= Hz.Num
	local A= Hz.Den
	local K = Polynomial{}
	if B.deg >= A.deg then
		local div=B/A
		K,B = div.Q,div.R
	end
	local q1,q2,repeated = A:roots(tol)
	--print("roots ",q1,q2,repeated)
	local pfearr = {}
	if repeated then -- Section for repeated root problem.
		for i = 1,#q1 do
			local pole = q1[i]; local n = q2[i];
			local vb =Polynomial{1}
			for ib=1,i-1 do vb = vb * PolyFromRoots{q1[ib]}^q2[ib] end
			for ib=i+1,#q1 do vb = vb * PolyFromRoots{q1[ib]}^q2[ib] end
			pfearr[#pfearr + 1]={root=pole,coeffs={}}
			local thiscoeffs = pfearr[#pfearr].coeffs
			for indx = 1,n do
				thiscoeffs[#thiscoeffs + 1] = resi2b(B,vb,pole,n,indx);
			end
		end
	else   -- No repeated roots.
		--local ro = TA(q1)
		for i = 1,#q1  do
			--local temp = PolyFromRoots(ro(1,i-1)..ro(i+1,#ro));
			-- without TA:
			local ro = {}
			for ib,v in ipairs(q1) do
				if ib~=i then ro[#ro + 1] = v end
			end
			local temp = PolyFromRoots(ro);
			
			pfearr[#pfearr + 1]={root=q1[i],coeffs={ B(q1[i]) / temp(q1[i]) }}
		end
	end
	return pfearr,K 
end

function RatPoly(Num,Den)
	local Num = Num or {1}
	local Den = Den or {1}
	local rat = {}
	rat.Num = IsPolynomial(Num) and Num or Polynomial(Num)
	rat.Den = IsPolynomial(Den) and Den or Polynomial(Den)
	setmetatable(rat, RationalPoly_mt)
	return rat
end
-------------------------- for Ratpolys in Z^-1
--expects coefs from an*Z^(-n) to a0
--and can be called with PolyFromRoots
function ZRatPoly(B,A,dosimp)
	local A = A or {1}
	local Num = IsPolynomial(B) and B or Polynomial(B)
	local Den = IsPolynomial(A) and A or Polynomial(A)
	--return (RatPoly(Num,Den)*Zpow(-Num.deg)*Zpow(Den.deg)) --:Simplify()
	if dosimp then
		return (RatPoly(Num,Den)*Zpow(Den.deg - Num.deg)):Simplify()
	else
		return RatPoly(Num,Den)*Zpow(Den.deg - Num.deg)
	end
end
function Zpow(i)
	assert(math.floor(i)==i)
	local zN = Polynomial{}
	zN[math.abs(i)]=1
	if i > 0 then
		return RatPoly(zN,{1})
	else
		return RatPoly({1},zN)
	end
end
--pfe in Z^1
function RationalPoly_mt.pfeZ(Hz,tol)
	local Hz2 = Hz:new(Hz.Num:reverse(),Hz.Den:reverse())
	local pfe,k=Hz2:pfe(tol)
	for i,v in ipairs(pfe) do 
		v.root=1/v.root
		for mult,coef in ipairs(v.coeffs) do
			v.coeffs[mult] =  coef * ((-v.root) ^mult);
		end	
	end
	return pfe,ZRatPoly(k:reverse():GetCoefs())
end
function pfe2ZRatPoly(pfearr,k)
	local res = k 
	for _,v in ipairs(pfearr) do
		for mult,coef in ipairs(v.coeffs) do
			res = res + ZRatPoly({coef},PolyFromRoots{v.root}^mult)
		end
	end
	return res
end
function pfe2RatPoly(pfearr,k)
	local res = k
	for _,v in ipairs(pfearr) do
		for mult,coef in ipairs(v.coeffs) do
			res = res + RatPoly({coef},PolyFromRoots{v.root}^mult)
		end
	end
	return res
end
function RationalPoly_mt:realCoefs()
	return self:new(self.Num:realCoefs(),self.Den:realCoefs())
end


-----------------------------------------
function MCD(a,b)
	local r
	if a < b then b,a = a,b end
	while true do
		r = a%b
		if r == 0 then return b end
		print(a,b,r)
		a,b = b,r
	end
end
function MCM(a,b)
	return a*b/MCD(a,b)
end
--------------------------------------------
