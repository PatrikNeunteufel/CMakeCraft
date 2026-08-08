# Fremdkomponenten und ihre Lizenzen

CMakeCraft selbst — die CMake-Module unter `cmake/`, der Entry-Point
`CMakeCraft.cmake`, die Vorlagen unter `templates/` und die Dokumentation unter
`docs/` — steht wahlweise unter **MIT** oder **Apache-2.0**
(siehe [LICENSE](LICENSE)).

Diese Datei listet alles auf, was **nicht** dazugehört. Sie ist in drei Teile
gegliedert:

1. **Mitgelieferter Fremdcode** — liegt im Repository und wird mit ihm
   weitergegeben. Wer CMakeCraft weitergibt, muss die hier genannten
   Copyright-Vermerke mitliefern.
2. **Zur Build-Zeit geholte Abhängigkeiten** — nicht im Repository; CMake holt
   sie beim Konfigurieren per `git clone` nach `.externals/`.
3. **Vorlagen-Einträge** — in `templates/Solution.json` vorbereitet, aber
   standardmäßig abgeschaltet.

Am Ende steht, was bewusst **nicht** enthalten ist.

---

## 1. Mitgelieferter Fremdcode

Diese Dateien gehören zur mitgelieferten **Demo-Solution**. Sie zeigen, wie ein
Local External aussieht — für den Betrieb des Build-Systems in einem eigenen
Projekt werden sie nicht gebraucht.

### doctest 2.4 — `externals/doctest/doctest.h`

Test-Framework, Single-Header. Wird von den Demo-Test-Targets genutzt.

- **Lizenz:** MIT
- **Copyright:** © 2016–2023 Viktor Kirilov
- **Herkunft:** <https://github.com/doctest/doctest>

Der vollständige Lizenztext steht im Kopf der Datei selbst.

### glad 0.1.36 — `externals/glad/`

OpenGL-Loader, mit dem Web-Generator <https://glad.dav1d.de/> erzeugt
(`gl=3.3`, Compatibility-Profil).

- **Generator glad:** MIT, © David Herberth — <https://github.com/Dav1dde/glad>
- **Erzeugter Loader-Code** (`include/glad/glad.h`, `src/glad.c`): vom Generator
  als gemeinfrei freigegeben; die zugrunde liegenden OpenGL-Spezifikationen
  stehen unter den Bedingungen der Khronos Group.

### KHR/khrplatform.h — `externals/glad/include/KHR/khrplatform.h`

Plattform-Header der Khronos Group, wird vom glad-Loader eingebunden.

- **Lizenz:** MIT-artig (Khronos-Lizenztext im Dateikopf)
- **Copyright:** © 2008–2018 The Khronos Group Inc.

### Lua 5.4 — `externals/lua54/win/include/`

Nur die öffentlichen Header (`lua.h`, `lualib.h`, `lauxlib.h`, `luaconf.h`,
`lua.hpp`). Die kompilierten Bibliotheken sind **nicht** im Repository — wer den
Local External `lua54` nutzen will, baut oder beschafft sie selbst.

- **Lizenz:** MIT
- **Copyright:** © 1994–2020 Lua.org, PUC-Rio
- **Herkunft:** <https://www.lua.org/>

---

## 2. Zur Build-Zeit geholte Abhängigkeiten

Diese Komponenten liegen **nicht** im Repository. Die mitgelieferte
`Solution.json` deklariert sie; CMake klont sie beim Konfigurieren in den
Ordner `.externals/` (gitignoriert). Beim ersten Konfigurieren braucht es dafür
eine Netzverbindung.

| Komponente | Version | Lizenz | Herkunft |
|---|---|---|---|
| **GLFW** | 3.4 | Zlib/libpng | <https://github.com/glfw/glfw> |
| **Dear ImGui** | v1.91.6 und v1.91.6-docking | MIT, © Omar Cornut | <https://github.com/ocornut/imgui> |
| **GoogleTest** | v1.14.0 | BSD-3-Clause, © Google Inc. | <https://github.com/google/googletest> |
| **Catch2** | v3.5.2 | Boost Software License 1.0 | <https://github.com/catchorg/Catch2> |

Für die Demo-Solution werden `glfw` und `imgui` nur gebraucht, wenn das
Demo-Executable `imGuiApp` eingeschaltet wird (steht auf `skip: true`).

### Qt 6 — System-External

Qt wird **nicht** geholt, sondern in einer vorhandenen Installation gesucht
(`cmake/externals/system/packages/Qt6.cmake`). Das Demo-Executable
`QtMarkdownViewer` nutzt `Core` und `Widgets`.

- **Lizenz:** LGPLv3 oder kommerzielle Lizenz von The Qt Company
- **Herkunft:** <https://www.qt.io/>

Wer Qt dynamisch dazulinkt und sein Programm weitergibt, muss die
LGPL-Bedingungen einhalten (Austauschbarkeit der Qt-Bibliotheken,
Quelltext-Angebot für Qt selbst). Das betrifft das jeweilige Projekt, nicht
CMakeCraft.

---

## 3. Vorlagen-Einträge (standardmäßig abgeschaltet)

`templates/Solution.json` ist die Kopiervorlage für neue Projekte. Sie enthält
vorbereitete External-Definitionen, die alle auf `"skip": true` stehen und
deshalb **nichts holen**, solange sie nicht eingeschaltet werden.

| Eintrag | Version | Lizenz | Herkunft |
|---|---|---|---|
| **Qt Advanced Docking System** | 4.3.1 | LGPL-2.1, © Uwe Kindler | <https://github.com/githubuser0xFFFF/Qt-Advanced-Docking-System> |
| **GLM** | 1.0.1 | MIT (Happy Bunny / MIT) | <https://github.com/g-truc/glm> |
| **sol2** | v3.3.1 | MIT | <https://github.com/ThePhD/sol2> |
| **stb** | `master` | MIT oder Public Domain (wahlweise) | <https://github.com/nothings/stb> |
| **ONNX Runtime** | System-Paket | MIT, © Microsoft | <https://github.com/microsoft/onnxruntime> |
| **projectm-eval** | v1.0.0 | *nicht geprüft* — vor dem Einschalten beim Upstream klären | <https://github.com/projectM-visualizer/projectm-eval> |

Wer einen dieser Einträge einschaltet, holt fremden Code in sein Projekt und ist
für dessen Lizenzbedingungen selbst verantwortlich. Die Angaben oben sind eine
Orientierung, kein Ersatz für einen Blick in das jeweilige Repository — Lizenzen
ändern sich zwischen Versionen.

Die PostFetch-Hooks unter `cmake/externals/hooks/postfetch/` (`imgui.cmake`,
`stb.cmake`, `qt-ads.cmake`) enthalten **keinen** fremden Code. Sie bauen nur
CMake-Targets um fremde Quellbäume herum, die kein eigenes CMake mitbringen.

---

## Nicht enthaltene Inhalte

### BASS — proprietär, muss selbst beschafft werden

Die Audio-Bibliothek **BASS** und ihre Add-ons gehören **un4seen developments
Ltd.**. Ihre Lizenz schließt Weiterverbreitung und Unterlizenzierung aus — und
zwar für das **gesamte SDK**: Binärdateien ebenso wie Header, Beispiele und die
CHM-Dokumentation. BASS kann deshalb nicht Teil dieses Repositorys sein.

Der Ordner `externals/bass/` enthält nur die Anleitung
[`SETUP.md`](externals/bass/SETUP.md).

CMakeCraft **braucht BASS nicht**. Betroffen sind ausschließlich zwei
Demo-Executables der mitgelieferten Solution (`MinimalConsole`,
`consolePlayer`) sowie ein abgeschalteter Integrationstest. Sie dienen als
Vorführung, wie ein Local External mit Plugin-Optionen angebunden wird. Alles
andere — die Phasentests des Selbsttests eingeschlossen — konfiguriert und baut
ohne BASS.

BASS ist für nicht-kommerzielle Nutzung kostenlos; kommerzielle Nutzung
erfordert eine Lizenz von un4seen. Bedingungen: <https://www.un4seen.com/>.

### Kompilierte Bibliotheken

Im Repository liegen **keine** vorkompilierten Bibliotheken (`.lib`, `.dll`,
`.so`, `.dylib`, `.a`). Das ist Absicht: Binärdateien ohne nachvollziehbaren
Bau-Ursprung gehören nicht in ein Quell-Repository — unabhängig davon, ob ihre
Lizenz die Weitergabe erlauben würde.

---

## Änderungen an dieser Datei

Wer Fremdcode hinzufügt, ergänzt hier einen Eintrag mit Lizenz und
Copyright-Vermerk und schreibt die Herkunft in den Dateikopf. Siehe
[`.github/CONTRIBUTING.md`](.github/CONTRIBUTING.md).
