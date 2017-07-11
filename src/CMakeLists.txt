set (CVMFS_CACHE_XRD_SOURCES
  cvmfs_cache_xrd.cc)

add_executable (cvmfs_cache_xrd ${CVMFS_CACHE_XRD_SOURCES})
target_link_libraries (cvmfs_cache_xrd ${LIBCVMFS_CACHE_LIBRARIES} ${OPENSSL_LIBRARIES} pthread)

install (
  TARGETS      cvmfs_cache_xrd
  RUNTIME
  DESTINATION    libexec/cvmfs/cache
)

set (CVMFS_CACHE_XRD_SOURCES
  cvmfs_cache_xrd.cc)

add_executable (cvmfs_cache_xrd_debug ${CVMFS_CACHE_XRD_SOURCES})
target_link_libraries (cvmfs_cache_xrd_debug ${LIBCVMFS_CACHE_LIBRARIES} ${OPENSSL_LIBRARIES} pthread)

set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -oO -g -fno-exceptions -fno-strict-aliasing -fasynchronous-unwind-tables -fno-omit-frame-pointer -fvisibility=hidden -Wall -D_REENTRANT -D__EXTENSIONS__ -D_LARGEFILE64_SOURCE -D__LARGE64_FILES")
install (
  TARGETS      cvmfs_cache_xrd_debug
  RUNTIME
  DESTINATION    libexec/cvmfs/cache
)

