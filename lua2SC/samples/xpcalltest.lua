--xpcall(function(a) print(a);print(ll.ss) end,function(...) print(...) end,"kkk")

--if not pcall(function(a) print(a);print(ll,ss) end,"kkk") then
--	print("error en pcall")
--end

function main()
	t1 = os.clock()
	aa = 1
	aaa = {}
	for i=1,10000000 do
		aa = aa + 1
		aaa[i] = aa
	end
	print("time: ",os.clock() - t1,aa)
end

if not xpcall(main,function(...) print("errrr",...) end,"kkk") then print("error en pcall") end
--main()