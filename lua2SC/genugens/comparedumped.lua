local function DefineU()
	UGen={ derived={},names={}}
	function UGen:new(o)
		o = o or {}
		self.derived[o.name] = o
		self.names[o.name] = 1 + (self.names[o.name] or 0)
		return o
	end
	MultiOutUGen={ derived={},names={}}
	function MultiOutUGen:new(o)
		o = o or {}
		self.derived[o.name] = o
		self.names[o.name] = 1 + (self.names[o.name] or 0)
		return o
	end
	Out={ derived={},names={}}
	function Out:new(o)
		o = o or {}
		self.derived[o.name] = o
		self.names[o.name] = 1 + (self.names[o.name] or 0)
		return o
	end
end

local function Compare(A,B)
	print"----------A not in B"
	for name,v in pairs(A.names) do
		if not B.names[name] then
			print(name )
		else
			local o1 = A.derived[name]
			local o2 = B.derived[name]
			for k,v1 in pairs(o1) do
				if not o2[k] then
					print(name,k)
				end
			end
		end
	end
	print"----------B not in A"
	for name,v in pairs(B.names) do
		if not A.names[name] then
			print(name )
		else
			local o1 = B.derived[name]
			local o2 = A.derived[name]
			for k,v1 in pairs(o1) do
				if not o2[k] then
					print(name,k)
				end
			end
		end
	end
end

DefineU()
require"declareugens5"

UGen1 = UGen
MultiOutUGen1 = MultiOutUGen
Out1 = Out

DefineU()
require"dumpedugens"


print("---------------Compare UGen")
Compare(UGen1,UGen)
print("---------------Compare MultiOutUGen")
Compare(MultiOutUGen1,MultiOutUGen)
print("---------------Compare Out")
Compare(Out1,Out)
