# cmake/core/Errors.cmake
# ========================
# Unified error handling for the entire build system
#
# Version: 1.1.0
# Date:    2026-11-09
# Status:  Release
# Author:  CMake Architecture Team
#
# Dependencies:
#   - None (base module, must be loaded first)
#
# Provides:
#   - cmake_fatal(CODE MESSAGE...)   - Abort build with error code
#   - cmake_warn(CODE MESSAGE...)    - Warning, build continues
#                                      (message parts are joined, see below)
#   - cmake_assert(CONDITION MSG)    - Assertion (for internal checks)
#   - cmake_require_field(CTX FIELD) - Field validation for Context
#
# Used by:
#   - All modules for error handling
#
# Error code ranges (codes actually raised: docs/de/konzepte/Guidelines.md 3.3,
# full reference: docs/de/guide/references/ErrorCodes.md):
#   E0xx - JSON/Parsing
#   E1xx - Target creation
#   E2xx - Externals
#   E3xx - Tests (standalone tests and app tests)
#   E4xx - Apps (app container)
#   E5xx - System externals
#   W0xx - Deprecation
#   W1xx - Config/Validation
#   W2xx - Tools/Setup
#   W3xx - Externals (Warnings)
#   W4xx - Apps (Warnings)
#   W5xx - System externals (Warnings)
#   W6xx-W9xx - Phase tests (cmake/buildSystemTest/ only)
#
# Changes v1.1.0 (CMakeCraft v0.14.1):
#   - cmake_fatal/cmake_warn join all message parts after CODE. Before, only
#     the first part was printed (E012, E502, E503, E220, W501 lost lines).
#   - Catalog: E3xx-E5xx, W4xx, W5xx added; E504/E505 now raised by the
#     system handler; E501/W502 dropped; codes that nothing raises are marked.
#
# Changes v0.1.5 (CMakeCraft v0.14.0):
#   - Documented E105 (compile_options on an INTERFACE library)
#   - Documented E106 (source package cannot be described in plain CMake)
#
# Changes v0.1.4:
#   - Documented E220 (Archive external without pin)
#   - Documented W111 (empty Source.cmake) and W112 (Package names a missing target)
#   - Documented W304 (Archive external not available)
#
# Changes v0.1.3:
#   - Documented E219 (Cache directory could not be removed)
#   - Documented W303 (Incomplete clone in cache)
#
# Changes v0.1.2:
#   - Added W3xx range for Externals warnings
#   - Documented E218 (Offline without cache)
#   - Documented W302 (Version mismatch in offline mode)

include_guard(GLOBAL)

# Message parts: cmake_fatal and cmake_warn join all arguments after CODE
# without separator, so long messages can be written as several quoted lines:
#     cmake_fatal("E012" "First line\n" "  second line")
# They read ARGV1 ... ARGV<n-1> instead of ARGN: ARGV<i> keeps an argument
# intact even when it contains a semicolon (e.g. "...: path;git").

# ============================================================================
# cmake_fatal - Fatal error (aborts build)
# ============================================================================
#[[
    cmake_fatal(CODE MESSAGE...)
    
    Aborts the build with a standardized error code.
    
    Parameters:
        CODE    - Mandatory: Error code (e.g. E001, E012, E201)
        MESSAGE - Mandatory: Error description; further arguments are
                  appended without separator (multi-line messages)
    
    Error Codes:
        E0xx - JSON/Parsing
            E001 - Required field missing
            E002 - Solution.json not found
            E003 - Schema version incompatible / invalid library type
            E004 - Invalid value in settings block
            E005 - Top-level CMakeLists.txt has no project() line
            E010 - External not defined in externals block
            E012 - External: no/multiple source fields
            E013 - Skipped external used by a target

        E1xx - Target Creation
            E101 - Dependency does not exist
            E102 - Target already exists
            E103 - Circular dependency (currently not raised - not detected)
            E104 - Source.cmake not found (mode=explicit)
            E105 - compile_options on an INTERFACE library
            E106 - Source package: library cannot be described in plain CMake

        E2xx - Externals
            E201 - Fetched external: no target in registry
            E202 - External fetch failed
            E203 - Target of an external not found
            E213 - Local external: Include.cmake not found
            E214 - Local external: path does not exist
            E215 - Fetched external: no tag/branch/commit
            E216 - Explicitly specified hook not found
            E217 - PostFetch hook required (cmakeSupport=false)
                   (currently not raised - reported as E201,
                   externals/fetched/Handler.cmake)
            E218 - External not cached and offline mode enabled
            E219 - Cache directory could not be removed
            E220 - Archive external: 'pin' field missing

        E3xx - Tests (standalone tests and app tests)
            E301 - No / unknown test framework
            E302 - Unknown test framework / source_from executable missing
            E303 - Test source directory not found
            E304 - App test target without type
            E305 - Path of an app test target does not exist

        E4xx - Apps
            E400 - App definition without name (collect phase)
            E401 - App has no 'name' field
            E402 - App path does not exist
            E403 - App has no src/ directory
            E404 - App has no source files in src/
            E405 - App dependency not found
            E406 - App has no main/ directory
            E407 - App has no source files in main/

        E5xx - System externals
            E502 - 'package' field missing
            E503 - find_package() failed (package not found / no config accepted)
            E504 - Package found, but not all requested components
            E505 - No package with a compatible version

    Example:
        cmake_fatal("E001" "Executable 'MyApp': Required field 'name' missing")
        cmake_fatal("E012" "External 'imgui': No source field specified")
        cmake_fatal("E218" "External 'glfw': Not cached and offline mode enabled")
]]
function(cmake_fatal CODE MESSAGE)
    set(_cf_text "")
    math(EXPR _cf_last "${ARGC} - 1")
    foreach(_cf_i RANGE 1 ${_cf_last})
        string(APPEND _cf_text "${ARGV${_cf_i}}")
    endforeach()
    message(FATAL_ERROR "[${CODE}] ${_cf_text}")
endfunction()

# ============================================================================
# cmake_warn - Warning (build continues)
# ============================================================================
#[[
    cmake_warn(CODE MESSAGE...)
    
    Outputs a warning, build continues.
    
    Parameters:
        CODE    - Mandatory: Warning code (e.g. W001, W103, W201)
        MESSAGE - Mandatory: Warning description; further arguments are
                  appended without separator (multi-line messages)
    
    Warning Codes:
        W0xx - Deprecation
            W001 - Deprecated schema version (currently not raised - only in
                   validate_solution_schema(), which nothing calls; Solution.cmake
                   checks the schema itself: E002/E003/W101/W102)
            W002 - Deprecated syntax/field (currently not raised)

        W1xx - Config/Validation
            W101 - Schema version too low / suboptimal configuration
                   (used for several validation hints)
            W102 - Schema version too high / optional feature missing
            W103 - Include.cmake creates executables
            W104 - Include.cmake includes example directories
            W105 - Version not SemVer compliant (currently not raised)
            W106 - Target has no version (currently not raised)
            W107 - Target overrides global standards (currently not raised)
            W108 - Multiple test frameworks without explicit field
                   (currently not raised)
            W109 - C++20 modules used (experimental)
            W110 - GLOB fallback active
            W111 - Source.cmake exists but defines no files
            W112 - Package names a target that does not exist
        
        W2xx - Tools/Setup
            W201 - Clang-Tidy enabled but not found
        
        W3xx - Externals
            W301 - Offline mode: using existing external (currently not raised -
                   a matching cache is used silently, a mismatch is W302)
            W302 - Version mismatch but offline mode - using cached
            W303 - Incomplete clone in cache - removed and fetched again
            W304 - Archive external not available - targets build without it

        W4xx - Apps
            W401 - App has no include/ directory / tests.targets is empty
            W402 - PCH enabled but header not found / parallel test settings
            W403 - Tests directory without sources / tests.targets without tests/

        W5xx - System externals
            W501 - Backup path used
    
    Example:
        cmake_warn("W001" "Schema version < 0.1, features limited")
        cmake_warn("W201" "ENABLE_CLANG_TIDY=ON but clang-tidy not found")
        cmake_warn("W302" "External 'glfw': Version mismatch but offline mode - using cached")
]]
function(cmake_warn CODE MESSAGE)
    set(_cw_text "")
    math(EXPR _cw_last "${ARGC} - 1")
    foreach(_cw_i RANGE 1 ${_cw_last})
        string(APPEND _cw_text "${ARGV${_cw_i}}")
    endforeach()
    message(WARNING "[${CODE}] ${_cw_text}")
endfunction()

# ============================================================================
# cmake_assert - Assertion (for internal consistency checks)
# ============================================================================
#[[
    cmake_assert(CONDITION MESSAGE)
    
    Checks a condition and aborts on failure.
    For internal consistency checks, not for user errors.
    
    NOTE: This is a macro(), not function(), to evaluate CONDITION correctly.
    
    Parameters:
        CONDITION - Mandatory: CMake condition (checked with if(NOT ...))
        MESSAGE   - Mandatory: Error description on failed assertion
    
    Example:
        cmake_assert(DEFINED _var "Variable must be defined")
        cmake_assert(_count GREATER 0 "Count must be > 0")
        cmake_assert("${_type}" STREQUAL "GUI" "Unexpected type")
]]
macro(cmake_assert CONDITION MESSAGE)
    if(NOT (${CONDITION}))
        cmake_fatal("ASSERT" "${MESSAGE}")
    endif()
endmacro()

# ============================================================================
# cmake_require_field - Field validation for Context
# ============================================================================
#[[
    cmake_require_field(CTX FIELD_NAME ENTITY_TYPE)
    
    Validates that a field is set in a Context.
    Uses ctx_get() from Context.cmake.
    
    Parameters:
        CTX         - Mandatory: Context prefix (e.g. EXE_0, LIB_CoreLib)
        FIELD_NAME  - Mandatory: Name of the field to check
        ENTITY_TYPE - Mandatory: Type for error message (e.g. "Executable")
    
    Errors:
        E001 - if field is missing or empty
    
    Example:
        cmake_require_field(EXE_0 NAME "Executable")
        cmake_require_field(EXE_0 PATH "Executable")
        cmake_require_field(LIB_0 TYPE "Library")
]]
function(cmake_require_field CTX FIELD_NAME ENTITY_TYPE)
    ctx_get(${CTX} ${FIELD_NAME} _value)
    if(NOT DEFINED _value OR "${_value}" STREQUAL "")
        ctx_get(${CTX} NAME _name)
        cmake_fatal("E001" "${ENTITY_TYPE} '${_name}': Missing field '${FIELD_NAME}'")
    endif()
endfunction()
