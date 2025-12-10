# Solution.json Änderung für ImGui Docking

## Aktuelle Konfiguration (tag)

```json
"imgui": {
    "git": "https://github.com/ocornut/imgui.git",
    "tag": "v1.91.6",
    "cmakeSupport": false
}
```

## Neue Konfiguration (docking branch)

```json
"imgui": {
    "git": "https://github.com/ocornut/imgui.git",
    "branch": "docking",
    "cmakeSupport": false
}
```

## Hinweis

- `tag` → Stabiler Release, aber OHNE Docking
- `branch: "docking"` → Mit Docking + Viewports

Der Docking-Branch wird regelmäßig mit dem master synchronisiert und ist stabil genug für Produktion.

## Komplette externals-Sektion

```json
"externals": {
    "bass": {
        "path": "externals/bass"
    },
    "lua54": {
        "path": "externals/lua54"
    },
    "doctest": {
        "path": "externals/doctest"
    },
    "glad": {
        "path": "externals/glad"
    },
    "glfw": {
        "git": "https://github.com/glfw/glfw.git",
        "tag": "3.4"
    },
    "imgui": {
        "git": "https://github.com/ocornut/imgui.git",
        "branch": "docking",
        "cmakeSupport": false
    }
}
```
