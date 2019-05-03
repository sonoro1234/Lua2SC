PROJECT(osclua CXX)
cmake_minimum_required(VERSION 2.8)
set(OSCPACK_DIR ${CMAKE_SOURCE_DIR}/oscpack_1_1_0)

set(oscpack_src
    ${OSCPACK_DIR}/osc/OscOutboundPacketStream.cpp
	${OSCPACK_DIR}/osc/OscReceivedElements.cpp
    ${OSCPACK_DIR}/osc/OscTypes.cpp
)

if(WIN32)
add_definitions(-DLUA_BUILD_AS_DLL -DLUA_LIB)
endif()

if(WIN32)
set(LUA_LIBRARY_L ${LUA_LIBRARY})
else()
set(LUA_LIBRARY_L "")
endif()

INCLUDE_DIRECTORIES(${LUA_INCLUDE_DIR})
INCLUDE_DIRECTORIES(${OSCPACK_DIR})
add_library(oscpack STATIC ${oscpack_src})
target_compile_options(oscpack PRIVATE -fPIC)
ADD_LIBRARY(osclua SHARED osclua.cpp)
set_target_properties(osclua PROPERTIES PREFIX "")
TARGET_LINK_LIBRARIES(osclua ${LUA_LIBRARY_L} oscpack)

INSTALL (TARGETS osclua RUNTIME DESTINATION . LIBRARY DESTINATION .)