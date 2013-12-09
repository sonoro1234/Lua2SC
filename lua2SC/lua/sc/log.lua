file=nil
function prfile(d)
		file:write("\n\n")
		for i=1,string.len(d) do
			file:write(string.format("%4s",string.sub(d,i,i)))
		end
		file:write("\n")
		for i=1,string.len(d) do
			file:write(string.format(" %3u",string.byte(d,i,i)))
		end
		file:flush()
end
table.insert(initCbCallbacks,function() io.close(file) end)
file=io.open("logsc.txt","w+")
table.insert(resetCbCallbacks,function() io.close(file) end)