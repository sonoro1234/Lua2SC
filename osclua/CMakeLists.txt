PROJECT(osclua CXX)
cmake_minimum_required(VERSION 2.8)
set(OSCPACK_DIR ${CMAKE_SOURCE_DIR}/oscpack_1_1_0)

set(oscpack_src
    ${OSCPACK_DIR}/osc/OscOutboundPacketStream.cpp
	${OSCPACK_DIR}/osc/OscReceivedElements.cpp
    ${OSCPACK_DIR}/osc/OscTypes.cpp
)
add_definitions(-DLUA_BUILD_AS_DLL -DLUA_LIB)
INCLUDE_DIRECTORIES(${LUA_INCLUDE_DIR})
INCLUDE_DIRECTORIES(${OSCPACK_DIR})
add_library(oscpack STATIC ${oscpack_src})
#"oscpack/osc/OscPrintReceivedElements.cpp" 
ADD_LIBRARY(osclua SHARED osclua.cpp)
set_target_properties(osclua PROPERTIES PREFIX "")
TARGET_LINK_LIBRARIES(osclua ${LUA_LIBRARY} oscpack)

INSTALL (TARGETS osclua RUNTIME DESTINATION luabin)