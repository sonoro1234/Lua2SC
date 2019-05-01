#############################################
## Expects LUA_INCLUDE_DIR and LUA_LIBRARY
#################################################
PROJECT(wxLuaBundled CXX)
cmake_minimum_required(VERSION 3.13)
	
	set(setDEBUG_LEVEL true)
	set(CPPFLAGS)
	if(setDEBUG_LEVEL)
		set(CPPFLAGS -DwxDEBUG_LEVEL=0)
	endif()
	
	if(MSVC)
		#SET(CPPFLAGS "${CPPFLAGS} /EHsc")
	endif()
	
	set(WX_BUILD ${CMAKE_CURRENT_BINARY_DIR}/build_wx)
	file(MAKE_DIRECTORY ${WX_BUILD})

	set(EXECUTE_COMMAND ${CMAKE_COMMAND}  -G${CMAKE_GENERATOR} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}  -DCMAKE_INSTALL_PREFIX=${WX_BUILD}/install -DwxBUILD_INSTALL=ON -DwxBUILD_MONOLITHIC=OFF -DwxBUILD_SHARED=OFF -DwxBUILD_COMPATIBILITY=2.8 -DwxUSE_RICHTEXT=OFF -DwxUSE_XRC=OFF -DwxBUILD_PRECOMP=OFF -DwxUSE_EXPAT=OFF -DwxUSE_LIBTIFF=OFF -DwxUSE_RICHTEXT=OFF -DwxUSE_UNICODE=ON -DwxUSE_LIBJPEG=builtin -DwxUSE_LIBPNG=builtin -DwxUSE_ZLIB=builtin "-DCMAKE_CXX_FLAGS=${CPPFLAGS}"  ${CMAKE_CURRENT_SOURCE_DIR}/wxWidgets)
	
	message("---------------------------- configuring wxWidgets -------------------------------")
	message("EXECUTE_COMMAND is " "${EXECUTE_COMMAND}")
	file(WRITE ${WX_BUILD}/comando.txt "${EXECUTE_COMMAND}")
    # execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WX_BUILD}
        # WORKING_DIRECTORY ${WX_BUILD}
        # )
    execute_process(COMMAND ${EXECUTE_COMMAND} 
        WORKING_DIRECTORY ${WX_BUILD}
        )
    message( "--------------------------- building " ${target} "------------------------------")
    execute_process(COMMAND ${CMAKE_COMMAND} --build . --target install
        WORKING_DIRECTORY ${WX_BUILD}
		RESULT_VARIABLE build_command_result
        )
	message( "build_command_result " ${build_command_result} "---------------------------------")
##wxLua
add_custom_target(SecondaryAllBuild ALL DEPENDS wxLuaModule)

set(wxWidgets_install ${WX_BUILD}/install)
set(CMAKE_CXX_FLAGS "-DLUA_COMPAT_MODULE")
if(WIN32)
	set(wxWidgets_ROOT_DIR ${wxWidgets_install})
	set(wxWidgets_CONFIGURATION mswu)
	if(MSVC)
		set(wxWidgets_LIB_DIR ${wxWidgets_install}/lib/vc_lib)
	else() #mingw
		set(wxWidgets_LIB_DIR ${wxWidgets_install}/lib/gcc_lib)
	endif()
endif()
if(UNIX)
	set(wxWidgets_CONFIG_EXECUTABLE ${WX_BUILD}/wx-config)
endif()

set(BUILD_VERBOSELY TRUE)
set(BUILD_SHARED_LIBS FALSE)
set(wxLua_LUA_LIBRARY_USE_BUILTIN FALSE)
set(wxLua_LUA_LIBRARY ${LUA_LIBRARY})
set(wxLua_LUA_INCLUDE_DIR ${LUA_INCLUDE_DIR})
set(wxWidgets_COMPONENTS "stc;gl;html;aui;adv;core;net;base")
set(wxLuaBind_COMPONENTS "stc;gl;html;aui;adv;core;net;base")
if(setDEBUG_LEVEL)
	SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DwxDEBUG_LEVEL=0")
endif()

if(MSVC)
	#add_compile_definitions(-D/EHsc)
	SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHsc")
endif()
add_subdirectory(wxlua/wxLua EXCLUDE_FROM_ALL)

#add_dependencies(SecondaryAllBuild wxLuaModule)


INSTALL(TARGETS wxLuaModule     
    RUNTIME DESTINATION .
    LIBRARY DESTINATION ${CMAKE_BINARY_DIR}/trash
    ARCHIVE DESTINATION ${CMAKE_BINARY_DIR}/trash)
#add_dependencies(install wxLuaModule)