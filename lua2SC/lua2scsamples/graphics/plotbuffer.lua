
local sclua = require"sclua.Server"
local s = sclua.Server()

buf = s.Buffer()
buf:alloc(1024)

t = {}
for i=1,1024 do
	t[i] = math.sin(i/30)
end
s.sync()
buf:setn(0,1024,t)

PlotBuffer(buf)--,200,100)