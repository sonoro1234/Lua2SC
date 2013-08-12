--[[
_A_ARCH
Archive. Set whenever the file is changed and cleared by the BACKUP command. Value: 0x20.
_A_HIDDEN
Hidden file. Not normally seen with the DIR command, unless the /AH option is used. Returns information about normal files and files with this attribute. Value: 0x02.
_A_NORMAL
Normal. File has no other attributes set and can be read or written to without restriction. Value: 0x00.
_A_RDONLY
Read-only. File cannot be opened for writing and a file with the same name cannot be created. Value: 0x01.
_A_SUBDIR
Subdirectory. Value: 0x10.
_A_SYSTEM
System file. Not normally seen with the DIR command, unless the /A or /A:S option is used. Value: 0x04.
]]--
_A_ARCH=0x20
_A_HIDDEN=0x02
_A_NORMAL=0x00
_A_RDONLY=0x01
_A_SUBDIR=0x10
_A_SYSTEM=0x04

function printdir(fname,attrib,size,tabs)
			tabs = tabs or 0
			print("\n")
			for i=1,tabs do
				print("\t")
			end
			print(fname .. " \tattrib:" .. attrib .. " \tsize:" .. size)
			if((attrib & _A_ARCH) > 0) then print("_A_ARCH") end
			if((attrib & _A_HIDDEN) > 0) then print("_A_HIDDEN") end
			if((attrib & _A_RDONLY) > 0) then print("_A_RDONLY") end
			if((attrib & _A_SYSTEM) > 0) then print("_A_SYSTEM") end
			if((attrib & _A_SUBDIR) > 0) then print("_A_SUBDIR")end
end

function recursedodir(func,pat,dire,level)
	level = level or 0
	dire = dire or "."
	pat = pat or "*.*"
	for fname,attrib,size in dir(dire.."/"..pat) do
		if(fname~="." and fname~="..") then
			func(fname,attrib,size,level)
		end
	end
	for fname,attrib,size in dir(dire.."/*.*") do
		if(fname~="." and fname~=".." and (attrib & _A_SUBDIR) > 0) then
			func(fname,attrib,size,level)
			recursedodir(func,pat,dire.."/"..fname,level + 1)
		end
	end
end

function dodir(func,pat,dire,level)
	level = level or 0
	dire = dire or "."
	pat = pat or "*.*"
	for fname,attrib,size in dir(dire.."/"..pat) do
		if(fname~="." and fname~="..") then
			func(fname,attrib,size,level)
		end
	end
end


