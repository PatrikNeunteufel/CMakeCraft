# ==============================================================================
# ExecutableCreate.cmake – Executable Target Creation
# ==============================================================================
#
# Module:       ExecutableCreate.cmake
# Version:      0.1.0
# Date:         2025-12-05
# Part of:      CMake Architecture V2
#
# Description:
#   Creates an executable target from a prepared Context.
#   This module handles the actual CMake target creation with all
#   necessary configurations.
#
# Dependencies (must be loaded before):
#   - cmake/core/Context.cmake
#   - cmake/core/Errors.cmake
#   - cmake/core/Debug.cmake
#   - cmake/core/OutputDirs.cmake
#   - cmake/core/Warnings.cmake
#   - cmake/core/CompilerOptions.cmake
#
# Provides:
#   _create_executable_target(CTX)
#
# Expected Context Keys (set by ExecutableCollect):
#   NAME, PATH, TYPE, PCH_ENABLED, PCH_HEADER,
#   DEPENDENCIES, EXTERNALS, DEFINES, COMPILE_OPTIONS, LINK_OPTIONS
#
# Based on:
#   - master_concept v0.1
#   - Solution_Schema v0.1
#   - guidelines v0.1
#
# ==============================================================================

include_guard(GLOBAL)

# ==============================================================================
# Main Function: _create_executable_target
# ==============================================================================
#
# Creates the CMake executable target from the Context.
#
# Parameters:
#   CTX  - Context prefix (e.g. EXE_0, EXE_1, ...)
#
function(_create_executable_target CTX)
    
    # --------------------------------------------------------------------------
    # Read Context Data
    # --------------------------------------------------------------------------
    
    ctx_get(${CTX} NAME _name)
    ctx_get(${CTX} PATH _path)
    ctx_get(${CTX} TYPE _type)
    ctx_get(${CTX} VERSION _version)
    ctx_get(${CTX} PCH_ENABLED _pch_enabled)
    ctx_get(${CTX} PCH_HEADER _pch_header)
    ctx_get(${CTX} DEPENDENCIES _dependencies)
    ctx_get(${CTX} EXTERNALS _externals)
    ctx_get(${CTX} DEFINES _defines)
    ctx_get(${CTX} COMPILE_OPTIONS _compile_options)
    ctx_get(${CTX} LINK_OPTIONS _link_options)
    
    # --------------------------------------------------------------------------
    # Validate Source Directory
    # --------------------------------------------------------------------------
    
    set(_src_dir "${CMAKE_SOURCE_DIR}/${_path}")
    
    if(NOT EXISTS "${_src_dir}")
        cmake_fatal("E001" "Executable '${_name}': Source path does not exist: ${_path}")
    endif()
    
    # --------------------------------------------------------------------------
    # Create Target (GUI vs. CONSOLE)
    # --------------------------------------------------------------------------
    
    if(_type STREQUAL "GUI")
        if(WIN32)
            add_executable(${_name} WIN32)
        elseif(APPLE)
            add_executable(${_name} MACOSX_BUNDLE)
        else()
            add_executable(${_name})
        endif()
    else()
        # CONSOLE, CLI, HEADLESS, WORKER or other
        add_executable(${_name})
    endif()
    
    dbg(${DBG_RARE} "    add_executable(${_name}) [${_type}]" ID EXECUTABLES)
     
    # --------------------------------------------------------------------------
    # Collect Sources (GLOB)
    # --------------------------------------------------------------------------
    
    file(GLOB_RECURSE _sources
        "${_src_dir}/*.cpp"
        "${_src_dir}/*.cxx"
        "${_src_dir}/*.cc"
        "${_src_dir}/*.c"
    )
    
    file(GLOB_RECURSE _headers
        "${_src_dir}/*.h"
        "${_src_dir}/*.hpp"
        "${_src_dir}/*.hxx"
    )
    
    if(NOT _sources)
        cmake_warn("W101" "Executable '${_name}': No source files found in ${_path}")
    endif()
    
    target_sources(${_name} PRIVATE ${_sources} ${_headers})
    
    dbg(${DBG_RARE} "    Sources: ${_sources}" ID EXECUTABLES)
    
    # --------------------------------------------------------------------------
    # Include Directory
    # --------------------------------------------------------------------------
    
    target_include_directories(${_name} PRIVATE "${_src_dir}")
    
    # Additionally: If there is a pch/ subdirectory
    if(EXISTS "${_src_dir}/pch")
        target_include_directories(${_name} PRIVATE "${_src_dir}/pch")
    endif()
    
    # --------------------------------------------------------------------------
    # Precompiled Headers
    # --------------------------------------------------------------------------
    
    if(_pch_enabled)
        # Search for PCH path
        set(_pch_path "")
        
        if(EXISTS "${_src_dir}/${_pch_header}")
            set(_pch_path "${_src_dir}/${_pch_header}")
        elseif(EXISTS "${_src_dir}/pch/${_pch_header}")
            set(_pch_path "${_src_dir}/pch/${_pch_header}")
        endif()
        
        if(_pch_path)
            target_precompile_headers(${_name} PRIVATE "${_pch_path}")
            dbg(${DBG_RARE} "    PCH: ${_pch_path}" ID EXECUTABLES)
        else()
            cmake_warn("W101" "Executable '${_name}': PCH enabled but '${_pch_header}' not found")
        endif()
    endif()
    
    # --------------------------------------------------------------------------
    # Internal Dependencies (Libraries)
    # --------------------------------------------------------------------------
    
    foreach(_dep IN LISTS _dependencies)
        if(TARGET ${_dep})
            target_link_libraries(${_name} PRIVATE ${_dep})
            dbg(${DBG_RARE} "    Link: ${_dep} (internal)" ID EXECUTABLES)
        else()
            cmake_fatal("E101" "Dependency '${_dep}' for '${_name}' does not exist")
        endif()
    endforeach()
    
    # --------------------------------------------------------------------------
    # External Dependencies (Externals)
    # Note: Full integration happens in Phase 5/6
    # --------------------------------------------------------------------------
    
    foreach(_ext IN LISTS _externals)
        # Check if external is defined in central block
        get_property(_externals_json GLOBAL PROPERTY SOLUTION_EXTERNALS_JSON)
        _json_has_key("${_externals_json}" "${_ext}" _ext_defined)
        
        if(NOT _ext_defined)
            cmake_fatal("E010" "External '${_ext}' not defined in externals block")
        endif()
        
        # If external target already exists, link it
        # (will be created by Externals pipeline)
        if(TARGET ${_ext})
            target_link_libraries(${_name} PRIVATE ${_ext})
            dbg(${DBG_RARE} "    Link: ${_ext} (external)" ID EXECUTABLES)
        else()
            # External will be processed later by Dependencies.cmake
            dbg(${DBG_RARE} "    External pending: ${_ext}" ID EXECUTABLES)
        endif()
    endforeach()
    
    # --------------------------------------------------------------------------
    # Preprocessor Definitions
    # --------------------------------------------------------------------------
    
    if(_defines)
        target_compile_definitions(${_name} PRIVATE ${_defines})
        dbg(${DBG_RARE} "    Defines: ${_defines}" ID EXECUTABLES)
    endif()
    
    # --------------------------------------------------------------------------
    # Additional Compiler Options
    # --------------------------------------------------------------------------
    
    if(_compile_options)
        target_compile_options(${_name} PRIVATE ${_compile_options})
        dbg(${DBG_RARE} "    Compile Options: ${_compile_options}" ID EXECUTABLES)
    endif()
    
    # --------------------------------------------------------------------------
    # Additional Linker Options
    # --------------------------------------------------------------------------
    
    if(_link_options)
        target_link_options(${_name} PRIVATE ${_link_options})
        dbg(${DBG_RARE} "    Link Options: ${_link_options}" ID EXECUTABLES)
    endif()
    
    # --------------------------------------------------------------------------
    # Apply Standard Modules
    # --------------------------------------------------------------------------
    
    # Warnings (from Warnings.cmake)
    apply_warnings(${_name})
    
    # Compiler options (from CompilerOptions.cmake)
    apply_compiler_options(${_name})
    
    # Output directories (from OutputDirs.cmake)
    setup_output_dirs(${_name})
    
    # --------------------------------------------------------------------------
    # Version as Target Property
    # --------------------------------------------------------------------------
    
    if(NOT "${_version}" STREQUAL "")
        set_target_properties(${_name} PROPERTIES
            VERSION "${_version}"
        )
    endif()
    
    # --------------------------------------------------------------------------
    # Windows-specific: Subsystem for GUI
    # --------------------------------------------------------------------------
    
    if(WIN32 AND _type STREQUAL "GUI")
        set_target_properties(${_name} PROPERTIES
            WIN32_EXECUTABLE TRUE
        )
    endif()
    
    # --------------------------------------------------------------------------
    # macOS-specific: Bundle Properties
    # --------------------------------------------------------------------------
    
    if(APPLE AND _type STREQUAL "GUI")
        ctx_get(${CTX} DISPLAY_NAME _display_name)
        set_target_properties(${_name} PROPERTIES
            MACOSX_BUNDLE TRUE
            MACOSX_BUNDLE_GUI_IDENTIFIER "com.project.${_name}"
            MACOSX_BUNDLE_BUNDLE_NAME "${_display_name}"
            MACOSX_BUNDLE_BUNDLE_VERSION "${_version}"
            MACOSX_BUNDLE_SHORT_VERSION_STRING "${_version}"
        )
    endif()
    
endfunction()
