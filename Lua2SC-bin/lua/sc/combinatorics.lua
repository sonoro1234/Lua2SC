require("init.utils")
require("random")
RANDOM=random.new() 
RANDOM:seed(os.time())

function scramble(t)
	local perm = permutationN(#t)
	local res = {}
	for i,v in ipairs(perm) do
		res[i]=t[v]
	end
	return res
end
function permutationN(n)
	return permutation(seriesFill(n))
end
function permutation(t)
	--tt=copyObj(t)
	--tt = deepcopy(t)
	local tt=copyiTable(t)
	local res={}
	for i=1,#t do
		j=RANDOM:valuei(1,#tt)
		table.insert(res,tt[j])
		table.remove(tt,j)
	end
	return res
end
function shuffle(list)
	local _shuffled = {}
	for i=1,#list do
		local randPos = RANDOM:valuei(1,i)
		_shuffled[i] = _shuffled[randPos]
        _shuffled[randPos] = list[i]
	end
	return _shuffled
end

function permutations(t)
	
	if #t==1 then return {t} end
	local res={}
	for i,v in ipairs(t) do

		local tt=copyiTable(t)
		table.remove(tt,i)
		
		local pp=permutations(tt)
		for i2,v2 in ipairs(pp) do
			table.insert(v2,v)
		end
		res=concat2Tables(res,pp)
	end
	
	return res
end
--n: total ,p:parts,m:minimum part,q:quant
function compositions(n,p,m,q)
	m=m or 1
	q=q or m
	if p==1 then
		assert(n>=m,"Partitions Error:Total less than minimum")
		return {{n}}
	end 
	local minn=m
	local maxn=n-((p-1)*m)
	
	local res={}
	for i=minn,maxn,q do
		local pp=compositions(n-i,p-1,m,q)
		for i2,v in ipairs(pp) do
			table.insert(v,i)
		end
		res=concat2Tables(res,pp)
	end
	return res
end
--not equiprobable
function partition(n,p,m,q)
	m=m or 1
	q=q or m
	if p==1 then
		assert(n>=m,"Partitions Error:Total less than minimum")
		return {n}
	end 
	local maxn=n-((p-1)*m)
	if m <=maxn then
		local hmax=math.floor((n-p*m)/q)
		local h=RANDOM:valuei(0,hmax)
		local i=m+h*q
		--print("hmax:",hmax," h:",h," i:",i)
		local pp=partition(n-i,p-1,m,q)
		table.insert(pp,i)
		return pp
	else
		return {}
	end
end
--n: total ,p:parts,m:minimum part,q:quant
function compositionN(n,p)
	assert(n > 0) 
	assert(p > 0)
	assert (n >= p)
	if p==1 then return {n} end
	local holes=seriesFill(n-1)
	local ht=chooseN(holes,p-1)
	table.sort(ht)
	ht[p] = n
	local res = {}
	local last = 0
	for i=1,p do
		res[i]=ht[i] - last
		last = ht[i]
	end
	return res
end
--with m minimum part
function compositionNR(n,p,m)
	local res=compositionN(n-(m-1)*p,p)
	for i,v in ipairs(res) do
		res[i] = v + m - 1
	end
	return res
end
function composition(n,p,m,q)
	m=m or 1
	q=q or m
	local Q = 1/q
	local res = compositionNR(Q*n,p,m*Q)
	for i,v in ipairs(res) do
		res[i] = v * q
	end
	return res
end
function choose(a)
	return a[RANDOM:valuei(1,#a)]
end
function chooseN(t,n)
	assert((#t >= n) and (n > 0))
	local res = {}
	local tt = copyiTable(t)
	for i=1,n do
		local ind = RANDOM:valuei(1,#tt)
		res[i]=tt[ind]
		table.remove(tt,ind)
	end
	return res
end

-- prtable(random)
-- prtable(table)
-- rr=random.new() 
-- rr:seed(os.time())
-- print(rr:value().."\n")

-- print(rr:choose({34,44,54,64}).."\n")
--print(rr:valuei(7,3))
-- pritable(rr:partition(16,4))
-- pritable(permutations({"a","b","c"}))
-- pritable(rr.permutation({"a","b","c"}))