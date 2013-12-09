err = [[error loading module 'iupluacontrols' from file 'C:\LUA\lua-5.1.5set\build482posixdwrf\Project\iupluacontrols.dll':
        No se puede encontrar el m¾dulo especificado.]]
local err2 = err:match("from file%s+'.-':.-([%w%p]*:%d*:)")
print(err2)