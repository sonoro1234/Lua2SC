rem set PATH=%PATH%;C:/mingw32-4.8.3-posix-dwarf/bin;C:/Program Files/CMake 2.8/bin/

cmake  -G"MinGW Makefiles"  -DCMAKE_BUILD_TYPE=Release  -DCMAKE_TOOLCHAIN_FILE="toolchain.cmake" ..
