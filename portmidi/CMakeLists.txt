# portmidi
# Roger B. Dannenberg
# 20 Sep 2009

cmake_minimum_required(VERSION 2.6)


PROJECT(portmidi)


include_directories(pm_common porttime)
add_subdirectory(pm_common)

#add_subdirectory(pm_test)

#add_subdirectory(pm_dylib)

# Cannot figure out how to make an xcode Java application with CMake
#add_subdirectory(pm_java)

