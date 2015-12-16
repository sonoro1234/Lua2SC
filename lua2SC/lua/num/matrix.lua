local matrix_mt = {}
matrix_mt.__index = matrix_mt
function matrix(t)
	return setmetatable(t,matrix_mt)
end
local function is_matrix(a)
	return getmetatable(a)==matrix_mt
end
function matrix_mt:size()
	return #self,#self[1]
end
function matrix_mt:new(m,n) -- Define new Matrix
	local mt = {} -- Make new array for Matrix
	for i=1,m do mt[i] = {} end -- Null matrix elements
	return matrix(mt) -- Set Matrix metatable
end
function matrix_mt.__mul(a,b)
	if not is_matrix(a) then a,b = b,a end
	local m,n = a:size()
	local res = a:new(m,n)
	if not is_matrix(b) then
		for i=1,m do for j=1,n do res[i][j] = b*a[i][j] end end
	else
		local mb,nb = b:size()
		assert(n==mb)
		for i=1,m do
			for j=1,nb do
				local sum = 0
				for k=1,n do sum = sum + a[i][k]*b[k][j] end
				res[i][j] = sum
			end
		end
	end
	return res
end
function matrix_mt.__tostring(mx) -- Convert to string for printing
	local m,n = mx:size()
	local s = '{{'
	for i=1,m do
		for j=1,n-1 do 
		s = s..(tostring(mx[i][j]) or '..')..', ' end
		s = s..(tostring(mx[i][n]) or '..')..'}'
		if i==m then s = s..'}' else s = s..',\n{' end
	end
	return s -- Printable string
end
--[[
require"num.complex"
require"num.filter_design"

function MM(k)
	return matrix{{Zpow(1),k*Zpow(-1)},{k*Zpow(1),Zpow(-1)}}*(1/(k+1))
end

function KLJunctionGain(kaes,rG,rL)
	kaes = TA(kaes):reverse()
	local res = matrix{{1},{rL}}
	for i,k in ipairs(kaes) do
		res = MM(k)*res
	end
	res = matrix{{Zpow(1),-rG*Zpow(-1)}}*res
	return 1/res[1][1]
end
function KLJunctionGain2(kaes,rG,rL)

	local res = matrix{{Zpow(1),-rG*Zpow(-1)}}--matrix{{1},{rL}}
	for i,k in ipairs(kaes) do
		res = res*MM(k)
	end
	res = res*matrix{{1},{rL}}
	return 1/res[1][1]
end

require"sc.utils"
require"sc.utilsstream"
Tract = require"num.Tract"(18,nil,nil,false)


function Areas2KK(AA)
	local Kaes = {}

	for i=2,#AA  do
		local num = (AA[i-1]-AA[i])
		local den = (AA[i]+AA[i-1])
		if AA[i]==math.huge then 
			Kaes[i-1] = 1
		else
			if num == 0 or den == 0 then
				Kaes[i-1] = 0
			else
				Kaes[i-1] = num/den
			end
		end
	end
	return Kaes
end

areas = Tract.areas.E
kaes = Areas2KK(areas)

print(KLJunctionGain({1,2,3},0.95,0.97))
print(KLJunctionGain2({1,2,3},0.95,0.97))

fil = KLJunctionGain(kaes,0.95,0.97)

print(MM(3))
pp = FilterPoly({1,1},{1})--*Zpow(-1)
print(pp)
pp2 = RatPoly({1,1},{1})--*Zpow(-1)
print(pp2)
aa = matrix{{1,1},{0,1}}
vec = matrix{{2,3}}
vec2 = matrix{{2},{3}}
print(aa:size())

print(aa*vec2)
--]]

