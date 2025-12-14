# Dokumentation & Struktur - Zusammenfassung

**Datum:** 2025-12-12  
**Kontext:** Vorbereitung für v0.5.0 → v1.0.0  
**Status:** Referenz für nächsten Chat

---

## 1. Dokumentationsstruktur

```
docs/
├── de/                             # Deutsche Dokumentation
│   ├── blueprints/                 # Meta-Standards für alle Dokumenttypen
│   ├── reference/                  # API/Schema Referenz
│   ├── modules/                    # CMake Modul-Beschreibungen
│   ├── guides/                     # User Guides / How-To
│   ├── standards/                  # Coding/Project Standards
│   ├── concepts/                   # Architektur-Konzepte
│   ├── tutorials/                  # Step-by-Step Tutorials
│   ├── templates/                  # Vorlagen
│   └── reports/                    # Berichte
│
└── en/                             # Englische Dokumentation (gleiche Struktur)
```

---

## 2. Versionierung (Hybrid-Ansatz)

| Zustand | Dateiname | Version |
|---------|-----------|---------|
| **Aktuell** | `AppContainer.md` | Im Header (z.B. v0.5.0) |
| **Archiviert** | `archive/AppContainer_v0.4.0.md` | Im Namen + Header |
| **Work-in-Progress** | `AppContainer_DRAFT.md` | Optional für größere Überarbeitungen |

**Vorteile:**
- Links zeigen immer auf `Dateiname.md` → nie kaputt
- Alte Versionen bleiben im `archive/` Ordner erhalten
- Klare Trennung zwischen aktuell und historisch

---

## 3. Blueprints (Meta-Standards)

Jeder Dokumenttyp bekommt einen Blueprint:

| Blueprint | Definiert Standard für |
|-----------|------------------------|
| `Blueprint.md` | Wie man Blueprints schreibt (Meta) |
| `Doc.md` | Allgemeine Dokumentation |
| `Readme.md` | README-Dateien |
| `ModuleDoc.md` | CMake-Modul-Dokumentation |
| `Guide.md` | User Guides |
| `Reference.md` | API/Schema Referenz |
| `Tutorial.md` | Tutorials |
| `Template.md` | Vorlagen |
| `Concept.md` | Architektur-Konzepte |
| `Report.md` | Berichte |
| `Standard.md` | Coding/Project Standards |
| `CMake.md` | CMake-Scripts |
| `Cpp.md` | C++-Code |

---

## 4. Module-Dokumentation

```
docs/de/modules/
├── CMakeLists.md                   # Top-Level CMakeLists.txt
├── core/
│   ├── Errors.md
│   ├── Debug.md
│   ├── Context.md
│   └── ...
├── project/
│   ├── Solution.md
│   ├── Executables.md
│   ├── Libraries.md
│   ├── Tests.md
│   └── Apps.md                     # App-Container (Phase 8)
└── externals/
    ├── Orchestrator.md
    ├── Fetch.md
    ├── Targets.md
    ├── hooks/                      # PreFetch/PostFetch Hooks
    │   ├── glfw.md
    │   ├── imgui.md
    │   ├── googletest.md
    │   └── catch2.md
    └── local/                      # Lokale Externals (Include.cmake)
        ├── bass.md
        ├── glad.md
        ├── doctest.md
        └── lua.md
```

---

## 5. Examples (In Solution integriert)

```
examples/
├── MinimalConsole/
│   └── src/main.cpp
├── GuiWithImGui/
│   └── src/main.cpp
└── AppContainerDemo/
    ├── include/AppContainerDemo/
    ├── src/AppContainerDemo/
    ├── main/
    ├── pch/
    └── tests/
        ├── unit/
        └── integration/
```

**Solution.json Integration:**
```json
{
    "executables": [
        {
            "name": "MinimalConsole",
            "path": "examples/MinimalConsole/src",
            "active": false
        }
    ],
    "apps": [
        {
            "name": "AppContainerDemo",
            "path": "examples/AppContainerDemo",
            "active": false
        }
    ]
}
```

- Kein separates `Solution.json` oder `CMakeLists.txt` in examples
- `active: false` als Default → manuell aktivierbar
- Custom `path` zeigt auf `examples/` statt `projects/`

---

## 6. Spezielle Dokumente

| Dokument | Ort | Bemerkung |
|----------|-----|-----------|
| `Future_Enhancements.md` | `concepts/` | Nach Umsetzung → `reports/Past_Enhancements.md` |
| `Development_Journal.md` | `reports/` | Entwicklungstagebuch |
| `Glossar.md` | `reference/` | Begriffsdefinitionen |
| `ErrorCodes.md` | `reference/` | Alle Error/Warning Codes |

---

## 7. App-Container Struktur (Phase 8)

```
projects/apps/{AppName}/
├── include/{AppName}/          # PUBLIC Headers (symmetrisch zu src/)
├── src/{AppName}/              # Implementation
├── main/                       # Entry Point (Runner)
├── pch/                        # Precompiled Header (optional)
└── tests/
    ├── unit/
    └── integration/
```

**Generierte Targets:**
- `{AppName}.Core` - STATIC Library
- `{AppName}` - Executable
- `{AppName}.UnitTests` - Test Executable
- `{AppName}.IntegrationTests` - Test Executable

---

## 8. Nächste Schritte

1. **Projektablage aktualisieren** - Alle Dokumente auf aktuellen Stand bringen
2. **v0.5.0 vereinheitlichen** - Alle Versionen angleichen
3. **Blueprints erstellen** - Mit `Blueprint.md` (Meta) beginnen
4. **Struktur umsetzen** - `de/`, `en/`, `archive/` Ordner anlegen
5. **v1.0.0 vorbereiten** - Finale Dokumentation

---

## 9. Offene Punkte für v1.0.0

- [ ] Alle Blueprints erstellen
- [ ] Module-Dokumentation vervollständigen
- [ ] App-Container implementieren (Phase 8)
- [ ] Examples erstellen
- [ ] Englische Übersetzung (optional für v1.0.0?)
