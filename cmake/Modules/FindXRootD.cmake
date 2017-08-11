# Try to find XROOTD
# Once done, this will define
#
# XROOTD_FOUND       - system has XRootD
# XROOTD_INCLUDE_DIR - the XRootD include directory
# XROOTD_LIB_DIR     - the XRootD library directory
# XROOTD_PRIVATE_INDCLUDE_DIR - the XRootD private include directory
#
# XROOTD_DIR may be defined as a hint for where to look

FIND_PATH(XROOTD_INCLUDE_DIR XrdVersion.hh
  HINTS
  $PWD/xrootd/src/include/
  ${XROOTD_DIR}
  $ENV{XROOTD_DIR}
  /usr
  /opt/xrootd/
  PATH_SUFFIXES include/xrootd
  PATHS /opt/xrootd
)
if (XROOTD_INCLUDE_DIR)
   SET(XROOTD_FOUND TRUE)
endif()

if (XROOTD_FOUND)
  FIND_LIBRARY(XROOTD_XrdPosix_LIBRARY
    NAME XrdPosix
    HINTS
    ${XROOTD_DIR}
    $ENV{XROOTD_DIR}
    /usr
    /opt/xrootd/
    PATH_SUFFIXES lib
    PATH_SUFFIXES lib64
  )
  if (XROOTD_XrdPosix_LIBRARY)
     list(APPEND XROOTD_LIBRARIES_NOOP ${XROOTD_XrdPosix_LIBRARY})
  else ()
     message(STATUS "             libXrdPosix not found!")
     SET(XROOTD_FOUND FALSE)
  endif ()

  FIND_LIBRARY(XROOTD_XrdPosixPreload_LIBRARY
    NAME XrdPosixPreload
    HINTS
    ${XROOTD_DIR}
    $ENV{XROOTD_DIR}
    /usr
    /opt/xrootd/
    PATH_SUFFIXES lib
    PATH_SUFFIXES lib64
  )
  if (XROOTD_XrdPosixPreload_LIBRARY)
     list(APPEND XROOTD_LIBRARIES ${XROOTD_XrdPosixPreload_LIBRARY})
  else ()
     message(STATUS "             libXrdPosixPreload not found!")
     SET(XROOTD_FOUND FALSE)
  endif ()
endif()

# GET_FILENAME_COMPONENT( XROOTD_LIB_DIR ${XROOTD_UTILS} PATH )

INCLUDE( FindPackageHandleStandardArgs )
FIND_PACKAGE_HANDLE_STANDARD_ARGS( XRootD DEFAULT_MSG
                                          XROOTD_LIBRARIES
                                          XROOTD_INCLUDE_DIR
                                          )
