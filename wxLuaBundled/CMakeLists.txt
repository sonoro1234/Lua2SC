#############################################
## Expects LUA_INCLUDE_DIR and LUA_LIBRARY
#################################################
PROJECT(wxLuaBundled CXX)
cmake_minimum_required(VERSION 3.13)

# This function is used to force a build on a dependant project at cmake configuration phase.
# 
function (build_external_project target source_dir argn) #FOLLOWING ARGUMENTS are the CMAKE_ARGS of ExternalProject_Add
message( "cmakeargs in are " ${argn})
    set(trigger_build_dir ${CMAKE_BINARY_DIR}/force_${target})

    #mktemp dir in build tree
    file(MAKE_DIRECTORY ${trigger_build_dir} ${trigger_build_dir}/build)

    #generate false dependency project
    set(CMAKE_LIST_CONTENT "
        cmake_minimum_required(VERSION 3.6)

        include(ExternalProject)
        ExternalProject_add(${target}
            SOURCE_DIR ${source_dir}
            CMAKE_ARGS ${argn}
            #INSTALL_COMMAND \"\"
            )

        add_custom_target(trigger_${target})
        add_dependencies(trigger_${target} ${target})
    ")

    file(WRITE ${trigger_build_dir}/CMakeLists.txt "${CMAKE_LIST_CONTENT}")
    message( "---------------------------configuring " ${target} "------------------------------")
    execute_process(COMMAND ${CMAKE_COMMAND}  -G ${CMAKE_GENERATOR} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} ..
        WORKING_DIRECTORY ${trigger_build_dir}/build
        )
    message( "---------------------------building " ${target} "------------------------------")
    execute_process(COMMAND ${CMAKE_COMMAND} --build .
        WORKING_DIRECTORY ${trigger_build_dir}/build
        )
    message( "---------------------------ended " ${target} "------------------------------")

endfunction()


# set(CMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/wxWidgets_install)
# set(wxBUILD_INSTALL ON)
# set(wxBUILD_MONOLITHIC OFF)
# set(wxBUILD_SHARED OFF)
# set(wxBUILD_COMPATIBILITY 2.8)
# set(wxUSE_RICHTEXT OFF)
# set(wxUSE_XRC OFF)

# add_subdirectory(wxWidgets)
set(wxWidgetsARGS "-DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/wxWidgets_install -DwxBUILD_INSTALL=ON -DwxBUILD_MONOLITHIC=OFF -DwxBUILD_SHARED=OFF -DwxBUILD_COMPATIBILITY=2.8  -DwxUSE_RICHTEXT=OFF -DwxUSE_XRC=OFF")
build_external_project(wxWidgets ${CMAKE_CURRENT_SOURCE_DIR}/wxWidgets ${wxWidgetsARGS})

##wxLua
set(CMAKE_CXX_FLAGS "-DLUA_COMPAT_MODULE")
if(WIN32)
	set(wxWidgets_ROOT_DIR ${CMAKE_BINARY_DIR}/wxWidgets_install)
	set(wxWidgets_CONFIGURATION mswu)
	if(MSVC)
		set(wxWidgets_LIB_DIR ${CMAKE_BINARY_DIR}/wxWidgets_install/lib/vc_lib)
	else() #mingw
		set(wxWidgets_LIB_DIR ${CMAKE_BINARY_DIR}/wxWidgets_install/lib/gcc_lib)
	endif()
endif()
if(UNIX)
	set(wxWidgets_CONFIG_EXECUTABLE ${CMAKE_BINARY_DIR}/wxWidgets_install/bin/wx-config)
endif()

set(BUILD_VERBOSELY TRUE)
set(BUILD_SHARED_LIBS FALSE)
set(wxLua_LUA_LIBRARY_USE_BUILTIN FALSE)
set(wxLua_LUA_LIBRARY ${LUA_LIBRARY})
set(wxLua_LUA_INCLUDE_DIR ${LUA_INCLUDE_DIR})
set(wxWidgets_COMPONENTS "stc;gl;html;aui;adv;core;net;base")
set(wxLuaBind_COMPONENTS "stc;gl;html;aui;adv;core;net;base")
if(MSVC)
	#add_compile_definitions(-D/EHsc)
	SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHsc")
endif()
add_subdirectory(wxLua/wxLua EXCLUDE_FROM_ALL)
add_custom_target(SecondaryAllBuild ALL DEPENDS wxLuaModule)
#add_dependencies(SecondaryAllBuild wxLuaModule)


INSTALL(TARGETS wxLuaModule     
    RUNTIME DESTINATION .
    LIBRARY DESTINATION ${CMAKE_BINARY_DIR}/trash
    ARCHIVE DESTINATION ${CMAKE_BINARY_DIR}/trash)
#add_dependencies(install wxLuaModule)