--[[
		     LIBRARY FOR COMPLEX NUMBERS

Philippe CASTAGLIOLA
Université de Nantes & IRCCyN UMR CNRS 6597
WWW: http://philippe.castagliola.free.fr/

--]]
--if type(jit) == 'table' then print"is jitxxxxxxxxxxxxxxxxxxxxxx" ; return require"num.ljcomplex" end

if type(jit) == 'table' then print"is jitxxxxxxxxxxxxxxxxxxxxxx" ; local complext = require"num.complexjit"; return complext end

local error_=error
local function error(fmt,...)  error_(string.format(fmt,...)) end

local assert_=assert
local function assert(b,fmt,...) return fmt and assert_(b,string.format(fmt,...)) or assert_(b) end

type_=type

--------------------------------------------------------------------------------
local math_={}

for _,v in pairs{"abs","acos","asin","atan","cos","exp","log","pow","sin","sqrt","tan"} do
  math_[v]=math[v]
end

--------------------------------------------------------------------------------
function math.acosh(z)
--------------------------------------------------------------------------------
  return math_.log(z+math_.sqrt(z*z-1))
end

--------------------------------------------------------------------------------
function math.asinh(z)
--------------------------------------------------------------------------------
  return math_.log(z+math_.sqrt(z*z+1))
end

--------------------------------------------------------------------------------
function math.atanh(z)
--------------------------------------------------------------------------------
  return math_.log((1+z)/(1-z))/2
end

for _,v in pairs{"acosh","asinh","atanh"} do
  math_[v]=math[v]
end

-- SHOULD BE REMOVED IN LUA 5.2 -- START

--------------------------------------------------------------------------------
function math.cosh(z)
--------------------------------------------------------------------------------
  return (math_.exp(z)+math_.exp(-z))/2
end

--------------------------------------------------------------------------------
function math.sinh(z)
--------------------------------------------------------------------------------
  return (math_.exp(z)-math_.exp(-z))/2
end

--------------------------------------------------------------------------------
function math.tanh(z)
--------------------------------------------------------------------------------
  local e=math_.exp(2*z)
  return (e-1)/(e+1)
end

for _,v in pairs{"cosh","sinh","tanh"} do
  math_[v]=math[v]
end

table.unpack=unpack

-- SHOULD BE REMOVED IN LUA 5.2 -- END

--------------------------------------------------------------------------------
complex={}
complex.__index=complex
complex.version="2011-01-05"

math.i=setmetatable({r=0,i=1},complex)

function complex.new(r,i)
	return setmetatable({r=r or 0,i= i or 0},complex)
end
--------------------------------------------------------------------------------
local is={}

function is.complex(c)
  return getmetatable(c)==complex
end

--------------------------------------------------------------------------------
function typeBAK(x)
  return getmetatable(x)==complex and "complex" or type_(x)
end

--------------------------------------------------------------------------------
local check={}

function check.complex(c,i)
  --local t=type(c)
  --assert(getmetatable(c)==complex,"bad argument #%d (complex number expected, got %s)",i,t)
end

function check.number(n,i)
  assert(tonumber(n),"bad argument #%d (number expected, got %s)",i,type(n))
end

--------------------------------------------------------------------------------
local string_={}
string_.format=string.format

function string.formatBAK(fmt,...)
	local arg = {...}
--local vvv=0
--vvv = vvv+1
  local arg_={}
--k=l.k
  for i=1,#arg do
	--print("stringformat",vvv)
    if is.complex(arg[i]) then
      table.insert(arg_,arg[i].r)
      table.insert(arg_,arg[i].i)
    else
      table.insert(arg_,arg[i])
    end
  end
  return string_.format(fmt,table.unpack(arg_))
end

--------------------------------------------------------------------------------
local function hypot(xr,xi)
--------------------------------------------------------------------------------
  local xr=math_.abs(xr)
  local xi=math_.abs(xi)
  if xr==0 then
    return xi
  end
  if xi==0 then
    return xr
  end
  if xr>xi then
    return xr*math_.sqrt(1+(xi/xr)^2)
  else
    return xi*math_.sqrt(1+(xr/xi)^2)
  end
end

--------------------------------------------------------------------------------
local function loghypot(xr,xi)
--------------------------------------------------------------------------------
  local xr=math_.abs(xr)
  local xi=math_.abs(xi)
  if xr==0 then
    return math_.log(xi)
  end
  if xi==0 then
    return math_.log(xr)
  end
  if xr>xi then
    return math_.log(xr)+math_.log(1+(xi/xr)^2)/2
  else
    return math_.log(xi)+math_.log(1+(xr/xi)^2)/2
  end
end

--------------------------------------------------------------------------------
local function sqrthypot(xr,xi)
--------------------------------------------------------------------------------
  local xr=math_.abs(xr)
  local xi=math_.abs(xi)
  if xr==0 then
    return math_.sqrt(xi)
  end
  if xi==0 then
    return math_.sqrt(xr)
  end
  if xr>xi then
    return math_.sqrt(xr*math_.sqrt(1+(xi/xr)^2))
  else
    return math_.sqrt(xi*math_.sqrt(1+(xr/xi)^2))
  end
end

--------------------------------------------------------------------------------
function complex.abs(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  return hypot(x.r,x.i)
end

--------------------------------------------------------------------------------
function math.abs(x)
--------------------------------------------------------------------------------
  local z=tonumber(x)
  if z then
    return math_.abs(z)
  elseif is.complex(x) then
    return complex.abs(x)
  else
    error("bad argument #1 to 'abs' (real or complex number expected, got %s)",type(x))
  end
end

--------------------------------------------------------------------------------
function complex.__add(x1,x2)
--------------------------------------------------------------------------------
  local x
  if type_(x1)=="number" then
    x={r=x1+x2.r,i=x2.i}
  elseif type_(x2)=="number" then
    x={r=x1.r+x2,i=x1.i}
  else
    check.complex(x1,1)
    check.complex(x2,2)
    x={r=x1.r+x2.r,i=x1.i+x2.i}
  end
  return setmetatable(x,complex)
end

--------------------------------------------------------------------------------
function complex.acos(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  local x1r=1-x.r*x.r+x.i*x.i
  local x1i=-2*x.r*x.i
  local a=math.atan2(x1i,x1r)/2
  local m=sqrthypot(x1r,x1i)
  local x2r=m*math_.cos(a)-x.i
  local x2i=m*math_.sin(a)+x.r
  local y={r=math.pi/2-math.atan2(x2i,x2r),i=loghypot(x2r,x2i)}
  return setmetatable(y,complex)
end

--------------------------------------------------------------------------------
function math.acos(x)
--------------------------------------------------------------------------------
  local z=tonumber(x)
  if z then
    if -1<=z and z<=1 then
      return math_.acos(z)
    else
      x={r=z,i=0}
      setmetatable(x,complex)
    end
  end
  if is.complex(x) then
    return complex.acos(x)
  else
    error("bad argument #1 to 'acos' (real or complex number expected, got %s)",type(x))
  end
end

--------------------------------------------------------------------------------
function complex.acosh(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  local x1r=x.r*x.r-x.i*x.i-1
  local x1i=2*x.r*x.i
  local a=math.atan2(x1i,x1r)/2
  local m=sqrthypot(x1r,x1i)
  local x2r=m*math_.cos(a)+x.r
  local x2i=m*math_.sin(a)+x.i
  local y={r=loghypot(x2r,x2i),i=math.atan2(x2i,x2r)}
  return setmetatable(y,complex)
end

--------------------------------------------------------------------------------
function math.acosh(x)
--------------------------------------------------------------------------------
  local z=tonumber(x)
  if z then
    if 1<=z then
      return math_.acosh(z)
    else
      x={r=z,i=0}
      setmetatable(x,complex)
    end
  end
  if is.complex(x) then
    return complex.acosh(x)
  else
    error("bad argument #1 to 'acosh' (real or complex number expected, got %s)",type(x))
  end
end

--------------------------------------------------------------------------------
function complex.arg(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  return math.atan2(x.i,x.r)
end

--------------------------------------------------------------------------------
function complex.asin(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  local x1r=1-x.r*x.r+x.i*x.i
  local x1i=-2*x.r*x.i
  local a=math.atan2(x1i,x1r)/2
  local m=sqrthypot(x1r,x1i)
  local x2r=m*math_.cos(a)-x.i
  local x2i=m*math_.sin(a)+x.r
  local y={r=math.atan2(x2i,x2r),i=-loghypot(x2r,x2i)}
  return setmetatable(y,complex)
end

--------------------------------------------------------------------------------
function math.asin(x)
--------------------------------------------------------------------------------
  local z=tonumber(x)
  if z then
    if -1<=z and z<=1 then
      return math_.asin(z)
    else
      x={r=z,i=0}
      setmetatable(x,complex)
    end
  end
  if is.complex(x) then
    return complex.asin(x)
  else
    error("bad argument #1 to 'asin' (real or complex number expected, got %s)",type(x))
  end
end

--------------------------------------------------------------------------------
function complex.asinh(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  local x1r=x.r*x.r-x.i*x.i+1
  local x1i=2*x.r*x.i
  local a=math.atan2(x1i,x1r)/2
  local m=sqrthypot(x1r,x1i)
  local x2r=m*math_.cos(a)+x.r
  local x2i=m*math_.sin(a)+x.i
  local y={r=loghypot(x2r,x2i),i=math.atan2(x2i,x2r)}
  return setmetatable(y,complex)
end

--------------------------------------------------------------------------------
function math.asinh(x)
--------------------------------------------------------------------------------
  local z=tonumber(x)
  if z then
    return math_.asinh(z)
  elseif is.complex(x) then
    return complex.asinh(x)
  else
    error("bad argument #1 to 'asinh' (real or complex number expected, got %s)",type(x))
  end
end

--------------------------------------------------------------------------------
function complex.atan(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  local x1r=1+x.i
  local x1i=-x.r
  local x2r=1-x.i
  local x2i=x.r
  local y={r=(math.atan2(x2i,x2r)-math.atan2(x1i,x1r))/2,
	   i=(loghypot(x1r,x1i)-loghypot(x2r,x2i))/2}
  return setmetatable(y,complex)
end

--------------------------------------------------------------------------------
function math.atan(x)
--------------------------------------------------------------------------------
  local z=tonumber(x)
  if z then
    return math_.atan(z)
  elseif is.complex(x) then
    return complex.atan(x)
  else
    error("bad argument #1 to 'atan' (real or complex number expected, got %s)",type(x))
  end
end

--------------------------------------------------------------------------------
function complex.atanh(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  local x1r=1+x.r
  local x1i=x.i
  local x2r=1-x.r
  local x2i=-x.i
  local m2=x2r*x2r+x2i*x2i
  local x3r=(x1r*x2r+x1i*x2i)/m2
  local x3i=(x1i*x2r-x1r*x2i)/m2
  local y={r=loghypot(x3r,x3i)/2,i=math.atan2(x3i,x3r)/2}
  return setmetatable(y,complex)
end

--------------------------------------------------------------------------------
function math.atanh(x)
--------------------------------------------------------------------------------
  local z=tonumber(x)
  if z then
    if -1<z and z<1 then
      return math_.atanh(z)
    else
      x={r=z,i=0}
      setmetatable(x,complex)
    end
  end
  if is.complex(x) then
    return complex.atanh(x)
  else
    error("bad argument #1 to 'atanh' (real or complex number expected, got %s)",type(x))
  end
end

--------------------------------------------------------------------------------
function complex.conj(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  return setmetatable({r=x.r,i=-x.i},complex)
end

--------------------------------------------------------------------------------
function complex.copy(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  return setmetatable({r=x.r,i=x.i},complex)
end

--------------------------------------------------------------------------------
function complex.cos(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  local e1=math_.exp(-x.i)
  local e2=math_.exp(x.i)
  local y={r=(e1+e2)*math_.cos(x.r)/2,
	   i=(e1-e2)*math_.sin(x.r)/2}
  return setmetatable(y,complex)
end

--------------------------------------------------------------------------------
function math.cos(x)
--------------------------------------------------------------------------------
  local z=tonumber(x)
  if z then
    return math_.cos(z)
  elseif is.complex(x) then
    return complex.cos(x)
  else
    error("bad argument #1 to 'cos' (real or complex number expected, got %s)",type(x))
  end
end

--------------------------------------------------------------------------------
function complex.cosh(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  local e1=math_.exp(x.r)
  local e2=math_.exp(-x.r)
  local y={r=(e1+e2)*math_.cos(x.i)/2,
	   i=(e1-e2)*math_.sin(x.i)/2}
  return setmetatable(y,complex)
end

--------------------------------------------------------------------------------
function math.cosh(x)
--------------------------------------------------------------------------------
  local z=tonumber(x)
  if z then
    return math_.cosh(z)
  elseif is.complex(x) then
    return complex.cosh(x)
  else
    error("bad argument #1 to 'cosh' (real or complex number expected, got %s)",type(x))
  end
end

--------------------------------------------------------------------------------
function complex.__div(x1,x2)
--------------------------------------------------------------------------------
  local x
  if type_(x1)=="number" then
    local y=x2.r*x2.r+x2.i*x2.i
    x={r=x1*x2.r/y,i=-x1*x2.i/y}
  elseif type_(x2)=="number" then
    x={r=x1.r/x2,i=x1.i/x2}
  else
    check.complex(x1,1)
    check.complex(x2,2)
    local y=x2.r*x2.r+x2.i*x2.i
    x={r=(x1.r*x2.r+x1.i*x2.i)/y,i=(x1.i*x2.r-x1.r*x2.i)/y}
  end
  return setmetatable(x,complex)
end

--------------------------------------------------------------------------------
function complex.__eq(x1,x2)
--------------------------------------------------------------------------------
  check.complex(x1,1)
  check.complex(x2,2)
  return x1.r==x2.r and x1.i==x2.i
end

--------------------------------------------------------------------------------
function complex.exp(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  local e,y
  e=math_.exp(x.r)
  y={r=e*math_.cos(x.i),i=e*math_.sin(x.i)}
  return setmetatable(y,complex)
end

--------------------------------------------------------------------------------
function math.exp(x)
--------------------------------------------------------------------------------
  local z=tonumber(x)
  if z then
    return math_.exp(z)
  elseif is.complex(x) then
    return complex.exp(x)
  else
    error("bad argument #1 to 'exp' (real or complex number expected, got %s)",type(x))
  end
end

--------------------------------------------------------------------------------
function complex.imag(self,v)
--------------------------------------------------------------------------------
  if v then
    check.number(v,2)
    self.i=v
    return self
  else
    return self.i
  end
end

--------------------------------------------------------------------------------
function complex.log(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  local y={r=loghypot(x.r,x.i),i=math.atan2(x.i,x.r)}
  return setmetatable(y,complex)
end

--------------------------------------------------------------------------------
function math.log(x)
--------------------------------------------------------------------------------
  local z=tonumber(x)
  if z then
    --if 0<=z then
      return math_.log(z)
    --else
    --  x={r=z,i=0}
    --  setmetatable(x,complex)
    --end
  end
  if is.complex(x) then
    return complex.log(x)
  else
    error("bad argument #1 to 'log' (real or complex number expected, got %s)",type(x))
  end
end
--------------------------------------------------------------------------------
function complex.__mul(x1,x2)
--------------------------------------------------------------------------------
  local x
  if type_(x1)=="number" then
    x={r=x1*x2.r,i=x1*x2.i}
  elseif type_(x2)=="number" then
    x={r=x1.r*x2,i=x1.i*x2}
  else
    check.complex(x1,1)
    check.complex(x2,2)
    x={r=x1.r*x2.r-x1.i*x2.i,i=x1.r*x2.i+x1.i*x2.r}
  end
  return setmetatable(x,complex)
end

--------------------------------------------------------------------------------
function complex.__pow(x1,x2)
--------------------------------------------------------------------------------
  local a,m,x,y,z
  if type_(x1)=="number" then
    y=x1*x1
    a=y^(x2.r/2)
    m=math_.log(y)*x2.i/2
    x={r=a*math_.cos(m),i=a*math_.sin(m)}
  elseif type_(x2)=="number" then
    a=(x1.r*x1.r+x1.i*x1.i)^(x2/2)
    m=math.atan2(x1.i,x1.r)*x2
    x={r=a*math_.cos(m),i=a*math_.sin(m)}
  else
    check.complex(x1,1)
    check.complex(x2,2)
    y=x1.r*x1.r+x1.i*x1.i
    z=math.atan2(x1.i,x1.r)
    a=math_.exp(-z*x2.i)*y^(x2.r/2)
    m=z*x2.r+math_.log(y)*x2.i/2
    x={r=a*math_.cos(m),i=a*math_.sin(m)}
  end
  return setmetatable(x,complex)
end

complex.pow=complex.__pow

--------------------------------------------------------------------------------
function math.pow(x1,x2)
--------------------------------------------------------------------------------
  local z1=tonumber(x1)
  local z2=tonumber(x2)
  if z1 and z2 then
    return math_.pow(z1,z2)
  end
  assert(z1 or is.complex(x1),"bad argument #1 to 'pow' (real or complex number expected, got %s)",type(x1))
  assert(z2 or is.complex(x2),"bad argument #2 to 'pow' (real or complex number expected, got %s)",type(x2))
  return complex.pow(x1,x2)
end

--------------------------------------------------------------------------------
function complex.real(self,v)
--------------------------------------------------------------------------------
  if v then
    check.number(v,2)
    self.r=v
    return self
  else
    return self.r
  end
end

--------------------------------------------------------------------------------
function complex.roots(x,n)
--------------------------------------------------------------------------------
  check.complex(x,1)
  check.number(n,2)
  assert(n>=1 and math.floor(n)==n,"bad argument #2 (must be an integer >= 1, got %g)",n)
  local r={}
  local a=math.atan2(x.i,x.r)
  local m=(hypot(x.r,x.i))^(1/n)
  for k=0,n-1 do
    table.insert(r,{r=m*math_.cos((a+2*k*math.pi)/n),
		    i=m*math_.sin((a+2*k*math.pi)/n)})
    setmetatable(r[k+1],complex)
  end
  return r
end

--------------------------------------------------------------------------------
function complex.sin(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  local e1=math_.exp(-x.i)
  local e2=math_.exp(x.i)
  local y={r=(e1+e2)*math_.sin(x.r)/2,
	   i=(e2-e1)*math_.cos(x.r)/2}
  return setmetatable(y,complex)
end

--------------------------------------------------------------------------------
function math.sin(x)
--------------------------------------------------------------------------------
  local z=tonumber(x)
  if z then
    return math_.sin(z)
  elseif is.complex(x) then
    return complex.sin(x)
  else
    error("bad argument #1 to 'sin' (real or complex number expected, got %s)",type(x))
  end
end

--------------------------------------------------------------------------------
function complex.sinh(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  local e1=math_.exp(x.r)
  local e2=math_.exp(-x.r)
  local y={r=(e1-e2)*math_.cos(x.i)/2,
	   i=(e1+e2)*math_.sin(x.i)/2}
  return setmetatable(y,complex)
end

--------------------------------------------------------------------------------
function math.sinh(x)
--------------------------------------------------------------------------------
  local z=tonumber(x)
  if z then
    return math_.sinh(z)
  elseif is.complex(x) then
    return complex.sinh(x)
  else
    error("bad argument #1 to 'sinh' (real or complex number expected, got %s)",type(x))
  end
end

--------------------------------------------------------------------------------
function complex.sqrt(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  local a=math.atan2(x.i,x.r)/2
  local m=sqrthypot(x.r,x.i)
  local y={r=m*math_.cos(a),i=m*math_.sin(a)}
  return setmetatable(y,complex)
end

--------------------------------------------------------------------------------
function math.sqrt(x)
--------------------------------------------------------------------------------
  local z=tonumber(x)
  if z then
    if z>=0 then
      return math_.sqrt(z)
    else
      x={r=z,i=0}
      setmetatable(x,complex)
    end
  end
  if is.complex(x) then
    return complex.sqrt(x)
  else
    error("bad argument #1 to 'sqrt' (real or complex number expected, got %s)",type(x))
  end
end

--------------------------------------------------------------------------------
function complex.__sub(x1,x2)
--------------------------------------------------------------------------------
  local x
  if type_(x1)=="number" then
    x={r=x1-x2.r,i=-x2.i}
  elseif type_(x2)=="number" then
    x={r=x1.r-x2,i=x1.i}
  else
    check.complex(x1,1)
    check.complex(x2,2)
    x={r=x1.r-x2.r,i=x1.i-x2.i}
  end
  return setmetatable(x,complex)
end

--------------------------------------------------------------------------------
function complex.tan(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  local e=math_.exp(-2*x.i)
  local x1r=e*math_.cos(2*x.r)-1
  local x2r=x1r+2
  local x1i=e*math_.sin(2*x.r)
  local m2=x2r*x2r+x1i*x1i
  local y={r=(x1i*x2r-x1r*x1i)/m2,i=-(x1r*x2r+x1i*x1i)/m2}
  return setmetatable(y,complex)
end

--------------------------------------------------------------------------------
function math.tan(x)
--------------------------------------------------------------------------------
  local z=tonumber(x)
  if z then
    return math_.tan(z)
  elseif is.complex(x) then
    return complex.tan(x)
  else
    error("bad argument #1 to 'tan' (real or complex number expected, got %s)",type(x))
  end
end

--------------------------------------------------------------------------------
function complex.tanh(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  local e=math_.exp(2*x.r)
  local x1r=e*math_.cos(2*x.i)-1
  local x2r=x1r+2
  local x1i=e*math_.sin(2*x.i)
  local m2=x2r*x2r+x1i*x1i
  local y={r=(x1r*x2r+x1i*x1i)/m2,
	   i=(x1i*x2r-x1r*x1i)/m2}
  return setmetatable(y,complex)
end

--------------------------------------------------------------------------------
function math.tanh(x)
--------------------------------------------------------------------------------
  local z=tonumber(x)
  if z then
    return math_.tanh(z)
  elseif is.complex(x) then
    return complex.tanh(x)
  else
    error("bad argument #1 to 'tanh' (real or complex number expected, got %s)",type(x))
  end
end

--------------------------------------------------------------------------------
function complex.__tostring(self)
--------------------------------------------------------------------------------
	return string.format("[%s %si]",tostring(self.r),tostring(self.i))
--[[
  if self.i==0 then
    return tostring(self.r)
  elseif self.r==0 then
    if self.i==1 then
      return "i"
    elseif self.i==-1 then
      return "-i"
    else
      return string.format("%si",tostring(self.i))
    end
  else
    if self.i==1 then
      return string.format("%s+i",tostring(self.r))
    elseif self.i==-1 then
      return string.format("%s-i",tostring(self.r))
    elseif self.i>0 then
      return string.format("%s+%si",tostring(self.r),tostring(self.i))
    else
      return string.format("%s%si",tostring(self.r),tostring(self.i))
    end
  end
--]]
end

--------------------------------------------------------------------------------
function complex.__unm(x)
--------------------------------------------------------------------------------
  check.complex(x,1)
  return setmetatable({r=-x.r,i=-x.i},complex)
end

