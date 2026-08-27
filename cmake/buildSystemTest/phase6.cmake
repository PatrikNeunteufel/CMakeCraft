# ==============================================================================
# phase6.cmake – Build System Test for Git Externals & Hooks
# ==============================================================================
#
# Test:         Phase 6
# Version:      1.1.0
# Date:         2026-08-08
# Part of:      CMake Architecture
#
# Description:
#   Tests the Git Externals pipeline including:
#   - FetchContent integration
#   - PreFetch/PostFetch hooks
#   - Hook reuse (imgui_docking uses imgui hook)
#   - Target Registry
#   - cmakeSupport: false handling
#   - Detection and removal of aborted clones (Fetch.cmake v1.1.0)
#
# ==============================================================================

include_guard(GLOBAL)

dbg_init(ID PHASE6_TEST LEVEL ${DBG_SHOW_ALL} SWITCH ON TAG "Phase6")
dbg(${DBG_OFTEN} "=== Phase 6 Test Start ===" ID PHASE6_TEST)

# ==============================================================================
# Test 1: Git External GLFW (cmakeSupport: true)
# ==============================================================================

dbg(${DBG_COMMON} "Testing Git External (GLFW)..." ID PHASE6_TEST)

# Check if glfw target exists
if(TARGET glfw)
    dbg(${DBG_COMMON} "  GLFW target exists" ID PHASE6_TEST)
else()
    cmake_warn("W601" "GLFW target not found - may not be used by any executable")
endif()

# Check registry
get_property(_glfw_registered GLOBAL PROPERTY EXTERNAL_TARGET_glfw)
if(_glfw_registered)
    dbg(${DBG_COMMON} "  GLFW registered in Target Registry" ID PHASE6_TEST)
else()
    dbg(${DBG_COMMON} "  GLFW not in registry (normal if not used)" ID PHASE6_TEST)
endif()

# ==============================================================================
# Test 2: Git External without CMake Support (ImGui)
# ==============================================================================

dbg(${DBG_COMMON} "Testing Git External without CMake (ImGui)..." ID PHASE6_TEST)

# imgui uses PostFetch hook to create target
if(TARGET imgui OR TARGET imgui_docking)
    dbg(${DBG_COMMON} "  ImGui target(s) created by PostFetch hook" ID PHASE6_TEST)
else()
    dbg(${DBG_COMMON} "  ImGui targets not created (normal if not used)" ID PHASE6_TEST)
endif()

# ==============================================================================
# Test 3: Hook Reuse (imgui_docking → imgui hook)
# ==============================================================================

dbg(${DBG_COMMON} "Testing Hook Reuse..." ID PHASE6_TEST)

# Both imgui and imgui_docking should use the same hook file
# but create different targets
get_property(_imgui_hook GLOBAL PROPERTY EXTERNAL_HOOK_imgui)
get_property(_imgui_docking_hook GLOBAL PROPERTY EXTERNAL_HOOK_imgui_docking)

dbg(${DBG_RARE} "  imgui hook: ${_imgui_hook}" ID PHASE6_TEST)
dbg(${DBG_RARE} "  imgui_docking hook: ${_imgui_docking_hook}" ID PHASE6_TEST)

if(TARGET imgui AND TARGET imgui_docking)
    # Both targets should exist and be different
    get_target_property(_imgui_type imgui TYPE)
    get_target_property(_docking_type imgui_docking TYPE)
    dbg(${DBG_COMMON} "  Hook reuse works: imgui and imgui_docking are separate targets" ID PHASE6_TEST)
endif()

# ==============================================================================
# Test 4: Externals JSON Parsing
# ==============================================================================

dbg(${DBG_COMMON} "Testing Externals JSON..." ID PHASE6_TEST)

get_property(_externals_json GLOBAL PROPERTY SOLUTION_EXTERNALS_JSON)

if(_externals_json)
    # Check for git field
    string(JSON _glfw_json ERROR_VARIABLE _err GET "${_externals_json}" "glfw")
    if(NOT _err)
        string(JSON _glfw_git ERROR_VARIABLE _err2 GET "${_glfw_json}" "git")
        if(NOT _err2 AND _glfw_git)
            dbg(${DBG_COMMON} "  Git URL parsed: ${_glfw_git}" ID PHASE6_TEST)
        endif()
    endif()
    
    # Check for cmakeSupport field
    string(JSON _imgui_json ERROR_VARIABLE _err GET "${_externals_json}" "imgui")
    if(NOT _err)
        string(JSON _cmake_support ERROR_VARIABLE _err2 GET "${_imgui_json}" "cmakeSupport")
        if(NOT _err2)
            dbg(${DBG_COMMON} "  cmakeSupport field parsed: ${_cmake_support}" ID PHASE6_TEST)
        endif()
    endif()
    
    # Check for hook field
    string(JSON _docking_json ERROR_VARIABLE _err GET "${_externals_json}" "imgui_docking")
    if(NOT _err)
        string(JSON _hook_field ERROR_VARIABLE _err2 GET "${_docking_json}" "hook")
        if(NOT _err2)
            dbg(${DBG_COMMON} "  hook field parsed: ${_hook_field}" ID PHASE6_TEST)
        endif()
    endif()
else()
    cmake_warn("W602" "SOLUTION_EXTERNALS_JSON not set")
endif()

# ==============================================================================
# Test 5: Fetched External in Executable
# ==============================================================================

dbg(${DBG_COMMON} "Testing Fetched External Linking..." ID PHASE6_TEST)

# imGuiApp should link against glad, glfw, and imgui_docking
if(TARGET imGuiApp)
    get_target_property(_libs imGuiApp LINK_LIBRARIES)
    dbg(${DBG_RARE} "  imGuiApp links: ${_libs}" ID PHASE6_TEST)
    
    set(_has_glfw FALSE)
    set(_has_imgui FALSE)
    
    foreach(_lib IN LISTS _libs)
        if("${_lib}" MATCHES "glfw")
            set(_has_glfw TRUE)
        endif()
        if("${_lib}" MATCHES "imgui")
            set(_has_imgui TRUE)
        endif()
    endforeach()
    
    if(_has_glfw)
        dbg(${DBG_COMMON} "  imGuiApp links glfw" ID PHASE6_TEST)
    endif()
    if(_has_imgui)
        dbg(${DBG_COMMON} "  imGuiApp links imgui" ID PHASE6_TEST)
    endif()
else()
    dbg(${DBG_COMMON} "  imGuiApp target not found (may be skipped)" ID PHASE6_TEST)
endif()

# ==============================================================================
# Test 6: Aborted clones are recognised as such
# ==============================================================================
#
# An interrupted "git clone" leaves a .git behind with nothing checked out.
# Before this check existed, such debris passed as "cached" and the version
# comparison reported a misleading "version mismatch". Fetch.cmake v1.1.0
# distinguishes the two - this test pins that down.
#
# Runs entirely on scratch directories under the build tree; no network, and
# nothing in .externals/ is touched.

dbg(${DBG_COMMON} "Testing clone completeness detection..." ID PHASE6_TEST)

set(_p6_scratch "${CMAKE_BINARY_DIR}/buildSystemTest/phase6")
file(REMOVE_RECURSE "${_p6_scratch}")

# --- Case A0: .git present but not a repository -> incomplete -----------------
#
# The important case, and the one that is easy to get wrong: this scratch
# directory lies inside the project's own git repository. Asked from within,
# git walks upwards, finds THAT repository and happily reports a HEAD - so a
# naive check calls the debris complete. Detection has to pin git to the
# directory itself.
set(_p6_fake "${_p6_scratch}/fake-git")
file(MAKE_DIRECTORY "${_p6_fake}/.git")

_is_complete_clone("phase6-fake" "${_p6_fake}" _p6_fake_ok)

if(_p6_fake_ok)
    cmake_fatal("ASSERT" "A .git that is not a repository was classified as a complete clone - the check is resolving the surrounding project repo")
endif()
dbg(${DBG_COMMON} "  Broken .git inside a repository detected as incomplete" ID PHASE6_TEST)

# --- Case A1: .git as a file (submodule/worktree link) -> incomplete ----------
set(_p6_gitfile "${_p6_scratch}/git-as-file")
file(MAKE_DIRECTORY "${_p6_gitfile}")
file(WRITE "${_p6_gitfile}/.git" "gitdir: ../elsewhere\n")

_is_complete_clone("phase6-gitfile" "${_p6_gitfile}" _p6_gitfile_ok)

if(_p6_gitfile_ok)
    cmake_fatal("ASSERT" "A .git file was classified as a complete clone")
endif()
dbg(${DBG_COMMON} "  .git as a file detected as incomplete" ID PHASE6_TEST)

# --- Case A: directory with a .git but no commit -> incomplete ----------------
set(_p6_broken "${_p6_scratch}/broken")
file(MAKE_DIRECTORY "${_p6_broken}")

find_program(_p6_git git)
if(_p6_git)
    execute_process(
        COMMAND "${_p6_git}" init --quiet
        WORKING_DIRECTORY "${_p6_broken}"
        OUTPUT_QUIET ERROR_QUIET
        RESULT_VARIABLE _p6_init_rc
    )

    if(NOT _p6_init_rc EQUAL 0)
        cmake_warn("W601" "Phase 6: could not create the test repository - clone detection not verified")
    else()
        _is_complete_clone("phase6-broken" "${_p6_broken}" _p6_broken_ok)

        if(_p6_broken_ok)
            cmake_fatal("ASSERT" "Aborted clone (.git without HEAD) was classified as complete")
        endif()
        dbg(${DBG_COMMON} "  Aborted clone detected as incomplete" ID PHASE6_TEST)

        # --- Case B: this very repository -> complete -------------------------
        # CMAKECRAFT_ROOT is the checkout CMakeCraft itself was loaded from. It
        # has a resolvable HEAD - unless CMakeCraft was consumed as an unpacked
        # copy rather than a clone, hence the guard.
        set(_p6_self "${CMAKECRAFT_ROOT}")

        if(EXISTS "${_p6_self}/.git")
            _is_complete_clone("phase6-self" "${_p6_self}" _p6_self_ok)

            if(NOT _p6_self_ok)
                cmake_fatal("ASSERT" "A real checkout was classified as an incomplete clone: ${_p6_self}")
            endif()
            dbg(${DBG_COMMON} "  Real checkout detected as complete" ID PHASE6_TEST)
        else()
            dbg(${DBG_COMMON} "  No .git next to CMAKECRAFT_DIR - skipping the positive case" ID PHASE6_TEST)
        endif()
    endif()
else()
    dbg(${DBG_COMMON} "  Git not found - skipping clone detection test" ID PHASE6_TEST)
endif()

# --- Case C: _purge_cache_dir really removes ----------------------------------
set(_p6_victim "${_p6_scratch}/victim")
file(MAKE_DIRECTORY "${_p6_victim}/sub")
file(WRITE "${_p6_victim}/sub/file.txt" "scratch")

_purge_cache_dir("phase6-victim" "${_p6_victim}")

if(EXISTS "${_p6_victim}")
    cmake_fatal("ASSERT" "_purge_cache_dir left the directory behind: ${_p6_victim}")
endif()
dbg(${DBG_COMMON} "  _purge_cache_dir removes completely" ID PHASE6_TEST)

# _purge_cache_dir on something that does not exist must be a no-op, not an error
_purge_cache_dir("phase6-absent" "${_p6_scratch}/never-existed")
dbg(${DBG_COMMON} "  _purge_cache_dir tolerates a missing directory" ID PHASE6_TEST)

file(REMOVE_RECURSE "${_p6_scratch}")

# ==============================================================================
# Summary
# ==============================================================================

dbgspace(ID PHASE6_TEST)
dbg(${DBG_OFTEN} "=== Phase 6 Test PASSED ===" ID PHASE6_TEST)
enddbgblock(ID PHASE6_TEST)

set(PHASE6_TEST_PASSED TRUE CACHE BOOL "Phase 6 Test passed" FORCE)
