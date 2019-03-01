PROJECT(LuaJIT)
#to allow install from subdirectory
cmake_minimum_required(VERSION 3.13)

include(ExternalProject)

#luajit project
set(ljpre ${CMAKE_CURRENT_BINARY_DIR}/luajit-2.1)
set(ljdir ${ljpre}/project_luajit)
set(ljsrc ${ljpre}/project_luajit/src)
set(LUAJIT_INSTALL ${CMAKE_BINARY_DIR}/LuaJIT_install)
#set(URLLUAJIT http://luajit.org/download/LuaJIT-2.0.1.tar.gz)
#set(URLLUAJIT https://github.com/LuaJIT/LuaJIT.git)
if(UNIX)
    ExternalProject_Add(project_luajit
      PREFIX ${ljpre}
      SOURCE_DIR ${CMAKE_SOURCE_DIR}/LuaJIT/LuaJIT
	  CONFIGURE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/LuaJIT/LuaJIT ${ljdir}
      BINARY_DIR ${ljdir}
      BUILD_COMMAND ${CMAKE_MAKE_COMMAND} 
      INSTALL_COMMAND ${CMAKE_MAKE_COMMAND} install PREFIX="${LUAJIT_INSTALL}"
    )
    set (ljname libluajit.a)
else(UNIX)
  if(MSVC)
    ExternalProject_Add(project_luaji
      PREFIX ${ljpre}
	  SOURCE_DIR ${CMAKE_SOURCE_DIR}/LuaJIT/LuaJIT
	  CONFIGURE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/LuaJIT/LuaJIT ${ljdir}
      BINARY_DIR ${ljsrc}
      BUILD_COMMAND ${ljsrc}/msvcbuild.bat
      INSTALL_COMMAND ""
    )
    set (ljname lua51.lib)
  else(MSVC) #mingw
      ExternalProject_Add(project_luajit
      PREFIX ${ljpre}
	  SOURCE_DIR ${CMAKE_SOURCE_DIR}/LuaJIT/LuaJIT
	  CONFIGURE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/LuaJIT/LuaJIT ${ljdir}
      BINARY_DIR ${ljsrc}
      BUILD_COMMAND ${CMAKE_MAKE_COMMAND}
      INSTALL_COMMAND ""
    )
  endif(MSVC)
    set (ljdllname lua51.dll)
endif(UNIX)


#########install
if(Darwin)
	install(FILES ${LUAJIT_INSTALL}/bin/luajit ${LUAJIT_INSTALL}/bin/lua51.so DESTINATION .)
elseif(UNIX)
	install(FILES ${LUAJIT_INSTALL}/bin/luajit ${LUAJIT_INSTALL}/bin/lua51.so DESTINATION .)
else() #win
	install(FILES ${ljsrc}/luajit.exe ${ljsrc}/lua51.dll DESTINATION .)
endif()
install(DIRECTORY ${ljsrc}/jit DESTINATION ./lua/jit)



