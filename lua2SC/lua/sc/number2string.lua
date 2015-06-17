---  number to string conversion functions
--  Copyright (C) 2012 Victor Bombi

function str2uint(a)
	local number =0
	local len = a:len()
	for i=1,len do
		number= number + a:byte(i) * 256 ^ (len - i)
	end
	
	return number
end
function int2str(int, len, notrev)
   local signbit = (int < 0) and 1 or 0
   local nn2 = signbit * 2^(len*8-1)
   local number = int + (signbit * (2^(len*8-1)))
   --print("signo:"..signbit.." numero:"..number.." nn2:"..nn2.."\n")
   assert(number >=0,"el entero no cabe en esta longitud")
   
   local bytes={}
   for i=1,len do
     bytes[i]= number % 256; 
     number = math.floor(number / 256);
   end
   
   assert(bytes[len]<128,"entero no cabe en longitud")
   bytes[len] = bytes[len] + signbit * 128
   --prtable(bytes)
   local str = ""
   if notrev then
    for i=1,len do
       str=str..string.char(bytes[i])
    end
   else
    for i=1,len do
       str=str..string.char(bytes[len - i +1])
    end
   end
   return str;
end
 
function str2int(a) --two's complement
	local len = a:len()
	--find left MSB
	local  a1 = a:byte(1) % 128
	local sig=(a:byte(1) - a1)/128
	sig = -sig * 2 ^ (len * 8 - 1)
	local number = a1
	if len > 1 then
		for i=2,len do
			number= number * 256 + a:byte(i)
		end
	end
	number = number + sig
	return number
end

function float2str(float)

	local signbit,N
	if (float < 0) then 
		signbit=1
		N = -float
	elseif (float > 0) then
		signbit=0
		N = float
	else
		return string.char(0,0,0,0)
	end
	if float == math.huge then
		return string.char(127 + 128*signbit,128,0,0)
	end
	local man,exp2 = math.frexp(N)
	--print("exponents",exp2,exp2+127)
	--print("mantissas",M,string.format("%0.17g",man),math.floor(0.5+(math.ldexp(man, 23)-math.ldexp(1, 23))))
	--print("aver",man * 2^exp2)
	
	while (0.5 + (man-1)*2^23) < 0 do
		exp2 = exp2 - 1
		man = man * 2
		--print("man",man)
	end
	e = exp2 + 127
	M = math.floor(0.5 + (man-1)*2^23)
	--print("M",M)
	----
	local bytes={}
	local number=M
	for i=1,3 do
		bytes[i]= number % 256; 
		number = math.floor(number / 256);
	end
	assert(bytes[3]<128,"mantissa no cabe en longitud "..string.format("%.32f bytes3 %d e %d",float,bytes[3],e))
	bytes[3]=bytes[3]+128*(e % 2)
	bytes[4]=math.floor(e/2) + 128*signbit

	return string.char(bytes[4],bytes[3],bytes[2],bytes[1])

end
function str2float32(x)

	local sign = 1
	--x=x:reverse() --in case BIGENDIA o  LITTLEENDIAN
	local mantissa = string.byte(x, 2) % 128
	for i = 3, 4  do mantissa = mantissa * 256 + string.byte(x, i) end

	if string.byte(x, 1) > 127 then sign = -1 end
	local exponent = (string.byte(x, 1) % 128) * 2 + math.floor(string.byte(x, 2) / 128)
	if exponent == 0 then return 0 end
	
	mantissa = (math.ldexp(mantissa, -23) + 1) * sign -- sign * ((mantissa *(2^(-23)))+1)
	local val=math.ldexp(mantissa, exponent - 127)  -- mantissa * 2^(exponent -127)
	--mantissa = sign * ((mantissa *(2^(-23)))+1)
	--local val=mantissa * (2^(exponent -127))

	return val
end
--ss=float2str(0.49999999999999994000000000000000)
--ss=float2str(math.huge)
--ss=float2str(123.567)
--print("recupero",str2float32(ss))