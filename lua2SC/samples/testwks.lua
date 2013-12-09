

mt = {}
function mt:pepe()
end

kkk = {}
function kkk:juan()
end

--Stream.
--partition(sdf,sf
--setmetatable(kkk,mt)

print(ToStr(ListStepsStream,true))

--ll.ii=0
aa = 1
while false do
	aa = aa + 1
end

print(string.gsub("adf.er","%.","%%%."))

print(string.match("ff,df,fd",","))

function stsplit(s,c)
	local t = {}
	local pat = ""..c.."?([^"..c.."]*)"..c.."?"
	for w in string.gmatch(s, pat) do  -- ";?[^;]+;?"
		t[#t + 1] = w
	end
	return t
end
function string:split(sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end
function split(str, pat)
	local t = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		--if s ~= 1 then --or cap ~= "" then
		table.insert(t,cap)
		--end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	elseif str:sub(-1)==pat then
		table.insert(t, "")
	end
	return t
end


word = "e,sd,fg,"
prtable(stsplit(word,","))
prtable(word:split(","))
prtable(split(word,","))
prtable(Debugger)
