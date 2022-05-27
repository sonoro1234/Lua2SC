local file = io.open("dumpedugens.lua")
local str = file:read"*a"
file:close()

str = str:gsub("^.+For help press F1%.","")
str = str:gsub("WARNING","%-%-WARNING")
str = str:gsub("(%-%-%]%])(.+)$","%1")

local file = io.open("dumpedugens.lua","w")
file:write(str)
file:close()

print"done"