

lanes = require"lanes".configure()
core = require"lanes.core"
print("maxprio",core.max_prio)--.max_prio)
l=lanes.linda()

f = function( l)
    print "lane ready"
    while true do
--l:receive( 0, "dummy")
    end
end

g = lanes.gen( "*", f)
h = g( l)

print( "lane handle: " .. tostring( h))

l:receive( 1, "dummy")
print"going to cancel"
a,b=pcall(function() h:cancel( 0.1, true,1) end)

print("cancel:",a,b)

io.read()
print"end"