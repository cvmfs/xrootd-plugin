set (CVMFS_CACHE_XRD_SOURCES
  cvmfs_cache_xrd.cc)

add_executable (cvmfs_cache_xrd ${CVMFS_CACHE_XRD_SOURCES})
target_link_libraries (cvmfs_cache_xrd ${LIBCVMFS_CACHE_LIBRARIES} ${OPENSSL_LIBRARIES} pthread)

install (
  TARGETS      cvmfs_cache_xrd
  RUNTIME
  DESTINATION    libexec/cvmfs/cache
)


