# Git Externals: AI & GPU Computing — Reference

> **Version:** 1.0.0  
> **Date:** 2025-12-26  
> **Type:** Reference  
> **Status:** Stable  
> **Target Audience:** All developers  
> **Language:** English  
> **German:** [Git_Externals_AI.md](../../../../de/guide/references/externals/Git_Externals_AI.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [LLM Inference](#2-llm-inference)
3. [ML Frameworks](#3-ml-frameworks)
4. [CUDA / GPU Computing](#4-cuda--gpu-computing)
5. [Notes](#5-notes)
6. [Quick Reference](#6-quick-reference)
7. [See Also](#7-see-also)
8. [Changelog](#8-changelog)

---

## 1. Overview

This document describes libraries for machine learning, LLM inference and GPU computing.

### Categories

| Category | Libraries |
|----------|-----------|
| LLM Inference | llama.cpp, whisper.cpp, ggml |
| ML Frameworks | onnxruntime, ncnn |
| CUDA/GPU | thrust, cub, cutlass |

### Complexity Note

⚠️ Many of these libraries have complex build requirements (CUDA, special hardware). Check the documentation of the respective library before integrating it.

---

## 2. LLM Inference

### 2.1 llama.cpp

> **Purpose:** Efficient LLM inference in C/C++ (LLaMA, Mistral, Phi, etc.).

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/ggerganov/llama.cpp.git` |
| **Current Tag** | `b2000+` (frequent releases) |
| **CMake Support** | ✅ |
| **Hook** | PreFetch recommended |
| **CUDA** | Optional (significant speedup) |
| **Complexity** | 🟡 Medium |

```json
"llama_cpp": {
    "git": "https://github.com/ggerganov/llama.cpp.git",
    "tag": "b2500"
}
```

**PreFetch Hook (llama_cpp.cmake):**
```cmake
set(LLAMA_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
# GPU Acceleration (optional)
set(LLAMA_CUDA OFF CACHE BOOL "" FORCE)      # NVIDIA CUDA
set(LLAMA_VULKAN OFF CACHE BOOL "" FORCE)    # Vulkan (cross-platform)
set(LLAMA_METAL OFF CACHE BOOL "" FORCE)     # Apple Metal
```

**Usage:**
```cpp
#include "llama.h"

llama_backend_init();
llama_model_params model_params = llama_model_default_params();
llama_model* model = llama_load_model_from_file("model.gguf", model_params);

llama_context_params ctx_params = llama_context_default_params();
ctx_params.n_ctx = 2048;
llama_context* ctx = llama_new_context_with_model(model, ctx_params);

// Tokenize, sample, generate...
```

---

### 2.2 whisper.cpp

> **Purpose:** Automatic Speech Recognition (OpenAI Whisper in C++).

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/ggerganov/whisper.cpp.git` |
| **Current Tag** | `v1.6.0+` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch recommended |
| **CUDA** | Optional |
| **Complexity** | 🟡 Medium |

```json
"whisper_cpp": {
    "git": "https://github.com/ggerganov/whisper.cpp.git",
    "tag": "v1.6.0"
}
```

**PreFetch Hook (whisper_cpp.cmake):**
```cmake
set(WHISPER_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(WHISPER_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(WHISPER_CUDA OFF CACHE BOOL "" FORCE)
```

**Usage:**
```cpp
#include "whisper.h"

whisper_context_params cparams = whisper_context_default_params();
whisper_context* ctx = whisper_init_from_file_with_params("model.bin", cparams);

whisper_full_params wparams = whisper_full_default_params(WHISPER_SAMPLING_GREEDY);
wparams.language = "de";

whisper_full(ctx, wparams, pcm_data, n_samples);

int n_segments = whisper_full_n_segments(ctx);
for (int i = 0; i < n_segments; ++i) {
    const char* text = whisper_full_get_segment_text(ctx, i);
    printf("%s\n", text);
}
```

---

### 2.3 ggml

> **Purpose:** Tensor library for machine learning (basis for llama.cpp, whisper.cpp).

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/ggerganov/ggml.git` |
| **Current Tag** | Current releases |
| **CMake Support** | ✅ |
| **Hook** | PreFetch recommended |
| **Complexity** | 🟡 Medium |

```json
"ggml": {
    "git": "https://github.com/ggerganov/ggml.git",
    "tag": "master"
}
```

---

## 3. ML Frameworks

### 3.1 onnxruntime

> **Purpose:** ONNX model inference from Microsoft.

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/microsoft/onnxruntime.git` |
| **Current Tag** | `v1.17.0` |
| **CMake Support** | ⚠️ Complex |
| **Hook** | PreFetch required |
| **Complexity** | 🔴 High |

```json
"onnxruntime": {
    "git": "https://github.com/microsoft/onnxruntime.git",
    "tag": "v1.17.0"
}
```

**PreFetch Hook (onnxruntime.cmake):**
```cmake
set(onnxruntime_BUILD_UNIT_TESTS OFF CACHE BOOL "" FORCE)
set(onnxruntime_BUILD_SHARED_LIB ON CACHE BOOL "" FORCE)
set(onnxruntime_ENABLE_PYTHON OFF CACHE BOOL "" FORCE)
```

> ⚠️ **Note:** Very complex build. Recommendation: use pre-built binaries from the [Release Page](https://github.com/microsoft/onnxruntime/releases).

---

### 3.2 ncnn

> **Purpose:** High-performance neural network inference (mobile-optimized, by Tencent).

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/Tencent/ncnn.git` |
| **Current Tag** | `20240102` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch recommended |
| **Vulkan** | Optional (GPU acceleration) |
| **Complexity** | 🟡 Medium |

```json
"ncnn": {
    "git": "https://github.com/Tencent/ncnn.git",
    "tag": "20240102"
}
```

**PreFetch Hook (ncnn.cmake):**
```cmake
set(NCNN_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(NCNN_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(NCNN_BUILD_TOOLS OFF CACHE BOOL "" FORCE)
set(NCNN_BUILD_BENCHMARK OFF CACHE BOOL "" FORCE)
# Vulkan GPU Acceleration
set(NCNN_VULKAN OFF CACHE BOOL "" FORCE)
```

---

## 4. CUDA / GPU Computing

### 4.1 thrust

> **Purpose:** CUDA-based parallel algorithms (STL-like API).

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/NVIDIA/thrust.git` |
| **Current Tag** | `2.2.0` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch recommended |
| **Header-only** | ✅ |
| **Prerequisite** | CUDA Toolkit |

```json
"thrust": {
    "git": "https://github.com/NVIDIA/thrust.git",
    "tag": "2.2.0"
}
```

**PreFetch Hook (thrust.cmake):**
```cmake
set(THRUST_ENABLE_TESTING OFF CACHE BOOL "" FORCE)
set(THRUST_ENABLE_EXAMPLES OFF CACHE BOOL "" FORCE)
```

**Usage:**
```cpp
#include <thrust/device_vector.h>
#include <thrust/sort.h>

thrust::device_vector<int> d_vec(1000000);
// Fill vector...
thrust::sort(d_vec.begin(), d_vec.end());
```

---

### 4.2 cub

> **Purpose:** CUDA Unbound - primitives for CUDA kernel development.

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/NVIDIA/cub.git` |
| **Current Tag** | `2.2.0` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch recommended |
| **Header-only** | ✅ |

```json
"cub": {
    "git": "https://github.com/NVIDIA/cub.git",
    "tag": "2.2.0"
}
```

---

### 4.3 cutlass

> **Purpose:** CUDA Templates for Linear Algebra Subroutines (matrix operations).

| Aspect | Value |
|--------|-------|
| **Repository** | `https://github.com/NVIDIA/cutlass.git` |
| **Current Tag** | `v3.4.1` |
| **CMake Support** | ✅ |
| **Hook** | PreFetch recommended |
| **Prerequisite** | CUDA Toolkit |
| **Complexity** | 🔴 High |

```json
"cutlass": {
    "git": "https://github.com/NVIDIA/cutlass.git",
    "tag": "v3.4.1"
}
```

**PreFetch Hook (cutlass.cmake):**
```cmake
set(CUTLASS_ENABLE_TESTS OFF CACHE BOOL "" FORCE)
set(CUTLASS_ENABLE_EXAMPLES OFF CACHE BOOL "" FORCE)
set(CUTLASS_ENABLE_TOOLS OFF CACHE BOOL "" FORCE)
```

---

## 5. Notes

### 5.1 CUDA Toolkit (System)

CUDA must be present as a system installation:

```cmake
find_package(CUDAToolkit REQUIRED)
target_link_libraries(MyApp PRIVATE CUDA::cudart CUDA::cublas)
```

### 5.2 Build Complexity

| Library | Build Time | Dependencies |
|---------|------------|--------------|
| llama.cpp | Medium | Optional: CUDA, Vulkan, Metal |
| whisper.cpp | Medium | Optional: CUDA |
| onnxruntime | Very long | Many (pre-built recommended) |
| ncnn | Medium | Optional: Vulkan |
| thrust/cub | Fast | CUDA Toolkit |
| cutlass | Long | CUDA Toolkit |

### 5.3 Recommended Approach

For onnxruntime and complex CUDA projects:
1. Download pre-built binaries
2. Integrate them as a Local External
3. Write a custom Include.cmake

---

## 6. Quick Reference

| Library | Tag | CMake | Hook | Main Use |
|---------|-----|-------|------|----------|
| llama.cpp | b2500 | ✅ | PreFetch | LLM inference |
| whisper.cpp | v1.6.0 | ✅ | PreFetch | Speech recognition |
| ggml | master | ✅ | PreFetch | Tensor operations |
| onnxruntime | v1.17.0 | ⚠️ | PreFetch | ONNX inference |
| ncnn | 20240102 | ✅ | PreFetch | Mobile ML inference |
| thrust | 2.2.0 | ✅ | PreFetch | CUDA parallel algorithms |
| cub | 2.2.0 | ✅ | PreFetch | CUDA primitives |
| cutlass | v3.4.1 | ✅ | PreFetch | CUDA linear algebra |

---

## 7. See Also

- [Git_Externals_Reference.md](Git_Externals.md) — Main overview
- [Git_Externals_Core.md](Git_Externals_Core.md) — Testing & Benchmarking
- [Git_Externals_Network.md](Git_Externals_Network.md) — Threading

---

## 8. Changelog

| Version | Date | Changes |
|---------|------|---------|
| **1.0.0** | **2025-12-26** | **Release 1 (carried over from newCMake, `2e00db7`)** |
| 0.5.0 | 2025-12-14 | Initial: extracted from Git_Externals_Reference |
