cmake_minimum_required(VERSION 2.8)
add_subdirectory(random)
add_subdirectory(osclua)
add_subdirectory(luaportmidi)

# install
if(NOT LUA_BIN)
	set(LUA_BIN ${CMAKE_BINARY_DIR}/install)
endif(NOT LUA_BIN)

set(CMAKE_INSTALL_PREFIX ${LUA_BIN})
INSTALL (DIRECTORY  Lua2SC-bin/lua/ DESTINATION lua)
#file(GLOB_RECURSE luafiles RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/Lua2SC-bin/lua Lua2SC-bin/lua/*.*)
#list(REMOVE_ITEM luafiles lanes.lua socket.lua)

#foreach(loop_var ${luafiles})
	#message("compiling files " ${loop_var})
	#list(APPEND copyfiles ${CMAKE_CURRENT_SOURCE_DIR}/Lua2SC-bin/lua/${loop_var})
#endforeach(loop_var)
#list(APPEND copyfiles ${CMAKE_CURRENT_SOURCE_DIR}/Lua2SC-bin/lua2sc.lua ${CMAKE_CURRENT_SOURCE_DIR}/Lua2SC-bin/lua2sc.bat)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/Lua2SC-bin/lua2sc.lua ${CMAKE_CURRENT_SOURCE_DIR}/Lua2SC-bin/lua2sc.bat DESTINATION ./)
