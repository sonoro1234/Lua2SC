PROJECT(random C)
cmake_minimum_required(VERSION 2.8)

if(WIN32)
add_definitions(-DLUA_BUILD_AS_DLL -DLUA_LIB)
endif()

if(WIN32)
set(LUA_LIBRARY_L ${LUA_LIBRARY})
else()
set(LUA_LIBRARY_L "")
endif()

INCLUDE_DIRECTORIES(${LUA_INCLUDE_DIR})

ADD_LIBRARY(random SHARED random.c lrandom.c)
set_target_properties(random PROPERTIES PREFIX "")
TARGET_LINK_LIBRARIES(random ${LUA_LIBRARY_L})

INSTALL (TARGETS random RUNTIME DESTINATION . LIBRARY DESTINATION .)