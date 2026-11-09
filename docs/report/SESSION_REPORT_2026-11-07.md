# CMakeCraft_Session9_2026-11-07_compile-options-quellpaket

> **Zeitraum:** 2026-11-07 · **Status:** abgeschlossen ·
> **Tests am Ende:** Selbsttest `craft-selftest` 11 von 11 PASSED (Configure Exit 0), Phase 11 auch
> unter Visual Studio 18 / MSVC, auf dem Stand von `v0.14.0`
> **Basis:** `master` @ `2d0656f` → `8b68d25` (v0.14.0); Tag und Branch gepusht (Patrik)
>
> Auftrag aus der LumiViz-Sitzung 174 (CC1 a), über den Sync `../sync_LumiViz_CMakeCraft`
> (Prefix CC). Den Abschnitt „v0.14.0“ hat LV eröffnet und geleitet. Die Freigabe zum Bau hat Patrik
> in LV S174 gegeben und in dieser Sitzung bestätigt. LV hat den Sync am 07.11. 18:09 gestoppt.

## Schwerpunkt

**v0.14.0: Schalter je Bibliothek und Quellpaket ohne CMakeCraft.** LumiViz gibt seine
Rechen-Bibliotheken an InstrumentsCalculation (IC). IC baut mit einfachem CMake, auch unter Linux.
Beide Seiten müssen dieselben Bits rechnen, also müssen die Fließkomma-Schalter mit der Bibliothek
reisen.

## Abstimmung (Entscheide Patrik, „Alle a“)

Der Befund von LV („Heute fehlt“, Datei:Zeile) stimmte. Drei Punkte hat CC zur Entscheidung
vorgelegt:

- **P1 a:** `{ "name", "library" }` ersetzt `contents`. `{version}` ist die Version der Bibliothek.
  `config` und `version_file` ergeben E001.
- **P2 a:** Die Schalter, die Sprachregeln setzen, reisen mit (`/permissive- /Zc:preprocessor
  /Zc:__cplusplus`, `NOMINMAX`, Ausnahmen/RTTI). Warnungen, `/MP` und `/bigobj` reisen nicht mit.
- **P3 a:** Ein lokales External reist mit dem mit, was es am Ziel **hinzugefügt** hat, nicht bloß
  mit dem Include-Ordner. Der Grund war pocketfft: Seine `Include.cmake` setzt
  `POCKETFFT_NO_MULTITHREADING`, mit nur dem Ordner wäre das Define verloren gegangen. Das hat den
  Auftrag berichtigt.

Ergänzt hat CC ohne eigenen Entscheid:
- `CXX_EXTENSIONS` und `CXX_STANDARD_REQUIRED` reisen mit, ebenso PCH und `OUTPUT_NAME`.
- Das `CMakeLists.txt` wird mit `file(WRITE)` statt `file(GENERATE)` geschrieben, damit die
  Generator Expressions wörtlich bleiben.
- Neue Fehlercodes E105 und E106.
- Hinweise an LumiViz: `.gitattributes` für die Bibliotheken (LV-4) und die Grenze bei `libm`.
  LV antwortete auf die Rückfrage zu Abhängigkeiten mit „nein“: Es braucht kein Paket nur aus
  Köpfen.

## Neu und geändert (Commit `8b68d25`)

- **`compile_options` an `libraries[]`:**
  - `LibraryCollect.cmake` 1.1.0 liest das Feld.
  - `LibraryCreate.cmake` 1.1.0 setzt die Schalter PRIVATE, **nach** `apply_compiler_options`. Bei
    INTERFACE gibt es E105.
- **`craft_language_rules()`** (`CompilerOptions.cmake` 1.3.0) ist die einzige Quelle der
  Sprachregel-Schalter für alle Compiler-Familien. `apply_compiler_options` nutzt sie; die Werte am
  Ziel sind gleich geblieben.
- **Beschreibung am Ziel:** `LibraryCreate` hinterlegt `CRAFT_LIB_*`. Vor und nach jedem External
  hält `_craft_target_snapshot` / `_craft_record_external_effect` das Ziel fest, das Ergebnis steht
  in `CRAFT_EXT_<ext>_LINKS`, `_PUBLIC` und `_OTHER`.
- **`SourcePackage.cmake` 1.0.0 (neu):**
  - **Inhalt:** `src/`, `include/` und `externals/<ext>/` (ohne `Include.cmake`).
  - **Erzeugtes `CMakeLists.txt`:**
    - Sprachregeln unter `if(MSVC)` / `elseif(GNU|Clang)`, danach `compile_options` wörtlich in
      Bracket-Argumenten.
    - `cxx_std_<n>`, `CXX_*`, Abhängigkeiten.
    - Externals als `if(NOT TARGET …)`-Block mit Prüfsummen-Wächter.
  - **E106** bei allem, was sich nicht abbilden lässt.
  - `Packages.cmake` 1.1.0 leitet Einträge mit `library` an das Modul weiter.
- **`PackageBuild.cmake` 1.1.0:**
  - **Quellpaket:** Dateien und Ordner kopieren, Ordner-Prüfsumme je External, `VERSION`,
    `SHA256SUMS` (sortiert).
  - **`_craft_pkg_write_lf()`:** Alle Dateien, die das Skript selbst erzeugt, schreibt es mit LF,
    auch die `.zip.sha256` jedes Pakets.
- **Selbsttest Phase 11 (neu):**
  - **Demo:** `CalcDemo` (STATIC, `compile_options` je Compiler-Familie) und das lokale External
    `externals/calcext` mit eigener `Include.cmake`; Define `CALCEXT_NO_THREADS`, sonst `#error`.
  - **Sieben Tests**, bis zu einem Projekt ohne CMakeCraft, das das Paket einbindet, baut und
    ausführt. Dazu E105 und E106 in geschachtelten Configures.
  - **Bytes:** Die erzeugten Dateien werden als Hex auf CR geprüft.
  - `CMakeCraft.cmake` läuft jetzt über die Phasen 1–11.
- **Doku:**
  - **de:** `Solution_Schema` §7 / 0.11.0, `Packages` §2.5 / 1.2.0, `ErrorCodes` 1.6.0, die
    Modul-Dokus zu LibraryCollect, LibraryCreate, Packages, PackageBuild, CompilerOptions, neu
    `SourcePackage.md` und `Phase11_doc.md`, die READMEs.
  - **en:** Ein Hilfsagent hat die englische Seite nachgezogen.
- **Versionsstellen:** `CMakeCraft.cmake` 0.14.0, `Neues_Projekt_Guide` 1.4.0 (Pin-Beispiel),
  `templates/consumer/cmakecraft.pin` (stand noch auf v0.9.2).

## Verifikation

- **Selbsttest:** 11 von 11 nach jedem Schritt, zuletzt nach den Versionsstellen. Der Demo-Baum
  baut unter Ninja/Clang. `package_calcdemo` und `package_packdemo` gebaut; `sha256sum -c` geht
  durch, für `SHA256SUMS` wie für beide `.zip.sha256`.
- **Probe unter VS 18 / MSVC** (Phase 11, Bauordner unter `out/`, danach gelöscht): grün.
  - Im `CalcDemo.vcxproj` des Beziehers stehen `ConformanceMode`, `/Zc:__cplusplus` und
    `FloatingPointModel Precise`, an der Exe des Beziehers keiner dieser Schalter.
  - Unter Clang bekommt die Bibliothek `-std=c++20`, die Exe des Beziehers `gnu++20`. Damit ist
    belegt, dass `CXX_EXTENSIONS` mitreisen muss.
- **Gegenprüfung LumiViz (LV-2)** mit der Probe `IcProbe` (pocketfft) gegen die Arbeitskopie:
  - Die Schalter stehen nur an der Probe; `POCKETFFT_NO_MULTITHREADING` kommt an.
  - Bezieher mit einfachem CMake unter clang 20 und cl 19.51 liefern denselben Abdruck
    `fca0d82358c3be40`.
  - Ein Befund: CRLF in den erzeugten Dateien (siehe unten), danach bestanden.
- **LV-3:** LumiViz holt v0.14.0 von GitHub (Klon `8b68d25`). Der volle Lauf ist 1753 von 1753 unter
  Release-clang und Testing-MSVC.

## Stolperfallen

- **`file(WRITE)` schreibt unter Windows CRLF.** `VERSION`, `CMakeLists.txt`, `SHA256SUMS` und
  `.zip.sha256` hatten CRLF, also scheiterte `sha256sum -c`, und ein Paket unter Linux hätte andere
  Prüfsummen. Abhilfe: `file(CONFIGURE … @ONLY NEWLINE_STYLE LF)`, jedes `@` maskiert. Die
  `.zip.sha256` der Binärpakete war seit v0.10.0 betroffen.
- **`file(READ)` verbirgt das CR unter Windows.** Die erste Fassung von Phase 11 prüfte
  `MATCHES "\r"` und lief trotz CRLF grün. LV fand den Fehler, nicht der Selbsttest. Byteprüfungen
  deshalb mit `file(READ … HEX)` und `^(..)*0d`. Gegenprobe an LVs alter CRLF-Datei: Die Prüfung
  schlägt an.
- **Annahme falsch:** Ich schrieb LV, bei LumiViz gelte `CXX_EXTENSIONS ON`. Das Preset setzt
  `OFF`. Der Mechanismus nahm den echten Wert vom Ziel, nur die Nachricht war falsch.
- **Prüfung traf den eigenen Kommentar:** Test 3 („kein `craft_` im erzeugten Text“) schlug am
  eigenen Kommentar an. Die Prüfung ist jetzt enger (`craft_language`, `CMAKECRAFT_`), der Kommentar
  umformuliert.
- **Hook-Bedarf:** keiner. Die Sperre gegen Backslashes im Heredoc griff zweimal und wurde, wie sie
  es verlangt, über das Edit-Werkzeug umgangen. Der CR-Fehler kam nur einmal vor und ist jetzt
  durch Phase 11 abgedeckt.

## Sync

- **Nachrichten von CC:**
  - Antwort mit P1–P3 (`CC-20261107-1655`) und Leerlauf (`-1657`).
  - Bereit für LV-2 (`-1723`), CRLF behoben (`-1731`).
  - CC-4 vorbereitet (`-1737`), veröffentlicht (`-1743`).
  - 2059 von 4000 Token.
- **`STATUS.md`, Hälfte CC:** CC-1 bis CC-4 erledigt.
- **Abschluss:** LV hat den Sync nach LV-3 auf Patriks Wort gestoppt (18:09). Ein `sync-abschluss`
  war deshalb nicht mehr nötig.

## Offene Punkte / Plan für die nächste Session

1. **Englische Doku hängt hinterher**, schon vor dieser Sitzung (Befund des Hilfsagenten).
   - `LibraryCollect.md`, `LibraryCreate.md`, `CompilerOptions.md`, `buildSystemTest_README.md` und
     Teile von `ErrorCodes.md` unter `en/` sind großenteils deutsch.
   - Einige Kopfverweise (`German:`, `Module:`) zeigen ins Leere.
   - `Phase8_doc.md` und `Phase9_doc.md` fehlen auf Englisch.
   - Der Kopf von `Solution_Schema.md` (de/en) steht noch auf 1.0.0.
2. **Aus dieser Sitzung offen gelassen:**
   - Ein Quellpaket mit zwei Bibliotheken, die dasselbe External mitbringen (Kern und Messung):
     Den Prüfsummen-Wächter prüft noch kein Test, er ist nur im erzeugten Text belegt.
   - Linux ist nicht geprüft; das übernimmt der erste Bau in IC.
3. **Unverändert:**
   - Bauzeit Testing-MSVC (PCH für Test-Ziele).
   - CC-8 Bootstrap.
   - Die Kopie entfernt nichts.
   - `ENABLE_TESTING_CONFIG` wird nicht gelesen.
   - Lange Pfade unter `projects/`, Bass-PreFetch-Hook, `CMakeUserPresets.json` → `.example`,
     Doku-Umzug Phase 2.

---

> **Hinweis zur Ablage:** Der Steckbrief deklariert Session-Reports, Handover und
> Changelog/Logbuch als „—“. Dieser Report liegt wie die vorigen im Fallback-Pfad `docs/report/`.
> Der Changelog steht im Kopf von `CMakeCraft.cmake` und ist mit v0.14.0 nachgezogen.
