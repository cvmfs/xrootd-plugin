
#-------------------------------------------------------------------------------
# The CernVM-FS XRootD cache plug-in
#-------------------------------------------------------------------------------

set (CVMFS_CACHE_XRD_SOURCES cvmfs_cache_xrd.cc)
include_directories( ${XROOTD_INCLUDE_DIR})
add_executable (cvmfs_cache_xrd ${CVMFS_CACHE_XRD_SOURCES})
message( STATUS "C++ flags:         " ${CMAKE_CXX_FLAGS} )
target_link_libraries (cvmfs_cache_xrd
                       ${LIBCVMFS_CACHE_LIBRARIES}
                       ${OPENSSL_LIBRARIES} ${RT_LIBRARY}
                       ${XROOTD_LIBRARIES}  pthread)

install (
  TARGETS      cvmfs_cache_xrd
  RUNTIME
  DESTINATION    libexec/cvmfs/cache
)
