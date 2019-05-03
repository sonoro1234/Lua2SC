PROJECT(Lua2SC C)
cmake_minimum_required(VERSION 2.8)


set(THIS_LUA_SRC ${CMAKE_BINARY_DIR}/LuaJIT/luajit-2.1/src)
set(LUA_INCLUDE_DIR ${THIS_LUA_SRC})
#TODO check osx
if(WIN32)
	if(MSVC)
		set(LUA_LIBRARY ${THIS_LUA_SRC}/lua51.lib)
	else() #mingw
		set(LUA_LIBRARY ${THIS_LUA_SRC}/lua51.dll)
	endif()
elseif(Darwin)
	set(LUA_LIBRARY ${THIS_LUA_SRC}/libluajit.dylib)
else() 
	set(LUA_LIBRARY  ${THIS_LUA_SRC}/libluajit.so)
endif()
set(CMAKE_INSTALL_PREFIX ${LUAJIT_BIN})

add_subdirectory(LuaJIT)

add_subdirectory(random)
add_subdirectory(osclua)
add_subdirectory(luaportmidi)
add_subdirectory(luasocket_cmake)
message("------------lanes-----------------------------")

set(INSTALL_CMOD ./lanes CACHE INTERNAL "cmod" FORCE)
set(INSTALL_LMOD ./lua  CACHE INTERNAL "lmod" FORCE)
set(INSTALL_DATA ${CMAKE_BINARY_DIR}/lanes_install  CACHE INTERNAL "lanes data" FORCE)
add_subdirectory(lanes )


if(BUILD_WXLUA)
	set(LUA_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/lua-5.1.5/src) #wxLua dont like luajit headers
	add_subdirectory(wxLuaBundled)
endif()

############ install #######################
INSTALL (DIRECTORY  lua2SC DESTINATION .)
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
#TODO launchers for osx
if(WIN32)
	INSTALL(FILES launcher/Lua2SC.bat DESTINATION .)
else(WIN32)#linux
	INSTALL(FILES launcher/Lua2SC.sh
    PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
	DESTINATION .)
endif(WIN32)

