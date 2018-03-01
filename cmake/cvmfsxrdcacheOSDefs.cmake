#-------------------------------------------------------------------------------
# Define the OS variables
#-------------------------------------------------------------------------------

set( Linux    FALSE )
set( MacOSX   FALSE )

set( LIBRARY_PATH_PREFIX "lib" )

#-------------------------------------------------------------------------------
# Adapt C++ flags
#-------------------------------------------------------------------------------
set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64" )

#-------------------------------------------------------------------------------
# Linux
#-------------------------------------------------------------------------------
if( ${CMAKE_SYSTEM_NAME} STREQUAL Linux )
  set( Linux TRUE )
  include( GNUInstallDirs )
  add_definitions( -D__linux__=1 )
  set( EXTRA_LIBS rt )

#-------------------------------------------------------------------------------
# MacOSX
#-------------------------------------------------------------------------------
elseif( APPLE )
  set( MacOSX TRUE )

  # this is here because of Apple deprecating openssl and krb5
  set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated-declarations" )

  add_definitions( -D__macos__=1 )
  add_definitions( -DLT_MODULE_EXT=".dylib" )
  set( CMAKE_INSTALL_LIBDIR "lib" )
  set( CMAKE_INSTALL_BINDIR "bin" )
  set( CMAKE_INSTALL_MANDIR "share/man" )
  set( CMAKE_INSTALL_INCLUDEDIR "include" )
  set( CMAKE_INSTALL_DATADIR "share" )

#-------------------------------------------------------------------------------
# Other systems
#-------------------------------------------------------------------------------
else()
  message( FATAL_ERROR "support for your system not foreseen!")
endif()
