// pack_demo.h
// Demo of a packaged shared library: C interface, version from Solution.json.
// Packaged by the target package_packdemo (see "packages" in Solution.json).

#ifndef PACK_DEMO_H
#define PACK_DEMO_H

#if defined(_WIN32)
#  if defined(PackDemo_EXPORTS)
#    define PACK_DEMO_API __declspec(dllexport)
#  else
#    define PACK_DEMO_API __declspec(dllimport)
#  endif
#else
#  define PACK_DEMO_API __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

// Version of the library as given in Solution.json ("defines" with {version})
PACK_DEMO_API const char* pack_demo_version(void);

#ifdef __cplusplus
}
#endif

#endif // PACK_DEMO_H
