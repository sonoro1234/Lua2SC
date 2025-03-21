PROJECT(luasocket C)
cmake_minimum_required(VERSION 2.8)


aux_source_directory(./luasocket/src socket_src)
list(REMOVE_ITEM socket_src ./luasocket/src/mime.c)
set(LUASOCKET_LINK)
if(WIN32)
	list(REMOVE_ITEM socket_src ./luasocket/src/serial.c ./luasocket/src/unix.c ./luasocket/src/usocket.c ./luasocket/src/unixdgram.c ./luasocket/src/unixstream.c)
	add_definitions(-D_WIN32_WINNT=0x0600) ##should be this or the next two for working on XP
	#add_definitions(-D_WIN32_WINNT=0x0501)
	#add_definitions(-DLUASOCKET_INET_PTON)
	set(LUASOCKET_LINK  wsock32 ws2_32 )
	set(POSTN dll)
	set(LUA_LIBRARY_L ${LUA_LIBRARY})
else()
	list(REMOVE_ITEM socket_src ./luasocket/src/wsocket.c) 
	set(POSTN so)
	set(LUA_LIBRARY_L "")
endif(WIN32)


INCLUDE_DIRECTORIES(${LUA_INCLUDE_DIR})

add_definitions(-DLUASOCKET_DEBUG)

if(WIN32)
add_definitions(-DLUA_BUILD_AS_DLL -DLUA_LIB)
endif()

add_definitions( -DLUASOCKET_EXPORTS)

add_library(socket SHARED ${socket_src})
target_compile_definitions(socket PUBLIC UDP_DATAGRAMSIZE=65536)
ADD_LIBRARY(mime SHARED ./luasocket/src/mime.c ./luasocket/src/compat.c)

if(MSVC)
	set_target_properties(socket PROPERTIES PREFIX "lib")
	set_target_properties(mime PROPERTIES PREFIX "lib")
endif()

TARGET_LINK_LIBRARIES(socket ${LUA_LIBRARY_L} ${LUASOCKET_LINK} )
TARGET_LINK_LIBRARIES(mime ${LUA_LIBRARY_L}) 

######install
#set default LDIR and CDIR if not given
if( NOT CDIR)
	set(CDIR .)
endif()
if( NOT LDIR)
	set(LDIR ./lua)
endif()

##cant use set_target_properties to rename because one overwrites the other so:
INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/libsocket.${POSTN} DESTINATION ${CDIR}/socket RENAME core.${POSTN})
INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/libmime.${POSTN} DESTINATION ${CDIR}/mime RENAME core.${POSTN})  

install(DIRECTORY luasocket/src/ DESTINATION ${LDIR}/socket
        FILES_MATCHING PATTERN "*.lua"
		PATTERN ltn12.lua EXCLUDE 
		PATTERN socket.lua EXCLUDE
		PATTERN mime.lua EXCLUDE)
install(FILES ./luasocket/src/socket.lua ./luasocket/src/mime.lua ./luasocket/src/ltn12.lua DESTINATION ${LDIR})