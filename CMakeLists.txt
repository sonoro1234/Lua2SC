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
#set(CMAKE_INSTALL_PREFIX ${LUAJIT_BIN})

add_subdirectory(LuaJIT)

add_subdirectory(random)
add_subdirectory(osclua)
add_subdirectory(luaportmidi)

set(CDIR ${LUAJIT_BIN})
set(LDIR ${LUAJIT_BIN}/lua)
add_subdirectory(luasocket_cmake)
add_subdirectory(LuaJIT-libsndfile)
message("------------lanes-----------------------------")

set(INSTALL_CMOD ${LUAJIT_BIN}/lanes CACHE INTERNAL "cmod" FORCE)
set(INSTALL_LMOD ${LUAJIT_BIN}/lua  CACHE INTERNAL "lmod" FORCE)
set(INSTALL_DATA ${CMAKE_BINARY_DIR}/lanes_install  CACHE INTERNAL "lanes data" FORCE)
add_subdirectory(lanes )


if(BUILD_WXLUA)
	set(LUA_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/lua-5.1.5/src) #wxLua dont like luajit headers
	add_subdirectory(wxLuaBundled)
endif()

############ install #######################
INSTALL (DIRECTORY  lua2SC DESTINATION ${LUAJIT_BIN} PATTERN "*.bak" EXCLUDE  PATTERN "*.WinMerge" EXCLUDE)
install(FILES luafilesystem/lfs_ffi.lua luafilesystem/lfs.lua DESTINATION ${LUAJIT_BIN}/lua)

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
INSTALL(FILES ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS} DESTINATION ${LUAJIT_BIN})

##launcher
#TODO launchers for osx
if(WIN32)
	INSTALL(FILES launcher/Lua2SC.bat DESTINATION ${LUAJIT_BIN})
else(WIN32)#linux
	INSTALL(FILES launcher/Lua2SC.sh
    PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
	DESTINATION ${LUAJIT_BIN})
endif(WIN32)

