/**
 * This file is part of the CernVM File System.
 *
 * A demo external cache plugin.  All data is stored in std::string.  Feature-
 * complete but quite inefficient.
 */

#define __STDC_FORMAT_MACROS

#include <alloca.h>
#include <inttypes.h>
#include <stdint.h>
#include <unistd.h>

#include <fcntl.h>
#include <errno.h>
#include <cassert>
#include <stdio.h>
#include <stdlib.h>
#include <cstdio>
#include <cstring>
#include <ctime>
#include <map>
#include <string>
#include <vector>
#include <sys/types.h>
#include <sys/stat.h>

#include "libcvmfs_cache.h"
// #include "XrdPosix/XrdPosix.hh"

using namespace std;  // NOLINT

#define BUF_SIZE 8192


const char *rproto = "root://";
const char *xproto = "xroot://";
const char *domain = "localhost:1094//";
char *urlbuffer = new char [BUF_SIZE];

struct Object {
  struct cvmcache_hash id;
  int fd;
  int32_t refcnt;
};

struct TxnInfo {
  struct cvmcache_hash id;
  Object partial_object;
};

/**
  * List of elements requested by a client.
  */
struct Listing {
  Listing() : pos(0) { }
  cvmcache_object_type type;
  uint64_t pos;
  vector<Object> *elems;
};

/**
  * Fancy way to organize the hash codes.
  */
struct ComparableHash {
  ComparableHash() { }
  explicit ComparableHash(const struct cvmcache_hash &h) : hash(h) { }
  struct cvmcache_hash hash;
  bool operator <(const ComparableHash &other) const {
    return cvmcache_hash_cmp(const_cast<cvmcache_hash *>(&(this->hash)),
                             const_cast<cvmcache_hash *>(&(other.hash))) < 0;
  }
};

map<uint64_t, TxnInfo> transactions;
map<ComparableHash, Object> storage;
map<uint64_t, Listing> listings;

struct cvmcache_context *ctx;

static int null_getpath(struct cvmcache_hash *id) {

  //Build URL
  strcpy(urlbuffer, rproto);
  strcat(urlbuffer, domain);
  strncat(urlbuffer, reinterpret_cast<const char*>(id->digest[0]), 2);
  strcat(urlbuffer, "/");
  strncat(urlbuffer, reinterpret_cast<const char*>(id->digest[2]), 17);

  return CVMCACHE_STATUS_OK;
}

/**
  * Checks the validity of the hash and reference count associated with the
  * desired data.
  */
static int null_chrefcnt(struct cvmcache_hash *id, int32_t change_by) {
  ComparableHash h(*id);

  null_getpath(id);

  if (storage.find(h) == storage.end())
    return CVMCACHE_STATUS_NOENTRY;
  Object obj = storage[h];

  if (change_by > 0){
    obj.fd = open(urlbuffer, O_RDONLY);
    if (obj.fd <0)
      return CVMCACHE_STATUS_BADCOUNT;
  }

  //TODO: check the appropriate error to return.
  if (change_by < 0){
    obj.fd = close(obj.fd);
    if (obj.fd <0)
      return CVMCACHE_STATUS_BADCOUNT;
  }

  obj.refcnt += change_by;
  return CVMCACHE_STATUS_OK;
}


/**
  * Retrieves object information from the hash.
  * Implements the same "integrity" check as the previous function.
  */
static int null_obj_info(
  struct cvmcache_hash *id,
  struct cvmcache_object_info *info)
{
  struct stat *statbuffer = new struct stat [BUF_SIZE];
  ComparableHash h(*id);
  if (storage.find(h) == storage.end())
    return CVMCACHE_STATUS_NOENTRY;

  Object obj = storage[h];

  //TODO: check if I should open the object or not
  if (obj.refcnt <= 0)
    return CVMCACHE_STATUS_BADCOUNT;

  if (!(fstat(obj.fd, statbuffer)))
    info->size=statbuffer->st_size;
  else
    return -errno;

  delete [] statbuffer;
  return CVMCACHE_STATUS_OK;
}


/**
  * Copies the contents of the cache in the buffer (?)
  */
static int null_pread(struct cvmcache_hash *id,
                    uint64_t offset,
                    uint32_t *size,
                    unsigned char *buffer)
{
  struct stat *statbuffer = new struct stat [BUF_SIZE];

  ComparableHash h(*id);
  int numbytes;
  null_getpath(id);

  if (storage.find(h) == storage.end())
    return CVMCACHE_STATUS_NOENTRY;

  Object obj = storage[h];
  if (obj.fd < 0)
    return CVMCACHE_STATUS_NOENTRY;

  if (fstat(obj.fd, statbuffer))
    return -errno;
  size_t file_size = statbuffer->st_size;

  delete [] statbuffer;
  // returns an error if the offset is larget than the file size
  if (offset > lseek(obj.fd, 0, SEEK_END))
    return CVMCACHE_STATUS_OUTOFBOUNDS;

  //number of bytes the data occupies
  numbytes = pread(obj.fd, buffer, file_size, offset);
  if (numbytes < 0)
    return -errno;

  return CVMCACHE_STATUS_OK;
}

static void Usage(const char *progname) {
  printf("%s <config file>\n", progname);
}


int main(int argc, char **argv) {
  if (argc < 2) {
    Usage(argv[0]);
    return 1;
  }

  cvmcache_init_global();

  cvmcache_option_map *options = cvmcache_options_init();
  if (cvmcache_options_parse(options, argv[1]) != 0) {
    printf("cannot parse options file %s\n", argv[1]);
    return 1;
  }
  char *locator = cvmcache_options_get(options, "CVMFS_CACHE_PLUGIN_LOCATOR");
  if (locator == NULL) {
    printf("CVMFS_CACHE_PLUGIN_LOCATOR missing\n");
    cvmcache_options_fini(options);
    return 1;
  }

  cvmcache_spawn_watchdog(NULL);

  struct cvmcache_callbacks callbacks;
  memset(&callbacks, 0, sizeof(callbacks));
  callbacks.cvmcache_chrefcnt = null_chrefcnt;
  callbacks.cvmcache_obj_info = null_obj_info;
  callbacks.cvmcache_pread = null_pread;
  callbacks.capabilities = CVMCACHE_CAP_NONE;


  ctx = cvmcache_init(&callbacks);
  int retval = cvmcache_listen(ctx, locator);
  if (!retval) {
    fprintf(stderr, "failed to listen on %s\n", locator);
    return 1;
  }
  printf("Listening for cvmfs clients on %s\n", locator);
  printf("NOTE: this process needs to run as user cvmfs\n\n");

  // Starts the I/O processing thread
  cvmcache_process_requests(ctx, 0);

  if (!cvmcache_is_supervised()) {
    printf("Press <R ENTER> to ask clients to release nested catalogs\n");
    printf("Press <Ctrl+D> to quit\n");
    while (true) {
      char buf;
      int retval = read(fileno(stdin), &buf, 1);
      if (retval != 1)
        break;
      if (buf == 'R') {
        printf("  ... asking clients to release nested catalogs\n");
        cvmcache_ask_detach(ctx);
      }
    }
    cvmcache_terminate(ctx);
  }

  cvmcache_wait_for(ctx);
  printf("  ... good bye\n");

  cvmcache_options_free(locator);
  cvmcache_options_fini(options);
  cvmcache_terminate_watchdog();
  cvmcache_cleanup_global();
  return 0;
}
