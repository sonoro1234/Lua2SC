--[[
-- ljcomplex.lua
-- Complex library for Numeric Lua, LuaJIT version
-- Luis Carvalho (lexcarvalho@gmail.com)
-- See Copyright Notice in numlua.h
--]]

local ffi = require "ffi"
local C, istype = ffi.C, ffi.istype

local T0 = "double c%s (double complex z);"
local F0 = {"abs", "arg", "imag", "real"}
local T1 = "double complex c%s (double complex z);"
local F1 = {"acos", "acosh", "asin", "asinh", "atan", "atanh", "cos",
  "cosh", "exp", "log", "proj", "sin", "sinh", "sqrt", "tan", "tanh"}
local T2 = "double complex c%s (double complex x, double complex z);"
local F2 = {"add", "sub", "mul", "div", "pow"} -- metamethods

local cdefs = {}
for _, f in ipairs(F0) do cdefs[#cdefs + 1] = T0:format(f) end
for _, f in ipairs(F1) do cdefs[#cdefs + 1] = T1:format(f) end
cdefs[#cdefs + 1] = "double complex conj (double complex z);"
for _, f in ipairs(F2) do cdefs[#cdefs + 1] = T2:format(f) end
ffi.cdef(table.concat(cdefs))

local cpxlib = {}
for _, f in ipairs(F0) do cpxlib[f] = C["c" .. f] end
for _, f in ipairs(F1) do cpxlib[f] = C["c" .. f] end
cpxlib.conj = C.conj
cpxlib.logabs = function (z)
  local r, i = math.abs(z.re), math.abs(z.im)
  if i > r then r, i = i, r end
  local t = i / r
  return math.log(r) + 0.5 * C.log1p(t * t)
end

local complex
local tocomplex = function (a, b)
  if not istype(complex, a) then
    assert(type(a) == "number", "number or complex expected")
    return complex(a), b
  elseif not istype(complex, b) then
    assert(type(b) == "number", "number or complex expected")
    return a, complex(b)
  end
  return a, b
end

function cpxlib.add (a, b)
  a, b = tocomplex(a, b)
  return complex(a.re + b.re, a.im + b.im)
end
function cpxlib.sub (a, b)
  a, b = tocomplex(a, b)
  return complex(a.re - b.re, a.im - b.im)
end
function cpxlib.mul (a, b)
  a, b = tocomplex(a, b)
  return complex(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re)
end
function cpxlib.div (a, b)
  a, b = tocomplex(a, b)
  local r, d
  if math.abs(b.re) < math.abs(b.im) then
    r = b.re / b.im
    d = b.re * r + b.im
    return complex((a.re * r + a.im) / d, (a.im * r - a.re) / d)
  end
  r = b.im / b.re
  d = b.im * r + b.re
  return complex((a.im * r + a.re) / d, (a.im - a.re * r) / d)
end

local mt = { -- while LuaJIT doesn't support them natively
  __len = function (a, b) return C.cabs(a) end,
  __unm = function (a) return complex (-a.re, -a.im) end,
  __add = cpxlib.add, __sub = cpxlib.sub,
  __mul = cpxlib.mul, __div = cpxlib.div,
  __pow = C.cpow, __index = cpxlib,
}
complex = ffi.metatype("complex", mt)

setmetatable(cpxlib, {__call = function(_, ...) return complex(...) end})
cpxlib.i, cpxlib.j = complex(0, 1), complex(0, 1)
return cpxlib