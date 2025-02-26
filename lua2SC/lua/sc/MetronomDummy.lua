

local meta = {
__index = function(_,_) return function() end end
}

theMetro = setmetatable({},meta)