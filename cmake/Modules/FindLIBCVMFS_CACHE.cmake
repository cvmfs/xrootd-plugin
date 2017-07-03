# - Try to find VOMS
# Once done this will define
#
#  VOMS_FOUND - system has VOMS
#  VOMS_INCLUDE_DIRS - the VOMS include directory
#  VOMS_LIBRARIES - Link these to use VOMS
#  VOMS_DEFINITIONS - Compiler switches required for using VOMS
#
#  Copyright (c) 2008 Andreas Schneider <mail@cynapses.org>
#
#  Redistribution and use is allowed according to the terms of the New
#  BSD license.
#  For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#

if (LIBCVMFS_CACHE_LIBRARIES AND LIBCVMFS_CACHE_INCLUDE_DIR)
  # in cache already
  set(LIBCVMFS_CACHE_FOUND TRUE)
else (LIBCVMFS_CACHE_LIBRARIES AND LIBCVMFS_CACHE_INCLUDE_DIR)
  find_path(LIBCVMFS_CACHE_INCLUDE_DIR
    NAMES
      libcvmfs_cache.h
    PATHS
      /usr/include
      /usr/local/include
  )

  find_library(LIBCVMFS_CACHE_LIBRARIES
    NAMES
      libcvmfs_cache.a
    PATHS
      /usr/lib
      /usr/lib64
      /usr/local/lib
  )

  set(LIBCVMFS_CACHE_INCLUDE_DIRS
    ${LIBCVMFS_CACHE_INCLUDE_DIR}
  )

  if (LIBCVMFS_CACHE_INCLUDE_DIRS AND LIBCVMFS_CACHE_LIBRARIES)
     set(LIBCVMFS_CACHE_FOUND TRUE)
  endif (LIBCVMFS_CACHE_INCLUDE_DIRS AND LIBCVMFS_CACHE_LIBRARIES)

  if (LIBCVMFS_CACHE_FOUND)
    if (NOT LIBCVMFS_CACHE_FIND_QUIETLY)
      message(STATUS "Found libcvmfs_cache: ${LIBCVMFS_CACHE_LIBRARIES}")
    endif (NOT LIBCVMFS_CACHE_QUIETLY)
  else (LIBCVMFS_CACHE_FOUND)
    if (LIBCVMFS_CACHE_FIND_REQUIRED)
      message(FATAL_ERROR "Could not find libcvmfs_cache")
    endif (LIBCVMFS_CACHE_FIND_REQUIRED)
  endif (LIBCVMFS_CACHE_FOUND)

  # show the LIBCVMFS_CACHE_INCLUDE_DIRS and LIBCVMFS_CACHE_LIBRARIES variables only in the advanced view
  mark_as_advanced(LIBCVMFS_CACHE_INCLUDE_DIRS LIBCVMFS_CACHE_LIBRARIES)

endif (LIBCVMFS_CACHE_LIBRARIES AND LIBCVMFS_CACHE_INCLUDE_DIR)

