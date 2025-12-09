# C++ Coding Standard – Stil-Richtlinien

> **Version:** 0.1.0  
> **Datum:** 2025-12-05  
> **Typ:** Standard  
> **Status:** In Entwicklung (Pre-Release)  
> **Geltungsbereich:** Alle C++-Projekte (PC-Applikationen)  
> **Bezug:** CMake_Standard v0.1, ClangFormat_Blueprint v0.1, ClangTidy_Blueprint v0.1  
> **Sprache:** Deutsch  

---

## 1. Zweck und Geltungsbereich

Dieser Standard definiert **Coding-Konventionen für C++** im Unternehmen.

### Anwendungsbereich

| Sprache | Fokus | Typische Projekte |
|---------|-------|-------------------|
| **C++** | PC-Applikationen | Tools, GUIs, Services, Test-Programme, Libraries |
| C | Embedded | Firmware, MCUs, sicherheitskritische Teile |

Dieser Standard wird ergänzt durch:
- **C_Coding_Standard** – Embedded-spezifisch
- **CMake_Standard** – Build-System
- **ClangFormat_Blueprint** – Formatierung
- **ClangTidy_Blueprint** – Statische Analyse

### Tool-Autorität

> Bei Konflikten zwischen Dokumentation und Tool-Konfiguration gelten `.clang-format` und `.clang-tidy` als **verbindliche Umsetzung**.

---

## 2. Grundprinzipien

1. **Lesbarkeit über Cleverness**
2. **Sicherheit und Korrektheit über vorzeitige Optimierung**
3. **Konsistenz über persönliche Präferenz**
4. **Automatisierte Tools über manuelle Stil-Diskussionen**

---

## 3. Sprachversion und Features

### 3.1 Standard-Version

| Projekt-Typ | C++ Standard |
|-------------|--------------|
| Neue Projekte | **C++20** (Default) |
| Legacy-Projekte | Dokumentiert im README |

### 3.2 Empfohlene Features

| Feature | Verwendung |
|---------|------------|
| `enum class` | Stark typisierte Enums |
| RAII | Alle Ressourcen |
| Lambdas | Wo Lokalität und Klarheit verbessert werden |
| `constexpr` / `consteval` | Compile-Zeit-Berechnungen |
| Standard-Container | `std::vector`, `std::map`, etc. |
| Smart Pointers | `std::unique_ptr`, `std::shared_ptr` |

### 3.3 Zu vermeiden

| Feature | Grund | Alternative |
|---------|-------|-------------|
| `new` / `delete` | Manuelles Memory-Management | Smart Pointers, Container |
| Raw owning Pointers | Ownership unklar | `std::unique_ptr` |
| Präprozessor-Makros | Fehleranfällig | `constexpr`, Templates |

### 3.4 Verboten (außer dokumentiert)

| Feature | Grund |
|---------|-------|
| `reinterpret_cast` für Type-Punning | Undefined Behavior |
| Abhängigkeit von UB | Nicht portabel |

---

## 4. Formatierung

### 4.1 Autorität

- Alle Formatierung via `clang-format`
- Manuelle Abweichungen nicht erlaubt
- Bei Problemen: `.clang-format` anpassen, nicht umgehen

### 4.2 Übersicht (Details in `.clang-format`)

| Aspekt | Regel |
|--------|-------|
| Basis-Stil | LLVM mit Anpassungen |
| Einrückung | 4 Spaces |
| Tabs | Nie verwenden |
| Klammern | Allman-Stil (neue Zeile) |
| Include-Reihenfolge | PCH → System → Projekt |
| Arrays | Ein Element pro Zeile |

---

## 5. Namenskonventionen

### 5.1 Autorität

- Namensregeln via `clang-tidy` (`readability-identifier-naming`)
- Verstöße beheben, nicht unterdrücken

### 5.2 Übersicht

| Entität | Konvention | Beispiel |
|---------|------------|----------|
| Namespace | `lower_case` | `audio`, `core_utils` |
| Klasse/Struct/Enum | `CamelCase` | `LogManager`, `AudioBuffer` |
| Enum-Konstante | `CamelCase` | `LogLevelInfo` |
| Funktion/Methode | `camelBack` | `writeLog()`, `processData()` |
| Parameter | `camelBack` | `filePath`, `bufferSize` |
| Lokale Variable | `camelBack` | `currentIndex`, `tempValue` |
| Member-Variable | `m_` Prefix | `m_buffer`, `m_logger` |
| Globale Konstante | `UPPER_CASE` | `MAX_BUFFER_SIZE` |
| Globale Variable | `g_` Prefix | `g_logger` |
| Statische Variable | `s_` Prefix | `s_cache` |

---

## 6. Typen, Ownership und Lifetime

### 6.1 Fundamentale Typen

| Anforderung | Typ |
|-------------|-----|
| Größe wichtig | `std::int32_t`, `std::uint64_t` |
| Größen/Indizes | `std::size_t` |

### 6.2 Ownership-Modell

| Ownership | Mechanismus |
|-----------|-------------|
| Exklusiv | `std::unique_ptr` |
| Geteilt | `std::shared_ptr` (nur wenn nötig) |
| Nicht-besitzend | Raw Pointer oder Reference |

### 6.3 RAII

Alle Ressourcen werden durch RAII verwaltet:
- Dateien, Sockets, Handles
- Speicher
- Locks

```cpp
// ✅ RAII
{
    std::unique_ptr<Resource> res = createResource();
    // Automatische Freigabe am Scope-Ende
}

// ❌ Manuell
Resource* res = createResource();
// ... vergessen zu löschen = Leak
delete res;
```

---

## 7. Fehlerbehandlung

### 7.1 Exceptions (C++ PC)

Exceptions sind **erlaubt und erwartet**:

| Regel | Beschreibung |
|-------|--------------|
| Werfen | By Value |
| Fangen | By (const) Reference |
| Verwendung | Echte Ausnahmesituationen |
| Nicht verwenden für | Normalen Kontrollfluss |

### 7.2 Alternative Fehlerbehandlung

Für Low-Level-Code (I/O, OS-Interfaces):

| Mechanismus | Verwendung |
|-------------|------------|
| `std::error_code` | Erwartete Fehler |
| `std::optional<T>` | Optionale Rückgabe |
| `std::expected` (C++23) | Fehler oder Wert |

### 7.3 Logging

- Zentrales Logging-System verwenden (z.B. `LogManager`)
- Keine `std::cout` / `printf` in Produktionscode
- Exceptions an Grenzen loggen oder propagieren

---

## 8. Concurrency

### 8.1 Empfohlene Mechanismen

| Mechanismus | Verwendung |
|-------------|------------|
| `std::thread` / `std::jthread` | Thread-Erzeugung |
| `std::mutex` / `std::shared_mutex` | Synchronisation |
| `std::lock_guard` / `std::unique_lock` | RAII-Locking |
| `std::atomic<T>` | Atomare Operationen |

### 8.2 Richtlinien

- **Keine Data Races** – Shared Data immer schützen
- **Kurze kritische Sektionen** – Locks minimal halten
- **Thread-Safe Design bevorzugen** – Immutable Data, Message Passing

---

## 9. Statische Analyse

### 9.1 Default-Profil: Dev-Gentle

Aktivierte Check-Kategorien:
- `clang-analyzer-*` – Kritische Bugs
- `bugprone-*` – Logik-Fehler
- `performance-*` – Ineffizienzen
- `readability-*` – Lesbarkeit
- `modernize-*` – C++-Modernisierung

### 9.2 Umgang mit Warnungen

| Warnung | Anforderung |
|---------|-------------|
| `clang-analyzer-*`, `bugprone-*` | **Beheben** oder dokumentiert unterdrücken |
| Stil-Warnungen | Zeitnah beheben, nicht ignorieren |

### 9.3 Profile

| Profil | Kontext |
|--------|---------|
| Dev-Gentle | Tägliche Entwicklung |
| CI-Strict | Pull Requests |
| API-Gate | Öffentliche APIs |

---

## 10. Test-Code

- Test-Code folgt **demselben Standard**
- Test-spezifische Abkürzungen bleiben in Tests
- Verwendete Frameworks (GoogleTest, Catch2) respektieren Naming-Regeln

---

## 11. Verhältnis zu C (Embedded)

| Aspekt | C++ (PC) | C (Embedded) |
|--------|----------|--------------|
| Exceptions | Ja | Nein |
| Dynamic Allocation | Erlaubt | Vermeiden |
| Standard Library | Voll | Eingeschränkt |
| MISRA/CERT | Alignment | Strikte Einhaltung |

### Shared Components

Libraries für PC und Embedded müssen dokumentieren:
- Verwendete C++-Subset
- Embedded-Einschränkungen

---

## 12. Legacy-Code und Ausnahmen

### 12.1 Legacy-Code

- Bleibt temporär, wenn nicht compliant
- Neuer Code **immer** nach Standard
- Refactoring-Chancen nutzen

### 12.2 Intentionale Abweichungen

- Kommentar im Code
- Begründung dokumentieren
- Scope minimieren

---

## 13. MISRA/CERT-Alignment

Dieser Standard orientiert sich an:

| Richtlinie | Relevanz |
|------------|----------|
| MISRA C++ | Sicherheitskritischer Code |
| SEI CERT C++ | Defensive Programmierung |

### Umgesetzte Prinzipien

- Keine gefährlichen Casts
- Keine implizite Truncation
- Rückgabewerte prüfen
- Variablen initialisieren

---

## 14. Siehe auch

- [C_Coding_Standard](C_Coding_Standard_v0_1_0.md) – Embedded C
- [CMake_Standard](CMake_Standard_v0_1_0.md) – Build-System
- [ClangFormat_Blueprint](ClangFormat_Blueprint_v0_1_0.md) – Formatierung
- [ClangTidy_Blueprint](ClangTidy_Blueprint_v0_1_0.md) – Statische Analyse

---

## Changelog

| Version | Datum | Änderungen |
|---------|-------|------------|
| **0.1.0** | **2025-12-05** | **Initial: Namenskonventionen, Ownership, Exceptions, MISRA-Alignment** |
