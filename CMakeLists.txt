cmake_minimum_required(VERSION 2.8)

set(LUA_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/lua-5.1.5/src)
#TODO unix and osx
set(LUA_LIBRARY ${CMAKE_BINARY_DIR}/LuaJIT/luajit-2.1/project_luajit/src/lua51.dll)
set(CMAKE_INSTALL_PREFIX ${LUAJIT_BIN})

add_subdirectory(LuaJIT)

add_subdirectory(random)
add_subdirectory(osclua)
add_subdirectory(luaportmidi)
add_subdirectory(luasocket)
set(INSTALL_CMOD ./lanes)
set(INSTALL_LMOD ./lua)
add_subdirectory(lanes)

# install
#set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install)
INSTALL (DIRECTORY  Lua2SC DESTINATION .)
install(FILES luafilesystem/lfs_ffi.lua luafilesystem/lfs.lua DESTINATION ./lua)
##runtime libraries
if( MINGW )
    message( STATUS "    Installing system-libraries: MinGW DLLs." )
    get_filename_component( Mingw_Path ${CMAKE_CXX_COMPILER} PATH )
	file(GLOB libgcc LIST_DIRECTORIES false ${Mingw_Path}/libgcc*.dll)
	#message("libgcc is " ${libgcc})
    set( CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS ${Mingw_Path}/libwinpthread-1.dll ${libgcc} ${Mingw_Path}/libstdc++-6.dll )
endif( MINGW )
set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP TRUE)
include (InstallRequiredSystemLibraries)
INSTALL(FILES ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS} DESTINATION .)
##launcher
if(WIN32)
	INSTALL(FILES launcher/Lua2SC.bat DESTINATION .)
endif(WIN32)

