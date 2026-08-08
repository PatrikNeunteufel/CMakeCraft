# Konsumenten-Vorlage

Diese drei Dateien sind alles, was ein Projekt braucht, um CMakeCraft zu nutzen.
Kopiere sie in den **Root** deines Projekts:

```bash
cp templates/consumer/CMakeCraftBootstrap.cmake  <dein-projekt>/
cp templates/consumer/cmakecraft.pin             <dein-projekt>/
cp templates/consumer/CMakeLists.txt             <dein-projekt>/
```

| Datei | Anpassen? |
|---|---|
| `CMakeCraftBootstrap.cmake` | **nein** — unveraendert uebernehmen |
| `cmakecraft.pin` | **ja** — Version (Git-Tag) und ggf. Fallback-Pfade |
| `CMakeLists.txt` | nur den Kommentarkopf (Projektname) |

Dazu kommt eine `Solution.json` — die beschreibt, *was* gebaut wird. Vorlage:
[`../Solution.json`](../Solution.json).

Die vollstaendige Anleitung mit allen weiteren Dateien (`CMakePresets.json`,
`.gitignore`, `clang-format`) steht in
[`docs/de/guide/userguides/Neues_Projekt_Guide.md`](../../docs/de/guide/userguides/Neues_Projekt_Guide.md).

## Warum kein Snapshot mehr?

Frueher trug jedes Projekt eine Kopie des `cmake/`-Ordners. Das ging so lange
gut, bis zwei Projekte auseinanderliefen. Jetzt steht in `cmakecraft.pin` nur
noch **welche Version** gelten soll; geholt wird sie beim Konfigurieren nach
`.externals/cmakecraft/<version>/`. Divergenz ist damit technisch ausgeschlossen
statt nur verboten.

Hintergrund: [`docs/de/konzepte/Konzept_Versionierter_Bezug.md`](../../docs/de/konzepte/Konzept_Versionierter_Bezug.md).

## Am Build-System selbst arbeiten

Wenn du CMakeCraft parallel zum Projekt aenderst, willst du nicht bei jeder
Aenderung einen Tag setzen. Dafuer gibt es den Override — er umgeht Pin und
Cache und nutzt deine Arbeitskopie direkt:

```bash
cmake --preset <dein-preset> -DCMAKECRAFT_LOCAL_DIR=../CMakeCraft
```
