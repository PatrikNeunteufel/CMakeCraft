# CppModuleDoc — Standard for C++ Module Documentation

> **Version:** 1.0.1  
> **Date:** 2026-11-09  
> **Type:** Blueprint  
> **Status:** In Development  
> **Based on:** Doc v0.5, Blueprint v0.5  
> **Target Audience:** Developers  
> **Language:** English  
> **German:** [CppModuleDoc.md](../../../de/autorenwerk/blueprints/CppModuleDoc.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Scope](#2-scope)
3. [Header Extensions](#3-header-extensions)
4. [Mandatory Sections](#4-mandatory-sections)
5. [API Documentation Format](#5-api-documentation-format)
6. [Interface vs. Implementation](#6-interface-vs-implementation)
7. [Example: Complete Module Documentation](#7-example-complete-module-documentation)
8. [Review Checklist](#8-review-checklist)
9. [See Also](#9-see-also)
10. [Changelog](#10-changelog)

---

## 1. Overview

This blueprint defines the **structure for C++ module documentation**. A module documentation describes a C++ class or a module (related .hpp/.cpp/.tpp/.inl files).

### 1.1 Target Audience

- Developers who want to use the module
- Developers who maintain or extend the module

### 1.2 Delimitation

| Documentation type | Question | Example |
|-------------------|---------------|----------|
| **CppModuleDoc** | "What does this class do and how do I use it?" | ShaderManager.md |
| **Concept** | "What is the overall architecture?" | MyVisualizer concept |
| **Reference** | "Which error codes exist?" | ErrorCodes.md |

### 1.3 Documentation Granularity

| Module type | Documentation |
|-----------|---------------|
| **Interface** (e.g. IShader) | Own file, focused on the contract |
| **Implementation** (e.g. OpenGLShader) | Own file, focused on concrete logic |
| **Belonging together** (e.g. ShaderManager) | One file for .hpp + .cpp |
| **Header-only** | One file for .hpp |

---

## 2. Scope

This blueprint applies to documentation of:

- C++ classes (.hpp/.cpp)
- C++ templates (.hpp/.tpp)
- Header-only libraries
- Interfaces (pure virtual classes)

**File naming convention:**

```
docs/[lang]/guide/module/[Namespace]/[ClassName].md
```

**Examples:**

- `docs/de/guide/module/gpu/ShaderManager.md`
- `docs/de/guide/module/gpu/IShader.md`
- `docs/de/guide/module/visuals/NullVisualizer.md`

---

## 3. Header Extensions

### 3.1 Mandatory Fields

| Field | Description |
|------|--------------|
| `Module:` | Fully qualified class name |
| `Files:` | List of the related files |
| `Namespace:` | C++ namespace |
| `Dependencies:` | External and internal dependencies |

### 3.2 Complete Header

```markdown
# [ClassName] — [Short description]

> **Version:** X.Y.Z  
> **Date:** YYYY-MM-DD  
> **Type:** CppModuleDoc  
> **Status:** [Stable | In Development | Deprecated]  
> **Module:** [Namespace]::[ClassName]  
> **Files:** [file.hpp], [file.cpp]  
> **Namespace:** [namespace]  
> **Dependencies:** [list]  
> **Target Audience:** Developers  
> **Language:** English  
```

---

## 4. Mandatory Sections

### 4.1 Structure for Implementations

```
## 1. Overview
### 1.1 Purpose
### 1.2 Responsibilities
### 1.3 Non-Responsibilities

## 2. Dependencies

## 3. API
### 3.1 Construction
### 3.2 Public Methods
### 3.3 Signals/Slots (if Qt)

## 4. Usage
### 4.1 Simple Example
### 4.2 Advanced Example (optional)

## 5. Internals (optional)
### 5.1 Implementation Details
### 5.2 Pimpl (if used)

## 6. Thread Safety

## 7. Error Handling

## Changelog
```

### 4.2 Structure for Interfaces

```
## 1. Overview
### 1.1 Purpose
### 1.2 Contract

## 2. Dependencies

## 3. Interface Definition
### 3.1 Pure Virtual Methods
### 3.2 Virtual Methods with Default
### 3.3 Non-Virtual Methods

## 4. Implementation Requirements

## 5. Known Implementations

## Changelog
```

### 4.3 Section Details

| # | Section | Content | Mandatory |
|---|-----------|--------|---------|
| 1 | Overview | Purpose, responsibilities | ✅ |
| 2 | Dependencies | External/internal dependencies | ✅ |
| 3 | API | Method documentation | ✅ |
| 4 | Usage | Code examples | ✅ |
| 5 | Internals | Implementation details | Optional |
| 6 | Thread safety | Concurrency guarantees | ✅ |
| 7 | Error handling | Exceptions, error codes | ✅ |

---

## 5. API Documentation Format

### 5.1 Method Table

```markdown
### 3.2 Public Methods

| Method | Parameters | Returns | Description |
|---------|-----------|----------|--------------|
| `load(path)` | `const std::string&` | `bool` | Loads resource, `true` on success |
| `get(name)` | `const std::string&` | `T*` | Returns cached resource or `nullptr` |
```

### 5.2 Detailed Method Documentation

For complex methods, additionally:

````markdown
#### `bool load(const std::string& path)`

Loads a resource from the given path.

**Parameters:**
- `path` — relative or absolute file path

**Returns:**
- `true` — resource loaded successfully
- `false` — error (see `getErrorLog()`)

**Exceptions:**
- None (errors via return value)

**Example:**
```cpp
if (!manager.load("shaders/basic.vert"))
{
    std::cerr << manager.getErrorLog();
}
```
````

### 5.3 Signals/Slots (Qt)

```markdown
### 3.3 Signals

| Signal | Parameters | Description |
|--------|-----------|--------------|
| `initialized()` | — | Emitted after successful initialization |
| `errorOccurred(msg)` | `QString` | Emitted on errors |

### 3.4 Slots

| Slot | Parameters | Description |
|------|-----------|--------------|
| `setPaused(paused)` | `bool` | Pauses/resumes rendering |
```

---

## 6. Interface vs. Implementation

### 6.1 Interface Documentation

Focus on the **contract** (what must an implementation fulfil?):

```markdown
## 3. Interface Definition

### 3.1 Pure Virtual Methods

| Method | Contract |
|---------|---------|
| `initialize(ctx)` | Must allocate resources, `true` on success |
| `render(ctx)` | Must render the frame, must not block |
| `cleanup()` | Must release all resources |

### Invariants

- After `initialize()` returning `true`: `isInitialized()` returns `true`
- After `cleanup()`: the object can be initialized again
```

### 6.2 Implementation Documentation

Focus on **concrete logic**:

```markdown
## 5. Internals

### 5.1 OpenGL Resources

| Resource | Type | Lifecycle |
|-----------|-----|--------------|
| `m_program` | `GLuint` | `initialize()` → `cleanup()` |
| `m_vao` | `GLuint` | `initialize()` → `cleanup()` |

### 5.2 Render Pipeline

1. `glUseProgram(m_program)`
2. `glBindVertexArray(m_vao)`
3. `glDrawArrays(...)`
```

---

## 7. Example: Complete Module Documentation

````markdown
# ShaderManager — Shader Management and Caching

> **Version:** 1.0.0  
> **Date:** 2025-12-23  
> **Type:** CppModuleDoc  
> **Status:** Stable  
> **Module:** myvis::gpu::ShaderManager  
> **Files:** ShaderManager.hpp, ShaderManager.cpp  
> **Namespace:** myvis::gpu  
> **Dependencies:** OpenGLShader, IShader, glad, glm  
> **Target Audience:** Developers  
> **Language:** English  

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [API](#3-api)
4. [Usage](#4-usage)
5. [Thread Safety](#5-thread-safety)
6. [Error Handling](#6-error-handling)

---

## 1. Overview

### 1.1 Purpose

ShaderManager manages loading, compiling and caching of GLSL shaders.

### 1.2 Responsibilities

- Load shaders from source code or file
- Cache compiled shaders
- Uniform interface for shader access

### 1.3 Non-Responsibilities

- No uniform management (→ IShader)
- No automatic hot reload

---

## 2. Dependencies

| Dependency | Type | Purpose |
|------------|-----|-------|
| OpenGLShader | Internal | Concrete shader implementation |
| IShader | Internal | Interface for polymorphic access |
| glad | External | OpenGL functions |
| glm | External | Mathematics for uniforms |

---

## 3. API

### 3.1 Construction

```cpp
ShaderManager();
~ShaderManager();
```

### 3.2 Public Methods

| Method | Parameters | Returns | Description |
|---------|-----------|----------|--------------|
| `loadFromSource(name, vert, frag)` | `string, string, string` | `IShader*` | Compiles shader from source |
| `loadFromFile(name, vertPath, fragPath)` | `string, string, string` | `IShader*` | Loads and compiles from files |
| `get(name)` | `string` | `IShader*` | Returns cached shader or `nullptr` |
| `remove(name)` | `string` | `void` | Removes shader from cache |
| `clear()` | — | `void` | Removes all shaders |
| `getErrorLog()` | — | `string` | Last error |

---

## 4. Usage

### 4.1 Simple Example

```cpp
ShaderManager shaders;

auto* basic = shaders.loadFromSource(
    "basic",
    R"(#version 330 core
       layout(location=0) in vec3 aPos;
       void main() { gl_Position = vec4(aPos, 1.0); })",
    R"(#version 330 core
       out vec4 FragColor;
       void main() { FragColor = vec4(1.0); })"
);

if (basic)
{
    basic->bind();
    // Render...
    basic->unbind();
}
```

---

## 5. Thread Safety

**Not thread-safe.** All calls must be made from the GL context thread.

---

## 6. Error Handling

- On error: the method returns `nullptr`
- Error details: `getErrorLog()` contains GLSL compiler errors
- No exceptions

---

## Changelog

| Version | Date | Changes |
|---------|-------|------------|
| 1.0.0 | 2025-12-23 | Initial |
````

---

## 8. Review Checklist

**Header:**

- [ ] Module name fully qualified (with namespace)
- [ ] Files listed
- [ ] Dependencies documented

**Content:**

- [ ] Purpose clearly described
- [ ] Responsibilities defined
- [ ] All public methods documented
- [ ] At least one usage example
- [ ] Thread safety documented
- [ ] Error handling documented

**API documentation:**

- [ ] Parameters with types
- [ ] Return values with meaning
- [ ] Exceptions/error cases documented

**Code examples:**

- [ ] Compilable (syntactically correct)
- [ ] Minimalistic (only relevant code)
- [ ] Commented where necessary

---

## 9. See Also

- [Doc.md](Doc.md) — General documentation rules
- [Cpp.md](Cpp.md) — C++ code standards
- [Concept.md](Concept.md) — For architecture documentation

---

## 10. Changelog

| Version | Date | Changes |
|---------|-------|------------|
| **1.0.1** | **2026-11-09** | **Aligned with the code: location `docs/[lang]/guide/module/` instead of `modules/` (§ 2)** |
| 1.0.0 | 2025-12-23 | Header at 1.0.0 since creation (`cb2f6e5`) |
| 0.1.0 | 2025-12-23 | Initial: structure for C++ module documentation |
