function ss(...)
	print(select(1, ...))
	print(select(2, ...))
	local xx ={select(1, ...),{select(2, ...)}}
	prtable(xx)
end

ss(1,2,3,4,5,6,7,8)