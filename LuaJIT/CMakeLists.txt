PROJECT(LuaJIT)
#to allow install from subdirectory
cmake_minimum_required(VERSION 3.6)

#luajit project
set(ljpre ${CMAKE_CURRENT_BINARY_DIR}/luajit-2.1)
set(ljsrc ${ljpre}/src)
set(LUAJIT_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/LuaJIT/)
set(LUAJIT_BUILD ${CMAKE_CURRENT_BINARY_DIR}/build_LJ)

if(NOT EXISTS ${LUAJIT_BUILD})#only build if not done before
	file(MAKE_DIRECTORY ${LUAJIT_BUILD})
	
	message("-----------------------copying LuaJIT files")
	file(MAKE_DIRECTORY ${ljpre})
	#file(COPY ${LUAJIT_SOURCES} DESTINATION ${ljpre})
	#generate .relver
	execute_process(COMMAND git archive -o archivo.tar HEAD WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/LuaJIT)
	#move sources to binary and extract
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/LuaJIT/archivo.tar ${ljpre})
	execute_process(COMMAND ${CMAKE_COMMAND} -E tar x archivo.tar WORKING_DIRECTORY ${ljpre})
	#delete archivo.tar
	execute_process(COMMAND ${CMAKE_COMMAND} -E rm archivo.tar WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/LuaJIT)
	
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
else()
message(">>>>>>>>>>>>>>LuaJIT was already built,\n delete " ${LUAJIT_BUILD} " folder before runing cmake to rebuild.")
endif()
message(">>>>>>>>>>>>>>LuaJIT done>>>>>>>>>>>>>>>>>>>>>>>>>")
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
	install(FILES ${ljsrc}/luajit.exe ${ljsrc}/lua51.dll DESTINATION ${LUAJIT_BIN})
endif()

install(DIRECTORY ${ljsrc}/jit DESTINATION ${LUAJIT_BIN}/lua FILES_MATCHING PATTERN "*.lua")
