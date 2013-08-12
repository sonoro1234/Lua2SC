-- test random library

--require"random"

print(random.version)
print""

r=random.new(1234)
print("new",r:value(),r:value(),r:value())
print("more",r:value(),r:value(),r:value())
r:seed(1234)
print("seed",r:value(),r:value(),r:value())
r:seed(5678)
print("seed",r:value(),r:value(),r:value())
r:seed()
s=r:clone()
print("seed",r:value(),r:value(),r:value())
print("more",r:value(),r:value(),r:value())
print("clone",s:value(),s:value(),s:value())

r:seed(os.time())
N=100000
print""
print("range","distribution",N)

function test(N,a,b)
 local S={0,0,0,0,0,0,0,0,0,0,0}
 for i=1,N do
  local i=r:valuei(a,b)
  S[i]=S[i]+1
 end
 for i=1,9 do
  S[i]=math.floor(100*S[i]/N+0.5)
 end
 print(a..".."..b,S[1],S[2],S[3],S[4],S[5],S[6],S[7],S[8])
end

test(N,1,8)
test(N,2,4)
test(N,3,7)

function test(w,f)
 local t=os.clock()
 for i=1,N do
  f()
 end
 t=os.clock()-t
 print(w,math.floor(N/t/1000),N,t)
end

N=3*N
print""
print("","1000/s","N","time")
test("math",function () return math.random() end)
test("random",function () return random.value(r) end)

print""
print(random.version)

-- eof
