#############################################
## Expects LUA_INCLUDE_DIR and LUA_LIBRARY
#################################################
PROJECT(wxLuaBundled CXX)
cmake_minimum_required(VERSION 3.13)

set(WX_BUILD ${CMAKE_CURRENT_BINARY_DIR}/build_wx)

if(UNIX)
    if(NOT EXISTS ${WX_BUILD})#only build if not done before
	file(MAKE_DIRECTORY ${WX_BUILD})
	set(MAKEFLAGS "-j4")
	set(WXWIDGETSDEBUG "--disable-debug")
	set(WXWIDGETSLOC ${CMAKE_CURRENT_BINARY_DIR}/wxWidgets)
	set(EXECUTE_COMMAND	./configure)
	set(EXECUTE_ARGS --prefix=${WX_BUILD} ${WXWIDGETSDEBUG} --disable-shared --enable-unicode --with-opengl 
    --enable-compat30 
    --with-libjpeg=builtin --with-libpng=builtin --with-libtiff=no --with-expat=no 
    --with-zlib=builtin --disable-richtext --with-gtk=2 
    "CFLAGS=-Os -fPIC" "CXXFLAGS=-Os -fPIC")
	message("-----------------------copying wWidgets files")
	file(MAKE_DIRECTORY ${WXWIDGETSLOC})
	file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/wxWidgets DESTINATION .)
	message("---------------------------- configuring wxWidgets -------------------------------")
	message("EXECUTE_COMMAND is " "${EXECUTE_COMMAND} ${EXECUTE_ARGS}")	
	execute_process(COMMAND ${EXECUTE_COMMAND} ${EXECUTE_ARGS}
        WORKING_DIRECTORY ${WXWIDGETSLOC}
    )
	message("---------------------------- making wxWidgets -------------------------------")
	execute_process(COMMAND make ${MAKEFLAGS} 
        WORKING_DIRECTORY ${WXWIDGETSLOC}
    )
	execute_process(COMMAND make install 
        WORKING_DIRECTORY ${WXWIDGETSLOC}
    )
    endif()

else(UNIX)
	file(MAKE_DIRECTORY ${WX_BUILD})	
	set(setDEBUG_LEVEL true)
	set(CPPFLAGS)
	if(setDEBUG_LEVEL)
		set(CPPFLAGS -DwxDEBUG_LEVEL=0)
	endif()
	
	if(MSVC)
		#SET(CPPFLAGS "${CPPFLAGS} /EHsc")
	endif()
	
	#set(EXECUTE_COMMAND ${CMAKE_COMMAND}  -G${CMAKE_GENERATOR} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}  -DCMAKE_INSTALL_PREFIX=${WX_BUILD}/install -DwxBUILD_INSTALL=ON -DwxBUILD_MONOLITHIC=OFF -DwxBUILD_SHARED=OFF -DwxBUILD_COMPATIBILITY=2.8 -DwxUSE_RICHTEXT=OFF -DwxUSE_XRC=OFF -DwxBUILD_PRECOMP=OFF -DwxUSE_EXPAT=OFF -DwxUSE_LIBTIFF=OFF -DwxUSE_UNICODE=ON -DwxUSE_LIBJPEG=builtin -DwxUSE_LIBPNG=builtin -DwxUSE_ZLIB=builtin "-DCMAKE_CXX_FLAGS=${CPPFLAGS}"  ${CMAKE_CURRENT_SOURCE_DIR}/wxWidgets)
	set(EXECUTE_COMMAND ${CMAKE_COMMAND}  -G${CMAKE_GENERATOR} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}  -DCMAKE_INSTALL_PREFIX=${WX_BUILD}/install -DwxBUILD_INSTALL=ON -DwxBUILD_MONOLITHIC=OFF -DwxBUILD_SHARED=OFF -DwxBUILD_COMPATIBILITY=3.0 -DwxUSE_RICHTEXT=OFF -DwxUSE_XRC=OFF -DwxBUILD_PRECOMP=OFF -DwxUSE_UNICODE=ON -DwxUSE_EXPAT=builtin -DwxUSE_LIBTIFF=builtin -DwxUSE_LIBJPEG=builtin -DwxUSE_LIBPNG=builtin -DwxUSE_ZLIB=builtin "-DCMAKE_CXX_FLAGS=${CPPFLAGS}"  ${CMAKE_CURRENT_SOURCE_DIR}/wxWidgets)
	
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
endif()
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
		if("${CMAKE_SIZEOF_VOID_P}" STREQUAL "8")
			set(wxWidgets_LIB_DIR ${wxWidgets_install}/lib/gcc_x64_lib)
		else()
			set(wxWidgets_LIB_DIR ${wxWidgets_install}/lib/gcc_lib)
		endif()
	endif()
endif()
if(UNIX)
	set(wxWidgets_CONFIG_EXECUTABLE ${WX_BUILD}/bin/wx-config)
endif()

set(BUILD_VERBOSELY TRUE)
set(BUILD_SHARED_LIBS FALSE)
set(wxLua_LUA_LIBRARY_USE_BUILTIN FALSE)
set(wxLua_LUA_LIBRARY ${LUA_LIBRARY})
set(wxLua_LUA_INCLUDE_DIR ${LUA_INCLUDE_DIR})

set(wxWidgets_COMPONENTS "gl;core;stc;html;aui;adv;net;base")
set(wxLuaBind_COMPONENTS ${wxWidgets_COMPONENTS})
#set(wxWidgets_EXCLUDE_COMMON_LIBRARIES ON) #wxWidgets built without tiff, expat ...
if(setDEBUG_LEVEL)
	SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DwxDEBUG_LEVEL=0")
endif()

if(MSVC)
	#add_compile_definitions(-D/EHsc)
	SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHsc")
endif()
add_subdirectory(wxlua/wxLua EXCLUDE_FROM_ALL)
set_target_properties(wxLuaModule PROPERTIES PREFIX "")

INSTALL(TARGETS wxLuaModule     
    RUNTIME DESTINATION ${LUAJIT_BIN}
    LIBRARY DESTINATION ${LUAJIT_BIN}
    ARCHIVE DESTINATION ${CMAKE_BINARY_DIR}/trash)

