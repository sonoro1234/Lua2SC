cmake_minimum_required(VERSION 2.8)
add_subdirectory(random)
add_subdirectory(osclua)
add_subdirectory(luaportmidi)

# install
if(NOT LUA_BIN)
	set(LUA_BIN ${CMAKE_BINARY_DIR}/install)
endif(NOT LUA_BIN)

set(CMAKE_INSTALL_PREFIX ${LUA_BIN})
INSTALL (DIRECTORY  lua/ DESTINATION lua)
