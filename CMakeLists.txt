# CMake project file for the CernVM-FS XRootD cache plug-in

cmake_minimum_required (VERSION 2.6)
project (cvmfsxrdcache)

#if(NOT (CMAKE_VERSION VERSION_LESS "2.8.12"))
#   cmake_policy(SET CMP0021 OLD)
#endif()

# make sure that the default is a RELEASE
if (NOT CMAKE_BUILD_TYPE)
  set (CMAKE_BUILD_TYPE RELEASE CACHE STRING
      "Choose the type of build, options are: None Debug Release."
      FORCE)
endif (NOT CMAKE_BUILD_TYPE)

# Add uninstall target
CONFIGURE_FILE(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/cmake/cmake_uninstall.cmake"
  IMMEDIATE @ONLY)
ADD_CUSTOM_TARGET(uninstall
  "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/cmake/cmake_uninstall.cmake")

set( CMAKE_MODULE_PATH
 ${PROJECT_SOURCE_DIR}/src
 ${PROJECT_SOURCE_DIR}/cmake )

include_directories(${PROJECT_SOURCE_DIR}/src)

include( cvmfsxrdcacheOSDefs )
#-------------------------------------------------------------------------------
# Generate the version header
#-------------------------------------------------------------------------------
add_custom_target(
  CvmfsCacheXrdVers.hh
  ${CMAKE_SOURCE_DIR}/genversion.sh ${CMAKE_SOURCE_DIR} )
macro( add_library _target )
  _add_library( ${_target} ${ARGN} )
  add_dependencies( ${_target} CvmfsCacheXrdVers.hh )
endmacro()

macro( add_executable _target )
  _add_executable( ${_target} ${ARGN} )
  add_dependencies( ${_target} CvmfsCacheXrdVers.hh )
endmacro()

#-------------------------------------------------------------------------------
# Libs required
#-------------------------------------------------------------------------------
find_package( LIBCVMFS_CACHE REQUIRED)
find_package (OpenSSL REQUIRED)
find_package( XRootD REQUIRED)

#-------------------------------------------------------------------------------
# Include directories required
#-------------------------------------------------------------------------------
#set (INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${LIBCVMFS_CACHE_INCLUDE_DIR})
#set (INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${OPENSSL_INCLUDE_DIR})
#set (INCLUDE_DIRECTORIES ${INCLUDE_DIRECTORIES} ${XROOTD_INCLUDE_DIR})

#-------------------------------------------------------------------------------
# Build in subdirectories
#-------------------------------------------------------------------------------
add_subdirectory( src )

#-------------------------------------------------------------------------------
# Summary
#-------------------------------------------------------------------------------
message( STATUS "----------------------------------------" )
message( STATUS "Installation path: " ${CMAKE_INSTALL_PREFIX} )
message( STATUS "Build type:        " ${CMAKE_BUILD_TYPE} )
message( STATUS "C++ flags:         " ${CMAKE_CXX_FLAGS} )
message( STATUS "----------------------------------------" )
