cmake_minimum_required(VERSION 3.25)
project(zlib VERSION 1.4.0 LANGUAGES C)
include(GNUInstallDirs)

option(ZLIB_BUILD_STATIC "Build the static library" ON)
option(ZLIB_BUILD_SHARED "Build the shared library" ON)
set(sources
    adler32.c compress.c crc32.c deflate.c gzclose.c gzlib.c gzread.c gzwrite.c
    infback.c inffast.c inflate.c inftrees.c trees.c uncompr.c zutil.c)

function(add_zlib target type)
    add_library(${target} ${type} ${sources})
    target_include_directories(${target} PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>")
    target_compile_definitions(${target} PRIVATE
        "$<$<PLATFORM_ID:Darwin,Linux,FreeBSD>:HAVE_UNISTD_H>")
    set_target_properties(${target} PROPERTIES POSITION_INDEPENDENT_CODE ON)
    if(NOT WIN32)
        set_target_properties(${target} PROPERTIES OUTPUT_NAME z)
    endif()
    if(ZLIB_INSTALL)
        install(TARGETS ${target})
    endif()
endfunction()

option(ZLIB_INSTALL "Install zlib" ON)
if(ZLIB_BUILD_STATIC)
    add_zlib(zlibstatic STATIC)
endif()
if(ZLIB_BUILD_SHARED)
    add_zlib(zlib SHARED)
    set_target_properties(zlib PROPERTIES VERSION ${PROJECT_VERSION} SOVERSION 1
        WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()
if(ZLIB_INSTALL)
    install(FILES zlib.h zconf.h DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
    install(FILES LICENSE DESTINATION "${CMAKE_INSTALL_DATADIR}/licenses/zlib")
endif()

if(WIN32 AND TARGET zlib)
    enable_language(RC)
    configure_file(cmake/LibraryVersion.rc.in LibraryVersion.rc @ONLY)
    target_sources(zlib PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/LibraryVersion.rc")
endif()
