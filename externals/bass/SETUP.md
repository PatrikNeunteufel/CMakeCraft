# BASS beschaffen

**BASS ist nicht Teil dieses Repositorys und kann es nicht sein.** Die
Bibliothek gehört un4seen developments Ltd.; ihre Lizenz schließt
Weiterverbreitung und Unterlizenzierung aus. Betroffen ist das **gesamte SDK** —
Binärdateien ebenso wie Header, Beispiele und Dokumentation.

Dieser Ordner ist deshalb leer bis auf diese Anleitung.

## Brauchst du das überhaupt?

**Für CMakeCraft selbst: nein.** Das Build-System kommt ohne BASS aus, und der
Selbsttest (`cmake --preset craft-selftest`) läuft ohne diesen Schritt sauber
durch — die Phasentests prüfen nur, dass der Local External *definiert und
registriert* ist, nicht dass seine Dateien vorhanden sind.

Gebraucht wird BASS ausschließlich, wenn du zwei **Demo-Executables** der
mitgelieferten Solution bauen willst:

| Target | Optionen in `Solution.json` |
|---|---|
| `MinimalConsole` | `BASS_FLAC` |
| `consolePlayer` | `BASS_FLAC`, `BASS_FX` |

> **Symptom, wenn dieser Schritt fehlt:** Das Konfigurieren läuft sauber durch;
> erst der Build bricht ab, und zwar an der fehlenden Bibliotheksdatei — noch
> bevor irgendetwas übersetzt wird:
> `…/externals/bass/bass24/win/c/x64/bass.lib … missing and no known rule to make it`.

**Du willst die beiden Programme nicht bauen?** Dann setze sie in
`Solution.json` auf `"skip": true` — der Rest der Demo-Solution baut unabhängig
davon. Den External-Eintrag `bass` selbst bitte stehen lassen: Phasentest 5
prüft ihn.

> **Wichtig:** Der Ordner `externals/bass/` muss **existieren**, auch wenn nur
> diese Datei darin liegt. Fehlt er, bricht das Konfigurieren mit
> `E214 Local external 'bass': Path does not exist` ab.

## Lizenz — bitte vorher lesen

BASS ist **kostenlos für nicht-kommerzielle Nutzung**. Sobald du damit Geld
verdienst — Verkauf, Werbung, kommerzieller Vertrieb — brauchst du eine
Lizenz von un4seen. Die Bedingungen stehen in der `bass.txt` des Pakets,
Abschnitt *Licence*, und auf <https://www.un4seen.com/>.

Das gilt unabhängig von der CMakeCraft-Lizenz: CMakeCraft selbst steht unter MIT
bzw. Apache-2.0, BASS nicht. Siehe
[`../../THIRD_PARTY_NOTICES.md`](../../THIRD_PARTY_NOTICES.md).

## Benötigte Pakete

| Paket | Download | Zielordner hier | Wofür |
|---|---|---|---|
| **BASS** 2.4 | <https://www.un4seen.com/bass.html> | `bass24/` | immer |
| **BASSFLAC** | <https://www.un4seen.com/> (Add-ons) | `bassflac24/` | `BASS_FLAC` |
| **BASS_FX** | <https://www.un4seen.com/> (Add-ons) | `bass_fx24/` | `BASS_FX`, nur `consolePlayer` |

Weitere Add-ons (Opus, WMA, WASAPI, MIDI, Mix, DSD, Encoder …) unterstützt
`cmake/externals/includes/bass/Include.cmake` ebenfalls — sie werden nur
gebraucht, wenn du sie in `Solution.json` unter `external_options` einschaltest.
Das Namensschema ist dabei immer dasselbe wie unten.

## Wohin die Dateien gehören

Lade das ZIP je Paket und entpacke es in einen **gleichnamigen Unterordner**
dieses Verzeichnisses. Die ZIP-Struktur von un4seen passt dabei unverändert.

### Windows x64

```
externals/bass/bass24/win/c/bass.h                 ← Header
externals/bass/bass24/win/c/x64/bass.lib           ← Import-Library (Linker)
externals/bass/bass24/win/x64/bass.dll             ← Laufzeit-DLL (wird neben die Exe kopiert)

externals/bass/bassflac24/win/c/bassflac.h
externals/bass/bassflac24/win/c/x64/bassflac.lib
externals/bass/bassflac24/win/x64/bassflac.dll

externals/bass/bass_fx24/win/C/bass_fx.h           ← Achtung: großes C
externals/bass/bass_fx24/win/C/x64/bass_fx.lib
externals/bass/bass_fx24/win/x64/bass_fx.dll
```

> **Zwei häufige Fehler:**
>
> - `win/c/bass.lib` (ohne `x64`) ist die **32-Bit**-Variante. Für einen
>   x64-Build muss die Datei aus dem `x64`-Unterordner kommen.
> - **BASS_FX benutzt ein großes `C`** im Ordnernamen (`win/C/`), alle anderen
>   Pakete ein kleines. Das ist eine Eigenart des un4seen-Archivs; unter Windows
>   fällt es nicht auf, unter Linux und macOS schon.

### Linux x86_64

```
externals/bass/bass24/linux/bass.h
externals/bass/bass24/linux/libs/x86_64/libbass.so

externals/bass/bassflac24/linux/bassflac.h
externals/bass/bassflac24/linux/libs/x86_64/libbassflac.so
```

### macOS

```
externals/bass/bass24/osx/c/bass.h
externals/bass/bass24/osx/libbass.dylib
```

## Prüfen

Nach dem Entpacken muss diese Datei existieren (Windows x64):

```bash
ls externals/bass/bass24/win/c/x64/bass.lib
```

Danach bauen wie in [`../../BUILDING.md`](../../BUILDING.md) beschrieben.

## Warum das nicht automatisch geht

Ein PreFetch-Hook, der die Pakete beim Konfigurieren selbst holt, wäre technisch
möglich — CMakeCraft hat die Infrastruktur dafür
(`cmake/externals/hooks/prefetch/`). Er ist bewusst nicht gebaut: ein
automatischer Download würde die Lizenzentscheidung an dir vorbeitreffen. Wer
BASS nutzt, soll die Bedingungen einmal gesehen haben.

## Hinweis für bestehende Arbeitskopien

Hast du BASS für ein anderes Projekt schon einmal beschafft, kopierst du die
Ordner am schnellsten direkt herüber:

```bash
cp -r <anderer-checkout>/externals/bass/bass24     externals/bass/
cp -r <anderer-checkout>/externals/bass/bassflac24 externals/bass/
```
