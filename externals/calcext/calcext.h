// calcext.h - demo local header external (selftest phase 11)
//
// Stands for a header-only library like pocketfft whose Include.cmake sets a
// define on its target. The source package has to carry the define along; a
// package that only set the include folder would fail right here.
#pragma once

#ifndef CALCEXT_NO_THREADS
#error "CALCEXT_NO_THREADS missing - it comes from the target 'calcext' (Include.cmake / source package)"
#endif

#define CALCEXT_MARKER 42
