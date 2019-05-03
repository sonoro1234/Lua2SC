PROJECT(LuaJIT)
#to allow install from subdirectory
cmake_minimum_required(VERSION 3.6)

include(ExternalProject)

#luajit project
set(ljpre ${CMAKE_CURRENT_BINARY_DIR}/luajit-2.1)
set(ljsrc ${ljpre}/src)
set(LUAJIT_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/LuaJIT/)
set(LUAJIT_BUILD ${CMAKE_CURRENT_BINARY_DIR}/build_LJ)

if(NOT EXISTS ${LUAJIT_BUILD})#only build if not done before
	file(MAKE_DIRECTORY ${LUAJIT_BUILD})
	
	message("-----------------------copying LuaJIT files")
	file(MAKE_DIRECTORY ${ljpre})
	file(COPY ${LUAJIT_SOURCES} DESTINATION ${ljpre})
	
	message("---------------------------- making LuaJIT -------------------------------")
	if(UNIX)
		execute_process(COMMAND make CCOPT="-DLUAJIT_ENABLE_LUA52COMPAT"
			WORKING_DIRECTORY ${ljpre})
		#dont doit now, will be done afterwards
		#execute_process(COMMAND make install PREFIX=${LUAJIT_BUILD}
		#    WORKING_DIRECTORY ${ljpre})
	else()
		if(MSVC)
			execute_process(COMMAND ${ljsrc}/msvcbuild.bat #CCOPT="-DLUAJIT_ENABLE_LUA52COMPAT" #dont know haow to set it
			WORKING_DIRECTORY ${ljsrc})
		else()
			execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} CCOPT="-DLUAJIT_ENABLE_LUA52COMPAT"
			WORKING_DIRECTORY ${ljsrc})
		endif()
	endif()
endif()

#########install
if(Darwin)
	install(FILES ${ljsrc}/luajit ${ljsrc}/libluajit.dylib 
  PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
  DESTINATION .)
elseif(UNIX)
	install(FILES ${ljsrc}/luajit ${ljsrc}/libluajit.so 
  PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
  DESTINATION .)
else() #win
	install(FILES ${ljsrc}/luajit.exe ${ljsrc}/lua51.dll DESTINATION .)
endif()

install(DIRECTORY ${ljsrc}/jit DESTINATION ./lua FILES_MATCHING PATTERN "*.lua")
