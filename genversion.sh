#!/bin/bash

#-------------------------------------------------------------------------------
# Print help
#-------------------------------------------------------------------------------
function printHelp()
{
  echo "Usage:"                                                1>&2
  echo "${0} [--help|--print-only| --tag-only] [SOURCEPATH]"   1>&2
  echo "  --help       prints this message"                    1>&2
  echo "  --print-only prints the version to stdout and quits" 1>&2
  echo "  --tag-only   prints last tag to stdout and quits" 1>&2
}

#-------------------------------------------------------------------------------
# Check the parameters
#-------------------------------------------------------------------------------
while test ${#} -ne 0; do
  if test x${1} = x--help; then
    PRINTHELP=1
  elif test x${1} = x--print-only; then
    PRINTONLY=1
  elif test x${1} = x--tag-only; then
    TAGONLY=1
  else
    SOURCEPATH=${1}
  fi
  shift
done

if test x$PRINTHELP != x; then
  printHelp ${0}
  exit 0
fi

if test x$SOURCEPATH != x; then
  SOURCEPATH=${SOURCEPATH}/
  if test ! -d $SOURCEPATH; then
    echo "The given source path does not exist: ${SOURCEPATH}" 1>&2
    exit 1
  fi
fi

#-------------------------------------------------------------------------------
# Default if everything fails
#-------------------------------------------------------------------------------
VERSION="unknown"

#-------------------------------------------------------------------------------
# We're not inside a git repo
#-------------------------------------------------------------------------------
if test ! -d ${SOURCEPATH}.git; then
  #-----------------------------------------------------------------------------
  # We cannot figure out what version we are
  #----------------------------------------------------------------------------
  echo "[I] No git repository info found. Trying to interpret VERSION_INFO" 1>&2
  if test ! -r ${SOURCEPATH}VERSION_INFO; then
    echo "[!] VERSION_INFO file absent. Unable to determine the version. Using \"unknown\"" 1>&2
  elif test x"`grep Format ${SOURCEPATH}VERSION_INFO`" != x; then
    echo "[!] VERSION_INFO file invalid. Unable to determine the version. Using \"unknown\"" 1>&2

  #-----------------------------------------------------------------------------
  # The version file exists and seems to be valid so we know the version
  #----------------------------------------------------------------------------
  else
     TAG="`grep Tag ${SOURCEPATH}VERSION_INFO`"
     TAG=${TAG/Tag:/}
     VERSION=${TAG// /}
  fi

#-------------------------------------------------------------------------------
# We're in a git repo so we can try to determine the version using that
#-------------------------------------------------------------------------------
else
  echo "[I] Determining version from git" 1>&2
  EX="`which git`"
  if test x"${EX}" == x -o ! -x "${EX}"; then
    echo "[!] Unable to find git in the path: setting the version tag to unknown" 1>&2
  else
    #---------------------------------------------------------------------------
    # Sanity check
    #---------------------------------------------------------------------------
    CURRENTDIR=$PWD
    if [ x${SOURCEPATH} != x ]; then
      cd ${SOURCEPATH}
    fi
    git log -1 >/dev/null 2>&1
    if test $? -ne 0; then
      echo "[!] Error while generating src/XrdVersion.hh, the git repository may be corrupted" 1>&2
      echo "[!] Setting the version tag to unknown" 1>&2
    else
      #-------------------------------------------------------------------------
      # Get the tag, exact or not
      #-------------------------------------------------------------------------
      VERSION="`git describe --tags`"
    fi
    cd $CURRENTDIR
  fi
fi

#-------------------------------------------------------------------------------
# Variable to fill
#-------------------------------------------------------------------------------
VTG=""
VMJ=""
VMN=""
VPT=""
VCM=""
VRL="0"
NUMVERSION="-1"
if test ! x$VERSION == xunknown; then
   # Drop the leading 'v'
   VERSION=${VERSION/v/}
   # Last tag
   VTG=`echo $VERSION | sed "s|\(.*\)\-\(.*\)\-\(.*\)|\1|"`
   if test ! x$VTG == x$VERSION ; then
      # Since last patch ?
      VRL=`echo $VERSION | sed "s|\(.*\)\-\(.*\)\-\(.*\)|\2|"`
      # The patch
      VCM=`echo $VERSION | sed "s|\(.*\)\-\(.*\)\-\(.*\)|\3|"`
      if  test ! x$VCM == x &&  test ! x$VRL == x0 ; then
         VRL="1"
      fi
   fi

   # The major
   VMJ=`echo $VTG | sed "s|\([0-9]\)\.\([0-9]\)\.\([0-9]\)|\1|"`
   # The minor
   VMN=`echo $VTG | sed "s|\([0-9]\)\.\([0-9]\)\.\([0-9]\)|\2|"`
   # The patch
   VPT=`echo $VTG | sed "s|\([0-9]\)\.\([0-9]\)\.\([0-9]\)|\3|"`
   if test x$VMJ == x0 ; then
      if test x$VMN == x0 ; then
         NUMVERSION=`printf "%d%01d" $VPT $VRL`
      else
         NUMVERSION=`printf "%d%02d%01d" $VMN $VPT $VRL`
      fi
   else
      NUMVERSION=`printf "%d%02d%02d%01d" $VMJ $VMN $VPT $VRL`
   fi
   # The string
   if test x$VCM == x || test x$VRL == x0 ; then
      VERSIONS=`printf "v%d.%d.%d" $VMJ $VMN $VPT`
   else
      VERSIONS=`printf "v%d.%d.%d-%s" $VMJ $VMN $VPT $VCM`
   fi
fi

#-------------------------------------------------------------------------------
# Print the version info and exit if necessary
#-------------------------------------------------------------------------------
if test x$PRINTONLY != x; then
  echo $VERSIONS
  exit 0
fi

#-------------------------------------------------------------------------------
# Print the last tag info and exit if necessary
#-------------------------------------------------------------------------------
if test x$TAGONLY != x; then
  echo $VTG
  exit 0
fi

#-------------------------------------------------------------------------------
# Create CvmfsCacheXrdVers.h
#-------------------------------------------------------------------------------
if test ! -r ${SOURCEPATH}src/CvmfsCacheXrdVers.h.in; then
   echo "[!] Unable to find src/CvmfsCacheXrdVers.h.in" 1>&2
   exit 1
fi

sed -e "s/#define XrdVOMSVERSION  \"unknown\"/#define XrdVOMSVERSION  \"$VERSIONS\"/" ${SOURCEPATH}src/CvmfsCacheXrdVers.h.in | \
sed -e "s/#define XrdVOMSVERSNUM  \"xyyzzr\"/#define XrdVOMSVERSNUM  $NUMVERSION/" \
> src/CvmfsCacheXrdVers.h.new

if test $? -ne 0; then
  echo "[!] Error while generating src/CvmfsCacheXrdVers.h from the input template" 1>&2
  exit 1
fi

if test ! -e src/CvmfsCacheXrdVers.h; then
  mv src/CvmfsCacheXrdVers.h.new src/CvmfsCacheXrdVers.h
elif test x"`diff src/CvmfsCacheXrdVers.h.new src/CvmfsCacheXrdVers.h`" != x; then
  mv src/CvmfsCacheXrdVers.h.new src/CvmfsCacheXrdVers.h
else
  rm src/CvmfsCacheXrdVers.h.new
fi
echo "[I] src/CvmfsCacheXrdVers.h successfuly generated" 1>&2
