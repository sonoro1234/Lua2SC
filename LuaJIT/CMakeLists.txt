PROJECT(LuaJIT)
#to allow install from subdirectory
cmake_minimum_required(VERSION 3.13)

include(ExternalProject)

#luajit project
set(ljpre ${CMAKE_CURRENT_BINARY_DIR}/luajit-2.1)
set(ljdir ${ljpre}/project_luajit)
set(ljsrc ${ljpre}/project_luajit/src)

#debug flags
###dont use still
#[[
string(TOLOWER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE_LOWER)
if(${CMAKE_BUILD_TYPE_LOWER} STREQUAL "debug")
    message("== LuaJIT will be built in debug mode")
	if(MSVC)
		set(DEBUG_FLAGS "debug")
	else()
		set(DEBUG_FLAGS "CCDEBUG=-g")
	endif()
endif()
]]

set(LUAJIT_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/LuaJIT)
if(UNIX)
    ExternalProject_Add(project_luajit
      PREFIX ${ljpre}
      SOURCE_DIR ${LUAJIT_SOURCES}
	  CONFIGURE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${LUAJIT_SOURCES} ${ljdir}
      BINARY_DIR ${ljdir}
      BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} ${DEBUG_FLAGS}
      INSTALL_COMMAND ""
    )
    set (ljname libluajit.a)
else(UNIX)
  if(MSVC)
    ExternalProject_Add(project_luajit
      PREFIX ${ljpre}
	  SOURCE_DIR ${LUAJIT_SOURCES}
	  CONFIGURE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${LUAJIT_SOURCES} ${ljdir}
      BINARY_DIR ${ljsrc}
      BUILD_COMMAND ${ljsrc}/msvcbuild.bat ${DEBUG_FLAGS}
      INSTALL_COMMAND ""
    )
    set (ljname lua51.lib)
  else(MSVC) #mingw

      ExternalProject_Add(project_luajit
      PREFIX ${ljpre}
	  SOURCE_DIR ${LUAJIT_SOURCES}
	  CONFIGURE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${LUAJIT_SOURCES} ${ljdir}
      BINARY_DIR ${ljsrc}
      BUILD_COMMAND 
		${CMAKE_MAKE_PROGRAM} 
		${DEBUG_FLAGS}
      INSTALL_COMMAND ""
    )
  endif(MSVC)
    set (ljdllname lua51.dll)
endif(UNIX)


#########install
if(Darwin)
	install(FILES ${ljsrc}/luajit ${ljsrc}/libluajit.dylib 
  PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
  DESTINATION ${LUAJIT_BIN})
elseif(UNIX)
	install(FILES ${ljsrc}/luajit ${ljsrc}/libluajit.so 
  PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
  DESTINATION ${LUAJIT_BIN})
else() #win
	install(FILES ${ljsrc}/luajit.exe ${ljsrc}/lua51.dll DESTINATION .)
endif()
install(DIRECTORY ${ljsrc}/jit DESTINATION ./lua FILES_MATCHING PATTERN "*.lua")



