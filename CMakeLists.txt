cmake_minimum_required(VERSION 2.8)
add_subdirectory(random)
add_subdirectory(osclua)
add_subdirectory(luaportmidi)

# install
set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/Lua2SC)
INSTALL (DIRECTORY  Lua2SC DESTINATION ..)

